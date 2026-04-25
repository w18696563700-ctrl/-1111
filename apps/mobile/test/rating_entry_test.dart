import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/shell/shell_app.dart';

Map<String, Object?> _counterpartyRatingEntryPayload({
  required bool canRate,
  String? reason,
  String? ratingState = 'eligible',
}) {
  return <String, Object?>{
    'orderId': 'order-1',
    'projectId': 'project-1',
    'raterOrganizationId': 'org-owner',
    'rateeOrganizationId': 'org-counterpart',
    'canRate': canRate,
    'reason': reason,
    'ratingState': ratingState,
  };
}

Map<String, Object?> _counterpartyRatingSubmitPayload() {
  return <String, Object?>{
    'ratingId': 'rating-1',
    'orderId': 'order-1',
    'projectId': 'project-1',
    'raterOrganizationId': 'org-owner',
    'rateeOrganizationId': 'org-counterpart',
    'state': 'submitted',
    'ratingState': 'submitted',
    'scoreValue': 5,
    'scoreLabel': 'very_satisfied',
    'submittedAt': '2026-06-03T10:00:00Z',
  };
}

Map<String, Object?> _orderDetailPayload() {
  return <String, Object?>{
    'orderId': 'order-1',
    'orderNo': 'ORD-1',
    'projectId': 'project-1',
    'buyerOrganizationId': 'org-owner',
    'sellerOrganizationId': 'org-counterpart',
    'state': 'completed',
    'completionRequestState': 'confirmed',
    'summary': <String, Object?>{'heading': 'order'},
  };
}

Map<String, Object?> _myProjectListPayload({required String evaluationStatus}) {
  return <String, Object?>{
    'ongoingProjects': <Object?>[],
    'historicalProjects': <Object?>[
      <String, Object?>{
        'publicProject': <String, Object?>{
          'projectId': 'project-1',
          'projectNo': 'MY-001',
          'title': '评价项目',
          'buildingType': 'exhibition',
          'budgetAmount': 2000,
          'state': 'converted_to_order',
          'summary': <String, Object?>{'heading': 'history'},
        },
        'privateSummary': <String, Object?>{
          'hasAcceptedOrder': true,
          'orderStatus': 'completed',
          'contractStatus': 'active',
          'fulfillmentStatus': 'submitted',
          'acceptanceStatus': 'rechecked',
          'afterSalesOrDisputeStatus': null,
          'formalCompletionStatus': 'formally_completed',
          'evaluationStatus': evaluationStatus,
        },
      },
    ],
  };
}

