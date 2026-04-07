import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/location/device_location_service.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/exhibition_home_aggregation_client.dart';
import 'package:mobile/features/exhibition/data/forum_consumer_layer.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/messages/data/messages_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_consumer_layer.dart';
import 'package:mobile/shell/shell_app.dart';

import 'support/exhibition_home_test_doubles.dart';

Map<String, Object?> _workbenchPayload({
  Map<String, Object?>? projectChain,
  Map<String, Object?>? orderChain,
  Map<String, Object?>? fulfillmentChain,
  Map<String, Object?>? extensionBoundary,
}) {
  return <String, Object?>{
    'project_chain':
        projectChain ??
        <String, Object?>{
          'hasProjects': true,
          'recentProjectId': 'project-1',
          'recentProjectTitle': '首发项目',
          'canCreateProject': true,
          'canOpenProjectPool': true,
        },
    'order_chain':
        orderChain ??
        <String, Object?>{
          'activeOrderId': 'order-1',
          'activeOrderNo': 'ORD-1',
          'activeOrderState': 'active',
          'canOpenOrderDetail': true,
          'canOpenContractDetail': true,
          'canOpenDisputeOpen': true,
        },
    'fulfillment_chain':
        fulfillmentChain ??
        <String, Object?>{
          'activeMilestoneId': 'milestone-1',
          'activeMilestoneTitle': '首期里程碑',
          'inspectionState': 'draft',
          'canOpenMilestoneList': true,
          'canOpenMilestoneSubmit': true,
          'canOpenInspectionDetail': true,
          'canOpenInspectionSubmit': true,
        },
    'extension_boundary':
        extensionBoundary ??
        <String, Object?>{
          'canOpenContractDetail': true,
          'ratingEntryState': 'extension_only',
          'canOpenDisputeOpen': true,
          'disputeWithdrawState': 'frozen',
        },
  };
}

ExhibitionMobileApp _buildApp({
  required ExhibitionConsumerLayer exhibitionConsumerLayer,
  ForumConsumerLayer? forumConsumerLayer,
  ExhibitionHomeAggregationClient? exhibitionHomeAggregationClient,
  DeviceLocationService? deviceLocationService,
  String initialRoute = ExhibitionRoutes.workbench,
}) {
  return ExhibitionMobileApp(
    initialRoute: initialRoute,
    exhibitionConsumerLayer: exhibitionConsumerLayer,
    exhibitionHomeAggregationClient:
        exhibitionHomeAggregationClient ??
        FakeExhibitionHomeAggregationClient(),
    forumConsumerLayer: forumConsumerLayer,
    deviceLocationService: deviceLocationService ?? FakeDeviceLocationService(),
    messagesConsumerLayer: MessagesConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers:
              <
                String,
                Future<AppApiResponse> Function(AppApiRequest request)
              >{},
        ),
      ),
    ),
    profileConsumerLayer: ProfileConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers:
              <
                String,
                Future<AppApiResponse> Function(AppApiRequest request)
              >{},
        ),
      ),
    ),
  );
}

Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    220,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

ForumConsumerLayer _forumConsumer() {
  return ForumConsumerLayer(
    client: AppApiClient(
      config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
      transport: FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/forum/me/index': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'memberId': 'member-1',
                    'summary': <String, Object?>{
                      'topicCount': 2,
                      'postCount': 3,
                      'draftCount': 1,
                      'unreadReplyCount': 0,
                    },
                    'recentTopics': <Object?>[
                      <String, Object?>{
                        'topicId': 'expo-materials',
                        'title': '展台材料分享',
                        'excerpt': '当前话题摘要',
                        'categoryKey': 'expo',
                        'state': 'published',
                        'author': <String, Object?>{
                          'authorId': 'member-1',
                          'displayName': '赵工',
                        },
                        'engagement': <String, Object?>{
                          'replyCount': 8,
                          'likeCount': 12,
                          'viewCount': 45,
                        },
                        'lastActiveAt': '2026-03-27T10:00:00Z',
                        'highlightedPostId': 'post-materials-1',
                      },
                    ],
                    'recentPosts': <Object?>[
                      <String, Object?>{
                        'postId': 'post-materials-1',
                        'topicId': 'expo-materials',
                        'topicTitle': '展台材料分享',
                        'excerpt': '当前帖子摘要',
                        'state': 'published',
                        'author': <String, Object?>{
                          'authorId': 'member-1',
                          'displayName': '赵工',
                        },
                        'publishedAt': '2026-03-27T09:30:00Z',
                      },
                    ],
                    'recentDrafts': <Object?>[
                      <String, Object?>{
                        'draftId': 'draft-1',
                        'draftType': 'topic',
                        'topicId': 'expo-materials',
                        'title': '本地进场夜班经验分享',
                        'excerpt': '当前草稿摘要',
                        'state': 'ready_to_publish',
                        'updatedAt': '2026-03-27T09:00:00Z',
                        'attachmentRefs': <Object?>[],
                      },
                    ],
                  },
                );
              },
            },
      ),
    ),
  );
}

