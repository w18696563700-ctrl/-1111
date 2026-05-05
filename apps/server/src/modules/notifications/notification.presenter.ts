import { Injectable } from '@nestjs/common';
import { AppNotificationEntity } from './entities/app-notification.entity';

export type NotificationUnreadProjection = {
  total: number;
  projectCommunication: number;
  businessTodo: number;
  bidParticipationRequest: number;
  forumInteraction: number;
  system: number;
};

@Injectable()
export class NotificationPresenter {
  toNotification(item: AppNotificationEntity) {
    return {
      notificationId: item.id,
      type: item.type,
      source: item.source,
      title: item.title,
      body: item.body,
      projectId: item.projectId,
      threadId: item.threadId,
      routeTarget: this.toRouteTarget(item.routeTarget),
      createdAt: item.createdAt.toISOString(),
      readAt: item.readAt?.toISOString() ?? null,
      unread: !item.readAt
    };
  }

  toList(items: AppNotificationEntity[], unread: NotificationUnreadProjection, limit: number) {
    const pageItems = items.slice(0, limit);
    const last = pageItems.at(-1) ?? null;
    return {
      items: pageItems.map((item) => this.toNotification(item)),
      page: {
        nextCursor: items.length > limit ? last?.createdAt.toISOString() ?? null : null,
        hasMore: items.length > limit
      },
      unread
    };
  }

  emptyUnread(): NotificationUnreadProjection {
    return {
      total: 0,
      projectCommunication: 0,
      businessTodo: 0,
      bidParticipationRequest: 0,
      forumInteraction: 0,
      system: 0
    };
  }

  private toRouteTarget(value: Record<string, unknown> | null | undefined) {
    return value && Object.keys(value).length > 0 ? value : null;
  }
}
