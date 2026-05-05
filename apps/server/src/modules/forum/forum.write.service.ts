import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, In, Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { FileAssetEntity } from '../upload/entities/file-asset.entity';
import { ForumDraftEntity } from './entities/forum-draft.entity';
import { ForumPostEntity } from './entities/forum-post.entity';
import {
  forumDraftInvalid,
  forumDraftUnavailable,
  forumPublishInvalid,
  forumPublishInvalidState
} from './forum.errors';
import { ForumPresenter } from './forum.presenter';
import { findForumTopic } from './forum-topic.catalog';

type SaveDraftCommand = {
  draftId: string | null;
  topicId: string;
  title: string;
  body: string;
  attachmentFileAssetIds: string[];
};

type PublishDraftCommand = {
  draftId: string;
};

type DeleteDraftCommand = {
  draftId: string;
};

type OwnPostCommand = {
  postId: string;
};

@Injectable()
export class ForumWriteService {
  constructor(
    @InjectRepository(ForumDraftEntity)
    private readonly draftRepository: Repository<ForumDraftEntity>,
    @InjectRepository(ForumPostEntity)
    private readonly postRepository: Repository<ForumPostEntity>,
    @InjectRepository(FileAssetEntity)
    private readonly fileAssetRepository: Repository<FileAssetEntity>,
    private readonly dataSource: DataSource,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: ForumPresenter
  ) {}

  async saveDraft(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toSaveDraftCommand(payload);
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    if (!scope) {
      throw forumDraftUnavailable('organizationId is unavailable for forum draft save.');
    }

    const topic = findForumTopic(command.topicId);
    if (!topic) {
      throw forumDraftUnavailable('Forum topic is unavailable for draft save.');
    }
    await this.assertAttachmentAssets(command.attachmentFileAssetIds, currentSession.userId, scope.organization.id);

    const draft = command.draftId
      ? await this.loadEditableDraft(command.draftId, currentSession.userId, scope.organization.id)
      : this.draftRepository.create({
          id: randomUUID(),
          draftNo: this.createDraftNo(),
          organizationId: scope.organization.id,
          creatorUserId: currentSession.userId,
          creatorActorId: currentSession.actorId,
          ownerActorId: currentSession.actorId,
          ownerOrganizationId: scope.organization.id,
          draftType: 'topic',
          targetPostId: null,
          parentCommentId: null,
          publishedPostId: null
        });

    draft.topicId = topic.topicId;
    draft.title = command.title;
    draft.body = command.body;
    draft.attachmentFileAssetIds = command.attachmentFileAssetIds;
    draft.state = 'ready_to_publish';

    const savedDraft = await this.draftRepository.save(draft);
    return this.presenter.toDraftSavedResponse(savedDraft);
  }

  async publishDraft(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toPublishDraftCommand(payload);
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    if (!scope) {
      throw forumPublishInvalidState('Forum draft is unavailable for publish because organizationId is unavailable.');
    }

    const draft = await this.draftRepository.findOneBy({
      id: command.draftId,
      creatorUserId: currentSession.userId,
      organizationId: scope.organization.id
    });
    if (!draft) {
      throw forumPublishInvalidState('Forum draft is unavailable for publish.');
    }
    if (draft.state !== 'ready_to_publish') {
      throw forumPublishInvalidState('Only ready_to_publish drafts may be published.');
    }

    const topic = findForumTopic(draft.topicId);
    if (!topic) {
      throw forumPublishInvalidState('Forum draft topic is unavailable for publish.');
    }

    const publishedAt = new Date();
    const targetPost = draft.targetPostId
      ? await this.loadOwnActionablePost(draft.targetPostId, currentSession.userId, scope.organization.id)
      : null;
    const post =
      targetPost ??
      this.postRepository.create({
        id: randomUUID(),
        postNo: this.createPostNo(),
        organizationId: scope.organization.id,
        authorUserId: currentSession.userId,
        authorActorId: currentSession.actorId,
        authorOrganizationId: scope.organization.id,
        sourceDraftId: draft.id,
        topicId: topic.topicId,
        title: draft.title,
        body: draft.body,
        excerpt: this.presenter.toExcerpt(draft.body),
        attachmentFileAssetIds: draft.attachmentFileAssetIds,
        state: 'published',
        commentCount: 0,
        lastModerationCaseId: null,
        hiddenAt: null,
        archivedAt: null,
        publishedAt
      });

    if (targetPost) {
      post.topicId = topic.topicId;
      post.title = draft.title;
      post.body = draft.body;
      post.excerpt = this.presenter.toExcerpt(draft.body);
      post.attachmentFileAssetIds = draft.attachmentFileAssetIds;
      post.sourceDraftId = draft.id;
    }

    draft.state = 'published';
    draft.publishedPostId = post.id;
    draft.updatedAt = publishedAt;

    await this.dataSource.transaction(async (manager) => {
      await manager.getRepository(ForumPostEntity).save(post);
      await manager.getRepository(ForumDraftEntity).save(draft);
    });

    return this.presenter.toPublishResponse({ draft, post, topic });
  }

