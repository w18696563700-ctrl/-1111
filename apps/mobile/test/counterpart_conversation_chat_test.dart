import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/boot/app_bootstrap_controller.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/auth/auth_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/exhibition/presentation/exhibition_trade_pages.dart';
import 'package:mobile/features/messages/data/counterpart_conversation_consumer_layer.dart';
import 'package:mobile/features/messages/data/messages_registered_entry_registry.dart';
import 'package:mobile/shell/context/app_shell_scope.dart';

AppApiClient _client(FakeAppApiTransport transport) {
  return AppApiClient(
    config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
    transport: transport,
  );
}

Widget _buildPage(
  FakeAppApiTransport transport, {
  ProjectCommunicationRealtimeClient? realtimeClient,
}) {
  final client = _client(transport);
  ExhibitionConsumerLayer.install(ExhibitionConsumerLayer(client: client));
  CounterpartConversationConsumerLayer.install(
    CounterpartConversationConsumerLayer(
      client: client,
      realtimeClient:
          realtimeClient ?? const _NoopProjectCommunicationRealtimeClient(),
    ),
  );
  return MaterialApp(
    home: const Scaffold(
      body: CounterpartConversationPage(
        conversationId: 'conversation-1',
        projectId: 'project-1',
      ),
    ),
    onGenerateRoute: (RouteSettings settings) {
      final name = settings.name;
      final uri = name == null ? null : Uri.tryParse(name);
      if (uri?.path == ExhibitionRoutes.orderDetail) {
        final routeUri = uri!;
        return MaterialPageRoute<void>(
          builder: (_) => OrderDetailPage(
            orderId: routeUri.queryParameters['orderId'],
            projectId: routeUri.queryParameters['projectId'],
          ),
          settings: settings,
        );
      }
      return MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('route opened')),
        settings: settings,
      );
    },
  );
}

Widget _buildPageWithShell(
  FakeAppApiTransport transport, {
  required AppShellContextData shellContext,
  ProjectCommunicationRealtimeClient? realtimeClient,
}) {
  final controller = AppBootstrapController(
    bootstrapShellContext: shellContext,
  );
  controller.initialize();
  addTearDown(controller.dispose);
  return AppShellScope(
    controller: controller,
    child: _buildPage(transport, realtimeClient: realtimeClient),
  );
}

Future<void> _ensureVisible(WidgetTester tester, Finder finder) async {
  await tester.pumpAndSettle();
  for (var i = 0; i < 12 && finder.evaluate().isEmpty; i += 1) {
    final scrollables = find.byType(Scrollable);
    if (scrollables.evaluate().isEmpty) {
      break;
    }
    await tester.drag(scrollables.first, const Offset(0, -320));
    await tester.pumpAndSettle();
  }
  if (finder.evaluate().isNotEmpty) {
    await tester.ensureVisible(finder);
  }
  await tester.pumpAndSettle();
}

final class _NoopProjectCommunicationRealtimeClient
    implements ProjectCommunicationRealtimeClient {
  const _NoopProjectCommunicationRealtimeClient();

  @override
  Future<ProjectCommunicationRealtimeSubscription> subscribe({
    required String threadId,
    required String projectId,
    required String counterpartOrganizationId,
  }) async {
    final controller =
        StreamController<ProjectCommunicationMessageCreatedEvent>.broadcast();
    return ProjectCommunicationRealtimeSubscription(
      events: controller.stream,
      done: Completer<void>().future,
      close: () async {},
    );
  }
}

final class _FakeProjectCommunicationRealtimeClient
    implements ProjectCommunicationRealtimeClient {
  _FakeProjectCommunicationRealtimeClient(this.controller);

  final StreamController<ProjectCommunicationMessageCreatedEvent> controller;
  final List<Map<String, String>> subscriptions = <Map<String, String>>[];

  @override
  Future<ProjectCommunicationRealtimeSubscription> subscribe({
    required String threadId,
    required String projectId,
    required String counterpartOrganizationId,
  }) async {
    subscriptions.add(<String, String>{
      'threadId': threadId,
      'projectId': projectId,
      'counterpartOrganizationId': counterpartOrganizationId,
    });
    return ProjectCommunicationRealtimeSubscription(
      events: controller.stream,
      done: controller.done,
      close: () async {
        await controller.close();
      },
    );
  }
}

final class _FailingProjectCommunicationRealtimeClient
    implements ProjectCommunicationRealtimeClient {
  @override
  Future<ProjectCommunicationRealtimeSubscription> subscribe({
    required String threadId,
    required String projectId,
    required String counterpartOrganizationId,
  }) async {
    throw const SocketException('ws unavailable');
  }
}

final class _LifecycleProjectCommunicationRealtimeClient
    implements ProjectCommunicationRealtimeClient {
  final List<Map<String, String>> subscriptions = <Map<String, String>>[];
  int closeCount = 0;

  @override
  Future<ProjectCommunicationRealtimeSubscription> subscribe({
    required String threadId,
    required String projectId,
    required String counterpartOrganizationId,
  }) async {
    subscriptions.add(<String, String>{
      'threadId': threadId,
      'projectId': projectId,
      'counterpartOrganizationId': counterpartOrganizationId,
    });
    final controller =
        StreamController<ProjectCommunicationMessageCreatedEvent>.broadcast();
    return ProjectCommunicationRealtimeSubscription(
      events: controller.stream,
      done: controller.done,
      close: () async {
        closeCount += 1;
        if (!controller.isClosed) {
          await controller.close();
        }
      },
    );
  }
}

