import 'dart:async';

import 'package:flutter/foundation.dart';
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
  ValueListenable<int>? refreshSignal,
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
  return MaterialApp(
    home: Scaffold(body: MessagesPage(refreshSignal: refreshSignal)),
  );
}

Map<String, Object?> _messageInteractionItem({
  required String interactionId,
  required String projectId,
  required String bidId,
  required String counterpartName,
  required String summary,
  required String lastMessageText,
  Map<String, Object?>? p0PaySummary,
  String latestCardType = 'bid_thread',
  String summaryTitle = '新的竞标已提交',
}) {
  final definition =
      messagesRegisteredEntryByActionKey['counterpart_conversation.open']!;
  return <String, Object?>{
    'interactionId': interactionId,
    'interactionType': 'counterpart_conversation',
    'conversationId': 'org-$interactionId',
    'projectId': projectId,
    'counterpart': <String, Object?>{
      'organizationId': 'org-$interactionId',
      'displayName': counterpartName,
      'avatarUrl': null,
      'role': 'counterpart',
    },
    'summary': <String, Object?>{
      'focusProjectId': projectId,
      'title': summaryTitle,
      'text': lastMessageText,
      'projectCount': 1,
      'latestCardType': latestCardType,
    },
    'p0PaySummary': ?p0PaySummary,
    'updatedAt': '2026-03-27T10:00:00Z',
    'routeTarget': <String, Object?>{
      'objectType': definition.objectType,
      'actionKey': definition.actionKey,
      'canonicalPath': definition.canonicalPath,
      'params': <String, String>{
        'conversationId': 'org-$interactionId',
        'projectId': projectId,
      },
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

    expect(find.text('互动中心'), findsNothing);
    expect(find.text('论坛互动'), findsOneWidget);
    expect(find.text('回复我的'), findsWidgets);
    expect(find.text('收到的赞'), findsWidgets);
    expect(find.text('新关注'), findsWidgets);
    expect(find.text('这里集中查看别人对你的回复、点赞、关注，以及项目沟通会话。'), findsNothing);
    expect(find.text('回复了你在《材料交接节点》里的问题'), findsOneWidget);
    expect(find.text('回到源对象'), findsOneWidget);

    await tester.tap(find.text('收到的赞').last);
    await tester.pumpAndSettle();
    expect(find.text('赞了你在《搭建夜班排班》下的评论'), findsOneWidget);
    expect(find.text('这里只显示别人给你的帖子或评论点的赞。'), findsNothing);
  });

  testWidgets(
    'messages building renders project communication interactions in a separate lane',
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
        handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
          'GET /api/app/message/interactions': (AppApiRequest request) async {
            expect(
              request.uri.queryParameters['lane'],
              'project_communication',
            );
            return AppApiResponse(
              statusCode: 200,
              uri: request.uri,
              body: <String, Object?>{
                'lane': 'project_communication',
                'items': <Object?>[
                  _messageInteractionItem(
                    interactionId: 'interaction-1',
                    projectId: 'project-1',
                    bidId: 'bid-1',
                    counterpartName: '杭州搭建公司',
                    summary: '杭州搭建公司已对当前项目提交竞标。',
                    lastMessageText: '当前竞标已提交，可继续进入沟通。',
                    p0PaySummary: const <String, Object?>{
                      'taskId': 'task-1',
                      'taskType': 'inquiry_quote',
                      'inquiryDeposit': <String, Object?>{
                        'depositStatus': 'paid',
                        'amount': '200.00',
                      },
                      'messageDisplaySummary': <String, Object?>{
                        'displayAllowed': true,
                        'readOnly': true,
                        'statusTextKey': 'inquiry_deposit_paid',
                        'routeTarget': <String, Object?>{
                          'objectType': 'trade_task',
                          'actionKey': 'p0_pay_summary.read',
                          'canonicalPath':
                              '/api/app/exhibition/trade-tasks/task-1/p0-pay-summary',
                        },
                      },
                    },
                  ),
                  _messageInteractionItem(
                    interactionId: 'interaction-2',
                    projectId: 'project-2',
                    bidId: 'bid-2',
                    counterpartName: '苏州执行团队',
                    summary: '苏州执行团队已对当前项目提交竞标。',
                    lastMessageText: '项目方在沟通与投标里回复了新的交付问题。',
                    latestCardType: 'project_order',
                    summaryTitle: '订单状态已更新',
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

      expect(find.text('项目沟通'), findsOneWidget);
      expect(find.text('杭州搭建公司'), findsOneWidget);
      expect(find.text('苏州执行团队'), findsOneWidget);
      expect(find.text('昵称'), findsNothing);
      expect(find.text('对方主体'), findsNothing);
      expect(find.text('项目 1 个'), findsNWidgets(2));
      expect(find.text('项目方在沟通与投标里回复了新的交付问题。'), findsNothing);
      expect(find.text('订单状态'), findsNothing);
      expect(find.text('P0-Pay 只读状态'), findsNothing);
      expect(find.textContaining('发单诚意金：已支付'), findsNothing);
      expect(find.textContaining('只读 handoff'), findsNothing);
      expect(find.widgetWithText(FilledButton, '支付'), findsNothing);
      expect(find.text('进入项目沟通'), findsNWidgets(2));
      await tester.scrollUntilVisible(find.text('回复了你在《材料交接节点》里的问题'), 240);
      expect(find.text('回复了你在《材料交接节点》里的问题'), findsOneWidget);
      expect(find.text('回复我的'), findsWidgets);
    },
  );

  testWidgets(
    'messages page refresh reloads forum inbox and project communication interactions together',
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
              'GET /api/app/message/interactions':
                  (AppApiRequest request) async {
                    messageRequestCount += 1;
                    final title = messageRequestCount == 1
                        ? '第一次项目沟通会话'
                        : '第二次项目沟通会话';
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: <String, Object?>{
                        'lane': 'project_communication',
                        'items': <Object?>[
                          _messageInteractionItem(
                            interactionId: 'interaction-$messageRequestCount',
                            projectId: 'project-1',
                            bidId: 'bid-1',
                            counterpartName: title,
                            summary: '$title 已生成。',
                            lastMessageText: '$title 最近有更新。',
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
      expect(find.text('第一次项目沟通会话'), findsOneWidget);

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
      expect(find.text('第二次项目沟通会话'), findsOneWidget);
    },
  );

  testWidgets(
    'background refresh keeps existing message center content stable',
    (WidgetTester tester) async {
      var forumRequestCount = 0;
      var messageRequestCount = 0;
      final secondForumRequest = Completer<void>();
      final secondMessageRequest = Completer<void>();
      final refreshSignal = ValueNotifier<int>(0);
      addTearDown(refreshSignal.dispose);

      final forumTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/forum/interaction/inbox':
                  (AppApiRequest request) async {
                    forumRequestCount += 1;
                    if (forumRequestCount > 1) {
                      await secondForumRequest.future;
                    }
                    final title = forumRequestCount == 1
                        ? '首次论坛回复'
                        : '后台刷新后的论坛回复';
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
              'GET /api/app/message/interactions':
                  (AppApiRequest request) async {
                    messageRequestCount += 1;
                    if (messageRequestCount > 1) {
                      await secondMessageRequest.future;
                    }
                    final title = messageRequestCount == 1
                        ? '首次项目沟通会话'
                        : '后台刷新后的项目沟通会话';
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: <String, Object?>{
                        'lane': 'project_communication',
                        'items': <Object?>[
                          _messageInteractionItem(
                            interactionId: 'interaction-$messageRequestCount',
                            projectId: 'project-1',
                            bidId: 'bid-1',
                            counterpartName: title,
                            summary: '$title 已生成。',
                            lastMessageText: '$title 最近有更新。',
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
          refreshSignal: refreshSignal,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('首次论坛回复'), findsOneWidget);
      expect(find.text('首次项目沟通会话'), findsOneWidget);

      refreshSignal.value += 1;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(forumRequestCount, 2);
      expect(messageRequestCount, 2);
      expect(find.text('首次论坛回复'), findsOneWidget);
      expect(find.text('首次项目沟通会话'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNothing);

      secondForumRequest.complete();
      secondMessageRequest.complete();
      await tester.pumpAndSettle();

      expect(find.text('后台刷新后的论坛回复'), findsOneWidget);
      expect(find.text('后台刷新后的项目沟通会话'), findsOneWidget);
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
    expect(find.text('暂无新的回复我的提醒。'), findsOneWidget);
    expect(find.text('这里只显示别人回复你的帖子或评论；你自己发表评论，不会进入“回复我的”。'), findsNothing);
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

    expect(find.text('互动通知暂不可用'), findsOneWidget);
    expect(find.text('当前“回复我的”入口暂不可用，请稍后再试。'), findsOneWidget);
    expect(find.text('没有找到对应的论坛内容'), findsNothing);
  });
}
