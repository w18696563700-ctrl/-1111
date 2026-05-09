import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/auth/auth_consumer_layer.dart';
import 'package:mobile/core/boot/app_bootstrap_controller.dart';
import 'package:mobile/core/boot/app_shell_context_consumer.dart';

void main() {
  tearDown(() {
    AppSessionStore.reset();
    AuthConsumerLayer.reset();
  });

  test('initial shell context retryable failure still shows offline', () async {
    AppSessionStore.install(_authenticatedSessionStore());
    final controller = AppBootstrapController(
      shellContextConsumer: _shellContextConsumer(
        (AppApiRequest request) async => throw const SocketException('offline'),
      ),
    );

    controller.initialize();
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(controller.snapshot.blockingState, GlobalShellState.offline);
  });

  test(
    'background shell context retryable failure keeps loaded shell',
    () async {
      AppSessionStore.install(_authenticatedSessionStore());
      var calls = 0;
      final controller = AppBootstrapController(
        shellContextConsumer: _shellContextConsumer((
          AppApiRequest request,
        ) async {
          calls += 1;
          if (calls > 1) {
            throw const SocketException('offline');
          }
          return AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: _shellContextPayload(),
          );
        }),
      );

      controller.initialize();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(controller.snapshot.blockingState, isNull);

      await controller.reloadShellContext();

      expect(calls, 2);
      expect(controller.snapshot.blockingState, isNull);
      expect(controller.snapshot.shellContext.organizationId, 'org-1');
    },
  );

  test('background refresh retryable failure keeps loaded shell', () async {
    AppSessionStore.install(_authenticatedSessionStore());
    AuthConsumerLayer.install(
      AuthConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers: <String, Future<AppApiResponse> Function(AppApiRequest)>{
              'POST /api/app/auth/refresh': (AppApiRequest request) async =>
                  throw const SocketException('offline'),
            },
          ),
        ),
      ),
    );
    var calls = 0;
    final controller = AppBootstrapController(
      shellContextConsumer: _shellContextConsumer((
        AppApiRequest request,
      ) async {
        calls += 1;
        if (calls > 1) {
          return AppApiResponse(statusCode: 401, uri: request.uri);
        }
        return AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: _shellContextPayload(),
        );
      }),
    );

    controller.initialize();
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(controller.snapshot.blockingState, isNull);

    await controller.reloadShellContext();

    expect(calls, 2);
    expect(controller.snapshot.blockingState, isNull);
    expect(controller.snapshot.shellContext.organizationId, 'org-1');
  });
}

AppSessionStore _authenticatedSessionStore() {
  final store = AppSessionStore();
  store.establishSession(
    accessToken: 'test-access-token',
    refreshToken: 'test-refresh-token',
    expiresInSeconds: 3600,
    deviceId: 'test-device-id',
  );
  return store;
}

AppShellContextConsumer _shellContextConsumer(
  Future<AppApiResponse> Function(AppApiRequest request) handler,
) {
  return AppShellContextConsumer(
    client: AppApiClient(
      config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
      transport: FakeAppApiTransport(
        handlers: <String, Future<AppApiResponse> Function(AppApiRequest)>{
          'GET /api/app/shell/context': handler,
        },
      ),
    ),
  );
}

Map<String, Object?> _shellContextPayload() {
  return <String, Object?>{
    'userId': 'user-1',
    'displayName': 'Test User',
    'avatarUrl': null,
    'organizationId': 'org-1',
    'organizationType': 'supplier',
    'roleKeys': <String>['supplier'],
    'certificationStatus': 'approved',
    'membershipStatus': null,
    'visibleBuildings': <String>['exhibition', 'messages', 'profile'],
    'featureFlagsVersion': 'ffv-test',
    'unreadSummary': <String, Object?>{'messages': 0},
  };
}
