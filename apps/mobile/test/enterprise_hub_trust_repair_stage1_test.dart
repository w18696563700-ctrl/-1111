import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_preview_projection.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_published_change_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_workbench_consumer_layer.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_detail_relayout_sections.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_detail_relayout_support.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_case_detail_sheet.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_detail_surface_widgets.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_list_controls.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_shared.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_workbench_pages.dart';

void main() {
  testWidgets('enterprise card uses logo url when available', (
    WidgetTester tester,
  ) async {
    const item = EnterpriseHubListItem(
      enterpriseId: 'enterprise-company-1',
      boardType: EnterpriseBoardType.company,
      name: '重庆坤特公司样本',
      logoUrl: 'https://example.com/logo.png',
      provinceName: '重庆市',
      cityName: '重庆城区',
      primaryBoardLabel: '优秀公司',
      secondaryCapabilityLabels: <String>['优秀公司'],
      shortIntro: '展会服务',
      certificationLabel: '已认证',
      caseCount: 1,
      keywordTags: <String>[],
      boardHighlights: <String, Object?>{
        'company': <String, Object?>{
          'exhibitionTypes': <String>['特装展台'],
          'serviceItems': <String>['设计施工一体化'],
        },
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EnterpriseCard(item: item, onPressed: () {}),
        ),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('disabled city filter button does not trigger callback', (
    WidgetTester tester,
  ) async {
    var tapped = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EnterpriseActionFilterButton(
            label: '城市',
            enabled: false,
            onPressed: () => tapped += 1,
          ),
        ),
      ),
    );

    await tester.tap(find.text('城市'));
    await tester.pump();

    expect(tapped, 0);
  });

  test('enterprise location resolve visible message maps config failure', () {
    expect(
      enterpriseLocationResolveVisibleMessage(
        errorCode: 'ENTERPRISE_LOCATION_PROVIDER_CONFIG_MISSING',
      ),
      '当前企业位置解析缺少高德运行态配置，暂时无法解析文字地址。',
    );
  });

  test('visual gallery keeps upload order and de-duplicates album images', () {
    const gallery = EnterpriseHubVisualGallery(
      albumImageUrls: <String>[
        'https://example.com/album-0.png',
        'https://example.com/album-1.png',
        'https://example.com/album-1.png',
        'https://example.com/album-2.png',
      ],
      source: 'enterprise_album',
    );

    expect(gallery.galleryImageUrls, <String>[
      'https://example.com/album-0.png',
      'https://example.com/album-1.png',
      'https://example.com/album-2.png',
    ]);
  });

  testWidgets('company detail hero uses album carousel in upload order', (
    WidgetTester tester,
  ) async {
    const data = EnterpriseHubDetailData(
      header: EnterpriseHubHeader(
        enterpriseId: 'ent-1',
        name: '西南会展搭建有限公司',
        primaryBoardType: EnterpriseBoardType.company,
        secondaryCapabilities: <EnterpriseBoardType>[],
        shortIntro: '承接展陈搭建',
        provinceName: '四川',
        cityName: '成都',
        logoUrl: 'https://example.com/logo.png',
      ),
      visualGallery: EnterpriseHubVisualGallery(
        albumImageUrls: <String>[
          'https://example.com/album-1.png',
          'https://example.com/album-2.png',
        ],
        source: 'enterprise_album',
      ),
      basicInfo: EnterpriseHubBasicInfo(),
      location: EnterpriseHubLocationData(),
      boardProfile: <String, Object?>{},
      serviceAreas: <EnterpriseHubServiceArea>[],
      cases: <EnterpriseHubCaseCard>[],
      certifications: <EnterpriseHubCertificationCard>[],
      reviewSummary: EnterpriseHubReviewSummary(keywordTags: <String>[]),
      contacts: <EnterpriseHubContactCard>[],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: EnterpriseDetailOverviewCard(data: data),
          ),
        ),
      ),
    );

    expect(find.byType(PageView), findsOneWidget);
    final image = tester.widget<Image>(find.byType(Image).first);
    expect(
      (image.image as NetworkImage).url,
      'https://example.com/album-1.png',
    );
  });

  testWidgets('company detail hero next button advances to the next image', (
    WidgetTester tester,
  ) async {
    const data = EnterpriseHubDetailData(
      header: EnterpriseHubHeader(
        enterpriseId: 'ent-1',
        name: '西南会展搭建有限公司',
        primaryBoardType: EnterpriseBoardType.company,
        secondaryCapabilities: <EnterpriseBoardType>[],
        shortIntro: '承接展陈搭建',
        provinceName: '四川',
        cityName: '成都',
        logoUrl: 'https://example.com/logo.png',
      ),
      visualGallery: EnterpriseHubVisualGallery(
        albumImageUrls: <String>[
          'https://example.com/album-1.png',
          'https://example.com/album-2.png',
        ],
        source: 'enterprise_album',
      ),
      basicInfo: EnterpriseHubBasicInfo(),
      location: EnterpriseHubLocationData(),
      boardProfile: <String, Object?>{},
      serviceAreas: <EnterpriseHubServiceArea>[],
      cases: <EnterpriseHubCaseCard>[],
      certifications: <EnterpriseHubCertificationCard>[],
      reviewSummary: EnterpriseHubReviewSummary(keywordTags: <String>[]),
      contacts: <EnterpriseHubContactCard>[],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: EnterpriseDetailOverviewCard(data: data),
          ),
        ),
      ),
    );

    final pageScrollable = find.descendant(
      of: find.byType(PageView),
      matching: find.byType(Scrollable),
    );
    final scrollableState = tester.state<ScrollableState>(pageScrollable);

    expect(scrollableState.position.pixels, 0);

    await tester.tap(
      find.byKey(const ValueKey<String>('enterprise-detail-hero-next-button')),
    );
    await tester.pumpAndSettle();

    expect(scrollableState.position.pixels, greaterThan(0));
  });

  testWidgets(
    'company detail hero allows horizontal swipe through the lower overlay area',
    (WidgetTester tester) async {
      const data = EnterpriseHubDetailData(
        header: EnterpriseHubHeader(
          enterpriseId: 'ent-1',
          name: '西南会展搭建有限公司',
          primaryBoardType: EnterpriseBoardType.company,
          secondaryCapabilities: <EnterpriseBoardType>[],
          shortIntro: '承接展陈搭建',
          provinceName: '四川',
          cityName: '成都',
          logoUrl: 'https://example.com/logo.png',
        ),
        visualGallery: EnterpriseHubVisualGallery(
          albumImageUrls: <String>[
            'https://example.com/album-1.png',
            'https://example.com/album-2.png',
          ],
          source: 'enterprise_album',
        ),
        basicInfo: EnterpriseHubBasicInfo(),
        location: EnterpriseHubLocationData(),
        boardProfile: <String, Object?>{},
        serviceAreas: <EnterpriseHubServiceArea>[],
        cases: <EnterpriseHubCaseCard>[],
        certifications: <EnterpriseHubCertificationCard>[],
        reviewSummary: EnterpriseHubReviewSummary(keywordTags: <String>[]),
        contacts: <EnterpriseHubContactCard>[],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: EnterpriseDetailOverviewCard(data: data),
            ),
          ),
        ),
      );

      final pageScrollable = find.descendant(
        of: find.byType(PageView),
        matching: find.byType(Scrollable),
      );
      final scrollableState = tester.state<ScrollableState>(pageScrollable);
      final pageRect = tester.getRect(find.byType(PageView));
      final overlayDragStart = Offset(
        pageRect.left + 180,
        pageRect.bottom - 36,
      );

      expect(scrollableState.position.pixels, 0);

      await tester.flingFrom(overlayDragStart, const Offset(-420, 0), 1200);
      await tester.pumpAndSettle();

      expect(scrollableState.position.pixels, greaterThan(0));
    },
  );

  testWidgets(
    'detail gallery keeps empty state when album images are unavailable',
    (WidgetTester tester) async {
      const gallery = EnterpriseHubVisualGallery(
        albumImageUrls: <String>[],
        source: 'enterprise_album',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: EnterpriseDetailVisualGallerySection(
                visualGallery: gallery,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('当前还没有可展示的企业画册图片。'), findsNWidgets(2));
      expect(find.byType(PageView), findsNothing);
    },
  );

  test('company and factory detail hide standalone visual gallery section', () {
    const companyData = EnterpriseHubDetailData(
      header: EnterpriseHubHeader(
        enterpriseId: 'ent-company-gallery',
        name: '西南会展搭建有限公司',
        primaryBoardType: EnterpriseBoardType.company,
        secondaryCapabilities: <EnterpriseBoardType>[],
        shortIntro: '承接展陈搭建',
        provinceName: '四川',
        cityName: '成都',
      ),
      visualGallery: EnterpriseHubVisualGallery(
        albumImageUrls: <String>['https://example.com/company-album-1.png'],
        source: 'enterprise_album',
      ),
      basicInfo: EnterpriseHubBasicInfo(),
      location: EnterpriseHubLocationData(),
      boardProfile: <String, Object?>{},
      serviceAreas: <EnterpriseHubServiceArea>[],
      cases: <EnterpriseHubCaseCard>[
        EnterpriseHubCaseCard(
          id: 'case-company-1',
          title: '糖酒会主场案例',
          summary: '案例摘要',
          caseStatus: 'published',
          coverImageUrl: 'https://example.com/company-case-cover.png',
        ),
      ],
      certifications: <EnterpriseHubCertificationCard>[],
      reviewSummary: EnterpriseHubReviewSummary(keywordTags: <String>[]),
      contacts: <EnterpriseHubContactCard>[],
    );
    const factoryData = EnterpriseHubDetailData(
      header: EnterpriseHubHeader(
        enterpriseId: 'ent-factory-gallery',
        name: '重庆坤特展览展示有限公司',
        primaryBoardType: EnterpriseBoardType.factory,
        secondaryCapabilities: <EnterpriseBoardType>[],
        shortIntro: '主打展台木作与结构制作',
        provinceName: '重庆市',
        cityName: '重庆市',
      ),
      visualGallery: EnterpriseHubVisualGallery(
        albumImageUrls: <String>['https://example.com/factory-album-1.png'],
        source: 'enterprise_album',
      ),
      basicInfo: EnterpriseHubBasicInfo(),
      location: EnterpriseHubLocationData(),
      boardProfile: <String, Object?>{
        'showcaseImageUrls': <String>['https://example.com/showcase-1.png'],
      },
      serviceAreas: <EnterpriseHubServiceArea>[],
      cases: <EnterpriseHubCaseCard>[
        EnterpriseHubCaseCard(
          id: 'case-factory-1',
          title: '工厂案例',
          summary: '案例摘要',
          caseStatus: 'published',
          coverImageUrl: 'https://example.com/factory-case-cover.png',
        ),
      ],
      certifications: <EnterpriseHubCertificationCard>[],
      reviewSummary: EnterpriseHubReviewSummary(keywordTags: <String>[]),
      contacts: <EnterpriseHubContactCard>[],
    );

    expect(
      enterpriseDetailShouldShowVisualGallerySection(companyData),
      isFalse,
    );
    expect(
      enterpriseDetailShouldShowVisualGallerySection(factoryData),
      isFalse,
    );
  });

  test(
    'published change preview projection reuses detail truth without leaking internal fields',
    () {
      const data = EnterpriseHubPublishedChangeWorkbenchData(
        enterpriseId: 'ent-published-1',
        boardType: EnterpriseBoardType.company,
        liveSnapshot: EnterpriseHubPublishedLiveSnapshot(
          enterpriseStatus: 'published',
          displayStatus: 'visible',
          publishedAt: '2026-04-01T08:00:00Z',
        ),
        currentChangeRequest: EnterpriseHubCurrentChangeRequestSnapshot(
          changeRequestId: 'chg-1',
          changeStatus: 'draft',
        ),
        basic: EnterpriseHubWorkbenchBasic(
          name: '西南会展搭建有限公司',
          shortIntro: '承接展陈搭建',
          fullIntro: '完整介绍',
          provinceName: '四川',
          cityName: '成都',
          address: '四川省成都市高新区天府大道 1 号',
          foundedAt: '2019-09-09',
          contactVisible: true,
        ),
        boardProfile: <String, Object?>{
          'exhibitionTypes': <String>['特装展台'],
          'serviceItems': <String>['设计搭建'],
          'serviceCities': <String>['成都'],
          'showcaseImageUrlMap': <String, String>{
            'showcase-1': 'https://example.com/showcase-1.png',
          },
        },
        primaryContact: EnterpriseHubWorkbenchContact(
          contactName: '王伟伟',
          mobile: '13800000000',
          isPrimary: true,
          visibleToPublic: true,
        ),
        cases: <EnterpriseHubWorkbenchCaseItem>[
          EnterpriseHubWorkbenchCaseItem(
            caseId: 'case-1',
            boardType: EnterpriseBoardType.company,
            title: '糖酒会主场案例',
            city: '成都',
            eventTime: '2026-03',
            summary: '案例摘要',
            caseCoverFileAssetId: 'file-case-cover-1',
            caseMediaFileAssetIds: <String>[],
            caseImageUrlMap: <String, String>{
              'file-case-cover-1': 'https://example.com/case-cover-1.png',
            },
            isFeatured: true,
            caseStatus: 'approved',
          ),
        ],
        changeReadiness: EnterpriseHubPublishedChangeReadiness(
          draftEditable: true,
          submitReady: false,
          blockers: <String>['请先补案例'],
        ),
      );
      const certification = EnterpriseHubWorkbenchCertification(
        certificationStatus: 'approved',
        legalName: '西南会展搭建有限公司',
      );

      final preview = enterpriseHubBuildPublishedChangePreviewDetailData(
        data: data,
        certification: certification,
      );

      expect(preview, isNotNull);
      expect(preview!.header.name, '西南会展搭建有限公司');
      expect(preview.header.verificationStatus, 'approved');
      expect(preview.visualGallery.galleryImageUrls, isEmpty);
      expect(
        preview.visualGallery.imageUrls,
        <String>['https://example.com/showcase-1.png'],
      );
      expect(preview.contacts.single.contactName, '王伟伟');
      expect(preview.cases.single.title, '糖酒会主场案例');
      expect(
        preview.cases.single.coverImageUrl,
        'https://example.com/case-cover-1.png',
      );
      expect(
        preview.cases.single.caseImageUrlMap,
        <String, String>{
          'file-case-cover-1': 'https://example.com/case-cover-1.png',
        },
      );
    },
  );

  testWidgets(
    'case detail sheet prefers inline preview seed over public live fetch',
    (WidgetTester tester) async {
      AppApiRequest? seenPublicCaseRequest;
      EnterpriseHubConsumerLayer.install(
        EnterpriseHubConsumerLayer(
          client: AppApiClient(
            transport: FakeAppApiTransport(
              handlers: <String, Future<AppApiResponse> Function(AppApiRequest)>{
                'GET /api/app/exhibition/enterprise-hub/public-cases/case-inline-1':
                    (AppApiRequest request) async {
                      seenPublicCaseRequest = request;
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'caseId': 'case-inline-1',
                          'enterpriseId': 'ent-inline-1',
                          'boardType': 'factory',
                          'title': 'public live case',
                          'exhibitionType': '公开案例',
                          'city': '成都',
                          'eventTime': '2026-01-01',
                          'summary': '公开案例摘要',
                          'caseCoverFileAssetId': 'file-public-cover',
                          'caseMediaFileAssetIds': <String>[
                            'file-public-cover',
                          ],
                          'caseImageUrlMap': <String, String>{
                            'file-public-cover':
                                'https://example.com/public-cover.png',
                          },
                          'isFeatured': false,
                          'caseStatus': 'approved',
                        },
                      );
                    },
              },
            ),
          ),
        ),
      );
      const item = EnterpriseHubCaseCard(
        id: 'case-inline-1',
        title: '当前变更案例',
        summary: '当前变更稿摘要',
        caseStatus: 'approved',
        coverImageUrl: 'https://example.com/preview-cover.png',
        eventTime: '2026-04-19',
        enterpriseId: 'ent-inline-1',
        boardType: EnterpriseBoardType.factory,
        exhibitionType: '工厂案例',
        city: '重庆',
        caseCoverFileAssetId: 'file-inline-cover',
        caseMediaFileAssetIds: <String>['file-inline-cover', 'file-inline-2'],
        caseImageUrlMap: <String, String>{
          'file-inline-cover': 'https://example.com/preview-cover.png',
          'file-inline-2': 'https://example.com/preview-2.png',
        },
        isFeatured: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return FilledButton(
                  onPressed: () => showEnterpriseCaseDetailSheet(
                    context,
                    item: item,
                  ),
                  child: const Text('open'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(
          const ValueKey<String>('enterprise-detail-case-detail-sheet'),
        ),
        findsOneWidget,
      );
      expect(seenPublicCaseRequest, isNull);
      expect(find.text('当前变更案例'), findsWidgets);
      expect(find.text('工厂案例'), findsOneWidget);
      expect(find.text('重庆'), findsOneWidget);
      final galleryFinder = find.byKey(
        const ValueKey<String>('enterprise-detail-case-detail-gallery'),
      );
      await tester.scrollUntilVisible(
        galleryFinder,
        180,
        scrollable: find
            .descendant(
              of: find.byKey(
                const ValueKey<String>('enterprise-detail-case-detail-sheet'),
              ),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(
        galleryFinder,
        findsOneWidget,
      );
      expect(find.text('public live case'), findsNothing);
    },
  );

  test('ensure shell posts shell route with board type only', () async {
    AppApiRequest? seenRequest;
    final layer = EnterpriseHubConsumerLayer(
      client: AppApiClient(
        transport: FakeAppApiTransport(
          handlers: <String, Future<AppApiResponse> Function(AppApiRequest)>{
            'POST /api/app/exhibition/enterprise-hub/enterprises/ensure-shell':
                (AppApiRequest request) async {
                  seenRequest = request;
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
          },
        ),
      ),
    );

    final result = await layer.ensureShell(
      boardType: EnterpriseBoardType.company,
    );

    expect(result.isSuccess, isTrue);
    expect(
      seenRequest?.canonicalPath,
      '/api/app/exhibition/enterprise-hub/enterprises/ensure-shell',
    );
    expect(seenRequest?.body, <String, Object?>{'boardType': 'company'});
    expect(result.data?.enterpriseId, 'ent-shell-1');
    expect(result.data?.shellStatus, 'created');
  });

  test(
    'create application keeps applicant fields on applications route',
    () async {
      AppApiRequest? seenRequest;
      final layer = EnterpriseHubConsumerLayer(
        client: AppApiClient(
          transport: FakeAppApiTransport(
            handlers: <String, Future<AppApiResponse> Function(AppApiRequest)>{
              'POST /api/app/exhibition/enterprise-hub/applications':
                  (AppApiRequest request) async {
                    seenRequest = request;
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'applicationId': 'app-1',
                        'enterpriseId': 'ent-shell-1',
                        'applicationStatus': 'draft',
                      },
                    );
                  },
            },
          ),
        ),
      );

      final result = await layer.createApplication(
        boardType: EnterpriseBoardType.company,
        applicantName: '王伟伟',
        applicantMobile: '13800000000',
      );

      expect(result.isSuccess, isTrue);
      expect(
        seenRequest?.canonicalPath,
        '/api/app/exhibition/enterprise-hub/applications',
      );
      expect(seenRequest?.body, <String, Object?>{
        'applyBoardType': 'company',
        'applicantName': '王伟伟',
        'applicantMobile': '13800000000',
      });
      expect(result.data?.applicationId, 'app-1');
    },
  );
}
