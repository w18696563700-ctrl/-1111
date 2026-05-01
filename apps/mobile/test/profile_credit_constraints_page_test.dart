import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/boot/app_bootstrap_controller.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/core/location/device_location_service.dart';
import 'package:mobile/features/profile/data/profile_credit_constraints_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_payment_billing_consumer_layer.dart';
import 'package:mobile/features/profile/presentation/profile_detail_pages.dart';
import 'package:mobile/shell/context/app_shell_scope.dart';
import 'package:mobile/shell/navigation/app_building.dart';
import 'package:mobile/shell/presentation/app_shell_scaffold.dart';

const String _outputDir =
    '/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/test_artifacts/profile_credit_constraints';

final class _CreditDeviceLocationService implements DeviceLocationService {
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
    organizationId: 'org-credit-constraints',
    roleKeys: <String>['buyer_admin'],
    certificationStatus: 'approved',
    membershipStatus: 'active',
    visibleBuildings: <String>['exhibition', 'messages', 'profile'],
  );
}

Map<String, Object?> _statusPayload({required bool limited}) {
  return <String, Object?>{
    'privateSummary': <String, Object?>{
      'entryKey': 'my_credit_and_constraints',
      'summaryStatus': limited ? 'limited' : 'handoff_required',
      'creditConstraintStatus': limited ? 'constrained' : 'clear',
      'depositPostureStatus': limited ? 'clear' : 'handoff_required',
      'transactionGuaranteeEligibilityStatus': limited
          ? 'not_eligible'
          : 'eligible',
      'updatedAt': '2026-04-09 10:31:05',
    },
    'creditConstraint': <String, Object?>{
      'creditConstraintStatus': limited ? 'constrained' : 'clear',
      'performanceConstraintStatus': 'clear',
      'executionAvailabilityStatus': limited ? 'limited' : 'available',
      'restrictionReasonCode': limited ? 'credit_restriction' : null,
      'advisoryReasonCode': limited ? 'credit_advisory' : null,
      'updatedAt': '2026-04-09 10:31:05',
    },
    'deposit': <String, Object?>{
      'depositRequirementStatus': limited ? 'not_required' : 'required',
      'depositEligibilityStatus': limited ? 'not_eligible' : 'eligible',
      'depositRestrictionStatus': limited ? 'restricted' : 'clear',
      'depositPostureStatus': limited ? 'clear' : 'handoff_required',
      'depositHandoffKey': 'deposit_open_payment_dependency',
      'depositDependencyKey': limited ? null : 'v22_payment_billing_required',
      'updatedAt': '2026-04-09 10:31:05',
    },
    'transactionGuarantee': <String, Object?>{
      'transactionGuaranteeEligibilityStatus': limited
          ? 'not_eligible'
          : 'eligible',
      'transactionGuaranteeRestrictionStatus': limited ? 'restricted' : 'clear',
      'transactionGuaranteeExplanationKey':
          'transaction_guarantee_dependency_required',
      'transactionGuaranteeHandoffKey': 'transaction_guarantee_open_dependency',
      'transactionGuaranteeDependencyKey': limited
          ? null
          : 'v22_payment_billing_required',
      'updatedAt': '2026-04-09 10:31:05',
    },
    'dependencyReference': limited
        ? null
        : <String, Object?>{
            'dependencyFamilyKey': 'v22_payment_billing',
            'dependencyRequired': true,
            'dependencyExplanationKey': 'requires_v22_payment_billing',
            'dependencyHandoffKey': 'open_v22_payment_billing',
          },
  };
}

Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
_creditHandlers({required bool limited}) {
  return <String, Future<AppApiResponse> Function(AppApiRequest request)>{
    'GET /api/app/profile/credit-and-constraints/status':
        (AppApiRequest request) async => AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: _statusPayload(limited: limited),
        ),
    'GET /api/app/profile/credit-and-constraints/explanation':
        (AppApiRequest request) async => AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: const <String, Object?>{
            'creditExplanation': <String, Object?>{
              'explanationKey': 'credit_advisory',
              'title': '当前信用约束',
              'body': '当前没有硬阻断，但存在规则提示。',
            },
            'depositExplanation': <String, Object?>{
              'explanationKey': 'deposit_dependency_required',
              'title': '当前保证金姿态',
              'body': '当前保证金只停在 posture 与 handoff 层。',
            },
            'transactionGuaranteeExplanation': <String, Object?>{
              'explanationKey': 'transaction_guarantee_dependency_required',
              'title': '当前交易保障姿态',
              'body': '当前交易保障仍停在 eligibility、restriction 与 handoff posture。',
            },
            'dependencyExplanation': <String, Object?>{
              'dependencyFamilyKey': 'v22_payment_billing',
              'dependencyRequired': true,
              'dependencyExplanationKey': 'requires_v22_payment_billing',
              'title': '后续依赖',
              'body': '当前真实资金动作仍属于 V2.2 payment/billing package dependency。',
            },
            'disclaimer':
                '当前信用、保证金与交易保障内容只承接 posture、explanation、handoff 与 dependency reference。',
          },
        ),
    'GET /api/app/profile/credit-and-constraints/handoff':
        (AppApiRequest request) async => AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: const <String, Object?>{
            'creditHandoff': <String, Object?>{
              'handoffKey': 'credit_rule_explanation',
              'title': '信用处理方向',
              'body': '当前建议先查看规则说明，确认限制与提示来源。',
            },
            'depositHandoff': <String, Object?>{
              'handoffKey': 'deposit_open_payment_dependency',
              'title': '保证金处理方向',
              'body': '当前不执行具体缴纳或冻结。',
            },
            'transactionGuaranteeHandoff': <String, Object?>{
              'handoffKey': 'transaction_guarantee_open_dependency',
              'title': '交易保障处理方向',
              'body': '当前保障语义只表达 handoff 与 dependency posture。',
            },
            'dependencyHandoff': <String, Object?>{
              'dependencyFamilyKey': 'v22_payment_billing',
              'dependencyRequired': true,
              'dependencyHandoffKey': 'open_v22_payment_billing',
              'title': '后续依赖方向',
              'body': '当前后续动作仍需 V2.2 payment/billing package dependency。',
            },
          },
        ),
  };
}