Map<String, Object?> _detailPayload({
  String projectState = 'published',
  Map<String, Object?>? orderSummary,
  Map<String, Object?>? ratingEntry,
  bool includeOrderCard = false,
}) {
  final nameAccessDefinition =
      messagesRegisteredEntryByActionKey['project_name_access_thread.open']!;
  final bidThreadDefinition =
      messagesRegisteredEntryByActionKey['bid_thread.open']!;
  final orderDetailDefinition =
      messagesRegisteredEntryByActionKey['order_detail.open']!;
  return <String, Object?>{
    'conversationId': 'conversation-1',
    'counterpart': const <String, Object?>{
      'organizationId': 'org-counterpart',
      'displayName': '重庆涪川展览工厂',
      'avatarUrl': null,
      'role': 'counterpart',
    },
    'summary': <String, Object?>{
      'focusProjectId': 'project-1',
      'title': includeOrderCard ? '订单状态已更新' : '项目沟通',
      'text': includeOrderCard ? '当前项目订单已有新状态。' : '当前申请组织申请查看当前项目名称。',
      'projectCount': 1,
      'latestCardType': includeOrderCard
          ? 'project_order'
          : 'project_name_access_request',
    },
    'focusProjectId': 'project-1',
    'latestActivityAt': '2026-05-04T10:00:00Z',
    'projectGroups': <Object?>[
      <String, Object?>{
        'projectId': 'project-1',
        'projectDisplayTitle': '项目名称需申请查看',
        'titleVisibility': 'masked',
        'projectState': projectState,
        'latestActivityAt': '2026-05-04T10:00:00Z',
        'orderSummary': orderSummary,
        'ratingEntry': ratingEntry,
        'cards': <Object?>[
          <String, Object?>{
            'cardId': 'name-access-card',
            'cardType': 'project_name_access_request',
            'title': '项目名称查看申请',
            'summary': '当前申请组织 申请查看当前项目名称。',
            'status': 'pending',
            'updatedAt': '2026-05-04T10:00:00Z',
            'truthAnchor': const <String, Object?>{
              'truthType': 'project_name_access_request',
              'projectId': 'project-1',
              'requestId': 'request-1',
              'threadId': 'thread-name-access-1',
            },
            'detailRouteTarget': <String, Object?>{
              'objectType': nameAccessDefinition.objectType,
              'actionKey': nameAccessDefinition.actionKey,
              'canonicalPath': nameAccessDefinition.canonicalPath,
              'params': const <String, Object?>{
                'threadId': 'thread-name-access-1',
                'projectId': 'project-1',
                'requestId': 'request-1',
              },
            },
            'decisionAvailability': const <String, Object?>{
              'canApprove': true,
              'canReject': true,
            },
          },
          <String, Object?>{
            'cardId': 'bid-card',
            'cardType': 'bid_thread',
            'title': '新的竞标已提交',
            'summary': '重庆展宏展览展示有限公司 已提交竞标。',
            'status': 'submitted',
            'updatedAt': '2026-05-04T10:01:00Z',
            'truthAnchor': const <String, Object?>{
              'truthType': 'bid_thread',
              'projectId': 'project-1',
              'bidId': 'bid-1',
            },
            'detailRouteTarget': <String, Object?>{
              'objectType': bidThreadDefinition.objectType,
              'actionKey': bidThreadDefinition.actionKey,
              'canonicalPath': bidThreadDefinition.canonicalPath,
              'params': const <String, Object?>{
                'projectId': 'project-1',
                'bidId': 'bid-1',
              },
            },
            'decisionAvailability': null,
          },
          if (includeOrderCard)
            <String, Object?>{
              'cardId': 'order-card',
              'cardType': 'project_order',
              'title': '订单状态',
              'summary': '当前订单正在履约中。',
              'status': 'active',
              'updatedAt': '2026-05-04T10:02:00Z',
              'truthAnchor': const <String, Object?>{
                'truthType': 'project_order',
                'projectId': 'project-1',
                'orderId': 'order-1',
              },
              'detailRouteTarget': <String, Object?>{
                'objectType': orderDetailDefinition.objectType,
                'actionKey': orderDetailDefinition.actionKey,
                'canonicalPath': orderDetailDefinition.canonicalPath,
                'params': const <String, Object?>{
                  'projectId': 'project-1',
                  'orderId': 'order-1',
                },
              },
              'decisionAvailability': null,
            },
        ],
      },
    ],
  };
}

Map<String, Object?> _threadPayload() {
  return const <String, Object?>{
    'threadId': 'project-thread-1',
    'projectId': 'project-1',
    'ownerOrganizationId': 'org-owner',
    'counterpartOrganizationId': 'org-counterpart',
    'threadState': 'open',
    'lastMessageId': null,
    'lastMessageAt': null,
    'createdAt': '2026-05-04T10:00:00Z',
    'updatedAt': '2026-05-04T10:00:00Z',
  };
}

