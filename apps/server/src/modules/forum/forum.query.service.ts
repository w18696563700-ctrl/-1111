import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import {
  requireVerifiedCurrentSessionContext,
  VerifiedCurrentSessionContext
} from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { FileAssetEntity } from '../upload/entities/file-asset.entity';
import { ForumAuthorFollowEntity } from './entities/forum-author-follow.entity';
import { ForumCommentEntity } from './entities/forum-comment.entity';
import { ForumDraftEntity } from './entities/forum-draft.entity';
import { ForumPostBookmarkEntity } from './entities/forum-post-bookmark.entity';
import { ForumPostEntity } from './entities/forum-post.entity';
import { ForumPostLikeEntity } from './entities/forum-post-like.entity';
import { ForumAuthorProjectionService } from './forum-author-projection.service';
import { forumDraftUnavailable, forumPostUnavailable } from './forum.errors';
import { ForumPresenter } from './forum.presenter';
import { findForumTopic, listForumTopics } from './forum-topic.catalog';

@Injectable()
export class ForumQueryService {
  constructor(
    @InjectRepository(ForumDraftEntity)
    private readonly draftRepository: Repository<ForumDraftEntity>,
    @InjectRepository(ForumCommentEntity)
    private readonly commentRepository: Repository<ForumCommentEntity>,
    @InjectRepository(ForumPostEntity)
    private readonly postRepository: Repository<ForumPostEntity>,
    @InjectRepository(ForumPostLikeEntity)
    private readonly likeRepository: Repository<ForumPostLikeEntity>,
    @InjectRepository(ForumPostBookmarkEntity)
    private readonly bookmarkRepository: Repository<ForumPostBookmarkEntity>,
    @InjectRepository(ForumAuthorFollowEntity)
    private readonly authorFollowRepository: Repository<ForumAuthorFollowEntity>,
    @InjectRepository(FileAssetEntity)
    private readonly fileAssetRepository: Repository<FileAssetEntity>,
    private readonly authorProjectionService: ForumAuthorProjectionService,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: ForumPresenter
  ) {}

