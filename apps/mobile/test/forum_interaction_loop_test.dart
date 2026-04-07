import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';

import 'forum_test_support.dart';

void main() {
  testWidgets(
    'forum comment interaction submits text comment and reloads list',
    (WidgetTester tester) async {
      final comments = <Map<String, Object?>>[];

      await tester.pumpWidget(
        buildForumTestAppWithOverrides(
          initialRoute: ExhibitionRoutes.forumCommentsWithPostId(
            'post-materials-1',
          ),
          forumHandlerOverrides:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'GET /api/app/forum/post/comments':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: <String, Object?>{
                          'items': comments,
                          'page': const <String, Object?>{
                            'nextCursor': null,
                            'hasMore': false,
                          },
                        },
                      );
                    },
                'POST /api/app/forum/post/comment':
                    (AppApiRequest request) async {
                      final body = request.body as Map<String, Object?>;
                      comments.add(<String, Object?>{
                        'commentId': 'comment-live-1',
                        'postId': body['postId'],
                        'parentCommentId': body['parentCommentId'],
                        'author': const <String, Object?>{
                          'authorId': 'member-1',
                          'displayName': '赵工',
                        },
                        'body': body['body'],
                        'state': 'published',
                        'publishedAt': '2026-03-30T11:00:00Z',
                        'replyCount': 0,
                      });
                      return AppApiResponse(
                        statusCode: 202,
                        uri: request.uri,
                        body: <String, Object?>{
                          'commentId': 'comment-live-1',
                          'postId': body['postId'],
                          'parentCommentId': body['parentCommentId'],
                          'state': 'published',
                          'publishedAt': '2026-03-30T11:00:00Z',
                        },
                      );
                    },
              },
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, '这是一条正式评论');
      await tester.drag(find.byType(ListView).first, const Offset(0, -260));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, '发送回复').first);
      await tester.pump();
      await tester.pumpAndSettle();
      expect(comments, hasLength(1));
    },
  );

  testWidgets('forum detail like toggle follows authoritative response', (
    WidgetTester tester,
  ) async {
    var liked = false;
    var likeCount = 0;

    Future<AppApiResponse> postDetail(AppApiRequest request) async {
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
          'viewerHasLiked': liked,
          'viewerHasBookmarked': false,
          'viewerFollowsTopic': true,
        },
      );
    }

    await tester.pumpWidget(
      buildForumTestAppWithOverrides(
        initialRoute: ExhibitionRoutes.forumPostWithPostId('post-materials-1'),
        forumHandlerOverrides:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/forum/post/detail': postDetail,
              'POST /api/app/forum/post/like': (AppApiRequest request) async {
                final body = request.body as Map<String, Object?>;
                liked = body['action'] == 'like';
                likeCount = liked ? 1 : 0;
                return AppApiResponse(
                  statusCode: 202,
                  uri: request.uri,
                  body: <String, Object?>{
                    'postId': body['postId'],
                    'state': liked ? 'liked' : 'unliked',
                    'viewerHasLiked': liked,
                    'likeCount': likeCount,
                  },
                );
              },
            },
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('点赞'), 200);
    await tester.tap(find.text('点赞'));
    await tester.pumpAndSettle();

    expect(find.text('已点赞'), findsWidgets);
  });

  testWidgets('forum detail bookmark toggle follows authoritative response', (
    WidgetTester tester,
  ) async {
    var bookmarked = false;

    Future<AppApiResponse> postDetail(AppApiRequest request) async {
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
          'viewerHasBookmarked': bookmarked,
          'viewerFollowsTopic': true,
        },
      );
    }

    await tester.pumpWidget(
      buildForumTestAppWithOverrides(
        initialRoute: ExhibitionRoutes.forumPostWithPostId('post-materials-1'),
        forumHandlerOverrides:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/forum/post/detail': postDetail,
              'POST /api/app/forum/post/bookmark':
                  (AppApiRequest request) async {
                    final body = request.body as Map<String, Object?>;
                    bookmarked = body['action'] == 'add';
                    return AppApiResponse(
                      statusCode: 202,
                      uri: request.uri,
                      body: <String, Object?>{
                        'postId': body['postId'],
                        'state': bookmarked ? 'bookmarked' : 'unbookmarked',
                        'viewerHasBookmarked': bookmarked,
                      },
                    );
                  },
            },
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('收藏'), 200);
    await tester.tap(find.text('收藏'));
    await tester.pumpAndSettle();

    expect(find.text('已收藏'), findsWidgets);
  });

  testWidgets('forum me comments consumes bounded nested post anchor shape', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildForumTestAppWithOverrides(
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
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('这是我刚刚提交的评论'), findsOneWidget);
    expect(find.text('夜间进场窗口怎么排吊装和安检顺序？'), findsOneWidget);
    expect(find.text('查看原帖'), findsOneWidget);
  });

  testWidgets('forum me comments tolerates compact runtime asset shape', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildForumTestAppWithOverrides(
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
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('这是当前账号刚发出的评论'), findsOneWidget);
    expect(find.text('夜间进场怎么排安检和吊装？'), findsOneWidget);
    expect(find.textContaining('评论时间：'), findsOneWidget);
  });

  testWidgets('forum me bookmarks consumes bounded post anchor shape', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildForumTestAppWithOverrides(
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
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('供应商交接模板怎么落地更省沟通'), findsOneWidget);
    expect(find.textContaining('王监理'), findsOneWidget);
    expect(find.text('查看帖子'), findsOneWidget);
  });
}
