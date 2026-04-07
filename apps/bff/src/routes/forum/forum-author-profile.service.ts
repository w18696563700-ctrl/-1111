import { Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { AuthContextService } from '../../core/auth/auth-context.service';
import { ErrorNormalizerService } from '../../core/errors/error-normalizer.service';
import { ServerClientService } from '../../core/http/server-client.service';

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
  excerpt?: unknown;
  state?: unknown;
  author?: unknown;
  publishedAt?: unknown;
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
    private readonly errors: ErrorNormalizerService,
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
      throw this.errors.toHttpException(error, 'FORUM_AUTHOR_PROFILE_FAILED', 'Forum author profile aggregation failed.');
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
      throw this.errors.toHttpException(error, 'FORUM_AUTHOR_POSTS_FAILED', 'Forum author posts aggregation failed.');
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
    const excerpt = this.asOptionalString(item.excerpt);
    const state = this.asOptionalString(item.state);
    const publishedAt = this.asOptionalString(item.publishedAt);
    const author = this.shapeAuthorSummary(item.author);

    if (!postId || !topicId || !topicTitle || !excerpt || !state || !publishedAt || !author) {
      return null;
    }

    return {
      postId,
      topicId,
      topicTitle,
      excerpt,
      state,
      author,
      publishedAt,
    };
  }

  private shapeAuthorSummary(raw: unknown) {
    const body = this.asRecord(raw);
    const authorId = this.asOptionalString(body.authorId);
    const displayName = this.asOptionalString(body.displayName);
    if (!authorId || !displayName) {
      return null;
    }

    return {
      authorId,
      displayName,
      organizationName: this.asNullableString(body.organizationName),
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
