import { Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ServerClientService } from '../../core/http/server-client.service';
import { ForumCommandErrorService } from './forum-command-error.service';

type ServerForumAuthorProfileResponse = {
  authorId?: unknown;
  displayName?: unknown;
  avatarUrl?: unknown;
  organizationName?: unknown;
  publicPostCount?: unknown;
  publicCommentCount?: unknown;
};

type ServerForumAuthorPostsResponse = {
  items?: unknown;
  page?: unknown;
};

type ServerForumPostCard = {
  postId?: unknown;
  topicId?: unknown;
  topicTitle?: unknown;
  title?: unknown;
  excerpt?: unknown;
  state?: unknown;
  publishedAt?: unknown;
  updatedAt?: unknown;
  canEdit?: unknown;
  canDelete?: unknown;
};

const FORUM_AUTHOR_PROFILE_ROUTE_CONTRACT = {
  appPath: '/api/app/forum/author/profile',
} as const;

const FORUM_AUTHOR_POSTS_ROUTE_CONTRACT = {
  appPath: '/api/app/forum/author/posts',
} as const;

@Injectable()
export class ForumAuthorProfileService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly authContext: AuthContextService,
    private readonly forumCommandErrors: ForumCommandErrorService,
  ) {}

  async getAuthorProfile(headers: IncomingHttpHeaders, authorId?: string) {
    try {
      const routeContract = FORUM_AUTHOR_PROFILE_ROUTE_CONTRACT;
      const result = await this.serverClient.get<Record<string, unknown>>('/server/forum/author/profile', {
        headers: this.authContext.buildPublicHeadersWithOptionalActorHints(headers),
        params: {
          authorId: this.asOptionalString(authorId),
        },
      });
      void routeContract;
      return this.shapeAuthorProfileResponse(result);
    } catch (error) {
      throw this.forumCommandErrors.normalizeAuthorReadError(error, 'profile');
    }
  }

  async getAuthorPosts(headers: IncomingHttpHeaders, authorId?: string, cursor?: string, pageSize?: string) {
    try {
      const routeContract = FORUM_AUTHOR_POSTS_ROUTE_CONTRACT;
      const result = await this.serverClient.get<Record<string, unknown>>('/server/forum/author/posts', {
        headers: this.authContext.buildPublicHeadersWithOptionalActorHints(headers),
        params: {
          authorId: this.asOptionalString(authorId),
          cursor: this.asOptionalString(cursor),
          pageSize: this.asOptionalString(pageSize),
        },
      });
      void routeContract;
      return this.shapeAuthorPostsResponse(result);
    } catch (error) {
      throw this.forumCommandErrors.normalizeAuthorReadError(error, 'posts');
    }
  }

  private shapeAuthorProfileResponse(result: Record<string, unknown>) {
    const body = result as ServerForumAuthorProfileResponse;
    const authorId = this.asOptionalString(body.authorId);
    const displayName = this.asOptionalString(body.displayName);
    if (!authorId || !displayName) {
      return result;
    }

    return {
      authorId,
      displayName,
      avatarUrl: this.asNullableString(body.avatarUrl),
      organizationName: this.asNullableString(body.organizationName),
      publicPostCount: this.asNonNegativeInteger(body.publicPostCount),
      publicCommentCount: this.asNonNegativeInteger(body.publicCommentCount),
    };
  }

  private shapeAuthorPostsResponse(result: Record<string, unknown>) {
    const body = result as ServerForumAuthorPostsResponse;
    const items = Array.isArray(body.items) ? body.items : null;
    const page = this.asRecord(body.page);
    if (!items || typeof page.hasMore !== 'boolean') {
      return result;
    }

    const shapedItems = items.map((item) => this.shapeAuthorPostCard(item));
    if (shapedItems.some((item) => item === null)) {
      return result;
    }

    return {
      items: shapedItems,
      page: {
        nextCursor: this.asNullableString(page.nextCursor),
        hasMore: page.hasMore,
      },
    };
  }

  private shapeAuthorPostCard(raw: unknown) {
    const item = raw as ServerForumPostCard;
    const postId = this.asOptionalString(item.postId);
    const topicId = this.asOptionalString(item.topicId);
    const topicTitle = this.asOptionalString(item.topicTitle);
    const title = this.asOptionalString(item.title);
    const excerpt = this.asOptionalString(item.excerpt);
    const state = this.asOptionalString(item.state);
    const publishedAt = this.asOptionalString(item.publishedAt);
    const updatedAt = this.asOptionalString(item.updatedAt);
    const canEdit = typeof item.canEdit === 'boolean' ? item.canEdit : false;
    const canDelete = typeof item.canDelete === 'boolean' ? item.canDelete : false;

    if (!postId || !topicId || !topicTitle || !title || !excerpt || !state || !publishedAt || !updatedAt) {
      return null;
    }

    return {
      postId,
      topicId,
      topicTitle,
      title,
      excerpt,
      state,
      publishedAt,
      updatedAt,
      canEdit,
      canDelete,
    };
  }

  private asOptionalString(value: unknown): string | undefined {
    return typeof value === 'string' && value.trim().length > 0 ? value.trim() : undefined;
  }

  private asNullableString(value: unknown): string | null {
    const resolved = this.asOptionalString(value);
    return resolved ?? null;
  }

  private asNonNegativeInteger(value: unknown) {
    if (typeof value === 'number' && Number.isInteger(value) && value >= 0) {
      return value;
    }
    if (typeof value === 'string' && value.trim().length > 0) {
      const parsed = Number.parseInt(value, 10);
      if (Number.isInteger(parsed) && parsed >= 0) {
        return parsed;
      }
    }
    return 0;
  }

  private asRecord(value: unknown): Record<string, unknown> {
    return value && typeof value === 'object' ? (value as Record<string, unknown>) : {};
  }
}
