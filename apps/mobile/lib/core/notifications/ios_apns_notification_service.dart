import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

final class IosApnsRegistrationResult {
  const IosApnsRegistrationResult({
    required this.permissionSupported,
    required this.permissionGranted,
    required this.degraded,
    required this.authorizationStatus,
    this.deviceToken,
    this.message,
  });

  final bool permissionSupported;
  final bool permissionGranted;
  final bool degraded;
  final String authorizationStatus;
  final String? deviceToken;
  final String? message;

  bool get hasDeviceToken =>
      deviceToken != null && deviceToken!.trim().isNotEmpty;

  static const unsupported = IosApnsRegistrationResult(
    permissionSupported: false,
    permissionGranted: false,
    degraded: true,
    authorizationStatus: 'unsupported',
    message: '当前平台不支持 iOS APNs 注册。',
  );
}

class IosApnsNotificationService {
  IosApnsNotificationService({MethodChannel? channel})
    : _channel =
          channel ?? const MethodChannel('exhibition_home/apns_notifications');

  final MethodChannel _channel;

  Future<void> installRouteTargetOpenHandler(
    FutureOr<void> Function(Map<String, Object?> routeTarget)
    onRouteTargetOpened,
  ) async {
    if (!Platform.isIOS) {
      return;
    }
    _channel.setMethodCallHandler((MethodCall call) async {
      if (call.method != 'notificationRouteTargetOpened') {
        throw MissingPluginException(
          'Unsupported APNs notification method ${call.method}',
        );
      }
      final routeTarget = _mapRouteTarget(call.arguments);
      if (routeTarget == null) {
        return;
      }
      await onRouteTargetOpened(routeTarget);
    });
    final pending = await consumePendingRouteTarget();
    if (pending != null) {
      await onRouteTargetOpened(pending);
    }
  }

  Future<Map<String, Object?>?> consumePendingRouteTarget() async {
    if (!Platform.isIOS) {
      return null;
    }
    try {
      final payload = await _channel.invokeMapMethod<String, Object?>(
        'pendingRouteTarget',
      );
      return _mapRouteTarget(payload);
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  Future<IosApnsRegistrationResult> requestAuthorizationAndToken() async {
    if (!Platform.isIOS) {
      return IosApnsRegistrationResult.unsupported;
    }
    try {
      final payload = await _channel.invokeMapMethod<String, Object?>(
        'requestAuthorizationAndRegister',
      );
      return _mapRegistrationResult(payload);
    } on PlatformException catch (error) {
      return IosApnsRegistrationResult(
        permissionSupported: true,
        permissionGranted: false,
        degraded: true,
        authorizationStatus: error.code,
        message: '系统通知能力暂不可用，已保留站内通知。',
      );
    } on MissingPluginException {
      return const IosApnsRegistrationResult(
        permissionSupported: true,
        permissionGranted: false,
        degraded: true,
        authorizationStatus: 'missing_plugin',
        message: '当前 iOS 构建未接入 APNs 原生桥，已保留站内通知。',
      );
    }
  }

  IosApnsRegistrationResult _mapRegistrationResult(
    Map<String, Object?>? payload,
  ) {
    if (payload == null) {
      return const IosApnsRegistrationResult(
        permissionSupported: true,
        permissionGranted: false,
        degraded: true,
        authorizationStatus: 'empty_payload',
        message: '系统通知注册返回为空，已保留站内通知。',
      );
    }
    final token = payload['deviceToken']?.toString().trim();
    final permissionGranted = payload['permissionGranted'] == true;
    final permissionSupported = payload['permissionSupported'] != false;
    return IosApnsRegistrationResult(
      permissionSupported: permissionSupported,
      permissionGranted: permissionGranted,
      degraded: !permissionGranted || token == null || token.isEmpty,
      authorizationStatus:
          payload['authorizationStatus']?.toString().trim() ?? 'unknown',
      deviceToken: token == null || token.isEmpty ? null : token,
      message: payload['message']?.toString(),
    );
  }

  Map<String, Object?>? _mapRouteTarget(Object? payload) {
    if (payload is! Map) {
      return null;
    }
    final mapped = payload.map<String, Object?>(
      (Object? key, Object? value) => MapEntry('$key', value),
    );
    return mapped.isEmpty ? null : mapped;
  }
}
