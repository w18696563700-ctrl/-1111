import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { UserEntity } from '../identity/entities/user.entity';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { OrganizationEntity } from '../organization/entities/organization.entity';
import { FileAssetEntity } from '../upload/entities/file-asset.entity';
import { ForumDraftEntity } from './entities/forum-draft.entity';
import { ForumPostEntity } from './entities/forum-post.entity';
import { forumDraftUnavailable } from './forum.errors';
import { ForumPresenter } from './forum.presenter';
import { findForumTopic, listForumTopics } from './forum-topic.catalog';

type AuthorSnapshot = {
  authorId: string;
  displayName: string;
  organizationName: string | null;
};

@Injectable()
export class ForumQueryService {
  constructor(
    @InjectRepository(ForumDraftEntity)
    private readonly draftRepository: Repository<ForumDraftEntity>,
    @InjectRepository(ForumPostEntity)
    private readonly postRepository: Repository<ForumPostEntity>,
    @InjectRepository(UserEntity)
    private readonly userRepository: Repository<UserEntity>,
    @InjectRepository(OrganizationEntity)
    private readonly organizationRepository: Repository<OrganizationEntity>,
    @InjectRepository(FileAssetEntity)
    private readonly fileAssetRepository: Repository<FileAssetEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: ForumPresenter
  ) {}

  async getFeed(scope?: string, topicId?: string) {
    const normalizedScope = this.normalizeOptional(scope);
    if (normalizedScope && normalizedScope !== 'all') {
      return this.presenter.toFeedResponse([]);
    }

    const normalizedTopicId = this.normalizeOptional(topicId);
    const posts = await this.postRepository.find({
      where: {
        ...(normalizedTopicId ? { topicId: normalizedTopicId } : {}),
        state: 'published'
      },
      order: { publishedAt: 'DESC', createdAt: 'DESC' }
    });
    if (!posts.length) {
      return this.presenter.toFeedResponse([]);
    }

    const authorSnapshots = await this.buildAuthorSnapshotMap(posts);
    return this.presenter.toFeedResponse(
      posts
        .map((post) => {
          const topic = findForumTopic(post.topicId);
          const author = authorSnapshots.get(post.id);
          if (!topic || !author) {
            return null;
          }

          return {
            postId: post.id,
            topicId: post.topicId,
            topicLabel: topic.title,
            title: post.title,
            excerpt: post.excerpt,
            state: post.state,
            publishedAt: post.publishedAt,
            author,
            engagement: {
              replyCount: 0,
              likeCount: 0,
              viewCount: 0
            }
          };
        })
        .filter((item): item is NonNullable<typeof item> => Boolean(item))
    );
  }

  async getTopicMetadata() {
    return this.presenter.toTopicMetadataResponse(listForumTopics());
  }

  async getTopicList(categoryKey?: string) {
    const topics = listForumTopics(categoryKey);
    if (!topics.length) {
      return this.presenter.toTopicListResponse([]);
    }

    const posts = await this.postRepository.find({
      where: {
        topicId: In(topics.map((item) => item.topicId)),
        state: 'published'
      },
      order: { publishedAt: 'DESC', createdAt: 'DESC' }
    });
    if (!posts.length) {
      return this.presenter.toTopicListResponse([]);
    }

    const latestPostByTopicId = new Map<string, ForumPostEntity>();
    for (const post of posts) {
      if (!latestPostByTopicId.has(post.topicId)) {
        latestPostByTopicId.set(post.topicId, post);
      }
    }
    const authorSnapshots = await this.buildAuthorSnapshotMap([...latestPostByTopicId.values()]);
    return this.presenter.toTopicListResponse(
      topics
        .map((topic) => {
          const latestPost = latestPostByTopicId.get(topic.topicId);
          if (!latestPost) {
            return null;
          }
          const author = authorSnapshots.get(latestPost.id);
          if (!author) {
            return null;
          }
          return {
            topicId: topic.topicId,
            title: topic.title,
            excerpt: latestPost.excerpt,
            categoryKey: topic.categoryKey,
            state: 'published',
            lastActiveAt: latestPost.publishedAt,
            highlightedPostId: latestPost.id,
            author,
            engagement: {
              replyCount: 0,
              likeCount: 0,
              viewCount: 0
            }
          };
        })
        .filter((item): item is NonNullable<typeof item> => Boolean(item))
    );
  }

