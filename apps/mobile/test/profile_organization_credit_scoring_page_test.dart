import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/core/location/device_location_service.dart';
import 'package:mobile/features/profile/data/profile_organization_credit_scoring_consumer_layer.dart';
import 'package:mobile/features/profile/navigation/profile_routes.dart';
import 'package:mobile/shell/shell_app.dart';

const String _outputDir =
    '/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/test_artifacts/organization_credit_scoring_reserve';

final class _ReserveDeviceLocationService implements DeviceLocationService {
  @override
  bool get supportsDeviceLocation => false;

  @override
  bool get supportsReverseGeocoding => false;

  @override
  Future<DeviceLocationPermissionSnapshot> readPermissionStatus() async {
    return const DeviceLocationPermissionSnapshot(
      permissionState: DeviceLocationPermissionState.unavailable,
      serviceEnabled: false,
      message: '当前环境未接入设备定位。',
    );
  }

  @override
  Future<bool> openAppPermissionSettings() async => false;

  @override
  Future<bool> openSystemLocationSettings() async => false;

  @override
  Future<DeviceLocationSnapshot> resolveCurrentPosition() async {
    return const DeviceLocationSnapshot(
      permissionState: DeviceLocationPermissionState.unavailable,
      errorMessage: '当前环境未接入设备定位。',
    );
  }
}

AppShellContextData _shellContext() {
  return AppShellContextData(
    userId: '13812345678',
    organizationId: 'org-credit',
    roleKeys: <String>['buyer_admin'],
    certificationStatus: 'approved',
    membershipStatus: 'active',
    visibleBuildings: <String>['exhibition', 'messages', 'profile'],
  );
}

Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
_creditHandlers({required bool sufficient}) {
  return <String, Future<AppApiResponse> Function(AppApiRequest request)>{
    'GET /api/app/profile/organization-credit-scoring/status':
        (AppApiRequest request) async => AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: sufficient
              ? const <String, Object?>{
                  'score': 86,
                  'tierCode': 'STABLE_A',
                  'tierLabel': '稳态档位',
                  'sampleStatus': 'SUFFICIENT',
                  'riskPosture': 'LOW',
                  'ratedCompletedOrderCount': 18,
                  'positiveRate': 0.94,
                  'negativeRate': 0.06,
                  'verySatisfiedCount': 12,
                  'satisfiedCount': 5,
                  'passableCount': 1,
                  'negativeCount': 0,
                  'actionableState': '继续观察',
                  'updatedAt': '2026-04-14T09:00:00Z',
                }
              : const <String, Object?>{
                  'score': null,
                  'tierCode': null,
                  'tierLabel': null,
                  'sampleStatus': 'INSUFFICIENT',
                  'riskPosture': null,
                  'ratedCompletedOrderCount': 4,
                  'positiveRate': null,
                  'negativeRate': null,
                  'verySatisfiedCount': 2,
                  'satisfiedCount': 1,
                  'passableCount': 1,
                  'negativeCount': 0,
                  'actionableState': null,
                  'updatedAt': '2026-04-14T09:00:00Z',
                },
        ),
    'GET /api/app/profile/organization-credit-scoring/explanation':
        (AppApiRequest request) async => AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: sufficient
              ? const <String, Object?>{
                  'reasonSummary': '未来主线 reserve 只读说明摘要',
                  'reasonCodes': <Object?>[
                    'order_rating_sample_ready',
                    'low_negative_rate',
                  ],
                  'sampleStatus': 'SUFFICIENT',
                  'riskPosture': 'LOW',
                  'ratedCompletedOrderCount': 18,
                  'positiveRate': 0.94,
                  'negativeRate': 0.06,
                  'verySatisfiedCount': 12,
                  'satisfiedCount': 5,
                  'passableCount': 1,
                  'negativeCount': 0,
                  'updatedAt': '2026-04-14T09:00:00Z',
                }
              : const <String, Object?>{
                  'reasonSummary':
                      '当前有效评价样本不足，future-mainline reserve 仅展示只读占位。',
                  'reasonCodes': <Object?>[
                    'SAMPLE_INSUFFICIENT',
                    'RATING_ONLY_MODE_ACTIVE',
                  ],
                  'sampleStatus': 'INSUFFICIENT',
                  'riskPosture': null,
                  'ratedCompletedOrderCount': 4,
                  'positiveRate': null,
                  'negativeRate': null,
                  'verySatisfiedCount': 2,
                  'satisfiedCount': 1,
                  'passableCount': 1,
                  'negativeCount': 0,
                  'updatedAt': '2026-04-14T09:00:00Z',
                },
        ),
    'GET /api/app/profile/organization-credit-scoring/handoff':
        (AppApiRequest request) async => AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: sufficient
              ? const <String, Object?>{
                  'actionableState': '继续观察',
                  'sampleStatus': 'SUFFICIENT',
                  'riskPosture': 'LOW',
                  'primaryActionCode': 'continue_observe',
                  'primaryActionLabel': '继续观察',
                  'handoffMessage': '未来主线 reserve 仅作只读衔接',
                  'updatedAt': '2026-04-14T09:00:00Z',
                }
              : const <String, Object?>{
                  'actionableState': null,
                  'sampleStatus': 'INSUFFICIENT',
                  'riskPosture': null,
                  'primaryActionCode': null,
                  'primaryActionLabel': null,
                  'handoffMessage': null,
                  'updatedAt': '2026-04-14T09:00:00Z',
                },
        ),
  };
}

