import 'dart:async';
import 'dart:io';

import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_api_entry_mode.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/core/config/config_manifest.dart';
import 'package:mobile/core/location/device_location_service.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/exhibition_home_aggregation_client.dart';
import 'package:mobile/features/messages/data/messages_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_consumer_layer.dart';
import 'package:mobile/shell/shell_app.dart';

ExhibitionMobileApp buildVisualDemoApp({required String initialRoute}) {
  const demoBaseUrl = AppApiEntryTarget.sshTunnelBaseUrl;
  final exhibitionClient = AppApiClient(
    config: AppApiConfig(baseUrl: demoBaseUrl),
    transport: FakeAppApiTransport(handlers: _exhibitionHandlers()),
  );
  return ExhibitionMobileApp(
    initialRoute: initialRoute,
    bootstrapManifest: AppConfigManifest.bootstrapDefaults(),
    bootstrapShellContext: AppShellContextData(
      userId: 'demo-user',
      organizationId: 'org-demo',
      organizationType: 'both',
      roleKeys: const <String>['buyer_admin', 'supplier_admin'],
      certificationStatus: 'verified',
      personalCertificationStatus: 'verified',
      personalCertificationQualified: true,
      membershipStatus: 'active',
      visibleBuildings: const <String>['exhibition', 'messages', 'profile'],
      unreadSummary: const <String, Object?>{'todo': 3, 'notice': 2},
    ),
    exhibitionConsumerLayer: ExhibitionConsumerLayer(client: exhibitionClient),
    exhibitionHomeAggregationClient: CanonicalExhibitionHomeAggregationClient(
      client: exhibitionClient,
    ),
    deviceLocationService: _VisualDemoDeviceLocationService(
      state: _visualHomeWeatherState(),
    ),
    messagesConsumerLayer: MessagesConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: demoBaseUrl),
        transport: FakeAppApiTransport(handlers: _messagesHandlers()),
      ),
    ),
    profileConsumerLayer: ProfileConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: demoBaseUrl),
        transport: FakeAppApiTransport(handlers: _profileHandlers()),
      ),
    ),
    sessionStore: AppSessionStore()
      ..establishSession(
        accessToken: 'visual-demo-access-token',
        refreshToken: 'visual-demo-refresh-token',
        expiresInSeconds: 3600,
        deviceId: 'visual-demo-device',
        localLoginSource: AppSessionLoginSource.passwordLogin,
      ),
  );
}

Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
_exhibitionHandlers() {
  return <String, Future<AppApiResponse> Function(AppApiRequest request)>{
    'GET /api/app/exhibition/home': _handleExhibitionHome,
    'POST /api/app/exhibition/home/refresh': _handleExhibitionHome,
    'POST /api/app/exhibition/home/location/select': _handleExhibitionHome,
    'GET /api/app/project/list': _handleProjectList,
    'GET /api/app/project/detail': _handleProjectDetail,
    'POST /api/app/file/upload/init': _handleUploadInit,
    'POST /api/app/file/upload/confirm': _handleUploadConfirm,
    'GET /api/app/contract/detail': _handleContractDetail,
    'POST /api/app/contract/confirm': _handleContractConfirm,
    'POST /api/app/dispute/open': _handleDisputeOpen,
    'GET /api/app/rating/entry': _handleRatingEntry,
  };
}

String _visualHomeWeatherState() {
  const compileTimeState = String.fromEnvironment('VISUAL_HOME_WEATHER_STATE');
  final runtimeState = Platform.environment['VISUAL_HOME_WEATHER_STATE']
      ?.trim();
  final state = compileTimeState.isNotEmpty
      ? compileTimeState
      : runtimeState != null && runtimeState.isNotEmpty
      ? runtimeState
      : 'formal';
  return state == 'degraded' || state == 'no_location' ? state : 'formal';
}

final class _VisualDemoDeviceLocationService implements DeviceLocationService {
  const _VisualDemoDeviceLocationService({required this.state});

