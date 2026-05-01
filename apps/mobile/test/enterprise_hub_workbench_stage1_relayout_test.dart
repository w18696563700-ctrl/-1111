import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/boot/app_bootstrap_controller.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/core/location/china_region_catalog.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_published_change_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_workbench_consumer_layer.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_workbench_pages.dart';
import 'package:mobile/features/profile/data/profile_identity_consumer_layer.dart';
import 'package:mobile/shell/context/app_shell_scope.dart';

void main() {
  tearDown(() {
    ChinaRegionCatalogLoader.reset();
    EnterpriseHubConsumerLayer.reset();
    EnterpriseHubPublishedChangeConsumerLayer.reset();
    EnterpriseHubWorkbenchConsumerLayer.reset();
    ProfileIdentityConsumerLayer.reset();
  });

  testWidgets('company workbench uses compact homepage and module drill-in', (
    WidgetTester tester,
  ) async {
    _installWorkbenchDependencies();

    await _pumpWorkbench(
      tester,
      initialRoute: ExhibitionRoutes.companyDisplayWorkbench,
    );

    expect(
      find.byKey(const ValueKey<String>('company-workbench-homepage')),
      findsOneWidget,
    );
    expect(find.text('公司展示工作台'), findsOneWidget);
    expect(find.text('西南会展搭建有限公司'), findsOneWidget);
    expect(find.text('快捷入口'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('company-workbench-completeness')),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('信息完整度'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('company-workbench-module-entries')),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('核心信息概览'), findsOneWidget);
    expect(find.text('最新动态'), findsNothing);
    expect(find.text('暂无动态'), findsNothing);
    expect(find.text('数据看板'), findsNothing);
    expect(find.text('暂无数据'), findsNothing);
    expect(
      find.byKey(
        const ValueKey<String>(
          'enterprise-workbench-display-identification-section',
        ),
      ),
      findsNothing,
    );
    expect(find.text('服务城市（逗号分隔）'), findsNothing);
    expect(find.text('最大项目规模'), findsNothing);
    expect(find.text('资质说明'), findsNothing);

    await tester.drag(find.byType(Scrollable).first, const Offset(0, 1200));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('company-workbench-module-展示标识')),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('company-workbench-module-展示标识')),
    );
    await tester.pumpAndSettle();

    expect(find.text('展示标识'), findsWidgets);
    expect(
      find.byKey(
        const ValueKey<String>(
          'enterprise-workbench-display-identification-section',
        ),
      ),
      findsOneWidget,
    );
    expect(find.text('公司名称'), findsOneWidget);
    expect(find.text('公司位置'), findsOneWidget);
    expect(find.text('公司信用评分（建设中）'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('company-workbench-module-基础资料')),
    );
    await tester.pumpAndSettle();

    expect(find.text('一句话简介'), findsNothing);
    expect(find.text('公司介绍（2000字以内）'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is SegmentedButton<EnterpriseBoardType>,
      ),
      findsNothing,
    );
  });

  testWidgets('factory workbench uses compact homepage and module drill-in', (
    WidgetTester tester,
  ) async {
    _installWorkbenchDependencies(
      boardType: EnterpriseBoardType.factory,
      workbenchPayload: _buildFactoryWorkbenchPayload(),
    );

    await _pumpWorkbench(
      tester,
      initialRoute: ExhibitionRoutes.factoryDisplayWorkbench,
    );

    expect(
      find.byKey(const ValueKey<String>('factory-workbench-homepage')),
      findsOneWidget,
    );
    expect(find.text('工厂展示工作台'), findsOneWidget);
    expect(find.text('重庆海川展览工厂'), findsOneWidget);
    expect(find.text('快捷入口'), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey<String>(
          'enterprise-workbench-display-identification-section',
        ),
      ),
      findsNothing,
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('factory-workbench-activity-empty')),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('最新动态'), findsOneWidget);
    expect(find.text('暂无动态'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('factory-workbench-analytics-empty')),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('数据看板'), findsOneWidget);
    expect(find.text('暂无数据'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('factory-workbench-highlights')),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('工厂亮点'), findsOneWidget);
    expect(find.text('厂房面积'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('company-workbench-module-展示标识')),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('company-workbench-module-展示标识')),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(
        const ValueKey<String>(
          'enterprise-workbench-display-identification-section',
        ),
      ),
      findsOneWidget,
    );
    final factoryNameFinder = find.byKey(
      const ValueKey<String>('enterprise-workbench-factory-name-field'),
    );
    await tester.ensureVisible(factoryNameFinder);
    await tester.pumpAndSettle();
    expect(factoryNameFinder, findsOneWidget);
  });

  testWidgets('supplier workbench uses compact homepage and module drill-in', (
    WidgetTester tester,
  ) async {
    _installWorkbenchDependencies(
      boardType: EnterpriseBoardType.supplier,
      workbenchPayload: _buildSupplierWorkbenchPayload(),
    );

    await _pumpWorkbench(
      tester,
      initialRoute: ExhibitionRoutes.supplierDisplayWorkbench,
    );

    expect(
      find.byKey(const ValueKey<String>('supplier-workbench-homepage')),
      findsOneWidget,
    );
    expect(find.text('供应商展示工作台'), findsOneWidget);
    expect(find.text('重庆坤特展览展示有限公司'), findsOneWidget);
    expect(find.text('模块管理'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('supplier-workbench-homepage-preview')),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('公开展示预览'), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey<String>(
          'enterprise-workbench-display-identification-section',
        ),
      ),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('supplier-workbench-bottom-status')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('supplier-workbench-module-服务能力')),
    );
    await tester.pumpAndSettle();

    expect(find.text('服务能力'), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey<String>(
          'enterprise-workbench-display-identification-section',
        ),
      ),
      findsOneWidget,
    );
    expect(find.text('供应模式'), findsNothing);
  });

  testWidgets('published change mode keeps snapshot corridor after relayout', (
    WidgetTester tester,
  ) async {
    _installPublishedChangeDependencies();

    await _pumpWorkbench(
      tester,
      initialRoute:
          ExhibitionRoutes.enterprisePublishedChangeWorkbenchWithEnterpriseId(
            'ent-published-1',
            boardType: 'company',
          ),
    );

    expect(
      find.byKey(const ValueKey<String>('company-workbench-homepage')),
      findsOneWidget,
    );
    expect(find.text('公司展示工作台'), findsOneWidget);
    expect(find.text('快捷入口'), findsOneWidget);
    final snapshotFinder = find.byKey(
      const ValueKey<String>('enterprise-published-change-snapshot-section'),
    );
    final submitFinder = find.byKey(
      const ValueKey<String>('enterprise-workbench-submit-section'),
    );
    final previewFinder = find.byKey(
      const ValueKey<String>('enterprise-published-change-preview-section'),
    );
    final livePreviewFinder = find.byKey(
      const ValueKey<String>('enterprise-published-live-preview-section'),
    );
    expect(snapshotFinder, findsNothing);
    expect(livePreviewFinder, findsNothing);

    await tester.tap(
      find.byKey(const ValueKey<String>('company-workbench-bottom-status')),
    );
    await tester.pumpAndSettle();

    expect(snapshotFinder, findsOneWidget);
    expect(
      find.byKey(
        const ValueKey<String>('enterprise-published-change-current-snapshot'),
      ),
      findsNothing,
    );
    expect(
      find.byKey(
        const ValueKey<String>('enterprise-published-change-live-snapshot'),
      ),
      findsNothing,
    );
    await tester.tap(
      find.byKey(
        const ValueKey<String>('enterprise-published-change-snapshot-toggle'),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(
        const ValueKey<String>('enterprise-published-change-current-snapshot'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey<String>('enterprise-published-change-live-snapshot'),
      ),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      submitFinder,
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(submitFinder, findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey<String>('company-workbench-quick-preview')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('company-workbench-quick-preview')),
    );
    await tester.pumpAndSettle();

    expect(livePreviewFinder, findsOneWidget);
    expect(find.text('线上公开展示'), findsWidgets);
    await tester.ensureVisible(
      find
          .byKey(
            const ValueKey<String>(
              'enterprise-target-enterprise-info-entry-card',
            ),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find
          .byKey(
            const ValueKey<String>(
              'enterprise-target-enterprise-info-entry-card',
            ),
          )
          .first,
    );
    await tester.pumpAndSettle();
    expect(find.text('企业信息'), findsOneWidget);
    expect(find.text('认证主体'), findsOneWidget);
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('company-workbench-preview-summary')),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(
      find.byKey(
        const ValueKey<String>('company-workbench-preview-draft-entry'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(
        const ValueKey<String>('company-workbench-preview-draft-entry'),
      ),
    );
    await tester.pumpAndSettle();

    expect(previewFinder, findsOneWidget);
    expect(find.text('当前变更稿预览'), findsWidgets);
    expect(find.textContaining('当前变更稿预览优先使用已解析到的 Logo'), findsNothing);
    final previewToggle = find.byKey(
      const ValueKey<String>('enterprise-published-change-preview-toggle'),
    );
    await tester.ensureVisible(previewToggle);
    await tester.pumpAndSettle();
    await tester.tap(previewToggle);
    await tester.pumpAndSettle();
    expect(find.textContaining('当前变更稿预览优先使用已解析到的 Logo'), findsOneWidget);
    await tester.scrollUntilVisible(
      find
          .byKey(
            const ValueKey<String>(
              'enterprise-target-enterprise-info-entry-card',
            ),
          )
          .last,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find
          .byKey(
            const ValueKey<String>(
              'enterprise-target-enterprise-info-entry-card',
            ),
          )
          .last,
    );
    await tester.pumpAndSettle();
    expect(find.text('企业信息'), findsOneWidget);
    expect(find.text('认证主体'), findsOneWidget);
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();
  });

  test('company profile update body preserves hidden legacy fields', () {
    final body = enterpriseWorkbenchCompanyProfileUpdateBody(
      exhibitionTypes: <String>{'特装展台'},
      serviceItems: <String>{'设计搭建'},
      serviceCitiesText: '成都, 重庆',
      maxProjectScaleText: '500 万以内',
      qualificationDescText: '展陈施工二级',
    );

    expect(body['exhibitionTypes'], <String>['特装展台']);
    expect(body['serviceItems'], <String>['设计搭建']);
    expect(body['serviceCities'], <String>['成都', '重庆']);
    expect(body['maxProjectScale'], '500 万以内');
    expect(body['qualificationDesc'], '展陈施工二级');
  });
}

Future<void> _pumpWorkbench(
  WidgetTester tester, {
  required String initialRoute,
}) async {
  final controller = AppBootstrapController(
    bootstrapShellContext: _buildShellContext(),
  );
  controller.initialize();
  await tester.pumpWidget(
    AppShellScope(
      controller: controller,
      child: MaterialApp(
        initialRoute: initialRoute,
        onGenerateRoute: (settings) => MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const Scaffold(body: EnterpriseApplicationPage()),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pumpAndSettle();
}

void _installWorkbenchDependencies({
  EnterpriseBoardType boardType = EnterpriseBoardType.company,
  Map<String, Object?>? workbenchPayload,
}) {
  _installRegionCatalogFixture();
  final workbenchPath = switch (boardType) {
    EnterpriseBoardType.company =>
      '/api/app/exhibition/enterprise-hub/company/workbench',
    EnterpriseBoardType.factory =>
      '/api/app/exhibition/enterprise-hub/factory/workbench',
    EnterpriseBoardType.supplier =>
      '/api/app/exhibition/enterprise-hub/supplier/workbench',
  };
  EnterpriseHubWorkbenchConsumerLayer.install(
    EnterpriseHubWorkbenchConsumerLayer(
      client: AppApiClient(
        transport: FakeAppApiTransport(
          handlers: <String, Future<AppApiResponse> Function(AppApiRequest)>{
            'GET $workbenchPath': (AppApiRequest request) async =>
                AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body:
                      workbenchPayload ??
                      (boardType == EnterpriseBoardType.supplier
                          ? _buildSupplierWorkbenchPayload()
                          : _buildWorkbenchPayload()),
                ),
          },
        ),
      ),
    ),
  );
  ProfileIdentityConsumerLayer.install(_buildProfileIdentityConsumer());
}

void _installPublishedChangeDependencies({
  Map<String, Object?>? workbenchPayload,
  Map<String, Object?>? statusPayload,
  Map<String, Object?>? liveDetailPayload,
}) {
  _installRegionCatalogFixture();
  EnterpriseHubPublishedChangeConsumerLayer.install(
    EnterpriseHubPublishedChangeConsumerLayer(
      client: AppApiClient(
        transport: FakeAppApiTransport(
          handlers: <String, Future<AppApiResponse> Function(AppApiRequest)>{
            'GET /api/app/exhibition/enterprise-hub/company/enterprises/ent-published-1/changes/current':
                (AppApiRequest request) async => AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body:
                      workbenchPayload ??
                      _buildPublishedChangeWorkbenchPayload(),
                ),
            'GET /api/app/exhibition/enterprise-hub/company/enterprises/ent-published-1/changes/current/status':
                (AppApiRequest request) async => AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: statusPayload ?? _buildPublishedChangeStatusPayload(),
                ),
          },
        ),
      ),
    ),
  );
  EnterpriseHubConsumerLayer.install(
    EnterpriseHubConsumerLayer(
      client: AppApiClient(
        transport: FakeAppApiTransport(
          handlers: <String, Future<AppApiResponse> Function(AppApiRequest)>{
            'GET /api/app/exhibition/enterprise-hub/company/enterprises/ent-published-1':
                (AppApiRequest request) async => AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: liveDetailPayload ?? _buildPublishedLiveDetailPayload(),
                ),
            'GET /api/app/exhibition/enterprise-hub/enterprises/ent-published-1/formal-info':
                (AppApiRequest request) async => AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _buildPublishedTargetEnterpriseFormalInfoPayload(),
                ),
          },
        ),
      ),
    ),
  );
  ProfileIdentityConsumerLayer.install(_buildProfileIdentityConsumer());
}

void _installRegionCatalogFixture() {
  ChinaRegionCatalogLoader.installLoadOverrideForTest(
    () async => ChinaRegionCatalog(
      provinces: const <ChinaProvinceOption>[
        ChinaProvinceOption(
          provinceCode: '500000',
          provinceName: '重庆',
          cities: <ChinaCityOption>[
            ChinaCityOption(
              provinceCode: '500000',
              provinceName: '重庆',
              cityCode: '500100',
              cityName: '重庆',
            ),
          ],
        ),
        ChinaProvinceOption(
          provinceCode: '510000',
          provinceName: '四川',
          cities: <ChinaCityOption>[
            ChinaCityOption(
              provinceCode: '510000',
              provinceName: '四川',
              cityCode: '510100',
              cityName: '成都',
            ),
          ],
        ),
      ],
    ),
  );
}

ProfileIdentityConsumerLayer _buildProfileIdentityConsumer() {
  return ProfileIdentityConsumerLayer(
    client: AppApiClient(
      transport: FakeAppApiTransport(
        handlers: <String, Future<AppApiResponse> Function(AppApiRequest)>{
          'GET /api/app/profile/organization/mine':
              (AppApiRequest request) async => AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: const <String, Object?>{
                  'items': <Object?>[
                    <String, Object?>{
                      'organizationId': 'org-1',
                      'name': '西南会展搭建有限公司',
                      'organizationType': 'company',
                      'roleKeys': <String>['company_admin'],
                      'membershipStatus': 'active',
                      'certificationStatus': 'approved',
                      'current': true,
                      'provinceCode': '510000',
                      'cityCode': '510100',
                    },
                  ],
                },
              ),
          'GET /api/app/profile/certification/current':
              (AppApiRequest request) async => AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: const <String, Object?>{
                  'organizationId': 'org-1',
                  'certificationStatus': 'approved',
                  'legalName': '西南会展搭建有限公司',
                  'uscc': '91510100TEST12345',
                  'licenseFileId': 'license-1',
                },
              ),
          'POST /api/app/profile/certification/license/ocr':
              (AppApiRequest request) async => AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: const <String, Object?>{
                  'status': 'recognized',
                  'message': 'ok',
                  'address': '四川省成都市高新区天府大道 1 号',
                  'establishedAt': '2019-09-09',
                },
              ),
        },
      ),
    ),
  );
}

