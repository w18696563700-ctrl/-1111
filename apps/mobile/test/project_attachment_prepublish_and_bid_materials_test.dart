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
  List<Map<String, Object?>> attachments,
) {
  return <String, Object?>{'projectId': projectId, 'attachments': attachments};
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
  testWidgets('bid submit keeps step one only until continue bid', (
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
                        attachmentId: 'attachment-1',
                        projectId: 'project-1',
                        fileAssetId: 'asset-1',
                        fileName: '效果图.png',
                        attachmentKind: 'effect_image',
                        mimeType: 'image/png',
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
          (widget.child as Text).data == '继续竞标',
      description: 'FilledButton("继续竞标")',
    );

    expect(find.text('第一步 核对项目'), findsOneWidget);
    expect(continueButton, findsOneWidget);
    expect(find.text('项目附件'), findsNothing);
    expect(find.text('第二步 填写报价与方案说明'), findsNothing);
    expect(find.text('第三步 上传必选文档'), findsNothing);

    final continueAction = tester
        .widget<FilledButton>(continueButton)
        .onPressed;
    expect(continueAction, isNotNull);
    await _scrollTo(tester, continueButton);
    continueAction!.call();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.textContaining('项目核对已完成'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, '重新展开核对'), findsOneWidget);
    expect(find.text('项目附件'), findsOneWidget);
    expect(find.text('效果图.png'), findsOneWidget);
    expect(find.text('施工图.pdf'), findsOneWidget);
    expect(find.text('其他资料'), findsNothing);
    expect(find.text('选择项目附件', skipOffstage: false), findsNothing);
    expect(find.text('上传并形成正式附件', skipOffstage: false), findsNothing);
    expect(find.text('删除当前文书', skipOffstage: false), findsNothing);

    final reopenReview = find.widgetWithText(OutlinedButton, '重新展开核对');
    tester.widget<OutlinedButton>(reopenReview).onPressed!.call();
    await tester.pumpAndSettle();

    expect(find.text('核心信息'), findsOneWidget);
    expect(find.text('地点与安排'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, '收起核对信息'), findsOneWidget);

    await _scrollTo(tester, find.text('第二步 填写报价与方案说明'));
    expect(find.text('第二步 填写报价与方案说明'), findsOneWidget);
    await _scrollTo(tester, find.text('第三步 上传必选文档'));
    expect(find.text('第三步 上传必选文档'), findsOneWidget);
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
          (widget.child as Text).data == '继续竞标',
      description: 'FilledButton("继续竞标")',
    );
    await _scrollTo(tester, continueButton);
    tester.widget<FilledButton>(continueButton).onPressed!.call();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('项目附件'), findsOneWidget);
    expect(find.text('项目附件暂不可读'), findsOneWidget);
    expect(find.text('其他资料.zip'), findsNothing);
    expect(find.text('其他资料'), findsNothing);
    expect(find.text('选择项目附件', skipOffstage: false), findsNothing);
    expect(find.text('上传并形成正式附件', skipOffstage: false), findsNothing);
    expect(find.text('删除当前文书', skipOffstage: false), findsNothing);
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

    expect(find.widgetWithText(FilledButton, '补充项目详情文书'), findsOneWidget);
    expect(find.text('项目详情文书：效果图为必传，材质图和尺寸图为选传。'), findsOneWidget);
    await _scrollTo(tester, find.text('项目详情文书区'));
    expect(find.text('项目详情文书区'), findsOneWidget);
    expect(find.textContaining('效果图为必传，材质图和尺寸图为选传'), findsWidgets);
    expect(find.widgetWithText(ChoiceChip, '效果图（必传）'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, '材质图（选传）'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, '尺寸图（选传）'), findsOneWidget);
    expect(find.textContaining('当前还没有补充效果图、材质图或尺寸图'), findsOneWidget);
  });
}