  final String state;

  @override
  bool get supportsDeviceLocation => true;

  @override
  bool get supportsReverseGeocoding => true;

  @override
  Future<DeviceLocationSnapshot> resolveCurrentPosition() async {
    if (state == 'no_location') {
      return const DeviceLocationSnapshot(
        permissionState: DeviceLocationPermissionState.denied,
        errorMessage: '定位权限未开启。',
      );
    }
    return const DeviceLocationSnapshot(
      permissionState: DeviceLocationPermissionState.granted,
      latitude: 29.5630,
      longitude: 106.5516,
      provinceCode: '500000',
      provinceName: '重庆市',
    );
  }
}

Future<AppApiResponse> _handleExhibitionHome(AppApiRequest request) async {
  final state = _visualHomeWeatherState();
  return AppApiResponse(
    statusCode: state == 'no_location' ? 503 : 200,
    uri: request.uri,
    body: state == 'no_location'
        ? const <String, Object?>{
            'errorCode': 'HOME_AGGREGATION_UNAVAILABLE',
            'message': '天气信息同步中，请稍候。',
          }
        : _homePayload(degraded: state == 'degraded'),
  );
}

Future<AppApiResponse> _handleProjectList(AppApiRequest request) async {
  return AppApiResponse(
    statusCode: 200,
    uri: request.uri,
    body: <String, Object?>{
      'items': <Object?>[
        <String, Object?>{
          'projectId': 'project-home-capture',
          'projectNo': 'EXH-2026-DD93A8',
          'displayTitle': '西洽会',
          'title': '西洽会',
          'buildingType': 'exhibition',
          'budgetAmount': 120000,
          'state': 'published',
          'areaSqm': 200,
          'provinceName': '重庆市',
          'cityName': '重庆市',
          'plannedStartAt': '2026-05-16',
          'publishedAt': '2026-04-20',
          'summary': <String, Object?>{'heading': '西洽会'},
        },
      ],
    },
  );
}