  async getFeed(scope?: string, topicId?: string, context?: RequestContext) {
    const normalizedScope = this.normalizeOptional(scope);
    if (
      normalizedScope &&
      normalizedScope !== 'all' &&
      normalizedScope !== 'square' &&
      normalizedScope !== 'local' &&
      normalizedScope !== 'following'
    ) {
      return this.presenter.toFeedResponse([]);
    }

    const followedAuthorIds =
      normalizedScope === 'following' ? await this.resolveFollowedAuthorIds(context) : null;
    if (followedAuthorIds !== null && !followedAuthorIds.length) {
      return this.presenter.toFeedResponse([]);
    }

    const normalizedTopicId = this.normalizeOptional(topicId);
    const posts = await this.postRepository.find({
      where: {
        ...(normalizedTopicId ? { topicId: normalizedTopicId } : {}),
        ...(followedAuthorIds !== null ? { authorUserId: In(followedAuthorIds) } : {}),
        state: 'published'
      },
      order: { publishedAt: 'DESC', createdAt: 'DESC' }
    });
    if (!posts.length) {
      return this.presenter.toFeedResponse([]);
    }

    const [authorSnapshots, interactionSummary] = await Promise.all([
      this.authorProjectionService.buildAuthorSnapshotMap(posts),
      this.buildPostInteractionSummary(posts, context)
    ]);
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
              replyCount: post.commentCount,
              likeCount: interactionSummary.likeCountByPostId.get(post.id) ?? 0,
              viewCount: 0
            },
            viewerHasLiked: interactionSummary.viewerLikedPostIds.has(post.id),
            viewerHasBookmarked: interactionSummary.viewerBookmarkedPostIds.has(post.id)
          };
        })
        .filter((item): item is NonNullable<typeof item> => Boolean(item))
    );
  }

  private async resolveFollowedAuthorIds(context?: RequestContext) {
    if (!context) {
      return [] satisfies string[];
    }
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    const follows = await this.authorFollowRepository.find({
      where: { followerUserId: currentSession.userId },
      order: { createdAt: 'DESC' }
    });
    return [...new Set(follows.map((follow) => follow.targetAuthorUserId).filter(Boolean))];
  }

  async getTopicMetadata() {
    return this.presenter.toTopicMetadataResponse(listForumTopics());
  }

  async getTopicList(categoryKey?: string, context?: RequestContext) {
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
    const latestPosts = [...latestPostByTopicId.values()];
    const [authorSnapshots, interactionSummary] = await Promise.all([
      this.authorProjectionService.buildAuthorSnapshotMap(latestPosts),
      this.buildPostInteractionSummary(latestPosts, context)
    ]);
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
              replyCount: latestPost.commentCount,
              likeCount: interactionSummary.likeCountByPostId.get(latestPost.id) ?? 0,
              viewCount: 0
            }
          };
        })
        .filter((item): item is NonNullable<typeof item> => Boolean(item))
    );
  }

  async getTopicDetail(topicId?: string, context?: RequestContext) {
    const topic = findForumTopic(topicId);
    if (!topic) {
      throw forumPostUnavailable('Forum topic is unavailable for detail.');
    }

    const leadPost = await this.postRepository.findOne({
      where: {
        topicId: topic.topicId,
        state: 'published'
      },
      order: { publishedAt: 'DESC', createdAt: 'DESC' }
    });
    if (!leadPost) {
      throw forumPostUnavailable('Forum topic has no published post for detail.');
    }

    const [authorSnapshots, interactionSummary] = await Promise.all([
      this.authorProjectionService.buildAuthorSnapshotMap([leadPost]),
      this.buildPostInteractionSummary([leadPost], context)
    ]);
    const author = authorSnapshots.get(leadPost.id);
    if (!author) {
      throw forumPostUnavailable('Forum topic lead post author is unavailable.');
    }

    void interactionSummary;
    return this.presenter.toTopicDetailResponse({ topic, leadPost, author });
  }

  async getPostDetail(postId?: string, context?: RequestContext) {
    const normalizedPostId = this.normalizeOptional(postId);
    if (!normalizedPostId) {
      throw forumPostUnavailable('postId is required for forum post detail.');
    }

    const post = await this.postRepository.findOneBy({
      id: normalizedPostId,
      state: 'published'
    });
    if (!post) {
      throw forumPostUnavailable('Forum post is unavailable for detail.');
    }

    const topic = findForumTopic(post.topicId);
    const [authorSnapshots, interactionSummary] = await Promise.all([
      this.authorProjectionService.buildAuthorSnapshotMap([post]),
      this.buildPostInteractionSummary([post], context)
    ]);
    const author = authorSnapshots.get(post.id);
    if (!topic || !author) {
      throw forumPostUnavailable('Forum post detail projection is unavailable.');
    }

    const attachmentMap = await this.buildAttachmentMap(post.attachmentFileAssetIds);
    return {
      ...this.presenter.toPostDetailResponse({
      post,
      topic,
      author,
      attachmentRefs: post.attachmentFileAssetIds
        .map((item) => attachmentMap.get(item))
        .filter(
          (item): item is {
            fileAssetId: string;
            fileName: string;
            mimeType: string;
          } => Boolean(item)
        )
      }),
      viewerHasLiked: interactionSummary.viewerLikedPostIds.has(post.id),
      viewerHasBookmarked: interactionSummary.viewerBookmarkedPostIds.has(post.id),
      engagement: {
        replyCount: post.commentCount,
        likeCount: interactionSummary.likeCountByPostId.get(post.id) ?? 0,
        viewCount: 0
      }
    };
  }

  async search(q?: string) {
    const keyword = this.normalizeOptional(q)?.toLowerCase();
    if (!keyword) {
      return this.presenter.toSearchResponse([]);
    }

    const posts = await this.postRepository.find({
      where: {
        state: 'published'
      },
      order: { publishedAt: 'DESC', createdAt: 'DESC' }
    });
    const matchedPosts = posts.filter((post) =>
      [post.title, post.excerpt, post.body].some((value) => value.toLowerCase().includes(keyword))
    );
    if (!matchedPosts.length) {
      return this.presenter.toSearchResponse([]);
    }

    const authorSnapshots = await this.authorProjectionService.buildAuthorSnapshotMap(matchedPosts);
    return this.presenter.toSearchResponse(
      matchedPosts
        .map((post) => {
          const topic = findForumTopic(post.topicId);
          const author = authorSnapshots.get(post.id);
          return topic && author ? { post, topic, author } : null;
        })
        .filter((item): item is NonNullable<typeof item> => Boolean(item))
    );
  }

  async getMeIndex(context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    if (!scope) {
      throw forumDraftUnavailable('organizationId is unavailable for my forum index.');
    }

    const [postCount, draftCount] = await Promise.all([
      this.postRepository.countBy({
        authorUserId: currentSession.userId,
        organizationId: scope.organization.id,
        state: In(['published', 'hidden'])
      }),
      this.draftRepository.countBy({
        creatorUserId: currentSession.userId,
        organizationId: scope.organization.id,
        state: In(['draft', 'ready_to_publish'])
      })
    ]);

    return this.presenter.toMeIndexResponse({
      memberId: currentSession.userId,
      postCount,
      draftCount
    });
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

  async getDraftDetail(draftId: string | undefined, context: RequestContext) {
    const normalizedDraftId = this.normalizeOptional(draftId);
    if (!normalizedDraftId) {
      throw forumDraftUnavailable('draftId is required for forum draft detail.');
    }

    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    if (!scope) {
      throw forumDraftUnavailable('organizationId is unavailable for forum draft detail.');
    }

    const draft = await this.draftRepository.findOneBy({
      id: normalizedDraftId,
      creatorUserId: currentSession.userId,
      organizationId: scope.organization.id,
      state: In(['draft', 'ready_to_publish'])
    });
    if (!draft) {
      throw forumDraftUnavailable('Forum draft is unavailable for detail.');
    }

    return this.presenter.toDraftDetailResponse(draft);
  }

  async getMyPosts(context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    if (!scope) {
      throw forumDraftUnavailable('organizationId is unavailable for my forum posts.');
    }

    const posts = await this.postRepository.find({
      where: {
        authorUserId: currentSession.userId,
        organizationId: scope.organization.id,
        state: In(['published', 'hidden'])
      },
      order: { updatedAt: 'DESC', createdAt: 'DESC' }
    });

    return this.presenter.toMyPostListResponse(posts);
  }

  async getMyComments(context: RequestContext) {
    const currentSession = await this.requireCurrentForumAssetScope(context, 'my forum comments');
    const comments = await this.commentRepository.find({
      where: {
        authorUserId: currentSession.userId,
        state: 'published'
      },
      order: { publishedAt: 'DESC', createdAt: 'DESC' }
    });
    if (!comments.length) {
      return this.presenter.toCommentAssetListResponse([]);
    }

    const posts = await this.postRepository.findBy({
      id: In([...new Set(comments.map((item) => item.postId))]),
      state: 'published'
    });
    const postMap = new Map(posts.map((post): [string, ForumPostEntity] => [post.id, post]));
    const authorSnapshots = await this.authorProjectionService.buildAuthorSnapshotMap(comments);
    return this.presenter.toCommentAssetListResponse(
      comments
        .map((comment) => {
          const post = postMap.get(comment.postId);
          const topic = post ? findForumTopic(post.topicId) : null;
          const author = authorSnapshots.get(comment.id);
          return post && topic && author ? { comment, post, topic, author } : null;
        })
        .filter((item): item is NonNullable<typeof item> => Boolean(item))
    );
  }

  async getMyBookmarks(context: RequestContext) {
    const currentSession = await this.requireCurrentForumAssetScope(context, 'my forum bookmarks');
    const bookmarks = await this.bookmarkRepository.find({
      where: { userId: currentSession.userId },
      order: { createdAt: 'DESC' }
    });
    return this.buildPostAssetList(bookmarks.map((item) => item.postId));
  }

  async getMyLikes(context: RequestContext) {
    const currentSession = await this.requireCurrentForumAssetScope(context, 'my forum likes');
    const likes = await this.likeRepository.find({
      where: { userId: currentSession.userId },
      order: { createdAt: 'DESC' }
    });
    return this.buildPostAssetList(likes.map((item) => item.postId));
  }

  async getMyFollows(context: RequestContext) {
    const currentSession = await this.requireCurrentForumAssetScope(context, 'my forum follows');
    const follows = await this.authorFollowRepository.find({
      where: { followerUserId: currentSession.userId },
      order: { createdAt: 'DESC' }
    });
    if (!follows.length) {
      return this.presenter.toAuthorFollowListResponse([]);
    }

    const authorSnapshots = await this.authorProjectionService.buildAuthorSnapshotMap(
      follows.map((follow) => ({
        id: follow.id,
        authorUserId: follow.targetAuthorUserId,
        organizationId: follow.targetOrganizationId
      }))
    );
    const targetAuthorIds = follows.map((item) => item.targetAuthorUserId);
    const [postCountRows, commentCountRows] = await Promise.all([
      this.countPostsByAuthor(targetAuthorIds),
      this.countCommentsByAuthor(targetAuthorIds)
    ]);
    return this.presenter.toAuthorFollowListResponse(
      follows
        .map((follow) => {
          const author = authorSnapshots.get(follow.id);
          return author
            ? {
                follow,
                author,
                publicPostCount: postCountRows.get(follow.targetAuthorUserId) ?? 0,
                publicCommentCount: commentCountRows.get(follow.targetAuthorUserId) ?? 0
              }
            : null;
        })
        .filter((item): item is NonNullable<typeof item> => Boolean(item))
    );
  }

  private async buildPostAssetList(postIds: string[]) {
    const orderedPostIds = postIds.map((item) => item.trim()).filter(Boolean);
    if (!orderedPostIds.length) {
      return this.presenter.toPostCardListResponse([]);
    }
    const posts = await this.postRepository.findBy({
      id: In([...new Set(orderedPostIds)]),
      state: 'published'
    });
    const postMap = new Map(posts.map((post): [string, ForumPostEntity] => [post.id, post]));
    const orderedPosts = orderedPostIds
      .map((postId) => postMap.get(postId))
      .filter((post): post is ForumPostEntity => Boolean(post));
    if (!orderedPosts.length) {
      return this.presenter.toPostCardListResponse([]);
    }

    const authorSnapshots = await this.authorProjectionService.buildAuthorSnapshotMap(orderedPosts);
    return this.presenter.toPostCardListResponse(
      orderedPosts
        .map((post) => {
          const topic = findForumTopic(post.topicId);
          const author = authorSnapshots.get(post.id);
          return topic && author ? { post, topic, author } : null;
        })
        .filter((item): item is NonNullable<typeof item> => Boolean(item))
    );
  }

  private async buildPostInteractionSummary(posts: ForumPostEntity[], context?: RequestContext) {
    const postIds = posts.map((item) => item.id);
    if (!postIds.length) {
      return {
        likeCountByPostId: new Map<string, number>(),
        viewerLikedPostIds: new Set<string>(),
        viewerBookmarkedPostIds: new Set<string>()
      };
    }
    const likeCountByPostId = await this.countLikesByPost(postIds);
    const viewer = await this.resolveOptionalViewer(context);
    if (!viewer) {
      return {
        likeCountByPostId,
        viewerLikedPostIds: new Set<string>(),
        viewerBookmarkedPostIds: new Set<string>()
      };
    }

    const [likes, bookmarks] = await Promise.all([
      this.likeRepository.findBy({ userId: viewer.userId, postId: In(postIds) }),
      this.bookmarkRepository.findBy({ userId: viewer.userId, postId: In(postIds) })
    ]);
    return {
      likeCountByPostId,
      viewerLikedPostIds: new Set(likes.map((item) => item.postId)),
      viewerBookmarkedPostIds: new Set(bookmarks.map((item) => item.postId))
    };
  }

  private async countLikesByPost(postIds: string[]) {
    if (!postIds.length) {
      return new Map<string, number>();
    }
    const rows = (await this.likeRepository
      .createQueryBuilder('item')
      .select('item.postId', 'postId')
      .addSelect('COUNT(*)', 'count')
      .where('item.postId IN (:...postIds)', { postIds })
      .groupBy('item.postId')
      .getRawMany()) as Array<{ postId?: string; count?: string }>;
    return new Map(
      rows
        .map((row): [string, number] | null => {
          const postId = row.postId?.trim();
          if (!postId) {
            return null;
          }
          return [postId, Number.parseInt(row.count ?? '0', 10) || 0];
        })
        .filter((item): item is [string, number] => Boolean(item))
    );
  }

  private async countPostsByAuthor(authorIds: string[]) {
    return this.countRowsByAuthor(this.postRepository, 'post', authorIds);
  }

  private async countCommentsByAuthor(authorIds: string[]) {
    return this.countRowsByAuthor(this.commentRepository, 'comment', authorIds);
  }

  private async countRowsByAuthor(
    repository: Repository<{ authorUserId: string }>,
    alias: string,
    authorIds: string[]
  ) {
    const normalizedAuthorIds = [...new Set(authorIds.map((item) => item.trim()).filter(Boolean))];
    if (!normalizedAuthorIds.length) {
      return new Map<string, number>();
    }
    const rows = (await repository
      .createQueryBuilder(alias)
      .select(`${alias}.authorUserId`, 'authorUserId')
      .addSelect('COUNT(*)', 'count')
      .where(`${alias}.authorUserId IN (:...authorIds)`, { authorIds: normalizedAuthorIds })
      .andWhere(`${alias}.state = :state`, { state: 'published' })
      .groupBy(`${alias}.authorUserId`)
      .getRawMany()) as Array<{ authorUserId?: string; count?: string }>;
    return new Map(
      rows
        .map((row): [string, number] | null => {
          const authorUserId = row.authorUserId?.trim();
          if (!authorUserId) {
            return null;
          }
          return [authorUserId, Number.parseInt(row.count ?? '0', 10) || 0];
        })
        .filter((item): item is [string, number] => Boolean(item))
    );
  }

  private async resolveOptionalViewer(context?: RequestContext): Promise<VerifiedCurrentSessionContext | null> {
    if (!context) {
      return null;
    }
    if (context.authorization.trim()) {
      const result = await this.currentSessionVerificationService.verifyCurrentSessionContext(context);
      return result.outcome === 'verified' ? result.currentSession : null;
    }
    const userId = context.userId.trim();
    if (!userId) {
      return null;
    }
    return {
      sessionId: '',
      actorId: context.actorId.trim() || userId,
      userId,
      organizationId: context.organizationId.trim() || null,
      requestId: context.requestId,
      traceId: context.traceId
    };
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

  private toFileName(objectKey: string) {
    const segments = objectKey.split('/');
    const fileName = segments[segments.length - 1]?.trim();
    return fileName || objectKey;
  }

  private normalizeOptional(value?: string | null) {
    const normalized = value?.trim() ?? '';
    return normalized ? normalized : null;
  }

  private async requireCurrentForumAssetScope(context: RequestContext, assetName: string) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    if (!scope) {
      throw forumDraftUnavailable(`organizationId is unavailable for ${assetName}.`);
    }
    return currentSession;
  }
}