AppShellContextData _buildShellContext() {
  return AppShellContextData(
    userId: 'user-1',
    organizationId: 'org-1',
    certificationStatus: 'verified',
    visibleBuildings: <String>['exhibition', 'messages', 'profile'],
  );
}

Map<String, Object?> _buildWorkbenchPayload() {
  return <String, Object?>{
    'organizationId': 'org-1',
    'enterpriseId': 'ent-company-1',
    'boardType': 'company',
    'latestApplication': const <String, Object?>{
      'applicationId': 'app-1',
      'applicationStatus': 'draft',
    },
    'basic': const <String, Object?>{
      'name': '西南会展搭建有限公司',
      'shortIntro': '承接展陈搭建',
      'fullIntro': '完整介绍',
      'provinceCode': '510000',
      'provinceName': '四川',
      'cityCode': '510100',
      'cityName': '成都',
      'address': '四川省成都市高新区天府大道 1 号',
      'foundedAt': '2019-09-09',
      'cooperationModes': <String>['host_service'],
      'contactVisible': true,
    },
    'boardProfile': const <String, Object?>{
      'exhibitionTypes': <String>['特装展台'],
      'serviceItems': <String>['设计搭建'],
      'serviceCities': <String>['成都'],
    },
    'primaryContact': const <String, Object?>{
      'contactName': '王伟伟',
      'mobile': '13800000000',
      'isPrimary': true,
      'visibleToPublic': true,
    },
    'cases': const <Object?>[],
    'certification': const <String, Object?>{
      'certificationStatus': 'approved',
      'legalName': '西南会展搭建有限公司',
      'uscc': '91510100TEST12345',
      'licenseFileId': 'license-1',
      'submittedAt': '2026-03-01',
      'reviewedAt': '2026-03-05',
    },
    'readiness': const <String, Object?>{
      'hasApplication': true,
      'draftEditable': true,
      'basicCompleted': true,
      'profileCompleted': true,
      'hasCase': false,
      'hasContact': true,
      'certificationApproved': true,
      'submitReady': false,
      'blockers': <String>['请先补案例'],
    },
  };
}

