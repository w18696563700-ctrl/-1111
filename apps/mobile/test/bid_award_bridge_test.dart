import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/shell/shell_app.dart';

Map<String, Object?> _summary([String heading = 'summary']) {
  return <String, Object?>{'heading': heading};
}

Map<String, Object?> _publicProjectDetail({
  required String projectId,
  required String state,
  required String viewerProjectRelation,
}) {
  return <String, Object?>{
    'projectId': projectId,
    'projectNo': 'PROJ-1',
    'title': '展会项目 1',
    'buildingType': 'exhibition',
    'budgetAmount': 1200,
    'state': state,
    'viewerProjectRelation': viewerProjectRelation,
    'summary': _summary('project'),
  };
}

Map<String, Object?> _projectPayload({
  required String projectId,
  required String state,
}) {
  return _publicProjectDetail(
    projectId: projectId,
    state: state,
    viewerProjectRelation: 'bidder',
  );
}

Map<String, Object?> _privateProgress({
  required bool hasAcceptedOrder,
  String? orderStatus,
  String? contractStatus,
  String evaluationStatus = 'not_eligible',
}) {
  return <String, Object?>{
    'hasAcceptedOrder': hasAcceptedOrder,
    'orderStatus': orderStatus,
    'contractStatus': contractStatus,
    'fulfillmentStatus': null,
    'acceptanceStatus': null,
    'afterSalesOrDisputeStatus': null,
    'formalCompletionStatus': 'not_formally_completed',
    'evaluationStatus': evaluationStatus,
  };
}

Map<String, Object?> _myProjectDetailPayload({
  required String projectId,
  required String state,
  required bool hasAcceptedOrder,
  String? orderStatus,
  String? contractStatus,
}) {
  return <String, Object?>{
    'publicProject': _publicProjectDetail(
      projectId: projectId,
      state: state,
      viewerProjectRelation: 'owner',
    ),
    'privateProgress': _privateProgress(
      hasAcceptedOrder: hasAcceptedOrder,
      orderStatus: orderStatus,
      contractStatus: contractStatus,
    ),
  };
}

Map<String, Object?> _myProjectListPayload({
  required String projectId,
  required String projectState,
  required String? orderStatus,
}) {
  return <String, Object?>{
    'ongoingProjects': <Object?>[
      <String, Object?>{
        'publicProject': <String, Object?>{
          'projectId': projectId,
          'projectNo': 'PROJ-1',
          'title': '展会项目 1',
          'buildingType': 'exhibition',
          'budgetAmount': 1200,
          'state': projectState,
          'summary': _summary('my-project'),
        },
        'privateSummary': <String, Object?>{
          'hasAcceptedOrder': orderStatus != null,
          'orderStatus': orderStatus,
          'contractStatus': orderStatus == null ? null : 'active',
          'fulfillmentStatus': null,
          'acceptanceStatus': null,
          'afterSalesOrDisputeStatus': null,
          'formalCompletionStatus': 'not_formally_completed',
          'evaluationStatus': 'not_eligible',
        },
      },
    ],
    'historicalProjects': <Object?>[],
  };
}

