import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, LessThan, Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { NotificationService } from '../notifications/notification.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { ForumAuthorFollowEntity } from './entities/forum-author-follow.entity';
import { ForumCommentEntity } from './entities/forum-comment.entity';
import { ForumPostBookmarkEntity } from './entities/forum-post-bookmark.entity';
import { ForumPostEntity } from './entities/forum-post.entity';
import { ForumPostLikeEntity } from './entities/forum-post-like.entity';
import { ForumAuthorProjectionService } from './forum-author-projection.service';
import {
  forumAuthorUnavailable,
  forumCommentInvalid,
  forumCommentInvalidState,
  forumPostUnavailable
} from './forum.errors';
import { ForumPresenter } from './forum.presenter';

type CommentCreateCommand = {
  postId: string;
  parentCommentId: string | null;
  body: string;
};

@Injectable()
export class ForumCommentService {
  constructor(
    @InjectRepository(ForumPostEntity)
    private readonly postRepository: Repository<ForumPostEntity>,
    @InjectRepository(ForumCommentEntity)
    private readonly commentRepository: Repository<ForumCommentEntity>,
    @InjectRepository(ForumPostLikeEntity)
    private readonly likeRepository: Repository<ForumPostLikeEntity>,
    @InjectRepository(ForumPostBookmarkEntity)
    private readonly bookmarkRepository: Repository<ForumPostBookmarkEntity>,
    @InjectRepository(ForumAuthorFollowEntity)
    private readonly authorFollowRepository: Repository<ForumAuthorFollowEntity>,
    private readonly dataSource: DataSource,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly authorProjectionService: ForumAuthorProjectionService,
    private readonly presenter: ForumPresenter,
    private readonly notificationService: NotificationService
  ) {}

  async getPostComments(postId?: string, cursor?: string, pageSize?: string) {
    const normalizedPostId = this.normalizeRequiredPostId(postId, 'forum post comments');
    const post = await this.postRepository.findOneBy({
      id: normalizedPostId,
      state: 'published'
    });
    if (!post) {
      throw forumPostUnavailable('Forum post is unavailable for comments.');
    }

    const limit = this.normalizePageSize(pageSize, 10, 50);
    const cursorDate = this.normalizeCursor(cursor);
    const comments = await this.commentRepository.find({
      where: {
        postId: normalizedPostId,
        state: 'published',
        ...(cursorDate ? { publishedAt: LessThan(cursorDate) } : {})
      },
      order: { publishedAt: 'DESC', createdAt: 'DESC' },
      take: limit + 1
    });
    const visibleComments = comments.slice(0, limit);
    if (!visibleComments.length) {
      return this.presenter.toCommentListPagedResponse([], this.toPage(visibleComments, comments.length, limit));
    }

    const authorSnapshots = await this.authorProjectionService.buildAuthorSnapshotMap(visibleComments);
    return this.presenter.toCommentListPagedResponse(
      visibleComments
        .map((comment) => {
          const author = authorSnapshots.get(comment.id);
          return author ? { comment, author } : null;
        })
        .filter((item): item is NonNullable<typeof item> => Boolean(item)),
      this.toPage(visibleComments, comments.length, limit)
    );
  }

  async createComment(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toCommentCreateCommand(payload);
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    if (!scope) {
      throw forumCommentInvalidState('organizationId is unavailable for forum comment interaction.');
    }

    const post = await this.postRepository.findOneBy({
      id: command.postId,
      state: 'published'
    });
    if (!post) {
      throw forumPostUnavailable('Forum post is unavailable for interaction.');
    }
    let parentComment: ForumCommentEntity | null = null;
    if (command.parentCommentId) {
      parentComment = await this.commentRepository.findOneBy({
        id: command.parentCommentId,
        postId: command.postId,
        state: 'published'
      });
      if (!parentComment) {
        throw forumCommentInvalidState('parentCommentId is unavailable for forum comment submit.');
      }
    }

    const publishedAt = new Date();
    const comment = this.commentRepository.create({
      id: randomUUID(),
      postId: post.id,
      parentCommentId: command.parentCommentId,
      organizationId: scope.organization.id,
      authorUserId: currentSession.userId,
      authorActorId: currentSession.actorId ?? null,
      body: command.body,
      state: 'published',
      publishedAt
    });

    await this.dataSource.transaction(async (manager) => {
      await manager.getRepository(ForumCommentEntity).save(comment);
      await manager.getRepository(ForumPostEntity).increment({ id: post.id }, 'commentCount', 1);
      await this.notificationService.createForumInteractionNotification(
        {
          tab: 'replies',
          title: '有新的论坛回复',
          body: parentComment ? '有人回复了你的评论。' : '有人评论了你的帖子。',
          recipientUserId: parentComment?.authorUserId ?? post.authorUserId,
          recipientOrganizationId: parentComment?.organizationId ?? post.organizationId,
          actorUserId: currentSession.userId,
          targetId: post.id
        },
        manager
      );
    });

    return this.presenter.toCommentAcceptedResponse(comment);
  }

