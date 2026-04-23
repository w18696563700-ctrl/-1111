import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/features/exhibition/data/forum_consumer_layer.dart';
import 'package:mobile/features/messages/data/messages_consumer_layer.dart';
import 'package:mobile/features/messages/data/messages_registered_entry_registry.dart';
import 'package:mobile/features/messages/presentation/messages_page.dart';

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
    'createdAt': '2026-03-27T10:00:00Z',
    'unread': true,
    'canQuickReply': true,
  };
}

Widget _buildApp({
  required FakeAppApiTransport forumTransport,
  FakeAppApiTransport? messageTransport,
}) {
  ForumConsumerLayer.install(
    ForumConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: forumTransport,
      ),
    ),
  );
  MessagesConsumerLayer.install(
    MessagesConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport:
            messageTransport ??
            FakeAppApiTransport(
              handlers:
                  <
                    String,
                    Future<AppApiResponse> Function(AppApiRequest request)
                  >{},
            ),
      ),
    ),
  );
  return const MaterialApp(home: Scaffold(body: MessagesPage()));
}

Map<String, Object?> _messageTodoItem({
  required String todoId,
  required String actionKey,
  required String title,
  required String summary,
  required Map<String, String> instanceRef,
  required Map<String, String> routeParams,
}) {
  final definition = messagesRegisteredEntryByActionKey[actionKey]!;
  return <String, Object?>{
    'todoId': todoId,
    'messageType': 'instance_todo',
    'instanceRef': instanceRef,
    'actionKey': actionKey,
    'title': title,
    'summary': summary,
    'state': 'pending',
    'routeTarget': <String, Object?>{
      'canonicalPath': definition.canonicalPath,
      'localEntryKey': definition.localEntryKey,
      'requiredParams': definition.requiredParams,
      'state': definition.state,
      'routeParams': routeParams,
    },
  };
}

