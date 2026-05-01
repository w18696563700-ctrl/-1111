import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/auth/protected_app_request.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/features/profile/data/profile_personal_edit_parser.dart';
import 'package:mobile/features/profile/data/profile_personal_edit_upload_models.dart';

final class ProfileIdentityCanonicalPaths {
  const ProfileIdentityCanonicalPaths._();

  static const String organizationCreate =
      '/api/app/profile/organization/create';
  static const String organizationCurrent =
      '/api/app/profile/organization/current';
  static const String organizationJoinByCode =
      '/api/app/profile/organization/join-by-code';
  static const String organizationSwitch =
      '/api/app/profile/organization/switch';
  static const String organizationCurrentLeave =
      '/api/app/profile/organization/current/leave';
  static const String organizationMine = '/api/app/profile/organization/mine';
  static const String organizationMembers =
      '/api/app/profile/organization/members';
  static const String certificationCurrent =
      '/api/app/profile/certification/current';
  static const String certificationLicenseOcr =
      '/api/app/profile/certification/license/ocr';
  static const String personalCertificationIdCardOcr =
      '/api/app/profile/certification/personal/id-card/ocr';
  static const String personalCertificationSubmit =
      '/api/app/profile/certification/personal/submit';
  static const String certificationSubmit =
      '/api/app/profile/certification/submit';
  static const String certificationRevalidate =
      '/api/app/profile/certification/revalidate';
  static const String certificationResubmit =
      '/api/app/profile/certification/resubmit';
  static const String securityDevices = '/api/app/profile/security/devices';

  static String securityDeviceRevoke(String deviceId) =>
      '/api/app/profile/security/devices/${Uri.encodeComponent(deviceId)}/revoke';

  static String organizationMemberRolePatch(String memberId) =>
      '/api/app/profile/organization/members/${Uri.encodeComponent(memberId)}/role';

  static String organizationMemberDisable(String memberId) =>
      '/api/app/profile/organization/members/${Uri.encodeComponent(memberId)}/disable';
}

class ProfileIdentityResult<T> {
  const ProfileIdentityResult({
    required this.state,
    required this.method,
    required this.path,
    this.data,
    this.message,
    this.errorCode,
  });

  final AppPageState state;
  final String method;
  final String path;
  final T? data;
  final String? message;
  final String? errorCode;
}

class ProfileOrganizationCreateView {
  const ProfileOrganizationCreateView({
    required this.organizationId,
    required this.roleKeys,
    required this.membershipStatus,
    required this.certificationStatus,
    this.traceId,
  });

  final String organizationId;
  final List<String> roleKeys;
  final String membershipStatus;
  final String certificationStatus;
  final String? traceId;
}

class ProfileOrganizationJoinAcceptedView {
  const ProfileOrganizationJoinAcceptedView({
    required this.organizationId,
    required this.membershipStatus,
    required this.traceId,
  });

  final String organizationId;
  final String membershipStatus;
  final String traceId;
}

class OrganizationLeaveAcceptedView {
  const OrganizationLeaveAcceptedView({
    required this.leftOrganizationId,
    required this.nextOrganizationId,
    required this.shellBootstrapState,
    required this.traceId,
  });

  final String leftOrganizationId;
  final String? nextOrganizationId;
  final String shellBootstrapState;
  final String traceId;
}

class MyOrganizationItemView {
  const MyOrganizationItemView({
    required this.organizationId,
    required this.name,
    required this.organizationType,
    required this.roleKeys,
    required this.membershipStatus,
    required this.certificationStatus,
    required this.current,
    this.provinceCode,
    this.cityCode,
    this.contactName,
    this.contactMobile,
    this.intro,
  });

  final String organizationId;
  final String name;
  final String organizationType;
  final String? provinceCode;
  final String? cityCode;
  final String? contactName;
  final String? contactMobile;
  final String? intro;
  final List<String> roleKeys;
  final String membershipStatus;
  final String certificationStatus;
  final bool current;
}

class MyOrganizationsView {
  const MyOrganizationsView({required this.items});

  final List<MyOrganizationItemView> items;
}

class OrganizationMemberItemView {
  const OrganizationMemberItemView({
    required this.memberId,
    required this.userId,
    required this.roleKey,
    required this.memberStatus,
    this.displayName,
    this.mobileMasked,
    this.joinedAt,
    this.disabledAt,
  });

  final String memberId;
  final String userId;
  final String roleKey;
  final String memberStatus;
  final String? displayName;
  final String? mobileMasked;
  final String? joinedAt;
  final String? disabledAt;
}

class OrganizationMembersView {
  const OrganizationMembersView({required this.items});

  final List<OrganizationMemberItemView> items;
}

class ProfileCertificationCurrentView {
  const ProfileCertificationCurrentView({
    required this.organizationId,
    required this.certificationStatus,
    this.legalName,
    this.uscc,
    this.legalPerson,
    this.businessType,
    this.address,
    this.registeredCapital,
    this.establishedAt,
    this.businessTerm,
    this.businessScope,
    this.licenseFileId,
    this.rejectReason,
    this.expiresAt,
    this.submittedAt,
    this.personalCertification,
  });

  final String? organizationId;
  final String? certificationStatus;
  final String? legalName;
  final String? uscc;
  final String? legalPerson;
  final String? businessType;
  final String? address;
  final String? registeredCapital;
  final String? establishedAt;
  final String? businessTerm;
  final String? businessScope;
  final String? licenseFileId;
  final String? rejectReason;
  final String? expiresAt;
  final String? submittedAt;
  final ProfilePersonalCertificationCurrentView? personalCertification;
}

class ProfilePersonalCertificationCurrentView {
  const ProfilePersonalCertificationCurrentView({
    required this.organizationId,
    required this.certificationStatus,
    required this.qualifiedForCurrentActor,
    required this.lockedToOtherActor,
    this.userId,
    this.realName,
    this.idNumberMasked,
    this.idCardFrontFileId,
    this.rejectReason,
    this.submittedAt,
    this.lockedAt,
  });

  final String organizationId;
  final String certificationStatus;
  final bool qualifiedForCurrentActor;
  final bool lockedToOtherActor;
  final String? userId;
  final String? realName;
  final String? idNumberMasked;
  final String? idCardFrontFileId;
  final String? rejectReason;
  final String? submittedAt;
  final String? lockedAt;
}

class ProfileCertificationAcceptedView {
  const ProfileCertificationAcceptedView({
    required this.organizationId,
    required this.certificationStatus,
    required this.submittedAt,
    required this.traceId,
  });

  final String organizationId;
  final String certificationStatus;
  final String? submittedAt;
  final String traceId;
}

