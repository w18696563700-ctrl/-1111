import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/core/location/china_region_catalog.dart';
import 'package:mobile/core/location/device_location_service.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/exhibition_home_aggregation_client.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_published_change_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_workbench_consumer_layer.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/exhibition/presentation/presentation_support/external_map_launcher.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_workbench_pages.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_workbench_widgets.dart';
import 'package:mobile/features/profile/data/profile_identity_consumer_layer.dart';
import 'package:mobile/shell/shell_app.dart';

void main() {
  test('external map candidates keep app schemes before web fallback', () {
    final candidates = externalMapCandidateUrls(
      latitude: 30.5728,
      longitude: 104.0668,
      address: '四川省成都市高新区天府大道 1 号',
      mapLinkUrl: 'https://uri.amap.com/marker?position=104.0668,30.5728',
    );

    expect(candidates, isNotEmpty);
    expect(
      candidates.last,
      'https://uri.amap.com/marker?position=104.0668,30.5728',
    );
    expect(
      candidates.any(
        (String candidate) =>
            candidate.startsWith('geo:') ||
            candidate.startsWith('maps://') ||
            candidate.startsWith('http://maps.apple.com'),
      ),
      isTrue,
    );
  });

  tearDown(() {
    resetEnterpriseWorkbenchPlacemarkLookup();
    ChinaRegionCatalogLoader.reset();
    EnterpriseHubConsumerLayer.reset();
    EnterpriseHubPublishedChangeConsumerLayer.reset();
    EnterpriseHubWorkbenchConsumerLayer.reset();
    ProfileIdentityConsumerLayer.reset();
    DeviceLocationService.reset();
  });

  Map<String, Object?> buildWorkbenchPayload({
    String boardType = 'company',
    String? enterpriseId = 'ent-company-1',
    String latestApplicationStatus = 'draft',
    String? latestApplicationReviewedAt,
    String? latestApplicationRejectionReason,
    String? name = '西南会展搭建有限公司',
    String shortIntro = '承接展陈搭建',
    String fullIntro = '完整介绍',
    String? provinceCode = '510000',
    String? provinceName = '四川',
    String? cityCode = '510100',
    String? cityName = '成都',
    String? address = '四川省成都市高新区天府大道 1 号',
    String? foundedAt = '2019-09-09',
    List<String> albumImageFileAssetIds = const <String>[],
    List<String> serviceCities = const <String>['成都'],
    List<Object?>? cases,
    String certificationStatus = 'approved',
    bool submitReady = true,
    List<String> blockers = const <String>[],
  }) {
    final boardProfile = switch (boardType) {
      'supplier' => <String, Object?>{
        'supplyCategories': <String>['桁架舞台搭建厂'],
        'coreProductsOrServices': <String>['标准展具'],
        'responseSlaDesc': '2小时内响应',
        'deliveryRange': '西南地区',
      },
      _ => <String, Object?>{
        'exhibitionTypes': <String>['特装展台'],
        'serviceItems': <String>['设计搭建'],
        'serviceCities': serviceCities,
      },
    };
    return <String, Object?>{
      'organizationId': 'org-1',
      'enterpriseId': enterpriseId,
      'boardType': boardType,
      if (enterpriseId != null)
        'latestApplication': <String, Object?>{
          'applicationId': 'app-1',
          'applicationStatus': latestApplicationStatus,
          if (latestApplicationReviewedAt case final String value)
            'reviewedAt': value,
          if (latestApplicationRejectionReason case final String value)
            'rejectionReason': value,
        },
      'basic': <String, Object?>{
        'name': name,
        'shortIntro': shortIntro,
        'fullIntro': fullIntro,
        'provinceCode': provinceCode,
        'provinceName': provinceName,
        'cityCode': cityCode,
        'cityName': cityName,
        'address': address,
        'foundedAt': foundedAt,
        'cooperationModes': <String>['host_service'],
        'contactVisible': true,
        'albumImageFileAssetIds': albumImageFileAssetIds,
      },
      'boardProfile': boardProfile,
      'primaryContact': <String, Object?>{
        'contactName': '王伟伟',
        'mobile': '13800000000',
        'isPrimary': true,
        'visibleToPublic': true,
      },
      'cases':
          cases ??
          const <Object?>[
            <String, Object?>{
              'caseId': 'case-1',
              'boardType': 'company',
              'title': '成都车展案例',
              'summary': '展台搭建案例',
              'caseCoverFileAssetId': 'file-cover-1',
              'caseMediaFileAssetIds': <String>['file-media-1'],
              'isFeatured': true,
              'caseStatus': 'draft',
            },
          ],
      'certification': <String, Object?>{
        'certificationStatus': certificationStatus,
        'legalName': '西南会展搭建有限公司',
        'uscc': '91510100TEST12345',
        'licenseFileId': 'license-1',
        'submittedAt': '2026-03-01',
        'reviewedAt': '2026-03-05',
      },
      'readiness': <String, Object?>{
        'hasApplication': enterpriseId != null,
        'draftEditable': enterpriseId != null,
        'basicCompleted': true,
        'profileCompleted': true,
        'hasCase': (cases ?? const <Object?>[1]).isNotEmpty,
        'hasContact': true,
        'certificationApproved':
            certificationStatus == 'approved' ||
            certificationStatus == 'verified',
        'submitReady': submitReady,
        'blockers': blockers,
      },
    };
  }

  Map<String, Object?> buildFactoryWorkbenchPayload({
    String? enterpriseId = 'ent-factory-1',
    String latestApplicationStatus = 'draft',
    String factoryName = '海川旧工厂',
    List<String> processTypes = const <String>['木作'],
    List<String> showcaseImageFileAssetIds = const <String>['file-factory-1'],
  }) {
    return <String, Object?>{
      'organizationId': 'org-1',
      'enterpriseId': enterpriseId,
      if (enterpriseId != null)
        'latestApplication': <String, Object?>{
          'applicationId': 'app-factory-1',
          'applicationStatus': latestApplicationStatus,
        },
      'boardType': 'factory',
      'basic': const <String, Object?>{
        'name': '重庆坤特展览展示有限公司',
        'shortIntro': '承接工厂制作与配套运输',
        'fullIntro': '完整介绍',
        'provinceCode': '500000',
        'provinceName': '重庆',
        'cityCode': '500100',
        'cityName': '重庆',
        'address': '重庆市渝北区金开大道 1 号',
        'foundedAt': '2016-03-30',
        'cooperationModes': <String>['host_service'],
        'contactVisible': true,
      },
      'boardProfile': <String, Object?>{
        'factoryName': factoryName,
        'processTypes': processTypes,
        'coreProducts': <String>['旧核心产品'],
        'equipmentList': <String>['雕刻机*1'],
        'showcaseImageFileAssetIds': showcaseImageFileAssetIds,
        'plantAreaSqm': 1200,
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
        'legalName': '重庆坤特展览展示有限公司',
        'uscc': '91500105MA5U58K346',
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

  Future<void> scrollCompanyHomepageUntilVisible(
    WidgetTester tester,
    Finder finder, {
    Offset step = const Offset(0, -360),
  }) async {
    Finder homepageList = find.byKey(
      const ValueKey<String>('company-workbench-homepage'),
    );
    if (homepageList.evaluate().isEmpty) {
      homepageList = find.byKey(
        const ValueKey<String>('factory-workbench-homepage'),
      );
    }
    for (var index = 0; index < 12 && finder.evaluate().isEmpty; index += 1) {
      await tester.drag(homepageList, step);
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(finder, findsOneWidget);
  }

  Future<void> openCompanyWorkbenchModule(
    WidgetTester tester,
    String title,
  ) async {
    final moduleFinder = find.byKey(
      ValueKey<String>('company-workbench-module-$title'),
    );
    await scrollCompanyHomepageUntilVisible(tester, moduleFinder);
    await Scrollable.ensureVisible(
      tester.element(moduleFinder),
      alignment: 0.5,
    );
    await tester.pumpAndSettle();
    await tester.tap(moduleFinder);
    await tester.pumpAndSettle();
  }

  Future<void> openCompanyStatusModule(WidgetTester tester) async {
    final statusFinder = find.byKey(
      const ValueKey<String>('company-workbench-bottom-status'),
    );
    await tester.ensureVisible(statusFinder);
    await tester.pumpAndSettle();
    await tester.tap(statusFinder);
    await tester.pumpAndSettle();
  }

  Future<void> popTopRoute(WidgetTester tester) async {
    Navigator.of(tester.element(find.byType(Scaffold).last)).pop();
    await tester.pumpAndSettle();
  }

  Map<String, Object?> buildCaseDetailPayload({
    String caseId = 'case-1',
    String enterpriseId = 'ent-company-1',
    String boardType = 'company',
    String title = '2026 重庆工厂案例',
    String exhibitionType = '工厂开放日',
    String city = '重庆',
    String eventTime = '2026-05-18',
    String summary = '更新后的案例摘要',
    String? caseCoverFileAssetId = 'file-cover-9',
    List<String> caseMediaFileAssetIds = const <String>['file-media-9'],
    Map<String, String> caseImageUrlMap = const <String, String>{
      'file-cover-9': 'https://example.com/file-cover-9.png',
      'file-media-9': 'https://example.com/file-media-9.png',
    },
    bool isFeatured = true,
    String caseStatus = 'draft',
  }) {
    return <String, Object?>{
      'caseId': caseId,
      'enterpriseId': enterpriseId,
      'boardType': boardType,
      'title': title,
      'exhibitionType': exhibitionType,
      'city': city,
      'eventTime': eventTime,
      'summary': summary,
      'caseCoverFileAssetId': caseCoverFileAssetId,
      'caseMediaFileAssetIds': caseMediaFileAssetIds,
      'caseImageUrlMap': caseImageUrlMap,
      'isFeatured': isFeatured,
      'caseStatus': caseStatus,
    };
  }

  Map<String, Object?> buildPublishedChangeWorkbenchPayload({
    String enterpriseId = 'ent-published-1',
    String boardType = 'company',
    String changeStatus = 'draft',
    String? rejectionReason,
    bool submitReady = true,
    List<String> blockers = const <String>[],
    List<String> albumImageFileAssetIds = const <String>[],
    Map<String, Object?>? boardProfile,
    List<Object?> cases = const <Object?>[
      <String, Object?>{
        'caseId': 'case-published-1',
        'boardType': 'company',
        'title': '已发布展示案例',
        'exhibitionType': '展馆活动',
        'city': '成都',
        'eventTime': '2026-05-01',
        'summary': '当前变更中的案例摘要',
        'caseCoverFileAssetId': 'file-published-cover-1',
        'caseMediaFileAssetIds': <String>[
          'file-published-cover-1',
          'file-published-media-1',
        ],
        'isFeatured': true,
        'caseStatus': 'approved',
      },
    ],
  }) {
    return <String, Object?>{
      'enterpriseId': enterpriseId,
      'boardType': boardType,
      'liveSnapshot': const <String, Object?>{
        'enterpriseStatus': 'published',
        'displayStatus': 'visible',
        'publishedAt': '2026-04-01T08:00:00Z',
      },
      'currentChangeRequest': <String, Object?>{
        'changeRequestId': 'chg-1',
        'changeStatus': changeStatus,
        'submittedAt': '2026-04-10T09:00:00Z',
        if (changeStatus != 'draft') 'reviewedAt': '2026-04-11T10:00:00Z',
        if (rejectionReason case final String value) 'rejectionReason': value,
      },
      'basic': <String, Object?>{
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
        'albumImageFileAssetIds': albumImageFileAssetIds,
      },
      'boardProfile':
          boardProfile ??
          switch (boardType) {
            'factory' => <String, Object?>{
              'factoryName': 'current change 工厂档案',
              'processTypes': <String>['木作'],
              'coreProducts': <String>['current 核心产品'],
              'equipmentList': <String>['雕刻机*2'],
              'showcaseImageFileAssetIds': <String>['file-factory-2'],
              'plantAreaSqm': 1800,
            },
            _ => <String, Object?>{
              'exhibitionTypes': <String>['特装展台'],
              'serviceItems': <String>['设计搭建'],
              'serviceCities': <String>['成都'],
            },
          },
      'primaryContact': const <String, Object?>{
        'contactName': '王伟伟',
        'mobile': '13800000000',
        'isPrimary': true,
        'visibleToPublic': true,
      },
      'cases': cases,
      'changeReadiness': <String, Object?>{
        'draftEditable': true,
        'submitReady': submitReady,
        'blockers': blockers,
      },
    };
  }

  Map<String, Object?> buildPublishedChangeStatusPayload({
    String enterpriseId = 'ent-published-1',
    String changeRequestId = 'chg-1',
    String changeStatus = 'draft',
    String? rejectionReason,
  }) {
    return <String, Object?>{
      'enterpriseId': enterpriseId,
      'changeRequestId': changeRequestId,
      'changeStatus': changeStatus,
      'submittedAt': '2026-04-10T09:00:00Z',
      if (changeStatus != 'draft') 'reviewedAt': '2026-04-11T10:00:00Z',
      if (rejectionReason case final String value) 'rejectionReason': value,
    };
  }

  Map<String, Object?> buildPublishedLiveDetailPayload({
    String enterpriseId = 'ent-published-1',
    String boardType = 'company',
  }) {
    return <String, Object?>{
      'header': <String, Object?>{
        'enterpriseId': enterpriseId,
        'name': boardType == 'factory' ? '重庆海川展览工厂' : '西南会展搭建有限公司',
        'primaryBoardType': boardType,
        'shortIntro': boardType == 'factory' ? '主打展台木作与结构制作。' : '承接展陈搭建',
        'provinceName': boardType == 'factory' ? '重庆市' : '四川',
        'cityName': boardType == 'factory' ? '重庆市' : '成都',
        'verificationStatus': 'approved',
        'logoUrl': 'https://example.com/live-logo.png',
      },
      'visualGallery': <String, Object?>{
        'albumImageUrls': <String>[],
        'source': 'enterprise_album',
      },
      'basicInfo': <String, Object?>{
        'fullIntro': boardType == 'factory' ? '工厂线上公开介绍' : '公司线上公开介绍',
        'address': boardType == 'factory'
            ? '重庆市江北区洋河二村 73 号'
            : '四川省成都市高新区天府大道 1 号',
      },
      'location': <String, Object?>{
        'provinceName': boardType == 'factory' ? '重庆市' : '四川',
        'cityName': boardType == 'factory' ? '重庆市' : '成都',
        'publicDisplayAddress': boardType == 'factory'
            ? '重庆市江北区洋河二村 73 号'
            : '四川省成都市高新区天府大道 1 号',
      },
      'boardProfile': boardType == 'factory'
          ? <String, Object?>{
              'factoryName': '重庆海川展览工厂',
              'processTypes': <String>['木作'],
              'coreProducts': <String>['展台搭建'],
              'showcaseImageUrls': <String>[
                'https://example.com/live-showcase-1.png',
              ],
            }
          : <String, Object?>{
              'exhibitionTypes': <String>['特装展台'],
              'serviceItems': <String>['设计搭建'],
            },
      'serviceAreas': <Object?>[],
      'cases': <Object?>[
        <String, Object?>{
          'id': 'case-live-1',
          'title': boardType == 'factory' ? 'live 工厂案例' : 'live 公司案例',
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

  AppShellContextData buildEnterpriseShellContext() {
    return AppShellContextData(
      userId: 'user-1',
      organizationId: 'org-1',
      certificationStatus: 'verified',
      visibleBuildings: <String>['exhibition', 'messages', 'profile'],
    );
  }

  EnterpriseBoardType resolveEnterpriseBoardType(
    String? raw, {
    EnterpriseBoardType fallback = EnterpriseBoardType.company,
  }) {
    return EnterpriseBoardType.fromRaw(raw) ?? fallback;
  }

  EnterpriseHubBoardCanonicalFamily boardFamily(EnterpriseBoardType boardType) {
    return EnterpriseHubBoardCanonicalFamily.forBoard(boardType);
  }

  String boardEnterprisesPath(EnterpriseBoardType boardType) {
    return boardFamily(boardType).enterprises;
  }

  String boardRecommendationsPath(EnterpriseBoardType boardType) {
    return boardFamily(boardType).recommendations;
  }

  String boardWorkbenchPath(EnterpriseBoardType boardType) {
    return boardFamily(boardType).workbench;
  }

  String boardEnterpriseDetailPath(
    EnterpriseBoardType boardType,
    String enterpriseId,
  ) {
    return boardFamily(boardType).enterpriseDetail(enterpriseId);
  }

  String boardEnsureShellPath(EnterpriseBoardType boardType) {
    return boardFamily(boardType).ensureShell;
  }

  String boardUpdateBasicPath(
    EnterpriseBoardType boardType,
    String enterpriseId,
  ) {
    return boardFamily(boardType).updateBasic(enterpriseId);
  }

  String boardUpdateProfilePath(
    EnterpriseBoardType boardType,
    String enterpriseId,
  ) {
    return boardFamily(boardType).updateProfile(enterpriseId);
  }

  String boardApplicationStatusPath(
    EnterpriseBoardType boardType,
    String applicationId,
  ) {
    return boardFamily(boardType).applicationStatus(applicationId);
  }

  String boardPublishedChangeWorkbenchPath(
    EnterpriseBoardType boardType,
    String enterpriseId,
  ) {
    return boardFamily(boardType).publishedChangeWorkbench(enterpriseId);
  }

  String boardPublishedChangeStatusPath(
    EnterpriseBoardType boardType,
    String enterpriseId,
  ) {
    return boardFamily(boardType).publishedChangeStatus(enterpriseId);
  }

  String boardPublishedChangeBasicPath(
    EnterpriseBoardType boardType,
    String enterpriseId,
  ) {
    return boardFamily(boardType).publishedChangeBasic(enterpriseId);
  }

  String boardPublishedChangeSubmitPath(
    EnterpriseBoardType boardType,
    String enterpriseId,
  ) {
    return boardFamily(boardType).publishedChangeSubmit(enterpriseId);
  }

  void installEnterpriseWorkbenchApplyDependencies({
    EnterpriseBoardType boardType = EnterpriseBoardType.company,
    Map<String, Object?>? workbenchPayload,
    String? organizationCityCode = '510100',
    String? certificationLicenseFileId = 'license-1',
    Map<String, Object?>? certificationOcrBody,
  }) {
    final resolvedBoardType = resolveEnterpriseBoardType(
      workbenchPayload?['boardType'] as String?,
      fallback: boardType,
    );
    EnterpriseHubWorkbenchConsumerLayer.install(
      EnterpriseHubWorkbenchConsumerLayer(
        client: AppApiClient(
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET ${boardWorkbenchPath(resolvedBoardType)}':
                      (AppApiRequest request) async {
                        return AppApiResponse(
                          statusCode: 200,
                          uri: request.uri,
                          body: workbenchPayload ?? buildWorkbenchPayload(),
                        );
                      },
                },
          ),
        ),
      ),
    );
    final profileIdentityConsumerLayer = ProfileIdentityConsumerLayer(
      client: AppApiClient(
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'GET /api/app/profile/organization/mine':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: <String, Object?>{
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
                              'cityCode': organizationCityCode,
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
                        body: <String, Object?>{
                          'organizationId': 'org-1',
                          'certificationStatus': 'approved',
                          'legalName': '西南会展搭建有限公司',
                          'uscc': '91510100TEST12345',
                          'licenseFileId': certificationLicenseFileId,
                        },
                      );
                    },
                'POST /api/app/profile/certification/license/ocr':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body:
                            certificationOcrBody ??
                            const <String, Object?>{
                              'status': 'recognized',
                              'message': 'ok',
                              'address': '四川省成都市高新区天府大道 1 号',
                              'establishedAt': '2019-09-09',
                            },
                      );
                    },
              },
        ),
      ),
    );
    ProfileIdentityConsumerLayer.install(profileIdentityConsumerLayer);
  }

  void installEnterpriseLocationResolveStub({
    required Map<String, Object?> Function(AppApiRequest request) responseBody,
    void Function(AppApiRequest request)? onRequest,
  }) {
    EnterpriseHubConsumerLayer.install(
      EnterpriseHubConsumerLayer(
        client: AppApiClient(
          transport: FakeAppApiTransport(
            handlers: <String, Future<AppApiResponse> Function(AppApiRequest)>{
              'POST /api/app/exhibition/enterprise-hub/location/resolve':
                  (AppApiRequest request) async {
                    onRequest?.call(request);
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: responseBody(request),
                    );
                  },
            },
          ),
        ),
      ),
    );
  }

  void installPublishedChangeWorkbenchDependencies({
    EnterpriseBoardType boardType = EnterpriseBoardType.company,
    Map<String, Object?>? workbenchPayload,
    Map<String, Object?>? statusPayload,
    Map<String, Object?>? liveDetailPayload,
    String? organizationCityCode = '510100',
    String? certificationLicenseFileId = 'license-1',
    Map<String, Object?>? certificationOcrBody,
    bool installConsumer = true,
  }) {
    final resolvedBoardType = resolveEnterpriseBoardType(
      workbenchPayload?['boardType'] as String?,
      fallback: boardType,
    );
    if (installConsumer) {
      EnterpriseHubPublishedChangeConsumerLayer.install(
        EnterpriseHubPublishedChangeConsumerLayer(
          client: AppApiClient(
            transport: FakeAppApiTransport(
              handlers:
                  <
                    String,
                    Future<AppApiResponse> Function(AppApiRequest request)
                  >{
                    'GET ${boardPublishedChangeWorkbenchPath(resolvedBoardType, 'ent-published-1')}':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body:
                                workbenchPayload ??
                                buildPublishedChangeWorkbenchPayload(),
                          );
                        },
                    'GET ${boardPublishedChangeStatusPath(resolvedBoardType, 'ent-published-1')}':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body:
                                statusPayload ??
                                buildPublishedChangeStatusPayload(),
                          );
                        },
                  },
            ),
          ),
        ),
      );
    }
    EnterpriseHubConsumerLayer.install(
      EnterpriseHubConsumerLayer(
        client: AppApiClient(
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET ${boardEnterpriseDetailPath(resolvedBoardType, 'ent-published-1')}':
                      (AppApiRequest request) async {
                        final boardType =
                            workbenchPayload?['boardType'] as String? ??
                            'company';
                        return AppApiResponse(
                          statusCode: 200,
                          uri: request.uri,
                          body:
                              liveDetailPayload ??
                              buildPublishedLiveDetailPayload(
                                boardType: boardType,
                              ),
                        );
                      },
                },
          ),
        ),
      ),
    );
    final profileIdentityConsumerLayer = ProfileIdentityConsumerLayer(
      client: AppApiClient(
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'GET /api/app/profile/organization/mine':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: <String, Object?>{
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
                              'cityCode': organizationCityCode,
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
                        body: <String, Object?>{
                          'organizationId': 'org-1',
                          'certificationStatus': 'approved',
                          'legalName': '西南会展搭建有限公司',
                          'uscc': '91510100TEST12345',
                          'licenseFileId': certificationLicenseFileId,
                        },
                      );
                    },
                'POST /api/app/profile/certification/license/ocr':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body:
                            certificationOcrBody ??
                            const <String, Object?>{
                              'status': 'recognized',
                              'message': 'ok',
                              'address': '四川省成都市高新区天府大道 1 号',
                              'establishedAt': '2019-09-09',
                            },
                      );
                    },
              },
        ),
      ),
    );
    ProfileIdentityConsumerLayer.install(profileIdentityConsumerLayer);
  }

  test('enterprise application error copy covers frozen app-facing codes', () {
    expect(
      enterpriseApplicationVisibleErrorMessage(
        errorCode: 'AUTH_SESSION_INVALID',
      ),
      '登录状态已失效，请重新登录后再继续企业展示申请。',
    );
    expect(
      enterpriseApplicationVisibleErrorMessage(
        errorCode: 'ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS',
      ),
      '当前提交确认未完成，请返回工作台确认提交入驻申请后再继续。',
    );
    expect(
      enterpriseApplicationVisibleErrorMessage(
        errorCode: 'ENTERPRISE_HUB_PERMISSION_DENIED',
      ),
      '当前账号暂不允许执行企业展示申请操作。',
    );
    expect(
      enterpriseApplicationVisibleErrorMessage(
        errorCode: 'ENTERPRISE_HUB_APPLICATION_NOT_FOUND',
      ),
      '当前申请单不存在或已不可访问。',
    );
    expect(
      enterpriseApplicationVisibleErrorMessage(
        errorCode: 'ENTERPRISE_HUB_PROFILE_NOT_COMPLETED',
      ),
      '当前板块画像尚未完善，请先回到工作台补齐后再提交。',
    );
    expect(
      enterpriseApplicationVisibleErrorMessage(
        errorCode: 'ENTERPRISE_HUB_CONTACT_REQUIRED',
      ),
      '当前还缺少联系人，请先回到工作台补齐后再提交。',
    );
    expect(
      enterpriseApplicationVisibleErrorMessage(
        errorCode: 'ENTERPRISE_HUB_CASE_REQUIRED',
      ),
      '当前还缺少已保存案例，请先回到工作台保存案例后再提交。',
    );
    expect(
      enterpriseApplicationVisibleErrorMessage(
        errorCode: 'ENTERPRISE_HUB_CERTIFICATION_REQUIRED',
      ),
      '当前企业认证尚未通过，请先完成认证后再提交。',
    );
    expect(
      enterpriseApplicationVisibleErrorMessage(
        errorCode: 'ENTERPRISE_HUB_INVALID_STATE_TRANSITION',
      ),
      '当前申请状态不允许继续此操作，请先刷新状态后再试。',
    );
  });

  test('enterprise submit action uses canonical app-facing transport', () async {
    AppApiRequest? seenRequest;
    EnterpriseHubConsumerLayer.install(
      EnterpriseHubConsumerLayer(
        client: AppApiClient(
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'POST /api/app/exhibition/enterprise-hub/applications/app-1/submit':
                      (AppApiRequest request) async {
                        seenRequest = request;
                        return AppApiResponse(
                          statusCode: 200,
                          uri: request.uri,
                          body: const <String, Object?>{'success': true},
                        );
                      },
                },
          ),
        ),
      ),
    );

    final result = await EnterpriseHubConsumerLayer.instance.submitApplication(
      applicationId: 'app-1',
    );

    expect(result.isSuccess, isTrue);
    expect(result.method, 'POST');
    expect(
      result.path,
      '/api/app/exhibition/enterprise-hub/applications/app-1/submit',
    );
    expect(seenRequest?.canonicalPath, result.path);
    expect(seenRequest?.method, AppApiMethod.post);
    expect(seenRequest?.body, const <String, Object?>{'confirm': true});
  });

  test(
    'enterprise submit missing required fields stays on confirm semantics instead of profile blocker',
    () async {
      EnterpriseHubConsumerLayer.install(
        EnterpriseHubConsumerLayer(
          client: AppApiClient(
            transport: FakeAppApiTransport(
              handlers:
                  <
                    String,
                    Future<AppApiResponse> Function(AppApiRequest request)
                  >{
                    'POST /api/app/exhibition/enterprise-hub/applications/app-1/submit':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 400,
                            uri: request.uri,
                            body: const <String, Object?>{
                              'code': 'ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS',
                              'message': 'confirm is required',
                            },
                          );
                        },
                  },
            ),
          ),
        ),
      );

      final result = await EnterpriseHubConsumerLayer.instance
          .submitApplication(applicationId: 'app-1');

      expect(result.isSuccess, isFalse);
      expect(result.errorCode, 'ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS');
      expect(
        enterpriseApplicationVisibleErrorMessage(
          state: result.controlledState,
          errorCode: result.errorCode,
          fallbackMessage: result.message,
        ),
        '当前提交确认未完成，请返回工作台确认提交入驻申请后再继续。',
      );
    },
  );

  test('enterprise submit action preserves app-facing error semantics', () async {
    EnterpriseHubConsumerLayer.install(
      EnterpriseHubConsumerLayer(
        client: AppApiClient(
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'POST /api/app/exhibition/enterprise-hub/applications/app-1/submit':
                      (AppApiRequest request) async {
                        return AppApiResponse(
                          statusCode: 409,
                          uri: request.uri,
                          body: const <String, Object?>{
                            'code': 'ENTERPRISE_HUB_PROFILE_NOT_COMPLETED',
                            'message': 'profile not completed',
                          },
                        );
                      },
                },
          ),
        ),
      ),
    );

    final result = await EnterpriseHubConsumerLayer.instance.submitApplication(
      applicationId: 'app-1',
    );

    expect(result.isSuccess, isFalse);
    expect(result.controlledState, AppPageState.errorNonRetryable);
    expect(result.errorCode, 'ENTERPRISE_HUB_PROFILE_NOT_COMPLETED');
    expect(
      enterpriseApplicationVisibleErrorMessage(
        state: result.controlledState,
        errorCode: result.errorCode,
        fallbackMessage: result.message,
      ),
      '当前板块画像尚未完善，请先回到工作台补齐后再提交。',
    );
  });

  test('enterprise status load uses canonical app-facing transport', () async {
    AppApiRequest? seenRequest;
    EnterpriseHubConsumerLayer.install(
      EnterpriseHubConsumerLayer(
        client: AppApiClient(
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/exhibition/enterprise-hub/applications/app-1':
                      (AppApiRequest request) async {
                        seenRequest = request;
                        return AppApiResponse(
                          statusCode: 200,
                          uri: request.uri,
                          body: const <String, Object?>{
                            'applicationId': 'app-1',
                            'enterpriseId': 'ent-company-1',
                            'applyBoardType': 'company',
                            'applicationStatus': 'submitted',
                          },
                        );
                      },
                },
          ),
        ),
      ),
    );

    final result = await EnterpriseHubConsumerLayer.instance
        .loadApplicationStatus(applicationId: 'app-1');

    expect(result.state, AppPageState.content);
    expect(
      result.path,
      '/api/app/exhibition/enterprise-hub/applications/app-1',
    );
    expect(seenRequest?.canonicalPath, result.path);
    expect(seenRequest?.method, AppApiMethod.get);
    expect(result.data?.applicationId, 'app-1');
    expect(result.data?.applicationStatus, 'submitted');
  });

  testWidgets('enterprise company list route renders formal list skeleton', (
    WidgetTester tester,
  ) async {
    EnterpriseHubConsumerLayer.install(
      EnterpriseHubConsumerLayer(
        client: AppApiClient(
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET ${boardEnterprisesPath(EnterpriseBoardType.company)}':
                      (AppApiRequest request) async {
                        return AppApiResponse(
                          statusCode: 200,
                          uri: request.uri,
                          body: const <String, Object?>{
                            'recommended': <Object?>[],
                            'items': <Object?>[
                              <String, Object?>{
                                'enterpriseId': 'ent-company-1',
                                'boardType': 'company',
                                'name': '西南会展搭建有限公司',
                                'provinceName': '四川',
                                'cityName': '成都',
                                'primaryBoardLabel': '优秀公司',
                                'secondaryCapabilityLabels': <String>['主场服务'],
                                'shortIntro': '承接展台搭建与活动执行。',
                                'certificationLabel': '已认证',
                                'caseCount': 12,
                                'boardHighlights': <String, Object?>{
                                  'company': <String, Object?>{
                                    'exhibitionTypes': <String>['特装展台'],
                                  },
                                },
                              },
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
                  'GET ${boardRecommendationsPath(EnterpriseBoardType.company)}':
                      (AppApiRequest request) async {
                        return AppApiResponse(
                          statusCode: 200,
                          uri: request.uri,
                          body: const <String, Object?>{
                            'boardType': 'company',
                            'items': <Object?>[],
                          },
                        );
                      },
                },
          ),
        ),
      ),
    );

    await tester.pumpWidget(
      ExhibitionMobileApp(initialRoute: ExhibitionRoutes.companies),
    );
    await tester.pumpAndSettle();

    expect(find.text('优秀公司'), findsOneWidget);
    expect(find.text('城市'), findsOneWidget);
    expect(find.text('业务方向'), findsNothing);
    expect(find.text('默认排序'), findsNothing);
    expect(find.text('继续入驻'), findsNothing);
    expect(find.text('清空筛选'), findsNothing);
    await tester.tap(find.byIcon(Icons.search_rounded).first);
    await tester.pumpAndSettle();
    expect(find.text('搜索公司名称、业务方向、所在城市'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('西南会展搭建有限公司'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('西南会展搭建有限公司'), findsOneWidget);
    expect(find.textContaining('当前展示：已接通内容，共 1 家'), findsOneWidget);
    expect(find.text('当前条件下没有企业卡片。'), findsNothing);
  });

  testWidgets('enterprise supplier list renders differentiated landing copy', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 2200);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    EnterpriseHubConsumerLayer.install(
      EnterpriseHubConsumerLayer(
        client: AppApiClient(
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET ${boardEnterprisesPath(EnterpriseBoardType.supplier)}':
                      (AppApiRequest request) async {
                        return AppApiResponse(
                          statusCode: 200,
                          uri: request.uri,
                          body: const <String, Object?>{
                            'recommended': <Object?>[],
                            'items': <Object?>[
                              <String, Object?>{
                                'enterpriseId': 'ent-supplier-1',
                                'boardType': 'supplier',
                                'name': '华南物料租赁服务商',
                                'provinceName': '广东',
                                'cityName': '广州',
                                'primaryBoardLabel': '优秀供应商',
                                'secondaryCapabilityLabels': <String>['家具租赁'],
                                'shortIntro': '覆盖展具、家具与多媒体设备租赁。',
                                'certificationLabel': '已认证',
                                'caseCount': 5,
                                'boardHighlights': <String, Object?>{
                                  'supplier': <String, Object?>{
                                    'supplyCategories': <String>['桁架舞台搭建厂'],
                                    'responseSlaDesc': '2 小时响应',
                                  },
                                },
                              },
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
                  'GET ${boardRecommendationsPath(EnterpriseBoardType.supplier)}':
                      (AppApiRequest request) async {
                        return AppApiResponse(
                          statusCode: 200,
                          uri: request.uri,
                          body: const <String, Object?>{
                            'boardType': 'supplier',
                            'items': <Object?>[],
                          },
                        );
                      },
                },
          ),
        ),
      ),
    );

    await tester.pumpWidget(
      ExhibitionMobileApp(initialRoute: ExhibitionRoutes.suppliers),
    );
    await tester.pumpAndSettle();

    expect(find.text('优秀供应商'), findsNothing);
    expect(find.text('城市'), findsOneWidget);
    expect(find.text('供应品类'), findsOneWidget);
    expect(find.text('全部'), findsOneWidget);
    expect(find.text('桁架舞台搭建厂'), findsOneWidget);
    expect(find.text('默认排序'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('华南物料租赁服务商'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('桁架舞台搭建厂'), findsOneWidget);
    expect(find.textContaining('响应'), findsOneWidget);
    expect(find.text('已认证'), findsNothing);
    expect(find.text('5 个案例'), findsNothing);
    expect(find.text('按天租赁'), findsNothing);
  });

  testWidgets(
    'enterprise factory list keeps plant area filter and removes fake primary filter and sort',
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
                    'GET ${boardEnterprisesPath(EnterpriseBoardType.factory)}':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: const <String, Object?>{
                              'recommended': <Object?>[],
                              'items': <Object?>[
                                <String, Object?>{
                                  'enterpriseId': 'ent-factory-1',
                                  'boardType': 'factory',
                                  'name': '华南数字制作工厂',
                                  'provinceName': '广东',
                                  'cityName': '佛山',
                                  'primaryBoardLabel': '优秀工厂',
                                  'secondaryCapabilityLabels': <String>['木作制作'],
                                  'shortIntro': '覆盖木作、喷绘与配送支持。',
                                  'certificationLabel': '已认证',
                                  'caseCount': 8,
                                  'boardHighlights': <String, Object?>{
                                    'factory': <String, Object?>{
                                      'processTypes': <String>['木作'],
                                      'deliveryRadiusDesc': '50km',
                                    },
                                  },
                                },
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
                    'GET ${boardRecommendationsPath(EnterpriseBoardType.factory)}':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: const <String, Object?>{
                              'boardType': 'factory',
                              'items': <Object?>[],
                            },
                          );
                        },
                  },
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        ExhibitionMobileApp(initialRoute: ExhibitionRoutes.factories),
      );
      await tester.pumpAndSettle();

      expect(find.text('优秀工厂'), findsNothing);
      expect(find.text('厂房位置'), findsOneWidget);
      expect(find.text('厂房面积'), findsOneWidget);
      expect(find.text('工艺类型'), findsNothing);
      expect(find.text('默认排序'), findsNothing);
      await tester.scrollUntilVisible(
        find.text('华南数字制作工厂'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('华南数字制作工厂'), findsOneWidget);
      expect(find.text('工艺：木作'), findsOneWidget);
      expect(find.text('已认证'), findsNothing);
      expect(find.text('8 个案例'), findsNothing);
    },
  );

  test(
    'enterprise public list query only sends frozen minimal contract',
    () async {
      Uri? seenUri;
      EnterpriseHubConsumerLayer.install(
        EnterpriseHubConsumerLayer(
          client: AppApiClient(
            transport: FakeAppApiTransport(
              handlers:
                  <
                    String,
                    Future<AppApiResponse> Function(AppApiRequest request)
                  >{
                    'GET ${boardEnterprisesPath(EnterpriseBoardType.factory)}':
                        (AppApiRequest request) async {
                          seenUri = request.uri;
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: const <String, Object?>{
                              'recommended': <Object?>[],
                              'items': <Object?>[],
                              'pagination': <String, Object?>{
                                'page': 2,
                                'pageSize': 20,
                                'total': 0,
                                'hasMore': false,
                              },
                            },
                          );
                        },
                  },
            ),
          ),
        ),
      );

      await EnterpriseHubConsumerLayer.instance.loadEnterprises(
        const EnterpriseHubListQuery(
          boardType: EnterpriseBoardType.factory,
          keyword: '木作',
          provinceCode: '500000',
          cityCode: '500100',
          plantAreaRange: 'from_1200_to_1999',
          page: 2,
          pageSize: 20,
        ),
      );

      expect(seenUri?.queryParameters, <String, String>{
        'keyword': '木作',
        'provinceCode': '500000',
        'cityCode': '500100',
        'plantAreaRange': 'from_1200_to_1999',
        'page': '2',
        'pageSize': '20',
      });
    },
  );

  testWidgets(
    'enterprise company list renders empty state from frozen list payload',
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
                    'GET ${boardEnterprisesPath(EnterpriseBoardType.company)}':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: const <String, Object?>{
                              'recommended': <Object?>[],
                              'items': <Object?>[],
                              'pagination': <String, Object?>{
                                'page': 1,
                                'pageSize': 10,
                                'total': 0,
                                'hasMore': false,
                              },
                            },
                          );
                        },
                    'GET ${boardRecommendationsPath(EnterpriseBoardType.company)}':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: const <String, Object?>{
                              'boardType': 'company',
                              'items': <Object?>[],
                            },
                          );
                        },
                  },
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        ExhibitionMobileApp(initialRoute: ExhibitionRoutes.companies),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('当前展示：真实空结果。当前条件下没有企业卡片。'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('当前展示：真实空结果。当前条件下没有企业卡片。'), findsOneWidget);
      expect(find.textContaining('当前展示：真实空结果，当前条件下暂无匹配企业'), findsOneWidget);
      expect(find.text('重置筛选'), findsNothing);
    },
  );

  test(
    'enterprise workbench consumer parses frozen workbench payload',
    () async {
      EnterpriseHubWorkbenchConsumerLayer.install(
        EnterpriseHubWorkbenchConsumerLayer(
          client: AppApiClient(
            transport: FakeAppApiTransport(
              handlers:
                  <
                    String,
                    Future<AppApiResponse> Function(AppApiRequest request)
                  >{
                    'GET ${boardWorkbenchPath(EnterpriseBoardType.company)}':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: buildWorkbenchPayload(
                              shortIntro: '旧一句话简介',
                              submitReady: false,
                              blockers: const <String>['请先完善企业简介'],
                            ),
                          );
                        },
                  },
            ),
          ),
        ),
      );

      final result = await EnterpriseHubWorkbenchConsumerLayer.instance
          .loadWorkbench(boardType: EnterpriseBoardType.company);

      expect(result.state, AppPageState.content);
      expect(result.data?.basic?.shortIntro, '旧一句话简介');
      expect(result.data?.certification?.certificationStatus, 'approved');
      expect(result.data?.readiness.submitReady, isFalse);
      expect(result.data?.readiness.blockers, <String>['请先完善企业简介']);
    },
  );

  testWidgets('enterprise company list renders controlled 403 state', (
    WidgetTester tester,
  ) async {
    EnterpriseHubConsumerLayer.install(
      EnterpriseHubConsumerLayer(
        client: AppApiClient(
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET ${boardEnterprisesPath(EnterpriseBoardType.company)}':
                      (AppApiRequest request) async {
                        return AppApiResponse(
                          statusCode: 403,
                          uri: request.uri,
                          body: const <String, Object?>{
                            'message': '当前 actor 范围未开放 company 列表。',
                          },
                        );
                      },
                  'GET ${boardRecommendationsPath(EnterpriseBoardType.company)}':
                      (AppApiRequest request) async {
                        return AppApiResponse(
                          statusCode: 200,
                          uri: request.uri,
                          body: const <String, Object?>{
                            'boardType': 'company',
                            'items': <Object?>[],
                          },
                        );
                      },
                },
          ),
        ),
      ),
    );

    await tester.pumpWidget(
      ExhibitionMobileApp(initialRoute: ExhibitionRoutes.companies),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('当前展示：受控状态。当前 actor 范围未开放 company 列表。'),
      findsOneWidget,
    );
  });

  testWidgets('enterprise detail route renders unified detail sections', (
    WidgetTester tester,
  ) async {
    EnterpriseHubConsumerLayer.install(
      EnterpriseHubConsumerLayer(
        client: AppApiClient(
          transport: FakeAppApiTransport(
            handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET ${boardEnterpriseDetailPath(EnterpriseBoardType.company, 'ent-company-1')}':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'header': <String, Object?>{
                          'enterpriseId': 'ent-company-1',
                          'name': '西南会展搭建有限公司',
                          'primaryBoardType': 'company',
                          'secondaryCapabilities': <String>['supplier'],
                          'shortIntro': '主打特装展台与活动执行。',
                          'provinceName': '四川',
                          'cityName': '成都',
                          'logoUrl': 'https://example.com/logo.png',
                        },
                        'visualGallery': <String, Object?>{
                          'coverImageUrl': 'https://example.com/cover.png',
                          'albumImageUrls': <String>[
                            'https://example.com/album-1.png',
                            'https://example.com/album-2.png',
                          ],
                          'source': 'enterprise_album',
                        },
                        'basicInfo': <String, Object?>{
                          'fullIntro': '完整介绍',
                          'address': '四川省成都市高新区天府大道 1 号',
                        },
                        'boardProfile': <String, Object?>{
                          'exhibitionTypes': <String>['特装展台'],
                          'serviceItems': <String>['设计', '搭建'],
                          'serviceCities': <String>['成都'],
                          'qualificationDesc': '展陈搭建资质齐全。',
                        },
                        'serviceAreas': <Object?>[
                          <String, Object?>{
                            'provinceName': '四川',
                            'cityName': '成都',
                          },
                        ],
                        'cases': <Object?>[
                          <String, Object?>{
                            'id': 'case-1',
                            'title': '糖酒会主场案例',
                            'summary': '案例摘要',
                            'caseStatus': 'approved',
                          },
                        ],
                        'certifications': <Object?>[
                          <String, Object?>{
                            'type': 'business',
                            'name': '营业执照',
                            'status': 'approved',
                          },
                        ],
                        'reviewSummary': <String, Object?>{
                          'keywordTags': <String>['交付稳定'],
                        },
                        'contacts': <Object?>[
                          <String, Object?>{'contactName': '李经理'},
                        ],
                      },
                    );
                  },
              'GET /api/app/exhibition/enterprise-hub/enterprises/ent-company-1/formal-info':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'enterpriseId': 'ent-company-1',
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
                      },
                    );
                  },
            },
          ),
        ),
      ),
    );

    await tester.pumpWidget(
      ExhibitionMobileApp(
        bootstrapShellContext: AppShellContextData(
          organizationId: 'org-1',
          certificationStatus: 'approved',
          personalCertificationStatus: 'approved',
          personalCertificationQualified: true,
          personalCertificationLockedToOtherActor: false,
          visibleBuildings: const <String>['exhibition', 'messages', 'profile'],
        ),
        initialRoute: ExhibitionRoutes.companyDetailWithEnterpriseId(
          'ent-company-1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('企业画册'), findsNothing);
    expect(find.text('优秀公司'), findsNothing);
    expect(find.text('查看企业信息'), findsWidgets);
    expect(find.text('西南会展搭建有限公司'), findsOneWidget);
    expect(find.text('展陈搭建资质齐全。'), findsOneWidget);
    expect(find.text('公司样本摘要'), findsNothing);
    expect(find.text('展会类型'), findsWidgets);
    expect(find.text('项目规模'), findsNothing);
    expect(find.text('https://example.com/cover.png'), findsNothing);
    expect(find.text('https://example.com/album-1.png'), findsNothing);
    expect(find.text('信任背书'), findsOneWidget);
    expect(find.text('公司介绍'), findsOneWidget);
    expect(find.text('核心优势'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(
        const ValueKey<String>('enterprise-target-enterprise-info-entry-card'),
      ),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(
        const ValueKey<String>('enterprise-target-enterprise-info-entry-card'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('企业信息'), findsWidgets);
    expect(find.text('认证主体'), findsOneWidget);
    expect(find.text('统一社会信用代码'), findsOneWidget);
    expect(find.text('法定代表人'), findsOneWidget);
    expect(find.text('当前认证状态'), findsOneWidget);

    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('地址与服务区域'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('地址与服务区域'), findsOneWidget);
    expect(find.text('四川省成都市高新区天府大道 1 号'), findsOneWidget);
    expect(find.text('当前公开详情还没有返回可用坐标，先按文字地址展示企业位置。'), findsOneWidget);
    expect(find.text('查看地图'), findsNothing);

    expect(find.text('核心能力'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('公司介绍'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('公司介绍'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('交付稳定'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('交付稳定'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('案例展示'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('案例展示'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('联系方式'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('联系方式'), findsOneWidget);
  });

  testWidgets(
    'factory detail route uses hero overlay, hides duplicate gallery, and renders empty-case copy',
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
                    'GET ${boardEnterpriseDetailPath(EnterpriseBoardType.factory, 'ent-factory-1')}':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: const <String, Object?>{
                              'header': <String, Object?>{
                                'enterpriseId': 'ent-factory-1',
                                'name': '重庆坤特展览展示有限公司',
                                'primaryBoardType': 'factory',
                                'shortIntro': '主打展台木作与结构制作。',
                                'provinceName': '重庆市',
                                'cityName': '重庆市',
                                'verificationStatus': 'approved',
                                'logoUrl':
                                    'https://example.com/factory-logo.png',
                              },
                              'visualGallery': <String, Object?>{
                                'albumImageUrls': <String>[
                                  'https://example.com/album-1.png',
                                ],
                                'source': 'enterprise_album',
                              },
                              'basicInfo': <String, Object?>{
                                'fullIntro': '工厂详细介绍',
                                'teamSizeRange': '31-100',
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
                                'equipmentList': <String>[
                                  '推台锯',
                                  '封边机',
                                  '雕刻机',
                                  '空压机',
                                ],
                                'showcaseImageUrls': <String>[
                                  'https://example.com/showcase-1.png',
                                ],
                                'plantAreaSqm': 5000,
                                'warehouseCapability': true,
                                'transportCapability': '自有车辆',
                                'deliveryRadiusDesc': '重庆主城',
                              },
                              'serviceAreas': <Object?>[],
                              'cases': <Object?>[],
                              'certifications': <Object?>[
                                <String, Object?>{
                                  'type': 'business_license',
                                  'name': '营业执照',
                                  'status': 'approved',
                                },
                              ],
                              'reviewSummary': <String, Object?>{},
                              'contacts': <Object?>[],
                            },
                          );
                        },
                  },
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        ExhibitionMobileApp(
          bootstrapShellContext: AppShellContextData(
            organizationId: 'org-1',
            certificationStatus: 'approved',
            personalCertificationStatus: 'approved',
            personalCertificationQualified: true,
            personalCertificationLockedToOtherActor: false,
            visibleBuildings: const <String>[
              'exhibition',
              'messages',
              'profile',
            ],
          ),
          initialRoute: ExhibitionRoutes.factoryDetailWithEnterpriseId(
            'ent-factory-1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey<String>('enterprise-detail-hero-overlay')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('enterprise-detail-hero-metric-地区')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('enterprise-detail-hero-metric-认证')),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const ValueKey<String>('enterprise-detail-hero-metric-厂房面积'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const ValueKey<String>('enterprise-detail-hero-metric-团队规模'),
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is Image &&
              widget.image is NetworkImage &&
              (widget.image as NetworkImage).url ==
                  'https://example.com/showcase-1.png',
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is Image &&
              widget.image is NetworkImage &&
              (widget.image as NetworkImage).url ==
                  'https://example.com/album-1.png',
        ),
        findsNothing,
      );
      expect(find.text('企业画册'), findsNothing);
      expect(find.text('月产能'), findsNothing);
      expect(find.text('approved'), findsNothing);
      expect(find.text('仓储'), findsNothing);
      expect(find.text('运输'), findsNothing);
      expect(find.text('配送半径'), findsNothing);

      await tester.scrollUntilVisible(
        find.text('核心能力'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(
          const ValueKey<String>('enterprise-detail-factory-capability-layout'),
        ),
        findsOneWidget,
      );
      expect(
        tester.widget(
          find.byKey(
            const ValueKey<String>(
              'enterprise-detail-factory-capability-layout',
            ),
          ),
        ),
        isA<Row>(),
      );
      expect(
        find.byKey(
          const ValueKey<String>(
            'enterprise-detail-factory-equipment-column-0',
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const ValueKey<String>(
            'enterprise-detail-factory-equipment-column-1',
          ),
        ),
        findsOneWidget,
      );

      await tester.scrollUntilVisible(
        find.text('资质与口碑'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('营业执照'), findsOneWidget);
      expect(find.text('approved'), findsNothing);

      await tester.scrollUntilVisible(
        find.text('案例展示'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('案例展示'), findsOneWidget);
      expect(find.text('暂无公开案例'), findsOneWidget);
    },
  );

  testWidgets(
    'factory detail case card opens detail sheet and loads case detail',
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
                    'GET ${boardEnterpriseDetailPath(EnterpriseBoardType.factory, 'ent-factory-case-1')}':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: const <String, Object?>{
                              'header': <String, Object?>{
                                'enterpriseId': 'ent-factory-case-1',
                                'name': '重庆坤特展览展示有限公司',
                                'primaryBoardType': 'factory',
                                'shortIntro': '主打展台木作与结构制作。',
                                'provinceName': '重庆市',
                                'cityName': '重庆市',
                                'verificationStatus': 'approved',
                              },
                              'visualGallery': <String, Object?>{
                                'albumImageUrls': <String>[
                                  'https://example.com/showcase-1.png',
                                ],
                                'source': 'showcase',
                              },
                              'basicInfo': <String, Object?>{
                                'fullIntro': '工厂详细介绍',
                                'teamSizeRange': '31-100',
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
                                'equipmentList': <String>['推台锯'],
                                'showcaseImageUrls': <String>[
                                  'https://example.com/showcase-1.png',
                                ],
                                'plantAreaSqm': 5000,
                              },
                              'serviceAreas': <Object?>[],
                              'cases': <Object?>[
                                <String, Object?>{
                                  'id': 'case-1',
                                  'title': '重庆车展展台搭建',
                                  'summary': '双层木作结构与现场执行案例。',
                                  'caseStatus': 'published',
                                  'coverImageUrl':
                                      'https://example.com/case-cover.png',
                                  'eventTime': '2026-03',
                                },
                              ],
                              'certifications': <Object?>[],
                              'reviewSummary': <String, Object?>{},
                              'contacts': <Object?>[],
                            },
                          );
                        },
                    'GET /api/app/exhibition/enterprise-hub/public-cases/case-1':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: const <String, Object?>{
                              'caseId': 'case-1',
                              'enterpriseId': 'ent-factory-case-1',
                              'boardType': 'factory',
                              'title': '重庆车展展台搭建',
                              'exhibitionType': '车展',
                              'city': '重庆',
                              'eventTime': '2026-03',
                              'summary': '双层木作结构与现场执行案例，已接通案例详情读取。',
                              'caseCoverFileAssetId': 'file-cover-1',
                              'caseMediaFileAssetIds': <String>[
                                'file-cover-1',
                                'file-media-1',
                              ],
                              'caseImageUrlMap': <String, String>{
                                'file-cover-1':
                                    'https://example.com/case-cover.png',
                                'file-media-1':
                                    'https://example.com/case-media-1.png',
                              },
                              'isFeatured': true,
                              'caseStatus': 'published',
                            },
                          );
                        },
                  },
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        ExhibitionMobileApp(
          bootstrapShellContext: AppShellContextData(
            organizationId: 'org-1',
            certificationStatus: 'approved',
            personalCertificationStatus: 'approved',
            personalCertificationQualified: true,
            personalCertificationLockedToOtherActor: false,
            visibleBuildings: const <String>[
              'exhibition',
              'messages',
              'profile',
            ],
          ),
          initialRoute: ExhibitionRoutes.factoryDetailWithEnterpriseId(
            'ent-factory-case-1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byKey(
          const ValueKey<String>('enterprise-detail-case-card-case-1'),
        ),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(
          const ValueKey<String>('enterprise-detail-case-card-case-1'),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(
        find.byKey(
          const ValueKey<String>('enterprise-detail-case-detail-sheet'),
        ),
        findsOneWidget,
      );
      expect(find.text('案例详情'), findsOneWidget);
      expect(find.text('车展'), findsOneWidget);
      expect(find.text('重庆'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('案例摘要'),
        120,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      expect(find.text('双层木作结构与现场执行案例，已接通案例详情读取。'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('案例图片'),
        120,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      expect(find.text('案例图片'), findsOneWidget);
    },
  );

  testWidgets(
    'enterprise detail renders real map preview when location exposes preview url',
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
                    'GET ${boardEnterpriseDetailPath(EnterpriseBoardType.company, 'ent-map-1')}':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: const <String, Object?>{
                              'header': <String, Object?>{
                                'enterpriseId': 'ent-map-1',
                                'name': '地图样本企业',
                                'primaryBoardType': 'company',
                                'shortIntro': '地图能力样本',
                                'provinceName': '重庆',
                                'cityName': '重庆',
                              },
                              'basicInfo': <String, Object?>{
                                'fullIntro': '完整介绍',
                                'address': '重庆市渝北区金开大道 1 号',
                              },
                              'location': <String, Object?>{
                                'publicDisplayAddress': '重庆市渝北区金开大道 1 号',
                                'provinceName': '重庆市',
                                'cityName': '重庆市',
                                'districtName': '渝北区',
                                'latitude': 29.7,
                                'longitude': 106.5,
                                'geoStatus': 'resolved',
                                'mapProvider': 'amap',
                                'mapPreviewUrl':
                                    'https://example.com/amap-preview.png',
                              },
                              'boardProfile': <String, Object?>{},
                              'serviceAreas': <Object?>[],
                              'cases': <Object?>[],
                              'certifications': <Object?>[],
                              'reviewSummary': <String, Object?>{},
                              'contacts': <Object?>[],
                            },
                          );
                        },
                  },
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        ExhibitionMobileApp(
          bootstrapShellContext: AppShellContextData(
            organizationId: 'org-1',
            certificationStatus: 'approved',
            personalCertificationStatus: 'approved',
            personalCertificationQualified: true,
            personalCertificationLockedToOtherActor: false,
            visibleBuildings: const <String>[
              'exhibition',
              'messages',
              'profile',
            ],
          ),
          initialRoute: ExhibitionRoutes.companyDetailWithEnterpriseId(
            'ent-map-1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('地址与服务区域'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('当前已解析出可展示坐标，地图预览已接通。'), findsOneWidget);
      expect(find.text('重庆市渝北区金开大道 1 号'), findsWidgets);
      expect(find.byType(Image), findsWidgets);
      expect(find.textContaining('地图能力暂未接通'), findsNothing);
    },
  );

  testWidgets('enterprise detail route renders controlled 404 state', (
    WidgetTester tester,
  ) async {
    EnterpriseHubConsumerLayer.install(
      EnterpriseHubConsumerLayer(
        client: AppApiClient(
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET ${boardEnterpriseDetailPath(EnterpriseBoardType.company, 'ent-missing')}':
                      (AppApiRequest request) async {
                        return AppApiResponse(
                          statusCode: 404,
                          uri: request.uri,
                          body: const <String, Object?>{
                            'message': '当前企业不存在或已下线。',
                          },
                        );
                      },
                },
          ),
        ),
      ),
    );

    await tester.pumpWidget(
      ExhibitionMobileApp(
        initialRoute: ExhibitionRoutes.companyDetailWithEnterpriseId(
          'ent-missing',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('当前还没有读取到真实企业详情；页面保持受控阻断，不把空态或错误态伪装成实体已接通。'),
      findsOneWidget,
    );
    expect(find.text('当前企业不存在或已下线。'), findsOneWidget);
  });

  testWidgets(
    'enterprise home cards expose three real board entries and company card continues into real list/detail',
    (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1200, 2200);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      EnterpriseHubConsumerLayer.install(
        EnterpriseHubConsumerLayer(
          client: AppApiClient(
            transport: FakeAppApiTransport(
              handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'GET ${boardEnterprisesPath(EnterpriseBoardType.company)}':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'recommended': <Object?>[],
                          'items': <Object?>[
                            <String, Object?>{
                              'enterpriseId':
                                  'e2a016f4-0b6a-497d-902c-409413858ca9',
                              'boardType': 'company',
                              'name': '西南会展搭建有限公司',
                              'provinceName': '四川',
                              'cityName': '成都',
                              'primaryBoardLabel': '优秀公司',
                              'secondaryCapabilityLabels': <String>['主场服务'],
                              'shortIntro': '承接展台搭建与活动执行。',
                              'certificationLabel': '已认证',
                              'caseCount': 12,
                              'boardHighlights': <String, Object?>{
                                'company': <String, Object?>{
                                  'exhibitionTypes': <String>['特装展台'],
                                },
                              },
                            },
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
                'GET ${boardEnterprisesPath(EnterpriseBoardType.factory)}':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'recommended': <Object?>[],
                          'items': <Object?>[
                            <String, Object?>{
                              'enterpriseId':
                                  'bf5ff83a-26e7-4138-8157-042fb38a5f46',
                              'boardType': 'factory',
                              'name': '华南数字制作工厂',
                              'provinceName': '广东',
                              'cityName': '佛山',
                              'primaryBoardLabel': '优秀工厂',
                              'secondaryCapabilityLabels': <String>['木作制作'],
                              'shortIntro': '覆盖木作、喷绘与仓储配套。',
                              'certificationLabel': '已认证',
                              'caseCount': 8,
                              'boardHighlights': <String, Object?>{
                                'factory': <String, Object?>{
                                  'processTypes': <String>['木作'],
                                },
                              },
                            },
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
                'GET ${boardEnterprisesPath(EnterpriseBoardType.supplier)}':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'recommended': <Object?>[],
                          'items': <Object?>[
                            <String, Object?>{
                              'enterpriseId':
                                  'c0576f5c-854c-4b78-9f93-6d57e55d8b47',
                              'boardType': 'supplier',
                              'name': '华东会展物料供应商',
                              'provinceName': '江苏',
                              'cityName': '苏州',
                              'primaryBoardLabel': '优秀供应商',
                              'secondaryCapabilityLabels': <String>['家具租赁'],
                              'shortIntro': '供应展具、家具与多媒体设备。',
                              'certificationLabel': '已认证',
                              'caseCount': 6,
                              'boardHighlights': <String, Object?>{
                                'supplier': <String, Object?>{
                                  'supplyCategories': <String>['家具租赁'],
                                },
                              },
                            },
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
                'GET ${boardEnterpriseDetailPath(EnterpriseBoardType.company, 'e2a016f4-0b6a-497d-902c-409413858ca9')}':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'header': <String, Object?>{
                            'enterpriseId':
                                'e2a016f4-0b6a-497d-902c-409413858ca9',
                            'name': '西南会展搭建有限公司',
                            'primaryBoardType': 'company',
                            'shortIntro': '主打特装展台与活动执行。',
                            'provinceName': '四川',
                            'cityName': '成都',
                          },
                          'basicInfo': <String, Object?>{'fullIntro': '公司真实详情'},
                          'boardProfile': <String, Object?>{
                            'exhibitionTypes': <String>['特装展台'],
                          },
                          'serviceAreas': <Object?>[],
                          'cases': <Object?>[],
                          'certifications': <Object?>[],
                          'reviewSummary': <String, Object?>{},
                          'contacts': <Object?>[],
                        },
                      );
                    },
                'GET ${boardEnterpriseDetailPath(EnterpriseBoardType.factory, 'bf5ff83a-26e7-4138-8157-042fb38a5f46')}':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'header': <String, Object?>{
                            'enterpriseId':
                                'bf5ff83a-26e7-4138-8157-042fb38a5f46',
                            'name': '华南数字制作工厂',
                            'primaryBoardType': 'factory',
                            'shortIntro': '工厂真实详情。',
                            'provinceName': '广东',
                            'cityName': '佛山',
                          },
                          'basicInfo': <String, Object?>{'fullIntro': '工厂真实详情'},
                          'boardProfile': <String, Object?>{
                            'processTypes': <String>['木作'],
                          },
                          'serviceAreas': <Object?>[],
                          'cases': <Object?>[],
                          'certifications': <Object?>[],
                          'reviewSummary': <String, Object?>{},
                          'contacts': <Object?>[],
                        },
                      );
                    },
                'GET ${boardEnterpriseDetailPath(EnterpriseBoardType.supplier, 'c0576f5c-854c-4b78-9f93-6d57e55d8b47')}':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'header': <String, Object?>{
                            'enterpriseId':
                                'c0576f5c-854c-4b78-9f93-6d57e55d8b47',
                            'name': '华东会展物料供应商',
                            'primaryBoardType': 'supplier',
                            'shortIntro': '供应商真实详情。',
                            'provinceName': '江苏',
                            'cityName': '苏州',
                          },
                          'basicInfo': <String, Object?>{
                            'fullIntro': '供应商真实详情',
                          },
                          'boardProfile': <String, Object?>{
                            'supplyCategories': <String>['家具租赁'],
                          },
                          'serviceAreas': <Object?>[],
                          'cases': <Object?>[],
                          'certifications': <Object?>[],
                          'reviewSummary': <String, Object?>{},
                          'contacts': <Object?>[],
                        },
                      );
                    },
              },
            ),
          ),
        ),
      );

      final exhibitionConsumerLayer = ExhibitionConsumerLayer(
        client: AppApiClient(
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
                      body: const <String, Object?>{'items': <Object?>[]},
                    );
                  },
                },
          ),
        ),
      );

      Future<void> pumpHome() async {
        await tester.pumpWidget(
          ExhibitionMobileApp(
            key: UniqueKey(),
            initialRoute: '/',
            bootstrapShellContext: buildEnterpriseShellContext(),
            exhibitionConsumerLayer: exhibitionConsumerLayer,
            exhibitionHomeAggregationClient:
                _EnterpriseHubHomeAggregationClient(
                  result: _enterpriseHubHomeResult(),
                ),
            deviceLocationService:
                const _EnterpriseWorkbenchTestLocationService(
                  snapshot: DeviceLocationSnapshot(
                    permissionState: DeviceLocationPermissionState.granted,
                    latitude: 30.5728,
                    longitude: 104.0668,
                  ),
                ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(milliseconds: 300));
      }

      await pumpHome();
      expect(find.text('公司'), findsOneWidget);
      expect(find.text('工厂'), findsOneWidget);
      expect(find.text('供应商'), findsOneWidget);

      await tester.tap(find.text('公司'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('进入公司列表'), findsOneWidget);
      expect(find.text('查看公司详情'), findsNothing);
      expect(find.text('优秀公司'), findsNothing);
      expect(find.text('西南会展搭建有限公司'), findsOneWidget);

      await tester.tap(find.text('西南会展搭建有限公司').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('公司真实详情'), findsWidgets);
      expect(
        find.text('当前还没有读取到真实企业详情；页面保持受控阻断，不把空态或错误态伪装成实体已接通。'),
        findsNothing,
      );

      await pumpHome();
      await tester.tap(find.text('公司'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      await tester.ensureVisible(find.text('进入公司列表'));
      await tester.tap(find.text('进入公司列表'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('当前展示：已接通内容，共 1 家'), findsOneWidget);
      expect(find.text('西南会展搭建有限公司'), findsWidgets);

      await tester.tap(find.text('西南会展搭建有限公司').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('公司真实详情'), findsWidgets);
      expect(
        find.text('当前还没有读取到真实企业详情；页面保持受控阻断，不把空态或错误态伪装成实体已接通。'),
        findsNothing,
      );
    },
  );

  testWidgets(
    'enterprise apply route hides upstream truth and certification summary in normal state',
    (WidgetTester tester) async {
      EnterpriseHubWorkbenchConsumerLayer.install(
        EnterpriseHubWorkbenchConsumerLayer(
          client: AppApiClient(
            transport: FakeAppApiTransport(
              handlers:
                  <
                    String,
                    Future<AppApiResponse> Function(AppApiRequest request)
                  >{
                    'GET ${boardWorkbenchPath(EnterpriseBoardType.company)}':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: const <String, Object?>{
                              'organizationId': 'org-1',
                              'enterpriseId': 'ent-company-1',
                              'boardType': 'company',
                              'latestApplication': <String, Object?>{
                                'applicationId': 'app-1',
                                'applicationStatus': 'draft',
                              },
                              'basic': <String, Object?>{
                                'name': '西南会展搭建有限公司',
                                'shortIntro': '承接展陈搭建',
                                'fullIntro': '完整介绍',
                                'provinceCode': '510000',
                                'provinceName': '四川',
                                'cityCode': '510100',
                                'cityName': '成都',
                                'cooperationModes': <String>['主场服务'],
                                'contactVisible': true,
                                'albumImageFileAssetIds': <String>[
                                  'file-album-1',
                                  'file-album-2',
                                ],
                              },
                              'boardProfile': <String, Object?>{
                                'exhibitionTypes': <String>['特装展台'],
                                'serviceItems': <String>['设计搭建'],
                                'serviceCities': <String>['成都'],
                              },
                              'primaryContact': <String, Object?>{
                                'contactName': '王伟伟',
                                'mobile': '13800000000',
                                'isPrimary': true,
                                'visibleToPublic': true,
                              },
                              'cases': <Object?>[
                                <String, Object?>{
                                  'caseId': 'case-1',
                                  'boardType': 'company',
                                  'title': '成都车展案例',
                                  'summary': '展台搭建案例',
                                  'caseCoverFileAssetId': 'file-cover-1',
                                  'caseMediaFileAssetIds': <String>[
                                    'file-media-1',
                                  ],
                                  'isFeatured': true,
                                  'caseStatus': 'draft',
                                },
                              ],
                              'certification': <String, Object?>{
                                'certificationStatus': 'approved',
                                'legalName': '西南会展搭建有限公司',
                                'uscc': '91510100TEST12345',
                              },
                              'readiness': <String, Object?>{
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
                              'legalName': '西南会展搭建有限公司',
                              'uscc': '91510100TEST12345',
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
                              'address': '四川省成都市高新区天府大道 1 号',
                              'establishedAt': '2019-09-09',
                            },
                          );
                        },
                  },
            ),
          ),
        ),
      );

      final shellContext = AppShellContextData(
        userId: 'user-1',
        organizationId: 'org-1',
        certificationStatus: 'verified',
        visibleBuildings: const <String>['exhibition', 'messages', 'profile'],
      );

      await tester.pumpWidget(
        ExhibitionMobileApp(
          initialRoute: ExhibitionRoutes.enterpriseApplyWithBoardType(
            'company',
          ),
          bootstrapShellContext: shellContext,
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey<String>('company-workbench-homepage')),
        findsOneWidget,
      );
      await scrollCompanyHomepageUntilVisible(
        tester,
        find.byKey(const ValueKey<String>('company-workbench-module-entries')),
      );
      expect(
        find.byKey(const ValueKey<String>('company-workbench-module-entries')),
        findsOneWidget,
      );
      expect(find.text('公司展示工作台'), findsWidgets);
      expect(find.text('企业认证'), findsNothing);
      expect(
        find.byKey(
          const ValueKey<String>(
            'enterprise-workbench-display-identification-section',
          ),
        ),
        findsNothing,
      );
      expect(find.text('数据看板'), findsNothing);
      expect(find.text('最新动态'), findsNothing);
      expect(find.text('服务城市（逗号分隔）'), findsNothing);
      expect(find.text('最大项目规模'), findsNothing);
      expect(find.text('资质说明'), findsNothing);
      expect(
        find.byKey(
          const ValueKey<String>('enterprise-workbench-truth-section'),
        ),
        findsNothing,
      );
      expect(
        find.byKey(
          const ValueKey<String>(
            'enterprise-workbench-certification-summary-section',
          ),
        ),
        findsNothing,
      );
      expect(find.text('上游真值'), findsNothing);
      expect(find.text('认证摘要'), findsNothing);
      expect(find.textContaining('请先去我的公司'), findsNothing);
      expect(find.textContaining('请先完成企业认证信息补齐'), findsNothing);
      expect(find.textContaining('注册城市'), findsNothing);

      await openCompanyWorkbenchModule(tester, '展示标识');
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
    },
  );

  testWidgets(
    'enterprise workbench save basic ensures shell before basic save when contact is still empty',
    (WidgetTester tester) async {
      ChinaRegionCatalogLoader.installLoadOverrideForTest(
        () async => ChinaRegionCatalog(
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
                ),
              ],
            ),
          ],
        ),
      );

      Map<String, Object?> shellOnlyWorkbenchPayload({String? enterpriseId}) {
        final payload = buildWorkbenchPayload(enterpriseId: enterpriseId);
        payload.remove('latestApplication');
        payload.remove('primaryContact');
        payload['readiness'] = <String, Object?>{
          'hasApplication': false,
          'draftEditable': false,
          'basicCompleted': true,
          'profileCompleted': true,
          'hasCase': true,
          'hasContact': false,
          'certificationApproved': true,
          'submitReady': false,
          'blockers': const <String>['请先补联系人'],
        };
        return payload;
      }

      var shellReady = false;
      final actionTransport = FakeAppApiTransport(
        handlers: <String, Future<AppApiResponse> Function(AppApiRequest)>{
          'POST ${boardEnsureShellPath(EnterpriseBoardType.company)}':
              (AppApiRequest request) async {
                shellReady = true;
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'enterpriseId': 'ent-shell-1',
                    'boardType': 'company',
                    'shellStatus': 'created',
                  },
                );
              },
          'PUT ${boardUpdateBasicPath(EnterpriseBoardType.company, 'ent-shell-1')}':
              (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: const <String, Object?>{'ok': true},
                );
              },
        },
      );

      installEnterpriseWorkbenchApplyDependencies();
      EnterpriseHubWorkbenchConsumerLayer.install(
        EnterpriseHubWorkbenchConsumerLayer(
          client: AppApiClient(
            transport: FakeAppApiTransport(
              handlers:
                  <String, Future<AppApiResponse> Function(AppApiRequest)>{
                    'GET ${boardWorkbenchPath(EnterpriseBoardType.company)}':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: shellOnlyWorkbenchPayload(
                              enterpriseId: shellReady ? 'ent-shell-1' : null,
                            ),
                          );
                        },
                  },
            ),
          ),
        ),
      );
      EnterpriseHubConsumerLayer.install(
        EnterpriseHubConsumerLayer(
          client: AppApiClient(transport: actionTransport),
        ),
      );

      await tester.pumpWidget(
        ExhibitionMobileApp(
          initialRoute: ExhibitionRoutes.enterpriseApplyWithBoardType(
            'company',
          ),
          bootstrapShellContext: buildEnterpriseShellContext(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      final dynamic state = tester.state(
        find.byType(EnterpriseApplicationPage),
      );
      for (var index = 0; index < 20; index += 1) {
        final snapshot =
            state.debugBasicSaveSnapshotForTest() as Map<String, Object?>;
        if (state.debugLoadingForTest == false &&
            snapshot['hasBasic'] == true) {
          break;
        }
        await tester.pump(const Duration(milliseconds: 100));
      }

      await openCompanyWorkbenchModule(tester, '基础资料');

      for (var index = 0; index < 20; index += 1) {
        if (find
            .byKey(const ValueKey<String>('enterprise-workbench-save-basic'))
            .evaluate()
            .isNotEmpty) {
          break;
        }
        await tester.pump(const Duration(milliseconds: 100));
      }

      final saveBasicButton = find.byKey(
        const ValueKey<String>('enterprise-workbench-save-basic'),
      );
      final scrollable = find.byType(Scrollable).first;
      for (var index = 0; index < 8; index += 1) {
        if (saveBasicButton.evaluate().isNotEmpty) {
          break;
        }
        await tester.drag(scrollable, const Offset(0, -320));
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(saveBasicButton, findsOneWidget);
      await tester.ensureVisible(saveBasicButton);
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(saveBasicButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      final requestKeys = actionTransport.requests
          .map(
            (request) =>
                '${request.method.name.toUpperCase()} ${request.canonicalPath}',
          )
          .toList(growable: false);
      expect(
        requestKeys,
        containsAllInOrder(<String>[
          'POST ${boardEnsureShellPath(EnterpriseBoardType.company)}',
          'PUT ${boardUpdateBasicPath(EnterpriseBoardType.company, 'ent-shell-1')}',
        ]),
      );
      expect(
        requestKeys,
        isNot(contains('POST /api/app/exhibition/enterprise-hub/applications')),
      );
      expect(actionTransport.requests.first.body, const <String, Object?>{});
      expect(state.debugCurrentEnterpriseIdForTest, 'ent-shell-1');
      expect(find.textContaining('请先填写联系人姓名和手机号'), findsNothing);
    },
  );

  testWidgets(
    'enterprise supplier workbench keeps single category save and hides retired supply mode UI',
    (WidgetTester tester) async {
      final actionTransport = FakeAppApiTransport(
        handlers: <String, Future<AppApiResponse> Function(AppApiRequest)>{
          'PUT ${boardUpdateProfilePath(EnterpriseBoardType.supplier, 'ent-supplier-1')}':
              (AppApiRequest request) async {
                final body = request.body as Map<String, Object?>;
                expect(body['supplyCategories'], <String>['广告喷绘公司']);
                expect(body.containsKey('supplyMode'), isFalse);
                expect(body['coreProductsOrServices'], <String>['标准展具']);
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: const <String, Object?>{'ok': true},
                );
              },
        },
      );
      installEnterpriseWorkbenchApplyDependencies(
        boardType: EnterpriseBoardType.supplier,
        workbenchPayload: buildWorkbenchPayload(
          boardType: 'supplier',
          enterpriseId: 'ent-supplier-1',
          name: '重庆坤特展览展示有限公司',
          shortIntro: '供应商展示',
          fullIntro: '供应商完整介绍',
          cases: const <Object?>[],
        ),
      );
      EnterpriseHubConsumerLayer.install(
        EnterpriseHubConsumerLayer(
          client: AppApiClient(transport: actionTransport),
        ),
      );

      await tester.pumpWidget(
        ExhibitionMobileApp(
          initialRoute: ExhibitionRoutes.enterpriseApplyWithBoardType(
            'supplier',
          ),
          bootstrapShellContext: buildEnterpriseShellContext(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(
        find.byKey(
          const ValueKey<String>('enterprise-workbench-header-section'),
        ),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey<String>('supplier-workbench-homepage')),
        findsOneWidget,
      );
      final serviceModuleFinder = find.byKey(
        const ValueKey<String>('supplier-workbench-module-服务能力'),
      );
      await tester.scrollUntilVisible(
        serviceModuleFinder,
        220,
        scrollable: find.byType(Scrollable).first,
      );
      await Scrollable.ensureVisible(
        tester.element(serviceModuleFinder),
        alignment: 0.5,
      );
      await tester.pumpAndSettle();
      expect(find.text('模块管理'), findsOneWidget);
      expect(find.text('供应模式'), findsNothing);
      expect(find.text('当前主板块为供应商，重点维护品类、供应模式与响应能力。'), findsNothing);

      await tester.tap(serviceModuleFinder);
      await tester.pumpAndSettle();

      final newSupplierCategoryFinder = find
          .widgetWithText(FilterChip, '广告喷绘公司')
          .first;
      await tester.ensureVisible(newSupplierCategoryFinder);
      await tester.pumpAndSettle();
      await tester.tap(newSupplierCategoryFinder);
      await tester.pumpAndSettle();

      final selectedNewChip = tester.widget<FilterChip>(
        newSupplierCategoryFinder,
      );
      final deselectedOldChip = tester.widget<FilterChip>(
        find.widgetWithText(FilterChip, '桁架舞台搭建厂').first,
      );
      expect(selectedNewChip.selected, isTrue);
      expect(deselectedOldChip.selected, isFalse);

      await tester.scrollUntilVisible(
        find.byKey(
          const ValueKey<String>(
            'enterprise-workbench-save-display-identification',
          ),
        ),
        220,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(
        find.byKey(
          const ValueKey<String>(
            'enterprise-workbench-save-display-identification',
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(
          const ValueKey<String>(
            'enterprise-workbench-save-display-identification',
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'enterprise factory workbench keeps local board-profile draft when remote hydration runs',
    (WidgetTester tester) async {
      installEnterpriseWorkbenchApplyDependencies(
        workbenchPayload: buildFactoryWorkbenchPayload(),
      );

      await tester.pumpWidget(
        ExhibitionMobileApp(
          initialRoute: ExhibitionRoutes.enterpriseApplyWithBoardType(
            'factory',
          ),
          bootstrapShellContext: buildEnterpriseShellContext(),
        ),
      );
      await tester.pumpAndSettle();

      final dynamic state = tester.state(
        find.byType(EnterpriseApplicationPage),
      );
      expect(
        find.byKey(const ValueKey<String>('factory-workbench-homepage')),
        findsOneWidget,
      );
      await openCompanyWorkbenchModule(tester, '展示标识');
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(
          const ValueKey<String>('enterprise-workbench-factory-name-field'),
        ),
        '海川新工厂',
      );
      await tester.pump();

      state.debugMarkProfileDraftDirtyForTest();
      state.debugHydrateBoardProfileFromWorkbenchForTest(<String, Object?>{
        'factoryName': '服务端回刷工厂',
        'processTypes': <String>['烤漆'],
        'coreProducts': <String>['服务端旧产品'],
        'equipmentList': <String>['喷绘机*2'],
        'showcaseImageFileAssetIds': <String>['file-server-2'],
        'plantAreaSqm': 3600,
      });
      await tester.pump();

      expect(find.text('海川新工厂'), findsOneWidget);
      expect(find.text('服务端回刷工厂'), findsNothing);
    },
  );

  testWidgets(
    'enterprise factory workbench collapses optional capability section by default',
    (WidgetTester tester) async {
      installEnterpriseWorkbenchApplyDependencies(
        workbenchPayload: buildFactoryWorkbenchPayload(),
      );

      await tester.pumpWidget(
        ExhibitionMobileApp(
          initialRoute: ExhibitionRoutes.enterpriseApplyWithBoardType(
            'factory',
          ),
          bootstrapShellContext: buildEnterpriseShellContext(),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey<String>('factory-workbench-homepage')),
        findsOneWidget,
      );
      await openCompanyWorkbenchModule(tester, '展示标识');
      await tester.scrollUntilVisible(
        find.byKey(
          const ValueKey<String>(
            'enterprise-workbench-factory-optional-section',
          ),
        ),
        220,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(
          const ValueKey<String>(
            'enterprise-workbench-factory-optional-section',
          ),
        ),
        findsOneWidget,
      );
      expect(find.text('履约与扩展能力（选填）'), findsOneWidget);
      expect(find.text('加急能力'), findsNothing);
      expect(find.text('运输能力'), findsNothing);
      expect(find.text('支持仓储'), findsNothing);

      await tester.scrollUntilVisible(
        find.byKey(
          const ValueKey<String>(
            'enterprise-workbench-factory-optional-section',
          ),
        ),
        220,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(
        find.byKey(
          const ValueKey<String>(
            'enterprise-workbench-factory-optional-section',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('履约与扩展能力（选填）'));
      await tester.pumpAndSettle();

      expect(find.text('加急能力'), findsOneWidget);
      expect(find.text('运输能力'), findsOneWidget);
      expect(find.text('支持仓储'), findsOneWidget);
    },
  );

  testWidgets(
    'enterprise case editor create route starts in save-case mode without nested case library actions',
    (WidgetTester tester) async {
      installEnterpriseWorkbenchApplyDependencies(
        workbenchPayload: buildWorkbenchPayload(
          cases: const <Object?>[
            <String, Object?>{
              'caseId': 'case-2',
              'boardType': 'company',
              'title': '2026 糖酒会案例',
              'summary': '已保存进案例库',
              'caseCoverFileAssetId': 'file-cover-2',
              'caseMediaFileAssetIds': <String>['file-media-2'],
              'isFeatured': true,
              'caseStatus': 'draft',
            },
          ],
        ),
      );

      await tester.pumpWidget(
        ExhibitionMobileApp(
          initialRoute: ExhibitionRoutes.enterpriseCaseEditorWithBoardType(
            'company',
          ),
          bootstrapShellContext: buildEnterpriseShellContext(),
        ),
      );
      await tester.pump();

      final dynamic state = tester.state(
        find.byType(EnterpriseApplicationPage),
      );
      expect(state.debugIsPublishedChangeModeForTest, isFalse);
      expect(state.debugCaseSaveActionLabelForTest, '保存案例');
      expect(find.text('案例编辑器'), findsOneWidget);
      expect(find.text('公司案例编辑工作台'), findsOneWidget);
      expect(find.text('返回企业工作台'), findsOneWidget);
      expect(find.text('案例库'), findsNothing);
      expect(find.text('继续编辑'), findsNothing);
    },
  );

  testWidgets(
    'enterprise workbench case library card exposes continue edit and hides draft jargon',
    (WidgetTester tester) async {
      String? continuedCaseId;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnterpriseWorkbenchCaseListCard(
              items: const <EnterpriseHubWorkbenchCaseItem>[
                EnterpriseHubWorkbenchCaseItem(
                  caseId: 'case-1',
                  boardType: EnterpriseBoardType.company,
                  title: '2026 糖酒会案例',
                  summary: '已保存进案例库',
                  caseCoverFileAssetId: 'file-cover-1',
                  caseMediaFileAssetIds: <String>['file-media-1'],
                  isFeatured: true,
                  caseStatus: 'draft',
                ),
              ],
              onContinueEdit: (String caseId) {
                continuedCaseId = caseId;
              },
            ),
          ),
        ),
      );

      expect(find.text('案例库'), findsOneWidget);
      expect(find.text('已有案例'), findsNothing);
      expect(find.text('2026 糖酒会案例'), findsOneWidget);
      expect(find.text('已保存到案例库'), findsOneWidget);
      expect(find.text('继续编辑'), findsOneWidget);
      expect(find.text('草稿'), findsNothing);
      await tester.tap(find.text('继续编辑'));
      await tester.pump();
      expect(continuedCaseId, 'case-1');
    },
  );

  testWidgets(
    'enterprise case continuation preserves preloaded workbench image previews when detail omits url map',
    (WidgetTester tester) async {
      installEnterpriseWorkbenchApplyDependencies(
        workbenchPayload: buildWorkbenchPayload(
          cases: const <Object?>[
            <String, Object?>{
              'caseId': 'case-1',
              'boardType': 'company',
              'title': '已保存案例',
              'summary': '已保存进案例库',
              'caseCoverFileAssetId': 'file-cover-1',
              'caseMediaFileAssetIds': <String>['file-media-1'],
              'caseImageUrlMap': <String, String>{
                'file-cover-1': 'https://example.com/workbench-cover-1.png',
                'file-media-1': 'https://example.com/workbench-media-1.png',
              },
              'isFeatured': false,
              'caseStatus': 'draft',
            },
          ],
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
                    'GET /api/app/exhibition/enterprise-hub/cases/case-1':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: buildCaseDetailPayload(
                              caseCoverFileAssetId: 'file-cover-1',
                              caseMediaFileAssetIds: const <String>[
                                'file-media-1',
                              ],
                              caseImageUrlMap: const <String, String>{},
                            ),
                          );
                        },
                  },
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        ExhibitionMobileApp(
          initialRoute: ExhibitionRoutes.enterpriseApplyWithBoardType(
            'company',
          ),
          bootstrapShellContext: buildEnterpriseShellContext(),
        ),
      );
      await tester.pumpAndSettle();
      final dynamic state = tester.state(
        find.byType(EnterpriseApplicationPage),
      );
      state.debugHydrateCaseComposerFromWorkbenchCaseItemForTest(
        const EnterpriseHubWorkbenchCaseItem(
          caseId: 'case-1',
          boardType: EnterpriseBoardType.company,
          title: '已保存案例',
          summary: '已保存进案例库',
          caseCoverFileAssetId: 'file-cover-1',
          caseMediaFileAssetIds: <String>['file-media-1'],
          caseImageUrlMap: <String, String>{
            'file-cover-1': 'https://example.com/workbench-cover-1.png',
            'file-media-1': 'https://example.com/workbench-media-1.png',
          },
          isFeatured: false,
          caseStatus: 'draft',
        ),
      );
      await state.debugContinueEditCaseForTest('case-1');
      await tester.pump();
      expect(state.debugCaseSaveActionLabelForTest, '保存修改');
      expect(state.debugCaseTitleForTest, '2026 重庆工厂案例');
      expect(state.debugCaseExhibitionTypeForTest, '工厂开放日');
      expect(state.debugCaseCityForTest, '重庆');
      expect(state.debugCaseEventTimeForTest, '2026-05-18');
      expect(state.debugCaseSummaryForTest, '更新后的案例摘要');
      expect(state.debugCaseFeaturedForTest, isTrue);
      expect(state.debugCaseComposerImageFileAssetIdsForTest, const <String>[
        'file-cover-1',
        'file-media-1',
      ]);
      expect(state.debugCaseComposerImageUrlsForTest, const <String>[
        'https://example.com/workbench-cover-1.png',
        'https://example.com/workbench-media-1.png',
      ]);
    },
  );

  testWidgets(
    'enterprise workbench case editor enters published change corridor for post-submit factory cases',
    (WidgetTester tester) async {
      installEnterpriseWorkbenchApplyDependencies(
        workbenchPayload: buildWorkbenchPayload(
          boardType: 'factory',
          enterpriseId: 'ent-published-1',
          latestApplicationStatus: 'submitted',
          cases: const <Object?>[
            <String, Object?>{
              'caseId': 'case-1',
              'boardType': 'factory',
              'title': 'live snapshot',
              'summary': '当前线上案例摘要',
              'caseCoverFileAssetId': 'file-live-cover-1',
              'caseMediaFileAssetIds': <String>['file-live-cover-1'],
              'caseImageUrlMap': <String, String>{
                'file-live-cover-1': 'https://example.com/live-cover-1.png',
              },
              'isFeatured': false,
              'caseStatus': 'approved',
            },
          ],
        ),
      );
      installPublishedChangeWorkbenchDependencies(
        workbenchPayload: buildPublishedChangeWorkbenchPayload(
          enterpriseId: 'ent-published-1',
          boardType: 'factory',
          cases: const <Object?>[
            <String, Object?>{
              'caseId': 'case-1',
              'boardType': 'factory',
              'title': 'current change snapshot',
              'exhibitionType': '机械展',
              'city': '重庆',
              'eventTime': '2026-04-12',
              'summary': '当前变更中的工厂案例',
              'caseCoverFileAssetId': 'file-draft-cover-1',
              'caseMediaFileAssetIds': <String>[
                'file-draft-cover-1',
                'file-draft-media-1',
              ],
              'caseImageUrlMap': <String, String>{
                'file-draft-cover-1': 'https://example.com/draft-cover-1.png',
                'file-draft-media-1': 'https://example.com/draft-media-1.png',
              },
              'isFeatured': true,
              'caseStatus': 'draft',
            },
          ],
        ),
      );

      await tester.pumpWidget(
        ExhibitionMobileApp(
          initialRoute: ExhibitionRoutes.enterpriseCaseEditorWithBoardType(
            'factory',
            enterpriseId: 'ent-published-1',
            caseId: 'case-1',
          ),
          bootstrapShellContext: buildEnterpriseShellContext(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      final dynamic state = tester.state(
        find.byType(EnterpriseApplicationPage),
      );
      expect(state.debugIsPublishedChangeModeForTest, isTrue);
      expect(state.debugCurrentEnterpriseIdForTest, 'ent-published-1');
      expect(state.debugCaseSaveActionLabelForTest, '保存修改');
      expect(state.debugCaseTitleForTest, 'current change snapshot');
      expect(state.debugCaseExhibitionTypeForTest, '机械展');
      expect(state.debugCaseCityForTest, '重庆');
      expect(state.debugCaseEventTimeForTest, '2026-04-12');
      expect(state.debugCaseSummaryForTest, '当前变更中的工厂案例');
      expect(state.debugCaseFeaturedForTest, isTrue);
      expect(state.debugCaseComposerImageFileAssetIdsForTest, const <String>[
        'file-draft-cover-1',
        'file-draft-media-1',
      ]);
      expect(state.debugCaseComposerImageUrlsForTest, const <String>[
        'https://example.com/draft-cover-1.png',
        'https://example.com/draft-media-1.png',
      ]);
      expect(find.text('返回变更工作台'), findsOneWidget);
    },
  );

  testWidgets(
    'enterprise case editor workbench does not nest case library actions',
    (WidgetTester tester) async {
      installEnterpriseWorkbenchApplyDependencies(
        workbenchPayload: buildWorkbenchPayload(
          boardType: 'factory',
          enterpriseId: 'ent-published-1',
          latestApplicationStatus: 'submitted',
          cases: const <Object?>[
            <String, Object?>{
              'caseId': 'case-1',
              'boardType': 'factory',
              'title': 'live snapshot',
              'summary': '当前线上案例摘要',
              'caseCoverFileAssetId': 'file-live-cover-1',
              'caseMediaFileAssetIds': <String>['file-live-cover-1'],
              'caseImageUrlMap': <String, String>{
                'file-live-cover-1': 'https://example.com/live-cover-1.png',
              },
              'isFeatured': false,
              'caseStatus': 'approved',
            },
          ],
        ),
      );
      installPublishedChangeWorkbenchDependencies(
        workbenchPayload: buildPublishedChangeWorkbenchPayload(
          enterpriseId: 'ent-published-1',
          boardType: 'factory',
          cases: const <Object?>[
            <String, Object?>{
              'caseId': 'case-1',
              'boardType': 'factory',
              'title': 'current change snapshot',
              'exhibitionType': '机械展',
              'city': '重庆',
              'eventTime': '2026-04-12',
              'summary': '当前变更中的工厂案例',
              'caseCoverFileAssetId': 'file-draft-cover-1',
              'caseMediaFileAssetIds': <String>[
                'file-draft-cover-1',
                'file-draft-media-1',
              ],
              'caseImageUrlMap': <String, String>{
                'file-draft-cover-1': 'https://example.com/draft-cover-1.png',
                'file-draft-media-1': 'https://example.com/draft-media-1.png',
              },
              'isFeatured': true,
              'caseStatus': 'draft',
            },
          ],
        ),
      );

      await tester.pumpWidget(
        ExhibitionMobileApp(
          initialRoute: ExhibitionRoutes.enterpriseCaseEditorWithBoardType(
            'factory',
            enterpriseId: 'ent-published-1',
            caseId: 'case-1',
          ),
          bootstrapShellContext: buildEnterpriseShellContext(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      expect(find.text('工厂案例编辑工作台'), findsOneWidget);
      expect(find.text('案例编辑器'), findsOneWidget);
      expect(find.text('返回变更工作台'), findsOneWidget);
      expect(find.text('案例库'), findsNothing);
      expect(find.text('继续编辑'), findsNothing);
      expect(find.widgetWithText(FilledButton, '新增案例'), findsNothing);
    },
  );

  test(
    'enterprise workbench case update body matches direct continuation contract',
    () {
      final body = enterpriseWorkbenchCaseUpdateBody(
        titleText: '2026 重庆工厂案例',
        exhibitionTypeText: '工厂开放日',
        cityText: '重庆',
        eventTimeText: '2026-05-18',
        summaryText: '继续编辑后的案例摘要',
        caseMediaFileAssetIds: const <String>['file-cover-9', 'file-media-9'],
        isFeatured: true,
      );

      expect(body['title'], '2026 重庆工厂案例');
      expect(body['exhibitionType'], '工厂开放日');
      expect(body['city'], '重庆');
      expect(body['eventTime'], '2026-05-18');
      expect(body['summary'], '继续编辑后的案例摘要');
      expect(body['caseCoverFileAssetId'], 'file-cover-9');
      expect(body['caseMediaFileAssetIds'], const <String>[
        'file-cover-9',
        'file-media-9',
      ]);
      expect(body['isFeatured'], isTrue);
      expect(body.containsKey('boardType'), isFalse);
    },
  );

  test(
    'enterprise case update uses canonical put path for direct continuation',
    () async {
      AppApiRequest? seenUpdateRequest;
      EnterpriseHubConsumerLayer.install(
        EnterpriseHubConsumerLayer(
          client: AppApiClient(
            transport: FakeAppApiTransport(
              handlers:
                  <
                    String,
                    Future<AppApiResponse> Function(AppApiRequest request)
                  >{
                    'PUT /api/app/exhibition/enterprise-hub/cases/case-1':
                        (AppApiRequest request) async {
                          seenUpdateRequest = request;
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: const <String, Object?>{
                              'caseId': 'case-1',
                              'caseStatus': 'draft',
                            },
                          );
                        },
                  },
            ),
          ),
        ),
      );

      final body = enterpriseWorkbenchCaseUpdateBody(
        titleText: '2026 重庆工厂案例',
        exhibitionTypeText: '工厂开放日',
        cityText: '重庆',
        eventTimeText: '2026-05-18',
        summaryText: '继续编辑后的案例摘要',
        caseMediaFileAssetIds: const <String>['file-cover-9', 'file-media-9'],
        isFeatured: true,
      );
      final result = await EnterpriseHubConsumerLayer.instance.updateCase(
        caseId: 'case-1',
        body: body,
      );

      expect(result.isSuccess, isTrue);
      expect(result.path, '/api/app/exhibition/enterprise-hub/cases/case-1');
      expect(seenUpdateRequest?.canonicalPath, result.path);
      expect(seenUpdateRequest?.method, AppApiMethod.put);
      expect(seenUpdateRequest?.body, body);
    },
  );

  test(
    'enterprise workbench corridor required exits direct editing with controlled prompt',
    () {
      expect(
        enterpriseWorkbenchShouldExitDirectCaseEditing(
          'ENTERPRISE_HUB_CHANGE_CORRIDOR_REQUIRED',
        ),
        isTrue,
      );
      expect(
        enterpriseWorkbenchShouldExitDirectCaseEditing(
          'ENTERPRISE_HUB_CASE_NOT_FOUND',
        ),
        isFalse,
      );
      expect(
        enterpriseWorkbenchCaseContinuationVisibleMessage(
          errorCode: 'ENTERPRISE_HUB_CHANGE_CORRIDOR_REQUIRED',
        ),
        '当前案例已进入正式展示变更流程，当前页不再继续直接编辑，请改走正式变更入口。',
      );
    },
  );

  testWidgets(
    'enterprise generic factory workbench route with enterpriseId enters current change carrier before live hydration',
    (WidgetTester tester) async {
      var publishedWorkbenchCalls = 0;
      installEnterpriseWorkbenchApplyDependencies(
        workbenchPayload: buildFactoryWorkbenchPayload(
          enterpriseId: 'ent-published-1',
          latestApplicationStatus: 'approved',
          factoryName: 'live 工厂档案',
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
                    'GET ${boardPublishedChangeWorkbenchPath(EnterpriseBoardType.factory, 'ent-published-1')}':
                        (AppApiRequest request) async {
                          publishedWorkbenchCalls += 1;
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: buildPublishedChangeWorkbenchPayload(
                              enterpriseId: 'ent-published-1',
                              boardType: 'factory',
                            ),
                          );
                        },
                    'GET ${boardPublishedChangeStatusPath(EnterpriseBoardType.factory, 'ent-published-1')}':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: buildPublishedChangeStatusPayload(
                              enterpriseId: 'ent-published-1',
                            ),
                          );
                        },
                  },
            ),
          ),
        ),
      );

      final initialRoute = Uri(
        path: ExhibitionRoutes.enterpriseApply,
        queryParameters: <String, String>{
          'boardType': 'factory',
          'enterpriseId': 'ent-published-1',
        },
      ).toString();

      await tester.pumpWidget(
        ExhibitionMobileApp(
          initialRoute: initialRoute,
          bootstrapShellContext: buildEnterpriseShellContext(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      final dynamic state = tester.state(
        find.byType(EnterpriseApplicationPage).last,
      );
      expect(publishedWorkbenchCalls, 1);
      expect(state.debugIsPublishedChangeModeForTest, isTrue);
      expect(state.debugHasPublishedWorkbenchDataForTest, isTrue);
      expect(state.debugWorkbenchStateForTest, isNull);
      expect(find.text('工厂展示变更工作台'), findsNothing);
      expect(
        find.byKey(const ValueKey<String>('factory-workbench-homepage')),
        findsOneWidget,
      );
      await openCompanyStatusModule(tester);
      expect(
        find.byKey(
          const ValueKey<String>(
            'enterprise-published-change-snapshot-section',
          ),
        ),
        findsOneWidget,
      );
      expect(find.text('live 工厂档案'), findsNothing);
    },
  );

  testWidgets(
    'enterprise generic factory case editor route enters current change carrier and skips live case detail continuation',
    (WidgetTester tester) async {
      var liveCaseDetailCalls = 0;
      installEnterpriseWorkbenchApplyDependencies(
        workbenchPayload: buildFactoryWorkbenchPayload(
          enterpriseId: 'ent-published-1',
          latestApplicationStatus: 'approved',
          factoryName: 'live 工厂档案',
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
                    'GET ${boardPublishedChangeWorkbenchPath(EnterpriseBoardType.factory, 'ent-published-1')}':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: buildPublishedChangeWorkbenchPayload(
                              enterpriseId: 'ent-published-1',
                              boardType: 'factory',
                              cases: const <Object?>[
                                <String, Object?>{
                                  'caseId': 'case-published-1',
                                  'boardType': 'factory',
                                  'title': 'current change 工厂案例',
                                  'exhibitionType': '木作制作',
                                  'city': '重庆',
                                  'eventTime': '2026-05-18',
                                  'summary': '当前变更稿中的工厂案例',
                                  'caseCoverFileAssetId':
                                      'file-published-cover-1',
                                  'caseMediaFileAssetIds': <String>[
                                    'file-published-cover-1',
                                    'file-published-media-1',
                                  ],
                                  'isFeatured': true,
                                  'caseStatus': 'approved',
                                },
                              ],
                            ),
                          );
                        },
                    'GET ${boardPublishedChangeStatusPath(EnterpriseBoardType.factory, 'ent-published-1')}':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: buildPublishedChangeStatusPayload(
                              enterpriseId: 'ent-published-1',
                            ),
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
                    'GET /api/app/exhibition/enterprise-hub/cases/case-published-1':
                        (AppApiRequest request) async {
                          liveCaseDetailCalls += 1;
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: buildCaseDetailPayload(
                              caseId: 'case-published-1',
                              enterpriseId: 'ent-published-1',
                              boardType: 'factory',
                              title: 'live 直改案例',
                            ),
                          );
                        },
                  },
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        ExhibitionMobileApp(
          initialRoute: ExhibitionRoutes.enterpriseCaseEditorWithBoardType(
            'factory',
            enterpriseId: 'ent-published-1',
            caseId: 'case-published-1',
          ),
          bootstrapShellContext: buildEnterpriseShellContext(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      final dynamic state = tester.state(
        find.byType(EnterpriseApplicationPage),
      );
      expect(liveCaseDetailCalls, 0);
      expect(state.debugIsPublishedChangeModeForTest, isTrue);
      expect(state.debugCurrentEnterpriseIdForTest, 'ent-published-1');
      expect(state.debugCaseSaveActionLabelForTest, '保存修改');
      expect(state.debugCaseTitleForTest, 'current change 工厂案例');
      expect(find.text('current change 工厂案例'), findsOneWidget);
      expect(find.text('live 直改案例'), findsNothing);
      expect(find.text('返回变更工作台'), findsOneWidget);
    },
  );

  test(
    'enterprise workbench basic update body sends contactName and contactMobile',
    () {
      final body = enterpriseWorkbenchBasicUpdateBody(
        enterpriseName: '西南会展搭建有限公司',
        contactNameText: '李经理',
        contactMobileText: '13900002222',
        logoFileAssetId: 'file-logo-1',
        shortIntroText: '承接展陈搭建',
        fullIntroText: '完整介绍',
        provinceCode: '510000',
        provinceName: '四川',
        cityCode: '510100',
        cityName: '成都',
        addressText: '四川省成都市高新区天府大道 1 号',
        foundedAtText: '2019-09-09',
        teamSizeRange: '11_50',
        cooperationModes: <String>{'host_service'},
        contactVisible: true,
      );

      expect(body['contactName'], '李经理');
      expect(body['contactMobile'], '13900002222');
      expect(body.containsKey('wechat'), isFalse);
      expect(body.containsKey('phone'), isFalse);
      expect(body.containsKey('email'), isFalse);
      expect(body.containsKey('position'), isFalse);
    },
  );

  test(
    'enterprise workbench basic update body normalizes empty contact fields without widening payload',
    () {
      final body = enterpriseWorkbenchBasicUpdateBody(
        enterpriseName: '西南会展搭建有限公司',
        contactNameText: '   ',
        contactMobileText: '',
        logoFileAssetId: null,
        shortIntroText: '承接展陈搭建',
        fullIntroText: '完整介绍',
        provinceCode: '510000',
        provinceName: '四川',
        cityCode: '510100',
        cityName: '成都',
        addressText: '四川省成都市高新区天府大道 1 号',
        foundedAtText: '2019-09-09',
        teamSizeRange: null,
        cooperationModes: <String>{'host_service'},
        contactVisible: true,
      );

      expect(body.containsKey('contactName'), isTrue);
      expect(body.containsKey('contactMobile'), isTrue);
      expect(body['contactName'], isNull);
      expect(body['contactMobile'], isNull);
      expect(body['name'], '西南会展搭建有限公司');
      expect(body['provinceCode'], '510000');
      expect(body['provinceName'], '四川');
      expect(body['cityCode'], '510100');
      expect(body['cityName'], '成都');
      expect(body.containsKey('wechat'), isFalse);
      expect(body.containsKey('phone'), isFalse);
      expect(body.containsKey('email'), isFalse);
      expect(body.containsKey('position'), isFalse);
    },
  );

  test(
    'enterprise workbench board profile hydration stops when local draft is pending',
    () {
      expect(
        enterpriseWorkbenchShouldHydrateBoardProfileFromWorkbench(
          hasPendingLocalProfileDraft: false,
        ),
        isTrue,
      );
      expect(
        enterpriseWorkbenchShouldHydrateBoardProfileFromWorkbench(
          hasPendingLocalProfileDraft: true,
        ),
        isFalse,
      );
    },
  );

  test(
    'enterprise workbench approved submit disposition switches to status view',
    () {
      const readiness = EnterpriseHubWorkbenchReadiness(
        hasApplication: true,
        draftEditable: true,
        basicCompleted: true,
        profileCompleted: true,
        hasCase: true,
        hasContact: true,
        certificationApproved: true,
        submitReady: false,
        blockers: <String>['请先完善企业简介'],
      );
      const latestApplication = EnterpriseHubWorkbenchApplication(
        applicationId: 'app-1',
        applicationStatus: 'approved',
        reviewedAt: '2026-04-09T12:00:00Z',
      );

      final disposition = enterpriseWorkbenchSubmitDisposition(
        latestApplication: latestApplication,
        readiness: readiness,
      );

      expect(disposition.isPostSubmit, isTrue);
      expect(disposition.subtitle, '当前申请已通过；如需继续测试或准备新一轮提交，请重新创建申请草稿。');
      expect(disposition.panelTitle, '申请已通过');
      expect(disposition.panelBody, '当前申请已通过审核。若要继续验证修改链，请先重新创建一条新的申请草稿。');
      expect(disposition.panelHighlighted, isFalse);
      expect(disposition.showSubmitAction, isFalse);
      expect(disposition.showRecreateDraftAction, isTrue);
      expect(disposition.showViewApplicationStatusAction, isTrue);
      expect(disposition.viewApplicationStatusPrimary, isFalse);
      expect(disposition.showBlockers, isFalse);
    },
  );

  test(
    'enterprise workbench revision required submit disposition offers recreate draft entry',
    () {
      const readiness = EnterpriseHubWorkbenchReadiness(
        hasApplication: true,
        draftEditable: false,
        basicCompleted: true,
        profileCompleted: true,
        hasCase: true,
        hasContact: true,
        certificationApproved: true,
        submitReady: false,
        blockers: <String>[],
      );
      const latestApplication = EnterpriseHubWorkbenchApplication(
        applicationId: 'app-2',
        applicationStatus: 'revision_required',
        rejectionReason: '请补案例说明',
      );

      final disposition = enterpriseWorkbenchSubmitDisposition(
        latestApplication: latestApplication,
        readiness: readiness,
      );

      expect(disposition.isPostSubmit, isTrue);
      expect(disposition.showSubmitAction, isFalse);
      expect(disposition.showRecreateDraftAction, isTrue);
      expect(disposition.showViewApplicationStatusAction, isTrue);
      expect(disposition.panelTitle, '申请需补充资料');
      expect(disposition.panelBody, contains('重新创建申请草稿后'));
    },
  );

  test(
    'enterprise workbench rejected submit disposition offers recreate draft entry',
    () {
      const readiness = EnterpriseHubWorkbenchReadiness(
        hasApplication: true,
        draftEditable: false,
        basicCompleted: true,
        profileCompleted: true,
        hasCase: true,
        hasContact: true,
        certificationApproved: true,
        submitReady: false,
        blockers: <String>[],
      );
      const latestApplication = EnterpriseHubWorkbenchApplication(
        applicationId: 'app-3',
        applicationStatus: 'rejected',
        rejectionReason: '信息不一致',
      );

      final disposition = enterpriseWorkbenchSubmitDisposition(
        latestApplication: latestApplication,
        readiness: readiness,
      );

      expect(disposition.isPostSubmit, isTrue);
      expect(disposition.showSubmitAction, isFalse);
      expect(disposition.showRecreateDraftAction, isTrue);
      expect(disposition.showViewApplicationStatusAction, isTrue);
      expect(disposition.panelTitle, '申请未通过');
      expect(disposition.panelBody, contains('信息不一致'));
    },
  );

  test(
    'enterprise workbench draft submit disposition keeps pre-submit blockers',
    () {
      const readiness = EnterpriseHubWorkbenchReadiness(
        hasApplication: true,
        draftEditable: true,
        basicCompleted: false,
        profileCompleted: true,
        hasCase: true,
        hasContact: true,
        certificationApproved: true,
        submitReady: false,
        blockers: <String>['请先完善企业简介'],
      );
      const latestApplication = EnterpriseHubWorkbenchApplication(
        applicationId: 'app-1',
        applicationStatus: 'draft',
      );

      final disposition = enterpriseWorkbenchSubmitDisposition(
        latestApplication: latestApplication,
        readiness: readiness,
      );

      expect(disposition.isPostSubmit, isFalse);
      expect(disposition.subtitle, '提交按钮置灰时，会在下方明确显示未完成项。');
      expect(disposition.showSubmitAction, isTrue);
      expect(disposition.showViewApplicationStatusAction, isTrue);
      expect(disposition.viewApplicationStatusPrimary, isFalse);
      expect(disposition.showBlockers, isTrue);
      expect(disposition.panelTitle, isNull);
      expect(disposition.panelBody, isNull);
    },
  );

  test(
    'enterprise workbench upstream truth semantics show only when organization city or founded date truth is missing',
    () {
      expect(
        enterpriseWorkbenchShouldShowUpstreamTruthSection(
          enterpriseNameTruth: '西南会展搭建有限公司',
          organizationCityTruth: '四川 / 成都',
          foundedAtTruth: '2019-09-09',
        ),
        isFalse,
      );
      expect(
        enterpriseWorkbenchShouldShowUpstreamTruthSection(
          enterpriseNameTruth: '西南会展搭建有限公司',
          organizationCityTruth: null,
          foundedAtTruth: '2019-09-09',
        ),
        isTrue,
      );
      expect(
        enterpriseWorkbenchShouldShowUpstreamTruthSection(
          enterpriseNameTruth: '西南会展搭建有限公司',
          organizationCityTruth: '四川 / 成都',
          foundedAtTruth: null,
        ),
        isTrue,
      );
      expect(enterpriseWorkbenchOrganizationCityTruthLabel, '组织所在城市');
      expect(
        enterpriseWorkbenchOrganizationCityTruthLabel.contains('注册城市'),
        isFalse,
      );
      expect(
        enterpriseWorkbenchOrganizationCityTruthHelperText(isMissing: true),
        contains('请先去我的公司补全组织所在城市'),
      );
      expect(
        enterpriseWorkbenchOrganizationCityTruthHelperText(
          isMissing: true,
        ).contains('注册城市'),
        isFalse,
      );
    },
  );

  test(
    'enterprise workbench certification summary semantics show only in abnormal states',
    () {
      expect(
        enterpriseWorkbenchShouldShowCertificationSummary(
          certificationStatus: 'approved',
          rejectReason: null,
        ),
        isFalse,
      );
      expect(
        enterpriseWorkbenchShouldShowCertificationSummary(
          certificationStatus: 'verified',
          rejectReason: null,
        ),
        isFalse,
      );
      expect(
        enterpriseWorkbenchShouldShowCertificationSummary(
          certificationStatus: 'submitted',
          rejectReason: null,
        ),
        isTrue,
      );
      expect(
        enterpriseWorkbenchShouldShowCertificationSummary(
          certificationStatus: 'approved',
          rejectReason: '营业执照信息不一致',
        ),
        isTrue,
      );
    },
  );

  testWidgets(
    'enterprise published change workbench consumes changes current family and separates live snapshot from current snapshot',
    (WidgetTester tester) async {
      AppApiRequest? seenWorkbenchRequest;
      AppApiRequest? seenStatusRequest;
      EnterpriseHubPublishedChangeConsumerLayer.install(
        EnterpriseHubPublishedChangeConsumerLayer(
          client: AppApiClient(
            transport: FakeAppApiTransport(
              handlers:
                  <
                    String,
                    Future<AppApiResponse> Function(AppApiRequest request)
                  >{
                    'GET ${boardPublishedChangeWorkbenchPath(EnterpriseBoardType.company, 'ent-published-1')}':
                        (AppApiRequest request) async {
                          seenWorkbenchRequest = request;
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: buildPublishedChangeWorkbenchPayload(),
                          );
                        },
                    'GET ${boardPublishedChangeStatusPath(EnterpriseBoardType.company, 'ent-published-1')}':
                        (AppApiRequest request) async {
                          seenStatusRequest = request;
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
      installPublishedChangeWorkbenchDependencies(installConsumer: false);

      await tester.pumpWidget(
        ExhibitionMobileApp(
          initialRoute:
              ExhibitionRoutes.enterprisePublishedChangeWorkbenchWithEnterpriseId(
                'ent-published-1',
                boardType: 'company',
              ),
          bootstrapShellContext: buildEnterpriseShellContext(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      final dynamic state = tester.state(
        find.byType(EnterpriseApplicationPage),
      );
      expect(
        seenWorkbenchRequest?.canonicalPath,
        boardPublishedChangeWorkbenchPath(
          EnterpriseBoardType.company,
          'ent-published-1',
        ),
      );
      expect(
        seenStatusRequest?.canonicalPath,
        boardPublishedChangeStatusPath(
          EnterpriseBoardType.company,
          'ent-published-1',
        ),
      );
      expect(state.debugIsPublishedChangeModeForTest, isTrue);
      expect(state.debugCurrentEnterpriseIdForTest, 'ent-published-1');
      expect(
        state.debugPublishedWorkbenchStateForTest,
        AppPageState.content,
        reason: state.debugPublishedWorkbenchMessageForTest,
      );
      expect(state.debugHasPublishedWorkbenchDataForTest, isTrue);
      expect(
        find.byKey(const ValueKey<String>('company-workbench-homepage')),
        findsOneWidget,
      );
      expect(find.text('公司展示变更工作台'), findsNothing);

      await openCompanyStatusModule(tester);
      expect(
        find.byKey(
          const ValueKey<String>(
            'enterprise-published-change-snapshot-section',
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const ValueKey<String>(
            'enterprise-published-change-current-snapshot',
          ),
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
          const ValueKey<String>(
            'enterprise-published-change-current-snapshot',
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const ValueKey<String>('enterprise-published-change-live-snapshot'),
        ),
        findsOneWidget,
      );
      await popTopRoute(tester);

      final quickPreviewFinder = find.byKey(
        const ValueKey<String>('company-workbench-quick-preview'),
      );
      await scrollCompanyHomepageUntilVisible(
        tester,
        quickPreviewFinder,
        step: const Offset(0, 360),
      );
      await Scrollable.ensureVisible(
        tester.element(quickPreviewFinder),
        alignment: 0.5,
      );
      await tester.pumpAndSettle();
      await tester.tap(quickPreviewFinder);
      await tester.pumpAndSettle();
      expect(
        find.byKey(
          const ValueKey<String>('enterprise-published-live-preview-section'),
        ),
        findsOneWidget,
      );
      expect(find.text('线上公开展示'), findsWidgets);
      await popTopRoute(tester);

      await scrollCompanyHomepageUntilVisible(
        tester,
        find.byKey(const ValueKey<String>('company-workbench-preview-summary')),
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
      expect(
        find.byKey(
          const ValueKey<String>('enterprise-published-change-preview-section'),
        ),
        findsOneWidget,
      );
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
      expect(find.textContaining('待 apply'), findsNothing);
      await popTopRoute(tester);
      expect(
        find.byKey(const ValueKey<String>('company-workbench-homepage')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'enterprise published change basic save uses changes current basic path and keeps copy off live semantics',
    (WidgetTester tester) async {
      AppApiRequest? seenSaveRequest;
      installPublishedChangeWorkbenchDependencies(installConsumer: false);
      EnterpriseHubPublishedChangeConsumerLayer.install(
        EnterpriseHubPublishedChangeConsumerLayer(
          client: AppApiClient(
            transport: FakeAppApiTransport(
              handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'GET ${boardPublishedChangeWorkbenchPath(EnterpriseBoardType.company, 'ent-published-1')}':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: buildPublishedChangeWorkbenchPayload(),
                      );
                    },
                'GET ${boardPublishedChangeStatusPath(EnterpriseBoardType.company, 'ent-published-1')}':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: buildPublishedChangeStatusPayload(),
                      );
                    },
                'PUT ${boardPublishedChangeBasicPath(EnterpriseBoardType.company, 'ent-published-1')}':
                    (AppApiRequest request) async {
                      seenSaveRequest = request;
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{'success': true},
                      );
                    },
              },
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        ExhibitionMobileApp(
          initialRoute:
              ExhibitionRoutes.enterprisePublishedChangeWorkbenchWithEnterpriseId(
                'ent-published-1',
                boardType: 'company',
              ),
          bootstrapShellContext: buildEnterpriseShellContext(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.byType(EnterpriseApplicationPage), findsOneWidget);
      await openCompanyWorkbenchModule(tester, '基础资料');
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey<String>('enterprise-workbench-save-basic')),
        220,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey<String>('enterprise-workbench-save-basic')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        seenSaveRequest?.canonicalPath,
        boardPublishedChangeBasicPath(
          EnterpriseBoardType.company,
          'ent-published-1',
        ),
      );
      expect(find.text('基础资料已保存到当前变更内容，线上展示暂未更新。'), findsOneWidget);
      expect(find.textContaining('已立即上线'), findsNothing);
    },
  );

  testWidgets(
    'enterprise published change case continuation refreshes into save-modification mode',
    (WidgetTester tester) async {
      EnterpriseHubPublishedChangeConsumerLayer.install(
        EnterpriseHubPublishedChangeConsumerLayer(
          client: AppApiClient(
            transport: FakeAppApiTransport(
              handlers:
                  <
                    String,
                    Future<AppApiResponse> Function(AppApiRequest request)
                  >{
                    'GET ${boardPublishedChangeWorkbenchPath(EnterpriseBoardType.company, 'ent-published-1')}':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: buildPublishedChangeWorkbenchPayload(),
                          );
                        },
                    'GET ${boardPublishedChangeStatusPath(EnterpriseBoardType.company, 'ent-published-1')}':
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
      installPublishedChangeWorkbenchDependencies(installConsumer: false);

      await tester.pumpWidget(
        ExhibitionMobileApp(
          initialRoute:
              ExhibitionRoutes.enterprisePublishedChangeWorkbenchWithEnterpriseId(
                'ent-published-1',
                boardType: 'company',
              ),
          bootstrapShellContext: buildEnterpriseShellContext(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      final dynamic state = tester.state(
        find.byType(EnterpriseApplicationPage),
      );
      await state.debugContinueEditCaseForTest('case-published-1');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 1));
      expect(state.debugIsPublishedChangeModeForTest, isTrue);
      expect(
        state.debugPublishedWorkbenchStateForTest,
        AppPageState.content,
        reason: state.debugPublishedWorkbenchMessageForTest,
      );
      expect(state.debugHasPublishedWorkbenchDataForTest, isTrue);
      expect(state.debugCaseSaveActionLabelForTest, '保存修改');
      expect(state.debugCaseTitleForTest, '已发布展示案例');
    },
  );

  testWidgets(
    'enterprise published change submit navigates to real status instead of guessing local live result',
    (WidgetTester tester) async {
      var submitCount = 0;
      EnterpriseHubPublishedChangeConsumerLayer.install(
        EnterpriseHubPublishedChangeConsumerLayer(
          client: AppApiClient(
            transport: FakeAppApiTransport(
              handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'GET ${boardPublishedChangeWorkbenchPath(EnterpriseBoardType.company, 'ent-published-1')}':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: buildPublishedChangeWorkbenchPayload(
                          changeStatus: submitCount == 0
                              ? 'draft'
                              : 'submitted',
                        ),
                      );
                    },
                'GET ${boardPublishedChangeStatusPath(EnterpriseBoardType.company, 'ent-published-1')}':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: buildPublishedChangeStatusPayload(
                          changeStatus: submitCount == 0
                              ? 'draft'
                              : 'submitted',
                        ),
                      );
                    },
                'POST ${boardPublishedChangeSubmitPath(EnterpriseBoardType.company, 'ent-published-1')}':
                    (AppApiRequest request) async {
                      submitCount += 1;
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{'success': true},
                      );
                    },
              },
            ),
          ),
        ),
      );
      installPublishedChangeWorkbenchDependencies(installConsumer: false);

      await tester.pumpWidget(
        ExhibitionMobileApp(
          initialRoute:
              ExhibitionRoutes.enterprisePublishedChangeWorkbenchWithEnterpriseId(
                'ent-published-1',
                boardType: 'company',
              ),
          bootstrapShellContext: buildEnterpriseShellContext(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      await openCompanyStatusModule(tester);
      await tester.scrollUntilVisible(
        find.byKey(
          const ValueKey<String>('enterprise-workbench-submit-change'),
        ),
        220,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(
        find.byKey(
          const ValueKey<String>('enterprise-workbench-submit-change'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(
          const ValueKey<String>('enterprise-workbench-submit-change'),
        ),
      );
      await tester.pumpAndSettle();

      expect(submitCount, 1);
      expect(find.text('变更状态'), findsOneWidget);
      expect(find.textContaining('当前变更已提交'), findsOneWidget);
      expect(find.textContaining('已写入线上展示'), findsNothing);
    },
  );

  testWidgets(
    'enterprise published change revision required stays on same change request and remains editable',
    (WidgetTester tester) async {
      installPublishedChangeWorkbenchDependencies(
        workbenchPayload: buildPublishedChangeWorkbenchPayload(
          changeStatus: 'revision_required',
          rejectionReason: '请补充案例摘要',
          submitReady: false,
          blockers: const <String>['请补充案例摘要'],
        ),
        statusPayload: buildPublishedChangeStatusPayload(
          changeStatus: 'revision_required',
          rejectionReason: '请补充案例摘要',
        ),
      );

      await tester.pumpWidget(
        ExhibitionMobileApp(
          initialRoute:
              ExhibitionRoutes.enterprisePublishedChangeWorkbenchWithEnterpriseId(
                'ent-published-1',
                boardType: 'company',
              ),
          bootstrapShellContext: buildEnterpriseShellContext(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      await openCompanyStatusModule(tester);
      await tester.scrollUntilVisible(
        find.byKey(
          const ValueKey<String>('enterprise-workbench-submit-section'),
        ),
        220,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('你正在修改同一条 change request'), findsOneWidget);
      expect(find.textContaining('changeRequestId：chg-1'), findsOneWidget);
      expect(
        find.byKey(
          const ValueKey<String>('enterprise-workbench-submit-change'),
        ),
        findsOneWidget,
      );
      expect(find.text('还差这些：'), findsOneWidget);
      expect(find.textContaining('请补充案例摘要'), findsWidgets);
    },
  );

  testWidgets(
    'enterprise published change status keeps approved and applied clearly separated',
    (WidgetTester tester) async {
      EnterpriseHubPublishedChangeConsumerLayer.install(
        EnterpriseHubPublishedChangeConsumerLayer(
          client: AppApiClient(
            transport: FakeAppApiTransport(
              handlers:
                  <
                    String,
                    Future<AppApiResponse> Function(AppApiRequest request)
                  >{
                    'GET ${boardPublishedChangeStatusPath(EnterpriseBoardType.company, 'ent-published-1')}':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: buildPublishedChangeStatusPayload(
                              changeStatus: 'approved',
                            ),
                          );
                        },
                  },
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        ExhibitionMobileApp(
          initialRoute:
              ExhibitionRoutes.enterprisePublishedChangeStatusWithEnterpriseId(
                'ent-published-1',
                boardType: 'company',
              ),
          bootstrapShellContext: buildEnterpriseShellContext(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.textContaining('待 apply'), findsWidgets);
      expect(find.textContaining('已写入 live listing'), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      EnterpriseHubPublishedChangeConsumerLayer.install(
        EnterpriseHubPublishedChangeConsumerLayer(
          client: AppApiClient(
            transport: FakeAppApiTransport(
              handlers:
                  <
                    String,
                    Future<AppApiResponse> Function(AppApiRequest request)
                  >{
                    'GET ${boardPublishedChangeStatusPath(EnterpriseBoardType.company, 'ent-published-1')}':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: buildPublishedChangeStatusPayload(
                              changeStatus: 'applied',
                            ),
                          );
                        },
                  },
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        ExhibitionMobileApp(
          initialRoute:
              ExhibitionRoutes.enterprisePublishedChangeStatusWithEnterpriseId(
                'ent-published-1',
                boardType: 'company',
              ),
          bootstrapShellContext: buildEnterpriseShellContext(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.textContaining('已写入 live listing'), findsWidgets);
      expect(find.textContaining('待 apply'), findsNothing);
    },
  );

  testWidgets(
    'enterprise workbench location fill resolves through cloud location route',
    (WidgetTester tester) async {
      var resolveCount = 0;
      installEnterpriseWorkbenchApplyDependencies();
      installEnterpriseLocationResolveStub(
        onRequest: (request) {
          resolveCount += 1;
          final body = request.body as Map<String, Object?>;
          expect(body['resolveMode'], 'device_location');
          expect(body['latitude'], 30.5728);
          expect(body['longitude'], 104.0668);
        },
        responseBody: (_) => <String, Object?>{
          'location': <String, Object?>{
            'addressText': '四川省成都市高新区天府大道 1 号',
            'publicDisplayAddress': '四川省成都市高新区天府大道 1 号',
            'provinceCode': '510000',
            'provinceName': '四川省',
            'cityCode': '510100',
            'cityName': '成都市',
            'districtCode': '510109',
            'districtName': '高新区',
            'latitude': 30.5728,
            'longitude': 104.0668,
            'geoSource': 'device_location',
            'geoStatus': 'resolved',
            'lastGeocodedAt': '2026-04-16T10:00:00.000Z',
            'mapProvider': 'amap',
            'mapLinkUrl':
                'https://uri.amap.com/marker?position=104.0668,30.5728',
          },
          'message': '已按当前位置解析出可公开展示的位置结果。',
        },
      );

      await tester.pumpWidget(
        ExhibitionMobileApp(
          initialRoute: ExhibitionRoutes.enterpriseApplyWithBoardType(
            'company',
          ),
          bootstrapShellContext: buildEnterpriseShellContext(),
          deviceLocationService: const _EnterpriseWorkbenchTestLocationService(
            snapshot: DeviceLocationSnapshot(
              permissionState: DeviceLocationPermissionState.granted,
              latitude: 30.5728,
              longitude: 104.0668,
            ),
            reverseGeocodingSupported: false,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      await openCompanyWorkbenchModule(tester, '地址与服务区域');
      await tester.scrollUntilVisible(
        find.byKey(
          const ValueKey<String>(
            'enterprise-workbench-address-fill-from-location',
          ),
        ),
        240,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(
        find.byKey(
          const ValueKey<String>(
            'enterprise-workbench-address-fill-from-location',
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(
          const ValueKey<String>(
            'enterprise-workbench-address-fill-from-location',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(resolveCount, 1);
      expect(find.text('已按当前位置解析企业位置。'), findsOneWidget);
      expect(find.text('位置状态：已解析坐标'), findsOneWidget);
      final addressField = tester.widget<TextField>(
        find.byKey(
          const ValueKey<String>('enterprise-workbench-address-field'),
        ),
      );
      expect(addressField.controller?.text, '四川省成都市高新区天府大道 1 号');
    },
  );

  testWidgets(
    'enterprise workbench manual address resolves through cloud location route',
    (WidgetTester tester) async {
      var resolveCount = 0;
      installEnterpriseWorkbenchApplyDependencies();
      installEnterpriseLocationResolveStub(
        onRequest: (request) {
          resolveCount += 1;
          final body = request.body as Map<String, Object?>;
          expect(body['resolveMode'], 'manual_address');
          expect(body['addressText'], '四川省成都市高新区天府大道 1 号');
        },
        responseBody: (_) => <String, Object?>{
          'location': <String, Object?>{
            'addressText': '四川省成都市高新区天府大道 1 号',
            'publicDisplayAddress': '四川省成都市高新区天府大道 1 号',
            'provinceCode': '510000',
            'provinceName': '四川省',
            'cityCode': '510100',
            'cityName': '成都市',
            'districtCode': '510109',
            'districtName': '高新区',
            'latitude': 30.5728,
            'longitude': 104.0668,
            'geoSource': 'manual_address_geocode',
            'geoStatus': 'resolved',
            'lastGeocodedAt': '2026-04-16T10:00:00.000Z',
            'mapProvider': 'amap',
          },
          'message': '文字地址已解析为可公开展示的位置结果。',
        },
      );

      await tester.pumpWidget(
        ExhibitionMobileApp(
          initialRoute: ExhibitionRoutes.enterpriseApplyWithBoardType(
            'company',
          ),
          bootstrapShellContext: buildEnterpriseShellContext(),
          deviceLocationService: const _EnterpriseWorkbenchTestLocationService(
            snapshot: DeviceLocationSnapshot(
              permissionState: DeviceLocationPermissionState.granted,
              latitude: 30.5728,
              longitude: 104.0668,
            ),
            reverseGeocodingSupported: true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      await openCompanyWorkbenchModule(tester, '地址与服务区域');
      await tester.scrollUntilVisible(
        find.byKey(
          const ValueKey<String>('enterprise-workbench-address-field'),
        ),
        240,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(
        find.byKey(
          const ValueKey<String>('enterprise-workbench-address-field'),
        ),
      );
      await tester.enterText(
        find.byKey(
          const ValueKey<String>('enterprise-workbench-address-field'),
        ),
        '四川省成都市高新区天府大道 1 号',
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(
          const ValueKey<String>('enterprise-workbench-address-resolve-manual'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(
          const ValueKey<String>('enterprise-workbench-address-resolve-manual'),
        ),
      );
      await tester.pumpAndSettle();

      expect(resolveCount, 1);
      expect(find.text('文字地址已解析为企业位置候选。'), findsOneWidget);
      expect(find.text('位置状态：已解析坐标'), findsOneWidget);
      final addressField = tester.widget<TextField>(
        find.byKey(
          const ValueKey<String>('enterprise-workbench-address-field'),
        ),
      );
      expect(addressField.controller?.text, '四川省成都市高新区天府大道 1 号');
    },
  );

  testWidgets(
    'enterprise workbench location fill surfaces provider failure without fake map',
    (WidgetTester tester) async {
      installEnterpriseWorkbenchApplyDependencies();
      EnterpriseHubConsumerLayer.install(
        EnterpriseHubConsumerLayer(
          client: AppApiClient(
            transport: FakeAppApiTransport(
              handlers:
                  <String, Future<AppApiResponse> Function(AppApiRequest)>{
                    'POST /api/app/exhibition/enterprise-hub/location/resolve':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 503,
                            uri: request.uri,
                            body: const <String, Object?>{
                              'code':
                                  'ENTERPRISE_LOCATION_PROVIDER_CONFIG_MISSING',
                              'message': '当前企业位置解析缺少高德运行态配置，请先完成配置后再试。',
                            },
                          );
                        },
                  },
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        ExhibitionMobileApp(
          initialRoute: ExhibitionRoutes.enterpriseApplyWithBoardType(
            'company',
          ),
          bootstrapShellContext: buildEnterpriseShellContext(),
          deviceLocationService: const _EnterpriseWorkbenchTestLocationService(
            snapshot: DeviceLocationSnapshot(
              permissionState: DeviceLocationPermissionState.granted,
              latitude: 30.5728,
              longitude: 104.0668,
            ),
            reverseGeocodingSupported: true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      await openCompanyWorkbenchModule(tester, '地址与服务区域');
      await tester.scrollUntilVisible(
        find.byKey(
          const ValueKey<String>(
            'enterprise-workbench-address-fill-from-location',
          ),
        ),
        240,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(
        find.byKey(
          const ValueKey<String>(
            'enterprise-workbench-address-fill-from-location',
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(
          const ValueKey<String>(
            'enterprise-workbench-address-fill-from-location',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('缺少高德运行态配置'), findsOneWidget);
      expect(find.text('位置状态：已解析坐标'), findsNothing);
      final addressField = tester.widget<TextField>(
        find.byKey(
          const ValueKey<String>('enterprise-workbench-address-field'),
        ),
      );
      expect(addressField.controller?.text, isEmpty);
    },
  );

  testWidgets('enterprise status route remains reachable', (
    WidgetTester tester,
  ) async {
    EnterpriseHubConsumerLayer.install(
      EnterpriseHubConsumerLayer(
        client: AppApiClient(
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET ${boardApplicationStatusPath(EnterpriseBoardType.company, 'app-1')}':
                      (AppApiRequest request) async {
                        return AppApiResponse(
                          statusCode: 200,
                          uri: request.uri,
                          body: const <String, Object?>{
                            'applicationId': 'app-1',
                            'enterpriseId': 'ent-company-1',
                            'applyBoardType': 'company',
                            'applicationStatus': 'submitted',
                          },
                        );
                      },
                },
          ),
        ),
      ),
    );

    await tester.pumpWidget(
      ExhibitionMobileApp(
        initialRoute: ExhibitionRoutes.enterpriseApplicationStatusWithId(
          'app-1',
          boardType: 'company',
        ),
        bootstrapShellContext: buildEnterpriseShellContext(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('状态：当前已提交，等待审核。'), findsOneWidget);
  });

  testWidgets(
    'enterprise status route renders real approved content in authenticated context',
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
                    'GET ${boardApplicationStatusPath(EnterpriseBoardType.factory, 'c1e83c6f-4637-407f-8d41-5c1413821874')}':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: const <String, Object?>{
                              'applicationId':
                                  'c1e83c6f-4637-407f-8d41-5c1413821874',
                              'enterpriseId':
                                  'bf5ff83a-26e7-4138-8157-042fb38a5f46',
                              'applyBoardType': 'factory',
                              'applicationStatus': 'approved',
                              'submittedAt': '2026-04-08T10:00:00Z',
                              'reviewedAt': '2026-04-09T12:00:00Z',
                            },
                          );
                        },
                  },
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        ExhibitionMobileApp(
          initialRoute: ExhibitionRoutes.enterpriseApplicationStatusWithId(
            'c1e83c6f-4637-407f-8d41-5c1413821874',
            boardType: 'factory',
          ),
          bootstrapShellContext: buildEnterpriseShellContext(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('当前展示：已接通内容。'), findsOneWidget);
      expect(find.textContaining('申请已读取到真实状态结果。'), findsOneWidget);
      expect(find.textContaining('状态：当前申请已通过审核。'), findsOneWidget);
      expect(find.textContaining('当前账号暂不允许'), findsNothing);
    },
  );

  testWidgets(
    'enterprise status route keeps 401 as blocker instead of success handoff',
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
                    'GET ${boardApplicationStatusPath(EnterpriseBoardType.company, 'app-401')}':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 401,
                            uri: request.uri,
                            body: const <String, Object?>{
                              'code': 'AUTH_SESSION_INVALID',
                              'message': 'session invalid',
                            },
                          );
                        },
                  },
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        ExhibitionMobileApp(
          initialRoute: ExhibitionRoutes.enterpriseApplicationStatusWithId(
            'app-401',
            boardType: 'company',
          ),
          bootstrapShellContext: buildEnterpriseShellContext(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('当前展示：受控状态。'), findsOneWidget);
      expect(find.text('登录状态已失效，请重新登录后再继续企业展示申请。'), findsOneWidget);
      expect(find.textContaining('申请已读取到真实状态结果。'), findsNothing);
    },
  );

  testWidgets('enterprise status route renders controlled 404 state', (
    WidgetTester tester,
  ) async {
    EnterpriseHubConsumerLayer.install(
      EnterpriseHubConsumerLayer(
        client: AppApiClient(
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET ${boardApplicationStatusPath(EnterpriseBoardType.company, 'app-404')}':
                      (AppApiRequest request) async {
                        return AppApiResponse(
                          statusCode: 404,
                          uri: request.uri,
                          body: const <String, Object?>{
                            'code': 'ENTERPRISE_HUB_APPLICATION_NOT_FOUND',
                            'message': '当前申请单不存在或不在 actor scope 内。',
                          },
                        );
                      },
                },
          ),
        ),
      ),
    );

    await tester.pumpWidget(
      ExhibitionMobileApp(
        initialRoute: ExhibitionRoutes.enterpriseApplicationStatusWithId(
          'app-404',
          boardType: 'company',
        ),
        bootstrapShellContext: buildEnterpriseShellContext(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('当前申请单不存在或已不可访问。'), findsOneWidget);
  });

  testWidgets('enterprise status route renders controlled 403 state', (
    WidgetTester tester,
  ) async {
    EnterpriseHubConsumerLayer.install(
      EnterpriseHubConsumerLayer(
        client: AppApiClient(
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET ${boardApplicationStatusPath(EnterpriseBoardType.company, 'app-403')}':
                      (AppApiRequest request) async {
                        return AppApiResponse(
                          statusCode: 403,
                          uri: request.uri,
                          body: const <String, Object?>{
                            'code': 'ENTERPRISE_HUB_PERMISSION_DENIED',
                            'message': 'permission denied',
                          },
                        );
                      },
                },
          ),
        ),
      ),
    );

    await tester.pumpWidget(
      ExhibitionMobileApp(
        initialRoute: ExhibitionRoutes.enterpriseApplicationStatusWithId(
          'app-403',
          boardType: 'company',
        ),
        bootstrapShellContext: buildEnterpriseShellContext(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('当前账号暂不允许执行企业展示申请操作。'), findsOneWidget);
  });

  testWidgets(
    'enterprise status route keeps missing required fields on submit confirm semantics',
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
                    'GET /api/app/exhibition/enterprise-hub/applications/app-1':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 400,
                            uri: request.uri,
                            body: const <String, Object?>{
                              'code': 'ENTERPRISE_HUB_MISSING_REQUIRED_FIELDS',
                              'message': 'confirm is required',
                            },
                          );
                        },
                  },
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        ExhibitionMobileApp(
          initialRoute: ExhibitionRoutes.enterpriseApplicationStatusWithId(
            'app-1',
          ),
          bootstrapShellContext: buildEnterpriseShellContext(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('当前提交确认未完成，请返回工作台确认提交入驻申请后再继续。'), findsOneWidget);
      expect(find.textContaining('资料缺少'), findsNothing);
      expect(find.textContaining('资料未完成'), findsNothing);
    },
  );
}

class _EnterpriseWorkbenchTestLocationService implements DeviceLocationService {
  const _EnterpriseWorkbenchTestLocationService({
    required this.snapshot,
    this.reverseGeocodingSupported = false,
  });

  final DeviceLocationSnapshot snapshot;
  final bool reverseGeocodingSupported;

  @override
  bool get supportsDeviceLocation => true;

  @override
  bool get supportsReverseGeocoding => reverseGeocodingSupported;

  @override
  Future<DeviceLocationPermissionSnapshot> readPermissionStatus() async {
    return DeviceLocationPermissionSnapshot(
      permissionState: snapshot.permissionState,
      serviceEnabled: true,
      message: snapshot.errorMessage,
    );
  }

  @override
  Future<bool> openAppPermissionSettings() async => true;

  @override
  Future<bool> openSystemLocationSettings() async => true;

  @override
  Future<DeviceLocationSnapshot> resolveCurrentPosition() async => snapshot;
}

class _EnterpriseHubHomeAggregationClient
    implements ExhibitionHomeAggregationClient {
  const _EnterpriseHubHomeAggregationClient({required this.result});

  final ExhibitionLoadResult result;

  @override
  Future<ExhibitionLoadResult> load({
    ExhibitionHomeLocationContextRequest? locationContext,
  }) async => result;

  @override
  Future<ExhibitionLoadResult> refresh({
    ExhibitionHomeLocationContextRequest? locationContext,
  }) async => result;

  @override
  Future<ExhibitionLoadResult> selectLocation({
    required ExhibitionHomeLocationSelectRequest selection,
  }) async => result;
}

ExhibitionLoadResult _enterpriseHubHomeResult() {
  return ExhibitionLoadResult(
    state: AppPageState.content,
    method: 'GET',
    path: '/api/app/exhibition/home',
    payload: const <String, Object?>{
      'currentLocation': <String, Object?>{
        'displayName': '成都市高新区',
        'provinceName': '四川',
        'latitude': 30.5728,
        'longitude': 104.0668,
        'source': 'device_location',
        'persisted': false,
      },
      'selectionScope': 'request_only',
      'selectionNotice': '当前定位仅用于本次首页聚合',
      'sourceLabel': '首页聚合返回',
      'currentWeather': '多云',
      'currentTemperature': 21,
      'highTemperature': 25,
      'lowTemperature': 17,
      'precipitationProbability': 20,
      'updatedAt': '2026-04-10T10:00:00Z',
      'canExpand': true,
      'refreshable': true,
      'hourlyForecast': <Object?>[],
      'dailyForecast': <Object?>[],
      'officialAlerts': <String>[],
      'constructionSuggestions': <String>[],
      'modules': <Object?>[
        <String, Object?>{
          'moduleKey': 'excellent_company',
          'title': '优秀公司',
          'summary': '当前展示：已接通内容，可继续进入真实公司列表。',
          'statusLabel': '已接通内容',
          'actionLabel': '查看公司',
          'enabled': true,
          'placeholder': false,
        },
        <String, Object?>{
          'moduleKey': 'excellent_factory',
          'title': '优秀工厂',
          'summary': '当前展示：已接通内容，可继续进入真实工厂列表。',
          'statusLabel': '已接通内容',
          'actionLabel': '查看工厂',
          'enabled': true,
          'placeholder': false,
        },
        <String, Object?>{
          'moduleKey': 'excellent_supplier',
          'title': '优秀供应商',
          'summary': '当前展示：已接通内容，可继续进入真实供应商列表。',
          'statusLabel': '已接通内容',
          'actionLabel': '查看供应商',
          'enabled': true,
          'placeholder': false,
        },
      ],
      'recommendationSections': <Object?>[],
    },
  );
}
