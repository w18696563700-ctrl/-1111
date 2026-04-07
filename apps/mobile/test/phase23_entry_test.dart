import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/shell/shell_app.dart';

Map<String, Object?> _summary([String heading = 'summary']) {
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

Map<String, Object?> _disputePayload({
  required String disputeId,
  required String orderId,
  String state = 'opened',
  String summaryHeading = 'dispute',
}) {
  return <String, Object?>{
    'disputeId': disputeId,
    'orderId': orderId,
    'state': state,
    'summary': _summary(summaryHeading),
  };
}

void main() {
  Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
  defaultHandlers() {
    return <String, Future<AppApiResponse> Function(AppApiRequest request)>{
      'GET /api/app/project/list': (AppApiRequest request) async {
        return AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: <String, Object?>{'items': <Object?>[]},
        );
      },
    };
  }

  ExhibitionMobileApp buildApp({
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

  testWidgets('contract detail canonical path is assembled from orderId', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            ...defaultHandlers(),
            'GET /api/app/contract/detail': (AppApiRequest request) async {
              expect(request.uri.queryParameters['orderId'], 'order-1');
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _contractPayload(
                  contractId: 'contract-1',
                  orderId: 'order-1',
                ),
              );
            },
          },
    );

    await tester.pumpWidget(
      buildApp(
        initialRoute: '${ExhibitionRoutes.contractDetail}?orderId=order-1',
        transport: transport,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('合同详情'), findsWidgets);
    final confirmButton = find.text('继续合同确认');
    await tester.scrollUntilVisible(
      confirmButton,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(confirmButton, findsOneWidget);
    expect(
      transport.requests.single.canonicalPath,
      ExhibitionCanonicalPaths.contractDetail,
    );
  });

  testWidgets('contract confirm loads detail and posts real contractId', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            ...defaultHandlers(),
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
      buildApp(
        initialRoute: '${ExhibitionRoutes.contractConfirm}?orderId=order-1',
        transport: transport,
      ),
    );
    await tester.pumpAndSettle();

    final submitButton = find.text(
      '提交',
      findRichText: true,
      skipOffstage: false,
    );
    await tester.ensureVisible(submitButton);
    await tester.pumpAndSettle();
    await tester.tap(submitButton);
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
  });

  testWidgets('dispute open canonical path is assembled from orderId', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            ...defaultHandlers(),
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
                ),
              );
            },
          },
    );

    await tester.pumpWidget(
      buildApp(
        initialRoute: '${ExhibitionRoutes.disputeOpen}?orderId=order-1',
        transport: transport,
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'reason (optional)'),
      '质量争议',
    );
    final submitButton = find.text(
      '提交',
      findRichText: true,
      skipOffstage: false,
    );
    await tester.ensureVisible(submitButton);
    await tester.pumpAndSettle();
    await tester.tap(submitButton);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(
      find.textContaining('当前争议 ID：dispute-1'),
      findsOneWidget,
    );
    expect(
      transport.requests.single.canonicalPath,
      ExhibitionCanonicalPaths.disputeOpen,
    );
  });

  testWidgets('contract detail without orderId enters controlled state', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(handlers: defaultHandlers());

    await tester.pumpWidget(
      buildApp(
        initialRoute: ExhibitionRoutes.contractDetail,
        transport: transport,
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('orderId is required from route context before contract entry'),
      findsOneWidget,
    );
    expect(
      transport.requests.where(
        (AppApiRequest request) =>
            request.canonicalPath == ExhibitionCanonicalPaths.contractDetail,
      ),
      isEmpty,
    );
  });

  test('missing contract summary enters controlled failure', () async {
    final consumer = ExhibitionConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'GET /api/app/contract/detail': (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: <String, Object?>{
                      'contractId': 'contract-1',
                      'orderId': 'order-1',
                      'state': 'pending_confirm',
                    },
                  );
                },
              },
        ),
      ),
    );

    final result = await consumer.loadContractDetail(orderId: 'order-1');

    expect(result.state, AppPageState.errorNonRetryable);
    expect(result.message, contains('missing required field "summary"'));
  });

  test('unknown dispute error code stays controlled and explicit', () async {
    final consumer = ExhibitionConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'POST /api/app/dispute/open': (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 409,
                    uri: request.uri,
                    body: <String, Object?>{
                      'code': 'DISPUTE_ALREADY_EXISTS',
                      'message': 'A dispute already exists for this order.',
                      'source': 'server',
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
    expect(result.errorCode, isNull);
    expect(
      result.message,
      'unrecognized error code DISPUTE_ALREADY_EXISTS from canonical path: '
      'A dispute already exists for this order.',
    );
  });
}