ExhibitionMobileApp _buildApp({
  required String initialRoute,
  required FakeAppApiTransport transport,
  List<String> roleKeys = const <String>['buyer_admin'],
}) {
  final sessionStore = AppSessionStore()
    ..establishSession(
      accessToken: 'bid-award-access',
      refreshToken: 'bid-award-refresh',
      expiresInSeconds: 3600,
      deviceId: 'bid-award-device',
    );

  return ExhibitionMobileApp(
    initialRoute: initialRoute,
    bootstrapShellContext: AppShellContextData(
      userId: 'user-1',
      organizationId: 'org-1',
      roleKeys: roleKeys,
      certificationStatus: 'approved',
      membershipStatus: 'active',
      visibleBuildings: const <String>['exhibition', 'messages', 'profile'],
    ),
    sessionStore: sessionStore,
    exhibitionConsumerLayer: ExhibitionConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: transport,
      ),
    ),
  );
}

Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'buyer award entry is no longer exposed from my-project detail after cleanup',
    (WidgetTester tester) async {
      var myProjectDetailRequestCount = 0;

      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/my/projects/project-1':
                  (AppApiRequest request) async {
                    myProjectDetailRequestCount += 1;
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _myProjectDetailPayload(
                        projectId: 'project-1',
                        state: myProjectDetailRequestCount == 1
                            ? 'bidding_closed'
                            : 'converted_to_order',
                        hasAcceptedOrder: myProjectDetailRequestCount > 1,
                        orderStatus: myProjectDetailRequestCount > 1
                            ? 'active'
                            : null,
                        contractStatus: myProjectDetailRequestCount > 1
                            ? 'active'
                            : null,
                      ),
                    );
                  },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          initialRoute: ExhibitionRoutes.myProjectDetailWithProjectId(
            'project-1',
          ),
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('路由不可用'), findsNothing);
      expect(find.text('继续最小定标'), findsNothing);
      expect(
        find.byKey(const ValueKey<String>('bid_award_submit_button')),
        findsNothing,
      );
      expect(myProjectDetailRequestCount, 1);
    },
  );

  testWidgets(
    'supplier result read is reachable on the reused bid submit route and refreshes project detail and my-project',
    (WidgetTester tester) async {
      var projectDetailRefreshCount = 0;
      var myProjectListRefreshCount = 0;

      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/bid/result': (AppApiRequest request) async {
                expect(request.uri.queryParameters['projectId'], 'project-1');
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'bidId': 'bid-1',
                    'projectId': 'project-1',
                    'state': 'awarded',
                    'result': 'won',
                    'reasonCode': 'commercial_fit',
                    'reasonText': '综合报价与交付能力最优',
                    'decidedAt': '2026-04-12T10:00:00Z',
                  },
                );
              },
              'GET /api/app/project/detail': (AppApiRequest request) async {
                projectDetailRefreshCount += 1;
                expect(request.uri.queryParameters['projectId'], 'project-1');
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _publicProjectDetail(
                    projectId: 'project-1',
                    state: 'converted_to_order',
                    viewerProjectRelation: 'non_owner',
                  ),
                );
              },
              'GET /api/app/my/projects': (AppApiRequest request) async {
                myProjectListRefreshCount += 1;
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _myProjectListPayload(
                    projectId: 'project-1',
                    projectState: 'converted_to_order',
                    orderStatus: 'active',
                  ),
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          initialRoute: ExhibitionRoutes.bidResultWithProjectId('project-1'),
          transport: transport,
          roleKeys: const <String>['supplier_admin'],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('竞标结果'), findsWidgets);
      await _scrollTo(tester, find.textContaining('当前竞标 ID：bid-1'));
      expect(find.textContaining('当前项目 ID：project-1'), findsOneWidget);
      expect(find.textContaining('原因编码：commercial_fit'), findsOneWidget);
      expect(find.textContaining('原因说明：综合报价与交付能力最优'), findsOneWidget);
      expect(find.textContaining('裁决时间：2026-04-12T10:00:00Z'), findsOneWidget);
      expect(projectDetailRefreshCount, 2);
      expect(myProjectListRefreshCount, 1);
      expect(find.text('路由不可用'), findsNothing);
    },
  );

  testWidgets(
    'supplier result unavailable is consumed as a controlled load error without raw path leakage',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
          'GET /api/app/project/detail': (AppApiRequest request) async {
            return AppApiResponse(
              statusCode: 200,
              uri: request.uri,
              body: _projectPayload(
                projectId: 'project-1',
                state: 'converted_to_order',
              ),
            );
          },
          'GET /api/app/bid/result': (AppApiRequest request) async {
            return AppApiResponse(
              statusCode: 409,
              uri: request.uri,
              body: const <String, Object?>{
                'errorCode': 'BID_RESULT_UNAVAILABLE',
                'message':
                    'upstream GET /api/app/bid/result is unavailable with stack trace',
              },
            );
          },
        },
      );

      await tester.pumpWidget(
        _buildApp(
          initialRoute: ExhibitionRoutes.bidResultWithProjectId('project-1'),
          transport: transport,
          roleKeys: const <String>['supplier_admin'],
        ),
      );
      await tester.pumpAndSettle();

      final controlledError = find.textContaining('当前竞标结果暂未开放读取');
      await _scrollTo(tester, controlledError);
      expect(controlledError, findsOneWidget);
      expect(find.textContaining('/api/app/bid/result'), findsNothing);
      expect(find.textContaining('stack trace'), findsNothing);
    },
  );
}
