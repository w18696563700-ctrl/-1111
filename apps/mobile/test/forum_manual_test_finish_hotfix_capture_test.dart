import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/exhibition/presentation/forum/forum_pages.dart';

import 'forum_test_support.dart';

const String _outputDir =
    '/Users/wangweiwei/Desktop/展览装修之家总控/.tmp/agent_reports/forum_manual_test_finish_hotfix/20260331';

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

Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
_uploadHandlers({
  required String uploadSessionId,
  required String mimeType,
  required String fileAssetId,
}) {
  return <String, Future<AppApiResponse> Function(AppApiRequest request)>{
    'POST /api/app/file/upload/init': (AppApiRequest request) async {
      return AppApiResponse(
        statusCode: 200,
        uri: request.uri,
        body: <String, Object?>{
          'uploadSessionId': uploadSessionId,
          'directUpload': <String, Object?>{
            'url': 'https://upload.example.com/$fileAssetId',
            'method': 'PUT',
            'headers': <String, Object?>{'content-type': mimeType},
          },
          'confirm': const <String, Object?>{
            'endpoint': '/api/app/file/upload/confirm',
          },
        },
      );
    },
    'POST /api/app/file/upload/confirm': (AppApiRequest request) async {
      return AppApiResponse(
        statusCode: 200,
        uri: request.uri,
        body: <String, Object?>{'fileAssetId': fileAssetId},
      );
    },
  };
}

Future<void> _fillComposer(
  WidgetTester tester, {
  required String title,
  required String body,
}) async {
  await tester.enterText(find.byType(TextField).at(0), title);
  await tester.enterText(find.byType(TextField).at(1), body);
  await tester.pump();
  await tester.drag(find.byType(ListView).first, const Offset(0, -280));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    ForumPublishMediaDebugOverrides.reset();
  });

  testWidgets('capture manual finish hotfix screenshots', (
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
      initialRoute: ExhibitionRoutes.forumPublish,
    );
    await _capture(boundaryKey, '01_publish_guidance.png');

    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumMePosts,
      forumHandlerOverrides:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/forum/me/posts': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: const <String, Object?>{
                  'items': <Object?>[
                    <String, Object?>{
                      'postId': 'post-active-1',
                      'title': '活跃帖子',
                      'topicId': 'expo-materials',
                      'topicTitle': '布展进场',
                      'excerpt': '仍在公开区可见。',
                      'state': 'published',
                      'publishedAt': '2026-03-27T09:30:00Z',
                      'updatedAt': '2026-03-30T09:30:00Z',
                      'canEdit': true,
                      'canDelete': true,
                    },
                    <String, Object?>{
                      'postId': 'post-archived-1',
                      'title': '已删除帖子',
                      'topicId': 'expo-materials',
                      'topicTitle': '布展进场',
                      'excerpt': '这是一条已删除记录。',
                      'state': 'archived',
                      'publishedAt': '2026-03-27T09:30:00Z',
                      'updatedAt': '2026-03-30T09:30:00Z',
                      'canEdit': false,
                      'canDelete': false,
                    },
                  ],
                  'page': <String, Object?>{
                    'nextCursor': null,
                    'hasMore': false,
                  },
                },
              );
            },
          },
    );
    await _capture(boundaryKey, '02_my_posts_filtered.png');

    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumMeComments,
      forumHandlerOverrides:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/forum/me/comments': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: const <String, Object?>{
                  'items': <Object?>[
                    <String, Object?>{
                      'commentId': 'comment-compact-1',
                      'postId': 'post-compact-1',
                      'parentCommentId': null,
                      'body': '这是当前账号刚发出的评论',
                      'state': 'published',
                      'publishedAt': '2026-03-31T02:10:00Z',
                      'post': <String, Object?>{
                        'postId': 'post-compact-1',
                        'topicId': 'topic-compact-1',
                        'topicLabel': '布展进场',
                        'title': '夜间进场怎么排安检和吊装？',
                        'excerpt': '帖子摘要',
                        'publishedAt': '2026-03-30T12:00:00Z',
                      },
                    },
                  ],
                  'page': <String, Object?>{
                    'nextCursor': null,
                    'hasMore': false,
                  },
                },
              );
            },
          },
    );
    await _capture(boundaryKey, '03_my_comments_visible.png');

    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forum,
    );
    await _capture(boundaryKey, '04_shell_without_environment_banner.png');

    ForumPublishMediaDebugOverrides.installPicker(
      (_) async => <ForumPublishMediaDraft>[
        ForumPublishMediaDraft(
          fileName: '现场照片.jpg',
          bytes: const <int>[1, 2, 3, 4, 5, 6, 7, 8],
        ),
      ],
    );
    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumPublish,
      forumHandlerOverrides:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'POST /api/app/forum/draft/save': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 202,
                uri: request.uri,
                body: const <String, Object?>{
                  'draftId': 'draft-finish-1',
                  'state': 'ready_to_publish',
                  'updatedAt': '2026-03-31T10:40:00Z',
                },
              );
            },
          },
      exhibitionHandlerOverrides: _uploadHandlers(
        uploadSessionId: 'upload-session-finish-1',
        mimeType: 'image/jpeg',
        fileAssetId: 'asset-finish-1',
      ),
      exhibitionUploadHandler: (AppApiUploadRequest request) async {
        return AppApiResponse(statusCode: 200, uri: Uri.parse(request.url));
      },
    );
    await _fillComposer(tester, title: '继续验证上传', body: '确认这轮收尾 hotfix 没把上传带坏。');
    await tester.tap(find.text('添加图片'));
    await tester.pumpAndSettle();
    await _capture(boundaryKey, '05_upload_publish_still_normal.png');

    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumDrafts,
      forumHandlerOverrides:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/forum/draft/list': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: const <String, Object?>{
                  'items': <Object?>[
                    <String, Object?>{
                      'draftId': 'draft-delete-1',
                      'draftType': 'reply',
                      'topicId': 'expo-materials',
                      'title': '待删除草稿',
                      'excerpt': '草稿摘要',
                      'state': 'ready_to_publish',
                      'updatedAt': '2026-03-27T09:00:00Z',
                      'attachmentRefs': <Object?>[],
                    },
                  ],
                  'page': <String, Object?>{
                    'nextCursor': null,
                    'hasMore': false,
                  },
                },
              );
            },
          },
    );
    await tester.drag(find.text('待删除草稿'), const Offset(-120, 0));
    await tester.pumpAndSettle();
    await _capture(boundaryKey, '06_draft_delete_still_normal.png');
  });
}
