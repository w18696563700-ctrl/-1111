import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/forum_consumer_layer.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/exhibition/presentation/exhibition_trade_pages.dart';
import 'package:mobile/features/messages/data/counterpart_conversation_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_identity_consumer_layer.dart';
import 'package:mobile/shell/shell_app.dart';

Map<String, Object?> _projectDetailPayload({
  required String projectId,
  required String state,
  required String viewerProjectRelation,
}) {
  return <String, Object?>{
    'projectId': projectId,
    'projectNo': 'PROJ-1',
    'title': '西洽会 / 品牌A',
    'exhibitionName': '西洽会',
    'brandName': '品牌A',
    'buildingType': 'exhibition',
    'budgetAmount': 120000,
    'areaSqm': 200,
    'provinceCode': '500000',
    'provinceName': '重庆市',
    'cityCode': '500100',
    'cityName': '重庆市',
    'districtCode': '500105',
    'districtName': '江北区',
    'detailAddress': '重庆国际博览中心',
    'scopeSummary': '整体展位装修全包',
    'plannedStartAt': '2026-05-16',
    'plannedEndAt': '2026-05-23',
    'scheduleDetail': null,
    'buildingTypeRemark': null,
    'description': '项目已进入最小发布走廊。',
    'viewerProjectRelation': viewerProjectRelation,
    'state': state,
    'summary': const <String, Object?>{'heading': '项目已进入最小发布走廊。'},
  };
}

