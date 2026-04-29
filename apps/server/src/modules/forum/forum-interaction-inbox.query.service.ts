import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, LessThan, Not, Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { ForumAuthorFollowEntity } from './entities/forum-author-follow.entity';
import { ForumCommentEntity } from './entities/forum-comment.entity';
import { ForumPostEntity } from './entities/forum-post.entity';
import { ForumPostLikeEntity } from './entities/forum-post-like.entity';
import { ForumAuthorProjectionService } from './forum-author-projection.service';
import { forumInteractionInboxInvalid, forumInteractionUnavailable } from './forum.errors';
import {
  ForumInteractionInboxItemInput,
  ForumInteractionInboxPresenter,
  ForumInteractionInboxTab
} from './forum-interaction-inbox.presenter';

type CurrentForumInboxActor = {
  userId: string;
  organizationId: string;
};

@Injectable()
export class ForumInteractionInboxQueryService {
  constructor(
    @InjectRepository(ForumCommentEntity)
    private readonly commentRepository: Repository<ForumCommentEntity>,
    @InjectRepository(ForumPostEntity)
    private readonly postRepository: Repository<ForumPostEntity>,
    @InjectRepository(ForumPostLikeEntity)
    private readonly likeRepository: Repository<ForumPostLikeEntity>,
    @InjectRepository(ForumAuthorFollowEntity)
    private readonly authorFollowRepository: Repository<ForumAuthorFollowEntity>,
    private readonly authorProjectionService: ForumAuthorProjectionService,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: ForumInteractionInboxPresenter
  ) {}

  async getInteractionInbox(
    tab: string | undefined,
    cursor: string | undefined,
    pageSize: string | undefined,
    context: RequestContext
  ) {
    const normalizedTab = this.normalizeTab(tab);
    const actor = await this.requireCurrentInboxActor(context);
    const limit = this.normalizePageSize(pageSize);
    const cursorDate = this.normalizeCursor(cursor);

    if (normalizedTab === 'replies') {
      return this.getReplyInbox(actor, cursorDate, limit);
    }
    if (normalizedTab === 'likes') {
      return this.getLikeInbox(actor, cursorDate, limit);
    }
    return this.getFollowInbox(actor, cursorDate, limit);
  }

  private async getReplyInbox(
    actor: CurrentForumInboxActor,
    cursorDate: Date | null,
    limit: number
  ) {
    const [ownedPosts, ownComments] = await Promise.all([
      this.postRepository.find({
        where: {
          authorUserId: actor.userId,
          organizationId: actor.organizationId,
          state: 'published'
        },
        order: { publishedAt: 'DESC', createdAt: 'DESC' }
      }),
      this.commentRepository.find({
        where: {
          authorUserId: actor.userId,
          organizationId: actor.organizationId,
          state: 'published'
        },
        order: { publishedAt: 'DESC', createdAt: 'DESC' }
      })
    ]);
    const ownedPostIds = ownedPosts.map((post) => post.id);
    const ownCommentIds = ownComments.map((comment) => comment.id);
    const where = [
      ...(ownedPostIds.length
        ? [
            {
              postId: In(ownedPostIds),
              authorUserId: Not(actor.userId),
              state: 'published',
              ...this.toPublishedCursor(cursorDate)
            }
          ]
        : []),
      ...(ownCommentIds.length
        ? [
            {
              parentCommentId: In(ownCommentIds),
              authorUserId: Not(actor.userId),
              state: 'published',
              ...this.toPublishedCursor(cursorDate)
            }
          ]
        : [])
    ];
    if (!where.length) {
      return this.presenter.toResponse([]);
    }

    const comments = await this.commentRepository.find({
      where,
      order: { publishedAt: 'DESC', createdAt: 'DESC' },
      take: limit + 1
    });
    const candidates = this.uniqueById(comments)
      .filter((comment) => comment.authorUserId !== actor.userId)
      .sort((left, right) => this.compareDesc(left.publishedAt, right.publishedAt));
    const visible = candidates.slice(0, limit);
    if (!visible.length) {
      return this.presenter.toResponse([], this.toPage(visible, candidates.length, limit));
    }

    const posts = await this.postRepository.find({
      where: {
        id: In([...new Set(visible.map((comment) => comment.postId))]),
        state: 'published'
      }
    });
    const postMap = new Map(posts.map((post): [string, ForumPostEntity] => [post.id, post]));
    const authorSnapshots = await this.authorProjectionService.buildAuthorSnapshotMap(visible);
    return this.presenter.toResponse(
      this.buildReplyItems(visible, postMap, authorSnapshots, new Set(ownCommentIds)),
      this.toPage(visible, candidates.length, limit)
    );
  }

