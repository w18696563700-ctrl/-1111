import { Injectable } from '@nestjs/common';
import { ForumAuthorFollowEntity } from './entities/forum-author-follow.entity';
import { ForumCommentEntity } from './entities/forum-comment.entity';
import { ForumDraftEntity } from './entities/forum-draft.entity';
import { ForumPostEntity } from './entities/forum-post.entity';
import { findForumTopic, ForumTopicCatalogItem } from './forum-topic.catalog';

type ForumAuthorSummaryInput = {
  authorId: string;
  displayName: string;
  avatarUrl: string | null;
  organizationName: string | null;
};

type ForumEngagementSummaryInput = {
  replyCount: number;
  likeCount: number;
  viewCount: number;
};

type ForumFeedItemInput = {
  postId: string;
  topicId: string;
  topicLabel: string;
  title: string;
  excerpt: string;
  state: string;
  publishedAt: Date;
  author: ForumAuthorSummaryInput;
  engagement: ForumEngagementSummaryInput;
  viewerHasLiked?: boolean;
  viewerHasBookmarked?: boolean;
};

type ForumTopicCardInput = {
  topicId: string;
  title: string;
  excerpt: string;
  categoryKey: string;
  state: string;
  lastActiveAt: Date;
  highlightedPostId: string | null;
  author: ForumAuthorSummaryInput;
  engagement: ForumEngagementSummaryInput;
};

type ForumDraftCardInput = {
  draft: ForumDraftEntity;
  attachmentRefs: {
    fileAssetId: string;
    fileName: string;
    mimeType: string;
  }[];
};

type ForumPostDetailInput = {
  post: ForumPostEntity;
  topic: ForumTopicCatalogItem;
  author: ForumAuthorSummaryInput;
  attachmentRefs: {
    fileAssetId: string;
    fileName: string;
    mimeType: string;
  }[];
};

type ForumTopicDetailInput = {
  topic: ForumTopicCatalogItem;
  leadPost: ForumPostEntity;
  author: ForumAuthorSummaryInput;
};

type ForumSearchResultInput = {
  post: ForumPostEntity;
  topic: ForumTopicCatalogItem;
  author: ForumAuthorSummaryInput;
};

type ForumCommentInput = {
  comment: ForumCommentEntity;
  author: ForumAuthorSummaryInput;
};

type ForumPostCardInput = {
  post: ForumPostEntity;
  topic: ForumTopicCatalogItem;
  author: ForumAuthorSummaryInput;
};

type ForumCommentAssetInput = {
  comment: ForumCommentEntity;
  post: ForumPostEntity;
  topic: ForumTopicCatalogItem;
  author: ForumAuthorSummaryInput;
};

type ForumAuthorFollowInput = {
  follow: ForumAuthorFollowEntity;
  author: ForumAuthorSummaryInput;
  publicPostCount: number;
  publicCommentCount: number;
};

@Injectable()
export class ForumPresenter {
  toTopicMetadataResponse(items: ForumTopicCatalogItem[]) {
    return {
      items: items.map((item) => ({
        topicId: item.topicId,
        title: item.title,
        description: item.description,
        selected: false
      }))
    };
  }

  toTopicListResponse(items: ForumTopicCardInput[]) {
    return {
      items: items.map((item) => ({
        topicId: item.topicId,
        title: item.title,
        excerpt: item.excerpt,
        categoryKey: item.categoryKey,
        state: item.state,
        author: item.author,
        engagement: item.engagement,
        lastActiveAt: item.lastActiveAt.toISOString(),
        highlightedPostId: item.highlightedPostId
      })),
      page: this.toPage()
    };
  }

  toFeedResponse(items: ForumFeedItemInput[]) {
    return {
      items: items.map((item) => ({
        postId: item.postId,
        topicId: item.topicId,
        topicLabel: item.topicLabel,
        title: item.title,
        excerpt: item.excerpt,
        state: item.state,
        author: item.author,
        engagement: item.engagement,
        publishedAt: item.publishedAt.toISOString(),
        viewerHasLiked: item.viewerHasLiked === true,
        viewerHasBookmarked: item.viewerHasBookmarked === true,
        viewerFollowsTopic: false
      })),
      page: this.toPage()
    };
  }

  toTopicDetailResponse(input: ForumTopicDetailInput) {
    return {
      topicId: input.topic.topicId,
      title: input.topic.title,
      categoryKey: input.topic.categoryKey,
      state: 'published',
      author: input.author,
      engagement: {
        replyCount: input.leadPost.commentCount,
        likeCount: 0,
        viewCount: 0
      },
      leadPostId: input.leadPost.id,
      leadPostExcerpt: input.leadPost.excerpt,
      publishedAt: input.leadPost.publishedAt.toISOString(),
      lastActiveAt: input.leadPost.updatedAt.toISOString()
    };
  }

