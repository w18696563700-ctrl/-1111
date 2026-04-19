import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/location/device_location_service.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/exhibition_home_aggregation_client.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/forum_consumer_layer.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/messages/data/messages_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_consumer_layer.dart';
import 'package:mobile/shell/shell_app.dart';

import 'support/exhibition_home_test_doubles.dart';

ExhibitionMobileApp _buildApp({
  required ExhibitionConsumerLayer exhibitionConsumerLayer,
  ForumConsumerLayer? forumConsumerLayer,
  ExhibitionHomeAggregationClient? exhibitionHomeAggregationClient,
  DeviceLocationService? deviceLocationService,
  String initialRoute = '/',
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

ExhibitionConsumerLayer _projectListConsumer({
  List<Object?> items = const <Object?>[],
}) {
  return ExhibitionConsumerLayer(
    client: AppApiClient(
      config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
      transport: FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/project/list': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{'items': items},
                );
              },
            },
      ),
    ),
  );
}

void main() {
  tearDown(() {
    EnterpriseHubConsumerLayer.reset();
  });

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
    'exhibition home renders real company factory recommendation items from aggregation section',
    (WidgetTester tester) async {
      final homeClient = FakeExhibitionHomeAggregationClient(
        onLoad: (_) => contentHomeResult(
          recommendationSections: const <Object?>[
            <String, Object?>{
              'sectionKey': 'company_factory_recommendations',
              'items': <Object?>[
                <String, Object?>{
                  'itemType': 'factory',
                  'entityId': 'bf5ff83a-26e7-4138-8157-042fb38a5f46',
                  'title': '重庆坤特工厂样本',
                  'summary': '展台制作与木作工厂样本',
                  'badgeLabel': '优秀工厂',
                },
              ],
            },
          ],
        ),
      );

      await tester.pumpWidget(
        _buildApp(
          initialRoute: '/',
          exhibitionConsumerLayer: _projectListConsumer(),
          exhibitionHomeAggregationClient: homeClient,
          forumConsumerLayer: _forumConsumer(),
        ),
      );
      await tester.pumpAndSettle();

      await _scrollTo(tester, find.text('重庆坤特工厂样本'));
      expect(find.text('3. 本省优秀公司与工厂'), findsOneWidget);
      expect(find.text('重庆坤特工厂样本'), findsOneWidget);
      expect(find.text('展台制作与木作工厂样本'), findsOneWidget);
      expect(find.text('优秀工厂'), findsOneWidget);
      expect(find.text('公司与工厂推荐位持续完善中，当前先提供模块入口说明。'), findsNothing);
    },
  );

  testWidgets(
    'exhibition home automatic location handoff carries province scope into default home load',
    (WidgetTester tester) async {
      final homeClient = FakeExhibitionHomeAggregationClient(
        onLoad: (locationContext) {
          final hasProvinceScope =
              locationContext?.provinceCode == '500000' &&
              locationContext?.provinceName == '重庆市';
          return contentHomeResult(
            provinceName: locationContext?.provinceName ?? '重庆市',
            recommendationSections: <Object?>[
              <String, Object?>{
                'sectionKey': 'company_factory_recommendations',
                'items': hasProvinceScope
                    ? <Object?>[
                        const <String, Object?>{
                          'itemType': 'factory',
                          'entityId': 'bf5ff83a-26e7-4138-8157-042fb38a5f46',
                          'title': '重庆坤特工厂样本',
                          'summary': '展台制作与木作工厂样本',
                          'badgeLabel': '优秀工厂',
                        },
                      ]
                    : <Object?>[],
              },
            ],
          );
        },
      );
      final locationService = FakeDeviceLocationService(
        resolver: () => const DeviceLocationSnapshot(
          permissionState: DeviceLocationPermissionState.granted,
          latitude: 29.5630,
          longitude: 106.5516,
          provinceCode: '500000',
          provinceName: '重庆市',
        ),
      );

      await tester.pumpWidget(
        _buildApp(
          initialRoute: '/',
          exhibitionConsumerLayer: _projectListConsumer(),
          exhibitionHomeAggregationClient: homeClient,
          forumConsumerLayer: _forumConsumer(),
          deviceLocationService: locationService,
        ),
      );
      await tester.pumpAndSettle();

      expect(homeClient.lastLoadLocationContext?.provinceCode, '500000');
      expect(homeClient.lastLoadLocationContext?.provinceName, '重庆市');
      await _scrollTo(tester, find.text('重庆坤特工厂样本'));
      expect(find.text('重庆坤特工厂样本'), findsOneWidget);
      expect(find.text('公司与工厂推荐位持续完善中，当前先提供模块入口说明。'), findsNothing);
    },
  );

  testWidgets(
    'exhibition home keeps controlled placeholder when company factory recommendation items are empty',
    (WidgetTester tester) async {
      final homeClient = FakeExhibitionHomeAggregationClient(
        onLoad: (_) => contentHomeResult(
          recommendationSections: const <Object?>[
            <String, Object?>{
              'sectionKey': 'company_factory_recommendations',
              'items': <Object?>[],
            },
          ],
        ),
      );

      await tester.pumpWidget(
        _buildApp(
          initialRoute: '/',
          exhibitionConsumerLayer: _projectListConsumer(),
          exhibitionHomeAggregationClient: homeClient,
          forumConsumerLayer: _forumConsumer(),
        ),
      );
      await tester.pumpAndSettle();

      await _scrollTo(tester, find.text('3. 本省优秀公司与工厂'));
      expect(find.text('3. 本省优秀公司与工厂'), findsOneWidget);
      expect(find.text('公司与工厂推荐位持续完善中，当前先提供模块入口说明。'), findsOneWidget);
      expect(find.text('重庆坤特工厂样本'), findsNothing);
    },
  );

  testWidgets(
    'exhibition home keeps controlled placeholder when automatic location has no province scope',
    (WidgetTester tester) async {
      final homeClient = FakeExhibitionHomeAggregationClient(
        onLoad: (locationContext) => contentHomeResult(
          recommendationSections: const <Object?>[
            <String, Object?>{
              'sectionKey': 'company_factory_recommendations',
              'items': <Object?>[],
            },
          ],
        ),
      );
      final locationService = FakeDeviceLocationService(
        resolver: () => const DeviceLocationSnapshot(
          permissionState: DeviceLocationPermissionState.granted,
          latitude: 29.5630,
          longitude: 106.5516,
        ),
      );

      await tester.pumpWidget(
        _buildApp(
          initialRoute: '/',
          exhibitionConsumerLayer: _projectListConsumer(),
          exhibitionHomeAggregationClient: homeClient,
          forumConsumerLayer: _forumConsumer(),
          deviceLocationService: locationService,
        ),
      );
      await tester.pumpAndSettle();

      expect(homeClient.lastLoadLocationContext?.provinceCode, isNull);
      expect(homeClient.lastLoadLocationContext?.provinceName, isNull);
      await _scrollTo(tester, find.text('3. 本省优秀公司与工厂'));
      expect(find.text('公司与工厂推荐位持续完善中，当前先提供模块入口说明。'), findsOneWidget);
      expect(find.text('重庆坤特工厂样本'), findsNothing);
    },
  );

  testWidgets(
    'exhibition home company factory recommendation item opens existing enterprise detail route',
    (WidgetTester tester) async {
      EnterpriseHubConsumerLayer.install(
        EnterpriseHubConsumerLayer(
          client: AppApiClient(
            transport: FakeAppApiTransport(
              handlers:
                  <
                    String,
                    Future<AppApiResponse> Function(AppApiRequest request)
                  >{
                    'GET /api/app/exhibition/enterprise-hub/enterprises/bf5ff83a-26e7-4138-8157-042fb38a5f46':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: const <String, Object?>{
                              'header': <String, Object?>{
                                'enterpriseId':
                                    'bf5ff83a-26e7-4138-8157-042fb38a5f46',
                                'name': '重庆坤特工厂样本',
                                'primaryBoardType': 'factory',
                                'shortIntro': '展台制作与木作工厂样本',
                                'provinceName': '重庆',
                                'cityName': '重庆',
                              },
                              'basicInfo': <String, Object?>{
                                'fullIntro': '工厂详情已接通',
                              },
                              'boardProfile': <String, Object?>{
                                'factoryName': '重庆坤特工厂样本',
                              },
                              'serviceAreas': <Object?>[],
                              'cases': <Object?>[],
                              'certifications': <Object?>[],
                              'contacts': <Object?>[],
                            },
                          );
                        },
                  },
            ),
          ),
        ),
      );
      final homeClient = FakeExhibitionHomeAggregationClient(
        onLoad: (_) => contentHomeResult(
          recommendationSections: const <Object?>[
            <String, Object?>{
              'sectionKey': 'company_factory_recommendations',
              'items': <Object?>[
                <String, Object?>{
                  'itemType': 'factory',
                  'entityId': 'bf5ff83a-26e7-4138-8157-042fb38a5f46',
                  'title': '重庆坤特工厂样本',
                  'summary': '展台制作与木作工厂样本',
                  'badgeLabel': '优秀工厂',
                },
              ],
            },
          ],
        ),
      );

      await tester.pumpWidget(
        _buildApp(
          initialRoute: '/',
          exhibitionConsumerLayer: _projectListConsumer(),
          exhibitionHomeAggregationClient: homeClient,
          forumConsumerLayer: _forumConsumer(),
        ),
      );
      await tester.pumpAndSettle();

      await _scrollTo(tester, find.text('重庆坤特工厂样本'));
      await tester.tap(find.widgetWithText(FilledButton, '查看工厂详情'));
      await tester.pumpAndSettle();

      expect(find.text('header'), findsNothing);
      expect(find.text('重庆坤特工厂样本'), findsWidgets);
      expect(find.text('工厂详情已接通'), findsOneWidget);
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
      expect(find.text('发布项目工作台'), findsNothing);
      expect(find.text('筛选条件'), findsNothing);
      expect(find.text('城市'), findsWidgets);
      expect(find.text('面积'), findsWidgets);
      expect(find.text('金额'), findsWidgets);
      expect(find.text('跟随城市'), findsWidgets);
      expect(find.text('不限面积'), findsWidgets);
      expect(find.text('不限金额'), findsWidgets);
      expect(find.text('刷新当前结果'), findsNothing);
      expect(find.text('恢复默认筛选'), findsNothing);
      expect(find.text('去创建项目'), findsNothing);
      expect(find.textContaining('这里是项目展示正式面'), findsNothing);
      expect(find.textContaining('项目展示 -> 展示详情 -> 按项目状态导流继续竞标'), findsNothing);
      expect(find.text('展示正式面'), findsNothing);
    },
  );
}
