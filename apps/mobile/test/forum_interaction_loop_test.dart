import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';

import 'forum_test_support.dart';

void main() {
  testWidgets(
    'forum detail keeps comments inline with page size 10 and load more',
    (WidgetTester tester) async {
      final requestedPageSizes = <String?>[];
      final requestedCursors = <String?>[];
      final submittedBodies = <String?>[];
      final firstPage = List<Map<String, Object?>>.generate(
        10,
        (int index) =>
            _commentFixture('comment-${index + 1}', '第 ${index + 1} 条评论'),
      );
      final secondPage = <Map<String, Object?>>[
        _commentFixture('comment-11', '第 11 条评论'),
      ];

      await tester.pumpWidget(
        buildForumTestAppWithOverrides(
          initialRoute: ExhibitionRoutes.forumPostWithPostId(
            'post-materials-1',
          ),
          forumHandlerOverrides:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'GET /api/app/forum/post/detail':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: _detailBody(),
                      );
                    },
                'GET /api/app/forum/post/comments':
                    (AppApiRequest request) async {
                      requestedPageSizes.add(
                        request.uri.queryParameters['pageSize'],
                      );
                      requestedCursors.add(
                        request.uri.queryParameters['cursor'],
                      );
                      final isSecondPage =
                          request.uri.queryParameters['cursor'] == 'cursor-2';
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: <String, Object?>{
                          'items': isSecondPage ? secondPage : firstPage,
                          'page': <String, Object?>{
                            'nextCursor': isSecondPage ? null : 'cursor-2',
                            'hasMore': !isSecondPage,
                          },
                        },
                      );
                    },
                'POST /api/app/forum/post/comment':
                    (AppApiRequest request) async {
                      final body = request.body as Map<String, Object?>;
                      submittedBodies.add(body['body'] as String?);
                      return AppApiResponse(
                        statusCode: 202,
                        uri: request.uri,
                        body: <String, Object?>{
                          'commentId': 'comment-new-1',
                          'postId': body['postId'],
                          'parentCommentId': null,
                          'state': 'published',
                          'publishedAt': '2026-03-30T11:00:00Z',
                        },
                      );
                    },
              },
        ),
      );
      await tester.pumpAndSettle();

      expect(requestedPageSizes.first, '10');
      expect(find.text('查看全部评论'), findsNothing);
      await tester.tap(find.textContaining('评论').first);
      await tester.pumpAndSettle();
      expect(find.text('写评论'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, '详情页内联评论');
      await tester.ensureVisible(find.widgetWithText(FilledButton, '发送'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, '发送'));
      await tester.pumpAndSettle();
      expect(submittedBodies, contains('详情页内联评论'));

      final loadMoreAction = find.widgetWithText(OutlinedButton, '查看更多评论').last;
      await tester.scrollUntilVisible(
        loadMoreAction,
        500,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.ensureVisible(loadMoreAction);
      await tester.pumpAndSettle();
      final loadMoreButton = tester.widget<OutlinedButton>(loadMoreAction);
      loadMoreButton.onPressed?.call();
      await tester.pumpAndSettle();
      expect(requestedCursors, contains('cursor-2'));
      expect(requestedPageSizes, everyElement('10'));
      expect(find.text('第 11 条评论'), findsOneWidget);
    },
  );

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
          'engagement': <String, Object?>{
            'replyCount': 0,
            'likeCount': likeCount,
            'viewCount': 0,
          },
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

    final likeAction = find.textContaining('点赞').first;
    await tester.ensureVisible(likeAction);
    await tester.tap(likeAction);
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
          'engagement': const <String, Object?>{
            'replyCount': 0,
            'likeCount': 0,
            'viewCount': 0,
          },
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

    final bookmarkAction = find.textContaining('收藏').first;
    await tester.ensureVisible(bookmarkAction);
    await tester.tap(bookmarkAction);
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

Map<String, Object?> _detailBody() {
  return const <String, Object?>{
    'postId': 'post-materials-1',
    'topicId': 'expo-materials',
    'topicTitle': '布展进场',
    'state': 'published',
    'author': <String, Object?>{'authorId': 'member-1', 'displayName': '赵工'},
    'content': '正式帖子正文',
    'attachmentRefs': <Object?>[],
    'engagement': <String, Object?>{
      'replyCount': 10,
      'likeCount': 0,
      'viewCount': 0,
    },
    'publishedAt': '2026-03-27T09:30:00Z',
    'viewerHasLiked': false,
    'viewerHasBookmarked': false,
    'viewerFollowsTopic': true,
  };
}

Map<String, Object?> _commentFixture(String commentId, String body) {
  return <String, Object?>{
    'commentId': commentId,
    'postId': 'post-materials-1',
    'parentCommentId': null,
    'author': const <String, Object?>{
      'authorId': 'member-1',
      'displayName': '赵工',
    },
    'body': body,
    'state': 'published',
    'publishedAt': '2026-03-30T11:00:00Z',
    'replyCount': 0,
  };
}
