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

    expect(find.text('消息中心'), findsOneWidget);
    expect(find.text('重要通知、项目沟通等消息'), findsOneWidget);
    expect(find.text('有新的项目沟通消息'), findsNothing);

    await tester.tap(find.text('消息中心'));
    await tester.pumpAndSettle();

    expect(find.text('项目沟通'), findsWidgets);
    expect(find.text('有新的项目沟通消息'), findsOneWidget);
    expect(find.text('报价确认已发送。'), findsOneWidget);

    await tester.tap(find.text('有新的项目沟通消息'));
    await tester.pumpAndSettle();
    expect(
      transport.requests
          .where(
            (request) => request.canonicalPath == '/api/app/notifications/read',
          )
          .length,
      1,
    );
    expect(find.text('当前通知暂时没有可打开的页面。'), findsOneWidget);
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
          home: AppShellScope(
            controller: controller,
            child: const Scaffold(body: MessagesPage()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('消息中心'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('有新的项目沟通消息'));
      await tester.pumpAndSettle();

      expect(shellConsumer.loadResultCount, 1);
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
        unreadSummary: const <String, Object?>{'messages': 0},
      ),
    );
  }
}