Map<String, Object?> _buildFactoryWorkbenchPayload() {
  return <String, Object?>{
    'organizationId': 'org-1',
    'enterpriseId': 'ent-factory-1',
    'boardType': 'factory',
    'latestApplication': const <String, Object?>{
      'applicationId': 'app-factory-1',
      'applicationStatus': 'draft',
    },
    'basic': const <String, Object?>{
      'name': '重庆海川展览服务有限公司',
      'shortIntro': '主打展台木作与结构制作。',
      'fullIntro': '工厂完整介绍',
      'provinceCode': '500000',
      'provinceName': '重庆',
      'cityCode': '500100',
      'cityName': '重庆',
      'address': '重庆市江北区洋河二村 73 号',
      'foundedAt': '2018-08-08',
      'cooperationModes': <String>['host_service'],
      'contactVisible': true,
    },
    'boardProfile': const <String, Object?>{
      'factoryName': '重庆海川展览工厂',
      'processTypes': <String>['木作'],
      'coreProducts': <String>['展台搭建'],
      'equipmentList': <String>['雕刻机*2'],
      'plantAreaSqm': 1800,
    },
    'primaryContact': const <String, Object?>{
      'contactName': '李工',
      'mobile': '13800000001',
      'isPrimary': true,
      'visibleToPublic': true,
    },
    'cases': const <Object?>[],
    'certification': const <String, Object?>{
      'certificationStatus': 'approved',
      'legalName': '重庆海川展览服务有限公司',
      'uscc': '91500100TEST12345',
      'licenseFileId': 'license-factory-1',
      'submittedAt': '2026-03-01',
      'reviewedAt': '2026-03-05',
    },
    'readiness': const <String, Object?>{
      'hasApplication': true,
      'draftEditable': true,
      'basicCompleted': true,
      'profileCompleted': true,
      'hasCase': false,
      'hasContact': true,
      'certificationApproved': true,
      'submitReady': false,
      'blockers': <String>['请先补案例'],
    },
  };
}

