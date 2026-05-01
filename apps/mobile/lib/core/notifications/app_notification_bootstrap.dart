import 'dart:io';

import 'package:mobile/core/api/app_ui_contracts.dart';
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
  AppNotificationBootstrapService({MessagesConsumerLayer? messagesConsumer})
    : _messagesConsumer = messagesConsumer ?? MessagesConsumerLayer.instance;

  final MessagesConsumerLayer _messagesConsumer;

  Future<AppNotificationBootstrapResult> initialize({
    String? deviceTokenOverride,
    String? appInstallationId,
    String? appVersion,
  }) async {
    final token = deviceTokenOverride?.trim();
    if (token == null || token.isEmpty) {
      return const AppNotificationBootstrapResult(
        permissionSupported: false,
        permissionGranted: false,
        tokenRegistered: false,
        degraded: true,
        message: '当前构建未接入 APNs/FCM token，先启用站内通知中心降级能力。',
      );
    }
    final platform = Platform.isIOS ? 'ios' : 'android';
    final result = await _messagesConsumer.registerDevicePushToken(
      platform: platform,
      provider: Platform.isIOS ? 'apns' : 'fcm',
      deviceToken: token,
      appInstallationId:
          appInstallationId ??
          'local-installation-${DateTime.now().millisecondsSinceEpoch}',
      appVersion: appVersion,
    );
    return AppNotificationBootstrapResult(
      permissionSupported: true,
      permissionGranted: result.state == AppPageState.content,
      tokenRegistered: result.registered,
      degraded: !result.registered,
      message:
          result.message ??
          (result.registered ? '系统通知 token 已注册。' : '系统通知 token 注册未完成。'),
    );
  }
}
