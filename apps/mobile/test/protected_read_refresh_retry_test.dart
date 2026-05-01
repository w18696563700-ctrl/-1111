import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/auth/auth_consumer_layer.dart';
import 'package:mobile/core/auth/protected_app_request.dart';
import 'package:mobile/core/boot/app_shell_context_consumer.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/messages/data/messages_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_consumer_layer.dart';

void main() {
  setUp(_resetSessionState);
  tearDown(_resetSessionState);

  test(
    'project list read retries once after unauthorized and refreshes auth',
    () async {
      _installSession(expired: false);
      var refreshRequests = 0;
      var projectListRequests = 0;
      _installAuthConsumer(
        FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'POST /api/app/auth/refresh': (AppApiRequest request) async {
                  refreshRequests += 1;
                  return _refreshSuccess(
                    request,
                    accessToken: 'project-list-refreshed-token',
                  );
                },
              },
        ),
      );

      final consumer = ExhibitionConsumerLayer(
        client: AppApiClient(
          config: _config(),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/project/list': (AppApiRequest request) async {
                    projectListRequests += 1;
                    if (projectListRequests == 1) {
                      return _unauthorized(
                        request,
                        path: ExhibitionCanonicalPaths.projectList,
                      );
                    }
                    expect(
                      request.headers['authorization'],
                      'Bearer project-list-refreshed-token',
                    );
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{'items': <Object?>[]},
                    );
                  },
                },
          ),
        ),
      );

      final result = await consumer.loadProjectList(forceRefresh: true);

      expect(result.state, AppPageState.empty);
      expect(refreshRequests, 1);
      expect(projectListRequests, 2);
    },
  );

  test(
    'profile index read retries once after unauthorized and returns content',
    () async {
      _installSession(expired: false);
      var refreshRequests = 0;
      var profileRequests = 0;
      _installAuthConsumer(
        FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'POST /api/app/auth/refresh': (AppApiRequest request) async {
                  refreshRequests += 1;
                  return _refreshSuccess(
                    request,
                    accessToken: 'profile-refreshed-token',
                  );
                },
              },
        ),
      );

      final consumer = ProfileConsumerLayer(
        client: AppApiClient(
          config: _config(),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/profile/index': (AppApiRequest request) async {
                    profileRequests += 1;
                    if (profileRequests == 1) {
                      return _unauthorized(
                        request,
                        path: ProfileCanonicalPaths.profileIndex,
                      );
                    }
                    expect(
                      request.headers['authorization'],
                      'Bearer profile-refreshed-token',
                    );
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _profileIndexPayload(),
                    );
                  },
                },
          ),
        ),
      );

      final result = await consumer.loadIndex();

      expect(result.state, AppPageState.content);
      expect(result.data?.organization.organizationId, 'org-1');
      expect(refreshRequests, 1);
      expect(profileRequests, 2);
    },
  );

  test(
    'shell context read retries once after unauthorized and returns content',
    () async {
      _installSession(expired: false);
      var refreshRequests = 0;
      var shellRequests = 0;
      _installAuthConsumer(
        FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'POST /api/app/auth/refresh': (AppApiRequest request) async {
                  refreshRequests += 1;
                  return _refreshSuccess(
                    request,
                    accessToken: 'shell-refreshed-token',
                  );
                },
              },
        ),
      );

      final consumer = AppShellContextConsumer(
        client: AppApiClient(
          config: _config(),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/shell/context': (AppApiRequest request) async {
                    shellRequests += 1;
                    if (shellRequests == 1) {
                      return _unauthorized(
                        request,
                        path: AppShellContextCanonicalPaths.shellContext,
                      );
                    }
                    expect(
                      request.headers['authorization'],
                      'Bearer shell-refreshed-token',
                    );
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _shellContextPayload(),
                    );
                  },
                },
          ),
        ),
      );

      final result = await consumer.loadResult();

      expect(result.state, AppPageState.content);
      expect(result.data?.userId, 'user-1');
      expect(refreshRequests, 1);
      expect(shellRequests, 2);
    },
  );

  test('message interactions refresh before loading list', () async {
    _installSession(expired: true);
    var refreshRequests = 0;
    var interactionRequests = 0;
    _installAuthConsumer(
      FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'POST /api/app/auth/refresh': (AppApiRequest request) async {
                refreshRequests += 1;
                return _refreshSuccess(
                  request,
                  accessToken: 'message-interactions-token',
                );
              },
            },
      ),
    );

    final consumer = MessagesConsumerLayer(
      client: AppApiClient(
        config: _config(),
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'GET /api/app/message/interactions':
                    (AppApiRequest request) async {
                      interactionRequests += 1;
                      expect(
                        request.headers['authorization'],
                        'Bearer message-interactions-token',
                      );
                      expect(
                        request.uri.queryParameters['lane'],
                        'project_communication',
                      );
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'lane': 'project_communication',
                          'items': <Object?>[],
                        },
                      );
                    },
              },
        ),
      ),
    );

    final result = await consumer.loadInteractions();

    expect(result.state, AppPageState.empty);
    expect(refreshRequests, 1);
    expect(interactionRequests, 1);
  });

  test('parallel protected reads share one refresh request', () async {
    _installSession(expired: true);
    var refreshRequests = 0;
    var shellRequests = 0;
    _installAuthConsumer(
      FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'POST /api/app/auth/refresh': (AppApiRequest request) async {
                refreshRequests += 1;
                await Future<void>.delayed(Duration.zero);
                return _refreshSuccess(
                  request,
                  accessToken: 'shared-refreshed-token',
                );
              },
            },
      ),
    );

    final client = AppApiClient(
      config: _config(),
      transport: FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/shell/context': (AppApiRequest request) async {
                shellRequests += 1;
                expect(
                  request.headers['authorization'],
                  'Bearer shared-refreshed-token',
                );
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _shellContextPayload(),
                );
              },
            },
      ),
    );

    final results = await Future.wait(<Future<AppApiResponse>>[
      runProtectedAppRequest(
        () => client.getEndpoint(AppShellContextCanonicalPaths.shellContext),
      ),
      runProtectedAppRequest(
        () => client.getEndpoint(AppShellContextCanonicalPaths.shellContext),
      ),
    ]);

    expect(results.map((AppApiResponse response) => response.statusCode), [
      200,
      200,
    ]);
    expect(refreshRequests, 1);
    expect(shellRequests, 2);
  });

  test(
    'stale unauthorized refresh does not clear newer local session',
    () async {
      _installSession(expired: true);
      var refreshRequests = 0;
      _installAuthConsumer(
        FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'POST /api/app/auth/refresh': (AppApiRequest request) async {
                  refreshRequests += 1;
                  AppSessionStore.instance.establishSession(
                    accessToken: 'newer-access-token',
                    refreshToken: 'newer-refresh-token',
                    expiresInSeconds: 3600,
                    deviceId: 'device-1',
                  );
                  return _unauthorized(request, path: '/api/app/auth/refresh');
                },
              },
        ),
      );

      final result = await AuthConsumerLayer.instance.refreshSession();

      expect(result.state, AppPageState.unauthorized);
      expect(refreshRequests, 1);
      expect(AppSessionStore.instance.refreshToken, 'newer-refresh-token');
      expect(AppSessionStore.instance.authorizationHeaders, <String, String>{
        'authorization': 'Bearer newer-access-token',
      });
    },
  );

  test(
    'protected read retries current token before starting refresh',
    () async {
      _installSession(expired: false);
      var refreshRequests = 0;
      var shellRequests = 0;
      _installAuthConsumer(
        FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'POST /api/app/auth/refresh': (AppApiRequest request) async {
                  refreshRequests += 1;
                  return _refreshSuccess(
                    request,
                    accessToken: 'unexpected-refresh-token',
                  );
                },
              },
        ),
      );

      final client = AppApiClient(
        config: _config(),
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'GET /api/app/shell/context': (AppApiRequest request) async {
                  shellRequests += 1;
                  if (shellRequests == 1) {
                    AppSessionStore.instance.establishSession(
                      accessToken: 'already-refreshed-token',
                      refreshToken: 'refresh-token-2',
                      expiresInSeconds: 3600,
                      deviceId: 'device-1',
                    );
                    return _unauthorized(
                      request,
                      path: AppShellContextCanonicalPaths.shellContext,
                    );
                  }
                  expect(
                    request.headers['authorization'],
                    'Bearer already-refreshed-token',
                  );
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: _shellContextPayload(),
                  );
                },
              },
        ),
      );

      final response = await runProtectedAppRequest(
        () => client.getEndpoint(AppShellContextCanonicalPaths.shellContext),
      );

      expect(response.statusCode, 200);
      expect(refreshRequests, 0);
      expect(shellRequests, 2);
    },
  );
}