class CertificationLicenseOcrView {
  const CertificationLicenseOcrView({
    required this.status,
    required this.message,
    this.legalName,
    this.uscc,
    this.legalPerson,
    this.businessType,
    this.address,
    this.registeredCapital,
    this.establishedAt,
    this.businessTerm,
    this.businessScope,
    this.providerRequestId,
  });

  final String status;
  final String message;
  final String? legalName;
  final String? uscc;
  final String? legalPerson;
  final String? businessType;
  final String? address;
  final String? registeredCapital;
  final String? establishedAt;
  final String? businessTerm;
  final String? businessScope;
  final String? providerRequestId;
}

class PersonalCertificationIdCardOcrView {
  const PersonalCertificationIdCardOcrView({
    required this.status,
    required this.message,
    this.realName,
    this.idNumberMasked,
    this.providerRequestId,
  });

  final String status;
  final String message;
  final String? realName;
  final String? idNumberMasked;
  final String? providerRequestId;
}

class PersonalCertificationAcceptedView {
  const PersonalCertificationAcceptedView({
    required this.organizationId,
    required this.userId,
    required this.certificationStatus,
    required this.traceId,
    this.submittedAt,
    this.lockedAt,
  });

  final String organizationId;
  final String userId;
  final String certificationStatus;
  final String traceId;
  final String? submittedAt;
  final String? lockedAt;
}

class SecurityDeviceItemView {
  const SecurityDeviceItemView({
    required this.deviceId,
    required this.currentDevice,
    required this.trustStatus,
    this.deviceName,
    this.osType,
    this.appVersion,
    this.lastSeenAt,
    this.revokedAt,
  });

  final String deviceId;
  final bool currentDevice;
  final String trustStatus;
  final String? deviceName;
  final String? osType;
  final String? appVersion;
  final String? lastSeenAt;
  final String? revokedAt;
}

class SecurityDevicesView {
  const SecurityDevicesView({required this.items});

  final List<SecurityDeviceItemView> items;
}

class ProfileActionAckView {
  const ProfileActionAckView({required this.ok, required this.traceId});

  final bool ok;
  final String traceId;
}

class ProfileIdentityConsumerLayer {
  ProfileIdentityConsumerLayer._(this._client);

  factory ProfileIdentityConsumerLayer({AppApiClient? client}) {
    return ProfileIdentityConsumerLayer._(client ?? AppApiClient());
  }

  static ProfileIdentityConsumerLayer _instance =
      ProfileIdentityConsumerLayer();

  static ProfileIdentityConsumerLayer get instance => _instance;

  static void install(ProfileIdentityConsumerLayer consumerLayer) {
    _instance = consumerLayer;
  }

  static void reset() {
    _instance = ProfileIdentityConsumerLayer();
  }

  final AppApiClient _client;
  static const String _profileBusinessType = 'profile';
  static const String _certificationLicenseFileKind = 'business_license';
  static const String _personalCertificationIdCardFileKind = 'id_card_front';

  Future<ProfileIdentityResult<ProfileOrganizationCreateView>>
  createOrganization({
    required String name,
    required String organizationType,
    required String provinceCode,
    required String cityCode,
    required String contactName,
    required String contactMobile,
  }) {
    return _post(
      canonicalPath: ProfileIdentityCanonicalPaths.organizationCreate,
      body: <String, Object?>{
        'name': name.trim(),
        'organizationType': organizationType,
        'provinceCode': provinceCode.trim(),
        'cityCode': cityCode.trim(),
        'contactName': contactName.trim(),
        'contactMobile': contactMobile.trim(),
      },
      parser: _parseOrganizationCreateView,
    );
  }

  Future<ProfileIdentityResult<ProfileActionAckView>>
  updateCurrentOrganization({
    required String name,
    required String provinceCode,
    required String cityCode,
    required String contactName,
    required String contactMobile,
    String? intro,
  }) {
    return _patch(
      canonicalPath: ProfileIdentityCanonicalPaths.organizationCurrent,
      body: <String, Object?>{
        'name': name.trim(),
        'provinceCode': provinceCode.trim(),
        'cityCode': cityCode.trim(),
        'contactName': contactName.trim(),
        'contactMobile': contactMobile.trim(),
        'intro': _trimNullable(intro),
      },
      parser: _parseActionAckView,
    );
  }

  Future<ProfileIdentityResult<ProfileOrganizationJoinAcceptedView>>
  joinByCode({required String inviteCode}) {
    return _post(
      canonicalPath: ProfileIdentityCanonicalPaths.organizationJoinByCode,
      body: <String, Object?>{'inviteCode': inviteCode.trim()},
      parser: _parseJoinByCodeView,
    );
  }

  Future<ProfileIdentityResult<AppShellContextData>> switchOrganization({
    required String organizationId,
  }) {
    return _post(
      canonicalPath: ProfileIdentityCanonicalPaths.organizationSwitch,
      body: <String, Object?>{'organizationId': organizationId},
      parser: _parseShellContextData,
    );
  }

  Future<ProfileIdentityResult<OrganizationLeaveAcceptedView>>
  leaveCurrentOrganization({String? reason}) {
    return _post(
      canonicalPath: ProfileIdentityCanonicalPaths.organizationCurrentLeave,
      body: <String, Object?>{'reason': _trimNullable(reason)},
      parser: _parseOrganizationLeaveAcceptedView,
    );
  }

  Future<ProfileIdentityResult<MyOrganizationsView>> loadMyOrganizations() {
    return _get(
      canonicalPath: ProfileIdentityCanonicalPaths.organizationMine,
      parser: _parseMyOrganizationsView,
    );
  }

  Future<ProfileIdentityResult<OrganizationMembersView>>
  loadOrganizationMembers() {
    return _get(
      canonicalPath: ProfileIdentityCanonicalPaths.organizationMembers,
      parser: _parseOrganizationMembersView,
    );
  }

  Future<ProfileIdentityResult<ProfileCertificationCurrentView>>
  loadCertificationCurrent() {
    return _get(
      canonicalPath: ProfileIdentityCanonicalPaths.certificationCurrent,
      parser: _parseCertificationCurrentView,
    );
  }

  Future<ProfileIdentityResult<ProfileCertificationAcceptedView>>
  submitCertification({
    required String organizationId,
    required String legalName,
    required String uscc,
    required String fileAssetId,
    String? contactName,
    String? contactMobile,
  }) {
    return _post(
      canonicalPath: ProfileIdentityCanonicalPaths.certificationSubmit,
      body: <String, Object?>{
        'organizationId': organizationId.trim(),
        'legalName': legalName.trim(),
        'uscc': uscc.trim(),
        'licenseFileId': fileAssetId.trim(),
        'contactName': _trimNullable(contactName),
        'contactMobile': _trimNullable(contactMobile),
      },
      parser: _parseCertificationAcceptedView,
    );
  }

