import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/location/china_region_catalog.dart';
import 'package:mobile/core/location/device_location_service.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/exhibition_home_aggregation_client.dart';
import 'package:mobile/features/messages/data/messages_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_consumer_layer.dart';
import 'package:mobile/shell/shell_app.dart';
import 'package:mobile/features/exhibition/data/exhibition_home_location_context_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/exhibition_home_test_doubles.dart';

ExhibitionMobileApp _buildApp({
  required FakeExhibitionHomeAggregationClient homeClient,
  required FakeDeviceLocationService locationService,
  required FakeAppApiTransport transport,
  AppSessionStore? sessionStore,
}) {
  return ExhibitionMobileApp(
    initialRoute: '/',
    exhibitionConsumerLayer: ExhibitionConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: transport,
      ),
    ),
    exhibitionHomeAggregationClient: homeClient,
    deviceLocationService: locationService,
    sessionStore: sessionStore,
    messagesConsumerLayer: MessagesConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers:
              <
                String,
                Future<AppApiResponse> Function(AppApiRequest request)
              >{},
        ),
      ),
    ),
    profileConsumerLayer: ProfileConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers:
              <
                String,
                Future<AppApiResponse> Function(AppApiRequest request)
              >{},
        ),
      ),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    ExhibitionHomeLocationContextStore.reset();
    ChinaRegionCatalogLoader.installLoadOverrideForTest(
      () async => ChinaRegionCatalog(
        provinces: const <ChinaProvinceOption>[
          ChinaProvinceOption(
            provinceCode: '500000',
            provinceName: '重庆',
            cities: <ChinaCityOption>[
              ChinaCityOption(
                provinceCode: '500000',
                provinceName: '重庆',
                cityCode: '500100',
                cityName: '重庆市',
              ),
            ],
          ),
          ChinaProvinceOption(
            provinceCode: '510000',
            provinceName: '四川',
            cities: <ChinaCityOption>[
              ChinaCityOption(
                provinceCode: '510000',
                provinceName: '四川',
                cityCode: '510100',
                cityName: '成都市',
              ),
            ],
          ),
        ],
      ),
    );
  });

  tearDown(ChinaRegionCatalogLoader.reset);

  testWidgets(
    'weather card keeps controlled unavailable state before home path connects',
    (WidgetTester tester) async {
      final homeClient = FakeExhibitionHomeAggregationClient();
      final locationService = FakeDeviceLocationService();
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/project/list': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: const <String, Object?>{'items': <Object?>[]},
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          homeClient: homeClient,
          locationService: locationService,
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('发现优质项目，把握商机'), findsOneWidget);
      expect(find.text('城市已定位，天气加载中'), findsOneWidget);
      expect(find.text('地区识别中'), findsOneWidget);
      expect(find.textContaining('5 分钟自动整页刷新'), findsNothing);
      expect(find.textContaining('30.5728'), findsNothing);
      expect(find.textContaining('104.0668'), findsNothing);
      expect(find.text('展览首页'), findsNothing);
      expect(find.text('秩序化首页'), findsNothing);
      expect(find.text('重庆'), findsNothing);

      await tester.tap(find.byTooltip('展开天气卡'));
      await tester.pumpAndSettle();

      expect(find.text('今日施工天气总览'), findsOneWidget);
      expect(find.text('天气与施工说明'), findsOneWidget);
      expect(find.text('当前地区说明尚未就绪'), findsOneWidget);
      expect(find.text('当前位置已获取，但当前还未拿到可展示的天气结果。'), findsOneWidget);
      expect(find.text('所在地区识别中'), findsWidgets);
      expect(find.textContaining('/api/app/exhibition/home'), findsNothing);
    },
  );

  testWidgets(
    'weather card can expand real aggregation content when BFF payload is ready',
    (WidgetTester tester) async {
      final homeClient = FakeExhibitionHomeAggregationClient(
        onLoad: (_) => contentHomeResult(
          constructionRiskLevel: 'critical',
          constructionRiskSummary: '今晚雷雨风险升高，户外工序建议顺延。',
          riskTags: const <String>['rain', 'night_rain', 'official_alert'],
          riskTimeLabel: '今晚 20:00-23:00',
          nightRainExpected: true,
          nightRainTimeLabel: '今晚 20:00-23:00',
          officialAlerts: const <String>['重庆市雷电黄色预警'],
          constructionSuggestions: const <String>[
            '暂停高空作业，优先室内工序。',
            '检查临电和排水，落实防雨覆盖。',
            '将材料转运调整到降雨窗口外。',
          ],
        ),
      );
      final locationService = FakeDeviceLocationService();
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/project/list': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: const <String, Object?>{'items': <Object?>[]},
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          homeClient: homeClient,
          locationService: locationService,
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('今晚雷雨风险升高'), findsOneWidget);
      expect(find.text('施工极高风险'), findsOneWidget);
      expect(find.text('5 分钟自动整页刷新'), findsNothing);

      await tester.tap(find.byTooltip('展开天气卡'));
      await tester.pumpAndSettle();

      expect(find.text('今日施工天气总览'), findsOneWidget);
      expect(find.text('施工风险卡'), findsOneWidget);
      expect(find.text('今日施工建议'), findsOneWidget);
      expect(find.text('重庆市雷电黄色预警'), findsOneWidget);
      expect(find.text('降雨 / 夜间降雨 / 官方预警'), findsWidgets);
      expect(find.textContaining('rain / night_rain'), findsNothing);
      expect(find.textContaining('当前定位仅用于本次首页聚合'), findsOneWidget);
      expect(find.textContaining('仅当前请求'), findsNothing);
      expect(find.textContaining('尚未持久化到后端'), findsNothing);
      expect(find.text('小时预报'), findsOneWidget);
      expect(find.text('每日预报'), findsOneWidget);

      await tester.tap(find.byTooltip('收起天气卡'));
      await tester.pumpAndSettle();

      expect(find.text('小时预报'), findsNothing);
      expect(find.text('每日预报'), findsNothing);
    },
  );

  testWidgets(
    'weather card renders degraded weather payload without falling back to placeholder copy',
    (WidgetTester tester) async {
      final homeClient = FakeExhibitionHomeAggregationClient(
        onLoad: (_) =>
            degradedWeatherHomeResult(displayName: '重庆市', provinceName: '重庆'),
      );
      final locationService = FakeDeviceLocationService();
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/project/list': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: const <String, Object?>{'items': <Object?>[]},
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          homeClient: homeClient,
          locationService: locationService,
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('重庆市 已同步，天气暂不可用'), findsOneWidget);
      expect(find.text('天气暂不可用'), findsOneWidget);
      expect(find.textContaining('受控占位'), findsNothing);
      expect(find.text('待同步'), findsNothing);

      await tester.tap(find.byTooltip('展开天气卡'));
      await tester.pumpAndSettle();

      expect(find.text('当前地区天气总览'), findsOneWidget);
      expect(find.text('施工风险卡'), findsOneWidget);
      expect(find.text('今日施工建议'), findsOneWidget);
      expect(find.textContaining('当前定位仅用于本次首页聚合'), findsWidgets);
      expect(find.textContaining('天气暂不可用'), findsWidgets);
      expect(find.text('小时预报'), findsNothing);
      expect(find.text('每日预报'), findsNothing);
      expect(find.text('重庆市雷电黄色预警'), findsNothing);
    },
  );

  testWidgets(
    'hourly forecast only keeps future slots and still caps to four items',
    (WidgetTester tester) async {
      String timeLabel(int hour) => '${hour.toString().padLeft(2, '0')}:00';
      final now = DateTime.now();
      final currentHour = now.hour;
      final previousHour = currentHour == 0 ? 0 : currentHour - 1;
      final futureHour1 = (currentHour + 1) % 24;
      final futureHour2 = (currentHour + 2) % 24;
      final futureHour3 = (currentHour + 3) % 24;
      final futureHour4 = (currentHour + 4) % 24;

      final homeClient = FakeExhibitionHomeAggregationClient(
        onLoad: (_) {
          final seeded = contentHomeResult();
          final payload = Map<String, Object?>.from(
            seeded.payload! as Map<String, Object?>,
          );
          payload['hourlyForecast'] = <Object?>[
            <String, Object?>{
              'timeLabel': timeLabel(previousHour),
              'weather': '多云',
              'temperature': 19,
              'precipitationProbability': 10,
            },
            <String, Object?>{
              'timeLabel': timeLabel(currentHour),
              'weather': '多云',
              'temperature': 20,
              'precipitationProbability': 10,
            },
            <String, Object?>{
              'timeLabel': timeLabel(futureHour1),
              'weather': '晴',
              'temperature': 21,
              'precipitationProbability': 10,
            },
            <String, Object?>{
              'timeLabel': timeLabel(futureHour2),
              'weather': '晴',
              'temperature': 22,
              'precipitationProbability': 10,
            },
            <String, Object?>{
              'timeLabel': timeLabel(futureHour3),
              'weather': '晴',
              'temperature': 23,
              'precipitationProbability': 10,
            },
            <String, Object?>{
              'timeLabel': timeLabel(futureHour4),
              'weather': '晴',
              'temperature': 24,
              'precipitationProbability': 10,
            },
          ];
          return ExhibitionLoadResult(
            state: seeded.state,
            method: seeded.method,
            path: seeded.path,
            payload: payload,
            errorCode: seeded.errorCode,
            message: seeded.message,
          );
        },
      );
      final locationService = FakeDeviceLocationService();
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/project/list': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: const <String, Object?>{'items': <Object?>[]},
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          homeClient: homeClient,
          locationService: locationService,
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('展开天气卡'));
      await tester.pumpAndSettle();

      expect(find.text('小时预报'), findsOneWidget);
      expect(find.text(timeLabel(currentHour)), findsNothing);
      if (currentHour > 0) {
        expect(find.text(timeLabel(previousHour)), findsNothing);
      }
      expect(find.text(timeLabel(futureHour1)), findsOneWidget);
      expect(find.text(timeLabel(futureHour2)), findsOneWidget);
      expect(find.text(timeLabel(futureHour3)), findsOneWidget);
      expect(find.text(timeLabel(futureHour4)), findsOneWidget);
    },
  );

  testWidgets(
    'manual refresh and five minute timer both refresh the whole page',
    (WidgetTester tester) async {
      var projectRequestCount = 0;
      final homeClient = FakeExhibitionHomeAggregationClient();
      final locationService = FakeDeviceLocationService();
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/project/list': (AppApiRequest request) async {
                projectRequestCount += 1;
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: const <String, Object?>{'items': <Object?>[]},
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          homeClient: homeClient,
          locationService: locationService,
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      expect(homeClient.loadCount, 1);
      expect(homeClient.refreshCount, 0);
      expect(locationService.requestCount, 1);
      expect(projectRequestCount, 1);

      await tester.tap(find.byTooltip('整页刷新'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(homeClient.refreshCount, 1);
      expect(locationService.requestCount, 2);
      expect(projectRequestCount, 2);

      await tester.pump(const Duration(minutes: 5));
      await tester.pumpAndSettle();

      expect(homeClient.refreshCount, 2);
      expect(locationService.requestCount, 3);
      expect(projectRequestCount, 3);
    },
  );

  testWidgets(
    'public home falls back to GET home when refresh path returns unauthorized',
    (WidgetTester tester) async {
      final homeClient = FakeExhibitionHomeAggregationClient(
        onLoad: (_) => contentHomeResult(
          displayName: '上海',
          provinceName: '上海',
          constructionRiskSummary: '今日施工重点：天气条件整体平稳，可按计划推进。',
        ),
        onRefresh: (_) => ExhibitionLoadResult(
          state: AppPageState.unauthorized,
          method: 'POST',
          path: ExhibitionCanonicalPaths.exhibitionHomeRefresh,
          errorCode: 'AUTH_SESSION_INVALID',
          message: 'Request must include a valid session carrier.',
        ),
      );
      final locationService = FakeDeviceLocationService();
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/project/list': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: const <String, Object?>{'items': <Object?>[]},
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          homeClient: homeClient,
          locationService: locationService,
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('整页刷新'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(homeClient.refreshCount, 1);
      expect(homeClient.loadCount, 2);
      expect(find.textContaining('登录状态已失效'), findsNothing);
      expect(find.textContaining('天气条件整体平稳'), findsWidgets);
      expect(find.textContaining('上海'), findsWidgets);
    },
  );

  testWidgets(
    'manual location selection stays active for manual refresh and auto refresh',
    (WidgetTester tester) async {
      final homeClient = FakeExhibitionHomeAggregationClient(
        onLoad: (_) =>
            contentHomeResult(displayName: '成都市', provinceName: '四川'),
        onSelectLocation: (selection) => contentHomeResult(
          displayName: selection.cityName ?? selection.provinceName,
          provinceName: selection.provinceName,
          selectionScope: 'request_only',
          selectionNotice: '当前选择仅用于当前首页聚合',
        ),
        onRefresh: (locationContext) => contentHomeResult(
          displayName: locationContext?.provinceName ?? '当前地区',
          provinceName: locationContext?.provinceName ?? '当前地区',
          selectionScope: 'request_only',
          selectionNotice: '当前选择仅用于当前首页聚合',
        ),
      );
      final locationService = FakeDeviceLocationService();
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/project/list': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: const <String, Object?>{'items': <Object?>[]},
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          homeClient: homeClient,
          locationService: locationService,
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.widgetWithText(OutlinedButton, '手动选择地区'));
      await tester.tap(find.widgetWithText(OutlinedButton, '手动选择地区'));
      await tester.pumpAndSettle();

      expect(find.text('选择城市', skipOffstage: false), findsOneWidget);
      await tester.tap(
        find.widgetWithText(CupertinoButton, '确定', skipOffstage: false),
      );
      await tester.pumpAndSettle();

      expect(homeClient.selectLocationCount, 1);
      expect(locationService.requestCount, 1);

      await tester.drag(find.byType(ListView).first, const Offset(0, 240));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('整页刷新'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(homeClient.refreshCount, 1);
      expect(locationService.requestCount, 1);
      expect(
        homeClient.lastRefreshLocationContext?.provinceName,
        homeClient.lastSelectedLocation?.provinceName,
      );
      expect(homeClient.lastRefreshLocationContext?.latitude, isNull);
      expect(
        find.text(homeClient.lastSelectedLocation?.provinceName ?? ''),
        findsOneWidget,
      );

      await tester.pump(const Duration(minutes: 5));
      await tester.pumpAndSettle();

      expect(homeClient.refreshCount, 2);
      expect(locationService.requestCount, 1);
      expect(
        homeClient.lastRefreshLocationContext?.provinceName,
        homeClient.lastSelectedLocation?.provinceName,
      );
      expect(
        find.text(homeClient.lastSelectedLocation?.provinceName ?? ''),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'manual location selection falls back to GET home when select path returns unauthorized',
    (WidgetTester tester) async {
      final homeClient = FakeExhibitionHomeAggregationClient(
        onLoad: (locationContext) => contentHomeResult(
          displayName: locationContext?.provinceName ?? '成都市',
          provinceName: locationContext?.provinceName ?? '四川',
          selectionScope: 'request_only',
          selectionNotice: '当前选择仅用于当前首页聚合',
        ),
        onSelectLocation: (_) => ExhibitionLoadResult(
          state: AppPageState.unauthorized,
          method: 'POST',
          path: ExhibitionCanonicalPaths.exhibitionHomeLocationSelect,
          errorCode: 'AUTH_SESSION_INVALID',
          message: 'Request must include a valid session carrier.',
        ),
      );
      final locationService = FakeDeviceLocationService();
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/project/list': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: const <String, Object?>{'items': <Object?>[]},
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          homeClient: homeClient,
          locationService: locationService,
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.widgetWithText(OutlinedButton, '手动选择地区'));
      await tester.tap(find.widgetWithText(OutlinedButton, '手动选择地区'));
      await tester.pumpAndSettle();

      expect(find.text('选择城市', skipOffstage: false), findsOneWidget);
      await tester.tap(
        find.widgetWithText(CupertinoButton, '确定', skipOffstage: false),
      );
      await tester.pumpAndSettle();

      expect(homeClient.selectLocationCount, 1);
      expect(homeClient.loadCount, 2);
      expect(
        homeClient.lastLoadLocationContext?.provinceName,
        homeClient.lastSelectedLocation?.provinceName,
      );
      expect(
        find.text(homeClient.lastSelectedLocation?.provinceName ?? ''),
        findsOneWidget,
      );
      expect(find.textContaining('登录状态已失效'), findsNothing);
    },
  );

  testWidgets(
    'manual location selection calls canonical select path and updates home',
    (WidgetTester tester) async {
      final homeClient = FakeExhibitionHomeAggregationClient(
        onLoad: (_) =>
            contentHomeResult(displayName: '重庆市', provinceName: '重庆'),
        onSelectLocation: (selection) => contentHomeResult(
          displayName: selection.cityName ?? selection.provinceName,
          provinceName: selection.provinceName,
          selectionScope: 'request_only',
          selectionNotice: '当前选择仅用于当前首页聚合',
        ),
      );
      final locationService = FakeDeviceLocationService();
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/project/list': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: const <String, Object?>{'items': <Object?>[]},
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          homeClient: homeClient,
          locationService: locationService,
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.widgetWithText(OutlinedButton, '手动选择地区'));
      await tester.tap(find.widgetWithText(OutlinedButton, '手动选择地区'));
      await tester.pumpAndSettle();

      expect(find.text('选择城市', skipOffstage: false), findsOneWidget);
      await tester.tap(
        find.widgetWithText(CupertinoButton, '确定', skipOffstage: false),
      );
      await tester.pumpAndSettle();

      expect(homeClient.selectLocationCount, 1);
      expect(homeClient.lastSelectedLocation?.provinceName, '重庆');
      expect(find.textContaining('天气平稳'), findsOneWidget);
    },
  );

  testWidgets(
    'last known location context survives account-scoped page rebuilds',
    (WidgetTester tester) async {
      final firstHomeClient = FakeExhibitionHomeAggregationClient(
        onLoad: (locationContext) => contentHomeResult(
          displayName: locationContext?.provinceName ?? '当前地区',
          provinceName: locationContext?.provinceName ?? '当前地区',
        ),
      );
      final firstLocationService = FakeDeviceLocationService(
        resolver: () => const DeviceLocationSnapshot(
          permissionState: DeviceLocationPermissionState.granted,
          latitude: 29.5630,
          longitude: 106.5516,
          provinceCode: '500000',
          provinceName: '重庆',
        ),
      );
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/project/list': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: const <String, Object?>{'items': <Object?>[]},
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          homeClient: firstHomeClient,
          locationService: firstLocationService,
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      expect(firstHomeClient.lastLoadLocationContext?.provinceName, '重庆');
      expect(firstHomeClient.lastLoadLocationContext?.latitude, 29.5630);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      final secondHomeClient = FakeExhibitionHomeAggregationClient(
        onLoad: (locationContext) => contentHomeResult(
          displayName: locationContext?.provinceName ?? '当前地区',
          provinceName: locationContext?.provinceName ?? '当前地区',
        ),
      );
      final unavailableLocationService = FakeDeviceLocationService(
        resolver: () => const DeviceLocationSnapshot(
          permissionState: DeviceLocationPermissionState.unavailable,
          errorMessage: '设备定位当前不可用。',
        ),
      );

      await tester.pumpWidget(
        _buildApp(
          homeClient: secondHomeClient,
          locationService: unavailableLocationService,
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      expect(secondHomeClient.lastLoadLocationContext?.provinceName, '重庆');
      expect(secondHomeClient.lastLoadLocationContext?.latitude, 29.5630);
      expect(find.textContaining('重庆'), findsWidgets);
      expect(find.text('当前地区说明：地区已同步，天气暂不可用'), findsNothing);
    },
  );

  testWidgets(
    'persisted location context survives store reset and unavailable relaunch',
    (WidgetTester tester) async {
      final firstHomeClient = FakeExhibitionHomeAggregationClient(
        onLoad: (locationContext) => contentHomeResult(
          displayName: locationContext?.cityName ?? '重庆南岸',
          provinceName: locationContext?.provinceName ?? '重庆市',
        ),
      );
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/project/list': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: const <String, Object?>{'items': <Object?>[]},
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          homeClient: firstHomeClient,
          locationService: FakeDeviceLocationService(
            resolver: () => const DeviceLocationSnapshot(
              permissionState: DeviceLocationPermissionState.granted,
              latitude: 29.5630,
              longitude: 106.5516,
              provinceCode: '500000',
              provinceName: '重庆市',
            ),
          ),
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 1));

      ExhibitionHomeLocationContextStore.reset();

      final secondHomeClient = FakeExhibitionHomeAggregationClient(
        onLoad: (locationContext) => contentHomeResult(
          displayName: locationContext?.provinceName ?? '当前地区',
          provinceName: locationContext?.provinceName ?? '当前地区',
        ),
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await tester.pumpWidget(
        _buildApp(
          homeClient: secondHomeClient,
          locationService: FakeDeviceLocationService(
            resolver: () => const DeviceLocationSnapshot(
              permissionState: DeviceLocationPermissionState.unavailable,
              errorMessage: '设备定位当前不可用。',
            ),
          ),
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      expect(secondHomeClient.lastLoadLocationContext?.provinceName, '重庆');
      expect(secondHomeClient.lastLoadLocationContext?.latitude, 29.5630);
      expect(find.textContaining('重庆'), findsWidgets);
      expect(find.text('当前地区说明：地区已同步，天气暂不可用'), findsNothing);
    },
  );

  testWidgets(
    'successful home result seeds device-level location fallback across accounts',
    (WidgetTester tester) async {
      final firstHomeClient = FakeExhibitionHomeAggregationClient(
        onLoad: (_) => contentHomeResult(
          displayName: '重庆市南岸区',
          provinceCode: '500000',
          provinceName: '重庆市',
          cityName: '重庆市',
          districtName: '南岸区',
          latitude: null,
          longitude: null,
        ),
      );
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/project/list': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: const <String, Object?>{'items': <Object?>[]},
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          homeClient: firstHomeClient,
          locationService: FakeDeviceLocationService(
            resolver: () => const DeviceLocationSnapshot(
              permissionState: DeviceLocationPermissionState.unavailable,
              errorMessage: '设备定位当前不可用。',
            ),
          ),
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 1));

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      final secondHomeClient = FakeExhibitionHomeAggregationClient(
        onLoad: (locationContext) => contentHomeResult(
          displayName: locationContext?.districtName == null
              ? (locationContext?.cityName ??
                    locationContext?.provinceName ??
                    '当前地区')
              : '${locationContext!.cityName}${locationContext.districtName}',
          provinceCode: locationContext?.provinceCode,
          provinceName: locationContext?.provinceName ?? '当前地区',
          cityName: locationContext?.cityName,
          districtName: locationContext?.districtName,
          latitude: locationContext?.latitude,
          longitude: locationContext?.longitude,
        ),
      );

      await tester.pumpWidget(
        _buildApp(
          homeClient: secondHomeClient,
          locationService: FakeDeviceLocationService(
            resolver: () => const DeviceLocationSnapshot(
              permissionState: DeviceLocationPermissionState.unavailable,
              errorMessage: '设备定位当前不可用。',
            ),
          ),
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      expect(secondHomeClient.lastLoadLocationContext?.provinceCode, '500000');
      expect(secondHomeClient.lastLoadLocationContext?.provinceName, '重庆市');
      expect(secondHomeClient.lastLoadLocationContext?.cityName, '重庆市');
      expect(secondHomeClient.lastLoadLocationContext?.districtName, '南岸区');
      expect(find.textContaining('重庆市南岸区'), findsWidgets);
      expect(find.text('当前地区 已同步，天气暂不可用'), findsNothing);
    },
  );

  test('GET weather query keeps city and district hints', () {
    final query = ExhibitionHomeLocationContextRequest(
      provinceCode: '500000',
      provinceName: '重庆市',
      cityName: '重庆市',
      districtName: '南岸区',
      locationPermissionState: 'granted',
    ).toQueryParameters();

    expect(query['provinceCode'], '500000');
    expect(query['provinceName'], '重庆市');
    expect(query['cityName'], '重庆市');
    expect(query['districtName'], '南岸区');
    expect(query['locationPermissionState'], 'granted');
  });

  testWidgets('home refreshes after account session changes', (
    WidgetTester tester,
  ) async {
    final sessionStore = AppSessionStore();
    var locationRequests = 0;
    final locationService = FakeDeviceLocationService(
      resolver: () {
        locationRequests += 1;
        if (locationRequests == 1) {
          return const DeviceLocationSnapshot(
            permissionState: DeviceLocationPermissionState.unavailable,
            errorMessage: '设备定位当前不可用。',
          );
        }

        return const DeviceLocationSnapshot(
          permissionState: DeviceLocationPermissionState.granted,
          latitude: 29.5630,
          longitude: 106.5516,
          provinceCode: '500000',
          provinceName: '重庆市',
        );
      },
    );
    final homeClient = FakeExhibitionHomeAggregationClient(
      onLoad: (locationContext) =>
          locationContext?.hasUsableLocationHints == true
          ? contentHomeResult(
              displayName: '重庆南岸',
              provinceName: '重庆市',
              currentWeather: '小雨',
            )
          : degradedWeatherHomeResult(
              displayName: '当前地区',
              provinceName: '当前地区',
            ),
      onRefresh: (locationContext) =>
          locationContext?.hasUsableLocationHints == true
          ? contentHomeResult(
              displayName: '重庆南岸',
              provinceName: '重庆市',
              currentWeather: '小雨',
            )
          : degradedWeatherHomeResult(
              displayName: '当前地区',
              provinceName: '当前地区',
            ),
    );
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/project/list': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: const <String, Object?>{'items': <Object?>[]},
              );
            },
          },
    );

    await tester.pumpWidget(
      _buildApp(
        homeClient: homeClient,
        locationService: locationService,
        transport: transport,
        sessionStore: sessionStore,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('当前地区 已同步，天气暂不可用'), findsOneWidget);

    sessionStore.establishSession(
      accessToken: 'access-token-a',
      refreshToken: 'refresh-token-a',
      expiresInSeconds: 3600,
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(homeClient.refreshCount, greaterThanOrEqualTo(1));
    expect(find.text('当前地区 已同步，天气暂不可用'), findsNothing);
    expect(find.textContaining('重庆南岸'), findsWidgets);
  });
}