Map<String, Object?> _homePayload({required bool degraded}) {
  return <String, Object?>{
    'currentLocation': const <String, Object?>{
      'displayName': '重庆南岸',
      'provinceCode': '500000',
      'provinceName': '重庆市',
      'cityName': '重庆市',
      'districtName': '南岸区',
      'latitude': 29.5630,
      'longitude': 106.5516,
      'source': 'device_location',
      'persisted': false,
    },
    'selectionScope': 'request_only',
    'selectionNotice': '当前定位仅用于本次首页聚合',
    'isUsingDeviceLocation': true,
    'currentWeather': degraded ? '天气暂不可用' : '小雨',
    'currentTemperature': degraded ? 0 : 21,
    'highTemperature': degraded ? 0 : 24,
    'lowTemperature': degraded ? 0 : 18,
    'precipitationProbability': degraded ? 0 : 20,
    'constructionRiskLevel': degraded ? 'medium' : 'low',
    'constructionRiskSummary': degraded
        ? '天气接口异常不影响项目列表和推荐频道。'
        : '天气平稳，适合推进布展准备。',
    'riskTags': degraded ? const <Object?>[] : const <Object?>['rain'],
    'riskTimeLabel': degraded ? null : '今日白天',
    'nightRainExpected': degraded ? null : false,
    'nightRainTimeLabel': degraded ? null : '今夜无明显降雨',
    'officialAlerts': const <Object?>[],
    'constructionSuggestions': degraded
        ? const <Object?>['稍后刷新天气，项目列表与公开入口仍可正常使用。']
        : const <Object?>['按计划推进布展准备。', '关注临电和材料覆盖。', '预留雨具和转运缓冲。'],
    'hourlyForecast': degraded
        ? const <Object?>[]
        : const <Object?>[
            <String, Object?>{
              'timeLabel': '18:00',
              'weather': '小雨',
              'temperature': 21,
              'precipitationProbability': 20,
            },
            <String, Object?>{
              'timeLabel': '20:00',
              'weather': '多云',
              'temperature': 20,
              'precipitationProbability': 10,
            },
          ],
    'dailyForecast': degraded
        ? const <Object?>[]
        : const <Object?>[
            <String, Object?>{
              'dateLabel': '今天',
              'weekdayLabel': '周六',
              'weather': '小雨',
              'highTemperature': 24,
              'lowTemperature': 18,
              'precipitationProbability': 20,
            },
          ],
    'updatedAt': '2026-04-25T18:00:00+08:00',
    'sourceLabel': '首页聚合返回',
    'canExpand': true,
    'refreshable': true,
    'modules': const <Object?>[],
    'recommendationSections': const <Object?>[],
  };
}

Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
_messagesHandlers() {
  return <String, Future<AppApiResponse> Function(AppApiRequest request)>{
    'GET /api/app/message/index': (AppApiRequest request) async {
      return AppApiResponse(
        statusCode: 200,
        uri: request.uri,
        body: <String, Object?>{
          'items': <Object?>[
            _todoItem(
              todoId: 'todo-contract-confirm',
              objectType: 'contract',
              instanceId: 'contract-1',
              actionKey: 'contract.confirm',
              title: '确认合同',
              summary: '请在合同确认页完成这次生效承接。',
              canonicalPath: '/api/app/contract/detail',
              localEntryKey: 'registered.contract.confirm',
              requiredParams: const <String>['orderId'],
              routeParams: const <String, String>{'orderId': 'order-1'},
            ),
            _todoItem(
              todoId: 'todo-rating-submit',
              objectType: 'rating',
              instanceId: 'rating-entry-order-1',
              actionKey: 'rating.submit',
              title: '补齐评价提交',
              summary: '当前评价入口已承接，可继续进入评价提交。',
              canonicalPath: '/api/app/rating/entry',
              localEntryKey: 'registered.rating.submit',
              requiredParams: const <String>['orderId'],
              routeParams: const <String, String>{'orderId': 'order-1'},
            ),
            _todoItem(
              todoId: 'todo-dispute-open',
              objectType: 'dispute',
              instanceId: 'dispute-entry-order-1',
              actionKey: 'dispute.open',
              title: '开启争议入口',
              summary: '当前订单已允许进入争议开启边界页。',
              canonicalPath: '/api/app/order/detail',
              localEntryKey: 'registered.dispute.open',
              requiredParams: const <String>['orderId'],
              routeParams: const <String, String>{'orderId': 'order-1'},
            ),
          ],
          'unreadCount': 5,
        },
      );
    },
  };
}

Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
_profileHandlers() {
  return <String, Future<AppApiResponse> Function(AppApiRequest request)>{
    'GET /api/app/profile/index': (AppApiRequest request) async {
      return AppApiResponse(
        statusCode: 200,
        uri: request.uri,
        body: <String, Object?>{
          'organization': <String, Object?>{
            'organizationId': 'org-demo',
            'organizationType': 'both',
            'roleKeys': const <String>['buyer_admin', 'supplier_admin'],
            'visibleBuildings': const <String>[
              'exhibition',
              'messages',
              'profile',
            ],
          },
          'certification': <String, Object?>{'status': 'verified'},
          'personalCertification': <String, Object?>{
            'status': 'verified',
            'qualifiedForCurrentActor': true,
          },
          'membership': <String, Object?>{'status': 'active'},
          'settingsEntry': <String, Object?>{'state': 'visible'},
        },
      );
    },
  };
}

Future<AppApiResponse> _handleContractDetail(AppApiRequest request) async {
  final orderId = request.uri.queryParameters['orderId'] ?? 'order-1';
  return AppApiResponse(
    statusCode: 200,
    uri: request.uri,
    body: _contractPayload(
      contractId: 'contract-1',
      orderId: orderId,
      state: 'pending_confirm',
      summaryHeading: '合同重点已整理完成',
    ),
  );
}

