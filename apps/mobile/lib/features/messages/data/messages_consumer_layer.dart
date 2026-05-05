import 'dart:io';

import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/auth/protected_app_request.dart';
import 'package:mobile/features/messages/data/app_notification_models.dart';
import 'package:mobile/features/messages/data/app_notification_parser.dart';
import 'package:mobile/features/messages/data/messages_interaction_models.dart';
import 'package:mobile/features/messages/data/messages_interaction_parser.dart';

export 'package:mobile/features/messages/data/app_notification_models.dart';
export 'package:mobile/features/messages/data/messages_interaction_models.dart';

class MessagesConsumerLayer {
  MessagesConsumerLayer._(this._client);

  factory MessagesConsumerLayer({AppApiClient? client}) {
    return MessagesConsumerLayer._(client ?? AppApiClient());
  }

  static MessagesConsumerLayer _instance = MessagesConsumerLayer();

  static MessagesConsumerLayer get instance => _instance;

  static void install(MessagesConsumerLayer consumerLayer) {
    _instance = consumerLayer;
  }

  static void reset() {
    _instance = MessagesConsumerLayer();
  }

  final AppApiClient _client;

  String get configuredEnvironmentLabel =>
      _client.config.userFacingEnvironmentLabel;

  Future<MessageInteractionListResult> loadInteractions({
    String lane = 'project_communication',
  }) async {
    try {
      final response = await runProtectedAppRequest(
        () => _client.get(
          MessagesCanonicalPaths.messageInteractions,
          queryParameters: <String, String>{'lane': lane},
        ),
      );
      return _mapResponse(response);
    } on SocketException {
      return MessageInteractionListResult(
        state: AppPageState.errorRetryable,
        method: 'GET',
        path: MessagesCanonicalPaths.messageInteractions,
        lane: lane,
        message: 'network error while loading message interactions',
      );
    } on HttpException {
      return MessageInteractionListResult(
        state: AppPageState.errorRetryable,
        method: 'GET',
        path: MessagesCanonicalPaths.messageInteractions,
        lane: lane,
        message: 'http error while loading message interactions',
      );
    } on StateError {
      return MessageInteractionListResult(
        state: AppPageState.empty,
        method: 'GET',
        path: MessagesCanonicalPaths.messageInteractions,
        lane: lane,
        message: 'current fake transport did not provide message interactions',
      );
    } on FormatException catch (error) {
      return MessageInteractionListResult(
        state: AppPageState.errorNonRetryable,
        method: 'GET',
        path: MessagesCanonicalPaths.messageInteractions,
        lane: lane,
        message: error.message,
      );
    }
  }

  @Deprecated('Use loadInteractions() instead.')
  Future<MessageInteractionListResult> loadIndex() {
    return loadInteractions();
  }

  Future<AppNotificationListResult> loadNotifications({
    int pageSize = 30,
    String? cursor,
    String? source,
  }) async {
    final query = <String, String>{'pageSize': '$pageSize'};
    final normalizedCursor = cursor?.trim();
    if (normalizedCursor != null && normalizedCursor.isNotEmpty) {
      query['cursor'] = normalizedCursor;
    }
    final normalizedSource = source?.trim();
    if (normalizedSource != null && normalizedSource.isNotEmpty) {
      query['source'] = normalizedSource;
    }
    try {
      final response = await runProtectedAppRequest(
        () => _client.get(
          AppNotificationCanonicalPaths.notificationList,
          queryParameters: query,
        ),
      );
      return _mapNotificationListResponse(response);
    } on SocketException {
      return const AppNotificationListResult(
        state: AppPageState.errorRetryable,
        method: 'GET',
        path: AppNotificationCanonicalPaths.notificationList,
        message: 'network error while loading notifications',
      );
    } on HttpException {
      return const AppNotificationListResult(
        state: AppPageState.errorRetryable,
        method: 'GET',
        path: AppNotificationCanonicalPaths.notificationList,
        message: 'http error while loading notifications',
      );
    } on StateError {
      return const AppNotificationListResult(
        state: AppPageState.empty,
        method: 'GET',
        path: AppNotificationCanonicalPaths.notificationList,
        message: 'current fake transport did not provide notifications',
      );
    } on FormatException catch (error) {
      return AppNotificationListResult(
        state: AppPageState.errorNonRetryable,
        method: 'GET',
        path: AppNotificationCanonicalPaths.notificationList,
        message: error.message,
      );
    }
  }

  Future<AppNotificationReadResult> markNotificationsRead(
    List<String> notificationIds,
  ) async {
    try {
      final response = await runProtectedAppRequest(
        () => _client.post(
          AppNotificationCanonicalPaths.notificationRead,
          body: <String, Object?>{'notificationIds': notificationIds},
        ),
      );
      return _mapNotificationReadResponse(response);
    } on SocketException {
      return const AppNotificationReadResult(
        state: AppPageState.errorRetryable,
        method: 'POST',
        path: AppNotificationCanonicalPaths.notificationRead,
        message: 'network error while marking notifications read',
      );
    } on HttpException {
      return const AppNotificationReadResult(
        state: AppPageState.errorRetryable,
        method: 'POST',
        path: AppNotificationCanonicalPaths.notificationRead,
        message: 'http error while marking notifications read',
      );
    } on StateError {
      return const AppNotificationReadResult(
        state: AppPageState.empty,
        method: 'POST',
        path: AppNotificationCanonicalPaths.notificationRead,
        message: 'current fake transport did not provide notification read',
      );
    } on FormatException catch (error) {
      return AppNotificationReadResult(
        state: AppPageState.errorNonRetryable,
        method: 'POST',
        path: AppNotificationCanonicalPaths.notificationRead,
        message: error.message,
      );
    }
  }