void main() {
  testWidgets('messages building renders forum interaction center', (
    WidgetTester tester,
  ) async {
    final forumTransport = FakeAppApiTransport(
      handlers:
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
                      'page': <String, Object?>{
                        'nextCursor': null,
                        'hasMore': false,
                      },
                    },
                  );
                },
          },
    );

    await tester.pumpWidget(_buildApp(forumTransport: forumTransport));
    await tester.pumpAndSettle();

    expect(find.text('互动中心'), findsOneWidget);
    expect(find.text('回复我的'), findsWidgets);
    expect(find.text('收到的赞'), findsWidgets);
    expect(find.text('新关注'), findsWidgets);
    expect(find.text('这里只显示别人回复你的帖子或评论；你自己发表评论，不会进入“回复我的”。'), findsOneWidget);
    expect(find.text('回复了你在《材料交接节点》里的问题'), findsOneWidget);
    expect(find.text('回到源对象'), findsOneWidget);

    await tester.tap(find.text('收到的赞').last);
    await tester.pumpAndSettle();
    expect(find.text('赞了你在《搭建夜班排班》下的评论'), findsOneWidget);
    expect(find.text('这里只显示别人给你的帖子或评论点的赞。'), findsOneWidget);
  });

  testWidgets(
    'messages building renders project communication reminders in a separate lane',
    (WidgetTester tester) async {
      final forumTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/forum/interaction/inbox':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: <String, Object?>{
                        'items': <Object?>[
                          _inboxItem(
                            notificationId: 'notice-reply-1',
                            tab: 'replies',
                            targetType: 'forum_post',
                            targetId: 'post-1',
                            title: '回复了你在《材料交接节点》里的问题',
                            preview: '建议先锁定吊装批次。',
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
      final messageTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/message/index': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'items': <Object?>[
                      _messageTodoItem(
                        todoId: 'todo-clarification-1',
                        actionKey: 'project_clarification.open',
                        title: '重庆馆项目新增公开澄清',
                        summary: '请回到项目澄清查看最新补充说明。',
                        instanceRef: const <String, String>{
                          'objectType': 'project_clarification',
                          'instanceId': 'clarification-1',
                        },
                        routeParams: const <String, String>{
                          'projectId': 'project-1',
                        },
                      ),
                      _messageTodoItem(
                        todoId: 'todo-thread-1',
                        actionKey: 'bid_thread.open',
                        title: 'A 馆投标线程有新消息',
                        summary: '项目方在沟通与投标里回复了新的交付问题。',
                        instanceRef: const <String, String>{
                          'objectType': 'bid_thread',
                          'instanceId': 'thread-1',
                        },
                        routeParams: const <String, String>{
                          'projectId': 'project-1',
                          'bidId': 'bid-1',
                        },
                      ),
                      _messageTodoItem(
                        todoId: 'todo-inspection-1',
                        actionKey: 'inspection.submit',
                        title: '这条验收待办不应该进入项目沟通提醒',
                        summary: '非项目沟通提醒。',
                        instanceRef: const <String, String>{
                          'objectType': 'inspection',
                          'instanceId': 'inspection-1',
                        },
                        routeParams: const <String, String>{
                          'milestoneId': 'milestone-1',
                        },
                      ),
                    ],
                  },
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          forumTransport: forumTransport,
          messageTransport: messageTransport,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('项目沟通提醒'), findsOneWidget);
      expect(find.text('项目澄清'), findsOneWidget);
      expect(find.text('沟通与投标'), findsOneWidget);
      expect(find.text('重庆馆项目新增公开澄清'), findsOneWidget);
      expect(find.text('A 馆投标线程有新消息'), findsOneWidget);
      expect(find.text('这条验收待办不应该进入项目沟通提醒'), findsNothing);
      await tester.scrollUntilVisible(find.text('回复了你在《材料交接节点》里的问题'), 240);
      expect(find.text('回复了你在《材料交接节点》里的问题'), findsOneWidget);
      expect(find.text('回复我的'), findsWidgets);
    },
  );

  testWidgets(
    'messages page refresh reloads forum inbox and project communication reminders together',
    (WidgetTester tester) async {
      var forumRequestCount = 0;
      var messageRequestCount = 0;
      final forumTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/forum/interaction/inbox':
                  (AppApiRequest request) async {
                    forumRequestCount += 1;
                    final title = forumRequestCount == 1
                        ? '第一次论坛回复'
                        : '第二次论坛回复';
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: <String, Object?>{
                        'items': <Object?>[
                          _inboxItem(
                            notificationId: 'notice-reply-$forumRequestCount',
                            tab: 'replies',
                            targetType: 'forum_post',
                            targetId: 'post-1',
                            title: title,
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
      final messageTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/message/index': (AppApiRequest request) async {
                messageRequestCount += 1;
                final title = messageRequestCount == 1
                    ? '第一次项目澄清提醒'
                    : '第二次项目澄清提醒';
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'items': <Object?>[
                      _messageTodoItem(
                        todoId: 'todo-clarification-$messageRequestCount',
                        actionKey: 'project_clarification.open',
                        title: title,
                        summary: '回到项目澄清查看更新。',
                        instanceRef: const <String, String>{
                          'objectType': 'project_clarification',
                          'instanceId': 'clarification-1',
                        },
                        routeParams: const <String, String>{
                          'projectId': 'project-1',
                        },
                      ),
                    ],
                  },
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          forumTransport: forumTransport,
          messageTransport: messageTransport,
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('第一次论坛回复'), 240);
      expect(find.text('第一次论坛回复'), findsOneWidget);
      expect(find.text('第一次项目澄清提醒'), findsOneWidget);

      final refreshIndicator = tester.state<RefreshIndicatorState>(
        find.byType(RefreshIndicator),
      );
      // Trigger the page-level pull-to-refresh without depending on shell-level routes.
      refreshIndicator.show();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(forumRequestCount, greaterThanOrEqualTo(2));
      expect(messageRequestCount, greaterThanOrEqualTo(2));
      await tester.scrollUntilVisible(find.text('第二次论坛回复'), 240);
      expect(find.text('第二次论坛回复'), findsOneWidget);
      expect(find.text('第二次项目澄清提醒'), findsOneWidget);
    },
  );

  testWidgets('messages building enters empty state for empty inbox', (
    WidgetTester tester,
  ) async {
    final forumTransport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/forum/interaction/inbox':
                (AppApiRequest request) async {
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
          },
    );

    await tester.pumpWidget(_buildApp(forumTransport: forumTransport));
    await tester.pumpAndSettle();

    expect(find.text('回复我的当前为空'), findsOneWidget);
    expect(find.text('这里只显示别人回复你的帖子或评论；你自己发表评论，不会进入“回复我的”。'), findsWidgets);
  });

  testWidgets(
    'messages building surfaces retryable failure in user-facing wording',
    (WidgetTester tester) async {
      final forumTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/forum/interaction/inbox':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 503,
                      uri: request.uri,
                      body: <String, Object?>{'message': 'forum inbox failed'},
                    );
                  },
            },
      );

      await tester.pumpWidget(_buildApp(forumTransport: forumTransport));
      await tester.pumpAndSettle();

      expect(find.text('互动通知暂时不可用，请稍后再试'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '重试'), findsOneWidget);
    },
  );

  testWidgets('forum comment inbox item uses controlled source guidance', (
    WidgetTester tester,
  ) async {
    final forumTransport = FakeAppApiTransport(
      handlers:
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

    await tester.pumpWidget(_buildApp(forumTransport: forumTransport));
    await tester.pumpAndSettle();

    expect(find.text('查看说明'), findsOneWidget);
    expect(find.text('继续回复'), findsNothing);

    await tester.tap(find.text('查看说明'));
    await tester.pumpAndSettle();

    expect(find.text('这条提醒暂时还不能直接打开原评论，请稍后再试。'), findsOneWidget);
  });

  testWidgets('messages building surfaces tab-specific not found wording', (
    WidgetTester tester,
  ) async {
    final forumTransport = FakeAppApiTransport(
      handlers:
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

    await tester.pumpWidget(_buildApp(forumTransport: forumTransport));
    await tester.pumpAndSettle();

    expect(find.text('当前“回复我的”入口暂不可用，请稍后再试。'), findsOneWidget);
  });
}