void main() {
  testWidgets(
    'exhibition home reads province project recommendations from cloud list and refreshes in place',
    (WidgetTester tester) async {
      var requestCount = 0;
      final homeClient = FakeExhibitionHomeAggregationClient();
      final locationService = FakeDeviceLocationService();
      final consumer = ExhibitionConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/project/list': (AppApiRequest request) async {
                    requestCount += 1;
                    final title = requestCount == 1
                        ? '重庆春季展台项目'
                        : '重庆春季展台项目（刷新）';
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: <String, Object?>{
                        'items': <Object?>[
                          <String, Object?>{
                            'projectId': 'project-$requestCount',
                            'projectNo': 'PROJ-$requestCount',
                            'title': title,
                            'buildingType': 'exhibition',
                            'budgetAmount': 188000,
                            'state': 'published',
                            'summary': <String, Object?>{
                              'heading': 'project-$requestCount',
                            },
                          },
                        ],
                      },
                    );
                  },
                },
          ),
        ),
      );

      await tester.pumpWidget(
        _buildApp(
          initialRoute: '/',
          exhibitionConsumerLayer: consumer,
          exhibitionHomeAggregationClient: homeClient,
          forumConsumerLayer: _forumConsumer(),
          deviceLocationService: locationService,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('天气与定位'), findsOneWidget);
      await _scrollTo(tester, find.text('重庆春季展台项目'));
      expect(find.text('当前位置项目推荐'), findsOneWidget);
      expect(find.text('重庆春季展台项目'), findsOneWidget);
      expect(find.byTooltip('发布项目入口'), findsOneWidget);
      expect(find.byTooltip('回到顶部'), findsOneWidget);
      expect(requestCount, 1);
      expect(homeClient.loadCount, 1);
      expect(homeClient.refreshCount, 0);
      expect(locationService.requestCount, 1);

      await tester.tap(find.widgetWithText(OutlinedButton, '刷新首页'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(requestCount, 2);
      expect(homeClient.refreshCount, 1);
      expect(locationService.requestCount, 2);
      await _scrollTo(tester, find.text('重庆春季展台项目（刷新）'));
      expect(find.text('重庆春季展台项目（刷新）'), findsOneWidget);
      expect(find.text('查看全部项目展示'), findsOneWidget);
    },
  );

  testWidgets(
    'exhibition home keeps controlled failure state when project recommendation request fails',
    (WidgetTester tester) async {
      final homeClient = FakeExhibitionHomeAggregationClient();
      final consumer = ExhibitionConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/project/list': (AppApiRequest request) async {
                    throw const SocketException('offline');
                  },
                },
          ),
        ),
      );

      await tester.pumpWidget(
        _buildApp(
          initialRoute: '/',
          exhibitionConsumerLayer: consumer,
          exhibitionHomeAggregationClient: homeClient,
          forumConsumerLayer: _forumConsumer(),
        ),
      );
      await tester.pumpAndSettle();

      await _scrollTo(tester, find.text('当前位置项目推荐暂时没有刷新成功'));
      expect(find.text('当前位置项目推荐暂时没有刷新成功'), findsOneWidget);
      expect(find.textContaining('当前不会用本地演示项目替代云端推荐'), findsOneWidget);
      expect(find.text('重庆春季展台项目'), findsNothing);
      expect(find.widgetWithText(FilledButton, '重试整页刷新'), findsOneWidget);
      expect(homeClient.loadCount, 1);
    },
  );

  testWidgets(
    'exhibition showcase keeps showcase semantics separate from workbench',
    (WidgetTester tester) async {
      final consumer = ExhibitionConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/project/list': (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: <String, Object?>{
                        'items': <Object?>[
                          <String, Object?>{
                            'projectId': 'project-1',
                            'projectNo': 'PROJ-1',
                            'title': '首发项目',
                            'buildingType': 'exhibition',
                            'budgetAmount': 1800,
                            'state': 'published',
                            'summary': <String, Object?>{
                              'heading': 'project-1',
                            },
                          },
                        ],
                      },
                    );
                  },
                },
          ),
        ),
      );

      await tester.pumpWidget(
        _buildApp(
          initialRoute: ExhibitionRoutes.showcase,
          exhibitionConsumerLayer: consumer,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('项目展示'), findsWidgets);
      await _scrollTo(tester, find.text('项目工作台'));
      expect(find.text('项目工作台'), findsWidgets);
      expect(find.text('刷新列表'), findsOneWidget);
      expect(find.text('去创建项目'), findsNothing);
      expect(find.text('公开项目'), findsOneWidget);
      expect(find.textContaining('这里是项目展示正式面'), findsNothing);
      expect(find.textContaining('项目展示 -> 展示详情 -> 按项目状态导流继续竞标'), findsNothing);
      expect(find.text('展示正式面'), findsNothing);
    },
  );

  testWidgets(
    'exhibition workbench renders four private containers and controlled handoff',
    (WidgetTester tester) async {
      final consumer = ExhibitionConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/exhibition/workbench':
                      (AppApiRequest request) async {
                        return AppApiResponse(
                          statusCode: 200,
                          uri: request.uri,
                          body: _workbenchPayload(),
                        );
                      },
                },
          ),
        ),
      );

      await tester.pumpWidget(
        _buildApp(
          exhibitionConsumerLayer: consumer,
          forumConsumerLayer: _forumConsumer(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('展览首页'), findsNothing);
      expect(find.text('私域入口'), findsOneWidget);
      expect(find.text('项目工作台'), findsWidgets);
      await _scrollTo(tester, find.text('project_chain'));
      expect(find.text('project_chain'), findsOneWidget);
      expect(find.text('order_chain'), findsOneWidget);
      expect(find.text('fulfillment_chain'), findsOneWidget);
      expect(find.text('extension_boundary'), findsOneWidget);
      expect(find.text('content'), findsWidgets);
      expect(find.widgetWithText(FilledButton, '创建项目'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '订单详情'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '合同详情'), findsWidgets);
      expect(find.widgetWithText(FilledButton, '里程碑列表'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '里程碑提交'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '验收详情'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '验收提交'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '争议开启'), findsWidgets);

      expect(find.text('继续当前工作'), findsNothing);
      expect(find.text('打开论坛'), findsNothing);
      expect(find.text('打开项目展示'), findsNothing);
      expect(find.widgetWithText(FilledButton, '评价提交'), findsNothing);
      expect(find.widgetWithText(FilledButton, '争议撤回'), findsNothing);
      expect(find.widgetWithText(FilledButton, '验收复检'), findsNothing);
    },
  );

  testWidgets(
    'exhibition workbench shows empty state when continuable carriers are missing',
    (WidgetTester tester) async {
      final consumer = ExhibitionConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/exhibition/workbench':
                      (AppApiRequest request) async {
                        return AppApiResponse(
                          statusCode: 200,
                          uri: request.uri,
                          body: _workbenchPayload(
                            projectChain: <String, Object?>{
                              'hasProjects': false,
                              'recentProjectId': null,
                              'recentProjectTitle': null,
                              'canCreateProject': false,
                              'canOpenProjectPool': false,
                            },
                            orderChain: <String, Object?>{
                              'activeOrderId': null,
                              'activeOrderNo': null,
                              'activeOrderState': null,
                              'canOpenOrderDetail': false,
                              'canOpenContractDetail': false,
                              'canOpenDisputeOpen': false,
                            },
                            fulfillmentChain: <String, Object?>{
                              'activeMilestoneId': null,
                              'activeMilestoneTitle': null,
                              'inspectionState': null,
                              'canOpenMilestoneList': false,
                              'canOpenMilestoneSubmit': false,
                              'canOpenInspectionDetail': false,
                              'canOpenInspectionSubmit': false,
                            },
                            extensionBoundary: <String, Object?>{
                              'canOpenContractDetail': false,
                              'ratingEntryState': 'controlled_unavailable',
                              'canOpenDisputeOpen': false,
                              'disputeWithdrawState': 'frozen',
                            },
                          ),
                        );
                      },
                },
          ),
        ),
      );

      await tester.pumpWidget(
        _buildApp(
          exhibitionConsumerLayer: consumer,
          forumConsumerLayer: _forumConsumer(),
        ),
      );
      await tester.pumpAndSettle();

      await _scrollTo(tester, find.text('project_chain'));
      expect(find.text('project_chain'), findsOneWidget);
      expect(find.text('order_chain'), findsOneWidget);
      expect(find.text('fulfillment_chain'), findsOneWidget);
      expect(find.text('extension_boundary'), findsOneWidget);
      expect(find.text('empty'), findsWidgets);
      expect(find.widgetWithText(FilledButton, '创建项目'), findsNothing);
      expect(find.widgetWithText(FilledButton, '订单详情'), findsNothing);
      expect(find.widgetWithText(FilledButton, '合同详情'), findsNothing);
      expect(find.widgetWithText(FilledButton, '里程碑列表'), findsNothing);
      expect(find.widgetWithText(FilledButton, '里程碑提交'), findsNothing);
      expect(find.widgetWithText(FilledButton, '验收详情'), findsNothing);
      expect(find.widgetWithText(FilledButton, '验收提交'), findsNothing);
      expect(find.widgetWithText(FilledButton, '争议开启'), findsNothing);
    },
  );

  testWidgets(
    'exhibition workbench keeps real error state on network failure',
    (WidgetTester tester) async {
      final consumer = ExhibitionConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/exhibition/workbench':
                      (AppApiRequest request) async {
                        throw SocketException('offline');
                      },
                },
          ),
        ),
      );

      await tester.pumpWidget(
        _buildApp(
          exhibitionConsumerLayer: consumer,
          forumConsumerLayer: _forumConsumer(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('工作台数据：待重试'), findsOneWidget);
      await _scrollTo(tester, find.text('项目工作台暂时没有刷新成功'));
      expect(find.text('项目工作台暂时没有刷新成功'), findsOneWidget);
      expect(find.text('工作台当前先按演示内容承接'), findsNothing);
      await _scrollTo(tester, find.text('project_chain'));
      expect(find.text('controlled_failure'), findsWidgets);
      expect(find.widgetWithText(OutlinedButton, '刷新当前容器'), findsWidgets);
    },
  );

  testWidgets(
    'exhibition workbench falls back to demo source when fake transport misses canonical summary',
    (WidgetTester tester) async {
      final consumer = ExhibitionConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{},
          ),
        ),
      );

      await tester.pumpWidget(
        _buildApp(
          exhibitionConsumerLayer: consumer,
          forumConsumerLayer: _forumConsumer(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('工作台数据：演示承接'), findsOneWidget);
      await _scrollTo(tester, find.text('工作台当前先按演示内容承接'));
      expect(find.text('工作台当前先按演示内容承接'), findsOneWidget);
      await _scrollTo(tester, find.text('project_chain'));
      expect(find.text('project_chain'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '创建项目'), findsOneWidget);
      expect(find.text('content'), findsWidgets);
      expect(find.text('empty'), findsWidgets);
    },
  );
}