  toPostDetailResponse(input: ForumPostDetailInput) {
    return {
      postId: input.post.id,
      topicId: input.topic.topicId,
      topicTitle: input.topic.title,
      state: input.post.state,
      author: input.author,
      content: input.post.body,
      attachmentRefs: input.attachmentRefs,
      publishedAt: input.post.publishedAt.toISOString(),
      viewerHasLiked: false,
      viewerHasBookmarked: false,
      viewerFollowsTopic: false,
      engagement: {
        replyCount: input.post.commentCount,
        likeCount: 0,
        viewCount: 0
      }
    };
  }

  toCommentListResponse(items: ForumCommentInput[]) {
    return this.toCommentListPagedResponse(items);
  }

  toCommentListPagedResponse(
    items: ForumCommentInput[],
    page: { nextCursor: string | null; hasMore: boolean } = this.toPage()
  ) {
    return {
      items: items.map((item) => ({
        commentId: item.comment.id,
        postId: item.comment.postId,
        parentCommentId: item.comment.parentCommentId,
        author: item.author,
        body: item.comment.body,
        state: item.comment.state,
        publishedAt: item.comment.publishedAt.toISOString(),
        replyCount: 0
      })),
      page
    };
  }

  toCommentAcceptedResponse(comment: ForumCommentEntity) {
    return {
      commentId: comment.id,
      postId: comment.postId,
      state: 'published',
      publishedAt: comment.publishedAt.toISOString()
    };
  }

  toPostLikeToggleResponse(input: {
    postId: string;
    viewerHasLiked: boolean;
    likeCount: number;
  }) {
    return {
      targetId: input.postId,
      state: input.viewerHasLiked ? 'liked' : 'unliked',
      viewerHasLiked: input.viewerHasLiked,
      likeCount: input.likeCount
    };
  }

  toPostBookmarkToggleResponse(input: {
    postId: string;
    viewerHasBookmarked: boolean;
  }) {
    return {
      targetId: input.postId,
      state: input.viewerHasBookmarked ? 'bookmarked' : 'unbookmarked',
      viewerHasBookmarked: input.viewerHasBookmarked
    };
  }

  toAuthorFollowToggleResponse(input: {
    authorId: string;
    viewerFollowsAuthor: boolean;
  }) {
    return {
      targetId: input.authorId,
      state: input.viewerFollowsAuthor ? 'followed' : 'unfollowed',
      viewerFollowsAuthor: input.viewerFollowsAuthor
    };
  }

  toAuthorProfileResponse(input: {
    author: ForumAuthorSummaryInput;
    publicPostCount: number;
    publicCommentCount: number;
    viewerFollowsAuthor?: boolean;
  }) {
    return {
      authorId: input.author.authorId,
      displayName: input.author.displayName,
      avatarUrl: input.author.avatarUrl,
      organizationName: input.author.organizationName,
      publicPostCount: input.publicPostCount,
      publicCommentCount: input.publicCommentCount,
      viewerFollowsAuthor: input.viewerFollowsAuthor === true
    };
  }

  toPostCardListResponse(items: ForumPostCardInput[]) {
    return {
      items: items.map((item) => ({
        postId: item.post.id,
        topicId: item.topic.topicId,
        topicTitle: item.topic.title,
        excerpt: item.post.excerpt,
        state: item.post.state,
        author: item.author,
        publishedAt: item.post.publishedAt.toISOString()
      })),
      page: this.toPage()
    };
  }

  toCommentAssetListResponse(items: ForumCommentAssetInput[]) {
    return {
      items: items.map((item) => ({
        postId: item.post.id,
        postTitle: item.post.title,
        topicId: item.topic.topicId,
        topicLabel: item.topic.title,
        comment: {
          commentId: item.comment.id,
          postId: item.comment.postId,
          parentCommentId: item.comment.parentCommentId,
          author: item.author,
          body: item.comment.body,
          state: item.comment.state,
          publishedAt: item.comment.publishedAt.toISOString(),
          replyCount: 0
        }
      })),
      page: this.toPage()
    };
  }

