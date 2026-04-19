import 'dart:io';

import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_consumer_layer.dart';

class EnterpriseHubWorkbenchData {
  const EnterpriseHubWorkbenchData({
    required this.organizationId,
    required this.enterpriseId,
    required this.boardType,
    required this.latestApplication,
    required this.basic,
    required this.boardProfile,
    required this.primaryContact,
    required this.cases,
    required this.certification,
    required this.readiness,
  });

  final String organizationId;
  final String? enterpriseId;
  final EnterpriseBoardType? boardType;
  final EnterpriseHubWorkbenchApplication? latestApplication;
  final EnterpriseHubWorkbenchBasic? basic;
  final Map<String, Object?>? boardProfile;
  final EnterpriseHubWorkbenchContact? primaryContact;
  final List<EnterpriseHubWorkbenchCaseItem> cases;
  final EnterpriseHubWorkbenchCertification? certification;
  final EnterpriseHubWorkbenchReadiness readiness;
}

class EnterpriseHubWorkbenchApplication {
  const EnterpriseHubWorkbenchApplication({
    required this.applicationId,
    required this.applicationStatus,
    this.submittedAt,
    this.reviewedAt,
    this.rejectionReason,
    this.reviewNote,
  });

  final String applicationId;
  final String applicationStatus;
  final String? submittedAt;
  final String? reviewedAt;
  final String? rejectionReason;
  final String? reviewNote;
}

class EnterpriseHubWorkbenchBasic {
  const EnterpriseHubWorkbenchBasic({
    this.name,
    this.logoFileAssetId,
    this.logoUrl,
    this.albumImageFileAssetIds = const <String>[],
    this.albumImageUrlMap = const <String, String>{},
    this.shortIntro,
    this.fullIntro,
    this.provinceCode,
    this.provinceName,
    this.cityCode,
    this.cityName,
    this.address,
    this.location,
    this.foundedAt,
    this.teamSizeRange,
    this.cooperationModes = const <String>[],
    this.contactVisible = false,
  });

  final String? name;
  final String? logoFileAssetId;
  final String? logoUrl;
  final List<String> albumImageFileAssetIds;
  final Map<String, String> albumImageUrlMap;
  final String? shortIntro;
  final String? fullIntro;
  final String? provinceCode;
  final String? provinceName;
  final String? cityCode;
  final String? cityName;
  final String? address;
  final EnterpriseHubLocationData? location;
  final String? foundedAt;
  final String? teamSizeRange;
  final List<String> cooperationModes;
  final bool contactVisible;
}

class EnterpriseHubWorkbenchContact {
  const EnterpriseHubWorkbenchContact({
    required this.contactName,
    this.mobile,
    this.wechat,
    this.phone,
    this.email,
    this.position,
    required this.isPrimary,
    required this.visibleToPublic,
  });

  final String contactName;
  final String? mobile;
  final String? wechat;
  final String? phone;
  final String? email;
  final String? position;
  final bool isPrimary;
  final bool visibleToPublic;
}

class EnterpriseHubWorkbenchCaseItem {
  const EnterpriseHubWorkbenchCaseItem({
    required this.caseId,
    required this.boardType,
    required this.title,
    this.exhibitionType,
    this.city,
    this.eventTime,
    required this.summary,
    required this.caseCoverFileAssetId,
    required this.caseMediaFileAssetIds,
    this.caseImageUrlMap = const <String, String>{},
    required this.isFeatured,
    required this.caseStatus,
  });

  final String caseId;
  final EnterpriseBoardType boardType;
  final String title;
  final String? exhibitionType;
  final String? city;
  final String? eventTime;
  final String summary;
  final String caseCoverFileAssetId;
  final List<String> caseMediaFileAssetIds;
  final Map<String, String> caseImageUrlMap;
  final bool isFeatured;
  final String caseStatus;
}

