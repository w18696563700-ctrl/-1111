import 'dart:io';

import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';

enum EnterpriseBoardType {
  company,
  factory,
  supplier;

  String get contractName => name;

  String get title => switch (this) {
    EnterpriseBoardType.company => '优秀公司',
    EnterpriseBoardType.factory => '优秀工厂',
    EnterpriseBoardType.supplier => '优秀供应商',
  };

  String get listTitle => switch (this) {
    EnterpriseBoardType.company => '公司列表',
    EnterpriseBoardType.factory => '工厂列表',
    EnterpriseBoardType.supplier => '供应商列表',
  };

  String get detailTitle => switch (this) {
    EnterpriseBoardType.company => '公司详情',
    EnterpriseBoardType.factory => '工厂详情',
    EnterpriseBoardType.supplier => '供应商详情',
  };

  String get applyTitle => switch (this) {
    EnterpriseBoardType.company => '公司入驻',
    EnterpriseBoardType.factory => '工厂入驻',
    EnterpriseBoardType.supplier => '供应商入驻',
  };

  String get displayLabel => switch (this) {
    EnterpriseBoardType.company => '公司展示',
    EnterpriseBoardType.factory => '工厂展示',
    EnterpriseBoardType.supplier => '供应商展示',
  };

  static EnterpriseBoardType? fromRaw(String? raw) {
    return switch (raw?.trim().toLowerCase()) {
      'company' => EnterpriseBoardType.company,
      'factory' => EnterpriseBoardType.factory,
      'supplier' => EnterpriseBoardType.supplier,
      _ => null,
    };
  }
}

class EnterpriseHubLoadResult<T> {
  const EnterpriseHubLoadResult({
    required this.state,
    required this.method,
    required this.path,
    this.data,
    this.payload,
    this.message,
    this.errorCode,
  });

  final AppPageState state;
  final String method;
  final String path;
  final T? data;
  final Object? payload;
  final String? message;
  final String? errorCode;
}

class EnterpriseHubActionResult<T> {
  const EnterpriseHubActionResult({
    required this.isSuccess,
    required this.method,
    required this.path,
    this.data,
    this.payload,
    this.controlledState,
    this.message,
    this.errorCode,
  });

  final bool isSuccess;
  final String method;
  final String path;
  final T? data;
  final Object? payload;
  final AppPageState? controlledState;
  final String? message;
  final String? errorCode;
}

class EnterpriseHubListQuery {
  const EnterpriseHubListQuery({
    required this.boardType,
    this.keyword,
    this.provinceCode,
    this.cityCode,
    this.supplyCategory,
    this.plantAreaRange,
    this.page = 1,
    this.pageSize = 10,
  });

  final EnterpriseBoardType boardType;
  final String? keyword;
  final String? provinceCode;
  final String? cityCode;
  final String? supplyCategory;
  final String? plantAreaRange;
  final int page;
  final int pageSize;

  Map<String, String> toQueryParameters() {
    final normalizedPlantAreaRange = boardType == EnterpriseBoardType.factory
        ? _normalized(plantAreaRange)
        : null;
    final normalizedSupplyCategory = boardType == EnterpriseBoardType.supplier
        ? _normalized(supplyCategory)
        : null;
    return <String, String>{
      'boardType': boardType.contractName,
      if (_normalized(keyword) case final String value) 'keyword': value,
      if (_normalized(provinceCode) case final String value)
        'provinceCode': value,
      if (_normalized(cityCode) case final String value) 'cityCode': value,
      if (normalizedSupplyCategory case final String value)
        'supplyCategory': value,
      if (normalizedPlantAreaRange case final String value)
        'plantAreaRange': value,
      'page': '$page',
      'pageSize': '$pageSize',
    };
  }

  Map<String, String> toBoardScopedQueryParameters() {
    final normalizedPlantAreaRange = boardType == EnterpriseBoardType.factory
        ? _normalized(plantAreaRange)
        : null;
    final normalizedSupplyCategory = boardType == EnterpriseBoardType.supplier
        ? _normalized(supplyCategory)
        : null;
    return <String, String>{
      if (_normalized(keyword) case final String value) 'keyword': value,
      if (_normalized(provinceCode) case final String value)
        'provinceCode': value,
      if (_normalized(cityCode) case final String value) 'cityCode': value,
      if (normalizedSupplyCategory case final String value)
        'supplyCategory': value,
      if (normalizedPlantAreaRange case final String value)
        'plantAreaRange': value,
      'page': '$page',
      'pageSize': '$pageSize',
    };
  }

