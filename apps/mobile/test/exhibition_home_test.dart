import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/location/china_region_catalog.dart';
import 'package:mobile/core/location/device_location_service.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/exhibition_home_aggregation_client.dart';
import 'package:mobile/features/exhibition/data/exhibition_home_location_context_store.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/forum_consumer_layer.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/messages/data/messages_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_consumer_layer.dart';
import 'package:mobile/shell/shell_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    scrollable: find
        .byWidgetPredicate(
          (Widget widget) =>
              widget is Scrollable &&
              widget.axisDirection == AxisDirection.down,
        )
        .first,
  );
  await tester.pumpAndSettle();
}

Future<void> _selectHomeTab(WidgetTester tester, String tabName) async {
  final finder = find.byKey(ValueKey<String>('home-tab-$tabName'));
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

ForumConsumerLayer _forumConsumer() {
  return ForumConsumerLayer(
    client: AppApiClient(
      config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
      transport: FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/forum/feed': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'items': <Object?>[
                      <String, Object?>{
                        'postId': 'post-1',
                        'topicId': 'expo-materials',
                        'topicLabel': '展台材料分享',
                        'title': '重庆进场材料怎么提前锁仓',
                        'excerpt': '最近一轮西洽会项目里，先锁仓再排车明显更稳。',
                        'state': 'published',
                        'author': <String, Object?>{
                          'authorId': 'member-1',
                          'displayName': '赵工',
                          'organizationName': '重庆布展组',
                        },
                        'engagement': <String, Object?>{
                          'replyCount': 8,
                          'likeCount': 12,
                          'viewCount': 45,
                        },
                        'publishedAt': '2026-03-27T09:30:00Z',
                        'viewerHasLiked': false,
                        'viewerHasBookmarked': false,
                        'viewerFollowsTopic': false,
                      },
                    ],
                    'page': <String, Object?>{
                      'nextCursor': null,
                      'hasMore': false,
                    },
                  },
                );
              },
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

Map<String, Object?> _enterpriseItem({
  required String enterpriseId,
  required String boardType,
  required String name,
  String provinceCode = '500000',
  String provinceName = '重庆市',
  String cityCode = '500100',
  String cityName = '重庆市',
  String primaryBoardLabel = '优选展示',
  String shortIntro = '当前样本已接入公开展示。',
}) {
  return <String, Object?>{
    'enterpriseId': enterpriseId,
    'boardType': boardType,
    'name': name,
    'provinceCode': provinceCode,
    'provinceName': provinceName,
    'cityCode': cityCode,
    'cityName': cityName,
    'primaryBoardLabel': primaryBoardLabel,
    'secondaryCapabilityLabels': <Object?>['展陈', '搭建'],
    'shortIntro': shortIntro,
    'certificationLabel': '已认证',
    'caseCount': 6,
    'avgScore': 4.8,
    'keywordTags': <Object?>['本地'],
    'boardHighlights': <String, Object?>{},
  };
}