Map<String, Object?> _messagePayload({
  required String messageId,
  required String body,
  String? clientMessageId,
}) {
  return <String, Object?>{
    'messageId': messageId,
    'threadId': 'project-thread-1',
    'projectId': 'project-1',
    'senderUserId': 'user-1',
    'senderActorId': 'actor-1',
    'senderOrganizationId': 'org-owner',
    'messageKind': 'text',
    'body': body,
    'clientMessageId': clientMessageId,
    'messageState': 'active',
    'createdAt': '2026-05-04T10:02:00Z',
  };
}

Map<String, Object?> _albumPhotoPayload({
  String photoId = 'photo-1',
  String fileAssetId = 'file-album-1',
  String category = 'progress',
  String? caption = 'progress.png',
  String photoState = 'active',
  String? removedAt,
}) {
  return <String, Object?>{
    'photoId': photoId,
    'projectId': 'project-1',
    'fileAssetId': fileAssetId,
    'category': category,
    'caption': caption,
    'mimeType': 'image/png',
    'sortOrder': 0,
    'photoState': photoState,
    'uploadedByUserId': 'user-1',
    'uploadedByActorId': 'actor-1',
    'uploadedByOrganizationId': 'org-owner',
    'createdAt': '2026-05-06T10:00:00Z',
    'removedAt': removedAt,
  };
}

Map<String, Object?> _albumListPayload(List<Object?> items) {
  return <String, Object?>{
    'projectId': 'project-1',
    'limit': 50,
    'photoCount': items.length,
    'items': items,
  };
}

Map<String, Object?> _orderSummaryPayload({
  String state = 'active',
  String completionRequestState = 'none',
  bool includeOrganizationAnchors = true,
}) {
  return <String, Object?>{
    'orderId': 'order-1',
    'projectId': 'project-1',
    if (includeOrganizationAnchors) ...<String, Object?>{
      'buyerOrganizationId': 'org-owner',
      'sellerOrganizationId': 'org-counterpart',
    },
    'state': state,
    'completionRequestState': completionRequestState,
  };
}

Map<String, Object?> _orderDetailPayload({
  String state = 'active',
  String completionRequestState = 'none',
  bool includeOrganizationAnchors = true,
}) {
  return <String, Object?>{
    'orderId': 'order-1',
    'orderNo': 'ORD-1',
    'projectId': 'project-1',
    'bidId': 'bid-1',
    if (includeOrganizationAnchors) ...<String, Object?>{
      'buyerOrganizationId': 'org-owner',
      'sellerOrganizationId': 'org-counterpart',
    },
    'state': state,
    'completionRequestState': completionRequestState,
    'summary': const <String, Object?>{'heading': '订单已承接'},
    'milestones': const <Object?>[],
  };
}

Map<String, Object?> _myProjectListPayload() {
  return const <String, Object?>{
    'ongoingProjects': <Object?>[],
    'historicalProjects': <Object?>[],
  };
}

