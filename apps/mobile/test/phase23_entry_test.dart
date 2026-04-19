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
  required String orderId,
  String state = 'accepted',
  String summaryHeading = 'dispute',
}) {
  return <String, Object?>{
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

  testWidgets(
    'contract detail canonical path is assembled from orderId and exposes the minimal confirm entry only',
    (WidgetTester tester) async {
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

    final confirmButton = find.byKey(
      const ValueKey<String>('contract_confirm_button'),
    );
    await tester.scrollUntilVisible(
      confirmButton,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('合同详情'), findsWidgets);
    expect(confirmButton, findsOneWidget);
    expect(find.byKey(const ValueKey<String>('contract_amend_button')), findsNothing);
    expect(find.text('继续合同改单'), findsNothing);
    expect(
      transport.requests.single.canonicalPath,
      ExhibitionCanonicalPaths.contractDetail,
    );
  });

  testWidgets(
    'contract confirm submits orderId and refreshes contract detail and my-project list',
    (WidgetTester tester) async {
      var contractDetailRequestCount = 0;
      var myProjectListRequestCount = 0;
      final transport = FakeAppApiTransport(
        handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
          ...defaultHandlers(),
          'GET /api/app/contract/detail': (AppApiRequest request) async {
            contractDetailRequestCount += 1;
            expect(request.uri.queryParameters['orderId'], 'order-1');
            return AppApiResponse(
              statusCode: 200,
              uri: request.uri,
              body: _contractPayload(
                contractId: 'contract-1',
                orderId: 'order-1',
                state: contractDetailRequestCount == 1
                    ? 'pending_confirm'
                    : 'active',
              ),
            );
          },
          'POST /api/app/contract/confirm': (AppApiRequest request) async {
            expect(request.body, <String, Object?>{'orderId': 'order-1'});
            return AppApiResponse(
              statusCode: 202,
              uri: request.uri,
              body: _contractPayload(
                contractId: 'contract-1',
                orderId: 'order-1',
                state: 'active',
                summaryHeading: 'confirmed',
              ),
            );
          },
          'GET /api/app/my/projects': (AppApiRequest request) async {
            myProjectListRequestCount += 1;
            return AppApiResponse(
              statusCode: 200,
              uri: request.uri,
              body: <String, Object?>{'items': <Object?>[]},
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

      final confirmButton = find.byKey(
        const ValueKey<String>('contract_confirm_button'),
      );
      await tester.scrollUntilVisible(
        confirmButton,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(confirmButton, findsOneWidget);
      await tester.pumpAndSettle();
      await tester.tap(confirmButton);
      await tester.pump();
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('合同确认已受理'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('当前动作已完成'), findsOneWidget);
      expect(find.text('合同确认已受理'), findsOneWidget);
      expect(
        find.text('如果当前合同需要最小改单，可以直接在这里执行；改单成功后页面会刷新合同详情和我的项目。'),
        findsOneWidget,
      );
      expect(confirmButton, findsNothing);
      expect(contractDetailRequestCount, 2);
      expect(myProjectListRequestCount, 1);
      expect(
        transport.requests
            .where(
              (AppApiRequest request) =>
                  request.canonicalPath ==
                  ExhibitionCanonicalPaths.contractConfirm,
            )
            .length,
        1,
      );
    },
  );

  testWidgets(
    'contract detail exposes the minimal amend entry only when contract is active',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
          ...defaultHandlers(),
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
        buildApp(
          initialRoute: '${ExhibitionRoutes.contractDetail}?orderId=order-1',
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      final amendButton = find.byKey(
        const ValueKey<String>('contract_amend_button'),
      );
      await tester.scrollUntilVisible(
        amendButton,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(amendButton, findsOneWidget);
      expect(find.byKey(const ValueKey<String>('contract_confirm_button')), findsNothing);
    },
  );

  testWidgets(
    'contract amend submits orderId and refreshes contract detail and my-project list',
    (WidgetTester tester) async {
      var contractDetailRequestCount = 0;
      var myProjectListRequestCount = 0;
      final transport = FakeAppApiTransport(
        handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
          ...defaultHandlers(),
          'GET /api/app/contract/detail': (AppApiRequest request) async {
            contractDetailRequestCount += 1;
            expect(request.uri.queryParameters['orderId'], 'order-1');
            return AppApiResponse(
              statusCode: 200,
              uri: request.uri,
              body: _contractPayload(
                contractId: 'contract-1',
                orderId: 'order-1',
                state: contractDetailRequestCount == 1 ? 'active' : 'amended',
              ),
            );
          },
          'POST /api/app/contract/amend': (AppApiRequest request) async {
            expect(request.body, <String, Object?>{'orderId': 'order-1'});
            return AppApiResponse(
              statusCode: 202,
              uri: request.uri,
              body: _contractPayload(
                contractId: 'contract-1',
                orderId: 'order-1',
                state: 'amended',
                summaryHeading: 'amended',
              ),
            );
          },
          'GET /api/app/my/projects': (AppApiRequest request) async {
            myProjectListRequestCount += 1;
            return AppApiResponse(
              statusCode: 200,
              uri: request.uri,
              body: <String, Object?>{'items': <Object?>[]},
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

      final amendButton = find.byKey(
        const ValueKey<String>('contract_amend_button'),
      );
      await tester.scrollUntilVisible(
        amendButton,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(amendButton, findsOneWidget);
      await tester.ensureVisible(amendButton);
      await tester.pumpAndSettle();
      await tester.tap(amendButton);
      await tester.pump();
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('合同改单已受理'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('当前动作已完成'), findsOneWidget);
      expect(find.text('合同改单已受理'), findsOneWidget);
      expect(
        find.text('当前合同已改单，后续以回看当前状态为主，不再展开更多闭环。'),
        findsOneWidget,
      );
      expect(amendButton, findsNothing);
      expect(contractDetailRequestCount, 2);
      expect(myProjectListRequestCount, 1);
      expect(
        transport.requests
            .where(
              (AppApiRequest request) =>
                  request.canonicalPath ==
                  ExhibitionCanonicalPaths.contractAmend,
            )
            .length,
        1,
      );
    },
  );

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
      '继续争议开启',
      findRichText: true,
      skipOffstage: false,
    );
    await tester.ensureVisible(submitButton);
    await tester.pumpAndSettle();
    await tester.tap(submitButton);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.textContaining('当前争议 ID：'), findsNothing);
    expect(find.text('当前状态：已受理'), findsOneWidget);
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

  testWidgets('order detail without orderId enters controlled state', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(handlers: defaultHandlers());

    await tester.pumpWidget(
      buildApp(
        initialRoute: ExhibitionRoutes.orderDetail,
        transport: transport,
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('当前入口还没有承接到所需实例，这一页暂时不能继续。你现在可以先回到展览，再从已承接主链重新进入。'),
      findsOneWidget,
    );
    expect(
      find.text('orderId is required from route context before order entry'),
      findsNothing,
    );
    expect(
      transport.requests.where(
        (AppApiRequest request) =>
            request.canonicalPath == ExhibitionCanonicalPaths.orderDetail,
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
