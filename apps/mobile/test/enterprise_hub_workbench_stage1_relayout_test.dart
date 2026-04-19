import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/boot/app_bootstrap_controller.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_published_change_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_workbench_consumer_layer.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_workbench_pages.dart';
import 'package:mobile/features/profile/data/profile_identity_consumer_layer.dart';
import 'package:mobile/shell/context/app_shell_scope.dart';

void main() {
  tearDown(() {
    EnterpriseHubConsumerLayer.reset();
    EnterpriseHubPublishedChangeConsumerLayer.reset();
    EnterpriseHubWorkbenchConsumerLayer.reset();
    ProfileIdentityConsumerLayer.reset();
  });

  testWidgets('company workbench uses the stage-1 relayout skeleton', (
    WidgetTester tester,
  ) async {
    _installWorkbenchDependencies();

    await _pumpWorkbench(
      tester,
      initialRoute: ExhibitionRoutes.companyDisplayWorkbench,
    );

    final headerFinder = find.byKey(
      const ValueKey<String>('enterprise-workbench-header-section'),
    );
    final displayFinder = find.byKey(
      const ValueKey<String>(
        'enterprise-workbench-display-identification-section',
      ),
    );
    final albumFinder = find.byKey(
      const ValueKey<String>('enterprise-workbench-album-section'),
    );
    final mapFinder = find.byKey(
      const ValueKey<String>('enterprise-workbench-map-location-section'),
    );
    final basicFinder = find.byKey(
      const ValueKey<String>('enterprise-workbench-basic-section'),
    );
    final submitFinder = find.byKey(
      const ValueKey<String>('enterprise-workbench-submit-section'),
    );

    expect(headerFinder, findsOneWidget);
    expect(displayFinder, findsOneWidget);
    expect(
      tester.getTopLeft(headerFinder).dy,
      lessThan(tester.getTopLeft(displayFinder).dy),
    );
    expect(find.text('公司名称'), findsOneWidget);
    expect(find.text('公司位置'), findsOneWidget);
    expect(find.text('公司信用评分（建设中）'), findsOneWidget);
    expect(find.text('服务城市（逗号分隔）'), findsNothing);
    expect(find.text('最大项目规模'), findsNothing);
    expect(find.text('资质说明'), findsNothing);
    await tester.scrollUntilVisible(
      albumFinder,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(albumFinder, findsOneWidget);
    await tester.scrollUntilVisible(
      mapFinder,
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(mapFinder, findsOneWidget);
    expect(find.text('位置补充说明（选填）'), findsOneWidget);
    await tester.scrollUntilVisible(
      basicFinder,
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(basicFinder, findsOneWidget);
    expect(find.text('一句话简介'), findsNothing);
    expect(find.text('公司介绍（2000字以内）'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('公开展示联系人'),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('公开展示联系人'), findsOneWidget);
    await tester.scrollUntilVisible(
      submitFinder,
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(submitFinder, findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is SegmentedButton<EnterpriseBoardType>,
      ),
      findsNothing,
    );
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

    expect(find.text('公司展示变更工作台'), findsOneWidget);
    final snapshotFinder = find.byKey(
      const ValueKey<String>('enterprise-published-change-snapshot-section'),
    );
    final displayFinder = find.byKey(
      const ValueKey<String>(
        'enterprise-workbench-display-identification-section',
      ),
    );
    final albumFinder = find.byKey(
      const ValueKey<String>('enterprise-workbench-album-section'),
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
    expect(snapshotFinder, findsOneWidget);
    expect(livePreviewFinder, findsOneWidget);
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
      livePreviewFinder,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(livePreviewFinder, findsOneWidget);
    expect(find.text('线上公开展示'), findsOneWidget);
    await tester.scrollUntilVisible(
      previewFinder,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(previewFinder, findsOneWidget);
    expect(find.text('当前变更稿预览'), findsOneWidget);
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
      displayFinder,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(displayFinder, findsOneWidget);
    await tester.scrollUntilVisible(
      albumFinder,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(albumFinder, findsOneWidget);
    await tester.scrollUntilVisible(
      submitFinder,
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(submitFinder, findsOneWidget);
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

void _installWorkbenchDependencies({Map<String, Object?>? workbenchPayload}) {
  EnterpriseHubWorkbenchConsumerLayer.install(
    EnterpriseHubWorkbenchConsumerLayer(
      client: AppApiClient(
        transport: FakeAppApiTransport(
          handlers: <String, Future<AppApiResponse> Function(AppApiRequest)>{
            'GET /api/app/exhibition/enterprise-hub/company/workbench':
                (AppApiRequest request) async => AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: workbenchPayload ?? _buildWorkbenchPayload(),
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
          },
        ),
      ),
    ),
  );
  ProfileIdentityConsumerLayer.install(_buildProfileIdentityConsumer());
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
