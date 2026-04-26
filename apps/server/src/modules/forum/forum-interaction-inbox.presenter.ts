import { Injectable } from '@nestjs/common';
import type { ForumAuthorSnapshot } from './forum-author-projection.service';

export type ForumInteractionInboxTab = 'replies' | 'likes' | 'follows';
export type ForumInteractionTargetType = 'forum_post' | 'forum_comment' | 'forum_topic';

export type ForumInteractionInboxItemInput = {
  notificationId: string;
  tab: ForumInteractionInboxTab;
  actor: ForumAuthorSnapshot;
  targetType: ForumInteractionTargetType;
  targetId: string;
  title: string;
  preview: string | null;
  createdAt: Date;
  canQuickReply?: boolean | null;
};

@Injectable()
export class ForumInteractionInboxPresenter {
  toResponse(
    items: ForumInteractionInboxItemInput[],
    page: { nextCursor: string | null; hasMore: boolean } = this.toPage()
  ) {
    return {
      items: items.map((item) => ({
        notificationId: item.notificationId,
        tab: item.tab,
        actor: item.actor,
        targetType: item.targetType,
        targetId: item.targetId,
        title: item.title,
        preview: item.preview,
        createdAt: item.createdAt.toISOString(),
        unread: false,
        canQuickReply: item.canQuickReply ?? null
      })),
      page
    };
  }

  private toPage() {
    return {
      nextCursor: null,
      hasMore: false
    };
  }
}
