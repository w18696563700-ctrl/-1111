import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/boot/app_shell_context_consumer.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/messages/data/messages_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_consumer_layer.dart';
import 'package:mobile/shell/shell_app.dart';

Map<String, Object?> _workbenchPayload() {
  return <String, Object?>{
    'project_chain': <String, Object?>{
      'hasProjects': false,
      'recentProjectId': null,
      'recentProjectTitle': null,
      'canCreateProject': true,
      'canOpenProjectPool': true,
    },
    'order_chain': <String, Object?>{
      'activeOrderId': null,
      'activeOrderNo': null,
      'activeOrderState': null,
      'canOpenOrderDetail': false,
      'canOpenContractDetail': false,
      'canOpenDisputeOpen': false,
    },
    'fulfillment_chain': <String, Object?>{
      'activeMilestoneId': null,
      'activeMilestoneTitle': null,
      'inspectionState': null,
      'canOpenMilestoneList': false,
      'canOpenMilestoneSubmit': false,
      'canOpenInspectionDetail': false,
      'canOpenInspectionSubmit': false,
    },
    'extension_boundary': <String, Object?>{
      'canOpenContractDetail': false,
      'ratingEntryState': 'controlled_unavailable',
      'canOpenDisputeOpen': false,
      'disputeWithdrawState': 'frozen',
    },
  };
}

ExhibitionMobileApp _buildApp({
  required FakeAppApiTransport transport,
  AppSessionStore? sessionStore,
  AppShellContextConsumer? shellContextConsumer,
}) {
  return ExhibitionMobileApp(
    initialRoute: '/exhibition/projects/create',
    shellContextConsumer: shellContextConsumer,
    exhibitionConsumerLayer: ExhibitionConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: transport,
      ),
    ),
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
    sessionStore: sessionStore,
  );
}

AppSessionStore _buildAuthenticatedSessionStore({required String deviceId}) {
  final sessionStore = AppSessionStore();
  sessionStore.establishSession(
    accessToken: 'token-$deviceId',
    refreshToken: 'refresh-$deviceId',
    expiresInSeconds: 3600,
    deviceId: deviceId,
  );
  return sessionStore;
}

AppShellContextConsumer _buildShellContextConsumer() {
  return AppShellContextConsumer(
    client: AppApiClient(
      config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
      transport: FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/shell/context': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'userId': 'round-a-user',
                    'organizationId': 'org-round-a',
                    'roleKeys': const <String>['supplier_admin'],
                    'certificationStatus': 'verified',
                    'membershipStatus': 'active',
                    'visibleBuildings': const <String>[
                      'exhibition',
                      'messages',
                      'profile',
                    ],
                    'featureFlagsVersion': 'ffv-20260404',
                    'unreadSummary': const <String, Object?>{},
                  },
                );
              },
            },
      ),
    ),
  );
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
    '预算金额' => 'project-create-budget-amount',
    '省' => 'project-create-province',
    '市' => 'project-create-city',
    '区/县' => 'project-create-district',
    '详细地址' => 'project-create-detail-address',
    '范围说明' => 'project-create-scope-summary',
    '计划开始日期' => 'project-create-planned-start-at',
    '计划结束日期' => 'project-create-planned-end-at',
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

