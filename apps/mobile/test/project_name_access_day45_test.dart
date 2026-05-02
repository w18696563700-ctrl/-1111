import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/forum_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/project_name_access_consumer_layer.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/messages/data/counterpart_conversation_consumer_layer.dart';
import 'package:mobile/features/messages/data/messages_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_consumer_layer.dart';
import 'package:mobile/shell/shell_app.dart';

AppApiClient _client(FakeAppApiTransport transport) {
  return AppApiClient(
    config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
    transport: transport,
  );
}

AppSessionStore _authenticatedSessionStore({required String deviceId}) {
  final sessionStore = AppSessionStore();
  sessionStore.establishSession(
    accessToken: 'access-$deviceId',
    refreshToken: 'refresh-$deviceId',
    expiresInSeconds: 3600,
    deviceId: deviceId,
  );
  return sessionStore;
}

ForumConsumerLayer _forumConsumer({FakeAppApiTransport? transport}) {
  return ForumConsumerLayer(
    client: AppApiClient(
      config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
      transport:
          transport ??
          FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
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
          ),
    ),
  );
}

ProfileConsumerLayer _profileConsumer() {
  return ProfileConsumerLayer(
    client: AppApiClient(
      config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
      transport: FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{},
      ),
    ),
  );
}

ExhibitionMobileApp _buildApp({
  required String initialRoute,
  required FakeAppApiTransport transport,
  AppSessionStore? sessionStore,
  ForumConsumerLayer? forumConsumerLayer,
}) {
  return ExhibitionMobileApp(
    initialRoute: initialRoute,
    exhibitionConsumerLayer: ExhibitionConsumerLayer(
      client: _client(transport),
    ),
    projectNameAccessConsumerLayer: ProjectNameAccessConsumerLayer(
      client: _client(transport),
    ),
    messagesConsumerLayer: MessagesConsumerLayer(client: _client(transport)),
    counterpartConversationConsumerLayer: CounterpartConversationConsumerLayer(
      client: _client(transport),
    ),
    forumConsumerLayer: forumConsumerLayer ?? _forumConsumer(),
    profileConsumerLayer: _profileConsumer(),
    sessionStore: sessionStore,
  );
}

Map<String, Object?> _projectPayload({
  required String projectId,
  required Map<String, Object?> nameAccess,
}) {
  return <String, Object?>{
    'projectId': projectId,
    'projectNo': 'EXH-2026-DD93A8',
    'title': '项目名称需申请查看',
    'displayTitle': '项目名称需申请查看',
    'exhibitionName': null,
    'brandName': null,
    'buildingType': 'exhibition',
    'budgetAmount': 120000,
    'areaSqm': 200,
    'provinceCode': '500000',
    'provinceName': '重庆市',
    'cityCode': '500100',
    'cityName': '重庆市',
    'districtCode': '500112',
    'districtName': '渝北区',
    'detailAddress': '重庆国际博览中心',
    'scopeSummary': '整个展位装修全包',
    'plannedStartAt': '2026-05-16',
    'plannedEndAt': '2026-05-23',
    'scheduleDetail': '5 月 16 日夜间进场',
    'viewerProjectRelation': 'non_owner',
    'state': 'published',
    'nameAccess': nameAccess,
    'summary': const <String, Object?>{
      'heading': '项目已进入最小发布走廊。',
      'stateLabel': '当前项目已发布，可继续进入最小竞标继续面。',
    },
  };
}

