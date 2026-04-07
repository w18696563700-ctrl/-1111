import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/exhibition/presentation/forum/forum_pages.dart';

import 'forum_test_support.dart';

const String _outputDir =
    '/Users/wangweiwei/Desktop/展览装修之家总控/.tmp/agent_reports/forum_manual_test_blocker_hotfix/20260330';

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

Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
_publishSaveHandlers({
  String draftId = 'draft-hotfix-1',
  Future<AppApiResponse> Function(AppApiRequest request)? publishHandler,
  Future<AppApiResponse> Function(AppApiRequest request)? detailHandler,
}) {
  final handlers =
      <String, Future<AppApiResponse> Function(AppApiRequest request)>{
        'POST /api/app/forum/draft/save': (AppApiRequest request) async {
          return AppApiResponse(
            statusCode: 202,
            uri: request.uri,
            body: <String, Object?>{
              'draftId': draftId,
              'state': 'ready_to_publish',
              'updatedAt': '2026-03-31T10:40:00Z',
            },
          );
        },
      };
  if (publishHandler != null) {
    handlers['POST /api/app/forum/publish'] = publishHandler;
  }
  if (detailHandler != null) {
    handlers['GET /api/app/forum/post/detail'] = detailHandler;
    handlers['GET /api/app/forum/post/comments'] =
        (AppApiRequest request) async {
          return AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: const <String, Object?>{
              'items': <Object?>[],
              'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
            },
          );
        };
  }
  return handlers;
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