Map<String, Object?> _buildSupplierWorkbenchPayload() {
  return <String, Object?>{
    'organizationId': 'org-1',
    'enterpriseId': 'ent-supplier-1',
    'boardType': 'supplier',
    'latestApplication': const <String, Object?>{
      'applicationId': 'app-supplier-1',
      'applicationStatus': 'draft',
    },
    'basic': const <String, Object?>{
      'name': '重庆坤特展览展示有限公司',
      'shortIntro': '供应展具、家具与多媒体设备。',
      'fullIntro': '供应商完整介绍',
      'provinceCode': '500000',
      'provinceName': '重庆',
      'cityCode': '500100',
      'cityName': '重庆',
      'address': '重庆市南岸区学府大道 33 号',
      'foundedAt': '2018-06-18',
      'teamSizeRange': '31_100',
      'cooperationModes': <String>['host_service', 'long_term_cooperation'],
      'contactVisible': true,
    },
    'boardProfile': const <String, Object?>{
      'supplyCategories': <String>['广告喷绘公司'],
      'coreProductsOrServices': <String>['标准展具', '租赁家具'],
      'responseSlaDesc': '2 小时内响应',
      'deliveryRange': '重庆及周边城市',
    },
    'primaryContact': const <String, Object?>{
      'contactName': '张先生',
      'mobile': '13812345678',
      'isPrimary': true,
      'visibleToPublic': true,
    },
    'cases': const <Object?>[
      <String, Object?>{
        'caseId': 'case-supplier-1',
        'boardType': 'supplier',
        'title': '重庆国际博览会 2024',
        'exhibitionType': '展具租赁',
        'city': '重庆',
        'eventTime': '2024-05-01',
        'summary': '标准展具和现场配送支持。',
        'caseCoverFileAssetId': 'case-cover-1',
        'caseMediaFileAssetIds': <String>['case-cover-1'],
        'isFeatured': true,
        'caseStatus': 'draft',
      },
    ],
    'certification': const <String, Object?>{
      'certificationStatus': 'approved',
      'legalName': '重庆坤特展览展示有限公司',
      'uscc': '91500100TEST12345',
      'licenseFileId': 'license-supplier-1',
      'submittedAt': '2026-03-01',
      'reviewedAt': '2026-03-05',
    },
    'readiness': const <String, Object?>{
      'hasApplication': true,
      'draftEditable': true,
      'basicCompleted': true,
      'profileCompleted': true,
      'hasCase': true,
      'hasContact': true,
      'certificationApproved': true,
      'submitReady': true,
      'blockers': <String>[],
    },
  };
}

