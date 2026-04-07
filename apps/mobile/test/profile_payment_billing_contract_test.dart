import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/features/profile/data/profile_payment_billing_consumer_layer.dart';

void main() {
  HttpOverrides? previousHttpOverrides;

  setUp(() {
    previousHttpOverrides = HttpOverrides.current;
    HttpOverrides.global = _PassthroughHttpOverrides();
    ProfilePaymentBillingConsumerLayer.reset();
  });

  tearDown(() {
    HttpOverrides.global = previousHttpOverrides;
    ProfilePaymentBillingConsumerLayer.reset();
  });

  test('payment-billing status stays content on HTTP 200', () async {
    final consumer = ProfilePaymentBillingConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
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
                            'updatedAt': '2026-04-06T09:30:00Z',
                          },
                          'paymentStatus': <String, Object?>{
                            'paymentStatus': 'handoff_required',
                            'paymentAvailabilityStatus': 'available',
                            'paymentHandoffKey':
                                'payment_open_future_finance_dependency',
                            'paymentExplanationKey': 'payment_handoff_required',
                            'paymentDependencyKey':
                                'future_finance_dependency_required',
                            'updatedAt': '2026-04-06T09:30:00Z',
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
                            'updatedAt': '2026-04-06T09:30:00Z',
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
    );

    final result = await consumer.loadStatus();

    expect(result.state, AppPageState.content);
    expect(result.data?.privateSummary.entryKey, 'payment_and_billing_status');
    expect(result.data?.privateSummary.summaryStatus, 'handoff_required');
    expect(result.data?.billingReference.billingReferenceCode, 'BILL-REF-001');
    expect(
      result.data?.dependencyReference?.dependencyFamilyKey,
      'future_settlement_clearing_tax_finance_admin',
    );
  });

  test('payment-billing explanation stays content on HTTP 200', () async {
    final consumer = ProfilePaymentBillingConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
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
          },
        ),
      ),
    );

    final result = await consumer.loadExplanation();

    expect(result.state, AppPageState.content);
    expect(result.data?.paymentExplanation.title, '当前支付状态');
    expect(result.data?.billingExplanation.title, '当前账单参考');
    expect(result.data?.dependencyExplanation?.dependencyRequired, isTrue);
  });

  test('payment-billing handoff stays content on HTTP 200', () async {
    final consumer = ProfilePaymentBillingConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
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
                            'updatedAt': '2026-04-06T09:30:00Z',
                          },
                          'billingHandoff': <String, Object?>{
                            'billingHandoffKey':
                                'billing_reference_view_current_reference',
                            'title': '账单参考处理方向',
                            'body': '当前可查看 bounded billing reference。',
                            'updatedAt': '2026-04-06T09:30:00Z',
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
    );

    final result = await consumer.loadHandoff();

    expect(result.state, AppPageState.content);
    expect(result.data?.paymentHandoff.title, '支付处理方向');
    expect(
      result.data?.paymentHandoff.handoffTargetFamily,
      'future_finance_dependency',
    );
    expect(
      result.data?.dependencyHandoff?.dependencyFamilyKey,
      'future_settlement_clearing_tax_finance_admin',
    );
  });
}

final class _PassthroughHttpOverrides extends HttpOverrides {}