Future<void> _fillCreateRequiredFields(
  WidgetTester tester, {
  String title = 'Round A 项目',
  String budgetAmount = '1280',
}) async {
  await tester.enterText(_projectCreateField('项目名称'), title);
  await _selectProjectType(tester, option: '会议');
  await tester.enterText(_projectCreateField('预算金额'), budgetAmount);
  await _selectStandardizedProjectLocation(tester);
  await tester.enterText(_projectCreateField('详细地址'), '世纪城新国际会展中心 6 号馆西门');
  await tester.enterText(_projectCreateField('范围说明'), '主舞台、医疗器械展区与灯光联动区进场搭建');
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'Round A create page keeps selector, address row, and localized date display',
    (WidgetTester tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(900, 1100));

      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/exhibition/workbench':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _workbenchPayload(),
                    );
                  },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          transport: transport,
          sessionStore: _buildAuthenticatedSessionStore(deviceId: 'layout'),
          shellContextConsumer: _buildShellContextConsumer(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('基础信息'), findsOneWidget);
      expect(find.text('项目地点与范围', skipOffstage: false), findsOneWidget);
      expect(find.text('计划时间', skipOffstage: false), findsOneWidget);

      final provinceY = tester.getTopLeft(_projectCreateField('省')).dy;
      final cityY = tester.getTopLeft(_projectCreateField('市')).dy;
      final districtY = tester.getTopLeft(_projectCreateField('区/县')).dy;
      expect((provinceY - cityY).abs(), lessThan(1));
      expect((provinceY - districtY).abs(), lessThan(1));

      await _selectProjectType(tester, option: '会议');
      expect(find.textContaining('已选择会议'), findsOneWidget);

      await _scrollAndTap(tester, find.byTooltip('选择计划开始日期'));
      await tester.tap(
        find
            .descendant(of: find.byType(Dialog), matching: find.text('10'))
            .last,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('确定'));
      await tester.pumpAndSettle();

      final startDateField = tester.widget<TextField>(
        _projectCreateField('计划开始日期'),
      );
      expect(
        startDateField.controller?.text,
        matches(RegExp(r'^\d{4}年\d{1,2}月\d{1,2}日$')),
      );
      await tester.scrollUntilVisible(
        find.text('补充说明与附件'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('补充说明与附件', skipOffstage: false), findsOneWidget);

      await tester.binding.setSurfaceSize(const Size(420, 1000));
      await tester.pumpAndSettle();

      final narrowProvinceY = tester.getTopLeft(_projectCreateField('省')).dy;
      final narrowCityY = tester.getTopLeft(_projectCreateField('市')).dy;
      final narrowDistrictY = tester.getTopLeft(_projectCreateField('区/县')).dy;
      expect(
        narrowCityY > narrowProvinceY + 10 ||
            narrowDistrictY > narrowProvinceY + 10,
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Round A validation shows unified message and scrolls to first invalid field',
    (WidgetTester tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(390, 800));

      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/exhibition/workbench':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _workbenchPayload(),
                    );
                  },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          transport: transport,
          sessionStore: _buildAuthenticatedSessionStore(deviceId: 'validation'),
          shellContextConsumer: _buildShellContextConsumer(),
        ),
      );
      await tester.pumpAndSettle();

      final scrollable = tester.state<ScrollableState>(
        find.byType(Scrollable).first,
      );
      await tester.scrollUntilVisible(
        find.widgetWithText(FilledButton, '发布项目'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      final beforeSubmitOffset = scrollable.position.pixels;

      final submitButton = find.widgetWithText(FilledButton, '发布项目');
      final submitAction = tester.widget<FilledButton>(submitButton);
      expect(submitAction.onPressed, isNotNull);
      submitAction.onPressed!();
      await tester.pump();
      await tester.pumpAndSettle();

      await tester.drag(find.byType(Scrollable).first, const Offset(0, 1200));
      await tester.pumpAndSettle();

      final titleField = tester.widget<TextField>(_projectCreateField('项目名称'));
      expect(titleField.decoration?.errorText, '请输入项目名称');
      expect(scrollable.position.pixels, lessThan(beforeSubmitOffset));
      expect(tester.getTopLeft(_projectCreateField('项目名称')).dy, lessThan(220));
    },
  );

  testWidgets(
    'Round A selector still submits canonical buildingType exhibition',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/exhibition/workbench':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _workbenchPayload(),
                    );
                  },
              'POST /api/app/project/create': (AppApiRequest request) async {
                expect(request.body, <String, Object?>{
                  'title': 'Round A 映射项目',
                  'buildingType': 'exhibition',
                  'budgetAmount': 1280.0,
                  'provinceCode': '510000',
                  'provinceName': '四川',
                  'cityCode': '510100',
                  'cityName': '成都',
                  'districtCode': '510107',
                  'districtName': '武侯区',
                  'detailAddress': '世纪城新国际会展中心 6 号馆西门',
                  'scopeSummary': '主舞台、医疗器械展区与灯光联动区进场搭建',
                });
                return AppApiResponse(
                  statusCode: 202,
                  uri: request.uri,
                  body: const <String, Object?>{'projectId': 'round-a-project'},
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildApp(
          transport: transport,
          sessionStore: _buildAuthenticatedSessionStore(deviceId: 'mapping'),
          shellContextConsumer: _buildShellContextConsumer(),
        ),
      );
      await tester.pumpAndSettle();

      await _fillCreateRequiredFields(tester, title: 'Round A 映射项目');
      await _scrollAndTap(tester, find.widgetWithText(FilledButton, '发布项目'));

      await tester.scrollUntilVisible(
        find.text('项目创建成功'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('项目创建成功'), findsOneWidget);
      expect(find.text('项目 ID：round-a-project'), findsOneWidget);
    },
  );
}