Map<String, Object?> _buildPublishedChangeWorkbenchPayload() {
  return <String, Object?>{
    'enterpriseId': 'ent-published-1',
    'boardType': 'company',
    'liveSnapshot': const <String, Object?>{
      'enterpriseStatus': 'published',
      'displayStatus': 'visible',
      'publishedAt': '2026-04-01T08:00:00Z',
    },
    'currentChangeRequest': const <String, Object?>{
      'changeRequestId': 'chg-1',
      'changeStatus': 'draft',
      'submittedAt': '2026-04-10T09:00:00Z',
    },
    'basic': const <String, Object?>{
      'name': '西南会展搭建有限公司',
      'shortIntro': '承接展陈搭建',
      'fullIntro': '完整介绍',
      'provinceCode': '510000',
      'provinceName': '四川',
      'cityCode': '510100',
      'cityName': '成都',
      'address': '四川省成都市高新区天府大道 1 号',
      'foundedAt': '2019-09-09',
      'cooperationModes': <String>['host_service'],
      'contactVisible': true,
    },
    'boardProfile': const <String, Object?>{
      'exhibitionTypes': <String>['特装展台'],
      'serviceItems': <String>['设计搭建'],
    },
    'primaryContact': const <String, Object?>{
      'contactName': '王伟伟',
      'mobile': '13800000000',
      'isPrimary': true,
      'visibleToPublic': true,
    },
    'cases': const <Object?>[],
    'changeReadiness': const <String, Object?>{
      'draftEditable': true,
      'submitReady': false,
      'blockers': <String>['请先补案例'],
    },
  };
}

