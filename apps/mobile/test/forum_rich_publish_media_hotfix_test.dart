import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/exhibition/presentation/forum/forum_pages.dart';

import 'forum_test_support.dart';

void main() {
  testWidgets('forum media picker opens before draft save handoff', (
    WidgetTester tester,
  ) async {
    ForumPublishMediaDebugOverrides.installPicker(
      (_) async => const <ForumPublishMediaDraft>[
        ForumPublishMediaDraft(
          fileName: '现场照片.jpg',
          bytes: <int>[1, 2, 3, 4, 5, 6],
        ),
      ],
    );
    addTearDown(ForumPublishMediaDebugOverrides.reset);

    var draftSaveRequestCount = 0;

    await tester.pumpWidget(
      buildForumTestAppWithOverrides(
        initialRoute: ExhibitionRoutes.forumPublish,
        forumHandlerOverrides:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'POST /api/app/forum/draft/save': (AppApiRequest request) async {
                draftSaveRequestCount += 1;
                return AppApiResponse(
                  statusCode: 202,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'draftId': 'draft-saved-1',
                    'state': 'ready_to_publish',
                    'updatedAt': '2026-03-30T10:40:00Z',
                  },
                );
              },
            },
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView).first, const Offset(0, -280));
    await tester.pumpAndSettle();
    await tester.tap(find.text('添加图片'));
    await tester.pumpAndSettle();

    expect(draftSaveRequestCount, 0);
    expect(find.text('现场照片.jpg'), findsOneWidget);
  });

  testWidgets(
    'forum publish media video upload binds confirmed file asset ids into draft save',
    (WidgetTester tester) async {
      ForumPublishMediaDebugOverrides.installPicker(
        (_) async => const <ForumPublishMediaDraft>[
          ForumPublishMediaDraft(
            fileName: '现场视频.mp4',
            bytes: <int>[9, 8, 7, 6, 5, 4, 3, 2],
          ),
        ],
      );
      addTearDown(ForumPublishMediaDebugOverrides.reset);

      final draftSaveBodies = <Map<String, Object?>>[];

      await tester.pumpWidget(
        buildForumTestAppWithOverrides(
          initialRoute: ExhibitionRoutes.forumPublish,
          exhibitionHandlerOverrides:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'POST /api/app/file/upload/init':
                    (AppApiRequest request) async {
                      final body = request.body! as Map<String, Object?>;
                      expect(body['businessType'], 'forum_draft_attachment');
                      expect(body['businessId'], 'draft-saved-1');
                      expect(body['fileKind'], 'media');
                      expect(body['mimeType'], 'video/mp4');
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'uploadSessionId': 'upload-session-video-1',
                          'directUpload': <String, Object?>{
                            'url': 'https://upload.example.com/forum-video-1',
                            'method': 'PUT',
                            'headers': <String, Object?>{
                              'content-type': 'video/mp4',
                            },
                          },
                          'confirm': <String, Object?>{
                            'endpoint': '/api/app/file/upload/confirm',
                          },
                        },
                      );
                    },
                'POST /api/app/file/upload/confirm':
                    (AppApiRequest request) async {
                      expect(request.body, const <String, Object?>{
                        'uploadSessionId': 'upload-session-video-1',
                      });
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'fileAssetId': 'asset-video-1',
                        },
                      );
                    },
              },
          exhibitionUploadHandler: (AppApiUploadRequest request) async {
            expect(request.method, 'PUT');
            expect(request.headers['content-type'], 'video/mp4');
            return AppApiResponse(statusCode: 200, uri: Uri.parse(request.url));
          },
          forumHandlerOverrides:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'POST /api/app/forum/draft/save':
                    (AppApiRequest request) async {
                      final body = Map<String, Object?>.from(
                        request.body! as Map<Object?, Object?>,
                      );
                      draftSaveBodies.add(body);
                      return AppApiResponse(
                        statusCode: 202,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'draftId': 'draft-saved-1',
                          'state': 'ready_to_publish',
                          'updatedAt': '2026-03-30T10:40:00Z',
                        },
                      );
                    },
                'POST /api/app/forum/publish': (AppApiRequest request) async {
                  expect(request.body, const <String, Object?>{
                    'draftId': 'draft-saved-1',
                  });
                  return AppApiResponse(
                    statusCode: 202,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'draftId': 'draft-saved-1',
                      'topicId': 'expo-materials',
                      'postId': 'post-with-video-asset-1',
                      'state': 'published',
                      'summary': <String, Object?>{
                        'title': '视频附件帖子',
                        'publishedAt': '2026-03-30T11:00:00Z',
                      },
                      'decision': 'clear',
                      'message': '发布成功',
                    },
                  );
                },
                'GET /api/app/forum/post/detail':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'postId': 'post-with-video-asset-1',
                          'topicId': 'expo-materials',
                          'topicTitle': '布展进场',
                          'state': 'published',
                          'author': <String, Object?>{
                            'authorId': 'member-1',
                            'displayName': '赵工',
                          },
                          'content': '正式帖子正文',
                          'attachmentRefs': <Object?>[
                            <String, Object?>{
                              'fileAssetId': 'asset-video-1',
                              'fileName': '现场视频.mp4',
                              'mimeType': 'video/mp4',
                            },
                          ],
                          'publishedAt': '2026-03-30T09:30:00Z',
                          'viewerHasLiked': false,
                          'viewerHasBookmarked': false,
                          'viewerFollowsTopic': true,
                        },
                      );
                    },
              },
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), '视频附件发帖验证');
      await tester.enterText(find.byType(TextField).at(1), '这是一条带视频附件的论坛草稿。');
      await tester.pump();

      await tester.drag(find.byType(ListView).first, const Offset(0, -280));
      await tester.pumpAndSettle();
      await tester.tap(find.text('添加视频'));
      await tester.pumpAndSettle();

      expect(find.text('现场视频.mp4'), findsOneWidget);
      await tester.pumpAndSettle();

      expect(find.text('上传确认完成，请保存草稿'), findsOneWidget);

      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      await tester.tap(find.text('保存草稿'));
      await tester.pumpAndSettle();

      expect(draftSaveBodies.last['attachmentFileAssetIds'], const <String>[
        'asset-video-1',
      ]);
      expect(find.text('已保存到草稿，附件已承接'), findsOneWidget);
      expect(find.text('已承接到当前草稿'), findsWidgets);

      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      await tester.tap(find.text('发布'));
      await tester.pumpAndSettle();

      expect(find.text('附件'), findsOneWidget);
      expect(find.text('现场视频.mp4'), findsOneWidget);
    },
  );
}
