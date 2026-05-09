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

export type NotificationRouteTargetAvailabilityState =
  | 'available'
  | 'unavailable'
  | 'expired'
  | 'forbidden'
  | 'missing_context';

export type NotificationRouteTargetFallbackAction = 'none' | 'open_subject_list';

export type NotificationRouteTargetAvailability = {
  state: NotificationRouteTargetAvailabilityState;
  reasonCode: string;
  reasonText: string;
  fallbackAction: NotificationRouteTargetFallbackAction;
  fallbackRouteTarget: Record<string, unknown> | null;
};

export type NotificationListItemProjection = {
  item: AppNotificationEntity;
  routeTargetAvailability: NotificationRouteTargetAvailability;
};

@Injectable()
export class NotificationPresenter {
  toNotification(input: AppNotificationEntity | NotificationListItemProjection) {
    const item = 'item' in input ? input.item : input;
    const routeTargetAvailability =
      'routeTargetAvailability' in input
        ? input.routeTargetAvailability
        : this.defaultRouteTargetAvailability(item);
    return {
      notificationId: item.id,
      type: item.type,
      source: item.source,
      title: item.title,
      body: item.body,
      projectId: item.projectId,
      threadId: item.threadId,
      routeTarget: this.toRouteTarget(item.routeTarget),
      routeTargetAvailability,
      createdAt: item.createdAt.toISOString(),
      readAt: item.readAt?.toISOString() ?? null,
      unread: !item.readAt
    };
  }

  toList(
    items: Array<AppNotificationEntity | NotificationListItemProjection>,
    unread: NotificationUnreadProjection,
    limit: number
  ) {
    const pageItems = items.slice(0, limit);
    const last = pageItems.at(-1) ?? null;
    const lastItem = last ? this.unwrapNotificationItem(last) : null;
    return {
      items: pageItems.map((item) => this.toNotification(item)),
      page: {
        nextCursor: items.length > limit ? lastItem?.createdAt.toISOString() ?? null : null,
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

  private unwrapNotificationItem(input: AppNotificationEntity | NotificationListItemProjection) {
    return 'item' in input ? input.item : input;
  }

  private defaultRouteTargetAvailability(item: AppNotificationEntity): NotificationRouteTargetAvailability {
    const routeTarget = this.toRouteTarget(item.routeTarget);
    if (!routeTarget) {
      return {
        state: 'missing_context',
        reasonCode: 'ROUTE_TARGET_MISSING',
        reasonText: '当前通知暂时无法定位，请稍后重试或从对应入口进入。',
        fallbackAction: 'none',
        fallbackRouteTarget: null
      };
    }
    if (routeTarget.state !== 'enabled') {
      return {
        state: 'unavailable',
        reasonCode: 'ROUTE_TARGET_UNAVAILABLE',
        reasonText: '当前通知入口暂不可用，请稍后重试或从对应入口进入。',
        fallbackAction: 'none',
        fallbackRouteTarget: null
      };
    }
    return {
      state: 'available',
      reasonCode: 'ROUTE_TARGET_AVAILABLE',
      reasonText: '当前通知入口可用。',
      fallbackAction: 'none',
      fallbackRouteTarget: null
    };
  }
}
