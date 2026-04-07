import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/forum_consumer_layer.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/profile/data/profile_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_identity_consumer_layer.dart';
import 'package:mobile/shell/shell_app.dart';

Map<String, Object?> _profilePayload() {
  return <String, Object?>{
    'organization': <String, Object?>{
      'organizationId': 'org-my-project',
      'roleKeys': <Object?>['buyer_admin'],
      'visibleBuildings': <Object?>['exhibition', 'messages', 'profile'],
    },
    'certification': <String, Object?>{'status': 'approved'},
    'membership': <String, Object?>{'status': 'active'},
    'settingsEntry': <String, Object?>{'state': 'visible'},
  };
}

Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
_forumHandlers() {
  AppApiResponse emptyPaged(AppApiRequest request) => AppApiResponse(
    statusCode: 200,
    uri: request.uri,
    body: <String, Object?>{
      'items': <Object?>[],
      'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
    },
  );

  return <String, Future<AppApiResponse> Function(AppApiRequest request)>{
    'GET /api/app/forum/me/posts': (AppApiRequest request) async =>
        emptyPaged(request),
    'GET /api/app/forum/me/comments': (AppApiRequest request) async =>
        emptyPaged(request),
    'GET /api/app/forum/me/bookmarks': (AppApiRequest request) async =>
        emptyPaged(request),
    'GET /api/app/forum/me/follows': (AppApiRequest request) async =>
        emptyPaged(request),
    'GET /api/app/forum/draft/list': (AppApiRequest request) async =>
        emptyPaged(request),
  };
}

Map<String, Object?> _publicProjectListItem({
  required String projectId,
  required String projectNo,
  required String title,
  required num budgetAmount,
  String buildingType = 'exhibition',
  String state = 'published',
  String summaryHeading = '当前项目已承接',
  num? areaSqm,
  String? provinceCode,
  String? provinceName,
  String? cityCode,
  String? cityName,
}) {
  return <String, Object?>{
    'projectId': projectId,
    'projectNo': projectNo,
    'title': title,
    'buildingType': buildingType,
    'budgetAmount': budgetAmount,
    'state': state,
    'summary': <String, Object?>{'heading': summaryHeading},
    'areaSqm': areaSqm,
    'provinceCode': provinceCode,
    'provinceName': provinceName,
    'cityCode': cityCode,
    'cityName': cityName,
  };
}

Map<String, Object?> _publicProjectDetail({
  required String projectId,
  required String projectNo,
  required String title,
  required num budgetAmount,
  String buildingType = 'exhibition',
  String state = 'published',
  String summaryHeading = '当前项目已承接',
  String? summaryStateLabel,
  num? areaSqm,
  String? buildingTypeRemark,
  String? provinceCode,
  String? provinceName,
  String? cityCode,
  String? cityName,
  String? districtCode,
  String? districtName,
  String? detailAddress,
  String? scopeSummary,
  String? plannedStartAt,
  String? plannedEndAt,
  String? scheduleDetail,
  String? description,
  String? viewerProjectRelation,
}) {
  final summary = <String, Object?>{'heading': summaryHeading};
  if (summaryStateLabel != null) {
    summary['stateLabel'] = summaryStateLabel;
  }

  return <String, Object?>{
    ..._publicProjectListItem(
      projectId: projectId,
      projectNo: projectNo,
      title: title,
      budgetAmount: budgetAmount,
      buildingType: buildingType,
      state: state,
      summaryHeading: summaryHeading,
      areaSqm: areaSqm,
      provinceCode: provinceCode,
      provinceName: provinceName,
      cityCode: cityCode,
      cityName: cityName,
    ),
    'summary': summary,
    'buildingTypeRemark': buildingTypeRemark,
    'districtCode': districtCode,
    'districtName': districtName,
    'detailAddress': detailAddress,
    'scopeSummary': scopeSummary,
    'plannedStartAt': plannedStartAt,
    'plannedEndAt': plannedEndAt,
    'scheduleDetail': scheduleDetail,
    'description': description,
    if (viewerProjectRelation case final String relation)
      'viewerProjectRelation': relation,
  };
}