class EnterpriseHubWorkbenchCertification {
  const EnterpriseHubWorkbenchCertification({
    required this.certificationStatus,
    this.legalName,
    this.uscc,
    this.licenseFileId,
    this.submittedAt,
    this.reviewedAt,
    this.rejectReason,
  });

  final String certificationStatus;
  final String? legalName;
  final String? uscc;
  final String? licenseFileId;
  final String? submittedAt;
  final String? reviewedAt;
  final String? rejectReason;
}

class EnterpriseHubWorkbenchReadiness {
  const EnterpriseHubWorkbenchReadiness({
    required this.hasApplication,
    required this.draftEditable,
    required this.basicCompleted,
    required this.profileCompleted,
    required this.hasCase,
    required this.hasContact,
    required this.certificationApproved,
    required this.submitReady,
    required this.blockers,
  });

  final bool hasApplication;
  final bool draftEditable;
  final bool basicCompleted;
  final bool profileCompleted;
  final bool hasCase;
  final bool hasContact;
  final bool certificationApproved;
  final bool submitReady;
  final List<String> blockers;
}

class EnterpriseHubWorkbenchConsumerLayer {
  EnterpriseHubWorkbenchConsumerLayer({AppApiClient? client})
    : _client = client ?? AppApiClient();

  final AppApiClient _client;

  static EnterpriseHubWorkbenchConsumerLayer _instance =
      EnterpriseHubWorkbenchConsumerLayer();

  static EnterpriseHubWorkbenchConsumerLayer get instance => _instance;

  static void install(EnterpriseHubWorkbenchConsumerLayer consumerLayer) {
    _instance = consumerLayer;
  }

  static void reset() {
    _instance = EnterpriseHubWorkbenchConsumerLayer();
  }

  Future<EnterpriseHubLoadResult<EnterpriseHubWorkbenchData>> loadWorkbench({
    required EnterpriseBoardType boardType,
  }) async {
    final canonicalPath = EnterpriseHubBoardCanonicalFamily.forBoard(
      boardType,
    ).workbench;
    try {
      final response = await _client.get(canonicalPath);
      final payload = _asMap(response.body);
      final failureState = _mapFailureState(response.statusCode);
      if (failureState != null) {
        return EnterpriseHubLoadResult<EnterpriseHubWorkbenchData>(
          state: failureState,
          method: 'GET',
          path: canonicalPath,
          payload: payload ?? response.body,
          message: _messageFromPayload(payload),
          errorCode: _errorCodeFromPayload(payload),
        );
      }
      if (payload == null) {
        return EnterpriseHubLoadResult<EnterpriseHubWorkbenchData>(
          state: AppPageState.errorNonRetryable,
          method: 'GET',
          path: canonicalPath,
          payload: response.body,
          message: '响应体不是对象，当前无法完成工作台合同映射。',
        );
      }
      return EnterpriseHubLoadResult<EnterpriseHubWorkbenchData>(
        state: AppPageState.content,
        method: 'GET',
        path: canonicalPath,
        payload: payload,
        data: _parseWorkbench(payload),
      );
    } on SocketException {
      return EnterpriseHubLoadResult<EnterpriseHubWorkbenchData>(
        state: AppPageState.errorRetryable,
        method: 'GET',
        path: canonicalPath,
        message: '网络未就绪，当前无法读取展示工作台。',
      );
    } on StateError {
      return EnterpriseHubLoadResult<EnterpriseHubWorkbenchData>(
        state: AppPageState.errorRetryable,
        method: 'GET',
        path: canonicalPath,
        message: '当前 fake transport 尚未提供企业展示工作台 canonical path。',
      );
    } on FormatException catch (error) {
      return EnterpriseHubLoadResult<EnterpriseHubWorkbenchData>(
        state: AppPageState.errorNonRetryable,
        method: 'GET',
        path: canonicalPath,
        message: error.message,
      );
    }
  }
}

