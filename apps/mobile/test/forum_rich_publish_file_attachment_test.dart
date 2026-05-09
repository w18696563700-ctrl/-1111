import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/exhibition/presentation/forum/forum_pages.dart';

import 'forum_test_support.dart';

void main() {
  testWidgets(
    'forum publish file upload binds confirmed file asset ids into draft save',
    (WidgetTester tester) async {
      ForumPublishMediaDebugOverrides.installPicker(
        (_) async => const <ForumPublishMediaDraft>[
          ForumPublishMediaDraft(
            fileName: '现场交付清单.pdf',
            bytes: <int>[37, 80, 68, 70, 45, 49, 46, 55],
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
                      expect(body['fileKind'], '现场交付清单.pdf');
                      expect(body['mimeType'], 'application/pdf');
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'uploadSessionId': 'upload-session-file-1',
                          'directUpload': <String, Object?>{
                            'url': 'https://upload.example.com/forum-file-1',
                            'method': 'PUT',
                            'headers': <String, Object?>{
                              'content-type': 'application/pdf',
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
                        'uploadSessionId': 'upload-session-file-1',
                      });
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'fileAssetId': 'asset-file-1',
                        },
                      );
                    },
              },
          exhibitionUploadHandler: (AppApiUploadRequest request) async {
            expect(request.method, 'PUT');
            expect(request.headers['content-type'], 'application/pdf');
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
                          'updatedAt': '2026-03-30T18:40:00Z',
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
                      'postId': 'post-with-file-asset-1',
                      'state': 'published',
                      'summary': <String, Object?>{
                        'title': '文件附件帖子',
                        'publishedAt': '2026-03-30T19:00:00Z',
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
                          'postId': 'post-with-file-asset-1',
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
                              'fileAssetId': 'asset-file-1',
                              'fileName': '现场交付清单.pdf',
                              'mimeType': 'application/pdf',
                            },
                          ],
                          'publishedAt': '2026-03-30T18:30:00Z',
                          'engagement': <String, Object?>{
                            'replyCount': 0,
                            'likeCount': 0,
                            'viewCount': 0,
                          },
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

      await tester.enterText(find.byType(TextField).at(0), '文件附件发帖验证');
      await tester.enterText(find.byType(TextField).at(1), '这是一条带 PDF 的论坛草稿。');
      await tester.pump();

      await tester.drag(find.byType(ListView).first, const Offset(0, -320));
      await tester.pumpAndSettle();
      await tester.tap(find.text('添加文件'));
      await tester.pumpAndSettle();

      expect(find.text('现场交付清单.pdf'), findsOneWidget);
      expect(find.textContaining('PDF ·'), findsOneWidget);
      await tester.pumpAndSettle();

      expect(find.text('上传确认完成，等待保存草稿'), findsOneWidget);

      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      await tester.tap(find.text('保存草稿并跳转至草稿箱发布帖子'));
      await tester.pumpAndSettle();

      expect(draftSaveBodies.last['attachmentFileAssetIds'], const <String>[
        'asset-file-1',
      ]);
      expect(find.text('草稿'), findsOneWidget);
      expect(find.text('本地进场夜班经验分享'), findsOneWidget);
      expect(find.text('application/pdf'), findsNothing);
    },
  );

  testWidgets(
    'forum publish file picker blocks unsupported file with controlled Chinese message',
    (WidgetTester tester) async {
      ForumPublishMediaDebugOverrides.installPicker(
        (_) async => const <ForumPublishMediaDraft>[
          ForumPublishMediaDraft(
            fileName: '恶意压缩包.zip',
            bytes: <int>[1, 2, 3, 4],
          ),
        ],
      );
      addTearDown(ForumPublishMediaDebugOverrides.reset);

      var initRequestCount = 0;

      await tester.pumpWidget(
        buildForumTestAppWithOverrides(
          initialRoute: ExhibitionRoutes.forumPublish,
          exhibitionHandlerOverrides:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'POST /api/app/file/upload/init':
                    (AppApiRequest request) async {
                      initRequestCount += 1;
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{},
                      );
                    },
              },
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), '不支持附件');
      await tester.enterText(find.byType(TextField).at(1), 'zip 不应被当成已支持文件。');
      await tester.pump();

      await tester.drag(find.byType(ListView).first, const Offset(0, -320));
      await tester.pumpAndSettle();
      await tester.tap(find.text('添加文件'));
      await tester.pumpAndSettle();

      expect(find.text('论坛附件目前只支持图片、视频以及 PDF/文档文件。'), findsOneWidget);
      expect(find.text('恶意压缩包.zip'), findsNothing);
      expect(initRequestCount, 0);
    },
  );

  testWidgets(
    'forum publish file picker blocks oversize document with controlled Chinese message',
    (WidgetTester tester) async {
      ForumPublishMediaDebugOverrides.installPicker(
        (_) async => <ForumPublishMediaDraft>[
          ForumPublishMediaDraft(
            fileName: '超限资料.pdf',
            bytes: Uint8List(20 * 1024 * 1024 + 1),
          ),
        ],
      );
      addTearDown(ForumPublishMediaDebugOverrides.reset);

      var initRequestCount = 0;

      await tester.pumpWidget(
        buildForumTestAppWithOverrides(
          initialRoute: ExhibitionRoutes.forumPublish,
          exhibitionHandlerOverrides:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'POST /api/app/file/upload/init':
                    (AppApiRequest request) async {
                      initRequestCount += 1;
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{},
                      );
                    },
              },
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), '超限附件');
      await tester.enterText(find.byType(TextField).at(1), '超限文档需要在本地就被受控拦住。');
      await tester.pump();

      await tester.drag(find.byType(ListView).first, const Offset(0, -320));
      await tester.pumpAndSettle();
      await tester.tap(find.text('添加文件'));
      await tester.pumpAndSettle();

      expect(find.text('论坛文档附件单个文件不能超过 20 MiB。'), findsOneWidget);
      expect(find.text('超限资料.pdf'), findsNothing);
      expect(initRequestCount, 0);
    },
  );
}