void _installEnterpriseHubConsumer({
  bool companyFeaturedEmpty = false,
  bool supplierFeaturedEmpty = false,
}) {
  EnterpriseHubConsumerLayer.install(
    EnterpriseHubConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'GET /api/app/exhibition/enterprise-hub/company/enterprises':
                    (AppApiRequest request) async {
                      final isProvinceScoped =
                          request.uri.queryParameters['provinceCode'] ==
                          '500000';
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: <String, Object?>{
                          'recommended': <Object?>[],
                          'items': <Object?>[
                            _enterpriseItem(
                              enterpriseId: 'company-1',
                              boardType: 'company',
                              name: isProvinceScoped ? '重庆展陈公司样本' : '全国展陈公司样本',
                              primaryBoardLabel: '公司展示',
                            ),
                          ],
                          'pagination': <String, Object?>{
                            'page': 1,
                            'pageSize': 10,
                            'total': 1,
                            'hasMore': false,
                          },
                        },
                      );
                    },
                'GET /api/app/exhibition/enterprise-hub/company/recommendations':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: <String, Object?>{
                          'boardType': 'company',
                          'items': companyFeaturedEmpty
                              ? const <Object?>[]
                              : <Object?>[
                                  _enterpriseItem(
                                    enterpriseId: 'company-r1',
                                    boardType: 'company',
                                    name: '公司优选样本',
                                    primaryBoardLabel: '优选公司',
                                  ),
                                ],
                        },
                      );
                    },
                'GET /api/app/exhibition/enterprise-hub/factory/enterprises':
                    (AppApiRequest request) async {
                      final isProvinceScoped =
                          request.uri.queryParameters['provinceCode'] ==
                          '500000';
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: <String, Object?>{
                          'recommended': <Object?>[],
                          'items': <Object?>[
                            _enterpriseItem(
                              enterpriseId: 'factory-1',
                              boardType: 'factory',
                              name: isProvinceScoped ? '重庆坤特工厂样本' : '全国工厂样本',
                              primaryBoardLabel: '工厂展示',
                              shortIntro: '展台制作与木作工厂样本',
                            ),
                          ],
                          'pagination': <String, Object?>{
                            'page': 1,
                            'pageSize': 10,
                            'total': 1,
                            'hasMore': false,
                          },
                        },
                      );
                    },
                'GET /api/app/exhibition/enterprise-hub/factory/recommendations':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: <String, Object?>{
                          'boardType': 'factory',
                          'items': <Object?>[
                            _enterpriseItem(
                              enterpriseId: 'factory-r1',
                              boardType: 'factory',
                              name: '工厂优选样本',
                              primaryBoardLabel: '优选工厂',
                            ),
                          ],
                        },
                      );
                    },
                'GET /api/app/exhibition/enterprise-hub/supplier/enterprises':
                    (AppApiRequest request) async {
                      final isProvinceScoped =
                          request.uri.queryParameters['provinceCode'] ==
                          '500000';
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: <String, Object?>{
                          'recommended': <Object?>[],
                          'items': <Object?>[
                            _enterpriseItem(
                              enterpriseId: 'supplier-1',
                              boardType: 'supplier',
                              name: isProvinceScoped ? '重庆供应商样本' : '全国供应商样本',
                              primaryBoardLabel: '供应商展示',
                            ),
                          ],
                          'pagination': <String, Object?>{
                            'page': 1,
                            'pageSize': 10,
                            'total': 1,
                            'hasMore': false,
                          },
                        },
                      );
                    },
                'GET /api/app/exhibition/enterprise-hub/supplier/recommendations':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: <String, Object?>{
                          'boardType': 'supplier',
                          'items': supplierFeaturedEmpty
                              ? const <Object?>[]
                              : <Object?>[
                                  _enterpriseItem(
                                    enterpriseId: 'supplier-r1',
                                    boardType: 'supplier',
                                    name: '供应商优选样本',
                                    primaryBoardLabel: '优选供应商',
                                  ),
                                ],
                        },
                      );
                    },
              },
        ),
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