  async deferLike(payload: Record<string, unknown>, context: RequestContext) {
    const source = this.asRecord(payload);
    const postId = this.normalizeRequiredPostId(source.postId, 'forum post like');
    const shouldLike = this.readToggleAction(source.action, 'like', 'unlike', 'forum post like');
    const actor = await this.requireAuthenticatedInteraction(context, 'forum post like');
    const post = await this.requirePublishedPost(postId, 'Forum post is unavailable for like interaction.');

    await this.dataSource.transaction(async (manager) => {
      const likeRepository = manager.getRepository(ForumPostLikeEntity);
      const existing = await likeRepository.findOneBy({
        postId,
        userId: actor.userId
      });
      if (shouldLike && !existing) {
        await likeRepository.save(
          likeRepository.create({
            id: randomUUID(),
            postId,
            userId: actor.userId,
            actorId: actor.actorId,
            organizationId: actor.organizationId
          })
        );
        await this.notificationService.createForumInteractionNotification(
          {
            tab: 'likes',
            title: '有新的论坛点赞',
            body: '有人点赞了你的帖子。',
            recipientUserId: post.authorUserId,
            recipientOrganizationId: post.organizationId,
            actorUserId: actor.userId,
            targetId: post.id
          },
          manager
        );
      }
      if (!shouldLike && existing) {
        await likeRepository.delete({ id: existing.id });
      }
    });

    return this.presenter.toPostLikeToggleResponse({
      postId,
      viewerHasLiked: shouldLike,
      likeCount: await this.likeRepository.countBy({ postId })
    });
  }

  async deferBookmark(payload: Record<string, unknown>, context: RequestContext) {
    const source = this.asRecord(payload);
    const postId = this.normalizeRequiredPostId(source.postId, 'forum post bookmark');
    const shouldBookmark = this.readToggleAction(source.action, 'add', 'remove', 'forum post bookmark');
    const actor = await this.requireAuthenticatedInteraction(context, 'forum post bookmark');
    await this.requirePublishedPost(postId, 'Forum post is unavailable for bookmark interaction.');

    const existing = await this.bookmarkRepository.findOneBy({
      postId,
      userId: actor.userId
    });
    if (shouldBookmark && !existing) {
      await this.bookmarkRepository.save(
        this.bookmarkRepository.create({
          id: randomUUID(),
          postId,
          userId: actor.userId,
          actorId: actor.actorId,
          organizationId: actor.organizationId
        })
      );
    }
    if (!shouldBookmark && existing) {
      await this.bookmarkRepository.delete({ id: existing.id });
    }

    return this.presenter.toPostBookmarkToggleResponse({
      postId,
      viewerHasBookmarked: shouldBookmark
    });
  }

