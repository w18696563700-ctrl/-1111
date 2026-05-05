import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/boot/app_bootstrap_controller.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/core/boot/app_shell_context_consumer.dart';
import 'package:mobile/features/exhibition/data/forum_consumer_layer.dart';
import 'package:mobile/features/messages/data/counterpart_conversation_consumer_layer.dart';
import 'package:mobile/features/messages/data/app_notification_parser.dart';
import 'package:mobile/features/messages/data/messages_consumer_layer.dart';
import 'package:mobile/features/messages/data/messages_registered_entry_registry.dart';
import 'package:mobile/features/messages/presentation/messages_page.dart';
import 'package:mobile/shell/context/app_shell_scope.dart';

AppApiClient _client(FakeAppApiTransport transport) {
  return AppApiClient(
    config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
    transport: transport,
  );
}

Future<void> _openNotificationPanel(WidgetTester tester) async {
  await tester.tap(find.byTooltip('消息中心'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('messages building renders bounded notification center', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers: <String, Future<AppApiResponse> Function(AppApiRequest)>{
        'GET /api/app/message/interactions': (request) async {
          return AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: const <String, Object?>{
              'lane': 'project_communication',
              'items': <Object?>[],
            },
          );
        },
        'GET /api/app/notifications/list': (request) async {
          return AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: const <String, Object?>{
              'items': <Object?>[
                <String, Object?>{
                  'notificationId': 'notice-1',
                  'type': 'project_communication_message',
                  'source': 'project_communication',
                  'title': '有新的项目沟通消息',
                  'body': '报价确认已发送。',
                  'projectId': 'project-1',
                  'threadId': 'thread-1',
                  'routeTarget': null,
                  'createdAt': '2026-05-01T08:00:00Z',
                  'readAt': null,
                  'unread': true,
                },
              ],
              'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
              'unread': <String, Object?>{
                'total': 1,
                'projectCommunication': 1,
                'businessTodo': 0,
                'bidParticipationRequest': 0,
                'forumInteraction': 0,
                'system': 0,
              },
            },
          );
        },
        'POST /api/app/notifications/read': (request) async {
          expect(request.body, <String, Object?>{
            'notificationIds': <String>['notice-1'],
          });
          return AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: const <String, Object?>{
              'readNotificationIds': <Object?>['notice-1'],
              'unread': <String, Object?>{
                'total': 0,
                'projectCommunication': 0,
                'businessTodo': 0,
                'bidParticipationRequest': 0,
                'forumInteraction': 0,
                'system': 0,
              },
            },
          );
        },
      },
    );
    final client = _client(transport);
    MessagesConsumerLayer.install(MessagesConsumerLayer(client: client));
    ForumConsumerLayer.install(ForumConsumerLayer(client: client));
    addTearDown(MessagesConsumerLayer.reset);
    addTearDown(ForumConsumerLayer.reset);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: MessagesPage())),
    );
    await tester.pumpAndSettle();

    expect(find.text('消息中心'), findsNothing);
    expect(find.text('重要通知、项目沟通等消息'), findsNothing);
    expect(find.textContaining('有新的项目沟通消息'), findsNothing);

    await _openNotificationPanel(tester);

    expect(find.text('消息中心'), findsOneWidget);
    expect(find.text('项目沟通'), findsWidgets);
    expect(find.textContaining('有新的项目沟通消息'), findsOneWidget);
    expect(find.text('报价确认已发送。'), findsOneWidget);

    await tester.tap(find.textContaining('有新的项目沟通消息'));
    await tester.pumpAndSettle();
    expect(
      transport.requests
          .where(
            (request) => request.canonicalPath == '/api/app/notifications/read',
          )
          .length,
      0,
    );
    expect(find.text('当前通知暂时无法定位，请稍后重试或从对应入口进入。'), findsOneWidget);
  });

  testWidgets('notification center scrolls long lists without overflow', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers: <String, Future<AppApiResponse> Function(AppApiRequest)>{
        'GET /api/app/message/interactions': (request) async {
          return AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: const <String, Object?>{
              'lane': 'project_communication',
              'items': <Object?>[],
            },
          );
        },
        'GET /api/app/notifications/list': (request) async {
          return AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: <String, Object?>{
              'items': <Object?>[
                for (var index = 1; index <= 20; index += 1)
                  <String, Object?>{
                    'notificationId': 'notice-$index',
                    'type': 'project_communication_message',
                    'source': 'project_communication',
                    'title': '通知 $index',
                    'body': '项目消息 $index',
                    'projectId': 'project-1',
                    'threadId': 'thread-$index',
                    'routeTarget': null,
                    'createdAt': '2026-05-01T08:00:00Z',
                    'readAt': null,
                    'unread': true,
                  },
              ],
              'page': const <String, Object?>{
                'nextCursor': null,
                'hasMore': false,
              },
              'unread': const <String, Object?>{
                'total': 20,
                'projectCommunication': 20,
                'businessTodo': 0,
                'bidParticipationRequest': 0,
                'forumInteraction': 0,
                'system': 0,
              },
            },
          );
        },
      },
    );
    final client = _client(transport);
    MessagesConsumerLayer.install(MessagesConsumerLayer(client: client));
    ForumConsumerLayer.install(ForumConsumerLayer(client: client));
    addTearDown(MessagesConsumerLayer.reset);
    addTearDown(ForumConsumerLayer.reset);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: MessagesPage())),
    );
    await tester.pumpAndSettle();

    await _openNotificationPanel(tester);

    expect(tester.takeException(), isNull);
    expect(find.textContaining('项目沟通 · 通知 1'), findsOneWidget);
    await tester.drag(find.byType(ListView).last, const Offset(0, -360));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('project communication refresh does not reload shell context', (
    WidgetTester tester,
  ) async {
    var messageRequestCount = 0;
    final refreshSignal = ValueNotifier<int>(0);
    addTearDown(refreshSignal.dispose);
    final transport = FakeAppApiTransport(
      handlers: <String, Future<AppApiResponse> Function(AppApiRequest)>{
        'GET /api/app/message/interactions': (request) async {
          messageRequestCount += 1;
          return AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: const <String, Object?>{
              'lane': 'project_communication',
              'items': <Object?>[],
            },
          );
        },
        'GET /api/app/notifications/list': (request) async {
          return AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: const <String, Object?>{
              'items': <Object?>[],
              'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
              'unread': <String, Object?>{
                'total': 3,
                'projectCommunication': 2,
                'businessTodo': 1,
                'bidParticipationRequest': 1,
                'forumInteraction': 0,
                'system': 0,
              },
            },
          );
        },
      },
    );
    final shellConsumer = _FakeShellContextConsumer(messagesUnread: 99);
    final controller = AppBootstrapController(
      shellContextConsumer: shellConsumer,
    );
    final client = _client(transport);
    MessagesConsumerLayer.install(MessagesConsumerLayer(client: client));
    ForumConsumerLayer.install(ForumConsumerLayer(client: client));
    addTearDown(controller.dispose);
    addTearDown(MessagesConsumerLayer.reset);
    addTearDown(ForumConsumerLayer.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: AppShellScope(
          controller: controller,
          child: Scaffold(body: MessagesPage(refreshSignal: refreshSignal)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final shellReloadsBeforeRefresh = shellConsumer.loadResultCount;
    refreshSignal.value += 1;
    await tester.pump();
    await tester.pumpAndSettle();

    expect(messageRequestCount, greaterThanOrEqualTo(2));
    expect(shellConsumer.loadResultCount, shellReloadsBeforeRefresh);
    expect(controller.snapshot.shellContext.messagesUnreadBadgeLabel, '3');
  });

  testWidgets(
    'marking a notification read refreshes shell unread badge source',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers: <String, Future<AppApiResponse> Function(AppApiRequest)>{
          'GET /api/app/message/interactions': (request) async {
            return AppApiResponse(
              statusCode: 200,
              uri: request.uri,
              body: const <String, Object?>{
                'lane': 'project_communication',
                'items': <Object?>[],
              },
            );
          },
          'GET /api/app/notifications/list': (request) async {
            return AppApiResponse(
              statusCode: 200,
              uri: request.uri,
              body: const <String, Object?>{
                'items': <Object?>[
                  <String, Object?>{
                    'notificationId': 'notice-1',
                    'type': 'project_communication_message',
                    'source': 'project_communication',
                    'title': '有新的项目沟通消息',
                    'body': 'Day12 material_process softLink',
                    'projectId': 'project-1',
                    'threadId': 'thread-1',
                    'routeTarget': <String, Object?>{
                      'state': 'enabled',
                      'routeParams': <String, Object?>{
                        'threadId': 'thread-1',
                        'projectId': 'project-1',
                        'conversationId': 'org-1',
                      },
                      'canonicalPath':
                          '/api/app/message/counterpart-conversation/detail',
                      'localEntryKey': 'counterpart_conversation.open',
                      'requiredParams': <Object?>[
                        'conversationId',
                        'projectId',
                      ],
                    },
                    'createdAt': '2026-05-01T08:00:00Z',
                    'readAt': null,
                    'unread': true,
                  },
                ],
                'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
                'unread': <String, Object?>{
                  'total': 1,
                  'projectCommunication': 1,
                  'businessTodo': 0,
                  'bidParticipationRequest': 0,
                  'forumInteraction': 0,
                  'system': 0,
                },
              },
            );
          },
          'POST /api/app/notifications/read': (request) async {
            return AppApiResponse(
              statusCode: 200,
              uri: request.uri,
              body: const <String, Object?>{
                'readNotificationIds': <Object?>['notice-1'],
                'unread': <String, Object?>{
                  'total': 0,
                  'projectCommunication': 0,
                  'businessTodo': 0,
                  'bidParticipationRequest': 0,
                  'forumInteraction': 0,
                  'system': 0,
                },
              },
            );
          },
        },
      );
      final client = _client(transport);
      final shellConsumer = _FakeShellContextConsumer();
      final controller = AppBootstrapController(
        shellContextConsumer: shellConsumer,
      );
      MessagesConsumerLayer.install(MessagesConsumerLayer(client: client));
      ForumConsumerLayer.install(ForumConsumerLayer(client: client));
      addTearDown(controller.dispose);
      addTearDown(MessagesConsumerLayer.reset);
      addTearDown(ForumConsumerLayer.reset);

      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (settings) {
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => const Scaffold(body: Text('项目沟通详情')),
            );
          },
          home: AppShellScope(
            controller: controller,
            child: const Scaffold(body: MessagesPage()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _openNotificationPanel(tester);

      final reloadCountBeforeRead = shellConsumer.loadResultCount;
      await tester.tap(find.textContaining('有新的项目沟通消息'));
      await tester.pumpAndSettle();

      expect(shellConsumer.loadResultCount, reloadCountBeforeRead + 1);
      expect(controller.snapshot.shellContext.messagesUnreadBadgeLabel, isNull);
    },
  );

  testWidgets(
    'messages page keeps shell badge from shell context when project communication is empty',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers: <String, Future<AppApiResponse> Function(AppApiRequest)>{
          'GET /api/app/message/interactions': (request) async {
            return AppApiResponse(
              statusCode: 200,
              uri: request.uri,
              body: const <String, Object?>{
                'lane': 'project_communication',
                'items': <Object?>[],
              },
            );
          },
          'GET /api/app/notifications/list': (request) async {
            return AppApiResponse(
              statusCode: 200,
              uri: request.uri,
              body: const <String, Object?>{
                'items': <Object?>[],
                'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
                'unread': <String, Object?>{
                  'total': 1,
                  'projectCommunication': 0,
                  'businessTodo': 1,
                  'bidParticipationRequest': 1,
                  'forumInteraction': 0,
                  'system': 0,
                },
              },
            );
          },
        },
      );
      final controller = AppBootstrapController(
        shellContextConsumer: _FakeShellContextConsumer(messagesUnread: 1),
      );
      MessagesConsumerLayer.install(
        MessagesConsumerLayer(client: _client(transport)),
      );
      ForumConsumerLayer.install(
        ForumConsumerLayer(client: _client(transport)),
      );
      addTearDown(controller.dispose);
      addTearDown(MessagesConsumerLayer.reset);
      addTearDown(ForumConsumerLayer.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: AppShellScope(
            controller: controller,
            child: const Scaffold(body: MessagesPage()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(controller.snapshot.shellContext.messagesUnreadBadgeLabel, '1');
    },
  );

  testWidgets(
    'messages page syncs shell badge from notification unread total only',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers: <String, Future<AppApiResponse> Function(AppApiRequest)>{
          'GET /api/app/message/interactions': (request) async {
            return AppApiResponse(
              statusCode: 200,
              uri: request.uri,
              body: const <String, Object?>{
                'lane': 'project_communication',
                'items': <Object?>[],
              },
            );
          },
          'GET /api/app/notifications/list': (request) async {
            return AppApiResponse(
              statusCode: 200,
              uri: request.uri,
              body: const <String, Object?>{
                'items': <Object?>[
                  <String, Object?>{
                    'notificationId': 'notice-1',
                    'type': 'project_communication_message',
                    'source': 'project_communication',
                    'title': '有新的项目沟通消息',
                    'body': '这条 item 是未读，但 total 为 0。',
                    'projectId': 'project-1',
                    'threadId': 'thread-1',
                    'routeTarget': null,
                    'createdAt': '2026-05-01T08:00:00Z',
                    'readAt': null,
                    'unread': true,
                  },
                ],
                'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
                'unread': <String, Object?>{
                  'total': 0,
                  'projectCommunication': 0,
                  'businessTodo': 0,
                  'bidParticipationRequest': 0,
                  'forumInteraction': 0,
                  'system': 0,
                },
              },
            );
          },
        },
      );
      final controller = AppBootstrapController(
        shellContextConsumer: _FakeShellContextConsumer(messagesUnread: 9),
      );
      MessagesConsumerLayer.install(
        MessagesConsumerLayer(client: _client(transport)),
      );
      ForumConsumerLayer.install(
        ForumConsumerLayer(client: _client(transport)),
      );
      addTearDown(controller.dispose);
      addTearDown(MessagesConsumerLayer.reset);
      addTearDown(ForumConsumerLayer.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: AppShellScope(
            controller: controller,
            child: const Scaffold(body: MessagesPage()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(controller.snapshot.shellContext.messagesUnreadBadgeLabel, isNull);
    },
  );

  testWidgets(
    'bid participation notification marks read and opens existing review thread',
    (WidgetTester tester) async {
      String? openedRoute;
      final transport = FakeAppApiTransport(
        handlers: <String, Future<AppApiResponse> Function(AppApiRequest)>{
          'GET /api/app/message/interactions': (request) async {
            return AppApiResponse(
              statusCode: 200,
              uri: request.uri,
              body: const <String, Object?>{
                'lane': 'project_communication',
                'items': <Object?>[],
              },
            );
          },
          'GET /api/app/notifications/list': (request) async {
            return AppApiResponse(
              statusCode: 200,
              uri: request.uri,
              body: const <String, Object?>{
                'items': <Object?>[
                  <String, Object?>{
                    'notificationId': 'notice-bpr-1',
                    'type': 'bid_participation_request',
                    'source': 'bid_participation_request',
                    'title': '有新的参与竞标申请',
                    'body': '有供应商提交了参与竞标申请，请进入审核线程处理。',
                    'projectId': 'project-1',
                    'threadId': 'request-1',
                    'routeTarget': <String, Object?>{
                      'canonicalPath':
                          '/api/app/project/bid-participation/thread/detail',
                      'localEntryKey': 'bid_participation_request.open',
                      'requiredParams': <Object?>[
                        'threadId',
                        'projectId',
                        'requestId',
                      ],
                      'routeParams': <String, Object?>{
                        'threadId': 'request-1',
                        'projectId': 'project-1',
                        'requestId': 'request-1',
                      },
                      'state': 'enabled',
                    },
                    'createdAt': '2026-05-04T07:30:00Z',
                    'readAt': null,
                    'unread': true,
                  },
                ],
                'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
                'unread': <String, Object?>{
                  'total': 1,
                  'projectCommunication': 0,
                  'businessTodo': 1,
                  'bidParticipationRequest': 1,
                  'forumInteraction': 0,
                  'system': 0,
                },
              },
            );
          },
          'POST /api/app/notifications/read': (request) async {
            expect(request.body, <String, Object?>{
              'notificationIds': <String>['notice-bpr-1'],
            });
            return AppApiResponse(
              statusCode: 200,
              uri: request.uri,
              body: const <String, Object?>{
                'readNotificationIds': <Object?>['notice-bpr-1'],
                'unread': <String, Object?>{
                  'total': 0,
                  'projectCommunication': 0,
                  'businessTodo': 0,
                  'bidParticipationRequest': 0,
                  'forumInteraction': 0,
                  'system': 0,
                },
              },
            );
          },
        },
      );
      final controller = AppBootstrapController(
        shellContextConsumer: _FakeShellContextConsumer(),
      );
      MessagesConsumerLayer.install(
        MessagesConsumerLayer(client: _client(transport)),
      );
      ForumConsumerLayer.install(
        ForumConsumerLayer(client: _client(transport)),
      );
      addTearDown(controller.dispose);
      addTearDown(MessagesConsumerLayer.reset);
      addTearDown(ForumConsumerLayer.reset);

      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (settings) {
            openedRoute = settings.name;
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => const Scaffold(body: Text('处理参与竞标申请')),
            );
          },
          home: AppShellScope(
            controller: controller,
            child: const Scaffold(body: MessagesPage()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _openNotificationPanel(tester);

      expect(find.text('业务待办'), findsWidgets);
      expect(find.textContaining('有新的参与竞标申请'), findsOneWidget);

      await tester.tap(find.textContaining('有新的参与竞标申请'));
      await tester.pumpAndSettle();

      expect(
        transport.requests
            .where(
              (request) =>
                  request.canonicalPath == '/api/app/notifications/read',
            )
            .length,
        1,
      );
      expect(
        openedRoute,
        contains('/exhibition/projects/bid-participation-thread'),
      );
      expect(find.text('处理参与竞标申请'), findsOneWidget);
      expect(controller.snapshot.shellContext.messagesUnreadBadgeLabel, isNull);
    },
  );

  test(
    'project communication preview and softLink consume BFF routes',
    () async {
      final definition =
          messagesRegisteredEntryByActionKey['counterpart_conversation.open']!;
      final transport = FakeAppApiTransport(
        handlers: <String, Future<AppApiResponse> Function(AppApiRequest)>{
          'GET /api/app/file/preview/access': (request) async {
            expect(request.uri.queryParameters, <String, String>{
              'projectId': 'project-1',
              'threadId': 'thread-1',
              'fileAssetId': 'asset-1',
            });
            return AppApiResponse(
              statusCode: 200,
              uri: request.uri,
              body: const <String, Object?>{
                'fileAssetId': 'asset-1',
                'projectId': 'project-1',
                'threadId': 'thread-1',
                'previewType': 'pdf',
                'canPreview': true,
                'fileName': '方案.pdf',
                'mimeType': 'application/pdf',
                'accessUrl': 'https://signed.example/asset-1',
                'expiresAt': '2026-05-01T08:10:00Z',
                'contentLengthBytes': 2048,
                'downloadAvailable': true,
              },
            );
          },
          'GET /api/app/confirmation/softlink/detail': (request) async {
            expect(request.uri.queryParameters, <String, String>{
              'projectId': 'project-1',
              'threadId': 'thread-1',
              'messageId': 'message-1',
            });
            return AppApiResponse(
              statusCode: 200,
              uri: request.uri,
              body: <String, Object?>{
                'projectId': 'project-1',
                'threadId': 'thread-1',
                'messageId': 'message-1',
                'confirmationType': 'quote',
                'status': 'pending',
                'title': '报价确认',
                'summary': '确认报价。',
                'routeTarget': <String, Object?>{
                  'objectType': definition.objectType,
                  'actionKey': definition.actionKey,
                  'canonicalPath': definition.canonicalPath,
                  'params': const <String, Object?>{
                    'conversationId': 'org-1',
                    'projectId': 'project-1',
                  },
                },
              },
            );
          },
        },
      );
      final consumer = CounterpartConversationConsumerLayer(
        client: _client(transport),
        realtimeClient: const _NoopRealtimeClient(),
      );

      final preview = await consumer.loadProjectCommunicationFilePreviewAccess(
        projectId: 'project-1',
        threadId: 'thread-1',
        fileAssetId: 'asset-1',
      );
      final softLink = await consumer
          .loadProjectCommunicationConfirmationSoftLink(
            projectId: 'project-1',
            threadId: 'thread-1',
            messageId: 'message-1',
          );

      expect(preview.data?.previewType, 'pdf');
      expect(preview.data?.accessUrl, 'https://signed.example/asset-1');
      expect(softLink.data?.confirmationType, 'quote');
      expect(softLink.data?.routeTarget?.routeLocation, isNotNull);
    },
  );

  test(
    'notification routeTarget ignores carried threadId when opening project communication',
    () {
      final item = parseAppNotificationItem(const <String, Object?>{
        'notificationId': 'notice-1',
        'type': 'project_communication_message',
        'source': 'project_communication',
        'title': '有新的项目沟通消息',
        'body': 'Day12 schedule softLink',
        'projectId': 'project-1',
        'threadId': 'thread-1',
        'routeTarget': <String, Object?>{
          'state': 'enabled',
          'routeParams': <String, Object?>{
            'threadId': 'thread-1',
            'projectId': 'project-1',
            'conversationId': 'org-1',
          },
          'canonicalPath': '/api/app/message/counterpart-conversation/detail',
          'localEntryKey': 'counterpart_conversation.open',
          'requiredParams': <Object?>['conversationId', 'projectId'],
        },
        'createdAt': '2026-05-01T08:00:00Z',
        'readAt': null,
        'unread': true,
      });

      expect(
        item.routeTarget?.routeLocation,
        '/exhibition/messages/counterpart-conversation?conversationId=org-1&projectId=project-1',
      );
    },
  );

  test(
    'bid participation notification routeTarget opens existing review thread',
    () {
      final item = parseAppNotificationItem(const <String, Object?>{
        'notificationId': 'notice-bpr-1',
        'type': 'bid_participation_request',
        'source': 'bid_participation_request',
        'title': '有新的参与竞标申请',
        'body': '有供应商提交了参与竞标申请，请进入审核线程处理。',
        'projectId': 'project-1',
        'threadId': 'request-1',
        'routeTarget': <String, Object?>{
          'state': 'enabled',
          'routeParams': <String, Object?>{
            'threadId': 'request-1',
            'projectId': 'project-1',
            'requestId': 'request-1',
          },
          'canonicalPath': '/api/app/project/bid-participation/thread/detail',
          'localEntryKey': 'bid_participation_request.open',
          'requiredParams': <Object?>['threadId', 'projectId', 'requestId'],
        },
        'createdAt': '2026-05-04T07:30:00Z',
        'readAt': null,
        'unread': true,
      });

      expect(
        item.routeTarget?.routeLocation,
        '/exhibition/projects/bid-participation-thread?threadId=request-1&projectId=project-1&requestId=request-1',
      );
    },
  );
}

final class _NoopRealtimeClient implements ProjectCommunicationRealtimeClient {
  const _NoopRealtimeClient();

  @override
  Future<ProjectCommunicationRealtimeSubscription> subscribe({
    required String threadId,
    required String projectId,
    required String counterpartOrganizationId,
  }) {
    throw UnimplementedError('not needed for preview consumer tests');
  }
}

final class _FakeShellContextConsumer implements AppShellContextConsumer {
  _FakeShellContextConsumer({this.messagesUnread = 0});

  final int messagesUnread;
  int loadResultCount = 0;

  @override
  Future<AppShellContextData?> load() async => (await loadResult()).data;

  @override
  Future<AppShellContextResult> loadResult() async {
    loadResultCount += 1;
    return AppShellContextResult(
      state: AppPageState.content,
      method: 'GET',
      path: AppShellContextCanonicalPaths.shellContext,
      data: AppShellContextData(
        organizationId: 'org-1',
        unreadSummary: <String, Object?>{'messages': messagesUnread},
      ),
    );
  }
}
