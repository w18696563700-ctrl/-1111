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
    this.certifiedOnly = false,
    this.sortBy = 'default',
    this.exhibitionType,
    this.serviceCity,
    this.processType,
    this.urgentCapability,
    this.warehouseCapability,
    this.supplyCategory,
    this.supplyMode,
    this.page = 1,
    this.pageSize = 10,
  });

  final EnterpriseBoardType boardType;
  final String? keyword;
  final bool certifiedOnly;
  final String sortBy;
  final String? exhibitionType;
  final String? serviceCity;
  final String? processType;
  final String? urgentCapability;
  final bool? warehouseCapability;
  final String? supplyCategory;
  final String? supplyMode;
  final int page;
  final int pageSize;

  Map<String, String> toQueryParameters() {
    return <String, String>{
      'boardType': boardType.contractName,
      if (_normalized(keyword) case final String value) 'keyword': value,
      if (certifiedOnly) 'certifiedOnly': 'true',
      if (_normalized(sortBy) case final String value) 'sortBy': value,
      if (_normalized(exhibitionType) case final String value)
        'exhibitionType': value,
      if (_normalized(serviceCity) case final String value) 'serviceCity': value,
      if (_normalized(processType) case final String value) 'processType': value,
      if (_normalized(urgentCapability) case final String value)
        'urgentCapability': value,
      if (warehouseCapability != null)
        'warehouseCapability': warehouseCapability! ? 'true' : 'false',
      if (_normalized(supplyCategory) case final String value)
        'supplyCategory': value,
      if (_normalized(supplyMode) case final String value) 'supplyMode': value,
      'page': '$page',
      'pageSize': '$pageSize',
    };
  }

  EnterpriseHubListQuery copyWith({
    String? keyword,
    bool? certifiedOnly,
    String? sortBy,
    String? exhibitionType,
    String? serviceCity,
    String? processType,
    String? urgentCapability,
    bool? warehouseCapability,
    String? supplyCategory,
    String? supplyMode,
    int? page,
    int? pageSize,
    bool clearWarehouseCapability = false,
  }) {
    return EnterpriseHubListQuery(
      boardType: boardType,
      keyword: keyword ?? this.keyword,
      certifiedOnly: certifiedOnly ?? this.certifiedOnly,
      sortBy: sortBy ?? this.sortBy,
      exhibitionType: exhibitionType ?? this.exhibitionType,
      serviceCity: serviceCity ?? this.serviceCity,
      processType: processType ?? this.processType,
      urgentCapability: urgentCapability ?? this.urgentCapability,
      warehouseCapability: clearWarehouseCapability
          ? null
          : warehouseCapability ?? this.warehouseCapability,
      supplyCategory: supplyCategory ?? this.supplyCategory,
      supplyMode: supplyMode ?? this.supplyMode,
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
    this.avgScore,
    this.keywordTags = const <String>[],
  });

  final String enterpriseId;
  final EnterpriseBoardType boardType;
  final String name;
  final String? logoUrl;
  final String provinceName;
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
    required this.basicInfo,
    required this.boardProfile,
    required this.serviceAreas,
    required this.cases,
    required this.certifications,
    required this.reviewSummary,
    required this.contacts,
  });

  final EnterpriseHubHeader header;
  final EnterpriseHubBasicInfo basicInfo;
  final Map<String, Object?> boardProfile;
  final List<EnterpriseHubServiceArea> serviceAreas;
  final List<EnterpriseHubCaseCard> cases;
  final List<EnterpriseHubCertificationCard> certifications;
  final EnterpriseHubReviewSummary reviewSummary;
  final List<EnterpriseHubContactCard> contacts;
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
  });

  final String id;
  final String title;
  final String summary;
  final String caseStatus;
  final String? coverImageUrl;
  final String? eventTime;
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

class EnterpriseHubApplicationStatusData {
  const EnterpriseHubApplicationStatusData({
    required this.applicationId,
    required this.enterpriseId,
    required this.applyBoardType,
    required this.applicationStatus,
    this.rejectionReason,
    this.submittedAt,
    this.reviewedAt,
  });

