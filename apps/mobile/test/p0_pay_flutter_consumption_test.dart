import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/p0_pay_read_only_summary.dart';

AppApiClient _client(FakeAppApiTransport transport) {
  return AppApiClient(
    config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
    transport: transport,
  );
}

Map<String, Object?> _body(AppApiRequest request) {
  final body = request.body;
  expect(body, isA<Map<String, Object?>>());
  return body! as Map<String, Object?>;
}

void main() {
  tearDown(AppSessionStore.reset);

  test(
    'project publish consumes project-scoped authenticity sincerity BFF routes',
    () async {
      final transport = FakeAppApiTransport(
        handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
          'GET ${ExhibitionCanonicalPaths.projectPricingSummary('project-1')}':
              (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'projectId': 'project-1',
                    'publisherPricing': <String, Object?>{
                      'authenticitySincerityRequired': true,
                      'authenticitySincerityAmount': '200.00',
                      'authenticitySincerityStatus': null,
                      'publishGateStatus': 'required',
                      'nextAction': <String, Object?>{
                        'actionKey': 'project_authenticity_sincerity.open',
                        'canonicalPath':
                            '/api/app/project/project-1/authenticity-sincerity/orders',
                      },
                    },
                    'readOnly': true,
                    'updatedAt': '2026-05-12T00:00:00Z',
                  },
                );
              },
          'POST ${ExhibitionCanonicalPaths.projectAuthenticitySincerityOrders('project-1')}':
              (AppApiRequest request) async {
                final body = _body(request);
                expect(body['expectedAmount'], 200);
                expect(body['expectedCurrency'], 'CNY');
                expect(body['ruleVersion'], 'platform_pricing_rules_master_v1');
                expect(body, contains('idempotencyKey'));
                return AppApiResponse(
                  statusCode: 201,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'orderId': 'order-1',
                    'orderStatus': 'pending_payment',
                    'amount': '200.00',
                    'currency': 'CNY',
                    'channelCandidates': <Object?>['alipay_candidate'],
                    'updatedAt': '2026-05-12T00:01:00Z',
                  },
                );
              },
          'POST ${ExhibitionCanonicalPaths.projectAuthenticitySincerityPayInit('project-1', 'order-1')}':
              (AppApiRequest request) async {
                final body = _body(request);
                expect(body['payChannel'], 'alipay_candidate');
                expect(body['clientPlatform'], 'flutter');
                expect(body, contains('idempotencyKey'));
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'paymentInitStatus': 'started',
                    'orderId': 'order-1',
                    'paymentReferenceId': 'pay-ref-1',
                    'channelActionType': 'web_redirect',
                    'channelPayload': <String, Object?>{
                      'redirectUrl': 'https://pay.example.test/order-1',
                    },
                    'callbackAwaiting': true,
                    'updatedAt': '2026-05-12T00:02:00Z',
                  },
                );
              },
          'GET ${ExhibitionCanonicalPaths.projectAuthenticitySincerityOrderStatus('project-1', 'order-1')}':
              (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'orderId': 'order-1',
                    'orderStatus': 'paid',
                    'amount': '200.00',
                    'currency': 'CNY',
                    'updatedAt': '2026-05-12T00:03:00Z',
                  },
                );
              },
        },
      );
      final consumer = ExhibitionConsumerLayer(client: _client(transport));

      final summaryResult = await consumer.loadProjectPricingSummary(
        projectId: 'project-1',
        forceRefresh: true,
      );
      final orderResult = await consumer
          .createProjectAuthenticitySincerityOrder(
            projectId: 'project-1',
            command: ProjectAuthenticitySincerityOrderCommand(
              ruleVersion: 'platform_pricing_rules_master_v1',
              ruleSnapshotHash: 'platform_pricing_rules_master_v1',
            ),
          );
      final initResult = await consumer.initProjectAuthenticitySincerityPayment(
        projectId: 'project-1',
        orderId: 'order-1',
        command: ProjectPricingPayInitCommand(payChannel: 'alipay_candidate'),
      );
      final statusResult = await consumer
          .loadProjectAuthenticitySincerityOrderStatus(
            projectId: 'project-1',
            orderId: 'order-1',
            forceRefresh: true,
          );

      expect(summaryResult.state, AppPageState.content);
      expect(orderResult.isSuccess, isTrue);
      expect(initResult.isSuccess, isTrue);
      expect(statusResult.state, AppPageState.content);
      expect(
        transport.requests.map(
          (AppApiRequest request) => request.canonicalPath,
        ),
        <String>[
          ExhibitionCanonicalPaths.projectPricingSummary('project-1'),
          ExhibitionCanonicalPaths.projectAuthenticitySincerityOrders(
            'project-1',
          ),
          ExhibitionCanonicalPaths.projectAuthenticitySincerityPayInit(
            'project-1',
            'order-1',
          ),
          ExhibitionCanonicalPaths.projectAuthenticitySincerityOrderStatus(
            'project-1',
            'order-1',
          ),
        ],
      );
    },
  );

  test(
    'project authenticity sincerity active-order conflict keeps stable error code',
    () async {
      final transport = FakeAppApiTransport(
        handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
          'POST ${ExhibitionCanonicalPaths.projectAuthenticitySincerityOrders('project-1')}':
              (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 409,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'statusCode': 409,
                    'code': 'P0_PAY_STATE_CONFLICT',
                    'message':
                        'Current inquiry task already has an active sincerity money order.',
                    'source': 'server',
                  },
                );
              },
        },
      );
      final consumer = ExhibitionConsumerLayer(client: _client(transport));

      final result = await consumer.createProjectAuthenticitySincerityOrder(
        projectId: 'project-1',
        command: ProjectAuthenticitySincerityOrderCommand(
          ruleVersion: 'platform_pricing_rules_master_v1',
          ruleSnapshotHash: 'platform_pricing_rules_master_v1',
        ),
      );

      expect(result.isSuccess, isFalse);
      expect(result.errorCode, 'P0_PAY_STATE_CONFLICT');
      expect(result.message, isNot(contains('unrecognized error code')));
    },
  );

  test(
    'project finance routes consume refund and settlement summaries without local money truth',
    () async {
      final transport = FakeAppApiTransport(
        handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
          'POST ${ExhibitionCanonicalPaths.projectAuthenticitySincerityRefundInit('project-1', 'order-1')}':
              (AppApiRequest request) async {
                final body = _body(request);
                expect(body['refundReasonCode'], 'publisher_cancelled');
                expect(body['refundReasonText'], '发布方取消项目。');
                expect(body, contains('idempotencyKey'));
                return AppApiResponse(
                  statusCode: 202,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'orderId': 'order-1',
                    'refundOrderId': 'refund-1',
                    'refundStatus': 'refund_pending',
                    'amount': '200.00',
                    'currency': 'CNY',
                    'callbackAwaiting': true,
                    'updatedAt': '2026-06-01T10:00:00Z',
                  },
                );
              },
          'GET ${ExhibitionCanonicalPaths.projectAuthenticitySincerityRefundStatus('project-1', 'order-1')}':
              (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'orderId': 'order-1',
                    'refundOrderId': 'refund-1',
                    'refundStatus': 'refund_pending',
                    'amount': '200.00',
                    'currency': 'CNY',
                    'callbackAwaiting': true,
                    'updatedAt': '2026-06-01T10:01:00Z',
                  },
                );
              },
          'GET ${ExhibitionCanonicalPaths.projectSettlementSummary('project-1')}':
              (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'projectId': 'project-1',
                    'settlementSummary': <String, Object?>{
                      'settlementStatus': 'draft',
                      'platformIncomeAmount': '675.00',
                      'pendingSettlementAmount': '675.00',
                      'settledAmount': '0.00',
                      'autoPayoutEnabled': false,
                    },
                    'updatedAt': '2026-06-01T10:02:00Z',
                  },
                );
              },
        },
      );
      final consumer = ExhibitionConsumerLayer(client: _client(transport));

      final refund = await consumer.initProjectAuthenticitySincerityRefund(
        projectId: 'project-1',
        orderId: 'order-1',
        command: ProjectAuthenticitySincerityRefundCommand(
          refundReasonCode: 'publisher_cancelled',
          refundReasonText: '发布方取消项目。',
          idempotencyKey: 'idem-refund',
        ),
      );
      final refundStatus = await consumer
          .loadProjectAuthenticitySincerityRefundStatus(
            projectId: 'project-1',
            orderId: 'order-1',
            forceRefresh: true,
          );
      final settlement = await consumer.loadProjectSettlementSummary(
        projectId: 'project-1',
        forceRefresh: true,
      );

      expect(refund.isSuccess, isTrue);
      expect(refundStatus.state, AppPageState.content);
      expect(settlement.state, AppPageState.content);
      expect(
        transport.requests.map(
          (AppApiRequest request) => request.canonicalPath,
        ),
        <String>[
          ExhibitionCanonicalPaths.projectAuthenticitySincerityRefundInit(
            'project-1',
            'order-1',
          ),
          ExhibitionCanonicalPaths.projectAuthenticitySincerityRefundStatus(
            'project-1',
            'order-1',
          ),
          ExhibitionCanonicalPaths.projectSettlementSummary('project-1'),
        ],
      );
    },
  );

  test('project authenticity sincerity polling stops after paid', () async {
    var attempts = 0;
    final transport = FakeAppApiTransport(
      handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
        'GET ${ExhibitionCanonicalPaths.projectAuthenticitySincerityOrderStatus('project-1', 'order-1')}':
            (AppApiRequest request) async {
              attempts += 1;
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: <String, Object?>{
                  'orderId': 'order-1',
                  'orderStatus': attempts == 1 ? 'pending_payment' : 'paid',
                  'amount': '200.00',
                  'currency': 'CNY',
                  'updatedAt': '2026-05-14T00:0$attempts:00Z',
                },
              );
            },
      },
    );
    final consumer = ExhibitionConsumerLayer(client: _client(transport));

    final result = await consumer.pollProjectAuthenticitySincerityOrderStatus(
      projectId: 'project-1',
      orderId: 'order-1',
      maxAttempts: 3,
      interval: Duration.zero,
    );

    expect(result.outcome, P0PayPaymentOutcome.success);
    expect(result.isSuccess, isTrue);
    expect(result.status, 'paid');
    expect(result.attempts, 2);
    expect(transport.requests.length, 2);
  });

  test('legacy inquiry deposit polling stops after BFF reports paid', () async {
    var attempts = 0;
    final transport = FakeAppApiTransport(
      handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
        'GET ${ExhibitionCanonicalPaths.p0PayInquiryDepositStatus('task-1', 'deposit-1')}':
            (AppApiRequest request) async {
              attempts += 1;
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: <String, Object?>{
                  'depositOrderId': 'deposit-1',
                  'depositStatus': attempts == 1 ? 'pending_payment' : 'paid',
                  'amount': '200.00',
                  'currency': 'CNY',
                  'updatedAt': '2026-05-14T00:0$attempts:00Z',
                },
              );
            },
      },
    );
    final consumer = ExhibitionConsumerLayer(client: _client(transport));

    final result = await consumer.pollP0PayInquiryDepositStatus(
      taskId: 'task-1',
      depositOrderId: 'deposit-1',
      maxAttempts: 3,
      interval: Duration.zero,
    );

    expect(result.outcome, P0PayPaymentOutcome.success);
    expect(result.isSuccess, isTrue);
    expect(result.status, 'paid');
    expect(result.attempts, 2);
    expect(transport.requests.length, 2);
  });

  test('bid service fee authorization uses project-scoped 4000 quota', () async {
    final transport = FakeAppApiTransport(
      handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
        'POST ${ExhibitionCanonicalPaths.projectBidServiceFeeAuthorizations('project-1')}':
            (AppApiRequest request) async {
              final body = _body(request);
              expect(body['bidParticipationRequestId'], 'bpr-1');
              expect(body['expectedAmount'], 4000);
              expect(body['expectedCurrency'], 'CNY');
              expect(body['ruleVersion'], 'platform_pricing_rules_master_v1');
              expect(body.keys.toSet(), <String>{
                'bidParticipationRequestId',
                'expectedAmount',
                'expectedCurrency',
                'ruleVersion',
                'ruleSnapshotHash',
                'idempotencyKey',
              });
              expect(body, isNot(contains('estimatedFeeAmount')));
              expect(body, contains('idempotencyKey'));
              return AppApiResponse(
                statusCode: 201,
                uri: request.uri,
                body: const <String, Object?>{
                  'authorizationId': 'auth-1',
                  'authorizationStatus': 'pending_freeze',
                  'quotaAmount': '4000.00',
                  'currency': 'CNY',
                  'channelCandidates': <Object?>['other_candidate'],
                  'updatedAt': '2026-05-13T00:01:00Z',
                },
              );
            },
        'POST ${ExhibitionCanonicalPaths.projectBidServiceFeeAuthorizationFreezeInit('project-1', 'auth-1')}':
            (AppApiRequest request) async {
              final body = _body(request);
              expect(body['payChannel'], 'other_candidate');
              expect(body['clientPlatform'], 'flutter');
              expect(body.keys.toSet(), <String>{
                'payChannel',
                'clientPlatform',
                'idempotencyKey',
              });
              expect(body, contains('idempotencyKey'));
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: const <String, Object?>{
                  'freezeInitStatus': 'pending_user_confirm',
                  'authorizationId': 'auth-1',
                  'paymentReferenceId': 'auth-ref-1',
                  'callbackAwaiting': true,
                  'updatedAt': '2026-05-13T00:02:00Z',
                },
              );
            },
        'GET ${ExhibitionCanonicalPaths.projectBidServiceFeeAuthorizationStatus('project-1', 'auth-1')}':
            (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: const <String, Object?>{
                  'authorizationId': 'auth-1',
                  'authorizationStatus': 'frozen',
                  'quotaAmount': '4000.00',
                  'currency': 'CNY',
                  'channelSummary': <String, Object?>{
                    'paymentChannel': 'other_candidate',
                    'status': 'frozen',
                  },
                  'updatedAt': '2026-05-13T00:03:00Z',
                },
              );
            },
      },
    );
    final consumer = ExhibitionConsumerLayer(client: _client(transport));

    final authorizationResult = await consumer
        .createProjectBidServiceFeeAuthorization(
          projectId: 'project-1',
          command: BidServiceFeeAuthorizationCommand(
            bidParticipationRequestId: 'bpr-1',
            ruleVersion: 'platform_pricing_rules_master_v1',
            ruleSnapshotHash: 'platform_pricing_rules_master_v1',
          ),
        );
    final initResult = await consumer
        .initProjectBidServiceFeeAuthorizationFreeze(
          projectId: 'project-1',
          authorizationId: 'auth-1',
          command: ProjectPricingPayInitCommand(payChannel: 'other_candidate'),
        );
    final statusResult = await consumer
        .loadProjectBidServiceFeeAuthorizationStatus(
          projectId: 'project-1',
          authorizationId: 'auth-1',
          forceRefresh: true,
        );

    expect(authorizationResult.isSuccess, isTrue);
    expect(initResult.isSuccess, isTrue);
    expect(statusResult.state, AppPageState.content);
    expect(
      transport.requests.map((AppApiRequest request) => request.canonicalPath),
      <String>[
        ExhibitionCanonicalPaths.projectBidServiceFeeAuthorizations(
          'project-1',
        ),
        ExhibitionCanonicalPaths.projectBidServiceFeeAuthorizationFreezeInit(
          'project-1',
          'auth-1',
        ),
        ExhibitionCanonicalPaths.projectBidServiceFeeAuthorizationStatus(
          'project-1',
          'auth-1',
        ),
      ],
    );
  });

  test('inquiry deposit polling stops after BFF reports paid', () async {
    var attempts = 0;
    final transport = FakeAppApiTransport(
      handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
        'GET ${ExhibitionCanonicalPaths.p0PayInquiryDepositStatus('task-1', 'deposit-1')}':
            (AppApiRequest request) async {
              attempts += 1;
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: <String, Object?>{
                  'depositOrderId': 'deposit-1',
                  'depositStatus': attempts == 1 ? 'pending_payment' : 'paid',
                  'amount': '200.00',
                  'currency': 'CNY',
                  'updatedAt': '2026-05-14T00:0$attempts:00Z',
                },
              );
            },
      },
    );
    final consumer = ExhibitionConsumerLayer(client: _client(transport));

    final result = await consumer.pollP0PayInquiryDepositStatus(
      taskId: 'task-1',
      depositOrderId: 'deposit-1',
      maxAttempts: 3,
      interval: Duration.zero,
    );

    expect(result.outcome, P0PayPaymentOutcome.success);
    expect(result.isSuccess, isTrue);
    expect(result.status, 'paid');
    expect(result.attempts, 2);
    expect(transport.requests.length, 2);
  });

  test('service-fee authorization polling times out while pending', () async {
    final transport = FakeAppApiTransport(
      handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
        'GET ${ExhibitionCanonicalPaths.p0PayServiceFeeAuthorizationStatus('task-1', 'bid-1', 'auth-1')}':
            (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: const <String, Object?>{
                  'authorizationId': 'auth-1',
                  'authorizationStatus': 'pending_authorization',
                  'quotedAmount': '80000.00',
                  'feeRate': '0.030',
                  'estimatedFeeAmount': '2000.00',
                  'currency': 'CNY',
                  'updatedAt': '2026-05-14T00:00:00Z',
                },
              );
            },
      },
    );
    final consumer = ExhibitionConsumerLayer(client: _client(transport));

    final result = await consumer.pollP0PayServiceFeeAuthorizationStatus(
      taskId: 'task-1',
      bidId: 'bid-1',
      authorizationId: 'auth-1',
      maxAttempts: 2,
      interval: Duration.zero,
    );

    expect(result.outcome, P0PayPaymentOutcome.timedOut);
    expect(result.timedOut, isTrue);
    expect(result.isFailure, isTrue);
    expect(result.status, 'pending_authorization');
    expect(result.attempts, 2);
    expect(transport.requests.length, 2);
  });

  test(
    'payment result polling exposes controlled failures without success',
    () async {
      final transport = FakeAppApiTransport(
        handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
          'GET ${ExhibitionCanonicalPaths.p0PayInquiryDepositStatus('task-1', 'deposit-1')}':
              (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 503,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'code': 'PAYMENT_CHANNEL_UNAVAILABLE',
                    'message': 'payment channel unavailable',
                  },
                );
              },
        },
      );
      final consumer = ExhibitionConsumerLayer(client: _client(transport));

      final result = await consumer.pollP0PayInquiryDepositStatus(
        taskId: 'task-1',
        depositOrderId: 'deposit-1',
        maxAttempts: 3,
        interval: Duration.zero,
      );

      expect(result.outcome, P0PayPaymentOutcome.controlledFailure);
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.result.state, AppPageState.errorRetryable);
      expect(result.result.errorCode, 'PAYMENT_CHANNEL_UNAVAILABLE');
      expect(transport.requests.length, 1);
    },
  );

  test('service-fee authorization failed and succeeded states are terminal', () async {
    var attempts = 0;
    final transport = FakeAppApiTransport(
      handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
        'GET ${ExhibitionCanonicalPaths.p0PayServiceFeeAuthorizationStatus('task-1', 'bid-1', 'auth-1')}':
            (AppApiRequest request) async {
              attempts += 1;
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: <String, Object?>{
                  'authorizationId': 'auth-1',
                  'authorizationStatus': attempts == 1
                      ? 'pending_user_confirm'
                      : 'succeeded',
                  'quotedAmount': '80000.00',
                  'feeRate': '0.030',
                  'estimatedFeeAmount': '2000.00',
                  'currency': 'CNY',
                  'updatedAt': '2026-05-14T00:0$attempts:00Z',
                },
              );
            },
      },
    );
    final consumer = ExhibitionConsumerLayer(client: _client(transport));

    final successResult = await consumer.pollP0PayServiceFeeAuthorizationStatus(
      taskId: 'task-1',
      bidId: 'bid-1',
      authorizationId: 'auth-1',
      maxAttempts: 3,
      interval: Duration.zero,
    );

    expect(successResult.outcome, P0PayPaymentOutcome.success);
    expect(successResult.status, 'succeeded');
    expect(successResult.attempts, 2);

    final failedTransport = FakeAppApiTransport(
      handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
        'GET ${ExhibitionCanonicalPaths.p0PayServiceFeeAuthorizationStatus('task-1', 'bid-1', 'auth-2')}':
            (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: const <String, Object?>{
                  'authorizationId': 'auth-2',
                  'authorizationStatus': 'failed',
                  'quotedAmount': '80000.00',
                  'feeRate': '0.030',
                  'estimatedFeeAmount': '2000.00',
                  'currency': 'CNY',
                  'failureReasonCode': 'PAYMENT_CHANNEL_UNAVAILABLE',
                  'updatedAt': '2026-05-14T00:03:00Z',
                },
              );
            },
      },
    );
    final failedConsumer = ExhibitionConsumerLayer(
      client: _client(failedTransport),
    );

    final failedResult = await failedConsumer
        .pollP0PayServiceFeeAuthorizationStatus(
          taskId: 'task-1',
          bidId: 'bid-1',
          authorizationId: 'auth-2',
          maxAttempts: 3,
          interval: Duration.zero,
        );

    expect(failedResult.outcome, P0PayPaymentOutcome.failed);
    expect(failedResult.isFailure, isTrue);
    expect(failedTransport.requests.length, 1);
  });

  test(
    'project detail can render full read-only P0-Pay charged summary lines',
    () {
      final summary = parseP0PayReadOnlySummary(const <String, Object?>{
        'taskId': 'task-1',
        'taskType': 'fixed_price_bid',
        'platformServiceFee': <String, Object?>{
          'status': 'charged',
          'authorizationQuotaAmount': '4000.00',
          'baseFeeAmount': '3000.00',
          'membershipDiscountRate': '0.9000',
          'capAmount': '3600.00',
          'feeRateLabel': '标准会员 9折（作用于 baseFeeAmount）',
          'membershipTierSnapshot': 'standard',
          'finalFeeAmount': '2700.00',
        },
        'contractConfirmation': <String, Object?>{'status': 'confirmed'},
        'messageDisplaySummary': <String, Object?>{
          'displayAllowed': true,
          'readOnly': true,
          'statusTextKey': 'charged',
        },
      });

      expect(summary, isNotNull);
      expect(summary!.readOnly, isTrue);
      expect(summary.platformServiceFeeStatus, 'charged');
      expect(summary.platformServiceFeeFinalAmount, '2700.00');
      expect(summary.contractConfirmationStatus, 'confirmed');
      expect(
        summary.statusLines.map((P0PayReadOnlyStatusLine line) {
          return '${line.label}:${line.value}';
        }),
        containsAll(<String>[
          '竞标服务费预授权:已扣取',
          '预授权额度:4000.00',
          '服务费规则:标准会员 9折（作用于 baseFeeAmount）',
          '会员档位快照:标准会员',
          '服务费基础金额:3000.00',
          '会员折扣:9 折',
          '服务费封顶:3600.00',
          '最终服务费:2700.00',
          '合同确认:已确认',
          '消息楼状态:已扣取',
          '消息楼只读:是',
        ]),
      );
    },
  );
}
