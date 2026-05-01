import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/boot/app_bootstrap_controller.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/features/profile/data/profile_payment_billing_consumer_layer.dart';
import 'package:mobile/features/profile/presentation/profile_detail_pages.dart';
import 'package:mobile/shell/context/app_shell_scope.dart';
import 'package:mobile/shell/navigation/app_building.dart';
import 'package:mobile/shell/navigation/app_router.dart';
import 'package:mobile/shell/presentation/app_shell_scaffold.dart';
import 'package:mobile/shared/theme/app_theme.dart';

const String _outputDir =
    '/Users/wangweiwei/Desktop/展览装修之家总控/.tmp/agent_reports/profile_payment_billing_status_overview_20260501';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await _loadFont(
      family: 'STHeiti',
      path: '/System/Library/Fonts/STHeiti Medium.ttc',
    );
    await _loadFont(
      family: 'MaterialIcons',
      path:
          '/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/build/unit_test_assets/fonts/MaterialIcons-Regular.otf',
    );
  });

  setUp(() {
    final sessionStore = AppSessionStore();
    AppSessionStore.install(sessionStore);
    sessionStore.establishSession(
      accessToken: 'payment-billing-capture-access-token',
      refreshToken: 'payment-billing-capture-refresh-token',
      expiresInSeconds: 3600,
      deviceId: 'payment-billing-capture-device',
    );
    ProfilePaymentBillingConsumerLayer.install(
      ProfilePaymentBillingConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/profile/payment-and-billing-status/status':
                      (AppApiRequest request) async {
                        return AppApiResponse(
                          statusCode: 200,
                          uri: request.uri,
                          body: const <String, Object?>{
                            'privateSummary': <String, Object?>{
                              'entryKey': 'payment_and_billing_status',
                              'summaryStatus': 'handoff_required',
                              'paymentStatus': 'handoff_required',
                              'billingReferenceStatus': 'unavailable',
                              'updatedAt': '2026-04-09 11:35:05',
                            },
                            'paymentStatus': <String, Object?>{
                              'paymentStatus': 'handoff_required',
                              'paymentAvailabilityStatus': 'unavailable',
                              'paymentHandoffKey':
                                  'payment_open_future_finance_dependency',
                              'paymentExplanationKey':
                                  'payment_handoff_required',
                              'paymentDependencyKey':
                                  'future_finance_dependency_required',
                              'updatedAt': '2026-04-09 11:35:05',
                            },
                            'billingReference': <String, Object?>{
                              'billingReferenceStatus': 'unavailable',
                              'billingReferenceCode': null,
                              'billingReferenceVisibilityStatus': 'hidden',
                              'billingExplanationKey':
                                  'billing_reference_unavailable',
                              'billingHandoffKey':
                                  'billing_reference_wait_future_reference',
                              'billingDependencyKey':
                                  'future_finance_dependency_required',
                              'updatedAt': '2026-04-09 11:35:05',
                            },
                            'dependencyReference': <String, Object?>{
                              'dependencyFamilyKey':
                                  'future_settlement_clearing_tax_finance_admin',
                              'dependencyRequired': true,
                              'dependencyExplanationKey':
                                  'requires_future_finance_dependency',
                              'dependencyHandoffKey':
                                  'open_future_finance_dependency',
                            },
                          },
                        );
                      },
                },
          ),
        ),
      ),
    );
  });

  tearDown(() async {
    AppSessionStore.reset();
    ProfilePaymentBillingConsumerLayer.reset();
  });

  testWidgets(
    'capture payment-billing overview desktop-width mobile viewport',
    (WidgetTester tester) async {
      final boundaryKey = GlobalKey();
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });
      await _pumpCapture(tester, boundaryKey, const Size(393, 852));
      await _capture(
        boundaryKey,
        'payment_billing_status_overview_393x852.png',
      );
    },
  );

  testWidgets('capture payment-billing overview narrow bottom viewport', (
    WidgetTester tester,
  ) async {
    final boundaryKey = GlobalKey();
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
    await _pumpCapture(tester, boundaryKey, const Size(320, 740));
    await tester.scrollUntilVisible(
      find.text('处理与衔接页'),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('处理与衔接页'), findsOneWidget);
    await _capture(
      boundaryKey,
      'payment_billing_status_overview_narrow_320x740_bottom.png',
    );
  });
}

Future<void> _loadFont({required String family, required String path}) async {
  final bytes = File(path).readAsBytesSync();
  final fontData = ByteData.view(Uint8List.fromList(bytes).buffer);
  await (FontLoader(family)..addFont(Future<ByteData>.value(fontData))).load();
}

Future<void> _pumpCapture(
  WidgetTester tester,
  GlobalKey boundaryKey,
  Size surfaceSize,
) async {
  final controller = AppBootstrapController(
    bootstrapShellContext: AppShellContextData(
      userId: '13812345678',
      organizationId: 'org-payment-billing-capture',
      roleKeys: <String>['buyer_admin'],
      certificationStatus: 'approved',
      membershipStatus: 'active',
      visibleBuildings: <String>['exhibition', 'messages', 'profile'],
    ),
  );
  controller.initialize();
  addTearDown(controller.dispose);

  await tester.binding.setSurfaceSize(surfaceSize);
  await tester.pumpWidget(
    RepaintBoundary(
      key: boundaryKey,
      child: AppShellScope(
        controller: controller,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: _captureTheme(),
          onGenerateRoute: const AppRouter().onGenerateRoute,
          home: AppShellScaffold(
            currentBuilding: AppBuilding.profile,
            titleOverride: '支付与账单状态',
            showStageBanner: false,
            child: const ProfilePaymentBillingStatusPage(),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

ThemeData _captureTheme() {
  final theme = AppTheme.light();
  return theme.copyWith(
    textTheme: theme.textTheme.apply(fontFamily: 'STHeiti'),
    primaryTextTheme: theme.primaryTextTheme.apply(fontFamily: 'STHeiti'),
  );
}

Future<void> _capture(GlobalKey boundaryKey, String filename) async {
  await expectLater(
    find.byKey(boundaryKey),
    matchesGoldenFile('$_outputDir/$filename'),
  );
}