  Future<ProfileIdentityResult<CertificationLicenseOcrView>>
  recognizeCertificationLicense({
    required String organizationId,
    required String fileAssetId,
  }) {
    return _post(
      canonicalPath: ProfileIdentityCanonicalPaths.certificationLicenseOcr,
      body: <String, Object?>{
        'organizationId': organizationId.trim(),
        'licenseFileId': fileAssetId.trim(),
      },
      parser: _parseCertificationLicenseOcrView,
    );
  }

  Future<ProfileIdentityResult<PersonalCertificationIdCardOcrView>>
  recognizePersonalCertificationIdCard({
    required String organizationId,
    required String fileAssetId,
  }) {
    return _post(
      canonicalPath:
          ProfileIdentityCanonicalPaths.personalCertificationIdCardOcr,
      body: <String, Object?>{
        'organizationId': organizationId.trim(),
        'idCardFrontFileId': fileAssetId.trim(),
      },
      parser: _parsePersonalCertificationIdCardOcrView,
    );
  }

  Future<ProfileIdentityResult<PersonalCertificationAcceptedView>>
  submitPersonalCertification({
    required String organizationId,
    required String fileAssetId,
  }) {
    return _post(
      canonicalPath: ProfileIdentityCanonicalPaths.personalCertificationSubmit,
      body: <String, Object?>{
        'organizationId': organizationId.trim(),
        'idCardFrontFileId': fileAssetId.trim(),
      },
      parser: _parsePersonalCertificationAcceptedView,
    );
  }

  Future<ProfileIdentityResult<ProfileCertificationAcceptedView>>
  revalidateCertification({
    required String organizationId,
    required String legalName,
    required String uscc,
    required String fileAssetId,
    String? correctionNote,
  }) {
    return _post(
      canonicalPath: ProfileIdentityCanonicalPaths.certificationRevalidate,
      body: <String, Object?>{
        'organizationId': organizationId.trim(),
        'legalName': legalName.trim(),
        'uscc': uscc.trim(),
        'licenseFileId': fileAssetId.trim(),
        'correctionNote': _trimNullable(correctionNote),
      },
      parser: _parseCertificationAcceptedView,
    );
  }

  Future<ProfileIdentityResult<ProfileCertificationAcceptedView>>
  resubmitCertification({
    required String organizationId,
    required String legalName,
    required String uscc,
    required String fileAssetId,
    String? supplementNote,
  }) {
    return _post(
      canonicalPath: ProfileIdentityCanonicalPaths.certificationResubmit,
      body: <String, Object?>{
        'organizationId': organizationId.trim(),
        'legalName': legalName.trim(),
        'uscc': uscc.trim(),
        'licenseFileId': fileAssetId.trim(),
        'supplementNote': _trimNullable(supplementNote),
      },
      parser: _parseCertificationAcceptedView,
    );
  }

  Future<ProfileFileUploadResult> initCertificationLicenseUpload({
    required String? organizationId,
    required String mimeType,
    required List<int> bodyBytes,
  }) async {
    final normalizedOrganizationId = _trimNullable(organizationId);
    final normalizedMimeType = ProfilePersonalEditParser.readString(mimeType);
    if (normalizedOrganizationId == null ||
        normalizedMimeType == null ||
        bodyBytes.isEmpty) {
      return const ProfileFileUploadResult(
        state: AppUploadState.uploadFailedRetryable,
        controlledState: AppPageState.errorNonRetryable,
        message: '当前营业执照上传参数不完整，请重新选择后再试。',
        errorCode: 'FILE_UPLOAD_INIT_INVALID',
      );
    }

    try {
      final response = await _client.post(
        ProfileFileUploadCanonicalPaths.uploadInit,
        body: <String, Object?>{
          'businessType': _profileBusinessType,
          'businessId': normalizedOrganizationId,
          'fileKind': _certificationLicenseFileKind,
          'mimeType': normalizedMimeType,
          'size': bodyBytes.length,
          'checksum': sha256.convert(bodyBytes).toString(),
        },
      );

      if (!ProfilePersonalEditParser.isSuccessful(response.statusCode)) {
        return ProfilePersonalEditParser.uploadFailure(
          state: AppUploadState.uploadFailedRetryable,
          controlledState: ProfilePersonalEditParser.mapPageState(
            response.statusCode,
          ),
          body: response.body,
          fallbackMessage: '当前营业执照上传入口暂不可用，请稍后再试。',
        );
      }

      final directive = ProfilePersonalEditParser.parseUploadDirective(
        response.body,
      );
      if (directive == null) {
        return const ProfileFileUploadResult(
          state: AppUploadState.uploadFailedRetryable,
          controlledState: AppPageState.errorNonRetryable,
          message: '营业执照上传初始化响应缺少必要字段，页面保持受控失败。',
        );
      }
      if (directive.confirmEndpoint !=
          ProfileFileUploadCanonicalPaths.uploadConfirm) {
        return const ProfileFileUploadResult(
          state: AppUploadState.uploadFailedRetryable,
          controlledState: AppPageState.errorNonRetryable,
          message: '营业执照上传确认路由漂移到非 app-facing canonical path，页面保持受控失败。',
        );
      }

      return ProfileFileUploadResult(
        state: AppUploadState.signedReady,
        controlledState: AppPageState.content,
        directive: directive,
      );
    } on SocketException {
      return const ProfileFileUploadResult(
        state: AppUploadState.uploadFailedRetryable,
        controlledState: AppPageState.errorRetryable,
        message: '当前营业执照上传初始化网络异常，请检查后重试。',
      );
    } on HttpException {
      return const ProfileFileUploadResult(
        state: AppUploadState.uploadFailedRetryable,
        controlledState: AppPageState.errorRetryable,
        message: '当前营业执照上传初始化请求失败，请稍后再试。',
      );
    } on FormatException {
      return const ProfileFileUploadResult(
        state: AppUploadState.uploadFailedRetryable,
        controlledState: AppPageState.errorNonRetryable,
        message: '当前营业执照上传初始化响应解析失败，页面保持受控失败。',
      );
    }
  }

