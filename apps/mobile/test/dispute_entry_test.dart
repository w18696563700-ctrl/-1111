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
  required String orderId,
  required String state,
  String summaryHeading = 'dispute',
  String? disputeId,
}) {
  return <String, Object?>{
    'orderId': orderId,
    'state': state,
    'summary': _disputeSummary(summaryHeading),
    if (disputeId case final String value) 'disputeId': value,
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
                  orderId: 'order-1',
                  state: 'accepted',
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
    expect(find.textContaining('当前争议 ID：'), findsNothing);
    expect(find.text('当前状态：已受理'), findsOneWidget);
    expect(find.text('当前说明：争议开启入口已经受理，当前页继续保留边界续接结果。'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '去争议撤回'), findsOneWidget);
    expect(find.text('当前边界'), findsOneWidget);
    expect(find.text('negotiation'), findsNothing);
    expect(find.text('platform review'), findsNothing);
    expect(find.text('escalation'), findsNothing);
    expect(find.text('resolution'), findsNothing);
    expect(find.text('eligibility console'), findsNothing);
    expect(find.text('history'), findsNothing);
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

  testWidgets(
    'dispute withdraw submits orderId and refreshes my-project list only',
    (WidgetTester tester) async {
      var myProjectListRequestCount = 0;
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'POST /api/app/dispute/withdraw': (AppApiRequest request) async {
                expect(request.body, <String, Object?>{'orderId': 'order-1'});
                return AppApiResponse(
                  statusCode: 202,
                  uri: request.uri,
                  body: _disputePayload(
                    disputeId: 'dispute-1',
                    orderId: 'order-1',
                    state: 'withdrawn',
                    summaryHeading: 'withdrawn',
                  ),
                );
              },
              'GET /api/app/my/projects': (AppApiRequest request) async {
                myProjectListRequestCount += 1;
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'items': <Object?>[],
                  },
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          initialRoute: '${ExhibitionRoutes.disputeWithdraw}?orderId=order-1',
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
      expect(submitButton, findsOneWidget);
      await tester.pumpAndSettle();
      await tester.ensureVisible(submitButton);
      await tester.pumpAndSettle();
      await tester.tap(submitButton);
      await tester.pump();
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('当前动作已完成').first,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('当前动作已完成'), findsAtLeastNWidgets(1));
      expect(find.text('争议撤回已受理'), findsOneWidget);
      expect(find.text('当前状态：已撤回'), findsOneWidget);
      expect(find.textContaining('当前争议 ID：dispute-1'), findsOneWidget);
      expect(myProjectListRequestCount, 1);
      expect(
        transport.requests
            .where(
              (AppApiRequest request) =>
                  request.canonicalPath ==
                  ExhibitionCanonicalPaths.disputeWithdraw,
            )
            .length,
        1,
      );
    },
  );

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
    'dispute withdraw 409 stays controlled without local state judgement',
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
                  'POST /api/app/dispute/withdraw': (
                    AppApiRequest request,
                  ) async {
                    return AppApiResponse(
                      statusCode: 409,
                      uri: request.uri,
                      body: <String, Object?>{
                        'code': 'DISPUTE_INVALID_STATE',
                        'message':
                            'current actor is not eligible to withdraw this dispute',
                      },
                    );
                  },
                },
          ),
        ),
      );

      final result = await consumer.withdrawDispute(
        const DisputeWithdrawCommand(orderId: 'order-1'),
      );

      expect(result.isSuccess, isFalse);
      expect(result.controlledState, AppPageState.errorNonRetryable);
      expect(result.errorCode, 'DISPUTE_INVALID_STATE');
      expect(
        result.message,
        'current actor is not eligible to withdraw this dispute',
      );
    },
  );

}