Map<String, Object?> _privateProgress({
  required bool hasAcceptedOrder,
  String? orderStatus,
  String? contractStatus,
  String? fulfillmentStatus,
  String? acceptanceStatus,
  String? afterSalesOrDisputeStatus,
  required String formalCompletionStatus,
  required String evaluationStatus,
}) {
  return <String, Object?>{
    'hasAcceptedOrder': hasAcceptedOrder,
    'orderStatus': orderStatus,
    'contractStatus': contractStatus,
    'fulfillmentStatus': fulfillmentStatus,
    'acceptanceStatus': acceptanceStatus,
    'afterSalesOrDisputeStatus': afterSalesOrDisputeStatus,
    'formalCompletionStatus': formalCompletionStatus,
    'evaluationStatus': evaluationStatus,
  };
}

Map<String, Object?> _myProjectItem({
  required Map<String, Object?> publicProject,
  required Map<String, Object?> privateSummary,
}) {
  return <String, Object?>{
    'publicProject': publicProject,
    'privateSummary': privateSummary,
  };
}

ExhibitionMobileApp _buildApp({
  required Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
  exhibitionHandlers,
  Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
      profileHandlers =
      const <String, Future<AppApiResponse> Function(AppApiRequest request)>{},
  String initialRoute = '/profile',
}) {
  final sessionStore = AppSessionStore()
    ..establishSession(
      accessToken: 'my-project-access',
      refreshToken: 'my-project-refresh',
      expiresInSeconds: 3600,
      deviceId: 'my-project-device',
    );

  return ExhibitionMobileApp(
    initialRoute: initialRoute,
    bootstrapShellContext: AppShellContextData(
      userId: '13812345678',
      organizationId: 'org-my-project',
      roleKeys: const <String>['buyer_admin'],
      certificationStatus: 'approved',
      membershipStatus: 'active',
      visibleBuildings: const <String>['exhibition', 'messages', 'profile'],
    ),
    sessionStore: sessionStore,
    exhibitionConsumerLayer: ExhibitionConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(handlers: exhibitionHandlers),
      ),
    ),
    profileConsumerLayer: ProfileConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(handlers: profileHandlers),
      ),
    ),
    forumConsumerLayer: ForumConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(handlers: _forumHandlers()),
      ),
    ),
    profileIdentityConsumerLayer: ProfileIdentityConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(handlers: const {}),
      ),
    ),
  );
}