  toAuthorFollowListResponse(items: ForumAuthorFollowInput[]) {
    return {
      items: items.map((item) => ({
        followId: item.follow.id,
        authorId: item.author.authorId,
        displayName: item.author.displayName,
        avatarUrl: item.author.avatarUrl,
        organizationName: item.author.organizationName,
        followedAt: item.follow.createdAt.toISOString(),
        publicPostCount: item.publicPostCount,
        publicCommentCount: item.publicCommentCount,
        viewerFollowsAuthor: true
      })),
      page: this.toPage()
    };
  }

  toPublicAuthorPostListResponse(
    posts: ForumPostEntity[],
    page: { nextCursor: string | null; hasMore: boolean } = this.toPage()
  ) {
    return {
      items: posts.map((post) => ({
        postId: post.id,
        title: post.title,
        topicId: post.topicId,
        topicTitle: this.toTopicTitle(post.topicId),
        excerpt: post.excerpt,
        state: post.state,
        publishedAt: post.publishedAt.toISOString(),
        updatedAt: post.updatedAt.toISOString(),
        canEdit: false,
        canDelete: false
      })),
      page
    };
  }

  toSearchResponse(items: ForumSearchResultInput[]) {
    return {
      items: items.map((item) => ({
        resultType: 'post',
        topicId: item.topic.topicId,
        postId: item.post.id,
        title: item.post.title,
        excerpt: item.post.excerpt,
        author: item.author,
        publishedAt: item.post.publishedAt.toISOString()
      })),
      page: this.toPage()
    };
  }

  toDraftListResponse(items: ForumDraftCardInput[]) {
    return {
      items: items.map((item) => ({
        draftId: item.draft.id,
        draftType: item.draft.draftType,
        topicId: item.draft.topicId,
        title: item.draft.title,
        excerpt: this.toExcerpt(item.draft.body),
        state: item.draft.state,
        updatedAt: item.draft.updatedAt.toISOString(),
        attachmentRefs: item.attachmentRefs
      })),
      page: this.toPage()
    };
  }

  toDraftSavedResponse(draft: ForumDraftEntity) {
    return {
      draftId: draft.id,
      state: draft.state,
      updatedAt: draft.updatedAt.toISOString()
    };
  }

  toDraftDetailResponse(draft: ForumDraftEntity) {
    return {
      draftId: draft.id,
      draftType: draft.draftType,
      targetPostId: draft.targetPostId,
      topicId: draft.topicId,
      title: draft.title,
      body: draft.body,
      attachmentFileAssetIds: draft.attachmentFileAssetIds,
      state: draft.state,
      updatedAt: draft.updatedAt.toISOString()
    };
  }

  toMyPostListResponse(posts: ForumPostEntity[]) {
    return {
      items: posts.map((post) => {
        const topic = post.topicId ? this.toTopicTitle(post.topicId) : null;
        const ownerActionable = post.state === 'published' || post.state === 'hidden';
        return {
          postId: post.id,
          title: post.title,
          topicId: post.topicId,
          topicTitle: topic,
          excerpt: post.excerpt,
          state: post.state,
          publishedAt: post.publishedAt.toISOString(),
          updatedAt: post.updatedAt.toISOString(),
          canEdit: ownerActionable,
          canDelete: ownerActionable
        };
      }),
      page: this.toPage()
    };
  }

  toMeIndexResponse(input: {
    memberId: string;
    postCount: number;
    draftCount: number;
  }) {
    return {
      memberId: input.memberId,
      summary: {
        topicCount: 0,
        postCount: input.postCount,
        draftCount: input.draftCount,
        unreadReplyCount: 0
      },
      recentTopics: [],
      recentPosts: [],
      recentDrafts: []
    };
  }

  toEmptyPagedResponse() {
    return {
      items: [],
      page: this.toPage()
    };
  }

  toPublishResponse(input: {
    draft: ForumDraftEntity;
    post: ForumPostEntity;
    topic: ForumTopicCatalogItem;
  }) {
    return {
      draftId: input.draft.id,
      topicId: input.topic.topicId,
      postId: input.post.id,
      state: 'published',
      decision: 'clear',
      message: '发布成功',
      summary: {
        title: input.post.title,
        publishedAt: input.post.publishedAt.toISOString()
      }
    };
  }

  toExcerpt(body: string) {
    const normalized = body.trim().replace(/\s+/g, ' ');
    if (normalized.length <= 72) {
      return normalized;
    }
    return `${normalized.slice(0, 72)}...`;
  }

  private toPage(page?: { nextCursor: string | null; hasMore: boolean }) {
    if (page) {
      return page;
    }
    return {
      nextCursor: null,
      hasMore: false
    };
  }

  private toTopicTitle(topicId: string) {
    return findForumTopic(topicId)?.title ?? topicId;
  }
}