void main() {
  tearDown(() {
    CounterpartConversationConsumerLayer.reset();
    ExhibitionConsumerLayer.reset();
    AppSessionStore.reset();
    AuthConsumerLayer.reset();
    ProjectAttachmentDebugOverrides.reset();
  });

  test(
    'project communication realtime client refreshes and forwards auth headers',
    () async {
      final sessionStore = AppSessionStore();
      AppSessionStore.install(sessionStore);
      sessionStore.establishSession(
        accessToken: 'stale-access-token',
        refreshToken: 'refresh-token-1',
        expiresInSeconds: 0,
        deviceId: 'device-1',
      );

      var refreshRequests = 0;
      AuthConsumerLayer.install(
        AuthConsumerLayer(
          client: AppApiClient(
            config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
            transport: FakeAppApiTransport(
              handlers:
                  <
                    String,
                    Future<AppApiResponse> Function(AppApiRequest request)
                  >{
                    'POST /api/app/auth/refresh':
                        (AppApiRequest request) async {
                          refreshRequests += 1;
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: const <String, Object?>{
                              'accessToken': 'refreshed-access-token',
                              'refreshToken': 'refresh-token-2',
                              'expiresInSeconds': 3600,
                            },
                          );
                        },
                  },
            ),
          ),
        ),
      );

      Uri? capturedUri;
      Map<String, String>? capturedHeaders;
      final realtimeClient = ProjectCommunicationIoRealtimeClient(
        client: AppApiClient(
          config: AppApiConfig(
            baseUrl: 'http://127.0.0.1:8080/api/app',
            defaultHeaders: const <String, String>{
              'x-actor-id': 'actor-1',
              'x-user-id': 'user-1',
            },
          ),
        ),
        connector: (Uri uri, Map<String, String> headers) async {
          capturedUri = uri;
          capturedHeaders = Map<String, String>.of(headers);
          throw const SocketException('stop after capturing websocket headers');
        },
      );

      await expectLater(
        realtimeClient.subscribe(
          threadId: 'thread-1',
          projectId: 'project-1',
          counterpartOrganizationId: 'org-counterpart',
        ),
        throwsA(isA<SocketException>()),
      );

      expect(refreshRequests, 1);
      expect(
        capturedUri.toString(),
        'ws://127.0.0.1:8080/api/app/message/project-communication/realtime',
      );
      expect(
        capturedHeaders?['authorization'],
        'Bearer refreshed-access-token',
      );
      expect(capturedHeaders?['x-actor-id'], 'actor-1');
      expect(capturedHeaders?['x-user-id'], 'user-1');
    },
  );

  testWidgets(
    'conversation order card stays read-only when order organization anchors are missing',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/message/counterpart-conversation/detail':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _detailPayload(
                        projectState: 'converted_to_order',
                        orderSummary: _orderSummaryPayload(
                          includeOrganizationAnchors: false,
                        ),
                      ),
                    );
                  },
              'GET /api/app/message/project-communication/thread':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _threadPayload(),
                    );
                  },
              'GET /api/app/message/project-communication/messages':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'items': <Object?>[],
                        'nextCursor': null,
                      },
                    );
                  },
              'GET /api/app/project/project-1/album/photos':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _albumListPayload(const <Object?>[]),
                    );
                  },
              'GET /api/app/order/detail': (AppApiRequest request) async {
                expect(request.uri.queryParameters['projectId'], 'project-1');
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _orderDetailPayload(includeOrganizationAnchors: false),
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildPageWithShell(
          transport,
          shellContext: AppShellContextData(
            userId: 'seller-user',
            organizationId: 'org-counterpart',
            roleKeys: const <String>['supplier_admin'],
            certificationStatus: 'approved',
            personalCertificationStatus: 'approved',
            personalCertificationQualified: true,
            visibleBuildings: const <String>[
              'exhibition',
              'messages',
              'profile',
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _ensureVisible(tester, find.text('订单状态卡'));
      await _ensureVisible(tester, find.text('当前账号仅可查看'));
      expect(find.text('当前账号仅可查看'), findsOneWidget);
      expect(find.text('申请完工'), findsNothing);
      expect(find.text('确认完成'), findsNothing);
    },
  );

  testWidgets(
    'conversation order summary lets seller request completion without rating entry',
    (WidgetTester tester) async {
      var requestCount = 0;
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/message/counterpart-conversation/detail':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _detailPayload(
                        projectState: 'converted_to_order',
                        orderSummary: _orderSummaryPayload(
                          completionRequestState: requestCount == 0
                              ? 'none'
                              : 'requested',
                        ),
                      ),
                    );
                  },
              'GET /api/app/message/project-communication/thread':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _threadPayload(),
                    );
                  },
              'GET /api/app/message/project-communication/messages':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'items': <Object?>[],
                        'nextCursor': null,
                      },
                    );
                  },
              'GET /api/app/project/project-1/album/photos':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _albumListPayload(const <Object?>[]),
                    );
                  },
              'GET /api/app/order/detail': (AppApiRequest request) async {
                expect(request.uri.queryParameters['orderId'], 'order-1');
                expect(request.uri.queryParameters['projectId'], 'project-1');
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _orderDetailPayload(
                    completionRequestState: requestCount == 0
                        ? 'none'
                        : 'requested',
                  ),
                );
              },
              'POST /api/app/order/complete/request':
                  (AppApiRequest request) async {
                    requestCount += 1;
                    expect(request.body, const <String, Object?>{
                      'orderId': 'order-1',
                      'note': '承接方申请当前订单完工，请发布方确认。',
                    });
                    return AppApiResponse(
                      statusCode: 202,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'orderId': 'order-1',
                        'projectId': 'project-1',
                        'state': 'active',
                        'completionRequestState': 'requested',
                        'summary': <String, Object?>{'heading': '已申请完工'},
                      },
                    );
                  },
              'GET /api/app/my/projects': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _myProjectListPayload(),
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildPageWithShell(
          transport,
          shellContext: AppShellContextData(
            userId: 'seller-user',
            organizationId: 'org-counterpart',
            roleKeys: const <String>['supplier_admin'],
            certificationStatus: 'approved',
            personalCertificationStatus: 'approved',
            personalCertificationQualified: true,
            visibleBuildings: const <String>[
              'exhibition',
              'messages',
              'profile',
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _ensureVisible(tester, find.text('订单状态卡'));
      await _ensureVisible(tester, find.text('申请完工'));
      expect(find.text('申请完工'), findsOneWidget);
      expect(find.text('确认完成'), findsNothing);

      await tester.tap(find.text('申请完工'));
      await tester.pumpAndSettle();

      expect(requestCount, 1);
    },
  );

  testWidgets(
    'conversation order summary lets buyer confirm requested completion',
    (WidgetTester tester) async {
      var confirmCount = 0;
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/message/counterpart-conversation/detail':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _detailPayload(
                        projectState: 'converted_to_order',
                        orderSummary: _orderSummaryPayload(
                          state: confirmCount == 0 ? 'active' : 'completed',
                          completionRequestState: confirmCount == 0
                              ? 'requested'
                              : 'confirmed',
                        ),
                      ),
                    );
                  },
              'GET /api/app/message/project-communication/thread':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _threadPayload(),
                    );
                  },
              'GET /api/app/message/project-communication/messages':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'items': <Object?>[],
                        'nextCursor': null,
                      },
                    );
                  },
              'GET /api/app/project/project-1/album/photos':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _albumListPayload(const <Object?>[]),
                    );
                  },
              'GET /api/app/order/detail': (AppApiRequest request) async {
                expect(request.uri.queryParameters['orderId'], 'order-1');
                expect(request.uri.queryParameters['projectId'], 'project-1');
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _orderDetailPayload(
                    state: confirmCount == 0 ? 'active' : 'completed',
                    completionRequestState: confirmCount == 0
                        ? 'requested'
                        : 'confirmed',
                  ),
                );
              },
              'POST /api/app/order/complete/confirm':
                  (AppApiRequest request) async {
                    confirmCount += 1;
                    expect(request.body, const <String, Object?>{
                      'orderId': 'order-1',
                    });
                    return AppApiResponse(
                      statusCode: 202,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'orderId': 'order-1',
                        'projectId': 'project-1',
                        'state': 'completed',
                        'completionRequestState': 'confirmed',
                        'summary': <String, Object?>{'heading': '已确认完成'},
                      },
                    );
                  },
              'GET /api/app/my/projects': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _myProjectListPayload(),
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildPageWithShell(
          transport,
          shellContext: AppShellContextData(
            userId: 'buyer-user',
            organizationId: 'org-owner',
            roleKeys: const <String>['buyer_admin'],
            certificationStatus: 'approved',
            personalCertificationStatus: 'approved',
            personalCertificationQualified: true,
            visibleBuildings: const <String>[
              'exhibition',
              'messages',
              'profile',
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _ensureVisible(tester, find.text('订单状态卡'));
      await _ensureVisible(tester, find.text('确认完成'));
      expect(find.text('确认完成'), findsOneWidget);
      await _ensureVisible(tester, find.text('拒绝完工'));
      expect(find.text('拒绝完工'), findsOneWidget);
      expect(find.text('申请完工'), findsNothing);

      await tester.tap(find.text('确认完成'));
      await tester.pumpAndSettle();

      expect(confirmCount, 1);
    },
  );

  testWidgets(
    'counterpart conversation header uses nickname and business cards are full-flow actions',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/message/counterpart-conversation/detail':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _detailPayload(),
                    );
                  },
              'GET /api/app/message/project-communication/thread':
                  (AppApiRequest request) async {
                    expect(
                      request.uri.queryParameters['projectId'],
                      'project-1',
                    );
                    expect(
                      request.uri.queryParameters['counterpartOrganizationId'],
                      'org-counterpart',
                    );
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _threadPayload(),
                    );
                  },
              'GET /api/app/message/project-communication/messages':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'items': <Object?>[],
                        'nextCursor': null,
                      },
                    );
                  },
            },
      );

      await tester.pumpWidget(_buildPage(transport));
      await tester.pumpAndSettle();

      expect(find.text('项目沟通'), findsOneWidget);
      expect(find.text('重庆涪川展览工厂'), findsOneWidget);
      expect(find.text('昵称'), findsOneWidget);
      expect(find.text('对方主体'), findsNothing);
      expect(find.text('1 个项目'), findsNothing);
      expect(find.text('查看申请'), findsOneWidget);
      expect(find.text('进入竞标沟通'), findsOneWidget);
      expect(find.text('想跟TA说点什么...'), findsOneWidget);

      await tester.tap(find.byType(CircleAvatar).first);
      await tester.pumpAndSettle();

      expect(find.text('对方主体'), findsOneWidget);
      expect(find.text('评价对方'), findsOneWidget);
      expect(find.text('当前项目尚未结束，评价入口不会开放。'), findsOneWidget);
    },
  );

  testWidgets(
    'project order business card opens order detail with project and order anchors',
    (WidgetTester tester) async {
      var orderDetailCount = 0;
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/message/counterpart-conversation/detail':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _detailPayload(includeOrderCard: true),
                    );
                  },
              'GET /api/app/message/project-communication/thread':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _threadPayload(),
                    );
                  },
              'GET /api/app/message/project-communication/messages':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'items': <Object?>[],
                        'nextCursor': null,
                      },
                    );
                  },
              'GET /api/app/order/detail': (AppApiRequest request) async {
                orderDetailCount += 1;
                expect(request.uri.queryParameters['orderId'], 'order-1');
                expect(request.uri.queryParameters['projectId'], 'project-1');
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _orderDetailPayload(),
                );
              },
            },
      );

      await tester.pumpWidget(_buildPage(transport));
      await tester.pumpAndSettle();

      expect(find.text('订单状态'), findsWidgets);
      expect(find.text('查看订单'), findsOneWidget);

      final openOrderButton = find.text('查看订单');
      await _ensureVisible(tester, openOrderButton);
      await tester.tap(openOrderButton);
      await tester.pumpAndSettle();

      expect(orderDetailCount, 1);
      expect(find.text('订单详情'), findsOneWidget);
    },
  );

  testWidgets(
    'ended project avatar sheet submits rating once when server rating anchor allows it',
    (WidgetTester tester) async {
      var detailLoadCount = 0;
      var submitCount = 0;
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/message/counterpart-conversation/detail':
                  (AppApiRequest request) async {
                    detailLoadCount += 1;
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _detailPayload(
                        projectState: 'completed',
                        ratingEntry: <String, Object?>{
                          'orderId': 'order-1',
                          'projectId': 'project-1',
                          'rateeOrganizationId': 'org-counterpart',
                          'canRate': detailLoadCount == 1,
                          'reason': detailLoadCount == 1 ? null : '评价已提交。',
                          'ratingState': detailLoadCount == 1
                              ? 'draft'
                              : 'submitted',
                        },
                      ),
                    );
                  },
              'GET /api/app/message/project-communication/thread':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _threadPayload(),
                    );
                  },
              'GET /api/app/message/project-communication/messages':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'items': <Object?>[],
                        'nextCursor': null,
                      },
                    );
                  },
              'POST /api/app/project-counterparty-rating/submit':
                  (AppApiRequest request) async {
                    submitCount += 1;
                    expect(request.body, const <String, Object?>{
                      'orderId': 'order-1',
                      'projectId': 'project-1',
                      'rateeOrganizationId': 'org-counterpart',
                      'scoreLabel': 'very_satisfied',
                      'commentText': '标签：响应及时',
                    });
                    return AppApiResponse(
                      statusCode: 202,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'ratingId': 'rating-1',
                        'orderId': 'order-1',
                        'projectId': 'project-1',
                        'raterOrganizationId': 'org-owner',
                        'rateeOrganizationId': 'org-counterpart',
                        'state': 'submitted',
                        'ratingState': 'submitted',
                        'scoreValue': 5,
                        'scoreLabel': 'very_satisfied',
                        'submittedAt': '2026-05-07T10:00:00Z',
                      },
                    );
                  },
            },
      );

      await tester.pumpWidget(_buildPage(transport));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CircleAvatar).first);
      await tester.pumpAndSettle();
      final submitButton = find.byKey(
        const ValueKey<String>('counterpart_rating_submit_button'),
      );
      await tester.scrollUntilVisible(
        submitButton,
        220,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      await tester.tap(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(submitCount, 1);
      expect(detailLoadCount, 2);
      expect(find.text('评价已提交'), findsOneWidget);
    },
  );

  testWidgets(
    'project album uploads image through file asset flow and deletes photo',
    (WidgetTester tester) async {
      var albumLoadCount = 0;
      var bindCount = 0;
      var deleteCount = 0;
      ProjectAttachmentDebugOverrides.installPicker(
        () async => const ProjectAttachmentDraft(
          fileName: 'progress.png',
          bytes: <int>[1, 2, 3, 4],
        ),
      );
      final transport = FakeAppApiTransport(
        uploadHandler: (AppApiUploadRequest request) async {
          expect(request.url, 'https://upload.example.com/album-1');
          expect(request.bodyBytes, const <int>[1, 2, 3, 4]);
          return AppApiResponse(statusCode: 200, uri: Uri.parse(request.url));
        },
        handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
          'GET /api/app/message/counterpart-conversation/detail':
              (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _detailPayload(),
                );
              },
          'GET /api/app/message/project-communication/thread':
              (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _threadPayload(),
                );
              },
          'GET /api/app/message/project-communication/messages':
              (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'items': <Object?>[],
                    'nextCursor': null,
                  },
                );
              },
          'GET /api/app/project/project-1/album/photos':
              (AppApiRequest request) async {
                albumLoadCount += 1;
                final items = albumLoadCount >= 2 && deleteCount == 0
                    ? <Object?>[_albumPhotoPayload()]
                    : <Object?>[];
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _albumListPayload(items),
                );
              },
          'POST /api/app/file/upload/init': (AppApiRequest request) async {
            expect(request.body, const <String, Object?>{
              'businessType': 'project',
              'businessId': 'project-1',
              'fileKind': 'project_album_photo',
              'mimeType': 'image/png',
              'size': 4,
              'checksum':
                  '9f64a747e1b97f131fabb6b447296c9b6f0201e79fb3c5356e6c77e89b6a806a',
            });
            return AppApiResponse(
              statusCode: 200,
              uri: request.uri,
              body: const <String, Object?>{
                'uploadSessionId': 'album-session-1',
                'directUpload': <String, Object?>{
                  'url': 'https://upload.example.com/album-1',
                  'method': 'PUT',
                  'headers': <String, Object?>{},
                },
                'confirm': <String, Object?>{
                  'endpoint': '/api/app/file/upload/confirm',
                },
              },
            );
          },
          'POST /api/app/file/upload/confirm': (AppApiRequest request) async {
            expect(request.body, const <String, Object?>{
              'uploadSessionId': 'album-session-1',
            });
            return AppApiResponse(
              statusCode: 200,
              uri: request.uri,
              body: const <String, Object?>{'fileAssetId': 'file-album-1'},
            );
          },
          'POST /api/app/project/project-1/album/photos':
              (AppApiRequest request) async {
                bindCount += 1;
                expect(request.body, const <String, Object?>{
                  'fileAssetId': 'file-album-1',
                  'category': 'progress',
                  'caption': 'progress.png',
                  'sortOrder': 0,
                });
                return AppApiResponse(
                  statusCode: 202,
                  uri: request.uri,
                  body: _albumPhotoPayload(),
                );
              },
          'DELETE /api/app/project/project-1/album/photos/photo-1':
              (AppApiRequest request) async {
                deleteCount += 1;
                return AppApiResponse(
                  statusCode: 202,
                  uri: request.uri,
                  body: _albumPhotoPayload(
                    photoState: 'removed',
                    removedAt: '2026-05-06T10:05:00Z',
                  ),
                );
              },
        },
      );

      await tester.pumpWidget(_buildPage(transport));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('项目相册'),
        280,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('项目相册'), findsOneWidget);
      expect(find.text('当前数量：0 / 50'), findsOneWidget);
      expect(find.text('上传图片'), findsOneWidget);

      await tester.tap(find.text('上传图片'));
      await tester.pumpAndSettle();

      expect(bindCount, 1);
      expect(transport.uploads, hasLength(1));
      expect(find.textContaining('progress.png 已进入项目相册'), findsOneWidget);
      expect(find.textContaining('file-album-1'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('预览'),
        160,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('预览'));
      await tester.pumpAndSettle();
      expect(find.text('照片预览'), findsOneWidget);
      await tester.tap(find.text('关闭'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('删除'),
        120,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('删除'));
      await tester.pumpAndSettle();

      expect(deleteCount, 1);
      expect(find.textContaining('已删除相册照片'), findsOneWidget);
    },
  );

  testWidgets(
    'project communication composer shows optimistic text and refreshes after send',
    (WidgetTester tester) async {
      final sendCompleter = Completer<void>();
      var messageLoadCount = 0;
      var postCount = 0;
      Object? postedBody;
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/message/counterpart-conversation/detail':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _detailPayload(),
                    );
                  },
              'GET /api/app/message/project-communication/thread':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _threadPayload(),
                    );
                  },
              'GET /api/app/message/project-communication/messages':
                  (AppApiRequest request) async {
                    messageLoadCount += 1;
                    final items = messageLoadCount > 1
                        ? <Object?>[
                            _messagePayload(messageId: 'message-1', body: '在吗'),
                          ]
                        : <Object?>[];
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: <String, Object?>{
                        'items': items,
                        'nextCursor': null,
                      },
                    );
                  },
              'POST /api/app/message/project-communication/messages':
                  (AppApiRequest request) async {
                    postCount += 1;
                    postedBody = request.body;
                    await sendCompleter.future;
                    return AppApiResponse(
                      statusCode: 202,
                      uri: request.uri,
                      body: _messagePayload(
                        messageId: 'message-1',
                        body: '在吗',
                        clientMessageId:
                            (request.body
                                    as Map<String, Object?>)['clientMessageId']
                                as String?,
                      ),
                    );
                  },
              'POST /api/app/message/project-communication/read-cursor':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 202,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'threadId': 'project-thread-1',
                        'projectId': 'project-1',
                        'organizationId': 'org-owner',
                        'lastReadMessageId': 'message-1',
                        'lastReadAt': '2026-05-04T10:02:01Z',
                        'updatedAt': '2026-05-04T10:02:01Z',
                      },
                    );
                  },
            },
      );

      await tester.pumpWidget(_buildPage(transport));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(TextField));
      await tester.tap(find.byType(TextField));
      await tester.enterText(find.byType(TextField), '在吗');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.send_rounded), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 260));

      expect(postCount, 1);
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -900));
      await tester.pump();
      expect(find.text('在吗'), findsOneWidget);
      expect(find.text('发送中...'), findsOneWidget);
      expect(
        postedBody,
        isA<Map<String, Object?>>()
            .having(
              (Map<String, Object?> body) => body['threadId'],
              'threadId',
              'project-thread-1',
            )
            .having(
              (Map<String, Object?> body) => body['projectId'],
              'projectId',
              'project-1',
            )
            .having((Map<String, Object?> body) => body['body'], 'body', '在吗'),
      );

      sendCompleter.complete();
      await tester.pumpAndSettle();

      expect(messageLoadCount, 2);
      expect(find.text('发送中...'), findsNothing);
      expect(find.text('在吗'), findsOneWidget);
    },
  );

  testWidgets(
    'project communication failed draft can be retried and then refreshed',
    (WidgetTester tester) async {
      var messageLoadCount = 0;
      var postCount = 0;
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/message/counterpart-conversation/detail':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _detailPayload(),
                    );
                  },
              'GET /api/app/message/project-communication/thread':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _threadPayload(),
                    );
                  },
              'GET /api/app/message/project-communication/messages':
                  (AppApiRequest request) async {
                    messageLoadCount += 1;
                    final items = postCount >= 2
                        ? <Object?>[
                            _messagePayload(
                              messageId: 'retry-message-1',
                              body: '重试后的消息',
                              clientMessageId: 'retry-client-id',
                            ),
                          ]
                        : <Object?>[];
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: <String, Object?>{
                        'items': items,
                        'nextCursor': null,
                      },
                    );
                  },
              'POST /api/app/message/project-communication/messages':
                  (AppApiRequest request) async {
                    postCount += 1;
                    if (postCount == 1) {
                      return AppApiResponse(
                        statusCode: 502,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'code': 'PROJECT_COMMUNICATION_UNAVAILABLE',
                          'message': '网络抖动，请重试',
                        },
                      );
                    }
                    return AppApiResponse(
                      statusCode: 202,
                      uri: request.uri,
                      body: _messagePayload(
                        messageId: 'retry-message-1',
                        body: '重试后的消息',
                        clientMessageId: 'retry-client-id',
                      ),
                    );
                  },
              'POST /api/app/message/project-communication/read-cursor':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 202,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'threadId': 'project-thread-1',
                        'projectId': 'project-1',
                        'organizationId': 'org-owner',
                        'lastReadMessageId': 'retry-message-1',
                        'lastReadAt': '2026-05-04T10:05:01Z',
                        'updatedAt': '2026-05-04T10:05:01Z',
                      },
                    );
                  },
            },
      );

      await tester.pumpWidget(_buildPage(transport));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(TextField));
      await tester.tap(find.byType(TextField));
      await tester.enterText(find.byType(TextField), '重试后的消息');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.send_rounded), warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -900));
      await tester.pumpAndSettle();

      expect(postCount, 1);
      expect(find.textContaining('发送失败'), findsOneWidget);
      expect(find.text('重试'), findsOneWidget);

      await tester.tap(find.text('重试'));
      await tester.pumpAndSettle();

      expect(postCount, 2);
      expect(messageLoadCount, greaterThanOrEqualTo(2));
      expect(find.textContaining('发送失败'), findsNothing);
      expect(find.text('重试后的消息'), findsOneWidget);
    },
  );

  testWidgets(
    'project communication realtime event appears without tapping refresh',
    (WidgetTester tester) async {
      var messageLoadCount = 0;
      final realtimeEvents =
          StreamController<ProjectCommunicationMessageCreatedEvent>();
      final realtimeClient = _FakeProjectCommunicationRealtimeClient(
        realtimeEvents,
      );
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/message/counterpart-conversation/detail':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _detailPayload(),
                    );
                  },
              'GET /api/app/message/project-communication/thread':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _threadPayload(),
                    );
                  },
              'GET /api/app/message/project-communication/messages':
                  (AppApiRequest request) async {
                    messageLoadCount += 1;
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'items': <Object?>[],
                        'nextCursor': null,
                      },
                    );
                  },
              'POST /api/app/message/project-communication/read-cursor':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 202,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'threadId': 'project-thread-1',
                        'projectId': 'project-1',
                        'organizationId': 'org-owner',
                        'lastReadMessageId': 'message-realtime-1',
                        'lastReadAt': '2026-05-04T10:03:01Z',
                        'updatedAt': '2026-05-04T10:03:01Z',
                      },
                    );
                  },
            },
      );

      await tester.pumpWidget(
        _buildPage(transport, realtimeClient: realtimeClient),
      );
      await tester.pumpAndSettle();

      expect(realtimeClient.subscriptions, hasLength(1));
      expect(realtimeClient.subscriptions.single, <String, String>{
        'threadId': 'project-thread-1',
        'projectId': 'project-1',
        'counterpartOrganizationId': 'org-counterpart',
      });
      expect(messageLoadCount, 1);
      expect(find.text('实时收到的新消息'), findsNothing);

      realtimeEvents.add(
        const ProjectCommunicationMessageCreatedEvent(
          eventId: 'event-1',
          messageId: 'message-realtime-1',
          threadId: 'project-thread-1',
          projectId: 'project-1',
          senderOrganizationId: 'org-counterpart',
          messageKind: 'text',
          body: '实时收到的新消息',
          clientMessageId: null,
          createdAt: '2026-05-04T10:03:00Z',
        ),
      );
      await tester.pump();
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -900));
      await tester.pumpAndSettle();

      expect(find.text('实时收到的新消息'), findsOneWidget);
      expect(messageLoadCount, 1);
    },
  );

  testWidgets(
    'project communication falls back to quiet polling when websocket is unavailable',
    (WidgetTester tester) async {
      var messageLoadCount = 0;
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/message/counterpart-conversation/detail':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _detailPayload(),
                    );
                  },
              'GET /api/app/message/project-communication/thread':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _threadPayload(),
                    );
                  },
              'GET /api/app/message/project-communication/messages':
                  (AppApiRequest request) async {
                    messageLoadCount += 1;
                    final items = messageLoadCount > 1
                        ? <Object?>[
                            _messagePayload(
                              messageId: 'poll-message-1',
                              body: '轮询兜底消息',
                            ),
                          ]
                        : <Object?>[];
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: <String, Object?>{
                        'items': items,
                        'nextCursor': null,
                      },
                    );
                  },
              'POST /api/app/message/project-communication/read-cursor':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 202,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'threadId': 'project-thread-1',
                        'projectId': 'project-1',
                        'organizationId': 'org-owner',
                        'lastReadMessageId': 'poll-message-1',
                        'lastReadAt': '2026-05-04T10:04:01Z',
                        'updatedAt': '2026-05-04T10:04:01Z',
                      },
                    );
                  },
            },
      );

      await tester.pumpWidget(
        _buildPage(
          transport,
          realtimeClient: _FailingProjectCommunicationRealtimeClient(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -900));
      await tester.pumpAndSettle();

      expect(messageLoadCount, greaterThanOrEqualTo(2));
      expect(find.text('轮询兜底消息'), findsOneWidget);
    },
  );

  testWidgets(
    'project communication closes websocket when page leaves and reconnects when it returns',
    (WidgetTester tester) async {
      final realtimeClient = _LifecycleProjectCommunicationRealtimeClient();
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/message/counterpart-conversation/detail':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _detailPayload(),
                    );
                  },
              'GET /api/app/message/project-communication/thread':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _threadPayload(),
                    );
                  },
              'GET /api/app/message/project-communication/messages':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'items': <Object?>[],
                        'nextCursor': null,
                      },
                    );
                  },
            },
      );

      await tester.pumpWidget(
        _buildPage(transport, realtimeClient: realtimeClient),
      );
      await tester.pumpAndSettle();
      expect(realtimeClient.subscriptions, hasLength(1));

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await tester.idle();
      expect(realtimeClient.closeCount, 1);

      await tester.pumpWidget(
        _buildPage(transport, realtimeClient: realtimeClient),
      );
      await tester.pumpAndSettle();
      await tester.idle();
      expect(realtimeClient.subscriptions, hasLength(2));
    },
  );
}
