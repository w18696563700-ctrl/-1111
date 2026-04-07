import { Injectable } from '@nestjs/common';
import { ForumDraftEntity } from './entities/forum-draft.entity';
import { ForumPostEntity } from './entities/forum-post.entity';
import { ForumTopicCatalogItem } from './forum-topic.catalog';

type ForumAuthorSummaryInput = {
  authorId: string;
  displayName: string;
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
        viewerHasLiked: false,
        viewerHasBookmarked: false,
        viewerFollowsTopic: false
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

  private toPage() {
    return {
      nextCursor: null,
      hasMore: false
    };
  }
}
