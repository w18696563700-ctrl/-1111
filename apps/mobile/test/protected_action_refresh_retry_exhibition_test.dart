import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/auth/auth_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';

void main() {
  setUp(_resetSessionState);
  tearDown(_resetSessionState);

  test(
    'exhibition create refreshes before request when session should refresh',
    () async {
      _installSession(expired: true);
      var refreshRequests = 0;
      var createRequests = 0;
      _installAuthConsumer(
        FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'POST /api/app/auth/refresh': (AppApiRequest request) async {
                  refreshRequests += 1;
                  return _refreshSuccess(
                    request,
                    accessToken: 'create-refreshed-token',
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
                  'POST /api/app/project/create':
                      (AppApiRequest request) async {
                        createRequests += 1;
                        expect(
                          request.headers['authorization'],
                          'Bearer create-refreshed-token',
                        );
                        return AppApiResponse(
                          statusCode: 202,
                          uri: request.uri,
                          body: const <String, Object?>{
                            'projectId': 'project-refresh-1',
                          },
                        );
                      },
                },
          ),
        ),
      );

      final result = await consumer.createProject(
        ProjectCreateCommand(
          title: 'refresh create',
          buildingType: 'exhibition',
          budgetAmount: 1600,
          provinceCode: '510000',
          provinceName: '四川',
          cityCode: '510100',
          cityName: '成都',
          detailAddress: '世纪城新国际会展中心 6 号馆西门',
          scopeSummary: 'refresh test scope',
        ),
      );

      expect(result.isSuccess, isTrue);
      expect(result.payload, const <String, Object?>{
        'projectId': 'project-refresh-1',
      });
      expect(refreshRequests, 1);
      expect(createRequests, 1);
    },
  );

  test(
    'exhibition create keeps unauthorized when refresh after 401 fails',
    () async {
      _installSession(expired: false);
      var refreshRequests = 0;
      var createRequests = 0;
      _installAuthConsumer(
        FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'POST /api/app/auth/refresh': (AppApiRequest request) async {
                  refreshRequests += 1;
                  return _unauthorized(
                    request,
                    path: AuthCanonicalPaths.refresh,
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
                  'POST /api/app/project/create':
                      (AppApiRequest request) async {
                        createRequests += 1;
                        return _unauthorized(
                          request,
                          path: ExhibitionCanonicalPaths.projectCreate,
                        );
                      },
                },
          ),
        ),
      );

      final result = await consumer.createProject(
        ProjectCreateCommand(
          title: 'unauthorized create',
          buildingType: 'exhibition',
          budgetAmount: 1600,
          provinceCode: '510000',
          provinceName: '四川',
          cityCode: '510100',
          cityName: '成都',
          detailAddress: '世纪城新国际会展中心 6 号馆西门',
          scopeSummary: 'unauthorized test scope',
        ),
      );

      expect(result.isSuccess, isFalse);
      expect(result.controlledState, AppPageState.unauthorized);
      expect(refreshRequests, 1);
      expect(createRequests, 1);
      expect(AppSessionStore.instance.hasAnySession, isFalse);
    },
  );

  test('exhibition create retries only once after unauthorized', () async {
    _installSession(expired: false);
    var refreshRequests = 0;
    var createRequests = 0;
    _installAuthConsumer(
      FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'POST /api/app/auth/refresh': (AppApiRequest request) async {
                refreshRequests += 1;
                return _refreshSuccess(
                  request,
                  accessToken: 'create-retry-token',
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
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'POST /api/app/project/create': (AppApiRequest request) async {
                  createRequests += 1;
                  return _unauthorized(
                    request,
                    path: ExhibitionCanonicalPaths.projectCreate,
                  );
                },
              },
        ),
      ),
    );

    final result = await consumer.createProject(
      ProjectCreateCommand(
        title: 'retry once',
        buildingType: 'exhibition',
        budgetAmount: 1600,
        provinceCode: '510000',
        provinceName: '四川',
        cityCode: '510100',
        cityName: '成都',
        detailAddress: '世纪城新国际会展中心 6 号馆西门',
        scopeSummary: 'retry test scope',
      ),
    );

    expect(result.isSuccess, isFalse);
    expect(result.controlledState, AppPageState.unauthorized);
    expect(refreshRequests, 1);
    expect(createRequests, 2);
  });

  test('upload init recovers after one refresh retry', () async {
    _installSession(expired: false);
    var refreshRequests = 0;
    var initRequests = 0;
    _installAuthConsumer(
      FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'POST /api/app/auth/refresh': (AppApiRequest request) async {
                refreshRequests += 1;
                return _refreshSuccess(
                  request,
                  accessToken: 'upload-init-token',
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
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'POST /api/app/file/upload/init':
                    (AppApiRequest request) async {
                      initRequests += 1;
                      if (initRequests == 1) {
                        return _unauthorized(
                          request,
                          path: ExhibitionCanonicalPaths.uploadInit,
                        );
                      }
                      expect(
                        request.headers['authorization'],
                        'Bearer upload-init-token',
                      );
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: _uploadInitAcceptedBody(),
                      );
                    },
              },
        ),
      ),
    );

    final result = await consumer.uploadInit(
      const UploadInitCommand(
        businessType: 'project',
        businessId: 'project-1',
        fileKind: 'evidence',
        mimeType: 'application/pdf',
        size: 256,
        checksum: 'checksum-1',
      ),
    );

    expect(result.state, AppUploadState.signedReady);
    expect(result.controlledState, isNull);
    expect(
      result.directive?.confirmEndpoint,
      ExhibitionCanonicalPaths.uploadConfirm,
    );
    expect(refreshRequests, 1);
    expect(initRequests, 2);
  });

  test(
    'upload confirm recovers with pre-refresh and preserves canonical endpoint',
    () async {
      _installSession(expired: true);
      var refreshRequests = 0;
      var confirmRequests = 0;
      _installAuthConsumer(
        FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'POST /api/app/auth/refresh': (AppApiRequest request) async {
                  refreshRequests += 1;
                  return _refreshSuccess(
                    request,
                    accessToken: 'upload-confirm-token',
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
                  'POST /api/app/file/upload/confirm':
                      (AppApiRequest request) async {
                        confirmRequests += 1;
                        expect(
                          request.headers['authorization'],
                          'Bearer upload-confirm-token',
                        );
                        return AppApiResponse(
                          statusCode: 200,
                          uri: request.uri,
                          body: const <String, Object?>{
                            'fileAssetId': 'file-asset-1',
                          },
                        );
                      },
                },
          ),
        ),
      );

      final result = await consumer.uploadConfirm(
        directive: const UploadDirective(
          uploadSessionId: 'upload-session-1',
          directUploadUrl: 'https://oss.example.com/upload',
          directUploadMethod: 'PUT',
          directUploadHeaders: <String, String>{},
          confirmEndpoint: ExhibitionCanonicalPaths.uploadConfirm,
        ),
      );

      expect(result.state, AppUploadState.uploadBound);
      expect(result.fileAssetId, 'file-asset-1');
      expect(result.controlledState, isNull);
      expect(refreshRequests, 1);
      expect(confirmRequests, 1);
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
    body: const <String, Object?>{'code': 'UNAUTHORIZED', 'message': '当前登录已失效'},
  );
}

Map<String, Object?> _uploadInitAcceptedBody() {
  return const <String, Object?>{
    'uploadSessionId': 'upload-session-1',
    'directUpload': <String, Object?>{
      'url': 'https://oss.example.com/upload/project-1',
      'method': 'PUT',
      'headers': <String, Object?>{'content-type': 'application/pdf'},
    },
    'confirm': <String, Object?>{
      'endpoint': ExhibitionCanonicalPaths.uploadConfirm,
    },
  };
}