void _installReserveConsumer({required bool sufficient}) {
  ProfileOrganizationCreditScoringConsumerLayer.install(
    ProfileOrganizationCreditScoringConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers: _creditHandlers(sufficient: sufficient),
        ),
      ),
    ),
  );
}

Future<void> _pumpReserveApp(
  WidgetTester tester, {
  required bool sufficient,
  required GlobalKey boundaryKey,
  String initialRoute = ProfileRoutes.organizationCreditScoring,
}) async {
  _installReserveConsumer(sufficient: sufficient);
  final sessionStore = AppSessionStore();
  sessionStore.establishSession(
    accessToken: 'reserve-access-token',
    refreshToken: 'reserve-refresh-token',
    expiresInSeconds: 7200,
    deviceId: 'reserve-device',
    localLoginSource: AppSessionLoginSource.passwordLogin,
  );

  await tester.pumpWidget(
    RepaintBoundary(
      key: boundaryKey,
      child: KeyedSubtree(
        key: UniqueKey(),
        child: ExhibitionMobileApp(
          initialRoute: initialRoute,
          bootstrapShellContext: _shellContext(),
          sessionStore: sessionStore,
          deviceLocationService: _ReserveDeviceLocationService(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _capture(GlobalKey boundaryKey, String filename) async {
  await expectLater(
    find.byKey(boundaryKey),
    matchesGoldenFile('$_outputDir/$filename'),
  );
}

Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    240,
    scrollable: find.byType(Scrollable).first,
  );
}

Future<void> _scrollPastBottomNav(WidgetTester tester) async {
  await tester.drag(find.byType(Scrollable).first, const Offset(0, -180));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    Directory(_outputDir).createSync(recursive: true);
  });

  tearDown(() {
    ProfileOrganizationCreditScoringConsumerLayer.reset();
  });

  testWidgets('reserve empty state keeps real placeholders readable', (
    WidgetTester tester,
  ) async {
    final boundaryKey = GlobalKey();
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _pumpReserveApp(tester, sufficient: false, boundaryKey: boundaryKey);

    expect(find.text('组织信用评分'), findsWidgets);
    expect(find.text('future-mainline reserve'), findsWidgets);
    expect(find.text('当前暂无评分'), findsOneWidget);
    expect(find.text('样本不足'), findsWidgets);
    expect(find.text('风险姿态暂未提供'), findsWidgets);
    expect(find.text('当前暂无可执行建议'), findsOneWidget);
    await _scrollTo(tester, find.text('已评分完成订单数'));
    expect(find.text('已评分完成订单数'), findsOneWidget);
    expect(find.text('-'), findsNWidgets(2));
  });

  testWidgets(
    'reserve sufficient state renders true values without fake copy',
    (WidgetTester tester) async {
      final boundaryKey = GlobalKey();
      await tester.binding.setSurfaceSize(const Size(393, 852));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await _pumpReserveApp(tester, sufficient: true, boundaryKey: boundaryKey);

      expect(find.text('评分 86'), findsNWidgets(2));
      expect(find.text('稳态档位'), findsOneWidget);
      expect(find.text('STABLE_A'), findsOneWidget);
      expect(find.text('低风险姿态'), findsWidgets);
      expect(find.text('继续观察'), findsWidgets);
      await _scrollTo(tester, find.text('94%'));
      expect(find.text('94%'), findsOneWidget);
      expect(find.text('6%'), findsOneWidget);
    },
  );

  testWidgets('reserve page keeps explanation and handoff entry routes', (
    WidgetTester tester,
  ) async {
    final boundaryKey = GlobalKey();
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _pumpReserveApp(tester, sufficient: false, boundaryKey: boundaryKey);

    await _scrollTo(tester, find.text('说明页'));
    await tester.tap(find.text('说明页'));
    await tester.pumpAndSettle();
    expect(find.text('组织信用评分说明'), findsWidgets);
    expect(find.textContaining('当前有效评价样本不足'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    await _scrollTo(tester, find.text('衔接页'));
    await tester.tap(find.text('衔接页'));
    await tester.pumpAndSettle();
    expect(find.text('组织信用评分衔接'), findsWidgets);
    await _scrollTo(tester, find.text('当前暂无衔接说明'));
    expect(find.text('当前暂无衔接说明'), findsOneWidget);
  });

  testWidgets(
    'reserve page keeps last action card above bottom navigation on narrow width',
    (WidgetTester tester) async {
      final boundaryKey = GlobalKey();
      await tester.binding.setSurfaceSize(const Size(360, 720));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await _pumpReserveApp(
        tester,
        sufficient: false,
        boundaryKey: boundaryKey,
      );

      await _scrollTo(tester, find.text('衔接页'));
      await _scrollPastBottomNav(tester);
      final handoffCard = find.ancestor(
        of: find.text('衔接页'),
        matching: find.byType(InkWell),
      );
      final handoffRect = tester.getRect(handoffCard.first);
      final navigationRect = tester.getRect(find.byType(NavigationBar));
      expect(handoffRect.bottom, lessThan(navigationRect.top));
    },
  );

  testWidgets('capture reserve status screenshots', (
    WidgetTester tester,
  ) async {
    final boundaryKey = GlobalKey();
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.binding.setSurfaceSize(const Size(430, 1500));
    await _pumpReserveApp(tester, sufficient: false, boundaryKey: boundaryKey);
    await _capture(boundaryKey, 'status-default-width.png');

    await tester.binding.setSurfaceSize(const Size(360, 1500));
    await _pumpReserveApp(tester, sufficient: false, boundaryKey: boundaryKey);
    await tester.pumpAndSettle();
    await _capture(boundaryKey, 'status-narrow-width.png');
  });
}
