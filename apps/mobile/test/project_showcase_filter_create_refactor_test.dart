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

Map<String, Object?> _projectPayload({
  required String projectId,
  String projectNo = 'PROJ-1',
  String title = '旧兼容标题',
  String? exhibitionName,
  String? brandName,
  String buildingType = 'exhibition',
  num budgetAmount = 180000,
  num? areaSqm = 350.5,
  String? provinceCode = '510000',
  String? provinceName = '四川',
  String? cityCode = '510100',
  String? cityName = '成都',
  String? districtCode = '510107',
  String? districtName = '武侯区',
  String? detailAddress = '世纪城新国际会展中心 6 号馆西门',
  String? scopeSummary = '主舞台与医疗器械展区联动搭建',
  String? plannedStartAt = '2026-04-10',
  String? plannedEndAt = '2026-04-18',
  String? scheduleDetail = '4 月 10 日晚进场',
  String? description = '现场先完成基础施工与设备进场。',
  String viewerProjectRelation = 'non_owner',
  String state = 'published',
}) {
  return <String, Object?>{
    'projectId': projectId,
    'projectNo': projectNo,
    'title': title,
    if (exhibitionName case final String value) 'exhibitionName': value,
    if (brandName case final String value) 'brandName': value,
    'buildingType': buildingType,
    'budgetAmount': budgetAmount,
    if (areaSqm case final num value) 'areaSqm': value,
    if (provinceCode case final String value) 'provinceCode': value,
    if (provinceName case final String value) 'provinceName': value,
    if (cityCode case final String value) 'cityCode': value,
    if (cityName case final String value) 'cityName': value,
    if (districtCode case final String value) 'districtCode': value,
    if (districtName case final String value) 'districtName': value,
    if (detailAddress case final String value) 'detailAddress': value,
    if (scopeSummary case final String value) 'scopeSummary': value,
    if (plannedStartAt case final String value) 'plannedStartAt': value,
    if (plannedEndAt case final String value) 'plannedEndAt': value,
    if (scheduleDetail case final String value) 'scheduleDetail': value,
    if (description case final String value) 'description': value,
    'viewerProjectRelation': viewerProjectRelation,
    'state': state,
    'summary': const <String, Object?>{'heading': 'summary'},
  };
}

ExhibitionMobileApp _buildApp({
  required FakeAppApiTransport transport,
  required String initialRoute,
  AppSessionStore? sessionStore,
  AppShellContextConsumer? shellContextConsumer,
}) {
  return ExhibitionMobileApp(
    initialRoute: initialRoute,
    exhibitionConsumerLayer: ExhibitionConsumerLayer(
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
    shellContextConsumer: shellContextConsumer,
  );
}

AppSessionStore _buildAuthenticatedSessionStore() {
  final sessionStore = AppSessionStore();
  sessionStore.establishSession(
    accessToken: 'token-project-create',
    refreshToken: 'refresh-project-create',
    expiresInSeconds: 3600,
    deviceId: 'device-project-create',
  );
  return sessionStore;
}

AppShellContextConsumer _buildShellContextConsumer({
  bool canCreateProject = true,
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
                    'userId': 'showcase-user-1',
                    'organizationId': 'org-1',
                    'roleKeys': <String>['supplier_admin'],
                    'certificationStatus': 'verified',
                    'membershipStatus': 'active',
                    'projectCreateEligibility': <String, Object?>{
                      'canCreateProject': canCreateProject,
                    },
                    'visibleBuildings': <String>[
                      'exhibition',
                      'messages',
                      'profile',
                    ],
                    'featureFlagsVersion': 'ffv-20260411',
                    'unreadSummary': <String, Object?>{},
                  },
                );
              },
            },
      ),
    ),
  );
}

Finder _projectCreateField(String key) => find.byKey(ValueKey<String>(key));

Future<void> _scrollAndTap(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder, warnIfMissed: false);
  await tester.pump();
  await tester.pumpAndSettle();
}

