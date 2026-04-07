import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';

import 'forum_test_support.dart';

const String _outputDir =
    '/Users/wangweiwei/Desktop/展览装修之家总控/.tmp/agent_reports/forum_interaction_loop_frontend/20260330';

Future<void> _pumpCaptureApp(
  WidgetTester tester,
  GlobalKey boundaryKey, {
  required String initialRoute,
  Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
      forumHandlerOverrides =
      const <String, Future<AppApiResponse> Function(AppApiRequest request)>{},
}) async {
  await tester.pumpWidget(
    RepaintBoundary(
      key: boundaryKey,
      child: KeyedSubtree(
        key: UniqueKey(),
        child: buildForumTestAppWithOverrides(
          initialRoute: initialRoute,
          forumHandlerOverrides: forumHandlerOverrides,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _capture(
  WidgetTester tester,
  GlobalKey boundaryKey,
  String filename,
) async {
  await expectLater(
    find.byKey(boundaryKey),
    matchesGoldenFile('$_outputDir/$filename'),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture comment interaction formal surface', (
    WidgetTester tester,
  ) async {
    final boundaryKey = GlobalKey();
    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumCommentsWithPostId(
        'post-materials-1',
      ),
    );
    await _capture(tester, boundaryKey, '01_comment_interaction.png');
  });

  testWidgets('capture detail liked surface', (WidgetTester tester) async {
    final boundaryKey = GlobalKey();
    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumPostWithPostId('post-materials-1'),
      forumHandlerOverrides:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/forum/post/detail': (AppApiRequest request) async {
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
                  'content': '正式帖子正文',
                  'attachmentRefs': const <Object?>[],
                  'publishedAt': '2026-03-27T09:30:00Z',
                  'viewerHasLiked': true,
                  'viewerHasBookmarked': false,
                  'viewerFollowsTopic': true,
                },
              );
            },
          },
    );
    await tester.scrollUntilVisible(find.text('已点赞'), 200);
    await tester.pumpAndSettle();
    await _capture(tester, boundaryKey, '02_post_detail_liked.png');
  });

  testWidgets('capture detail bookmarked surface', (WidgetTester tester) async {
    final boundaryKey = GlobalKey();
    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumPostWithPostId('post-materials-1'),
      forumHandlerOverrides:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/forum/post/detail': (AppApiRequest request) async {
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
                  'content': '正式帖子正文',
                  'attachmentRefs': const <Object?>[],
                  'publishedAt': '2026-03-27T09:30:00Z',
                  'viewerHasLiked': false,
                  'viewerHasBookmarked': true,
                  'viewerFollowsTopic': true,
                },
              );
            },
          },
    );
    await tester.scrollUntilVisible(find.text('已收藏'), 200);
    await tester.pumpAndSettle();
    await _capture(tester, boundaryKey, '03_post_detail_bookmarked.png');
  });

  testWidgets('capture my comments surface', (WidgetTester tester) async {
    final boundaryKey = GlobalKey();
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
                body: <String, Object?>{
                  'items': <Object?>[
                    <String, Object?>{
                      'commentId': 'comment-loop-1',
                      'postId': 'post-loop-1',
                      'parentCommentId': null,
                      'author': const <String, Object?>{
                        'authorId': 'member-1',
                        'displayName': '赵工',
                      },
                      'body': '这是我刚刚提交的评论',
                      'state': 'published',
                      'publishedAt': '2026-03-30T10:12:00Z',
                      'replyCount': 2,
                      'post': const <String, Object?>{
                        'postId': 'post-loop-1',
                        'topicId': 'expo-materials',
                        'topicLabel': '布展进场',
                        'title': '夜间进场窗口怎么排吊装和安检顺序？',
                        'excerpt': '帖子摘要',
                        'publishedAt': '2026-03-27T09:30:00Z',
                      },
                    },
                  ],
                  'page': const <String, Object?>{
                    'nextCursor': null,
                    'hasMore': false,
                  },
                },
              );
            },
          },
    );
    await _capture(tester, boundaryKey, '04_my_comments.png');
  });

  testWidgets('capture my bookmarks surface', (WidgetTester tester) async {
    final boundaryKey = GlobalKey();
    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumMeBookmarks,
      forumHandlerOverrides:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/forum/me/bookmarks': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: <String, Object?>{
                  'items': <Object?>[
                    <String, Object?>{
                      'bookmarkId': 'bookmark-loop-1',
                      'postId': 'post-bookmark-1',
                      'state': 'bookmarked',
                      'bookmarkedAt': '2026-03-30T10:15:00Z',
                      'post': const <String, Object?>{
                        'postId': 'post-bookmark-1',
                        'topicId': 'vendor-collab',
                        'topicLabel': '材料协同',
                        'title': '供应商交接模板怎么落地更省沟通',
                        'excerpt': '帖子摘要',
                        'author': <String, Object?>{
                          'authorId': 'member-2',
                          'displayName': '王监理',
                        },
                        'publishedAt': '2026-03-27T09:30:00Z',
                      },
                    },
                  ],
                  'page': const <String, Object?>{
                    'nextCursor': null,
                    'hasMore': false,
                  },
                },
              );
            },
          },
    );
    await _capture(tester, boundaryKey, '05_my_bookmarks.png');
  });
}
