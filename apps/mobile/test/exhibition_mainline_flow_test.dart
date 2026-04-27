import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/boot/app_shell_context_consumer.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/exhibition/presentation/exhibition_trade_pages.dart';
import 'package:mobile/features/messages/data/messages_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_consumer_layer.dart';
import 'package:mobile/shell/shell_app.dart';

Map<String, Object?> _summary([String heading = 'summary']) {
  return <String, Object?>{'heading': heading};
}

Map<String, Object?> _projectPayload({
  required String projectId,
  String projectNo = 'PROJ-1',
  String title = '展览项目',
  String buildingType = 'exhibition',
  num budgetAmount = 1000,
  String viewerProjectRelation = 'non_owner',
  String state = 'published',
  String summaryHeading = 'project',
  String? provinceName,
  String? cityName,
  String? districtName,
  String? detailAddress,
  String? scopeSummary,
  String? plannedStartAt,
  String? plannedEndAt,
}) {
  return <String, Object?>{
    'projectId': projectId,
    'projectNo': projectNo,
    'title': title,
    'buildingType': buildingType,
    'budgetAmount': budgetAmount,
    if (provinceName case final String value) 'provinceName': value,
    if (cityName case final String value) 'cityName': value,
    if (districtName case final String value) 'districtName': value,
    if (detailAddress case final String value) 'detailAddress': value,
    if (scopeSummary case final String value) 'scopeSummary': value,
    if (plannedStartAt case final String value) 'plannedStartAt': value,
    if (plannedEndAt case final String value) 'plannedEndAt': value,
    'viewerProjectRelation': viewerProjectRelation,
    'state': state,
    'summary': _summary(summaryHeading),
  };
}

ExhibitionMobileApp _buildApp({
  String initialRoute = '/',
  required FakeAppApiTransport transport,
  ExhibitionConsumerLayer? exhibitionConsumerLayer,
  AppSessionStore? sessionStore,
  AppShellContextConsumer? shellContextConsumer,
}) {
  return ExhibitionMobileApp(
    initialRoute: initialRoute,
    shellContextConsumer: shellContextConsumer,
    exhibitionConsumerLayer:
        exhibitionConsumerLayer ??
        ExhibitionConsumerLayer(
          client: AppApiClient(
            config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
            transport: transport,
          ),
        ),
    messagesConsumerLayer: MessagesConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers:
              <
                String,
                Future<AppApiResponse> Function(AppApiRequest request)
              >{},
        ),
      ),
    ),
    profileConsumerLayer: ProfileConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers:
              <
                String,
                Future<AppApiResponse> Function(AppApiRequest request)
              >{},
        ),
      ),
    ),
    sessionStore: sessionStore,
  );
}

AppSessionStore _buildAuthenticatedSessionStore({required String deviceId}) {
  final sessionStore = AppSessionStore();
  sessionStore.establishSession(
    accessToken: 'token-$deviceId',
    refreshToken: 'refresh-$deviceId',
    expiresInSeconds: 3600,
    deviceId: deviceId,
  );
  return sessionStore;
}

AppShellContextConsumer _buildShellContextConsumer({
  String? organizationId = 'org-1',
  List<String> roleKeys = const <String>['supplier_admin'],
  String? certificationStatus = 'verified',
  String? personalCertificationStatus = 'approved',
  bool? personalCertificationQualified = true,
  bool? personalCertificationLockedToOtherActor = false,
  bool? canCreateProject = true,
  Future<AppApiResponse> Function(AppApiRequest request)? shellContextHandler,
}) {
  return AppShellContextConsumer(
    client: AppApiClient(
      config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
      transport: FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/shell/context':
                  shellContextHandler ??
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: <String, Object?>{
                        'userId': 'mainline-user-1',
                        'organizationId': organizationId,
                        'roleKeys': roleKeys,
                        'certificationStatus': certificationStatus,
                        'personalCertificationStatus':
                            personalCertificationStatus,
                        'personalCertificationQualified':
                            personalCertificationQualified,
                        'personalCertificationLockedToOtherActor':
                            personalCertificationLockedToOtherActor,
                        'membershipStatus': 'active',
                        if (canCreateProject case final bool value)
                          'projectCreateEligibility': <String, Object?>{
                            'canCreateProject': value,
                          },
                        'visibleBuildings': const <String>[
                          'exhibition',
                          'messages',
                          'profile',
                        ],
                        'featureFlagsVersion': 'ffv-20260328',
                        'unreadSummary': const <String, Object?>{},
                      },
                    );
                  },
            },
      ),
    ),
  );
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  Future<void> pumpFrames([int times = 6]) async {
    for (var index = 0; index < times; index += 1) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await pumpFrames();
  await tester.ensureVisible(finder);
  await pumpFrames();
  await tester.tap(finder, warnIfMissed: false);
  await pumpFrames(12);
}