void _installMinimalRegionCatalog() {
  ChinaRegionCatalogLoader.installLoadOverrideForTest(() async {
    return ChinaRegionCatalog(
      provinces: const <ChinaProvinceOption>[
        ChinaProvinceOption(
          provinceCode: '500000',
          provinceName: '重庆市',
          cities: <ChinaCityOption>[],
        ),
        ChinaProvinceOption(
          provinceCode: '510000',
          provinceName: '四川省',
          cities: <ChinaCityOption>[],
        ),
      ],
    );
  });
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    ChinaRegionCatalogLoader.reset();
    ExhibitionHomeLocationContextStore.reset();
    _installEnterpriseHubConsumer();
  });

  tearDown(() {
    EnterpriseHubConsumerLayer.reset();
    ChinaRegionCatalogLoader.reset();
    ExhibitionHomeLocationContextStore.reset();
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
                          for (var index = 0; index < 3; index++)
                            <String, Object?>{
                              'projectId': 'project-$requestCount-$index',
                              'projectNo': 'PROJ-$requestCount-$index',
                              'title': index == 0 ? title : '$title-$index',
                              'buildingType': 'exhibition',
                              'budgetAmount': 188000 + index * 10000,
                              'areaSqm': 150 + index * 50,
                              'cityName': '重庆市',
                              'plannedStartAt': '2026-05-${16 + index}',
                              'publishedAt': index == 0
                                  ? '2026-04-30T08:15:00'
                                  : '2026-04-30T09:0$index:00',
                              'state': 'published',
                              'summary': <String, Object?>{
                                'heading': 'project-$requestCount-$index',
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

      expect(find.text('发现优质项目，把握商机'), findsOneWidget);
      await _scrollTo(tester, find.text('重庆春季展台项目'));
      expect(find.text('重庆春季展台项目'), findsOneWidget);
      expect(find.text('发布 4月30日 08:15'), findsOneWidget);
      expect(find.text('示意图'), findsNWidgets(3));
      expect(find.text('会展'), findsNWidgets(3));
      final plusExampleImages = find.byWidgetPredicate((Widget widget) {
        if (widget is! Image || widget.image is! AssetImage) {
          return false;
        }
        final assetImage = widget.image as AssetImage;
        return assetImage.assetName ==
            'assets/exhibition/project_examples/area_108_plus.png';
      });
      expect(plusExampleImages, findsNWidgets(3));
      final coverLabelTop = tester.getTopLeft(find.text('示意图').first).dy;
      final titleTop = tester.getTopLeft(find.text('重庆春季展台项目')).dy;
      expect(coverLabelTop, greaterThan(titleTop));
      expect(find.widgetWithText(TextButton, '去发布项目'), findsOneWidget);
      expect(find.byTooltip('回到顶部'), findsOneWidget);
      expect(requestCount, 1);
      expect(homeClient.loadCount, 1);
      expect(homeClient.refreshCount, 0);
      expect(locationService.requestCount, 1);

      await _scrollTo(tester, find.widgetWithText(TextButton, '刷新'));
      await tester.tap(find.widgetWithText(TextButton, '刷新'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(requestCount, 2);
      expect(homeClient.refreshCount, 1);
      expect(locationService.requestCount, 2);
      await _scrollTo(tester, find.text('重庆春季展台项目（刷新）'));
      expect(find.text('重庆春季展台项目（刷新）'), findsOneWidget);
      expect(find.text('进入项目列表'), findsOneWidget);
    },
  );

  testWidgets('exhibition home switches unified module deck content by tab', (
    WidgetTester tester,
  ) async {
    final homeClient = FakeExhibitionHomeAggregationClient(
      onLoad: (_) => contentHomeResult(),
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

    expect(
      find.byKey(const ValueKey<String>('home-tab-project')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('home-tab-forum')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('home-tab-company')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('home-tab-factory')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('home-tab-supplier')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey<String>('home-tab-team')), findsOneWidget);
    expect(find.widgetWithText(TextButton, '去发布项目'), findsOneWidget);

    await _selectHomeTab(tester, 'forum');

    expect(find.text('打开论坛'), findsOneWidget);
    expect(find.text('重庆进场材料怎么提前锁仓'), findsOneWidget);
    expect(find.text('去发布项目'), findsNothing);
  });

  testWidgets(
    'exhibition home preserves visited tab state when switching back',
    (WidgetTester tester) async {
      final homeClient = FakeExhibitionHomeAggregationClient(
        onLoad: (_) => contentHomeResult(),
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

      await tester.tap(find.text('本省').first);
      await tester.pumpAndSettle();
      expect(find.text('当前还没拿到本省定位'), findsOneWidget);

      await _selectHomeTab(tester, 'forum');
      expect(find.text('重庆进场材料怎么提前锁仓'), findsOneWidget);

      await _selectHomeTab(tester, 'project');
      expect(find.text('当前还没拿到本省定位'), findsOneWidget);
      expect(find.text('重新定位并刷新'), findsWidgets);
    },
  );

  testWidgets(
    'exhibition home factory tab renders truthful list items from enterprise surface',
    (WidgetTester tester) async {
      final homeClient = FakeExhibitionHomeAggregationClient(
        onLoad: (_) => contentHomeResult(),
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

      await _selectHomeTab(tester, 'factory');
      await _scrollTo(tester, find.text('全国工厂样本'));
      expect(find.text('全国工厂样本'), findsOneWidget);
      expect(find.text('展台制作与木作工厂样本'), findsOneWidget);
      expect(find.text('工厂展示'), findsWidgets);
      expect(find.widgetWithText(FilledButton, '进入工厂列表'), findsOneWidget);
    },
  );

  testWidgets(
    'exhibition home automatic location handoff enables truthful province filter on factory channel',
    (WidgetTester tester) async {
      final homeClient = FakeExhibitionHomeAggregationClient(
        onLoad: (locationContext) => contentHomeResult(
          provinceName: locationContext?.provinceName ?? '重庆市',
        ),
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
      await _selectHomeTab(tester, 'factory');
      await tester.tap(find.text('本省').last);
      await tester.pumpAndSettle();
      await _scrollTo(tester, find.text('重庆坤特工厂样本'));
      expect(find.text('重庆坤特工厂样本'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '进入工厂列表'), findsOneWidget);
    },
  );

  testWidgets(
    'exhibition home company channel switches between comprehensive and featured sources',
    (WidgetTester tester) async {
      final homeClient = FakeExhibitionHomeAggregationClient(
        onLoad: (_) => contentHomeResult(),
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

      await _selectHomeTab(tester, 'company');
      expect(find.text('全国展陈公司样本'), findsOneWidget);
      await tester.tap(find.text('优选').last);
      await tester.pumpAndSettle();
      expect(find.text('进入公司列表'), findsOneWidget);
      expect(find.text('公司优选样本'), findsOneWidget);
    },
  );

  testWidgets(
    'exhibition home keeps controlled province notice when factory channel has no province scope',
    (WidgetTester tester) async {
      final homeClient = FakeExhibitionHomeAggregationClient(
        onLoad: (locationContext) => contentHomeResult(
          displayName: '当前地区',
          provinceName: '当前地区',
          provinceCode: null,
          latitude: null,
          longitude: null,
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
      await _selectHomeTab(tester, 'factory');
      await tester.tap(find.text('本省').last);
      await tester.pumpAndSettle();
      expect(find.text('当前还没拿到本省定位'), findsOneWidget);
      expect(find.text('重庆坤特工厂样本'), findsNothing);
    },
  );

  testWidgets(
    'exhibition home backfills province code from home location name for province project filter',
    (WidgetTester tester) async {
      _installMinimalRegionCatalog();
      final provinceRequests = <String?>[];
      final homeClient = FakeExhibitionHomeAggregationClient(
        onLoad: (_) => contentHomeResult(
          displayName: '重庆渝中',
          provinceName: '重庆',
          provinceCode: null,
          cityName: '重庆',
          latitude: 29.563,
          longitude: 106.5516,
        ),
      );
      final locationService = FakeDeviceLocationService(
        resolver: () => const DeviceLocationSnapshot(
          permissionState: DeviceLocationPermissionState.granted,
          latitude: 29.563,
          longitude: 106.5516,
        ),
      );
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
                    final provinceCode =
                        request.uri.queryParameters['provinceCode'];
                    provinceRequests.add(provinceCode);
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: <String, Object?>{
                        'items': <Object?>[
                          <String, Object?>{
                            'projectId': provinceCode == '500000'
                                ? 'project-province'
                                : 'project-all',
                            'title': provinceCode == '500000'
                                ? '重庆本省项目'
                                : '综合项目',
                            'buildingType': 'exhibition',
                            'budgetAmount': 180000,
                            'areaSqm': 220,
                            'provinceCode': provinceCode,
                            'cityName': '重庆市',
                            'plannedStartAt': '2026-05-18',
                            'state': 'published',
                            'summary': const <String, Object?>{},
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

      await tester.drag(
        find
            .byWidgetPredicate(
              (Widget widget) =>
                  widget is Scrollable &&
                  widget.axisDirection == AxisDirection.down,
            )
            .first,
        const Offset(0, -180),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('本省').last);
      await tester.pumpAndSettle();

      expect(provinceRequests, contains('500000'));
      expect(find.text('当前还没拿到本省定位'), findsNothing);
    },
  );

  testWidgets(
    'exhibition home province empty relocate button retries device location',
    (WidgetTester tester) async {
      _installMinimalRegionCatalog();
      var resolveCount = 0;
      final provinceRequests = <String?>[];
      final homeClient = FakeExhibitionHomeAggregationClient(
        onLoad: (locationContext) => contentHomeResult(
          displayName: locationContext?.provinceName ?? '当前地区',
          provinceName: locationContext?.provinceName ?? '当前地区',
          provinceCode: locationContext?.provinceCode,
          latitude: locationContext?.latitude,
          longitude: locationContext?.longitude,
        ),
        onRefresh: (locationContext) => contentHomeResult(
          displayName: locationContext?.provinceName ?? '当前地区',
          provinceName: locationContext?.provinceName ?? '当前地区',
          provinceCode: locationContext?.provinceCode,
          latitude: locationContext?.latitude,
          longitude: locationContext?.longitude,
        ),
      );
      final locationService = FakeDeviceLocationService(
        resolver: () {
          resolveCount += 1;
          if (resolveCount == 1) {
            return const DeviceLocationSnapshot(
              permissionState: DeviceLocationPermissionState.unavailable,
            );
          }
          return const DeviceLocationSnapshot(
            permissionState: DeviceLocationPermissionState.granted,
            latitude: 29.563,
            longitude: 106.5516,
            provinceCode: '500000',
            provinceName: '重庆市',
          );
        },
      );
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
                    final provinceCode =
                        request.uri.queryParameters['provinceCode'];
                    provinceRequests.add(provinceCode);
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: <String, Object?>{
                        'items': <Object?>[
                          if (provinceCode == '500000')
                            <String, Object?>{
                              'projectId': 'project-province',
                              'title': '重庆本省项目',
                              'buildingType': 'exhibition',
                              'budgetAmount': 180000,
                              'areaSqm': 220,
                              'provinceCode': '500000',
                              'cityName': '重庆市',
                              'plannedStartAt': '2026-05-18',
                              'state': 'published',
                              'summary': const <String, Object?>{},
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

      await tester.drag(
        find
            .byWidgetPredicate(
              (Widget widget) =>
                  widget is Scrollable &&
                  widget.axisDirection == AxisDirection.down,
            )
            .first,
        const Offset(0, -180),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('本省').last);
      await tester.pumpAndSettle();
      expect(find.text('当前还没拿到本省定位'), findsOneWidget);

      final relocateButton = find.text('重新定位并刷新').last;
      await tester.ensureVisible(relocateButton);
      await tester.pumpAndSettle();
      await tester.tap(relocateButton);
      await tester.pumpAndSettle();

      expect(resolveCount, 2);
      expect(homeClient.refreshCount, 1);
      expect(provinceRequests, contains('500000'));
    },
  );

  testWidgets(
    'exhibition home factory channel uses clean card with whole-card detail entry',
    (WidgetTester tester) async {
      final homeClient = FakeExhibitionHomeAggregationClient(
        onLoad: (_) => contentHomeResult(),
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

      await _selectHomeTab(tester, 'factory');
      await tester.tap(find.text('优选').last);
      await tester.pumpAndSettle();
      await _scrollTo(tester, find.text('工厂优选样本'));
      expect(find.text('查看工厂详情'), findsNothing);
      await tester.tap(find.text('工厂优选样本'));
      await tester.pumpAndSettle();
      expect(find.text('工厂优选样本'), findsWidgets);
    },
  );

  testWidgets(
    'exhibition home supplier and team channels stay actionable without fake content',
    (WidgetTester tester) async {
      final homeClient = FakeExhibitionHomeAggregationClient(
        onLoad: (_) => contentHomeResult(),
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

      await _selectHomeTab(tester, 'supplier');
      expect(find.text('进入供应商列表'), findsOneWidget);
      expect(find.text('全国供应商样本'), findsOneWidget);
      expect(find.text('优选'), findsOneWidget);

      await _selectHomeTab(tester, 'team');
      expect(find.text('查看说明'), findsWidgets);
      expect(find.text('敬请期待'), findsOneWidget);
      expect(find.text('团队频道保持受控建设态'), findsOneWidget);
    },
  );

  testWidgets(
    'exhibition home hides featured filter when company and supplier recommendations are empty',
    (WidgetTester tester) async {
      _installEnterpriseHubConsumer(
        companyFeaturedEmpty: true,
        supplierFeaturedEmpty: true,
      );
      final homeClient = FakeExhibitionHomeAggregationClient(
        onLoad: (_) => contentHomeResult(),
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

      await _selectHomeTab(tester, 'company');
      expect(find.text('进入公司列表'), findsOneWidget);
      expect(find.text('全国展陈公司样本'), findsOneWidget);
      expect(find.text('优选'), findsNothing);

      await _selectHomeTab(tester, 'supplier');
      expect(find.text('进入供应商列表'), findsOneWidget);
      expect(find.text('全国供应商样本'), findsOneWidget);
      expect(find.text('优选'), findsNothing);

      await _selectHomeTab(tester, 'factory');
      expect(find.text('优选'), findsOneWidget);
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

      await _scrollTo(tester, find.text('当前项目推荐暂时没有刷新成功'));
      expect(find.text('当前项目推荐暂时没有刷新成功'), findsOneWidget);
      expect(find.textContaining('当前不会用本地演示项目替代云端推荐'), findsOneWidget);
      expect(find.text('重庆春季展台项目'), findsNothing);
      expect(find.widgetWithText(OutlinedButton, '刷新当前频道'), findsOneWidget);
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
