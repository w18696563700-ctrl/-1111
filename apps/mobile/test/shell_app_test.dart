import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/boot/app_bootstrap_controller.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/core/boot/app_shell_context_consumer.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/auth/auth_consumer_layer.dart';
import 'package:mobile/core/config/config_manifest.dart';
import 'package:mobile/core/location/device_location_service.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/exhibition_home_aggregation_client.dart';
import 'package:mobile/features/exhibition/data/forum_consumer_layer.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/exhibition/presentation/exhibition_trade_pages.dart';
import 'package:mobile/features/messages/data/messages_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_identity_consumer_layer.dart';
import 'package:mobile/features/profile/navigation/profile_identity_routes.dart';
import 'package:mobile/shell/navigation/app_building.dart';
import 'package:mobile/shell/shell_app.dart';

import 'support/exhibition_home_test_doubles.dart';

Map<String, Object?> _summary([String heading = 'summary']) {
  return <String, Object?>{'heading': heading};
}

Map<String, Object?> _projectPayload({
  required String projectId,
  String projectNo = 'PROJ-1',
  String title = '展览项目',
  String buildingType = 'exhibition',
  num budgetAmount = 1000,
  String state = 'published',
  String summaryHeading = 'project',
  num? areaSqm,
  String? buildingTypeRemark,
  String? description,
  String? provinceCode,
  String? provinceName,
  String? cityCode,
  String? cityName,
  String? districtCode,
  String? districtName,
  String? detailAddress,
  String? scopeSummary,
  String? plannedStartAt,
  String? plannedEndAt,
  String? scheduleDetail,
}) {
  return <String, Object?>{
    'projectId': projectId,
    'projectNo': projectNo,
    'title': title,
    'buildingType': buildingType,
    'budgetAmount': budgetAmount,
    if (areaSqm case final num value) 'areaSqm': value,
    if (buildingTypeRemark case final String value) 'buildingTypeRemark': value,
    if (description case final String value) 'description': value,
    if (provinceCode case final String value) 'provinceCode': value,
    if (provinceName case final String value) 'provinceName': value,
    if (cityCode case final String value) 'cityCode': value,
    if (cityName case final String value) 'cityName': value,
    if (districtCode case final String value) 'districtCode': value,
    if (districtName case final String value) 'districtName': value,
    if (detailAddress case final String value) 'detailAddress': value,
    if (scopeSummary case final String value) 'scopeSummary': value,
    if (plannedStartAt case final String value) 'plannedStartAt': value,
    if (plannedEndAt case final String value) 'plannedEndAt': value,
    if (scheduleDetail case final String value) 'scheduleDetail': value,
    'state': state,
    'summary': _summary(summaryHeading),
  };
}

Map<String, Object?> _orderPayload({
  required String orderId,
  required String projectId,
  required String bidId,
  String orderNo = 'ORD-1',
  String state = 'active',
  String summaryHeading = 'order',
  List<Object?> milestones = const <Object?>[],
}) {
  return <String, Object?>{
    'orderId': orderId,
    'orderNo': orderNo,
    'projectId': projectId,
    'bidId': bidId,
    'state': state,
    'summary': _summary(summaryHeading),
    'milestones': milestones,
  };
}

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
          'hasProjects': false,
          'recentProjectId': null,
          'recentProjectTitle': null,
          'canCreateProject': true,
          'canOpenProjectPool': true,
        },
    'order_chain':
        orderChain ??
        <String, Object?>{
          'activeOrderId': null,
          'activeOrderNo': null,
          'activeOrderState': null,
          'canOpenOrderDetail': false,
          'canOpenContractDetail': false,
          'canOpenDisputeOpen': false,
        },
    'fulfillment_chain':
        fulfillmentChain ??
        <String, Object?>{
          'activeMilestoneId': null,
          'activeMilestoneTitle': null,
          'inspectionState': null,
          'canOpenMilestoneList': false,
          'canOpenMilestoneSubmit': false,
          'canOpenInspectionDetail': false,
          'canOpenInspectionSubmit': false,
        },
    'extension_boundary':
        extensionBoundary ??
        <String, Object?>{
          'canOpenContractDetail': false,
          'ratingEntryState': 'controlled_unavailable',
          'canOpenDisputeOpen': false,
          'disputeWithdrawState': 'frozen',
        },
  };
}

Map<String, Object?> _shellContextPayload({
  String userId = 'user-1',
  String? organizationId = 'org-1',
  List<String> roleKeys = const <String>[],
  String? certificationStatus,
  String? membershipStatus,
  List<String> visibleBuildings = const <String>[
    'exhibition',
    'messages',
    'profile',
  ],
  String featureFlagsVersion = 'ffv-20260328',
  Map<String, Object?> unreadSummary = const <String, Object?>{},
}) {
  return <String, Object?>{
    'userId': userId,
    'organizationId': organizationId,
    'roleKeys': roleKeys,
    'certificationStatus': certificationStatus,
    'membershipStatus': membershipStatus,
    'visibleBuildings': visibleBuildings,
    'featureFlagsVersion': featureFlagsVersion,
    'unreadSummary': unreadSummary,
  };
}

Future<void> _scrollAndTap(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder, warnIfMissed: false);
  await tester.pump();
  await tester.pumpAndSettle();
}

Finder _projectCreateField(String label) {
  final key = switch (label) {
    '项目名称' => 'project-create-title',
    '项目类型' => 'project-create-building-type',
    '类型备注（选填）' => 'project-create-building-type-remark',
    '预算金额' => 'project-create-budget-amount',
    '项目面积' => 'project-create-area-sqm',
    '省' => 'project-create-province',
    '市' => 'project-create-city',
    '区/县' => 'project-create-district',
    '详细地址' => 'project-create-detail-address',
    '范围说明' => 'project-create-scope-summary',
    '计划开始日期' => 'project-create-planned-start-at',
    '计划结束日期' => 'project-create-planned-end-at',
    '详细时间（选填）' => 'project-create-schedule-detail',
    '补充说明' => 'project-create-description',
    _ => throw ArgumentError('Unknown project create field: $label'),
  };
  return find.byKey(ValueKey<String>(key));
}

Future<void> _selectProjectType(
  WidgetTester tester, {
  String option = '会展',
}) async {
  await _scrollAndTap(tester, _projectCreateField('项目类型'));
  await _scrollAndTap(tester, find.text(option));
}

Future<void> _selectStandardizedProjectLocation(
  WidgetTester tester, {
  String location = '四川 / 成都',
  String? district = '武侯区',
}) async {
  await _scrollAndTap(tester, _projectCreateField('省'));
  await _scrollAndTap(tester, find.text(location));
  if (district == null) {
    return;
  }
  await _scrollAndTap(tester, _projectCreateField('区/县'));
  await _scrollAndTap(tester, find.text(district));
}

Map<String, Object?> _projectCreateAddressRangeBody({
  String title = '展览项目',
  String buildingType = 'exhibition',
  double budgetAmount = 1000,
  double? areaSqm,
  String? buildingTypeRemark,
  String provinceCode = '510000',
  String provinceName = '四川',
  String cityCode = '510100',
  String cityName = '成都',
  String? districtCode = '510107',
  String? districtName = '武侯区',
  String detailAddress = '世纪城新国际会展中心 6 号馆西门',
  String scopeSummary = '主舞台、医疗器械展区与灯光联动区进场搭建',
  String? plannedStartAt = '2026-04-10',
  String? plannedEndAt = '2026-04-18',
  String? scheduleDetail,
  String? description,
}) {
  return <String, Object?>{
    'title': title,
    'buildingType': buildingType,
    'budgetAmount': budgetAmount,
    if (areaSqm case final double value) 'areaSqm': value,
    if (buildingTypeRemark case final String value) 'buildingTypeRemark': value,
    'provinceCode': provinceCode,
    'provinceName': provinceName,
    'cityCode': cityCode,
    'cityName': cityName,
    if (districtCode case final String value) 'districtCode': value,
    if (districtName case final String value) 'districtName': value,
    'detailAddress': detailAddress,
    'scopeSummary': scopeSummary,
    if (plannedStartAt case final String value) 'plannedStartAt': value,
    if (plannedEndAt case final String value) 'plannedEndAt': value,
    if (scheduleDetail case final String value) 'scheduleDetail': value,
    if (description case final String value) 'description': value,
  };
}