Future<void> _expandBidSubmitFlowIfNeeded(WidgetTester tester) async {
  final continueFinder = find.byWidgetPredicate(
    (Widget widget) =>
        widget is FilledButton &&
        widget.child is Text &&
        (widget.child as Text).data == '继续竞标',
    description: 'FilledButton("继续竞标")',
  );
  if (continueFinder.evaluate().isEmpty) {
    return;
  }

  await tester.scrollUntilVisible(
    continueFinder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  tester.widget<FilledButton>(continueFinder).onPressed!.call();
  await tester.pump();
  await tester.pumpAndSettle();
}

Future<void> _enterVisibleBidTextField(
  WidgetTester tester, {
  required String label,
  required String value,
}) async {
  await _expandBidSubmitFlowIfNeeded(tester);
  final fieldFinder = find.widgetWithText(TextField, label);
  await tester.scrollUntilVisible(
    fieldFinder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.enterText(fieldFinder, value);
}

Future<void> _uploadBidAttachment(WidgetTester tester, String label) async {
  await _expandBidSubmitFlowIfNeeded(tester);
  await _tapVisible(tester, find.widgetWithText(FilledButton, '上传$label'));
}

Finder _projectCreateField(String label) {
  final key = switch (label) {
    '项目名称' => 'project-create-title',
    '品牌' => 'project-create-brand-name',
    '项目类型' => 'project-create-building-type',
    '类型备注（选填）' => 'project-create-building-type-remark',
    '预算金额' => 'project-create-budget-amount',
    '项目面积' => 'project-create-area-sqm',
    '省' => 'project-create-province',
    '市' => 'project-create-city',
    '区/县' => 'project-create-district',
    '详细地址' => 'project-create-detail-address',
    '范围说明' => 'project-create-scope-summary',
    '计划开始日期' => 'project-create-planned-start-at',
    '计划结束日期' => 'project-create-planned-end-at',
    '补充说明' => 'project-create-description',
    _ => throw ArgumentError('Unknown project create field: $label'),
  };
  return find.byKey(ValueKey<String>(key));
}

Map<String, Object?> _expectedProjectCreateBody({
  required String title,
  required String brandName,
  required double budgetAmount,
}) {
  return <String, Object?>{
    'title': '$title - $brandName',
    'exhibitionName': title,
    'brandName': brandName,
    'buildingType': 'exhibition',
    'budgetAmount': budgetAmount,
    'provinceCode': '510000',
    'provinceName': '四川',
    'cityCode': '510100',
    'cityName': '成都',
    'districtCode': '510107',
    'districtName': '武侯区',
    'detailAddress': '世纪城新国际会展中心 6 号馆西门',
    'scopeSummary': '主舞台、医疗器械展区与灯光联动区进场搭建',
    'plannedStartAt': '2026-04-10',
    'plannedEndAt': '2026-04-18',
  };
}

void main() {
  testWidgets('create entry hands off into stripped project create page', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/project/list': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: const <String, Object?>{'items': <Object?>[]},
              );
            },
            'POST /api/app/project/create': (AppApiRequest request) async {
              expect(
                request.body,
                _expectedProjectCreateBody(
                  title: '首发演示项目',
                  brandName: '迈德瑞',
                  budgetAmount: 1800,
                ),
              );
              return AppApiResponse(
                statusCode: 202,
                uri: request.uri,
                body: const <String, Object?>{'projectId': 'project-created'},
              );
            },
            'GET /api/app/project/detail': (AppApiRequest request) async {
              expect(
                request.uri.queryParameters['projectId'],
                'project-created',
              );
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _projectPayload(
                  projectId: 'project-created',
                  projectNo: 'PROJ-CREATED',
                  title: '首发演示项目',
                  budgetAmount: 1800,
                ),
              );
            },
          },
    );

    await tester.pumpWidget(
      _buildApp(
        initialRoute: ExhibitionRoutes.projectCreate,
        transport: transport,
        sessionStore: _buildAuthenticatedSessionStore(deviceId: 'mainline-1'),
        shellContextConsumer: _buildShellContextConsumer(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('创建项目'), findsWidgets);
    expect(find.text('基础信息'), findsOneWidget);
    expect(find.text('第二步 地址与范围'), findsNothing);
    expect(find.text('第三步 文件资料'), findsNothing);
    expect(find.text('第四步 文字说明与 AI 辅助'), findsNothing);
    expect(find.text('第五步 预览、支付与一键发布'), findsNothing);
    expect(_projectCreateField('项目名称'), findsOneWidget);
    expect(_projectCreateField('项目类型'), findsOneWidget);
    expect(_projectCreateField('预算金额'), findsOneWidget);
    await tester.scrollUntilVisible(
      _projectCreateField('省'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(_projectCreateField('省'), findsOneWidget);
    expect(_projectCreateField('市'), findsOneWidget);
    expect(_projectCreateField('区/县'), findsOneWidget);
    expect(_projectCreateField('详细地址'), findsOneWidget);
    expect(_projectCreateField('范围说明'), findsOneWidget);
    expect(find.text('添加范围说明'), findsOneWidget);
    await tester.scrollUntilVisible(
      _projectCreateField('计划结束日期'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(_projectCreateField('计划开始日期'), findsOneWidget);
    expect(_projectCreateField('计划结束日期'), findsOneWidget);
    expect(find.byTooltip('选择计划开始日期'), findsOneWidget);
    expect(find.byTooltip('选择计划结束日期'), findsOneWidget);
    expect(find.text('补充说明与附件', skipOffstage: false), findsNothing);
    expect(_projectCreateField('补充说明'), findsNothing);
    expect(find.text('资料补充', skipOffstage: false), findsNothing);
  });

  test(
    'project create success keeps my-project continuation payload ready',
    () async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'POST /api/app/project/create': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 202,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'projectId': 'project-created',
                    'state': 'draft',
                  },
                );
              },
              'GET /api/app/my/projects': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'ongoingProjects': <Object?>[
                      <String, Object?>{
                        'publicProject': <String, Object?>{
                          'projectId': 'project-created',
                          'projectNo': 'MY-NEW-1',
                          'title': '发布成功项目',
                          'buildingType': 'exhibition',
                          'budgetAmount': 2600,
                          'state': 'draft',
                          'summary': _summary('已回流到我的项目'),
                        },
                        'privateSummary': <String, Object?>{
                          'hasAcceptedOrder': false,
                          'orderStatus': null,
                          'contractStatus': null,
                          'fulfillmentStatus': null,
                          'acceptanceStatus': null,
                          'afterSalesOrDisputeStatus': null,
                          'formalCompletionStatus': 'not_formally_completed',
                          'evaluationStatus': 'not_eligible',
                        },
                      },
                    ],
                    'historicalProjects': <Object?>[],
                  },
                );
              },
            },
      );
      final consumer = ExhibitionConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: transport,
        ),
      );

      final createResult = await consumer.createProject(
        ProjectCreateCommand(
          title: '发布成功项目 - 迈德瑞',
          exhibitionName: '发布成功项目',
          brandName: '迈德瑞',
          buildingType: 'exhibition',
          budgetAmount: 2600,
          provinceCode: '510000',
          provinceName: '四川',
          cityCode: '510100',
          cityName: '成都',
          detailAddress: '世纪城新国际会展中心 6 号馆西门',
          scopeSummary: '主舞台、医疗器械展区与灯光联动区进场搭建',
        ),
      );

      expect(createResult.isSuccess, isTrue);

      final myProjects = await consumer.loadMyProjectList(forceRefresh: true);
      expect(myProjects.state, AppPageState.content);
      final payload = myProjects.payload as Map<String, Object?>;
      final ongoing = payload['ongoingProjects'] as List<Object?>;
      final first = ongoing.first as Map<String, Object?>;
      final publicProject = first['publicProject'] as Map<String, Object?>;
      expect(publicProject['title'], '发布成功项目');
      expect(publicProject['state'], 'draft');
    },
  );

  test(
    'project create success invalidates cached my project list for same-session backflow',
    () async {
      var myProjectListRequests = 0;

      Map<String, Object?> myProjectItem({
        required String projectId,
        required String title,
        required String projectNo,
      }) {
        return <String, Object?>{
          'publicProject': <String, Object?>{
            'projectId': projectId,
            'projectNo': projectNo,
            'title': title,
            'buildingType': 'exhibition',
            'budgetAmount': 2600,
            'state': 'published',
            'summary': _summary('当前项目已承接'),
            'areaSqm': 380,
            'provinceCode': '510000',
            'provinceName': '四川',
            'cityCode': '510100',
            'cityName': '成都',
          },
          'privateSummary': <String, Object?>{
            'hasAcceptedOrder': false,
            'orderStatus': null,
            'contractStatus': null,
            'fulfillmentStatus': null,
            'acceptanceStatus': null,
            'afterSalesOrDisputeStatus': null,
            'formalCompletionStatus': 'not_formally_completed',
            'evaluationStatus': 'not_eligible',
          },
        };
      }

      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/my/projects': (AppApiRequest request) async {
                myProjectListRequests += 1;
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'ongoingProjects': <Object?>[
                      myProjectListRequests == 1
                          ? myProjectItem(
                              projectId: 'project-old',
                              title: '缓存旧项目',
                              projectNo: 'MY-OLD-1',
                            )
                          : myProjectItem(
                              projectId: 'project-created',
                              title: '新回流项目',
                              projectNo: 'MY-NEW-1',
                            ),
                    ],
                    'historicalProjects': <Object?>[],
                  },
                );
              },
              'POST /api/app/project/create': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 202,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'projectId': 'project-created',
                    'state': 'draft',
                  },
                );
              },
            },
      );
      final exhibitionConsumerLayer = ExhibitionConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: transport,
        ),
      );

      final cachedMyProjects = await exhibitionConsumerLayer
          .loadMyProjectList();
      expect(cachedMyProjects.state, AppPageState.content);
      expect(myProjectListRequests, 1);

      final createResult = await exhibitionConsumerLayer.createProject(
        ProjectCreateCommand(
          title: '新回流项目 - 迈德瑞',
          exhibitionName: '新回流项目',
          brandName: '迈德瑞',
          buildingType: 'exhibition',
          budgetAmount: 2600,
          provinceCode: '510000',
          provinceName: '四川',
          cityCode: '510100',
          cityName: '成都',
          detailAddress: '世纪城新国际会展中心 6 号馆西门',
          scopeSummary: '主舞台、医疗器械展区与灯光联动区进场搭建',
        ),
      );
      expect(createResult.isSuccess, isTrue);

      exhibitionConsumerLayer.invalidateMyProjectList();
      final refreshedMyProjects = await exhibitionConsumerLayer
          .loadMyProjectList(forceRefresh: true);
      expect(myProjectListRequests, 2);
      expect(refreshedMyProjects.state, AppPageState.content);
      final payload = refreshedMyProjects.payload as Map<String, Object?>;
      final ongoing = payload['ongoingProjects'] as List<Object?>;
      final first = ongoing.first as Map<String, Object?>;
      final publicProject = first['publicProject'] as Map<String, Object?>;
      expect(publicProject['title'], '新回流项目');
      expect(publicProject['projectNo'], 'MY-NEW-1');
    },
  );

  testWidgets('project create failure says login reason exactly', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          const <
            String,
            Future<AppApiResponse> Function(AppApiRequest request)
          >{},
    );

    await tester.pumpWidget(
      _buildApp(
        initialRoute: ExhibitionRoutes.projectCreate,
        transport: transport,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('请先登录'), findsOneWidget);
    expect(find.text('当前账号未登录，先登录后再创建项目。'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '去登录'), findsOneWidget);
  });

  testWidgets('project create failure says organization reason exactly', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          const <
            String,
            Future<AppApiResponse> Function(AppApiRequest request)
          >{},
    );

    await tester.pumpWidget(
      _buildApp(
        initialRoute: ExhibitionRoutes.projectCreate,
        transport: transport,
        sessionStore: _buildAuthenticatedSessionStore(deviceId: 'mainline-4'),
        shellContextConsumer: _buildShellContextConsumer(organizationId: null),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('请先加入组织'), findsOneWidget);
    expect(find.text('当前账号还没有组织信息，先完成组织承接后再创建项目。'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '去完善组织'), findsOneWidget);
  });

  testWidgets('project create failure says certification reason exactly', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          const <
            String,
            Future<AppApiResponse> Function(AppApiRequest request)
          >{},
    );

    await tester.pumpWidget(
      _buildApp(
        initialRoute: ExhibitionRoutes.projectCreate,
        transport: transport,
        sessionStore: _buildAuthenticatedSessionStore(deviceId: 'mainline-4b'),
        shellContextConsumer: _buildShellContextConsumer(
          certificationStatus: 'pending_review',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('当前认证未通过'), findsOneWidget);
    expect(find.text('当前组织认证尚未通过，需先完成并通过认证后再创建项目。'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '查看认证状态'), findsOneWidget);
  });

  testWidgets('project create failure says role reason exactly', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          const <
            String,
            Future<AppApiResponse> Function(AppApiRequest request)
          >{},
    );

    await tester.pumpWidget(
      _buildApp(
        initialRoute: ExhibitionRoutes.projectCreate,
        transport: transport,
        sessionStore: _buildAuthenticatedSessionStore(deviceId: 'mainline-5'),
        shellContextConsumer: _buildShellContextConsumer(
          roleKeys: const <String>['supplier_admin'],
          canCreateProject: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('当前角色不允许创建项目'), findsNothing);
    expect(find.widgetWithText(FilledButton, '返回我的项目'), findsNothing);
    expect(find.text('当前组织角色暂不允许创建项目'), findsNothing);
  });

  testWidgets('project create failure says network reason exactly', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          const <
            String,
            Future<AppApiResponse> Function(AppApiRequest request)
          >{},
    );

    await tester.pumpWidget(
      _buildApp(
        initialRoute: ExhibitionRoutes.projectCreate,
        transport: transport,
        sessionStore: _buildAuthenticatedSessionStore(deviceId: 'mainline-6'),
        shellContextConsumer: _buildShellContextConsumer(
          shellContextHandler: (AppApiRequest request) async {
            throw const SocketException('offline');
          },
          canCreateProject: null,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('当前暂时无法确认创建条件'), findsOneWidget);
    expect(find.text('当前无法确认当前创建资格，请稍后再试。'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '返回我的项目'), findsOneWidget);
  });

  testWidgets('project list stays dense while keeping core project fields', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/project/list': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: <String, Object?>{
                  'items': <Object?>[
                    _projectPayload(
                      projectId: 'project-list-1',
                      projectNo: 'PROJ-LIST-1',
                      title: '高密度展示项目',
                      budgetAmount: 188000,
                      summaryHeading: '核心摘要',
                      provinceName: '四川',
                      cityName: '成都',
                    )..addAll(<String, Object?>{'areaSqm': 320}),
                  ],
                },
              );
            },
          },
    );

    await tester.pumpWidget(
      _buildApp(
        initialRoute: ExhibitionRoutes.projectList,
        transport: transport,
        sessionStore: _buildAuthenticatedSessionStore(deviceId: 'mainline-7'),
        shellContextConsumer: _buildShellContextConsumer(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('当前展示：已接通内容'), findsNothing);
    expect(find.text('筛选条件'), findsNothing);
    expect(find.text('城市'), findsWidgets);
    expect(find.text('面积'), findsWidgets);
    expect(find.text('金额'), findsWidgets);
    expect(find.text('跟随城市'), findsWidgets);
    expect(find.text('不限面积'), findsWidgets);
    expect(find.text('不限金额'), findsWidgets);
    expect(find.text('刷新当前结果'), findsNothing);
    expect(find.text('高密度展示项目'), findsOneWidget);
    expect(find.textContaining('预算：', skipOffstage: false), findsWidgets);
    expect(find.textContaining('面积：', skipOffstage: false), findsWidgets);
    expect(find.textContaining('搭建地：', skipOffstage: false), findsWidgets);
    expect(find.text('讲解建议'), findsNothing);
    expect(find.text('项目编号：PROJ-LIST-1'), findsOneWidget);
    expect(find.text('下一步动作'), findsNothing);
    expect(find.widgetWithText(OutlinedButton, '查看详情'), findsOneWidget);
  });

  testWidgets(
    'showcase project detail keeps business sections and downranks boundary noise',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/project/detail': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body:
                      _projectPayload(
                        projectId: 'project-showcase-1',
                        projectNo: 'PROJ-SHOWCASE-1',
                        title: '展示详情项目',
                        budgetAmount: 560000,
                        summaryHeading: '公开项目摘要',
                        provinceName: '四川',
                        cityName: '成都',
                        districtName: '武侯区',
                        detailAddress: '世纪城新国际会展中心',
                        scopeSummary: '主舞台与展区搭建',
                        plannedStartAt: '2026-04-10',
                        plannedEndAt: '2026-04-18',
                      )..addAll(<String, Object?>{
                        'areaSqm': 420,
                        'description': '项目说明文本',
                      }),
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          initialRoute: ExhibitionRoutes.projectDetailWithProjectId(
            'project-showcase-1',
          ),
          transport: transport,
          sessionStore: _buildAuthenticatedSessionStore(deviceId: 'mainline-8'),
          shellContextConsumer: _buildShellContextConsumer(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('当前展示：已接通内容'), findsNothing);
      expect(find.text('项目概要'), findsOneWidget);
      expect(find.text('地点与安排'), findsNothing);
      expect(find.text('公开项目说明'), findsNothing);
      expect(find.text('公开资料边界'), findsNothing);
      expect(find.widgetWithText(FilledButton, '立即参与竞标'), findsOneWidget);
      expect(find.text('附件展示承接'), findsNothing);
      expect(find.text('展示边界'), findsNothing);
      expect(find.text('当前展示来源'), findsNothing);
      expect(find.text('状态说明'), findsNothing);
    },
  );

  testWidgets(
    'owner project detail hands off to private continuation surfaces',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/project/detail': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body:
                      _projectPayload(
                        projectId: 'project-owner-1',
                        projectNo: 'PROJ-OWNER-1',
                        title: 'Owner 项目详情',
                        budgetAmount: 580000,
                        viewerProjectRelation: 'owner',
                        summaryHeading: 'owner 摘要',
                        provinceName: '四川',
                        cityName: '成都',
                        districtName: '武侯区',
                        detailAddress: '世纪城新国际会展中心',
                        scopeSummary: '主舞台与展区搭建',
                        plannedStartAt: '2026-04-10',
                        plannedEndAt: '2026-04-18',
                      )..addAll(<String, Object?>{
                        'areaSqm': 420,
                        'description': '项目说明文本',
                      }),
                );
              },
            },
      );
      final exhibitionConsumerLayer = ExhibitionConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: transport,
        ),
      );
      final detailResult = await exhibitionConsumerLayer.loadProjectDetail(
        projectId: 'project-owner-1',
      );
      expect(detailResult.state, AppPageState.content);
      expect(
        (detailResult.payload
            as Map<String, Object?>?)?['viewerProjectRelation'],
        'owner',
      );

      await tester.pumpWidget(
        _buildApp(
          initialRoute: ExhibitionRoutes.projectDetailWithProjectId(
            'project-owner-1',
          ),
          transport: transport,
          exhibitionConsumerLayer: exhibitionConsumerLayer,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('项目概要'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.widgetWithText(FilledButton, '进入我的项目'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.widgetWithText(FilledButton, '进入我的项目'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '打开发布项目工作台'), findsNothing);
      expect(find.widgetWithText(FilledButton, '立即参与竞标'), findsNothing);
      expect(
        transport.requests
            .map((AppApiRequest request) => request.canonicalPath)
            .toList(),
        <String>[ExhibitionCanonicalPaths.projectDetail],
      );
    },
  );

  testWidgets(
    'shell mainline continues from project list to minimum bid submit result',
    (WidgetTester tester) async {
      final uploadedKinds = <String>[];
      BidSubmitAttachmentDebugOverrides.installPicker(() async {
        final nextFile = switch (uploadedKinds.length) {
          0 => 'project-understanding.png',
          1 => 'quote-sheet.xlsx',
          _ => 'schedule-plan.docx',
        };
        return BidSubmitAttachmentDraft(
          fileName: nextFile,
          bytes: utf8.encode('mock-$nextFile'),
        );
      });
      addTearDown(BidSubmitAttachmentDebugOverrides.reset);

      final transport = FakeAppApiTransport(
        uploadHandler: (AppApiUploadRequest request) async {
          return AppApiResponse(statusCode: 200, uri: Uri.parse(request.url));
        },
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/project/list': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'items': <Object?>[
                      _projectPayload(
                        projectId: 'project-1',
                        projectNo: 'PROJ-1',
                        title: '首发项目',
                        budgetAmount: 1200,
                      ),
                    ],
                  },
                );
              },
              'GET /api/app/project/detail': (AppApiRequest request) async {
                expect(request.uri.queryParameters['projectId'], 'project-1');
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _projectPayload(
                    projectId: 'project-1',
                    projectNo: 'PROJ-1',
                    title: '首发项目',
                    budgetAmount: 1200,
                  ),
                );
              },
              'GET /api/app/project/bid-materials':
                  (AppApiRequest request) async {
                    expect(
                      request.uri.queryParameters['projectId'],
                      'project-1',
                    );
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'projectId': 'project-1',
                        'attachments': <Object?>[],
                      },
                    );
                  },
              'GET /api/app/project/public-resources':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{'resources': <Object?>[]},
                    );
                  },
              'POST /api/app/file/upload/init': (AppApiRequest request) async {
                final body = request.body as Map<String, Object?>;
                final fileKind = '${body['fileKind']}';
                uploadedKinds.add(fileKind);
                expect(body['businessType'], 'project');
                expect(body['businessId'], 'project-1');
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'uploadSessionId': 'session-$fileKind',
                    'directUpload': <String, Object?>{
                      'url': 'https://upload.test/$fileKind',
                      'method': 'PUT',
                      'headers': <String, Object?>{},
                    },
                    'confirm': <String, Object?>{
                      'endpoint': '/api/app/file/upload/confirm',
                    },
                  },
                );
              },
              'POST /api/app/file/upload/confirm':
                  (AppApiRequest request) async {
                    final body = request.body as Map<String, Object?>;
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: <String, Object?>{
                        'fileAssetId': 'fa-${body['uploadSessionId']}',
                      },
                    );
                  },
              'POST /api/app/bid/submit': (AppApiRequest request) async {
                expect(request.body, <String, Object?>{
                  'projectId': 'project-1',
                  'quoteAmount': 1200.0,
                  'proposalSummary': '首发主链投标',
                  'projectUnderstandingFileAssetId':
                      'fa-session-bid_project_understanding',
                  'quoteSheetFileAssetId': 'fa-session-bid_quote_sheet',
                  'schedulePlanFileAssetId': 'fa-session-bid_schedule_plan',
                });
                return AppApiResponse(
                  statusCode: 202,
                  uri: request.uri,
                  body: const <String, Object?>{'bidId': 'bid-1'},
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          transport: transport,
          sessionStore: _buildAuthenticatedSessionStore(deviceId: 'mainline-2'),
          shellContextConsumer: _buildShellContextConsumer(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('推荐频道'), findsOneWidget);
      await _tapVisible(tester, find.widgetWithText(FilledButton, '进入项目列表'));

      expect(find.text('项目展示'), findsWidgets);
      await _tapVisible(tester, find.widgetWithText(OutlinedButton, '查看详情'));

      expect(find.text('项目详情'), findsWidgets);
      await _tapVisible(tester, find.widgetWithText(FilledButton, '立即参与竞标'));

      expect(find.text('竞标提交'), findsWidgets);
      await _enterVisibleBidTextField(tester, label: '竞标报价', value: '1200');
      await _enterVisibleBidTextField(tester, label: '方案说明', value: '首发主链投标');
      await _uploadBidAttachment(tester, '项目理解');
      await _uploadBidAttachment(tester, '报价表');
      await _uploadBidAttachment(tester, '进度安排');
      await _tapVisible(tester, find.widgetWithText(FilledButton, '提交竞标'));

      expect(find.text('竞标已提交'), findsOneWidget);
      expect(find.text('竞标 ID：bid-1'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '继续创建订单'), findsNothing);
      expect(find.widgetWithText(FilledButton, '查看订单详情'), findsNothing);

      expect(
        transport.requests
            .map((AppApiRequest request) => request.canonicalPath)
            .toList(),
        containsAll(<String>[
          ExhibitionCanonicalPaths.projectList,
          ExhibitionCanonicalPaths.projectDetail,
          ExhibitionCanonicalPaths.bidSubmit,
        ]),
      );
    },
  );
}
