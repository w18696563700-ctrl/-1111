import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/shell/shell_app.dart';

Map<String, Object?> _summary([String heading = 'contract']) {
  return <String, Object?>{'heading': heading};
}

Map<String, Object?> _contractPayload({
  required String contractId,
  required String orderId,
  String state = 'pending_confirm',
  String summaryHeading = 'contract',
}) {
  return <String, Object?>{
    'contractId': contractId,
    'orderId': orderId,
    'state': state,
    'summary': _summary(summaryHeading),
  };
}

ExhibitionMobileApp _buildApp({
  required String initialRoute,
  required FakeAppApiTransport transport,
}) {
  return ExhibitionMobileApp(
    initialRoute: initialRoute,
    exhibitionConsumerLayer: ExhibitionConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: transport,
      ),
    ),
  );
}

void main() {
  testWidgets(
    'contract detail success stays minimal and exposes confirm entry',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/contract/detail': (AppApiRequest request) async {
                expect(request.uri.queryParameters['orderId'], 'order-1');
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _contractPayload(
                    contractId: 'contract-1',
                    orderId: 'order-1',
                    state: 'pending_confirm',
                  ),
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          initialRoute: ExhibitionRoutes.contractDetailWithOrderId('order-1'),
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('合同详情'), findsWidgets);
      final confirmButton = find.widgetWithText(FilledButton, '继续合同确认');
      await tester.scrollUntilVisible(
        confirmButton,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('当前订单 ID：order-1'), findsAtLeastNWidgets(1));
      expect(
        find.textContaining('当前合同 ID：contract-1'),
        findsAtLeastNWidgets(1),
      );
      expect(find.text('当前状态：待确认'), findsOneWidget);
      expect(
        find.text('当前说明：合同最小读模型已经承接完成，页面不会扩展成签约工作台或历史报表页。'),
        findsOneWidget,
      );
      expect(confirmButton, findsOneWidget);
      expect(find.text('继续合同改单'), findsNothing);
      expect(find.text('clause editor'), findsNothing);
      expect(find.text('sign workflow'), findsNothing);
      expect(find.text('legal review'), findsNothing);
      expect(find.text('history'), findsNothing);
      expect(find.text('查看评价入口'), findsNothing);
      expect(find.text('开启争议入口'), findsNothing);
      expect(
        transport.requests.map(
          (AppApiRequest request) => request.canonicalPath,
        ),
        contains(ExhibitionCanonicalPaths.contractDetail),
      );
    },
  );

  testWidgets('contract detail active state exposes amend entry only', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/contract/detail': (AppApiRequest request) async {
              expect(request.uri.queryParameters['orderId'], 'order-1');
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _contractPayload(
                  contractId: 'contract-1',
                  orderId: 'order-1',
                  state: 'active',
                ),
              );
            },
          },
    );

    await tester.pumpWidget(
      _buildApp(
        initialRoute: ExhibitionRoutes.contractDetailWithOrderId('order-1'),
        transport: transport,
      ),
    );
    await tester.pumpAndSettle();

    final amendButton = find.widgetWithText(FilledButton, '继续合同改单');
    await tester.scrollUntilVisible(
      amendButton,
      200,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('当前业务状态：进行中'), findsOneWidget);
    expect(amendButton, findsOneWidget);
    expect(find.text('继续合同确认'), findsNothing);
  });

  testWidgets('contract detail amended state stays read-only', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/contract/detail': (AppApiRequest request) async {
              expect(request.uri.queryParameters['orderId'], 'order-1');
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _contractPayload(
                  contractId: 'contract-1',
                  orderId: 'order-1',
                  state: 'amended',
                ),
              );
            },
          },
    );

    await tester.pumpWidget(
      _buildApp(
        initialRoute: ExhibitionRoutes.contractDetailWithOrderId('order-1'),
        transport: transport,
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('当前保持只读'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('当前状态：已改单'), findsOneWidget);
    expect(find.text('当前保持只读'), findsOneWidget);
    expect(find.text('继续合同确认'), findsNothing);
    expect(find.text('继续合同改单'), findsNothing);
  });

  testWidgets(
    'contract confirm success posts contractId only and stays minimal',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/contract/detail': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _contractPayload(
                    contractId: 'contract-1',
                    orderId: 'order-1',
                    state: 'pending_confirm',
                  ),
                );
              },
              'POST /api/app/contract/confirm': (AppApiRequest request) async {
                expect(request.body, <String, Object?>{
                  'contractId': 'contract-1',
                });
                return AppApiResponse(
                  statusCode: 202,
                  uri: request.uri,
                  body: _contractPayload(
                    contractId: 'contract-1',
                    orderId: 'order-1',
                    state: 'active',
                  ),
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          initialRoute: ExhibitionRoutes.contractConfirmWithOrderId('order-1'),
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      final submitButton = find.byKey(
        const ValueKey<String>('contract_confirm_submit_button'),
      );
      await tester.scrollUntilVisible(
        submitButton,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      final submitAction = tester.widget<FilledButton>(submitButton);
      expect(submitAction.onPressed, isNotNull);
      submitAction.onPressed!();
      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(
        transport.requests
            .map((AppApiRequest request) => request.canonicalPath)
            .toList(),
        containsAll(<String>[
          ExhibitionCanonicalPaths.contractDetail,
          ExhibitionCanonicalPaths.contractConfirm,
        ]),
      );
      expect(
        find.textContaining('当前合同 ID：contract-1'),
        findsAtLeastNWidgets(1),
      );
      expect(find.textContaining('当前订单 ID：order-1'), findsAtLeastNWidgets(1));
      expect(find.text('当前业务状态：进行中'), findsOneWidget);
      expect(
        find.text('页面摘要：当前确认结果已经准备好，可继续讲解后续承接。'),
        findsWidgets,
      );
      expect(find.text('clause editor'), findsNothing);
      expect(find.text('sign workflow'), findsNothing);
      expect(find.text('legal review'), findsNothing);
      expect(find.text('history'), findsNothing);
      expect(find.text('查看评价入口'), findsNothing);
      expect(find.text('开启争议入口'), findsNothing);
    },
  );

  testWidgets(
    'contract confirm active state stays read-only and does not allow submit',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/contract/detail': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _contractPayload(
                    contractId: 'contract-1',
                    orderId: 'order-1',
                    state: 'active',
                  ),
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          initialRoute: ExhibitionRoutes.contractConfirmWithOrderId('order-1'),
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      final submitButton = find.byKey(
        const ValueKey<String>('contract_confirm_submit_button'),
      );
      await tester.scrollUntilVisible(
        submitButton,
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('当前业务状态：进行中'), findsOneWidget);
      expect(find.text('当前动作：合同已经生效，当前页保持只读承接，不再继续放开确认提交。'), findsOneWidget);
      final submitAction = tester.widget<FilledButton>(submitButton);
      expect(submitAction.onPressed, isNull);
    },
  );

  testWidgets('contract amend success posts frozen body and stays minimal', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/contract/detail': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _contractPayload(
                  contractId: 'contract-1',
                  orderId: 'order-1',
                  state: 'active',
                ),
              );
            },
            'POST /api/app/contract/amend': (AppApiRequest request) async {
              expect(request.body, <String, Object?>{
                'contractId': 'contract-1',
                'amendmentSummary': '一期改单说明',
              });
              return AppApiResponse(
                statusCode: 202,
                uri: request.uri,
                body: _contractPayload(
                  contractId: 'contract-1',
                  orderId: 'order-1',
                  state: 'amended',
                ),
              );
            },
          },
    );

    await tester.pumpWidget(
      _buildApp(
        initialRoute: ExhibitionRoutes.contractAmendWithOrderId('order-1'),
        transport: transport,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('合同改单'), findsWidgets);
    final amendmentField = find.byKey(
      const ValueKey<String>('contract_amend_summary_field'),
    );
    await tester.scrollUntilVisible(
      amendmentField,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(amendmentField, findsOneWidget);
    await tester.enterText(amendmentField, '一期改单说明');
    final submitButton = find.byKey(
      const ValueKey<String>('contract_amend_submit_button'),
    );
    await tester.scrollUntilVisible(
      submitButton,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    final submitAction = tester.widget<FilledButton>(submitButton);
    expect(submitAction.onPressed, isNotNull);
    submitAction.onPressed!();
    await tester.pump();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(
      transport.requests
          .map((AppApiRequest request) => request.canonicalPath)
          .toList(),
      containsAll(<String>[
        ExhibitionCanonicalPaths.contractDetail,
        ExhibitionCanonicalPaths.contractAmend,
      ]),
    );
    expect(find.textContaining('当前合同 ID：contract-1'), findsAtLeastNWidgets(1));
    expect(find.textContaining('当前订单 ID：order-1'), findsAtLeastNWidgets(1));
    expect(find.text('当前业务状态：已改单'), findsOneWidget);
    expect(
      find.text('页面摘要：当前改单结果已经准备好，可继续讲解后续承接。'),
      findsWidgets,
    );
    expect(find.text('clause editor'), findsNothing);
    expect(find.text('sign workflow'), findsNothing);
    expect(find.text('legal review'), findsNothing);
    expect(find.text('history'), findsNothing);
    expect(find.text('查看评价入口'), findsNothing);
    expect(find.text('开启争议入口'), findsNothing);
  });

  testWidgets(
    'contract amend amended state stays read-only and does not allow submit',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/contract/detail': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _contractPayload(
                    contractId: 'contract-1',
                    orderId: 'order-1',
                    state: 'amended',
                  ),
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          initialRoute: ExhibitionRoutes.contractAmendWithOrderId('order-1'),
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      final submitButton = find.byKey(
        const ValueKey<String>('contract_amend_submit_button'),
      );
      await tester.scrollUntilVisible(
        submitButton,
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('当前业务状态：已改单'), findsOneWidget);
      expect(find.text('当前动作：合同已经改单，当前页保持只读承接，不再继续放开改单提交。'), findsOneWidget);
      final submitAction = tester.widget<FilledButton>(submitButton);
      expect(submitAction.onPressed, isNull);
    },
  );

  testWidgets('contract detail 409 enters controlled failure', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/contract/detail': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 409,
                uri: request.uri,
                body: <String, Object?>{
                  'code': 'CONTRACT_ENTRY_UNAVAILABLE',
                  'message': 'contract truth is unavailable for this order',
                },
              );
            },
          },
    );

    await tester.pumpWidget(
      _buildApp(
        initialRoute: ExhibitionRoutes.contractDetailWithOrderId('order-1'),
        transport: transport,
      ),
    );
    await tester.pumpAndSettle();

    final backButton = find.widgetWithText(
      FilledButton,
      '回到展览',
      skipOffstage: false,
    );
    await tester.scrollUntilVisible(
      backButton,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(backButton, findsOneWidget);
    expect(find.textContaining('error code:'), findsNothing);
    expect(find.textContaining('controlled state:'), findsNothing);
  });

  testWidgets('contract confirm 400 enters controlled failure', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/contract/detail': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _contractPayload(
                  contractId: 'contract-1',
                  orderId: 'order-1',
                ),
              );
            },
            'POST /api/app/contract/confirm': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 400,
                uri: request.uri,
                body: <String, Object?>{
                  'code': 'CONTRACT_CONFIRM_INVALID',
                  'message': 'contractId is required',
                },
              );
            },
          },
    );

    await tester.pumpWidget(
      _buildApp(
        initialRoute: ExhibitionRoutes.contractConfirmWithOrderId('order-1'),
        transport: transport,
      ),
    );
    await tester.pumpAndSettle();

    final submitButton = find.byKey(
      const ValueKey<String>('contract_confirm_submit_button'),
    );
    await tester.scrollUntilVisible(
      submitButton,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    final submitAction = tester.widget<FilledButton>(submitButton);
    expect(submitAction.onPressed, isNotNull);
    submitAction.onPressed!();
    await tester.pump();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('当前动作未完成'), findsOneWidget);
    expect(find.text('contractId is required'), findsOneWidget);
    expect(find.text('回到展览'), findsOneWidget);
    expect(find.textContaining('error code:'), findsNothing);
    expect(find.textContaining('controlled state:'), findsNothing);
  });

  testWidgets(
    'contract confirm 409 stays controlled and does not invent truth',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/contract/detail': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _contractPayload(
                    contractId: 'contract-1',
                    orderId: 'order-1',
                    state: 'pending_confirm',
                  ),
                );
              },
              'POST /api/app/contract/confirm': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 409,
                  uri: request.uri,
                  body: <String, Object?>{
                    'code': 'CONTRACT_INVALID_STATE',
                    'message':
                        'contract confirm is not allowed in current state',
                  },
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          initialRoute: ExhibitionRoutes.contractConfirmWithOrderId('order-1'),
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      final submitButton = find.byKey(
        const ValueKey<String>('contract_confirm_submit_button'),
      );
      await tester.scrollUntilVisible(
        submitButton,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      final submitAction = tester.widget<FilledButton>(submitButton);
      expect(submitAction.onPressed, isNotNull);
      submitAction.onPressed!();
      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('当前动作未完成'), findsOneWidget);
      expect(
        find.text('contract confirm is not allowed in current state'),
        findsOneWidget,
      );
      expect(find.text('回到展览'), findsOneWidget);
      expect(find.textContaining('error code:'), findsNothing);
      expect(find.textContaining('controlled state:'), findsNothing);
    },
  );

  testWidgets('contract amend 400 enters controlled failure', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/contract/detail': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _contractPayload(
                  contractId: 'contract-1',
                  orderId: 'order-1',
                  state: 'active',
                ),
              );
            },
            'POST /api/app/contract/amend': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 400,
                uri: request.uri,
                body: <String, Object?>{
                  'code': 'CONTRACT_AMEND_INVALID',
                  'message': 'amendmentSummary is required',
                },
              );
            },
          },
    );

    await tester.pumpWidget(
      _buildApp(
        initialRoute: ExhibitionRoutes.contractAmendWithOrderId('order-1'),
        transport: transport,
      ),
    );
    await tester.pumpAndSettle();

    final amendmentField = find.byKey(
      const ValueKey<String>('contract_amend_summary_field'),
    );
    await tester.scrollUntilVisible(
      amendmentField,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(amendmentField, '一期改单说明');
    final submitButton = find.byKey(
      const ValueKey<String>('contract_amend_submit_button'),
    );
    await tester.scrollUntilVisible(
      submitButton,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    final submitAction = tester.widget<FilledButton>(submitButton);
    expect(submitAction.onPressed, isNotNull);
    submitAction.onPressed!();
    await tester.pump();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('当前动作未完成'), findsOneWidget);
    expect(find.text('amendmentSummary is required'), findsOneWidget);
    expect(find.text('回到展览'), findsOneWidget);
    expect(find.textContaining('error code:'), findsNothing);
    expect(find.textContaining('controlled state:'), findsNothing);
  });

  testWidgets('contract amend 409 stays controlled on page', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/contract/detail': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _contractPayload(
                  contractId: 'contract-1',
                  orderId: 'order-1',
                  state: 'active',
                ),
              );
            },
            'POST /api/app/contract/amend': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 409,
                uri: request.uri,
                body: <String, Object?>{
                  'code': 'CONTRACT_AMEND_LIMIT_REACHED',
                  'message': 'only one amendment is allowed in this loop',
                },
              );
            },
          },
    );

    await tester.pumpWidget(
      _buildApp(
        initialRoute: ExhibitionRoutes.contractAmendWithOrderId('order-1'),
        transport: transport,
      ),
    );
    await tester.pumpAndSettle();

    final amendmentField = find.byKey(
      const ValueKey<String>('contract_amend_summary_field'),
    );
    await tester.scrollUntilVisible(
      amendmentField,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(amendmentField, '一期改单说明');
    final submitButton = find.byKey(
      const ValueKey<String>('contract_amend_submit_button'),
    );
    await tester.scrollUntilVisible(
      submitButton,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    final submitAction = tester.widget<FilledButton>(submitButton);
    expect(submitAction.onPressed, isNotNull);
    submitAction.onPressed!();
    await tester.pump();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('当前动作未完成'), findsOneWidget);
    expect(
      find.text('only one amendment is allowed in this loop'),
      findsOneWidget,
    );
    expect(find.text('回到展览'), findsOneWidget);
    expect(find.textContaining('error code:'), findsNothing);
    expect(find.textContaining('controlled state:'), findsNothing);
  });

  test(
    'contract amend 409 stays controlled and does not invent limit logic',
    () async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'POST /api/app/contract/amend': (AppApiRequest request) async {
                expect(request.body, <String, Object?>{
                  'contractId': 'contract-1',
                  'amendmentSummary': '一期改单说明',
                });
                return AppApiResponse(
                  statusCode: 409,
                  uri: request.uri,
                  body: <String, Object?>{
                    'code': 'CONTRACT_AMEND_LIMIT_REACHED',
                    'message': 'only one amendment is allowed in this loop',
                  },
                );
              },
            },
      );

      final consumer = ExhibitionConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: transport,
        ),
      );

      final result = await consumer.amendContract(
        const ContractAmendCommand(
          contractId: 'contract-1',
          amendmentSummary: '一期改单说明',
        ),
      );

      expect(result.isSuccess, isFalse);
      expect(result.controlledState, AppPageState.errorNonRetryable);
      expect(result.errorCode, 'CONTRACT_AMEND_LIMIT_REACHED');
      expect(result.message, 'only one amendment is allowed in this loop');
    },
  );
}