void _installCreditConsumers({required bool limited}) {
  ProfileCreditConstraintsConsumerLayer.install(
    ProfileCreditConstraintsConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers: _creditHandlers(limited: limited),
        ),
      ),
    ),
  );
  ProfilePaymentBillingConsumerLayer.install(
    ProfilePaymentBillingConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers: <String, Future<AppApiResponse> Function(AppApiRequest)>{
            'GET /api/app/profile/payment-and-billing-status/status':
                (AppApiRequest request) async => AppApiResponse(
                  statusCode: 404,
                  uri: request.uri,
                  body: const <String, Object?>{'message': '暂不可用'},
                ),
          },
        ),
      ),
    ),
  );
}

class _CreditStatusHarness extends StatefulWidget {
  const _CreditStatusHarness();

  @override
  State<_CreditStatusHarness> createState() => _CreditStatusHarnessState();
}

class _CreditStatusHarnessState extends State<_CreditStatusHarness> {
  late final AppBootstrapController _controller = AppBootstrapController(
    bootstrapShellContext: _shellContext(),
  )..initialize();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShellScope(
      controller: _controller,
      child: const MaterialApp(
        home: AppShellScaffold(
          currentBuilding: AppBuilding.profile,
          titleOverride: '我的信用与约束',
          showStageBanner: false,
          child: ProfileCreditConstraintsStatusPage(),
        ),
      ),
    );
  }
}

