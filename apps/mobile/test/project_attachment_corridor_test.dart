import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/forum_consumer_layer.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/exhibition/presentation/exhibition_trade_pages.dart';
import 'package:mobile/features/profile/data/profile_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_identity_consumer_layer.dart';
import 'package:mobile/shell/shell_app.dart';

Map<String, Object?> _projectPayload({
  required String projectId,
  required String viewerProjectRelation,
  required String state,
  String projectNo = 'PROJ-1',
  String title = '展览项目',
  String exhibitionName = '春季医疗器械展',
  String brandName = '迈德瑞',
  num budgetAmount = 1800,
}) {
  return <String, Object?>{
    'projectId': projectId,
    'projectNo': projectNo,
    'title': title,
    'exhibitionName': exhibitionName,
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
    'scopeSummary': '主舞台、展区和接待区同步进场',
    'plannedStartAt': '2026-04-10',
    'plannedEndAt': '2026-04-18',
    'scheduleDetail': '4 月 10 日晚进场，4 月 18 日撤场',
    'description': '这里继续承接项目说明文案。',
    'viewerProjectRelation': viewerProjectRelation,
    'state': state,
    'summary': const <String, Object?>{'heading': '当前项目已承接'},
  };
}

Map<String, Object?> _myProjectDetailPayload({
  required String projectId,
  required String viewerProjectRelation,
  required String state,
}) {
  return <String, Object?>{
    'publicProject': _projectPayload(
      projectId: projectId,
      viewerProjectRelation: viewerProjectRelation,
      state: state,
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

Map<String, Object?> _attachmentItem({
  required String attachmentId,
  required String projectId,
  required String fileAssetId,
  required String fileName,
  required String attachmentKind,
  required String mimeType,
  required int sortOrder,
  String? createdBy = 'actor-local-isolated',
}) {
  final item = <String, Object?>{
    'attachmentId': attachmentId,
    'projectId': projectId,
    'fileAssetId': fileAssetId,
    'fileName': fileName,
    'attachmentKind': attachmentKind,
    'mimeType': mimeType,
    'visibility': 'owner_private',
    'sortOrder': sortOrder,
    'createdAt': '2026-04-13T16:19:00Z',
  };
  if (createdBy != null) {
    item['createdBy'] = createdBy;
  }
  return item;
}

Map<String, Object?> _attachmentListResponse(
  String projectId,
  List<Map<String, Object?>> attachments,
) {
  return <String, Object?>{'projectId': projectId, 'attachments': attachments};
}

Map<String, Object?> _publicResourceItem({
  required String resourceId,
  required String resourceCategory,
  required String title,
  required String fileAssetId,
  required String fileName,
  required String mimeType,
  required int sortOrder,
  String? summary,
}) {
  return <String, Object?>{
    'resourceId': resourceId,
    'resourceCategory': resourceCategory,
    'title': title,
    'summary': summary,
    'fileAssetId': fileAssetId,
    'fileName': fileName,
    'mimeType': mimeType,
    'visibility': 'app_shared',
    'sortOrder': sortOrder,
    'publishedAt': '2026-04-14T09:30:00Z',
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
  required FakeAppApiTransport exhibitionTransport,
  required String initialRoute,
}) {
  final sessionStore = AppSessionStore()
    ..establishSession(
      accessToken: 'attachment-access',
      refreshToken: 'attachment-refresh',
      expiresInSeconds: 3600,
      deviceId: 'attachment-device',
    );

  return ExhibitionMobileApp(
    initialRoute: initialRoute,
    bootstrapShellContext: AppShellContextData(
      userId: 'user-attachment',
      organizationId: 'org-attachment',
      roleKeys: const <String>['buyer_admin'],
      certificationStatus: 'approved',
      membershipStatus: 'active',
      visibleBuildings: const <String>['exhibition', 'messages', 'profile'],
    ),
    sessionStore: sessionStore,
    exhibitionConsumerLayer: ExhibitionConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: exhibitionTransport,
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

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await _scrollTo(tester, finder);
  await tester.tap(finder, warnIfMissed: false);
  await tester.pump();
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    ProjectAttachmentDebugOverrides.reset();
    ProjectPublicResourceDebugOverrides.reset();
  });

  tearDown(() {
    ProjectAttachmentDebugOverrides.reset();
    ProjectPublicResourceDebugOverrides.reset();
  });

  testWidgets('my project detail supports formal attachment list add delete', (
    WidgetTester tester,
  ) async {
    ProjectAttachmentDebugOverrides.installPicker(
      () async => const ProjectAttachmentDraft(
        fileName: 'construction-plan.docx',
        bytes: <int>[7, 8, 9, 10],
      ),
    );

    final attachments = <Map<String, Object?>>[
      _attachmentItem(
        attachmentId: 'attachment-existing-1',
        projectId: 'project-owner-1',
        fileAssetId: 'file-asset-existing-1',
        fileName: '现场效果图.png',
        attachmentKind: 'effect_image',
        mimeType: 'image/png',
        sortOrder: 0,
      ),
    ];
    final resources = <Map<String, Object?>>[
      _publicResourceItem(
        resourceId: 'resource-contract-1',
        resourceCategory: 'contract_template',
        title: '标准合同模板',
        summary: '用于项目发布后的合同模板参考。',
        fileAssetId: 'file-resource-contract-1',
        fileName: 'standard-contract-template.pdf',
        mimeType: 'application/pdf',
        sortOrder: 0,
      ),
      _publicResourceItem(
        resourceId: 'resource-process-1',
        resourceCategory: 'process_guide',
        title: '发布流程图与说明',
        summary: '帮助理解项目发布与续接流程。',
        fileAssetId: 'file-resource-process-1',
        fileName: 'publish-process-guide.pdf',
        mimeType: 'application/pdf',
        sortOrder: 1,
      ),
      _publicResourceItem(
        resourceId: 'resource-other-1',
        resourceCategory: 'other_resource',
        title: '公共资料汇编',
        summary: '用于补充平台共享公共资料。',
        fileAssetId: 'file-resource-other-1',
        fileName: 'public-resource-bundle.docx',
        mimeType:
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        sortOrder: 2,
      ),
    ];
    Uri? openedUri;
    Uri? openedAttachmentUri;
    ProjectPublicResourceDebugOverrides.installExternalUrlOpener((
      Uri uri,
    ) async {
      openedUri = uri;
      return true;
    });
    ProjectAttachmentDebugOverrides.installExternalUrlOpener((Uri uri) async {
      openedAttachmentUri = uri;
      return true;
    });

    final transport = FakeAppApiTransport(
      handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
        'GET /api/app/my/projects/project-owner-1':
            (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _myProjectDetailPayload(
                  projectId: 'project-owner-1',
                  viewerProjectRelation: 'owner',
                  state: 'published',
                ),
              );
            },
        'GET /api/app/my/projects/project-owner-1/attachments':
            (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _attachmentListResponse('project-owner-1', attachments),
              );
            },
        'GET /api/app/project/public-resources': (AppApiRequest request) async {
          return AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: _publicResourceListResponse(resources),
          );
        },
        'GET /api/app/file/access': (AppApiRequest request) async {
          final fileAssetId = request.uri.queryParameters['fileAssetId'];
          final mode = request.uri.queryParameters['mode'];
          if (fileAssetId == 'file-resource-contract-1') {
            expect(mode, 'download');
            return AppApiResponse(
              statusCode: 200,
              uri: request.uri,
              body: const <String, Object?>{
                'fileAssetId': 'file-resource-contract-1',
                'mode': 'download',
                'accessUrl':
                    'https://files.example.com/public-resource-contract-1.pdf',
                'fileName': 'standard-contract-template.pdf',
                'mimeType': 'application/pdf',
                'expiresAt': '2026-04-14T10:00:00Z',
              },
            );
          }
          if (fileAssetId == 'file-asset-existing-1') {
            expect(mode, 'preview');
            return AppApiResponse(
              statusCode: 200,
              uri: request.uri,
              body: const <String, Object?>{
                'fileAssetId': 'file-asset-existing-1',
                'mode': 'preview',
                'accessUrl': 'https://files.example.com/effect-image-1.png',
                'fileName': '现场效果图.png',
                'mimeType': 'image/png',
                'expiresAt': '2026-04-14T10:00:00Z',
              },
            );
          }
          if (fileAssetId == 'file-asset-docx-1') {
            expect(mode, 'preview');
            return AppApiResponse(
              statusCode: 200,
              uri: request.uri,
              body: const <String, Object?>{
                'fileAssetId': 'file-asset-docx-1',
                'mode': 'preview',
                'accessUrl': 'https://files.example.com/construction-plan.docx',
                'fileName': 'construction-plan.docx',
                'mimeType':
                    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                'expiresAt': '2026-04-14T10:00:00Z',
              },
            );
          }
          fail('unexpected file access request: ${request.uri}');
        },
        'POST /api/app/file/upload/init': (AppApiRequest request) async {
          final body = request.body! as Map<String, Object?>;
          expect(body['fileKind'], 'project_attachment');
          expect(
            body['mimeType'],
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
          );
          return AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: const <String, Object?>{
              'uploadSessionId': 'upload-session-owner-1',
              'directUpload': <String, Object?>{
                'url': 'https://oss.example.com/project-owner-1',
                'method': 'PUT',
              },
              'confirm': <String, Object?>{
                'endpoint': '/api/app/file/upload/confirm',
              },
            },
          );
        },
        'POST /api/app/file/upload/confirm': (AppApiRequest request) async {
          return AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: const <String, Object?>{'fileAssetId': 'file-asset-docx-1'},
          );
        },
        'POST /api/app/my/projects/project-owner-1/attachments':
            (AppApiRequest request) async {
              final body = request.body! as Map<String, Object?>;
              expect(body['attachmentKind'], 'construction_doc');
              final item = _attachmentItem(
                attachmentId: 'attachment-docx-1',
                projectId: 'project-owner-1',
                fileAssetId: 'file-asset-docx-1',
                fileName: 'construction-plan.docx',
                attachmentKind: 'construction_doc',
                mimeType:
                    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                sortOrder: 1,
              );
              attachments.insert(0, item);
              return AppApiResponse(
                statusCode: 202,
                uri: request.uri,
                body: item,
              );
            },
        'DELETE /api/app/my/projects/project-owner-1/attachments/attachment-docx-1':
            (AppApiRequest request) async {
              attachments.removeWhere(
                (Map<String, Object?> item) =>
                    item['attachmentId'] == 'attachment-docx-1',
              );
              return AppApiResponse(
                statusCode: 202,
                uri: request.uri,
                body: const <String, Object?>{
                  'attachmentId': 'attachment-docx-1',
                  'projectId': 'project-owner-1',
                  'state': 'deleted',
                },
              );
            },
      },
      uploadHandler: (AppApiUploadRequest request) async {
        return AppApiResponse(statusCode: 200, uri: Uri.parse(request.url));
      },
    );

    await tester.pumpWidget(
      _buildApp(
        exhibitionTransport: transport,
        initialRoute: ExhibitionRoutes.myProjectDetailWithProjectId(
          'project-owner-1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _scrollTo(tester, find.text('项目详情文书区'));
    expect(find.text('项目详情文书区'), findsOneWidget);
    expect(find.textContaining('这里用于补充项目正式文书资料'), findsNothing);
    expect(find.textContaining('当前只对 owner 私域可见'), findsNothing);
    expect(find.text('当前说明'), findsNothing);
    expect(find.widgetWithText(ChoiceChip, '效果图'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, '施工图'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, '其他资料'), findsOneWidget);
    await _tapVisible(tester, find.widgetWithText(ChoiceChip, '其他资料'));
    expect(find.textContaining('展馆和展位图'), findsNothing);
    expect(find.textContaining('展商手册'), findsNothing);
    expect(find.text('现场效果图.png'), findsOneWidget);
    await _tapVisible(tester, find.widgetWithText(OutlinedButton, '预览图片'));
    expect(find.text('图片预览'), findsOneWidget);
    await _tapVisible(tester, find.text('关闭'));

    await _tapVisible(tester, find.widgetWithText(ChoiceChip, '施工图'));
    await _tapVisible(tester, find.text('选择项目附件', skipOffstage: false));
    await _tapVisible(tester, find.text('上传并形成正式附件', skipOffstage: false));

    await _scrollTo(tester, find.text('construction-plan.docx'));
    expect(find.text('construction-plan.docx'), findsWidgets);
    await _tapVisible(tester, find.widgetWithText(OutlinedButton, '预览文书'));
    expect(
      openedAttachmentUri?.toString(),
      'https://files.example.com/construction-plan.docx',
    );

    await _tapVisible(
      tester,
      find.widgetWithText(OutlinedButton, '删除当前文书').first,
    );
    await tester.pumpAndSettle();

    expect(find.text('construction-plan.docx'), findsNothing);
    expect(find.text('现场效果图.png'), findsOneWidget);

    await _scrollTo(tester, find.text('公共资源下载区'));
    expect(find.text('公共资源下载区'), findsOneWidget);
    expect(find.textContaining('这里提供平台共享参考资料'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, '合同模板'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, '流程图与说明'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, '公共资料'), findsOneWidget);
    await _tapVisible(tester, find.widgetWithText(ChoiceChip, '合同模板'));
    expect(find.text('标准合同模板'), findsOneWidget);
    await _tapVisible(tester, find.widgetWithText(FilledButton, '下载资料'));
    expect(find.text('已开始下载资料。'), findsOneWidget);
    expect(
      openedUri?.toString(),
      'https://files.example.com/public-resource-contract-1.pdf',
    );
  });

  testWidgets('selected effect image previews before upload', (
    WidgetTester tester,
  ) async {
    ProjectAttachmentDebugOverrides.installPicker(
      () async => const ProjectAttachmentDraft(
        fileName: '效果图样张.png',
        bytes: <int>[1, 2, 3, 4],
      ),
    );

    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/my/projects/project-owner-preview':
                (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: _myProjectDetailPayload(
                      projectId: 'project-owner-preview',
                      viewerProjectRelation: 'owner',
                      state: 'published',
                    ),
                  );
                },
            'GET /api/app/my/projects/project-owner-preview/attachments':
                (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: _attachmentListResponse(
                      'project-owner-preview',
                      const <Map<String, Object?>>[],
                    ),
                  );
                },
            'GET /api/app/project/public-resources':
                (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: _publicResourceListResponse(
                      const <Map<String, Object?>>[],
                    ),
                  );
                },
          },
    );

    await tester.pumpWidget(
      _buildApp(
        exhibitionTransport: transport,
        initialRoute: ExhibitionRoutes.myProjectDetailWithProjectId(
          'project-owner-preview',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _scrollTo(tester, find.text('项目详情文书区'));
    await _tapVisible(tester, find.text('选择项目图片', skipOffstage: false));
    expect(find.text('效果图样张.png'), findsOneWidget);

    await _tapVisible(tester, find.text('预览当前图片'));
    expect(find.text('图片预览'), findsOneWidget);
  });

  testWidgets('selected attachments can continue add and batch upload', (
    WidgetTester tester,
  ) async {
    final drafts = <ProjectAttachmentDraft>[
      const ProjectAttachmentDraft(
        fileName: '效果图_A.png',
        bytes: <int>[1, 2, 3, 4],
      ),
      const ProjectAttachmentDraft(
        fileName: '效果图_B.webp',
        bytes: <int>[5, 6, 7, 8],
      ),
    ];
    var pickIndex = 0;
    ProjectAttachmentDebugOverrides.installPicker(() async {
      if (pickIndex >= drafts.length) {
        return null;
      }
      final draft = drafts[pickIndex];
      pickIndex += 1;
      return draft;
    });

    final attachments = <Map<String, Object?>>[];
    var uploadSessionIndex = 0;
    var fileAssetIndex = 0;
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/my/projects/project-owner-batch':
                (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: _myProjectDetailPayload(
                      projectId: 'project-owner-batch',
                      viewerProjectRelation: 'owner',
                      state: 'published',
                    ),
                  );
                },
            'GET /api/app/my/projects/project-owner-batch/attachments':
                (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: _attachmentListResponse(
                      'project-owner-batch',
                      attachments,
                    ),
                  );
                },
            'GET /api/app/project/public-resources':
                (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: _publicResourceListResponse(
                      const <Map<String, Object?>>[],
                    ),
                  );
                },
            'POST /api/app/file/upload/init': (AppApiRequest request) async {
              final body = request.body! as Map<String, Object?>;
              expect(body['fileKind'], 'project_attachment');
              expect(
                body['mimeType'],
                anyOf(<Object?>['image/png', 'image/webp']),
              );
              uploadSessionIndex += 1;
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: <String, Object?>{
                  'uploadSessionId': 'upload-session-batch-$uploadSessionIndex',
                  'directUpload': const <String, Object?>{
                    'url': 'https://oss.example.com/project-owner-batch',
                    'method': 'PUT',
                  },
                  'confirm': const <String, Object?>{
                    'endpoint': '/api/app/file/upload/confirm',
                  },
                },
              );
            },
            'POST /api/app/file/upload/confirm': (AppApiRequest request) async {
              fileAssetIndex += 1;
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: <String, Object?>{
                  'fileAssetId': 'file-asset-batch-$fileAssetIndex',
                },
              );
            },
            'POST /api/app/my/projects/project-owner-batch/attachments':
                (AppApiRequest request) async {
                  final body = request.body! as Map<String, Object?>;
                  expect(body['attachmentKind'], 'effect_image');
                  final item = _attachmentItem(
                    attachmentId: 'attachment-batch-${attachments.length + 1}',
                    projectId: 'project-owner-batch',
                    fileAssetId: body['fileAssetId']! as String,
                    fileName: body['fileName']! as String,
                    attachmentKind: body['attachmentKind']! as String,
                    mimeType: body['mimeType']! as String,
                    sortOrder: body['sortOrder']! as int,
                  );
                  attachments.insert(0, item);
                  return AppApiResponse(
                    statusCode: 202,
                    uri: request.uri,
                    body: item,
                  );
                },
          },
      uploadHandler: (AppApiUploadRequest request) async {
        return AppApiResponse(statusCode: 200, uri: Uri.parse(request.url));
      },
    );

    await tester.pumpWidget(
      _buildApp(
        exhibitionTransport: transport,
        initialRoute: ExhibitionRoutes.myProjectDetailWithProjectId(
          'project-owner-batch',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _scrollTo(tester, find.text('项目详情文书区'));
    await _tapVisible(tester, find.text('选择项目图片', skipOffstage: false));
    expect(find.text('待上传附件（1）'), findsOneWidget);
    expect(find.text('效果图_A.png'), findsOneWidget);

    await _tapVisible(tester, find.text('继续添加'));
    expect(find.text('待上传附件（2）'), findsOneWidget);
    expect(find.text('效果图_B.webp'), findsOneWidget);

    await _tapVisible(tester, find.text('上传并形成正式附件', skipOffstage: false));

    expect(attachments, hasLength(2));
    expect(find.text('效果图_A.png'), findsOneWidget);
    expect(find.text('效果图_B.webp'), findsOneWidget);
  });

  testWidgets(
    'bind failure surfaces precise reason instead of generic fallback',
    (WidgetTester tester) async {
      ProjectAttachmentDebugOverrides.installPicker(
        () async => const ProjectAttachmentDraft(
          fileName: '效果图绑定失败.png',
          bytes: <int>[3, 4, 5, 6],
        ),
      );

      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/my/projects/project-owner-bind-failed':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _myProjectDetailPayload(
                        projectId: 'project-owner-bind-failed',
                        viewerProjectRelation: 'owner',
                        state: 'published',
                      ),
                    );
                  },
              'GET /api/app/my/projects/project-owner-bind-failed/attachments':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _attachmentListResponse(
                        'project-owner-bind-failed',
                        const <Map<String, Object?>>[],
                      ),
                    );
                  },
              'GET /api/app/project/public-resources':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _publicResourceListResponse(
                        const <Map<String, Object?>>[],
                      ),
                    );
                  },
              'POST /api/app/file/upload/init': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'uploadSessionId': 'upload-session-bind-failed',
                    'directUpload': <String, Object?>{
                      'url':
                          'https://oss.example.com/project-owner-bind-failed',
                      'method': 'PUT',
                    },
                    'confirm': <String, Object?>{
                      'endpoint': '/api/app/file/upload/confirm',
                    },
                  },
                );
              },
              'POST /api/app/file/upload/confirm':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'fileAssetId': 'file-asset-bind-failed',
                      },
                    );
                  },
              'POST /api/app/my/projects/project-owner-bind-failed/attachments':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 400,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'code': 'PROJECT_ATTACHMENT_INVALID',
                        'message': '当前资料文件与项目绑定不一致，请重新上传后再试。',
                        'source': 'bff',
                      },
                    );
                  },
            },
        uploadHandler: (AppApiUploadRequest request) async {
          return AppApiResponse(statusCode: 200, uri: Uri.parse(request.url));
        },
      );

      await tester.pumpWidget(
        _buildApp(
          exhibitionTransport: transport,
          initialRoute: ExhibitionRoutes.myProjectDetailWithProjectId(
            'project-owner-bind-failed',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _scrollTo(tester, find.text('项目详情文书区'));
      await _tapVisible(tester, find.text('选择项目图片', skipOffstage: false));
      await _tapVisible(tester, find.text('上传并形成正式附件', skipOffstage: false));

      expect(find.text('正式附件绑定未完成'), findsOneWidget);
      expect(find.text('当前资料文件与项目绑定不一致，请重新上传后再试。'), findsOneWidget);
      expect(find.textContaining('尚未形成项目详情文书'), findsNothing);
      expect(find.text('再次绑定正式附件'), findsOneWidget);
    },
  );

  testWidgets(
    'bind route missing surfaces cloud bff deployment hint instead of generic fallback',
    (WidgetTester tester) async {
      ProjectAttachmentDebugOverrides.installPicker(
        () async => const ProjectAttachmentDraft(
          fileName: '效果图云端未部署.png',
          bytes: <int>[7, 8, 9, 10],
        ),
      );

      final transport = FakeAppApiTransport(
        handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
          'GET /api/app/my/projects/project-owner-bind-route-missing':
              (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _myProjectDetailPayload(
                    projectId: 'project-owner-bind-route-missing',
                    viewerProjectRelation: 'owner',
                    state: 'published',
                  ),
                );
              },
          'GET /api/app/my/projects/project-owner-bind-route-missing/attachments':
              (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _attachmentListResponse(
                    'project-owner-bind-route-missing',
                    const <Map<String, Object?>>[],
                  ),
                );
              },
          'GET /api/app/project/public-resources':
              (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _publicResourceListResponse(
                    const <Map<String, Object?>>[],
                  ),
                );
              },
          'POST /api/app/file/upload/init': (AppApiRequest request) async {
            return AppApiResponse(
              statusCode: 200,
              uri: request.uri,
              body: const <String, Object?>{
                'uploadSessionId': 'upload-session-bind-route-missing',
                'directUpload': <String, Object?>{
                  'url':
                      'https://oss.example.com/project-owner-bind-route-missing',
                  'method': 'PUT',
                },
                'confirm': <String, Object?>{
                  'endpoint': '/api/app/file/upload/confirm',
                },
              },
            );
          },
          'POST /api/app/file/upload/confirm': (AppApiRequest request) async {
            return AppApiResponse(
              statusCode: 200,
              uri: request.uri,
              body: const <String, Object?>{
                'fileAssetId': 'file-asset-bind-route-missing',
              },
            );
          },
          'POST /api/app/my/projects/project-owner-bind-route-missing/attachments':
              (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 404,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'message':
                        'Cannot POST /api/app/my/projects/project-owner-bind-route-missing/attachments',
                    'error': 'Not Found',
                    'statusCode': 404,
                  },
                );
              },
        },
        uploadHandler: (AppApiUploadRequest request) async {
          return AppApiResponse(statusCode: 200, uri: Uri.parse(request.url));
        },
      );

      await tester.pumpWidget(
        _buildApp(
          exhibitionTransport: transport,
          initialRoute: ExhibitionRoutes.myProjectDetailWithProjectId(
            'project-owner-bind-route-missing',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _scrollTo(tester, find.text('项目详情文书区'));
      await _tapVisible(tester, find.text('选择项目图片', skipOffstage: false));
      await _tapVisible(tester, find.text('上传并形成正式附件', skipOffstage: false));

      expect(find.text('正式附件绑定未完成'), findsOneWidget);
      expect(find.text('当前云端 BFF 尚未部署项目附件写入路由，请先同步云端后再试。'), findsOneWidget);
      expect(find.textContaining('尚未形成项目详情文书'), findsNothing);
      expect(find.text('再次绑定正式附件'), findsOneWidget);
    },
  );

  testWidgets('bind success accepts current live payload when createdBy is omitted', (
    WidgetTester tester,
  ) async {
    ProjectAttachmentDebugOverrides.installPicker(
      () async => const ProjectAttachmentDraft(
        fileName: '效果图云端现状.jpg',
        bytes: <int>[11, 22, 33, 44],
      ),
    );

    final attachments = <Map<String, Object?>>[];
    final transport = FakeAppApiTransport(
      handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
        'GET /api/app/my/projects/project-owner-bind-without-created-by':
            (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _myProjectDetailPayload(
                  projectId: 'project-owner-bind-without-created-by',
                  viewerProjectRelation: 'owner',
                  state: 'published',
                ),
              );
            },
        'GET /api/app/my/projects/project-owner-bind-without-created-by/attachments':
            (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _attachmentListResponse(
                  'project-owner-bind-without-created-by',
                  attachments,
                ),
              );
            },
        'GET /api/app/project/public-resources': (AppApiRequest request) async {
          return AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: _publicResourceListResponse(const <Map<String, Object?>>[]),
          );
        },
        'POST /api/app/file/upload/init': (AppApiRequest request) async {
          return AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: const <String, Object?>{
              'uploadSessionId': 'upload-session-bind-without-created-by',
              'directUpload': <String, Object?>{
                'url':
                    'https://oss.example.com/project-owner-bind-without-created-by',
                'method': 'PUT',
              },
              'confirm': <String, Object?>{
                'endpoint': '/api/app/file/upload/confirm',
              },
            },
          );
        },
        'POST /api/app/file/upload/confirm': (AppApiRequest request) async {
          return AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: const <String, Object?>{
              'fileAssetId': 'file-asset-bind-without-created-by',
            },
          );
        },
        'POST /api/app/my/projects/project-owner-bind-without-created-by/attachments':
            (AppApiRequest request) async {
              final item = _attachmentItem(
                attachmentId: 'attachment-bind-without-created-by',
                projectId: 'project-owner-bind-without-created-by',
                fileAssetId: 'file-asset-bind-without-created-by',
                fileName: '效果图云端现状.jpg',
                attachmentKind: 'effect_image',
                mimeType: 'image/jpeg',
                sortOrder: 0,
                createdBy: null,
              );
              attachments
                ..clear()
                ..add(item);
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: item,
              );
            },
      },
      uploadHandler: (AppApiUploadRequest request) async {
        return AppApiResponse(statusCode: 200, uri: Uri.parse(request.url));
      },
    );

    await tester.pumpWidget(
      _buildApp(
        exhibitionTransport: transport,
        initialRoute: ExhibitionRoutes.myProjectDetailWithProjectId(
          'project-owner-bind-without-created-by',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _scrollTo(tester, find.text('项目详情文书区'));
    await _tapVisible(tester, find.text('选择项目图片', skipOffstage: false));
    await _tapVisible(tester, find.text('上传并形成正式附件', skipOffstage: false));

    expect(find.text('效果图云端现状.jpg'), findsWidgets);
    expect(find.text('正式附件绑定未完成'), findsNothing);
    expect(find.textContaining('contract drift'), findsNothing);
  });

  testWidgets('project edit supports post-publish formal attachment corridor', (
    WidgetTester tester,
  ) async {
    ProjectAttachmentDebugOverrides.installPicker(
      () async => const ProjectAttachmentDraft(
        fileName: 'brand-board.webp',
        bytes: <int>[11, 12, 13, 14],
      ),
    );

    final attachments = <Map<String, Object?>>[];
    final transport = FakeAppApiTransport(
      handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
        'GET /api/app/project/edit/detail': (AppApiRequest request) async {
          return AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: _projectPayload(
              projectId: 'project-edit-1',
              viewerProjectRelation: 'owner',
              state: 'published',
            ),
          );
        },
        'GET /api/app/my/projects/project-edit-1/attachments':
            (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _attachmentListResponse('project-edit-1', attachments),
              );
            },
        'POST /api/app/file/upload/init': (AppApiRequest request) async {
          final body = request.body! as Map<String, Object?>;
          expect(body['fileKind'], 'project_attachment');
          expect(body['mimeType'], 'image/webp');
          return AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: const <String, Object?>{
              'uploadSessionId': 'upload-session-edit-1',
              'directUpload': <String, Object?>{
                'url': 'https://oss.example.com/project-edit-1',
                'method': 'PUT',
              },
              'confirm': <String, Object?>{
                'endpoint': '/api/app/file/upload/confirm',
              },
            },
          );
        },
        'POST /api/app/file/upload/confirm': (AppApiRequest request) async {
          return AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: const <String, Object?>{'fileAssetId': 'file-asset-webp-1'},
          );
        },
        'POST /api/app/my/projects/project-edit-1/attachments':
            (AppApiRequest request) async {
              final body = request.body! as Map<String, Object?>;
              expect(body['attachmentKind'], 'other_material');
              final item = _attachmentItem(
                attachmentId: 'attachment-webp-1',
                projectId: 'project-edit-1',
                fileAssetId: 'file-asset-webp-1',
                fileName: 'brand-board.webp',
                attachmentKind: 'other_material',
                mimeType: 'image/webp',
                sortOrder: 0,
              );
              attachments
                ..clear()
                ..add(item);
              return AppApiResponse(
                statusCode: 202,
                uri: request.uri,
                body: item,
              );
            },
        'DELETE /api/app/my/projects/project-edit-1/attachments/attachment-webp-1':
            (AppApiRequest request) async {
              attachments.clear();
              return AppApiResponse(
                statusCode: 202,
                uri: request.uri,
                body: const <String, Object?>{
                  'attachmentId': 'attachment-webp-1',
                  'projectId': 'project-edit-1',
                  'state': 'deleted',
                },
              );
            },
      },
      uploadHandler: (AppApiUploadRequest request) async {
        return AppApiResponse(statusCode: 200, uri: Uri.parse(request.url));
      },
    );

    await tester.pumpWidget(
      _buildApp(
        exhibitionTransport: transport,
        initialRoute: ExhibitionRoutes.projectEditWithProjectId(
          'project-edit-1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _scrollTo(tester, find.text('项目详情文书区'));
    await _tapVisible(tester, find.widgetWithText(ChoiceChip, '其他资料'));
    await _tapVisible(tester, find.text('选择项目附件', skipOffstage: false));
    await _tapVisible(tester, find.text('上传并形成正式附件', skipOffstage: false));

    await _scrollTo(tester, find.text('brand-board.webp'));
    expect(find.text('brand-board.webp'), findsWidgets);

    await _tapVisible(
      tester,
      find.widgetWithText(OutlinedButton, '删除当前文书').first,
    );
    await tester.pumpAndSettle();

    expect(find.text('brand-board.webp'), findsNothing);
    expect(find.text('当前还没有项目文书'), findsOneWidget);
  });

  testWidgets('my project detail public resource zone handles empty state', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/my/projects/project-owner-empty':
                (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: _myProjectDetailPayload(
                      projectId: 'project-owner-empty',
                      viewerProjectRelation: 'owner',
                      state: 'published',
                    ),
                  );
                },
            'GET /api/app/my/projects/project-owner-empty/attachments':
                (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: _attachmentListResponse(
                      'project-owner-empty',
                      const <Map<String, Object?>>[],
                    ),
                  );
                },
            'GET /api/app/project/public-resources':
                (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: _publicResourceListResponse(
                      const <Map<String, Object?>>[],
                    ),
                  );
                },
          },
    );

    await tester.pumpWidget(
      _buildApp(
        exhibitionTransport: transport,
        initialRoute: ExhibitionRoutes.myProjectDetailWithProjectId(
          'project-owner-empty',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _scrollTo(tester, find.text('项目详情文书区'));
    expect(find.text('项目详情文书区'), findsOneWidget);
    await _scrollTo(tester, find.text('公共资源下载区'));
    expect(find.text('公共资源下载区'), findsOneWidget);
    expect(find.text('当前暂无可下载的公共资源'), findsOneWidget);
    expect(find.textContaining('不代表项目详情文书区为空'), findsOneWidget);
  });

  testWidgets(
    'my project detail public resource zone handles controlled unavailable',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/my/projects/project-owner-forbidden':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _myProjectDetailPayload(
                        projectId: 'project-owner-forbidden',
                        viewerProjectRelation: 'owner',
                        state: 'published',
                      ),
                    );
                  },
              'GET /api/app/my/projects/project-owner-forbidden/attachments':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _attachmentListResponse(
                        'project-owner-forbidden',
                        const <Map<String, Object?>>[],
                      ),
                    );
                  },
              'GET /api/app/project/public-resources':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 403,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'code': 'AUTH_PERMISSION_INSUFFICIENT',
                        'message': '当前账号暂不可访问公共资源目录。',
                      },
                    );
                  },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          exhibitionTransport: transport,
          initialRoute: ExhibitionRoutes.myProjectDetailWithProjectId(
            'project-owner-forbidden',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _scrollTo(tester, find.text('公共资源下载区'));
      expect(find.text('当前公共资源下载区暂不可用'), findsOneWidget);
      expect(find.text('当前账号暂不可访问公共资源目录。'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, '重新读取'), findsOneWidget);
    },
  );

  testWidgets('my project detail public resource zone handles timeout', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/my/projects/project-owner-timeout':
                (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: _myProjectDetailPayload(
                      projectId: 'project-owner-timeout',
                      viewerProjectRelation: 'owner',
                      state: 'published',
                    ),
                  );
                },
            'GET /api/app/my/projects/project-owner-timeout/attachments':
                (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: _attachmentListResponse(
                      'project-owner-timeout',
                      const <Map<String, Object?>>[],
                    ),
                  );
                },
            'GET /api/app/project/public-resources':
                (AppApiRequest request) async {
                  throw const SocketException(
                    'request timed out: GET /api/app/project/public-resources',
                  );
                },
          },
    );

    await tester.pumpWidget(
      _buildApp(
        exhibitionTransport: transport,
        initialRoute: ExhibitionRoutes.myProjectDetailWithProjectId(
          'project-owner-timeout',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _scrollTo(tester, find.text('公共资源下载区'));
    expect(find.text('当前公共资源目录读取超时'), findsOneWidget);
    expect(find.textContaining('这次公共资源目录读取超时了'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, '重新读取'), findsOneWidget);
  });

  testWidgets(
    'public project detail stays fail-closed for owner-private attachments',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/project/detail': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _projectPayload(
                    projectId: 'project-public-1',
                    viewerProjectRelation: 'non_owner',
                    state: 'published',
                  ),
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          exhibitionTransport: transport,
          initialRoute: ExhibitionRoutes.projectDetailWithProjectId(
            'project-public-1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _scrollTo(tester, find.widgetWithText(FilledButton, '立即参与竞标'));
      expect(find.text('公开资料边界'), findsNothing);
      expect(find.text('项目详情文书区'), findsNothing);
      expect(find.text('公共资源下载区'), findsNothing);
      expect(find.text('选择项目附件', skipOffstage: false), findsNothing);
      expect(find.text('上传并形成正式附件', skipOffstage: false), findsNothing);
      expect(find.text('项目文书列表'), findsNothing);
    },
  );
}