EnterpriseHubWorkbenchData _parseWorkbench(Map<String, Object?> payload) {
  return EnterpriseHubWorkbenchData(
    organizationId: _requiredString(payload, 'organizationId'),
    enterpriseId: _readString(payload['enterpriseId']),
    boardType: EnterpriseBoardType.fromRaw(_readString(payload['boardType'])),
    latestApplication: _parseLatestApplication(payload['latestApplication']),
    basic: _parseBasic(payload['basic']),
    boardProfile: _asMap(payload['boardProfile']),
    primaryContact: _parsePrimaryContact(payload['primaryContact']),
    cases: _parseCases(payload['cases']),
    certification: _parseCertification(payload['certification']),
    readiness: _parseReadiness(payload['readiness']),
  );
}

EnterpriseHubWorkbenchApplication? _parseLatestApplication(Object? raw) {
  final payload = _asMap(raw);
  if (payload == null) {
    return null;
  }
  return EnterpriseHubWorkbenchApplication(
    applicationId: _requiredString(payload, 'applicationId'),
    applicationStatus: _requiredString(payload, 'applicationStatus'),
    submittedAt: _readString(payload['submittedAt']),
    reviewedAt: _readString(payload['reviewedAt']),
    rejectionReason: _readString(payload['rejectionReason']),
    reviewNote: _readString(payload['reviewNote']),
  );
}

EnterpriseHubWorkbenchBasic? _parseBasic(Object? raw) {
  final payload = _asMap(raw);
  if (payload == null) {
    return null;
  }
  return EnterpriseHubWorkbenchBasic(
    name: _readString(payload['name']),
    logoFileAssetId: _readString(payload['logoFileAssetId']),
    logoUrl: _readString(payload['logoUrl']),
    albumImageFileAssetIds: _readStringList(payload['albumImageFileAssetIds']),
    albumImageUrlMap: _readStringMap(payload['albumImageUrlMap']),
    shortIntro: _readString(payload['shortIntro']),
    fullIntro: _readString(payload['fullIntro']),
    provinceCode: _readString(payload['provinceCode']),
    provinceName: _readString(payload['provinceName']),
    cityCode: _readString(payload['cityCode']),
    cityName: _readString(payload['cityName']),
    address: _readString(payload['address']),
    location: _asMap(payload['location']) == null
        ? null
        : EnterpriseHubLocationData(
            addressText: _readString(
              _asMap(payload['location'])?['addressText'],
              _asMap(payload['location'])?['address'],
            ),
            publicDisplayAddress: _readString(
              _asMap(payload['location'])?['publicDisplayAddress'],
            ),
            provinceCode: _readString(
              _asMap(payload['location'])?['provinceCode'],
            ),
            provinceName: _readString(
              _asMap(payload['location'])?['provinceName'],
            ),
            cityCode: _readString(_asMap(payload['location'])?['cityCode']),
            cityName: _readString(_asMap(payload['location'])?['cityName']),
            districtCode: _readString(
              _asMap(payload['location'])?['districtCode'],
            ),
            districtName: _readString(
              _asMap(payload['location'])?['districtName'],
            ),
            latitude: _readDouble(_asMap(payload['location'])?['latitude']),
            longitude: _readDouble(_asMap(payload['location'])?['longitude']),
            geoSource: _readString(_asMap(payload['location'])?['geoSource']),
            geoStatus:
                _readString(_asMap(payload['location'])?['geoStatus']) ??
                'not_provided',
            lastGeocodedAt: _readString(
              _asMap(payload['location'])?['lastGeocodedAt'],
            ),
            mapProvider: _readString(
              _asMap(payload['location'])?['mapProvider'],
            ),
            mapPreviewUrl: _readString(
              _asMap(payload['location'])?['mapPreviewUrl'],
            ),
            mapLinkUrl: _readString(_asMap(payload['location'])?['mapLinkUrl']),
          ),
    foundedAt: _readString(payload['foundedAt']),
    teamSizeRange: _readString(payload['teamSizeRange']),
    cooperationModes: _readStringList(payload['cooperationModes']),
    contactVisible: payload['contactVisible'] == true,
  );
}

