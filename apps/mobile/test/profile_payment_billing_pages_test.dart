import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/features/profile/data/profile_credit_constraints_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_payment_billing_consumer_layer.dart';
import 'profile_payment_billing_test_support.dart';

void main() {
  HttpOverrides? previousHttpOverrides;

  setUp(() {
    previousHttpOverrides = HttpOverrides.current;
    HttpOverrides.global = PassthroughHttpOverrides();
    installDefaultPaymentBillingSupportConsumers();
  });

  tearDown(() {
    HttpOverrides.global = previousHttpOverrides;
    AppSessionStore.reset();
    ProfileCreditConstraintsConsumerLayer.reset();
    ProfilePaymentBillingConsumerLayer.reset();
  });

  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'payment-billing entry consumes summary and the three bounded read pages',
    (WidgetTester tester) async {
      ProfilePaymentBillingConsumerLayer.install(
        ProfilePaymentBillingConsumerLayer(
          client: AppApiClient(
            config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
            transport: FakeAppApiTransport(
              handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
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
                            'billingReferenceStatus': 'available',
                            'updatedAt': '2026-04-06 09:30',
                          },
                          'paymentStatus': <String, Object?>{
                            'paymentStatus': 'handoff_required',
                            'paymentAvailabilityStatus': 'available',
                            'paymentHandoffKey':
                                'payment_open_future_finance_dependency',
                            'paymentExplanationKey': 'payment_handoff_required',
                            'paymentDependencyKey':
                                'future_finance_dependency_required',
                            'updatedAt': '2026-04-06 09:30',
                          },
                          'billingReference': <String, Object?>{
                            'billingReferenceStatus': 'available',
                            'billingReferenceCode': 'BILL-REF-001',
                            'billingReferenceVisibilityStatus': 'visible',
                            'billingExplanationKey':
                                'billing_reference_visible',
                            'billingHandoffKey':
                                'billing_reference_view_current_reference',
                            'billingDependencyKey':
                                'future_finance_dependency_required',
                            'updatedAt': '2026-04-06 09:30',
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
                'GET /api/app/profile/payment-and-billing-status/explanation':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'paymentExplanation': <String, Object?>{
                            'explanationKey': 'payment_handoff_required',
                            'title': '当前支付状态',
                            'body':
                                '当前支付只表达 status、handoff 与 dependency reference。',
                          },
                          'billingExplanation': <String, Object?>{
                            'explanationKey': 'billing_reference_visible',
                            'title': '当前账单参考',
                            'body': '当前仅提供 bounded billing reference。',
                          },
                          'dependencyExplanation': <String, Object?>{
                            'dependencyFamilyKey':
                                'future_settlement_clearing_tax_finance_admin',
                            'dependencyRequired': true,
                            'dependencyExplanationKey':
                                'requires_future_finance_dependency',
                            'title': '后续依赖',
                            'body': '当前更大范围财务动作仍只允许表达为 future dependency。',
                          },
                          'disclaimer':
                              '当前支付与账单内容只承接 payment-status、billing-reference、handoff、explanation 与 dependency reference。',
                        },
                      );
                    },
                'GET /api/app/profile/payment-and-billing-status/handoff':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'paymentHandoff': <String, Object?>{
                            'paymentHandoffKey':
                                'payment_open_future_finance_dependency',
                            'handoffStatus': 'handoff_required',
                            'handoffTargetFamily': 'future_finance_dependency',
                            'handoffExplanationKey':
                                'requires_future_finance_dependency',
                            'dependencyRequired': true,
                            'title': '支付处理方向',
                            'body': '当前支付后续动作只能 handoff 到 future dependency。',
                            'updatedAt': '2026-04-06 09:30',
                          },
                          'billingHandoff': <String, Object?>{
                            'billingHandoffKey':
                                'billing_reference_view_current_reference',
                            'title': '账单参考处理方向',
                            'body': '当前可查看 bounded billing reference。',
                            'updatedAt': '2026-04-06 09:30',
                          },
                          'dependencyHandoff': <String, Object?>{
                            'dependencyFamilyKey':
                                'future_settlement_clearing_tax_finance_admin',
                            'dependencyRequired': true,
                            'dependencyHandoffKey':
                                'open_future_finance_dependency',
                            'title': '后续依赖方向',
                            'body': '当前更大范围财务动作仍只允许表达为 future dependency。',
                          },
                        },
                      );
                    },
              },
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        buildPaymentBillingProfileApp(
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/profile/index': (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: paymentBillingProfilePayload(
                        organizationId: 'org-payment',
                        roleKeys: const <String>['buyer_admin'],
                        certificationStatus: 'approved',
                        membershipStatus: 'active',
                      ),
                    );
                  },
                },
          ),
          shellContext: paymentBillingShellContextData(
            organizationId: 'org-payment',
            roleKeys: const <String>['buyer_admin'],
            certificationStatus: 'approved',
            membershipStatus: 'active',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('支付与账单状态'));
      expect(find.text('支付与账单状态'), findsOneWidget);
      expect(find.textContaining('当前支付状态、账单引用与处理衔接摘要'), findsOneWidget);
      expect(find.text('我的项目'), findsOneWidget);
      expect(find.text('我的论坛'), findsOneWidget);
      expect(find.text('设置'), findsWidgets);

      await tester.tap(find.text('支付与账单状态'));
      await tester.pumpAndSettle();

      expect(find.text('当前摘要'), findsOneWidget);
      expect(find.text('当前需后续衔接'), findsWidgets);
      expect(find.textContaining('后续结算 / 清分 / 税务 / 财务后台依赖'), findsWidgets);
      await scrollTo(tester, find.text('BILL-REF-001'));
      expect(find.text('BILL-REF-001'), findsOneWidget);

      await scrollTo(tester, find.text('规则说明页'));
      await tester.tap(find.text('规则说明页'));
      await tester.pumpAndSettle();
      expect(find.text('当前支付状态'), findsOneWidget);
      expect(find.text('当前账单参考'), findsOneWidget);
      expect(find.text('后续依赖'), findsWidgets);

      await tester.pageBack();
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('处理与衔接页'));
      await tester.tap(find.text('处理与衔接页'));
      await tester.pumpAndSettle();
      expect(find.text('支付处理方向'), findsOneWidget);
      expect(find.text('账单参考处理方向'), findsOneWidget);
      expect(find.text('后续依赖方向'), findsOneWidget);
    },
  );

  testWidgets(
    'payment-billing keeps controlled unavailable state when route is unavailable',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildPaymentBillingProfileApp(
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/profile/index': (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: paymentBillingProfilePayload(
                        organizationId: 'org-payment',
                        roleKeys: const <String>['buyer_admin'],
                        certificationStatus: 'approved',
                        membershipStatus: 'active',
                      ),
                    );
                  },
                },
          ),
          shellContext: paymentBillingShellContextData(
            organizationId: 'org-payment',
            roleKeys: const <String>['buyer_admin'],
            certificationStatus: 'approved',
            membershipStatus: 'active',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('支付与账单状态'));
      await tester.tap(find.text('支付与账单状态'));
      await tester.pumpAndSettle();

      expect(find.text('支付与账单状态当前暂不可用'), findsOneWidget);
      expect(find.text('当前支付与账单入口暂不可用，请稍后再试。'), findsOneWidget);
    },
  );

  testWidgets(
    'payment-billing status page fail-closes when session is unavailable',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildPaymentBillingProfileApp(
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/profile/index': (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: paymentBillingProfilePayload(
                        organizationId: 'org-payment',
                        roleKeys: const <String>['buyer_admin'],
                        certificationStatus: 'approved',
                        membershipStatus: 'active',
                      ),
                    );
                  },
                },
          ),
          shellContext: paymentBillingShellContextData(
            organizationId: 'org-payment',
            roleKeys: const <String>['buyer_admin'],
            certificationStatus: 'approved',
            membershipStatus: 'active',
          ),
          establishSession: false,
        ),
      );
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('支付与账单状态'));
      await tester.tap(find.text('支付与账单状态'));
      await tester.pumpAndSettle();

      expect(find.text('当前会话暂不可用'), findsOneWidget);
      expect(find.text('当前没有可验证的会话，支付与账单状态页不展示伪造状态。'), findsOneWidget);
    },
  );
}
