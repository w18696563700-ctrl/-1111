import 'package:mobile/core/api/app_ui_contracts.dart';

final class AppNotificationCanonicalPaths {
  const AppNotificationCanonicalPaths._();

  static const String deviceTokenRegister =
      '/api/app/notifications/device-token/register';
  static const String notificationList = '/api/app/notifications/list';
  static const String notificationRead = '/api/app/notifications/read';
}

final class AppNotificationUnreadView {
  const AppNotificationUnreadView({
    required this.total,
    required this.projectCommunication,
    required this.businessTodo,
    required this.bidParticipationRequest,
    required this.forumInteraction,
    required this.system,
  });

  final int total;
  final int projectCommunication;
  final int businessTodo;
  final int bidParticipationRequest;
  final int forumInteraction;
  final int system;
}

final class AppNotificationRouteTargetView {
  const AppNotificationRouteTargetView({
    required this.canonicalPath,
    required this.localEntryKey,
    required this.params,
    required this.routeLocation,
  });

  final String canonicalPath;
  final String? localEntryKey;
  final Map<String, String> params;
  final String? routeLocation;
}

final class AppNotificationRouteTargetAvailabilityView {
  const AppNotificationRouteTargetAvailabilityView({
    required this.state,
    required this.reasonCode,
    required this.reasonText,
    required this.fallbackAction,
    required this.fallbackRouteTarget,
  });

  final String state;
  final String reasonCode;
  final String reasonText;
  final String fallbackAction;
  final AppNotificationRouteTargetView? fallbackRouteTarget;

  bool get isAvailable => state == 'available';

  bool get canOpenFallback =>
      fallbackAction == 'open_subject_list' &&
      fallbackRouteTarget?.routeLocation?.trim().isNotEmpty == true;
}

final class AppNotificationItemView {
  const AppNotificationItemView({
    required this.notificationId,
    required this.type,
    required this.source,
    required this.title,
    required this.body,
    required this.projectId,
    required this.threadId,
    required this.routeTarget,
    required this.routeTargetAvailability,
    required this.createdAt,
    required this.readAt,
    required this.unread,
  });

  final String notificationId;
  final String type;
  final String source;
  final String title;
  final String? body;
  final String? projectId;
  final String? threadId;
  final AppNotificationRouteTargetView? routeTarget;
  final AppNotificationRouteTargetAvailabilityView routeTargetAvailability;
  final String? createdAt;
  final String? readAt;
  final bool unread;
}

final class AppNotificationListView {
  const AppNotificationListView({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
    required this.unread,
  });

  final List<AppNotificationItemView> items;
  final String? nextCursor;
  final bool hasMore;
  final AppNotificationUnreadView unread;
}

final class AppNotificationListResult {
  const AppNotificationListResult({
    required this.state,
    required this.method,
    required this.path,
    this.data,
    this.message,
    this.errorCode,
  });

  final AppPageState state;
  final String method;
  final String path;
  final AppNotificationListView? data;
  final String? message;
  final String? errorCode;
}

final class AppNotificationReadResult {
  const AppNotificationReadResult({
    required this.state,
    required this.method,
    required this.path,
    this.readNotificationIds = const <String>[],
    this.unread,
    this.message,
    this.errorCode,
  });

  final AppPageState state;
  final String method;
  final String path;
  final List<String> readNotificationIds;
  final AppNotificationUnreadView? unread;
  final String? message;
  final String? errorCode;
}

final class DevicePushTokenRegisterResult {
  const DevicePushTokenRegisterResult({
    required this.state,
    required this.method,
    required this.path,
    required this.registered,
    this.tokenId,
    this.platform,
    this.provider,
    this.message,
    this.errorCode,
  });

  final AppPageState state;
  final String method;
  final String path;
  final bool registered;
  final String? tokenId;
  final String? platform;
  final String? provider;
  final String? message;
  final String? errorCode;
}