  private buildReplyItems(
    comments: ForumCommentEntity[],
    postMap: Map<string, ForumPostEntity>,
    authorSnapshots: Map<string, ForumInteractionInboxItemInput['actor']>,
    ownCommentIds: Set<string>
  ) {
    return comments
      .map((comment): ForumInteractionInboxItemInput | null => {
        const post = postMap.get(comment.postId);
        const author = authorSnapshots.get(comment.id);
        if (!post || !author) {
          return null;
        }
        const targetsOwnComment =
          comment.parentCommentId !== null && ownCommentIds.has(comment.parentCommentId);
        return {
          notificationId: `forum-reply:${comment.id}`,
          tab: 'replies',
          actor: author,
          targetType: 'forum_post',
          targetId: post.id,
          title: targetsOwnComment ? `${author.displayName}回复了你的评论` : `${author.displayName}评论了你的帖子`,
          preview: this.toPreview(comment.body),
          createdAt: comment.publishedAt,
          canQuickReply: false
        } satisfies ForumInteractionInboxItemInput;
      })
      .filter((item): item is ForumInteractionInboxItemInput => Boolean(item));
  }

  private async getLikeInbox(
    actor: CurrentForumInboxActor,
    cursorDate: Date | null,
    limit: number
  ) {
    const ownedPosts = await this.postRepository.find({
      where: {
        authorUserId: actor.userId,
        organizationId: actor.organizationId,
        state: 'published'
      },
      order: { publishedAt: 'DESC', createdAt: 'DESC' }
    });
    if (!ownedPosts.length) {
      return this.presenter.toResponse([]);
    }

    const postMap = new Map(ownedPosts.map((post): [string, ForumPostEntity] => [post.id, post]));
    const likes = await this.likeRepository.find({
      where: {
        postId: In([...postMap.keys()]),
        userId: Not(actor.userId),
        ...this.toCreatedCursor(cursorDate)
      },
      order: { createdAt: 'DESC' },
      take: limit + 1
    });
    const candidates = likes
      .filter((like) => like.userId !== actor.userId)
      .sort((left, right) => this.compareDesc(left.createdAt, right.createdAt));
    const visible = candidates.slice(0, limit);
    if (!visible.length) {
      return this.presenter.toResponse([], this.toPage(visible, candidates.length, limit));
    }

    const authorSnapshots = await this.authorProjectionService.buildAuthorSnapshotMap(
      visible.map((like) => ({
        id: like.id,
        authorUserId: like.userId,
        organizationId: like.organizationId
      }))
    );
    return this.presenter.toResponse(
      visible
        .map((like): ForumInteractionInboxItemInput | null => {
          const post = postMap.get(like.postId);
          const author = authorSnapshots.get(like.id);
          return post && author
            ? ({
                notificationId: `forum-like:${like.id}`,
                tab: 'likes',
                actor: author,
                targetType: 'forum_post',
                targetId: post.id,
                title: `${author.displayName}赞了你的帖子`,
                preview: post.title,
                createdAt: like.createdAt,
                canQuickReply: false
              } satisfies ForumInteractionInboxItemInput)
            : null;
        })
        .filter((item): item is ForumInteractionInboxItemInput => Boolean(item)),
      this.toPage(visible, candidates.length, limit)
    );
  }

