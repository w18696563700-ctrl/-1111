import { Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { ServerClientService } from '../../core/http/server-client.service';
import { requireAppApiPath, requireErrorCode } from '../../shared/contracts';
import { ForumCommandContextService } from './forum-command-context.service';
import { ForumCommandErrorService } from './forum-command-error.service';

const FORUM_COMMENT_CREATE_ROUTE_CONTRACT = {
  appPath: requireAppApiPath('/api/app/forum/post/comment'),
  errorCodes: [
    requireErrorCode('AUTH_SESSION_INVALID'),
    requireErrorCode('FORUM_COMMENT_INVALID'),
    requireErrorCode('FORUM_COMMENT_INVALID_STATE'),
    requireErrorCode('FORUM_POST_UNAVAILABLE'),
  ],
} as const;

const FORUM_LIKE_ROUTE_CONTRACT = {
  appPath: requireAppApiPath('/api/app/forum/post/like'),
  errorCodes: [
    requireErrorCode('AUTH_SESSION_INVALID'),
    requireErrorCode('FORUM_COMMENT_INVALID'),
    requireErrorCode('FORUM_INTERACTION_UNAVAILABLE'),
  ],
} as const;

const FORUM_BOOKMARK_ROUTE_CONTRACT = {
  appPath: requireAppApiPath('/api/app/forum/post/bookmark'),
  errorCodes: [
    requireErrorCode('AUTH_SESSION_INVALID'),
    requireErrorCode('FORUM_COMMENT_INVALID'),
    requireErrorCode('FORUM_INTERACTION_UNAVAILABLE'),
  ],
} as const;

const FORUM_AUTHOR_FOLLOW_ROUTE_CONTRACT = {
  appPath: '/api/app/forum/author/follow',
  errorCodes: [
    requireErrorCode('AUTH_SESSION_INVALID'),
    requireErrorCode('FORUM_COMMENT_INVALID'),
    requireErrorCode('FORUM_COMMENT_INVALID_STATE'),
    requireErrorCode('FORUM_AUTHOR_UNAVAILABLE'),
  ],
} as const;

@Injectable()
export class ForumInteractionService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly forumCommandContext: ForumCommandContextService,
    private readonly forumCommandErrors: ForumCommandErrorService,
  ) {}

  async createComment(payload: Record<string, unknown>, headers: IncomingHttpHeaders) {
    try {
      const routeContract = FORUM_COMMENT_CREATE_ROUTE_CONTRACT;
      const forwardHeaders = await this.forumCommandContext.buildCommandHeaders(headers);
      const result = await this.serverClient.post<Record<string, unknown>>('/server/forum/post/comment', payload, {
        headers: forwardHeaders,
      });
      void routeContract;
      return result;
    } catch (error) {
      throw this.forumCommandErrors.normalizeInteractionWriteError(error, 'comment_submit');
    }
  }

  async toggleLike(payload: Record<string, unknown>, headers: IncomingHttpHeaders) {
    try {
      const routeContract = FORUM_LIKE_ROUTE_CONTRACT;
      const forwardHeaders = await this.forumCommandContext.buildCommandHeaders(headers);
      const result = await this.serverClient.post<Record<string, unknown>>('/server/forum/post/like', payload, {
        headers: forwardHeaders,
      });
      void routeContract;
      return result;
    } catch (error) {
      throw this.forumCommandErrors.normalizeInteractionWriteError(error, 'post_like');
    }
  }

  async toggleBookmark(payload: Record<string, unknown>, headers: IncomingHttpHeaders) {
    try {
      const routeContract = FORUM_BOOKMARK_ROUTE_CONTRACT;
      const forwardHeaders = await this.forumCommandContext.buildCommandHeaders(headers);
      const result = await this.serverClient.post<Record<string, unknown>>('/server/forum/post/bookmark', payload, {
        headers: forwardHeaders,
      });
      void routeContract;
      return result;
    } catch (error) {
      throw this.forumCommandErrors.normalizeInteractionWriteError(error, 'post_bookmark');
    }
  }

  async toggleAuthorFollow(payload: Record<string, unknown>, headers: IncomingHttpHeaders) {
    try {
      const routeContract = FORUM_AUTHOR_FOLLOW_ROUTE_CONTRACT;
      const forwardHeaders = await this.forumCommandContext.buildCommandHeaders(headers);
      const result = await this.serverClient.post<Record<string, unknown>>('/server/forum/author/follow', payload, {
        headers: forwardHeaders,
      });
      void routeContract;
      return result;
    } catch (error) {
      throw this.forumCommandErrors.normalizeInteractionWriteError(error, 'author_follow');
    }
  }
}