  Future<DevicePushTokenRegisterResult> registerDevicePushToken({
    required String platform,
    required String provider,
    required String deviceToken,
    required String appInstallationId,
    String? appVersion,
    String? deviceLabel,
  }) async {
    try {
      final response = await runProtectedAppRequest(
        () => _client.post(
          AppNotificationCanonicalPaths.deviceTokenRegister,
          body: <String, Object?>{
            'platform': platform,
            'provider': provider,
            'deviceToken': deviceToken,
            'appInstallationId': appInstallationId,
            'appVersion': appVersion,
            'deviceLabel': deviceLabel,
          },
        ),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return DevicePushTokenRegisterResult(
          state: _stateFromStatus(response.statusCode),
          method: 'POST',
          path: AppNotificationCanonicalPaths.deviceTokenRegister,
          registered: false,
          message:
              extractNotificationMessage(response.body) ??
              'device token registration failed',
          errorCode: _extractCode(response.body),
        );
      }
      return parseDevicePushTokenRegisterResult(payload: response.body);
    } on SocketException {
      return const DevicePushTokenRegisterResult(
        state: AppPageState.errorRetryable,
        method: 'POST',
        path: AppNotificationCanonicalPaths.deviceTokenRegister,
        registered: false,
        message: 'network error while registering device token',
      );
    } on HttpException {
      return const DevicePushTokenRegisterResult(
        state: AppPageState.errorRetryable,
        method: 'POST',
        path: AppNotificationCanonicalPaths.deviceTokenRegister,
        registered: false,
        message: 'http error while registering device token',
      );
    } on FormatException catch (error) {
      return DevicePushTokenRegisterResult(
        state: AppPageState.errorNonRetryable,
        method: 'POST',
        path: AppNotificationCanonicalPaths.deviceTokenRegister,
        registered: false,
        message: error.message,
      );
    }
  }

  MessageInteractionListResult _mapResponse(AppApiResponse response) {
    if (response.statusCode == 401) {
      return MessageInteractionListResult(
        state: AppPageState.unauthorized,
        method: 'GET',
        path: MessagesCanonicalPaths.messageInteractions,
        lane: 'project_communication',
        message: extractMessage(response.body) ?? '当前登录态不可用，请重新登录后再试。',
      );
    }

    if (response.statusCode == 403) {
      return MessageInteractionListResult(
        state: AppPageState.forbidden,
        method: 'GET',
        path: MessagesCanonicalPaths.messageInteractions,
        lane: 'project_communication',
        message: extractMessage(response.body) ?? '当前账号暂无项目沟通查看权限。',
      );
    }

    if (response.statusCode == 404) {
      return MessageInteractionListResult(
        state: AppPageState.notFound,
        method: 'GET',
        path: MessagesCanonicalPaths.messageInteractions,
        lane: 'project_communication',
        message: extractMessage(response.body) ?? '当前项目沟通入口暂不可用，请稍后再试。',
      );
    }

    if (response.statusCode >= 500) {
      return MessageInteractionListResult(
        state: AppPageState.errorRetryable,
        method: 'GET',
        path: MessagesCanonicalPaths.messageInteractions,
        lane: 'project_communication',
        message:
            extractMessage(response.body) ??
            'message interactions temporarily unavailable',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return MessageInteractionListResult(
        state: AppPageState.errorNonRetryable,
        method: 'GET',
        path: MessagesCanonicalPaths.messageInteractions,
        lane: 'project_communication',
        message:
            extractMessage(response.body) ??
            'message interactions returned a controlled failure',
      );
    }

    final parsed = parseMessageInteractionPayload(response.body);
    return MessageInteractionListResult(
      state: parsed.state,
      method: 'GET',
      path: MessagesCanonicalPaths.messageInteractions,
      lane: parsed.lane,
      items: parsed.items,
      message: parsed.message,
    );
  }

  AppNotificationListResult _mapNotificationListResponse(
    AppApiResponse response,
  ) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return AppNotificationListResult(
        state: _stateFromStatus(response.statusCode),
        method: 'GET',
        path: AppNotificationCanonicalPaths.notificationList,
        message:
            extractNotificationMessage(response.body) ??
            'notifications returned a controlled failure',
        errorCode: _extractCode(response.body),
      );
    }
    final parsed = parseAppNotificationList(response.body);
    return AppNotificationListResult(
      state: parsed.items.isEmpty ? AppPageState.empty : AppPageState.content,
      method: 'GET',
      path: AppNotificationCanonicalPaths.notificationList,
      data: parsed,
    );
  }

  AppNotificationReadResult _mapNotificationReadResponse(
    AppApiResponse response,
  ) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return AppNotificationReadResult(
        state: _stateFromStatus(response.statusCode),
        method: 'POST',
        path: AppNotificationCanonicalPaths.notificationRead,
        message:
            extractNotificationMessage(response.body) ??
            'notification read returned a controlled failure',
        errorCode: _extractCode(response.body),
      );
    }
    return parseAppNotificationReadResult(response.body);
  }

  AppPageState _stateFromStatus(int statusCode) {
    if (statusCode == 401) {
      return AppPageState.unauthorized;
    }
    if (statusCode == 403) {
      return AppPageState.forbidden;
    }
    if (statusCode == 404) {
      return AppPageState.notFound;
    }
    if (statusCode >= 500) {
      return AppPageState.errorRetryable;
    }
    return AppPageState.errorNonRetryable;
  }

  String? _extractCode(Object? payload) {
    if (payload is Map) {
      final code = payload['code'];
      if (code is String && code.trim().isNotEmpty) {
        return code.trim();
      }
    }
    return null;
  }
}
