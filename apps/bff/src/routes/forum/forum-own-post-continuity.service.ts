import { Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { ServerClientService } from '../../core/http/server-client.service';
import { ForumCommandContextService } from './forum-command-context.service';
import { ForumCommandErrorService } from './forum-command-error.service';

type ServerForumMyPostsResponse = {
  items?: unknown;
  page?: unknown;
};

type ServerForumMyPostCard = {
  postId?: unknown;
  title?: unknown;
  topicId?: unknown;
  topicTitle?: unknown;
  excerpt?: unknown;
  state?: unknown;
  publishedAt?: unknown;
  updatedAt?: unknown;
  canEdit?: unknown;
  canDelete?: unknown;
};

type ServerForumEditEntryResponse = {
  status?: unknown;
  draftId?: unknown;
  targetPostId?: unknown;
  state?: unknown;
};

type ServerForumDeleteEntryResponse = {
  postId?: unknown;
  state?: unknown;
  archivedAt?: unknown;
};

const FORUM_ME_POSTS_ROUTE_CONTRACT = {
  appPath: '/api/app/forum/me/posts',
} as const;

const FORUM_POST_EDIT_ROUTE_CONTRACT = {
  appPath: '/api/app/forum/post/edit',
} as const;

const FORUM_POST_DELETE_ROUTE_CONTRACT = {
  appPath: '/api/app/forum/post/delete',
} as const;

@Injectable()
export class ForumOwnPostContinuityService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly forumCommandContext: ForumCommandContextService,
    private readonly forumCommandErrors: ForumCommandErrorService,
  ) {}

  async getMyPosts(headers: IncomingHttpHeaders, cursor?: string, pageSize?: string) {
    try {
      const routeContract = FORUM_ME_POSTS_ROUTE_CONTRACT;
      const forwardHeaders = await this.forumCommandContext.buildCommandHeaders(headers);
      const result = await this.serverClient.get<Record<string, unknown>>('/server/forum/me/posts', {
        headers: forwardHeaders,
        params: {
          cursor: this.asOptionalString(cursor),
          pageSize: this.asOptionalString(pageSize),
        },
      });
      void routeContract;
      return this.shapeMyPostsResponse(result);
    } catch (error) {
      throw this.forumCommandErrors.normalizeOwnPostReadError(error);
    }
  }

  async enterEditDraft(payload: Record<string, unknown>, headers: IncomingHttpHeaders) {
    try {
      const routeContract = FORUM_POST_EDIT_ROUTE_CONTRACT;
      const forwardHeaders = await this.forumCommandContext.buildCommandHeaders(headers);
      const result = await this.serverClient.post<Record<string, unknown>>('/server/forum/post/edit', payload, {
        headers: forwardHeaders,
      });
      void routeContract;
      return this.shapeEditEntryResponse(result);
    } catch (error) {
      throw this.forumCommandErrors.normalizeOwnPostEditError(error);
    }
  }

  async deletePost(payload: Record<string, unknown>, headers: IncomingHttpHeaders) {
    try {
      const routeContract = FORUM_POST_DELETE_ROUTE_CONTRACT;
      const forwardHeaders = await this.forumCommandContext.buildCommandHeaders(headers);
      const result = await this.serverClient.post<Record<string, unknown>>('/server/forum/post/delete', payload, {
        headers: forwardHeaders,
      });
      void routeContract;
      return this.shapeDeleteEntryResponse(result);
    } catch (error) {
      throw this.forumCommandErrors.normalizeOwnPostDeleteError(error);
    }
  }

  private shapeMyPostsResponse(result: Record<string, unknown>) {
    const body = result as ServerForumMyPostsResponse;
    const items = Array.isArray(body.items) ? body.items : null;
    const page = this.asRecord(body.page);
    if (!items || typeof page.hasMore !== 'boolean') {
      return result;
    }

    const shapedItems = items.map((item) => this.shapeMyPostCard(item));
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

  private shapeMyPostCard(raw: unknown) {
    const item = raw as ServerForumMyPostCard;
    const postId = this.asOptionalString(item.postId);
    const title = this.asOptionalString(item.title);
    const topicId = this.asOptionalString(item.topicId);
    const topicTitle = this.asOptionalString(item.topicTitle);
    const excerpt = this.asOptionalString(item.excerpt);
    const state = this.asOptionalString(item.state);
    const publishedAt = this.asOptionalString(item.publishedAt);
    const updatedAt = this.asOptionalString(item.updatedAt);
    const canEdit = this.asBoolean(item.canEdit);
    const canDelete = this.asBoolean(item.canDelete);

    if (
      !postId ||
      !title ||
      !topicId ||
      !topicTitle ||
      !excerpt ||
      !state ||
      !publishedAt ||
      !updatedAt ||
      canEdit === null ||
      canDelete === null
    ) {
      return null;
    }

    return {
      postId,
      title,
      topicId,
      topicTitle,
      excerpt,
      state,
      publishedAt,
      updatedAt,
      canEdit,
      canDelete,
    };
  }

  private shapeEditEntryResponse(result: Record<string, unknown>) {
    const body = result as ServerForumEditEntryResponse;
    const draftId = this.asOptionalString(body.draftId);
    const targetPostId = this.asOptionalString(body.targetPostId);
    const state = this.asOptionalString(body.state);
    if (!draftId || !targetPostId || !state) {
      return result;
    }

    const status = this.asOptionalString(body.status);

    return {
      draftId,
      targetPostId,
      state,
      status: status ?? 'accepted_edit_draft',
      message: this.resolveEditMessage(status),
    };
  }

  private shapeDeleteEntryResponse(result: Record<string, unknown>) {
    const body = result as ServerForumDeleteEntryResponse;
    const postId = this.asOptionalString(body.postId);
    const state = this.asOptionalString(body.state);
    const archivedAt = this.asOptionalString(body.archivedAt);
    if (!postId || !state || !archivedAt) {
      return result;
    }

    return {
      postId,
      state,
      archivedAt,
      message: '帖子已删除',
    };
  }

  private resolveEditMessage(status?: string) {
    if (status === 'resumed_active_edit_draft') {
      return '已进入编辑草稿';
    }
    return '已创建编辑草稿';
  }

  private asOptionalString(value: unknown): string | undefined {
    return typeof value === 'string' && value.trim().length > 0 ? value.trim() : undefined;
  }

  private asNullableString(value: unknown): string | null {
    const resolved = this.asOptionalString(value);
    return resolved ?? null;
  }

  private asBoolean(value: unknown): boolean | null {
    return typeof value === 'boolean' ? value : null;
  }

  private asRecord(value: unknown): Record<string, unknown> {
    return value && typeof value === 'object' ? (value as Record<string, unknown>) : {};
  }
}
