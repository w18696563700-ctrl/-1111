import { Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';
import { ServerClientService } from '../../core/http/server-client.service';
import { requireAppApiPath, requireErrorCode } from '../../shared/contracts';
import { ForumCommandContextService } from './forum-command-context.service';
import { ForumCommandErrorService } from './forum-command-error.service';
import { ForumPublishResultService } from './forum-publish-result.service';

type ServerForumFeedResponse = {
  items?: unknown;
  page?: unknown;
};

type ServerForumTopicCard = {
  topicId?: unknown;
  title?: unknown;
  excerpt?: unknown;
  categoryKey?: unknown;
  state?: unknown;
  author?: unknown;
  engagement?: unknown;
  lastActiveAt?: unknown;
  highlightedPostId?: unknown;
};

const FORUM_FEED_ROUTE_CONTRACT = {
  appPath: requireAppApiPath('/api/app/forum/feed'),
  errorCodes: [requireErrorCode('AUTH_SESSION_INVALID')],
} as const;

const FORUM_TOPIC_LIST_ROUTE_CONTRACT = {
  appPath: requireAppApiPath('/api/app/forum/topic/list'),
  errorCodes: [requireErrorCode('AUTH_SESSION_INVALID')],
} as const;

const FORUM_TOPIC_METADATA_ROUTE_CONTRACT = {
  appPath: '/api/app/forum/topic/metadata',
  errorCodes: [requireErrorCode('AUTH_SESSION_INVALID')],
} as const;

const FORUM_TOPIC_DETAIL_ROUTE_CONTRACT = {
  appPath: requireAppApiPath('/api/app/forum/topic/detail'),
  errorCodes: [requireErrorCode('AUTH_SESSION_INVALID'), requireErrorCode('FORUM_TOPIC_UNAVAILABLE')],
} as const;

const FORUM_POST_DETAIL_ROUTE_CONTRACT = {
  appPath: requireAppApiPath('/api/app/forum/post/detail'),
  errorCodes: [requireErrorCode('AUTH_SESSION_INVALID'), requireErrorCode('FORUM_POST_UNAVAILABLE')],
} as const;

const FORUM_POST_COMMENTS_ROUTE_CONTRACT = {
  appPath: '/api/app/forum/post/comments',
  errorCodes: [requireErrorCode('AUTH_SESSION_INVALID'), requireErrorCode('FORUM_POST_UNAVAILABLE')],
} as const;

const FORUM_PUBLISH_ROUTE_CONTRACT = {
  appPath: requireAppApiPath('/api/app/forum/publish'),
  errorCodes: [
    requireErrorCode('AUTH_SESSION_INVALID'),
    requireErrorCode('FORUM_PUBLISH_INVALID'),
    requireErrorCode('FORUM_PUBLISH_INVALID_STATE'),
  ],
} as const;

const FORUM_DRAFT_SAVE_ROUTE_CONTRACT = {
  appPath: '/api/app/forum/draft/save',
  errorCodes: [requireErrorCode('AUTH_SESSION_INVALID')],
} as const;

const FORUM_DRAFT_LIST_ROUTE_CONTRACT = {
  appPath: requireAppApiPath('/api/app/forum/draft/list'),
  errorCodes: [requireErrorCode('AUTH_SESSION_INVALID'), requireErrorCode('FORUM_DRAFT_UNAVAILABLE')],
} as const;

const FORUM_REPORT_SUBMIT_ROUTE_CONTRACT = {
  appPath: '/api/app/forum/report/submit',
  errorCodes: [
    requireErrorCode('AUTH_SESSION_INVALID'),
    requireErrorCode('FORUM_REPORT_INVALID'),
    requireErrorCode('FORUM_POST_UNAVAILABLE'),
  ],
} as const;

const FORUM_SEARCH_ROUTE_CONTRACT = {
  appPath: requireAppApiPath('/api/app/forum/search'),
  errorCodes: [requireErrorCode('AUTH_SESSION_INVALID'), requireErrorCode('FORUM_SEARCH_INVALID')],
} as const;

const FORUM_ME_INDEX_ROUTE_CONTRACT = {
  appPath: requireAppApiPath('/api/app/forum/me/index'),
  errorCodes: [requireErrorCode('AUTH_SESSION_INVALID')],
} as const;

@Injectable()
export class ForumService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly errors: ErrorNormalizerService,
    private readonly forumCommandContext: ForumCommandContextService,
    private readonly forumCommandErrors: ForumCommandErrorService,
    private readonly forumPublishResults: ForumPublishResultService,
  ) {}

  async getFeed(
    headers: IncomingHttpHeaders,
    scope?: string,
    topicId?: string,
    cursor?: string,
    pageSize?: string,
  ) {
    try {
      const routeContract = FORUM_FEED_ROUTE_CONTRACT;
      const result = await this.serverClient.get<Record<string, unknown>>('/server/forum/feed', {
        headers: this.authContext.buildForwardHeaders(headers),
        params: {
          ...this.toCursorParams({ cursor, pageSize }),
          scope: this.asOptionalString(scope),
          topicId: this.asOptionalString(topicId),
        },
      });
      void routeContract;
      return this.shapeFeedResponse(result, topicId);
    } catch (error) {
      throw this.errors.toHttpException(error, 'FORUM_FEED_FAILED', 'Forum feed aggregation failed.');
    }
  }

  async getTopicList(headers: IncomingHttpHeaders, categoryKey?: string, cursor?: string, pageSize?: string) {
    try {
      const routeContract = FORUM_TOPIC_LIST_ROUTE_CONTRACT;
      const result = await this.serverClient.get<Record<string, unknown>>('/server/forum/topic/list', {
        headers: this.authContext.buildForwardHeaders(headers),
        params: {
          ...this.toCursorParams({ cursor, pageSize }),
          categoryKey: this.asOptionalString(categoryKey),
        },
      });
      void routeContract;
      return result;
    } catch (error) {
      throw this.errors.toHttpException(error, 'FORUM_TOPIC_LIST_FAILED', 'Forum topic list aggregation failed.');
    }
  }

  async getTopicMetadata(headers: IncomingHttpHeaders) {
    try {
      const routeContract = FORUM_TOPIC_METADATA_ROUTE_CONTRACT;
      const result = await this.serverClient.get<Record<string, unknown>>('/server/forum/topic/metadata', {
        headers: this.authContext.buildForwardHeaders(headers),
      });
      void routeContract;
      return result;
    } catch (error) {
      throw this.errors.toHttpException(error, 'FORUM_TOPIC_METADATA_FAILED', 'Forum topic metadata aggregation failed.');
    }
  }

  async getTopicDetail(topicId: string, headers: IncomingHttpHeaders) {
    try {
      const routeContract = FORUM_TOPIC_DETAIL_ROUTE_CONTRACT;
      const result = await this.serverClient.get<Record<string, unknown>>('/server/forum/topic/detail', {
        headers: this.authContext.buildForwardHeaders(headers),
        params: {
          topicId: this.asOptionalString(topicId),
        },
      });
      void routeContract;
      return result;
    } catch (error) {
      throw this.errors.toHttpException(error, 'FORUM_TOPIC_DETAIL_FAILED', 'Forum topic detail aggregation failed.');
    }
  }

  async getPostDetail(postId: string, headers: IncomingHttpHeaders) {
    try {
      const routeContract = FORUM_POST_DETAIL_ROUTE_CONTRACT;
      const result = await this.serverClient.get<Record<string, unknown>>('/server/forum/post/detail', {
        headers: this.authContext.buildForwardHeaders(headers),
        params: {
          postId: this.asOptionalString(postId),
        },
      });
      void routeContract;
      return result;
    } catch (error) {
      throw this.errors.toHttpException(error, 'FORUM_POST_DETAIL_FAILED', 'Forum post detail aggregation failed.');
    }
  }

  async getPostComments(postId: string, headers: IncomingHttpHeaders, cursor?: string, pageSize?: string) {
    try {
      const routeContract = FORUM_POST_COMMENTS_ROUTE_CONTRACT;
      const result = await this.serverClient.get<Record<string, unknown>>('/server/forum/post/comments', {
        headers: this.authContext.buildForwardHeaders(headers),
        params: {
          ...this.toCursorParams({ cursor, pageSize }),
          postId: this.asOptionalString(postId),
        },
      });
      void routeContract;
      return result;
    } catch (error) {
      throw this.forumCommandErrors.normalizeInteractionReadError(error, 'post_comments');
    }
  }

  async publishDraft(payload: Record<string, unknown>, headers: IncomingHttpHeaders) {
    try {
      const routeContract = FORUM_PUBLISH_ROUTE_CONTRACT;
      const forwardHeaders = await this.forumCommandContext.buildCommandHeaders(headers);
      const result = await this.serverClient.post<Record<string, unknown>>('/server/forum/publish', payload, {
        headers: forwardHeaders,
      });
      void routeContract;
      return this.forumPublishResults.shapePublishResult(result);
    } catch (error) {
      throw this.forumCommandErrors.normalizePublishError(error);
    }
  }

  async saveDraft(payload: Record<string, unknown>, headers: IncomingHttpHeaders) {
    try {
      const routeContract = FORUM_DRAFT_SAVE_ROUTE_CONTRACT;
      const forwardHeaders = await this.forumCommandContext.buildCommandHeaders(headers);
      const result = await this.serverClient.post<Record<string, unknown>>('/server/forum/draft/save', payload, {
        headers: forwardHeaders,
      });
      void routeContract;
      return result;
    } catch (error) {
      throw this.forumCommandErrors.normalizeDraftSaveError(error);
    }
  }

  async getDraftList(headers: IncomingHttpHeaders, cursor?: string, pageSize?: string) {
    try {
      const routeContract = FORUM_DRAFT_LIST_ROUTE_CONTRACT;
      const forwardHeaders = await this.forumCommandContext.buildCommandHeaders(headers);
      const result = await this.serverClient.get<Record<string, unknown>>('/server/forum/draft/list', {
        headers: forwardHeaders,
        params: this.toCursorParams({ cursor, pageSize }),
      });
      void routeContract;
      return result;
    } catch (error) {
      throw this.errors.toHttpException(error, 'FORUM_DRAFT_LIST_FAILED', 'Forum draft list aggregation failed.');
    }
  }

  getMyComments(headers: IncomingHttpHeaders, cursor?: string, pageSize?: string) {
    return this.getMyAssetList('/server/forum/me/comments', headers, cursor, pageSize);
  }

  getMyBookmarks(headers: IncomingHttpHeaders, cursor?: string, pageSize?: string) {
    return this.getMyAssetList('/server/forum/me/bookmarks', headers, cursor, pageSize);
  }

  getMyLikes(headers: IncomingHttpHeaders, cursor?: string, pageSize?: string) {
    return this.getMyAssetList('/server/forum/me/likes', headers, cursor, pageSize);
  }

  getMyFollows(headers: IncomingHttpHeaders, cursor?: string, pageSize?: string) {
    return this.getMyAssetList('/server/forum/me/follows', headers, cursor, pageSize);
  }

  async submitReport(payload: Record<string, unknown>, headers: IncomingHttpHeaders) {
    try {
      const routeContract = FORUM_REPORT_SUBMIT_ROUTE_CONTRACT;
      const forwardHeaders = await this.forumCommandContext.buildCommandHeaders(headers);
      const result = await this.serverClient.post<Record<string, unknown>>('/server/forum/report/submit', payload, {
        headers: forwardHeaders,
      });
      void routeContract;
      return result;
    } catch (error) {
      throw this.forumCommandErrors.normalizeReportSubmitError(error);
    }
  }

  async search(q: string, headers: IncomingHttpHeaders, cursor?: string, pageSize?: string) {
    try {
      const routeContract = FORUM_SEARCH_ROUTE_CONTRACT;
      const result = await this.serverClient.get<Record<string, unknown>>('/server/forum/search', {
        headers: this.authContext.buildForwardHeaders(headers),
        params: {
          ...this.toCursorParams({ cursor, pageSize }),
          q: this.asOptionalString(q),
        },
      });
      void routeContract;
      return result;
    } catch (error) {
      throw this.errors.toHttpException(error, 'FORUM_SEARCH_FAILED', 'Forum search aggregation failed.');
    }
  }

  async getMeIndex(headers: IncomingHttpHeaders) {
    try {
      const routeContract = FORUM_ME_INDEX_ROUTE_CONTRACT;
      const result = await this.serverClient.get<Record<string, unknown>>('/server/forum/me/index', {
        headers: this.authContext.buildForwardHeaders(headers),
      });
      void routeContract;
      return result;
    } catch (error) {
      throw this.errors.toHttpException(error, 'FORUM_ME_INDEX_FAILED', 'Forum me index aggregation failed.');
    }
  }

  private toCursorParams(input: { cursor?: string; pageSize?: string }) {
    return {
      cursor: this.asOptionalString(input.cursor),
      pageSize: this.asOptionalString(input.pageSize),
    };
  }

  private async getMyAssetList(
    serverPath: string,
    headers: IncomingHttpHeaders,
    cursor?: string,
    pageSize?: string,
  ) {
    try {
      const forwardHeaders = await this.forumCommandContext.buildCommandHeaders(headers);
      return await this.serverClient.get<Record<string, unknown>>(serverPath, {
        headers: forwardHeaders,
        params: this.toCursorParams({ cursor, pageSize }),
      });
    } catch (error) {
      throw this.errors.toHttpException(error, 'FORUM_ME_ASSET_FAILED', 'Forum me asset aggregation failed.');
    }
  }

  private asOptionalString(value: unknown): string | undefined {
    return typeof value === 'string' && value.trim().length > 0 ? value.trim() : undefined;
  }

  private shapeFeedResponse(result: Record<string, unknown>, topicId?: string) {
    const body = result as ServerForumFeedResponse;
    const items = Array.isArray(body.items) ? body.items : null;
    if (!items || items.length === 0) {
      return result;
    }

    const shapedItems = items.map((item) => this.shapeFeedItem(item)).filter((item) => item !== null);
    const effectiveTopicId = this.asOptionalString(topicId);

    return {
      ...result,
      items:
        effectiveTopicId === undefined
          ? shapedItems
          : shapedItems.filter((item) => item.topicId === effectiveTopicId),
    };
  }

  private shapeFeedItem(raw: unknown) {
    if (this.looksLikePostFeedItem(raw)) {
      return raw as Record<string, unknown>;
    }

    if (!this.looksLikeTopicCard(raw)) {
      return null;
    }

    const item = raw as ServerForumTopicCard;
    const topicId = this.asOptionalString(item.topicId);
    const title = this.asOptionalString(item.title);
    const excerpt = this.asOptionalString(item.excerpt);
    const state = this.asOptionalString(item.state);
    const publishedAt = this.asOptionalString(item.lastActiveAt);
    const postId = this.asOptionalString(item.highlightedPostId);

    if (!topicId || !title || !excerpt || !state || !publishedAt || !postId) {
      return null;
    }

    return {
      postId,
      topicId,
      topicLabel: this.resolveTopicLabel(item.categoryKey, title),
      title,
      excerpt,
      state,
      author: this.asRecord(item.author),
      engagement: this.asRecord(item.engagement),
      publishedAt,
      viewerHasLiked: false,
      viewerHasBookmarked: false,
      viewerFollowsTopic: false,
    };
  }

  private looksLikePostFeedItem(raw: unknown) {
    const body = this.asRecord(raw);
    return (
      typeof body.postId === 'string' &&
      typeof body.topicId === 'string' &&
      typeof body.topicLabel === 'string' &&
      typeof body.title === 'string' &&
      typeof body.excerpt === 'string' &&
      typeof body.publishedAt === 'string'
    );
  }

  private looksLikeTopicCard(raw: unknown) {
    const body = this.asRecord(raw);
    return (
      typeof body.topicId === 'string' &&
      typeof body.title === 'string' &&
      typeof body.excerpt === 'string' &&
      typeof body.highlightedPostId === 'string' &&
      typeof body.lastActiveAt === 'string'
    );
  }

  private resolveTopicLabel(categoryKey: unknown, fallbackTitle: string) {
    const key = this.asOptionalString(categoryKey);
    if (key === 'expo') {
      return '布展进场';
    }
    if (key === 'material') {
      return '材料协同';
    }
    if (key === 'local') {
      return '本地供应链';
    }
    if (key === 'night_shift') {
      return '施工夜班';
    }
    return fallbackTitle;
  }

  private asRecord(value: unknown): Record<string, unknown> {
    return value && typeof value === 'object' ? (value as Record<string, unknown>) : {};
  }
}