Future<void> _fillProjectCreateAddressRangeForm(
  WidgetTester tester, {
  String location = '四川 / 成都',
  String? districtName = '武侯区',
  String detailAddress = '世纪城新国际会展中心 6 号馆西门',
  String scopeSummary = '主舞台、医疗器械展区与灯光联动区进场搭建',
  String plannedStartAt = '2026-04-10',
  String plannedEndAt = '2026-04-18',
}) async {
  await tester.drag(find.byType(Scrollable).first, const Offset(0, 1200));
  await tester.pumpAndSettle();

  Future<void> enterVisible(Finder finder, String value) async {
    await tester.scrollUntilVisible(
      finder,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.enterText(finder, value);
    await tester.pump();
  }

  await _selectStandardizedProjectLocation(
    tester,
    location: location,
    district: districtName,
  );
  await enterVisible(_projectCreateField('详细地址'), detailAddress);
  await enterVisible(_projectCreateField('范围说明'), scopeSummary);
  await enterVisible(_projectCreateField('计划开始日期'), plannedStartAt);
  await enterVisible(_projectCreateField('计划结束日期'), plannedEndAt);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    ProjectAttachmentDebugOverrides.reset();
    AppApiConfig.resetRuntimeBaseUrlOverride();
  });
  tearDown(() {
    ProjectAttachmentDebugOverrides.reset();
    AppApiConfig.resetRuntimeBaseUrlOverride();
  });

  Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
  defaultHandlers() {
    return <String, Future<AppApiResponse> Function(AppApiRequest request)>{
      'GET /api/app/exhibition/workbench': (AppApiRequest request) async {
        return AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: _workbenchPayload(),
        );
      },
      'GET /api/app/project/list': (AppApiRequest request) async {
        return AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: <String, Object?>{'items': <Object?>[]},
        );
      },
    };
  }

  ExhibitionMobileApp buildApp({
    String initialRoute = '/',
    AppConfigManifest? bootstrapManifest,
    AppShellContextData? bootstrapShellContext,
    AppShellContextConsumer? shellContextConsumer,
    FakeAppApiTransport? transport,
    FakeAppApiTransport? forumTransport,
    FakeAppApiTransport? messagesTransport,
    FakeAppApiTransport? profileTransport,
    AuthConsumerLayer? authConsumerLayer,
    ProfileIdentityConsumerLayer? profileIdentityConsumerLayer,
    ExhibitionHomeAggregationClient? exhibitionHomeAggregationClient,
    DeviceLocationService? deviceLocationService,
    AppSessionStore? sessionStore,
  }) {
    final exhibitionTransport =
        transport ?? FakeAppApiTransport(handlers: defaultHandlers());
    final resolvedMessagesTransport =
        messagesTransport ??
        FakeAppApiTransport(
          handlers:
              <
                String,
                Future<AppApiResponse> Function(AppApiRequest request)
              >{},
        );
    final resolvedForumTransport =
        forumTransport ??
        FakeAppApiTransport(
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
                'GET /api/app/forum/me/posts': (AppApiRequest request) async {
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
                'GET /api/app/forum/me/comments':
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
                'GET /api/app/forum/me/bookmarks':
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
                'GET /api/app/forum/me/follows': (AppApiRequest request) async {
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
                'GET /api/app/forum/draft/list': (AppApiRequest request) async {
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
    final resolvedProfileTransport =
        profileTransport ??
        FakeAppApiTransport(
          handlers:
              <
                String,
                Future<AppApiResponse> Function(AppApiRequest request)
              >{},
        );

    return ExhibitionMobileApp(
      initialRoute: initialRoute,
      bootstrapManifest: bootstrapManifest,
      bootstrapShellContext: bootstrapShellContext,
      shellContextConsumer: shellContextConsumer,
      exhibitionConsumerLayer: ExhibitionConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: exhibitionTransport,
        ),
      ),
      exhibitionHomeAggregationClient:
          exhibitionHomeAggregationClient ??
          FakeExhibitionHomeAggregationClient(),
      forumConsumerLayer: ForumConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: resolvedForumTransport,
        ),
      ),
      messagesConsumerLayer: MessagesConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: resolvedMessagesTransport,
        ),
      ),
      profileConsumerLayer: ProfileConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: resolvedProfileTransport,
        ),
      ),
      authConsumerLayer: authConsumerLayer,
      profileIdentityConsumerLayer: profileIdentityConsumerLayer,
      deviceLocationService:
          deviceLocationService ?? FakeDeviceLocationService(),
      sessionStore: sessionStore,
    );
  }

  AppShellContextConsumer buildShellContextConsumer({
    Duration requestTimeout = const Duration(milliseconds: 300),
    String userId = 'user-1',
    String? organizationId = 'org-1',
    List<String> roleKeys = const <String>[],
    String? certificationStatus,
    String? membershipStatus,
    List<String> visibleBuildings = const <String>[
      'exhibition',
      'messages',
      'profile',
    ],
  }) {
    return AppShellContextConsumer(
      client: AppApiClient(
        config: AppApiConfig(
          baseUrl: 'http://127.0.0.1:8080/api/app',
          requestTimeout: requestTimeout,
        ),
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'GET /api/app/shell/context': (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: _shellContextPayload(
                      userId: userId,
                      organizationId: organizationId,
                      roleKeys: roleKeys,
                      certificationStatus: certificationStatus,
                      membershipStatus: membershipStatus,
                      visibleBuildings: visibleBuildings,
                    ),
                  );
                },
              },
        ),
      ),
    );
  }

  Future<void> expectNoDefaultTechnicalDisclosure(
    WidgetTester tester, {
    required ExhibitionMobileApp app,
    required String pageTitle,
    List<String> visibleTexts = const <String>[],
  }) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    expect(find.textContaining(pageTitle, findRichText: true), findsWidgets);
    final scrollable = find.byType(Scrollable).first;
    for (final text in visibleTexts) {
      final finder = find.textContaining(text, findRichText: true);
      if (finder.evaluate().isEmpty) {
        await tester.scrollUntilVisible(finder, 200, scrollable: scrollable);
        await tester.pumpAndSettle();
      }
      expect(finder, findsWidgets);
    }
    expect(find.textContaining('当前连接信息（次级）'), findsNothing);
    expect(find.textContaining('协议承接信息（次级）'), findsNothing);
    expect(find.textContaining('payload snapshot'), findsNothing);
    expect(find.textContaining('route context'), findsNothing);
    expect(find.textContaining('page state:'), findsNothing);
    expect(find.textContaining('BFF base URL'), findsNothing);
  }

  Future<void> tapBottomDestination(WidgetTester tester, String label) async {
    final navigationBar = find.byType(NavigationBar);
    final labelFinder = find.descendant(
      of: navigationBar,
      matching: find.text(label),
    );
    await tester.tap(labelFinder.last);
    await tester.pump();
    await tester.pumpAndSettle();
  }

  NavigatorState rootNavigator(WidgetTester tester) {
    return tester.state<NavigatorState>(find.byType(Navigator).first);
  }

  Future<void> pushNamedRoute(WidgetTester tester, String routeName) async {
    rootNavigator(tester).pushNamed(routeName);
    await tester.pump();
    await tester.pumpAndSettle();
  }

  Future<void> popRoute(WidgetTester tester) async {
    rootNavigator(tester).pop();
    await tester.pump();
    await tester.pumpAndSettle();
  }

  AppSessionStore buildAuthenticatedSessionStore({
    String accessToken = 'test-access-token',
    String refreshToken = 'test-refresh-token',
    String deviceId = 'test-device-id',
  }) {
    final store = AppSessionStore();
    store.establishSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresInSeconds: 3600,
      deviceId: deviceId,
    );
    return store;
  }

  testWidgets(
    'shell context timeout falls back to bootstrap defaults and leaves booting',
    (WidgetTester tester) async {
      final hangingCompleter = Completer<AppApiResponse>();
      final shellContextConsumer = AppShellContextConsumer(
        client: AppApiClient(
          config: AppApiConfig(
            baseUrl: 'http://127.0.0.1:8080/api/app',
            requestTimeout: const Duration(milliseconds: 100),
          ),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/shell/context': (AppApiRequest request) {
                    return hangingCompleter.future;
                  },
                },
          ),
        ),
      );

      await tester.pumpWidget(
        buildApp(shellContextConsumer: shellContextConsumer),
      );
      await tester.pump();

      expect(find.text('Shell 启动中').evaluate().length <= 1, isTrue);

      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text('Shell 启动中'), findsNothing);

      final navigationBar = find.byType(NavigationBar);
      expect(
        find.descendant(of: navigationBar, matching: find.text('展览')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: navigationBar, matching: find.text('消息')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: navigationBar, matching: find.text('我的')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'unauthenticated users can view exhibition public home while other buildings stay guarded',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          shellContextConsumer: buildShellContextConsumer(),
          sessionStore: AppSessionStore(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('天气与定位'), findsOneWidget);
      expect(find.text('尚未登录'), findsNothing);

      await tapBottomDestination(tester, '消息');
      expect(find.text('尚未登录'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '进入登录入口'), findsOneWidget);

      await tapBottomDestination(tester, '我的');
      expect(find.text('尚未登录'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '进入登录入口'), findsOneWidget);
      expect(find.text('创建组织入口'), findsNothing);
      expect(find.text('加入组织入口'), findsNothing);
      expect(find.text('查看认证状态'), findsNothing);

      await tapBottomDestination(tester, '展览');
      expect(find.text('天气与定位'), findsOneWidget);
    },
  );

  testWidgets(
    'unauthenticated exhibition private actions stay tappable on compact desktop viewport and route to login entry',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1280, 720);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildApp(
          shellContextConsumer: buildShellContextConsumer(),
          sessionStore: AppSessionStore(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey<String>('home-private-entry-workbench')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey<String>('home-private-entry-workbench')),
      );
      await tester.pumpAndSettle();

      expect(find.text('登录入口'), findsWidgets);
      expect(find.text('验证码登录承接'), findsOneWidget);

      await popRoute(tester);

      await tester.tap(
        find.byKey(const ValueKey<String>('home-private-entry-publish')),
      );
      await tester.pumpAndSettle();

      expect(find.text('登录入口'), findsWidgets);
      expect(find.text('验证码登录承接'), findsOneWidget);
    },
  );

  testWidgets(
    'login entry stays public-facing and hides test credential shortcut',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          initialRoute: ProfileIdentityRoutes.login,
          shellContextConsumer: buildShellContextConsumer(
            userId: 'user-dev',
            organizationId: 'org-dev',
          ),
          sessionStore: AppSessionStore(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('测试通道直接进入'), findsNothing);
      expect(find.text('开发态测试通道'), findsNothing);
      expect(find.textContaining('不会调用 OTP send/login'), findsNothing);
      expect(find.text('填入联调测试账号'), findsNothing);
      expect(find.text('发送验证码'), findsOneWidget);
      expect(find.text('验证码登录 / 注册'), findsOneWidget);
      expect(find.widgetWithText(TextButton, '用户协议'), findsOneWidget);
      expect(find.widgetWithText(TextButton, '隐私政策'), findsOneWidget);
      expect(find.text('请输入可接收验证码的手机号'), findsOneWidget);
      expect(find.text('当前仍只承接手机号 + 验证码登录，不扩到其他登录方式或第二条认证路径。'), findsOneWidget);
      expect(find.textContaining('未注册手机号首次验证通过后会自动创建账号'), findsWidgets);
      expect(find.text('Apple'), findsNothing);
      expect(find.text('微信'), findsNothing);
      expect(find.text('一键登录'), findsNothing);
      expect(find.text('password login'), findsNothing);
      expect(AppSessionStore.instance.hasAnySession, isFalse);
      expect(
        AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app').effectiveBaseUrl,
        'http://127.0.0.1:8080/api/app',
      );
    },
  );

  testWidgets('login entry user agreement page renders markdown document', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        initialRoute: ProfileIdentityRoutes.userAgreement,
        shellContextConsumer: buildShellContextConsumer(),
        sessionStore: AppSessionStore(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('用户协议'), findsWidgets);
    expect(find.text('展览装修之家用户协议'), findsOneWidget);
    expect(find.textContaining('当前展示的是仓库内法务草案正文'), findsOneWidget);
  });

  testWidgets('login entry privacy policy page renders markdown document', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        initialRoute: ProfileIdentityRoutes.privacyPolicy,
        shellContextConsumer: buildShellContextConsumer(),
        sessionStore: AppSessionStore(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('隐私政策'), findsWidgets);
    expect(find.text('展览装修之家隐私政策'), findsOneWidget);
    expect(find.textContaining('当前展示的是仓库内法务草案正文'), findsOneWidget);
  });

  test('bootstrap shell context defaults follow manifest visibility flags', () {
    final manifest = AppConfigManifest.bootstrapDefaults()
        .copyWithFlag(ConfigFlagKeys.buildingMessagesVisible, false)
        .copyWithFlag(ConfigFlagKeys.buildingProfileVisible, false);

    final shellContext = AppShellContextData.bootstrapDefaults(
      manifest: manifest,
    );

    expect(shellContext.visibleBuildings, const <String>['exhibition']);
  });

  test('no-organization shell still allows exhibition building', () {
    final controller = AppBootstrapController(
      bootstrapManifest: AppConfigManifest.bootstrapDefaults(),
      bootstrapShellContext: AppShellContextData(
        userId: 'user-1',
        organizationId: null,
        visibleBuildings: const <String>['exhibition', 'messages', 'profile'],
      ),
    );

    controller.applyShellContext(
      AppShellContextData(
        userId: 'user-1',
        organizationId: null,
        visibleBuildings: const <String>['exhibition', 'messages', 'profile'],
      ),
    );

    expect(controller.guardBuilding(AppBuilding.exhibition), isNull);
    expect(
      controller.guardBuilding(AppBuilding.profile),
      GlobalShellState.noOrganization,
    );
  });

  testWidgets('first release bottom navigation only shows three buildings', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    final navigationBar = find.byType(NavigationBar);

    expect(
      find.descendant(of: navigationBar, matching: find.text('展览')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: navigationBar, matching: find.text('消息')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: navigationBar, matching: find.text('我的')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: navigationBar, matching: find.text('装修')),
      findsNothing,
    );
    expect(
      find.descendant(of: navigationBar, matching: find.text('全屋定制')),
      findsNothing,
    );
  });

  testWidgets('exhibition root presents a clean weather shell home', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    final scrollable = find.byType(Scrollable).first;

    expect(find.text('天气与定位'), findsOneWidget);
    expect(find.text('秩序化首页'), findsNothing);
    expect(find.text('展览首页'), findsNothing);
    expect(find.text('当前定位：重庆'), findsNothing);
    expect(find.text('当前环境：联调环境'), findsNothing);
    expect(find.text('地区识别中'), findsWidgets);
    expect(find.byTooltip('发布项目入口'), findsOneWidget);
    expect(find.byTooltip('回到顶部'), findsOneWidget);
    expect(find.byTooltip('整页刷新'), findsOneWidget);
    expect(find.text('手动选择地区'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('优秀团队员工'),
      200,
      scrollable: scrollable,
    );
    await tester.pumpAndSettle();
    expect(find.text('项目展示'), findsOneWidget);
    expect(find.text('优秀公司'), findsOneWidget);
    expect(find.text('优秀工厂'), findsOneWidget);
    expect(find.text('优秀供应商'), findsOneWidget);
    expect(find.text('展览论坛'), findsOneWidget);
    expect(find.text('优秀团队员工'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('进入项目工作台'),
      200,
      scrollable: scrollable,
    );
    await tester.pumpAndSettle();
    expect(find.text('进入项目工作台'), findsOneWidget);
    expect(find.text('发布项目'), findsOneWidget);
    expect(find.text('当前进度'), findsNothing);
    expect(find.text('继续当前工作'), findsNothing);
    expect(find.text('创建项目'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('本省推荐'),
      200,
      scrollable: scrollable,
    );
    await tester.pumpAndSettle();
    expect(find.text('本省推荐'), findsOneWidget);
    expect(find.text('1. 本省搭建项目'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.textContaining('首页现在改成天气卡壳层、六模块入口、本省推荐和私域导流的干净首页'),
      200,
      scrollable: scrollable,
    );
    await tester.pumpAndSettle();
    expect(
      find.textContaining('首页现在改成天气卡壳层、六模块入口、本省推荐和私域导流的干净首页'),
      findsOneWidget,
    );
    expect(find.textContaining('BFF base URL'), findsNothing);
    expect(find.textContaining('开发工作面'), findsNothing);
  });

  testWidgets(
    'shell no longer exposes environment banner on non-home buildings',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          initialRoute: AppBuilding.messages.routePath,
          messagesTransport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/message/index': (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{'items': <Object?>[]},
                    );
                  },
                },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('当前环境：联调环境'), findsNothing);
      expect(find.textContaining('127.0.0.1'), findsNothing);
      expect(find.textContaining('/api/app'), findsNothing);
    },
  );

  testWidgets('messages building can be hidden by manifest and stays guarded', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        initialRoute: AppBuilding.messages.routePath,
        bootstrapManifest: AppConfigManifest.bootstrapDefaults().copyWithFlag(
          ConfigFlagKeys.buildingMessagesVisible,
          false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final navigationBar = find.byType(NavigationBar);
    expect(
      find.descendant(of: navigationBar, matching: find.text('展览')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: navigationBar, matching: find.text('我的')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: navigationBar, matching: find.text('消息')),
      findsNothing,
    );
    expect(find.text('消息入口当前不可见'), findsOneWidget);
    expect(find.textContaining('首发阶段暂未开放到当前主路径'), findsWidgets);
    expect(find.text('回到展览'), findsWidgets);
  });

  testWidgets('profile building can be hidden by manifest and stays guarded', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        initialRoute: AppBuilding.profile.routePath,
        bootstrapManifest: AppConfigManifest.bootstrapDefaults().copyWithFlag(
          ConfigFlagKeys.buildingProfileVisible,
          false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final navigationBar = find.byType(NavigationBar);
    expect(
      find.descendant(of: navigationBar, matching: find.text('展览')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: navigationBar, matching: find.text('消息')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: navigationBar, matching: find.text('我的')),
      findsNothing,
    );
    expect(find.text('我的入口当前不可见'), findsOneWidget);
    expect(find.textContaining('首发阶段暂未开放到当前主路径'), findsWidgets);
    expect(find.text('回到展览'), findsWidgets);
  });

  testWidgets(
    'messages building shows controlled unreadSummary badge from shell context',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          bootstrapShellContext: AppShellContextData(
            visibleBuildings: const <String>[
              'exhibition',
              'messages',
              'profile',
            ],
            unreadSummary: <String, Object?>{
              'instanceTodo': 4,
              'profileNotice': 3,
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      final navigationBar = find.byType(NavigationBar);
      expect(
        find.descendant(of: navigationBar, matching: find.text('7')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: navigationBar, matching: find.text('消息')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'messages tab refreshes inbox when returning from another building',
    (WidgetTester tester) async {
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
              'GET /api/app/forum/me/posts': (AppApiRequest request) async =>
                  AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'items': <Object?>[],
                      'page': <String, Object?>{
                        'nextCursor': null,
                        'hasMore': false,
                      },
                    },
                  ),
              'GET /api/app/forum/me/comments': (AppApiRequest request) async =>
                  AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'items': <Object?>[],
                      'page': <String, Object?>{
                        'nextCursor': null,
                        'hasMore': false,
                      },
                    },
                  ),
              'GET /api/app/forum/me/bookmarks':
                  (AppApiRequest request) async => AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'items': <Object?>[],
                      'page': <String, Object?>{
                        'nextCursor': null,
                        'hasMore': false,
                      },
                    },
                  ),
              'GET /api/app/forum/me/follows': (AppApiRequest request) async =>
                  AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'items': <Object?>[],
                      'page': <String, Object?>{
                        'nextCursor': null,
                        'hasMore': false,
                      },
                    },
                  ),
              'GET /api/app/forum/draft/list': (AppApiRequest request) async =>
                  AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'items': <Object?>[],
                      'page': <String, Object?>{
                        'nextCursor': null,
                        'hasMore': false,
                      },
                    },
                  ),
            },
      );
      final profileTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/index': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'organization': <String, Object?>{
                      'organizationId': 'org-1',
                      'roleKeys': <Object?>[],
                      'visibleBuildings': <Object?>[
                        'exhibition',
                        'messages',
                        'profile',
                      ],
                    },
                    'certification': <String, Object?>{'status': 'verified'},
                    'membership': <String, Object?>{'status': 'active'},
                    'settingsEntry': <String, Object?>{'state': 'visible'},
                  },
                );
              },
            },
      );

      await tester.pumpWidget(
        buildApp(
          forumTransport: forumTransport,
          profileTransport: profileTransport,
        ),
      );
      await tester.pumpAndSettle();

      expect(forumTransport.requests, isEmpty);
      expect(profileTransport.requests, isEmpty);

      await tapBottomDestination(tester, '消息');
      expect(
        forumTransport.requests
            .where(
              (AppApiRequest request) =>
                  request.canonicalPath == ForumCanonicalPaths.interactionInbox,
            )
            .length,
        1,
      );

      await tapBottomDestination(tester, '我的');
      expect(
        profileTransport.requests
            .where(
              (AppApiRequest request) =>
                  request.canonicalPath == ProfileCanonicalPaths.profileIndex,
            )
            .length,
        1,
      );

      await tapBottomDestination(tester, '消息');
      expect(
        forumTransport.requests
            .where(
              (AppApiRequest request) =>
                  request.canonicalPath == ForumCanonicalPaths.interactionInbox,
            )
            .length,
        2,
      );
    },
  );

  testWidgets(
    'profile tab keeps its first loaded page alive across tab switches',
    (WidgetTester tester) async {
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
              'GET /api/app/forum/me/posts': (AppApiRequest request) async =>
                  AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'items': <Object?>[],
                      'page': <String, Object?>{
                        'nextCursor': null,
                        'hasMore': false,
                      },
                    },
                  ),
              'GET /api/app/forum/me/comments': (AppApiRequest request) async =>
                  AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'items': <Object?>[],
                      'page': <String, Object?>{
                        'nextCursor': null,
                        'hasMore': false,
                      },
                    },
                  ),
              'GET /api/app/forum/me/bookmarks':
                  (AppApiRequest request) async => AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'items': <Object?>[],
                      'page': <String, Object?>{
                        'nextCursor': null,
                        'hasMore': false,
                      },
                    },
                  ),
              'GET /api/app/forum/me/follows': (AppApiRequest request) async =>
                  AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'items': <Object?>[],
                      'page': <String, Object?>{
                        'nextCursor': null,
                        'hasMore': false,
                      },
                    },
                  ),
              'GET /api/app/forum/draft/list': (AppApiRequest request) async =>
                  AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'items': <Object?>[],
                      'page': <String, Object?>{
                        'nextCursor': null,
                        'hasMore': false,
                      },
                    },
                  ),
            },
      );
      final profileTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/index': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'organization': <String, Object?>{
                      'organizationId': 'org-1',
                      'roleKeys': <Object?>['buyer_admin'],
                      'visibleBuildings': <Object?>[
                        'exhibition',
                        'messages',
                        'profile',
                      ],
                    },
                    'certification': <String, Object?>{'status': 'verified'},
                    'membership': <String, Object?>{'status': 'active'},
                    'settingsEntry': <String, Object?>{'state': 'visible'},
                  },
                );
              },
            },
      );

      await tester.pumpWidget(
        buildApp(
          forumTransport: forumTransport,
          profileTransport: profileTransport,
        ),
      );
      await tester.pumpAndSettle();

      await tapBottomDestination(tester, '我的');
      expect(
        profileTransport.requests
            .where(
              (AppApiRequest request) =>
                  request.canonicalPath == ProfileCanonicalPaths.profileIndex,
            )
            .length,
        1,
      );

      await tapBottomDestination(tester, '展览');
      expect(find.text('天气与定位'), findsOneWidget);

      await tapBottomDestination(tester, '我的');
      expect(
        profileTransport.requests
            .where(
              (AppApiRequest request) =>
                  request.canonicalPath == ProfileCanonicalPaths.profileIndex,
            )
            .length,
        1,
      );
    },
  );

  testWidgets('hidden building route stays registered and guarded', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp(initialRoute: '/renovation'));
    await tester.pumpAndSettle();

    expect(find.text('装修入口当前不可见'), findsOneWidget);
    expect(find.text('回到展览'), findsWidgets);

    await tester.tap(find.text('回到展览').first);
    await tester.pumpAndSettle();

    expect(find.text('天气与定位'), findsOneWidget);
  });

  testWidgets(
    'hidden building can render its skeleton when manifest enables it',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          initialRoute: AppBuilding.renovation.routePath,
          bootstrapManifest: AppConfigManifest.bootstrapDefaults().copyWithFlag(
            ConfigFlagKeys.buildingRenovationVisible,
            true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('装修楼预埋骨架'), findsOneWidget);
      expect(find.text('预埋楼层'), findsOneWidget);
    },
  );

  testWidgets('custom furniture route stays registered and guarded', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(initialRoute: AppBuilding.customFurniture.routePath),
    );
    await tester.pumpAndSettle();

    expect(find.text('全屋定制入口当前不可见'), findsOneWidget);
    expect(find.text('回到展览'), findsWidgets);
  });

  testWidgets(
    'custom furniture can render its skeleton when manifest enables it',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          initialRoute: AppBuilding.customFurniture.routePath,
          bootstrapManifest: AppConfigManifest.bootstrapDefaults().copyWithFlag(
            ConfigFlagKeys.buildingCustomFurnitureVisible,
            true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('全屋定制楼预埋骨架'), findsOneWidget);
      expect(find.text('预埋楼层'), findsOneWidget);
    },
  );

  testWidgets('unknown route enters explicit not_found state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp(initialRoute: '/unknown-route'));
    await tester.pumpAndSettle();

    expect(find.text('路由不可用'), findsWidgets);
    expect(find.textContaining('page state'), findsNothing);
    expect(find.textContaining('requested route'), findsNothing);
    expect(find.text('回到展览'), findsWidgets);
    expect(find.textContaining('/unknown-route'), findsNothing);
    expect(find.text('展览入口骨架'), findsNothing);

    await tester.tap(find.text('回到展览').first);
    await tester.pumpAndSettle();

    expect(find.text('天气与定位'), findsOneWidget);
  });

  testWidgets(
    'project list repeated entry reuses session read result without a second GET',
    (WidgetTester tester) async {
      var projectListRequestCount = 0;
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/project/list': (AppApiRequest request) async {
                projectListRequestCount += 1;
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'items': <Object?>[_projectPayload(projectId: 'project-1')],
                  },
                );
              },
            },
      );

      await tester.pumpWidget(buildApp(transport: transport));
      await tester.pumpAndSettle();

      await pushNamedRoute(tester, ExhibitionRoutes.projectList);
      expect(projectListRequestCount, 1);
      expect(find.text('项目列表'), findsWidgets);

      await popRoute(tester);
      await pushNamedRoute(tester, ExhibitionRoutes.projectList);

      expect(projectListRequestCount, 1);
      expect(find.text('项目列表'), findsWidgets);
    },
  );

  testWidgets(
    'project detail repeated entry reuses session read result for the same projectId',
    (WidgetTester tester) async {
      var projectDetailRequestCount = 0;
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/project/detail': (AppApiRequest request) async {
                projectDetailRequestCount += 1;
                expect(request.uri.queryParameters['projectId'], 'project-1');
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _projectPayload(projectId: 'project-1'),
                );
              },
            },
      );

      await tester.pumpWidget(buildApp(transport: transport));
      await tester.pumpAndSettle();

      await pushNamedRoute(
        tester,
        ExhibitionRoutes.projectDetailWithProjectId('project-1'),
      );
      expect(projectDetailRequestCount, 1);

      await popRoute(tester);
      await pushNamedRoute(
        tester,
        ExhibitionRoutes.projectDetailWithProjectId('project-1'),
      );

      expect(projectDetailRequestCount, 1);
      expect(find.text('项目详情'), findsWidgets);
    },
  );

  testWidgets(
    'project detail reload button bypasses cached result and sends a fresh GET',
    (WidgetTester tester) async {
      var projectDetailRequestCount = 0;
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/project/detail': (AppApiRequest request) async {
                projectDetailRequestCount += 1;
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _projectPayload(
                    projectId: 'project-1',
                    projectNo: 'PROJ-$projectDetailRequestCount',
                  ),
                );
              },
            },
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute: ExhibitionRoutes.projectDetailWithProjectId(
            'project-1',
          ),
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      expect(projectDetailRequestCount, 1);
      await tester.scrollUntilVisible(
        find.text('项目编号：PROJ-1'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('项目编号：PROJ-1'), findsOneWidget);

      final reloadButton = find.widgetWithText(FilledButton, '重新加载详情');
      await tester.ensureVisible(reloadButton);
      await tester.pumpAndSettle();
      await tester.tap(reloadButton);
      await tester.pump();
      await tester.pumpAndSettle();

      expect(projectDetailRequestCount, 2);
      await tester.scrollUntilVisible(
        find.text('项目编号：PROJ-2'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('项目编号：PROJ-2'), findsOneWidget);
    },
  );

  testWidgets(
    'order detail repeated entry reuses session read result for the same orderId',
    (WidgetTester tester) async {
      var orderDetailRequestCount = 0;
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/order/detail': (AppApiRequest request) async {
                orderDetailRequestCount += 1;
                expect(request.uri.queryParameters['orderId'], 'order-1');
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _orderPayload(
                    orderId: 'order-1',
                    projectId: 'project-1',
                    bidId: 'bid-1',
                  ),
                );
              },
            },
      );

      await tester.pumpWidget(buildApp(transport: transport));
      await tester.pumpAndSettle();

      await pushNamedRoute(
        tester,
        ExhibitionRoutes.orderDetailWithOrderId('order-1'),
      );
      expect(orderDetailRequestCount, 1);

      await popRoute(tester);
      await pushNamedRoute(
        tester,
        ExhibitionRoutes.orderDetailWithOrderId('order-1'),
      );

      expect(orderDetailRequestCount, 1);
      expect(find.text('订单详情'), findsWidgets);
    },
  );

  testWidgets(
    'milestone list repeated entry reuses session read result for the same orderId',
    (WidgetTester tester) async {
      var milestoneListRequestCount = 0;
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/milestone/list': (AppApiRequest request) async {
                milestoneListRequestCount += 1;
                expect(request.uri.queryParameters['orderId'], 'order-1');
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'items': <Object?>[
                      <String, Object?>{
                        'milestoneId': 'milestone-1',
                        'orderId': 'order-1',
                        'title': 'initial delivery',
                        'amount': 1200,
                        'state': 'pending_submission',
                        'summary': <String, Object?>{'heading': 'initial'},
                      },
                    ],
                  },
                );
              },
            },
      );

      await tester.pumpWidget(buildApp(transport: transport));
      await tester.pumpAndSettle();

      await pushNamedRoute(
        tester,
        ExhibitionRoutes.milestoneListWithOrderId('order-1'),
      );
      expect(milestoneListRequestCount, 1);

      await popRoute(tester);
      await pushNamedRoute(
        tester,
        ExhibitionRoutes.milestoneListWithOrderId('order-1'),
      );

      expect(milestoneListRequestCount, 1);
      expect(find.text('里程碑列表'), findsWidgets);
    },
  );

  testWidgets(
    'contract detail repeated entry reuses session read result for the same orderId',
    (WidgetTester tester) async {
      var contractDetailRequestCount = 0;
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/contract/detail': (AppApiRequest request) async {
                contractDetailRequestCount += 1;
                expect(request.uri.queryParameters['orderId'], 'order-1');
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'contractId': 'contract-1',
                    'orderId': 'order-1',
                    'state': 'pending_confirm',
                    'summary': <String, Object?>{'heading': 'contract'},
                  },
                );
              },
            },
      );

      await tester.pumpWidget(buildApp(transport: transport));
      await tester.pumpAndSettle();

      await pushNamedRoute(
        tester,
        ExhibitionRoutes.contractDetailWithOrderId('order-1'),
      );
      expect(contractDetailRequestCount, 1);

      await popRoute(tester);
      await pushNamedRoute(
        tester,
        ExhibitionRoutes.contractDetailWithOrderId('order-1'),
      );

      expect(contractDetailRequestCount, 1);
      expect(find.text('合同详情'), findsWidgets);
    },
  );

  testWidgets(
    'contract detail reload button bypasses cached result and sends a fresh GET',
    (WidgetTester tester) async {
      var contractDetailRequestCount = 0;
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/contract/detail': (AppApiRequest request) async {
                contractDetailRequestCount += 1;
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'contractId': 'contract-$contractDetailRequestCount',
                    'orderId': 'order-1',
                    'state': 'pending_confirm',
                    'summary': <String, Object?>{
                      'heading': 'contract-$contractDetailRequestCount',
                    },
                  },
                );
              },
            },
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute: ExhibitionRoutes.contractDetailWithOrderId('order-1'),
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      expect(contractDetailRequestCount, 1);
      await tester.scrollUntilVisible(
        find.textContaining('contract-1'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('contract-1'), findsWidgets);

      final reloadButton = find.widgetWithText(FilledButton, '重新读取当前合同');
      await tester.ensureVisible(reloadButton);
      await tester.pumpAndSettle();
      await tester.tap(reloadButton);
      await tester.pump();
      await tester.pumpAndSettle();

      expect(contractDetailRequestCount, 2);
      await tester.scrollUntilVisible(
        find.textContaining('contract-2'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('contract-2'), findsWidgets);
    },
  );

  testWidgets(
    'inspection detail repeated entry reuses session read result for the same milestoneId',
    (WidgetTester tester) async {
      var inspectionDetailRequestCount = 0;
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/inspection/detail': (AppApiRequest request) async {
                inspectionDetailRequestCount += 1;
                expect(
                  request.uri.queryParameters['milestoneId'],
                  'milestone-1',
                );
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'inspectionId': 'inspection-1',
                    'milestoneId': 'milestone-1',
                    'state': 'draft',
                    'summary': <String, Object?>{'heading': 'inspection'},
                  },
                );
              },
            },
      );

      await tester.pumpWidget(buildApp(transport: transport));
      await tester.pumpAndSettle();

      await pushNamedRoute(
        tester,
        ExhibitionRoutes.inspectionDetailWithMilestoneId('milestone-1'),
      );
      expect(inspectionDetailRequestCount, 1);

      await popRoute(tester);
      await pushNamedRoute(
        tester,
        ExhibitionRoutes.inspectionDetailWithMilestoneId('milestone-1'),
      );

      expect(inspectionDetailRequestCount, 1);
      expect(find.text('验收详情'), findsWidgets);
    },
  );

  testWidgets(
    'rating entry repeated entry reuses session read result for the same orderId',
    (WidgetTester tester) async {
      var ratingEntryRequestCount = 0;
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/rating/entry': (AppApiRequest request) async {
                ratingEntryRequestCount += 1;
                expect(request.uri.queryParameters['orderId'], 'order-1');
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'orderId': 'order-1',
                    'state': 'draft',
                    'summary': <String, Object?>{'heading': 'rating'},
                  },
                );
              },
            },
      );

      await tester.pumpWidget(buildApp(transport: transport));
      await tester.pumpAndSettle();

      await pushNamedRoute(
        tester,
        ExhibitionRoutes.ratingEntryWithOrderId('order-1'),
      );
      expect(ratingEntryRequestCount, 1);

      await popRoute(tester);
      await pushNamedRoute(
        tester,
        ExhibitionRoutes.ratingEntryWithOrderId('order-1'),
      );

      expect(ratingEntryRequestCount, 1);
      expect(find.text('评价入口'), findsWidgets);
    },
  );

  testWidgets('canonical path is assembled for project list request', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            ...defaultHandlers(),
            'GET /api/app/project/list': (AppApiRequest request) async {
              expect(
                request.uri.toString(),
                'http://127.0.0.1:8080/api/app/project/list',
              );
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: <String, Object?>{
                  'items': <Object?>[
                    _projectPayload(
                      projectId: 'proj-1',
                      projectNo: 'PROJ-1',
                      title: '展览项目 1',
                    ),
                  ],
                },
              );
            },
          },
    );

    await tester.pumpWidget(
      buildApp(
        initialRoute: ExhibitionRoutes.projectList,
        transport: transport,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('项目列表'), findsWidgets);
    expect(
      transport.requests
          .where(
            (AppApiRequest request) =>
                request.canonicalPath == ExhibitionCanonicalPaths.projectList,
          )
          .length,
      1,
    );
    expect(
      transport.requests
          .where(
            (AppApiRequest request) =>
                request.canonicalPath == ExhibitionCanonicalPaths.projectList,
          )
          .single
          .canonicalPath,
      ExhibitionCanonicalPaths.projectList,
    );
    final projectCount = find.text('当前项目数：1 个', skipOffstage: false);
    await tester.scrollUntilVisible(
      projectCount.first,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('当前项目数：1 个'), findsOneWidget);
    expect(find.text('项目编号：PROJ-1'), findsOneWidget);
    expect(find.text('建筑类型：展览装修'), findsOneWidget);
    expect(find.text('预算金额：¥1000'), findsOneWidget);
  });

  testWidgets(
    'project list card consumes area and standardized province city without leaking detail-only fields',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/project/list': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'items': <Object?>[
                      _projectPayload(
                        projectId: 'proj-showcase-1',
                        projectNo: 'PROJ-SHOWCASE-1',
                        title: '展示对齐项目',
                        buildingType: 'exhibition',
                        budgetAmount: 2200,
                        areaSqm: 350.5,
                        provinceCode: '510000',
                        provinceName: '四川',
                        cityCode: '510100',
                        cityName: '成都',
                        districtCode: '510107',
                        districtName: '武侯区',
                        detailAddress: '世纪城新国际会展中心 6 号馆西门',
                        scopeSummary: '主舞台与医疗器械展区联动搭建',
                        description: '这段补充说明不应进入项目列表卡片',
                        summaryHeading: '展示摘要',
                      ),
                    ],
                  },
                );
              },
            },
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute: ExhibitionRoutes.projectList,
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('项目地点：四川 / 成都'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('项目列表'), findsWidgets);
      expect(find.text('展示摘要'), findsOneWidget);
      expect(find.text('四川 / 成都'), findsWidgets);
      expect(find.text('350.5 ㎡'), findsWidgets);
      expect(find.text('展览装修'), findsWidgets);
      expect(find.text('已发布'), findsWidgets);
      expect(find.text('武侯区'), findsNothing);
      expect(find.textContaining('世纪城新国际会展中心 6 号馆西门'), findsNothing);
      expect(find.textContaining('这段补充说明不应进入项目列表卡片'), findsNothing);
      expect(find.textContaining('scopeSummary'), findsNothing);
      expect(find.textContaining('正式附件'), findsNothing);
      expect(find.text('510000'), findsNothing);
      expect(find.text('510100'), findsNothing);
      expect(find.textContaining('奖励金额'), findsNothing);
      expect(find.textContaining('单位平方面积金额'), findsNothing);
    },
  );

  testWidgets(
    'project detail without projectId enters user-facing recovery state',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/project/detail': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{'id': 'proj-1'},
                );
              },
            },
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute: ExhibitionRoutes.projectDetail,
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      final missingProjectMessage = find.textContaining(
        '当前入口还没有承接到所需项目',
        skipOffstage: false,
      );
      await tester.scrollUntilVisible(
        missingProjectMessage.first,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('当前入口还没有承接到所需项目'), findsOneWidget);
      expect(find.textContaining('route context'), findsNothing);
      expect(find.text('回到项目池'), findsOneWidget);
      expect(
        transport.requests.where(
          (AppApiRequest request) =>
              request.canonicalPath == ExhibitionCanonicalPaths.projectDetail,
        ),
        isEmpty,
      );
      expect(find.widgetWithText(TextField, 'projectId'), findsNothing);

      await tester.tap(find.text('回到项目池').first);
      await tester.pumpAndSettle();

      expect(find.text('项目列表'), findsWidgets);
    },
  );

  testWidgets(
    'order detail network failure stays user-facing and recoverable',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/order/detail': (AppApiRequest request) async {
                throw const SocketException('offline');
              },
            },
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute: '${ExhibitionRoutes.orderDetail}?orderId=order-1',
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      final failureMessage = find.textContaining(
        '当前内容暂时没有成功返回',
        skipOffstage: false,
      );
      await tester.scrollUntilVisible(
        failureMessage,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('当前内容暂时没有成功返回'), findsOneWidget);
      expect(find.textContaining('network error'), findsNothing);
      expect(find.text('回到展览'), findsWidgets);
    },
  );

  testWidgets('contract detail http failure hides raw transport wording', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            ...defaultHandlers(),
            'GET /api/app/contract/detail': (AppApiRequest request) async {
              throw const HttpException('bad gateway');
            },
          },
    );

    await tester.pumpWidget(
      buildApp(
        initialRoute: '${ExhibitionRoutes.contractDetail}?orderId=order-1',
        transport: transport,
      ),
    );
    await tester.pumpAndSettle();

    final failureMessage = find.textContaining(
      '当前内容暂时没有成功返回',
      skipOffstage: false,
    );
    await tester.scrollUntilVisible(
      failureMessage,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('当前内容暂时没有成功返回'), findsOneWidget);
    expect(find.textContaining('http error'), findsNothing);
    expect(find.text('回到展览'), findsWidgets);
  });

  testWidgets('inspection detail decoding failure hides raw decoding wording', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            ...defaultHandlers(),
            'GET /api/app/inspection/detail': (AppApiRequest request) async {
              throw const FormatException('bad payload');
            },
          },
    );

    await tester.pumpWidget(
      buildApp(
        initialRoute:
            '${ExhibitionRoutes.inspectionDetail}?milestoneId=milestone-1',
        transport: transport,
      ),
    );
    await tester.pumpAndSettle();

    final failureMessage = find.textContaining(
      '当前内容暂时没有成功返回',
      skipOffstage: false,
    );
    await tester.scrollUntilVisible(
      failureMessage,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('当前内容暂时没有成功返回'), findsOneWidget);
    expect(find.textContaining('response decoding failed'), findsNothing);
    expect(find.text('回到展览'), findsWidgets);
  });

  testWidgets(
    'project detail consumes shared showcase detail ProjectReadModel fields only',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/project/detail': (AppApiRequest request) async {
                expect(request.uri.queryParameters['projectId'], 'proj-1');
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    ..._projectPayload(
                      projectId: 'proj-1',
                      projectNo: 'PROJ-1',
                      title: '展览项目 1',
                      buildingType: 'exhibition',
                      budgetAmount: 1888,
                      areaSqm: 350.5,
                      buildingTypeRemark: '医疗器械展区特装搭建',
                      provinceCode: '510000',
                      provinceName: '四川',
                      cityCode: '510100',
                      cityName: '成都',
                      districtCode: '510107',
                      districtName: '武侯区',
                      detailAddress: '世纪城新国际会展中心 6 号馆西门',
                      scopeSummary: '主舞台、医疗器械展区与灯光联动区进场搭建',
                      plannedStartAt: '2026-04-10',
                      plannedEndAt: '2026-04-18',
                      scheduleDetail: '4 月 10 日晚进场，4 月 18 日撤场',
                      description: '现场先完成基础施工与设备进场，重点关注主舞台区域。',
                      summaryHeading: 'project',
                    ),
                    'buyerOrganizationId': 'buyer-1',
                    'detailOnlyField': 'should-be-ignored',
                  },
                );
              },
            },
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute: '${ExhibitionRoutes.projectDetail}?projectId=proj-1',
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('项目详情'), findsWidgets);
      expect(find.text('当前项目 ID：proj-1'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('项目编号：PROJ-1'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('项目编号：PROJ-1'), findsOneWidget);
      expect(find.text('项目名称：展览项目 1'), findsOneWidget);
      expect(find.text('建筑类型：展览装修'), findsOneWidget);
      expect(find.text('预算金额：¥1888'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('项目面积：350.5 ㎡'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('项目面积：350.5 ㎡'), findsOneWidget);
      expect(find.text('类型备注：医疗器械展区特装搭建'), findsOneWidget);
      expect(find.text('当前说明：project'), findsOneWidget);
      expect(find.text('省：四川'), findsOneWidget);
      expect(find.text('市：成都'), findsOneWidget);
      expect(find.text('区/县：武侯区'), findsOneWidget);
      expect(find.text('详细地址：世纪城新国际会展中心 6 号馆西门'), findsOneWidget);
      expect(find.text('范围说明：主舞台、医疗器械展区与灯光联动区进场搭建'), findsOneWidget);
      expect(find.text('计划开始日期：2026-04-10'), findsOneWidget);
      expect(find.text('计划结束日期：2026-04-18'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('详细时间：4 月 10 日晚进场，4 月 18 日撤场'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('详细时间：4 月 10 日晚进场，4 月 18 日撤场'), findsOneWidget);
      expect(find.text('510000'), findsNothing);
      expect(find.text('510100'), findsNothing);
      expect(find.text('510107'), findsNothing);
      await tester.scrollUntilVisible(
        find.text('补充说明：现场先完成基础施工与设备进场，重点关注主舞台区域。'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('补充说明：现场先完成基础施工与设备进场，重点关注主舞台区域。'), findsOneWidget);
      expect(find.text('buyer-1'), findsNothing);
      expect(find.text('should-be-ignored'), findsNothing);
      expect(find.widgetWithText(TextField, 'projectId'), findsNothing);
    },
  );

  testWidgets(
    'project detail keeps legacy location names visible when standardized codes are absent',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/project/detail': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _projectPayload(
                    projectId: 'legacy-location-project-1',
                    projectNo: 'PROJ-LEGACY-LOC-1',
                    title: '旧地点项目',
                    provinceName: '四川',
                    cityName: '成都',
                    districtName: '武侯区',
                    detailAddress: '世纪城新国际会展中心 6 号馆西门',
                    budgetAmount: 980,
                  ),
                );
              },
            },
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute:
              '${ExhibitionRoutes.projectDetail}?projectId=legacy-location-project-1',
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('省：四川'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('省：四川'), findsOneWidget);
      expect(find.text('市：成都'), findsOneWidget);
      expect(find.text('区/县：武侯区'), findsOneWidget);
      expect(find.text('详细地址：世纪城新国际会展中心 6 号馆西门'), findsOneWidget);
      expect(find.textContaining('标准地区'), findsNothing);
      expect(find.textContaining('省 code'), findsNothing);
      expect(find.textContaining('区县 code'), findsNothing);
      expect(find.text('510000'), findsNothing);
      expect(find.text('510100'), findsNothing);
      expect(find.text('510107'), findsNothing);
    },
  );

  testWidgets(
    'project detail bid continuation redirects unauthenticated actor to login entry',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/project/detail': (AppApiRequest request) async {
                expect(request.uri.queryParameters['projectId'], 'proj-1');
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _projectPayload(
                    projectId: 'proj-1',
                    projectNo: 'PROJ-1',
                    title: '展览项目 1',
                    buildingType: 'exhibition',
                    budgetAmount: 1888,
                    state: 'published',
                    summaryHeading: 'project',
                  ),
                );
              },
            },
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute: '${ExhibitionRoutes.projectDetail}?projectId=proj-1',
          transport: transport,
          shellContextConsumer: buildShellContextConsumer(),
          sessionStore: AppSessionStore(),
        ),
      );
      await tester.pumpAndSettle();

      await _scrollAndTap(tester, find.widgetWithText(FilledButton, '继续竞标'));
      expect(find.text('登录入口'), findsWidgets);
      expect(find.text('验证码登录承接'), findsOneWidget);
    },
  );

  testWidgets('bid submit blocks unauthenticated actor with login handoff', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        initialRoute: '${ExhibitionRoutes.bidSubmit}?projectId=proj-1',
        shellContextConsumer: buildShellContextConsumer(),
        sessionStore: AppSessionStore(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, '进入登录入口'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '提交投标'), findsNothing);
    await _scrollAndTap(tester, find.widgetWithText(FilledButton, '进入登录入口'));
    expect(find.text('登录入口'), findsWidgets);
  });

  testWidgets(
    'bid submit blocks non-approved certification with controlled handoff',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          initialRoute: '${ExhibitionRoutes.bidSubmit}?projectId=proj-1',
          shellContextConsumer: buildShellContextConsumer(
            organizationId: 'org-1',
            roleKeys: const <String>['supplier_admin'],
            certificationStatus: 'pending',
          ),
          sessionStore: buildAuthenticatedSessionStore(
            deviceId: 'device-bid-cert-pending',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.widgetWithText(FilledButton, '查看认证状态'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '提交投标'), findsNothing);
      await _scrollAndTap(tester, find.widgetWithText(FilledButton, '查看认证状态'));
      expect(find.text('认证状态承接'), findsOneWidget);
    },
  );

  testWidgets('bid submit blocks non-supplier role with controlled handoff', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        initialRoute: '${ExhibitionRoutes.bidSubmit}?projectId=proj-1',
        shellContextConsumer: buildShellContextConsumer(
          organizationId: 'org-1',
          roleKeys: const <String>['buyer_admin'],
          certificationStatus: 'verified',
        ),
        sessionStore: buildAuthenticatedSessionStore(
          deviceId: 'device-bid-role-guard',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, '回到项目工作台'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '提交投标'), findsNothing);
    await _scrollAndTap(tester, find.widgetWithText(FilledButton, '回到项目工作台'));
    expect(find.text('项目工作台'), findsWidgets);
  });

  testWidgets('project create success carries real projectId to detail', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            ...defaultHandlers(),
            'POST /api/app/project/create': (AppApiRequest request) async {
              expect(
                request.body,
                _projectCreateAddressRangeBody(
                  title: '展览项目',
                  detailAddress: '世纪城新国际会展中心 6 号馆西门',
                  scopeSummary: '主舞台、医疗器械展区与灯光联动区进场搭建',
                ),
              );
              return AppApiResponse(
                statusCode: 202,
                uri: request.uri,
                body: <String, Object?>{'projectId': 'proj-123'},
              );
            },
            'GET /api/app/project/detail': (AppApiRequest request) async {
              expect(request.uri.queryParameters['projectId'], 'proj-123');
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _projectPayload(
                  projectId: 'proj-123',
                  projectNo: 'PROJ-123',
                  title: '展览项目',
                  buildingType: 'exhibition',
                  budgetAmount: 1000,
                  provinceName: '四川',
                  cityName: '成都',
                  districtName: '武侯区',
                  detailAddress: '世纪城新国际会展中心 6 号馆西门',
                  scopeSummary: '主舞台、医疗器械展区与灯光联动区进场搭建',
                  plannedStartAt: '2026-04-10',
                  plannedEndAt: '2026-04-18',
                ),
              );
            },
          },
    );

    await tester.pumpWidget(
      buildApp(
        initialRoute: ExhibitionRoutes.projectCreate,
        transport: transport,
        sessionStore: buildAuthenticatedSessionStore(deviceId: 'device-create'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      _projectCreateField('预算金额'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.enterText(_projectCreateField('项目名称'), '展览项目');
    await _selectProjectType(tester, option: '会议');
    await tester.enterText(_projectCreateField('预算金额'), '1000');
    await _fillProjectCreateAddressRangeForm(tester);
    final submitButton = find.widgetWithText(FilledButton, '发布项目');
    await _scrollAndTap(tester, submitButton);
    await tester.scrollUntilVisible(
      find.text('项目创建成功'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('项目创建成功'), findsOneWidget);
    expect(find.text('项目 ID：proj-123'), findsOneWidget);
    expect(find.text('项目名称：展览项目'), findsOneWidget);
    expect(find.text('查看项目列表'), findsOneWidget);
    expect(find.text('继续竞标'), findsNothing);

    final goToDetail = find.widgetWithText(FilledButton, '查看项目详情');
    await _scrollAndTap(tester, goToDetail);

    expect(find.text('项目详情'), findsWidgets);
    expect(find.text('当前项目 ID：proj-123'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('省：四川'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('省：四川'), findsOneWidget);
    expect(find.text('市：成都'), findsOneWidget);
    expect(find.text('区/县：武侯区'), findsOneWidget);
    expect(find.text('详细地址：世纪城新国际会展中心 6 号馆西门'), findsOneWidget);
    expect(find.text('范围说明：主舞台、医疗器械展区与灯光联动区进场搭建'), findsOneWidget);
    expect(find.text('计划开始日期：2026-04-10'), findsOneWidget);
    expect(find.text('计划结束日期：2026-04-18'), findsOneWidget);
    expect(find.textContaining('标准地区'), findsNothing);
    expect(find.textContaining('省 code'), findsNothing);
    expect(find.textContaining('区县 code'), findsNothing);
    expect(find.textContaining('project detail 已回传'), findsNothing);
  });

  testWidgets(
    'project create page surfaces admitted Round B richer fields only',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          initialRoute: ExhibitionRoutes.projectCreate,
          sessionStore: buildAuthenticatedSessionStore(
            deviceId: 'device-create-round-b-fields',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(_projectCreateField('类型备注（选填）'), findsOneWidget);
      expect(_projectCreateField('项目面积'), findsOneWidget);
      await tester.scrollUntilVisible(
        _projectCreateField('详细时间（选填）'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(_projectCreateField('详细时间（选填）'), findsOneWidget);
      expect(find.text('预算区间'), findsNothing);
      expect(find.text('奖励金额'), findsNothing);
    },
  );

  testWidgets(
    'project create success refreshes project list and workbench continuation without stale empty state',
    (WidgetTester tester) async {
      var created = false;

      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/exhibition/workbench':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _workbenchPayload(
                        projectChain: created
                            ? <String, Object?>{
                                'hasProjects': true,
                                'recentProjectId': 'proj-456',
                                'recentProjectTitle': '工作台新项目',
                                'canCreateProject': true,
                                'canOpenProjectPool': true,
                              }
                            : <String, Object?>{
                                'hasProjects': false,
                                'recentProjectId': null,
                                'recentProjectTitle': null,
                                'canCreateProject': true,
                                'canOpenProjectPool': true,
                              },
                      ),
                    );
                  },
              'POST /api/app/project/create': (AppApiRequest request) async {
                created = true;
                return AppApiResponse(
                  statusCode: 202,
                  uri: request.uri,
                  body: const <String, Object?>{'projectId': 'proj-456'},
                );
              },
              'GET /api/app/project/list': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'items': created
                        ? <Object?>[
                            _projectPayload(
                              projectId: 'proj-456',
                              projectNo: 'PROJ-456',
                              title: '工作台新项目',
                              buildingType: 'exhibition',
                              budgetAmount: 1880,
                            ),
                          ]
                        : <Object?>[],
                  },
                );
              },
            },
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute: ExhibitionRoutes.projectCreate,
          transport: transport,
          sessionStore: buildAuthenticatedSessionStore(
            deviceId: 'device-create-refresh',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        _projectCreateField('预算金额'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.enterText(_projectCreateField('项目名称'), '工作台新项目');
      await _selectProjectType(tester);
      await tester.enterText(_projectCreateField('预算金额'), '1880');
      await _fillProjectCreateAddressRangeForm(
        tester,
        detailAddress: '世纪城会展中心 5 号馆南门',
        scopeSummary: '工作台私域项目建档与附件承接',
      );
      await _scrollAndTap(tester, find.widgetWithText(FilledButton, '发布项目'));
      await tester.scrollUntilVisible(
        find.text('项目创建成功'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('项目创建成功'), findsOneWidget);
      expect(find.text('查看项目列表'), findsOneWidget);
      expect(find.text('回到项目工作台'), findsOneWidget);

      await _scrollAndTap(tester, find.text('查看项目列表'));
      expect(find.text('项目列表'), findsWidgets);
      await tester.scrollUntilVisible(
        find.text('当前项目数：1 个'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('当前项目数：1 个'), findsOneWidget);
      expect(find.text('当前还没有项目'), findsNothing);
      expect(find.text('项目编号：PROJ-456'), findsOneWidget);

      await popRoute(tester);
      await _scrollAndTap(tester, find.text('回到项目工作台'));
      expect(find.text('项目工作台'), findsWidgets);
      expect(
        transport.requests
            .where(
              (AppApiRequest request) =>
                  request.canonicalPath ==
                  ExhibitionCanonicalPaths.exhibitionWorkbench,
            )
            .length,
        2,
      );
      expect(
        find.text('project_chain 当前没有 recentProjectId，可从发布入口先进入最小建档。'),
        findsNothing,
      );
      expect(find.textContaining('当前未承接 recentProjectId'), findsNothing);
    },
  );

  testWidgets(
    'project create page reuses upload init-direct-confirm chain after success',
    (WidgetTester tester) async {
      final bytes = utf8.encode('create-page project attachment');
      ProjectAttachmentDebugOverrides.installPicker(
        () async =>
            ProjectAttachmentDraft(fileName: 'create-brief.pdf', bytes: bytes),
      );

      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'POST /api/app/project/create': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 202,
                  uri: request.uri,
                  body: const <String, Object?>{'projectId': 'project-1'},
                );
              },
              'POST /api/app/file/upload/init': (AppApiRequest request) async {
                expect(request.body, <String, Object?>{
                  'businessType': 'project',
                  'businessId': 'project-1',
                  'fileKind': 'evidence',
                  'mimeType': 'application/pdf',
                  'size': bytes.length,
                  'checksum': sha256.convert(bytes).toString(),
                });
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'uploadSessionId': 'upload-session-create-1',
                    'directUpload': <String, Object?>{
                      'url': 'https://oss.example.com/upload/create-1',
                      'method': 'PUT',
                    },
                    'confirm': <String, Object?>{
                      'endpoint': '/api/app/file/upload/confirm',
                    },
                  },
                );
              },
              'POST /api/app/file/upload/confirm':
                  (AppApiRequest request) async {
                    expect(request.body, <String, Object?>{
                      'uploadSessionId': 'upload-session-create-1',
                    });
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{'status': 'bound'},
                    );
                  },
            },
        uploadHandler: (AppApiUploadRequest request) async {
          expect(request.method, 'PUT');
          expect(request.url, 'https://oss.example.com/upload/create-1');
          return AppApiResponse(statusCode: 200, uri: Uri.parse(request.url));
        },
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute: ExhibitionRoutes.projectCreate,
          transport: transport,
          sessionStore: buildAuthenticatedSessionStore(
            deviceId: 'device-upload',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        _projectCreateField('预算金额'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.enterText(_projectCreateField('项目名称'), '展览项目');
      await _selectProjectType(tester);
      await tester.enterText(_projectCreateField('预算金额'), '1000');
      await _fillProjectCreateAddressRangeForm(tester);
      await _scrollAndTap(tester, find.widgetWithText(FilledButton, '发布项目'));
      await tester.scrollUntilVisible(
        find.text('文件资料继续承接'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('项目 ID：project-1'), findsOneWidget);
      expect(find.text('文件资料继续承接'), findsOneWidget);

      final chooseButton = find.text('选择项目附件', skipOffstage: false);
      await tester.scrollUntilVisible(
        chooseButton,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(chooseButton);
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('create-brief.pdf'), findsWidgets);

      final uploadButton = find.text('上传当前附件', skipOffstage: false);
      await tester.scrollUntilVisible(
        uploadButton,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(uploadButton);
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('上传确认已完成'), findsOneWidget);
      expect(find.textContaining('已上传并完成绑定确认'), findsWidgets);
      expect(
        transport.requests
            .map((AppApiRequest request) => request.canonicalPath)
            .toList(),
        containsAll(<String>[
          ExhibitionCanonicalPaths.projectCreate,
          ExhibitionCanonicalPaths.uploadInit,
          ExhibitionCanonicalPaths.uploadConfirm,
        ]),
      );
      expect(transport.uploads, hasLength(1));
    },
  );

  testWidgets('project create attachment confirm failure stays user-facing', (
    WidgetTester tester,
  ) async {
    final bytes = utf8.encode('create-page attachment confirm failure');
    ProjectAttachmentDebugOverrides.installPicker(
      () async =>
          ProjectAttachmentDraft(fileName: 'create-failure.pdf', bytes: bytes),
    );

    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            ...defaultHandlers(),
            'POST /api/app/project/create': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 202,
                uri: request.uri,
                body: const <String, Object?>{'projectId': 'project-failure-1'},
              );
            },
            'POST /api/app/file/upload/init': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: <String, Object?>{
                  'uploadSessionId': 'upload-session-failure-1',
                  'directUpload': <String, Object?>{
                    'url': 'https://oss.example.com/upload/failure-1',
                    'method': 'PUT',
                  },
                  'confirm': <String, Object?>{
                    'endpoint': '/api/app/file/upload/confirm',
                  },
                },
              );
            },
            'POST /api/app/file/upload/confirm': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 409,
                uri: request.uri,
                body: const <String, Object?>{
                  'code': 'FILE_UPLOAD_CONFIRM_REQUIRED',
                  'message':
                      'Upload confirm is required before binding the file.',
                },
              );
            },
          },
      uploadHandler: (AppApiUploadRequest request) async {
        return AppApiResponse(statusCode: 200, uri: Uri.parse(request.url));
      },
    );

    await tester.pumpWidget(
      buildApp(
        initialRoute: ExhibitionRoutes.projectCreate,
        transport: transport,
        sessionStore: buildAuthenticatedSessionStore(
          deviceId: 'device-create-upload-failure',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      _projectCreateField('预算金额'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.enterText(_projectCreateField('项目名称'), '失败态项目');
    await _selectProjectType(tester);
    await tester.enterText(_projectCreateField('预算金额'), '980');
    await _fillProjectCreateAddressRangeForm(
      tester,
      detailAddress: '世纪城会展中心 8 号馆装卸区',
      scopeSummary: '确认失败态附件链路',
    );
    await _scrollAndTap(tester, find.widgetWithText(FilledButton, '发布项目'));

    final chooseButton = find.text('选择项目附件', skipOffstage: false);
    await tester.scrollUntilVisible(
      chooseButton,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(chooseButton);
    await tester.pump();
    await tester.pumpAndSettle();

    final uploadButton = find.text('上传当前附件', skipOffstage: false);
    await tester.scrollUntilVisible(
      uploadButton,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(uploadButton);
    await tester.pump();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('附件确认暂未完成'), findsOneWidget);
    expect(find.textContaining('create-failure.pdf 确认结果未完成'), findsOneWidget);
    expect(find.text('再次确认上传结果'), findsOneWidget);
    expect(find.textContaining('uploadSessionId'), findsNothing);
    expect(find.textContaining('confirmEndpoint'), findsNothing);
  });

  testWidgets(
    'project create default content no longer exposes technical disclosure copy',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          initialRoute: ExhibitionRoutes.projectCreate,
          shellContextConsumer: buildShellContextConsumer(),
          sessionStore: buildAuthenticatedSessionStore(
            deviceId: 'device-content',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('创建项目'), findsWidgets);
      expect(find.text('先看这五步'), findsNothing);
      expect(find.text('第二步 地址与范围'), findsNothing);
      expect(find.text('第三步 文件资料'), findsNothing);
      expect(find.text('第四步 文字说明与 AI 辅助'), findsNothing);
      expect(find.text('第五步 预览、支付与一键发布'), findsNothing);
      expect(find.textContaining('BFF base URL'), findsNothing);
      expect(find.text('当前连接信息（次级）'), findsNothing);
      expect(find.text('协议承接信息（次级）'), findsNothing);
      expect(find.text('payload snapshot'), findsNothing);
      expect(find.text('基础信息'), findsOneWidget);
      expect(_projectCreateField('项目名称'), findsOneWidget);
      expect(_projectCreateField('项目类型'), findsOneWidget);
      expect(_projectCreateField('预算金额'), findsOneWidget);
      await tester.scrollUntilVisible(
        _projectCreateField('省'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(_projectCreateField('省'), findsOneWidget);
      expect(_projectCreateField('市'), findsOneWidget);
      expect(_projectCreateField('区/县'), findsOneWidget);
      final provinceField = tester.widget<TextField>(_projectCreateField('省'));
      final cityField = tester.widget<TextField>(_projectCreateField('市'));
      final districtField = tester.widget<TextField>(
        _projectCreateField('区/县'),
      );
      expect(provinceField.readOnly, isTrue);
      expect(cityField.readOnly, isTrue);
      expect(districtField.readOnly, isTrue);
      await _scrollAndTap(tester, _projectCreateField('省'));
      expect(find.text('选择项目所在地区'), findsOneWidget);
      expect(find.text('先选择项目所在城市；如需补充区/县，可在下一步继续选择。'), findsOneWidget);
      expect(find.textContaining('标准地区'), findsNothing);
      expect(find.textContaining('省 code'), findsNothing);
      expect(find.textContaining('城市 code'), findsNothing);
      await _scrollAndTap(tester, find.text('四川 / 成都'));
      await _scrollAndTap(tester, _projectCreateField('区/县'));
      expect(find.text('选择区/县'), findsOneWidget);
      expect(find.text('区/县为选填，如需补充，请选择更准确的项目位置。'), findsOneWidget);
      expect(find.text('暂不补充区/县'), findsOneWidget);
      expect(find.textContaining('districtCode'), findsNothing);
      expect(find.textContaining('区县 code'), findsNothing);
      await _scrollAndTap(tester, find.text('武侯区'));
      expect(_projectCreateField('详细地址'), findsOneWidget);
      expect(_projectCreateField('范围说明'), findsOneWidget);
      await tester.scrollUntilVisible(
        _projectCreateField('计划结束日期'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(_projectCreateField('计划开始日期'), findsOneWidget);
      expect(_projectCreateField('计划结束日期'), findsOneWidget);
      expect(find.byTooltip('选择计划开始日期'), findsOneWidget);
      expect(find.byTooltip('选择计划结束日期'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('补充说明与附件'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('补充说明与附件'), findsOneWidget);
      expect(_projectCreateField('补充说明'), findsOneWidget);
      expect(find.text('附件补充方式'), findsOneWidget);
      expect(find.text('title'), findsNothing);
      expect(find.text('buildingType'), findsNothing);
      expect(find.text('budgetAmount'), findsNothing);
      expect(find.textContaining('create 必填'), findsNothing);
      expect(find.textContaining('detail address contract'), findsNothing);
      expect(find.textContaining('detailAddress'), findsNothing);
      expect(find.textContaining('scopeSummary'), findsNothing);
      expect(find.textContaining('旧项目可为空'), findsNothing);
      expect(find.textContaining('默认行政区'), findsNothing);
      expect(find.textContaining('当前仍复用现有项目类型字段承接'), findsNothing);
      expect(find.textContaining('YYYY-MM-DD'), findsNothing);
      expect(find.textContaining('code + name'), findsNothing);
      expect(find.textContaining('carrier'), findsNothing);
    },
  );

  testWidgets('project create local validation stays user-facing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        initialRoute: ExhibitionRoutes.projectCreate,
        sessionStore: buildAuthenticatedSessionStore(
          deviceId: 'device-validation',
        ),
      ),
    );
    await tester.pumpAndSettle();

    final submitButton = find.widgetWithText(FilledButton, '发布项目');
    await tester.scrollUntilVisible(
      submitButton,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    final submitAction = tester.widget<FilledButton>(submitButton);
    expect(submitAction.onPressed, isNotNull);
    submitAction.onPressed!();
    await tester.pump();
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();

    await tester.drag(find.byType(Scrollable).first, const Offset(0, 1200));
    await tester.pumpAndSettle();

    final titleField = tester.widget<TextField>(_projectCreateField('项目名称'));
    expect(titleField.decoration?.errorText, '请输入项目名称');
    expect(find.textContaining('title'), findsNothing);
    expect(find.textContaining('buildingType'), findsNothing);
    expect(find.textContaining('budgetAmount'), findsNothing);
  });

  testWidgets('project create address range validation stays user-facing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        initialRoute: ExhibitionRoutes.projectCreate,
        sessionStore: buildAuthenticatedSessionStore(
          deviceId: 'device-address-validation',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(_projectCreateField('项目名称'), '地址校验项目');
    await _selectProjectType(tester);
    await tester.enterText(_projectCreateField('预算金额'), '1200');
    await _scrollAndTap(tester, find.widgetWithText(FilledButton, '发布项目'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      _projectCreateField('省'),
      -200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    final provinceField = tester.widget<TextField>(_projectCreateField('省'));
    expect(provinceField.decoration?.errorText, '请选择省');

    await _fillProjectCreateAddressRangeForm(
      tester,
      plannedStartAt: '2026/04/10',
      plannedEndAt: '2026-04-18',
    );
    await _scrollAndTap(tester, find.widgetWithText(FilledButton, '发布项目'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      _projectCreateField('计划开始日期'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    final startDateField = tester.widget<TextField>(
      _projectCreateField('计划开始日期'),
    );
    expect(startDateField.decoration?.errorText, '请选择有效的计划开始日期');
  });

  testWidgets('project create blocks unauthenticated actor with login hint', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        initialRoute: ExhibitionRoutes.projectCreate,
        shellContextConsumer: buildShellContextConsumer(),
        sessionStore: AppSessionStore(),
      ),
    );
    await tester.pumpAndSettle();

    final loginEntryButton = find.ancestor(
      of: find.text('进入登录入口', skipOffstage: false),
      matching: find.byType(FilledButton, skipOffstage: false),
    );
    final submitButton = find.ancestor(
      of: find.text('发布项目', skipOffstage: false),
      matching: find.byType(FilledButton, skipOffstage: false),
    );

    expect(loginEntryButton, findsOneWidget);
    expect(submitButton, findsNothing);

    await _scrollAndTap(tester, find.text('进入登录入口', skipOffstage: false));
    expect(find.text('登录入口'), findsWidgets);
    expect(find.text('验证码登录承接'), findsOneWidget);
  });

  testWidgets('project create blocks no-organization actor with handoff hint', (
    WidgetTester tester,
  ) async {
    final sessionStore = AppSessionStore();
    sessionStore.establishSession(
      accessToken: 'token-active',
      refreshToken: 'token-refresh',
      expiresInSeconds: 3600,
      deviceId: 'device-1',
    );

    await tester.pumpWidget(
      buildApp(
        initialRoute: ExhibitionRoutes.projectCreate,
        shellContextConsumer: buildShellContextConsumer(organizationId: null),
        sessionStore: sessionStore,
      ),
    );
    await tester.pumpAndSettle();

    final organizationHandoffButton = find.ancestor(
      of: find.text('去完善组织', skipOffstage: false),
      matching: find.byType(FilledButton, skipOffstage: false),
    );
    final submitButton = find.ancestor(
      of: find.text('发布项目', skipOffstage: false),
      matching: find.byType(FilledButton, skipOffstage: false),
    );

    expect(organizationHandoffButton, findsOneWidget);
    expect(submitButton, findsNothing);

    await _scrollAndTap(tester, find.text('去完善组织', skipOffstage: false));
    expect(find.text('组织承接'), findsWidgets);
    expect(find.text('组织办理'), findsOneWidget);
    expect(find.text('创建组织'), findsOneWidget);
    expect(find.text('加入组织'), findsOneWidget);
  });

  testWidgets('shell context not found stays unavailable instead of offline', (
    WidgetTester tester,
  ) async {
    final shellContextConsumer = AppShellContextConsumer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'GET /api/app/shell/context': (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 404,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'code': 'SHELL_CONTEXT_UNAVAILABLE',
                      'message': 'shell context unavailable',
                    },
                  );
                },
              },
        ),
      ),
    );

    await tester.pumpWidget(
      buildApp(
        initialRoute: AppBuilding.messages.routePath,
        shellContextConsumer: shellContextConsumer,
        sessionStore: buildAuthenticatedSessionStore(deviceId: 'device-shell'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('当前上下文暂不可用'), findsOneWidget);
    expect(find.text('当前离线'), findsNothing);
    expect(find.widgetWithText(FilledButton, '重试承接'), findsOneWidget);
  });

  testWidgets(
    'project create keeps role or certification guard controlled by workbench canCreateProject',
    (WidgetTester tester) async {
      final sessionStore = AppSessionStore();
      sessionStore.establishSession(
        accessToken: 'token-active',
        refreshToken: 'token-refresh',
        expiresInSeconds: 3600,
        deviceId: 'device-2',
      );

      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
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
                          'canOpenProjectPool': true,
                        },
                      ),
                    );
                  },
            },
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute: ExhibitionRoutes.projectCreate,
          shellContextConsumer: buildShellContextConsumer(
            organizationId: 'org-1',
            roleKeys: const <String>['buyer_member(scoped)'],
            certificationStatus: 'not_submitted',
          ),
          sessionStore: sessionStore,
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      final workbenchBackButton = find.ancestor(
        of: find.text('回到项目工作台', skipOffstage: false),
        matching: find.byType(FilledButton, skipOffstage: false),
      );
      final submitButton = find.ancestor(
        of: find.text('发布项目', skipOffstage: false),
        matching: find.byType(FilledButton, skipOffstage: false),
      );

      expect(workbenchBackButton, findsOneWidget);
      expect(submitButton, findsNothing);
      expect(
        transport.requests
            .where(
              (AppApiRequest request) =>
                  request.canonicalPath ==
                  ExhibitionCanonicalPaths.projectCreate,
            )
            .isEmpty,
        isTrue,
      );
    },
  );

  test(
    'project create submits admitted Round B richer fields while success result stays projectId only',
    () async {
      Object? capturedBody;
      final consumer = ExhibitionConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'POST /api/app/project/create':
                      (AppApiRequest request) async {
                        capturedBody = request.body;
                        return AppApiResponse(
                          statusCode: 202,
                          uri: request.uri,
                          body: <String, Object?>{
                            'projectId': 'project-1',
                            'projectNo': 'PROJ-1',
                            'title': 'raw project',
                            'buildingType': 'exhibition',
                            'budgetAmount': 1200,
                            'state': 'published',
                            'summary': <String, Object?>{'heading': 'project'},
                          },
                        );
                      },
                },
          ),
        ),
      );

      final result = await consumer.createProject(
        ProjectCreateCommand(
          title: '展览项目',
          buildingType: 'exhibition',
          budgetAmount: 1200,
          areaSqm: 350.5,
          buildingTypeRemark: '医疗器械展区特装搭建',
          provinceCode: '510000',
          provinceName: '四川',
          cityCode: '510100',
          cityName: '成都',
          districtCode: '510107',
          districtName: '武侯区',
          detailAddress: '世纪城新国际会展中心 6 号馆西门',
          scopeSummary: '主舞台、医疗器械展区与灯光联动区进场搭建',
          plannedStartAt: '2026-04-10',
          plannedEndAt: '2026-04-18',
          scheduleDetail: '4 月 10 日晚进场，4 月 18 日撤场',
        ),
      );

      expect(
        capturedBody,
        _projectCreateAddressRangeBody(
          budgetAmount: 1200,
          areaSqm: 350.5,
          buildingTypeRemark: '医疗器械展区特装搭建',
          scheduleDetail: '4 月 10 日晚进场，4 月 18 日撤场',
          description: null,
        ),
      );
      expect(result.isSuccess, isTrue);
      expect(result.controlledState, isNull);
      expect(result.payload, <String, Object?>{'projectId': 'project-1'});
    },
  );

  test(
    'project create omits districtCode and districtName together when district is not separately selected',
    () async {
      Object? capturedBody;
      final consumer = ExhibitionConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'POST /api/app/project/create':
                      (AppApiRequest request) async {
                        capturedBody = request.body;
                        return AppApiResponse(
                          statusCode: 202,
                          uri: request.uri,
                          body: const <String, Object?>{
                            'projectId': 'project-2',
                          },
                        );
                      },
                },
          ),
        ),
      );

      await consumer.createProject(
        ProjectCreateCommand(
          title: '不单独提供区县的项目',
          buildingType: 'exhibition',
          budgetAmount: 980,
          provinceCode: '510000',
          provinceName: '四川',
          cityCode: '510100',
          cityName: '成都',
          detailAddress: '世纪城新国际会展中心 5 号馆北门',
          scopeSummary: '不单独提供区县时的最小标准地区提交流程',
        ),
      );

      expect(capturedBody, <String, Object?>{
        'title': '不单独提供区县的项目',
        'buildingType': 'exhibition',
        'budgetAmount': 980.0,
        'provinceCode': '510000',
        'provinceName': '四川',
        'cityCode': '510100',
        'cityName': '成都',
        'detailAddress': '世纪城新国际会展中心 5 号馆北门',
        'scopeSummary': '不单独提供区县时的最小标准地区提交流程',
      });
    },
  );

  testWidgets(
    'project detail keeps legacy null address-range fields controlled',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/project/detail': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    ..._projectPayload(
                      projectId: 'legacy-project-1',
                      projectNo: 'PROJ-LEGACY-1',
                      title: '旧项目',
                      buildingType: 'exhibition',
                      budgetAmount: 980,
                    ),
                    'provinceName': null,
                    'cityName': null,
                    'districtName': null,
                    'detailAddress': null,
                    'scopeSummary': null,
                    'plannedStartAt': null,
                    'plannedEndAt': null,
                    'areaSqm': null,
                    'buildingTypeRemark': null,
                    'scheduleDetail': null,
                    'description': null,
                  },
                );
              },
            },
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute:
              '${ExhibitionRoutes.projectDetail}?projectId=legacy-project-1',
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('项目面积：当前项目暂未提供'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('项目面积：当前项目暂未提供'), findsOneWidget);
      expect(find.text('类型备注：当前项目暂未提供'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('当前项目还没有地址与范围字段'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('当前项目还没有地址与范围字段'), findsOneWidget);
      expect(find.text('省：当前项目暂未提供'), findsOneWidget);
      expect(find.text('市：当前项目暂未提供'), findsOneWidget);
      expect(find.text('区/县：当前项目暂未提供'), findsOneWidget);
      expect(find.text('详细地址：当前项目暂未提供'), findsOneWidget);
      expect(find.text('范围说明：当前项目暂未提供'), findsOneWidget);
      expect(find.text('计划开始日期：当前项目暂未提供'), findsOneWidget);
      expect(find.text('计划结束日期：当前项目暂未提供'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('详细时间：当前项目暂未提供'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('详细时间：当前项目暂未提供'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('当前项目还没有补充说明'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('当前项目还没有补充说明'), findsOneWidget);
      expect(find.text('补充说明：当前项目暂未提供'), findsOneWidget);
    },
  );

  testWidgets('bid submit success stays in minimum bid continuation only', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            ...defaultHandlers(),
            'POST /api/app/bid/submit': (AppApiRequest request) async {
              expect(request.body, <String, Object?>{
                'projectId': 'proj-1',
                'quoteAmount': 1200.0,
                'proposalSummary': 'phase 2.1 bid',
              });
              return AppApiResponse(
                statusCode: 202,
                uri: request.uri,
                body: <String, Object?>{'bidId': 'bid-123'},
              );
            },
          },
    );

    await tester.pumpWidget(
      buildApp(
        initialRoute: '${ExhibitionRoutes.bidSubmit}?projectId=proj-1',
        transport: transport,
        shellContextConsumer: buildShellContextConsumer(
          organizationId: 'org-1',
          roleKeys: const <String>['supplier_admin'],
          certificationStatus: 'verified',
        ),
        sessionStore: buildAuthenticatedSessionStore(deviceId: 'device-bid'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, '投标报价'), '1200');
    await tester.enterText(
      find.widgetWithText(TextField, '方案说明'),
      'phase 2.1 bid',
    );
    final submitButton = find.widgetWithText(FilledButton, '提交投标');
    await _scrollAndTap(tester, submitButton);

    expect(find.text('竞标已提交'), findsOneWidget);
    expect(find.text('投标 ID：bid-123'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '继续创建订单'), findsNothing);
    expect(find.widgetWithText(FilledButton, '查看订单详情'), findsNothing);
    expect(
      transport.requests
          .where(
            (AppApiRequest request) =>
                request.canonicalPath == ExhibitionCanonicalPaths.orderCreate,
          )
          .isEmpty,
      isTrue,
    );
  });

  testWidgets(
    'order detail enters content from route orderId and exposes approved continuation actions',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/order/detail': (AppApiRequest request) async {
                expect(request.uri.queryParameters['orderId'], 'order-1');
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _orderPayload(
                    orderId: 'order-1',
                    projectId: 'project-1',
                    bidId: 'bid-1',
                    milestones: <Object?>[
                      <String, Object?>{
                        'milestoneId': 'milestone-1',
                        'orderId': 'order-1',
                        'title': 'initial delivery',
                        'amount': 1200,
                        'state': 'pending_submission',
                        'summary': <String, Object?>{'heading': 'initial'},
                      },
                    ],
                  ),
                );
              },
            },
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute: '${ExhibitionRoutes.orderDetail}?orderId=order-1',
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('订单详情'), findsWidgets);
      expect(find.text('当前订单 ID：order-1'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('订单编号：ORD-1'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('订单编号：ORD-1'), findsOneWidget);
      expect(find.text('关联项目 ID：project-1'), findsOneWidget);
      expect(find.text('关联投标 ID：bid-1'), findsOneWidget);
      expect(find.text('当前状态：进行中'), findsOneWidget);
      expect(find.text('当前说明：订单关键信息已经承接完成，可以继续判断履约链或后半链入口。'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('查看里程碑列表'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('查看里程碑列表'), findsOneWidget);
      expect(find.text('去提交 initial delivery'), findsOneWidget);
      expect(find.text('查看合同详情'), findsOneWidget);
      expect(find.text('开启争议入口'), findsOneWidget);
      expect(find.text('去争议撤回'), findsNothing);
    },
  );

  testWidgets(
    'order detail continuation buttons enter contract detail and dispute open with the same orderId',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/order/detail': (AppApiRequest request) async {
                expect(request.uri.queryParameters['orderId'], 'order-1');
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _orderPayload(
                    orderId: 'order-1',
                    projectId: 'project-1',
                    bidId: 'bid-1',
                    milestones: <Object?>[
                      <String, Object?>{
                        'milestoneId': 'milestone-1',
                        'orderId': 'order-1',
                        'title': 'initial delivery',
                        'amount': 1200,
                        'state': 'pending_submission',
                        'summary': <String, Object?>{'heading': 'initial'},
                      },
                    ],
                  ),
                );
              },
              'GET /api/app/contract/detail': (AppApiRequest request) async {
                expect(request.uri.queryParameters['orderId'], 'order-1');
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'contractId': 'contract-1',
                    'orderId': 'order-1',
                    'state': 'pending_confirm',
                    'summary': _summary('contract'),
                  },
                );
              },
            },
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute: '${ExhibitionRoutes.orderDetail}?orderId=order-1',
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('查看合同详情'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -200));
      await tester.pumpAndSettle();

      final contractDetailButton = find.widgetWithText(FilledButton, '查看合同详情');
      await tester.ensureVisible(contractDetailButton);
      await tester.tap(contractDetailButton);
      await tester.pumpAndSettle();
      expect(find.text('合同详情'), findsWidgets);
      expect(find.text('当前订单 ID：order-1'), findsOneWidget);
      await popRoute(tester);

      final disputeOpenButton = find.widgetWithText(FilledButton, '开启争议入口');
      await tester.ensureVisible(disputeOpenButton);
      await tester.tap(disputeOpenButton);
      await tester.pumpAndSettle();
      expect(find.text('争议开启入口'), findsWidgets);
      expect(find.text('当前订单 ID：order-1'), findsOneWidget);
      expect(find.text('去争议撤回'), findsNothing);
      expect(find.text('查看评价入口'), findsNothing);

      expect(
        transport.requests
            .where(
              (AppApiRequest request) =>
                  request.canonicalPath ==
                  ExhibitionCanonicalPaths.contractDetail,
            )
            .length,
        1,
      );
    },
  );

  testWidgets(
    'milestone list enters content from route orderId and exposes only approved continuation action',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/milestone/list': (AppApiRequest request) async {
                expect(request.uri.queryParameters['orderId'], 'order-1');
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'items': <Object?>[
                      <String, Object?>{
                        'milestoneId': 'milestone-1',
                        'orderId': 'order-1',
                        'title': 'initial delivery',
                        'amount': 1200,
                        'state': 'pending_submission',
                        'summary': <String, Object?>{'heading': 'initial'},
                      },
                    ],
                  },
                );
              },
            },
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute: '${ExhibitionRoutes.milestoneList}?orderId=order-1',
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('里程碑列表'), findsWidgets);
      expect(find.text('当前订单 ID：order-1'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('initial delivery'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('当前里程碑数：1 个'), findsOneWidget);
      expect(find.text('initial delivery'), findsOneWidget);
      expect(find.text('里程碑 ID：milestone-1'), findsOneWidget);
      expect(find.text('所属订单：order-1'), findsOneWidget);
      expect(find.text('节点金额：¥1200'), findsOneWidget);
      expect(find.text('当前状态：待提交'), findsOneWidget);
      expect(find.text('下一步动作：先完成里程碑提交，再继续进入验收详情。'), findsOneWidget);
      expect(find.text('去提交 initial delivery'), findsOneWidget);
      expect(find.text('查看 initial delivery 验收详情'), findsNothing);
      expect(find.text('inspection detail'), findsNothing);
      expect(find.text('inspection submit'), findsNothing);
      expect(find.text('inspection recheck'), findsNothing);
    },
  );

  testWidgets(
    'bid submit default content no longer exposes technical disclosure copy',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          initialRoute: '${ExhibitionRoutes.bidSubmit}?projectId=proj-1',
          shellContextConsumer: buildShellContextConsumer(
            organizationId: 'org-1',
            roleKeys: const <String>['supplier_admin'],
            certificationStatus: 'verified',
          ),
          sessionStore: buildAuthenticatedSessionStore(
            deviceId: 'device-bid-content',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('投标提交'), findsWidgets);
      expect(find.text('当前项目 ID：proj-1'), findsOneWidget);
      expect(find.text('第一步 承接当前项目'), findsOneWidget);
      expect(find.text('第二步 补齐最小竞标信息'), findsOneWidget);
      expect(find.text('第三步 提交继续'), findsOneWidget);
      expect(find.textContaining('BFF base URL'), findsNothing);
      expect(find.text('当前连接信息（次级）'), findsNothing);
      expect(find.text('协议承接信息（次级）'), findsNothing);
      expect(find.text('payload snapshot'), findsNothing);
    },
  );

  test('bid submit success sanitizes to minimum command body only', () async {
    final consumer = ExhibitionConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'POST /api/app/bid/submit': (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 202,
                    uri: request.uri,
                    body: <String, Object?>{
                      'bidId': 'bid-1',
                      'bidNo': 'BID-1',
                      'projectId': 'project-1',
                      'quoteAmount': 1200,
                      'state': 'submitted',
                      'summary': <String, Object?>{'heading': 'bid'},
                    },
                  );
                },
              },
        ),
      ),
    );

    final result = await consumer.submitBid(
      const BidSubmitCommand(
        projectId: 'project-1',
        quoteAmount: 1200,
        proposalSummary: 'phase 2.1 bid',
      ),
    );

    expect(result.isSuccess, isTrue);
    expect(result.controlledState, isNull);
    expect(result.payload, <String, Object?>{'bidId': 'bid-1'});
  });

  test('order create success sanitizes to minimum command body only', () async {
    final consumer = ExhibitionConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'POST /api/app/order/create': (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 201,
                    uri: request.uri,
                    body: <String, Object?>{
                      'orderId': 'order-1',
                      'orderNo': 'ORD-1',
                      'projectId': 'project-1',
                      'bidId': 'bid-1',
                      'state': 'active',
                      'summary': <String, Object?>{'heading': 'order'},
                      'milestones': <Object?>[
                        <String, Object?>{
                          'milestoneId': 'milestone-1',
                          'orderId': 'order-1',
                          'title': 'initial delivery',
                          'amount': 1200,
                          'state': 'pending_submission',
                          'summary': <String, Object?>{'heading': 'initial'},
                        },
                        <String, Object?>{
                          'milestoneId': 'milestone-2',
                          'title': 'second milestone',
                        },
                      ],
                    },
                  );
                },
              },
        ),
      ),
    );

    final result = await consumer.createOrder(
      const OrderCreateCommand(bidId: 'bid-1'),
    );

    expect(result.isSuccess, isTrue);
    expect(result.controlledState, isNull);
    expect(result.payload, <String, Object?>{
      'orderId': 'order-1',
      'milestones': <Map<String, Object?>>[
        <String, Object?>{'milestoneId': 'milestone-1'},
      ],
    });
  });

  testWidgets(
    'milestone submit success carries route milestoneId to inspection detail',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'POST /api/app/milestone/submit': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 202,
                  uri: request.uri,
                  body: <String, Object?>{'milestoneId': 'milestone-1'},
                );
              },
              'GET /api/app/inspection/detail': (AppApiRequest request) async {
                expect(
                  request.uri.queryParameters['milestoneId'],
                  'milestone-1',
                );
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'inspectionId': 'inspection-1',
                    'milestoneId': 'milestone-1',
                    'state': 'draft',
                    'summary': <String, Object?>{'heading': 'inspection'},
                  },
                );
              },
            },
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute:
              '${ExhibitionRoutes.milestoneSubmit}?milestoneId=milestone-1',
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      final submitButton = find.widgetWithText(FilledButton, '提交里程碑');
      await tester.ensureVisible(submitButton);
      await tester.pumpAndSettle();
      await tester.tap(submitButton);
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('去验收详情'), findsOneWidget);
      expect(find.text('当前里程碑 ID：milestone-1'), findsOneWidget);

      final goToInspection = find.widgetWithText(FilledButton, '去验收详情');
      await tester.ensureVisible(goToInspection);
      await tester.pumpAndSettle();
      await tester.tap(goToInspection);
      await tester.pumpAndSettle();

      expect(find.text('验收详情'), findsWidgets);
      expect(find.textContaining('当前里程碑 ID：milestone-1'), findsWidgets);
    },
  );

  testWidgets(
    'milestone submit default content no longer exposes technical disclosure copy',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildApp(
          initialRoute:
              '${ExhibitionRoutes.milestoneSubmit}?milestoneId=milestone-1',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('里程碑提交'), findsWidgets);
      expect(find.text('当前里程碑 ID：milestone-1'), findsOneWidget);
      expect(find.textContaining('BFF base URL'), findsNothing);
      expect(find.text('当前连接信息（次级）'), findsNothing);
      expect(find.text('协议承接信息（次级）'), findsNothing);
      expect(find.text('payload snapshot'), findsNothing);
      expect(find.text('上传承接字段（次级）'), findsNothing);
    },
  );

  testWidgets(
    'remaining read pages default content no longer exposes technical disclosure copy',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/contract/detail': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'contractId': 'contract-1',
                    'orderId': 'order-1',
                    'state': 'pending_confirm',
                    'summary': <String, Object?>{'heading': 'contract'},
                  },
                );
              },
              'GET /api/app/inspection/detail': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'inspectionId': 'inspection-1',
                    'milestoneId': 'milestone-1',
                    'state': 'draft',
                    'summary': <String, Object?>{'heading': 'inspection'},
                  },
                );
              },
              'GET /api/app/rating/entry': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'orderId': 'order-1',
                    'state': 'draft',
                    'summary': <String, Object?>{'heading': 'rating'},
                  },
                );
              },
            },
      );

      await expectNoDefaultTechnicalDisclosure(
        tester,
        app: buildApp(
          initialRoute: '${ExhibitionRoutes.contractDetail}?orderId=order-1',
          transport: transport,
        ),
        pageTitle: '合同详情',
        visibleTexts: const <String>['当前订单 ID：order-1', '当前合同 ID：contract-1'],
      );

      await expectNoDefaultTechnicalDisclosure(
        tester,
        app: buildApp(
          initialRoute:
              '${ExhibitionRoutes.inspectionDetail}?milestoneId=milestone-1',
          transport: transport,
        ),
        pageTitle: '验收详情',
        visibleTexts: const <String>[
          '当前里程碑 ID：milestone-1',
          '当前验收 ID：inspection-1',
        ],
      );

      await expectNoDefaultTechnicalDisclosure(
        tester,
        app: buildApp(
          initialRoute: '${ExhibitionRoutes.ratingEntry}?orderId=order-1',
          transport: transport,
        ),
        pageTitle: '评价入口',
        visibleTexts: const <String>['当前订单 ID：order-1'],
      );
    },
  );

  testWidgets(
    'remaining action pages default content no longer exposes technical disclosure copy',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/contract/detail': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'contractId': 'contract-1',
                    'orderId': 'order-1',
                    'state': 'active',
                    'summary': <String, Object?>{'heading': 'contract'},
                  },
                );
              },
              'GET /api/app/inspection/detail': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'inspectionId': 'inspection-1',
                    'milestoneId': 'milestone-1',
                    'state': 'draft',
                    'summary': <String, Object?>{'heading': 'inspection'},
                  },
                );
              },
              'GET /api/app/rating/entry': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'orderId': 'order-1',
                    'state': 'draft',
                    'summary': <String, Object?>{'heading': 'rating'},
                  },
                );
              },
            },
      );

      await expectNoDefaultTechnicalDisclosure(
        tester,
        app: buildApp(
          initialRoute: '${ExhibitionRoutes.contractConfirm}?orderId=order-1',
          transport: transport,
        ),
        pageTitle: '合同确认',
        visibleTexts: const <String>['当前订单 ID：order-1', '当前合同 ID：contract-1'],
      );

      await expectNoDefaultTechnicalDisclosure(
        tester,
        app: buildApp(
          initialRoute: '${ExhibitionRoutes.contractAmend}?orderId=order-1',
          transport: transport,
        ),
        pageTitle: '合同改单',
        visibleTexts: const <String>['当前订单 ID：order-1', '当前合同 ID：contract-1'],
      );

      await expectNoDefaultTechnicalDisclosure(
        tester,
        app: buildApp(
          initialRoute:
              '${ExhibitionRoutes.inspectionSubmit}?milestoneId=milestone-1',
          transport: transport,
        ),
        pageTitle: '验收提交',
        visibleTexts: const <String>[
          '当前里程碑 ID：milestone-1',
          '当前验收 ID：inspection-1',
        ],
      );

      await expectNoDefaultTechnicalDisclosure(
        tester,
        app: buildApp(
          initialRoute:
              '${ExhibitionRoutes.inspectionRecheck}?milestoneId=milestone-1',
          transport: transport,
        ),
        pageTitle: '验收复检提交',
        visibleTexts: const <String>[
          '当前里程碑 ID：milestone-1',
          '当前验收 ID：inspection-1',
        ],
      );

      await expectNoDefaultTechnicalDisclosure(
        tester,
        app: buildApp(
          initialRoute: '${ExhibitionRoutes.ratingSubmit}?orderId=order-1',
          transport: transport,
        ),
        pageTitle: '评价提交',
        visibleTexts: const <String>['当前订单 ID：order-1'],
      );
    },
  );

  testWidgets(
    'dispute pages default content no longer exposes technical disclosure copy',
    (WidgetTester tester) async {
      await expectNoDefaultTechnicalDisclosure(
        tester,
        app: buildApp(
          initialRoute: '${ExhibitionRoutes.disputeOpen}?orderId=order-1',
        ),
        pageTitle: '争议开启入口',
        visibleTexts: const <String>['当前订单 ID：order-1'],
      );

      await expectNoDefaultTechnicalDisclosure(
        tester,
        app: buildApp(
          initialRoute:
              '${ExhibitionRoutes.disputeWithdraw}?disputeId=dispute-1&orderId=order-1',
        ),
        pageTitle: '争议撤回入口',
        visibleTexts: const <String>['当前争议 ID：dispute-1'],
      );
    },
  );

  testWidgets('upload confirm shows user-facing upload completion only', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            ...defaultHandlers(),
            'POST /api/app/file/upload/init': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: <String, Object?>{
                  'uploadSessionId': 'upload-session-1',
                  'directUpload': <String, Object?>{
                    'url': 'https://oss.example.com/upload/object-1',
                    'method': 'PUT',
                    'headers': <String, Object?>{
                      'x-oss-meta-source': 'flutter-test',
                    },
                  },
                  'confirm': <String, Object?>{
                    'endpoint': '/api/app/file/upload/confirm',
                  },
                },
              );
            },
            'POST /api/app/file/upload/confirm': (AppApiRequest request) async {
              expect(
                request.canonicalPath,
                ExhibitionCanonicalPaths.uploadConfirm,
              );
              expect(request.body, <String, Object?>{
                'uploadSessionId': 'upload-session-1',
              });
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: <String, Object?>{'status': 'bound'},
              );
            },
          },
      uploadHandler: (AppApiUploadRequest request) async {
        expect(request.method, 'PUT');
        expect(request.url, 'https://oss.example.com/upload/object-1');
        expect(request.headers['x-oss-meta-source'], 'flutter-test');
        return AppApiResponse(statusCode: 200, uri: Uri.parse(request.url));
      },
    );

    await tester.pumpWidget(
      buildApp(
        initialRoute:
            '${ExhibitionRoutes.milestoneSubmit}?milestoneId=milestone-1',
        transport: transport,
      ),
    );
    await tester.pumpAndSettle();

    final uploadSummaryField = find.widgetWithText(TextField, '凭证摘要');
    await tester.ensureVisible(uploadSummaryField);
    await tester.pumpAndSettle();
    await tester.enterText(uploadSummaryField, '现场照片与节点确认单');
    final uploadButton = find.widgetWithText(FilledButton, '补充当前凭证');

    await tester.ensureVisible(uploadButton);
    await tester.pumpAndSettle();
    await tester.tap(uploadButton);
    await tester.pump();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('上传已完成'), findsOneWidget);
    expect(find.textContaining('upload-session-1'), findsNothing);
    expect(find.textContaining('x-oss-meta-source'), findsNothing);
    expect(transport.uploads, hasLength(1));

    expect(find.text('上传已完成'), findsOneWidget);
    expect(find.textContaining('upload state'), findsNothing);
    expect(find.textContaining('uploadSessionId'), findsNothing);
    expect(find.textContaining('directMethod'), findsNothing);
    expect(find.textContaining('confirmEndpoint'), findsNothing);
    expect(
      transport.requests
          .map((AppApiRequest request) => request.canonicalPath)
          .contains(ExhibitionCanonicalPaths.uploadConfirm),
      isTrue,
    );
    expect(transport.uploads, hasLength(1));
  });

  testWidgets(
    'project detail attachment flow records confirm result without inventing project attachment binding',
    (WidgetTester tester) async {
      final bytes = utf8.encode('phase-3 project attachment');
      ProjectAttachmentDebugOverrides.installPicker(
        () async =>
            ProjectAttachmentDraft(fileName: 'project-brief.pdf', bytes: bytes),
      );

      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/project/detail': (AppApiRequest request) async {
                expect(request.uri.queryParameters['projectId'], 'project-1');
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _projectPayload(
                    projectId: 'project-1',
                    projectNo: 'PROJ-1',
                    title: '展览项目',
                    budgetAmount: 1200,
                  ),
                );
              },
              'POST /api/app/file/upload/init': (AppApiRequest request) async {
                expect(request.body, <String, Object?>{
                  'businessType': 'project',
                  'businessId': 'project-1',
                  'fileKind': 'evidence',
                  'mimeType': 'application/pdf',
                  'size': bytes.length,
                  'checksum': sha256.convert(bytes).toString(),
                });
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'uploadSessionId': 'upload-session-project-1',
                    'directUpload': <String, Object?>{
                      'url': 'https://oss.example.com/upload/project-1',
                      'method': 'PUT',
                    },
                    'confirm': <String, Object?>{
                      'endpoint': '/api/app/file/upload/confirm',
                    },
                  },
                );
              },
              'POST /api/app/file/upload/confirm':
                  (AppApiRequest request) async {
                    expect(request.body, <String, Object?>{
                      'uploadSessionId': 'upload-session-project-1',
                    });
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{'status': 'bound'},
                    );
                  },
            },
        uploadHandler: (AppApiUploadRequest request) async {
          expect(request.method, 'PUT');
          expect(request.url, 'https://oss.example.com/upload/project-1');
          return AppApiResponse(statusCode: 200, uri: Uri.parse(request.url));
        },
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute: '${ExhibitionRoutes.projectDetail}?projectId=project-1',
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      final chooseButton = find.text('选择项目附件', skipOffstage: false);
      await tester.scrollUntilVisible(
        chooseButton,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(chooseButton);
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('project-brief.pdf'), findsWidgets);

      final uploadButton = find.text('上传当前附件', skipOffstage: false);
      await tester.scrollUntilVisible(
        uploadButton,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(uploadButton);
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('上传确认已完成'), findsOneWidget);
      expect(find.text('本次上传确认记录'), findsOneWidget);
      expect(find.textContaining('待项目附件结果返回'), findsWidgets);
      expect(find.textContaining('已绑定'), findsNothing);
      expect(find.textContaining('uploadSessionId'), findsNothing);
      expect(find.textContaining('confirmEndpoint'), findsNothing);
      expect(transport.uploads, hasLength(1));
    },
  );

  testWidgets(
    'project detail attachment flow keeps unsupported types controlled',
    (WidgetTester tester) async {
      ProjectAttachmentDebugOverrides.installPicker(
        () async => const ProjectAttachmentDraft(
          fileName: 'project-note.txt',
          bytes: <int>[1, 2, 3],
        ),
      );

      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'GET /api/app/project/detail': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _projectPayload(projectId: 'project-1'),
                );
              },
            },
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute: '${ExhibitionRoutes.projectDetail}?projectId=project-1',
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      final chooseButton = find.text('选择项目附件', skipOffstage: false);
      await tester.scrollUntilVisible(
        chooseButton,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(chooseButton);
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('当前文件类型暂不支持'), findsOneWidget);
      expect(find.textContaining('PDF、DOC、DOCX'), findsWidgets);
      expect(find.widgetWithText(FilledButton, '上传当前附件'), findsNothing);
    },
  );

  testWidgets('submission failure maps to controlled error state', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            ...defaultHandlers(),
            'POST /api/app/project/create': (AppApiRequest request) async {
              expect(request.body, _projectCreateAddressRangeBody());
              return AppApiResponse(
                statusCode: 422,
                uri: request.uri,
                body: <String, Object?>{'code': 'PROJECT_INVALID_STATE'},
              );
            },
          },
    );

    await tester.pumpWidget(
      buildApp(
        initialRoute: ExhibitionRoutes.projectCreate,
        transport: transport,
        sessionStore: buildAuthenticatedSessionStore(
          deviceId: 'device-failure',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      _projectCreateField('预算金额'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.enterText(_projectCreateField('项目名称'), '展览项目');
    await _selectProjectType(tester);
    await tester.enterText(_projectCreateField('预算金额'), '1000');
    await _fillProjectCreateAddressRangeForm(tester);
    final submitButton = find.widgetWithText(FilledButton, '发布项目');
    await _scrollAndTap(tester, submitButton);
    await tester.scrollUntilVisible(
      find.text('当前动作未完成'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('controlled state'), findsNothing);
    expect(find.textContaining('error code'), findsNothing);
    expect(find.text('当前动作未完成'), findsOneWidget);
    expect(find.text('回到项目池'), findsWidgets);
  });

  testWidgets('unauthorized response enters controlled unauthorized state', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            ...defaultHandlers(),
            'GET /api/app/project/list': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 401,
                uri: request.uri,
                body: <String, Object?>{
                  'code': 'AUTH_SESSION_INVALID',
                  'message': 'missing auth headers',
                  'source': 'bff',
                },
              );
            },
          },
    );

    await tester.pumpWidget(
      buildApp(
        initialRoute: ExhibitionRoutes.projectList,
        transport: transport,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('missing auth headers'), findsOneWidget);
    expect(find.textContaining('error code'), findsNothing);
    expect(find.text('回到展览'), findsWidgets);
  });

  testWidgets('duplicate bid submission stays controlled and visible', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            ...defaultHandlers(),
            'POST /api/app/bid/submit': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 409,
                uri: request.uri,
                body: <String, Object?>{
                  'code': 'BID_DUPLICATE_SUBMISSION',
                  'message': 'duplicate bid',
                  'source': 'server',
                },
              );
            },
          },
    );

    await tester.pumpWidget(
      buildApp(
        initialRoute: '${ExhibitionRoutes.bidSubmit}?projectId=proj-1',
        transport: transport,
        shellContextConsumer: buildShellContextConsumer(
          organizationId: 'org-1',
          roleKeys: const <String>['supplier_admin'],
          certificationStatus: 'verified',
        ),
        sessionStore: buildAuthenticatedSessionStore(
          deviceId: 'device-bid-duplicate',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, '投标报价'), '1200');
    await tester.enterText(
      find.widgetWithText(TextField, '方案说明'),
      'phase 2.2 duplicate bid',
    );
    final submitButton = find.widgetWithText(FilledButton, '提交投标');
    await _scrollAndTap(tester, submitButton);

    expect(find.textContaining('controlled state'), findsNothing);
    expect(find.textContaining('error code'), findsNothing);
    expect(find.textContaining('duplicate bid'), findsWidgets);
    expect(find.text('回到项目池'), findsWidgets);
  });

  testWidgets('submitted milestone stays in controlled invalid_state failure', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            ...defaultHandlers(),
            'POST /api/app/milestone/submit': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 409,
                uri: request.uri,
                body: <String, Object?>{
                  'code': 'MILESTONE_INVALID_STATE',
                  'message':
                      'Only pending_submission milestones may be submitted.',
                  'source': 'server',
                },
              );
            },
          },
    );

    await tester.pumpWidget(
      buildApp(
        initialRoute:
            '${ExhibitionRoutes.milestoneSubmit}?milestoneId=milestone-1',
        transport: transport,
      ),
    );
    await tester.pumpAndSettle();

    final submitButton = find.widgetWithText(FilledButton, '提交里程碑');
    await tester.ensureVisible(submitButton);
    await tester.pumpAndSettle();
    await tester.tap(submitButton);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.textContaining('controlled state'), findsNothing);
    expect(find.textContaining('error code'), findsNothing);
    expect(
      find.textContaining(
        'Only pending_submission milestones may be submitted.',
      ),
      findsOneWidget,
    );
    expect(find.text('回到展览'), findsWidgets);
  });

  test(
    'milestone submit success sanitizes to minimum command body only',
    () async {
      final consumer = ExhibitionConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'POST /api/app/milestone/submit':
                      (AppApiRequest request) async {
                        return AppApiResponse(
                          statusCode: 202,
                          uri: request.uri,
                          body: <String, Object?>{
                            'milestoneId': 'milestone-1',
                            'orderId': 'order-1',
                            'title': 'initial delivery',
                            'amount': 1200,
                            'state': 'submitted',
                            'summary': <String, Object?>{
                              'heading': 'milestone',
                            },
                          },
                        );
                      },
                },
          ),
        ),
      );

      final result = await consumer.submitMilestone(
        const MilestoneSubmitCommand(
          milestoneId: 'milestone-1',
          submissionNote: 'phase 2 milestone',
        ),
      );

      expect(result.isSuccess, isTrue);
      expect(result.controlledState, isNull);
      expect(result.payload, <String, Object?>{'milestoneId': 'milestone-1'});
    },
  );

  testWidgets(
    'upload confirm required stays user-facing without technical upload tokens',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              ...defaultHandlers(),
              'POST /api/app/file/upload/init': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'uploadSessionId': 'upload-session-2',
                    'directUpload': <String, Object?>{
                      'url': 'https://oss.example.com/upload/object-2',
                      'method': 'PUT',
                      'headers': <String, Object?>{
                        'x-oss-meta-source': 'flutter-test',
                      },
                    },
                    'confirm': <String, Object?>{
                      'endpoint': '/api/app/file/upload/confirm',
                    },
                  },
                );
              },
              'POST /api/app/file/upload/confirm': (AppApiRequest request) async {
                expect(request.body, <String, Object?>{
                  'uploadSessionId': 'upload-session-2',
                });
                return AppApiResponse(
                  statusCode: 409,
                  uri: request.uri,
                  body: <String, Object?>{
                    'code': 'FILE_UPLOAD_CONFIRM_REQUIRED',
                    'message':
                        'Upload confirm is required before binding the file.',
                    'source': 'bff',
                  },
                );
              },
            },
        uploadHandler: (AppApiUploadRequest request) async {
          return AppApiResponse(statusCode: 200, uri: Uri.parse(request.url));
        },
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute:
              '${ExhibitionRoutes.milestoneSubmit}?milestoneId=milestone-1',
          transport: transport,
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, '凭证摘要'),
        '第二批现场照片与节点说明',
      );
      final uploadButton = find.widgetWithText(FilledButton, '补充当前凭证');
      await tester.ensureVisible(uploadButton);
      await tester.pumpAndSettle();
      await tester.tap(uploadButton);
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final uploadFailureTitle = find.text('上传确认暂未完成', skipOffstage: false);
      await tester.scrollUntilVisible(
        uploadFailureTitle.first,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('上传确认暂未完成'), findsOneWidget);
      expect(find.textContaining('upload state'), findsNothing);
      expect(find.textContaining('error code'), findsNothing);
      expect(find.textContaining('uploadSessionId'), findsNothing);
      expect(find.textContaining('directMethod'), findsNothing);
      expect(find.textContaining('confirmEndpoint'), findsNothing);
    },
  );

  test(
    'consumer layer sanitizes success payload to frozen minimum fields',
    () async {
      final consumer = ExhibitionConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/order/detail': (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: <String, Object?>{
                        'orderId': 'order-1',
                        'orderNo': 'ORD-1',
                        'projectId': 'project-1',
                        'bidId': 'bid-1',
                        'buyerOrganizationId': 'buyer-1',
                        'supplierOrganizationId': 'supplier-1',
                        'title': 'raw title',
                        'totalAmount': 1200,
                        'state': 'active',
                        'milestones': <Object?>[
                          <String, Object?>{
                            'milestoneId': 'milestone-1',
                            'orderId': 'order-1',
                            'title': 'initial delivery',
                            'amount': 1200,
                            'state': 'pending_submission',
                            'submittedBy': 'someone',
                            'summary': <String, Object?>{'heading': 'initial'},
                          },
                        ],
                        'summary': <String, Object?>{'heading': 'order'},
                      },
                    );
                  },
                },
          ),
        ),
      );

      final result = await consumer.loadOrderDetail(orderId: 'order-1');
      final payload = result.payload as Map<String, Object?>;

      expect(result.state, AppPageState.content);
      expect(payload, <String, Object?>{
        'orderId': 'order-1',
        'orderNo': 'ORD-1',
        'projectId': 'project-1',
        'bidId': 'bid-1',
        'state': 'active',
        'summary': <String, Object?>{'heading': 'order'},
        'milestones': <Map<String, Object?>>[
          <String, Object?>{
            'milestoneId': 'milestone-1',
            'orderId': 'order-1',
            'title': 'initial delivery',
            'amount': 1200,
            'state': 'pending_submission',
            'summary': <String, Object?>{'heading': 'initial'},
          },
        ],
      });
    },
  );

  test(
    'project list and detail sanitize to aligned showcase read models only',
    () async {
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
                            'title': 'raw project',
                            'buildingType': 'exhibition',
                            'budgetAmount': 1200,
                            'areaSqm': 350.5,
                            'provinceCode': '510000',
                            'provinceName': '四川',
                            'cityCode': '510100',
                            'cityName': '成都',
                            'districtCode': '510107',
                            'districtName': '武侯区',
                            'detailAddress': '世纪城新国际会展中心 6 号馆西门',
                            'description': 'list must not own description',
                            'state': 'published',
                            'summary': <String, Object?>{'heading': 'project'},
                            'detailOnlyField': 'ignored',
                          },
                        ],
                        'summary': <String, Object?>{'heading': 'ignored-list'},
                      },
                    );
                  },
                  'GET /api/app/project/detail': (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: <String, Object?>{
                        'projectId': 'project-1',
                        'projectNo': 'PROJ-1',
                        'title': 'raw project',
                        'buildingType': 'exhibition',
                        'budgetAmount': 1200,
                        'provinceCode': '510000',
                        'provinceName': '四川',
                        'cityCode': '510100',
                        'cityName': '成都',
                        'districtCode': '510107',
                        'districtName': '武侯区',
                        'detailAddress': '世纪城新国际会展中心 6 号馆西门',
                        'scopeSummary': '主舞台、医疗器械展区与灯光联动区进场搭建',
                        'plannedStartAt': '2026-04-10',
                        'plannedEndAt': '2026-04-18',
                        'areaSqm': 350.5,
                        'buildingTypeRemark': '医疗器械展区特装搭建',
                        'scheduleDetail': '4 月 10 日晚进场，4 月 18 日撤场',
                        'description': 'shared detail description',
                        'state': 'published',
                        'summary': <String, Object?>{'heading': 'project'},
                        'detailOnlyField': 'ignored',
                      },
                    );
                  },
                },
          ),
        ),
      );

      final listResult = await consumer.loadProjectList();
      final detailResult = await consumer.loadProjectDetail(
        projectId: 'project-1',
      );

      expect(listResult.state, AppPageState.content);
      expect(detailResult.state, AppPageState.content);
      expect(listResult.payload, <String, Object?>{
        'items': <Map<String, Object?>>[
          <String, Object?>{
            'projectId': 'project-1',
            'projectNo': 'PROJ-1',
            'title': 'raw project',
            'buildingType': 'exhibition',
            'budgetAmount': 1200,
            'areaSqm': 350.5,
            'provinceCode': '510000',
            'provinceName': '四川',
            'cityCode': '510100',
            'cityName': '成都',
            'state': 'published',
            'summary': <String, Object?>{'heading': 'project'},
          },
        ],
      });
      expect(detailResult.payload, <String, Object?>{
        'projectId': 'project-1',
        'projectNo': 'PROJ-1',
        'title': 'raw project',
        'buildingType': 'exhibition',
        'budgetAmount': 1200,
        'provinceCode': '510000',
        'provinceName': '四川',
        'cityCode': '510100',
        'cityName': '成都',
        'districtCode': '510107',
        'districtName': '武侯区',
        'detailAddress': '世纪城新国际会展中心 6 号馆西门',
        'scopeSummary': '主舞台、医疗器械展区与灯光联动区进场搭建',
        'plannedStartAt': '2026-04-10',
        'plannedEndAt': '2026-04-18',
        'areaSqm': 350.5,
        'buildingTypeRemark': '医疗器械展区特装搭建',
        'scheduleDetail': '4 月 10 日晚进场，4 月 18 日撤场',
        'description': 'shared detail description',
        'state': 'published',
        'summary': <String, Object?>{'heading': 'project'},
      });
    },
  );

  test(
    'session read cache keeps different projectId and orderId requests isolated',
    () async {
      var projectDetailRequestCount = 0;
      var orderDetailRequestCount = 0;
      final consumer = ExhibitionConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/project/detail': (AppApiRequest request) async {
                    projectDetailRequestCount += 1;
                    final projectId = request.uri.queryParameters['projectId']!;
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _projectPayload(
                        projectId: projectId,
                        projectNo: 'NO-$projectId',
                        title: 'title-$projectId',
                      ),
                    );
                  },
                  'GET /api/app/order/detail': (AppApiRequest request) async {
                    orderDetailRequestCount += 1;
                    final orderId = request.uri.queryParameters['orderId']!;
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _orderPayload(
                        orderId: orderId,
                        projectId: 'project-$orderId',
                        bidId: 'bid-$orderId',
                      ),
                    );
                  },
                },
          ),
        ),
      );

      final projectOne = await consumer.loadProjectDetail(
        projectId: 'project-1',
      );
      final projectTwo = await consumer.loadProjectDetail(
        projectId: 'project-2',
      );
      final projectOneAgain = await consumer.loadProjectDetail(
        projectId: 'project-1',
      );
      final orderOne = await consumer.loadOrderDetail(orderId: 'order-1');
      final orderTwo = await consumer.loadOrderDetail(orderId: 'order-2');
      final orderOneAgain = await consumer.loadOrderDetail(orderId: 'order-1');

      expect(projectDetailRequestCount, 2);
      expect(orderDetailRequestCount, 2);
      expect(
        (projectOne.payload as Map<String, Object?>)['projectId'],
        'project-1',
      );
      expect(
        (projectTwo.payload as Map<String, Object?>)['projectId'],
        'project-2',
      );
      expect(
        (projectOneAgain.payload as Map<String, Object?>)['projectId'],
        'project-1',
      );
      expect((orderOne.payload as Map<String, Object?>)['orderId'], 'order-1');
      expect((orderTwo.payload as Map<String, Object?>)['orderId'], 'order-2');
      expect(
        (orderOneAgain.payload as Map<String, Object?>)['orderId'],
        'order-1',
      );
    },
  );

  test(
    'new session read cache keeps contract, inspection, and rating instances isolated',
    () async {
      var contractDetailRequestCount = 0;
      var inspectionDetailRequestCount = 0;
      var ratingEntryRequestCount = 0;
      final consumer = ExhibitionConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/contract/detail':
                      (AppApiRequest request) async {
                        contractDetailRequestCount += 1;
                        final orderId = request.uri.queryParameters['orderId']!;
                        return AppApiResponse(
                          statusCode: 200,
                          uri: request.uri,
                          body: <String, Object?>{
                            'contractId': 'contract-$orderId',
                            'orderId': orderId,
                            'state': 'pending_confirm',
                            'summary': <String, Object?>{'heading': orderId},
                          },
                        );
                      },
                  'GET /api/app/inspection/detail':
                      (AppApiRequest request) async {
                        inspectionDetailRequestCount += 1;
                        final milestoneId =
                            request.uri.queryParameters['milestoneId']!;
                        return AppApiResponse(
                          statusCode: 200,
                          uri: request.uri,
                          body: <String, Object?>{
                            'inspectionId': 'inspection-$milestoneId',
                            'milestoneId': milestoneId,
                            'state': 'draft',
                            'summary': <String, Object?>{
                              'heading': milestoneId,
                            },
                          },
                        );
                      },
                  'GET /api/app/rating/entry': (AppApiRequest request) async {
                    ratingEntryRequestCount += 1;
                    final orderId = request.uri.queryParameters['orderId']!;
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: <String, Object?>{
                        'orderId': orderId,
                        'state': 'draft',
                        'summary': <String, Object?>{'heading': orderId},
                      },
                    );
                  },
                },
          ),
        ),
      );

      final contractOne = await consumer.loadContractDetail(orderId: 'order-1');
      final contractTwo = await consumer.loadContractDetail(orderId: 'order-2');
      final contractOneAgain = await consumer.loadContractDetail(
        orderId: 'order-1',
      );
      final inspectionOne = await consumer.loadInspectionDetail(
        milestoneId: 'milestone-1',
      );
      final inspectionTwo = await consumer.loadInspectionDetail(
        milestoneId: 'milestone-2',
      );
      final inspectionOneAgain = await consumer.loadInspectionDetail(
        milestoneId: 'milestone-1',
      );
      final ratingOne = await consumer.loadRatingEntry(orderId: 'order-1');
      final ratingTwo = await consumer.loadRatingEntry(orderId: 'order-2');
      final ratingOneAgain = await consumer.loadRatingEntry(orderId: 'order-1');

      expect(contractDetailRequestCount, 2);
      expect(inspectionDetailRequestCount, 2);
      expect(ratingEntryRequestCount, 2);
      expect(
        (contractOne.payload as Map<String, Object?>)['contractId'],
        'contract-order-1',
      );
      expect(
        (contractTwo.payload as Map<String, Object?>)['contractId'],
        'contract-order-2',
      );
      expect(
        (contractOneAgain.payload as Map<String, Object?>)['contractId'],
        'contract-order-1',
      );
      expect(
        (inspectionOne.payload as Map<String, Object?>)['inspectionId'],
        'inspection-milestone-1',
      );
      expect(
        (inspectionTwo.payload as Map<String, Object?>)['inspectionId'],
        'inspection-milestone-2',
      );
      expect(
        (inspectionOneAgain.payload as Map<String, Object?>)['inspectionId'],
        'inspection-milestone-1',
      );
      expect((ratingOne.payload as Map<String, Object?>)['orderId'], 'order-1');
      expect((ratingTwo.payload as Map<String, Object?>)['orderId'], 'order-2');
      expect(
        (ratingOneAgain.payload as Map<String, Object?>)['orderId'],
        'order-1',
      );
    },
  );

  test(
    'force refresh bypasses cached read result and sends a fresh request',
    () async {
      var projectDetailRequestCount = 0;
      final consumer = ExhibitionConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/project/detail': (AppApiRequest request) async {
                    projectDetailRequestCount += 1;
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _projectPayload(
                        projectId: 'project-1',
                        projectNo: 'PROJ-$projectDetailRequestCount',
                      ),
                    );
                  },
                },
          ),
        ),
      );

      final first = await consumer.loadProjectDetail(projectId: 'project-1');
      final second = await consumer.loadProjectDetail(projectId: 'project-1');
      final refreshed = await consumer.loadProjectDetail(
        projectId: 'project-1',
        forceRefresh: true,
      );

      expect(projectDetailRequestCount, 2);
      expect((first.payload as Map<String, Object?>)['projectNo'], 'PROJ-1');
      expect((second.payload as Map<String, Object?>)['projectNo'], 'PROJ-1');
      expect(
        (refreshed.payload as Map<String, Object?>)['projectNo'],
        'PROJ-2',
      );
    },
  );

  test(
    'session read optimization dedupes in-flight project detail requests',
    () async {
      var projectDetailRequestCount = 0;
      final responseCompleter = Completer<AppApiResponse>();
      final consumer = ExhibitionConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/project/detail': (AppApiRequest request) {
                    projectDetailRequestCount += 1;
                    return responseCompleter.future;
                  },
                },
          ),
        ),
      );

      final firstFuture = consumer.loadProjectDetail(projectId: 'project-1');
      final secondFuture = consumer.loadProjectDetail(projectId: 'project-1');

      expect(projectDetailRequestCount, 1);

      responseCompleter.complete(
        AppApiResponse(
          statusCode: 200,
          uri: Uri.parse('http://127.0.0.1:8080/api/app/project/detail'),
          body: _projectPayload(projectId: 'project-1'),
        ),
      );

      final results = await Future.wait<ExhibitionLoadResult>(
        <Future<ExhibitionLoadResult>>[firstFuture, secondFuture],
      );

      expect(projectDetailRequestCount, 1);
      expect(results[0].state, AppPageState.content);
      expect(results[1].state, AppPageState.content);
    },
  );

  test(
    'unsupported stable state enters controlled failure instead of content',
    () async {
      final consumer = ExhibitionConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/order/detail': (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _orderPayload(
                        orderId: 'order-1',
                        projectId: 'project-1',
                        bidId: 'bid-1',
                        state: 'draft',
                      ),
                    );
                  },
                },
          ),
        ),
      );

      final result = await consumer.loadOrderDetail(orderId: 'order-1');

      expect(result.state, AppPageState.errorNonRetryable);
      expect(
        result.message,
        contains('unsupported state "draft" for Phase 2.2'),
      );
    },
  );

  test(
    'consumer layer filters unsupported error codes from controlled failures',
    () async {
      final consumer = ExhibitionConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'POST /api/app/order/create': (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 409,
                      uri: request.uri,
                      body: <String, Object?>{
                        'code': 'ORDER_ALREADY_EXISTS',
                        'message': 'An order already exists for this bid.',
                        'source': 'server',
                      },
                    );
                  },
                },
          ),
        ),
      );

      final result = await consumer.createOrder(
        const OrderCreateCommand(bidId: 'bid-1'),
      );

      expect(result.isSuccess, isFalse);
      expect(result.controlledState, AppPageState.errorNonRetryable);
      expect(result.errorCode, isNull);
      expect(
        result.message,
        'unrecognized error code ORDER_ALREADY_EXISTS from canonical path: '
        'An order already exists for this bid.',
      );
      expect(result.payload, <String, Object?>{
        'message': 'An order already exists for this bid.',
        'source': 'server',
      });
    },
  );
}