  private async getFollowInbox(
    actor: CurrentForumInboxActor,
    cursorDate: Date | null,
    limit: number
  ) {
    const [follows, latestPost] = await Promise.all([
      this.authorFollowRepository.find({
        where: {
          targetAuthorUserId: actor.userId,
          targetOrganizationId: actor.organizationId,
          followerUserId: Not(actor.userId),
          ...this.toCreatedCursor(cursorDate)
        },
        order: { createdAt: 'DESC' },
        take: limit + 1
      }),
      this.postRepository.findOne({
        where: {
          authorUserId: actor.userId,
          organizationId: actor.organizationId,
          state: 'published'
        },
        order: { publishedAt: 'DESC', createdAt: 'DESC' }
      })
    ]);
    if (!latestPost) {
      return this.presenter.toResponse([]);
    }

    const candidates = follows
      .filter((follow) => follow.followerUserId !== actor.userId)
      .sort((left, right) => this.compareDesc(left.createdAt, right.createdAt));
    const visible = candidates.slice(0, limit);
    if (!visible.length) {
      return this.presenter.toResponse([], this.toPage(visible, candidates.length, limit));
    }

    const authorSnapshots = await this.authorProjectionService.buildAuthorSnapshotMap(
      visible.map((follow) => ({
        id: follow.id,
        authorUserId: follow.followerUserId,
        organizationId: follow.followerOrganizationId
      }))
    );
    return this.presenter.toResponse(
      visible
        .map((follow): ForumInteractionInboxItemInput | null => {
          const author = authorSnapshots.get(follow.id);
          return author
            ? ({
                notificationId: `forum-follow:${follow.id}`,
                tab: 'follows',
                actor: author,
                targetType: 'forum_post',
                targetId: latestPost.id,
                title: `${author.displayName}关注了你`,
                preview: latestPost.title,
                createdAt: follow.createdAt,
                canQuickReply: false
              } satisfies ForumInteractionInboxItemInput)
            : null;
        })
        .filter((item): item is ForumInteractionInboxItemInput => Boolean(item)),
      this.toPage(visible, candidates.length, limit)
    );
  }

  private async requireCurrentInboxActor(context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    if (!scope) {
      throw forumInteractionUnavailable('organizationId is unavailable for forum interaction inbox.');
    }
    return {
      userId: currentSession.userId,
      organizationId: scope.organization.id
    } satisfies CurrentForumInboxActor;
  }

  private normalizeTab(value: string | undefined) {
    const normalized = value?.trim();
    if (normalized === 'replies' || normalized === 'likes' || normalized === 'follows') {
      return normalized as ForumInteractionInboxTab;
    }
    throw forumInteractionInboxInvalid('tab must be one of replies, likes, follows.');
  }

  private normalizePageSize(value: string | undefined) {
    const parsed = typeof value === 'string' ? Number.parseInt(value, 10) : NaN;
    if (!Number.isInteger(parsed)) {
      return 20;
    }
    return Math.min(Math.max(parsed, 1), 50);
  }

  private normalizeCursor(value: string | undefined) {
    const normalized = value?.trim() ?? '';
    if (!normalized) {
      return null;
    }
    const parsed = new Date(normalized);
    return Number.isNaN(parsed.getTime()) ? null : parsed;
  }

  private toPublishedCursor(cursorDate: Date | null) {
    return cursorDate ? { publishedAt: LessThan(cursorDate) } : {};
  }

  private toCreatedCursor(cursorDate: Date | null) {
    return cursorDate ? { createdAt: LessThan(cursorDate) } : {};
  }

  private toPage(
    items: Array<{ publishedAt?: Date; createdAt?: Date }>,
    sourceLength: number,
    limit: number
  ) {
    const last = items[items.length - 1];
    return {
      nextCursor: sourceLength > limit ? (last?.publishedAt ?? last?.createdAt ?? null)?.toISOString() ?? null : null,
      hasMore: sourceLength > limit
    };
  }

  private uniqueById(comments: ForumCommentEntity[]) {
    return [...new Map(comments.map((comment): [string, ForumCommentEntity] => [comment.id, comment])).values()];
  }

  private compareDesc(left: Date, right: Date) {
    return right.getTime() - left.getTime();
  }

  private toPreview(value: string) {
    const normalized = value.trim().replace(/\s+/g, ' ');
    if (!normalized) {
      return null;
    }
    return normalized.length <= 80 ? normalized : `${normalized.slice(0, 80)}...`;
  }
}