Map<String, Object?> _buildPublishedChangeStatusPayload() {
  return const <String, Object?>{
    'enterpriseId': 'ent-published-1',
    'changeRequestId': 'chg-1',
    'changeStatus': 'draft',
    'submittedAt': '2026-04-10T09:00:00Z',
  };
}

Map<String, Object?> _buildPublishedLiveDetailPayload() {
  return const <String, Object?>{
    'header': <String, Object?>{
      'enterpriseId': 'ent-published-1',
      'name': '西南会展搭建有限公司',
      'primaryBoardType': 'company',
      'shortIntro': '线上公开公司摘要',
      'provinceName': '四川',
      'cityName': '成都',
      'verificationStatus': 'approved',
      'logoUrl': 'https://example.com/live-logo.png',
    },
    'visualGallery': <String, Object?>{
      'albumImageUrls': <String>[],
      'source': 'enterprise_album',
    },
    'basicInfo': <String, Object?>{
      'fullIntro': '线上公开公司介绍',
      'address': '四川省成都市高新区天府大道 1 号',
    },
    'location': <String, Object?>{
      'provinceName': '四川',
      'cityName': '成都',
      'publicDisplayAddress': '四川省成都市高新区天府大道 1 号',
    },
    'boardProfile': <String, Object?>{
      'exhibitionTypes': <String>['特装展台'],
      'serviceItems': <String>['设计搭建'],
    },
    'serviceAreas': <Object?>[],
    'cases': <Object?>[
      <String, Object?>{
        'id': 'case-live-1',
        'title': 'live 公司案例',
        'summary': '线上公开案例摘要',
        'caseStatus': 'approved',
        'coverImageUrl': 'https://example.com/live-case-cover.png',
        'eventTime': '2026-04-12',
      },
    ],
    'certifications': <Object?>[
      <String, Object?>{
        'type': 'business_license',
        'name': '营业执照',
        'status': 'approved',
      },
    ],
    'reviewSummary': <String, Object?>{'keywordTags': <String>[]},
    'contacts': <Object?>[
      <String, Object?>{'contactName': '王伟伟', 'mobile': '13800000000'},
    ],
  };
}

Map<String, Object?> _buildPublishedTargetEnterpriseFormalInfoPayload() {
  return const <String, Object?>{
    'enterpriseId': 'ent-published-1',
    'legalName': '西南会展搭建有限公司',
    'uscc': '91510100TEST12345',
    'legalPerson': '李工',
    'businessType': '有限责任公司',
    'address': '四川省成都市高新区天府大道 1 号',
    'registeredCapital': '500 万元',
    'establishedAt': '2019-09-09',
    'businessTerm': '2019-09-09 至 2039-09-09',
    'businessScope': '展陈搭建、活动执行、空间设计。',
    'certificationStatus': 'approved',
  };
}
