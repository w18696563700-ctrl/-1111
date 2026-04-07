import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/boot/app_shell_context_consumer.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
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

Map<String, Object?> _workbenchPayload({
  Map<String, Object?>? projectChain,
  Map<String, Object?>? orderChain,
  Map<String, Object?>? fulfillmentChain,
  Map<String, Object?>? extensionBoundary,
}) {
  return <String, Object?>{
    'project_chain':
        projectChain ??
        <String, Object?>{
          'hasProjects': false,
          'recentProjectId': null,
          'recentProjectTitle': null,
          'canCreateProject': true,
          'canOpenProjectPool': true,
        },
    'order_chain':
        orderChain ??
        <String, Object?>{
          'activeOrderId': null,
          'activeOrderNo': null,
          'activeOrderState': null,
          'canOpenOrderDetail': false,
          'canOpenContractDetail': false,
          'canOpenDisputeOpen': false,
        },
    'fulfillment_chain':
        fulfillmentChain ??
        <String, Object?>{
          'activeMilestoneId': null,
          'activeMilestoneTitle': null,
          'inspectionState': null,
          'canOpenMilestoneList': false,
          'canOpenMilestoneSubmit': false,
          'canOpenInspectionDetail': false,
          'canOpenInspectionSubmit': false,
        },
    'extension_boundary':
        extensionBoundary ??
        <String, Object?>{
          'canOpenContractDetail': false,
          'ratingEntryState': 'controlled_unavailable',
          'canOpenDisputeOpen': false,
          'disputeWithdrawState': 'frozen',
        },
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
}) {
  return AppShellContextConsumer(
    client: AppApiClient(
      config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
      transport: FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/shell/context': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'userId': 'mainline-user-1',
                    'organizationId': organizationId,
                    'roleKeys': roleKeys,
                    'certificationStatus': certificationStatus,
                    'membershipStatus': 'active',
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

Finder _projectCreateField(String label) {
  final key = switch (label) {
    '项目名称' => 'project-create-title',
    '项目类型' => 'project-create-building-type',
    '预算金额' => 'project-create-budget-amount',
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
  required double budgetAmount,
}) {
  return <String, Object?>{
    'title': title,
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
            'GET /api/app/exhibition/workbench': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _workbenchPayload(),
              );
            },
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
                _expectedProjectCreateBody(title: '首发演示项目', budgetAmount: 1800),
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
        transport: transport,
        sessionStore: _buildAuthenticatedSessionStore(deviceId: 'mainline-1'),
        shellContextConsumer: _buildShellContextConsumer(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('天气与定位'), findsOneWidget);
    await _tapVisible(tester, find.widgetWithText(FilledButton, '项目工作台'));
    expect(find.text('项目工作台'), findsWidgets);
    await _tapVisible(tester, find.widgetWithText(FilledButton, '创建项目'));

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
    await tester.scrollUntilVisible(
      find.text('补充说明与附件'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('补充说明与附件'), findsOneWidget);
    expect(_projectCreateField('补充说明'), findsOneWidget);
    expect(find.text('资料补充'), findsOneWidget);
  });

  testWidgets(
    'project create success prioritizes publish success and preview',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/exhibition/workbench':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _workbenchPayload(),
                    );
                  },
              'POST /api/app/project/create': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 202,
                  uri: request.uri,
                  body: const <String, Object?>{'projectId': 'project-created'},
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          initialRoute: ExhibitionRoutes.projectCreate,
          transport: transport,
          sessionStore: _buildAuthenticatedSessionStore(deviceId: 'mainline-3'),
          shellContextConsumer: _buildShellContextConsumer(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(_projectCreateField('项目名称'), '发布成功项目');
      await _tapVisible(tester, _projectCreateField('项目类型'));
      await tester.tap(find.text('会展').last);
      await tester.pumpAndSettle();
      await tester.enterText(_projectCreateField('预算金额'), '2600');
      await tester.scrollUntilVisible(
        _projectCreateField('省'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await _tapVisible(tester, _projectCreateField('省'));
      await tester.tap(find.text('四川 / 成都').last);
      await tester.pumpAndSettle();
      await _tapVisible(tester, _projectCreateField('区/县'));
      await tester.tap(find.text('武侯区').last);
      await tester.pumpAndSettle();
      await tester.enterText(_projectCreateField('详细地址'), '世纪城新国际会展中心 6 号馆西门');
      await tester.enterText(
        _projectCreateField('范围说明'),
        '主舞台、医疗器械展区与灯光联动区进场搭建',
      );
      await tester.scrollUntilVisible(
        _projectCreateField('计划结束日期'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.enterText(_projectCreateField('计划开始日期'), '2026年4月10日');
      await tester.enterText(_projectCreateField('计划结束日期'), '2026年4月18日');
      await tester.scrollUntilVisible(
        _projectCreateField('补充说明'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.enterText(_projectCreateField('补充说明'), '现场先完成基础施工与设备进场。');

      await _tapVisible(tester, find.widgetWithText(FilledButton, '发布项目'));

      expect(find.text('已成功发布'), findsOneWidget);
      expect(find.text('已发布项目预览'), findsOneWidget);
      expect(find.text('当前项目：发布成功项目'), findsOneWidget);
      expect(find.text('项目地点：四川 / 成都 / 武侯区'), findsOneWidget);
      expect(find.text('预算金额：¥2600'), findsWidgets);
      expect(find.text('范围说明：主舞台、医疗器械展区与灯光联动区进场搭建'), findsOneWidget);
      expect(find.text('计划开始日期：2026年4月10日'), findsOneWidget);
      expect(find.text('计划结束日期：2026年4月18日'), findsOneWidget);
      expect(find.text('结果反馈'), findsNothing);
    },
  );

  testWidgets(
    'project create success invalidates cached my project list for same-session backflow',
    (WidgetTester tester) async {
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
              'GET /api/app/exhibition/workbench':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _workbenchPayload(),
                    );
                  },
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
                  body: const <String, Object?>{'projectId': 'project-created'},
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

      await tester.pumpWidget(
        _buildApp(
          initialRoute: ExhibitionRoutes.projectCreate,
          transport: transport,
          exhibitionConsumerLayer: exhibitionConsumerLayer,
          sessionStore: _buildAuthenticatedSessionStore(
            deviceId: 'mainline-backflow',
          ),
          shellContextConsumer: _buildShellContextConsumer(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(_projectCreateField('项目名称'), '新回流项目');
      await _tapVisible(tester, _projectCreateField('项目类型'));
      await tester.tap(find.text('会展').last);
      await tester.pumpAndSettle();
      await tester.enterText(_projectCreateField('预算金额'), '2600');
      await tester.scrollUntilVisible(
        _projectCreateField('省'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await _tapVisible(tester, _projectCreateField('省'));
      await tester.tap(find.text('四川 / 成都').last);
      await tester.pumpAndSettle();
      await _tapVisible(tester, _projectCreateField('区/县'));
      await tester.tap(find.text('武侯区').last);
      await tester.pumpAndSettle();
      await tester.enterText(_projectCreateField('详细地址'), '世纪城新国际会展中心 6 号馆西门');
      await tester.enterText(
        _projectCreateField('范围说明'),
        '主舞台、医疗器械展区与灯光联动区进场搭建',
      );
      await tester.scrollUntilVisible(
        _projectCreateField('计划结束日期'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.enterText(_projectCreateField('计划开始日期'), '2026年4月10日');
      await tester.enterText(_projectCreateField('计划结束日期'), '2026年4月18日');
      await tester.scrollUntilVisible(
        _projectCreateField('补充说明'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.enterText(_projectCreateField('补充说明'), '现场先完成基础施工与设备进场。');

      await _tapVisible(tester, find.widgetWithText(FilledButton, '发布项目'));

      expect(find.text('已成功发布'), findsOneWidget);
      expect(myProjectListRequests, 1);

      Navigator.of(
        tester.element(find.text('已成功发布')),
      ).pushNamed(ExhibitionRoutes.myProjectList);
      await tester.pumpAndSettle();

      expect(myProjectListRequests, 2);
      expect(find.text('新回流项目'), findsWidgets);
      expect(find.text('缓存旧项目'), findsNothing);
      expect(find.text('尚未正式完结'), findsWidgets);
      expect(find.text('暂不可评价'), findsWidgets);
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

  testWidgets('project create failure says canCreateProject reason exactly', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/exhibition/workbench': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _workbenchPayload(
                  projectChain: <String, Object?>{
                    'hasProjects': true,
                    'recentProjectId': 'project-1',
                    'recentProjectTitle': '首发项目',
                    'canCreateProject': false,
                    'canOpenProjectPool': true,
                  },
                ),
              );
            },
          },
    );

    await tester.pumpWidget(
      _buildApp(
        initialRoute: ExhibitionRoutes.projectCreate,
        transport: transport,
        sessionStore: _buildAuthenticatedSessionStore(deviceId: 'mainline-5'),
        shellContextConsumer: _buildShellContextConsumer(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('当前暂不可创建项目'), findsOneWidget);
    expect(
      find.text('项目工作台显示当前账号暂不具备创建项目条件，请先回到项目工作台查看可执行入口。'),
      findsOneWidget,
    );
    expect(find.widgetWithText(FilledButton, '回到项目工作台'), findsOneWidget);
  });

  testWidgets('project create failure says network reason exactly', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/exhibition/workbench': (AppApiRequest request) async {
              throw const SocketException('offline');
            },
          },
    );

    await tester.pumpWidget(
      _buildApp(
        initialRoute: ExhibitionRoutes.projectCreate,
        transport: transport,
        sessionStore: _buildAuthenticatedSessionStore(deviceId: 'mainline-6'),
        shellContextConsumer: _buildShellContextConsumer(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('网络暂时不可用'), findsOneWidget);
    expect(find.text('当前无法从项目工作台确认是否可创建项目，请检查网络后再试。'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '回到项目工作台'), findsOneWidget);
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

    expect(find.text('高密度展示项目'), findsOneWidget);
    expect(find.text('核心摘要'), findsOneWidget);
    expect(find.text('四川 / 成都'), findsWidgets);
    expect(find.text('320 ㎡'), findsWidgets);
    expect(find.text('预算金额：¥188000'), findsOneWidget);
    expect(find.text('讲解建议'), findsNothing);
    expect(find.text('项目编号：PROJ-LIST-1'), findsNothing);
    expect(find.text('下一步动作'), findsNothing);
    expect(find.widgetWithText(FilledButton, '查看详情'), findsOneWidget);
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
            surface: ExhibitionRoutes.showcaseSurface,
          ),
          transport: transport,
          sessionStore: _buildAuthenticatedSessionStore(deviceId: 'mainline-8'),
          shellContextConsumer: _buildShellContextConsumer(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('项目概览'), findsOneWidget);
      expect(find.text('地点与范围'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('项目说明'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('项目说明'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('项目资料'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('项目资料'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '继续竞标'), findsOneWidget);
      expect(find.text('附件展示承接'), findsNothing);
      expect(find.text('展示边界'), findsNothing);
      expect(find.text('当前展示来源'), findsNothing);
      expect(find.text('状态说明'), findsNothing);
    },
  );

  testWidgets(
    'owner project detail swaps bid CTA into local manage-current sheet shell',
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
            surface: ExhibitionRoutes.showcaseSurface,
          ),
          transport: transport,
          exhibitionConsumerLayer: exhibitionConsumerLayer,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('项目概览'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.widgetWithText(FilledButton, '管理当前'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.widgetWithText(FilledButton, '管理当前'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '继续竞标'), findsNothing);

      await _tapVisible(tester, find.widgetWithText(FilledButton, '管理当前'));

      expect(find.text('推广此项目'), findsOneWidget);
      expect(find.text('编辑'), findsOneWidget);
      expect(find.text('下架'), findsOneWidget);
      expect(find.text('删除此项目'), findsOneWidget);
      expect(
        transport.requests
            .map((AppApiRequest request) => request.canonicalPath)
            .toList(),
        <String>[ExhibitionCanonicalPaths.projectDetail],
      );

      await tester.tapAt(const Offset(24, 24));
      await tester.pumpAndSettle();

      expect(find.text('推广此项目'), findsNothing);
      expect(find.text('编辑'), findsNothing);
      expect(find.text('下架'), findsNothing);
      expect(find.text('删除此项目'), findsNothing);
      expect(find.widgetWithText(FilledButton, '管理当前'), findsOneWidget);
    },
  );

  testWidgets(
    'shell mainline continues from project list to minimum bid submit result',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/exhibition/workbench':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _workbenchPayload(),
                    );
                  },
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
              'POST /api/app/bid/submit': (AppApiRequest request) async {
                expect(request.body, <String, Object?>{
                  'projectId': 'project-1',
                  'quoteAmount': 1200.0,
                  'proposalSummary': '首发主链投标',
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

      expect(find.text('天气与定位'), findsOneWidget);
      await _tapVisible(tester, find.widgetWithText(FilledButton, '进入模块'));

      expect(find.text('项目展示'), findsWidgets);
      await _tapVisible(tester, find.widgetWithText(FilledButton, '查看详情'));

      expect(find.text('项目详情'), findsWidgets);
      await _tapVisible(tester, find.widgetWithText(FilledButton, '继续竞标'));

      expect(find.text('投标提交'), findsWidgets);
      await tester.enterText(find.widgetWithText(TextField, '投标报价'), '1200');
      await tester.enterText(find.widgetWithText(TextField, '方案说明'), '首发主链投标');
      await _tapVisible(tester, find.widgetWithText(FilledButton, '提交投标'));

      expect(find.text('竞标已提交'), findsOneWidget);
      expect(find.text('投标 ID：bid-1'), findsOneWidget);
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
