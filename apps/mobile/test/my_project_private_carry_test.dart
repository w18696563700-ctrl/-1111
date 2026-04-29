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

Map<String, Object?> _publicProjectListItem({
  required String projectId,
  required String projectNo,
  required String title,
  required num budgetAmount,
  String buildingType = 'exhibition',
  String state = 'published',
  String summaryHeading = '当前项目已保存',
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
  String summaryHeading = '当前项目已保存',
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

Map<String, Object?> _myBidItem({
  required String bidId,
  required String projectId,
  required String projectNo,
  required String projectTitle,
  required num quoteAmount,
  required String proposalSummaryPreview,
  required String submittedAt,
  required String outcomeState,
  required bool canOpenBidThread,
  required bool canOpenBidResult,
}) {
  return <String, Object?>{
    'bidId': bidId,
    'projectId': projectId,
    'projectNo': projectNo,
    'projectTitle': projectTitle,
    'quoteAmount': quoteAmount,
    'proposalSummaryPreview': proposalSummaryPreview,
    'submittedAt': submittedAt,
    'outcomeState': outcomeState,
    'canOpenBidThread': canOpenBidThread,
    'canOpenBidResult': canOpenBidResult,
  };
}

Map<String, Object?> _attachmentListResponse(
  String projectId,
  List<Map<String, Object?>> attachments,
) {
  return <String, Object?>{'projectId': projectId, 'attachments': attachments};
}

Map<String, Object?> _publicResourceListResponse(
  List<Map<String, Object?>> resources,
) {
  return <String, Object?>{'resources': resources};
}

Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
_forumHandlers() {
  AppApiResponse emptyPaged(AppApiRequest request) => AppApiResponse(
    statusCode: 200,
    uri: request.uri,
    body: const <String, Object?>{
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

ExhibitionMobileApp _buildApp({
  required Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
  exhibitionHandlers,
  String initialRoute = ExhibitionRoutes.myProjectList,
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
        transport: FakeAppApiTransport(handlers: const {}),
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

Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await _scrollTo(tester, finder.first);
  await tester.tap(finder.first);
  await tester.pumpAndSettle();
}

Future<void> _tapChoiceChipLabel(WidgetTester tester, String label) async {
  final chipFinder = find.widgetWithText(ChoiceChip, label);
  await _scrollTo(tester, chipFinder.first);
  await tester.tap(chipFinder.first);
  await tester.pumpAndSettle();
}

Map<String, Object?> _projectMeta(String projectId) {
  if (projectId.contains('draft')) {
    return <String, Object?>{
      'title': '草稿项目',
      'budgetAmount': 1200,
      'areaSqm': 180,
      'provinceCode': '510000',
      'provinceName': '四川',
      'cityCode': '510100',
      'cityName': '成都',
    };
  }
  if (projectId.contains('submitted')) {
    return <String, Object?>{
      'title': '预发布项目',
      'budgetAmount': 1600,
      'areaSqm': 200,
      'provinceCode': '310000',
      'provinceName': '上海',
      'cityCode': '310100',
      'cityName': '上海',
    };
  }
  if (projectId.contains('published')) {
    return <String, Object?>{
      'title': '已发布项目',
      'budgetAmount': 2200,
      'areaSqm': 320,
      'provinceCode': '110000',
      'provinceName': '北京',
      'cityCode': '110100',
      'cityName': '北京',
    };
  }
  if (projectId.contains('active')) {
    return <String, Object?>{
      'title': '进行中项目',
      'budgetAmount': 2800,
      'areaSqm': 420,
      'provinceCode': '330000',
      'provinceName': '浙江',
      'cityCode': '330100',
      'cityName': '杭州',
    };
  }
  if (projectId.contains('archived')) {
    return <String, Object?>{
      'title': '已归档项目',
      'budgetAmount': 1400,
      'areaSqm': 160,
      'provinceCode': '320000',
      'provinceName': '江苏',
      'cityCode': '320100',
      'cityName': '南京',
    };
  }
  return <String, Object?>{
    'title': '项目 $projectId',
    'budgetAmount': 1999,
    'areaSqm': 260,
    'provinceCode': '440000',
    'provinceName': '广东',
    'cityCode': '440100',
    'cityName': '广州',
  };
}

String _projectNo(String projectId) {
  return 'MY-${projectId.replaceAll('-', '_').toUpperCase()}';
}

Map<String, Object?> _privateProgressForState(String state) {
  final isActive = state == 'converted_to_order' || state == 'awarded';
  return _privateProgress(
    hasAcceptedOrder: state == 'converted_to_order',
    orderStatus: state == 'converted_to_order' ? 'active' : null,
    contractStatus: state == 'converted_to_order' ? 'active' : null,
    fulfillmentStatus: isActive ? 'submitted' : null,
    acceptanceStatus: isActive ? 'rechecked' : null,
    formalCompletionStatus: state == 'converted_to_order'
        ? 'formally_completed'
        : 'not_formally_completed',
    evaluationStatus: state == 'converted_to_order'
        ? 'eligible'
        : 'not_eligible',
  );
}

Map<String, Object?> _publicProjectListForState({
  required String projectId,
  required String state,
}) {
  final meta = _projectMeta(projectId);
  return _publicProjectListItem(
    projectId: projectId,
    projectNo: _projectNo(projectId),
    title: meta['title']! as String,
    budgetAmount: meta['budgetAmount']! as num,
    state: state,
    areaSqm: meta['areaSqm'] as num?,
    provinceCode: meta['provinceCode'] as String?,
    provinceName: meta['provinceName'] as String?,
    cityCode: meta['cityCode'] as String?,
    cityName: meta['cityName'] as String?,
  );
}

Map<String, Object?> _publicProjectDetailForState({
  required String projectId,
  required String state,
}) {
  final meta = _projectMeta(projectId);
  return _publicProjectDetail(
    projectId: projectId,
    projectNo: _projectNo(projectId),
    title: meta['title']! as String,
    budgetAmount: meta['budgetAmount']! as num,
    state: state,
    areaSqm: meta['areaSqm'] as num?,
    provinceCode: meta['provinceCode'] as String?,
    provinceName: meta['provinceName'] as String?,
    cityCode: meta['cityCode'] as String?,
    cityName: meta['cityName'] as String?,
    districtCode: '510107',
    districtName: '武侯区',
    detailAddress: '世纪城新国际会展中心 6 号馆西门',
    scopeSummary: '主舞台、器械展区与接待区同步进场',
    plannedStartAt: '2026-04-10',
    plannedEndAt: '2026-04-18',
    scheduleDetail: '4 月 10 日晚进场，4 月 18 日撤场',
    description: '这里继续承接项目说明文案。',
    buildingTypeRemark: '医疗器械展区主舞台与灯光联动搭建',
    viewerProjectRelation: 'owner',
  );
}

Map<String, Object?> _myProjectListBodyFromStates(Map<String, String> states) {
  final ongoingProjects = <Object?>[];
  final historicalProjects = <Object?>[];
  final entries = states.entries.toList()
    ..sort((MapEntry<String, String> left, MapEntry<String, String> right) {
      return left.key.compareTo(right.key);
    });
  for (final entry in entries) {
    final item = _myProjectItem(
      publicProject: _publicProjectListForState(
        projectId: entry.key,
        state: entry.value,
      ),
      privateSummary: _privateProgressForState(entry.value),
    );
    if (entry.value == 'archived' ||
        entry.value == 'awarded' ||
        entry.value == 'converted_to_order') {
      historicalProjects.add(item);
    } else {
      ongoingProjects.add(item);
    }
  }
  return <String, Object?>{
    'ongoingProjects': ongoingProjects,
    'historicalProjects': historicalProjects,
  };
}

Finder _entityCardByTitle(String title) {
  return find.ancestor(
    of: find.text(title),
    matching: find.byWidgetPredicate(
      (Widget widget) => widget.runtimeType.toString() == '_EntityCard',
    ),
  );
}

Future<void> _tapEntityCardAction(
  WidgetTester tester, {
  required String title,
  required String actionLabel,
}) async {
  final cardFinder = _entityCardByTitle(title).first;
  final primaryButtonFinder = find.descendant(
    of: cardFinder,
    matching: find.widgetWithText(FilledButton, actionLabel),
  );
  final secondaryButtonFinder = find.descendant(
    of: cardFinder,
    matching: find.widgetWithText(OutlinedButton, actionLabel),
  );
  final buttonFinder = primaryButtonFinder.evaluate().isNotEmpty
      ? primaryButtonFinder
      : secondaryButtonFinder;
  await _scrollTo(tester, buttonFinder.first);
  await tester.tap(buttonFinder.first);
  await tester.pumpAndSettle();
}

typedef _AppHandler = Future<AppApiResponse> Function(AppApiRequest request);

Map<String, _AppHandler> _mutableMyProjectHandlers({
  required Map<String, String> projectStates,
  List<Map<String, Object?>> myBidItems = const <Map<String, Object?>>[],
  String? failingLifecyclePath,
  String? failingLifecycleCode,
  String? failingLifecycleMessage,
  List<String>? pricingCalls,
  void Function(String projectId)? onDelete,
}) {
  Future<AppApiResponse> lifecycleSuccess(
    AppApiRequest request, {
    required String nextState,
    required String invalidCode,
    required String invalidMessage,
    required bool Function(String state) allow,
  }) async {
    final body = request.body as Map<String, Object?>;
    final projectId = body['projectId'] as String?;
    final state = projectId == null ? null : projectStates[projectId];
    if (projectId == null || state == null) {
      return AppApiResponse(
        statusCode: 404,
        uri: request.uri,
        body: const <String, Object?>{
          'errorCode': 'AUTH_RESOURCE_UNAVAILABLE',
          'message': '当前项目不可用。',
        },
      );
    }
    if (request.canonicalPath == failingLifecyclePath) {
      return AppApiResponse(
        statusCode: 409,
        uri: request.uri,
        body: <String, Object?>{
          'errorCode': failingLifecycleCode ?? invalidCode,
          'message': failingLifecycleMessage ?? invalidMessage,
        },
      );
    }
    if (!allow(state)) {
      return AppApiResponse(
        statusCode: 409,
        uri: request.uri,
        body: <String, Object?>{
          'errorCode': invalidCode,
          'message': invalidMessage,
        },
      );
    }

    projectStates[projectId] = nextState;
    return AppApiResponse(
      statusCode: 202,
      uri: request.uri,
      body: <String, Object?>{'projectId': projectId, 'state': nextState},
    );
  }

  final handlers = <String, _AppHandler>{
    'GET /api/app/my/projects': (AppApiRequest request) async => AppApiResponse(
      statusCode: 200,
      uri: request.uri,
      body: _myProjectListBodyFromStates(projectStates),
    ),
    'GET /api/app/my/bids': (AppApiRequest request) async => AppApiResponse(
      statusCode: 200,
      uri: request.uri,
      body: <String, Object?>{'items': myBidItems},
    ),
    'GET /api/app/project/public-resources': (AppApiRequest request) async =>
        AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: _publicResourceListResponse(const <Map<String, Object?>>[
            {
              'resourceId': 'resource-contract-1',
              'resourceCategory': 'contract_template',
              'title': '标准合同模板',
              'summary': '用于项目发布后的合同模板参考。',
              'fileAssetId': 'file-resource-contract-1',
              'fileName': 'standard-contract-template.pdf',
              'mimeType': 'application/pdf',
              'visibility': 'app_shared',
              'sortOrder': 0,
              'publishedAt': '2026-04-14T09:30:00Z',
            },
            {
              'resourceId': 'resource-process-1',
              'resourceCategory': 'process_guide',
              'title': '发布流程图与说明',
              'summary': '帮助理解项目发布与续接流程。',
              'fileAssetId': 'file-resource-process-1',
              'fileName': 'publish-process-guide.pdf',
              'mimeType': 'application/pdf',
              'visibility': 'app_shared',
              'sortOrder': 1,
              'publishedAt': '2026-04-14T09:40:00Z',
            },
            {
              'resourceId': 'resource-other-1',
              'resourceCategory': 'other_resource',
              'title': '公共资料汇编',
              'summary': '用于补充平台共享公共资料。',
              'fileAssetId': 'file-resource-other-1',
              'fileName': 'public-resource-bundle.docx',
              'mimeType':
                  'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
              'visibility': 'app_shared',
              'sortOrder': 2,
              'publishedAt': '2026-04-14T09:50:00Z',
            },
          ]),
        ),
    'POST /api/app/project/withdraw': (AppApiRequest request) {
      return lifecycleSuccess(
        request,
        nextState: 'draft',
        invalidCode: 'PROJECT_WITHDRAW_INVALID',
        invalidMessage: '当前项目尚未提交，暂不支持撤回到草稿。',
        allow: (String state) => state == 'submitted',
      );
    },
    'POST /api/app/project/publish': (AppApiRequest request) {
      return lifecycleSuccess(
        request,
        nextState: 'published',
        invalidCode: 'PROJECT_PUBLISH_INVALID',
        invalidMessage: '当前项目尚未进入预发布列表，暂不支持正式发布。',
        allow: (String state) => state == 'submitted',
      );
    },
    'POST /api/app/project/archive': (AppApiRequest request) {
      return lifecycleSuccess(
        request,
        nextState: 'archived',
        invalidCode: 'PROJECT_ARCHIVE_INVALID',
        invalidMessage: '当前项目尚未提交，暂不支持作废归档。',
        allow: (String state) => state == 'submitted',
      );
    },
    'POST /api/app/project/close': (AppApiRequest request) {
      return lifecycleSuccess(
        request,
        nextState: 'archived',
        invalidCode: 'PROJECT_CLOSE_INVALID',
        invalidMessage: '当前项目状态暂不支持下架关闭。',
        allow: (String state) => state == 'published',
      );
    },
    'POST /api/app/project/withdraw-published': (AppApiRequest request) {
      return lifecycleSuccess(
        request,
        nextState: 'submitted',
        invalidCode: 'PROJECT_WITHDRAW_PUBLISHED_INVALID',
        invalidMessage: '当前项目状态暂不支持撤回到预发布列表。',
        allow: (String state) => state == 'published',
      );
    },
    'POST /api/app/project/discard-submitted': (AppApiRequest request) {
      return lifecycleSuccess(
        request,
        nextState: 'archived',
        invalidCode: 'PROJECT_SUBMITTED_DISCARD_INVALID',
        invalidMessage: '当前项目状态暂不支持作废删除。',
        allow: (String state) => state == 'submitted',
      );
    },
    'POST /api/app/project/cancellation/request':
        (AppApiRequest request) async {
          final body = request.body as Map<String, Object?>;
          final projectId = body['projectId'] as String?;
          final state = projectId == null ? null : projectStates[projectId];
          if (projectId == null ||
              state == null ||
              state != 'converted_to_order') {
            return AppApiResponse(
              statusCode: 409,
              uri: request.uri,
              body: const <String, Object?>{
                'errorCode': 'PROJECT_EXIT_INVALID_STATE',
                'message': '当前项目暂不支持从这里推进取消申请。',
              },
            );
          }
          return AppApiResponse(
            statusCode: 202,
            uri: request.uri,
            body: <String, Object?>{
              'projectId': projectId,
              'exitCaseId': 'exit-$projectId',
              'projectState': state,
              'caseStatus': 'requested',
              'action': 'request_cancellation',
            },
          );
        },
    'POST /api/app/project/breach/record-publisher':
        (AppApiRequest request) async {
          final body = request.body as Map<String, Object?>;
          final projectId = body['projectId'] as String?;
          final state = projectId == null ? null : projectStates[projectId];
          return AppApiResponse(
            statusCode: state == 'converted_to_order' ? 202 : 409,
            uri: request.uri,
            body: state == 'converted_to_order'
                ? <String, Object?>{
                    'projectId': projectId,
                    'exitCaseId': 'exit-publisher-$projectId',
                    'projectState': state,
                    'caseStatus': 'recorded',
                    'breachParty': 'publisher',
                    'action': 'record_publisher_breach',
                    'creditImpactCandidate': true,
                  }
                : const <String, Object?>{
                    'errorCode': 'PROJECT_EXIT_INVALID_STATE',
                    'message': '当前项目暂不支持从这里记录违约。',
                  },
          );
        },
    'POST /api/app/project/breach/record-factory':
        (AppApiRequest request) async {
          final body = request.body as Map<String, Object?>;
          final projectId = body['projectId'] as String?;
          final state = projectId == null ? null : projectStates[projectId];
          return AppApiResponse(
            statusCode: state == 'converted_to_order' ? 202 : 409,
            uri: request.uri,
            body: state == 'converted_to_order'
                ? <String, Object?>{
                    'projectId': projectId,
                    'exitCaseId': 'exit-factory-$projectId',
                    'projectState': state,
                    'caseStatus': 'recorded',
                    'breachParty': 'factory',
                    'action': 'record_factory_breach',
                    'creditImpactCandidate': true,
                  }
                : const <String, Object?>{
                    'errorCode': 'PROJECT_EXIT_INVALID_STATE',
                    'message': '当前项目暂不支持从这里记录违约。',
                  },
          );
        },
  };

  for (final projectId in projectStates.keys.toList()) {
    handlers['GET /api/app/my/projects/$projectId'] =
        (AppApiRequest request) async {
          final state = projectStates[projectId];
          if (state == null) {
            return AppApiResponse(
              statusCode: 404,
              uri: request.uri,
              body: const <String, Object?>{
                'errorCode': 'AUTH_RESOURCE_UNAVAILABLE',
                'message': '当前项目不可用。',
              },
            );
          }

          return AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: <String, Object?>{
              'publicProject': _publicProjectDetailForState(
                projectId: projectId,
                state: state,
              ),
              'privateProgress': _privateProgressForState(state),
            },
          );
        };
    handlers['GET /api/app/my/projects/$projectId/attachments'] =
        (AppApiRequest request) async {
          final attachments =
              projectId == 'project-publish-flow' ||
                  projectId == 'project-sincerity-pending'
              ? <Map<String, Object?>>[
                  <String, Object?>{
                    'attachmentId': 'attachment-effect-1',
                    'projectId': projectId,
                    'fileAssetId': 'file-effect-1',
                    'fileName': '必传效果图.png',
                    'attachmentKind': 'effect_image',
                    'mimeType': 'image/png',
                    'visibility': 'owner_private',
                    'sortOrder': 0,
                    'createdAt': '2026-04-13T16:19:00Z',
                  },
                ]
              : const <Map<String, Object?>>[];
          return AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: _attachmentListResponse(projectId, attachments),
          );
        };
    handlers['GET ${ExhibitionCanonicalPaths.projectPricingSummary(projectId)}'] =
        (AppApiRequest request) async {
          pricingCalls?.add(request.canonicalPath);
          return AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: <String, Object?>{
              'projectId': projectId,
              'publisherPricing': <String, Object?>{
                'authenticitySincerityRequired': true,
                'authenticitySincerityAmount': '200.00',
                'authenticitySincerityStatus': null,
                'publishGateStatus': 'required',
              },
              'readOnly': true,
              'updatedAt': '2026-04-26T09:00:00Z',
            },
          );
        };
    handlers['POST ${ExhibitionCanonicalPaths.projectAuthenticitySincerityOrders(projectId)}'] =
        (AppApiRequest request) async {
          pricingCalls?.add(request.canonicalPath);
          return AppApiResponse(
            statusCode: 201,
            uri: request.uri,
            body: <String, Object?>{
              'orderId': 'sincerity-$projectId',
              'orderStatus': 'pending_payment',
              'amount': '200.00',
              'currency': 'CNY',
              'channelCandidates': const <Object?>['alipay_candidate'],
              'updatedAt': '2026-04-26T09:01:00Z',
            },
          );
        };
    handlers['POST ${ExhibitionCanonicalPaths.projectAuthenticitySincerityPayInit(projectId, 'sincerity-$projectId')}'] =
        (AppApiRequest request) async {
          pricingCalls?.add(request.canonicalPath);
          return AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: <String, Object?>{
              'paymentInitStatus': 'started',
              'orderId': 'sincerity-$projectId',
              'paymentReferenceId': 'pay-$projectId',
              'callbackAwaiting': true,
              'updatedAt': '2026-04-26T09:02:00Z',
            },
          );
        };
    handlers['GET ${ExhibitionCanonicalPaths.projectAuthenticitySincerityOrderStatus(projectId, 'sincerity-$projectId')}'] =
        (AppApiRequest request) async {
          pricingCalls?.add(request.canonicalPath);
          return AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: <String, Object?>{
              'orderId': 'sincerity-$projectId',
              'orderStatus': projectId == 'project-sincerity-pending'
                  ? 'pending_payment'
                  : 'paid',
              'amount': '200.00',
              'currency': 'CNY',
              'updatedAt': '2026-04-26T09:03:00Z',
            },
          );
        };
    handlers['DELETE /api/app/my/projects/$projectId'] =
        (AppApiRequest request) async {
          onDelete?.call(projectId);
          projectStates.remove(projectId);
          return AppApiResponse(
            statusCode: 202,
            uri: request.uri,
            body: <String, Object?>{'projectId': projectId, 'state': 'deleted'},
          );
        };
  }

  return handlers;
}