  Future<ProfileFileUploadResult> initPersonalCertificationIdCardUpload({
    required String? organizationId,
    required String mimeType,
    required List<int> bodyBytes,
  }) async {
    final normalizedOrganizationId = _trimNullable(organizationId);
    final normalizedMimeType = ProfilePersonalEditParser.readString(mimeType);
    if (normalizedOrganizationId == null ||
        normalizedMimeType == null ||
        bodyBytes.isEmpty) {
      return const ProfileFileUploadResult(
        state: AppUploadState.uploadFailedRetryable,
        controlledState: AppPageState.errorNonRetryable,
        message: '当前身份证正面上传参数不完整，请重新选择后再试。',
        errorCode: 'FILE_UPLOAD_INIT_INVALID',
      );
    }

    try {
      final response = await _client.post(
        ProfileFileUploadCanonicalPaths.uploadInit,
        body: <String, Object?>{
          'businessType': _profileBusinessType,
          'businessId': normalizedOrganizationId,
          'fileKind': _personalCertificationIdCardFileKind,
          'mimeType': normalizedMimeType,
          'size': bodyBytes.length,
          'checksum': sha256.convert(bodyBytes).toString(),
        },
      );

      if (!ProfilePersonalEditParser.isSuccessful(response.statusCode)) {
        return ProfilePersonalEditParser.uploadFailure(
          state: AppUploadState.uploadFailedRetryable,
          controlledState: ProfilePersonalEditParser.mapPageState(
            response.statusCode,
          ),
          body: response.body,
          fallbackMessage: '当前身份证正面上传入口暂不可用，请稍后再试。',
        );
      }

      final directive = ProfilePersonalEditParser.parseUploadDirective(
        response.body,
      );
      if (directive == null) {
        return const ProfileFileUploadResult(
          state: AppUploadState.uploadFailedRetryable,
          controlledState: AppPageState.errorNonRetryable,
          message: '身份证正面上传初始化响应缺少必要字段，页面保持受控失败。',
        );
      }
      if (directive.confirmEndpoint !=
          ProfileFileUploadCanonicalPaths.uploadConfirm) {
        return const ProfileFileUploadResult(
          state: AppUploadState.uploadFailedRetryable,
          controlledState: AppPageState.errorNonRetryable,
          message: '身份证正面上传确认路由漂移到非 app-facing canonical path，页面保持受控失败。',
        );
      }

      return ProfileFileUploadResult(
        state: AppUploadState.signedReady,
        controlledState: AppPageState.content,
        directive: directive,
      );
    } on SocketException {
      return const ProfileFileUploadResult(
        state: AppUploadState.uploadFailedRetryable,
        controlledState: AppPageState.errorRetryable,
        message: '当前身份证正面上传初始化网络异常，请检查后重试。',
      );
    } on HttpException {
      return const ProfileFileUploadResult(
        state: AppUploadState.uploadFailedRetryable,
        controlledState: AppPageState.errorRetryable,
        message: '当前身份证正面上传初始化请求失败，请稍后再试。',
      );
    } on FormatException {
      return const ProfileFileUploadResult(
        state: AppUploadState.uploadFailedRetryable,
        controlledState: AppPageState.errorNonRetryable,
        message: '当前身份证正面上传初始化响应解析失败，页面保持受控失败。',
      );
    }
  }

  Future<ProfileFileUploadResult> directCertificationLicenseUpload({
    required ProfileFileUploadDirective directive,
    required List<int> bodyBytes,
  }) async {
    try {
      final response = await _client.upload(
        method: directive.directUploadMethod,
        url: directive.directUploadUrl,
        headers: directive.directUploadHeaders,
        bodyBytes: bodyBytes,
      );
      if (ProfilePersonalEditParser.isSuccessful(response.statusCode)) {
        return const ProfileFileUploadResult(
          state: AppUploadState.uploadConfirming,
          controlledState: AppPageState.content,
        );
      }

      return ProfilePersonalEditParser.uploadFailure(
        state: AppUploadState.uploadFailedRetryable,
        controlledState: ProfilePersonalEditParser.mapPageState(
          response.statusCode,
        ),
        body: response.body,
        fallbackMessage: '当前营业执照直传失败，请稍后再试。',
      );
    } on SocketException {
      return const ProfileFileUploadResult(
        state: AppUploadState.uploadFailedRetryable,
        controlledState: AppPageState.errorRetryable,
        message: '当前营业执照直传网络异常，请检查后重试。',
      );
    } on HttpException {
      return const ProfileFileUploadResult(
        state: AppUploadState.uploadFailedRetryable,
        controlledState: AppPageState.errorRetryable,
        message: '当前营业执照直传请求失败，请稍后再试。',
      );
    }
  }

  Future<ProfileFileUploadResult> confirmCertificationLicenseUpload({
    required ProfileFileUploadDirective directive,
  }) async {
    try {
      final response = await _client.post(
        ProfileFileUploadCanonicalPaths.uploadConfirm,
        body: <String, Object?>{'uploadSessionId': directive.uploadSessionId},
      );
      if (!ProfilePersonalEditParser.isSuccessful(response.statusCode)) {
        return ProfilePersonalEditParser.uploadFailure(
          state: AppUploadState.uploadConfirmFailed,
          controlledState: ProfilePersonalEditParser.mapPageState(
            response.statusCode,
          ),
          body: response.body,
          fallbackMessage: '当前营业执照上传确认失败，请稍后再试。',
        );
      }

      final fileAssetId = ProfilePersonalEditParser.readFileAssetId(
        response.body,
      );
      if (fileAssetId == null) {
        return const ProfileFileUploadResult(
          state: AppUploadState.uploadConfirmFailed,
          controlledState: AppPageState.errorNonRetryable,
          message: '营业执照上传确认响应缺少 fileAssetId，页面保持受控失败。',
        );
      }

      return ProfileFileUploadResult(
        state: AppUploadState.uploadBound,
        controlledState: AppPageState.content,
        fileAssetId: fileAssetId,
      );
    } on SocketException {
      return const ProfileFileUploadResult(
        state: AppUploadState.uploadConfirmFailed,
        controlledState: AppPageState.errorRetryable,
        message: '当前营业执照上传确认网络异常，请检查后重试。',
      );
    } on HttpException {
      return const ProfileFileUploadResult(
        state: AppUploadState.uploadConfirmFailed,
        controlledState: AppPageState.errorRetryable,
        message: '当前营业执照上传确认请求失败，请稍后再试。',
      );
    } on FormatException {
      return const ProfileFileUploadResult(
        state: AppUploadState.uploadConfirmFailed,
        controlledState: AppPageState.errorNonRetryable,
        message: '当前营业执照上传确认响应解析失败，页面保持受控失败。',
      );
    }
  }