  async deleteDraft(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toDeleteDraftCommand(payload);
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    if (!scope) {
      throw forumDraftUnavailable('organizationId is unavailable for forum draft delete.');
    }

    const draft = await this.draftRepository.findOne({
      where: {
        id: command.draftId,
        creatorUserId: currentSession.userId,
        organizationId: scope.organization.id,
        state: In(['draft', 'ready_to_publish'])
      }
    });
    if (!draft) {
      throw forumDraftUnavailable('Forum draft is unavailable for delete.');
    }

    const discardedAt = new Date();
    draft.state = 'deleted';
    draft.discardedAt = discardedAt;
    await this.draftRepository.save(draft);

    return {
      draftId: draft.id,
      state: 'deleted'
    };
  }

  async enterPostEdit(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toOwnPostCommand(payload);
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    if (!scope) {
      throw forumDraftUnavailable('organizationId is unavailable for forum post edit.');
    }

    const post = await this.loadOwnActionablePost(command.postId, currentSession.userId, scope.organization.id);
    const existingDraft = await this.draftRepository.findOne({
      where: {
        creatorUserId: currentSession.userId,
        organizationId: scope.organization.id,
        targetPostId: post.id,
        state: In(['draft', 'ready_to_publish'])
      },
      order: { updatedAt: 'DESC' }
    });
    if (existingDraft) {
      return {
        status: 'resumed_active_edit_draft',
        draftId: existingDraft.id,
        targetPostId: post.id,
        state: existingDraft.state
      };
    }

    const draft = this.draftRepository.create({
      id: randomUUID(),
      draftNo: this.createDraftNo(),
      organizationId: scope.organization.id,
      creatorUserId: currentSession.userId,
      creatorActorId: currentSession.actorId,
      ownerActorId: currentSession.actorId,
      ownerOrganizationId: scope.organization.id,
      draftType: 'topic_edit',
      targetPostId: post.id,
      parentCommentId: null,
      topicId: post.topicId,
      title: post.title,
      body: post.body,
      attachmentFileAssetIds: post.attachmentFileAssetIds,
      state: 'ready_to_publish',
      publishedPostId: null
    });
    const savedDraft = await this.draftRepository.save(draft);
    return {
      status: 'accepted_edit_draft',
      draftId: savedDraft.id,
      targetPostId: post.id,
      state: savedDraft.state
    };
  }

  async deletePost(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toOwnPostCommand(payload);
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    if (!scope) {
      throw forumDraftUnavailable('organizationId is unavailable for forum post delete.');
    }

    const post = await this.loadOwnActionablePost(command.postId, currentSession.userId, scope.organization.id);
    const archivedAt = new Date();
    post.state = 'archived';
    post.archivedAt = archivedAt;
    await this.postRepository.save(post);
    return {
      postId: post.id,
      state: post.state,
      archivedAt: archivedAt.toISOString()
    };
  }

  private async loadEditableDraft(draftId: string, userId: string, organizationId: string) {
    const draft = await this.draftRepository.findOneBy({
      id: draftId,
      creatorUserId: userId,
      organizationId
    });
    if (!draft) {
      throw forumDraftUnavailable('Forum draft is unavailable for save.');
    }
    if (draft.state === 'published') {
      throw forumDraftUnavailable('Forum draft is not editable in the current state.');
    }
    return draft;
  }