Map<String, Object?> _myProjectDetailPayload({
  required String projectId,
  required String state,
}) {
  return <String, Object?>{
    'publicProject': _projectDetailPayload(
      projectId: projectId,
      state: state,
      viewerProjectRelation: 'owner',
    ),
    'privateProgress': const <String, Object?>{
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

Map<String, Object?> _attachmentListResponse(
  String projectId,
  List<Map<String, Object?>> attachments, {
  Map<String, Object?>? materialReview,
}) {
  return <String, Object?>{
    'projectId': projectId,
    'attachments': attachments,
    'materialReview': materialReview,
  };
}

Map<String, Object?> _bidMaterial({
  required String attachmentId,
  required String projectId,
  required String fileAssetId,
  required String fileName,
  required String attachmentKind,
  required String mimeType,
  required int sortOrder,
}) {
  return <String, Object?>{
    'attachmentId': attachmentId,
    'projectId': projectId,
    'fileAssetId': fileAssetId,
    'fileName': fileName,
    'attachmentKind': attachmentKind,
    'mimeType': mimeType,
    'sortOrder': sortOrder,
    'createdAt': '2026-04-16T09:30:00Z',
  };
}

Map<String, Object?> _publicResourceListResponse(
  List<Map<String, Object?>> resources,
) {
  return <String, Object?>{'resources': resources};
}

Map<String, Object?> _publisherMaterialReviewProjection(
  String projectId,
  List<Map<String, Object?>> attachments,
) {
  return <String, Object?>{
    'projectId': projectId,
    'threadId': 'thread-1',
    'viewerRole': 'bidder',
    'chatAvailability': const <String, Object?>{
      'canSendMessage': false,
      'lockReasonCode': 'publisher_material_confirmation_pending',
      'lockReasonText': '请先确认发布方提供的报价依据资料。',
      'requiredNextAction': 'confirm_publisher_materials',
    },
    'entries': _publisherMaterialReviewEntries(projectId, attachments),
    'generatedAt': '2026-04-16T10:00:00Z',
  };
}

List<Map<String, Object?>> _publisherMaterialReviewEntries(
  String projectId,
  List<Map<String, Object?>> attachments,
) {
  const definitions = <({String kind, String entryKey, String label})>[
    (
      kind: 'effect_image',
      entryKey: 'publisher_effect_image_review',
      label: '效果图确认',
    ),
    (
      kind: 'construction_doc',
      entryKey: 'publisher_construction_doc_review',
      label: '尺寸图 / 施工图确认',
    ),
    (
      kind: 'material_sample',
      entryKey: 'publisher_material_sample_review',
      label: '材质图 / 材料样板确认',
    ),
    (
      kind: 'equipment_material_list',
      entryKey: 'publisher_equipment_material_list_review',
      label: '设备物料清单确认',
    ),
    (
      kind: 'service_list',
      entryKey: 'publisher_service_list_review',
      label: '服务清单确认',
    ),
  ];
  return definitions
      .map((definition) {
        final sourceFiles = attachments
            .where((item) => item['attachmentKind'] == definition.kind)
            .map(
              (item) => <String, Object?>{
                'fileAssetId': item['fileAssetId'],
                'fileName': item['fileName'],
                'mimeType': item['mimeType'],
                'sortOrder': item['sortOrder'],
              },
            )
            .toList(growable: false);
        return <String, Object?>{
          'entryKey': definition.entryKey,
          'group': 'publisher_materials',
          'label': definition.label,
          'summary': null,
          'projectId': projectId,
          'threadId': 'thread-1',
          'bidId': null,
          'viewerRole': 'bidder',
          'subjectOwnerRole': 'publisher',
          'availabilityState': sourceFiles.isEmpty ? 'unsubmitted' : 'readable',
          'reviewState': sourceFiles.isEmpty ? 'unsubmitted' : 'pending_review',
          'actionState': sourceFiles.isEmpty ? 'blocked' : 'enabled',
          'attachmentCount': sourceFiles.length,
          'badgeCount': sourceFiles.isEmpty ? 0 : 1,
          'disabledReason': sourceFiles.isEmpty ? '当前资料尚未提交。' : null,
          'sourceFiles': sourceFiles,
          'latestFeedbackText': null,
          'latestFeedbackAt': null,
          'reviewedAt': null,
          'routeTarget': <String, Object?>{
            'actionKey': 'project_communication_material_review.open',
            'canonicalPath':
                '/api/app/message/project-communication/workbench/material-review-detail',
            'params': <String, Object?>{
              'projectId': projectId,
              'threadId': 'thread-1',
              'bidId': null,
              'entryKey': definition.entryKey,
            },
          },
          'truthAnchor': <String, Object?>{
            'truthOwner': 'server',
            'subjectType': 'publisher_quote_basis_material',
            'projectId': projectId,
            'threadId': 'thread-1',
            'bidId': null,
            'subjectOwnerOrganizationId': 'publisher-org',
            'reviewerOrganizationId': 'org-1',
            'materialKind': definition.kind,
            'bidMaterialSlot': null,
            'dealConfirmationId': null,
            'sourceVersionToken': 'source-${definition.kind}',
          },
        };
      })
      .toList(growable: false);
}

Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
_emptyForumHandlers() {
  AppApiResponse emptyPaged(AppApiRequest request) => AppApiResponse(
    statusCode: 200,
    uri: request.uri,
    body: const <String, Object?>{
      'items': <Object?>[],
      'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
    },
  );

  return <String, Future<AppApiResponse> Function(AppApiRequest request)>{
    'GET /api/app/forum/interaction/inbox': (AppApiRequest request) async =>
        emptyPaged(request),
    'GET /api/app/forum/me/posts': (AppApiRequest request) async =>
        emptyPaged(request),
    'GET /api/app/forum/me/comments': (AppApiRequest request) async =>
        emptyPaged(request),
    'GET /api/app/forum/me/bookmarks': (AppApiRequest request) async =>
        emptyPaged(request),
    'GET /api/app/forum/draft/list': (AppApiRequest request) async =>
        emptyPaged(request),
  };
}

ExhibitionMobileApp _buildApp({
  required String initialRoute,
  required FakeAppApiTransport transport,
  required List<String> roleKeys,
}) {
  final sessionStore = AppSessionStore()
    ..establishSession(
      accessToken: 'prep-access',
      refreshToken: 'prep-refresh',
      expiresInSeconds: 3600,
      deviceId: 'prep-device',
    );

  return ExhibitionMobileApp(
    initialRoute: initialRoute,
    bootstrapShellContext: AppShellContextData(
      userId: 'user-1',
      organizationId: 'org-1',
      organizationType: 'supplier',
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
    profileConsumerLayer: ProfileConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(handlers: const {}),
      ),
    ),
    forumConsumerLayer: ForumConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(handlers: _emptyForumHandlers()),
      ),
    ),
    profileIdentityConsumerLayer: ProfileIdentityConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(handlers: const {}),
      ),
    ),
    counterpartConversationConsumerLayer: CounterpartConversationConsumerLayer(
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
  setUp(() {
    ProjectAttachmentDebugOverrides.reset();
  });

  tearDown(() {
    ProjectAttachmentDebugOverrides.reset();
  });

  testWidgets('bid submit keeps step one only until continue bid', (
    WidgetTester tester,
  ) async {
    Uri? openedBidMaterialUri;
    ProjectAttachmentDebugOverrides.installRemoteImageBytesLoader((
      Uri uri,
    ) async {
      return null;
    });
    ProjectAttachmentDebugOverrides.installExternalUrlOpener((Uri uri) async {
      openedBidMaterialUri = uri;
      return true;
    });
    final quoteBasisAttachments = <Map<String, Object?>>[
      _bidMaterial(
        attachmentId: 'attachment-1',
        projectId: 'project-1',
        fileAssetId: 'asset-1',
        fileName: '效果图说明.docx',
        attachmentKind: 'effect_image',
        mimeType:
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        sortOrder: 0,
      ),
      _bidMaterial(
        attachmentId: 'attachment-2',
        projectId: 'project-1',
        fileAssetId: 'asset-2',
        fileName: '施工图.pdf',
        attachmentKind: 'construction_doc',
        mimeType: 'application/pdf',
        sortOrder: 1,
      ),
      _bidMaterial(
        attachmentId: 'attachment-3',
        projectId: 'project-1',
        fileAssetId: 'asset-3',
        fileName: '材质图.pdf',
        attachmentKind: 'material_sample',
        mimeType: 'application/pdf',
        sortOrder: 2,
      ),
      _bidMaterial(
        attachmentId: 'attachment-4',
        projectId: 'project-1',
        fileAssetId: 'asset-4',
        fileName: '设备物料清单.xlsx',
        attachmentKind: 'equipment_material_list',
        mimeType:
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        sortOrder: 3,
      ),
      _bidMaterial(
        attachmentId: 'attachment-5',
        projectId: 'project-1',
        fileAssetId: 'asset-5',
        fileName: '服务清单.csv',
        attachmentKind: 'service_list',
        mimeType: 'text/csv',
        sortOrder: 4,
      ),
    ];
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/project/detail': (AppApiRequest request) async =>
                AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _projectDetailPayload(
                    projectId: 'project-1',
                    state: 'published',
                    viewerProjectRelation: 'non_owner',
                  ),
                ),
            'GET /api/app/project/bid-materials':
                (AppApiRequest request) async => AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _attachmentListResponse(
                    'project-1',
                    quoteBasisAttachments,
                    materialReview: _publisherMaterialReviewProjection(
                      'project-1',
                      quoteBasisAttachments,
                    ),
                  ),
                ),
            'GET /api/app/project/public-resources':
                (AppApiRequest request) async => AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _publicResourceListResponse(
                    const <Map<String, Object?>>[],
                  ),
                ),
            'GET /api/app/file/access': (AppApiRequest request) async =>
                AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'fileAssetId': request.uri.queryParameters['fileAssetId'],
                    'mode': request.uri.queryParameters['mode'],
                    'accessUrl': 'https://signed.example.test/bid-material',
                    'fileName': '效果图.png',
                    'mimeType': 'image/png',
                    'expiresAt': '2026-04-27T10:00:00.000Z',
                  },
                ),
          },
    );

    await tester.pumpWidget(
      _buildApp(
        initialRoute: '${ExhibitionRoutes.bidSubmit}?projectId=project-1',
        transport: transport,
        roleKeys: const <String>['supplier_admin'],
      ),
    );
    await tester.pumpAndSettle();

    final continueButton = find.byWidgetPredicate(
      (Widget widget) =>
          widget is FilledButton &&
          widget.child is Text &&
          (widget.child as Text).data == '查看报价依据资料',
      description: 'FilledButton("查看报价依据资料")',
    );

    expect(find.text('已承接项目'), findsOneWidget);
    expect(continueButton, findsOneWidget);
    expect(find.text('项目附件'), findsNothing);
    expect(find.widgetWithText(FilledButton, '查看报价依据资料'), findsOneWidget);
    expect(find.text('温馨提示'), findsNothing);
    expect(find.text('填写报价'), findsNothing);
    expect(find.text('上传方案'), findsNothing);

    final continueAction = tester
        .widget<FilledButton>(continueButton)
        .onPressed;
    expect(continueAction, isNotNull);
    await _scrollTo(tester, continueButton);
    continueAction!.call();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.textContaining('项目信息已承接'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, '复核项目信息'), findsOneWidget);
    expect(find.text('查看报价依据资料'), findsOneWidget);
    expect(find.text('项目附件'), findsNothing);
    expect(find.text('效果图说明.docx'), findsOneWidget);
    expect(find.text('施工图.pdf'), findsOneWidget);
    expect(find.text('材质图.pdf'), findsOneWidget);
    expect(find.text('设备物料清单.xlsx'), findsOneWidget);
    expect(find.text('服务清单.csv'), findsOneWidget);
    expect(find.textContaining('建议先将资料下载到手机'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, '刷新报价依据资料'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, '查看 / 下载'), findsWidgets);
    expect(find.widgetWithText(OutlinedButton, '确认资料'), findsNWidgets(5));
    expect(find.text('待确认'), findsNWidgets(5));
    expect(find.widgetWithText(OutlinedButton, '预览图片'), findsNothing);
    expect(find.widgetWithText(OutlinedButton, '预览文书'), findsNothing);
    expect(find.text('其他资料'), findsNothing);
    expect(find.text('打开', skipOffstage: false), findsNothing);
    expect(find.text('下载原文件', skipOffstage: false), findsNothing);
    expect(find.text('选择项目附件', skipOffstage: false), findsNothing);
    expect(find.text('上传并形成正式附件', skipOffstage: false), findsNothing);
    expect(find.text('删除当前文书', skipOffstage: false), findsNothing);
    expect(find.text('绑定', skipOffstage: false), findsNothing);
    expect(
      transport.requests.where(
        (AppApiRequest request) =>
            request.canonicalPath == '/api/app/file/access',
      ),
      isEmpty,
    );
    expect(
      transport.requests
          .where(
            (AppApiRequest request) =>
                request.canonicalPath == '/api/app/project/bid-materials',
          )
          .length,
      1,
    );
    final refreshMaterials = find.widgetWithText(OutlinedButton, '刷新报价依据资料');
    await _scrollTo(tester, refreshMaterials);
    await tester.tap(refreshMaterials, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(
      transport.requests
          .where(
            (AppApiRequest request) =>
                request.canonicalPath == '/api/app/project/bid-materials',
          )
          .length,
      2,
    );
    final reopenReview = find.widgetWithText(
      OutlinedButton,
      '复核项目信息',
      skipOffstage: false,
    );
    tester.widget<OutlinedButton>(reopenReview).onPressed!.call();
    await tester.pumpAndSettle();

    expect(find.text('核心信息'), findsOneWidget);
    expect(find.text('地点与安排'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, '收起项目信息'), findsOneWidget);

    final openButtons = find.widgetWithText(OutlinedButton, '查看 / 下载');
    await _scrollTo(tester, openButtons.first);
    await tester.tap(openButtons.first, warnIfMissed: false);
    await tester.pumpAndSettle();
    final accessRequests = transport.requests
        .where(
          (AppApiRequest request) =>
              request.canonicalPath == '/api/app/file/access',
        )
        .toList(growable: false);
    expect(accessRequests, hasLength(1));
    expect(accessRequests.single.uri.queryParameters['fileAssetId'], 'asset-1');
    expect(accessRequests.single.uri.queryParameters['projectId'], 'project-1');
    expect(
      accessRequests.single.uri.queryParameters['accessScope'],
      'bid_material',
    );
    expect(openedBidMaterialUri, isNotNull);

    await _scrollTo(tester, find.text('填写报价'));
    expect(find.text('填写报价'), findsOneWidget);
    await _scrollTo(tester, find.text('上传方案'));
    expect(find.text('上传方案'), findsOneWidget);
  });

  testWidgets('bid submit rejects other-material drift before rendering', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/project/detail': (AppApiRequest request) async =>
                AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _projectDetailPayload(
                    projectId: 'project-1',
                    state: 'published',
                    viewerProjectRelation: 'non_owner',
                  ),
                ),
            'GET /api/app/project/bid-materials':
                (AppApiRequest request) async => AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _attachmentListResponse(
                    'project-1',
                    <Map<String, Object?>>[
                      _bidMaterial(
                        attachmentId: 'attachment-other',
                        projectId: 'project-1',
                        fileAssetId: 'asset-other',
                        fileName: '其他资料.zip',
                        attachmentKind: 'other_material',
                        mimeType: 'application/pdf',
                        sortOrder: 0,
                      ),
                    ],
                  ),
                ),
            'GET /api/app/project/public-resources':
                (AppApiRequest request) async => AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _publicResourceListResponse(
                    const <Map<String, Object?>>[],
                  ),
                ),
          },
    );

    await tester.pumpWidget(
      _buildApp(
        initialRoute: '${ExhibitionRoutes.bidSubmit}?projectId=project-1',
        transport: transport,
        roleKeys: const <String>['supplier_admin'],
      ),
    );
    await tester.pumpAndSettle();

    final continueButton = find.byWidgetPredicate(
      (Widget widget) =>
          widget is FilledButton &&
          widget.child is Text &&
          (widget.child as Text).data == '查看报价依据资料',
      description: 'FilledButton("查看报价依据资料")',
    );
    await _scrollTo(tester, continueButton);
    tester.widget<FilledButton>(continueButton).onPressed!.call();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('查看报价依据资料'), findsOneWidget);
    expect(find.text('报价依据资料暂不可读'), findsOneWidget);
    expect(find.text('其他资料.zip'), findsNothing);
    expect(find.text('其他资料'), findsNothing);
    expect(find.text('选择项目附件', skipOffstage: false), findsNothing);
    expect(find.text('上传并形成正式附件', skipOffstage: false), findsNothing);
    expect(find.text('删除当前文书', skipOffstage: false), findsNothing);
  });

  testWidgets('bid submit material read failure stays list-level copy', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/project/detail': (AppApiRequest request) async =>
                AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _projectDetailPayload(
                    projectId: 'project-1',
                    state: 'published',
                    viewerProjectRelation: 'non_owner',
                  ),
                ),
            'GET /api/app/project/bid-materials':
                (AppApiRequest request) async => AppApiResponse(
                  statusCode: 403,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'code': 'AUTH_PERMISSION_INSUFFICIENT',
                    'message': 'current account has no file access',
                  },
                ),
            'GET /api/app/project/public-resources':
                (AppApiRequest request) async => AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _publicResourceListResponse(
                    const <Map<String, Object?>>[],
                  ),
                ),
          },
    );

    await tester.pumpWidget(
      _buildApp(
        initialRoute: '${ExhibitionRoutes.bidSubmit}?projectId=project-1',
        transport: transport,
        roleKeys: const <String>['supplier_admin'],
      ),
    );
    await tester.pumpAndSettle();

    final continueButton = find.byWidgetPredicate(
      (Widget widget) =>
          widget is FilledButton &&
          widget.child is Text &&
          (widget.child as Text).data == '查看报价依据资料',
      description: 'FilledButton("查看报价依据资料")',
    );
    await _scrollTo(tester, continueButton);
    tester.widget<FilledButton>(continueButton).onPressed!.call();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('报价依据资料暂不可读'), findsOneWidget);
    expect(find.text('当前项目材料清单暂不可读，请稍后再试。'), findsOneWidget);
    expect(find.textContaining('账号'), findsNothing);
    expect(find.textContaining('权限'), findsNothing);
    expect(find.textContaining('file access'), findsNothing);
    expect(find.widgetWithText(OutlinedButton, '预览图片'), findsNothing);
    expect(find.widgetWithText(OutlinedButton, '预览文书'), findsNothing);
  });

  testWidgets('submitted my-project detail opens attachment corridor', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/my/projects/project-prepublish-1':
                (AppApiRequest request) async => AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _myProjectDetailPayload(
                    projectId: 'project-prepublish-1',
                    state: 'submitted',
                  ),
                ),
            'GET /api/app/my/projects/project-prepublish-1/attachments':
                (AppApiRequest request) async => AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _attachmentListResponse(
                    'project-prepublish-1',
                    const <Map<String, Object?>>[],
                  ),
                ),
            'GET /api/app/project/public-resources':
                (AppApiRequest request) async => AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _publicResourceListResponse(
                    const <Map<String, Object?>>[],
                  ),
                ),
          },
    );

    await tester.pumpWidget(
      _buildApp(
        initialRoute: ExhibitionRoutes.myProjectDetailWithProjectId(
          'project-prepublish-1',
        ),
        transport: transport,
        roleKeys: const <String>['buyer_admin'],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, '补充报价依据资料'), findsOneWidget);
    await _scrollTo(tester, find.text('报价依据资料').last);
    expect(find.text('报价依据资料'), findsWidgets);
  });
}
