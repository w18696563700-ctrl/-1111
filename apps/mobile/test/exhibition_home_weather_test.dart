import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/messages/data/messages_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_consumer_layer.dart';
import 'package:mobile/shell/shell_app.dart';

import 'support/exhibition_home_test_doubles.dart';

ExhibitionMobileApp _buildApp({
  required FakeExhibitionHomeAggregationClient homeClient,
  required FakeDeviceLocationService locationService,
  required FakeAppApiTransport transport,
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

      expect(find.text('天气与定位'), findsOneWidget);
      expect(find.text('今日施工重点：正在识别所在地区并同步施工天气'), findsOneWidget);
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
      expect(find.textContaining('同步施工天气与风险建议'), findsOneWidget);
      expect(find.text('所在地区识别中'), findsOneWidget);
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

      expect(find.text('今日施工重点：今晚雷雨风险升高，户外工序建议顺延。'), findsOneWidget);
      expect(find.text('风险：极高风险'), findsOneWidget);
      expect(find.text('5 分钟自动整页刷新'), findsNothing);

      await tester.tap(find.byTooltip('展开天气卡'));
      await tester.pumpAndSettle();

      expect(find.text('今日施工天气总览'), findsOneWidget);
      expect(find.text('施工风险卡'), findsOneWidget);
      expect(find.text('今日施工建议'), findsOneWidget);
      expect(find.text('重庆市雷电黄色预警'), findsOneWidget);
      expect(find.text('降雨 / 夜间降雨 / 官方预警'), findsWidgets);
      expect(find.textContaining('rain / night_rain'), findsNothing);
      expect(find.textContaining('当前地区仅用于本次天气查看'), findsOneWidget);
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
    'hourly forecast only keeps future slots and still caps to four items',
    (WidgetTester tester) async {
      String _timeLabel(int hour) => '${hour.toString().padLeft(2, '0')}:00';
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
              'timeLabel': _timeLabel(previousHour),
              'weather': '多云',
              'temperature': 19,
              'precipitationProbability': 10,
            },
            <String, Object?>{
              'timeLabel': _timeLabel(currentHour),
              'weather': '多云',
              'temperature': 20,
              'precipitationProbability': 10,
            },
            <String, Object?>{
              'timeLabel': _timeLabel(futureHour1),
              'weather': '晴',
              'temperature': 21,
              'precipitationProbability': 10,
            },
            <String, Object?>{
              'timeLabel': _timeLabel(futureHour2),
              'weather': '晴',
              'temperature': 22,
              'precipitationProbability': 10,
            },
            <String, Object?>{
              'timeLabel': _timeLabel(futureHour3),
              'weather': '晴',
              'temperature': 23,
              'precipitationProbability': 10,
            },
            <String, Object?>{
              'timeLabel': _timeLabel(futureHour4),
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
      expect(find.text(_timeLabel(currentHour)), findsNothing);
      if (currentHour > 0) {
        expect(find.text(_timeLabel(previousHour)), findsNothing);
      }
      expect(find.text(_timeLabel(futureHour1)), findsOneWidget);
      expect(find.text(_timeLabel(futureHour2)), findsOneWidget);
      expect(find.text(_timeLabel(futureHour3)), findsOneWidget);
      expect(find.text(_timeLabel(futureHour4)), findsOneWidget);
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
      expect(find.textContaining('今日施工重点：'), findsWidgets);
      expect(find.textContaining('上海'), findsWidgets);
    },
  );

  testWidgets(
    'manual location selection calls canonical select path and updates home',
    (WidgetTester tester) async {
      final homeClient = FakeExhibitionHomeAggregationClient(
        onSelectLocation: (selection) => contentHomeResult(
          displayName: '${selection.provinceName}市',
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

      await tester.tap(find.widgetWithText(FilledButton, '手动选择地区'));
      await tester.pumpAndSettle();

      expect(find.text('手动选择地区'), findsWidgets);
      await tester.tap(find.widgetWithText(FilledButton, '重庆'));
      await tester.pumpAndSettle();

      expect(homeClient.selectLocationCount, 1);
      expect(homeClient.lastSelectedLocation?.provinceName, '重庆');
      expect(find.textContaining('今日施工重点：'), findsOneWidget);
    },
  );
}