Future<AppApiResponse> _handleProjectDetail(AppApiRequest request) async {
  final projectId = request.uri.queryParameters['projectId'] ?? 'project-1';
  return AppApiResponse(
    statusCode: 200,
    uri: request.uri,
    body: <String, Object?>{
      'projectId': projectId,
      'projectNo': 'PROJ-20260327-01',
      'title': '上海品牌快闪展台',
      'buildingType': 'exhibition',
      'budgetAmount': 1888,
      'state': 'published',
      'summary': _summary('项目关键信息已承接'),
    },
  );
}

Future<AppApiResponse> _handleContractConfirm(AppApiRequest request) async {
  return AppApiResponse(
    statusCode: 202,
    uri: request.uri,
    body: _contractPayload(
      contractId: 'contract-1',
      orderId: 'order-1',
      state: 'active',
      summaryHeading: '合同确认已完成',
    ),
  );
}

Future<AppApiResponse> _handleDisputeOpen(AppApiRequest request) async {
  final body = request.body;
  final orderId = body is Map<String, Object?> && body['orderId'] is String
      ? body['orderId']! as String
      : 'order-1';
  return AppApiResponse(
    statusCode: 202,
    uri: request.uri,
    body: <String, Object?>{
      'disputeId': 'dispute-1',
      'orderId': orderId,
      'state': 'opened',
      'summary': _summary('争议开启结果已承接'),
    },
  );
}

Future<AppApiResponse> _handleRatingEntry(AppApiRequest request) async {
  final orderId = request.uri.queryParameters['orderId'] ?? 'order-1';
  return AppApiResponse(
    statusCode: 200,
    uri: request.uri,
    body: <String, Object?>{
      'orderId': orderId,
      'state': 'draft',
      'summary': _summary('评价入口已就位'),
    },
  );
}

Future<AppApiResponse> _handleUploadInit(AppApiRequest request) async {
  final body = request.body;
  final businessId =
      body is Map<String, Object?> && body['businessId'] is String
      ? body['businessId']! as String
      : 'project-1';
  return AppApiResponse(
    statusCode: 200,
    uri: request.uri,
    body: <String, Object?>{
      'uploadSessionId': 'visual-upload-$businessId',
      'directUpload': <String, Object?>{
        'url': 'https://oss.example.com/upload/$businessId',
        'method': 'PUT',
      },
      'confirm': <String, Object?>{'endpoint': '/api/app/file/upload/confirm'},
    },
  );
}

Future<AppApiResponse> _handleUploadConfirm(AppApiRequest request) async {
  return AppApiResponse(
    statusCode: 200,
    uri: request.uri,
    body: const <String, Object?>{'status': 'bound'},
  );
}

Map<String, Object?> _todoItem({
  required String todoId,
  required String objectType,
  required String instanceId,
  required String actionKey,
  required String title,
  required String summary,
  required String canonicalPath,
  required String localEntryKey,
  required List<String> requiredParams,
  required Map<String, String> routeParams,
}) {
  return <String, Object?>{
    'todoId': todoId,
    'messageType': 'instance_todo',
    'instanceRef': <String, Object?>{
      'objectType': objectType,
      'instanceId': instanceId,
    },
    'actionKey': actionKey,
    'title': title,
    'summary': summary,
    'routeTarget': <String, Object?>{
      'canonicalPath': canonicalPath,
      'localEntryKey': localEntryKey,
      'requiredParams': requiredParams,
      'state': 'enabled',
      'routeParams': routeParams,
    },
    'state': 'pending',
  };
}

Map<String, Object?> _contractPayload({
  required String contractId,
  required String orderId,
  required String state,
  required String summaryHeading,
}) {
  return <String, Object?>{
    'contractId': contractId,
    'orderId': orderId,
    'state': state,
    'summary': _summary(summaryHeading),
  };
}

Map<String, Object?> _summary(String heading) {
  return <String, Object?>{'heading': heading};
}