EnterpriseHubWorkbenchContact? _parsePrimaryContact(Object? raw) {
  final payload = _asMap(raw);
  if (payload == null) {
    return null;
  }
  return EnterpriseHubWorkbenchContact(
    contactName: _requiredString(payload, 'contactName'),
    mobile: _readString(payload['mobile']),
    wechat: _readString(payload['wechat']),
    phone: _readString(payload['phone']),
    email: _readString(payload['email']),
    position: _readString(payload['position']),
    isPrimary: payload['isPrimary'] == true,
    visibleToPublic: payload['visibleToPublic'] == true,
  );
}

List<EnterpriseHubWorkbenchCaseItem> _parseCases(Object? raw) {
  if (raw is! List) {
    return const <EnterpriseHubWorkbenchCaseItem>[];
  }
  return raw
      .whereType<Map>()
      .map(
        (Map item) =>
            item.map((Object? key, Object? value) => MapEntry('$key', value)),
      )
      .map(
        (Map<String, Object?> payload) => EnterpriseHubWorkbenchCaseItem(
          caseId: _requiredString(payload, 'caseId'),
          boardType:
              EnterpriseBoardType.fromRaw(_readString(payload['boardType'])) ??
              EnterpriseBoardType.company,
          title: _requiredString(payload, 'title'),
          exhibitionType: _readString(payload['exhibitionType']),
          city: _readString(payload['city']),
          eventTime: _readString(payload['eventTime']),
          summary: _requiredString(payload, 'summary'),
          caseCoverFileAssetId: _requiredString(
            payload,
            'caseCoverFileAssetId',
          ),
          caseMediaFileAssetIds: _readStringList(
            payload['caseMediaFileAssetIds'],
          ),
          caseImageUrlMap: _readStringMap(payload['caseImageUrlMap']),
          isFeatured: payload['isFeatured'] == true,
          caseStatus: _requiredString(payload, 'caseStatus'),
        ),
      )
      .toList(growable: false);
}

EnterpriseHubWorkbenchCertification? _parseCertification(Object? raw) {
  final payload = _asMap(raw);
  if (payload == null) {
    return null;
  }
  return EnterpriseHubWorkbenchCertification(
    certificationStatus: _requiredString(payload, 'certificationStatus'),
    legalName: _readString(payload['legalName']),
    uscc: _readString(payload['uscc']),
    licenseFileId: _readString(payload['licenseFileId']),
    submittedAt: _readString(payload['submittedAt']),
    reviewedAt: _readString(payload['reviewedAt']),
    rejectReason: _readString(payload['rejectReason']),
  );
}

EnterpriseHubWorkbenchReadiness _parseReadiness(Object? raw) {
  final payload = _asMap(raw) ?? const <String, Object?>{};
  return EnterpriseHubWorkbenchReadiness(
    hasApplication: payload['hasApplication'] == true,
    draftEditable: payload['draftEditable'] == true,
    basicCompleted: payload['basicCompleted'] == true,
    profileCompleted: payload['profileCompleted'] == true,
    hasCase: payload['hasCase'] == true,
    hasContact: payload['hasContact'] == true,
    certificationApproved: payload['certificationApproved'] == true,
    submitReady: payload['submitReady'] == true,
    blockers: _readStringList(payload['blockers']),
  );
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
  raw.forEach((Object? key, Object? value) {
    final normalizedKey = _readString('$key');
    final normalizedValue = value is String ? _readString(value) : null;
    if (normalizedKey != null && normalizedValue != null) {
      result[normalizedKey] = normalizedValue;
    }
  });
  return result;
}

double? _readDouble(Object? raw) {
  if (raw is num) {
    return raw.toDouble();
  }
  if (raw is String) {
    return double.tryParse(raw.trim());
  }
  return null;
}
