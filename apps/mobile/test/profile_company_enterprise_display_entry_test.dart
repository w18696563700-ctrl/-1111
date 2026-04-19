import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_published_change_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_workbench_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_identity_consumer_layer.dart';
import 'profile_private_operating_system_test_support.dart';

void main() {
  tearDown(() {
    EnterpriseHubConsumerLayer.reset();
    EnterpriseHubPublishedChangeConsumerLayer.reset();
    EnterpriseHubWorkbenchConsumerLayer.reset();
    ProfileIdentityConsumerLayer.reset();
  });

  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  Map<String, Object?> buildFactoryWorkbenchPayload({
    required String latestApplicationStatus,
  }) {
    return <String, Object?>{
      'organizationId': 'org-1',
      'enterpriseId': 'factory-1',
      'boardType': 'factory',
      'latestApplication': <String, Object?>{
        'applicationId': 'app-1',
        'applicationStatus': latestApplicationStatus,
      },
      'basic': <String, Object?>{
        'name': '华东展览制作工厂',
        'shortIntro': '覆盖木作、美工与桁架制作。',
        'provinceCode': '320000',
        'provinceName': '江苏',
        'cityCode': '320500',
        'cityName': '苏州',
      },
      'boardProfile': <String, Object?>{
        'processTypes': <String>['木作制作'],
        'coreProducts': <String>['桁架结构'],
        'equipmentList': <String>['UV 喷绘'],
        'monthlyCapacityDesc': '月产能 20 场',
        'deliveryRadiusDesc': '江浙沪',
        'warehouseCapability': true,
      },
      'primaryContact': <String, Object?>{
        'contactName': '张工',
        'mobile': '13800000000',
        'isPrimary': true,
        'visibleToPublic': true,
      },
      'cases': <Object?>[
        <String, Object?>{
          'caseId': 'case-1',
          'boardType': 'factory',
          'title': '苏州汽车展木作案例',
          'summary': '完成木作与桁架制作。',
          'caseCoverFileAssetId': 'file-cover-1',
          'caseMediaFileAssetIds': <String>[],
          'isFeatured': true,
          'caseStatus': 'published',
        },
      ],
      'certification': <String, Object?>{
        'certificationStatus': 'approved',
      },
      'readiness': <String, Object?>{
        'hasApplication': true,
        'draftEditable': latestApplicationStatus == 'draft',
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

  Map<String, Object?> buildPublishedChangeWorkbenchPayload() {
    return <String, Object?>{
      'enterpriseId': 'factory-1',
      'boardType': 'factory',
      'liveSnapshot': <String, Object?>{
        'enterpriseStatus': 'published',
        'displayStatus': 'visible',
        'publishedAt': '2026-04-19T10:00:00Z',
      },
      'currentChangeRequest': <String, Object?>{
        'changeRequestId': 'change-1',
        'changeStatus': 'draft',
      },
      'basic': <String, Object?>{
        'name': 'current change 工厂档案',
        'shortIntro': '当前变更稿摘要',
        'fullIntro': '当前变更稿详情',
        'provinceCode': '500000',
        'provinceName': '重庆',
        'cityCode': '500100',
        'cityName': '重庆',
        'address': '重庆市渝北区测试地址 1 号',
        'albumImageFileAssetIds': <String>[],
        'albumImageUrlMap': <String, String>{},
      },
      'boardProfile': <String, Object?>{
        'factoryName': 'current change 工厂档案',
        'showcaseImageFileAssetIds': <String>[],
        'showcaseImageUrlMap': <String, String>{},
      },
      'primaryContact': <String, Object?>{
        'contactName': '李工',
        'mobile': '13900000000',
        'isPrimary': true,
        'visibleToPublic': true,
      },
      'cases': <Object?>[
        <String, Object?>{
          'caseId': 'case-current-1',
          'boardType': 'factory',
          'title': 'current change 工厂案例',
          'summary': '当前变更稿中的案例',
          'caseCoverFileAssetId': 'file-current-cover-1',
          'caseMediaFileAssetIds': <String>['file-current-cover-1'],
          'caseImageUrlMap': <String, String>{
            'file-current-cover-1': 'https://example.com/current-case-cover.jpg',
          },
          'isFeatured': true,
          'caseStatus': 'approved',
        },
      ],
      'changeReadiness': <String, Object?>{
        'draftEditable': true,
        'submitReady': true,
        'blockers': <String>[],
      },
    };
  }

  Map<String, Object?> buildPublishedChangeStatusPayload() {
    return <String, Object?>{
      'enterpriseId': 'factory-1',
      'changeRequestId': 'change-1',
      'changeStatus': 'draft',
    };
  }

  testWidgets(
    'my building enterprise display asset entries sit below forum and factory lands on workbench',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      installDefaultPrivateOperatingSystemSupportConsumers();

      EnterpriseHubWorkbenchConsumerLayer.install(
        EnterpriseHubWorkbenchConsumerLayer(
          client: AppApiClient(
            transport: FakeAppApiTransport(
              handlers:
                  <
                    String,
                    Future<AppApiResponse> Function(AppApiRequest request)
                  >{
                    'GET /api/app/exhibition/enterprise-hub/workbench':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: buildFactoryWorkbenchPayload(
                              latestApplicationStatus: 'draft',
                            ),
                          );
                        },
                  },
            ),
          ),
        ),
      );
      ProfileIdentityConsumerLayer.install(
        ProfileIdentityConsumerLayer(
          client: AppApiClient(
            transport: FakeAppApiTransport(
              handlers:
                  <
                    String,
                    Future<AppApiResponse> Function(AppApiRequest request)
                  >{
                    'GET /api/app/profile/organization/mine':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: const <String, Object?>{
                              'items': <Object?>[
                                <String, Object?>{
                                  'organizationId': 'org-1',
                                  'name': '华东展览制作工厂',
                                  'organizationType': 'company',
                                  'roleKeys': <String>['supplier_admin'],
                                  'membershipStatus': 'active',
                                  'certificationStatus': 'approved',
                                  'current': true,
                                  'provinceCode': '320000',
                                  'cityCode': '320500',
                                },
                              ],
                            },
                          );
                        },
                    'GET /api/app/profile/certification/current':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: const <String, Object?>{
                              'organizationId': 'org-1',
                              'certificationStatus': 'approved',
                              'legalName': '华东展览制作工厂',
                              'uscc': '91320000TEST00001',
                              'licenseFileId': 'license-1',
                            },
                          );
                        },
                    'POST /api/app/profile/certification/license/ocr':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: const <String, Object?>{
                              'status': 'recognized',
                              'message': 'ok',
                              'address': '江苏省苏州市工业园区星湖街 1 号',
                              'establishedAt': '2018-05-06',
                            },
                          );
                        },
                  },
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        buildPrivateOperatingSystemProfileApp(
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/profile/index': (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: privateOperatingSystemProfilePayload(
                        organizationId: 'org-1',
                        roleKeys: const <String>['supplier_admin'],
                        certificationStatus: 'approved',
                        membershipStatus: 'active',
                      ),
                    );
                  },
                },
          ),
          shellContext: privateOperatingSystemShellContextData(
            organizationId: 'org-1',
            roleKeys: const <String>['supplier_admin'],
            certificationStatus: 'approved',
            membershipStatus: 'active',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('我的论坛'));
      final forumTop = tester.getTopLeft(find.text('我的论坛')).dy;
      await scrollTo(tester, find.text('我的个人/团队展示'));
      final companyTop = tester.getTopLeft(find.text('我的公司展示')).dy;
      final factoryTop = tester.getTopLeft(find.text('我的工厂展示')).dy;
      final supplierTop = tester.getTopLeft(find.text('我的供应商展示')).dy;
      final personalTeamTop = tester.getTopLeft(find.text('我的个人/团队展示')).dy;
      expect(companyTop, greaterThan(forumTop));
      expect(factoryTop, greaterThan(companyTop));
      expect(supplierTop, greaterThan(factoryTop));
      expect(personalTeamTop, greaterThan(supplierTop));

      await tester.tap(find.text('我的工厂展示'));
      await tester.pumpAndSettle();

      expect(find.text('工厂展示工作台'), findsOneWidget);
      expect(find.text('优秀工厂工作台'), findsOneWidget);
    },
  );

  testWidgets(
    'factory asset entry prefers published change corridor after post-submit',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      installDefaultPrivateOperatingSystemSupportConsumers();

      EnterpriseHubWorkbenchConsumerLayer.install(
        EnterpriseHubWorkbenchConsumerLayer(
          client: AppApiClient(
            transport: FakeAppApiTransport(
              handlers:
                  <
                    String,
                    Future<AppApiResponse> Function(AppApiRequest request)
                  >{
                    'GET /api/app/exhibition/enterprise-hub/workbench':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: buildFactoryWorkbenchPayload(
                              latestApplicationStatus: 'approved',
                            ),
                          );
                        },
                  },
            ),
          ),
        ),
      );
      EnterpriseHubPublishedChangeConsumerLayer.install(
        EnterpriseHubPublishedChangeConsumerLayer(
          client: AppApiClient(
            transport: FakeAppApiTransport(
              handlers:
                  <
                    String,
                    Future<AppApiResponse> Function(AppApiRequest request)
                  >{
                    'GET /api/app/exhibition/enterprise-hub/enterprises/factory-1/changes/current':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: buildPublishedChangeWorkbenchPayload(),
                          );
                        },
                    'GET /api/app/exhibition/enterprise-hub/enterprises/factory-1/changes/current/status':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: buildPublishedChangeStatusPayload(),
                          );
                        },
                  },
            ),
          ),
        ),
      );
      EnterpriseHubConsumerLayer.install(
        EnterpriseHubConsumerLayer(
          client: AppApiClient(
            transport: FakeAppApiTransport(
              handlers:
                  <
                    String,
                    Future<AppApiResponse> Function(AppApiRequest request)
                  >{
                    'GET /api/app/exhibition/enterprise-hub/enterprises/factory-1':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: const <String, Object?>{
                              'header': <String, Object?>{
                                'enterpriseId': 'factory-1',
                                'name': '重庆海川展览工厂',
                                'primaryBoardType': 'factory',
                                'shortIntro': '主打展台木作与结构制作。',
                                'provinceName': '重庆市',
                                'cityName': '重庆市',
                                'verificationStatus': 'approved',
                                'logoUrl':
                                    'https://example.com/live-factory-logo.png',
                              },
                              'visualGallery': <String, Object?>{
                                'albumImageUrls': <String>[],
                                'source': 'enterprise_album',
                              },
                              'basicInfo': <String, Object?>{
                                'fullIntro': '线上公开工厂介绍',
                                'address': '重庆市江北区洋河二村 73 号',
                              },
                              'location': <String, Object?>{
                                'provinceName': '重庆市',
                                'cityName': '重庆市',
                                'publicDisplayAddress': '重庆市江北区洋河二村 73 号',
                              },
                              'boardProfile': <String, Object?>{
                                'factoryName': '重庆海川展览工厂',
                                'processTypes': <String>['木作'],
                                'coreProducts': <String>['展台搭建'],
                                'showcaseImageUrls': <String>[
                                  'https://example.com/live-showcase-1.png',
                                ],
                              },
                              'serviceAreas': <Object?>[],
                              'cases': <Object?>[
                                <String, Object?>{
                                  'id': 'case-live-1',
                                  'title': 'live 工厂案例',
                                  'summary': '线上公开案例摘要',
                                  'caseStatus': 'approved',
                                  'coverImageUrl':
                                      'https://example.com/live-case-cover.png',
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
                              'reviewSummary': <String, Object?>{
                                'keywordTags': <String>[],
                              },
                              'contacts': <Object?>[
                                <String, Object?>{
                                  'contactName': '李工',
                                  'mobile': '13900000000',
                                },
                              ],
                            },
                          );
                        },
                  },
            ),
          ),
        ),
      );
      ProfileIdentityConsumerLayer.install(
        ProfileIdentityConsumerLayer(
          client: AppApiClient(
            transport: FakeAppApiTransport(
              handlers:
                  <
                    String,
                    Future<AppApiResponse> Function(AppApiRequest request)
                  >{
                    'GET /api/app/profile/organization/mine':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: const <String, Object?>{
                              'items': <Object?>[
                                <String, Object?>{
                                  'organizationId': 'org-1',
                                  'name': '华东展览制作工厂',
                                  'organizationType': 'company',
                                  'roleKeys': <String>['supplier_admin'],
                                  'membershipStatus': 'active',
                                  'certificationStatus': 'approved',
                                  'current': true,
                                  'provinceCode': '320000',
                                  'cityCode': '320500',
                                },
                              ],
                            },
                          );
                        },
                    'GET /api/app/profile/certification/current':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: const <String, Object?>{
                              'organizationId': 'org-1',
                              'certificationStatus': 'approved',
                              'legalName': '华东展览制作工厂',
                              'uscc': '91320000TEST00001',
                              'licenseFileId': 'license-1',
                            },
                          );
                        },
                    'POST /api/app/profile/certification/license/ocr':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: const <String, Object?>{
                              'status': 'recognized',
                              'message': 'ok',
                              'address': '江苏省苏州市工业园区星湖街 1 号',
                              'establishedAt': '2018-05-06',
                            },
                          );
                        },
                  },
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        buildPrivateOperatingSystemProfileApp(
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/profile/index': (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: privateOperatingSystemProfilePayload(
                        organizationId: 'org-1',
                        roleKeys: const <String>['supplier_admin'],
                        certificationStatus: 'approved',
                        membershipStatus: 'active',
                      ),
                    );
                  },
                },
          ),
          shellContext: privateOperatingSystemShellContextData(
            organizationId: 'org-1',
            roleKeys: const <String>['supplier_admin'],
            certificationStatus: 'approved',
            membershipStatus: 'active',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('我的工厂展示'));
      await tester.tap(find.text('我的工厂展示'));
      await tester.pumpAndSettle();

      expect(find.text('工厂展示工作台'), findsOneWidget);
      expect(find.text('优秀工厂变更工作台'), findsOneWidget);
      expect(find.text('线上公开展示'), findsOneWidget);
      await scrollTo(tester, find.text('当前变更稿预览'));
      expect(find.text('当前变更稿预览'), findsOneWidget);
      expect(
        find.textContaining('当前变更稿预览优先使用已解析到的 Logo'),
        findsNothing,
      );
      await tester.tap(
        find.byKey(
          const ValueKey<String>('enterprise-published-change-preview-toggle'),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.textContaining('当前变更稿预览优先使用已解析到的 Logo'),
        findsOneWidget,
      );
    },
  );

  testWidgets('personal team asset entry stays controlled placeholder', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    installDefaultPrivateOperatingSystemSupportConsumers();

    await tester.pumpWidget(
      buildPrivateOperatingSystemProfileApp(
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'GET /api/app/profile/index': (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: privateOperatingSystemProfilePayload(
                      organizationId: 'org-1',
                      roleKeys: const <String>['supplier_admin'],
                      certificationStatus: 'approved',
                      membershipStatus: 'active',
                    ),
                  );
                },
              },
        ),
        shellContext: privateOperatingSystemShellContextData(
          organizationId: 'org-1',
          roleKeys: const <String>['supplier_admin'],
          certificationStatus: 'approved',
          membershipStatus: 'active',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await scrollTo(tester, find.text('我的个人/团队展示'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('我的个人/团队展示'));
    await tester.pumpAndSettle();

    expect(find.text('个人/团队展示工作台正在接通，当前先保留选择位。'), findsOneWidget);
  });
}