  final String applicationId;
  final String enterpriseId;
  final EnterpriseBoardType applyBoardType;
  final String applicationStatus;
  final String? rejectionReason;
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
    return _load(
      method: 'GET',
      canonicalPath: _EnterpriseHubCanonicalPaths.enterprises,
      request: () => _client.get(
        _EnterpriseHubCanonicalPaths.enterprises,
        queryParameters: query.toQueryParameters(),
      ),
      parser: _parseListData,
    );
  }

  Future<EnterpriseHubLoadResult<EnterpriseHubDetailData>> loadEnterpriseDetail({
    required String enterpriseId,
    required EnterpriseBoardType boardType,
  }) {
    final normalizedId = _normalized(enterpriseId);
    if (normalizedId == null) {
      return Future.value(
        EnterpriseHubLoadResult<EnterpriseHubDetailData>(
          state: AppPageState.errorNonRetryable,
          method: 'GET',
          path: _EnterpriseHubCanonicalPaths.enterprises,
          message: '缺少 enterpriseId，当前无法读取详情。',
        ),
      );
    }

    return _load(
      method: 'GET',
      canonicalPath: _EnterpriseHubCanonicalPaths.enterpriseDetail(normalizedId),
      request: () => _client.get(
        _EnterpriseHubCanonicalPaths.enterpriseDetail(normalizedId),
        queryParameters: <String, String>{'boardType': boardType.contractName},
      ),
      parser: _parseDetailData,
    );
  }

  Future<EnterpriseHubLoadResult<EnterpriseHubRecommendationData>>
  loadRecommendations(EnterpriseBoardType boardType) {
    return _load(
      method: 'GET',
      canonicalPath: _EnterpriseHubCanonicalPaths.recommendations,
      request: () => _client.get(
        _EnterpriseHubCanonicalPaths.recommendations,
        queryParameters: <String, String>{'boardType': boardType.contractName},
      ),
      parser: _parseRecommendationData,
    );
  }

  Future<EnterpriseHubActionResult<EnterpriseHubApplicationDraft>>
  createApplication({
    required EnterpriseBoardType boardType,
    required String applicantName,
    required String applicantMobile,
  }) {
    return _submit(
      method: 'POST',
      canonicalPath: _EnterpriseHubCanonicalPaths.applications,
      request: () => _client.post(
        _EnterpriseHubCanonicalPaths.applications,
        body: <String, Object?>{
          'applyBoardType': boardType.contractName,
          'applicantName': applicantName.trim(),
          'applicantMobile': applicantMobile.trim(),
        },
      ),
      parser: _parseApplicationDraft,
    );
  }

  Future<EnterpriseHubActionResult<bool>> updateBasic({
    required String enterpriseId,
    required Map<String, Object?> body,
  }) {
    return _ackPut(
      _EnterpriseHubCanonicalPaths.updateBasic(enterpriseId),
      body: body,
    );
  }

  Future<EnterpriseHubActionResult<bool>> updateCompanyProfile({
    required String enterpriseId,
    required Map<String, Object?> body,
  }) {
    return _ackPut(
      _EnterpriseHubCanonicalPaths.updateCompanyProfile(enterpriseId),
      body: body,
    );
  }

  Future<EnterpriseHubActionResult<bool>> updateFactoryProfile({
    required String enterpriseId,
    required Map<String, Object?> body,
  }) {
    return _ackPut(
      _EnterpriseHubCanonicalPaths.updateFactoryProfile(enterpriseId),
      body: body,
    );
  }

  Future<EnterpriseHubActionResult<bool>> updateSupplierProfile({
    required String enterpriseId,
    required Map<String, Object?> body,
  }) {
    return _ackPut(
      _EnterpriseHubCanonicalPaths.updateSupplierProfile(enterpriseId),
      body: body,
    );
  }

  Future<EnterpriseHubActionResult<EnterpriseHubCaseCreateData>> createCase({
    required String enterpriseId,
    required Map<String, Object?> body,
  }) {
    return _submit(
      method: 'POST',
      canonicalPath: _EnterpriseHubCanonicalPaths.createCase(enterpriseId),
      request: () => _client.post(
        _EnterpriseHubCanonicalPaths.createCase(enterpriseId),
        body: body,
      ),
      parser: _parseCaseCreateData,
    );
  }

  Future<EnterpriseHubActionResult<bool>> submitApplication({
    required String applicationId,
  }) {
    return _submit(
      method: 'POST',
      canonicalPath: _EnterpriseHubCanonicalPaths.submitApplication(
        applicationId,
      ),
      request: () => _client.post(
        _EnterpriseHubCanonicalPaths.submitApplication(applicationId),
        body: const <String, Object?>{'confirm': true},
      ),
      parser: (_) => true,
    );
  }

  Future<EnterpriseHubLoadResult<EnterpriseHubApplicationStatusData>>
  loadApplicationStatus({
    required String applicationId,
  }) {
    return _load(
      method: 'GET',
      canonicalPath: _EnterpriseHubCanonicalPaths.applicationStatus(
        applicationId,
      ),
      request: () => _client.get(
        _EnterpriseHubCanonicalPaths.applicationStatus(applicationId),
      ),
      parser: _parseApplicationStatus,
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

  static const String enterprises = '/api/app/exhibition/enterprise-hub/enterprises';
  static const String recommendations =
      '/api/app/exhibition/enterprise-hub/recommendations';
  static const String applications =
      '/api/app/exhibition/enterprise-hub/applications';

  static String enterpriseDetail(String enterpriseId) =>
      '/api/app/exhibition/enterprise-hub/enterprises/$enterpriseId';

  static String updateBasic(String enterpriseId) =>
      '/api/app/exhibition/enterprise-hub/enterprises/$enterpriseId/basic';

  static String updateCompanyProfile(String enterpriseId) =>
      '/api/app/exhibition/enterprise-hub/enterprises/$enterpriseId/profiles/company';

  static String updateFactoryProfile(String enterpriseId) =>
      '/api/app/exhibition/enterprise-hub/enterprises/$enterpriseId/profiles/factory';

  static String updateSupplierProfile(String enterpriseId) =>
      '/api/app/exhibition/enterprise-hub/enterprises/$enterpriseId/profiles/supplier';

  static String createCase(String enterpriseId) =>
      '/api/app/exhibition/enterprise-hub/enterprises/$enterpriseId/cases';

  static String submitApplication(String applicationId) =>
      '/api/app/exhibition/enterprise-hub/applications/$applicationId/submit';

  static String applicationStatus(String applicationId) =>
      '/api/app/exhibition/enterprise-hub/applications/$applicationId';
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
  final boardType = EnterpriseBoardType.fromRaw(_readString(payload['boardType']));
  if (boardType == null) {
    throw const FormatException('recommendations 缺少合法 boardType。');
  }
  return EnterpriseHubRecommendationData(
    boardType: boardType,
    items: _parseListItems(payload['items']),
  );
}

EnterpriseHubDetailData _parseDetailData(Map<String, Object?> payload) {
  return EnterpriseHubDetailData(
    header: _parseHeader(payload['header']),
    basicInfo: _parseBasicInfo(payload['basicInfo']),
    boardProfile: _asMap(payload['boardProfile']) ??
        <String, Object?>{},
    serviceAreas: _parseServiceAreas(payload['serviceAreas']),
    cases: _parseCases(payload['cases']),
    certifications: _parseCertifications(payload['certifications']),
    reviewSummary: _parseReviewSummary(payload['reviewSummary']),
    contacts: _parseContacts(payload['contacts']),
  );
}

EnterpriseHubApplicationDraft _parseApplicationDraft(Map<String, Object?> payload) {
  return EnterpriseHubApplicationDraft(
    applicationId: _requiredString(payload, 'applicationId'),
    enterpriseId: _requiredString(payload, 'enterpriseId'),
    applicationStatus: _requiredString(payload, 'applicationStatus'),
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

List<EnterpriseHubListItem> _parseListItems(Object? raw) {
  if (raw is! List) {
    return const <EnterpriseHubListItem>[];
  }

  return raw
      .whereType<Map>()
      .map<Map<String, Object?>>(
        (Map item) => item.map((Object? key, Object? value) => MapEntry('$key', value)),
      )
      .map<EnterpriseHubListItem>(_parseListItem)
      .toList(growable: false);
}

EnterpriseHubListItem _parseListItem(Map<String, Object?> payload) {
  final boardType = EnterpriseBoardType.fromRaw(_requiredString(payload, 'boardType'));
  if (boardType == null) {
    throw const FormatException('enterprise list item 缺少合法 boardType。');
  }

  return EnterpriseHubListItem(
    enterpriseId: _requiredString(payload, 'enterpriseId'),
    boardType: boardType,
    name: _requiredString(payload, 'name'),
    logoUrl: _readString(payload['logoUrl']),
    provinceName: _requiredString(payload, 'provinceName'),
    cityName: _requiredString(payload, 'cityName'),
    primaryBoardLabel: _requiredString(payload, 'primaryBoardLabel'),
    secondaryCapabilityLabels: _readStringList(payload['secondaryCapabilityLabels']),
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
        (Map item) => item.map((Object? key, Object? value) => MapEntry('$key', value)),
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
        (Map item) => item.map((Object? key, Object? value) => MapEntry('$key', value)),
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
        (Map item) => item.map((Object? key, Object? value) => MapEntry('$key', value)),
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
        (Map item) => item.map((Object? key, Object? value) => MapEntry('$key', value)),
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

String? _readString(Object? raw) {
  if (raw is! String) {
    return null;
  }
  final trimmed = raw.trim();
  return trimmed.isEmpty ? null : trimmed;
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
