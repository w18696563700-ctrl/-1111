import 'dart:io';

import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/notifications/ios_apns_notification_service.dart';
import 'package:mobile/core/runtime_info/app_runtime_info_service.dart';
import 'package:mobile/features/messages/data/messages_consumer_layer.dart';

final class AppNotificationBootstrapResult {
  const AppNotificationBootstrapResult({
    required this.permissionSupported,
    required this.permissionGranted,
    required this.tokenRegistered,
    required this.degraded,
    required this.message,
  });

  final bool permissionSupported;
  final bool permissionGranted;
  final bool tokenRegistered;
  final bool degraded;
  final String message;
}

class AppNotificationBootstrapService {
  AppNotificationBootstrapService({
    MessagesConsumerLayer? messagesConsumer,
    IosApnsNotificationService? iosApnsNotificationService,
  }) : _messagesConsumer = messagesConsumer ?? MessagesConsumerLayer.instance,
       _iosApnsNotificationService =
           iosApnsNotificationService ?? IosApnsNotificationService();

  final MessagesConsumerLayer _messagesConsumer;
  final IosApnsNotificationService _iosApnsNotificationService;

  Future<AppNotificationBootstrapResult> initialize({
    String? deviceTokenOverride,
    String? appInstallationId,
    String? appVersion,
  }) async {
    String? token = deviceTokenOverride?.trim();
    var permissionSupported = true;
    var permissionGranted = true;
    var degradedMessage = '';
    if (token == null || token.isEmpty) {
      if (!Platform.isIOS) {
        return const AppNotificationBootstrapResult(
          permissionSupported: false,
          permissionGranted: false,
          tokenRegistered: false,
          degraded: true,
          message: 'Android 系统推送本轮未开通，已保留站内通知中心降级能力。',
        );
      }
      final apnsResult = await _iosApnsNotificationService
          .requestAuthorizationAndToken();
      permissionSupported = apnsResult.permissionSupported;
      permissionGranted = apnsResult.permissionGranted;
      token = apnsResult.deviceToken?.trim();
      degradedMessage = apnsResult.message ?? 'APNs token 获取未完成，已保留站内通知。';
      if (token == null || token.isEmpty) {
        return AppNotificationBootstrapResult(
          permissionSupported: permissionSupported,
          permissionGranted: permissionGranted,
          tokenRegistered: false,
          degraded: true,
          message: degradedMessage,
        );
      }
    }
    final platform = Platform.isIOS ? 'ios' : 'android';
    final runtimeInfo = await AppRuntimeInfoService.instance.load();
    final result = await _messagesConsumer.registerDevicePushToken(
      platform: platform,
      provider: Platform.isIOS ? 'apns' : 'fcm',
      deviceToken: token,
      appInstallationId:
          appInstallationId ?? AppSessionStore.instance.ensureDeviceId(),
      appVersion: appVersion ?? runtimeInfo.versionSummary,
    );
    return AppNotificationBootstrapResult(
      permissionSupported: permissionSupported,
      permissionGranted: permissionGranted,
      tokenRegistered: result.registered,
      degraded: !result.registered,
      message:
          result.message ??
          (result.registered ? '系统通知 token 已注册。' : '系统通知 token 注册未完成。'),
    );
  }
}
