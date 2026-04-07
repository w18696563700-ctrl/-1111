import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_consumer_layer.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/shell/shell_app.dart';

void main() {
  tearDown(() {
    EnterpriseHubConsumerLayer.reset();
  });

  testWidgets('enterprise company list route renders formal list skeleton', (
    WidgetTester tester,
  ) async {
    EnterpriseHubConsumerLayer.install(
      EnterpriseHubConsumerLayer(
        client: AppApiClient(
          transport: FakeAppApiTransport(
            handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/exhibition/enterprise-hub/enterprises':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'recommended': <Object?>[],
                        'items': <Object?>[
                          <String, Object?>{
                            'enterpriseId': 'ent-company-1',
                            'boardType': 'company',
                            'name': '西南会展搭建有限公司',
                            'provinceName': '四川',
                            'cityName': '成都',
                            'primaryBoardLabel': '优秀公司',
                            'secondaryCapabilityLabels': <String>['主场服务'],
                            'shortIntro': '承接展台搭建与活动执行。',
                            'certificationLabel': '已认证',
                            'caseCount': 12,
                            'boardHighlights': <String, Object?>{
                              'company': <String, Object?>{
                                'exhibitionTypes': <String>['特装展台'],
                              },
                            },
                          },
                        ],
                        'pagination': <String, Object?>{
                          'page': 1,
                          'pageSize': 10,
                          'total': 1,
                          'hasMore': false,
                        },
                      },
                    );
                  },
              'GET /api/app/exhibition/enterprise-hub/recommendations':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'boardType': 'company',
                        'items': <Object?>[],
                      },
                    );
                  },
            },
          ),
        ),
      ),
    );

    await tester.pumpWidget(
      ExhibitionMobileApp(initialRoute: ExhibitionRoutes.companies),
    );
    await tester.pumpAndSettle();

    expect(find.text('搜索框'), findsOneWidget);
    expect(find.text('筛选区'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('排序区'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('排序区'), findsOneWidget);
    expect(find.text('推荐位区'), findsOneWidget);
    expect(find.text('企业卡片列表'), findsOneWidget);
    expect(find.text('西南会展搭建有限公司'), findsOneWidget);
  });

  testWidgets('enterprise company list renders empty state from frozen list payload', (
    WidgetTester tester,
  ) async {
    EnterpriseHubConsumerLayer.install(
      EnterpriseHubConsumerLayer(
        client: AppApiClient(
          transport: FakeAppApiTransport(
            handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/exhibition/enterprise-hub/enterprises':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'recommended': <Object?>[],
                        'items': <Object?>[],
                        'pagination': <String, Object?>{
                          'page': 1,
                          'pageSize': 10,
                          'total': 0,
                          'hasMore': false,
                        },
                      },
                    );
                  },
              'GET /api/app/exhibition/enterprise-hub/recommendations':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'boardType': 'company',
                        'items': <Object?>[],
                      },
                    );
                  },
            },
          ),
        ),
      ),
    );

    await tester.pumpWidget(
      ExhibitionMobileApp(initialRoute: ExhibitionRoutes.companies),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('企业卡片列表'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('当前条件下没有企业卡片。'), findsOneWidget);
  });

  testWidgets('enterprise company list renders controlled 403 state', (
    WidgetTester tester,
  ) async {
    EnterpriseHubConsumerLayer.install(
      EnterpriseHubConsumerLayer(
        client: AppApiClient(
          transport: FakeAppApiTransport(
            handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/exhibition/enterprise-hub/enterprises':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 403,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'message': '当前 actor 范围未开放 company 列表。',
                      },
                    );
                  },
              'GET /api/app/exhibition/enterprise-hub/recommendations':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'boardType': 'company',
                        'items': <Object?>[],
                      },
                    );
                  },
            },
          ),
        ),
      ),
    );

    await tester.pumpWidget(
      ExhibitionMobileApp(initialRoute: ExhibitionRoutes.companies),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('企业卡片列表'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('当前 actor 范围未开放 company 列表。'), findsOneWidget);
  });

  testWidgets('enterprise detail route renders unified detail sections', (
    WidgetTester tester,
  ) async {
    EnterpriseHubConsumerLayer.install(
      EnterpriseHubConsumerLayer(
        client: AppApiClient(
          transport: FakeAppApiTransport(
            handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/exhibition/enterprise-hub/enterprises/ent-company-1':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'header': <String, Object?>{
                          'enterpriseId': 'ent-company-1',
                          'name': '西南会展搭建有限公司',
                          'primaryBoardType': 'company',
                          'secondaryCapabilities': <String>['supplier'],
                          'shortIntro': '主打特装展台与活动执行。',
                          'provinceName': '四川',
                          'cityName': '成都',
                        },
                        'basicInfo': <String, Object?>{
                          'fullIntro': '完整介绍',
                        },
                        'boardProfile': <String, Object?>{
                          'exhibitionTypes': <String>['特装展台'],
                          'serviceItems': <String>['设计', '搭建'],
                          'serviceCities': <String>['成都'],
                        },
                        'serviceAreas': <Object?>[
                          <String, Object?>{'provinceName': '四川', 'cityName': '成都'},
                        ],
                        'cases': <Object?>[
                          <String, Object?>{
                            'id': 'case-1',
                            'title': '糖酒会主场案例',
                            'summary': '案例摘要',
                            'caseStatus': 'approved',
                          },
                        ],
                        'certifications': <Object?>[
                          <String, Object?>{
                            'type': 'business',
                            'name': '营业执照',
                            'status': 'approved',
                          },
                        ],
                        'reviewSummary': <String, Object?>{
                          'keywordTags': <String>['交付稳定'],
                        },
                        'contacts': <Object?>[
                          <String, Object?>{
                            'contactName': '李经理',
                          },
                        ],
                      },
                    );
                  },
            },
          ),
        ),
      ),
    );

    await tester.pumpWidget(
      ExhibitionMobileApp(
        initialRoute: ExhibitionRoutes.companyDetailWithEnterpriseId(
          'ent-company-1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('header'), findsOneWidget);
    expect(find.text('basicInfo'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('boardProfile'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('boardProfile'), findsOneWidget);
    expect(find.text('serviceAreas'), findsOneWidget);
    expect(find.text('cases'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('certifications'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('certifications'), findsOneWidget);
    expect(find.text('reviewSummary'), findsOneWidget);
    expect(find.text('contacts'), findsOneWidget);
  });

  testWidgets('enterprise detail route renders controlled 404 state', (
    WidgetTester tester,
  ) async {
    EnterpriseHubConsumerLayer.install(
      EnterpriseHubConsumerLayer(
        client: AppApiClient(
          transport: FakeAppApiTransport(
            handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/exhibition/enterprise-hub/enterprises/ent-missing':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 404,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'message': '当前企业不存在或已下线。',
                      },
                    );
                  },
            },
          ),
        ),
      ),
    );

    await tester.pumpWidget(
      ExhibitionMobileApp(
        initialRoute: ExhibitionRoutes.companyDetailWithEnterpriseId(
          'ent-missing',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('当前企业不存在或已下线。'), findsOneWidget);
  });

  testWidgets('enterprise apply route remains reachable', (
    WidgetTester tester,
  ) async {
    final shellContext = AppShellContextData(
      userId: 'user-1',
      organizationId: 'org-1',
      certificationStatus: 'verified',
      visibleBuildings: const <String>['exhibition', 'messages', 'profile'],
    );

    await tester.pumpWidget(
      ExhibitionMobileApp(
        initialRoute: ExhibitionRoutes.enterpriseApplyWithBoardType('company'),
        bootstrapShellContext: shellContext,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('企业入驻页'), findsOneWidget);
    expect(find.text('basic'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('boardProfile'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('boardProfile'), findsOneWidget);
    expect(find.text('cases'), findsOneWidget);
  });

  testWidgets('enterprise status route remains reachable', (
    WidgetTester tester,
  ) async {
    EnterpriseHubConsumerLayer.install(
      EnterpriseHubConsumerLayer(
        client: AppApiClient(
          transport: FakeAppApiTransport(
            handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/exhibition/enterprise-hub/applications/app-1':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'applicationId': 'app-1',
                        'enterpriseId': 'ent-company-1',
                        'applyBoardType': 'company',
                        'applicationStatus': 'submitted',
                      },
                    );
                  },
            },
          ),
        ),
      ),
    );

    final shellContext = AppShellContextData(
      userId: 'user-1',
      organizationId: 'org-1',
      certificationStatus: 'verified',
      visibleBuildings: const <String>['exhibition', 'messages', 'profile'],
    );

    await tester.pumpWidget(
      ExhibitionMobileApp(
        initialRoute: ExhibitionRoutes.enterpriseApplicationStatusWithId(
          'app-1',
          boardType: 'company',
        ),
        bootstrapShellContext: shellContext,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('状态：submitted'), findsOneWidget);
  });

  testWidgets('enterprise status route renders controlled 404 state', (
    WidgetTester tester,
  ) async {
    EnterpriseHubConsumerLayer.install(
      EnterpriseHubConsumerLayer(
        client: AppApiClient(
          transport: FakeAppApiTransport(
            handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/exhibition/enterprise-hub/applications/app-404':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 404,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'message': '当前申请单不存在或不在 actor scope 内。',
                      },
                    );
                  },
            },
          ),
        ),
      ),
    );

    final shellContext = AppShellContextData(
      userId: 'user-1',
      organizationId: 'org-1',
      certificationStatus: 'verified',
      visibleBuildings: const <String>['exhibition', 'messages', 'profile'],
    );

    await tester.pumpWidget(
      ExhibitionMobileApp(
        initialRoute: ExhibitionRoutes.enterpriseApplicationStatusWithId(
          'app-404',
          boardType: 'company',
        ),
        bootstrapShellContext: shellContext,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('当前申请单不存在或不在 actor scope 内。'), findsOneWidget);
  });
}
