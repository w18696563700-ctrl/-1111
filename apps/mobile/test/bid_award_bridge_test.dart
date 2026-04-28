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
  List<Object?> bidCandidates = const <Object?>[],
  Map<String, Object?>? bidSelection,
  Map<String, Object?>? orderSummary,
}) {
  final payload = <String, Object?>{
    'projectId': projectId,
    'projectNo': 'PROJ-1',
    'title': '展会项目 1',
    'buildingType': 'exhibition',
    'budgetAmount': 1200,
    'state': state,
    'viewerProjectRelation': viewerProjectRelation,
    if (bidCandidates.isNotEmpty) 'bidCandidates': bidCandidates,
    'summary': _summary('project'),
  };
  if (bidSelection != null) {
    payload['bidSelection'] = bidSelection;
  }
  if (orderSummary != null) {
    payload['orderSummary'] = orderSummary;
  }
  return payload;
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

Map<String, Object?> _orderSummaryPayload({
  String state = 'active',
  String completionRequestState = 'none',
}) {
  return <String, Object?>{
    'orderId': 'order-1',
    'projectId': 'project-1',
    'buyerOrganizationId': 'buyer-org',
    'sellerOrganizationId': 'org-1',
    'state': state,
    'completionRequestState': completionRequestState,
  };
}

Map<String, Object?> _orderDetailPayload({
  String state = 'active',
  String completionRequestState = 'none',
}) {
  return <String, Object?>{
    'orderId': 'order-1',
    'orderNo': 'ORD-1',
    'projectId': 'project-1',
    'bidId': 'bid-1',
    'buyerOrganizationId': 'buyer-org',
    'sellerOrganizationId': 'org-1',
    'state': state,
    'completionRequestState': completionRequestState,
    'summary': _summary('order'),
    'milestones': const <Object?>[],
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
      personalCertificationStatus: 'approved',
      personalCertificationQualified: true,
      personalCertificationLockedToOtherActor: false,
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
  await tester.pumpAndSettle();
  if (finder.evaluate().isNotEmpty) {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    return;
  }
  for (final offset in const <Offset>[
    Offset(0, -320),
    Offset(0, 320),
    Offset(0, -320),
  ]) {
    for (var i = 0; i < 12 && finder.evaluate().isEmpty; i += 1) {
      final scrollable = find.byType(Scrollable);
      if (scrollable.evaluate().isEmpty) {
        return;
      }
      await tester.drag(scrollable.first, offset);
      await tester.pumpAndSettle();
    }
    if (finder.evaluate().isNotEmpty) {
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
      return;
    }
  }
}

void main() {
  testWidgets(
    'project detail order status card lets seller request completion from orderSummary',
    (WidgetTester tester) async {
      var requestCount = 0;
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/project/detail': (AppApiRequest request) async {
                expect(request.uri.queryParameters['projectId'], 'project-1');
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _publicProjectDetail(
                    projectId: 'project-1',
                    state: 'converted_to_order',
                    viewerProjectRelation: 'non_owner',
                    orderSummary: _orderSummaryPayload(
                      completionRequestState: requestCount == 0
                          ? 'none'
                          : 'requested',
                    ),
                  ),
                );
              },
              'GET /api/app/order/detail': (AppApiRequest request) async {
                expect(request.uri.queryParameters['orderId'], 'order-1');
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _orderDetailPayload(
                    completionRequestState: requestCount == 0
                        ? 'none'
                        : 'requested',
                  ),
                );
              },
              'POST /api/app/order/complete/request':
                  (AppApiRequest request) async {
                    requestCount += 1;
                    expect(request.body, const <String, Object?>{
                      'orderId': 'order-1',
                      'note': '承接方申请当前订单完工，请发布方确认。',
                    });
                    return AppApiResponse(
                      statusCode: 202,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'orderId': 'order-1',
                        'projectId': 'project-1',
                        'state': 'active',
                        'completionRequestState': 'requested',
                        'summary': <String, Object?>{'heading': '已申请完工'},
                      },
                    );
                  },
              'GET /api/app/my/projects': (AppApiRequest request) async {
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
          initialRoute: ExhibitionRoutes.projectDetailWithProjectId(
            'project-1',
          ),
          transport: transport,
          roleKeys: const <String>['supplier_admin'],
        ),
      );
      await tester.pumpAndSettle();

      await _scrollTo(tester, find.text('完工处理'));
      await _scrollTo(tester, find.text('申请完工'));
      expect(find.text('申请完工'), findsOneWidget);
      expect(find.text('确认完成'), findsNothing);

      await tester.tap(find.text('申请完工'));
      await tester.pumpAndSettle();

      expect(requestCount, 1);
      expect(find.text('已申请完工'), findsWidgets);
    },
  );

  testWidgets(
    'order completion invalid state is shown as controlled copy without raw leakage',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
          'GET /api/app/project/detail': (AppApiRequest request) async {
            expect(request.uri.queryParameters['projectId'], 'project-1');
            return AppApiResponse(
              statusCode: 200,
              uri: request.uri,
              body: _publicProjectDetail(
                projectId: 'project-1',
                state: 'converted_to_order',
                viewerProjectRelation: 'non_owner',
                orderSummary: _orderSummaryPayload(),
              ),
            );
          },
          'GET /api/app/order/detail': (AppApiRequest request) async {
            expect(request.uri.queryParameters['orderId'], 'order-1');
            return AppApiResponse(
              statusCode: 200,
              uri: request.uri,
              body: _orderDetailPayload(),
            );
          },
          'POST /api/app/order/complete/request': (AppApiRequest request) async {
            return AppApiResponse(
              statusCode: 409,
              uri: request.uri,
              body: const <String, Object?>{
                'errorCode': 'PROJECT_ORDER_COMPLETE_INVALID_STATE',
                'message':
                    'upstream POST /api/app/order/complete/request invalid state stack trace',
              },
            );
          },
        },
      );

      await tester.pumpWidget(
        _buildApp(
          initialRoute: ExhibitionRoutes.projectDetailWithProjectId(
            'project-1',
          ),
          transport: transport,
          roleKeys: const <String>['supplier_admin'],
        ),
      );
      await tester.pumpAndSettle();

      await _scrollTo(tester, find.text('完工处理'));
      await _scrollTo(tester, find.text('申请完工'));
      await tester.tap(find.text('申请完工'));
      await tester.pumpAndSettle();

      await _scrollTo(tester, find.textContaining('当前订单状态暂不支持这个完工动作'));
      expect(find.textContaining('当前订单状态暂不支持这个完工动作'), findsOneWidget);
      expect(
        find.textContaining('/api/app/order/complete/request'),
        findsNothing,
      );
      expect(find.textContaining('stack trace'), findsNothing);
    },
  );

  testWidgets(
    'owner project detail selects one bid candidate through select-bid-and-create-order',
    (WidgetTester tester) async {
      var projectDetailRequestCount = 0;
      var myProjectListRequestCount = 0;
      var selectionRequestCount = 0;
      Map<String, Object?>? capturedSelectionBody;

      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/project/detail': (AppApiRequest request) async {
                projectDetailRequestCount += 1;
                expect(request.uri.queryParameters['projectId'], 'project-1');
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _publicProjectDetail(
                    projectId: 'project-1',
                    state: projectDetailRequestCount == 1
                        ? 'published'
                        : 'converted_to_order',
                    viewerProjectRelation: 'owner',
                    bidCandidates: projectDetailRequestCount == 1
                        ? const <Object?>[
                            <String, Object?>{
                              'bidId': 'bid-1',
                              'bidNo': 'BID-1',
                              'bidderOrganizationId': 'factory-1',
                              'bidderOrganizationName': '重庆海川展览工厂',
                              'quoteAmount': 118000,
                              'proposalSummary': '综合报价与交付能力匹配。',
                              'state': 'submitted',
                              'submittedAt': '2026-05-20T10:00:00Z',
                            },
                          ]
                        : const <Object?>[],
                    orderSummary: projectDetailRequestCount == 1
                        ? null
                        : _orderSummaryPayload(),
                  ),
                );
              },
              'GET /api/app/order/detail': (AppApiRequest request) async {
                expect(request.uri.queryParameters['orderId'], 'order-1');
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'orderId': 'order-1',
                    'orderNo': 'ORD-1',
                    'projectId': 'project-1',
                    'bidId': 'bid-1',
                    'buyerOrganizationId': 'org-1',
                    'sellerOrganizationId': 'seller-org',
                    'state': 'active',
                    'completionRequestState': 'none',
                    'summary': <String, Object?>{'heading': 'order'},
                    'milestones': <Object?>[],
                  },
                );
              },
              'POST /api/app/bid/select-bid-and-create-order':
                  (AppApiRequest request) async {
                    selectionRequestCount += 1;
                    capturedSelectionBody =
                        request.body as Map<String, Object?>?;
                    return AppApiResponse(
                      statusCode: 202,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'bidAwardId': 'award-1',
                        'projectId': 'project-1',
                        'winningBidId': 'bid-1',
                        'orderId': 'order-1',
                        'contractId': 'contract-1',
                        'state': 'converted_to_order',
                        'actionKey': 'bid_select_create_order.submit',
                        'routeTarget': <String, Object?>{
                          'objectType': 'order',
                          'actionKey': 'order_detail.open',
                          'canonicalPath': '/api/app/order/detail',
                          'params': <String, Object?>{
                            'orderId': 'order-1',
                            'projectId': 'project-1',
                          },
                        },
                      },
                    );
                  },
              'GET /api/app/my/projects': (AppApiRequest request) async {
                myProjectListRequestCount += 1;
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
          initialRoute: ExhibitionRoutes.projectDetailWithProjectId(
            'project-1',
          ),
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      await _scrollTo(tester, find.text('发布方选择合作方'));
      expect(find.text('重庆海川展览工厂'), findsOneWidget);
      await _scrollTo(tester, find.widgetWithText(OutlinedButton, '进入沟通'));
      expect(find.widgetWithText(OutlinedButton, '进入沟通'), findsOneWidget);
      await _scrollTo(tester, find.widgetWithText(FilledButton, '选择为合作方'));
      await tester.tap(find.widgetWithText(FilledButton, '选择为合作方'));
      await tester.pumpAndSettle();

      expect(find.text('确认选择合作方'), findsWidgets);
      await tester.tap(
        find.byKey(const ValueKey<String>('project_bid_select_submit')),
      );
      await tester.pumpAndSettle();

      expect(selectionRequestCount, 1);
      expect(capturedSelectionBody, <String, Object?>{
        'projectId': 'project-1',
        'winningBidId': 'bid-1',
        'reasonCode': 'publisher_selected_partner',
        'reasonText': '发布方选择该竞标方作为当前项目合作方。',
      });
      expect(projectDetailRequestCount, 2);
      expect(myProjectListRequestCount, 1);
      expect(find.text('合作方选择已受理'), findsOneWidget);
      await _scrollTo(tester, find.text('完工处理'));
      expect(find.text('完工处理'), findsOneWidget);
      expect(find.text('订单状态：进行中'), findsWidgets);
    },
  );

  testWidgets(
    'duplicate bid selection is shown as controlled copy without raw leakage',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
          'GET /api/app/project/detail': (AppApiRequest request) async {
            expect(request.uri.queryParameters['projectId'], 'project-1');
            return AppApiResponse(
              statusCode: 200,
              uri: request.uri,
              body: _publicProjectDetail(
                projectId: 'project-1',
                state: 'published',
                viewerProjectRelation: 'owner',
                bidCandidates: const <Object?>[
                  <String, Object?>{
                    'bidId': 'bid-1',
                    'bidNo': 'BID-1',
                    'bidderOrganizationId': 'factory-1',
                    'bidderOrganizationName': '重庆海川展览工厂',
                    'quoteAmount': 118000,
                    'proposalSummary': '综合报价与交付能力匹配。',
                    'state': 'submitted',
                    'submittedAt': '2026-05-20T10:00:00Z',
                  },
                ],
              ),
            );
          },
          'POST /api/app/bid/select-bid-and-create-order':
              (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 409,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'errorCode': 'BID_AWARD_DUPLICATE',
                    'message':
                        'upstream POST /api/app/bid/select-bid-and-create-order duplicate stack trace',
                  },
                );
              },
        },
      );

      await tester.pumpWidget(
        _buildApp(
          initialRoute: ExhibitionRoutes.projectDetailWithProjectId(
            'project-1',
          ),
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      await _scrollTo(tester, find.text('发布方选择合作方'));
      await _scrollTo(tester, find.widgetWithText(FilledButton, '选择为合作方'));
      await tester.tap(find.widgetWithText(FilledButton, '选择为合作方'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey<String>('project_bid_select_submit')),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('当前项目已经处理过定标'), findsOneWidget);
      expect(
        find.textContaining('/api/app/bid/select-bid-and-create-order'),
        findsNothing,
      );
      expect(find.textContaining('stack trace'), findsNothing);
    },
  );

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

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      expect(find.text('竞标结果'), findsWidgets);
      await _scrollTo(tester, find.textContaining('当前项目 ID：project-1'));
      expect(find.textContaining('当前项目 ID：project-1'), findsWidgets);
      await _scrollTo(tester, find.textContaining('当前竞标 ID：bid-1'));
      expect(find.textContaining('当前竞标 ID：bid-1'), findsOneWidget);
      await _scrollTo(tester, find.textContaining('原因编码：commercial_fit'));
      expect(find.textContaining('原因编码：commercial_fit'), findsOneWidget);
      await _scrollTo(tester, find.textContaining('原因说明：综合报价与交付能力最优'));
      expect(find.textContaining('原因说明：综合报价与交付能力最优'), findsOneWidget);
      await _scrollTo(tester, find.textContaining('裁决时间：2026-04-12T10:00:00Z'));
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