void main() {
  testWidgets('我的项目列表按四阶段切换并把已归档项目放到只读区', (WidgetTester tester) async {
    final handlers = _mutableMyProjectHandlers(
      projectStates: <String, String>{
        'project-draft-1': 'draft',
        'project-submitted-1': 'submitted',
        'project-published-1': 'published',
        'project-active-1': 'converted_to_order',
        'project-archived-1': 'archived',
      },
    );

    await tester.pumpWidget(_buildApp(exhibitionHandlers: handlers));
    await tester.pumpAndSettle();

    expect(find.text('草稿 · 1 个'), findsOneWidget);
    expect(find.text('已归档 · 1 个'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, '草稿 · 1'), findsNothing);
    expect(find.text('预发布列表 · 1'), findsOneWidget);
    expect(find.text('竞标中 · 1'), findsOneWidget);
    expect(find.text('进行中 · 1'), findsOneWidget);
    expect(find.textContaining('当前只显示预发布列表阶段'), findsOneWidget);
    await _tapVisible(tester, find.text('草稿 · 1 个'));
    expect(find.text('草稿列表'), findsOneWidget);
    expect(find.textContaining('当前只显示草稿阶段'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '继续编辑'), findsOneWidget);

    await _tapChoiceChipLabel(tester, '预发布列表 · 1');
    expect(find.text('预发布项目'), findsOneWidget);
    expect(find.text('草稿项目'), findsNothing);

    await _tapChoiceChipLabel(tester, '竞标中 · 1');
    expect(find.text('竞标中'), findsWidgets);
    expect(find.text('预发布项目'), findsNothing);

    await _tapChoiceChipLabel(tester, '进行中 · 1');
    expect(find.text('进行中项目'), findsOneWidget);
    expect(find.text('当前阶段：竞标中'), findsNothing);

    await _tapVisible(tester, find.text('已归档 · 1 个'));
    expect(find.text('已归档列表'), findsOneWidget);
    expect(find.text('已归档项目'), findsOneWidget);
  });

  testWidgets('我的项目先分成我的发布和我的竞标', (WidgetTester tester) async {
    final handlers = _mutableMyProjectHandlers(
      projectStates: <String, String>{
        'project-draft-1': 'draft',
        'project-published-1': 'published',
      },
      myBidItems: <Map<String, Object?>>[
        _myBidItem(
          bidId: 'bid-1',
          projectId: 'project-published-1',
          projectNo: 'BID-PROJECT-1',
          projectTitle: '供应商竞标记录',
          quoteAmount: 8800,
          proposalSummaryPreview: '报价方案已提交，等待后续沟通。',
          submittedAt: '2026-04-20T10:00:00Z',
          outcomeState: 'published',
          canOpenBidThread: true,
          canOpenBidResult: false,
        ),
      ],
    );

    await tester.pumpWidget(_buildApp(exhibitionHandlers: handlers));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ChoiceChip, '我的发布'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, '我的竞标'), findsOneWidget);
    expect(find.text('草稿 · 1 个'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, '我的竞标'));
    await tester.pumpAndSettle();

    expect(find.text('当前竞标列表暂未接通'), findsNothing);
    expect(find.text('供应商竞标记录'), findsOneWidget);
    expect(find.text('沟通与投标'), findsOneWidget);
    expect(find.text('草稿 · 1 个'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, '我的发布'));
    await tester.pumpAndSettle();

    expect(find.text('草稿 · 1 个'), findsOneWidget);
  });

  testWidgets('我的项目路由可以直接钉到我的竞标 workspace', (WidgetTester tester) async {
    final handlers = _mutableMyProjectHandlers(
      projectStates: <String, String>{'project-published-1': 'published'},
      myBidItems: <Map<String, Object?>>[
        _myBidItem(
          bidId: 'bid-1',
          projectId: 'project-published-1',
          projectNo: 'BID-PROJECT-1',
          projectTitle: '供应商竞标记录',
          quoteAmount: 8800,
          proposalSummaryPreview: '报价方案已提交，等待后续沟通。',
          submittedAt: '2026-04-20T10:00:00Z',
          outcomeState: 'published',
          canOpenBidThread: true,
          canOpenBidResult: false,
        ),
      ],
    );

    await tester.pumpWidget(
      _buildApp(
        exhibitionHandlers: handlers,
        initialRoute: ExhibitionRoutes.myProjectListWithWorkspace('bids'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('供应商竞标记录'), findsOneWidget);
    expect(find.text('沟通与投标'), findsOneWidget);
    expect(find.text('草稿 · 1 个'), findsNothing);
  });

  testWidgets('我的项目列表卡片显示阶段、下一步和归档只读说明', (WidgetTester tester) async {
    final handlers = _mutableMyProjectHandlers(
      projectStates: <String, String>{
        'project-draft-1': 'draft',
        'project-submitted-1': 'submitted',
        'project-published-1': 'published',
        'project-active-1': 'converted_to_order',
        'project-archived-1': 'archived',
      },
    );

    await tester.pumpWidget(_buildApp(exhibitionHandlers: handlers));
    await tester.pumpAndSettle();

    await _tapVisible(tester, find.text('草稿 · 1 个'));
    expect(find.text('草稿列表'), findsOneWidget);
    expect(find.text('当前阶段：草稿'), findsOneWidget);
    expect(find.text('当前下一步：继续编辑 / 删除此项目'), findsOneWidget);

    await _tapChoiceChipLabel(tester, '预发布列表 · 1');
    expect(find.text('当前阶段：预发布列表'), findsOneWidget);
    expect(
      find.text('当前下一步：查看详情 / 先补资料后确认发布 / 返回草稿继续编辑 / 作废删除'),
      findsOneWidget,
    );
    expect(find.widgetWithText(FilledButton, '补资料后确认发布'), findsOneWidget);

    await _tapChoiceChipLabel(tester, '竞标中 · 1');
    expect(find.text('当前阶段：竞标中'), findsOneWidget);
    expect(find.text('当前下一步：查看详情 / 补充资料 / 撤回到预发布'), findsOneWidget);

    await _tapChoiceChipLabel(tester, '进行中 · 1');
    expect(find.text('当前阶段：进行中'), findsOneWidget);
    expect(find.text('当前下一步：查看详情 / 发起取消 / 记录违约'), findsOneWidget);

    await _tapVisible(tester, find.text('已归档 · 1 个'));
    expect(find.text('已归档列表'), findsOneWidget);
    expect(find.text('当前阶段：已归档'), findsOneWidget);
    expect(find.text('当前下一步：查看详情 / 当前只读'), findsOneWidget);
  });

  testWidgets('草稿详情显示继续编辑、删除并隐藏说明型区块', (WidgetTester tester) async {
    final handlers = _mutableMyProjectHandlers(
      projectStates: <String, String>{'project-draft-detail': 'draft'},
    );

    await tester.pumpWidget(
      _buildApp(
        exhibitionHandlers: handlers,
        initialRoute: ExhibitionRoutes.myProjectDetailWithProjectId(
          'project-draft-detail',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _scrollTo(tester, find.text('当前阶段动作'));
    expect(find.widgetWithText(FilledButton, '继续编辑'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, '删除此项目'), findsOneWidget);
    expect(find.text('当前展示：已接通内容'), findsNothing);
    expect(find.text('当前提示'), findsNothing);
    expect(find.text('已保存的地点与安排'), findsNothing);
    expect(find.text('已保存的项目说明'), findsNothing);
    expect(find.text('当前阶段补充信息'), findsNothing);
  });

  testWidgets('预发布列表详情显示正式发布与回退动作', (WidgetTester tester) async {
    final handlers = _mutableMyProjectHandlers(
      projectStates: <String, String>{'project-submitted-detail': 'submitted'},
    );

    await tester.pumpWidget(
      _buildApp(
        exhibitionHandlers: handlers,
        initialRoute: ExhibitionRoutes.myProjectDetailWithProjectId(
          'project-submitted-detail',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('预发布补齐资料并发布页', findRichText: true),
      findsOneWidget,
    );
    await _scrollTo(tester, find.text('当前阶段动作'));
    expect(find.widgetWithText(FilledButton, '检查无误，确定发布'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, '返回草稿继续编辑'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, '作废删除'), findsOneWidget);
    expect(find.text('发布前确认'), findsOneWidget);
    expect(find.textContaining('预发布阶段已开放报价依据资料'), findsOneWidget);
    expect(find.textContaining('补充效果图、尺寸图 / 施工图'), findsWidgets);
    expect(find.text('删除此项目'), findsNothing);
  });

  testWidgets('已发布详情展示补资料和撤回到预发布入口', (WidgetTester tester) async {
    final handlers = _mutableMyProjectHandlers(
      projectStates: <String, String>{'project-published-detail': 'published'},
    );

    await tester.pumpWidget(
      _buildApp(
        exhibitionHandlers: handlers,
        initialRoute: ExhibitionRoutes.myProjectDetailWithProjectId(
          'project-published-detail',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('已发布页', findRichText: true), findsOneWidget);
    expect(find.text('项目沟通'), findsNothing);
    expect(find.text('项目澄清'), findsNothing);
    expect(find.widgetWithText(OutlinedButton, '展开项目基础信息'), findsOneWidget);
    expect(find.textContaining('正式完结补充'), findsNothing);
    expect(find.textContaining('请补充五类报价依据资料'), findsOneWidget);
    await tester.tap(find.widgetWithText(OutlinedButton, '展开项目基础信息'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(OutlinedButton, '收起项目基础信息'), findsOneWidget);
    expect(find.textContaining('正式完结补充'), findsOneWidget);
    await _scrollTo(tester, find.text('当前阶段动作'));
    expect(find.text('当前阶段动作'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '补充报价依据资料'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, '撤回到预发布'), findsOneWidget);
    expect(find.text('下架关闭'), findsNothing);
    await _scrollTo(tester, find.text('报价依据资料'));
    expect(find.text('报价依据资料'), findsOneWidget);
    expect(find.textContaining('效果图、尺寸图 / 施工图、材质图 / 材料样板'), findsWidgets);
    expect(find.textContaining('这里用于补充项目正式文书资料'), findsNothing);
    expect(find.text('当前说明'), findsNothing);
    await _scrollTo(tester, find.text('公共资源下载区'));
    expect(find.text('公共资源下载区'), findsOneWidget);
    expect(find.text('可下载平台共享模板与公共资料。'), findsOneWidget);
    expect(find.text('删除此项目'), findsNothing);
  });

  testWidgets('已归档详情只保留只读动作', (WidgetTester tester) async {
    final handlers = _mutableMyProjectHandlers(
      projectStates: <String, String>{'project-archived-detail': 'archived'},
    );

    await tester.pumpWidget(
      _buildApp(
        exhibitionHandlers: handlers,
        initialRoute: ExhibitionRoutes.myProjectDetailWithProjectId(
          'project-archived-detail',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _scrollTo(tester, find.text('当前阶段动作'));
    expect(find.widgetWithText(OutlinedButton, '当前已归档，仅支持查看'), findsOneWidget);
    expect(find.text('继续编辑'), findsNothing);
    expect(find.text('删除此项目'), findsNothing);
  });

  testWidgets('预发布列表返回草稿继续编辑后详情进入草稿承接', (WidgetTester tester) async {
    final projectStates = <String, String>{
      'project-draft-1': 'draft',
      'project-withdraw-flow': 'submitted',
    };
    final handlers = _mutableMyProjectHandlers(projectStates: projectStates);

    await tester.pumpWidget(_buildApp(exhibitionHandlers: handlers));
    await tester.pumpAndSettle();

    await _tapChoiceChipLabel(tester, '预发布列表 · 1');
    await _tapEntityCardAction(
      tester,
      title: '项目 project-withdraw-flow',
      actionLabel: '补资料后确认发布',
    );
    await _scrollTo(tester, find.widgetWithText(OutlinedButton, '返回草稿继续编辑'));
    await tester.tap(find.widgetWithText(OutlinedButton, '返回草稿继续编辑'));
    await tester.pumpAndSettle();

    expect(find.textContaining('撤回后，项目会回到草稿，暂不进入公域展示'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, '确认撤回'));
    await tester.pumpAndSettle();

    expect(find.text('已撤回到草稿'), findsOneWidget);
    expect(projectStates['project-withdraw-flow'], 'draft');
    expect(find.widgetWithText(FilledButton, '继续编辑'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, '删除此项目'), findsOneWidget);
  });

  testWidgets('预发布列表作废删除后详情进入归档只读承接', (WidgetTester tester) async {
    final projectStates = <String, String>{
      'project-draft-1': 'draft',
      'project-archive-flow': 'submitted',
    };
    final handlers = _mutableMyProjectHandlers(projectStates: projectStates);

    await tester.pumpWidget(_buildApp(exhibitionHandlers: handlers));
    await tester.pumpAndSettle();

    await _tapChoiceChipLabel(tester, '预发布列表 · 1');
    await _tapEntityCardAction(
      tester,
      title: '项目 project-archive-flow',
      actionLabel: '补资料后确认发布',
    );
    await _scrollTo(tester, find.widgetWithText(OutlinedButton, '作废删除'));
    await tester.tap(find.widgetWithText(OutlinedButton, '作废删除'));
    await tester.pumpAndSettle();

    expect(find.textContaining('预发布项目不会被硬删除'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, '确认作废'));
    await tester.pumpAndSettle();

    expect(find.text('已作废删除'), findsOneWidget);
    expect(projectStates['project-archive-flow'], 'archived');
    expect(find.text('删除此项目'), findsNothing);
  });

  testWidgets('预发布列表卡片主动作进入详情后正式发布并进入已发布承接', (WidgetTester tester) async {
    final projectStates = <String, String>{
      'project-draft-1': 'draft',
      'project-publish-flow': 'submitted',
    };
    final pricingCalls = <String>[];
    final handlers = _mutableMyProjectHandlers(
      projectStates: projectStates,
      pricingCalls: pricingCalls,
    );

    await tester.pumpWidget(_buildApp(exhibitionHandlers: handlers));
    await tester.pumpAndSettle();

    await _tapChoiceChipLabel(tester, '预发布列表 · 1');
    await _tapEntityCardAction(
      tester,
      title: '项目 project-publish-flow',
      actionLabel: '补资料后确认发布',
    );
    await _scrollTo(tester, find.widgetWithText(FilledButton, '检查无误，确定发布'));
    await tester.tap(find.widgetWithText(FilledButton, '检查无误，确定发布'));
    await tester.pumpAndSettle();

    expect(find.textContaining('项目将从预发布列表进入公域项目详情'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, '确认发布'));
    await tester.pumpAndSettle();

    expect(find.text('已正式发布'), findsOneWidget);
    expect(projectStates['project-publish-flow'], 'published');
    expect(pricingCalls, <String>[
      ExhibitionCanonicalPaths.projectPricingSummary('project-publish-flow'),
      ExhibitionCanonicalPaths.projectAuthenticitySincerityOrders(
        'project-publish-flow',
      ),
      ExhibitionCanonicalPaths.projectAuthenticitySincerityPayInit(
        'project-publish-flow',
        'sincerity-project-publish-flow',
      ),
      ExhibitionCanonicalPaths.projectAuthenticitySincerityOrderStatus(
        'project-publish-flow',
        'sincerity-project-publish-flow',
      ),
    ]);
    expect(find.textContaining('竞标中', skipOffstage: false), findsWidgets);
  });

  testWidgets('预发布详情未完成 200 诚意金时不执行正式发布', (WidgetTester tester) async {
    final projectStates = <String, String>{
      'project-draft-1': 'draft',
      'project-sincerity-pending': 'submitted',
    };
    final pricingCalls = <String>[];
    final handlers = _mutableMyProjectHandlers(
      projectStates: projectStates,
      pricingCalls: pricingCalls,
    );

    await tester.pumpWidget(_buildApp(exhibitionHandlers: handlers));
    await tester.pumpAndSettle();

    await _tapChoiceChipLabel(tester, '预发布列表 · 1');
    await _tapEntityCardAction(
      tester,
      title: '项目 project-sincerity-pending',
      actionLabel: '补资料后确认发布',
    );
    await _scrollTo(tester, find.widgetWithText(FilledButton, '检查无误，确定发布'));
    await tester.tap(find.widgetWithText(FilledButton, '检查无误，确定发布'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '确认发布'));
    await tester.pumpAndSettle();

    expect(find.textContaining('项目真实性诚意金尚未完成冻结'), findsOneWidget);
    expect(projectStates['project-sincerity-pending'], 'submitted');
    expect(pricingCalls, <String>[
      ExhibitionCanonicalPaths.projectPricingSummary(
        'project-sincerity-pending',
      ),
      ExhibitionCanonicalPaths.projectAuthenticitySincerityOrders(
        'project-sincerity-pending',
      ),
      ExhibitionCanonicalPaths.projectAuthenticitySincerityPayInit(
        'project-sincerity-pending',
        'sincerity-project-sincerity-pending',
      ),
      ExhibitionCanonicalPaths.projectAuthenticitySincerityOrderStatus(
        'project-sincerity-pending',
        'sincerity-project-sincerity-pending',
      ),
    ]);
  });

  testWidgets('预发布详情缺少必传效果图时拦截正式发布', (WidgetTester tester) async {
    final projectStates = <String, String>{
      'project-draft-1': 'draft',
      'project-missing-effect': 'submitted',
    };
    final handlers = _mutableMyProjectHandlers(projectStates: projectStates);

    await tester.pumpWidget(_buildApp(exhibitionHandlers: handlers));
    await tester.pumpAndSettle();

    await _tapChoiceChipLabel(tester, '预发布列表 · 1');
    await _tapEntityCardAction(
      tester,
      title: '项目 project-missing-effect',
      actionLabel: '补资料后确认发布',
    );
    await _scrollTo(tester, find.widgetWithText(FilledButton, '检查无误，确定发布'));
    await tester.tap(find.widgetWithText(FilledButton, '检查无误，确定发布'));
    await tester.pumpAndSettle();

    expect(find.text('请先上传必传效果图，再进行正式发布确认。'), findsOneWidget);
    expect(find.textContaining('项目将从预发布列表进入公域项目详情'), findsNothing);
    expect(projectStates['project-missing-effect'], 'submitted');
  });

  testWidgets('已发布详情撤回到预发布后退出竞标中承接', (WidgetTester tester) async {
    final projectStates = <String, String>{
      'project-draft-1': 'draft',
      'project-close-flow': 'published',
    };
    final handlers = _mutableMyProjectHandlers(projectStates: projectStates);

    await tester.pumpWidget(_buildApp(exhibitionHandlers: handlers));
    await tester.pumpAndSettle();

    await _tapChoiceChipLabel(tester, '竞标中 · 1');
    await _tapEntityCardAction(
      tester,
      title: '项目 project-close-flow',
      actionLabel: '查看详情',
    );
    await _scrollTo(tester, find.text('当前阶段动作'));
    expect(find.text('当前阶段动作'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '补充报价依据资料'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, '撤回到预发布'), findsOneWidget);
    expect(find.text('下架关闭'), findsNothing);
    await tester.tap(find.widgetWithText(OutlinedButton, '撤回到预发布'));
    await tester.pumpAndSettle();
    expect(find.textContaining('项目会下架公域展示并回到预发布列表'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, '确认撤回'));
    await tester.pumpAndSettle();

    expect(projectStates['project-close-flow'], 'submitted');
    expect(find.text('已撤回到预发布'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '检查无误，确定发布'), findsOneWidget);
  });

  testWidgets('进行中详情只展示取消申请和违约留痕入口', (WidgetTester tester) async {
    final projectStates = <String, String>{
      'project-active-exit': 'converted_to_order',
    };
    final handlers = _mutableMyProjectHandlers(projectStates: projectStates);

    await tester.pumpWidget(
      _buildApp(
        exhibitionHandlers: handlers,
        initialRoute: ExhibitionRoutes.myProjectDetailWithProjectId(
          'project-active-exit',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _scrollTo(tester, find.text('当前阶段动作'));
    expect(find.widgetWithText(FilledButton, '发起取消申请'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, '记录发布方违约'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, '记录工厂违约'), findsOneWidget);
    expect(find.text('删除此项目'), findsNothing);
    expect(find.text('撤回到预发布'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, '发起取消申请'));
    await tester.pumpAndSettle();
    expect(find.textContaining('不能单方直接撤回'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, '确认发起'));
    await tester.pumpAndSettle();

    expect(find.text('已发起取消申请'), findsOneWidget);
    expect(projectStates['project-active-exit'], 'converted_to_order');
  });

  testWidgets('生命周期动作失败时显示中文业务错误', (WidgetTester tester) async {
    final handlers = _mutableMyProjectHandlers(
      projectStates: <String, String>{'project-submitted-fail': 'submitted'},
      failingLifecyclePath: '/api/app/project/withdraw',
      failingLifecycleCode: 'PROJECT_WITHDRAW_INVALID',
      failingLifecycleMessage: '当前项目尚未提交，暂不支持撤回到草稿。',
    );

    await tester.pumpWidget(
      _buildApp(
        exhibitionHandlers: handlers,
        initialRoute: ExhibitionRoutes.myProjectDetailWithProjectId(
          'project-submitted-fail',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _scrollTo(tester, find.widgetWithText(OutlinedButton, '返回草稿继续编辑'));
    await tester.tap(find.widgetWithText(OutlinedButton, '返回草稿继续编辑'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '确认撤回'));
    await tester.pumpAndSettle();

    expect(find.text('当前项目尚未提交，暂不支持撤回到草稿。'), findsOneWidget);
    expect(find.text('Current project state not supported'), findsNothing);
  });

  testWidgets('草稿项目删除后返回四阶段列表', (WidgetTester tester) async {
    var deleteCalls = 0;
    final handlers = _mutableMyProjectHandlers(
      projectStates: <String, String>{'project-draft-delete': 'draft'},
      onDelete: (_) => deleteCalls += 1,
    );

    await tester.pumpWidget(
      _buildApp(
        exhibitionHandlers: handlers,
        initialRoute: ExhibitionRoutes.myProjectDetailWithProjectId(
          'project-draft-delete',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _scrollTo(tester, find.widgetWithText(OutlinedButton, '删除此项目'));
    await tester.tap(find.widgetWithText(OutlinedButton, '删除此项目'));
    await tester.pumpAndSettle();

    expect(find.text('只有草稿项目可以删除。删除后不可恢复。'), findsWidgets);
    await tester.tap(find.widgetWithText(FilledButton, '确认删除'));
    await tester.pumpAndSettle();

    expect(deleteCalls, 1);
    expect(find.text('我的项目'), findsWidgets);
    await _tapVisible(tester, find.text('草稿 · 0 个'));
    expect(find.text('当前没有草稿项目'), findsOneWidget);
  });
}