void main() {
  test(
    'project list consumer forwards frozen filter params and keeps no-city fallback',
    () async {
      late AppApiRequest firstRequest;
      late AppApiRequest secondRequest;
      var projectListCallCount = 0;
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/project/list': (AppApiRequest request) async {
                projectListCallCount += 1;
                if (projectListCallCount == 1) {
                  firstRequest = request;
                } else {
                  secondRequest = request;
                }
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: const <String, Object?>{'items': <Object?>[]},
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

      await consumer.loadProjectList(forceRefresh: true);
      await consumer.loadProjectList(
        forceRefresh: true,
        provinceCode: '510000',
        cityCode: '510100',
        areaBucket: '36_sqm',
        budgetBucket: '8_10w',
      );

      expect(firstRequest.uri.queryParameters['provinceCode'], isNull);
      expect(firstRequest.uri.queryParameters['cityCode'], isNull);
      expect(firstRequest.uri.queryParameters['areaBucket'], isNull);
      expect(firstRequest.uri.queryParameters['budgetBucket'], isNull);
      expect(secondRequest.uri.queryParameters['provinceCode'], '510000');
      expect(secondRequest.uri.queryParameters['cityCode'], '510100');
      expect(secondRequest.uri.queryParameters['areaBucket'], '36_sqm');
      expect(secondRequest.uri.queryParameters['budgetBucket'], '8_10w');
    },
  );

  test(
    'project create command keeps dual-field mode and legacy title compatibility',
    () {
      final dualField = ProjectCreateCommand(
        title: '春季医疗器械展 - 迈德瑞',
        exhibitionName: '春季医疗器械展',
        brandName: '迈德瑞',
        buildingType: 'exhibition',
        budgetAmount: 180000,
        provinceCode: '510000',
        provinceName: '四川',
        cityCode: '510100',
        cityName: '成都',
        detailAddress: '世纪城新国际会展中心 6 号馆西门',
        scopeSummary: '主舞台与展区联动搭建',
      );
      final legacyOnly = ProjectCreateCommand(
        title: '旧标题项目',
        buildingType: 'exhibition',
        budgetAmount: 80000,
        provinceCode: '510000',
        provinceName: '四川',
        cityCode: '510100',
        cityName: '成都',
        detailAddress: '旧地址',
        scopeSummary: '旧范围',
      );

      expect(dualField.toJson()['title'], '春季医疗器械展 - 迈德瑞');
      expect(dualField.toJson()['exhibitionName'], '春季医疗器械展');
      expect(dualField.toJson()['brandName'], '迈德瑞');
      expect(dualField.toJson().containsKey('taskType'), isFalse);
      expect(dualField.toJson().containsKey('quoteMode'), isFalse);
      expect(dualField.toJson().containsKey('isInquiry'), isFalse);
      expect(dualField.toJson().containsKey('prepublish'), isFalse);
      expect(legacyOnly.toJson()['title'], '旧标题项目');
      expect(legacyOnly.toJson().containsKey('exhibitionName'), isFalse);
      expect(legacyOnly.toJson().containsKey('brandName'), isFalse);
    },
  );

  test(
    'project create consumer submits dual-field body through app-facing path',
    () async {
      late AppApiRequest capturedRequest;
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'POST /api/app/project/create': (AppApiRequest request) async {
                capturedRequest = request;
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
      final consumer = ExhibitionConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: transport,
        ),
      );

      await consumer.createProject(
        ProjectCreateCommand(
          title: '春季医疗器械展 - 迈德瑞',
          exhibitionName: '春季医疗器械展',
          brandName: '迈德瑞',
          buildingType: 'exhibition',
          budgetAmount: 180000,
          provinceCode: '510000',
          provinceName: '四川',
          cityCode: '510100',
          cityName: '成都',
          detailAddress: '世纪城新国际会展中心 6 号馆西门',
          scopeSummary: '主舞台与医疗器械展区联动搭建',
        ),
      );

      final body = capturedRequest.body as Map<String, Object?>;
      expect(capturedRequest.canonicalPath, '/api/app/project/create');
      expect(body['title'], '春季医疗器械展 - 迈德瑞');
      expect(body['exhibitionName'], '春季医疗器械展');
      expect(body['brandName'], '迈德瑞');
      expect(body.containsKey('taskType'), isFalse);
      expect(body.containsKey('quoteMode'), isFalse);
      expect(body.containsKey('isInquiry'), isFalse);
      expect(body.containsKey('prepublish'), isFalse);
    },
  );

  test(
    'project lifecycle consumer keeps app-facing edit/save/submit/publish contract aligned',
    () async {
      late AppApiRequest editRequest;
      late AppApiRequest saveRequest;
      late AppApiRequest submitRequest;
      late AppApiRequest publishRequest;
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/project/edit/detail':
                  (AppApiRequest request) async {
                    editRequest = request;
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _projectPayload(
                        projectId: 'project-edit-1',
                        exhibitionName: '春季医疗器械展',
                        brandName: '迈德瑞',
                        state: 'draft',
                        viewerProjectRelation: 'owner',
                      ),
                    );
                  },
              'POST /api/app/project/save': (AppApiRequest request) async {
                saveRequest = request;
                return AppApiResponse(
                  statusCode: 202,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'projectId': 'project-edit-1',
                    'state': 'draft',
                  },
                );
              },
              'POST /api/app/project/submit': (AppApiRequest request) async {
                submitRequest = request;
                return AppApiResponse(
                  statusCode: 202,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'projectId': 'project-edit-1',
                    'state': 'submitted',
                  },
                );
              },
              'POST /api/app/project/publish': (AppApiRequest request) async {
                publishRequest = request;
                return AppApiResponse(
                  statusCode: 202,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'projectId': 'project-edit-1',
                    'state': 'published',
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

      final editResult = await consumer.loadProjectEditDetail(
        projectId: 'project-edit-1',
        forceRefresh: true,
      );
      final saveResult = await consumer.saveProject(
        ProjectSaveCommand(
          projectId: 'project-edit-1',
          title: '春季医疗器械展 - 迈德瑞',
          exhibitionName: '春季医疗器械展',
          brandName: '迈德瑞',
          buildingType: 'exhibition',
          budgetAmount: 180000,
          provinceCode: '510000',
          provinceName: '四川',
          cityCode: '510100',
          cityName: '成都',
          detailAddress: '世纪城新国际会展中心 6 号馆西门',
          scopeSummary: '主舞台与医疗器械展区联动搭建',
        ),
      );
      final submitResult = await consumer.submitProject(
        const ProjectLifecycleActionCommand(projectId: 'project-edit-1'),
      );
      final publishResult = await consumer.publishProject(
        const ProjectLifecycleActionCommand(projectId: 'project-edit-1'),
      );

      expect(editRequest.canonicalPath, '/api/app/project/edit/detail');
      expect(editRequest.uri.queryParameters['projectId'], 'project-edit-1');
      expect(editResult.state, AppPageState.content);
      expect(saveRequest.canonicalPath, '/api/app/project/save');
      expect(saveRequest.body, containsPair('projectId', 'project-edit-1'));
      expect(saveResult.payload, <String, Object?>{
        'projectId': 'project-edit-1',
        'state': 'draft',
      });
      expect(submitRequest.canonicalPath, '/api/app/project/submit');
      expect(submitRequest.body, <String, Object?>{
        'projectId': 'project-edit-1',
      });
      expect(submitResult.payload, <String, Object?>{
        'projectId': 'project-edit-1',
        'state': 'submitted',
      });
      expect(publishRequest.canonicalPath, '/api/app/project/publish');
      expect(publishRequest.body, <String, Object?>{
        'projectId': 'project-edit-1',
      });
      expect(publishResult.payload, <String, Object?>{
        'projectId': 'project-edit-1',
        'state': 'published',
      });
    },
  );

  testWidgets(
    'project list renders real content-state with compact main info',
    (WidgetTester tester) async {
      final contentTransport = FakeAppApiTransport(
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
                        exhibitionName: '春季医疗器械展',
                        brandName: '迈德瑞',
                      ),
                    ],
                  },
                );
              },
            },
      );
      await tester.pumpWidget(
        _buildApp(
          transport: contentTransport,
          initialRoute: ExhibitionRoutes.projectList,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('当前展示：已接通内容'), findsNothing);
      expect(find.text('筛选条件'), findsNothing);
      expect(find.text('城市'), findsWidgets);
      expect(find.text('面积'), findsWidgets);
      expect(find.text('金额'), findsWidgets);
      expect(find.text('跟随城市'), findsWidgets);
      expect(find.text('不限面积'), findsWidgets);
      expect(find.text('不限金额'), findsWidgets);
      expect(find.textContaining('公开项目只展示当前仍在有效期内的项目'), findsOneWidget);
      expect(find.text('刷新当前结果'), findsNothing);
      expect(find.text('恢复默认筛选'), findsNothing);
      expect(find.textContaining('春季医疗器械展', skipOffstage: false), findsWidgets);
      expect(find.textContaining('迈德瑞', skipOffstage: false), findsWidgets);
      expect(find.textContaining('预算：', skipOffstage: false), findsWidgets);
      expect(find.textContaining('面积：', skipOffstage: false), findsWidgets);
      expect(find.textContaining('搭建地：', skipOffstage: false), findsWidgets);
      expect(find.textContaining('时间：', skipOffstage: false), findsWidgets);
    },
  );

  testWidgets(
    'project list renders real empty-state instead of pretending success',
    (WidgetTester tester) async {
      final emptyTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/project/list': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: const <String, Object?>{'items': <Object?>[]},
                );
              },
            },
      );
      await tester.pumpWidget(
        _buildApp(
          transport: emptyTransport,
          initialRoute: ExhibitionRoutes.projectList,
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.textContaining('当前展示：真实空结果', skipOffstage: false),
        findsWidgets,
      );
      expect(find.textContaining('退出公开展示', skipOffstage: false), findsWidgets);
    },
  );

  testWidgets('project list keeps blocker state distinct from content-state', (
    WidgetTester tester,
  ) async {
    final blockerTransport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/project/list': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 403,
                uri: request.uri,
                body: const <String, Object?>{
                  'code': 'AUTH_PERMISSION_DENIED',
                  'message': 'permission denied',
                },
              );
            },
          },
    );
    await tester.pumpWidget(
      _buildApp(
        transport: blockerTransport,
        initialRoute: ExhibitionRoutes.projectList,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('当前未开放'), findsOneWidget);
    expect(find.textContaining('真实空结果'), findsNothing);
  });

  testWidgets('project detail prefers exhibition and brand over legacy title', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/project/detail': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _projectPayload(
                  projectId: 'project-1',
                  title: '旧兼容标题',
                  exhibitionName: '春季医疗器械展',
                  brandName: '迈德瑞',
                ),
              );
            },
          },
    );

    await tester.pumpWidget(
      _buildApp(
        transport: transport,
        initialRoute: ExhibitionRoutes.projectDetailWithProjectId('project-1'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('春季医疗器械展'), findsOneWidget);
    expect(find.text('迈德瑞'), findsOneWidget);
    expect(find.text('项目名称：旧兼容标题'), findsNothing);
  });

  testWidgets(
    'project detail keeps expired public continuation unavailable controlled',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/project/detail': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 404,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'code': 'AUTH_RESOURCE_UNAVAILABLE',
                    'message': 'public continuation unavailable',
                  },
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          transport: transport,
          initialRoute: ExhibitionRoutes.projectDetailWithProjectId(
            'project-expired',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('回到项目展示', skipOffstage: false), findsWidgets);
      expect(find.text('公开项目信息'), findsNothing);
      expect(find.widgetWithText(FilledButton, '回到项目展示'), findsOneWidget);
    },
  );

  testWidgets('project create page exposes exhibition and brand fields', (
    WidgetTester tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(900, 1200));

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
          },
    );

    await tester.pumpWidget(
      _buildApp(
        transport: transport,
        initialRoute: ExhibitionRoutes.projectCreate,
        sessionStore: _buildAuthenticatedSessionStore(),
        shellContextConsumer: _buildShellContextConsumer(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('展会'), findsOneWidget);
    expect(find.text('品牌'), findsOneWidget);
    expect(find.text('项目名称'), findsNothing);
    expect(find.text('报价方式'), findsNothing);
    expect(find.text('明价'), findsOneWidget);
    expect(find.text('询价'), findsOneWidget);
    expect(find.text('P0-Pay 交易任务'), findsNothing);
    expect(find.text('创建明价竞标单'), findsNothing);
    expect(find.text('创建询价报价单并拉起发单诚意金'), findsNothing);
    expect(_projectCreateField('project-create-title'), findsOneWidget);
    expect(_projectCreateField('project-create-brand-name'), findsOneWidget);
    final typeFieldHeight = tester
        .getSize(_projectCreateField('project-create-building-type'))
        .height;
    final budgetFieldHeight = tester
        .getSize(_projectCreateField('project-create-budget-amount'))
        .height;
    final areaFieldHeight = tester
        .getSize(_projectCreateField('project-create-area-sqm'))
        .height;
    expect(typeFieldHeight, greaterThan(budgetFieldHeight));
    expect(areaFieldHeight, greaterThan(budgetFieldHeight));

    await tester.tap(find.text('明价'));
    await tester.pumpAndSettle();
    expect(find.text('明价'), findsOneWidget);
    expect(
      (tester.getTopLeft(find.text('明价')).dy -
              tester.getTopLeft(find.text('询价')).dy)
          .abs(),
      lessThan(1),
    );

    final fixedPriceBudgetField = tester.widget<TextField>(
      _projectCreateField('project-create-budget-amount'),
    );
    expect(fixedPriceBudgetField.decoration?.prefixText, '* ');

    await tester.tap(find.text('询价'));
    await tester.pumpAndSettle();
    expect(
      (tester.getTopLeft(find.text('明价')).dy -
              tester.getTopLeft(find.text('询价')).dy)
          .abs(),
      lessThan(1),
    );

    final inquiryBudgetField = tester.widget<TextField>(
      _projectCreateField('project-create-budget-amount'),
    );
    expect(inquiryBudgetField.decoration?.prefixText, isNull);
  });

  testWidgets(
    'project edit route surfaces draft lifecycle actions from real edit detail truth',
    (WidgetTester tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(900, 1200));

      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/project/edit/detail':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _projectPayload(
                        projectId: 'project-created-1',
                        exhibitionName: '春季医疗器械展',
                        brandName: '迈德瑞',
                        state: 'draft',
                        viewerProjectRelation: 'owner',
                      ),
                    );
                  },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          transport: transport,
          initialRoute: ExhibitionRoutes.projectEditWithProjectId(
            'project-created-1',
          ),
          sessionStore: _buildAuthenticatedSessionStore(),
          shellContextConsumer: _buildShellContextConsumer(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('编辑项目'), findsWidgets);
      expect(
        _projectCreateField('project-edit-app-bar-status'),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('草稿 -> 预发布列表'),
        ),
        findsOneWidget,
      );
      expect(find.text('当前状态：草稿'), findsNothing);
      expect(find.text('当前生命周期'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '保存到预发布列表'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, '仅保存草稿'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, '收起当前内容核对'), findsOneWidget);
      expect(find.text('基础信息'), findsWidgets);
      expect(find.text('项目地点与范围'), findsOneWidget);
      await tester.scrollUntilVisible(
        _projectCreateField('project-create-planned-start-at'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(
        _projectCreateField('project-create-planned-start-at'),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(
        _projectCreateField('project-create-description'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(_projectCreateField('project-create-description'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.widgetWithText(FilledButton, '确认保存到预发布列表'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('当前状态：当前项目尚未进入预发布附件补充阶段。'), findsOneWidget);
      expect(find.text('当前提示：请仔细核对上面信息，确认进入预发布列表。'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '确认保存到预发布列表'), findsOneWidget);
      expect(find.text('保存到草稿或预发布列表后，五类报价依据资料会在这里开放补充。'), findsNothing);
    },
  );

  testWidgets(
    'project edit routes draft actions to prepublish and keeps final publish confirmation on my-project detail',
    (WidgetTester tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(900, 1200));

      final requests = <AppApiRequest>[];
      var currentState = 'draft';
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/project/edit/detail':
                  (AppApiRequest request) async {
                    requests.add(request);
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _projectPayload(
                        projectId: 'project-edit-2',
                        exhibitionName: '西部糖酒会',
                        brandName: '古井贡',
                        state: currentState,
                        viewerProjectRelation: 'owner',
                      ),
                    );
                  },
              'GET /api/app/project/detail': (AppApiRequest request) async {
                requests.add(request);
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _projectPayload(
                    projectId: 'project-edit-2',
                    exhibitionName: '西部糖酒会',
                    brandName: '古井贡',
                    state: currentState,
                    viewerProjectRelation: 'owner',
                  ),
                );
              },
              'GET /api/app/my/projects/project-edit-2':
                  (AppApiRequest request) async {
                    requests.add(request);
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: <String, Object?>{
                        'publicProject': _projectPayload(
                          projectId: 'project-edit-2',
                          exhibitionName: '西部糖酒会',
                          brandName: '古井贡',
                          state: currentState,
                          viewerProjectRelation: 'owner',
                        ),
                        'privateProgress': const <String, Object?>{
                          'hasAcceptedOrder': false,
                          'formalCompletionStatus': 'not_formally_completed',
                          'evaluationStatus': 'not_eligible',
                        },
                      },
                    );
                  },
              'POST /api/app/project/save': (AppApiRequest request) async {
                requests.add(request);
                return AppApiResponse(
                  statusCode: 202,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'projectId': 'project-edit-2',
                    'state': 'draft',
                  },
                );
              },
              'POST /api/app/project/submit': (AppApiRequest request) async {
                requests.add(request);
                currentState = 'submitted';
                return AppApiResponse(
                  statusCode: 202,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'projectId': 'project-edit-2',
                    'state': 'submitted',
                  },
                );
              },
              'POST /api/app/project/publish': (AppApiRequest request) async {
                requests.add(request);
                currentState = 'published';
                return AppApiResponse(
                  statusCode: 202,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'projectId': 'project-edit-2',
                    'state': 'published',
                  },
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          transport: transport,
          initialRoute: ExhibitionRoutes.projectEditWithProjectId(
            'project-edit-2',
          ),
          sessionStore: _buildAuthenticatedSessionStore(),
          shellContextConsumer: _buildShellContextConsumer(),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        _projectCreateField('project-edit-app-bar-status'),
        findsOneWidget,
      );
      expect(find.text('当前状态：草稿'), findsNothing);
      await _scrollAndTap(tester, find.widgetWithText(OutlinedButton, '仅保存草稿'));
      await tester.pumpAndSettle();
      expect(
        requests.any(
          (AppApiRequest request) =>
              request.canonicalPath == '/api/app/project/save',
        ),
        isTrue,
      );

      await tester.scrollUntilVisible(
        find.byKey(
          const ValueKey<String>(
            'project-edit-draft-submit-to-prepublish-bottom',
          ),
        ),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await _scrollAndTap(
        tester,
        find.byKey(
          const ValueKey<String>(
            'project-edit-draft-submit-to-prepublish-bottom',
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        _projectCreateField('project-edit-app-bar-status'),
        findsOneWidget,
      );
      expect(
        find.descendant(of: find.byType(AppBar), matching: find.text('预发布列表')),
        findsOneWidget,
      );
      expect(find.text('当前状态：预发布列表'), findsNothing);
      expect(find.widgetWithText(FilledButton, '发布项目'), findsNothing);
      expect(find.widgetWithText(FilledButton, '返回预发布列表详情'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, '继续核对当前内容'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, '展开当前内容核对'), findsOneWidget);
      expect(find.text('基础信息'), findsNothing);
      expect(find.text('项目地点与范围'), findsNothing);
      expect(find.text('计划时间'), findsNothing);
      expect(find.text('补充说明'), findsNothing);
      expect(find.textContaining('西部糖酒会 / 古井贡'), findsOneWidget);
      expect(find.textContaining('四川 / 成都'), findsOneWidget);
      expect(find.textContaining('2026年4月10日 至 2026年4月18日'), findsOneWidget);
      expect(
        find.textContaining('最终发布确认回到“我的项目 -> 预发布列表 -> 单项目详情”完成'),
        findsOneWidget,
      );

      await _scrollAndTap(
        tester,
        find.widgetWithText(OutlinedButton, '继续核对当前内容'),
      );
      await tester.pumpAndSettle();
      expect(find.widgetWithText(OutlinedButton, '收起当前内容核对'), findsOneWidget);
      expect(find.text('基础信息'), findsWidgets);
      expect(find.text('项目地点与范围'), findsOneWidget);
      expect(_projectCreateField('project-create-title'), findsOneWidget);
      expect(_projectCreateField('project-create-brand-name'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('报价依据资料'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('报价依据资料'), findsOneWidget);

      await _scrollAndTap(
        tester,
        find.byKey(
          const ValueKey<String>(
            'project-edit-review-return-to-prepublish-bottom',
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        requests.any(
          (AppApiRequest request) =>
              request.canonicalPath == '/api/app/project/publish',
        ),
        isFalse,
      );
      expect(
        requests.any(
          (AppApiRequest request) =>
              request.canonicalPath == '/api/app/my/projects/project-edit-2',
        ),
        isTrue,
      );
    },
  );
}