  async getDraftList(context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    if (!scope) {
      throw forumDraftUnavailable('organizationId is unavailable for forum draft list.');
    }

    const drafts = await this.draftRepository.find({
      where: {
        creatorUserId: currentSession.userId,
        organizationId: scope.organization.id,
        state: In(['draft', 'ready_to_publish'])
      },
      order: { updatedAt: 'DESC', createdAt: 'DESC' }
    });
    if (!drafts.length) {
      return this.presenter.toDraftListResponse([]);
    }

    const attachmentMap = await this.buildAttachmentMap(drafts.flatMap((item) => item.attachmentFileAssetIds));
    return this.presenter.toDraftListResponse(
      drafts.map((draft) => ({
        draft,
        attachmentRefs: draft.attachmentFileAssetIds
          .map((item) => attachmentMap.get(item))
          .filter(
            (item): item is {
              fileAssetId: string;
              fileName: string;
              mimeType: string;
            } => Boolean(item)
          )
      }))
    );
  }

  private async buildAuthorSnapshotMap(posts: ForumPostEntity[]) {
    const authorIds = [...new Set(posts.map((item) => item.authorUserId))];
    const organizationIds = [...new Set(posts.map((item) => item.organizationId))];
    const [users, organizations] = await Promise.all([
      authorIds.length ? this.userRepository.findBy({ id: In(authorIds) }) : [],
      organizationIds.length ? this.organizationRepository.findBy({ id: In(organizationIds) }) : []
    ]);
    const userMap = new Map<string, UserEntity>(
      users.map((item): [string, UserEntity] => [item.id, item])
    );
    const organizationMap = new Map<string, OrganizationEntity>(
      organizations.map((item): [string, OrganizationEntity] => [item.id, item])
    );

    return new Map(
      posts
        .map((post) => {
          const user = userMap.get(post.authorUserId);
          if (!user) {
            return null;
          }
          return [
            post.id,
            {
              authorId: user.id,
              displayName: this.toDisplayName(user),
              organizationName: organizationMap.get(post.organizationId)?.name ?? null
            } satisfies AuthorSnapshot
          ] as const;
        })
        .filter((item): item is readonly [string, AuthorSnapshot] => Boolean(item))
    );
  }

  private async buildAttachmentMap(fileAssetIds: string[]) {
    const normalizedIds = [...new Set(fileAssetIds.map((item) => item.trim()).filter(Boolean))];
    if (!normalizedIds.length) {
      return new Map<string, { fileAssetId: string; fileName: string; mimeType: string }>();
    }

    const fileAssets = await this.fileAssetRepository.findBy({ id: In(normalizedIds) });
    return new Map<string, { fileAssetId: string; fileName: string; mimeType: string }>(
      fileAssets.map(
        (
          item
        ): [string, { fileAssetId: string; fileName: string; mimeType: string }] => [
          item.id,
          {
            fileAssetId: item.id,
            fileName: this.toFileName(item.objectKey),
            mimeType: item.mimeType
          }
        ]
      )
    );
  }

  private toDisplayName(user: UserEntity) {
    const nickname = this.normalizeOptional(user.nickname);
    if (nickname) {
      return nickname;
    }
    const mobileSuffix = user.mobile.trim().slice(-4);
    return mobileSuffix ? `用户${mobileSuffix}` : `用户${user.id.slice(0, 6)}`;
  }

  private toFileName(objectKey: string) {
    const segments = objectKey.split('/');
    const fileName = segments[segments.length - 1]?.trim();
    return fileName || objectKey;
  }

  private normalizeOptional(value?: string | null) {
    const normalized = value?.trim() ?? '';
    return normalized ? normalized : null;
  }
}
