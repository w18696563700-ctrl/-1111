import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/shell/shell_app.dart';

Map<String, Object?> _disputeSummary([String heading = 'summary']) {
  return <String, Object?>{'heading': heading};
}

Map<String, Object?> _disputePayload({
  required String disputeId,
  required String orderId,
  required String state,
  String summaryHeading = 'dispute',
}) {
  return <String, Object?>{
    'disputeId': disputeId,
    'orderId': orderId,
    'state': state,
    'summary': _disputeSummary(summaryHeading),
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
  testWidgets('dispute open success carries only minimal success body', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'POST /api/app/dispute/open': (AppApiRequest request) async {
              expect(request.body, <String, Object?>{
                'orderId': 'order-1',
                'reason': '质量争议',
              });
              return AppApiResponse(
                statusCode: 202,
                uri: request.uri,
                body: _disputePayload(
                  disputeId: 'dispute-1',
                  orderId: 'order-1',
                  state: 'opened',
                ),
              );
            },
          },
    );

    await tester.pumpWidget(
      _buildApp(
        initialRoute: '${ExhibitionRoutes.disputeOpen}?orderId=order-1',
        transport: transport,
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, '争议说明（选填）'), '质量争议');
    final submitButton = find.byKey(
      const ValueKey<String>('dispute_open_submit_button'),
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
    await tester.pumpAndSettle();

    expect(
      transport.requests.map((AppApiRequest request) => request.canonicalPath),
      contains(ExhibitionCanonicalPaths.disputeOpen),
    );
    expect(find.textContaining('当前订单 ID：order-1'), findsAtLeastNWidgets(1));
    expect(find.textContaining('当前争议 ID：dispute-1'), findsAtLeastNWidgets(1));
    expect(find.text('当前状态：已开启'), findsOneWidget);
    expect(find.text('当前说明：争议开启结果已经承接完成，当前页继续保留只读结果。'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '去争议撤回'), findsNothing);
    expect(find.text('当前冻结'), findsOneWidget);
    expect(find.text('negotiation'), findsNothing);
    expect(find.text('platform review'), findsNothing);
    expect(find.text('escalation'), findsNothing);
    expect(find.text('resolution'), findsNothing);
    expect(find.text('eligibility console'), findsNothing);
    expect(find.text('history'), findsNothing);
  });

  testWidgets('dispute withdraw success posts disputeId only and stays minimal', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'POST /api/app/dispute/withdraw': (AppApiRequest request) async {
              expect(request.body, <String, Object?>{'disputeId': 'dispute-1'});
              return AppApiResponse(
                statusCode: 202,
                uri: request.uri,
                body: _disputePayload(
                  disputeId: 'dispute-1',
                  orderId: 'order-1',
                  state: 'withdrawn',
                  summaryHeading: 'withdrawn dispute',
                ),
              );
            },
          },
    );

    await tester.pumpWidget(
      _buildApp(
        initialRoute:
            '${ExhibitionRoutes.disputeWithdraw}?disputeId=dispute-1&orderId=order-1',
        transport: transport,
      ),
    );
    await tester.pumpAndSettle();

    final submitButton = find.byKey(
      const ValueKey<String>('dispute_withdraw_submit_button'),
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
    await tester.pumpAndSettle();

    expect(
      transport.requests.any(
        (AppApiRequest request) {
          final body = request.body;
          return request.canonicalPath ==
                  ExhibitionCanonicalPaths.disputeWithdraw &&
              body is Map<String, Object?> &&
              body.length == 1 &&
              body['disputeId'] == 'dispute-1';
        },
      ),
      isTrue,
    );
    expect(find.textContaining('当前争议 ID：dispute-1'), findsWidgets);
    expect(find.text('当前业务状态：已撤回'), findsOneWidget);
    expect(find.text('当前业务状态：已撤回'), findsOneWidget);
    expect(find.textContaining('当前订单 ID：order-1'), findsWidgets);
    expect(find.text('当前动作：争议撤回已完成，页面停留在只读结果页，不再继续暴露新的操作。'), findsOneWidget);
    expect(find.text('当前动作：可以继续撤回争议；页面不会本地补做资格、范围或治理判断。'), findsNothing);
    expect(find.text('去争议撤回'), findsNothing);
    expect(find.text('negotiation'), findsNothing);
    expect(find.text('platform review'), findsNothing);
    expect(find.text('escalation'), findsNothing);
    expect(find.text('resolution'), findsNothing);
    expect(find.text('detail'), findsNothing);
    expect(find.text('history'), findsNothing);
    expect(find.text('governance console'), findsNothing);
  });

  testWidgets('dispute withdraw without disputeId enters controlled state', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(handlers: const {});

    await tester.pumpWidget(
      _buildApp(
        initialRoute: ExhibitionRoutes.disputeWithdraw,
        transport: transport,
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('当前入口还没有承接到所需实例，这一页暂时不能继续。你现在可以先回到展览，再从已承接主链重新进入。'),
      findsOneWidget,
    );
    expect(find.text('回到展览'), findsOneWidget);
    expect(find.textContaining('controlled state:'), findsNothing);
    expect(
      transport.requests.where(
        (AppApiRequest request) =>
            request.canonicalPath == ExhibitionCanonicalPaths.disputeWithdraw,
      ),
      isEmpty,
    );
  });

  testWidgets('dispute open 409 enters controlled failure on page', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'POST /api/app/dispute/open': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 409,
                uri: request.uri,
                body: <String, Object?>{
                  'code': 'DISPUTE_INVALID_STATE',
                  'message':
                      'current actor is not eligible to open this dispute',
                },
              );
            },
          },
    );

    await tester.pumpWidget(
      _buildApp(
        initialRoute: '${ExhibitionRoutes.disputeOpen}?orderId=order-1',
        transport: transport,
      ),
    );
    await tester.pumpAndSettle();

    final submitButton = find.byKey(
      const ValueKey<String>('dispute_open_submit_button'),
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
    await tester.pumpAndSettle();

    expect(find.text('当前动作未完成'), findsOneWidget);
    expect(
      find.text('current actor is not eligible to open this dispute'),
      findsOneWidget,
    );
    expect(find.text('回到展览'), findsOneWidget);
    expect(find.textContaining('error code:'), findsNothing);
    expect(find.textContaining('controlled state:'), findsNothing);
  });

  testWidgets('dispute withdraw 400 enters controlled failure on page', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'POST /api/app/dispute/withdraw': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 400,
                uri: request.uri,
                body: <String, Object?>{
                  'code': 'DISPUTE_WITHDRAW_INVALID',
                  'message': 'disputeId is required',
                },
              );
            },
          },
    );

    await tester.pumpWidget(
      _buildApp(
        initialRoute:
            '${ExhibitionRoutes.disputeWithdraw}?disputeId=dispute-1&orderId=order-1',
        transport: transport,
      ),
    );
    await tester.pumpAndSettle();

    final submitButton = find.byKey(
      const ValueKey<String>('dispute_withdraw_submit_button'),
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
    await tester.pumpAndSettle();

    expect(find.text('当前动作未完成'), findsOneWidget);
    expect(find.text('disputeId is required'), findsOneWidget);
    expect(find.text('回到展览'), findsOneWidget);
    expect(find.textContaining('error code:'), findsNothing);
    expect(find.textContaining('controlled state:'), findsNothing);
  });

  testWidgets('dispute withdraw 409 enters controlled failure on page', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'POST /api/app/dispute/withdraw': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 409,
                uri: request.uri,
                body: <String, Object?>{
                  'code': 'DISPUTE_INVALID_STATE',
                  'message': 'dispute is not withdrawable in current state',
                },
              );
            },
          },
    );

    await tester.pumpWidget(
      _buildApp(
        initialRoute:
            '${ExhibitionRoutes.disputeWithdraw}?disputeId=dispute-1&orderId=order-1',
        transport: transport,
      ),
    );
    await tester.pumpAndSettle();

    final submitButton = find.byKey(
      const ValueKey<String>('dispute_withdraw_submit_button'),
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
    await tester.pumpAndSettle();

    expect(find.text('当前动作未完成'), findsOneWidget);
    expect(
      find.text('dispute is not withdrawable in current state'),
      findsOneWidget,
    );
    expect(find.text('回到展览'), findsOneWidget);
    expect(find.textContaining('error code:'), findsNothing);
    expect(find.textContaining('controlled state:'), findsNothing);
  });

  test(
    'dispute open 409 stays controlled without local state judgement',
    () async {
      final consumer = ExhibitionConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'POST /api/app/dispute/open': (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 409,
                      uri: request.uri,
                      body: <String, Object?>{
                        'code': 'DISPUTE_INVALID_STATE',
                        'message':
                            'current actor is not eligible to open this dispute',
                      },
                    );
                  },
                },
          ),
        ),
      );

      final result = await consumer.openDispute(
        const DisputeOpenCommand(orderId: 'order-1'),
      );

      expect(result.isSuccess, isFalse);
      expect(result.controlledState, AppPageState.errorNonRetryable);
      expect(result.errorCode, 'DISPUTE_INVALID_STATE');
      expect(
        result.message,
        'current actor is not eligible to open this dispute',
      );
    },
  );

  test(
    'dispute withdraw 400 stays controlled and does not invent side or scope',
    () async {
      final consumer = ExhibitionConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'POST /api/app/dispute/withdraw':
                      (AppApiRequest request) async {
                        expect(request.body, <String, Object?>{
                          'disputeId': 'dispute-1',
                        });
                        return AppApiResponse(
                          statusCode: 400,
                          uri: request.uri,
                          body: <String, Object?>{
                            'code': 'DISPUTE_WITHDRAW_INVALID',
                            'message': 'disputeId is required',
                          },
                        );
                      },
                },
          ),
        ),
      );

      final result = await consumer.withdrawDispute(
        const DisputeWithdrawCommand(disputeId: 'dispute-1'),
      );

      expect(result.isSuccess, isFalse);
      expect(result.controlledState, AppPageState.errorNonRetryable);
      expect(result.errorCode, 'DISPUTE_WITHDRAW_INVALID');
      expect(result.message, 'disputeId is required');
      expect(result.payload, <String, Object?>{
        'code': 'DISPUTE_WITHDRAW_INVALID',
        'message': 'disputeId is required',
      });
    },
  );
}