  private async loadOwnActionablePost(postId: string, userId: string, organizationId: string) {
    const post = await this.postRepository.findOneBy({
      id: postId,
      authorUserId: userId,
      organizationId,
      state: In(['published', 'hidden'])
    });
    if (!post) {
      throw forumDraftUnavailable('Forum post is unavailable for owner action.');
    }
    return post;
  }

  private createDraftNo() {
    return randomUUID().replace(/-/g, '').toUpperCase();
  }

  private createPostNo() {
    return `FP${randomUUID().replace(/-/g, '').slice(0, 30).toUpperCase()}`;
  }

  private async assertAttachmentAssets(
    attachmentFileAssetIds: string[],
    userId: string,
    organizationId: string
  ) {
    if (!attachmentFileAssetIds.length) {
      return;
    }

    const fileAssets = await this.fileAssetRepository.findBy({
      id: In(attachmentFileAssetIds)
    });
    if (fileAssets.length !== attachmentFileAssetIds.length) {
      throw forumDraftInvalid('attachmentFileAssetIds are invalid for forum draft save.');
    }

    for (const fileAsset of fileAssets) {
      if (fileAsset.userId !== userId || fileAsset.organizationId !== organizationId) {
        throw forumDraftInvalid('attachmentFileAssetIds are invalid for forum draft save.');
      }
    }
  }

  private toSaveDraftCommand(payload: Record<string, unknown>) {
    const source = this.asRecord(payload);
    return {
      draftId: this.readOptionalString(source.draftId),
      topicId: this.readRequiredString(source.topicId, 'topicId'),
      title: this.readRequiredString(source.title, 'title'),
      body: this.readRequiredString(source.body, 'body'),
      attachmentFileAssetIds: this.readAttachmentFileAssetIds(source.attachmentFileAssetIds)
    } satisfies SaveDraftCommand;
  }

  private toPublishDraftCommand(payload: Record<string, unknown>) {
    const source = this.asRecord(payload);
    return {
      draftId: this.readRequiredString(source.draftId, 'draftId')
    } satisfies PublishDraftCommand;
  }

  private toDeleteDraftCommand(payload: Record<string, unknown>) {
    const source = this.asRecord(payload);
    return {
      draftId: this.readRequiredString(source.draftId, 'draftId')
    } satisfies DeleteDraftCommand;
  }

  private toOwnPostCommand(payload: Record<string, unknown>) {
    const source = this.asRecord(payload);
    return {
      postId: this.readRequiredString(source.postId, 'postId')
    } satisfies OwnPostCommand;
  }

  private readRequiredString(value: unknown, field: string) {
    if (typeof value !== 'string') {
      if (field === 'draftId') {
        throw forumPublishInvalid('draftId is required.');
      }
      if (field === 'postId') {
        throw forumDraftInvalid('postId is required for forum post owner action.');
      }
      throw forumDraftInvalid(`${field} is required for forum draft save.`);
    }
    const normalized = value.trim();
    if (!normalized) {
      if (field === 'draftId') {
        throw forumPublishInvalid('draftId is required.');
      }
      if (field === 'postId') {
        throw forumDraftInvalid('postId is required for forum post owner action.');
      }
      throw forumDraftInvalid(`${field} is required for forum draft save.`);
    }
    return normalized;
  }

  private readOptionalString(value: unknown) {
    if (typeof value !== 'string') {
      return null;
    }
    const normalized = value.trim();
    return normalized ? normalized : null;
  }

  private readAttachmentFileAssetIds(value: unknown) {
    if (value === undefined || value === null) {
      return [] satisfies string[];
    }
    if (!Array.isArray(value)) {
      throw forumDraftInvalid('attachmentFileAssetIds are invalid for forum draft save.');
    }

    const normalized = value.map((item) => {
      if (typeof item !== 'string' || !item.trim()) {
        throw forumDraftInvalid('attachmentFileAssetIds are invalid for forum draft save.');
      }
      return item.trim();
    });
    return [...new Set(normalized)];
  }

  private asRecord(value: unknown) {
    if (!value || Array.isArray(value) || typeof value !== 'object') {
      throw forumDraftInvalid('Forum draft payload must be an object.');
    }
    return value as Record<string, unknown>;
  }
}