Future<void> _captureUpload(
  WidgetTester tester,
  GlobalKey boundaryKey, {
  required String buttonLabel,
  required String fileName,
  required String mimeType,
  required String assetId,
}) async {
  ForumPublishMediaDebugOverrides.installPicker(
    (_) async => <ForumPublishMediaDraft>[
      ForumPublishMediaDraft(
        fileName: fileName,
        bytes: const <int>[1, 2, 3, 4, 5, 6, 7, 8],
      ),
    ],
  );
  await _pumpCaptureApp(
    tester,
    boundaryKey,
    initialRoute: ExhibitionRoutes.forumPublish,
    forumHandlerOverrides: _publishSaveHandlers(),
    exhibitionHandlerOverrides: _uploadHandlers(
      uploadSessionId: 'upload-session-$assetId',
      mimeType: mimeType,
      fileAssetId: assetId,
    ),
    exhibitionUploadHandler: (AppApiUploadRequest request) async {
      return AppApiResponse(statusCode: 200, uri: Uri.parse(request.url));
    },
  );
  await _fillComposer(tester, title: '上传交互截图', body: '用于展示当前附件上传的真实前端状态。');
  await tester.tap(find.text(buttonLabel));
  await tester.pumpAndSettle();
  expect(find.text(fileName), findsOneWidget);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    ForumPublishMediaDebugOverrides.reset();
  });

  testWidgets('capture manual blocker hotfix screenshots', (
    WidgetTester tester,
  ) async {
    final boundaryKey = GlobalKey();
    addTearDown(() async {
      ForumPublishMediaDebugOverrides.reset();
      await tester.binding.setSurfaceSize(null);
    });
    await tester.binding.setSurfaceSize(const Size(393, 852));

    await _captureUpload(
      tester,
      boundaryKey,
      buttonLabel: '添加图片',
      fileName: '现场照片.jpg',
      mimeType: 'image/jpeg',
      assetId: 'asset-image-1',
    );
    await _capture(boundaryKey, '01_image_upload_interaction.png');

    await _captureUpload(
      tester,
      boundaryKey,
      buttonLabel: '添加视频',
      fileName: '现场视频.mp4',
      mimeType: 'video/mp4',
      assetId: 'asset-video-1',
    );
    await _capture(boundaryKey, '02_video_upload_interaction.png');

    await _captureUpload(
      tester,
      boundaryKey,
      buttonLabel: '添加文件',
      fileName: '材料清单.pdf',
      mimeType: 'application/pdf',
      assetId: 'asset-file-1',
    );
    await _capture(boundaryKey, '03_file_upload_interaction.png');

    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumPublishWithDraftId('draft-blocked-1'),
      forumHandlerOverrides:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/forum/draft/detail': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: const <String, Object?>{
                  'draftId': 'draft-blocked-1',
                  'draftType': 'topic',
                  'topicId': 'expo-materials',
                  'title': '受控失败截图',
                  'body': '广告引流：加我微信领取免费资料。',
                  'attachmentFileAssetIds': <String>[],
                  'state': 'ready_to_publish',
                  'updatedAt': '2026-03-31T10:40:00Z',
                },
              );
            },
            'POST /api/app/forum/publish': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 202,
                uri: request.uri,
                body: const <String, Object?>{
                  'draftId': 'draft-blocked-1',
                  'state': 'blocked',
                  'decision': 'restricted',
                  'message': '当前内容暂不可发布',
                },
              );
            },
          },
    );
    await tester.tap(find.widgetWithText(FilledButton, '发布'));
    await tester.pumpAndSettle();
    await _capture(boundaryKey, '04_publish_controlled_failure.png');

    var detailReadCount = 0;
    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumPostWithPostId('post-materials-1'),
      forumHandlerOverrides:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/forum/post/detail': (AppApiRequest request) async {
              detailReadCount += 1;
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: <String, Object?>{
                  'postId': 'post-materials-1',
                  'topicId': 'expo-materials',
                  'topicTitle': '布展进场',
                  'state': 'published',
                  'author': const <String, Object?>{
                    'authorId': 'member-1',
                    'displayName': '赵工',
                  },
                  'content': '用于点赞截图的帖子正文。',
                  'attachmentRefs': const <Object?>[],
                  'publishedAt': '2026-03-31T09:30:00Z',
                  if (detailReadCount == 1) 'viewerHasLiked': false,
                  if (detailReadCount == 1) 'viewerHasBookmarked': false,
                },
              );
            },
            'GET /api/app/forum/post/comments': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: const <String, Object?>{
                  'items': <Object?>[],
                  'page': <String, Object?>{
                    'nextCursor': null,
                    'hasMore': false,
                  },
                },
              );
            },
            'POST /api/app/forum/post/like': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 202,
                uri: request.uri,
                body: const <String, Object?>{
                  'postId': 'post-materials-1',
                  'state': 'liked',
                  'viewerHasLiked': true,
                  'likeCount': 8,
                },
              );
            },
          },
    );
    await tester.tap(find.text('点赞'));
    await tester.pumpAndSettle();
    await _capture(boundaryKey, '05_like_success.png');

    detailReadCount = 0;
    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumPostWithPostId('post-materials-1'),
      forumHandlerOverrides:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/forum/post/detail': (AppApiRequest request) async {
              detailReadCount += 1;
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: <String, Object?>{
                  'postId': 'post-materials-1',
                  'topicId': 'expo-materials',
                  'topicTitle': '布展进场',
                  'state': 'published',
                  'author': const <String, Object?>{
                    'authorId': 'member-1',
                    'displayName': '赵工',
                  },
                  'content': '用于收藏截图的帖子正文。',
                  'attachmentRefs': const <Object?>[],
                  'publishedAt': '2026-03-31T09:30:00Z',
                  if (detailReadCount == 1) 'viewerHasLiked': false,
                  if (detailReadCount == 1) 'viewerHasBookmarked': false,
                },
              );
            },
            'GET /api/app/forum/post/comments': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: const <String, Object?>{
                  'items': <Object?>[],
                  'page': <String, Object?>{
                    'nextCursor': null,
                    'hasMore': false,
                  },
                },
              );
            },
            'POST /api/app/forum/post/bookmark': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 202,
                uri: request.uri,
                body: const <String, Object?>{
                  'postId': 'post-materials-1',
                  'state': 'bookmarked',
                  'viewerHasBookmarked': true,
                },
              );
            },
          },
    );
    await tester.tap(find.text('收藏'));
    await tester.pumpAndSettle();
    await _capture(boundaryKey, '06_bookmark_success.png');

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
                      'draftId': 'draft-1',
                      'draftType': 'reply',
                      'topicId': 'expo-materials',
                      'title': '待删除草稿',
                      'excerpt': '草稿摘要',
                      'state': 'ready_to_publish',
                      'updatedAt': '2026-03-31T09:00:00Z',
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
    await _capture(boundaryKey, '07_draft_swipe_delete.png');

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
                body: <String, Object?>{
                  'items': <Object?>[
                    <String, Object?>{
                      'postId': 'post-active-1',
                      'title': '活跃帖子',
                      'topicId': 'expo-materials',
                      'topicTitle': '布展进场',
                      'excerpt': '仍在公开区可见。',
                      'state': 'published',
                      'publishedAt': '2026-03-27T09:30:00Z',
                      'updatedAt': '2026-03-31T09:30:00Z',
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
                      'updatedAt': '2026-03-31T09:30:00Z',
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
    await tester.drag(find.byType(ListView).first, const Offset(0, -520));
    await tester.pumpAndSettle();
    await _capture(boundaryKey, '08_my_posts_deleted_item.png');
  });
}