Map<String, Object?> _projectInteractionItem() {
  return <String, Object?>{
    'interactionId': 'org-requester-1',
    'interactionType': 'counterpart_conversation',
    'conversationId': 'org-requester-1',
    'projectId': 'project-1',
    'counterpart': const <String, Object?>{
      'organizationId': 'org-requester-1',
      'displayName': '重庆搭建公司',
      'avatarUrl': null,
      'role': 'counterpart',
    },
    'summary': const <String, Object?>{
      'focusProjectId': 'project-1',
      'title': '新的参与竞标申请',
      'text': '当前申请会话只承接系统申请卡与审批结果。',
      'projectCount': 1,
      'latestCardType': 'bid_participation_request',
    },
    'updatedAt': '2026-04-24T10:00:00Z',
    'routeTarget': const <String, Object?>{
      'objectType': 'counterpart_conversation',
      'actionKey': 'counterpart_conversation.open',
      'canonicalPath': '/api/app/message/counterpart-conversation/detail',
      'params': <String, Object?>{
        'conversationId': 'org-requester-1',
        'projectId': 'project-1',
      },
    },
  };
}

Map<String, Object?> _counterpartConversationDetailPayload() {
  return <String, Object?>{
    'conversationId': 'org-requester-1',
    'counterpart': const <String, Object?>{
      'organizationId': 'org-requester-1',
      'displayName': '重庆搭建公司',
      'avatarUrl': null,
      'role': 'counterpart',
    },
    'summary': const <String, Object?>{
      'focusProjectId': 'project-1',
      'title': '参与竞标申请',
      'text': '重庆搭建公司申请参与当前项目竞标。',
      'projectCount': 1,
      'latestCardType': 'bid_participation_request',
    },
    'focusProjectId': 'project-1',
    'latestActivityAt': '2026-04-24T10:00:00Z',
    'projectGroups': <Object?>[
      <String, Object?>{
        'projectId': 'project-1',
        'projectDisplayTitle': '项目名称需申请查看',
        'titleVisibility': 'masked',
        'projectState': 'published',
        'latestActivityAt': '2026-04-24T10:00:00Z',
        'cards': <Object?>[
          <String, Object?>{
            'cardId': 'bid-participation:request-1',
            'cardType': 'bid_participation_request',
            'title': '参与竞标申请',
            'summary': '重庆搭建公司申请参与当前项目竞标。',
            'status': 'pending',
            'updatedAt': '2026-04-24T10:00:00Z',
            'truthAnchor': const <String, Object?>{
              'truthType': 'bid_participation_request',
              'projectId': 'project-1',
              'requestId': 'request-1',
              'threadId': 'request-1',
            },
            'detailRouteTarget': const <String, Object?>{
              'objectType': 'bid_participation_request',
              'actionKey': 'bid_participation_request.open',
              'canonicalPath':
                  '/api/app/project/bid-participation/thread/detail',
              'params': <String, Object?>{
                'threadId': 'request-1',
                'projectId': 'project-1',
                'requestId': 'request-1',
              },
            },
            'decisionAvailability': const <String, Object?>{
              'canApprove': true,
              'canReject': true,
            },
          },
        ],
      },
    ],
  };
}

