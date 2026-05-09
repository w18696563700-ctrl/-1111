import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/exhibition/presentation/forum/forum_pages.dart';

import 'forum_test_support.dart';

Map<String, Object?> _detailBody({
  bool includeViewerFlags = true,
  bool viewerHasLiked = false,
  bool viewerHasBookmarked = false,
}) {
  return <String, Object?>{
    'postId': 'post-materials-1',
    'topicId': 'expo-materials',
    'topicTitle': '布展进场',
    'state': 'published',
    'author': <String, Object?>{'authorId': 'member-1', 'displayName': '赵工'},
    'content': '正式帖子正文',
    'attachmentRefs': <Object?>[],
    'engagement': <String, Object?>{
      'replyCount': 0,
      'likeCount': viewerHasLiked ? 1 : 0,
      'viewCount': 0,
    },
    'publishedAt': '2026-03-27T09:30:00Z',
    if (includeViewerFlags) 'viewerHasLiked': viewerHasLiked,
    if (includeViewerFlags) 'viewerHasBookmarked': viewerHasBookmarked,
  };
}

void main() {
  testWidgets(
    'forum detail keeps accepted like and bookmark state when reread omits viewer fields',
    (WidgetTester tester) async {
      var detailReadCount = 0;

      await tester.pumpWidget(
        buildForumTestAppWithOverrides(
          initialRoute: ExhibitionRoutes.forumPostWithPostId(
            'post-materials-1',
          ),
          forumHandlerOverrides:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'GET /api/app/forum/post/detail':
                    (AppApiRequest request) async {
                      detailReadCount += 1;
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: detailReadCount == 1
                            ? _detailBody()
                            : _detailBody(includeViewerFlags: false),
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
                      'likeCount': 1,
                    },
                  );
                },
                'POST /api/app/forum/post/bookmark':
                    (AppApiRequest request) async {
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
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('点赞').first);
      await tester.pumpAndSettle();
      expect(find.text('已点赞'), findsWidgets);

      await tester.tap(find.textContaining('收藏').first);
      await tester.pumpAndSettle();
      expect(find.text('已收藏'), findsWidgets);
    },
  );

  testWidgets('forum my posts hides archived records from the default list', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildForumTestAppWithOverrides(
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
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('活跃帖子'), findsOneWidget);
    expect(find.text('已删除帖子'), findsNothing);
    expect(find.text('已删除记录'), findsNothing);
    expect(find.text('编辑帖子'), findsOneWidget);
    expect(find.text('查看帖子'), findsOneWidget);
  });

  testWidgets(
    'forum drafts swipe delete removes draft after accepted response',
    (WidgetTester tester) async {
      var deleted = false;

      await tester.pumpWidget(
        buildForumTestAppWithOverrides(
          initialRoute: ExhibitionRoutes.forumDrafts,
          forumHandlerOverrides:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'GET /api/app/forum/draft/list': (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: <String, Object?>{
                      'items': deleted
                          ? const <Object?>[]
                          : <Object?>[
                              <String, Object?>{
                                'draftId': 'draft-1',
                                'draftType': 'reply',
                                'topicId': 'expo-materials',
                                'title': '待删除草稿',
                                'excerpt': '草稿摘要',
                                'state': 'ready_to_publish',
                                'updatedAt': '2026-03-27T09:00:00Z',
                                'attachmentRefs': const <Object?>[],
                              },
                            ],
                      'page': const <String, Object?>{
                        'nextCursor': null,
                        'hasMore': false,
                      },
                    },
                  );
                },
                'POST /api/app/forum/draft/delete':
                    (AppApiRequest request) async {
                      deleted = true;
                      return AppApiResponse(
                        statusCode: 202,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'draftId': 'draft-1',
                          'state': 'deleted',
                        },
                      );
                    },
              },
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(find.text('待删除草稿'), const Offset(-120, 0));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.remove_rounded), findsOneWidget);
      await tester.tap(find.byIcon(Icons.remove_rounded));
      await tester.pumpAndSettle();

      expect(find.text('暂无草稿'), findsOneWidget);
      expect(find.text('草稿已删除'), findsOneWidget);
    },
  );

  testWidgets(
    'forum drafts publish button completes the publish continuation',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildForumTestApp(initialRoute: ExhibitionRoutes.forumDrafts),
      );
      await tester.pumpAndSettle();

      expect(find.text('本地进场夜班经验分享'), findsOneWidget);
      expect(find.text('发布帖子'), findsOneWidget);

      await tester.tap(find.text('发布帖子'));
      await tester.pumpAndSettle();

      expect(find.text('帖子详情'), findsOneWidget);
      expect(find.text('正式帖子正文'), findsOneWidget);
      expect(find.text('发布帖子'), findsNothing);
    },
  );

  testWidgets('forum my published post delete removes the card after confirm', (
    WidgetTester tester,
  ) async {
    var deleted = false;

    await tester.pumpWidget(
      buildForumTestAppWithOverrides(
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
                        'postId': 'post-delete-1',
                        'title': '可删除已发布帖子',
                        'topicId': 'expo-materials',
                        'topicTitle': '布展进场',
                        'excerpt': '这是一条可删的已发布帖子。',
                        'state': 'published',
                        'publishedAt': '2026-03-27T09:30:00Z',
                        'updatedAt': '2026-03-30T09:30:00Z',
                        'canEdit': true,
                        'canDelete': true,
                      },
                    ],
                    'page': <String, Object?>{
                      'nextCursor': null,
                      'hasMore': false,
                    },
                  },
                );
              },
              'POST /api/app/forum/post/delete': (AppApiRequest request) async {
                deleted = true;
                return AppApiResponse(
                  statusCode: 202,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'postId': 'post-delete-1',
                    'state': 'archived',
                    'archivedAt': '2026-03-30T09:57:48.523Z',
                    'message': '帖子已删除',
                  },
                );
              },
            },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('可删除已发布帖子'), findsOneWidget);
    await tester.tap(find.text('删除帖子'));
    await tester.pumpAndSettle();
    expect(find.text('删除后，这篇帖子会从公开列表中移除，并按受控删除结果处理。是否继续？'), findsOneWidget);

    await tester.tap(find.text('确认删除'));
    await tester.pumpAndSettle();

    expect(deleted, isTrue);
    expect(find.text('可删除已发布帖子'), findsNothing);
    expect(find.text('帖子已删除'), findsOneWidget);
  });

  testWidgets('forum draft delete 404 stays Chinese and controlled', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildForumTestAppWithOverrides(
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
                        'title': '删除失败草稿',
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
              'POST /api/app/forum/draft/delete':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 404,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'message': 'Cannot POST /bff/forum/draft/delete',
                        'error': 'Not Found',
                        'statusCode': 404,
                      },
                    );
                  },
            },
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.text('删除失败草稿'), const Offset(-120, 0));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.remove_rounded), findsOneWidget);
    await tester.tap(find.byIcon(Icons.remove_rounded));
    await tester.pumpAndSettle();

    expect(find.text('当前草稿删除入口暂不可用，请稍后再试'), findsOneWidget);
    expect(find.textContaining('Cannot POST'), findsNothing);
  });

  testWidgets('forum my posts route-missing 404 stays specific and Chinese', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildForumTestAppWithOverrides(
        initialRoute: ExhibitionRoutes.forumMePosts,
        forumHandlerOverrides:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/forum/me/posts': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 404,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'message': 'Cannot GET /api/app/forum/me/posts',
                    'error': 'Not Found',
                    'statusCode': 404,
                  },
                );
              },
            },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('当前云端 BFF 尚未部署我的帖子读侧路由，请先同步云端后再试。'), findsOneWidget);
    expect(find.text('这表示当前云端运行时还没有挂出对应论坛读侧接口，请先同步云端后再试。'), findsOneWidget);
    expect(find.text('当前内容暂不可用'), findsNothing);
    expect(find.text('这个内容现在还不能查看。'), findsNothing);
    expect(find.textContaining('Cannot GET'), findsNothing);
  });

  testWidgets('forum draft save auth failure is specific and legible', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildForumTestAppWithOverrides(
        initialRoute: ExhibitionRoutes.forumPublish,
        forumHandlerOverrides:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'POST /api/app/forum/draft/save': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 401,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'statusCode': 401,
                    'code': 'AUTH_SESSION_INVALID',
                    'message': 'Request failed with status code 401',
                  },
                );
              },
            },
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '草稿保存失败验证');
    await tester.enterText(find.byType(TextField).at(1), '这是一条用于验证草稿失败提示的正文。');
    await tester.pump();

    await tester.tap(find.text('保存草稿并跳转至草稿箱发布帖子'));
    await tester.pumpAndSettle();

    const expectedMessage = '当前登录状态已失效，请重新登录后再保存草稿';
    expect(find.text(expectedMessage), findsOneWidget);
    expect(find.text('草稿暂时保存失败，请稍后再试'), findsNothing);
    expect(find.textContaining('Request failed'), findsNothing);

    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    final context = tester.element(find.byType(SnackBar));
    final colorScheme = Theme.of(context).colorScheme;
    expect(snackBar.backgroundColor, colorScheme.errorContainer);
    final messageText = tester.widget<Text>(find.text(expectedMessage));
    expect(messageText.style?.color, colorScheme.onErrorContainer);
  });

  testWidgets('forum draft save 502 explains cloud bff reachability', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildForumTestAppWithOverrides(
        initialRoute: ExhibitionRoutes.forumPublish,
        forumHandlerOverrides:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'POST /api/app/forum/draft/save': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 502,
                  uri: request.uri,
                  body: '<html><body>Bad Gateway</body></html>',
                );
              },
            },
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '草稿保存 502 验证');
    await tester.enterText(
      find.byType(TextField).at(1),
      '这是一条用于验证 BFF 不可达提示的正文。',
    );
    await tester.pump();

    await tester.tap(find.text('保存草稿并跳转至草稿箱发布帖子'));
    await tester.pumpAndSettle();

    expect(find.text('云端 BFF 暂时不可达，草稿没有保存，请稍后重试'), findsOneWidget);
    expect(find.text('草稿暂时保存失败，请稍后再试'), findsNothing);
    expect(find.textContaining('Bad Gateway'), findsNothing);
  });

  testWidgets(
    'forum pending media starts automatically after content is ready',
    (WidgetTester tester) async {
      ForumPublishMediaDebugOverrides.installPicker(
        (_) async => const <ForumPublishMediaDraft>[
          ForumPublishMediaDraft(
            fileName: '现场照片.jpg',
            bytes: <int>[1, 2, 3, 4, 5, 6],
          ),
        ],
      );
      addTearDown(ForumPublishMediaDebugOverrides.reset);

      var uploadInitCount = 0;
      var uploadConfirmCount = 0;

      await tester.pumpWidget(
        buildForumTestAppWithOverrides(
          initialRoute: ExhibitionRoutes.forumPublish,
          exhibitionHandlerOverrides:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'POST /api/app/file/upload/init':
                    (AppApiRequest request) async {
                      uploadInitCount += 1;
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'uploadSessionId': 'upload-session-image-1',
                          'directUpload': <String, Object?>{
                            'url': 'https://upload.example.com/forum-image-1',
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
                'POST /api/app/file/upload/confirm':
                    (AppApiRequest request) async {
                      uploadConfirmCount += 1;
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'fileAssetId': 'asset-image-1',
                        },
                      );
                    },
              },
          exhibitionUploadHandler: (AppApiUploadRequest request) async {
            return AppApiResponse(statusCode: 200, uri: Uri.parse(request.url));
          },
          forumHandlerOverrides:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'POST /api/app/forum/draft/save':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 202,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'draftId': 'draft-saved-1',
                          'state': 'ready_to_publish',
                          'updatedAt': '2026-03-31T10:40:00Z',
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

      expect(uploadInitCount, 0);
      expect(find.text('现场照片.jpg'), findsWidgets);
      expect(find.text('正文图片'), findsOneWidget);
      expect(find.text('图片预览'), findsOneWidget);
      expect(find.text('附件已选中，请先填写分类、标题和正文'), findsOneWidget);

      await tester.drag(find.byType(ListView).first, const Offset(0, 320));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, '先补内容再续传');
      await tester.enterText(find.byType(TextField).last, '这条用来验证保存草稿后会继续上传。');
      await tester.pump();

      await tester.drag(find.byType(ListView).first, const Offset(0, -320));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      expect(uploadInitCount, 1);
      expect(uploadConfirmCount, 1);
      expect(find.text('开始上传'), findsNothing);
      expect(find.text('上传确认完成，等待保存草稿'), findsOneWidget);
    },
  );

  testWidgets('forum selected file preview offers local open action', (
    WidgetTester tester,
  ) async {
    ForumPublishMediaDebugOverrides.installPicker(
      (_) async => const <ForumPublishMediaDraft>[
        ForumPublishMediaDraft(
          fileName: '交付清单.pdf',
          bytes: <int>[1, 2, 3, 4, 5, 6],
        ),
      ],
    );
    addTearDown(ForumPublishMediaDebugOverrides.reset);

    await tester.pumpWidget(
      buildForumTestAppWithOverrides(
        initialRoute: ExhibitionRoutes.forumPublish,
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView).first, const Offset(0, -280));
    await tester.pumpAndSettle();
    await tester.tap(find.text('添加文件'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('交付清单.pdf').first);
    await tester.pumpAndSettle();

    expect(find.text('在系统中打开文件'), findsOneWidget);
    expect(find.textContaining('本地内容预览本轮未引入'), findsNothing);
  });

  testWidgets('forum picker failure stays controlled and visible', (
    WidgetTester tester,
  ) async {
    ForumPublishMediaDebugOverrides.installPicker((_) async {
      throw ArgumentError('picker unavailable');
    });
    addTearDown(ForumPublishMediaDebugOverrides.reset);

    await tester.pumpWidget(
      buildForumTestAppWithOverrides(
        initialRoute: ExhibitionRoutes.forumPublish,
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView).first, const Offset(0, -280));
    await tester.pumpAndSettle();
    await tester.tap(find.text('添加图片'));
    await tester.pumpAndSettle();

    expect(find.text('当前设备暂时打不开图片选择器，请稍后再试'), findsOneWidget);
  });
}