ExhibitionMobileApp _buildApp({
  required String initialRoute,
  required FakeAppApiTransport transport,
}) {
  final sessionStore = AppSessionStore()
    ..establishSession(
      accessToken: 'rating-entry-access',
      refreshToken: 'rating-entry-refresh',
      expiresInSeconds: 3600,
      deviceId: 'rating-entry-device',
    );

  return ExhibitionMobileApp(
    initialRoute: initialRoute,
    sessionStore: sessionStore,
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
    'counterparty rating entry uses the new three-anchor app-facing route',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/project-counterparty-rating/entry':
                  (AppApiRequest request) async {
                    expect(request.uri.queryParameters['orderId'], 'order-1');
                    expect(
                      request.uri.queryParameters['projectId'],
                      'project-1',
                    );
                    expect(
                      request.uri.queryParameters['rateeOrganizationId'],
                      'org-counterpart',
                    );
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _counterpartyRatingEntryPayload(canRate: true),
                    );
                  },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          initialRoute: ExhibitionRoutes.projectCounterpartyRatingEntry(
            orderId: 'order-1',
            projectId: 'project-1',
            rateeOrganizationId: 'org-counterpart',
          ),
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('双方互评入口'), findsWidgets);
      expect(find.textContaining('当前订单 ID：order-1'), findsAtLeastNWidgets(1));
      await tester.scrollUntilVisible(
        find.text('当前状态：待评价'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('当前项目 ID：project-1'), findsOneWidget);
      expect(find.textContaining('被评主体 ID：org-counterpart'), findsOneWidget);
      expect(find.text('当前状态：待评价'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey<String>('rating_submit_button')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.byKey(const ValueKey<String>('rating_submit_button')),
        findsOneWidget,
      );
      expect(
        transport.requests.single.canonicalPath,
        ExhibitionCanonicalPaths.projectCounterpartyRatingEntry,
      );
      expect(
        transport.requests.any(
          (AppApiRequest request) =>
              request.canonicalPath == ExhibitionCanonicalPaths.ratingSubmit,
        ),
        isFalse,
      );
    },
  );

  testWidgets(
    'counterparty rating submit posts the new truth anchors and refreshes state',
    (WidgetTester tester) async {
      var myProjectListRequestCount = 0;
      var orderDetailRequestCount = 0;
      var entryRequestCount = 0;
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/project-counterparty-rating/entry':
                  (AppApiRequest request) async {
                    entryRequestCount += 1;
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _counterpartyRatingEntryPayload(
                        canRate: entryRequestCount == 1,
                        ratingState: entryRequestCount == 1
                            ? 'eligible'
                            : 'submitted',
                        reason: entryRequestCount == 1 ? null : '评价已提交。',
                      ),
                    );
                  },
              'POST /api/app/project-counterparty-rating/submit':
                  (AppApiRequest request) async {
                    expect(request.body, <String, Object?>{
                      'orderId': 'order-1',
                      'projectId': 'project-1',
                      'rateeOrganizationId': 'org-counterpart',
                      'scoreLabel': 'very_satisfied',
                      'commentText': '标签：响应及时',
                    });
                    return AppApiResponse(
                      statusCode: 202,
                      uri: request.uri,
                      body: _counterpartyRatingSubmitPayload(),
                    );
                  },
              'GET /api/app/order/detail': (AppApiRequest request) async {
                orderDetailRequestCount += 1;
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _orderDetailPayload(),
                );
              },
              'GET /api/app/my/projects': (AppApiRequest request) async {
                myProjectListRequestCount += 1;
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _myProjectListPayload(evaluationStatus: 'submitted'),
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          initialRoute: ExhibitionRoutes.projectCounterpartyRatingEntry(
            orderId: 'order-1',
            projectId: 'project-1',
            rateeOrganizationId: 'org-counterpart',
          ),
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
      await tester.ensureVisible(submitButton);
      await tester.pumpAndSettle();
      await tester.tap(submitButton);
      await tester.pump();
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('双方互评已提交'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('当前动作已完成'), findsAtLeastNWidgets(1));
      expect(find.text('双方互评已提交'), findsOneWidget);
      expect(find.textContaining('当前评价 ID：rating-1'), findsAtLeastNWidgets(1));
      expect(entryRequestCount, 2);
      expect(orderDetailRequestCount, 1);
      expect(myProjectListRequestCount, 1);

      expect(
        transport.requests
            .where(
              (AppApiRequest request) =>
                  request.canonicalPath ==
                  ExhibitionCanonicalPaths.projectCounterpartyRatingSubmit,
            )
            .length,
        1,
      );
      expect(
        transport.requests.any(
          (AppApiRequest request) =>
              request.canonicalPath == ExhibitionCanonicalPaths.ratingSubmit,
        ),
        isFalse,
      );
    },
  );

  testWidgets(
    'counterparty rating forbidden submit uses controlled copy without raw path leakage',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
          'GET /api/app/project-counterparty-rating/entry':
              (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _counterpartyRatingEntryPayload(canRate: true),
                );
              },
          'POST /api/app/project-counterparty-rating/submit':
              (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 403,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'errorCode': 'PROJECT_COUNTERPARTY_RATING_FORBIDDEN',
                    'message':
                        'upstream POST /api/app/project-counterparty-rating/submit forbidden stack trace',
                  },
                );
              },
        },
      );

      await tester.pumpWidget(
        _buildApp(
          initialRoute: ExhibitionRoutes.projectCounterpartyRatingEntry(
            orderId: 'order-1',
            projectId: 'project-1',
            rateeOrganizationId: 'org-counterpart',
          ),
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
      await tester.ensureVisible(submitButton);
      await tester.pumpAndSettle();
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.textContaining('当前账号不能评价该订单对方主体'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('当前账号不能评价该订单对方主体'), findsOneWidget);
      expect(
        find.textContaining('/api/app/project-counterparty-rating/submit'),
        findsNothing,
      );
      expect(find.textContaining('stack trace'), findsNothing);
    },
  );

  testWidgets(
    'counterparty rating duplicate submit uses controlled copy and blocks raw leakage',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
          'GET /api/app/project-counterparty-rating/entry':
              (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _counterpartyRatingEntryPayload(canRate: true),
                );
              },
          'POST /api/app/project-counterparty-rating/submit':
              (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 409,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'errorCode': 'PROJECT_COUNTERPARTY_RATING_DUPLICATE',
                    'message':
                        'upstream POST /api/app/project-counterparty-rating/submit duplicate stack trace',
                  },
                );
              },
        },
      );

      await tester.pumpWidget(
        _buildApp(
          initialRoute: ExhibitionRoutes.projectCounterpartyRatingEntry(
            orderId: 'order-1',
            projectId: 'project-1',
            rateeOrganizationId: 'org-counterpart',
          ),
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
      await tester.ensureVisible(submitButton);
      await tester.pumpAndSettle();
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.textContaining('当前双方互评已经提交过'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('当前双方互评已经提交过'), findsOneWidget);
      expect(
        find.textContaining('/api/app/project-counterparty-rating/submit'),
        findsNothing,
      );
      expect(find.textContaining('stack trace'), findsNothing);
    },
  );
}
