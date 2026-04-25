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
    'project publish consumes P0-Pay task and inquiry deposit BFF routes',
    () async {
      final transport = FakeAppApiTransport(
        handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
          'POST ${ExhibitionCanonicalPaths.p0PayTradeTaskCreate}':
              (AppApiRequest request) async {
                final body = _body(request);
                expect(body['taskType'], 'inquiry_quote');
                expect(body['projectName'], '2026 智造展展台搭建');
                expect(body['authenticityMaterialFileAssetIds'], <String>[
                  'file-auth-1',
                ]);
                expect(
                  body['authenticityDeclarations'],
                  containsPair('demandExistsConfirmed', true),
                );
                expect(body, contains('idempotencyKey'));
                return AppApiResponse(
                  statusCode: 201,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'taskId': 'task-1',
                    'taskType': 'inquiry_quote',
                    'taskStatus': 'published',
                    'authenticityLevel': 'T2',
                    'publishGateStatus': 'inquiry_deposit_required',
                    'nextAction': 'pay_inquiry_deposit',
                    'updatedAt': '2026-05-12T00:00:00Z',
                  },
                );
              },
          'POST ${ExhibitionCanonicalPaths.p0PayInquiryDepositOrders('task-1')}':
              (AppApiRequest request) async {
                final body = _body(request);
                expect(body['expectedAmount'], 200);
                expect(body['expectedCurrency'], 'CNY');
                expect(body['ruleVersion'], 'p0-pay-v1.3');
                expect(body, contains('idempotencyKey'));
                return AppApiResponse(
                  statusCode: 201,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'depositOrderId': 'deposit-1',
                    'depositStatus': 'pending_payment',
                    'amount': '200.00',
                    'currency': 'CNY',
                    'channelCandidates': <Object?>['alipay_candidate'],
                    'updatedAt': '2026-05-12T00:01:00Z',
                  },
                );
              },
          'POST ${ExhibitionCanonicalPaths.p0PayInquiryDepositPayInit('task-1', 'deposit-1')}':
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
                    'depositOrderId': 'deposit-1',
                    'paymentReferenceId': 'pay-ref-1',
                    'channelActionType': 'web_redirect',
                    'channelPayload': <String, Object?>{
                      'redirectUrl': 'https://pay.example.test/deposit-1',
                    },
                    'callbackAwaiting': true,
                    'updatedAt': '2026-05-12T00:02:00Z',
                  },
                );
              },
          'GET ${ExhibitionCanonicalPaths.p0PayInquiryDepositStatus('task-1', 'deposit-1')}':
              (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'depositOrderId': 'deposit-1',
                    'depositStatus': 'paid',
                    'amount': '200.00',
                    'currency': 'CNY',
                    'updatedAt': '2026-05-12T00:03:00Z',
                  },
                );
              },
        },
      );
      final consumer = ExhibitionConsumerLayer(client: _client(transport));

      final taskResult = await consumer.createP0PayTradeTask(
        P0PayTradeTaskCreateCommand(
          taskType: 'inquiry_quote',
          projectName: '2026 智造展展台搭建',
          cityCode: '330100',
          projectType: 'exhibition',
          exhibitionName: '2026 智造展',
          area: 88,
          buildStartAt: '2026-05-20',
          dismantleAt: '2026-05-25',
          requirementDescription: '标准展台搭建',
          budgetAmount: 80000,
          budgetRange: 'CNY 80000.00',
          quoteDeadlineAt: '2026-05-10T18:00:00+08:00',
          contactId: 'contact-1',
          authenticityMaterialFileAssetIds: const <String>['file-auth-1'],
          authenticityDeclarations: const <String, bool>{
            'demandExistsConfirmed': true,
            'authorizationConfirmed': true,
            'noQuoteHarvestingConfirmed': true,
            'resultProcessingConfirmed': true,
            'creditImpactAcknowledged': true,
          },
        ),
      );
      final depositResult = await consumer.createP0PayInquiryDepositOrder(
        taskId: 'task-1',
        command: P0PayInquiryDepositOrderCommand(
          ruleVersion: 'p0-pay-v1.3',
          ruleSnapshotHash: 'p0-pay-v1.3-freeze',
        ),
      );
      final initResult = await consumer.initP0PayInquiryDepositPayment(
        taskId: 'task-1',
        depositOrderId: 'deposit-1',
        command: P0PayPayInitCommand(payChannel: 'alipay_candidate'),
      );
      final statusResult = await consumer.loadP0PayInquiryDepositStatus(
        taskId: 'task-1',
        depositOrderId: 'deposit-1',
        forceRefresh: true,
      );

      expect(taskResult.isSuccess, isTrue);
      expect(depositResult.isSuccess, isTrue);
      expect(initResult.isSuccess, isTrue);
      expect(statusResult.state, AppPageState.content);
      expect(
        transport.requests.map(
          (AppApiRequest request) => request.canonicalPath,
        ),
        <String>[
          ExhibitionCanonicalPaths.p0PayTradeTaskCreate,
          ExhibitionCanonicalPaths.p0PayInquiryDepositOrders('task-1'),
          ExhibitionCanonicalPaths.p0PayInquiryDepositPayInit(
            'task-1',
            'deposit-1',
          ),
          ExhibitionCanonicalPaths.p0PayInquiryDepositStatus(
            'task-1',
            'deposit-1',
          ),
        ],
      );
    },
  );

  test(
    'fixed-price bid uses BFF service-fee requirement before authorize-init',
    () async {
      final transport = FakeAppApiTransport(
        handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
          'POST ${ExhibitionCanonicalPaths.p0PayFixedPriceBids('task-1')}':
              (AppApiRequest request) async {
                final body = _body(request);
                expect(body['quoteAmount'], 80000);
                expect(body['quoteValidUntil'], '2026-05-20T18:00:00+08:00');
                expect(body['taxIncluded'], true);
                expect(body['transportIncluded'], true);
                expect(body['installationIncluded'], true);
                expect(body['attachmentFileAssetIds'], <String>['file-bid-1']);
                expect(
                  body['platformServiceFeeRuleAgreement'],
                  containsPair('readConfirmed', true),
                );
                expect(body, contains('idempotencyKey'));
                return AppApiResponse(
                  statusCode: 201,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'bidId': 'bid-1',
                    'bidStatus': 'pending_authorization',
                    'platformServiceFeeRequirement': <String, Object?>{
                      'feeRate': '0.03',
                      'quotedAmount': '80000.00',
                      'estimatedFeeAmount': '2400.00',
                      'currency': 'CNY',
                      'authorizationRequired': true,
                      'authorizationStatus': 'pending_authorization',
                    },
                    'nextAction': 'create_service_fee_authorization',
                    'updatedAt': '2026-05-13T00:00:00Z',
                  },
                );
              },
          'POST ${ExhibitionCanonicalPaths.p0PayServiceFeeAuthorizations('task-1', 'bid-1')}':
              (AppApiRequest request) async {
                final body = _body(request);
                expect(body['expectedQuotedAmount'], 80000);
                expect(body['expectedFeeRate'], '0.03');
                expect(body['expectedAuthorizationAmount'], '2400.00');
                expect(body['currency'], 'CNY');
                expect(body, contains('idempotencyKey'));
                return AppApiResponse(
                  statusCode: 201,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'authorizationId': 'auth-1',
                    'authorizationStatus': 'pending_authorization',
                    'estimatedFeeAmount': '2400.00',
                    'currency': 'CNY',
                    'channelCandidates': <Object?>['wechat_candidate'],
                    'updatedAt': '2026-05-13T00:01:00Z',
                  },
                );
              },
          'POST ${ExhibitionCanonicalPaths.p0PayServiceFeeAuthorizeInit('task-1', 'bid-1', 'auth-1')}':
              (AppApiRequest request) async {
                final body = _body(request);
                expect(body['payChannel'], 'wechat_candidate');
                expect(body['clientPlatform'], 'flutter');
                expect(body, contains('idempotencyKey'));
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'authorizationInitStatus': 'started',
                    'authorizationId': 'auth-1',
                    'paymentReferenceId': 'auth-ref-1',
                    'channelActionType': 'web_redirect',
                    'channelPayload': <String, Object?>{
                      'redirectUrl': 'https://pay.example.test/auth-1',
                    },
                    'callbackAwaiting': true,
                    'updatedAt': '2026-05-13T00:02:00Z',
                  },
                );
              },
          'GET ${ExhibitionCanonicalPaths.p0PayServiceFeeAuthorizationStatus('task-1', 'bid-1', 'auth-1')}':
              (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'authorizationId': 'auth-1',
                    'authorizationStatus': 'authorized',
                    'quotedAmount': '80000.00',
                    'feeRate': '0.03',
                    'estimatedFeeAmount': '2400.00',
                    'currency': 'CNY',
                    'channelSummary': <String, Object?>{
                      'paymentChannel': 'wechat_candidate',
                      'status': 'authorized',
                    },
                    'updatedAt': '2026-05-13T00:03:00Z',
                  },
                );
              },
        },
      );
      final consumer = ExhibitionConsumerLayer(client: _client(transport));

      final bidResult = await consumer.submitP0PayFixedPriceBid(
        taskId: 'task-1',
        command: P0PayFixedPriceBidCommand(
          quoteAmount: 80000,
          quoteValidUntil: '2026-05-20T18:00:00+08:00',
          taxIncluded: true,
          transportIncluded: true,
          installationIncluded: true,
          constructionPlan: '结构、灯光、画面整体搭建。',
          materialDescription: '阻燃板、铝型材。',
          craftDescription: '木作烤漆和模块化快装。',
          buildProcess: '工厂预制后现场安装。',
          deliveryMilestones: const <String>['结构搭建', '灯光安装'],
          riskNotes: '进场时间需提前确认。',
          attachmentFileAssetIds: const <String>['file-bid-1'],
          platformServiceFeeRuleAgreement: const <String, Object?>{
            'ruleVersion': 'p0-pay-v1.3',
            'ruleSnapshotHash': 'p0-pay-v1.3-freeze',
            'agreedAtClient': '2026-05-13T00:00:00+08:00',
            'readConfirmed': true,
            'authorizationAwarenessConfirmed': true,
            'publisherBreachReleaseAwarenessConfirmed': true,
          },
        ),
      );
      final authorizationResult = await consumer
          .createP0PayServiceFeeAuthorization(
            taskId: 'task-1',
            bidId: 'bid-1',
            command: P0PayServiceFeeAuthorizationCommand(
              expectedQuotedAmount: 80000,
              expectedFeeRate: '0.03',
              expectedAuthorizationAmount: '2400.00',
            ),
          );
      final initResult = await consumer.initP0PayServiceFeeAuthorization(
        taskId: 'task-1',
        bidId: 'bid-1',
        authorizationId: 'auth-1',
        command: P0PayPayInitCommand(payChannel: 'wechat_candidate'),
      );
      final statusResult = await consumer
          .loadP0PayServiceFeeAuthorizationStatus(
            taskId: 'task-1',
            bidId: 'bid-1',
            authorizationId: 'auth-1',
            forceRefresh: true,
          );

      expect(bidResult.isSuccess, isTrue);
      expect(authorizationResult.isSuccess, isTrue);
      expect(initResult.isSuccess, isTrue);
      expect(statusResult.state, AppPageState.content);
      expect(
        transport.requests.map(
          (AppApiRequest request) => request.canonicalPath,
        ),
        <String>[
          ExhibitionCanonicalPaths.p0PayFixedPriceBids('task-1'),
          ExhibitionCanonicalPaths.p0PayServiceFeeAuthorizations(
            'task-1',
            'bid-1',
          ),
          ExhibitionCanonicalPaths.p0PayServiceFeeAuthorizeInit(
            'task-1',
            'bid-1',
            'auth-1',
          ),
          ExhibitionCanonicalPaths.p0PayServiceFeeAuthorizationStatus(
            'task-1',
            'bid-1',
            'auth-1',
          ),
        ],
      );
    },
  );

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
                  'feeRate': '0.03',
                  'estimatedFeeAmount': '2400.00',
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
                  'feeRate': '0.03',
                  'estimatedFeeAmount': '2400.00',
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
                  'feeRate': '0.03',
                  'estimatedFeeAmount': '2400.00',
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

  test('project detail can render full read-only P0-Pay charged summary lines', () {
    final summary = parseP0PayReadOnlySummary(
      const <String, Object?>{
        'taskId': 'task-1',
        'taskType': 'fixed_price_bid',
        'platformServiceFee': <String, Object?>{
          'status': 'charged',
          'estimatedFeeAmount': '2640.00',
          'finalFeeAmount': '2700.00',
        },
        'contractConfirmation': <String, Object?>{'status': 'confirmed'},
        'messageDisplaySummary': <String, Object?>{
          'displayAllowed': true,
          'readOnly': true,
          'statusTextKey': 'charged',
        },
      },
    );

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
        '平台服务费:已扣取',
        '最终服务费:2700.00',
        '合同确认:已确认',
        '消息楼状态:已扣取',
        '消息楼只读:是',
      ]),
    );
  });
}
