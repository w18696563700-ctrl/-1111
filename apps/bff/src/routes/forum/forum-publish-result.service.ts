import { Injectable } from '@nestjs/common';

type ServerForumPublishResponse = {
  draftId?: unknown;
  topicId?: unknown;
  postId?: unknown;
  state?: unknown;
  decision?: unknown;
  message?: unknown;
  summary?: unknown;
};

@Injectable()
export class ForumPublishResultService {
  shapePublishResult(result: Record<string, unknown>) {
    const body = result as ServerForumPublishResponse;
    const draftId = this.asOptionalString(body.draftId);
    const state = this.asOptionalString(body.state);
    const decision = this.asOptionalString(body.decision);
    const message = this.asOptionalString(body.message);
    if (!draftId || !state || !decision || !message) {
      return result;
    }

    if (decision !== 'clear') {
      return {
        draftId,
        state,
        decision,
        message,
      };
    }

    const topicId = this.asOptionalString(body.topicId);
    const postId = this.asOptionalString(body.postId);
    const summary = this.asRecord(body.summary);
    const title = this.asOptionalString(summary.title);
    const publishedAt = this.asOptionalString(summary.publishedAt);
    if (!topicId || !postId || !title || !publishedAt) {
      return result;
    }

    return {
      draftId,
      topicId,
      postId,
      state,
      decision,
      message,
      summary: {
        title,
        publishedAt,
      },
    };
  }

  private asOptionalString(value: unknown): string | undefined {
    return typeof value === 'string' && value.trim().length > 0 ? value.trim() : undefined;
  }

  private asRecord(value: unknown): Record<string, unknown> {
    return value && typeof value === 'object' ? (value as Record<string, unknown>) : {};
  }
}