Map<String, Object?> _threadDetailPayload({required String requestStatus}) {
  final items = <Object?>[
    <String, Object?>{
      'itemId': 'request-1:seed',
      'itemKind': 'system_seed',
      'title': '参与竞标申请',
      'summary': '重庆搭建公司申请参与当前项目竞标。',
      'createdAt': '2026-04-24T10:00:00Z',
      'action': requestStatus == 'pending'
          ? const <String, Object?>{
              'actionKey': 'bid_participation.review',
              'objectType': 'bid_participation_request',
              'canonicalPath': null,
              'label': '处理申请',
              'params': <String, Object?>{},
            }
          : null,
    },
  ];
  if (requestStatus != 'pending') {
    items.add(<String, Object?>{
      'itemId': 'request-1:decision',
      'itemKind': 'system_notice',
      'title': requestStatus == 'approved' ? '审批已通过' : '审批已拒绝',
      'summary': requestStatus == 'approved'
          ? '重庆搭建公司 的参与竞标申请已通过。'
          : '重庆搭建公司 的参与竞标申请已拒绝。',
      'createdAt': '2026-04-24T10:05:00Z',
      'action': requestStatus == 'approved'
          ? const <String, Object?>{
              'actionKey': 'bid_submit.open',
              'objectType': 'bid_submit',
              'canonicalPath': '/api/app/bid/submit',
              'label': '立即参与竞标',
              'params': <String, Object?>{'projectId': 'project-1'},
            }
          : const <String, Object?>{
              'actionKey': 'bid_participation.refresh',
              'objectType': 'bid_participation_request',
              'canonicalPath': null,
              'label': '刷新状态',
              'params': <String, Object?>{},
            },
    });
  }

  return <String, Object?>{
    'threadId': 'request-1',
    'threadType': 'bid_participation_review',
    'projectId': 'project-1',
    'requestId': 'request-1',
    'requestStatus': requestStatus,
    'displayTitle': '项目名称需申请查看',
    'items': items,
    'primaryReviewAction': <String, Object?>{
      'actionKey': 'bid_participation.review',
      'enabled': requestStatus == 'pending',
      'availableDecisions': requestStatus == 'pending'
          ? const <Object?>['approve', 'reject']
          : const <Object?>[],
    },
  };
}