  async toggleAuthorFollow(payload: Record<string, unknown>, context: RequestContext) {
    const source = this.asRecord(payload);
    const targetAuthorId = this.readRequiredString(source.authorId, 'authorId is required for forum author follow.');
    const shouldFollow = this.readToggleAction(source.action, 'follow', 'unfollow', 'forum author follow');
    const actor = await this.requireAuthenticatedInteraction(context, 'forum author follow');
    if (targetAuthorId === actor.userId) {
      throw forumCommentInvalidState('Current actor cannot follow itself.');
    }
    const latestPost = await this.postRepository.findOne({
      where: { authorUserId: targetAuthorId, state: 'published' },
      order: { publishedAt: 'DESC', createdAt: 'DESC' }
    });
    if (!latestPost) {
      throw forumAuthorUnavailable('Forum public author is unavailable for follow.');
    }

    await this.dataSource.transaction(async (manager) => {
      const authorFollowRepository = manager.getRepository(ForumAuthorFollowEntity);
      const existing = await authorFollowRepository.findOneBy({
        followerUserId: actor.userId,
        targetAuthorUserId: targetAuthorId
      });
      if (shouldFollow && !existing) {
        await authorFollowRepository.save(
          authorFollowRepository.create({
            id: randomUUID(),
            followerUserId: actor.userId,
            followerActorId: actor.actorId,
            followerOrganizationId: actor.organizationId,
            targetAuthorUserId: targetAuthorId,
            targetOrganizationId: latestPost.organizationId
          })
        );
        await this.notificationService.createForumInteractionNotification(
          {
            tab: 'follows',
            title: '有新的论坛关注',
            body: '有人关注了你。',
            recipientUserId: targetAuthorId,
            recipientOrganizationId: latestPost.organizationId,
            actorUserId: actor.userId,
            targetId: targetAuthorId
          },
          manager
        );
      }
      if (!shouldFollow && existing) {
        await authorFollowRepository.delete({ id: existing.id });
      }
    });

    return this.presenter.toAuthorFollowToggleResponse({
      authorId: targetAuthorId,
      viewerFollowsAuthor: shouldFollow
    });
  }

  private async requireAuthenticatedInteraction(context: RequestContext, surface: string) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    if (!scope) {
      throw forumCommentInvalidState(`organizationId is unavailable for ${surface}.`);
    }
    return {
      userId: currentSession.userId,
      actorId: currentSession.actorId ?? null,
      organizationId: scope.organization.id
    };
  }

  private async requirePublishedPost(postId: string, message: string) {
    const post = await this.postRepository.findOneBy({
      id: postId,
      state: 'published'
    });
    if (!post) {
      throw forumPostUnavailable(message);
    }
    return post;
  }

  private toCommentCreateCommand(payload: Record<string, unknown>) {
    const source = this.asRecord(payload);
    return {
      postId: this.normalizeRequiredPostId(source.postId, 'forum comment submit'),
      parentCommentId: this.readOptionalString(source.parentCommentId),
      body: this.readCommentBody(source.body)
    } satisfies CommentCreateCommand;
  }

  private normalizeRequiredPostId(value: unknown, surface: string) {
    if (typeof value !== 'string') {
      throw forumCommentInvalid(`postId is required for ${surface}.`);
    }
    const normalized = value.trim();
    if (!normalized) {
      throw forumCommentInvalid(`postId is required for ${surface}.`);
    }
    return normalized;
  }

  private readCommentBody(value: unknown) {
    if (typeof value !== 'string') {
      throw forumCommentInvalid('body is required for forum comment submit.');
    }
    const normalized = value.trim();
    if (!normalized) {
      throw forumCommentInvalid('body is required for forum comment submit.');
    }
    if (normalized.length > 500) {
      throw forumCommentInvalid('body is too long for forum comment submit.');
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

  private readRequiredString(value: unknown, message: string) {
    if (typeof value !== 'string') {
      throw forumCommentInvalid(message);
    }
    const normalized = value.trim();
    if (!normalized) {
      throw forumCommentInvalid(message);
    }
    return normalized;
  }

  private readToggleAction(value: unknown, positive: string, negative: string, surface: string) {
    const action = this.readRequiredString(value, `action is required for ${surface}.`);
    if (action === positive) {
      return true;
    }
    if (action === negative) {
      return false;
    }
    throw forumCommentInvalid(`action is invalid for ${surface}.`);
  }

  private normalizePageSize(value: string | undefined, fallback: number, max: number) {
    const parsed = typeof value === 'string' ? Number.parseInt(value, 10) : NaN;
    if (!Number.isInteger(parsed)) {
      return fallback;
    }
    return Math.min(Math.max(parsed, 1), max);
  }

  private normalizeCursor(value?: string) {
    const normalized = value?.trim() ?? '';
    if (!normalized) {
      return null;
    }
    const parsed = new Date(normalized);
    return Number.isNaN(parsed.getTime()) ? null : parsed;
  }

  private toPage(items: ForumCommentEntity[], sourceLength: number, limit: number) {
    return {
      nextCursor: sourceLength > limit ? items[items.length - 1]?.publishedAt.toISOString() ?? null : null,
      hasMore: sourceLength > limit
    };
  }

  private asRecord(value: unknown) {
    if (!value || Array.isArray(value) || typeof value !== 'object') {
      throw forumCommentInvalid('Forum comment payload must be an object.');
    }
    return value as Record<string, unknown>;
  }
}