  EnterpriseHubListQuery copyWith({
    String? keyword,
    String? provinceCode,
    String? cityCode,
    String? supplyCategory,
    String? plantAreaRange,
    int? page,
    int? pageSize,
    bool clearKeyword = false,
    bool clearCity = false,
    bool clearSupplyCategory = false,
    bool clearPlantAreaRange = false,
  }) {
    return EnterpriseHubListQuery(
      boardType: boardType,
      keyword: clearKeyword ? null : keyword ?? this.keyword,
      provinceCode: clearCity ? null : provinceCode ?? this.provinceCode,
      cityCode: clearCity ? null : cityCode ?? this.cityCode,
      supplyCategory: clearSupplyCategory
          ? null
          : supplyCategory ?? this.supplyCategory,
      plantAreaRange: clearPlantAreaRange
          ? null
          : plantAreaRange ?? this.plantAreaRange,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}

class EnterpriseHubListData {
  const EnterpriseHubListData({
    required this.recommended,
    required this.items,
    required this.pagination,
  });

  final List<EnterpriseHubListItem> recommended;
  final List<EnterpriseHubListItem> items;
  final EnterpriseHubPagination pagination;
}

class EnterpriseHubRecommendationData {
  const EnterpriseHubRecommendationData({
    required this.boardType,
    required this.items,
  });

  final EnterpriseBoardType boardType;
  final List<EnterpriseHubListItem> items;
}

class EnterpriseHubPagination {
  const EnterpriseHubPagination({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.hasMore,
  });

  final int page;
  final int pageSize;
  final int total;
  final bool hasMore;
}

class EnterpriseHubListItem {
  const EnterpriseHubListItem({
    required this.enterpriseId,
    required this.boardType,
    required this.name,
    required this.provinceName,
    required this.cityName,
    required this.primaryBoardLabel,
    required this.secondaryCapabilityLabels,
    required this.shortIntro,
    required this.certificationLabel,
    required this.caseCount,
    required this.boardHighlights,
    this.logoUrl,
    this.provinceCode,
    this.cityCode,
    this.avgScore,
    this.keywordTags = const <String>[],
  });

  final String enterpriseId;
  final EnterpriseBoardType boardType;
  final String name;
  final String? logoUrl;
  final String? provinceCode;
  final String provinceName;
  final String? cityCode;
  final String cityName;
  final String primaryBoardLabel;
  final List<String> secondaryCapabilityLabels;
  final String shortIntro;
  final String certificationLabel;
  final int caseCount;
  final double? avgScore;
  final List<String> keywordTags;
  final Map<String, Object?> boardHighlights;
}

class EnterpriseHubDetailData {
  const EnterpriseHubDetailData({
    required this.header,
    required this.visualGallery,
    required this.basicInfo,
    required this.location,
    required this.boardProfile,
    required this.serviceAreas,
    required this.cases,
    required this.certifications,
    required this.reviewSummary,
    required this.contacts,
  });

  final EnterpriseHubHeader header;
  final EnterpriseHubVisualGallery visualGallery;
  final EnterpriseHubBasicInfo basicInfo;
  final EnterpriseHubLocationData location;
  final Map<String, Object?> boardProfile;
  final List<EnterpriseHubServiceArea> serviceAreas;
  final List<EnterpriseHubCaseCard> cases;
  final List<EnterpriseHubCertificationCard> certifications;
  final EnterpriseHubReviewSummary reviewSummary;
  final List<EnterpriseHubContactCard> contacts;
}

class EnterpriseHubLocationData {
  const EnterpriseHubLocationData({
    this.addressText,
    this.publicDisplayAddress,
    this.provinceCode,
    this.provinceName,
    this.cityCode,
    this.cityName,
    this.districtCode,
    this.districtName,
    this.latitude,
    this.longitude,
    this.geoSource,
    this.geoStatus,
    this.lastGeocodedAt,
    this.mapProvider,
    this.mapPreviewUrl,
    this.mapLinkUrl,
  });

  final String? addressText;
  final String? publicDisplayAddress;
  final String? provinceCode;
  final String? provinceName;
  final String? cityCode;
  final String? cityName;
  final String? districtCode;
  final String? districtName;
  final double? latitude;
  final double? longitude;
  final String? geoSource;
  final String? geoStatus;
  final String? lastGeocodedAt;
  final String? mapProvider;
  final String? mapPreviewUrl;
  final String? mapLinkUrl;

  bool get hasCoordinates => latitude != null && longitude != null;

  bool get isResolved => geoStatus == 'resolved' && hasCoordinates;

  bool get hasMapPreview => _normalized(mapPreviewUrl) != null && isResolved;

  String? get displayAddress {
    return _normalized(publicDisplayAddress) ?? _normalized(addressText);
  }

  String? get coordinatesLabel {
    if (!hasCoordinates) {
      return null;
    }
    return '${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}';
  }

  EnterpriseHubLocationData copyWith({
    String? addressText,
    String? publicDisplayAddress,
    String? provinceCode,
    String? provinceName,
    String? cityCode,
    String? cityName,
    String? districtCode,
    String? districtName,
    double? latitude,
    double? longitude,
    bool clearCoordinates = false,
    String? geoSource,
    String? geoStatus,
    String? lastGeocodedAt,
    String? mapProvider,
    String? mapPreviewUrl,
    String? mapLinkUrl,
  }) {
    return EnterpriseHubLocationData(
      addressText: addressText ?? this.addressText,
      publicDisplayAddress: publicDisplayAddress ?? this.publicDisplayAddress,
      provinceCode: provinceCode ?? this.provinceCode,
      provinceName: provinceName ?? this.provinceName,
      cityCode: cityCode ?? this.cityCode,
      cityName: cityName ?? this.cityName,
      districtCode: districtCode ?? this.districtCode,
      districtName: districtName ?? this.districtName,
      latitude: clearCoordinates ? null : latitude ?? this.latitude,
      longitude: clearCoordinates ? null : longitude ?? this.longitude,
      geoSource: geoSource ?? this.geoSource,
      geoStatus: geoStatus ?? this.geoStatus,
      lastGeocodedAt: lastGeocodedAt ?? this.lastGeocodedAt,
      mapProvider: mapProvider ?? this.mapProvider,
      mapPreviewUrl: mapPreviewUrl ?? this.mapPreviewUrl,
      mapLinkUrl: mapLinkUrl ?? this.mapLinkUrl,
    );
  }
}

class EnterpriseHubHeader {
  const EnterpriseHubHeader({
    required this.enterpriseId,
    required this.name,
    required this.primaryBoardType,
    required this.secondaryCapabilities,
    required this.shortIntro,
    required this.provinceName,
    required this.cityName,
    this.logoUrl,
    this.verificationStatus,
  });

  final String enterpriseId;
  final String name;
  final EnterpriseBoardType primaryBoardType;
  final List<EnterpriseBoardType> secondaryCapabilities;
  final String shortIntro;
  final String provinceName;
  final String cityName;
  final String? logoUrl;
  final String? verificationStatus;
}

class EnterpriseHubVisualGallery {
  const EnterpriseHubVisualGallery({
    this.showcaseImageUrls = const <String>[],
    required this.albumImageUrls,
    required this.source,
  });

  final List<String> showcaseImageUrls;
  final List<String> albumImageUrls;
  final String source;

  List<String> get imageUrls {
    final prioritized = showcaseImageUrls.isNotEmpty
        ? showcaseImageUrls
        : albumImageUrls;
    return List<String>.unmodifiable(_dedupeImageUrls(prioritized));
  }

  List<String> get galleryImageUrls {
    return List<String>.unmodifiable(_dedupeImageUrls(albumImageUrls));
  }
}

class EnterpriseHubBasicInfo {
  const EnterpriseHubBasicInfo({
    this.legalName,
    this.foundedAt,
    this.teamSizeRange,
    this.fullIntro,
    this.address,
  });

  final String? legalName;
  final String? foundedAt;
  final String? teamSizeRange;
  final String? fullIntro;
  final String? address;
}

class EnterpriseHubServiceArea {
  const EnterpriseHubServiceArea({
    required this.provinceName,
    this.areaType,
    this.cityName,
  });

  final String provinceName;
  final String? areaType;
  final String? cityName;
}

class EnterpriseHubCaseCard {
  const EnterpriseHubCaseCard({
    required this.id,
    required this.title,
    required this.summary,
    required this.caseStatus,
    this.coverImageUrl,
    this.eventTime,
    this.enterpriseId,
    this.boardType,
    this.exhibitionType,
    this.city,
    this.caseCoverFileAssetId,
    this.caseMediaFileAssetIds = const <String>[],
    this.caseImageUrlMap = const <String, String>{},
    this.isFeatured = false,
  });

  final String id;
  final String title;
  final String summary;
  final String caseStatus;
  final String? coverImageUrl;
  final String? eventTime;
  final String? enterpriseId;
  final EnterpriseBoardType? boardType;
  final String? exhibitionType;
  final String? city;
  final String? caseCoverFileAssetId;
  final List<String> caseMediaFileAssetIds;
  final Map<String, String> caseImageUrlMap;
  final bool isFeatured;
}

class EnterpriseHubCertificationCard {
  const EnterpriseHubCertificationCard({
    required this.type,
    required this.name,
    required this.status,
  });

  final String type;
  final String name;
  final String status;
}

class EnterpriseHubReviewSummary {
  const EnterpriseHubReviewSummary({
    required this.keywordTags,
    this.avgScore,
    this.reviewCount,
    this.deliveryScore,
    this.qualityScore,
    this.communicationScore,
  });

  final List<String> keywordTags;
  final double? avgScore;
  final int? reviewCount;
  final double? deliveryScore;
  final double? qualityScore;
  final double? communicationScore;
}

class EnterpriseHubContactCard {
  const EnterpriseHubContactCard({
    required this.contactName,
    this.mobile,
    this.wechat,
    this.phone,
    this.email,
    this.position,
  });

  final String contactName;
  final String? mobile;
  final String? wechat;
  final String? phone;
  final String? email;
  final String? position;
}

class EnterpriseHubTargetEnterpriseFormalInfoData {
  const EnterpriseHubTargetEnterpriseFormalInfoData({
    required this.enterpriseId,
    required this.legalName,
    required this.uscc,
    required this.legalPerson,
    required this.businessType,
    required this.address,
    required this.registeredCapital,
    required this.establishedAt,
    required this.businessTerm,
    required this.businessScope,
    required this.certificationStatus,
  });

  final String enterpriseId;
  final String? legalName;
  final String? uscc;
  final String? legalPerson;
  final String? businessType;
  final String? address;
  final String? registeredCapital;
  final String? establishedAt;
  final String? businessTerm;
  final String? businessScope;
  final String? certificationStatus;
}

class EnterpriseHubApplicationDraft {
  const EnterpriseHubApplicationDraft({
    required this.applicationId,
    required this.enterpriseId,
    required this.applicationStatus,
  });

  final String applicationId;
  final String enterpriseId;
  final String applicationStatus;
}

class EnterpriseHubEnsureShellData {
  const EnterpriseHubEnsureShellData({
    required this.enterpriseId,
    required this.boardType,
    required this.shellStatus,
  });

  final String enterpriseId;
  final EnterpriseBoardType boardType;
  final String shellStatus;
}

class EnterpriseHubApplicationStatusData {
  const EnterpriseHubApplicationStatusData({
    required this.applicationId,
    required this.enterpriseId,
    required this.applyBoardType,
    required this.applicationStatus,
    this.rejectionReason,
    this.reviewNote,
    this.submittedAt,
    this.reviewedAt,
  });

  final String applicationId;
  final String enterpriseId;
  final EnterpriseBoardType applyBoardType;
  final String applicationStatus;
  final String? rejectionReason;
  final String? reviewNote;
  final String? submittedAt;
  final String? reviewedAt;
}

class EnterpriseHubCaseCreateData {
  const EnterpriseHubCaseCreateData({
    required this.caseId,
    required this.caseStatus,
  });

  final String caseId;
  final String caseStatus;
}

class EnterpriseHubCaseDetailData {
  const EnterpriseHubCaseDetailData({
    required this.caseId,
    required this.enterpriseId,
    required this.boardType,
    required this.title,
    this.exhibitionType,
    this.city,
    this.eventTime,
    required this.summary,
    this.caseCoverFileAssetId,
    required this.caseMediaFileAssetIds,
    this.caseImageUrlMap = const <String, String>{},
    required this.isFeatured,
    required this.caseStatus,
  });

  final String caseId;
  final String enterpriseId;
  final EnterpriseBoardType boardType;
  final String title;
  final String? exhibitionType;
  final String? city;
  final String? eventTime;
  final String summary;
  final String? caseCoverFileAssetId;
  final List<String> caseMediaFileAssetIds;
  final Map<String, String> caseImageUrlMap;
  final bool isFeatured;
  final String caseStatus;
}

class EnterpriseHubConsumerLayer {
  EnterpriseHubConsumerLayer({AppApiClient? client})
    : _client = client ?? AppApiClient();

  static EnterpriseHubConsumerLayer _instance = EnterpriseHubConsumerLayer();

  static EnterpriseHubConsumerLayer get instance => _instance;

  static void install(EnterpriseHubConsumerLayer consumerLayer) {
    _instance = consumerLayer;
  }

  static void reset() {
    _instance = EnterpriseHubConsumerLayer();
  }

  final AppApiClient _client;

  Future<EnterpriseHubLoadResult<EnterpriseHubListData>> loadEnterprises(
    EnterpriseHubListQuery query,
  ) {
    final family = EnterpriseHubBoardCanonicalFamily.forBoard(query.boardType);
    return _load(
      method: 'GET',
      canonicalPath: family.enterprises,
      request: () => _client.get(
        family.enterprises,
        queryParameters: query.toBoardScopedQueryParameters(),
      ),
      parser: _parseListData,
    );
  }

  Future<EnterpriseHubLoadResult<EnterpriseHubDetailData>>
  loadEnterpriseDetail({
    required String enterpriseId,
    required EnterpriseBoardType boardType,
  }) {
    final family = EnterpriseHubBoardCanonicalFamily.forBoard(boardType);
    final normalizedId = _normalized(enterpriseId);
    if (normalizedId == null) {
      return Future.value(
        EnterpriseHubLoadResult<EnterpriseHubDetailData>(
          state: AppPageState.errorNonRetryable,
          method: 'GET',
          path: family.enterprises,
          message: '缺少 enterpriseId，当前无法读取详情。',
        ),
      );
    }

    return _load(
      method: 'GET',
      canonicalPath: family.enterpriseDetail(normalizedId),
      request: () => _client.get(family.enterpriseDetail(normalizedId)),
      parser: _parseDetailData,
    );
  }

  Future<EnterpriseHubLoadResult<EnterpriseHubTargetEnterpriseFormalInfoData>>
  loadTargetEnterpriseFormalInfo({required String enterpriseId}) {
    final normalizedId = _normalized(enterpriseId);
    if (normalizedId == null) {
      return Future.value(
        EnterpriseHubLoadResult<EnterpriseHubTargetEnterpriseFormalInfoData>(
          state: AppPageState.errorNonRetryable,
          method: 'GET',
          path: _EnterpriseHubCanonicalPaths.targetEnterpriseFormalInfo(
            enterpriseId,
          ),
          message: '缺少 enterpriseId，当前无法读取企业正式信息。',
        ),
      );
    }

    return _load(
      method: 'GET',
      canonicalPath: _EnterpriseHubCanonicalPaths.targetEnterpriseFormalInfo(
        normalizedId,
      ),
      request: () => _client.get(
        _EnterpriseHubCanonicalPaths.targetEnterpriseFormalInfo(normalizedId),
      ),
      parser: _parseTargetEnterpriseFormalInfoData,
    );
  }

  Future<EnterpriseHubLoadResult<EnterpriseHubRecommendationData>>
  loadRecommendations(EnterpriseBoardType boardType) {
    final family = EnterpriseHubBoardCanonicalFamily.forBoard(boardType);
    return _load(
      method: 'GET',
      canonicalPath: family.recommendations,
      request: () => _client.get(family.recommendations),
      parser: _parseRecommendationData,
    );
  }

  Future<EnterpriseHubActionResult<EnterpriseHubApplicationDraft>>
  createApplication({
    required EnterpriseBoardType boardType,
    required String applicantName,
    required String applicantMobile,
  }) {
    final family = EnterpriseHubBoardCanonicalFamily.forBoard(boardType);
    return _submit(
      method: 'POST',
      canonicalPath: family.applications,
      request: () => _client.post(
        family.applications,
        body: <String, Object?>{
          'applicantName': applicantName.trim(),
          'applicantMobile': applicantMobile.trim(),
        },
      ),
      parser: _parseApplicationDraft,
    );
  }

  Future<EnterpriseHubActionResult<EnterpriseHubEnsureShellData>> ensureShell({
    required EnterpriseBoardType boardType,
  }) {
    final family = EnterpriseHubBoardCanonicalFamily.forBoard(boardType);
    return _submit(
      method: 'POST',
      canonicalPath: family.ensureShell,
      request: () =>
          _client.post(family.ensureShell, body: const <String, Object?>{}),
      parser: _parseEnsureShellData,
    );
  }

  Future<EnterpriseHubActionResult<bool>> updateBasic({
    required EnterpriseBoardType boardType,
    required String enterpriseId,
    required Map<String, Object?> body,
  }) {
    final family = EnterpriseHubBoardCanonicalFamily.forBoard(boardType);
    return _ackPut(family.updateBasic(enterpriseId), body: body);
  }

  Future<EnterpriseHubActionResult<bool>> updateCompanyProfile({
    required String enterpriseId,
    required Map<String, Object?> body,
  }) {
    final family = EnterpriseHubBoardCanonicalFamily.forBoard(
      EnterpriseBoardType.company,
    );
    return _ackPut(family.updateProfile(enterpriseId), body: body);
  }

  Future<EnterpriseHubActionResult<bool>> updateFactoryProfile({
    required String enterpriseId,
    required Map<String, Object?> body,
  }) {
    final family = EnterpriseHubBoardCanonicalFamily.forBoard(
      EnterpriseBoardType.factory,
    );
    return _ackPut(family.updateProfile(enterpriseId), body: body);
  }

  Future<EnterpriseHubActionResult<bool>> updateSupplierProfile({
    required String enterpriseId,
    required Map<String, Object?> body,
  }) {
    final family = EnterpriseHubBoardCanonicalFamily.forBoard(
      EnterpriseBoardType.supplier,
    );
    return _ackPut(family.updateProfile(enterpriseId), body: body);
  }

  Future<EnterpriseHubActionResult<EnterpriseHubCaseCreateData>> createCase({
    required EnterpriseBoardType boardType,
    required String enterpriseId,
    required Map<String, Object?> body,
  }) {
    final family = EnterpriseHubBoardCanonicalFamily.forBoard(boardType);
    return _submit(
      method: 'POST',
      canonicalPath: family.createCase(enterpriseId),
      request: () => _client.post(family.createCase(enterpriseId), body: body),
      parser: _parseCaseCreateData,
    );
  }

  Future<EnterpriseHubLoadResult<EnterpriseHubCaseDetailData>> getCaseDetail({
    required String caseId,
  }) {
    final normalizedId = _normalized(caseId);
    if (normalizedId == null) {
      return Future.value(
        EnterpriseHubLoadResult<EnterpriseHubCaseDetailData>(
          state: AppPageState.errorNonRetryable,
          method: 'GET',
          path: _EnterpriseHubCanonicalPaths.cases,
          message: '缺少 caseId，当前无法读取案例详情。',
        ),
      );
    }

    return _load(
      method: 'GET',
      canonicalPath: _EnterpriseHubCanonicalPaths.caseDetail(normalizedId),
      request: () =>
          _client.get(_EnterpriseHubCanonicalPaths.caseDetail(normalizedId)),
      parser: _parseCaseDetailData,
    );
  }

  Future<EnterpriseHubLoadResult<EnterpriseHubCaseDetailData>>
  getPublicCaseDetail({required String caseId}) {
    final normalizedId = _normalized(caseId);
    if (normalizedId == null) {
      return Future.value(
        EnterpriseHubLoadResult<EnterpriseHubCaseDetailData>(
          state: AppPageState.errorNonRetryable,
          method: 'GET',
          path: _EnterpriseHubCanonicalPaths.publicCases,
          message: '缺少 caseId，当前无法读取公开案例详情。',
        ),
      );
    }

    return _load(
      method: 'GET',
      canonicalPath: _EnterpriseHubCanonicalPaths.publicCaseDetail(
        normalizedId,
      ),
      request: () => _client.get(
        _EnterpriseHubCanonicalPaths.publicCaseDetail(normalizedId),
      ),
      parser: _parseCaseDetailData,
    );
  }

  Future<EnterpriseHubActionResult<bool>> updateCase({
    required String caseId,
    required Map<String, Object?> body,
  }) {
    final normalizedId = _normalized(caseId);
    if (normalizedId == null) {
      return Future.value(
        EnterpriseHubActionResult<bool>(
          isSuccess: false,
          method: 'PUT',
          path: _EnterpriseHubCanonicalPaths.cases,
          controlledState: AppPageState.errorNonRetryable,
          message: '缺少 caseId，当前无法保存案例修改。',
        ),
      );
    }

    return _ackPut(
      _EnterpriseHubCanonicalPaths.caseDetail(normalizedId),
      body: body,
    );
  }

  Future<EnterpriseHubActionResult<bool>> submitApplication({
    EnterpriseBoardType? boardType,
    required String applicationId,
  }) {
    final canonicalPath = boardType == null
        ? _EnterpriseHubCanonicalPaths.submitApplication(applicationId)
        : EnterpriseHubBoardCanonicalFamily.forBoard(
            boardType,
          ).submitApplication(applicationId);
    return _submit(
      method: 'POST',
      canonicalPath: canonicalPath,
      request: () => _client.post(
        canonicalPath,
        body: const <String, Object?>{'confirm': true},
      ),
      parser: (_) => true,
    );
  }

  Future<EnterpriseHubActionResult<bool>> deleteCase({required String caseId}) {
    return _ackDelete(_EnterpriseHubCanonicalPaths.deleteCase(caseId));
  }

  Future<EnterpriseHubActionResult<bool>> deleteEnterprise({
    required EnterpriseBoardType boardType,
    required String enterpriseId,
  }) {
    final family = EnterpriseHubBoardCanonicalFamily.forBoard(boardType);
    return _ackDelete(family.deleteEnterprise(enterpriseId));
  }

  Future<EnterpriseHubLoadResult<EnterpriseHubApplicationStatusData>>
  loadApplicationStatus({
    required String applicationId,
    EnterpriseBoardType? boardType,
  }) {
    final canonicalPath = boardType == null
        ? _EnterpriseHubCanonicalPaths.applicationStatus(applicationId)
        : EnterpriseHubBoardCanonicalFamily.forBoard(
            boardType,
          ).applicationStatus(applicationId);
    return _load(
      method: 'GET',
      canonicalPath: canonicalPath,
      request: () => _client.get(canonicalPath),
      parser: _parseApplicationStatus,
    );
  }

  Future<EnterpriseHubActionResult<EnterpriseHubLocationData>> resolveLocation({
    required Map<String, Object?> body,
  }) {
    return _submit(
      method: 'POST',
      canonicalPath: _EnterpriseHubCanonicalPaths.resolveLocation,
      request: () => _client.post(
        _EnterpriseHubCanonicalPaths.resolveLocation,
        body: body,
      ),
      parser: _parseLocationData,
    );
  }

  Future<EnterpriseHubActionResult<bool>> _ackPut(
    String canonicalPath, {
    required Map<String, Object?> body,
  }) {
    return _submit(
      method: 'PUT',
      canonicalPath: canonicalPath,
      request: () => _client.put(canonicalPath, body: body),
      parser: (_) => true,
    );
  }

  Future<EnterpriseHubActionResult<bool>> _ackDelete(String canonicalPath) {
    return _submit(
      method: 'DELETE',
      canonicalPath: canonicalPath,
      request: () => _client.delete(canonicalPath),
      parser: (_) => true,
    );
  }

  Future<EnterpriseHubLoadResult<T>> _load<T>({
    required String method,
    required String canonicalPath,
    required Future<AppApiResponse> Function() request,
    required T Function(Map<String, Object?> payload) parser,
  }) async {
    try {
      final response = await request();
      final payload = _asMap(response.body);
      final failureState = _mapFailureState(response.statusCode);
      if (failureState != null) {
        return EnterpriseHubLoadResult<T>(
          state: failureState,
          method: method,
          path: canonicalPath,
          payload: payload ?? response.body,
          message: _messageFromPayload(payload),
          errorCode: _errorCodeFromPayload(payload),
        );
      }

      if (payload == null) {
        return EnterpriseHubLoadResult<T>(
          state: AppPageState.errorNonRetryable,
          method: method,
          path: canonicalPath,
          message: '响应体不是对象，当前无法完成合同映射。',
          payload: response.body,
        );
      }

      try {
        return EnterpriseHubLoadResult<T>(
          state: _isEffectivelyEmpty(payload)
              ? AppPageState.empty
              : AppPageState.content,
          method: method,
          path: canonicalPath,
          data: parser(payload),
          payload: payload,
        );
      } on FormatException catch (error) {
        return EnterpriseHubLoadResult<T>(
          state: AppPageState.errorNonRetryable,
          method: method,
          path: canonicalPath,
          message: error.message,
          payload: payload,
        );
      }
    } on SocketException {
      return EnterpriseHubLoadResult<T>(
        state: AppPageState.errorRetryable,
        method: method,
        path: canonicalPath,
        message: '网络未就绪，当前无法读取 enterprise-hub 接口。',
      );
    } on StateError {
      return EnterpriseHubLoadResult<T>(
        state: AppPageState.errorRetryable,
        method: method,
        path: canonicalPath,
        message: '当前 fake transport 尚未提供该 enterprise-hub canonical path。',
      );
    }
  }

  Future<EnterpriseHubActionResult<T>> _submit<T>({
    required String method,
    required String canonicalPath,
    required Future<AppApiResponse> Function() request,
    required T? Function(Map<String, Object?> payload) parser,
  }) async {
    try {
      final response = await request();
      final payload = _asMap(response.body);
      final failureState = _mapFailureState(response.statusCode);
      if (failureState != null) {
        return EnterpriseHubActionResult<T>(
          isSuccess: false,
          method: method,
          path: canonicalPath,
          controlledState: failureState,
          payload: payload ?? response.body,
          message: _messageFromPayload(payload),
          errorCode: _errorCodeFromPayload(payload),
        );
      }

      if (payload == null) {
        return EnterpriseHubActionResult<T>(
          isSuccess: true,
          method: method,
          path: canonicalPath,
          payload: response.body,
        );
      }

      try {
        return EnterpriseHubActionResult<T>(
          isSuccess: true,
          method: method,
          path: canonicalPath,
          data: parser(payload),
          payload: payload,
        );
      } on FormatException catch (error) {
        return EnterpriseHubActionResult<T>(
          isSuccess: false,
          method: method,
          path: canonicalPath,
          controlledState: AppPageState.errorNonRetryable,
          payload: payload,
          message: error.message,
        );
      }
    } on SocketException {
      return EnterpriseHubActionResult<T>(
        isSuccess: false,
        method: method,
        path: canonicalPath,
        controlledState: AppPageState.errorRetryable,
        message: '网络未就绪，当前无法提交 enterprise-hub 接口。',
      );
    } on StateError {
      return EnterpriseHubActionResult<T>(
        isSuccess: false,
        method: method,
        path: canonicalPath,
        controlledState: AppPageState.errorRetryable,
        message: '当前 fake transport 尚未提供该 enterprise-hub canonical path。',
      );
    }
  }
}

final class _EnterpriseHubCanonicalPaths {
  const _EnterpriseHubCanonicalPaths._();

  static const String cases = '/api/app/exhibition/enterprise-hub/cases';
  static const String publicCases =
      '/api/app/exhibition/enterprise-hub/public-cases';
  static const String resolveLocation =
      '/api/app/exhibition/enterprise-hub/location/resolve';

  static String caseDetail(String caseId) =>
      '/api/app/exhibition/enterprise-hub/cases/$caseId';

  static String publicCaseDetail(String caseId) =>
      '/api/app/exhibition/enterprise-hub/public-cases/$caseId';

  static String deleteCase(String caseId) =>
      '/api/app/exhibition/enterprise-hub/cases/$caseId';

  static String submitApplication(String applicationId) =>
      '/api/app/exhibition/enterprise-hub/applications/$applicationId/submit';

  static String applicationStatus(String applicationId) =>
      '/api/app/exhibition/enterprise-hub/applications/$applicationId';

  static String targetEnterpriseFormalInfo(String enterpriseId) =>
      '/api/app/exhibition/enterprise-hub/enterprises/$enterpriseId/formal-info';
}

final class EnterpriseHubBoardCanonicalFamily {
  const EnterpriseHubBoardCanonicalFamily._({
    required this.boardType,
    required this.basePath,
  });

  final EnterpriseBoardType boardType;
  final String basePath;

  static EnterpriseHubBoardCanonicalFamily forBoard(
    EnterpriseBoardType boardType,
  ) {
    return EnterpriseHubBoardCanonicalFamily._(
      boardType: boardType,
      basePath: '/api/app/exhibition/enterprise-hub/${boardType.contractName}',
    );
  }

  String get workbench => '$basePath/workbench';

  String get enterprises => '$basePath/enterprises';

  String get ensureShell => '$basePath/enterprises/ensure-shell';

  String get recommendations => '$basePath/recommendations';

  String get applications => '$basePath/applications';

  String enterpriseDetail(String enterpriseId) =>
      '$basePath/enterprises/$enterpriseId';

  String updateBasic(String enterpriseId) =>
      '$basePath/enterprises/$enterpriseId/basic';

  String updateProfile(String enterpriseId) =>
      '$basePath/enterprises/$enterpriseId/profiles/${boardType.contractName}';

  String createCase(String enterpriseId) =>
      '$basePath/enterprises/$enterpriseId/cases';

  String deleteEnterprise(String enterpriseId) =>
      '$basePath/enterprises/$enterpriseId';

  String submitApplication(String applicationId) =>
      '$basePath/applications/$applicationId/submit';

  String applicationStatus(String applicationId) =>
      '$basePath/applications/$applicationId';

  String publishedChangeWorkbench(String enterpriseId) =>
      '$basePath/enterprises/$enterpriseId/changes/current';

  String publishedChangeStatus(String enterpriseId) =>
      '$basePath/enterprises/$enterpriseId/changes/current/status';

  String publishedChangeBasic(String enterpriseId) =>
      '$basePath/enterprises/$enterpriseId/changes/current/basic';

  String publishedChangeProfile(String enterpriseId) =>
      '$basePath/enterprises/$enterpriseId/changes/current/profiles/${boardType.contractName}';

  String publishedChangeCreateCase(String enterpriseId) =>
      '$basePath/enterprises/$enterpriseId/changes/current/cases';

  String publishedChangeCaseDetail(String enterpriseId, String caseId) =>
      '$basePath/enterprises/$enterpriseId/changes/current/cases/$caseId';

  String publishedChangeSubmit(String enterpriseId) =>
      '$basePath/enterprises/$enterpriseId/changes/current/submit';
}

EnterpriseHubListData _parseListData(Map<String, Object?> payload) {
  return EnterpriseHubListData(
    recommended: _parseListItems(payload['recommended']),
    items: _parseListItems(payload['items']),
    pagination: _parsePagination(payload['pagination']),
  );
}

EnterpriseHubRecommendationData _parseRecommendationData(
  Map<String, Object?> payload,
) {
  final boardType = EnterpriseBoardType.fromRaw(
    _readString(payload['boardType']),
  );
  if (boardType == null) {
    throw const FormatException('recommendations 缺少合法 boardType。');
  }
  return EnterpriseHubRecommendationData(
    boardType: boardType,
    items: _parseListItems(payload['items']),
  );
}

EnterpriseHubDetailData _parseDetailData(Map<String, Object?> payload) {
  final boardProfile = _asMap(payload['boardProfile']) ?? <String, Object?>{};
  return EnterpriseHubDetailData(
    header: _parseHeader(payload['header']),
    visualGallery: _parseVisualGallery(payload, boardProfile),
    basicInfo: _parseBasicInfo(payload['basicInfo']),
    location: _parseLocationData(payload['location']),
    boardProfile: boardProfile,
    serviceAreas: _parseServiceAreas(payload['serviceAreas']),
    cases: _parseCases(payload['cases']),
    certifications: _parseCertifications(payload['certifications']),
    reviewSummary: _parseReviewSummary(payload['reviewSummary']),
    contacts: _parseContacts(payload['contacts']),
  );
}

EnterpriseHubLocationData _parseLocationData(Object? raw) {
  final rawPayload = _asMap(raw);
  final payload = _asMap(rawPayload?['location']) ?? rawPayload;
  if (payload == null) {
    return const EnterpriseHubLocationData(geoStatus: 'not_provided');
  }
  return EnterpriseHubLocationData(
    addressText: _readString(payload['addressText'], payload['address']),
    publicDisplayAddress: _readString(payload['publicDisplayAddress']),
    provinceCode: _readString(payload['provinceCode']),
    provinceName: _readString(payload['provinceName']),
    cityCode: _readString(payload['cityCode']),
    cityName: _readString(payload['cityName']),
    districtCode: _readString(payload['districtCode']),
    districtName: _readString(payload['districtName']),
    latitude: _readDouble(payload['latitude']),
    longitude: _readDouble(payload['longitude']),
    geoSource: _readString(payload['geoSource']),
    geoStatus: _readString(payload['geoStatus']) ?? 'not_provided',
    lastGeocodedAt: _readString(payload['lastGeocodedAt']),
    mapProvider: _readString(payload['mapProvider']),
    mapPreviewUrl: _readString(payload['mapPreviewUrl']),
    mapLinkUrl: _readString(payload['mapLinkUrl']),
  );
}

EnterpriseHubTargetEnterpriseFormalInfoData
_parseTargetEnterpriseFormalInfoData(Map<String, Object?> payload) {
  return EnterpriseHubTargetEnterpriseFormalInfoData(
    enterpriseId: _requiredString(payload, 'enterpriseId'),
    legalName: _readString(payload['legalName']),
    uscc: _readString(payload['uscc']),
    legalPerson: _readString(payload['legalPerson']),
    businessType: _readString(payload['businessType']),
    address: _readString(payload['address']),
    registeredCapital: _readString(payload['registeredCapital']),
    establishedAt: _readString(payload['establishedAt']),
    businessTerm: _readString(payload['businessTerm']),
    businessScope: _readString(payload['businessScope']),
    certificationStatus: _readString(payload['certificationStatus']),
  );
}

EnterpriseHubApplicationDraft _parseApplicationDraft(
  Map<String, Object?> payload,
) {
  return EnterpriseHubApplicationDraft(
    applicationId: _requiredString(payload, 'applicationId'),
    enterpriseId: _requiredString(payload, 'enterpriseId'),
    applicationStatus: _requiredString(payload, 'applicationStatus'),
  );
}

EnterpriseHubEnsureShellData _parseEnsureShellData(
  Map<String, Object?> payload,
) {
  final boardType = EnterpriseBoardType.fromRaw(
    _requiredString(payload, 'boardType'),
  );
  if (boardType == null) {
    throw const FormatException('enterprise ensure-shell 缺少合法 boardType。');
  }
  return EnterpriseHubEnsureShellData(
    enterpriseId: _requiredString(payload, 'enterpriseId'),
    boardType: boardType,
    shellStatus: _requiredString(payload, 'shellStatus'),
  );
}

EnterpriseHubApplicationStatusData _parseApplicationStatus(
  Map<String, Object?> payload,
) {
  final boardType = EnterpriseBoardType.fromRaw(
    _requiredString(payload, 'applyBoardType'),
  );
  if (boardType == null) {
    throw const FormatException('application status 缺少合法 applyBoardType。');
  }

  return EnterpriseHubApplicationStatusData(
    applicationId: _requiredString(payload, 'applicationId'),
    enterpriseId: _requiredString(payload, 'enterpriseId'),
    applyBoardType: boardType,
    applicationStatus: _requiredString(payload, 'applicationStatus'),
    rejectionReason: _readString(payload['rejectionReason']),
    reviewNote: _readString(payload['reviewNote']),
    submittedAt: _readString(payload['submittedAt']),
    reviewedAt: _readString(payload['reviewedAt']),
  );
}

EnterpriseHubCaseCreateData _parseCaseCreateData(Map<String, Object?> payload) {
  return EnterpriseHubCaseCreateData(
    caseId: _requiredString(payload, 'caseId'),
    caseStatus: _requiredString(payload, 'caseStatus'),
  );
}

EnterpriseHubCaseDetailData _parseCaseDetailData(Map<String, Object?> payload) {
  final boardType = EnterpriseBoardType.fromRaw(
    _readString(payload['boardType']),
  );
  if (boardType == null) {
    throw const FormatException('案例详情缺少合法 boardType。');
  }

  return EnterpriseHubCaseDetailData(
    caseId: _requiredString(payload, 'caseId'),
    enterpriseId: _requiredString(payload, 'enterpriseId'),
    boardType: boardType,
    title: _requiredString(payload, 'title'),
    exhibitionType: _readString(payload['exhibitionType']),
    city: _readString(payload['city']),
    eventTime: _readString(payload['eventTime']),
    summary: _requiredString(payload, 'summary'),
    caseCoverFileAssetId: _readString(payload['caseCoverFileAssetId']),
    caseMediaFileAssetIds: _readStringList(payload['caseMediaFileAssetIds']),
    caseImageUrlMap: _readStringMap(payload['caseImageUrlMap']),
    isFeatured: payload['isFeatured'] == true,
    caseStatus: _requiredString(payload, 'caseStatus'),
  );
}

List<EnterpriseHubListItem> _parseListItems(Object? raw) {
  if (raw is! List) {
    return const <EnterpriseHubListItem>[];
  }

  return raw
      .whereType<Map>()
      .map<Map<String, Object?>>(
        (Map item) =>
            item.map((Object? key, Object? value) => MapEntry('$key', value)),
      )
      .map<EnterpriseHubListItem>(_parseListItem)
      .toList(growable: false);
}

EnterpriseHubListItem _parseListItem(Map<String, Object?> payload) {
  final boardType = EnterpriseBoardType.fromRaw(
    _requiredString(payload, 'boardType'),
  );
  if (boardType == null) {
    throw const FormatException('enterprise list item 缺少合法 boardType。');
  }

  return EnterpriseHubListItem(
    enterpriseId: _requiredString(payload, 'enterpriseId'),
    boardType: boardType,
    name: _requiredString(payload, 'name'),
    logoUrl: _readString(payload['logoUrl']),
    provinceCode: _readString(payload['provinceCode']),
    provinceName: _requiredString(payload, 'provinceName'),
    cityCode: _readString(payload['cityCode']),
    cityName: _requiredString(payload, 'cityName'),
    primaryBoardLabel: _requiredString(payload, 'primaryBoardLabel'),
    secondaryCapabilityLabels: _readStringList(
      payload['secondaryCapabilityLabels'],
    ),
    shortIntro: _requiredString(payload, 'shortIntro'),
    certificationLabel: _requiredString(payload, 'certificationLabel'),
    caseCount: _readInt(payload['caseCount']) ?? 0,
    avgScore: _readDouble(payload['avgScore']),
    keywordTags: _readStringList(payload['keywordTags']),
    boardHighlights: _asMap(payload['boardHighlights']) ?? <String, Object?>{},
  );
}

EnterpriseHubPagination _parsePagination(Object? raw) {
  final payload = _asMap(raw);
  if (payload == null) {
    throw const FormatException('pagination 响应缺失。');
  }
  return EnterpriseHubPagination(
    page: _readInt(payload['page']) ?? 1,
    pageSize: _readInt(payload['pageSize']) ?? 10,
    total: _readInt(payload['total']) ?? 0,
    hasMore: payload['hasMore'] == true,
  );
}

EnterpriseHubHeader _parseHeader(Object? raw) {
  final payload = _asMap(raw);
  if (payload == null) {
    throw const FormatException('header 响应缺失。');
  }
  final boardType = EnterpriseBoardType.fromRaw(
    _requiredString(payload, 'primaryBoardType'),
  );
  if (boardType == null) {
    throw const FormatException('header.primaryBoardType 不合法。');
  }

  final secondaryCapabilities = <EnterpriseBoardType>[];
  final rawSecondary = payload['secondaryCapabilities'];
  if (rawSecondary is List) {
    for (final item in rawSecondary) {
      final parsed = EnterpriseBoardType.fromRaw(_readString(item));
      if (parsed != null) {
        secondaryCapabilities.add(parsed);
      }
    }
  }

  return EnterpriseHubHeader(
    enterpriseId: _requiredString(payload, 'enterpriseId'),
    name: _requiredString(payload, 'name'),
    primaryBoardType: boardType,
    secondaryCapabilities: secondaryCapabilities,
    shortIntro: _requiredString(payload, 'shortIntro'),
    provinceName: _requiredString(payload, 'provinceName'),
    cityName: _requiredString(payload, 'cityName'),
    logoUrl: _readString(payload['logoUrl']),
    verificationStatus: _readString(payload['verificationStatus']),
  );
}

EnterpriseHubVisualGallery _parseVisualGallery(
  Map<String, Object?> payload,
  Map<String, Object?> boardProfile,
) {
  final rawGallery = _asMap(payload['visualGallery']);
  final showcaseImageUrls = _readStringList(boardProfile['showcaseImageUrls']);
  if (rawGallery != null) {
    final albumImageUrls = _readStringList(rawGallery['albumImageUrls']);
    return EnterpriseHubVisualGallery(
      showcaseImageUrls: showcaseImageUrls,
      albumImageUrls: albumImageUrls,
      source:
          _readString(rawGallery['source']) ??
          (showcaseImageUrls.isNotEmpty
              ? 'showcase'
              : albumImageUrls.isEmpty
              ? 'empty'
              : 'enterprise_album'),
    );
  }

  return EnterpriseHubVisualGallery(
    showcaseImageUrls: showcaseImageUrls,
    albumImageUrls: const <String>[],
    source: showcaseImageUrls.isEmpty ? 'empty' : 'showcase',
  );
}

List<String> _dedupeImageUrls(List<String> rawItems) {
  final items = <String>[];
  for (final item in rawItems) {
    final normalized = item.trim();
    if (normalized.isEmpty || items.contains(normalized)) {
      continue;
    }
    items.add(normalized);
  }
  return items;
}

EnterpriseHubBasicInfo _parseBasicInfo(Object? raw) {
  final payload = _asMap(raw) ?? <String, Object?>{};
  return EnterpriseHubBasicInfo(
    legalName: _readString(payload['legalName']),
    foundedAt: _readString(payload['foundedAt']),
    teamSizeRange: _readString(payload['teamSizeRange']),
    fullIntro: _readString(payload['fullIntro']),
    address: _readString(payload['address']),
  );
}

List<EnterpriseHubServiceArea> _parseServiceAreas(Object? raw) {
  if (raw is! List) {
    return const <EnterpriseHubServiceArea>[];
  }

  return raw
      .whereType<Map>()
      .map<Map<String, Object?>>(
        (Map item) =>
            item.map((Object? key, Object? value) => MapEntry('$key', value)),
      )
      .map(
        (Map<String, Object?> item) => EnterpriseHubServiceArea(
          provinceName: _requiredString(item, 'provinceName'),
          areaType: _readString(item['areaType']),
          cityName: _readString(item['cityName']),
        ),
      )
      .toList(growable: false);
}

List<EnterpriseHubCaseCard> _parseCases(Object? raw) {
  if (raw is! List) {
    return const <EnterpriseHubCaseCard>[];
  }

  return raw
      .whereType<Map>()
      .map<Map<String, Object?>>(
        (Map item) =>
            item.map((Object? key, Object? value) => MapEntry('$key', value)),
      )
      .map(
        (Map<String, Object?> item) => EnterpriseHubCaseCard(
          id: _requiredString(item, 'id'),
          title: _requiredString(item, 'title'),
          summary: _requiredString(item, 'summary'),
          caseStatus: _requiredString(item, 'caseStatus'),
          coverImageUrl: _readString(item['coverImageUrl']),
          eventTime: _readString(item['eventTime']),
        ),
      )
      .toList(growable: false);
}

List<EnterpriseHubCertificationCard> _parseCertifications(Object? raw) {
  if (raw is! List) {
    return const <EnterpriseHubCertificationCard>[];
  }

  return raw
      .whereType<Map>()
      .map<Map<String, Object?>>(
        (Map item) =>
            item.map((Object? key, Object? value) => MapEntry('$key', value)),
      )
      .map(
        (Map<String, Object?> item) => EnterpriseHubCertificationCard(
          type: _requiredString(item, 'type'),
          name: _requiredString(item, 'name'),
          status: _requiredString(item, 'status'),
        ),
      )
      .toList(growable: false);
}

EnterpriseHubReviewSummary _parseReviewSummary(Object? raw) {
  final payload = _asMap(raw) ?? <String, Object?>{};
  return EnterpriseHubReviewSummary(
    keywordTags: _readStringList(payload['keywordTags']),
    avgScore: _readDouble(payload['avgScore']),
    reviewCount: _readInt(payload['reviewCount']),
    deliveryScore: _readDouble(payload['deliveryScore']),
    qualityScore: _readDouble(payload['qualityScore']),
    communicationScore: _readDouble(payload['communicationScore']),
  );
}

List<EnterpriseHubContactCard> _parseContacts(Object? raw) {
  if (raw is! List) {
    return const <EnterpriseHubContactCard>[];
  }

  return raw
      .whereType<Map>()
      .map<Map<String, Object?>>(
        (Map item) =>
            item.map((Object? key, Object? value) => MapEntry('$key', value)),
      )
      .map(
        (Map<String, Object?> item) => EnterpriseHubContactCard(
          contactName: _requiredString(item, 'contactName'),
          mobile: _readString(item['mobile']),
          wechat: _readString(item['wechat']),
          phone: _readString(item['phone']),
          email: _readString(item['email']),
          position: _readString(item['position']),
        ),
      )
      .toList(growable: false);
}

Map<String, Object?>? _asMap(Object? raw) {
  if (raw is! Map) {
    return null;
  }
  return raw.map((Object? key, Object? value) => MapEntry('$key', value));
}

AppPageState? _mapFailureState(int statusCode) {
  if (statusCode >= 200 && statusCode < 300) {
    return null;
  }
  if (statusCode == 401) {
    return AppPageState.unauthorized;
  }
  if (statusCode == 403) {
    return AppPageState.forbidden;
  }
  if (statusCode == 404) {
    return AppPageState.notFound;
  }
  if (statusCode >= 500) {
    return AppPageState.errorRetryable;
  }
  return AppPageState.errorNonRetryable;
}

String? _normalized(String? value) {
  if (value == null) {
    return null;
  }
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String _requiredString(Map<String, Object?> payload, String field) {
  final value = _readString(payload[field]);
  if (value == null) {
    throw FormatException('响应缺少必填字段 $field。');
  }
  return value;
}

String? _readString(Object? raw, [Object? fallback]) {
  if (raw is String) {
    final trimmed = raw.trim();
    if (trimmed.isNotEmpty) {
      return trimmed;
    }
  }
  if (fallback is String) {
    final trimmed = fallback.trim();
    if (trimmed.isNotEmpty) {
      return trimmed;
    }
  }
  return null;
}

int? _readInt(Object? raw) {
  if (raw is int) {
    return raw;
  }
  if (raw is num) {
    return raw.toInt();
  }
  return null;
}

double? _readDouble(Object? raw) {
  if (raw is num) {
    return raw.toDouble();
  }
  return null;
}

List<String> _readStringList(Object? raw) {
  if (raw is! List) {
    return const <String>[];
  }
  return raw
      .whereType<String>()
      .map((String item) => item.trim())
      .where((String item) => item.isNotEmpty)
      .toList(growable: false);
}

Map<String, String> _readStringMap(Object? raw) {
  if (raw is! Map) {
    return const <String, String>{};
  }
  final result = <String, String>{};
  for (final entry in raw.entries) {
    final key = '${entry.key}'.trim();
    final value = entry.value is String ? (entry.value as String).trim() : '';
    if (key.isEmpty || value.isEmpty) {
      continue;
    }
    result[key] = value;
  }
  return result;
}

String? _messageFromPayload(Map<String, Object?>? payload) {
  if (payload == null) {
    return null;
  }
  return _readString(payload['message']) ??
      _readString(payload['errorMessage']) ??
      _readString(payload['detail']);
}

String? _errorCodeFromPayload(Map<String, Object?>? payload) {
  if (payload == null) {
    return null;
  }
  return _readString(payload['code']) ?? _readString(payload['errorCode']);
}

bool _isEffectivelyEmpty(Map<String, Object?> payload) {
  if (payload.isEmpty) {
    return true;
  }

  final items = payload['items'];
  if (items is List) {
    final recommended = payload['recommended'];
    if (recommended is List) {
      return items.isEmpty && recommended.isEmpty;
    }
    return items.isEmpty;
  }
  return false;
}
