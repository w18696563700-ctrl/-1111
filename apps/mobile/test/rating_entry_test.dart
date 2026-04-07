import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/shell/shell_app.dart';

Map<String, Object?> _ratingSummary([String heading = 'rating']) {
  return <String, Object?>{'heading': heading};
}

Map<String, Object?> _ratingEntryPayload({
  required String orderId,
  String state = 'draft',
  String summaryHeading = 'rating entry',
}) {
  return <String, Object?>{
    'orderId': orderId,
    'state': state,
    'summary': _ratingSummary(summaryHeading),
  };
}

Map<String, Object?> _ratingSubmitPayload({
  required String ratingId,
  required String orderId,
  String state = 'submitted',
  String summaryHeading = 'rating submit',
}) {
  return <String, Object?>{
    'ratingId': ratingId,
    'orderId': orderId,
    'state': state,
    'summary': _ratingSummary(summaryHeading),
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
  testWidgets('rating entry success stays read-only and hands off to submit', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/rating/entry': (AppApiRequest request) async {
              expect(request.uri.queryParameters['orderId'], 'order-1');
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _ratingEntryPayload(orderId: 'order-1'),
              );
            },
          },
    );

    await tester.pumpWidget(
      _buildApp(
        initialRoute: '${ExhibitionRoutes.ratingEntry}?orderId=order-1',
        transport: transport,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('评价入口'), findsWidgets);
    final handoffButton = find.widgetWithText(FilledButton, '继续提交评价');
    await tester.scrollUntilVisible(
      handoffButton,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('当前订单 ID：order-1'), findsAtLeastNWidgets(1));
    expect(find.text('当前业务状态：草稿'), findsOneWidget);
    expect(find.text('摘要承接：已承接最小 summary'), findsOneWidget);
    expect(handoffButton, findsOneWidget);
    expect(find.text('开启争议入口'), findsNothing);
    expect(find.text('eligibility console'), findsNothing);
    expect(find.text('review matrix'), findsNothing);
    expect(find.text('history'), findsNothing);
    expect(transport.requests, hasLength(1));
    expect(
      transport.requests.single.canonicalPath,
      ExhibitionCanonicalPaths.ratingEntry,
    );
  });

  testWidgets('rating entry submitted state stays read-only', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/rating/entry': (AppApiRequest request) async {
              expect(request.uri.queryParameters['orderId'], 'order-1');
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _ratingEntryPayload(
                  orderId: 'order-1',
                  state: 'submitted',
                ),
              );
            },
          },
    );

    await tester.pumpWidget(
      _buildApp(
        initialRoute: '${ExhibitionRoutes.ratingEntry}?orderId=order-1',
        transport: transport,
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('当前动作：当前保持只读'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('当前业务状态：已提交'), findsOneWidget);
    expect(find.text('当前动作：当前保持只读'), findsOneWidget);
    expect(find.text('继续提交评价'), findsNothing);
  });

  testWidgets('rating submit success posts orderId only and stays minimal', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/rating/entry': (AppApiRequest request) async {
              expect(request.uri.queryParameters['orderId'], 'order-1');
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _ratingEntryPayload(orderId: 'order-1', state: 'draft'),
              );
            },
            'POST /api/app/rating/submit': (AppApiRequest request) async {
              expect(request.body, <String, Object?>{'orderId': 'order-1'});
              return AppApiResponse(
                statusCode: 202,
                uri: request.uri,
                body: _ratingSubmitPayload(
                  ratingId: 'rating-1',
                  orderId: 'order-1',
                ),
              );
            },
          },
    );

    await tester.pumpWidget(
      _buildApp(
        initialRoute: '${ExhibitionRoutes.ratingSubmit}?orderId=order-1',
        transport: transport,
      ),
    );
    await tester.pumpAndSettle();

    final submitButton = find.byKey(
      const ValueKey<String>('rating_submit_button'),
    );
    await tester.scrollUntilVisible(
      submitButton,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('当前业务状态：草稿'), findsOneWidget);
    final submitAction = tester.widget<FilledButton>(submitButton);
    expect(submitAction.onPressed, isNotNull);
    submitAction.onPressed!();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(
      transport.requests
          .map((AppApiRequest request) => request.canonicalPath)
          .toList(),
      containsAll(<String>[
        ExhibitionCanonicalPaths.ratingEntry,
        ExhibitionCanonicalPaths.ratingSubmit,
      ]),
    );
    expect(find.textContaining('当前评价 ID：rating-1'), findsAtLeastNWidgets(1));
    expect(find.textContaining('当前订单 ID：order-1'), findsAtLeastNWidgets(1));
    expect(find.text('当前业务状态：已提交'), findsOneWidget);
    expect(find.text('摘要承接：已承接最小 summary'), findsWidgets);
    expect(find.text('开启争议入口'), findsNothing);
    expect(find.text('eligibility console'), findsNothing);
    expect(find.text('review matrix'), findsNothing);
    expect(find.text('history'), findsNothing);
  });

  testWidgets(
    'rating submit submitted state stays read-only and does not allow submit',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/rating/entry': (AppApiRequest request) async {
                expect(request.uri.queryParameters['orderId'], 'order-1');
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _ratingEntryPayload(
                    orderId: 'order-1',
                    state: 'submitted',
                  ),
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          initialRoute: '${ExhibitionRoutes.ratingSubmit}?orderId=order-1',
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      final submitButton = find.byKey(
        const ValueKey<String>('rating_submit_button'),
      );
      await tester.scrollUntilVisible(
        submitButton,
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('当前业务状态：已提交'), findsOneWidget);
      expect(find.text('当前动作：评价已经提交，当前页保持只读承接，不再继续放开提交。'), findsOneWidget);
      final submitAction = tester.widget<FilledButton>(submitButton);
      expect(submitAction.onPressed, isNull);
    },
  );

  testWidgets('rating submit 400 enters controlled failure on page', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/rating/entry': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _ratingEntryPayload(orderId: 'order-1', state: 'draft'),
              );
            },
            'POST /api/app/rating/submit': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 400,
                uri: request.uri,
                body: <String, Object?>{
                  'code': 'RATING_SUBMIT_INVALID',
                  'message': 'orderId is required',
                },
              );
            },
          },
    );

    await tester.pumpWidget(
      _buildApp(
        initialRoute: '${ExhibitionRoutes.ratingSubmit}?orderId=order-1',
        transport: transport,
      ),
    );
    await tester.pumpAndSettle();

    final submitButton = find.byKey(
      const ValueKey<String>('rating_submit_button'),
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
    expect(find.text('orderId is required'), findsOneWidget);
    expect(find.text('回到展览'), findsOneWidget);
    expect(find.textContaining('error code:'), findsNothing);
    expect(find.textContaining('controlled state:'), findsNothing);
  });

  testWidgets('rating submit 409 stays controlled on page', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/rating/entry': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _ratingEntryPayload(orderId: 'order-1', state: 'draft'),
              );
            },
            'POST /api/app/rating/submit': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 409,
                uri: request.uri,
                body: <String, Object?>{
                  'code': 'RATING_INVALID_STATE',
                  'message': 'rating is already submitted',
                },
              );
            },
          },
    );

    await tester.pumpWidget(
      _buildApp(
        initialRoute: '${ExhibitionRoutes.ratingSubmit}?orderId=order-1',
        transport: transport,
      ),
    );
    await tester.pumpAndSettle();

    final submitButton = find.byKey(
      const ValueKey<String>('rating_submit_button'),
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
    expect(find.text('rating is already submitted'), findsOneWidget);
    expect(find.text('回到展览'), findsOneWidget);
    expect(find.textContaining('error code:'), findsNothing);
    expect(find.textContaining('controlled state:'), findsNothing);
  });

  testWidgets('rating entry 409 enters controlled failure on page', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/rating/entry': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 409,
                uri: request.uri,
                body: <String, Object?>{
                  'code': 'RATING_ENTRY_UNAVAILABLE',
                  'message': 'rating truth is unavailable for this order',
                },
              );
            },
          },
    );

    await tester.pumpWidget(
      _buildApp(
        initialRoute: '${ExhibitionRoutes.ratingEntry}?orderId=order-1',
        transport: transport,
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('rating truth is unavailable for this order'),
      findsOneWidget,
    );
    expect(find.text('回到展览'), findsOneWidget);
    expect(find.textContaining('error code:'), findsNothing);
    expect(find.textContaining('controlled state:'), findsNothing);
  });

  test(
    'rating submit 409 stays controlled and does not invent truth or eligibility',
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
                  'POST /api/app/rating/submit': (AppApiRequest request) async {
                    expect(request.body, <String, Object?>{
                      'orderId': 'order-1',
                    });
                    return AppApiResponse(
                      statusCode: 409,
                      uri: request.uri,
                      body: <String, Object?>{
                        'code': 'RATING_INVALID_STATE',
                        'message': 'rating is already submitted',
                      },
                    );
                  },
                },
          ),
        ),
      );

      final result = await consumer.submitRating(
        const RatingSubmitCommand(orderId: 'order-1'),
      );

      expect(result.isSuccess, isFalse);
      expect(result.controlledState, AppPageState.errorNonRetryable);
      expect(result.errorCode, 'RATING_INVALID_STATE');
      expect(result.message, 'rating is already submitted');
    },
  );

  test('unknown rating state still enters controlled failure', () async {
    final consumer = ExhibitionConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'GET /api/app/rating/entry': (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: _ratingEntryPayload(
                      orderId: 'order-1',
                      state: 'ready',
                    ),
                  );
                },
              },
        ),
      ),
    );

    final result = await consumer.loadRatingEntry(orderId: 'order-1');

    expect(result.state, AppPageState.errorNonRetryable);
    expect(result.message, contains('unsupported state "ready"'));
  });
}