Future<void> _pumpCreditStatusPage(
  WidgetTester tester, {
  required bool limited,
  required GlobalKey boundaryKey,
}) async {
  _installCreditConsumers(limited: limited);
  final sessionStore = AppSessionStore();
  sessionStore.establishSession(
    accessToken: 'credit-access-token',
    refreshToken: 'credit-refresh-token',
    expiresInSeconds: 7200,
    deviceId: 'credit-device',
    localLoginSource: AppSessionLoginSource.passwordLogin,
  );

  AppSessionStore.install(sessionStore);
  DeviceLocationService.install(_CreditDeviceLocationService());
  await tester.pumpWidget(
    RepaintBoundary(key: boundaryKey, child: const _CreditStatusHarness()),
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
    ProfileCreditConstraintsConsumerLayer.reset();
    ProfilePaymentBillingConsumerLayer.reset();
  });

  testWidgets('default handoff state renders bounded true posture', (
    WidgetTester tester,
  ) async {
    final boundaryKey = GlobalKey();
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _pumpCreditStatusPage(
      tester,
      limited: false,
      boundaryKey: boundaryKey,
    );

    expect(find.text('我的信用与约束'), findsWidgets);
    expect(find.text('部分可用'), findsWidgets);
    expect(find.text('当前需后续衔接'), findsWidgets);
    expect(find.textContaining('当前无信用约束'), findsWidgets);
    expect(find.textContaining('当前保证金需后续衔接'), findsWidgets);
    expect(find.textContaining('当前具备交易保障资格'), findsWidgets);
    expect(find.textContaining('依赖 V2.2 支付 / 账单能力'), findsWidgets);
    expect(find.textContaining('不执行缴纳、冻结、退款、结算或交易保障开通'), findsOneWidget);
  });

  testWidgets('limited advisory state does not fake available posture', (
    WidgetTester tester,
  ) async {
    final boundaryKey = GlobalKey();
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _pumpCreditStatusPage(
      tester,
      limited: true,
      boundaryKey: boundaryKey,
    );

    expect(find.text('当前存在规则提示'), findsWidgets);
    expect(find.textContaining('当前存在信用约束'), findsWidgets);
    expect(find.textContaining('当前暂不具备交易保障资格'), findsWidgets);
    expect(find.text('当前暂不需要额外依赖'), findsWidgets);
    expect(find.text('当前具备交易保障资格'), findsNothing);
  });

  testWidgets('status page keeps explanation and handoff entry routes', (
    WidgetTester tester,
  ) async {
    final boundaryKey = GlobalKey();
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _pumpCreditStatusPage(
      tester,
      limited: false,
      boundaryKey: boundaryKey,
    );

    await _scrollTo(tester, find.text('规则说明页'));
    await _scrollPastBottomNav(tester);
    await tester.tap(
      find
          .ancestor(of: find.text('规则说明页'), matching: find.byType(InkWell))
          .first,
    );
    await tester.pumpAndSettle();
    expect(find.text('当前信用约束'), findsOneWidget);
    expect(find.text('当前保证金姿态'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    await _scrollTo(tester, find.text('处理与衔接页'));
    await _scrollPastBottomNav(tester);
    await tester.tap(
      find
          .ancestor(of: find.text('处理与衔接页'), matching: find.byType(InkWell))
          .first,
    );
    await tester.pumpAndSettle();
    expect(find.text('信用处理方向'), findsOneWidget);
    expect(find.text('保证金处理方向'), findsOneWidget);
    expect(find.text('交易保障处理方向'), findsOneWidget);
    expect(find.text('后续依赖方向'), findsOneWidget);
  });

  testWidgets(
    'last action card stays above bottom navigation on narrow width',
    (WidgetTester tester) async {
      final boundaryKey = GlobalKey();
      await tester.binding.setSurfaceSize(const Size(360, 720));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await _pumpCreditStatusPage(
        tester,
        limited: false,
        boundaryKey: boundaryKey,
      );

      await _scrollTo(tester, find.text('处理与衔接页'));
      await _scrollPastBottomNav(tester);
      final handoffCard = find.ancestor(
        of: find.text('处理与衔接页'),
        matching: find.byType(InkWell),
      );
      final handoffRect = tester.getRect(handoffCard.first);
      final navigationRect = tester.getRect(find.byType(NavigationBar));
      expect(handoffRect.bottom, lessThan(navigationRect.top));
    },
  );

  testWidgets('capture credit constraints status screenshots', (
    WidgetTester tester,
  ) async {
    final boundaryKey = GlobalKey();
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.binding.setSurfaceSize(const Size(430, 1500));
    await _pumpCreditStatusPage(
      tester,
      limited: false,
      boundaryKey: boundaryKey,
    );
    await _capture(boundaryKey, 'status-default-width.png');

    await tester.binding.setSurfaceSize(const Size(360, 1500));
    await _pumpCreditStatusPage(
      tester,
      limited: false,
      boundaryKey: boundaryKey,
    );
    await tester.pumpAndSettle();
    await _capture(boundaryKey, 'status-narrow-width.png');
  });
}