void _resetSessionState() {
  AppApiConfig.resetRuntimeBaseUrlOverride();
  AppSessionStore.reset();
  AuthConsumerLayer.reset();
}

AppApiConfig _config() {
  return AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app');
}

void _installSession({required bool expired}) {
  final store = AppSessionStore();
  AppSessionStore.install(store);
  store.establishSession(
    accessToken: 'stale-access-token',
    refreshToken: 'refresh-token-1',
    expiresInSeconds: expired ? 0 : 3600,
    deviceId: 'device-1',
  );
}

void _installAuthConsumer(FakeAppApiTransport transport) {
  AuthConsumerLayer.install(
    AuthConsumerLayer(
      client: AppApiClient(config: _config(), transport: transport),
    ),
  );
}

AppApiResponse _refreshSuccess(
  AppApiRequest request, {
  required String accessToken,
}) {
  return AppApiResponse(
    statusCode: 200,
    uri: request.uri,
    body: <String, Object?>{
      'accessToken': accessToken,
      'refreshToken': 'refresh-token-2',
      'expiresInSeconds': 3600,
    },
  );
}

AppApiResponse _unauthorized(AppApiRequest request, {required String path}) {
  return AppApiResponse(
    statusCode: 401,
    uri: request.uri.replace(path: path),
    body: const <String, Object?>{
      'code': 'AUTH_SESSION_INVALID',
      'message': '当前登录已失效',
    },
  );
}

Map<String, Object?> _profileIndexPayload() {
  return const <String, Object?>{
    'organization': <String, Object?>{
      'organizationId': 'org-1',
      'roleKeys': <String>['supplier_admin'],
      'visibleBuildings': <String>['exhibition', 'messages', 'profile'],
    },
    'certification': <String, Object?>{'status': 'verified'},
    'membership': <String, Object?>{'status': 'active'},
    'settingsEntry': <String, Object?>{'state': 'visible'},
  };
}

Map<String, Object?> _shellContextPayload() {
  return const <String, Object?>{
    'userId': 'user-1',
    'displayName': '测试用户',
    'organizationId': 'org-1',
    'roleKeys': <String>['supplier_admin'],
    'certificationStatus': 'verified',
    'membershipStatus': 'active',
    'visibleBuildings': <String>['exhibition', 'messages', 'profile'],
    'featureFlagsVersion': 'ffv-1',
    'unreadSummary': <String, Object?>{},
  };
}
