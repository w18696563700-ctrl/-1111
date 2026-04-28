import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/boot/app_shell_context_consumer.dart';
import 'package:mobile/core/location/china_region_catalog.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/messages/data/messages_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_consumer_layer.dart';
import 'package:mobile/shell/shell_app.dart';

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
                    'projectCreateEligibility': const <String, Object?>{
                      'canCreateProject': true,
                    },
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
    '品牌' => 'project-create-brand-name',
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
    '补充说明' => 'project-create-description',
    _ => throw ArgumentError('Unknown project create field: $label'),
  };
  return find.byKey(ValueKey<String>(key));
}

Finder _projectCreateScopeSummaryInput() {
  return find.byKey(
    const ValueKey<String>('project-create-scope-summary-input'),
  );
}

Future<void> _setProjectCreateScopeSummary(
  WidgetTester tester,
  String value,
) async {
  await _scrollAndTap(tester, _projectCreateField('范围说明'));
  await tester.enterText(_projectCreateScopeSummaryInput(), value);
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(FilledButton, '保存说明'));
  await tester.pumpAndSettle();
}

Future<void> _selectProjectType(
  WidgetTester tester, {
  String option = '会展',
}) async {
  await _scrollAndTap(tester, _projectCreateField('项目类型'));
  await tester.tap(find.text(option, skipOffstage: false).last);
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
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{},
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

      final titleY = tester.getTopLeft(_projectCreateField('项目名称')).dy;
      final brandY = tester.getTopLeft(_projectCreateField('品牌')).dy;
      expect((titleY - brandY).abs(), lessThan(1));

      final typeY = tester.getTopLeft(_projectCreateField('项目类型')).dy;
      final budgetY = tester.getTopLeft(_projectCreateField('预算金额')).dy;
      final areaY = tester.getTopLeft(_projectCreateField('项目面积')).dy;
      expect((typeY - budgetY).abs(), lessThan(1));
      expect((typeY - areaY).abs(), lessThan(1));

      final provinceY = tester.getTopLeft(_projectCreateField('省')).dy;
      final cityY = tester.getTopLeft(_projectCreateField('市')).dy;
      final districtY = tester.getTopLeft(_projectCreateField('区/县')).dy;
      expect((provinceY - cityY).abs(), lessThan(1));
      expect((provinceY - districtY).abs(), lessThan(1));

      await _selectProjectType(tester, option: '会议');
      expect(find.textContaining('已选择会议'), findsOneWidget);

      expect(find.text('添加范围说明'), findsOneWidget);
      await _setProjectCreateScopeSummary(tester, '主舞台、医疗器械展区与灯光联动区进场搭建');
      expect(find.text('编辑范围说明'), findsOneWidget);
      expect(
        find.textContaining('主舞台、医疗器械展区', skipOffstage: false),
        findsWidgets,
      );

      await tester.enterText(_projectCreateField('计划开始日期'), '2026年4月10日');
      await tester.pumpAndSettle();

      final startDateField = tester.widget<TextField>(
        _projectCreateField('计划开始日期'),
      );
      expect(
        startDateField.controller?.text,
        matches(RegExp(r'^\d{4}年\d{1,2}月\d{1,2}日$')),
      );
      final startDateY = tester.getTopLeft(_projectCreateField('计划开始日期')).dy;
      final endDateY = tester.getTopLeft(_projectCreateField('计划结束日期')).dy;
      expect((startDateY - endDateY).abs(), lessThan(1));
      expect(find.text('补充说明与附件', skipOffstage: false), findsNothing);
      expect(find.text('资料补充', skipOffstage: false), findsNothing);

      await tester.binding.setSurfaceSize(const Size(420, 1000));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        _projectCreateField('项目类型'),
        -200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      final narrowTypeY = tester.getTopLeft(_projectCreateField('项目类型')).dy;
      final narrowBudgetY = tester.getTopLeft(_projectCreateField('预算金额')).dy;
      final narrowAreaY = tester.getTopLeft(_projectCreateField('项目面积')).dy;
      expect(
        narrowBudgetY > narrowTypeY + 10 || narrowAreaY > narrowTypeY + 10,
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Round A location fields use province and city wording', (
    WidgetTester tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(900, 1100));

    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{},
    );

    await tester.pumpWidget(
      _buildApp(
        transport: transport,
        sessionStore: _buildAuthenticatedSessionStore(
          deviceId: 'region-picker',
        ),
        shellContextConsumer: _buildShellContextConsumer(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('点击选择省 / 市'), findsOneWidget);
    expect(find.text('请选择项目所在省 / 市，系统会自动带入对应地区信息。'), findsOneWidget);
  });

  testWidgets(
    'Round A province selector opens and confirms a province-city choice',
    (WidgetTester tester) async {
      addTearDown(() {
        tester.binding.setSurfaceSize(null);
        ChinaRegionCatalogLoader.reset();
      });
      await tester.binding.setSurfaceSize(const Size(900, 1100));
      ChinaRegionCatalogLoader.installLoadOverrideForTest(() async {
        return ChinaRegionCatalog(
          provinces: const <ChinaProvinceOption>[
            ChinaProvinceOption(
              provinceCode: '510000',
              provinceName: '四川',
              cities: <ChinaCityOption>[
                ChinaCityOption(
                  provinceCode: '510000',
                  provinceName: '四川',
                  cityCode: '510100',
                  cityName: '成都',
                  districts: <ChinaDistrictOption>[
                    ChinaDistrictOption(
                      districtCode: '510107',
                      districtName: '武侯区',
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      });

      await tester.pumpWidget(
        _buildApp(
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{},
          ),
          sessionStore: _buildAuthenticatedSessionStore(
            deviceId: 'region-picker-open',
          ),
          shellContextConsumer: _buildShellContextConsumer(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(_projectCreateField('省'));
      await tester.pumpAndSettle();

      expect(find.text('选择省 / 市'), findsOneWidget);
      await tester.tap(find.text('确定'));
      await tester.pumpAndSettle();

      expect(find.textContaining('已选择四川 / 成都'), findsOneWidget);
      expect(find.text('四川'), findsWidgets);
      expect(find.text('成都'), findsWidgets);
    },
  );

  testWidgets(
    'Round A validation shows unified message and scrolls to first invalid field',
    (WidgetTester tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(390, 800));

      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{},
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
        find.widgetWithText(FilledButton, '保存项目基本信息并跳转至我的项目'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      final beforeSubmitOffset = scrollable.position.pixels;

      final submitButton = find.widgetWithText(
        FilledButton,
        '保存项目基本信息并跳转至我的项目',
      );
      final submitAction = tester.widget<FilledButton>(submitButton);
      expect(submitAction.onPressed, isNotNull);
      submitAction.onPressed!();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.textContaining('无法保存：请输入展会'), findsOneWidget);

      await tester.drag(find.byType(Scrollable).first, const Offset(0, 1200));
      await tester.pumpAndSettle();

      final titleField = tester.widget<TextField>(_projectCreateField('项目名称'));
      expect(titleField.decoration?.errorText, '请输入展会');
      expect(scrollable.position.pixels, lessThan(beforeSubmitOffset));
      expect(tester.getTopLeft(_projectCreateField('项目名称')).dy, lessThan(220));
    },
  );

  testWidgets('Round A validation keeps scope summary optional', (
    WidgetTester tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(390, 1000));

    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{},
    );

    await tester.pumpWidget(
      _buildApp(
        transport: transport,
        sessionStore: _buildAuthenticatedSessionStore(
          deviceId: 'scope-validation',
        ),
        shellContextConsumer: _buildShellContextConsumer(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(_projectCreateField('项目名称'), '教育装备展');
    await tester.enterText(_projectCreateField('品牌'), '新东方');
    await _selectProjectType(tester);
    await tester.enterText(_projectCreateField('预算金额'), '200000');
    await _scrollAndTap(tester, _projectCreateField('详细地址'));
    await tester.enterText(_projectCreateField('详细地址'), '西博城');
    await tester.pumpAndSettle();

    final submitButton = find.widgetWithText(FilledButton, '保存项目基本信息并跳转至我的项目');
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

    expect(find.textContaining('无法保存'), findsWidgets);
    expect(find.textContaining('请选择省 / 市'), findsWidgets);
    expect(find.textContaining('请补充范围说明'), findsNothing);
  });

  testWidgets(
    'Round A selector still submits canonical buildingType exhibition',
    (WidgetTester tester) async {
      var createCalled = false;
      AppSessionStore.install(
        _buildAuthenticatedSessionStore(deviceId: 'mapping-direct'),
      );
      addTearDown(AppSessionStore.reset);
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'POST /api/app/project/create': (AppApiRequest request) async {
                createCalled = true;
                expect(request.body, <String, Object?>{
                  'title': 'Round A 映射项目 - 坤特',
                  'exhibitionName': 'Round A 映射项目',
                  'brandName': '坤特',
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
                  body: const <String, Object?>{
                    'projectId': 'round-a-project',
                    'state': 'draft',
                  },
                );
              },
            },
      );
      final exhibitionConsumerLayer = ExhibitionConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: transport,
        ),
      );
      final result = await exhibitionConsumerLayer.createProject(
        ProjectCreateCommand(
          title: 'Round A 映射项目 - 坤特',
          exhibitionName: 'Round A 映射项目',
          brandName: '坤特',
          buildingType: 'exhibition',
          budgetAmount: 1280,
          provinceCode: '510000',
          provinceName: '四川',
          cityCode: '510100',
          cityName: '成都',
          districtCode: '510107',
          districtName: '武侯区',
          detailAddress: '世纪城新国际会展中心 6 号馆西门',
          scopeSummary: '主舞台、医疗器械展区与灯光联动区进场搭建',
        ),
      );

      expect(createCalled, isTrue);
      expect(result.isSuccess, isTrue);
    },
  );

  testWidgets(
    'Round A create keeps scope summary optional in request payload',
    (WidgetTester tester) async {
      var createCalled = false;
      AppSessionStore.install(
        _buildAuthenticatedSessionStore(deviceId: 'optional-direct'),
      );
      addTearDown(AppSessionStore.reset);
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'POST /api/app/project/create': (AppApiRequest request) async {
                createCalled = true;
                expect(
                  request.body,
                  isNot(containsPair('scopeSummary', anything)),
                );
                return AppApiResponse(
                  statusCode: 202,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'projectId': 'round-a-optional',
                    'state': 'draft',
                  },
                );
              },
            },
      );
      final exhibitionConsumerLayer = ExhibitionConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: transport,
        ),
      );
      final result = await exhibitionConsumerLayer.createProject(
        ProjectCreateCommand(
          title: 'Round A 选填范围项目 - 坤特',
          exhibitionName: 'Round A 选填范围项目',
          brandName: '坤特',
          buildingType: 'exhibition',
          budgetAmount: 1280,
          provinceCode: '510000',
          provinceName: '四川',
          cityCode: '510100',
          cityName: '成都',
          districtCode: '510107',
          districtName: '武侯区',
          detailAddress: '世纪城新国际会展中心 6 号馆西门',
        ),
      );

      expect(createCalled, isTrue);
      expect(result.isSuccess, isTrue);
    },
  );
}
