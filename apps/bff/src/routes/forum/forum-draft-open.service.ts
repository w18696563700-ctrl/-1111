import { Injectable } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { ServerClientService } from '../../core/http/server-client.service';
import { ForumCommandContextService } from './forum-command-context.service';
import { ForumCommandErrorService } from './forum-command-error.service';

type ServerForumDraftDetailResponse = {
  draftId?: unknown;
  draftType?: unknown;
  targetPostId?: unknown;
  topicId?: unknown;
  title?: unknown;
  body?: unknown;
  attachmentFileAssetIds?: unknown;
  state?: unknown;
  updatedAt?: unknown;
};

const FORUM_DRAFT_DETAIL_ROUTE_CONTRACT = {
  appPath: '/api/app/forum/draft/detail',
} as const;

@Injectable()
export class ForumDraftOpenService {
  constructor(
    private readonly serverClient: ServerClientService,
    private readonly forumCommandContext: ForumCommandContextService,
    private readonly forumCommandErrors: ForumCommandErrorService,
  ) {}

  async getDraftDetail(headers: IncomingHttpHeaders, draftId?: string) {
    try {
      const routeContract = FORUM_DRAFT_DETAIL_ROUTE_CONTRACT;
      const forwardHeaders = await this.forumCommandContext.buildCommandHeaders(headers);
      const result = await this.serverClient.get<Record<string, unknown>>('/server/forum/draft/detail', {
        headers: forwardHeaders,
        params: {
          draftId: this.asOptionalString(draftId),
        },
      });
      void routeContract;
      return this.shapeDraftDetailResponse(result);
    } catch (error) {
      throw this.forumCommandErrors.normalizeDraftOpenError(error);
    }
  }

  private shapeDraftDetailResponse(result: Record<string, unknown>) {
    const body = result as ServerForumDraftDetailResponse;
    const draftId = this.asOptionalString(body.draftId);
    const draftType = this.asOptionalString(body.draftType);
    const topicId = this.asOptionalString(body.topicId);
    const title = this.asOptionalString(body.title);
    const draftBody = this.asOptionalString(body.body);
    const state = this.asOptionalString(body.state);
    const updatedAt = this.asOptionalString(body.updatedAt);
    const attachmentFileAssetIds = this.asStringArray(body.attachmentFileAssetIds);

    if (
      !draftId ||
      !draftType ||
      !topicId ||
      !title ||
      !draftBody ||
      !state ||
      !updatedAt ||
      attachmentFileAssetIds === null
    ) {
      return result;
    }

    return {
      draftId,
      draftType,
      targetPostId: this.asNullableString(body.targetPostId),
      topicId,
      title,
      body: draftBody,
      attachmentFileAssetIds,
      state,
      updatedAt,
    };
  }

  private asOptionalString(value: unknown): string | undefined {
    return typeof value === 'string' && value.trim().length > 0 ? value.trim() : undefined;
  }

  private asNullableString(value: unknown): string | null {
    const resolved = this.asOptionalString(value);
    return resolved ?? null;
  }

  private asStringArray(value: unknown): string[] | null {
    if (!Array.isArray(value)) {
      return null;
    }

    const resolved = value
      .filter((item): item is string => typeof item === 'string' && item.trim().length > 0)
      .map((item) => item.trim());

    return resolved.length === value.length ? resolved : null;
  }
}