  Future<ProfileFileUploadResult> directPersonalCertificationIdCardUpload({
    required ProfileFileUploadDirective directive,
    required List<int> bodyBytes,
  }) async {
    try {
      final response = await _client.upload(
        method: directive.directUploadMethod,
        url: directive.directUploadUrl,
        headers: directive.directUploadHeaders,
        bodyBytes: bodyBytes,
      );
      if (ProfilePersonalEditParser.isSuccessful(response.statusCode)) {
        return const ProfileFileUploadResult(
          state: AppUploadState.uploadConfirming,
          controlledState: AppPageState.content,
        );
      }

      return ProfilePersonalEditParser.uploadFailure(
        state: AppUploadState.uploadFailedRetryable,
        controlledState: ProfilePersonalEditParser.mapPageState(
          response.statusCode,
        ),
        body: response.body,
        fallbackMessage: '当前身份证正面直传失败，请稍后再试。',
      );
    } on SocketException {
      return const ProfileFileUploadResult(
        state: AppUploadState.uploadFailedRetryable,
        controlledState: AppPageState.errorRetryable,
        message: '当前身份证正面直传网络异常，请检查后重试。',
      );
    } on HttpException {
      return const ProfileFileUploadResult(
        state: AppUploadState.uploadFailedRetryable,
        controlledState: AppPageState.errorRetryable,
        message: '当前身份证正面直传请求失败，请稍后再试。',
      );
    }
  }

  Future<ProfileFileUploadResult> confirmPersonalCertificationIdCardUpload({
    required ProfileFileUploadDirective directive,
  }) async {
    try {
      final response = await _client.post(
        ProfileFileUploadCanonicalPaths.uploadConfirm,
        body: <String, Object?>{'uploadSessionId': directive.uploadSessionId},
      );
      if (!ProfilePersonalEditParser.isSuccessful(response.statusCode)) {
        return ProfilePersonalEditParser.uploadFailure(
          state: AppUploadState.uploadConfirmFailed,
          controlledState: ProfilePersonalEditParser.mapPageState(
            response.statusCode,
          ),
          body: response.body,
          fallbackMessage: '当前身份证正面上传确认失败，请稍后再试。',
        );
      }

      final fileAssetId = ProfilePersonalEditParser.readFileAssetId(
        response.body,
      );
      if (fileAssetId == null) {
        return const ProfileFileUploadResult(
          state: AppUploadState.uploadConfirmFailed,
          controlledState: AppPageState.errorNonRetryable,
          message: '身份证正面上传确认响应缺少 fileAssetId，页面保持受控失败。',
        );
      }

      return ProfileFileUploadResult(
        state: AppUploadState.uploadBound,
        controlledState: AppPageState.content,
        fileAssetId: fileAssetId,
      );
    } on SocketException {
      return const ProfileFileUploadResult(
        state: AppUploadState.uploadConfirmFailed,
        controlledState: AppPageState.errorRetryable,
        message: '当前身份证正面上传确认网络异常，请检查后重试。',
      );
    } on HttpException {
      return const ProfileFileUploadResult(
        state: AppUploadState.uploadConfirmFailed,
        controlledState: AppPageState.errorRetryable,
        message: '当前身份证正面上传确认请求失败，请稍后再试。',
      );
    } on FormatException {
      return const ProfileFileUploadResult(
        state: AppUploadState.uploadConfirmFailed,
        controlledState: AppPageState.errorNonRetryable,
        message: '当前身份证正面上传确认响应解析失败，页面保持受控失败。',
      );
    }
  }

  Future<ProfileIdentityResult<SecurityDevicesView>> loadSecurityDevices() {
    return _get(
      canonicalPath: ProfileIdentityCanonicalPaths.securityDevices,
      parser: _parseSecurityDevicesView,
    );
  }

  Future<ProfileIdentityResult<ProfileActionAckView>> revokeSecurityDevice({
    required String deviceId,
  }) {
    final canonicalPath = ProfileIdentityCanonicalPaths.securityDeviceRevoke(
      deviceId.trim(),
    );
    return _post(
      canonicalPath: canonicalPath,
      body: <String, Object?>{'deviceId': deviceId.trim()},
      parser: _parseActionAckView,
    );
  }

  Future<ProfileIdentityResult<ProfileActionAckView>>
  patchOrganizationMemberRole({
    required String memberId,
    required String roleKey,
    String? reason,
  }) {
    final canonicalPath =
        ProfileIdentityCanonicalPaths.organizationMemberRolePatch(
          memberId.trim(),
        );
    return _patch(
      canonicalPath: canonicalPath,
      body: <String, Object?>{
        'roleKey': roleKey.trim(),
        'reason': _trimNullable(reason),
      },
      parser: _parseActionAckView,
    );
  }

  Future<ProfileIdentityResult<ProfileActionAckView>>
  disableOrganizationMember({required String memberId, String? reason}) {
    final canonicalPath =
        ProfileIdentityCanonicalPaths.organizationMemberDisable(
          memberId.trim(),
        );
    return _patch(
      canonicalPath: canonicalPath,
      body: <String, Object?>{'reason': _trimNullable(reason)},
      parser: _parseActionAckView,
    );
  }

  Future<ProfileIdentityResult<T>> _get<T>({
    required String canonicalPath,
    required T? Function(Object? payload) parser,
  }) async {
    try {
      final response = await runProtectedAppRequest(
        () => _client.get(canonicalPath),
      );
      return _mapResponse(
        response,
        method: 'GET',
        canonicalPath: canonicalPath,
        parser: parser,
      );
    } on SocketException {
      return ProfileIdentityResult<T>(
        state: AppPageState.errorRetryable,
        method: 'GET',
        path: canonicalPath,
        message: 'network error while requesting profile path',
      );
    } on HttpException {
      return ProfileIdentityResult<T>(
        state: AppPageState.errorRetryable,
        method: 'GET',
        path: canonicalPath,
        message: 'http error while requesting profile path',
      );
    } on FormatException {
      return ProfileIdentityResult<T>(
        state: AppPageState.errorNonRetryable,
        method: 'GET',
        path: canonicalPath,
        message: 'response decoding failed for profile path',
      );
    }
  }

  Future<ProfileIdentityResult<T>> _post<T>({
    required String canonicalPath,
    required Object? body,
    required T? Function(Object? payload) parser,
  }) async {
    try {
      final response = await _client.post(canonicalPath, body: body);
      return _mapResponse(
        response,
        method: 'POST',
        canonicalPath: canonicalPath,
        parser: parser,
      );
    } on SocketException {
      return ProfileIdentityResult<T>(
        state: AppPageState.errorRetryable,
        method: 'POST',
        path: canonicalPath,
        message: 'network error while requesting profile path',
      );
    } on HttpException {
      return ProfileIdentityResult<T>(
        state: AppPageState.errorRetryable,
        method: 'POST',
        path: canonicalPath,
        message: 'http error while requesting profile path',
      );
    } on FormatException {
      return ProfileIdentityResult<T>(
        state: AppPageState.errorNonRetryable,
        method: 'POST',
        path: canonicalPath,
        message: 'response decoding failed for profile path',
      );
    }
  }

