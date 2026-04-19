import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/shell/shell_app.dart';

Map<String, Object?> _summary([String heading = 'rating']) {
  return <String, Object?>{'heading': heading};
}

Map<String, Object?> _ratingPayload({
  required String ratingId,
  required String orderId,
  required String state,
  String summaryHeading = 'rating',
}) {
  return <String, Object?>{
    'ratingId': ratingId,
    'orderId': orderId,
    'state': state,
    'summary': _summary(summaryHeading),
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
          'orderStatus': 'active',
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
    'rating entry canonical path is assembled from orderId and exposes the minimal submit entry',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/rating/entry': (AppApiRequest request) async {
                expect(request.uri.queryParameters['orderId'], 'order-1');
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _ratingPayload(
                    ratingId: 'rating-1',
                    orderId: 'order-1',
                    state: 'eligible',
                  ),
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          initialRoute: ExhibitionRoutes.ratingEntryWithOrderId('order-1'),
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('评价入口'), findsWidgets);
      expect(find.textContaining('当前订单 ID：order-1'), findsAtLeastNWidgets(1));
      await tester.scrollUntilVisible(
        find.text('当前状态：待评价'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('当前状态：待评价'), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('rating_submit_button')),
        findsOneWidget,
      );
      expect(
        transport.requests.single.canonicalPath,
        ExhibitionCanonicalPaths.ratingEntry,
      );
    },
  );

  testWidgets(
    'rating submit posts orderId and refreshes my-project list only',
    (WidgetTester tester) async {
      var myProjectListRequestCount = 0;
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/rating/entry': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _ratingPayload(
                    ratingId: 'rating-1',
                    orderId: 'order-1',
                    state: 'eligible',
                  ),
                );
              },
              'POST /api/app/rating/submit': (AppApiRequest request) async {
                expect(request.body, <String, Object?>{'orderId': 'order-1'});
                return AppApiResponse(
                  statusCode: 202,
                  uri: request.uri,
                  body: _ratingPayload(
                    ratingId: 'rating-1',
                    orderId: 'order-1',
                    state: 'submitted',
                    summaryHeading: 'submitted',
                  ),
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
          initialRoute: ExhibitionRoutes.ratingEntryWithOrderId('order-1'),
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
        find.text('评价提交已受理'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('当前动作已完成'), findsAtLeastNWidgets(1));
      expect(find.text('评价提交已受理'), findsOneWidget);
      expect(find.textContaining('当前评价 ID：rating-1'), findsAtLeastNWidgets(1));
      expect(find.text('当前说明：评价提交已受理；页面已经刷新我的项目缓存。'), findsOneWidget);
      expect(myProjectListRequestCount, 1);

      final myProjectResult =
          await ExhibitionConsumerLayer.instance.loadMyProjectList();
      final myProjectPayload = myProjectResult.payload as Map<String, Object?>;
      final historicalProjects =
          myProjectPayload['historicalProjects'] as List<Object?>;
      final privateSummary =
          (historicalProjects.single as Map<String, Object?>)['privateSummary']
              as Map<String, Object?>;
      expect(privateSummary['evaluationStatus'], 'submitted');

      expect(
        transport.requests
            .where(
              (AppApiRequest request) =>
                  request.canonicalPath == ExhibitionCanonicalPaths.ratingSubmit,
            )
            .length,
        1,
      );
    },
  );
}