void main() {
  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'my building entry shows my projects and closes the list-detail loop',
    (WidgetTester tester) async {
      final exhibitionHandlers =
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/my/projects': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: <String, Object?>{
                  'ongoingProjects': <Object?>[
                    _myProjectItem(
                      publicProject: _publicProjectListItem(
                        projectId: 'my-project-1',
                        projectNo: 'MY-001',
                        title: '组织内项目 1',
                        budgetAmount: 1800,
                        areaSqm: 350.5,
                        provinceCode: '510000',
                        provinceName: '四川',
                        cityCode: '510100',
                        cityName: '成都',
                        summaryHeading: '组织内项目摘要',
                      ),
                      privateSummary: _privateProgress(
                        hasAcceptedOrder: false,
                        formalCompletionStatus: 'not_formally_completed',
                        evaluationStatus: 'not_eligible',
                      ),
                    ),
                  ],
                  'historicalProjects': <Object?>[],
                },
              );
            },
            'GET /api/app/my/projects/my-project-1':
                (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: <String, Object?>{
                      'publicProject': _publicProjectDetail(
                        projectId: 'my-project-1',
                        projectNo: 'MY-001',
                        title: '组织内项目 1',
                        budgetAmount: 1800,
                        areaSqm: 350.5,
                        provinceCode: '510000',
                        provinceName: '四川',
                        cityCode: '510100',
                        cityName: '成都',
                        districtCode: '510107',
                        districtName: '武侯区',
                        detailAddress: '世纪城新国际会展中心 6 号馆西门',
                        scopeSummary: '主舞台与器械展区联动搭建',
                        plannedStartAt: '2026-04-10',
                        plannedEndAt: '2026-04-18',
                        scheduleDetail: '4 月 10 日晚进场，4 月 18 日撤场',
                        description: '当前项目继续按最小私域基线承接。',
                      ),
                      'privateProgress': _privateProgress(
                        hasAcceptedOrder: false,
                        formalCompletionStatus: 'not_formally_completed',
                        evaluationStatus: 'not_eligible',
                      ),
                    },
                  );
                },
          };
      final profileHandlers =
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/profile/index': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _profilePayload(),
              );
            },
          };

      await tester.pumpWidget(
        _buildApp(
          exhibitionHandlers: exhibitionHandlers,
          profileHandlers: profileHandlers,
        ),
      );
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('我的项目'));
      expect(find.text('我的项目'), findsOneWidget);
      expect(find.text('当前组织项目资产与继续处理入口 · 进行中 1 个 · 历史 0 个'), findsOneWidget);

      await tester.tap(find.text('我的项目'));
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('进行中'));
      expect(find.text('我的项目'), findsWidgets);
      expect(find.text('进行中'), findsWidgets);

      await scrollTo(tester, find.widgetWithText(FilledButton, '查看项目'));
      await tester.tap(find.widgetWithText(FilledButton, '查看项目'));
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('项目信息'));
      expect(find.text('项目信息'), findsOneWidget);
      await scrollTo(tester, find.text('当前进度'));
      expect(find.text('当前进度'), findsOneWidget);
      expect(find.text('公域信息区'), findsNothing);
      expect(find.text('私域进度区'), findsNothing);
    },
  );

  testWidgets(
    'my project list consumes grouped publicProject and privateSummary only',
    (WidgetTester tester) async {
      final exhibitionHandlers =
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/my/projects': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: <String, Object?>{
                  'ongoingProjects': <Object?>[
                    _myProjectItem(
                      publicProject: <String, Object?>{
                        ..._publicProjectListItem(
                          projectId: 'my-project-ongoing',
                          projectNo: 'MY-ONGOING-1',
                          title: '进行中项目',
                          budgetAmount: 2200,
                          areaSqm: 350.5,
                          provinceCode: '510000',
                          provinceName: '四川',
                          cityCode: '510100',
                          cityName: '成都',
                          summaryHeading: '私域最小摘要',
                        ),
                        'districtName': '武侯区',
                        'detailAddress': '世纪城新国际会展中心 6 号馆西门',
                        'description': '列表不应展示这个说明',
                      },
                      privateSummary: _privateProgress(
                        hasAcceptedOrder: false,
                        formalCompletionStatus: 'not_formally_completed',
                        evaluationStatus: 'not_eligible',
                      ),
                    ),
                  ],
                  'historicalProjects': <Object?>[
                    _myProjectItem(
                      publicProject: _publicProjectListItem(
                        projectId: 'my-project-history',
                        projectNo: 'MY-HISTORY-1',
                        title: '历史项目',
                        budgetAmount: 3000,
                        areaSqm: 420,
                        provinceCode: '310000',
                        provinceName: '上海',
                        cityCode: '310100',
                        cityName: '上海',
                        state: 'converted_to_order',
                        summaryHeading: '归档摘要',
                      ),
                      privateSummary: _privateProgress(
                        hasAcceptedOrder: true,
                        formalCompletionStatus: 'formally_completed',
                        evaluationStatus: 'submitted',
                      ),
                    ),
                  ],
                },
              );
            },
          };

      await tester.pumpWidget(
        _buildApp(
          exhibitionHandlers: exhibitionHandlers,
          initialRoute: ExhibitionRoutes.myProjectList,
        ),
      );
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('进行中：1 个'));
      expect(find.text('进行中：1 个'), findsOneWidget);
      expect(find.text('历史项目：1 个'), findsOneWidget);
      expect(find.text('私域最小摘要'), findsOneWidget);
      expect(find.text('四川 / 成都'), findsWidgets);
      expect(find.text('350.5 ㎡'), findsWidgets);
      expect(find.text('未接单'), findsWidgets);
      expect(find.text('尚未正式完结'), findsWidgets);
      expect(find.text('暂不可评价'), findsWidgets);
      await scrollTo(tester, find.text('已接单'));
      expect(find.text('已接单'), findsWidgets);
      expect(find.text('已正式完结'), findsWidgets);
      expect(find.text('已评价'), findsWidgets);
      expect(find.text('510000'), findsNothing);
      expect(find.text('510100'), findsNothing);
      expect(find.text('武侯区'), findsNothing);
      expect(find.textContaining('世纪城新国际会展中心 6 号馆西门'), findsNothing);
      expect(find.textContaining('列表不应展示这个说明'), findsNothing);
      expect(find.textContaining('正式附件'), findsNothing);
      expect(find.textContaining('奖励金额'), findsNothing);
      expect(find.textContaining('单位平方面积金额'), findsNothing);
      expect(find.text('当前组织项目资产'), findsNothing);
      expect(find.text('页面定位'), findsNothing);
      expect(find.textContaining('不会伪造成仍有项目在推进'), findsNothing);
      expect(find.textContaining('不会把计划结束时间误解释成历史归档'), findsNothing);
    },
  );

  testWidgets(
    'my project detail consumes publicProject and privateProgress without code leakage',
    (WidgetTester tester) async {
      final exhibitionHandlers =
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/my/projects/my-project-1':
                (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: <String, Object?>{
                      'publicProject': _publicProjectDetail(
                        projectId: 'my-project-1',
                        projectNo: 'MY-001',
                        title: '单项目私域承接',
                        budgetAmount: 2600,
                        areaSqm: 380,
                        buildingTypeRemark: '医疗器械展区主舞台与灯光联动搭建',
                        provinceCode: '510000',
                        provinceName: '四川',
                        cityCode: '510100',
                        cityName: '成都',
                        districtCode: '510107',
                        districtName: '武侯区',
                        detailAddress: '世纪城新国际会展中心 6 号馆西门',
                        scopeSummary: '主舞台、器械展区与接待区同步进场',
                        plannedStartAt: '2026-04-10',
                        plannedEndAt: '2026-04-18',
                        scheduleDetail: '4 月 10 日晚进场，4 月 18 日撤场',
                        description: '这里继续承接项目说明文案。',
                        viewerProjectRelation: 'non_owner',
                      ),
                      'privateProgress': _privateProgress(
                        hasAcceptedOrder: false,
                        formalCompletionStatus: 'not_formally_completed',
                        evaluationStatus: 'not_eligible',
                      ),
                    },
                  );
                },
          };

      await tester.pumpWidget(
        _buildApp(
          exhibitionHandlers: exhibitionHandlers,
          initialRoute: ExhibitionRoutes.myProjectDetailWithProjectId(
            'my-project-1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('项目编号：MY-001'));
      expect(find.text('项目名称：单项目私域承接'), findsOneWidget);
      expect(find.text('建筑类型：展览装修'), findsOneWidget);
      expect(find.text('预算金额：¥2600'), findsOneWidget);
      expect(find.text('项目面积：380 ㎡'), findsOneWidget);
      expect(find.text('类型备注：医疗器械展区主舞台与灯光联动搭建'), findsOneWidget);
      expect(find.text('省：四川'), findsOneWidget);
      expect(find.text('市：成都'), findsOneWidget);
      expect(find.text('区县：武侯区'), findsOneWidget);
      expect(find.text('详细地址：世纪城新国际会展中心 6 号馆西门'), findsOneWidget);
      expect(find.text('范围说明：主舞台、器械展区与接待区同步进场'), findsOneWidget);
      expect(find.text('计划结束日期：2026-04-18'), findsOneWidget);
      expect(find.text('项目地点与安排'), findsOneWidget);
      await scrollTo(tester, find.text('项目说明'));
      expect(find.text('项目说明'), findsOneWidget);
      await scrollTo(tester, find.text('当前进度'));
      expect(find.text('当前进度'), findsOneWidget);
      await scrollTo(tester, find.text('继续竞标'));
      expect(find.text('继续竞标'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '管理当前'), findsNothing);
      await scrollTo(tester, find.text('是否已接单：未接单'));
      expect(find.text('进度摘要：未接单，尚未正式完结，暂不可评价。'), findsOneWidget);
      expect(find.text('是否已接单：未接单'), findsOneWidget);
      expect(find.text('当前订单状态：当前暂未提供'), findsOneWidget);
      expect(find.text('正式完结：尚未正式完结'), findsOneWidget);
      expect(find.text('评价状态：暂不可评价'), findsOneWidget);
      expect(find.text('510000'), findsNothing);
      expect(find.text('510100'), findsNothing);
      expect(find.text('510107'), findsNothing);
      expect(find.textContaining('正式附件'), findsNothing);
      expect(find.textContaining('奖励金额'), findsNothing);
      expect(find.textContaining('单位平方面积金额'), findsNothing);
      expect(find.text('状态说明'), findsNothing);
      expect(find.text('地点承接'), findsNothing);
      expect(find.textContaining('页面不会伪造已填写状态'), findsNothing);
    },
  );

  testWidgets(
    'my project detail switches owner surface into local manage-current shell',
    (WidgetTester tester) async {
      final exhibitionHandlers =
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/my/projects/my-project-owner':
                (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: <String, Object?>{
                      'publicProject': _publicProjectDetail(
                        projectId: 'my-project-owner',
                        projectNo: 'MY-OWNER-1',
                        title: '当前组织发布项目',
                        budgetAmount: 3600,
                        state: 'published',
                        viewerProjectRelation: 'owner',
                      ),
                      'privateProgress': _privateProgress(
                        hasAcceptedOrder: false,
                        formalCompletionStatus: 'not_formally_completed',
                        evaluationStatus: 'not_eligible',
                      ),
                    },
                  );
                },
          };

      await tester.pumpWidget(
        _buildApp(
          exhibitionHandlers: exhibitionHandlers,
          initialRoute: ExhibitionRoutes.myProjectDetailWithProjectId(
            'my-project-owner',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await scrollTo(tester, find.widgetWithText(FilledButton, '管理当前'));
      expect(find.widgetWithText(FilledButton, '管理当前'), findsOneWidget);
      expect(find.text('继续竞标'), findsNothing);

      await tester.tap(find.widgetWithText(FilledButton, '管理当前'));
      await tester.pumpAndSettle();

      expect(find.text('推广此项目'), findsOneWidget);
      expect(find.text('编辑'), findsOneWidget);
      expect(find.text('下架'), findsOneWidget);
      expect(find.text('删除此项目'), findsOneWidget);

      await tester.tapAt(const Offset(12, 12));
      await tester.pumpAndSettle();

      expect(find.text('推广此项目'), findsNothing);
      expect(find.text('删除此项目'), findsNothing);
    },
  );

  testWidgets(
    'my project progress mapping keeps formal completion and evaluation semantics exact',
    (WidgetTester tester) async {
      final exhibitionHandlers =
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/my/projects/my-project-2':
                (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: <String, Object?>{
                      'publicProject': _publicProjectDetail(
                        projectId: 'my-project-2',
                        projectNo: 'MY-002',
                        title: '评价准入项目',
                        budgetAmount: 3200,
                        plannedEndAt: '2026-03-20',
                      ),
                      'privateProgress': _privateProgress(
                        hasAcceptedOrder: true,
                        orderStatus: 'active',
                        contractStatus: 'active',
                        fulfillmentStatus: 'submitted',
                        acceptanceStatus: 'rechecked',
                        formalCompletionStatus: 'formally_completed',
                        evaluationStatus: 'eligible',
                      ),
                    },
                  );
                },
          };

      await tester.pumpWidget(
        _buildApp(
          exhibitionHandlers: exhibitionHandlers,
          initialRoute: ExhibitionRoutes.myProjectDetailWithProjectId(
            'my-project-2',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('正式完结：已正式完结'));
      expect(find.text('正式完结：已正式完结'), findsOneWidget);
      expect(find.text('评价状态：待评价'), findsOneWidget);
      expect(find.text('当前订单状态：订单进行中'), findsOneWidget);
      expect(find.text('合同状态：合同进行中'), findsOneWidget);
      expect(find.text('履约进度：已提交'), findsOneWidget);
      expect(find.text('验收状态：已复检'), findsOneWidget);
      expect(find.text('评价状态：已评价'), findsNothing);
    },
  );
}