Map<String, Object?> _legacyNameAccessThreadDetailPayload() {
  return <String, Object?>{
    'threadId': 'legacy-request-1',
    'threadType': 'project_name_access_review',
    'projectId': 'project-1',
    'requestId': 'legacy-request-1',
    'requestStatus': 'pending',
    'displayTitle': '项目名称需申请查看',
    'items': const <Object?>[
      <String, Object?>{
        'itemId': 'legacy-request-1:seed',
        'itemKind': 'system_seed',
        'title': '项目名称查看申请',
        'summary': '重庆搭建公司申请查看当前项目名称。',
        'createdAt': '2026-04-24T10:00:00Z',
        'action': <String, Object?>{
          'actionKey': 'project_name_access.review',
          'objectType': 'project_name_access_request',
          'canonicalPath': null,
          'label': '处理申请',
          'params': <String, Object?>{},
        },
      },
    ],
    'primaryReviewAction': const <String, Object?>{
      'actionKey': 'project_name_access.review',
      'enabled': true,
      'availableDecisions': <Object?>['approve', 'reject'],
    },
  };
}

Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    220,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await _scrollTo(tester, finder);
  await tester.tap(finder, warnIfMissed: false);
  await tester.pump();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'showcase list keeps name access compact and routes request through detail',
    (WidgetTester tester) async {
      var detailLoadCount = 0;
      var requestCount = 0;
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/project/list': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'items': <Object?>[
                      _projectPayload(
                        projectId: 'project-1',
                        nameAccess: const <String, Object?>{
                          'status': 'requestable',
                          'canRequest': true,
                        },
                      ),
                    ],
                  },
                );
              },
              'GET /api/app/project/detail': (AppApiRequest request) async {
                detailLoadCount += 1;
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _projectPayload(
                    projectId: 'project-1',
                    nameAccess: <String, Object?>{
                      'status': detailLoadCount == 1
                          ? 'requestable'
                          : 'pending',
                      'canRequest': detailLoadCount == 1,
                      if (detailLoadCount > 1) 'requestId': 'request-1',
                    },
                  ),
                );
              },
              'POST /api/app/project/bid-participation/request':
                  (AppApiRequest request) async {
                    requestCount += 1;
                    expect(request.body, <String, Object?>{
                      'projectId': 'project-1',
                    });
                    return AppApiResponse(
                      statusCode: 202,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'requestId': 'request-1',
                        'projectId': 'project-1',
                        'status': 'pending',
                        'threadId': 'request-1',
                      },
                    );
                  },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          initialRoute: ExhibitionRoutes.showcase,
          transport: transport,
          sessionStore: _authenticatedSessionStore(deviceId: 'device-list'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('项目名称需申请查看'), findsWidgets);
      expect(find.text('搭建地：重庆市'), findsOneWidget);
      expect(find.text('面积：200 ㎡'), findsOneWidget);
      expect(find.text('可申请参与'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, '申请参与竞标'), findsNothing);
      expect(find.textContaining('当前项目需先申请参与竞标'), findsNothing);

      await _tapVisible(tester, find.text('项目名称需申请查看').first);

      expect(find.text('项目详情'), findsWidgets);
      await _tapVisible(tester, find.text('项目名称需申请查看').first);
      await _tapVisible(
        tester,
        find.widgetWithText(FilledButton, '申请参与竞标', skipOffstage: false).last,
      );

      expect(requestCount, 1);
    },
  );

  testWidgets(
    'project detail submits bid participation request and shows pending state',
    (WidgetTester tester) async {
      var detailLoadCount = 0;
      var requestCount = 0;
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/project/detail': (AppApiRequest request) async {
                detailLoadCount += 1;
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _projectPayload(
                    projectId: 'project-1',
                    nameAccess: <String, Object?>{
                      'status': detailLoadCount == 1
                          ? 'requestable'
                          : 'pending',
                      'canRequest': detailLoadCount == 1,
                      if (detailLoadCount > 1) 'requestId': 'request-1',
                    },
                  ),
                );
              },
              'POST /api/app/project/bid-participation/request':
                  (AppApiRequest request) async {
                    requestCount += 1;
                    expect(request.body, <String, Object?>{
                      'projectId': 'project-1',
                    });
                    return AppApiResponse(
                      statusCode: 202,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'requestId': 'request-1',
                        'projectId': 'project-1',
                        'status': 'pending',
                        'threadId': 'request-1',
                      },
                    );
                  },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          initialRoute: ExhibitionRoutes.projectDetailWithProjectId(
            'project-1',
          ),
          transport: transport,
          sessionStore: _authenticatedSessionStore(deviceId: 'device-detail'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('参与竞标申请', skipOffstage: false), findsNothing);

      await _tapVisible(tester, find.text('项目名称需申请查看').first);

      expect(find.text('参与竞标申请', skipOffstage: false), findsOneWidget);
      expect(find.text('可申请参与', skipOffstage: false), findsOneWidget);
      expect(
        find.widgetWithText(FilledButton, '申请参与竞标', skipOffstage: false),
        findsWidgets,
      );

      await _tapVisible(
        tester,
        find.widgetWithText(FilledButton, '申请参与竞标', skipOffstage: false).last,
      );

      expect(requestCount, 1);

      await _tapVisible(tester, find.text('项目名称需申请查看').first);

      expect(find.text('待审批', skipOffstage: false), findsOneWidget);
      expect(
        find.widgetWithText(OutlinedButton, '查看申请状态', skipOffstage: false),
        findsOneWidget,
      );
    },
  );

  testWidgets('messages lane opens bid participation thread and approves request', (
    WidgetTester tester,
  ) async {
    var threadLoadCount = 0;
    var approveCount = 0;
    final transport = FakeAppApiTransport(
      handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
        'GET /api/app/message/interactions': (AppApiRequest request) async {
          return AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: <String, Object?>{
              'lane': 'project_communication',
              'items': <Object?>[_projectInteractionItem()],
            },
          );
        },
        'GET /api/app/message/counterpart-conversation/detail':
            (AppApiRequest request) async {
              expect(
                request.uri.queryParameters['conversationId'],
                'org-requester-1',
              );
              expect(request.uri.queryParameters['projectId'], 'project-1');
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _counterpartConversationDetailPayload(),
              );
            },
        'GET /api/app/project/bid-participation/thread/detail':
            (AppApiRequest request) async {
              threadLoadCount += 1;
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _threadDetailPayload(
                  requestStatus: threadLoadCount == 1 ? 'pending' : 'approved',
                ),
              );
            },
        'POST /api/app/my/projects/project-1/bid-participation/request-1/approve':
            (AppApiRequest request) async {
              approveCount += 1;
              return AppApiResponse(
                statusCode: 202,
                uri: request.uri,
                body: const <String, Object?>{
                  'requestId': 'request-1',
                  'projectId': 'project-1',
                  'status': 'approved',
                },
              );
            },
      },
    );

    await tester.pumpWidget(
      _buildApp(
        initialRoute: '/messages',
        transport: transport,
        sessionStore: _authenticatedSessionStore(deviceId: 'device-messages'),
        forumConsumerLayer: _forumConsumer(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('项目沟通'), findsOneWidget);
    expect(find.text('重庆搭建公司'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '进入项目沟通'), findsOneWidget);

    await _tapVisible(tester, find.widgetWithText(FilledButton, '进入项目沟通'));

    expect(find.text('项目名称需申请查看'), findsOneWidget);
    expect(find.text('项目列表'), findsOneWidget);
    expect(find.text('参与竞标申请'), findsNothing);

    await _tapVisible(tester, find.widgetWithText(FilledButton, '进入此项目竞标沟通'));

    expect(find.text('竞标沟通'), findsOneWidget);
    expect(find.text('参与竞标申请 / 审核'), findsOneWidget);

    await _tapVisible(tester, find.widgetWithText(FilledButton, '参与竞标申请 / 审核'));

    expect(find.text('参与竞标申请'), findsWidgets);
    expect(
      find.textContaining('当前状态：待审批', skipOffstage: false),
      findsOneWidget,
    );
    expect(find.textContaining('线程 ID', skipOffstage: false), findsNothing);
    expect(find.textContaining('项目 ID', skipOffstage: false), findsNothing);
    expect(find.textContaining('申请 ID', skipOffstage: false), findsNothing);

    await _tapVisible(tester, find.widgetWithText(FilledButton, '处理申请').first);
    expect(find.text('同意参与竞标'), findsOneWidget);

    await _tapVisible(tester, find.widgetWithText(FilledButton, '同意参与竞标'));

    expect(approveCount, 1);
    expect(find.text('审批已通过'), findsWidgets);
    expect(find.text('审批已通过'), findsWidgets);
  });

  testWidgets(
    'legacy project name access thread is read-only and hides review actions',
    (WidgetTester tester) async {
      var approveCount = 0;
      final transport = FakeAppApiTransport(
        handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
          'GET /api/app/project/name-access/thread/detail':
              (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _legacyNameAccessThreadDetailPayload(),
                );
              },
          'POST /api/app/my/projects/project-1/name-access/legacy-request-1/approve':
              (AppApiRequest request) async {
                approveCount += 1;
                return AppApiResponse(
                  statusCode: 202,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'requestId': 'legacy-request-1',
                    'projectId': 'project-1',
                    'status': 'approved',
                  },
                );
              },
        },
      );

      await tester.pumpWidget(
        _buildApp(
          initialRoute: ExhibitionRoutes.projectNameAccessThreadWithIds(
            threadId: 'legacy-request-1',
            projectId: 'project-1',
            requestId: 'legacy-request-1',
          ),
          transport: transport,
          sessionStore: _authenticatedSessionStore(deviceId: 'device-legacy'),
          forumConsumerLayer: _forumConsumer(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('历史项目名称查看申请'), findsOneWidget);
      expect(find.text('历史记录说明'), findsOneWidget);
      expect(find.textContaining('旧审批入口已停用'), findsOneWidget);
      await _scrollTo(tester, find.text('申请记录'));
      expect(find.text('项目名称查看申请'), findsOneWidget);
      expect(find.text('处理申请'), findsNothing);
      expect(find.text('同意查看项目名称'), findsNothing);
      expect(find.text('拒绝本次申请'), findsNothing);
      expect(approveCount, 0);
    },
  );
}
