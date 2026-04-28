import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';

import 'forum_test_support.dart';

const String _outputDir =
    '/Users/wangweiwei/Desktop/展览装修之家总控/.tmp/agent_reports/forum_messages_inbox_finish_round/20260331';

Map<String, Object?> _inboxItem({
  required String notificationId,
  required String tab,
  required String targetType,
  required String targetId,
  required String title,
  String? preview,
}) {
  return <String, Object?>{
    'notificationId': notificationId,
    'tab': tab,
    'actor': <String, Object?>{
      'authorId': 'member-1',
      'displayName': '王监理',
      'organizationName': '现场协作组',
    },
    'targetType': targetType,
    'targetId': targetId,
    'title': title,
    'preview': preview,
    'createdAt': '2026-03-31T12:00:00Z',
    'unread': true,
    'canQuickReply': true,
  };
}

Future<void> _pumpMessagesApp(
  WidgetTester tester,
  GlobalKey boundaryKey, {
  required Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
  forumHandlerOverrides,
}) async {
  await tester.pumpWidget(
    RepaintBoundary(
      key: boundaryKey,
      child: KeyedSubtree(
        key: UniqueKey(),
        child: buildForumTestAppWithOverrides(
          initialRoute: '/messages',
          forumHandlerOverrides: forumHandlerOverrides,
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

  testWidgets('capture forum messages inbox finish round screenshots', (
    WidgetTester tester,
  ) async {
    final boundaryKey = GlobalKey();
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
    await tester.binding.setSurfaceSize(const Size(393, 852));

    await _pumpMessagesApp(
      tester,
      boundaryKey,
      forumHandlerOverrides:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/forum/interaction/inbox':
                (AppApiRequest request) async {
                  final tab = request.uri.queryParameters['tab'];
                  final items = switch (tab) {
                    'likes' => <Object?>[
                      _inboxItem(
                        notificationId: 'notice-like-1',
                        tab: 'likes',
                        targetType: 'forum_post',
                        targetId: 'post-1',
                        title: '赞了你在《搭建夜班排班》下的评论',
                      ),
                    ],
                    'follows' => <Object?>[
                      _inboxItem(
                        notificationId: 'notice-follow-1',
                        tab: 'follows',
                        targetType: 'forum_topic',
                        targetId: 'topic-1',
                        title: '新关注了你的话题更新',
                      ),
                    ],
                    _ => <Object?>[
                      _inboxItem(
                        notificationId: 'notice-reply-1',
                        tab: 'replies',
                        targetType: 'forum_post',
                        targetId: 'post-1',
                        title: '回复了你在《材料交接节点》里的问题',
                        preview: '建议先锁定吊装批次。',
                      ),
                    ],
                  };
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: <String, Object?>{
                      'items': items,
                      'page': const <String, Object?>{
                        'nextCursor': null,
                        'hasMore': false,
                      },
                    },
                  );
                },
          },
    );
    await tester.tap(find.text('回复我的').last);
    await tester.pumpAndSettle();
    await _capture(boundaryKey, '01_replies_inbox.png');

    await tester.tap(find.text('收到的赞').last);
    await tester.pumpAndSettle();
    await _capture(boundaryKey, '02_likes_inbox.png');

    await _pumpMessagesApp(
      tester,
      boundaryKey,
      forumHandlerOverrides:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/forum/interaction/inbox':
                (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: <String, Object?>{
                      'items': <Object?>[
                        _inboxItem(
                          notificationId: 'notice-comment-1',
                          tab: 'replies',
                          targetType: 'forum_comment',
                          targetId: 'comment-1',
                          title: '回复了你的评论',
                          preview: '这是一条评论回复。',
                        ),
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
    await _capture(boundaryKey, '03_forum_comment_guidance.png');

    await _pumpMessagesApp(
      tester,
      boundaryKey,
      forumHandlerOverrides:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/forum/interaction/inbox':
                (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 404,
                    uri: request.uri,
                    body: <String, Object?>{'message': 'forum inbox missing'},
                  );
                },
          },
    );
    await tester.tap(find.text('新关注').last);
    await tester.pumpAndSettle();
    await _capture(boundaryKey, '04_follows_not_found.png');
  });
}