  Future<ProfileIdentityResult<T>> _patch<T>({
    required String canonicalPath,
    required Object? body,
    required T? Function(Object? payload) parser,
  }) async {
    try {
      final response = await _sendDirect(
        method: 'PATCH',
        canonicalPath: canonicalPath,
        body: body,
      );
      return _mapResponse(
        response,
        method: 'PATCH',
        canonicalPath: canonicalPath,
        parser: parser,
      );
    } on SocketException {
      return ProfileIdentityResult<T>(
        state: AppPageState.errorRetryable,
        method: 'PATCH',
        path: canonicalPath,
        message: 'network error while requesting profile path',
      );
    } on HttpException {
      return ProfileIdentityResult<T>(
        state: AppPageState.errorRetryable,
        method: 'PATCH',
        path: canonicalPath,
        message: 'http error while requesting profile path',
      );
    } on FormatException {
      return ProfileIdentityResult<T>(
        state: AppPageState.errorNonRetryable,
        method: 'PATCH',
        path: canonicalPath,
        message: 'response decoding failed for profile path',
      );
    }
  }

  ProfileIdentityResult<T> _mapResponse<T>(
    AppApiResponse response, {
    required String method,
    required String canonicalPath,
    required T? Function(Object? payload) parser,
  }) {
    final errorCode = _extractErrorCode(response.body);
    final message = _extractMessage(response.body);

    if (response.statusCode == 401) {
      return ProfileIdentityResult<T>(
        state: AppPageState.unauthorized,
        method: method,
        path: canonicalPath,
        message: message ?? '当前身份未授权。',
        errorCode: errorCode,
      );
    }

    if (response.statusCode == 403) {
      return ProfileIdentityResult<T>(
        state: AppPageState.forbidden,
        method: method,
        path: canonicalPath,
        message: message ?? '当前入口未开放。',
        errorCode: errorCode,
      );
    }

    if (response.statusCode == 404) {
      return ProfileIdentityResult<T>(
        state: AppPageState.notFound,
        method: method,
        path: canonicalPath,
        message: message ?? '当前路径暂未承接。',
        errorCode: errorCode,
      );
    }

    if (response.statusCode >= 500) {
      return ProfileIdentityResult<T>(
        state: AppPageState.errorRetryable,
        method: method,
        path: canonicalPath,
        message: message ?? '当前请求暂时没有成功。',
        errorCode: errorCode,
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return ProfileIdentityResult<T>(
        state: AppPageState.errorNonRetryable,
        method: method,
        path: canonicalPath,
        message: message ?? '当前请求处于受控失败态。',
        errorCode: errorCode,
      );
    }

    final data = parser(response.body);
    if (data == null) {
      return ProfileIdentityResult<T>(
        state: AppPageState.errorNonRetryable,
        method: method,
        path: canonicalPath,
        message: 'profile identity response is missing required fields',
      );
    }

    return ProfileIdentityResult<T>(
      state: AppPageState.content,
      method: method,
      path: canonicalPath,
      data: data,
    );
  }

  Future<AppApiResponse> _sendDirect({
    required String method,
    required String canonicalPath,
    Object? body,
  }) async {
    final uri = _client.config.resolveCanonicalPath(canonicalPath);
    final httpClient = HttpClient();
    try {
      final request = await httpClient
          .openUrl(method, uri)
          .timeout(
            _client.config.requestTimeout,
            onTimeout: () => throw SocketException(
              'request timed out: $method $canonicalPath',
            ),
          );
      final headers = <String, String>{
        ..._client.config.defaultHeaders,
        ...AppSessionStore.instance.authorizationHeaders,
      };
      headers.forEach(request.headers.set);
      if (body != null) {
        request.headers.set(
          HttpHeaders.contentTypeHeader,
          'application/json; charset=utf-8',
        );
        request.add(utf8.encode(jsonEncode(body)));
      }

      final response = await request.close().timeout(
        _client.config.requestTimeout,
        onTimeout: () =>
            throw SocketException('request timed out: $method $canonicalPath'),
      );
      final responseBody = await utf8.decoder.bind(response).join();
      Object? decodedBody;
      if (responseBody.isNotEmpty) {
        try {
          decodedBody = jsonDecode(responseBody);
        } on FormatException {
          decodedBody = responseBody;
        }
      }

      final responseHeaders = <String, String>{};
      response.headers.forEach((String name, List<String> values) {
        responseHeaders[name] = values.join(',');
      });
      return AppApiResponse(
        statusCode: response.statusCode,
        uri: uri,
        body: decodedBody,
        headers: responseHeaders,
      );
    } finally {
      httpClient.close(force: true);
    }
  }

  static ProfileOrganizationCreateView? _parseOrganizationCreateView(
    Object? payload,
  ) {
    if (payload is! Map) {
      return null;
    }

    final body = _map(payload);
    final organizationId = _readString(body['organizationId']);
    final roleKeys = _readStringList(body['roleKeys']);
    final membershipStatus = _readString(body['membershipStatus']);
    final certificationStatus = _readString(body['certificationStatus']);
    if (organizationId == null ||
        roleKeys == null ||
        membershipStatus == null ||
        certificationStatus == null) {
      return null;
    }

    return ProfileOrganizationCreateView(
      organizationId: organizationId,
      roleKeys: roleKeys,
      membershipStatus: membershipStatus,
      certificationStatus: certificationStatus,
      traceId: _readNullableString(body['traceId']),
    );
  }

  static ProfileOrganizationJoinAcceptedView? _parseJoinByCodeView(
    Object? payload,
  ) {
    if (payload is! Map) {
      return null;
    }

    final body = _map(payload);
    final organizationId = _readString(body['organizationId']);
    final membershipStatus = _readString(body['membershipStatus']);
    final traceId = _readString(body['traceId']);
    if (organizationId == null || membershipStatus == null || traceId == null) {
      return null;
    }

    return ProfileOrganizationJoinAcceptedView(
      organizationId: organizationId,
      membershipStatus: membershipStatus,
      traceId: traceId,
    );
  }

  static MyOrganizationsView? _parseMyOrganizationsView(Object? payload) {
    if (payload is! Map) {
      return null;
    }

    final body = _map(payload);
    final rawItems = body['items'];
    if (rawItems is! List) {
      return null;
    }

    final items = <MyOrganizationItemView>[];
    for (final rawItem in rawItems) {
      if (rawItem is! Map) {
        return null;
      }

      final item = _map(rawItem);
      final organizationId = _readString(item['organizationId']);
      final name = _readString(item['name']);
      final organizationType = _readString(item['organizationType']);
      final roleKeys = _readStringList(item['roleKeys']);
      final membershipStatus = _readString(item['membershipStatus']);
      final certificationStatus = _readString(item['certificationStatus']);
      final current = item['current'];
      if (organizationId == null ||
          name == null ||
          organizationType == null ||
          roleKeys == null ||
          membershipStatus == null ||
          certificationStatus == null ||
          current is! bool) {
        return null;
      }

      items.add(
        MyOrganizationItemView(
          organizationId: organizationId,
          name: name,
          organizationType: organizationType,
          provinceCode: _readNullableString(item['provinceCode']),
          cityCode: _readNullableString(item['cityCode']),
          contactName: _readNullableString(item['contactName']),
          contactMobile: _readNullableString(item['contactMobile']),
          intro: _readNullableString(item['intro']),
          roleKeys: roleKeys,
          membershipStatus: membershipStatus,
          certificationStatus: certificationStatus,
          current: current,
        ),
      );
    }

    return MyOrganizationsView(
      items: List<MyOrganizationItemView>.unmodifiable(items),
    );
  }

  static OrganizationMembersView? _parseOrganizationMembersView(
    Object? payload,
  ) {
    if (payload is! Map) {
      return null;
    }

    final body = _map(payload);
    final rawItems = body['items'];
    if (rawItems is! List) {
      return null;
    }

    final items = <OrganizationMemberItemView>[];
    for (final rawItem in rawItems) {
      if (rawItem is! Map) {
        return null;
      }

      final item = _map(rawItem);
      final memberId = _readString(item['memberId']);
      final userId = _readString(item['userId']);
      final roleKey = _readString(item['roleKey']);
      final memberStatus = _readString(item['memberStatus']);
      if (memberId == null ||
          userId == null ||
          roleKey == null ||
          memberStatus == null) {
        return null;
      }

      items.add(
        OrganizationMemberItemView(
          memberId: memberId,
          userId: userId,
          roleKey: roleKey,
          memberStatus: memberStatus,
          displayName: _readNullableString(item['displayName']),
          mobileMasked: _readNullableString(item['mobileMasked']),
          joinedAt: _readNullableString(item['joinedAt']),
          disabledAt: _readNullableString(item['disabledAt']),
        ),
      );
    }

    return OrganizationMembersView(
      items: List<OrganizationMemberItemView>.unmodifiable(items),
    );
  }

  static ProfileCertificationCurrentView? _parseCertificationCurrentView(
    Object? payload,
  ) {
    if (payload is! Map) {
      return null;
    }

    final body = _map(payload);
    return ProfileCertificationCurrentView(
      organizationId: _readNullableString(body['organizationId']),
      certificationStatus: _readNullableString(body['certificationStatus']),
      legalName: _readNullableString(body['legalName']),
      uscc: _readNullableString(body['uscc']),
      legalPerson: _readNullableString(body['legalPerson']),
      businessType: _readNullableString(body['businessType']),
      address: _readNullableString(body['address']),
      registeredCapital: _readNullableString(body['registeredCapital']),
      establishedAt: _readNullableString(body['establishedAt']),
      businessTerm: _readNullableString(body['businessTerm']),
      businessScope: _readNullableString(body['businessScope']),
      licenseFileId: _readNullableString(body['licenseFileId']),
      rejectReason: _readNullableString(body['rejectReason']),
      expiresAt: _readNullableString(body['expiresAt']),
      submittedAt: _readNullableString(body['submittedAt']),
      personalCertification: _parsePersonalCertificationCurrentView(
        body['personalCertification'],
      ),
    );
  }

  static ProfilePersonalCertificationCurrentView?
  _parsePersonalCertificationCurrentView(Object? payload) {
    if (payload == null) {
      return null;
    }
    if (payload is! Map) {
      return null;
    }

    final body = _map(payload);
    final organizationId = _readString(body['organizationId']);
    final certificationStatus = _readString(body['certificationStatus']);
    final qualifiedForCurrentActor = body['qualifiedForCurrentActor'];
    final lockedToOtherActor = body['lockedToOtherActor'];
    if (organizationId == null ||
        certificationStatus == null ||
        qualifiedForCurrentActor is! bool ||
        lockedToOtherActor is! bool) {
      return null;
    }

    return ProfilePersonalCertificationCurrentView(
      organizationId: organizationId,
      certificationStatus: certificationStatus,
      qualifiedForCurrentActor: qualifiedForCurrentActor,
      lockedToOtherActor: lockedToOtherActor,
      userId: _readNullableString(body['userId']),
      realName: _readNullableString(body['realName']),
      idNumberMasked: _readNullableString(body['idNumberMasked']),
      idCardFrontFileId: _readNullableString(body['idCardFrontFileId']),
      rejectReason: _readNullableString(body['rejectReason']),
      submittedAt: _readNullableString(body['submittedAt']),
      lockedAt: _readNullableString(body['lockedAt']),
    );
  }

  static ProfileCertificationAcceptedView? _parseCertificationAcceptedView(
    Object? payload,
  ) {
    if (payload is! Map) {
      return null;
    }

    final body = _map(payload);
    final organizationId = _readString(body['organizationId']);
    final certificationStatus = _readString(body['certificationStatus']);
    final traceId = _readString(body['traceId']);
    if (organizationId == null ||
        certificationStatus == null ||
        traceId == null) {
      return null;
    }

    return ProfileCertificationAcceptedView(
      organizationId: organizationId,
      certificationStatus: certificationStatus,
      submittedAt: _readNullableString(body['submittedAt']),
      traceId: traceId,
    );
  }

  static CertificationLicenseOcrView? _parseCertificationLicenseOcrView(
    Object? payload,
  ) {
    if (payload is! Map) {
      return null;
    }

    final body = _map(payload);
    final status = _readString(body['status']);
    final message = _readString(body['message']);
    if (status == null || message == null) {
      return null;
    }

    return CertificationLicenseOcrView(
      status: status,
      message: message,
      legalName: _readNullableString(body['legalName']),
      uscc: _readNullableString(body['uscc']),
      legalPerson: _readNullableString(body['legalPerson']),
      businessType: _readNullableString(body['businessType']),
      address: _readNullableString(body['address']),
      registeredCapital: _readNullableString(body['registeredCapital']),
      establishedAt: _readNullableString(body['establishedAt']),
      businessTerm: _readNullableString(body['businessTerm']),
      businessScope: _readNullableString(body['businessScope']),
      providerRequestId: _readNullableString(body['providerRequestId']),
    );
  }

  static PersonalCertificationIdCardOcrView?
  _parsePersonalCertificationIdCardOcrView(Object? payload) {
    if (payload is! Map) {
      return null;
    }

    final body = _map(payload);
    final status = _readString(body['status']);
    final message = _readString(body['message']);
    if (status == null || message == null) {
      return null;
    }

    return PersonalCertificationIdCardOcrView(
      status: status,
      message: message,
      realName: _readNullableString(body['realName']),
      idNumberMasked: _readNullableString(body['idNumberMasked']),
      providerRequestId: _readNullableString(body['providerRequestId']),
    );
  }

  static PersonalCertificationAcceptedView?
  _parsePersonalCertificationAcceptedView(Object? payload) {
    if (payload is! Map) {
      return null;
    }

    final body = _map(payload);
    final organizationId = _readString(body['organizationId']);
    final userId = _readString(body['userId']);
    final certificationStatus = _readString(body['certificationStatus']);
    final traceId = _readString(body['traceId']);
    if (organizationId == null ||
        userId == null ||
        certificationStatus == null ||
        traceId == null) {
      return null;
    }

    return PersonalCertificationAcceptedView(
      organizationId: organizationId,
      userId: userId,
      certificationStatus: certificationStatus,
      traceId: traceId,
      submittedAt: _readNullableString(body['submittedAt']),
      lockedAt: _readNullableString(body['lockedAt']),
    );
  }

  static SecurityDevicesView? _parseSecurityDevicesView(Object? payload) {
    if (payload is! Map) {
      return null;
    }

    final body = _map(payload);
    final rawItems = body['items'];
    if (rawItems is! List) {
      return null;
    }

    final items = <SecurityDeviceItemView>[];
    for (final rawItem in rawItems) {
      if (rawItem is! Map) {
        return null;
      }

      final item = _map(rawItem);
      final deviceId = _readString(item['deviceId']);
      final currentDevice = item['currentDevice'];
      final trustStatus = _readString(item['trustStatus']);
      if (deviceId == null || currentDevice is! bool || trustStatus == null) {
        return null;
      }

      items.add(
        SecurityDeviceItemView(
          deviceId: deviceId,
          currentDevice: currentDevice,
          trustStatus: trustStatus,
          deviceName: _readNullableString(item['deviceName']),
          osType: _readNullableString(item['osType']),
          appVersion: _readNullableString(item['appVersion']),
          lastSeenAt: _readNullableString(item['lastSeenAt']),
          revokedAt: _readNullableString(item['revokedAt']),
        ),
      );
    }

    return SecurityDevicesView(
      items: List<SecurityDeviceItemView>.unmodifiable(items),
    );
  }

  static ProfileActionAckView? _parseActionAckView(Object? payload) {
    if (payload is! Map) {
      return null;
    }

    final body = _map(payload);
    final ok = body['ok'];
    final traceId = _readString(body['traceId']);
    if (ok is! bool || ok != true || traceId == null) {
      return null;
    }

    return ProfileActionAckView(ok: ok, traceId: traceId);
  }

  static AppShellContextData? _parseShellContextData(Object? payload) {
    if (payload is! Map) {
      return null;
    }

    final body = _map(payload);
    return AppShellContextData(
      userId: _readNullableString(body['userId']),
      organizationId: _readNullableString(body['organizationId']),
      roleKeys: _readStringList(body['roleKeys']) ?? const <String>[],
      certificationStatus: _readNullableString(body['certificationStatus']),
      personalCertificationStatus: _readNullableString(
        body['personalCertificationStatus'],
      ),
      personalCertificationQualified:
          body['personalCertificationQualified'] is bool
          ? body['personalCertificationQualified'] as bool
          : null,
      personalCertificationLockedToOtherActor:
          body['personalCertificationLockedToOtherActor'] is bool
          ? body['personalCertificationLockedToOtherActor'] as bool
          : null,
      membershipStatus: _readNullableString(body['membershipStatus']),
      projectCreateEligibility: _readProjectCreateEligibility(
        body['projectCreateEligibility'],
      ),
      visibleBuildings:
          _readStringList(body['visibleBuildings']) ?? const <String>[],
      featureFlagsVersion: _readNullableString(body['featureFlagsVersion']),
      unreadSummary: _readObjectMap(body['unreadSummary']),
    );
  }

  static OrganizationLeaveAcceptedView? _parseOrganizationLeaveAcceptedView(
    Object? payload,
  ) {
    if (payload is! Map) {
      return null;
    }

    final body = _map(payload);
    final leftOrganizationId = _readNullableString(body['leftOrganizationId']);
    final shellBootstrapState = _readNullableString(
      body['shellBootstrapState'],
    );
    final traceId = _readNullableString(body['traceId']);
    if (leftOrganizationId == null ||
        traceId == null ||
        (shellBootstrapState != 'authenticated' &&
            shellBootstrapState != 'no_organization')) {
      return null;
    }

    return OrganizationLeaveAcceptedView(
      leftOrganizationId: leftOrganizationId,
      nextOrganizationId: _readNullableString(body['nextOrganizationId']),
      shellBootstrapState: shellBootstrapState!,
      traceId: traceId,
    );
  }

  static Map<String, Object?> _map(Map payload) {
    return payload.map((Object? key, Object? value) => MapEntry('$key', value));
  }

  static List<String>? _readStringList(Object? value) {
    if (value is! List) {
      return null;
    }

    return value
        .whereType<String>()
        .map((String item) => item.trim())
        .where((String item) => item.isNotEmpty)
        .toList(growable: false);
  }

  static String? _readString(Object? value) {
    if (value is! String) {
      return null;
    }

    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static String? _readNullableString(Object? value) => _readString(value);

  static String? _trimNullable(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  static Map<String, Object?>? _readObjectMap(Object? raw) {
    if (raw is! Map) {
      return null;
    }

    return raw.map((Object? key, Object? value) => MapEntry('$key', value));
  }

  static AppProjectCreateEligibilityData? _readProjectCreateEligibility(
    Object? raw,
  ) {
    final map = _readObjectMap(raw);
    final value = map?['canCreateProject'];
    if (value is! bool) {
      return null;
    }
    return AppProjectCreateEligibilityData(canCreateProject: value);
  }

  static String? _extractErrorCode(Object? payload) {
    if (payload is! Map) {
      return null;
    }

    return _readString(payload['code']);
  }

  static String? _extractMessage(Object? payload) {
    if (payload is! Map) {
      return null;
    }

    return _readString(payload['message']);
  }
}
