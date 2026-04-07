import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/exhibition/presentation/forum/forum_pages.dart';

import 'forum_test_support.dart';

const String _outputDir =
    '/Users/wangweiwei/Desktop/展览装修之家总控/.tmp/agent_reports/forum_draft_open_continuity_frontend/20260330';

Future<void> _pumpCaptureApp(
  WidgetTester tester,
  GlobalKey boundaryKey, {
  required String initialRoute,
  Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
      forumHandlerOverrides =
      const <String, Future<AppApiResponse> Function(AppApiRequest request)>{},
  Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
      exhibitionHandlerOverrides =
      const <String, Future<AppApiResponse> Function(AppApiRequest request)>{},
  Future<AppApiResponse> Function(AppApiUploadRequest request)?
  exhibitionUploadHandler,
}) async {
  await tester.pumpWidget(
    RepaintBoundary(
      key: boundaryKey,
      child: KeyedSubtree(
        key: UniqueKey(),
        child: buildForumTestAppWithOverrides(
          initialRoute: initialRoute,
          forumHandlerOverrides: forumHandlerOverrides,
          exhibitionHandlerOverrides: exhibitionHandlerOverrides,
          exhibitionUploadHandler: exhibitionUploadHandler,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _capture(GlobalKey boundaryKey, String filename) async {
  await expectLater(
    find.byKey(boundaryKey),
    matchesGoldenFile('$_outputDir/$filename'),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture forum draft-open continuity surfaces', (
    WidgetTester tester,
  ) async {
    final boundaryKey = GlobalKey();
    addTearDown(() async {
      ForumPublishMediaDebugOverrides.reset();
      await tester.binding.setSurfaceSize(null);
    });
    await tester.binding.setSurfaceSize(const Size(393, 852));

    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumDrafts,
    );
    await _capture(boundaryKey, '01_draft_list.png');

    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumDrafts,
    );
    await tester.tap(find.text('本地进场夜班经验分享'));
    await tester.pumpAndSettle();
    await _capture(boundaryKey, '02_draft_list_open_restored.png');

    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumPublishWithDraftId('draft-1'),
    );
    await _capture(boundaryKey, '03_normal_draft_restored.png');

    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumPublishWithDraftId('draft-edit-1'),
      forumHandlerOverrides:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/forum/draft/detail': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: const <String, Object?>{
                  'draftId': 'draft-edit-1',
                  'draftType': 'reply',
                  'targetPostId': 'post-owned-1',
                  'topicId': 'expo-materials',
                  'title': '编辑中的已发布帖子',
                  'body': '当前通过 targetPostId 恢复 edit continuity。',
                  'attachmentFileAssetIds': <String>[],
                  'state': 'ready_to_publish',
                  'updatedAt': '2026-03-30T09:00:00Z',
                },
              );
            },
          },
    );
    await _capture(boundaryKey, '04_edit_draft_restored.png');

    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumPublishWithDraftId('draft-asset-1'),
      forumHandlerOverrides:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/forum/draft/detail': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: const <String, Object?>{
                  'draftId': 'draft-asset-1',
                  'draftType': 'reply',
                  'targetPostId': null,
                  'topicId': 'expo-materials',
                  'title': '带附件的草稿',
                  'body': '当前草稿已经绑定 confirmed attachment。',
                  'attachmentFileAssetIds': <String>[
                    'asset-restored-1',
                  ],
                  'state': 'ready_to_publish',
                  'updatedAt': '2026-03-30T09:10:00Z',
                },
              );
            },
          },
    );
    await tester.drag(find.byType(ListView).first, const Offset(0, -320));
    await tester.pumpAndSettle();
    await _capture(boundaryKey, '05_attachment_draft_restored.png');

    ForumPublishMediaDebugOverrides.installPicker(
      (_) async => const <ForumPublishMediaDraft>[
        ForumPublishMediaDraft(
          fileName: '现场照片.jpg',
          bytes: <int>[1, 2, 3, 4, 5, 6],
        ),
      ],
    );
    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumPublish,
      exhibitionHandlerOverrides:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'POST /api/app/file/upload/init': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: const <String, Object?>{
                  'uploadSessionId': 'upload-session-1',
                  'directUpload': <String, Object?>{
                    'url': 'https://upload.example.com/forum-media-1',
                    'method': 'PUT',
                    'headers': <String, Object?>{
                      'content-type': 'image/jpeg',
                    },
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
                  'fileAssetId': 'asset-uploaded-1',
                },
              );
            },
          },
      exhibitionUploadHandler: (AppApiUploadRequest request) async {
        return AppApiResponse(statusCode: 200, uri: Uri.parse(request.url));
      },
      forumHandlerOverrides:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'POST /api/app/forum/draft/save': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 202,
                uri: request.uri,
                body: const <String, Object?>{
                  'draftId': 'draft-upload-1',
                  'state': 'ready_to_publish',
                  'updatedAt': '2026-03-30T10:40:00Z',
                },
              );
            },
          },
    );
    await tester.enterText(find.byType(TextField).at(0), '上传入口状态');
    await tester.enterText(find.byType(TextField).at(1), '当前选择附件后会自动进入上传流程。');
    await tester.pump();
    await tester.drag(find.byType(ListView).first, const Offset(0, -280));
    await tester.pumpAndSettle();
    await tester.tap(find.text('添加图片'));
    await tester.pumpAndSettle();
    await _capture(boundaryKey, '06_upload_interaction.png');

    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumPostWithPostId('post-publish-1'),
      forumHandlerOverrides:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/forum/post/detail': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: const <String, Object?>{
                  'postId': 'post-publish-1',
                  'state': 'published',
                  'topicId': 'expo-materials',
                  'topicTitle': '布展进场',
                  'author': <String, Object?>{
                    'authorId': 'member-1',
                    'displayName': '赵工',
                  },
                  'content': '发布后的帖子详情页。',
                  'attachmentRefs': <Object?>[],
                  'publishedAt': '2026-03-30T11:05:00Z',
                  'viewerHasLiked': false,
                  'viewerHasBookmarked': false,
                  'viewerFollowsTopic': false,
                },
              );
            },
            'GET /api/app/forum/post/comments': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: const <String, Object?>{
                  'items': <Object?>[],
                  'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
                },
              );
            },
          },
    );
    await _capture(boundaryKey, '07_publish_success.png');

    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumPublishWithDraftId('draft-missing-1'),
      forumHandlerOverrides:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/forum/draft/detail': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 409,
                uri: request.uri,
                body: const <String, Object?>{
                  'code': 'FORUM_DRAFT_OPEN_UNAVAILABLE',
                  'message': '当前草稿暂时不能打开。',
                  'source': 'server',
                },
              );
            },
          },
    );
    await _capture(boundaryKey, '08_draft_open_failure.png');
  });
}
