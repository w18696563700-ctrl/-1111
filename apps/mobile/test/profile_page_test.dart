import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/auth/auth_consumer_layer.dart';
import 'package:mobile/core/boot/app_shell_context_consumer.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/core/config/config_manifest.dart';
import 'package:mobile/core/local_cache/local_cache_cleanup_service.dart';
import 'package:mobile/core/location/device_location_service.dart';
import 'package:mobile/core/runtime_info/app_runtime_info_service.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/forum_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_credit_constraints_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_governance_status_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_identity_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_organization_credit_scoring_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_membership_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_membership_purchase_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_payment_billing_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_personal_edit_upload_models.dart';
import 'package:mobile/features/profile/navigation/profile_identity_routes.dart';
import 'package:mobile/features/profile/navigation/profile_routes.dart';
import 'package:mobile/features/profile/presentation/profile_organization_capability_copy.dart';
import 'package:mobile/features/profile/presentation/profile_avatar_picker.dart';
import 'package:mobile/features/profile/presentation/profile_member_management_sheet.dart';
import 'package:mobile/shell/shell_app.dart';

Map<String, Object?> _profilePayload({
  String? organizationId,
  List<String> roleKeys = const <String>[],
  List<String> visibleBuildings = const <String>[
    'exhibition',
    'messages',
    'profile',
  ],
  String? certificationStatus,
  String? membershipStatus,
  String settingsState = 'visible',
}) {
  return <String, Object?>{
    'organization': <String, Object?>{
      'organizationId': organizationId,
      'roleKeys': roleKeys,
      'visibleBuildings': visibleBuildings,
    },
    'certification': <String, Object?>{'status': certificationStatus},
    'membership': <String, Object?>{'status': membershipStatus},
    'settingsEntry': <String, Object?>{'state': settingsState},
  };
}

final List<int> _tinyPngBytes = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIW2P8z/D/PwAHggJ/PF2uWQAAAABJRU5ErkJggg==',
);

Map<String, Object?> _shellContextPayload({
  String? organizationId,
  List<String> roleKeys = const <String>[],
  String? certificationStatus,
  String? membershipStatus,
  String? paidMembershipTier,
  List<String> paidMembershipEntitlementsSummary = const <String>[],
  List<String> paidMembershipQuotaSummary = const <String>[],
  String? paidMembershipNextRefreshAt,
  List<String> visibleBuildings = const <String>[
    'exhibition',
    'messages',
    'profile',
  ],
}) {
  return <String, Object?>{
    'userId': '13812345678',
    'organizationId': organizationId,
    'roleKeys': roleKeys,
    'certificationStatus': certificationStatus,
    'membershipStatus': membershipStatus,
    'paidMembershipTier': paidMembershipTier,
    'paidMembershipEntitlementsSummary': paidMembershipEntitlementsSummary,
    'paidMembershipQuotaSummary': paidMembershipQuotaSummary,
    'paidMembershipNextRefreshAt': paidMembershipNextRefreshAt,
    'visibleBuildings': visibleBuildings,
    'featureFlagsVersion': '0.1.0',
    'unreadSummary': <String, Object?>{'total': 0, 'system': 0, 'business': 0},
  };
}

AppShellContextData _shellContextData({
  String? organizationId,
  required List<String> roleKeys,
  String? certificationStatus,
  String? membershipStatus,
  String? paidMembershipTier,
  List<String> paidMembershipEntitlementsSummary = const <String>[],
  List<String> paidMembershipQuotaSummary = const <String>[],
  String? paidMembershipNextRefreshAt,
}) {
  return AppShellContextData(
    userId: '13812345678',
    organizationId: organizationId,
    roleKeys: roleKeys,
    certificationStatus: certificationStatus,
    membershipStatus: membershipStatus,
    paidMembershipTier: paidMembershipTier,
    paidMembershipEntitlementsSummary: paidMembershipEntitlementsSummary,
    paidMembershipQuotaSummary: paidMembershipQuotaSummary,
    paidMembershipNextRefreshAt: paidMembershipNextRefreshAt,
    visibleBuildings: const <String>['exhibition', 'messages', 'profile'],
  );
}

Map<String, Object?> _organizationItemPayload({
  required String organizationId,
  required String name,
  required String organizationType,
  required List<String> roleKeys,
  required String membershipStatus,
  required String certificationStatus,
  required bool current,
  String? provinceCode,
  String? cityCode,
  String? contactName,
  String? contactMobile,
  String? intro,
}) {
  return <String, Object?>{
    'organizationId': organizationId,
    'name': name,
    'organizationType': organizationType,
    'provinceCode': provinceCode,
    'cityCode': cityCode,
    'contactName': contactName,
    'contactMobile': contactMobile,
    'intro': intro,
    'roleKeys': roleKeys,
    'membershipStatus': membershipStatus,
    'certificationStatus': certificationStatus,
    'current': current,
  };
}

Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
_forumHandlers() {
  return <String, Future<AppApiResponse> Function(AppApiRequest request)>{
    'GET /api/app/forum/me/posts': (AppApiRequest request) async =>
        AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: <String, Object?>{
            'items': <Object?>[
              <String, Object?>{
                'postId': 'post-1',
                'topicId': 'topic-1',
                'topicTitle': '供应商交接模板',
                'excerpt': '我发布过的一条帖子摘要',
                'state': 'published',
                'author': <String, Object?>{
                  'authorId': 'member-1',
                  'displayName': '赵工',
                },
                'publishedAt': '2026-03-27T10:00:00Z',
              },
            ],
            'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
          },
        ),
    'GET /api/app/forum/me/comments': (AppApiRequest request) async =>
        AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: <String, Object?>{
            'items': <Object?>[
              <String, Object?>{
                'comment': <String, Object?>{
                  'commentId': 'comment-1',
                  'postId': 'post-1',
                  'parentCommentId': null,
                  'author': <String, Object?>{
                    'authorId': 'member-1',
                    'displayName': '赵工',
                  },
                  'body': '我的评论内容',
                  'state': 'published',
                  'publishedAt': '2026-03-27T11:00:00Z',
                  'replyCount': 1,
                },
                'postId': 'post-1',
                'postTitle': '供应商交接模板',
                'topicId': 'topic-1',
                'topicLabel': '材料协同',
              },
            ],
            'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
          },
        ),
    'GET /api/app/forum/me/bookmarks': (AppApiRequest request) async =>
        AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: <String, Object?>{
            'items': <Object?>[
              <String, Object?>{
                'postId': 'post-2',
                'topicId': 'topic-2',
                'topicTitle': '夜班排班经验',
                'excerpt': '收藏过的一条帖子摘要',
                'state': 'published',
                'author': <String, Object?>{
                  'authorId': 'member-2',
                  'displayName': '王监理',
                },
                'publishedAt': '2026-03-26T20:00:00Z',
              },
            ],
            'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
          },
        ),
    'GET /api/app/forum/me/follows': (AppApiRequest request) async =>
        AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: <String, Object?>{
            'items': <Object?>[
              <String, Object?>{
                'topicId': 'topic-3',
                'title': '上海布展进场窗口',
                'excerpt': '关注的话题摘要',
                'categoryKey': 'local',
                'state': 'published',
                'author': <String, Object?>{
                  'authorId': 'member-3',
                  'displayName': '陈设计',
                },
                'engagement': <String, Object?>{
                  'replyCount': 3,
                  'likeCount': 8,
                  'viewCount': 56,
                },
                'lastActiveAt': '2026-03-27T08:30:00Z',
                'highlightedPostId': 'post-3',
              },
            ],
            'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
          },
        ),
    'GET /api/app/forum/draft/list': (AppApiRequest request) async =>
        AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: <String, Object?>{
            'items': <Object?>[
              <String, Object?>{
                'draftId': 'draft-1',
                'draftType': 'topic',
                'topicId': 'topic-1',
                'title': '待发布草稿',
                'excerpt': '草稿摘要',
                'state': 'ready_to_publish',
                'updatedAt': '2026-03-27T12:00:00Z',
                'attachmentRefs': <Object?>[],
              },
            ],
            'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
          },
        ),
  };
}

ExhibitionMobileApp _buildProfileApp({
  required FakeAppApiTransport transport,
  String initialRoute = '/profile',
  FakeAppApiTransport? exhibitionTransport,
  FakeAppApiTransport? forumTransport,
  FakeAppApiTransport? governanceStatusTransport,
  FakeAppApiTransport? profileIdentityTransport,
  AuthConsumerLayer? authConsumerLayer,
  ProfileIdentityConsumerLayer? profileIdentityConsumerLayer,
  AppShellContextData? shellContext,
  AppShellContextConsumer? shellContextConsumer,
  AppSessionStore? sessionStore,
  bool establishSession = true,
  DeviceLocationService? deviceLocationService,
}) {
  final resolvedSessionStore = sessionStore ?? AppSessionStore();
  if (establishSession && !resolvedSessionStore.hasAnySession) {
    resolvedSessionStore.establishSession(
      accessToken: 'profile-test-access-token',
      refreshToken: 'profile-test-refresh-token',
      expiresInSeconds: 3600,
      deviceId: 'profile-test-device',
    );
  }

  return ExhibitionMobileApp(
    initialRoute: initialRoute,
    bootstrapShellContext: shellContext,
    shellContextConsumer: shellContextConsumer,
    exhibitionConsumerLayer: ExhibitionConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport:
            exhibitionTransport ??
            FakeAppApiTransport(
              handlers:
                  <
                    String,
                    Future<AppApiResponse> Function(AppApiRequest request)
                  >{
                    'GET /api/app/my/projects': (AppApiRequest request) async =>
                        AppApiResponse(
                          statusCode: 200,
                          uri: request.uri,
                          body: const <String, Object?>{
                            'ongoingProjects': <Object?>[],
                            'historicalProjects': <Object?>[],
                          },
                        ),
                  },
            ),
      ),
    ),
    profileConsumerLayer: ProfileConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: transport,
      ),
    ),
    authConsumerLayer: authConsumerLayer,
    forumConsumerLayer: ForumConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport:
            forumTransport ?? FakeAppApiTransport(handlers: _forumHandlers()),
      ),
    ),
    profileGovernanceStatusConsumerLayer: ProfileGovernanceStatusConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport:
            governanceStatusTransport ??
            FakeAppApiTransport(
              handlers:
                  <
                    String,
                    Future<AppApiResponse> Function(AppApiRequest request)
                  >{
                    'GET /api/app/profile/governance/status':
                        (AppApiRequest request) async => AppApiResponse(
                          statusCode: 404,
                          uri: request.uri,
                          body: const <String, Object?>{
                            'message': '当前累计分快照入口暂不可用。',
                            'code': 'PROFILE_GOVERNANCE_STATUS_UNAVAILABLE',
                          },
                        ),
                  },
            ),
      ),
    ),
    profileIdentityConsumerLayer:
        profileIdentityConsumerLayer ??
        ProfileIdentityConsumerLayer(
          client: AppApiClient(
            config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
            transport:
                profileIdentityTransport ??
                FakeAppApiTransport(handlers: const {}),
          ),
        ),
    sessionStore: resolvedSessionStore,
    deviceLocationService:
        deviceLocationService ?? _ProfileSettingsDeviceLocationService(),
  );
}

class _ProfileSettingsDeviceLocationService implements DeviceLocationService {
  _ProfileSettingsDeviceLocationService({
    this.permissionSnapshot = const DeviceLocationPermissionSnapshot(
      permissionState: DeviceLocationPermissionState.granted,
      serviceEnabled: true,
      message: '定位权限已开启。',
    ),
  });

  final DeviceLocationPermissionSnapshot permissionSnapshot;
  int permissionReadCount = 0;
  int appSettingsOpenCount = 0;
  int locationSettingsOpenCount = 0;
  int resolvePositionCount = 0;

  @override
  bool get supportsDeviceLocation => true;

  @override
  bool get supportsReverseGeocoding => false;

  @override
  Future<DeviceLocationPermissionSnapshot> readPermissionStatus() async {
    permissionReadCount += 1;
    return permissionSnapshot;
  }

  @override
  Future<bool> openAppPermissionSettings() async {
    appSettingsOpenCount += 1;
    return true;
  }

  @override
  Future<bool> openSystemLocationSettings() async {
    locationSettingsOpenCount += 1;
    return true;
  }

  @override
  Future<DeviceLocationSnapshot> resolveCurrentPosition() async {
    resolvePositionCount += 1;
    return DeviceLocationSnapshot(
      permissionState: permissionSnapshot.permissionState,
      errorMessage: permissionSnapshot.message,
    );
  }
}

class _FakeAppRuntimeInfoService extends AppRuntimeInfoService {
  static const AppRuntimeInfo _info = AppRuntimeInfo(
    appName: '展览装修之家',
    packageName: 'mobile',
    version: '1.2.3',
    buildNumber: '45',
    environmentLabel: 'SSH隧道',
    entryModeLabel: 'ssh_tunnel',
    apiBaseSummary: '127.0.0.1:8080/api/app',
    debugModeLabel: 'debug',
  );

  int loadCount = 0;

  @override
  Future<AppRuntimeInfo> load() async {
    loadCount += 1;
    return _info;
  }
}

class _FakeLocalCacheCleanupService extends LocalCacheCleanupService {
  static const LocalCacheCleanupResult _result = LocalCacheCleanupResult(
    imageCacheCleared: true,
    deletedTemporaryFiles: 2,
    failedTemporaryFiles: 0,
  );

  int clearCount = 0;

  @override
  Future<LocalCacheCleanupResult> clearSafeLocalCache() async {
    clearCount += 1;
    return _result;
  }
}

class _FakeOrganizationMembersConsumer implements ProfileIdentityConsumerLayer {
  _FakeOrganizationMembersConsumer({
    required this.organizationsLoader,
    required this.certificationLoader,
    required this.membersLoader,
    required this.rolePatcher,
    required this.memberDisabler,
    this.organizationUpdater,
  });

  final Future<ProfileIdentityResult<MyOrganizationsView>> Function()
  organizationsLoader;
  final Future<ProfileIdentityResult<ProfileCertificationCurrentView>>
  Function()
  certificationLoader;
  final Future<ProfileIdentityResult<OrganizationMembersView>> Function()
  membersLoader;
  final Future<ProfileIdentityResult<ProfileActionAckView>> Function(
    String memberId,
    String roleKey,
  )
  rolePatcher;
  final Future<ProfileIdentityResult<ProfileActionAckView>> Function(
    String memberId,
  )
  memberDisabler;
  final Future<ProfileIdentityResult<ProfileActionAckView>> Function(
    String name,
    String provinceCode,
    String cityCode,
    String contactName,
    String contactMobile,
    String? intro,
  )?
  organizationUpdater;

  @override
  Future<ProfileIdentityResult<MyOrganizationsView>> loadMyOrganizations() {
    return organizationsLoader();
  }

  @override
  Future<ProfileIdentityResult<ProfileCertificationCurrentView>>
  loadCertificationCurrent() {
    return certificationLoader();
  }

  @override
  Future<ProfileIdentityResult<OrganizationMembersView>>
  loadOrganizationMembers() {
    return membersLoader();
  }

  @override
  Future<ProfileIdentityResult<ProfileActionAckView>>
  patchOrganizationMemberRole({
    required String memberId,
    required String roleKey,
    String? reason,
  }) {
    return rolePatcher(memberId, roleKey);
  }

  @override
  Future<ProfileIdentityResult<ProfileActionAckView>>
  disableOrganizationMember({required String memberId, String? reason}) {
    return memberDisabler(memberId);
  }

  @override
  Future<ProfileIdentityResult<ProfileOrganizationCreateView>>
  createOrganization({
    required String name,
    required String organizationType,
    required String provinceCode,
    required String cityCode,
    required String contactName,
    required String contactMobile,
  }) => throw UnimplementedError();

  @override
  Future<ProfileIdentityResult<ProfileActionAckView>>
  updateCurrentOrganization({
    required String name,
    required String provinceCode,
    required String cityCode,
    required String contactName,
    required String contactMobile,
    String? intro,
  }) {
    final handler = organizationUpdater;
    if (handler == null) {
      throw UnimplementedError();
    }
    return handler(
      name,
      provinceCode,
      cityCode,
      contactName,
      contactMobile,
      intro,
    );
  }

  @override
  Future<ProfileIdentityResult<ProfileOrganizationJoinAcceptedView>>
  joinByCode({required String inviteCode}) => throw UnimplementedError();

  @override
  Future<ProfileIdentityResult<AppShellContextData>> switchOrganization({
    required String organizationId,
  }) => throw UnimplementedError();

  @override
  Future<ProfileIdentityResult<OrganizationLeaveAcceptedView>>
  leaveCurrentOrganization({String? reason}) => throw UnimplementedError();

  @override
  Future<ProfileIdentityResult<ProfileCertificationAcceptedView>>
  submitCertification({
    required String organizationId,
    required String legalName,
    required String uscc,
    required String fileAssetId,
    String? contactName,
    String? contactMobile,
  }) => throw UnimplementedError();

  @override
  Future<ProfileIdentityResult<ProfileCertificationAcceptedView>>
  revalidateCertification({
    required String organizationId,
    required String legalName,
    required String uscc,
    required String fileAssetId,
    String? correctionNote,
  }) => throw UnimplementedError();

  @override
  Future<ProfileIdentityResult<ProfileCertificationAcceptedView>>
  resubmitCertification({
    required String organizationId,
    required String legalName,
    required String uscc,
    required String fileAssetId,
    String? supplementNote,
  }) => throw UnimplementedError();

  @override
  Future<ProfilePersonalAvatarUploadResult> initCertificationLicenseUpload({
    required String? organizationId,
    required String mimeType,
    required List<int> bodyBytes,
  }) => throw UnimplementedError();

  @override
  Future<ProfileIdentityResult<CertificationLicenseOcrView>>
  recognizeCertificationLicense({
    required String organizationId,
    required String fileAssetId,
  }) => throw UnimplementedError();

  @override
  Future<ProfileIdentityResult<PersonalCertificationIdCardOcrView>>
  recognizePersonalCertificationIdCard({
    required String organizationId,
    required String fileAssetId,
  }) => throw UnimplementedError();

  @override
  Future<ProfileIdentityResult<PersonalCertificationAcceptedView>>
  submitPersonalCertification({
    required String organizationId,
    required String fileAssetId,
  }) => throw UnimplementedError();

  @override
  Future<ProfilePersonalAvatarUploadResult> directCertificationLicenseUpload({
    required ProfilePersonalAvatarUploadDirective directive,
    required List<int> bodyBytes,
  }) => throw UnimplementedError();

  @override
  Future<ProfilePersonalAvatarUploadResult> confirmCertificationLicenseUpload({
    required ProfilePersonalAvatarUploadDirective directive,
  }) => throw UnimplementedError();

  @override
  Future<ProfilePersonalAvatarUploadResult>
  initPersonalCertificationIdCardUpload({
    required String? organizationId,
    required String mimeType,
    required List<int> bodyBytes,
  }) => throw UnimplementedError();

  @override
  Future<ProfilePersonalAvatarUploadResult>
  directPersonalCertificationIdCardUpload({
    required ProfilePersonalAvatarUploadDirective directive,
    required List<int> bodyBytes,
  }) => throw UnimplementedError();

  @override
  Future<ProfilePersonalAvatarUploadResult>
  confirmPersonalCertificationIdCardUpload({
    required ProfilePersonalAvatarUploadDirective directive,
  }) => throw UnimplementedError();

  @override
  Future<ProfileIdentityResult<SecurityDevicesView>> loadSecurityDevices() =>
      throw UnimplementedError();

  @override
  Future<ProfileIdentityResult<ProfileActionAckView>> revokeSecurityDevice({
    required String deviceId,
  }) => throw UnimplementedError();
}

void main() {
  HttpOverrides? previousHttpOverrides;

  test(
    'organization capability copy separates subject ability from current role',
    () {
      expect(
        profileDisplayOrganizationCapabilitySummary(
          'both',
          roleKeys: const <String>['supplier_admin'],
        ),
        '主体支持发布项目 / 参与竞标；当前角色偏供应商，发布项目需切到买方侧',
      );
      expect(
        profileDisplayOrganizationCapabilitySummary(
          'both',
          roleKeys: const <String>['buyer_admin'],
        ),
        '当前角色可发布项目；主体也可参与竞标',
      );
    },
  );

  setUp(() {
    previousHttpOverrides = HttpOverrides.current;
    HttpOverrides.global = _PassthroughHttpOverrides();
    ProfileAvatarPicker.reset();
    ProfileCreditConstraintsConsumerLayer.install(
      ProfileCreditConstraintsConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/profile/credit-and-constraints/status':
                      (AppApiRequest request) async {
                        return AppApiResponse(
                          statusCode: 404,
                          uri: request.uri,
                          body: const <String, Object?>{
                            'message': '当前信用与约束入口暂不可用，请稍后再试。',
                            'code': 'CREDIT_AND_CONSTRAINTS_ROUTE_UNAVAILABLE',
                          },
                        );
                      },
                  'GET /api/app/profile/credit-and-constraints/explanation':
                      (AppApiRequest request) async {
                        return AppApiResponse(
                          statusCode: 404,
                          uri: request.uri,
                          body: const <String, Object?>{
                            'message': '当前信用与约束说明暂不可用，请稍后再试。',
                            'code': 'CREDIT_AND_CONSTRAINTS_ROUTE_UNAVAILABLE',
                          },
                        );
                      },
                  'GET /api/app/profile/credit-and-constraints/handoff':
                      (AppApiRequest request) async {
                        return AppApiResponse(
                          statusCode: 404,
                          uri: request.uri,
                          body: const <String, Object?>{
                            'message': '当前信用与约束引导暂不可用，请稍后再试。',
                            'code': 'CREDIT_AND_CONSTRAINTS_ROUTE_UNAVAILABLE',
                          },
                        );
                      },
                },
          ),
        ),
      ),
    );
    ProfilePaymentBillingConsumerLayer.install(
      ProfilePaymentBillingConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/profile/payment-and-billing-status/status':
                      (AppApiRequest request) async {
                        return AppApiResponse(
                          statusCode: 404,
                          uri: request.uri,
                          body: const <String, Object?>{
                            'message': '当前支付与账单入口暂不可用，请稍后再试。',
                            'code':
                                'PAYMENT_AND_BILLING_STATUS_ROUTE_UNAVAILABLE',
                          },
                        );
                      },
                },
          ),
        ),
      ),
    );
    ProfileOrganizationCreditScoringConsumerLayer.reset();
    ProfileMembershipConsumerLayer.reset();
    ProfileMembershipPurchaseConsumerLayer.reset();
    AppRuntimeInfoService.install(_FakeAppRuntimeInfoService());
    LocalCacheCleanupService.install(_FakeLocalCacheCleanupService());
  });

  tearDown(() {
    HttpOverrides.global = previousHttpOverrides;
    ProfileAvatarPicker.reset();
    ProfileCreditConstraintsConsumerLayer.reset();
    ProfilePaymentBillingConsumerLayer.reset();
    ProfileOrganizationCreditScoringConsumerLayer.reset();
    ProfileMembershipConsumerLayer.reset();
    ProfileMembershipPurchaseConsumerLayer.reset();
    AppRuntimeInfoService.reset();
    LocalCacheCleanupService.reset();
  });

  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'profile page loads followed authors without generic cast crash',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/index': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _profilePayload(
                    organizationId: 'org-1',
                    certificationStatus: 'approved',
                    membershipStatus: 'active',
                  ),
                );
              },
            },
      );
      final forumHandlers = _forumHandlers();
      forumHandlers['GET /api/app/forum/me/follows'] =
          (AppApiRequest request) async {
            return AppApiResponse(
              statusCode: 200,
              uri: request.uri,
              body: const <String, Object?>{
                'items': <Object?>[
                  <String, Object?>{
                    'authorId': 'author-1',
                    'displayName': '陈设计',
                    'organizationName': '重庆海川展览工厂',
                    'followedAt': '2026-04-28T09:00:00Z',
                    'publicPostCount': 3,
                    'publicCommentCount': 5,
                    'viewerFollowsAuthor': true,
                  },
                ],
                'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
              },
            );
          };

      await tester.pumpWidget(
        _buildProfileApp(
          transport: transport,
          forumTransport: FakeAppApiTransport(handlers: forumHandlers),
          shellContext: AppShellContextData(
            userId: '13812345678',
            organizationId: 'org-1',
            certificationStatus: 'approved',
            membershipStatus: 'active',
            visibleBuildings: const <String>[
              'exhibition',
              'messages',
              'profile',
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('我的论坛'), findsOneWidget);
    },
  );

  testWidgets('profile page presents compact grouped hub', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/profile/index': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _profilePayload(
                  organizationId: 'org-1',
                  certificationStatus: 'approved',
                  membershipStatus: 'active',
                ),
              );
            },
          },
    );
    final exhibitionTransport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/my/projects': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: const <String, Object?>{
                  'ongoingProjects': <Object?>[
                    <String, Object?>{
                      'publicProject': <String, Object?>{
                        'projectId': 'my-project-1',
                        'projectNo': 'MY-001',
                        'title': '当前组织项目',
                        'buildingType': 'exhibition',
                        'budgetAmount': 1800,
                        'state': 'published',
                        'summary': <String, Object?>{'heading': '当前项目摘要'},
                      },
                      'privateSummary': <String, Object?>{
                        'hasAcceptedOrder': false,
                        'orderStatus': null,
                        'contractStatus': null,
                        'fulfillmentStatus': null,
                        'acceptanceStatus': null,
                        'afterSalesOrDisputeStatus': null,
                        'formalCompletionStatus': 'not_formally_completed',
                        'evaluationStatus': 'not_eligible',
                      },
                    },
                  ],
                  'historicalProjects': <Object?>[
                    <String, Object?>{
                      'publicProject': <String, Object?>{
                        'projectId': 'my-project-2',
                        'projectNo': 'MY-002',
                        'title': '历史项目一',
                        'buildingType': 'exhibition',
                        'budgetAmount': 2200,
                        'state': 'converted_to_order',
                        'summary': <String, Object?>{'heading': '历史摘要一'},
                      },
                      'privateSummary': <String, Object?>{
                        'hasAcceptedOrder': true,
                        'orderStatus': null,
                        'contractStatus': null,
                        'fulfillmentStatus': null,
                        'acceptanceStatus': null,
                        'afterSalesOrDisputeStatus': null,
                        'formalCompletionStatus': 'formally_completed',
                        'evaluationStatus': 'submitted',
                      },
                    },
                    <String, Object?>{
                      'publicProject': <String, Object?>{
                        'projectId': 'my-project-3',
                        'projectNo': 'MY-003',
                        'title': '历史项目二',
                        'buildingType': 'exhibition',
                        'budgetAmount': 2600,
                        'state': 'converted_to_order',
                        'summary': <String, Object?>{'heading': '历史摘要二'},
                      },
                      'privateSummary': <String, Object?>{
                        'hasAcceptedOrder': true,
                        'orderStatus': null,
                        'contractStatus': null,
                        'fulfillmentStatus': null,
                        'acceptanceStatus': null,
                        'afterSalesOrDisputeStatus': null,
                        'formalCompletionStatus': 'formally_completed',
                        'evaluationStatus': 'submitted',
                      },
                    },
                  ],
                },
              );
            },
          },
    );

    await tester.pumpWidget(
      _buildProfileApp(
        transport: transport,
        exhibitionTransport: exhibitionTransport,
        shellContext: AppShellContextData(
          userId: '13812345678',
          organizationId: 'org-1',
          certificationStatus: 'approved',
          membershipStatus: 'active',
          paidMembershipTier: 'standard',
          paidMembershipEntitlementsSummary: const <String>['更高排序'],
          paidMembershipQuotaSummary: const <String>['商机提醒剩余 12 次'],
          paidMembershipNextRefreshAt: '2026-04-06 00:00',
          visibleBuildings: const <String>['exhibition', 'messages', 'profile'],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      transport.requests.single.canonicalPath,
      ProfileCanonicalPaths.profileIndex,
    );
    expect(find.text('常用入口'), findsOneWidget);
    await scrollTo(tester, find.text('我的公司'));
    expect(find.text('我的公司'), findsWidgets);
    await scrollTo(tester, find.text('我的会员'));
    expect(find.text('我的会员'), findsOneWidget);
    expect(find.textContaining('当前付费会员档位与权益摘要'), findsNothing);
    await scrollTo(tester, find.text('我的项目'));
    expect(find.text('当前组织项目列表与项目详情入口 · 进行中 1 个 · 历史 2 个'), findsOneWidget);
    expect(find.text('发布项目工作台'), findsNothing);
    await scrollTo(tester, find.text('我的论坛'));
    expect(find.text('我的论坛'), findsOneWidget);
    await scrollTo(tester, find.text('设置').last);
    expect(find.text('设置'), findsWidgets);
    expect(find.text('身份与设置'), findsNothing);
    expect(find.text('论坛资产'), findsNothing);
    expect(find.text('我的帖子'), findsNothing);
    expect(find.text('草稿箱'), findsNothing);
    expect(find.text('论坛资产管理'), findsNothing);
  });

  testWidgets(
    'profile hub routes to profile, forum, company and settings pages',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/index': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _profilePayload(
                    organizationId: 'org-profile',
                    roleKeys: const <String>['buyer_admin'],
                    certificationStatus: 'approved',
                    membershipStatus: 'active',
                  ),
                );
              },
            },
      );
      final profileIdentityTransport = FakeAppApiTransport(
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
                            'organizationId': 'org-profile',
                            'name': '上海展建服务有限公司',
                            'organizationType': 'supplier',
                            'roleKeys': <Object?>['buyer_admin'],
                            'membershipStatus': 'active',
                            'certificationStatus': 'approved',
                            'current': true,
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
                        'organizationId': 'org-profile',
                        'certificationStatus': 'approved',
                        'legalName': '上海展建服务有限公司',
                        'uscc': '91310000123456789A',
                        'submittedAt': '2026-03-27 10:00',
                        'expiresAt': '2027-03-27',
                      },
                    );
                  },
            },
      );

      await tester.pumpWidget(
        _buildProfileApp(
          transport: transport,
          profileIdentityTransport: profileIdentityTransport,
          shellContext: AppShellContextData(
            userId: '13812345678',
            organizationId: 'org-profile',
            roleKeys: const <String>['buyer_admin'],
            certificationStatus: 'approved',
            membershipStatus: 'active',
            visibleBuildings: const <String>[
              'exhibition',
              'messages',
              'profile',
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('138****5678').first);
      await tester.pumpAndSettle();
      await scrollTo(tester, find.text('当前账号'));
      expect(find.text('当前账号'), findsOneWidget);
      expect(find.text('拍一拍'), findsNothing);
      expect(find.text('来电铃声'), findsNothing);
      expect(find.text('我的发票抬头'), findsNothing);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('我的论坛'));
      await tester.tap(find.text('我的论坛').first);
      await tester.pumpAndSettle();
      await scrollTo(tester, find.text('论坛资产'));
      expect(find.text('论坛资产'), findsOneWidget);
      expect(find.text('我的帖子'), findsOneWidget);
      expect(find.text('我的评论'), findsOneWidget);
      expect(find.text('我的收藏'), findsOneWidget);
      expect(find.text('我的点赞'), findsOneWidget);
      expect(find.text('我的关注'), findsOneWidget);
      await scrollTo(tester, find.text('草稿箱'));
      expect(find.text('草稿箱'), findsOneWidget);
      await scrollTo(tester, find.text('我的举报记录'));
      expect(find.text('我的举报记录'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('我的公司'));
      await tester.tap(find.text('我的公司').first);
      await tester.pumpAndSettle();
      await scrollTo(tester, find.text('可进行的操作'));
      expect(find.text('可进行的操作'), findsOneWidget);
      expect(find.text('公司与组织'), findsWidgets);
      expect(find.text('编辑当前组织'), findsNothing);
      expect(find.text('再创建一个组织'), findsNothing);
      expect(find.text('加入组织'), findsNothing);
      expect(find.text('成员管理'), findsNothing);
      expect(find.text('切换当前公司/组织'), findsNothing);
      expect(find.text('认证与身份'), findsNothing);
      expect(find.text('公司认证与我的身份'), findsWidgets);
      final organizationAction = tester.widget<ListTile>(
        find.byKey(
          const ValueKey<String>('profile-company-action-organization'),
        ),
      );
      final certificationAction = tester.widget<ListTile>(
        find.byKey(
          const ValueKey<String>('profile-company-action-certification'),
        ),
      );
      expect(organizationAction.tileColor, isNotNull);
      expect(certificationAction.tileColor, isNotNull);
      expect(find.widgetWithText(FilledButton, '提交认证'), findsNothing);
      expect(find.widgetWithText(FilledButton, '重新提交认证'), findsNothing);
      expect(find.text('当前认证已通过，可查看成员身份与当前组织状态'), findsOneWidget);
      expect(find.text('功能状态'), findsNothing);
      expect(find.text('当前公司/组织现状'), findsNothing);
      expect(find.text('认证资料'), findsNothing);
      expect(find.text('公司名称'), findsNothing);

      await tester.pageBack();
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('账号与安全、通知、隐私与权限等'));
      await tester.tap(find.text('账号与安全、通知、隐私与权限等'));
      await tester.pumpAndSettle();
      await scrollTo(tester, find.text('账号与安全'));
      expect(find.text('账号与安全'), findsOneWidget);
      expect(find.text('通知'), findsOneWidget);
      await scrollTo(tester, find.text('关于我们'));
      expect(find.text('关于我们'), findsOneWidget);
    },
  );

  testWidgets(
    'personal page shows bounded governance score snapshot from governance status only',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/index': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _profilePayload(
                    organizationId: 'org-1',
                    certificationStatus: 'approved',
                    membershipStatus: 'active',
                  ),
                );
              },
            },
      );
      final governanceStatusTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/governance/status':
                  (AppApiRequest request) async => AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'violationScoreSnapshot': 6,
                      'violationScoreUpdatedAt': '2026-04-08T10:30:00Z',
                    },
                  ),
            },
      );

      await tester.pumpWidget(
        _buildProfileApp(
          transport: transport,
          governanceStatusTransport: governanceStatusTransport,
          initialRoute: ProfileRoutes.personal,
          shellContext: AppShellContextData(
            userId: '13812345678',
            organizationId: 'org-1',
            roleKeys: const <String>['buyer_admin'],
            certificationStatus: 'approved',
            membershipStatus: 'active',
            visibleBuildings: const <String>[
              'exhibition',
              'messages',
              'profile',
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      await scrollTo(tester, find.text('治理记录'));

      expect(find.text('治理记录'), findsOneWidget);
      expect(find.text('累计分快照'), findsOneWidget);
      expect(find.textContaining('这是基于已生效处罚记录生成的累计分快照'), findsOneWidget);
      expect(find.textContaining('分值：6'), findsOneWidget);
      expect(find.textContaining('更新时间：'), findsOneWidget);
      expect(
        governanceStatusTransport.requests
            .map((AppApiRequest request) => request.canonicalPath)
            .toList(),
        const <String>['/api/app/profile/governance/status'],
      );
    },
  );

  testWidgets(
    'personal page keeps governance score snapshot hidden when route is unavailable',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/index': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _profilePayload(
                    organizationId: 'org-1',
                    certificationStatus: 'approved',
                    membershipStatus: 'active',
                  ),
                );
              },
            },
      );
      final governanceStatusTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/governance/status':
                  (AppApiRequest request) async => AppApiResponse(
                    statusCode: 404,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'message': '当前累计分快照入口暂不可用。',
                      'code': 'PROFILE_GOVERNANCE_STATUS_UNAVAILABLE',
                    },
                  ),
            },
      );

      await tester.pumpWidget(
        _buildProfileApp(
          transport: transport,
          governanceStatusTransport: governanceStatusTransport,
          initialRoute: ProfileRoutes.personal,
          shellContext: AppShellContextData(
            userId: '13812345678',
            organizationId: 'org-1',
            roleKeys: const <String>['buyer_admin'],
            certificationStatus: 'approved',
            membershipStatus: 'active',
            visibleBuildings: const <String>[
              'exhibition',
              'messages',
              'profile',
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      await scrollTo(tester, find.text('治理记录'));

      expect(find.text('治理记录'), findsOneWidget);
      expect(find.text('我的申诉记录'), findsOneWidget);
      expect(find.text('累计分快照'), findsNothing);
      expect(
        governanceStatusTransport.requests
            .map((AppApiRequest request) => request.canonicalPath)
            .toList(),
        const <String>['/api/app/profile/governance/status'],
      );
    },
  );

  testWidgets('settings page shows switch account and logout after login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildProfileApp(
        transport: FakeAppApiTransport(handlers: const {}),
        initialRoute: ProfileRoutes.settings,
        shellContext: AppShellContextData(
          userId: '13812345678',
          organizationId: 'org-1',
          certificationStatus: 'approved',
          membershipStatus: 'active',
          visibleBuildings: const <String>['exhibition', 'messages', 'profile'],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('当前账号：138****5678'), findsOneWidget);

    await scrollTo(tester, find.text('账号与安全'));

    expect(find.text('切换账号'), findsOneWidget);
    expect(find.text('退出登录'), findsOneWidget);
    expect(find.text('登录入口'), findsNothing);
  });

  testWidgets('settings auth actions require confirmation before logout', (
    WidgetTester tester,
  ) async {
    final authTransport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'POST /api/app/auth/logout': (AppApiRequest request) async =>
                AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'ok': true,
                    'traceId': 'logout-confirmation',
                  },
                ),
          },
    );

    await tester.pumpWidget(
      _buildProfileApp(
        transport: FakeAppApiTransport(handlers: const {}),
        authConsumerLayer: AuthConsumerLayer(
          client: AppApiClient(
            config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
            transport: authTransport,
          ),
        ),
        initialRoute: ProfileRoutes.settings,
        shellContext: AppShellContextData(
          userId: '13812345678',
          organizationId: 'org-1',
          certificationStatus: 'approved',
          membershipStatus: 'active',
          visibleBuildings: const <String>['exhibition', 'messages', 'profile'],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('切换账号'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, '退出并登录其他账号'), findsOneWidget);
    expect(authTransport.requests, isEmpty);

    await tester.tap(find.widgetWithText(TextButton, '取消'));
    await tester.pumpAndSettle();

    expect(authTransport.requests, isEmpty);

    await tester.tap(find.text('退出登录'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, '退出登录'), findsOneWidget);
    expect(authTransport.requests, isEmpty);

    await tester.tap(find.widgetWithText(TextButton, '取消'));
    await tester.pumpAndSettle();

    expect(authTransport.requests, isEmpty);
    expect(AppSessionStore.instance.hasAnySession, isTrue);
  });

  testWidgets('settings p1 certification identity opens status-only page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildProfileApp(
        transport: FakeAppApiTransport(handlers: const {}),
        initialRoute: ProfileRoutes.settings,
        shellContext: AppShellContextData(
          userId: '13812345678',
          organizationId: 'org-1',
          certificationStatus: 'approved',
          personalCertificationStatus: 'approved',
          personalCertificationQualified: true,
          membershipStatus: 'active',
          visibleBuildings: const <String>['exhibition', 'messages', 'profile'],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await scrollTo(tester, find.text('公司认证与我的身份'));
    expect(find.text('企业已认证 · 我的认证已通过 · 已开通'), findsOneWidget);

    await tester.tap(find.text('公司认证与我的身份'));
    await tester.pumpAndSettle();

    expect(find.text('当前只展示状态，不在设置页展开认证办理'), findsOneWidget);
    expect(find.text('企业认证'), findsOneWidget);
    expect(find.text('已认证'), findsOneWidget);
    expect(find.text('本轮边界'), findsOneWidget);
    expect(find.textContaining('设置页不展开认证提交'), findsOneWidget);
    expect(find.text('认证办理'), findsNothing);
  });

  testWidgets('settings p1 session page stays current-device only', (
    WidgetTester tester,
  ) async {
    final profileIdentityTransport = FakeAppApiTransport(handlers: const {});
    final sessionStore = AppSessionStore();
    sessionStore.establishSession(
      accessToken: 'profile-test-access-token',
      refreshToken: 'profile-test-refresh-token',
      expiresInSeconds: 7200,
      deviceId: 'profile-test-device',
      localLoginSource: AppSessionLoginSource.passwordLogin,
    );

    await tester.pumpWidget(
      _buildProfileApp(
        transport: FakeAppApiTransport(handlers: const {}),
        profileIdentityTransport: profileIdentityTransport,
        sessionStore: sessionStore,
        initialRoute: ProfileRoutes.settings,
        shellContext: AppShellContextData(
          userId: '13812345678',
          organizationId: 'org-1',
          certificationStatus: 'approved',
          membershipStatus: 'active',
          visibleBuildings: const <String>['exhibition', 'messages', 'profile'],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await scrollTo(tester, find.text('会话与设备'));
    expect(find.text('账号密码登录 · 当前设备已建立'), findsOneWidget);

    await tester.tap(find.text('会话与设备'));
    await tester.pumpAndSettle();

    expect(find.text('当前仅展示本机登录状态'), findsOneWidget);
    expect(find.text('profile-test-device'), findsNothing);
    expect(find.text('profil…vice'), findsOneWidget);
    expect(find.text('登录凭证'), findsOneWidget);
    expect(find.text('续期状态'), findsOneWidget);
    await scrollTo(tester, find.text('其他设备'));
    expect(find.text('其他设备'), findsOneWidget);
    expect(find.text('暂不展示。'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '撤销此设备'), findsNothing);
    expect(profileIdentityTransport.requests, isEmpty);
  });

  testWidgets('settings p1 cache cleanup requires confirmation', (
    WidgetTester tester,
  ) async {
    final cleanupService = _FakeLocalCacheCleanupService();
    LocalCacheCleanupService.install(cleanupService);

    await tester.pumpWidget(
      _buildProfileApp(
        transport: FakeAppApiTransport(handlers: const {}),
        initialRoute: ProfileRoutes.settings,
        shellContext: AppShellContextData(
          userId: '13812345678',
          organizationId: 'org-1',
          certificationStatus: 'approved',
          membershipStatus: 'active',
          visibleBuildings: const <String>['exhibition', 'messages', 'profile'],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await scrollTo(tester, find.text('清理缓存'));
    await tester.tap(find.text('清理缓存'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, '确认清理'), findsOneWidget);
    expect(cleanupService.clearCount, 0);

    await tester.tap(find.widgetWithText(TextButton, '取消'));
    await tester.pumpAndSettle();
    expect(cleanupService.clearCount, 0);

    await tester.tap(find.text('清理缓存'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '确认清理'));
    await tester.pumpAndSettle();

    expect(cleanupService.clearCount, 1);
    expect(find.textContaining('已清理图片缓存和 2 个临时预览文件'), findsOneWidget);
    expect(AppSessionStore.instance.hasAnySession, isTrue);
  });

  testWidgets('settings p1 version page shows runtime info', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildProfileApp(
        transport: FakeAppApiTransport(handlers: const {}),
        initialRoute: ProfileRoutes.settings,
        shellContext: AppShellContextData(
          userId: '13812345678',
          organizationId: 'org-1',
          certificationStatus: 'approved',
          membershipStatus: 'active',
          visibleBuildings: const <String>['exhibition', 'messages', 'profile'],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await scrollTo(tester, find.text('当前版本'));
    expect(find.text('1.2.3+45 · SSH隧道'), findsOneWidget);

    await tester.tap(find.text('当前版本'));
    await tester.pumpAndSettle();

    expect(find.text('查看当前应用版本与运行入口'), findsOneWidget);
    expect(find.text('版本号'), findsOneWidget);
    expect(find.text('1.2.3'), findsOneWidget);
    expect(find.text('构建号'), findsOneWidget);
    expect(find.text('45'), findsOneWidget);
    await scrollTo(tester, find.text('API 入口'));
    expect(find.text('API 入口'), findsOneWidget);
    expect(find.text('127.0.0.1:8080/api/app'), findsOneWidget);
  });

  testWidgets('settings page shows logged out state from local session', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildProfileApp(
        transport: FakeAppApiTransport(handlers: const {}),
        initialRoute: ProfileRoutes.settings,
        establishSession: false,
        shellContext: AppShellContextData(
          userId: '13812345678',
          organizationId: 'org-1',
          certificationStatus: 'approved',
          membershipStatus: 'active',
          visibleBuildings: const <String>['exhibition', 'messages', 'profile'],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('当前账号：未登录'), findsOneWidget);
    expect(find.text('当前账号：138****5678'), findsNothing);
    expect(find.text('登录入口'), findsOneWidget);
    expect(find.text('退出登录'), findsNothing);
  });

  testWidgets('switch account logs out and routes to login page', (
    WidgetTester tester,
  ) async {
    final authTransport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'POST /api/app/auth/logout': (AppApiRequest request) async =>
                AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'ok': true,
                    'traceId': 'logout-1',
                  },
                ),
          },
    );

    await tester.pumpWidget(
      _buildProfileApp(
        transport: FakeAppApiTransport(handlers: const {}),
        authConsumerLayer: AuthConsumerLayer(
          client: AppApiClient(
            config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
            transport: authTransport,
          ),
        ),
        initialRoute: ProfileRoutes.settings,
        shellContext: AppShellContextData(
          userId: '13812345678',
          organizationId: 'org-1',
          certificationStatus: 'approved',
          membershipStatus: 'active',
          visibleBuildings: const <String>['exhibition', 'messages', 'profile'],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('切换账号'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('退出并登录其他账号'));
    await tester.pumpAndSettle();

    expect(
      authTransport.requests
          .map((AppApiRequest request) => request.canonicalPath)
          .toList(),
      const <String>[AuthCanonicalPaths.logout],
    );
    expect(AppSessionStore.instance.hasAnySession, isFalse);
    expect(find.widgetWithText(TextButton, '发送验证码'), findsOneWidget);
  });

  testWidgets('logout treats unauthorized as local logout completion', (
    WidgetTester tester,
  ) async {
    final authTransport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'POST /api/app/auth/logout': (AppApiRequest request) async =>
                AppApiResponse(
                  statusCode: 401,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'message': '当前登录态不可用，请重新登录或刷新后再试。',
                    'code': 'AUTH_SESSION_INVALID',
                  },
                ),
          },
    );

    await tester.pumpWidget(
      _buildProfileApp(
        transport: FakeAppApiTransport(handlers: const {}),
        authConsumerLayer: AuthConsumerLayer(
          client: AppApiClient(
            config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
            transport: authTransport,
          ),
        ),
        initialRoute: ProfileRoutes.settings,
        shellContext: AppShellContextData(
          userId: '13812345678',
          organizationId: 'org-1',
          certificationStatus: 'approved',
          membershipStatus: 'active',
          visibleBuildings: const <String>['exhibition', 'messages', 'profile'],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('退出登录'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '退出登录'));
    await tester.pumpAndSettle();

    expect(
      authTransport.requests
          .map((AppApiRequest request) => request.canonicalPath)
          .toList(),
      const <String>[AuthCanonicalPaths.logout],
    );
    expect(AppSessionStore.instance.hasAnySession, isFalse);
    expect(find.text('当前账号：138****5678'), findsNothing);
  });

  testWidgets('settings page opens privacy permissions and legal documents', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildProfileApp(
        transport: FakeAppApiTransport(handlers: const {}),
        initialRoute: ProfileRoutes.settings,
        deviceLocationService: _ProfileSettingsDeviceLocationService(),
        shellContext: AppShellContextData(
          userId: '13812345678',
          organizationId: 'org-1',
          certificationStatus: 'approved',
          membershipStatus: 'active',
          visibleBuildings: const <String>['exhibition', 'messages', 'profile'],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('当前保持受控开放'), findsNothing);
    await scrollTo(tester, find.text('隐私与权限说明'));
    await tester.tap(find.text('隐私与权限说明'));
    await tester.pumpAndSettle();

    expect(find.text('隐私与权限说明'), findsWidgets);
    expect(find.text('用户协议'), findsOneWidget);
    expect(find.text('隐私政策'), findsOneWidget);
    expect(find.text('当前权限范围'), findsOneWidget);
    expect(find.textContaining('不表示已接入完整推送链路'), findsOneWidget);

    await tester.tap(find.widgetWithText(ListTile, '用户协议'));
    await tester.pumpAndSettle();
    expect(find.text('展览装修之家用户协议'), findsOneWidget);
  });

  testWidgets(
    'settings page reads location status without requesting position',
    (WidgetTester tester) async {
      final locationService = _ProfileSettingsDeviceLocationService(
        permissionSnapshot: const DeviceLocationPermissionSnapshot(
          permissionState: DeviceLocationPermissionState.denied,
          serviceEnabled: true,
          message: '定位权限未授予。',
        ),
      );

      await tester.pumpWidget(
        _buildProfileApp(
          transport: FakeAppApiTransport(handlers: const {}),
          initialRoute: ProfileRoutes.settings,
          deviceLocationService: locationService,
          shellContext: AppShellContextData(
            userId: '13812345678',
            organizationId: 'org-1',
            certificationStatus: 'approved',
            membershipStatus: 'active',
            visibleBuildings: const <String>[
              'exhibition',
              'messages',
              'profile',
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('定位权限'));
      expect(find.text('定位权限未授予。'), findsOneWidget);
      expect(locationService.permissionReadCount, 1);
      expect(locationService.resolvePositionCount, 0);

      await tester.tap(find.text('定位权限'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('刷新状态'));
      await tester.pumpAndSettle();

      expect(locationService.permissionReadCount, 2);
      expect(locationService.resolvePositionCount, 0);
    },
  );

  testWidgets('settings page opens app and location system settings only', (
    WidgetTester tester,
  ) async {
    final locationService = _ProfileSettingsDeviceLocationService();

    await tester.pumpWidget(
      _buildProfileApp(
        transport: FakeAppApiTransport(handlers: const {}),
        initialRoute: ProfileRoutes.settings,
        deviceLocationService: locationService,
        shellContext: AppShellContextData(
          userId: '13812345678',
          organizationId: 'org-1',
          certificationStatus: 'approved',
          membershipStatus: 'active',
          visibleBuildings: const <String>['exhibition', 'messages', 'profile'],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await scrollTo(tester, find.text('系统通知'));
    await tester.tap(find.text('系统通知'));
    await tester.pumpAndSettle();
    expect(locationService.appSettingsOpenCount, 1);
    expect(locationService.resolvePositionCount, 0);

    await scrollTo(tester, find.text('定位权限'));
    await tester.tap(find.text('定位权限'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('打开系统定位设置'));
    await tester.pumpAndSettle();

    expect(locationService.locationSettingsOpenCount, 1);
    expect(locationService.resolvePositionCount, 0);
  });

  testWidgets('personal page shows switch account and logout after login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _buildProfileApp(
        transport: FakeAppApiTransport(handlers: const {}),
        initialRoute: ProfileRoutes.personal,
        shellContext: AppShellContextData(
          userId: '13812345678',
          organizationId: 'org-1',
          certificationStatus: 'approved',
          membershipStatus: 'active',
          visibleBuildings: const <String>['exhibition', 'messages', 'profile'],
        ),
      ),
    );
    await tester.pumpAndSettle();
    await scrollTo(tester, find.text('身份与安全'));

    expect(find.text('切换账号'), findsOneWidget);
    expect(find.text('退出登录'), findsOneWidget);
    expect(find.text('登录入口'), findsNothing);
  });

  testWidgets(
    'personal page surfaces set password entry for otp login session',
    (WidgetTester tester) async {
      final sessionStore = AppSessionStore();
      sessionStore.establishSession(
        accessToken: 'access-otp',
        refreshToken: 'refresh-otp',
        expiresInSeconds: 3600,
        deviceId: 'device-otp',
        localLoginSource: AppSessionLoginSource.otpLogin,
      );

      await tester.pumpWidget(
        _buildProfileApp(
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
                      body: _profilePayload(
                        organizationId: 'org-otp',
                        certificationStatus: 'approved',
                        membershipStatus: 'active',
                      ),
                    );
                  },
                },
          ),
          initialRoute: ProfileRoutes.personal,
          sessionStore: sessionStore,
          shellContext: AppShellContextData(
            userId: '13812345678',
            organizationId: 'org-otp',
            roleKeys: const <String>['buyer_admin'],
            certificationStatus: 'approved',
            membershipStatus: 'active',
            visibleBuildings: const <String>[
              'exhibition',
              'messages',
              'profile',
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      await scrollTo(tester, find.text('身份与安全'));

      expect(find.widgetWithText(ListTile, '设置登录密码'), findsOneWidget);

      await tester.tap(find.widgetWithText(ListTile, '设置登录密码'));
      await tester.pumpAndSettle();

      expect(find.textContaining('只服务已登录账号补齐账号密码登录能力'), findsOneWidget);
    },
  );

  testWidgets(
    'personal page hides set password entry for password login session',
    (WidgetTester tester) async {
      final sessionStore = AppSessionStore();
      sessionStore.establishSession(
        accessToken: 'access-password',
        refreshToken: 'refresh-password',
        expiresInSeconds: 3600,
        deviceId: 'device-password',
        localLoginSource: AppSessionLoginSource.passwordLogin,
      );

      await tester.pumpWidget(
        _buildProfileApp(
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
                      body: _profilePayload(
                        organizationId: 'org-password',
                        certificationStatus: 'approved',
                        membershipStatus: 'active',
                      ),
                    );
                  },
                },
          ),
          initialRoute: ProfileRoutes.personal,
          sessionStore: sessionStore,
          shellContext: AppShellContextData(
            userId: '13812345678',
            organizationId: 'org-password',
            roleKeys: const <String>['buyer_admin'],
            certificationStatus: 'approved',
            membershipStatus: 'active',
            visibleBuildings: const <String>[
              'exhibition',
              'messages',
              'profile',
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      await scrollTo(tester, find.text('身份与安全'));

      expect(find.widgetWithText(ListTile, '设置登录密码'), findsNothing);
    },
  );

  testWidgets(
    'personal page removes set password entry after prompt dismissal',
    (WidgetTester tester) async {
      final sessionStore = AppSessionStore();
      sessionStore.establishSession(
        accessToken: 'access-dismiss',
        refreshToken: 'refresh-dismiss',
        expiresInSeconds: 3600,
        deviceId: 'device-dismiss',
        localLoginSource: AppSessionLoginSource.otpLogin,
      );

      await tester.pumpWidget(
        _buildProfileApp(
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
                      body: _profilePayload(
                        organizationId: 'org-dismiss',
                        certificationStatus: 'approved',
                        membershipStatus: 'active',
                      ),
                    );
                  },
                },
          ),
          initialRoute: ProfileRoutes.personal,
          sessionStore: sessionStore,
          shellContext: AppShellContextData(
            userId: '13812345678',
            organizationId: 'org-dismiss',
            roleKeys: const <String>['buyer_admin'],
            certificationStatus: 'approved',
            membershipStatus: 'active',
            visibleBuildings: const <String>[
              'exhibition',
              'messages',
              'profile',
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      await scrollTo(tester, find.text('身份与安全'));

      expect(find.widgetWithText(ListTile, '设置登录密码'), findsOneWidget);

      sessionStore.markPasswordSetupPromptDismissed();
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ListTile, '设置登录密码'), findsNothing);
    },
  );

  testWidgets(
    'my membership entry consumes shell summary and the four bounded read pages',
    (WidgetTester tester) async {
      ProfileMembershipConsumerLayer.install(
        ProfileMembershipConsumerLayer(
          client: AppApiClient(
            config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
            transport: FakeAppApiTransport(
              handlers:
                  <
                    String,
                    Future<AppApiResponse> Function(AppApiRequest request)
                  >{
                    'GET /api/app/profile/membership/current':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: const <String, Object?>{
                              'organizationId': 'org-membership',
                              'paidMembershipTier': 'standard',
                              'rateBand': null,
                              'serviceFeeDiscountSummary':
                                  '平台服务费 9 折，作用于 baseFeeAmount，单项目封顶 3600。',
                              'entitlementsSummary': <String>['更高排序', '更多曝光位'],
                              'quotaSummary': <String>[
                                '商机提醒剩余 12 次',
                                '优先曝光剩余 4 次',
                              ],
                              'effectiveAt': '2026-04-01 00:00',
                              'expiresAt': '2027-04-01 00:00',
                              'nextRefreshAt': '2026-04-06 00:00',
                            },
                          );
                        },
                    'GET /api/app/profile/membership/explanation':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: const <String, Object?>{
                              'tiers': <Object?>[
                                <String, Object?>{
                                  'tier': 'free_certified',
                                  'title': '免费认证版',
                                  'highlights': <String>['基础发布资格前提中的会员维度'],
                                },
                                <String, Object?>{
                                  'tier': 'standard',
                                  'title': '标准档位',
                                  'highlights': <String>['更高排序', '更多曝光位'],
                                },
                              ],
                              'entitlementNotes': <String>[
                                '当前权益以组织 scope 下的会员档位为准。',
                              ],
                              'quotaNotes': <String>['当前配额只展示最小摘要与说明。'],
                              'disclaimer': '当前说明仅用于会员读面，不构成支付承诺。',
                            },
                          );
                        },
                    'GET /api/app/profile/membership/quota':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: const <String, Object?>{
                              'items': <Object?>[
                                <String, Object?>{
                                  'quotaType': 'opportunity_alert',
                                  'summary': '商机提醒额度',
                                  'currentValue': 12,
                                  'refreshRule': '自然日刷新',
                                },
                              ],
                              'nextRefreshAt': '2026-04-06 00:00',
                            },
                          );
                        },
                    'GET /api/app/profile/membership/upgrade-guide':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: const <String, Object?>{
                              'currentTier': 'standard',
                              'availableTiers': <Object?>[
                                <String, Object?>{
                                  'tier': 'professional',
                                  'title': '专业档位',
                                  'serviceFeeDiscountSummary':
                                      '平台服务费 8 折，作用于 baseFeeAmount，单项目封顶 3200。',
                                  'candidateDisplayPrice': null,
                                  'candidateDisplayRateBand': null,
                                },
                              ],
                              'upgradeHighlights': <String>['人工撮合优先', '客服优先'],
                              'commercialDisclosure':
                                  '升级引导页只展示档位与权益说明；购买、支付、续费仍需后续门禁解锁。',
                            },
                          );
                        },
                  },
            ),
          ),
        ),
      );

      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/index': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _profilePayload(
                    organizationId: 'org-membership',
                    roleKeys: const <String>['buyer_admin'],
                    certificationStatus: 'approved',
                    membershipStatus: 'active',
                  ),
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildProfileApp(
          transport: transport,
          shellContext: _shellContextData(
            organizationId: 'org-membership',
            roleKeys: const <String>['buyer_admin'],
            certificationStatus: 'approved',
            membershipStatus: 'active',
            paidMembershipTier: 'standard',
            paidMembershipEntitlementsSummary: const <String>['更高排序'],
            paidMembershipQuotaSummary: const <String>['商机提醒剩余 12 次'],
            paidMembershipNextRefreshAt: '2026-04-06 00:00',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('我的信用与约束'));
      expect(find.text('我的信用与约束'), findsOneWidget);
      await scrollTo(tester, find.text('我的会员'));
      expect(find.text('我的会员'), findsOneWidget);
      expect(find.textContaining('当前付费会员档位与权益摘要'), findsNothing);
      expect(find.text('公司认证与我的身份'), findsNothing);
      expect(find.text('我的项目'), findsOneWidget);
      expect(find.text('发布项目工作台'), findsNothing);
      expect(find.text('我的论坛'), findsOneWidget);

      await tester.tap(find.text('我的会员'));
      await tester.pumpAndSettle();

      expect(find.text('功能状态总览'), findsOneWidget);
      expect(find.text('当前会员'), findsOneWidget);
      expect(find.text('当前已完成'), findsWidgets);
      expect(find.text('全部 4 项'), findsOneWidget);
      expect(find.text('当前未完成'), findsWidgets);
      expect(find.text('2 项'), findsOneWidget);
      expect(find.text('依赖项'), findsOneWidget);
      expect(find.text('后续开启条件'), findsWidgets);
      expect(find.text('支付沙箱验收未完成；续费、取消、退款、发票、KA/旗舰仍关闭。'), findsOneWidget);
      await scrollTo(tester, find.text('会员档位'));
      expect(find.text('会员档位'), findsOneWidget);
      expect(find.text('标准会员'), findsWidgets);
      expect(find.text('服务费优惠'), findsOneWidget);
      expect(
        find.text('平台服务费 9 折，作用于 baseFeeAmount，单项目封顶 3600。'),
        findsWidgets,
      );
      expect(find.textContaining('更高排序'), findsWidgets);
      await scrollTo(tester, find.textContaining('商机提醒剩余 12 次'));
      expect(find.textContaining('商机提醒剩余 12 次'), findsWidgets);
      await scrollTo(tester, find.text('权益说明页'));
      expect(find.text('权益说明页'), findsOneWidget);
      expect(find.text('配额说明页'), findsOneWidget);
      expect(find.text('升级引导页'), findsOneWidget);

      await tester.tap(find.text('权益说明页'));
      await tester.pumpAndSettle();
      expect(find.text('档位说明'), findsOneWidget);
      expect(find.text('标准会员 · 标准档位'), findsOneWidget);
      expect(find.textContaining('更多曝光位'), findsWidgets);
      expect(find.text('当前权益以组织 scope 下的会员档位为准。'), findsOneWidget);
      expect(find.text('当前说明仅用于会员读面，不构成支付承诺。'), findsOneWidget);

      Navigator.of(tester.element(find.text('档位说明'))).pop();
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('配额说明页'));
      await tester.tap(find.text('配额说明页'));
      await tester.pumpAndSettle();
      expect(find.text('当前额度'), findsOneWidget);
      expect(find.text('商机提醒额度'), findsOneWidget);
      expect(find.text('当前剩余 12 · 刷新规则：自然日刷新'), findsOneWidget);
      expect(find.text('刷新时间'), findsOneWidget);

      Navigator.of(tester.element(find.text('当前额度'))).pop();
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('升级引导页'));
      await tester.tap(find.text('升级引导页'));
      await tester.pumpAndSettle();
      expect(find.text('当前档位'), findsOneWidget);
      expect(find.text('专业会员 · 专业档位'), findsOneWidget);
      expect(
        find.text('平台服务费 8 折，作用于 baseFeeAmount，单项目封顶 3200。'),
        findsOneWidget,
      );
      expect(find.text('人工撮合优先'), findsOneWidget);
      expect(find.text('升级引导页只展示档位与权益说明；购买、支付、续费仍需后续门禁解锁。'), findsOneWidget);
      expect(find.text('进入会员直购'), findsNothing);
      expect(find.text('会员直购最小闭环'), findsNothing);
      expect(find.text('支付宝支付'), findsNothing);
      expect(find.text('微信支付（保留/灰度）'), findsNothing);
      expect(find.textContaining('2.5%'), findsNothing);
      expect(find.textContaining('2.0%'), findsNothing);
      expect(find.textContaining('1.5%'), findsNothing);
    },
  );

  testWidgets(
    'my membership does not present paid member badge or fake quota without paid tier',
    (WidgetTester tester) async {
      ProfileMembershipConsumerLayer.install(
        ProfileMembershipConsumerLayer(
          client: AppApiClient(
            config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
            transport: FakeAppApiTransport(
              handlers:
                  <
                    String,
                    Future<AppApiResponse> Function(AppApiRequest request)
                  >{
                    'GET /api/app/profile/membership/current':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: const <String, Object?>{
                              'organizationId': 'org-membership',
                              'paidMembershipTier': null,
                              'rateBand': null,
                              'serviceFeeDiscountSummary': null,
                              'entitlementsSummary': <String>[],
                              'quotaSummary': <String>[],
                              'effectiveAt': null,
                              'expiresAt': null,
                              'nextRefreshAt': null,
                            },
                          );
                        },
                  },
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        _buildProfileApp(
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
                      body: _profilePayload(
                        organizationId: 'org-membership',
                        roleKeys: const <String>['buyer_admin'],
                        certificationStatus: 'approved',
                        membershipStatus: 'active',
                      ),
                    );
                  },
                },
          ),
          shellContext: _shellContextData(
            organizationId: 'org-membership',
            roleKeys: const <String>['buyer_admin'],
            certificationStatus: 'approved',
            membershipStatus: 'active',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('我的会员'));
      await tester.tap(find.text('我的会员'));
      await tester.pumpAndSettle();

      expect(find.text('未开通'), findsOneWidget);
      expect(find.text('当前会员'), findsNothing);
      expect(find.text('当前未开通付费会员折扣'), findsOneWidget);
      expect(find.text('会员档位暂未提供'), findsWidgets);
      await scrollTo(tester, find.text('配额摘要'));
      expect(find.text('配额摘要'), findsOneWidget);
      expect(find.text('当前暂未提供。后续将根据会员档位与支付主线开放。'), findsOneWidget);
      expect(find.text('进入会员直购'), findsNothing);
      expect(find.text('支付宝支付'), findsNothing);
      expect(find.textContaining('2.5%'), findsNothing);
      expect(find.textContaining('2.0%'), findsNothing);
      expect(find.textContaining('1.5%'), findsNothing);
    },
  );

  testWidgets(
    'my membership keeps controlled unavailable state when current route is unavailable',
    (WidgetTester tester) async {
      ProfileMembershipConsumerLayer.install(
        ProfileMembershipConsumerLayer(
          client: AppApiClient(
            config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
            transport: FakeAppApiTransport(
              handlers:
                  <
                    String,
                    Future<AppApiResponse> Function(AppApiRequest request)
                  >{
                    'GET /api/app/profile/membership/current':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 404,
                            uri: request.uri,
                            body: const <String, Object?>{
                              'message': '当前会员路径暂不可用，请稍后再试。',
                              'code': 'MEMBERSHIP_ROUTE_UNAVAILABLE',
                            },
                          );
                        },
                  },
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        _buildProfileApp(
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
                      body: _profilePayload(
                        organizationId: 'org-membership',
                        roleKeys: const <String>['buyer_admin'],
                        certificationStatus: 'approved',
                        membershipStatus: 'active',
                      ),
                    );
                  },
                },
          ),
          shellContext: _shellContextData(
            organizationId: 'org-membership',
            roleKeys: const <String>['buyer_admin'],
            certificationStatus: 'approved',
            membershipStatus: 'active',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('我的会员'));
      await tester.tap(find.text('我的会员'));
      await tester.pumpAndSettle();

      expect(find.text('我的会员当前暂不可用'), findsOneWidget);
      expect(find.text('当前会员路径暂不可用，请稍后再试。'), findsOneWidget);
    },
  );

  testWidgets(
    'credit-and-constraints entry consumes summary and the three bounded read pages',
    (WidgetTester tester) async {
      ProfileCreditConstraintsConsumerLayer.install(
        ProfileCreditConstraintsConsumerLayer(
          client: AppApiClient(
            config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
            transport: FakeAppApiTransport(
              handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'GET /api/app/profile/credit-and-constraints/status':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'privateSummary': <String, Object?>{
                            'entryKey': 'my_credit_and_constraints',
                            'summaryStatus': 'handoff_required',
                            'creditConstraintStatus': 'clear',
                            'depositPostureStatus': 'handoff_required',
                            'transactionGuaranteeEligibilityStatus':
                                'not_eligible',
                            'updatedAt': '2026-04-06 09:30',
                          },
                          'creditConstraint': <String, Object?>{
                            'creditConstraintStatus': 'clear',
                            'performanceConstraintStatus': 'clear',
                            'executionAvailabilityStatus': 'limited',
                            'restrictionReasonCode': null,
                            'advisoryReasonCode': 'credit_advisory',
                            'updatedAt': '2026-04-06 09:30',
                          },
                          'deposit': <String, Object?>{
                            'depositRequirementStatus': 'required',
                            'depositEligibilityStatus': 'eligible',
                            'depositRestrictionStatus': 'clear',
                            'depositPostureStatus': 'handoff_required',
                            'depositHandoffKey':
                                'deposit_open_payment_dependency',
                            'depositDependencyKey':
                                'v22_payment_billing_required',
                            'updatedAt': '2026-04-06 09:30',
                          },
                          'transactionGuarantee': <String, Object?>{
                            'transactionGuaranteeEligibilityStatus':
                                'not_eligible',
                            'transactionGuaranteeRestrictionStatus': 'clear',
                            'transactionGuaranteeExplanationKey':
                                'transaction_guarantee_dependency_required',
                            'transactionGuaranteeHandoffKey':
                                'transaction_guarantee_open_dependency',
                            'transactionGuaranteeDependencyKey':
                                'v22_payment_billing_required',
                            'updatedAt': '2026-04-06 09:30',
                          },
                          'dependencyReference': <String, Object?>{
                            'dependencyFamilyKey': 'v22_payment_billing',
                            'dependencyRequired': true,
                            'dependencyExplanationKey':
                                'requires_v22_payment_billing',
                            'dependencyHandoffKey': 'open_v22_payment_billing',
                          },
                        },
                      );
                    },
                'GET /api/app/profile/credit-and-constraints/explanation':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'creditExplanation': <String, Object?>{
                            'explanationKey': 'credit_advisory',
                            'title': '当前信用约束',
                            'body': '当前没有硬阻断，但存在规则提示。',
                          },
                          'depositExplanation': <String, Object?>{
                            'explanationKey': 'deposit_dependency_required',
                            'title': '当前保证金姿态',
                            'body': '当前保证金只停在 posture 与 handoff 层。',
                          },
                          'transactionGuaranteeExplanation': <String, Object?>{
                            'explanationKey':
                                'transaction_guarantee_dependency_required',
                            'title': '当前交易保障姿态',
                            'body':
                                '当前交易保障仍停在 eligibility、restriction 与 handoff posture。',
                          },
                          'dependencyExplanation': <String, Object?>{
                            'dependencyFamilyKey': 'v22_payment_billing',
                            'dependencyRequired': true,
                            'dependencyExplanationKey':
                                'requires_v22_payment_billing',
                            'title': '后续依赖',
                            'body':
                                '当前真实资金动作仍属于 V2.2 payment/billing package dependency。',
                          },
                          'disclaimer':
                              '当前信用、保证金与交易保障内容只承接 posture、explanation、handoff 与 dependency reference。',
                        },
                      );
                    },
                'GET /api/app/profile/credit-and-constraints/handoff':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'creditHandoff': <String, Object?>{
                            'handoffKey': 'credit_rule_explanation',
                            'title': '信用处理方向',
                            'body': '当前建议先查看规则说明，确认限制与提示来源。',
                          },
                          'depositHandoff': <String, Object?>{
                            'handoffKey': 'deposit_open_payment_dependency',
                            'title': '保证金处理方向',
                            'body':
                                '当前只允许 handoff 到后续 payment/billing capability family；本轮不执行具体缴纳或冻结。',
                          },
                          'transactionGuaranteeHandoff': <String, Object?>{
                            'handoffKey':
                                'transaction_guarantee_open_dependency',
                            'title': '交易保障处理方向',
                            'body': '当前保障语义只表达 handoff 与 dependency posture。',
                          },
                          'dependencyHandoff': <String, Object?>{
                            'dependencyFamilyKey': 'v22_payment_billing',
                            'dependencyRequired': true,
                            'dependencyHandoffKey': 'open_v22_payment_billing',
                            'title': '后续依赖方向',
                            'body':
                                '当前后续动作仍需 V2.2 payment/billing package dependency，本轮不提供资金执行。',
                          },
                        },
                      );
                    },
              },
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        _buildProfileApp(
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
                      body: _profilePayload(
                        organizationId: 'org-credit',
                        roleKeys: const <String>['buyer_admin'],
                        certificationStatus: 'approved',
                        membershipStatus: 'active',
                      ),
                    );
                  },
                },
          ),
          shellContext: _shellContextData(
            organizationId: 'org-credit',
            roleKeys: const <String>['buyer_admin'],
            certificationStatus: 'approved',
            membershipStatus: 'active',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('我的信用与约束'));
      expect(find.text('我的信用与约束'), findsOneWidget);
      expect(find.text('发布项目工作台'), findsNothing);
      expect(find.text('我的论坛'), findsOneWidget);

      await tester.tap(find.text('我的信用与约束'));
      await tester.pumpAndSettle();

      expect(find.text('功能状态总览'), findsOneWidget);
      expect(find.text('当前不承接真实保证金缴纳、资金冻结、支付执行或结算。'), findsOneWidget);
      await scrollTo(tester, find.text('当前摘要'));
      expect(find.text('当前摘要'), findsOneWidget);
      expect(find.text('当前需后续衔接'), findsWidgets);
      expect(find.textContaining('当前保证金需后续衔接'), findsWidgets);
      expect(find.textContaining('依赖 V2.2 支付 / 账单能力'), findsWidgets);

      await scrollTo(tester, find.text('规则说明页'));
      await tester.tap(find.text('规则说明页'));
      await tester.pumpAndSettle();
      expect(find.text('当前信用约束'), findsOneWidget);
      expect(find.text('当前保证金姿态'), findsOneWidget);
      expect(
        find.textContaining('V2.2 payment/billing package dependency'),
        findsWidgets,
      );

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('处理与衔接页'));
      await tester.tap(find.text('处理与衔接页'));
      await tester.pumpAndSettle();
      expect(find.text('信用处理方向'), findsOneWidget);
      expect(find.text('保证金处理方向'), findsOneWidget);
      expect(find.text('交易保障处理方向'), findsOneWidget);
      expect(find.text('后续依赖方向'), findsOneWidget);
    },
  );

  testWidgets(
    'credit-and-constraints keeps controlled unavailable state when route is unavailable',
    (WidgetTester tester) async {
      ProfileCreditConstraintsConsumerLayer.install(
        ProfileCreditConstraintsConsumerLayer(
          client: AppApiClient(
            config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
            transport: FakeAppApiTransport(
              handlers:
                  <
                    String,
                    Future<AppApiResponse> Function(AppApiRequest request)
                  >{
                    'GET /api/app/profile/credit-and-constraints/status':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 404,
                            uri: request.uri,
                            body: const <String, Object?>{
                              'message': '当前信用与约束入口暂不可用，请稍后再试。',
                              'code':
                                  'CREDIT_AND_CONSTRAINTS_ROUTE_UNAVAILABLE',
                            },
                          );
                        },
                  },
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        _buildProfileApp(
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
                      body: _profilePayload(
                        organizationId: 'org-credit',
                        roleKeys: const <String>['buyer_admin'],
                        certificationStatus: 'approved',
                        membershipStatus: 'active',
                      ),
                    );
                  },
                },
          ),
          shellContext: _shellContextData(
            organizationId: 'org-credit',
            roleKeys: const <String>['buyer_admin'],
            certificationStatus: 'approved',
            membershipStatus: 'active',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('我的信用与约束'));
      await tester.tap(find.text('我的信用与约束'));
      await tester.pumpAndSettle();

      expect(find.text('我的信用与约束当前暂不可用'), findsOneWidget);
      expect(find.text('当前信用与约束入口暂不可用，请稍后再试。'), findsOneWidget);
    },
  );

  testWidgets(
    'organization-credit-scoring reserve entry consumes status explanation and handoff without polluting current V2.1',
    (WidgetTester tester) async {
      ProfileOrganizationCreditScoringConsumerLayer.install(
        ProfileOrganizationCreditScoringConsumerLayer(
          client: AppApiClient(
            config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
            transport: FakeAppApiTransport(
              handlers:
                  <
                    String,
                    Future<AppApiResponse> Function(AppApiRequest request)
                  >{
                    'GET /api/app/profile/organization-credit-scoring/status':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: const <String, Object?>{
                              'score': 86,
                              'tierCode': 'T2',
                              'tierLabel': '稳态档位',
                              'sampleStatus': 'SUFFICIENT',
                              'riskPosture': 'LOW',
                              'ratedCompletedOrderCount': 18,
                              'positiveRate': 0.94,
                              'negativeRate': 0.06,
                              'verySatisfiedCount': 12,
                              'satisfiedCount': 5,
                              'passableCount': 1,
                              'negativeCount': 0,
                              'actionableState': 'continue_observe',
                              'updatedAt': '2026-04-14T09:00:00Z',
                            },
                          );
                        },
                    'GET /api/app/profile/organization-credit-scoring/explanation':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: const <String, Object?>{
                              'reasonSummary': '未来主线 reserve 只读说明摘要',
                              'reasonCodes': <Object?>[
                                'order_rating_sample_ready',
                                'low_negative_rate',
                              ],
                              'sampleStatus': 'SUFFICIENT',
                              'riskPosture': 'LOW',
                              'ratedCompletedOrderCount': 18,
                              'positiveRate': 0.94,
                              'negativeRate': 0.06,
                              'verySatisfiedCount': 12,
                              'satisfiedCount': 5,
                              'passableCount': 1,
                              'negativeCount': 0,
                              'updatedAt': '2026-04-14T09:00:00Z',
                            },
                          );
                        },
                    'GET /api/app/profile/organization-credit-scoring/handoff':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: const <String, Object?>{
                              'actionableState': 'continue_observe',
                              'sampleStatus': 'SUFFICIENT',
                              'riskPosture': 'LOW',
                              'primaryActionCode': 'continue_observe',
                              'primaryActionLabel': '继续观察',
                              'handoffMessage': '未来主线 reserve 仅作只读衔接',
                              'updatedAt': '2026-04-14T09:00:00Z',
                            },
                          );
                        },
                  },
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        _buildProfileApp(
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
                      body: _profilePayload(
                        organizationId: 'org-credit',
                        roleKeys: const <String>['buyer_admin'],
                        certificationStatus: 'approved',
                        membershipStatus: 'active',
                      ),
                    );
                  },
                },
          ),
          shellContext: _shellContextData(
            organizationId: 'org-credit',
            roleKeys: const <String>['buyer_admin'],
            certificationStatus: 'approved',
            membershipStatus: 'active',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('组织信用评分 reserve'));
      expect(find.text('组织信用评分 reserve'), findsOneWidget);
      expect(find.textContaining('未来主线 reserve'), findsWidgets);

      await tester.tap(find.text('组织信用评分 reserve'));
      await tester.pumpAndSettle();

      expect(find.text('组织信用评分'), findsWidgets);
      expect(find.text('评分 86'), findsNWidgets(2));
      expect(find.text('稳态档位'), findsWidgets);
      expect(find.text('未来主线 reserve 只读总览'), findsNothing);
      expect(find.textContaining('future-mainline reserve'), findsWidgets);

      await scrollTo(tester, find.text('说明页'));
      await tester.tap(find.text('说明页'));
      await tester.pumpAndSettle();
      expect(find.text('未来主线 reserve 只读说明摘要'), findsOneWidget);
      await scrollTo(tester, find.text('原因码列表'));
      expect(find.textContaining('order_rating_sample_ready'), findsWidgets);
      expect(find.text('低风险姿态'), findsWidgets);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('衔接页'));
      await tester.tap(find.text('衔接页'));
      await tester.pumpAndSettle();
      await scrollTo(tester, find.text('主动作标签'));
      expect(find.text('未来主线 reserve 仅作只读衔接'), findsOneWidget);
      expect(find.text('继续观察'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('我的信用与约束'));
      await tester.tap(find.text('我的信用与约束'));
      await tester.pumpAndSettle();
      expect(find.textContaining('未来主线 reserve'), findsNothing);
    },
  );

  testWidgets(
    'organization-credit-scoring reserve keeps insufficient shadow projection readable when riskPosture is null',
    (WidgetTester tester) async {
      ProfileOrganizationCreditScoringConsumerLayer.install(
        ProfileOrganizationCreditScoringConsumerLayer(
          client: AppApiClient(
            config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
            transport: FakeAppApiTransport(
              handlers:
                  <
                    String,
                    Future<AppApiResponse> Function(AppApiRequest request)
                  >{
                    'GET /api/app/profile/organization-credit-scoring/status':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: const <String, Object?>{
                              'score': null,
                              'tierCode': null,
                              'tierLabel': null,
                              'sampleStatus': 'INSUFFICIENT',
                              'riskPosture': null,
                              'ratedCompletedOrderCount': 4,
                              'positiveRate': null,
                              'negativeRate': null,
                              'verySatisfiedCount': 2,
                              'satisfiedCount': 1,
                              'passableCount': 1,
                              'negativeCount': 0,
                              'actionableState': null,
                              'updatedAt': '2026-04-14T09:00:00Z',
                            },
                          );
                        },
                    'GET /api/app/profile/organization-credit-scoring/explanation':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: const <String, Object?>{
                              'reasonSummary':
                                  '当前有效评价样本不足，future-mainline reserve 仅展示只读占位。',
                              'reasonCodes': <Object?>[
                                'SAMPLE_INSUFFICIENT',
                                'RATING_ONLY_MODE_ACTIVE',
                              ],
                              'sampleStatus': 'INSUFFICIENT',
                              'riskPosture': null,
                              'ratedCompletedOrderCount': 4,
                              'positiveRate': null,
                              'negativeRate': null,
                              'verySatisfiedCount': 2,
                              'satisfiedCount': 1,
                              'passableCount': 1,
                              'negativeCount': 0,
                              'updatedAt': '2026-04-14T09:00:00Z',
                            },
                          );
                        },
                    'GET /api/app/profile/organization-credit-scoring/handoff':
                        (AppApiRequest request) async {
                          return AppApiResponse(
                            statusCode: 200,
                            uri: request.uri,
                            body: const <String, Object?>{
                              'actionableState': null,
                              'sampleStatus': 'INSUFFICIENT',
                              'riskPosture': null,
                              'primaryActionCode': null,
                              'primaryActionLabel': null,
                              'handoffMessage': null,
                              'updatedAt': '2026-04-14T09:00:00Z',
                            },
                          );
                        },
                  },
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        _buildProfileApp(
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
                      body: _profilePayload(
                        organizationId: 'org-credit',
                        roleKeys: const <String>['buyer_admin'],
                        certificationStatus: 'approved',
                        membershipStatus: 'active',
                      ),
                    );
                  },
                },
          ),
          shellContext: _shellContextData(
            organizationId: 'org-credit',
            roleKeys: const <String>['buyer_admin'],
            certificationStatus: 'approved',
            membershipStatus: 'active',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('组织信用评分 reserve'));
      await tester.tap(find.text('组织信用评分 reserve'));
      await tester.pumpAndSettle();

      expect(find.text('样本不足'), findsWidgets);
      expect(find.text('风险姿态暂未提供'), findsWidgets);
      expect(find.text('当前暂无评分'), findsOneWidget);
      expect(find.text('当前暂无可执行建议'), findsOneWidget);

      await scrollTo(tester, find.text('说明页'));
      await tester.tap(find.text('说明页'));
      await tester.pumpAndSettle();
      expect(find.textContaining('当前有效评价样本不足'), findsOneWidget);
      expect(find.text('风险姿态暂未提供'), findsWidgets);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('衔接页'));
      await tester.tap(find.text('衔接页'));
      await tester.pumpAndSettle();
      await scrollTo(tester, find.text('当前说明'));
      expect(find.text('当前暂无主动作标签'), findsOneWidget);
      expect(find.text('当前暂无衔接说明'), findsOneWidget);
      expect(find.text('风险姿态暂未提供'), findsWidgets);
    },
  );

  testWidgets(
    'company page keeps summary handoff actions when no organization exists',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/index': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _profilePayload(),
                );
              },
            },
      );
      final profileIdentityTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/organization/mine':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{'items': <Object?>[]},
                    );
                  },
              'GET /api/app/profile/certification/current':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 404,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'code': 'PROFILE_CERTIFICATION_UNAVAILABLE',
                        'message': 'profile certification unavailable',
                      },
                    );
                  },
            },
      );

      await tester.pumpWidget(
        _buildProfileApp(
          transport: transport,
          profileIdentityTransport: profileIdentityTransport,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('我的公司').first);
      await tester.pumpAndSettle();

      expect(find.text('当前还没有我的公司'), findsWidgets);
      expect(find.text('可进行的操作'), findsOneWidget);
      expect(find.text('公司与组织'), findsWidgets);
      expect(find.text('创建组织'), findsNothing);
      expect(find.text('加入组织'), findsNothing);
      expect(find.text('功能状态'), findsNothing);
      expect(find.text('当前公司/组织现状'), findsNothing);
      expect(find.text('认证资料'), findsNothing);
    },
  );

  testWidgets(
    'company page shows failure title instead of no-company title on retryable organization read error',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/index': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _profilePayload(),
                );
              },
            },
      );
      final profileIdentityTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/organization/mine':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 500,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'code': 'PROFILE_ORGANIZATION_TEMPORARY_UNAVAILABLE',
                        'message': 'organization read temporarily unavailable',
                      },
                    );
                  },
              'GET /api/app/profile/certification/current':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 404,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'code': 'PROFILE_CERTIFICATION_UNAVAILABLE',
                        'message': 'profile certification unavailable',
                      },
                    );
                  },
            },
      );

      await tester.pumpWidget(
        _buildProfileApp(
          transport: transport,
          profileIdentityTransport: profileIdentityTransport,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('我的公司').first);
      await tester.pumpAndSettle();

      expect(find.text('公司信息暂时没有加载成功'), findsOneWidget);
      expect(find.text('公司信息暂时没有加载成功，请稍后再试'), findsOneWidget);
      expect(find.text('当前还没有我的公司'), findsNothing);
    },
  );

  testWidgets(
    'company page keeps no-company title when organization list is truly empty',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/index': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _profilePayload(),
                );
              },
            },
      );
      final profileIdentityTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/organization/mine':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{'items': <Object?>[]},
                    );
                  },
              'GET /api/app/profile/certification/current':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 404,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'code': 'PROFILE_CERTIFICATION_UNAVAILABLE',
                        'message': 'profile certification unavailable',
                      },
                    );
                  },
            },
      );

      await tester.pumpWidget(
        _buildProfileApp(
          transport: transport,
          profileIdentityTransport: profileIdentityTransport,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('我的公司').first);
      await tester.pumpAndSettle();

      expect(find.text('当前还没有我的公司'), findsWidgets);
      expect(find.text('公司信息暂时没有加载成功'), findsNothing);
    },
  );

  testWidgets('company page highlights the two primary handoff actions', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/profile/index': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _profilePayload(
                  organizationId: 'org-company-highlight',
                  certificationStatus: 'approved',
                  membershipStatus: 'active',
                ),
              );
            },
          },
    );
    final profileIdentityTransport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/profile/organization/mine':
                (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'items': <Object?>[
                        <String, Object?>{
                          'organizationId': 'org-company-highlight',
                          'name': '重庆坤特展览展示有限公司',
                          'organizationType': 'supplier',
                          'roleKeys': <Object?>['buyer_admin'],
                          'membershipStatus': 'active',
                          'certificationStatus': 'approved',
                          'current': true,
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
                      'organizationId': 'org-title-dedup',
                      'certificationStatus': 'approved',
                      'legalName': '重庆坤特展览展示有限公司',
                      'uscc': '91500105MA5U58K346',
                    },
                  );
                },
          },
    );

    await tester.pumpWidget(
      _buildProfileApp(
        transport: transport,
        profileIdentityTransport: profileIdentityTransport,
        initialRoute: '/profile/company',
        shellContext: _shellContextData(
          organizationId: 'org-company-highlight',
          roleKeys: const <String>['buyer_admin'],
          certificationStatus: 'approved',
          membershipStatus: 'active',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await scrollTo(tester, find.text('可进行的操作'));
    expect(find.text('可进行的操作'), findsOneWidget);

    final organizationAction = tester.widget<ListTile>(
      find.byKey(const ValueKey<String>('profile-company-action-organization')),
    );
    final certificationAction = tester.widget<ListTile>(
      find.byKey(
        const ValueKey<String>('profile-company-action-certification'),
      ),
    );

    expect(organizationAction.tileColor, isNotNull);
    expect(certificationAction.tileColor, isNotNull);
    expect(find.text('功能状态'), findsNothing);
    expect(find.text('当前公司/组织现状'), findsNothing);
    expect(find.text('认证资料'), findsNothing);
    expect(find.text('公司名称'), findsNothing);
  });

  testWidgets('organization handoff keeps only one page title instance', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/profile/index': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _profilePayload(
                  organizationId: 'org-title-dedup',
                  certificationStatus: 'approved',
                  membershipStatus: 'active',
                ),
              );
            },
          },
    );
    final profileIdentityTransport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/profile/organization/mine':
                (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'items': <Object?>[
                        <String, Object?>{
                          'organizationId': 'org-title-dedup',
                          'name': '重庆坤特展览展示有限公司',
                          'organizationType': 'supplier',
                          'roleKeys': <Object?>['buyer_admin'],
                          'membershipStatus': 'active',
                          'certificationStatus': 'approved',
                          'current': true,
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
                      'organizationId': 'org-title-dedup',
                      'certificationStatus': 'approved',
                      'legalName': '重庆坤特展览展示有限公司',
                      'uscc': '91500105MA5U58K346',
                    },
                  );
                },
          },
    );

    await tester.pumpWidget(
      _buildProfileApp(
        transport: transport,
        profileIdentityTransport: profileIdentityTransport,
        initialRoute: '/profile/organization',
        shellContext: _shellContextData(
          organizationId: 'org-title-dedup',
          roleKeys: const <String>['buyer_admin'],
          certificationStatus: 'approved',
          membershipStatus: 'active',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('公司与组织'), findsOneWidget);
  });

  testWidgets('certification current keeps only one page title instance', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/profile/index': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _profilePayload(
                  organizationId: 'org-cert-title-dedup',
                  certificationStatus: 'approved',
                  membershipStatus: 'active',
                ),
              );
            },
          },
    );
    final profileIdentityTransport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/profile/organization/mine':
                (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'items': <Object?>[
                        <String, Object?>{
                          'organizationId': 'org-cert-title-dedup',
                          'name': '重庆坤特展览展示有限公司',
                          'organizationType': 'supplier',
                          'roleKeys': <Object?>['buyer_admin'],
                          'membershipStatus': 'active',
                          'certificationStatus': 'approved',
                          'current': true,
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
                      'organizationId': 'org-cert-title-dedup',
                      'certificationStatus': 'approved',
                      'legalName': '重庆坤特展览展示有限公司',
                    },
                  );
                },
          },
    );

    await tester.pumpWidget(
      _buildProfileApp(
        transport: transport,
        profileIdentityTransport: profileIdentityTransport,
        initialRoute: '/profile/certification/current',
        shellContext: _shellContextData(
          organizationId: 'org-cert-title-dedup',
          roleKeys: const <String>['buyer_admin'],
          certificationStatus: 'approved',
          membershipStatus: 'active',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('公司认证与我的身份'), findsOneWidget);
  });

  testWidgets('profile page keeps controlled failure wording compact', (
    WidgetTester tester,
  ) async {
    final transport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/profile/index': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 503,
                uri: request.uri,
                body: <String, Object?>{
                  'code': 'PROFILE_INDEX_TEMPORARY_UNAVAILABLE',
                  'message': 'profile index temporarily unavailable',
                },
              );
            },
          },
    );

    await tester.pumpWidget(_buildProfileApp(transport: transport));
    await tester.pumpAndSettle();

    expect(find.text('账号摘要暂未完整返回'), findsOneWidget);
    expect(find.text('我的楼暂时没有加载成功，请稍后再试'), findsOneWidget);
    expect(find.widgetWithText(TextButton, '重试'), findsOneWidget);
  });

  testWidgets(
    'company page stays fail-closed when organization surface is unavailable',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/index': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _profilePayload(
                    organizationId: 'org-shell',
                    roleKeys: const <String>['buyer_admin'],
                    certificationStatus: 'approved',
                    membershipStatus: 'active',
                  ),
                );
              },
            },
      );
      final profileIdentityTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/organization/mine':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 403,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'code': 'PROFILE_ORGANIZATION_FORBIDDEN',
                        'message': 'organization surface unavailable',
                      },
                    );
                  },
              'GET /api/app/profile/certification/current':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'organizationId': 'org-shell',
                        'certificationStatus': 'pending_review',
                        'submittedAt': '2026-04-02 10:00',
                      },
                    );
                  },
            },
      );

      await tester.pumpWidget(
        _buildProfileApp(
          transport: transport,
          profileIdentityTransport: profileIdentityTransport,
          shellContext: AppShellContextData(
            userId: '13812345678',
            organizationId: 'org-shell',
            roleKeys: const <String>['buyer_admin'],
            certificationStatus: 'approved',
            membershipStatus: 'active',
            visibleBuildings: const <String>[
              'exhibition',
              'messages',
              'profile',
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('我的公司'));
      await tester.tap(find.text('我的公司').first);
      await tester.pumpAndSettle();

      expect(find.text('组织上下文未开放'), findsOneWidget);
      expect(find.text('公司名称'), findsNothing);
      expect(find.text('公司与组织'), findsWidgets);
    },
  );

  testWidgets(
    'organization create success read-back keeps certification page, company page and hub on not_submitted truth',
    (WidgetTester tester) async {
      const staleOrganizationId = 'org-old';
      const staleCertificationStatus = 'approved';
      const membershipStatus = 'active';
      const freshOrganizationId = 'org-created';
      const freshOrganizationName = '上海新建组织';
      const freshOrganizationType = 'both';
      const freshRoleKeys = <String>['buyer_admin'];

      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/index': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _profilePayload(
                    organizationId: freshOrganizationId,
                    roleKeys: freshRoleKeys,
                    certificationStatus: 'not_submitted',
                    membershipStatus: membershipStatus,
                  ),
                );
              },
            },
      );
      final profileIdentityTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/organization/mine':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: <String, Object?>{
                        'items': <Object?>[
                          _organizationItemPayload(
                            organizationId: freshOrganizationId,
                            name: freshOrganizationName,
                            organizationType: freshOrganizationType,
                            roleKeys: freshRoleKeys,
                            membershipStatus: membershipStatus,
                            certificationStatus: 'not_submitted',
                            current: true,
                          ),
                        ],
                      },
                    );
                  },
              'GET /api/app/profile/certification/current':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 404,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'code': 'PROFILE_CERTIFICATION_UNAVAILABLE',
                        'message': '当前还没有认证记录。',
                      },
                    );
                  },
            },
      );

      ExhibitionMobileApp buildApp() {
        return _buildProfileApp(
          transport: transport,
          profileIdentityTransport: profileIdentityTransport,
          shellContext: _shellContextData(
            organizationId: staleOrganizationId,
            roleKeys: freshRoleKeys,
            certificationStatus: staleCertificationStatus,
            membershipStatus: membershipStatus,
          ),
        );
      }

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('我的公司'), findsWidgets);
      await scrollTo(tester, find.text('我的公司'));
      await tester.tap(find.text('我的公司').first);
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('公司认证与我的身份'));
      await tester.tap(find.text('公司认证与我的身份'));
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('当前认证状态'));
      expect(find.text('未认证'), findsWidgets);

      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.pageBack();
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('我的公司'));
      await tester.tap(find.text('我的公司').first);
      await tester.pumpAndSettle();

      expect(find.text(freshOrganizationName), findsWidgets);
      expect(find.text('当前角色可发布项目；主体也可参与竞标'), findsWidgets);
      expect(find.text('需求方 / 供应商'), findsNothing);
      expect(find.text('编辑当前组织'), findsNothing);
      expect(find.text('再创建一个组织'), findsNothing);
      expect(find.text('认证与身份'), findsNothing);
      await scrollTo(tester, find.text('公司认证与我的身份'));
      expect(find.text('公司认证与我的身份'), findsWidgets);
      expect(find.text('认证状态'), findsNothing);
      expect(find.text('企业未认证'), findsWidgets);
      expect(find.widgetWithText(FilledButton, '提交认证'), findsNothing);
      expect(find.widgetWithText(FilledButton, '重新提交认证'), findsNothing);
    },
  );

  testWidgets(
    'company and organization pages prefer certification current truth over stale organization certification badge',
    (WidgetTester tester) async {
      const organizationId = 'org-company-approved';

      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/index': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _profilePayload(
                    organizationId: organizationId,
                    roleKeys: const <String>['buyer_admin'],
                    certificationStatus: 'approved',
                    membershipStatus: 'active',
                  ),
                );
              },
            },
      );
      final profileIdentityTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/organization/mine':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'items': <Object?>[
                          <String, Object?>{
                            'organizationId': organizationId,
                            'name': '重庆展宏展览展示有限公司',
                            'organizationType': 'both',
                            'roleKeys': <Object?>['buyer_admin'],
                            'membershipStatus': 'active',
                            'certificationStatus': 'not_submitted',
                            'current': true,
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
                        'organizationId': organizationId,
                        'certificationStatus': 'approved',
                        'submittedAt': '2026-04-15T08:30:00Z',
                      },
                    );
                  },
            },
      );

      await tester.pumpWidget(
        _buildProfileApp(
          transport: transport,
          initialRoute: '/profile/company',
          profileIdentityTransport: profileIdentityTransport,
          shellContext: _shellContextData(
            organizationId: organizationId,
            roleKeys: const <String>['buyer_admin'],
            certificationStatus: 'approved',
            membershipStatus: 'active',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('企业已认证'), findsOneWidget);
      expect(find.text('成员已开通'), findsOneWidget);
      expect(find.text('需求管理员'), findsOneWidget);
      expect(find.text('企业未认证'), findsNothing);

      await scrollTo(tester, find.text('公司与组织'));
      await tester.tap(find.text('公司与组织').first);
      await tester.pumpAndSettle();

      expect(find.text('企业已认证'), findsOneWidget);
      expect(find.text('成员已开通'), findsOneWidget);
      expect(find.text('需求管理员'), findsOneWidget);
      expect(find.text('企业未认证'), findsNothing);
    },
  );

  testWidgets(
    'company and organization pages prefer shell current organization over stale current marker',
    (WidgetTester tester) async {
      const staleOrganizationId = 'org-stale-current';
      const shellOrganizationId = 'org-shell-current';

      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/index': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _profilePayload(
                    organizationId: shellOrganizationId,
                    roleKeys: const <String>['buyer_admin'],
                    certificationStatus: 'not_submitted',
                    membershipStatus: 'active',
                  ),
                );
              },
            },
      );
      final profileIdentityTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/organization/mine':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'items': <Object?>[
                          <String, Object?>{
                            'organizationId': staleOrganizationId,
                            'name': '旧当前主体',
                            'organizationType': 'demand',
                            'roleKeys': <Object?>['buyer_admin'],
                            'membershipStatus': 'active',
                            'certificationStatus': 'approved',
                            'current': true,
                          },
                          <String, Object?>{
                            'organizationId': shellOrganizationId,
                            'name': '壳层当前主体',
                            'organizationType': 'both',
                            'roleKeys': <Object?>['buyer_admin'],
                            'membershipStatus': 'active',
                            'certificationStatus': 'not_submitted',
                            'current': false,
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
                        'organizationId': shellOrganizationId,
                        'certificationStatus': 'not_submitted',
                      },
                    );
                  },
            },
      );

      await tester.pumpWidget(
        _buildProfileApp(
          transport: transport,
          initialRoute: '/profile/company',
          profileIdentityTransport: profileIdentityTransport,
          shellContext: _shellContextData(
            organizationId: shellOrganizationId,
            roleKeys: const <String>['buyer_admin'],
            certificationStatus: 'not_submitted',
            membershipStatus: 'active',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('壳层当前主体'), findsOneWidget);
      expect(find.text('旧当前主体'), findsNothing);

      await scrollTo(tester, find.text('公司与组织'));
      await tester.tap(find.text('公司与组织').first);
      await tester.pumpAndSettle();

      expect(find.text('壳层当前主体'), findsOneWidget);
      expect(find.text('旧当前主体'), findsNothing);
    },
  );

  testWidgets(
    'organization switch page renders switch targets as compact list rows',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/index': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _profilePayload(
                    organizationId: 'org-current',
                    roleKeys: const <String>['buyer_admin'],
                    certificationStatus: 'approved',
                    membershipStatus: 'active',
                  ),
                );
              },
            },
      );
      final profileIdentityTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/organization/mine':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: <String, Object?>{
                        'items': <Object?>[
                          _organizationItemPayload(
                            organizationId: 'org-current',
                            name: '重庆坤特展览展示有限公司',
                            organizationType: 'both',
                            roleKeys: const <String>['buyer_admin'],
                            membershipStatus: 'active',
                            certificationStatus: 'not_submitted',
                            current: true,
                          ),
                          _organizationItemPayload(
                            organizationId: 'org-platform',
                            name: 'Smoke Admin Review P0 Platform Org',
                            organizationType: 'platform',
                            roleKeys: const <String>['platform_reviewer'],
                            membershipStatus: 'active',
                            certificationStatus: 'not_submitted',
                            current: false,
                          ),
                          _organizationItemPayload(
                            organizationId: 'org-supplier',
                            name: '我的公司',
                            organizationType: 'supplier',
                            roleKeys: const <String>['supplier_admin'],
                            membershipStatus: 'active',
                            certificationStatus: 'approved',
                            current: false,
                          ),
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
                        'organizationId': 'org-current',
                        'certificationStatus': 'not_submitted',
                        'legalName': '重庆坤特展览展示有限公司',
                        'uscc': '91500105MA5U58K346',
                        'legalPerson': '王巍威',
                        'businessType': '有限责任公司',
                        'address': '重庆市江北区洋河二村73号1幢20-7',
                        'registeredCapital': '壹佰万元整',
                        'establishedAt': '2016-03-30',
                        'businessTerm': '2016年03月30日至永久',
                        'businessScope': '展览展示服务',
                      },
                    );
                  },
            },
      );

      await tester.pumpWidget(
        _buildProfileApp(
          transport: transport,
          profileIdentityTransport: profileIdentityTransport,
          initialRoute: ProfileIdentityRoutes.organizationSwitch,
          shellContext: _shellContextData(
            organizationId: 'org-current',
            roleKeys: const <String>['buyer_admin'],
            certificationStatus: 'not_submitted',
            membershipStatus: 'active',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('切换当前主体'), findsOneWidget);
      expect(find.text('当前公司/组织'), findsNothing);
      expect(find.textContaining('当前主体：重庆坤特展览展示有限公司'), findsOneWidget);
      expect(find.text('切换为当前公司/组织'), findsNothing);
      expect(find.text('Smoke Admin Review P0 Platform Org'), findsNothing);
      expect(find.text('当前'), findsOneWidget);
      expect(find.text('我的公司'), findsOneWidget);
      expect(find.text('切换'), findsOneWidget);
      expect(
        find.textContaining('能力：当前主体可参与竞标；企业认证：已认证；成员：已开通'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'organization switch falls back to read-back verification when switch response body is incomplete',
    (WidgetTester tester) async {
      String currentOrganizationId = 'org-switch-a';

      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/index': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _profilePayload(
                    organizationId: currentOrganizationId,
                    roleKeys: const <String>['buyer_admin'],
                    certificationStatus: 'not_submitted',
                    membershipStatus: 'active',
                  ),
                );
              },
            },
      );
      final profileIdentityTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/organization/mine':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'items': <Object?>[
                          <String, Object?>{
                            'organizationId': 'org-switch-a',
                            'name': '切换前主体',
                            'organizationType': 'supplier',
                            'roleKeys': <Object?>['buyer_admin'],
                            'membershipStatus': 'active',
                            'certificationStatus': 'approved',
                            'current': true,
                          },
                          <String, Object?>{
                            'organizationId': 'org-switch-b',
                            'name': '切换后主体',
                            'organizationType': 'both',
                            'roleKeys': <Object?>['buyer_admin'],
                            'membershipStatus': 'active',
                            'certificationStatus': 'not_submitted',
                            'current': false,
                          },
                        ],
                      },
                    );
                  },
              'POST /api/app/profile/organization/switch':
                  (AppApiRequest request) async {
                    currentOrganizationId = 'org-switch-b';
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: null,
                    );
                  },
            },
      );
      final shellTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/shell/context': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _shellContextPayload(
                    organizationId: currentOrganizationId,
                    roleKeys: const <String>['buyer_admin'],
                    certificationStatus: 'not_submitted',
                    membershipStatus: 'active',
                  ),
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildProfileApp(
          transport: transport,
          initialRoute: ProfileIdentityRoutes.organizationSwitch,
          profileIdentityTransport: profileIdentityTransport,
          shellContextConsumer: AppShellContextConsumer(
            client: AppApiClient(
              config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
              transport: shellTransport,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('切换').first);
      await tester.pumpAndSettle();
      expect(find.text('确认切换当前主体'), findsOneWidget);
      expect(find.textContaining('切换到“切换后主体”'), findsOneWidget);

      await tester.tap(find.text('确认切换'));
      await tester.pumpAndSettle();

      expect(find.text('切换成功'), findsOneWidget);
      expect(find.textContaining('当前主体：切换后主体'), findsOneWidget);
      expect(find.text('切换当前未完成'), findsNothing);
    },
  );

  testWidgets(
    'organization switch page leaves current organization and reloads next organization',
    (WidgetTester tester) async {
      String currentOrganizationId = 'org-leave-a';
      var leaveCalls = 0;

      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/index': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _profilePayload(
                    organizationId: currentOrganizationId,
                    roleKeys: const <String>['buyer_admin'],
                    certificationStatus: 'not_submitted',
                    membershipStatus: 'active',
                  ),
                );
              },
            },
      );
      final profileIdentityTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/organization/mine':
                  (AppApiRequest request) async {
                    final items = currentOrganizationId == 'org-leave-a'
                        ? <Object?>[
                            <String, Object?>{
                              'organizationId': 'org-leave-a',
                              'name': '退出前主体',
                              'organizationType': 'supplier',
                              'roleKeys': <Object?>['buyer_member(scoped)'],
                              'membershipStatus': 'active',
                              'certificationStatus': 'approved',
                              'current': true,
                            },
                            <String, Object?>{
                              'organizationId': 'org-leave-b',
                              'name': '退出后主体',
                              'organizationType': 'both',
                              'roleKeys': <Object?>['buyer_admin'],
                              'membershipStatus': 'active',
                              'certificationStatus': 'not_submitted',
                              'current': false,
                            },
                          ]
                        : <Object?>[
                            <String, Object?>{
                              'organizationId': 'org-leave-b',
                              'name': '退出后主体',
                              'organizationType': 'both',
                              'roleKeys': <Object?>['buyer_admin'],
                              'membershipStatus': 'active',
                              'certificationStatus': 'not_submitted',
                              'current': true,
                            },
                          ];
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: <String, Object?>{'items': items},
                    );
                  },
              'POST /api/app/profile/organization/current/leave':
                  (AppApiRequest request) async {
                    leaveCalls += 1;
                    currentOrganizationId = 'org-leave-b';
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'leftOrganizationId': 'org-leave-a',
                        'nextOrganizationId': 'org-leave-b',
                        'shellBootstrapState': 'authenticated',
                        'traceId': 'trace-leave',
                      },
                    );
                  },
            },
      );
      final shellTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/shell/context': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _shellContextPayload(
                    organizationId: currentOrganizationId,
                    roleKeys: const <String>['buyer_admin'],
                    certificationStatus: 'not_submitted',
                    membershipStatus: 'active',
                  ),
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildProfileApp(
          transport: transport,
          initialRoute: ProfileIdentityRoutes.organizationSwitch,
          profileIdentityTransport: profileIdentityTransport,
          shellContextConsumer: AppShellContextConsumer(
            client: AppApiClient(
              config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
              transport: shellTransport,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('当前主体：退出前主体'), findsOneWidget);
      await scrollTo(tester, find.widgetWithText(FilledButton, '退出当前组织'));
      await tester.tap(find.widgetWithText(FilledButton, '退出当前组织'));
      await tester.pumpAndSettle();
      expect(find.text('确认退出当前组织'), findsOneWidget);

      await tester.tap(find.text('确认退出'));
      await tester.pumpAndSettle();

      expect(leaveCalls, 1);
      expect(find.text('已退出当前组织'), findsOneWidget);
      expect(find.text('退出对象：退出后主体'), findsOneWidget);
      expect(find.textContaining('页面已重新读取当前组织上下文'), findsOneWidget);
    },
  );

  testWidgets(
    'organization handoff opens dedicated switch page and back returns to handoff',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/index': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _profilePayload(
                    organizationId: 'org-current',
                    roleKeys: const <String>['buyer_admin'],
                    certificationStatus: 'not_submitted',
                    membershipStatus: 'active',
                  ),
                );
              },
            },
      );
      final profileIdentityTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/organization/mine':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: <String, Object?>{
                        'items': <Object?>[
                          _organizationItemPayload(
                            organizationId: 'org-current',
                            name: '重庆坤特展览展示有限公司',
                            organizationType: 'both',
                            roleKeys: const <String>['buyer_admin'],
                            membershipStatus: 'active',
                            certificationStatus: 'not_submitted',
                            current: true,
                          ),
                          _organizationItemPayload(
                            organizationId: 'org-platform',
                            name: 'Smoke Admin Review P0 Platform Org',
                            organizationType: 'platform',
                            roleKeys: const <String>['platform_reviewer'],
                            membershipStatus: 'active',
                            certificationStatus: 'not_submitted',
                            current: false,
                          ),
                          _organizationItemPayload(
                            organizationId: 'org-supplier',
                            name: '我的公司',
                            organizationType: 'supplier',
                            roleKeys: const <String>['supplier_admin'],
                            membershipStatus: 'active',
                            certificationStatus: 'approved',
                            current: false,
                          ),
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
                        'organizationId': 'org-current',
                        'certificationStatus': 'not_submitted',
                        'legalName': '重庆坤特展览展示有限公司',
                        'uscc': '91500105MA5U58K346',
                        'legalPerson': '王巍威',
                        'businessType': '有限责任公司',
                        'address': '重庆市江北区洋河二村73号1幢20-7',
                        'registeredCapital': '壹佰万元整',
                        'establishedAt': '2016-03-30',
                        'businessTerm': '2016年03月30日至永久',
                        'businessScope': '展览展示服务',
                      },
                    );
                  },
            },
      );

      await tester.pumpWidget(
        _buildProfileApp(
          transport: transport,
          profileIdentityTransport: profileIdentityTransport,
          initialRoute: ProfileIdentityRoutes.organizationHandoff,
          shellContext: _shellContextData(
            organizationId: 'org-current',
            roleKeys: const <String>['buyer_admin'],
            certificationStatus: 'not_submitted',
            membershipStatus: 'active',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('正式认证资料'), findsOneWidget);
      expect(find.text('认证主体：重庆坤特展览展示有限公司'), findsOneWidget);
      await scrollTo(
        tester,
        find.byKey(const ValueKey<String>('organization-action-switch')),
      );
      await tester.tap(
        find.byKey(const ValueKey<String>('organization-action-switch')),
      );
      await tester.pumpAndSettle();

      expect(find.text('我的主体列表'), findsOneWidget);
      expect(find.textContaining('当前主体：重庆坤特展览展示有限公司'), findsOneWidget);
      expect(find.text('Smoke Admin Review P0 Platform Org'), findsNothing);
      expect(find.text('我的公司'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();

      expect(find.text('公司与组织'), findsWidgets);
      expect(find.text('我的主体列表'), findsNothing);
      expect(find.text('编辑当前组织'), findsOneWidget);
    },
  );

  testWidgets(
    'organization edit current mode patches current organization and keeps organization type locked',
    (WidgetTester tester) async {
      const organizationId = 'org-edit';
      const membershipStatus = 'active';
      var patchCalled = false;
      String currentName = '重庆博览展示有限公司';
      String currentProvinceCode = '500000';
      String currentCityCode = '500100';
      String currentContactName = '王经理';
      String currentContactMobile = '13900001111';

      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/index': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _profilePayload(
                    organizationId: organizationId,
                    roleKeys: const <String>['buyer_admin'],
                    certificationStatus: 'not_submitted',
                    membershipStatus: membershipStatus,
                  ),
                );
              },
            },
      );
      final shellTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/shell/context': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _shellContextPayload(
                    organizationId: organizationId,
                    roleKeys: const <String>['buyer_admin'],
                    certificationStatus: 'not_submitted',
                    membershipStatus: membershipStatus,
                  ),
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildProfileApp(
          transport: transport,
          initialRoute: ProfileIdentityRoutes.organizationHandoff,
          profileIdentityConsumerLayer: _FakeOrganizationMembersConsumer(
            organizationsLoader: () async =>
                ProfileIdentityResult<MyOrganizationsView>(
                  state: AppPageState.content,
                  method: 'GET',
                  path: '/api/app/profile/organization/mine',
                  data: MyOrganizationsView(
                    items: <MyOrganizationItemView>[
                      MyOrganizationItemView(
                        organizationId: organizationId,
                        name: currentName,
                        organizationType: 'supplier',
                        provinceCode: currentProvinceCode,
                        cityCode: currentCityCode,
                        contactName: currentContactName,
                        contactMobile: currentContactMobile,
                        roleKeys: const <String>['buyer_admin'],
                        membershipStatus: membershipStatus,
                        certificationStatus: 'not_submitted',
                        current: true,
                      ),
                    ],
                  ),
                ),
            certificationLoader: () async =>
                const ProfileIdentityResult<ProfileCertificationCurrentView>(
                  state: AppPageState.notFound,
                  method: 'GET',
                  path: '/api/app/profile/certification/current',
                  message: '当前还没有认证记录。',
                  errorCode: 'PROFILE_CERTIFICATION_UNAVAILABLE',
                ),
            membersLoader: () async =>
                const ProfileIdentityResult<OrganizationMembersView>(
                  state: AppPageState.content,
                  method: 'GET',
                  path: '/api/app/profile/organization/members',
                  data: OrganizationMembersView(
                    items: <OrganizationMemberItemView>[],
                  ),
                ),
            rolePatcher: (String memberId, String roleKey) async =>
                throw UnimplementedError(),
            memberDisabler: (String memberId) async =>
                throw UnimplementedError(),
            organizationUpdater:
                (
                  String name,
                  String provinceCode,
                  String cityCode,
                  String contactName,
                  String contactMobile,
                  String? intro,
                ) async {
                  patchCalled = true;
                  expect(name, '重庆展会新主体');
                  expect(provinceCode, currentProvinceCode);
                  expect(cityCode, currentCityCode);
                  expect(contactName, '李经理');
                  expect(contactMobile, '13900002222');
                  expect(intro, isNull);
                  currentName = name;
                  currentProvinceCode = provinceCode;
                  currentCityCode = cityCode;
                  currentContactName = contactName;
                  currentContactMobile = contactMobile;
                  return const ProfileIdentityResult<ProfileActionAckView>(
                    state: AppPageState.content,
                    method: 'PATCH',
                    path: '/api/app/profile/organization/current',
                    data: ProfileActionAckView(
                      ok: true,
                      traceId: 'org-update-1',
                    ),
                  );
                },
          ),
          shellContextConsumer: AppShellContextConsumer(
            client: AppApiClient(
              config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
              transport: shellTransport,
            ),
          ),
          shellContext: _shellContextData(
            organizationId: organizationId,
            roleKeys: const <String>['buyer_admin'],
            certificationStatus: 'not_submitted',
            membershipStatus: membershipStatus,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('编辑当前组织'), findsOneWidget);
      await scrollTo(
        tester,
        find.byKey(const ValueKey<String>('organization-action-edit')),
      );
      await tester.tap(
        find.byKey(const ValueKey<String>('organization-action-edit')).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('已创建当前组织'), findsOneWidget);
      expect(find.textContaining('组织类型与认证字段已锁定'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsNothing);
      expect(find.textContaining('供应商（已锁定'), findsOneWidget);

      final nameField = tester.widget<TextField>(
        find.widgetWithText(TextField, '组织名称'),
      );
      expect(nameField.controller?.text, currentName);
      expect(find.text('所在省'), findsOneWidget);
      expect(find.text('所在市'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextField, '组织名称'), '重庆展会新主体');
      final contactNameField = find.byWidgetPredicate(
        (Widget widget) =>
            widget is TextField && widget.decoration?.labelText == '联系人',
      );
      final contactMobileField = find.byWidgetPredicate(
        (Widget widget) =>
            widget is TextField && widget.decoration?.labelText == '联系电话',
      );
      await tester.enterText(contactNameField, '李经理');
      await tester.enterText(contactMobileField, '13900002222');
      await scrollTo(tester, find.widgetWithText(FilledButton, '保存修改'));
      await tester.tap(find.widgetWithText(FilledButton, '保存修改'));
      await tester.pumpAndSettle();

      expect(patchCalled, isTrue);
      expect(find.widgetWithText(FilledButton, '保存修改'), findsNothing);
    },
  );

  testWidgets(
    'organization edit current mode keeps certification subject read-only and saves the formal subject name',
    (WidgetTester tester) async {
      const organizationId = 'org-certified';
      const membershipStatus = 'active';
      var patchCalled = false;

      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/index': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _profilePayload(
                    organizationId: organizationId,
                    roleKeys: const <String>['buyer_admin'],
                    certificationStatus: 'approved',
                    membershipStatus: membershipStatus,
                  ),
                );
              },
            },
      );
      final shellTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/shell/context': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _shellContextPayload(
                    organizationId: organizationId,
                    roleKeys: const <String>['buyer_admin'],
                    certificationStatus: 'approved',
                    membershipStatus: membershipStatus,
                  ),
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildProfileApp(
          transport: transport,
          initialRoute: ProfileIdentityRoutes.organizationHandoff,
          profileIdentityConsumerLayer: _FakeOrganizationMembersConsumer(
            organizationsLoader: () async =>
                const ProfileIdentityResult<MyOrganizationsView>(
                  state: AppPageState.content,
                  method: 'GET',
                  path: '/api/app/profile/organization/mine',
                  data: MyOrganizationsView(
                    items: <MyOrganizationItemView>[
                      MyOrganizationItemView(
                        organizationId: organizationId,
                        name: '旧组织名称',
                        organizationType: 'both',
                        provinceCode: '500000',
                        cityCode: '500100',
                        contactName: '王巍威',
                        contactMobile: '18696563700',
                        roleKeys: <String>['buyer_admin'],
                        membershipStatus: membershipStatus,
                        certificationStatus: 'approved',
                        current: true,
                      ),
                    ],
                  ),
                ),
            certificationLoader: () async =>
                const ProfileIdentityResult<ProfileCertificationCurrentView>(
                  state: AppPageState.content,
                  method: 'GET',
                  path: '/api/app/profile/certification/current',
                  data: ProfileCertificationCurrentView(
                    organizationId: organizationId,
                    certificationStatus: 'approved',
                    legalName: '重庆坤特展览展示有限公司',
                    uscc: '91500105MA5U58K346',
                    legalPerson: '王巍威',
                    businessType: '有限责任公司',
                    address: '重庆市江北区洋河二村73号1幢20-7',
                    registeredCapital: '壹佰万元整',
                    establishedAt: '2016-03-30',
                    businessTerm: '2016年03月30日至永久',
                    businessScope: '展览展示服务',
                  ),
                ),
            membersLoader: () async =>
                const ProfileIdentityResult<OrganizationMembersView>(
                  state: AppPageState.content,
                  method: 'GET',
                  path: '/api/app/profile/organization/members',
                  data: OrganizationMembersView(
                    items: <OrganizationMemberItemView>[],
                  ),
                ),
            rolePatcher: (String memberId, String roleKey) async =>
                throw UnimplementedError(),
            memberDisabler: (String memberId) async =>
                throw UnimplementedError(),
            organizationUpdater:
                (
                  String name,
                  String provinceCode,
                  String cityCode,
                  String contactName,
                  String contactMobile,
                  String? intro,
                ) async {
                  patchCalled = true;
                  expect(name, '重庆坤特展览展示有限公司');
                  expect(provinceCode, '500000');
                  expect(cityCode, '500100');
                  expect(contactName, '王巍威');
                  expect(contactMobile, '18696563700');
                  expect(intro, isNull);
                  return const ProfileIdentityResult<ProfileActionAckView>(
                    state: AppPageState.content,
                    method: 'PATCH',
                    path: '/api/app/profile/organization/current',
                    data: ProfileActionAckView(
                      ok: true,
                      traceId: 'org-update-certified-1',
                    ),
                  );
                },
          ),
          shellContextConsumer: AppShellContextConsumer(
            client: AppApiClient(
              config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
              transport: shellTransport,
            ),
          ),
          shellContext: _shellContextData(
            organizationId: organizationId,
            roleKeys: const <String>['buyer_admin'],
            certificationStatus: 'approved',
            membershipStatus: membershipStatus,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await scrollTo(
        tester,
        find.byKey(const ValueKey<String>('organization-action-edit')),
      );
      await tester.tap(
        find.byKey(const ValueKey<String>('organization-action-edit')).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('认证主体信息'), findsOneWidget);
      expect(find.widgetWithText(TextField, '组织名称'), findsNothing);
      expect(find.text('认证主体：重庆坤特展览展示有限公司'), findsOneWidget);
      expect(find.text('统一社会信用代码：91500105MA5U58K346'), findsOneWidget);
      expect(find.text('住所：重庆市江北区洋河二村73号1幢20-7'), findsOneWidget);
      expect(find.textContaining('如需修改，请走“更正认证资料”'), findsOneWidget);
      await scrollTo(tester, find.widgetWithText(FilledButton, '保存修改'));
      await tester.tap(find.widgetWithText(FilledButton, '保存修改'));
      await tester.pumpAndSettle();

      expect(patchCalled, isTrue);
    },
  );

  testWidgets(
    'organization create another mode keeps create flow even when current organization exists',
    (WidgetTester tester) async {
      const organizationId = 'org-edit';

      await tester.pumpWidget(
        _buildProfileApp(
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
                      body: _profilePayload(
                        organizationId: organizationId,
                        roleKeys: const <String>['buyer_admin'],
                        certificationStatus: 'not_submitted',
                        membershipStatus: 'active',
                      ),
                    );
                  },
                },
          ),
          initialRoute: '/profile/organization/create?mode=create_another',
          profileIdentityTransport: FakeAppApiTransport(
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
                          body: <String, Object?>{
                            'items': <Object?>[
                              _organizationItemPayload(
                                organizationId: organizationId,
                                name: '重庆博览展示有限公司',
                                organizationType: 'supplier',
                                roleKeys: const <String>['buyer_admin'],
                                membershipStatus: 'active',
                                certificationStatus: 'not_submitted',
                                current: true,
                              ),
                            ],
                          },
                        );
                      },
                  'GET /api/app/profile/certification/current':
                      (AppApiRequest request) async {
                        return AppApiResponse(
                          statusCode: 404,
                          uri: request.uri,
                          body: const <String, Object?>{
                            'code': 'PROFILE_CERTIFICATION_UNAVAILABLE',
                            'message': '当前还没有认证记录。',
                          },
                        );
                      },
                },
          ),
          shellContext: _shellContextData(
            organizationId: organizationId,
            roleKeys: const <String>['buyer_admin'],
            certificationStatus: 'not_submitted',
            membershipStatus: 'active',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('再创建一个组织'), findsOneWidget);
      expect(find.textContaining('“再创建一个组织”模式'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '返回编辑当前组织'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '创建组织'), findsOneWidget);
    },
  );

  testWidgets(
    'organization switch success read-back keeps hub, company and identity on the new organization scope',
    (WidgetTester tester) async {
      const staleOrganizationId = 'org-a';
      const freshOrganizationId = 'org-b';
      const membershipStatus = 'active';
      const roleKeys = <String>['buyer_admin'];

      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/index': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _profilePayload(
                    organizationId: freshOrganizationId,
                    roleKeys: roleKeys,
                    certificationStatus: 'pending_review',
                    membershipStatus: membershipStatus,
                  ),
                );
              },
            },
      );
      final profileIdentityTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/organization/mine':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: <String, Object?>{
                        'items': <Object?>[
                          _organizationItemPayload(
                            organizationId: 'org-a',
                            name: '上海当前组织',
                            organizationType: 'supplier',
                            roleKeys: roleKeys,
                            membershipStatus: membershipStatus,
                            certificationStatus: 'approved',
                            current: false,
                          ),
                          _organizationItemPayload(
                            organizationId: freshOrganizationId,
                            name: '北京切换后组织',
                            organizationType: 'demand',
                            roleKeys: roleKeys,
                            membershipStatus: membershipStatus,
                            certificationStatus: 'pending_review',
                            current: true,
                          ),
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
                        'organizationId': freshOrganizationId,
                        'certificationStatus': 'pending_review',
                        'submittedAt': '2026-04-02 10:00',
                      },
                    );
                  },
            },
      );

      ExhibitionMobileApp buildApp() {
        return _buildProfileApp(
          transport: transport,
          profileIdentityTransport: profileIdentityTransport,
          shellContext: _shellContextData(
            organizationId: staleOrganizationId,
            roleKeys: roleKeys,
            certificationStatus: 'approved',
            membershipStatus: membershipStatus,
          ),
        );
      }

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('我的公司'), findsWidgets);
      await scrollTo(tester, find.text('我的公司'));
      await tester.tap(find.text('我的公司').first);
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('公司认证与我的身份'));
      await tester.tap(find.text('公司认证与我的身份'));
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('当前认证状态'));
      expect(find.text('认证中'), findsWidgets);

      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.pageBack();
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('我的公司'));
      await tester.tap(find.text('我的公司').first);
      await tester.pumpAndSettle();

      expect(find.text('功能状态'), findsNothing);
      expect(find.text('当前公司/组织现状'), findsNothing);
      expect(find.text('认证资料'), findsNothing);
      expect(find.text('认证状态'), findsNothing);
      expect(find.textContaining('认证'), findsWidgets);
    },
  );

  testWidgets(
    'certification submit happy path uploads license then submits with confirmed fileAssetId',
    (WidgetTester tester) async {
      const organizationId = 'org-submit';
      const currentMembershipStatus = 'active';
      String currentCertificationStatus = 'not_submitted';

      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/index': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _profilePayload(
                    organizationId: organizationId,
                    roleKeys: const <String>['buyer_admin'],
                    certificationStatus: currentCertificationStatus,
                    membershipStatus: currentMembershipStatus,
                  ),
                );
              },
            },
      );
      final profileIdentityTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/organization/mine':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: <String, Object?>{
                        'items': <Object?>[
                          _organizationItemPayload(
                            organizationId: organizationId,
                            name: '上海待认证组织',
                            organizationType: 'supplier',
                            roleKeys: const <String>['buyer_admin'],
                            membershipStatus: currentMembershipStatus,
                            certificationStatus: currentCertificationStatus,
                            current: true,
                          ),
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
                        'organizationId': organizationId,
                        'certificationStatus': currentCertificationStatus,
                        'submittedAt': '2026-04-03 09:00',
                      },
                    );
                  },
              'POST /api/app/file/upload/init': (AppApiRequest request) async {
                expect(request.body, isA<Map<String, Object?>>());
                final body = request.body! as Map<String, Object?>;
                expect(body['businessType'], 'profile');
                expect(body['businessId'], organizationId);
                expect(body['fileKind'], 'business_license');
                expect(body['mimeType'], 'image/png');
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'uploadSessionId': 'cert-upload-submit-1',
                    'directUpload': <String, Object?>{
                      'url': 'https://oss.example.com/cert-upload-submit-1',
                      'method': 'PUT',
                      'headers': <String, Object?>{'content-type': 'image/png'},
                    },
                    'confirm': <String, Object?>{
                      'endpoint': '/api/app/file/upload/confirm',
                    },
                  },
                );
              },
              'POST /api/app/file/upload/confirm':
                  (AppApiRequest request) async {
                    expect(request.body, const <String, Object?>{
                      'uploadSessionId': 'cert-upload-submit-1',
                    });
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'fileAssetId': 'file-asset-cert-submit-1',
                      },
                    );
                  },
              'POST /api/app/profile/certification/license/ocr':
                  (AppApiRequest request) async {
                    expect(request.body, const <String, Object?>{
                      'organizationId': organizationId,
                      'licenseFileId': 'file-asset-cert-submit-1',
                    });
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'status': 'recognized',
                        'message': '当前已完成营业执照 OCR 识别，认证主体和统一社会信用代码已自动回填。',
                        'legalName': '上海待认证组织',
                        'uscc': '91310000123456789A',
                        'legalPerson': '张三',
                        'businessType': '有限责任公司',
                        'address': '重庆市江北区洋河二村73号1幢20-7',
                        'registeredCapital': '壹佰万元整',
                        'establishedAt': '2016年03月30日',
                        'businessTerm': '2016年03月30日至永久',
                        'businessScope': '展览展示服务',
                        'providerRequestId': 'ocr-submit-1',
                      },
                    );
                  },
              'POST /api/app/profile/certification/submit':
                  (AppApiRequest request) async {
                    expect(request.body, const <String, Object?>{
                      'organizationId': organizationId,
                      'legalName': '上海待认证组织',
                      'uscc': '91310000123456789A',
                      'licenseFileId': 'file-asset-cert-submit-1',
                      'contactName': '张三',
                      'contactMobile': '13800000000',
                    });
                    currentCertificationStatus = 'approved';
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'organizationId': organizationId,
                        'certificationStatus': 'approved',
                        'submittedAt': '2026-04-05 10:10',
                        'traceId': 'cert-submit-1',
                      },
                    );
                  },
            },
        uploadHandler: (AppApiUploadRequest request) async {
          expect(request.method, 'PUT');
          expect(request.url, 'https://oss.example.com/cert-upload-submit-1');
          expect(request.headers['content-type'], 'image/png');
          expect(request.bodyBytes, _tinyPngBytes);
          return AppApiResponse(statusCode: 200, uri: Uri.parse(request.url));
        },
      );
      ProfileAvatarPicker.install(
        _FakeProfileAvatarPicker(
          result: ProfileAvatarPickResult.selected(
            ProfileAvatarPickedFile(
              fileName: 'license-submit.png',
              mimeType: 'image/png',
              bytes: _tinyPngBytes,
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        _buildProfileApp(
          transport: transport,
          profileIdentityTransport: profileIdentityTransport,
          initialRoute: '/profile/certification/submit',
          shellContext: _shellContextData(
            organizationId: organizationId,
            roleKeys: const <String>['buyer_admin'],
            certificationStatus: currentCertificationStatus,
            membershipStatus: currentMembershipStatus,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(
          '当前认证只接收 1 张营业执照图片。请先选择并确认上传，上传完成后会自动尝试 OCR 识别、展示营业执照摘要并回填认证主体与统一社会信用代码；提交认证后会基于 OCR 自动核验，符合直接通过，不符合直接打回。',
        ),
        findsOneWidget,
      );
      await tester.enterText(find.widgetWithText(TextField, '联系人'), '张三');
      await tester.enterText(
        find.widgetWithText(TextField, '联系电话'),
        '13800000000',
      );
      await scrollTo(tester, find.widgetWithText(FilledButton, '选择营业执照'));
      await tester.tap(find.widgetWithText(FilledButton, '选择营业执照'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('从相册选择'));
      await tester.pumpAndSettle();
      expect(find.text('营业执照待上传'), findsNothing);
      expect(find.text('点击图片可放大查看完整营业执照。'), findsOneWidget);
      await tester.tap(find.text('点击图片可放大查看完整营业执照。'));
      await tester.pumpAndSettle();
      expect(find.text('再次点击图片可恢复常规预览。'), findsOneWidget);
      await scrollTo(tester, find.widgetWithText(FilledButton, '确认上传营业执照'));
      await tester.tap(find.widgetWithText(FilledButton, '确认上传营业执照'));
      await tester.pumpAndSettle();

      expect(find.text('营业执照已完成上传绑定'), findsNothing);
      expect(find.text('营业执照 OCR 已完成'), findsNothing);
      expect(find.text('法定代表人'), findsOneWidget);
      expect(find.text('有限责任公司'), findsOneWidget);
      expect(find.text('展览展示服务'), findsOneWidget);
      expect(find.text('营业执照文件 ID'), findsNothing);
      expect(find.byType(Image), findsWidgets);
      final legalNameField = tester.widget<TextField>(
        find.widgetWithText(TextField, '认证主体'),
      );
      final usccField = tester.widget<TextField>(
        find.widgetWithText(TextField, '统一社会信用代码'),
      );
      expect(legalNameField.controller?.text, '上海待认证组织');
      expect(usccField.controller?.text, '91310000123456789A');

      await scrollTo(tester, find.widgetWithText(FilledButton, '提交认证'));
      await tester.tap(find.widgetWithText(FilledButton, '提交认证'));
      await tester.pumpAndSettle();

      expect(find.text('认证提交当前未完成'), findsNothing);
      expect(
        profileIdentityTransport.requests
            .map((AppApiRequest request) => request.canonicalPath)
            .where((String path) => path == '/api/app/file/upload/init')
            .length,
        1,
      );
      expect(
        profileIdentityTransport.requests
            .map((AppApiRequest request) => request.canonicalPath)
            .where((String path) => path == '/api/app/file/upload/confirm')
            .length,
        1,
      );
      expect(
        profileIdentityTransport.requests
            .map((AppApiRequest request) => request.canonicalPath)
            .where(
              (String path) => path == '/api/app/profile/certification/submit',
            )
            .length,
        1,
      );
    },
  );

  testWidgets(
    'certification submit keeps controlled failure when upload init fails',
    (WidgetTester tester) async {
      ProfileAvatarPicker.install(
        _FakeProfileAvatarPicker(
          result: ProfileAvatarPickResult.selected(
            ProfileAvatarPickedFile(
              fileName: 'license-init-failure.png',
              mimeType: 'image/png',
              bytes: _tinyPngBytes,
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        _buildProfileApp(
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
                      body: _profilePayload(
                        organizationId: 'org-submit-failure',
                        certificationStatus: 'not_submitted',
                        membershipStatus: 'active',
                      ),
                    );
                  },
                },
          ),
          initialRoute: '/profile/certification/submit',
          profileIdentityTransport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'POST /api/app/file/upload/init':
                      (AppApiRequest request) async => AppApiResponse(
                        statusCode: 409,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'message': '当前营业执照上传入口暂不可用，请稍后再试。',
                        },
                      ),
                },
          ),
          shellContext: AppShellContextData(
            userId: '13812345678',
            organizationId: 'org-submit-failure',
            certificationStatus: 'not_submitted',
            membershipStatus: 'active',
            visibleBuildings: const <String>[
              'exhibition',
              'messages',
              'profile',
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await scrollTo(tester, find.widgetWithText(FilledButton, '选择营业执照'));
      await tester.tap(find.widgetWithText(FilledButton, '选择营业执照'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('从相册选择'));
      await tester.pumpAndSettle();
      await scrollTo(tester, find.widgetWithText(FilledButton, '确认上传营业执照'));
      await tester.tap(find.widgetWithText(FilledButton, '确认上传营业执照'));
      await tester.pumpAndSettle();

      expect(find.text('营业执照上传当前未开始'), findsOneWidget);
      expect(find.text('当前营业执照上传入口暂不可用，请稍后再试。'), findsOneWidget);
      expect(find.text('营业执照文件 ID'), findsNothing);
    },
  );

  testWidgets('session center stays local-only and hides device management', (
    WidgetTester tester,
  ) async {
    final profileIdentityTransport = FakeAppApiTransport(
      handlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/profile/security/devices':
                (AppApiRequest request) async {
                  fail('session center must not load device list in P1 mode');
                },
            'POST /api/app/profile/security/devices/device-2/revoke':
                (AppApiRequest request) async {
                  fail('session center must not revoke devices in P1 mode');
                },
          },
    );

    await tester.pumpWidget(
      _buildProfileApp(
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'GET /api/app/profile/index': (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: _profilePayload(
                      organizationId: 'org-sec',
                      certificationStatus: 'approved',
                      membershipStatus: 'active',
                    ),
                  );
                },
              },
        ),
        initialRoute: '/profile/session',
        profileIdentityTransport: profileIdentityTransport,
        shellContext: AppShellContextData(
          userId: '13812345678',
          organizationId: 'org-sec',
          certificationStatus: 'approved',
          membershipStatus: 'active',
          visibleBuildings: const <String>['exhibition', 'messages', 'profile'],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('会话与设备'), findsWidgets);
    expect(find.text('当前仅展示本机登录状态，其他设备管理暂不开放。'), findsOneWidget);
    expect(find.text('本机信息'), findsOneWidget);
    expect(find.text('登录凭证'), findsOneWidget);
    expect(find.text('续期状态'), findsOneWidget);
    expect(find.text('当前 iPhone'), findsNothing);
    expect(find.text('备用 Android'), findsNothing);
    expect(find.widgetWithText(FilledButton, '撤销此设备'), findsNothing);
    expect(profileIdentityTransport.requests, isEmpty);
  });

  testWidgets(
    'session center does not surface revoke failure path in p1 mode',
    (WidgetTester tester) async {
      final profileIdentityTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/security/devices':
                  (AppApiRequest request) async {
                    fail('session center must not load device list in P1 mode');
                  },
              'POST /api/app/profile/security/devices/device-3/revoke':
                  (AppApiRequest request) async {
                    fail('session center must not revoke devices in P1 mode');
                  },
            },
      );

      await tester.pumpWidget(
        _buildProfileApp(
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
                      body: _profilePayload(
                        organizationId: 'org-sec',
                        certificationStatus: 'approved',
                        membershipStatus: 'active',
                      ),
                    );
                  },
                },
          ),
          initialRoute: '/profile/session',
          profileIdentityTransport: profileIdentityTransport,
          shellContext: AppShellContextData(
            userId: '13812345678',
            organizationId: 'org-sec',
            certificationStatus: 'approved',
            membershipStatus: 'active',
            visibleBuildings: const <String>[
              'exhibition',
              'messages',
              'profile',
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('设备撤销当前未完成'), findsNothing);
      expect(find.text('当前设备撤销目标不一致，请刷新后再试。'), findsNothing);
      expect(find.widgetWithText(FilledButton, '撤销此设备'), findsNothing);
      await scrollTo(tester, find.text('安全操作'));
      expect(find.text('其他设备暂不展示；退出登录请回到设置页完成二次确认。'), findsOneWidget);
      expect(profileIdentityTransport.requests, isEmpty);
    },
  );

  testWidgets(
    'organization members sheet consumes list and reloads truth after role change and disable success',
    (WidgetTester tester) async {
      final members = <OrganizationMemberItemView>[
        const OrganizationMemberItemView(
          memberId: 'member-1',
          userId: 'user-1',
          displayName: '张三',
          mobileMasked: '138****1111',
          roleKey: 'buyer_admin',
          memberStatus: 'invited',
          joinedAt: '2026-04-01 09:00',
        ),
        const OrganizationMemberItemView(
          memberId: 'member-2',
          userId: 'user-2',
          displayName: '李四',
          mobileMasked: '138****2222',
          roleKey: 'buyer_member(scoped)',
          memberStatus: 'active',
          joinedAt: '2026-04-02 10:00',
        ),
      ];

      await tester.pumpWidget(
        _buildProfileApp(
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
                      body: _profilePayload(
                        organizationId: 'org-members',
                        roleKeys: const <String>['buyer_admin'],
                        certificationStatus: 'approved',
                        membershipStatus: 'active',
                      ),
                    );
                  },
                },
          ),
          initialRoute: '/profile/company',
          profileIdentityConsumerLayer: _FakeOrganizationMembersConsumer(
            organizationsLoader: () async =>
                ProfileIdentityResult<MyOrganizationsView>(
                  state: AppPageState.content,
                  method: 'GET',
                  path: '/api/app/profile/organization/mine',
                  data: MyOrganizationsView(
                    items: const <MyOrganizationItemView>[
                      MyOrganizationItemView(
                        organizationId: 'org-members',
                        name: '上海展建服务有限公司',
                        organizationType: 'supplier',
                        roleKeys: <String>['buyer_admin'],
                        membershipStatus: 'active',
                        certificationStatus: 'approved',
                        current: true,
                      ),
                    ],
                  ),
                ),
            certificationLoader: () async =>
                const ProfileIdentityResult<ProfileCertificationCurrentView>(
                  state: AppPageState.content,
                  method: 'GET',
                  path: '/api/app/profile/certification/current',
                  data: ProfileCertificationCurrentView(
                    organizationId: 'org-members',
                    certificationStatus: 'approved',
                    legalName: '上海展建服务有限公司',
                    uscc: '91310000123456789A',
                    submittedAt: '2026-04-01 08:00',
                  ),
                ),
            membersLoader: () async =>
                ProfileIdentityResult<OrganizationMembersView>(
                  state: AppPageState.content,
                  method: 'GET',
                  path: '/api/app/profile/organization/members',
                  data: OrganizationMembersView(
                    items: List<OrganizationMemberItemView>.unmodifiable(
                      members,
                    ),
                  ),
                ),
            rolePatcher: (String memberId, String roleKey) async {
              expect(memberId, 'member-2');
              expect(roleKey, 'supplier_admin');
              members[1] = const OrganizationMemberItemView(
                memberId: 'member-2',
                userId: 'user-2',
                displayName: '李四',
                mobileMasked: '138****2222',
                roleKey: 'supplier_admin',
                memberStatus: 'active',
                joinedAt: '2026-04-02 10:00',
              );
              return const ProfileIdentityResult<ProfileActionAckView>(
                state: AppPageState.content,
                method: 'PATCH',
                path: '/api/app/profile/organization/members/member-2/role',
                data: ProfileActionAckView(ok: true, traceId: 'member-role-1'),
              );
            },
            memberDisabler: (String memberId) async {
              expect(memberId, 'member-2');
              members[1] = const OrganizationMemberItemView(
                memberId: 'member-2',
                userId: 'user-2',
                displayName: '李四',
                mobileMasked: '138****2222',
                roleKey: 'supplier_admin',
                memberStatus: 'disabled',
                joinedAt: '2026-04-02 10:00',
                disabledAt: '2026-04-05 14:30',
              );
              return const ProfileIdentityResult<ProfileActionAckView>(
                state: AppPageState.content,
                method: 'PATCH',
                path: '/api/app/profile/organization/members/member-2/disable',
                data: ProfileActionAckView(
                  ok: true,
                  traceId: 'member-disable-1',
                ),
              );
            },
          ),
          shellContext: _shellContextData(
            organizationId: 'org-members',
            roleKeys: const <String>['buyer_admin'],
            certificationStatus: 'approved',
            membershipStatus: 'active',
          ),
        ),
      );
      await tester.pumpAndSettle();

      showOrganizationMembersSheet(tester.element(find.byType(Scaffold).first));
      await tester.pumpAndSettle();

      expect(find.text('张三'), findsOneWidget);
      expect(find.text('李四'), findsOneWidget);
      expect(find.text('需求成员'), findsOneWidget);
      expect(find.textContaining('启用中'), findsWidgets);

      await tester.scrollUntilVisible(
        find.text('需求成员').last,
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('需求成员').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('供应商管理员').last);
      await tester.pumpAndSettle();

      expect(find.text('角色已刷新'), findsOneWidget);
      expect(find.textContaining('traceId member-role-1'), findsOneWidget);
      expect(find.text('供应商管理员'), findsWidgets);

      await tester.tap(find.widgetWithText(OutlinedButton, '禁用成员'));
      await tester.pumpAndSettle();

      expect(find.text('成员状态已刷新'), findsOneWidget);
      expect(find.textContaining('traceId member-disable-1'), findsOneWidget);
      expect(find.textContaining('已禁用'), findsWidgets);
      expect(find.textContaining('禁用时间'), findsOneWidget);
      expect(find.textContaining('2026-04-05 14:30'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, '禁用成员'), findsNothing);
    },
  );

  testWidgets(
    'organization members sheet keeps controlled failure when role patch fails',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildProfileApp(
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
                      body: _profilePayload(
                        organizationId: 'org-members',
                        roleKeys: const <String>['buyer_admin'],
                        certificationStatus: 'approved',
                        membershipStatus: 'active',
                      ),
                    );
                  },
                },
          ),
          initialRoute: '/profile/certification/current',
          profileIdentityConsumerLayer: _FakeOrganizationMembersConsumer(
            organizationsLoader: () async =>
                ProfileIdentityResult<MyOrganizationsView>(
                  state: AppPageState.content,
                  method: 'GET',
                  path: '/api/app/profile/organization/mine',
                  data: MyOrganizationsView(
                    items: const <MyOrganizationItemView>[
                      MyOrganizationItemView(
                        organizationId: 'org-members',
                        name: '上海展建服务有限公司',
                        organizationType: 'supplier',
                        roleKeys: <String>['buyer_admin'],
                        membershipStatus: 'active',
                        certificationStatus: 'approved',
                        current: true,
                      ),
                    ],
                  ),
                ),
            certificationLoader: () async =>
                const ProfileIdentityResult<ProfileCertificationCurrentView>(
                  state: AppPageState.content,
                  method: 'GET',
                  path: '/api/app/profile/certification/current',
                  data: ProfileCertificationCurrentView(
                    organizationId: 'org-members',
                    certificationStatus: 'approved',
                  ),
                ),
            membersLoader: () async =>
                const ProfileIdentityResult<OrganizationMembersView>(
                  state: AppPageState.content,
                  method: 'GET',
                  path: '/api/app/profile/organization/members',
                  data: OrganizationMembersView(
                    items: <OrganizationMemberItemView>[
                      OrganizationMemberItemView(
                        memberId: 'member-2',
                        userId: 'user-2',
                        displayName: '李四',
                        mobileMasked: '138****2222',
                        roleKey: 'buyer_member(scoped)',
                        memberStatus: 'active',
                        joinedAt: '2026-04-02 10:00',
                      ),
                    ],
                  ),
                ),
            rolePatcher: (String memberId, String roleKey) async {
              expect(memberId, 'member-2');
              expect(roleKey, 'supplier_admin');
              return const ProfileIdentityResult<ProfileActionAckView>(
                state: AppPageState.errorNonRetryable,
                method: 'PATCH',
                path: '/api/app/profile/organization/members/member-2/role',
                message: '当前成员角色不在本轮允许范围内，请重新选择后再试。',
                errorCode: 'ORG_MEMBER_ROLE_INVALID',
              );
            },
            memberDisabler: (String memberId) async =>
                throw UnimplementedError(),
          ),
          shellContext: _shellContextData(
            organizationId: 'org-members',
            roleKeys: const <String>['buyer_admin'],
            certificationStatus: 'approved',
            membershipStatus: 'active',
          ),
        ),
      );
      await tester.pumpAndSettle();

      showOrganizationMembersSheet(tester.element(find.byType(Scaffold).first));
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('李四'));
      await tester.tap(find.text('需求成员').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('供应商管理员').last);
      await tester.pumpAndSettle();

      expect(find.text('角色调整当前未完成'), findsOneWidget);
      expect(find.text('当前成员角色不在本轮允许范围内，请重新选择后再试。'), findsOneWidget);
      expect(find.textContaining('启用中'), findsWidgets);
      expect(find.widgetWithText(OutlinedButton, '禁用成员'), findsOneWidget);
    },
  );

  testWidgets(
    'organization join success refreshes hub, company and identity from app-facing truth',
    (WidgetTester tester) async {
      String currentOrganizationId = 'org-old';
      String currentOrganizationName = '上海旧组织';
      String currentOrganizationType = 'supplier';
      List<String> currentRoleKeys = const <String>['buyer_admin'];
      String currentMembershipStatus = 'active';
      String currentCertificationStatus = 'approved';

      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/index': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _profilePayload(
                    organizationId: currentOrganizationId,
                    roleKeys: currentRoleKeys,
                    certificationStatus: currentCertificationStatus,
                    membershipStatus: currentMembershipStatus,
                  ),
                );
              },
            },
      );
      final profileIdentityTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/organization/mine':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: <String, Object?>{
                        'items': <Object?>[
                          _organizationItemPayload(
                            organizationId: currentOrganizationId,
                            name: currentOrganizationName,
                            organizationType: currentOrganizationType,
                            roleKeys: currentRoleKeys,
                            membershipStatus: currentMembershipStatus,
                            certificationStatus: currentCertificationStatus,
                            current: true,
                          ),
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
                        'organizationId': currentOrganizationId,
                        'certificationStatus': currentCertificationStatus,
                        'submittedAt': '2026-04-03 09:00',
                      },
                    );
                  },
              'POST /api/app/profile/organization/join-by-code':
                  (AppApiRequest request) async {
                    currentOrganizationId = 'org-join-1';
                    currentOrganizationName = '北京加入后组织';
                    currentOrganizationType = 'both';
                    currentRoleKeys = const <String>['buyer_admin'];
                    currentMembershipStatus = 'active';
                    currentCertificationStatus = 'approved';
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'organizationId': 'org-join-1',
                        'membershipStatus': 'active',
                        'traceId': 'join-trace-1',
                      },
                    );
                  },
            },
      );
      final shellTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/shell/context': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _shellContextPayload(
                    organizationId: currentOrganizationId,
                    roleKeys: currentRoleKeys,
                    certificationStatus: currentCertificationStatus,
                    membershipStatus: currentMembershipStatus,
                  ),
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildProfileApp(
          transport: transport,
          profileIdentityTransport: profileIdentityTransport,
          shellContextConsumer: AppShellContextConsumer(
            client: AppApiClient(
              config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
              transport: shellTransport,
            ),
          ),
          shellContext: _shellContextData(
            organizationId: 'org-old',
            roleKeys: const <String>['buyer_admin'],
            certificationStatus: 'approved',
            membershipStatus: 'active',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('我的公司'));
      await tester.tap(find.text('我的公司').first);
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('公司与组织'));
      await tester.tap(find.text('公司与组织').first);
      await tester.pumpAndSettle();

      await scrollTo(
        tester,
        find.byKey(const ValueKey<String>('organization-action-join')),
      );
      await tester.tap(
        find.byKey(const ValueKey<String>('organization-action-join')).first,
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextField, '邀请码'), 'JOIN-001');
      await tester.tap(find.widgetWithText(FilledButton, '加入组织'));
      await tester.pumpAndSettle();

      if (find.text('北京加入后组织').evaluate().isEmpty) {
        await tester.pageBack();
        await tester.pumpAndSettle();
      }
      if (find.text('北京加入后组织').evaluate().isEmpty) {
        await scrollTo(tester, find.text('我的公司'));
        await tester.tap(find.text('我的公司').first);
        await tester.pumpAndSettle();
      }

      expect(find.textContaining('已认证'), findsWidgets);
      expect(find.text('北京加入后组织'), findsWidgets);
      expect(find.text('功能状态'), findsNothing);
      expect(find.text('当前公司/组织现状'), findsNothing);
      expect(find.text('认证资料'), findsNothing);
      expect(find.text('认证状态'), findsNothing);
      expect(find.text('已认证'), findsWidgets);

      if (find.text('公司认证与我的身份').evaluate().isEmpty) {
        await tester.pageBack();
        await tester.pumpAndSettle();
      }
      await scrollTo(tester, find.text('公司认证与我的身份'));
      await tester.tap(find.text('公司认证与我的身份').first);
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('当前认证状态'));
      expect(find.text('北京加入后组织'), findsWidgets);
      expect(find.text('已认证'), findsWidgets);
    },
  );

  testWidgets(
    'organization join shows controlled upstream failure when invite code is invalid',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildProfileApp(
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
                      body: _profilePayload(),
                    );
                  },
                },
          ),
          initialRoute: '/profile/organization/join',
          profileIdentityTransport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'POST /api/app/profile/organization/join-by-code':
                      (AppApiRequest request) async {
                        return AppApiResponse(
                          statusCode: 409,
                          uri: request.uri,
                          body: const <String, Object?>{
                            'code': 'PROFILE_ORGANIZATION_INVITE_INVALID',
                            'message': '当前邀请码无效，请确认后再试。',
                          },
                        );
                      },
                },
          ),
          shellContext: AppShellContextData.bootstrapDefaults(
            manifest: AppConfigManifest.bootstrapDefaults(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextField, '邀请码'), 'BAD-CODE');
      await tester.tap(find.widgetWithText(FilledButton, '加入组织'));
      await tester.pumpAndSettle();

      expect(find.text('加入当前未完成'), findsOneWidget);
      expect(find.text('当前邀请码无效，请确认后再试。'), findsOneWidget);
    },
  );

  testWidgets(
    'certification current page separates status from formal certification truth fields',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/index': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _profilePayload(
                    organizationId: 'org-approved-rich',
                    certificationStatus: 'approved',
                    membershipStatus: 'active',
                  ),
                );
              },
            },
      );
      final profileIdentityTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/organization/mine':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'items': <Object?>[
                          <String, Object?>{
                            'organizationId': 'org-approved-rich',
                            'name': '上海展建服务有限公司',
                            'organizationType': 'supplier',
                            'roleKeys': <Object?>['buyer_admin'],
                            'membershipStatus': 'active',
                            'certificationStatus': 'approved',
                            'current': true,
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
                        'organizationId': 'org-approved-rich',
                        'certificationStatus': 'approved',
                        'legalName': '上海展建服务有限公司',
                        'uscc': '91310000123456789A',
                        'legalPerson': '张三',
                        'businessType': '有限责任公司',
                        'address': '上海市徐汇区漕溪北路 398 号',
                        'registeredCapital': '壹佰万元整',
                        'establishedAt': '2016-03-30',
                        'businessTerm': '2016-03-30 至长期',
                        'businessScope': '展览展示服务',
                        'submittedAt': '2026-04-05 10:10',
                      },
                    );
                  },
            },
      );

      await tester.pumpWidget(
        _buildProfileApp(
          transport: transport,
          initialRoute: '/profile/certification/current',
          profileIdentityTransport: profileIdentityTransport,
          shellContext: AppShellContextData(
            userId: '13812345678',
            organizationId: 'org-approved-rich',
            certificationStatus: 'approved',
            membershipStatus: 'active',
            visibleBuildings: const <String>[
              'exhibition',
              'messages',
              'profile',
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('当前认证状态'));
      expect(find.text('当前认证状态'), findsOneWidget);
      expect(find.text('上海展建服务有限公司'), findsWidgets);
      expect(find.text('org-approved-rich'), findsNothing);
      expect(find.text('提交时间'), findsOneWidget);
      await scrollTo(tester, find.text('正式认证资料'));
      expect(find.text('正式认证资料'), findsOneWidget);
      expect(find.text('法定代表人'), findsOneWidget);
      expect(find.text('张三'), findsOneWidget);
      expect(find.text('企业类型'), findsOneWidget);
      expect(find.text('有限责任公司'), findsOneWidget);
      expect(find.text('住所'), findsOneWidget);
      expect(find.text('上海市徐汇区漕溪北路 398 号'), findsOneWidget);
      expect(find.text('成立日期'), findsOneWidget);
      expect(find.text('2016-03-30'), findsOneWidget);
      expect(find.text('经营范围'), findsOneWidget);
      expect(find.text('展览展示服务'), findsOneWidget);
    },
  );

  testWidgets(
    'certification current page surfaces personal certification truth and dual-cert action',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/index': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _profilePayload(
                    organizationId: 'org-personal-cert',
                    certificationStatus: 'approved',
                    membershipStatus: 'active',
                  ),
                );
              },
            },
      );
      final profileIdentityTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/organization/mine':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'items': <Object?>[
                          <String, Object?>{
                            'organizationId': 'org-personal-cert',
                            'name': '上海展建服务有限公司',
                            'organizationType': 'supplier',
                            'roleKeys': <Object?>['supplier_admin'],
                            'membershipStatus': 'active',
                            'certificationStatus': 'approved',
                            'current': true,
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
                        'organizationId': 'org-personal-cert',
                        'certificationStatus': 'approved',
                        'legalName': '上海展建服务有限公司',
                        'legalPerson': '张三',
                        'personalCertification': <String, Object?>{
                          'organizationId': 'org-personal-cert',
                          'userId': 'user-personal-cert',
                          'certificationStatus': 'rejected',
                          'realName': '李四',
                          'idNumberMasked': '310***********5678',
                          'qualifiedForCurrentActor': false,
                          'lockedToOtherActor': false,
                          'rejectReason': '身份证姓名与营业执照法定代表人不一致，当前不能通过我的认证。',
                          'submittedAt': '2026-04-06 10:10',
                        },
                      },
                    );
                  },
            },
      );

      await tester.pumpWidget(
        _buildProfileApp(
          transport: transport,
          initialRoute: '/profile/certification/current',
          profileIdentityTransport: profileIdentityTransport,
          shellContext: AppShellContextData(
            userId: '13812345678',
            organizationId: 'org-personal-cert',
            roleKeys: const <String>['supplier_admin'],
            certificationStatus: 'approved',
            personalCertificationStatus: 'rejected',
            personalCertificationQualified: false,
            membershipStatus: 'active',
            visibleBuildings: const <String>[
              'exhibition',
              'messages',
              'profile',
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('当前我的认证'));
      expect(find.text('当前我的认证'), findsOneWidget);
      expect(find.text('当前资格说明'), findsOneWidget);
      expect(find.text('竞标资格要求企业认证和我的认证同时通过。'), findsOneWidget);
      expect(find.text('身份证姓名与营业执照法定代表人不一致，当前不能通过我的认证。'), findsOneWidget);
      await scrollTo(tester, find.text('重新提交我的认证'));
      expect(find.text('重新提交我的认证'), findsOneWidget);
    },
  );

  testWidgets(
    'approved certification page shows revalidate entry but keeps submit and resubmit unavailable',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/index': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _profilePayload(
                    organizationId: 'org-approved',
                    certificationStatus: 'approved',
                    membershipStatus: 'active',
                  ),
                );
              },
            },
      );
      final profileIdentityTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/organization/mine':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'items': <Object?>[
                          <String, Object?>{
                            'organizationId': 'org-approved',
                            'name': '上海展建服务有限公司',
                            'organizationType': 'supplier',
                            'roleKeys': <Object?>['buyer_admin'],
                            'membershipStatus': 'active',
                            'certificationStatus': 'approved',
                            'current': true,
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
                        'organizationId': 'org-approved',
                        'certificationStatus': 'approved',
                        'legalName': '上海展建服务有限公司',
                        'submittedAt': '2026-04-01 09:00',
                      },
                    );
                  },
            },
      );

      await tester.pumpWidget(
        _buildProfileApp(
          transport: transport,
          initialRoute: '/profile/certification/current',
          profileIdentityTransport: profileIdentityTransport,
          shellContext: AppShellContextData(
            userId: '13812345678',
            organizationId: 'org-approved',
            certificationStatus: 'approved',
            membershipStatus: 'active',
            visibleBuildings: const <String>[
              'exhibition',
              'messages',
              'profile',
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('更正认证资料'));
      expect(find.text('已认证'), findsOneWidget);
      expect(find.text('更正认证资料'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '管理公司与组织'), findsOneWidget);
      expect(find.text('公司与组织'), findsNothing);
      expect(find.text('成员管理'), findsNothing);
      expect(find.widgetWithText(FilledButton, '加入组织'), findsNothing);
      expect(find.text('重新提交认证'), findsNothing);
      expect(find.text('提交认证'), findsNothing);

      await tester.tap(find.widgetWithText(FilledButton, '管理公司与组织'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          '先在这里确认当前主体，再继续创建组织、加入组织或切换当前主体；项目归属、认证主体与可发布 / 可竞标能力都会跟随这里。',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'certification revalidate keeps formal truth separate from OCR preview and stays approved after success',
    (WidgetTester tester) async {
      const organizationId = 'org-approved-revalidate';
      const membershipStatus = 'active';
      String currentCertificationStatus = 'approved';
      String currentLegalName = '上海展建服务有限公司';
      String currentUscc = '91310000123456789A';

      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/index': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _profilePayload(
                    organizationId: organizationId,
                    roleKeys: const <String>['buyer_admin'],
                    certificationStatus: currentCertificationStatus,
                    membershipStatus: membershipStatus,
                  ),
                );
              },
            },
      );
      final profileIdentityTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/organization/mine':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: <String, Object?>{
                        'items': <Object?>[
                          _organizationItemPayload(
                            organizationId: organizationId,
                            name: currentLegalName,
                            organizationType: 'supplier',
                            roleKeys: const <String>['buyer_admin'],
                            membershipStatus: membershipStatus,
                            certificationStatus: currentCertificationStatus,
                            current: true,
                          ),
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
                        'organizationId': organizationId,
                        'certificationStatus': currentCertificationStatus,
                        'legalName': currentLegalName,
                        'uscc': currentUscc,
                        'legalPerson': '张三',
                        'businessType': '有限责任公司',
                        'submittedAt': '2026-04-01 09:00',
                      },
                    );
                  },
              'POST /api/app/profile/certification/revalidate':
                  (AppApiRequest request) async {
                    expect(request.body, const <String, Object?>{
                      'organizationId': organizationId,
                      'legalName': '上海展建服务集团有限公司',
                      'uscc': '91310000999999999X',
                      'licenseFileId': 'file-asset-cert-revalidate-1',
                      'correctionNote': '营业执照字段已更新',
                    });
                    currentCertificationStatus = 'approved';
                    currentLegalName = '上海展建服务集团有限公司';
                    currentUscc = '91310000999999999X';
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'organizationId': organizationId,
                        'certificationStatus': 'approved',
                        'submittedAt': '2026-04-10 10:10',
                        'traceId': 'cert-revalidate-1',
                      },
                    );
                  },
              'POST /api/app/file/upload/init': (AppApiRequest request) async =>
                  AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'uploadSessionId': 'cert-upload-revalidate-1',
                      'directUpload': <String, Object?>{
                        'url':
                            'https://oss.example.com/cert-upload-revalidate-1',
                        'method': 'PUT',
                        'headers': <String, Object?>{
                          'content-type': 'image/png',
                        },
                      },
                      'confirm': <String, Object?>{
                        'endpoint': '/api/app/file/upload/confirm',
                      },
                    },
                  ),
              'POST /api/app/file/upload/confirm':
                  (AppApiRequest request) async => AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'fileAssetId': 'file-asset-cert-revalidate-1',
                    },
                  ),
              'POST /api/app/profile/certification/license/ocr':
                  (AppApiRequest request) async {
                    expect(request.body, const <String, Object?>{
                      'organizationId': organizationId,
                      'licenseFileId': 'file-asset-cert-revalidate-1',
                    });
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'status': 'recognized',
                        'message': '当前已完成营业执照 OCR 识别，认证主体和统一社会信用代码已自动回填。',
                        'legalName': '上海展建服务集团有限公司',
                        'uscc': '91310000999999999X',
                        'legalPerson': '李四',
                        'businessType': '有限责任公司',
                        'providerRequestId': 'ocr-revalidate-1',
                      },
                    );
                  },
            },
        uploadHandler: (AppApiUploadRequest request) async =>
            AppApiResponse(statusCode: 200, uri: Uri.parse(request.url)),
      );
      final shellTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/shell/context': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _shellContextPayload(
                    organizationId: organizationId,
                    roleKeys: const <String>['buyer_admin'],
                    certificationStatus: currentCertificationStatus,
                    membershipStatus: membershipStatus,
                  ),
                );
              },
            },
      );

      ProfileAvatarPicker.install(
        _FakeProfileAvatarPicker(
          result: ProfileAvatarPickResult.selected(
            ProfileAvatarPickedFile(
              fileName: 'license-revalidate.png',
              mimeType: 'image/png',
              bytes: _tinyPngBytes,
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        _buildProfileApp(
          transport: transport,
          profileIdentityTransport: profileIdentityTransport,
          shellContextConsumer: AppShellContextConsumer(
            client: AppApiClient(
              config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
              transport: shellTransport,
            ),
          ),
          initialRoute: '/profile/certification/current',
          shellContext: AppShellContextData(
            userId: '13812345678',
            organizationId: organizationId,
            certificationStatus: 'approved',
            membershipStatus: membershipStatus,
            roleKeys: const <String>['buyer_admin'],
            visibleBuildings: const <String>[
              'exhibition',
              'messages',
              'profile',
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('更正认证资料'));
      await tester.tap(find.text('更正认证资料'));
      await tester.pumpAndSettle();

      expect(find.text('当前正式认证资料'), findsOneWidget);
      expect(find.text('上海展建服务有限公司'), findsWidgets);
      expect(find.text('待审核更正状态'), findsOneWidget);
      expect(
        find.text('当前轮没有单独的待审核更正状态，也不会生成并行资格真值；当前页展示的“正式认证资料”仍然是当前有效真值。'),
        findsOneWidget,
      );
      expect(find.text('项目主线影响'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, '更正说明'),
        '营业执照字段已更新',
      );
      await scrollTo(tester, find.widgetWithText(FilledButton, '选择营业执照'));
      await tester.tap(find.widgetWithText(FilledButton, '选择营业执照'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('从相册选择'));
      await tester.pumpAndSettle();
      await scrollTo(tester, find.widgetWithText(FilledButton, '确认上传营业执照'));
      await tester.tap(find.widgetWithText(FilledButton, '确认上传营业执照'));
      await tester.pumpAndSettle();

      expect(find.text('OCR识别预览'), findsOneWidget);
      expect(find.text('上海展建服务集团有限公司'), findsWidgets);
      expect(find.text('91310000999999999X'), findsWidgets);

      await scrollTo(tester, find.widgetWithText(FilledButton, '提交资料更正'));
      await tester.tap(find.widgetWithText(FilledButton, '提交资料更正'));
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('当前认证状态'));
      expect(find.text('已认证'), findsWidgets);
      await scrollTo(tester, find.text('正式认证资料'));
      expect(find.text('正式认证资料'), findsOneWidget);
      expect(find.text('上海展建服务集团有限公司'), findsWidgets);
      expect(find.text('91310000999999999X'), findsWidgets);
    },
  );

  testWidgets(
    'certification page renders rejected state without approved fallback',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/index': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _profilePayload(
                    organizationId: 'org-cert',
                    certificationStatus: 'rejected',
                    membershipStatus: 'active',
                  ),
                );
              },
            },
      );
      final profileIdentityTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/organization/mine':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'items': <Object?>[
                          <String, Object?>{
                            'organizationId': 'org-cert',
                            'name': '上海展建服务有限公司',
                            'organizationType': 'supplier',
                            'roleKeys': <Object?>['buyer_admin'],
                            'membershipStatus': 'active',
                            'certificationStatus': 'rejected',
                            'current': true,
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
                        'organizationId': 'org-cert',
                        'certificationStatus': 'rejected',
                        'rejectReason': '营业执照信息不一致',
                        'submittedAt': '2026-04-01 09:00',
                      },
                    );
                  },
            },
      );

      await tester.pumpWidget(
        _buildProfileApp(
          transport: transport,
          initialRoute: '/profile/certification/current',
          profileIdentityTransport: profileIdentityTransport,
          shellContext: AppShellContextData(
            userId: '13812345678',
            organizationId: 'org-cert',
            certificationStatus: 'rejected',
            membershipStatus: 'active',
            visibleBuildings: const <String>[
              'exhibition',
              'messages',
              'profile',
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('当前认证状态'));
      expect(find.text('当前认证状态'), findsOneWidget);
      expect(find.text('认证未通过'), findsOneWidget);
      expect(find.text('拒绝原因'), findsOneWidget);
      expect(find.text('营业执照信息不一致'), findsOneWidget);
      await scrollTo(tester, find.text('重新提交认证'));
      expect(find.text('重新提交认证'), findsOneWidget);
      expect(find.text('已认证'), findsNothing);
    },
  );

  testWidgets(
    'certification page renders expired state without rejected fallback',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/index': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _profilePayload(
                    organizationId: 'org-expired',
                    certificationStatus: 'expired',
                    membershipStatus: 'active',
                  ),
                );
              },
            },
      );
      final profileIdentityTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/organization/mine':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'items': <Object?>[
                          <String, Object?>{
                            'organizationId': 'org-expired',
                            'name': '上海展建服务有限公司',
                            'organizationType': 'supplier',
                            'roleKeys': <Object?>['buyer_admin'],
                            'membershipStatus': 'active',
                            'certificationStatus': 'expired',
                            'current': true,
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
                        'organizationId': 'org-expired',
                        'certificationStatus': 'expired',
                        'submittedAt': '2025-04-01 09:00',
                        'expiresAt': '2026-04-01',
                      },
                    );
                  },
            },
      );

      await tester.pumpWidget(
        _buildProfileApp(
          transport: transport,
          initialRoute: '/profile/certification/current',
          profileIdentityTransport: profileIdentityTransport,
          shellContext: AppShellContextData(
            userId: '13812345678',
            organizationId: 'org-expired',
            certificationStatus: 'expired',
            membershipStatus: 'active',
            visibleBuildings: const <String>[
              'exhibition',
              'messages',
              'profile',
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('当前认证状态'));
      expect(find.text('当前认证状态'), findsOneWidget);
      expect(find.text('已过期'), findsOneWidget);
      expect(find.text('有效期'), findsOneWidget);
      expect(find.text('2026-04-01'), findsOneWidget);
      await scrollTo(tester, find.text('重新提交认证'));
      expect(find.text('重新提交认证'), findsOneWidget);
      expect(find.text('拒绝原因'), findsNothing);
      expect(find.text('认证未通过'), findsNothing);
    },
  );

  testWidgets(
    'certification resubmit rejected path success refreshes identity, company and hub back to pending_review truth',
    (WidgetTester tester) async {
      const organizationId = 'org-rejected';
      const membershipStatus = 'active';
      String currentCertificationStatus = 'rejected';
      String? currentRejectReason = '营业执照信息不一致';

      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/index': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _profilePayload(
                    organizationId: organizationId,
                    roleKeys: const <String>['buyer_admin'],
                    certificationStatus: currentCertificationStatus,
                    membershipStatus: membershipStatus,
                  ),
                );
              },
            },
      );
      final profileIdentityTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/organization/mine':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: <String, Object?>{
                        'items': <Object?>[
                          _organizationItemPayload(
                            organizationId: organizationId,
                            name: '上海展建服务有限公司',
                            organizationType: 'supplier',
                            roleKeys: const <String>['buyer_admin'],
                            membershipStatus: membershipStatus,
                            certificationStatus: currentCertificationStatus,
                            current: true,
                          ),
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
                        'organizationId': organizationId,
                        'certificationStatus': currentCertificationStatus,
                        'submittedAt': '2026-04-01 09:00',
                        'rejectReason': ?currentRejectReason,
                      },
                    );
                  },
              'POST /api/app/profile/certification/resubmit':
                  (AppApiRequest request) async {
                    expect(request.body, const <String, Object?>{
                      'organizationId': organizationId,
                      'legalName': '上海展建服务有限公司',
                      'uscc': '91310000123456789A',
                      'licenseFileId': 'file-asset-cert-resubmit-1',
                      'supplementNote': '已补充最新营业执照',
                    });
                    currentCertificationStatus = 'approved';
                    currentRejectReason = null;
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'organizationId': organizationId,
                        'certificationStatus': 'approved',
                        'submittedAt': '2026-04-05 10:10',
                        'traceId': 'cert-resubmit-1',
                      },
                    );
                  },
              'POST /api/app/file/upload/init': (AppApiRequest request) async =>
                  AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'uploadSessionId': 'cert-upload-resubmit-1',
                      'directUpload': <String, Object?>{
                        'url': 'https://oss.example.com/cert-upload-resubmit-1',
                        'method': 'PUT',
                        'headers': <String, Object?>{
                          'content-type': 'image/png',
                        },
                      },
                      'confirm': <String, Object?>{
                        'endpoint': '/api/app/file/upload/confirm',
                      },
                    },
                  ),
              'POST /api/app/file/upload/confirm':
                  (AppApiRequest request) async => AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'fileAssetId': 'file-asset-cert-resubmit-1',
                    },
                  ),
              'POST /api/app/profile/certification/license/ocr':
                  (AppApiRequest request) async {
                    expect(request.body, const <String, Object?>{
                      'organizationId': organizationId,
                      'licenseFileId': 'file-asset-cert-resubmit-1',
                    });
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'status': 'recognized',
                        'message': '当前已完成营业执照 OCR 识别，认证主体和统一社会信用代码已自动回填。',
                        'legalName': '上海展建服务有限公司',
                        'uscc': '91310000123456789A',
                        'legalPerson': '张三',
                        'providerRequestId': 'ocr-resubmit-1',
                      },
                    );
                  },
            },
        uploadHandler: (AppApiUploadRequest request) async =>
            AppApiResponse(statusCode: 200, uri: Uri.parse(request.url)),
      );
      final shellTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/shell/context': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _shellContextPayload(
                    organizationId: organizationId,
                    roleKeys: const <String>['buyer_admin'],
                    certificationStatus: currentCertificationStatus,
                    membershipStatus: membershipStatus,
                  ),
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildProfileApp(
          transport: transport,
          profileIdentityTransport: profileIdentityTransport,
          shellContextConsumer: AppShellContextConsumer(
            client: AppApiClient(
              config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
              transport: shellTransport,
            ),
          ),
          shellContext: AppShellContextData(
            userId: '13812345678',
            organizationId: organizationId,
            certificationStatus: 'rejected',
            membershipStatus: membershipStatus,
            roleKeys: const <String>['buyer_admin'],
            visibleBuildings: const <String>[
              'exhibition',
              'messages',
              'profile',
            ],
          ),
        ),
      );
      ProfileAvatarPicker.install(
        _FakeProfileAvatarPicker(
          result: ProfileAvatarPickResult.selected(
            ProfileAvatarPickedFile(
              fileName: 'license-resubmit.png',
              mimeType: 'image/png',
              bytes: _tinyPngBytes,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('认证未通过'), findsWidgets);
      await scrollTo(tester, find.text('我的公司'));
      await tester.tap(find.text('我的公司').first);
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('公司认证与我的身份'));
      await tester.tap(find.text('公司认证与我的身份'));
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('当前认证状态'));
      expect(find.text('认证未通过'), findsOneWidget);
      expect(find.text('拒绝原因'), findsOneWidget);
      expect(find.text('营业执照信息不一致'), findsOneWidget);

      expect(find.widgetWithText(FilledButton, '重新提交认证'), findsOneWidget);
      await scrollTo(tester, find.widgetWithText(FilledButton, '重新提交认证'));
      await tester.tap(find.widgetWithText(FilledButton, '重新提交认证'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          '当前认证只接收 1 张营业执照图片。请先选择并确认上传，上传完成后会自动尝试 OCR 识别、展示营业执照摘要并回填认证主体与统一社会信用代码；重新提交后会基于 OCR 自动核验，符合直接通过，不符合直接打回。',
        ),
        findsOneWidget,
      );
      await tester.enterText(
        find.widgetWithText(TextField, '认证主体'),
        '上海展建服务有限公司',
      );
      await tester.enterText(
        find.widgetWithText(TextField, '统一社会信用代码'),
        '91310000123456789A',
      );
      await tester.enterText(
        find.widgetWithText(TextField, '补充说明'),
        '已补充最新营业执照',
      );
      await scrollTo(tester, find.widgetWithText(FilledButton, '选择营业执照'));
      await tester.tap(find.widgetWithText(FilledButton, '选择营业执照'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('从相册选择'));
      await tester.pumpAndSettle();
      await scrollTo(tester, find.widgetWithText(FilledButton, '确认上传营业执照'));
      await tester.tap(find.widgetWithText(FilledButton, '确认上传营业执照'));
      await tester.pumpAndSettle();
      expect(find.text('营业执照已完成上传绑定'), findsNothing);
      await scrollTo(tester, find.widgetWithText(FilledButton, '重新提交认证'));
      await tester.tap(find.widgetWithText(FilledButton, '重新提交认证'));
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('当前认证状态'));
      expect(find.text('已认证'), findsWidgets);
      expect(find.text('拒绝原因'), findsNothing);
      expect(find.text('营业执照信息不一致'), findsNothing);

      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.drag(find.byType(Scrollable).first, const Offset(0, 2000));
      await tester.pumpAndSettle();

      expect(find.textContaining('已认证'), findsWidgets);
      await scrollTo(tester, find.text('我的公司'));
      await tester.tap(find.text('我的公司').first);
      await tester.pumpAndSettle();

      expect(find.text('功能状态'), findsNothing);
      expect(find.text('当前公司/组织现状'), findsNothing);
      expect(find.text('认证资料'), findsNothing);
      expect(find.text('认证状态'), findsNothing);
      expect(find.text('已认证'), findsWidgets);
      expect(find.text('拒绝原因'), findsNothing);
      expect(find.text('营业执照信息不一致'), findsNothing);
    },
  );

  testWidgets(
    'certification submit keeps OCR preview separate and filters invalid business type values',
    (WidgetTester tester) async {
      const organizationId = 'org-cert-ocr-preview';
      const currentMembershipStatus = 'active';
      const currentCertificationStatus = 'not_submitted';

      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/index': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _profilePayload(
                    organizationId: organizationId,
                    roleKeys: const <String>['buyer_admin'],
                    certificationStatus: currentCertificationStatus,
                    membershipStatus: currentMembershipStatus,
                  ),
                );
              },
            },
      );
      final profileIdentityTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'POST /api/app/file/upload/init': (AppApiRequest request) async =>
                  AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'uploadSessionId': 'cert-upload-preview-1',
                      'directUpload': <String, Object?>{
                        'url': 'https://oss.example.com/cert-upload-preview-1',
                        'method': 'PUT',
                        'headers': <String, Object?>{
                          'content-type': 'image/png',
                        },
                      },
                      'confirm': <String, Object?>{
                        'endpoint': '/api/app/file/upload/confirm',
                      },
                    },
                  ),
              'POST /api/app/file/upload/confirm':
                  (AppApiRequest request) async => AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'fileAssetId': 'file-asset-cert-preview-1',
                    },
                  ),
              'POST /api/app/profile/certification/license/ocr':
                  (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'status': 'recognized',
                        'message': '当前已完成营业执照 OCR 识别。',
                        'legalName': '上海待认证组织',
                        'uscc': '91310000123456789A',
                        'legalPerson': '张三',
                        'businessType': 'QRCode',
                        'address': '重庆市江北区洋河二村73号1幢20-7',
                        'establishedAt': '2016年03月30日',
                        'businessScope': '展览展示服务',
                        'providerRequestId': 'ocr-preview-1',
                      },
                    );
                  },
            },
        uploadHandler: (AppApiUploadRequest request) async =>
            AppApiResponse(statusCode: 200, uri: Uri.parse(request.url)),
      );
      ProfileAvatarPicker.install(
        _FakeProfileAvatarPicker(
          result: ProfileAvatarPickResult.selected(
            ProfileAvatarPickedFile(
              fileName: 'license-preview.png',
              mimeType: 'image/png',
              bytes: _tinyPngBytes,
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        _buildProfileApp(
          transport: transport,
          profileIdentityTransport: profileIdentityTransport,
          initialRoute: '/profile/certification/submit',
          shellContext: _shellContextData(
            organizationId: organizationId,
            roleKeys: const <String>['buyer_admin'],
            certificationStatus: currentCertificationStatus,
            membershipStatus: currentMembershipStatus,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await scrollTo(tester, find.widgetWithText(FilledButton, '选择营业执照'));
      await tester.tap(find.widgetWithText(FilledButton, '选择营业执照'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('从相册选择'));
      await tester.pumpAndSettle();
      await scrollTo(tester, find.widgetWithText(FilledButton, '确认上传营业执照'));
      await tester.tap(find.widgetWithText(FilledButton, '确认上传营业执照'));
      await tester.pumpAndSettle();

      expect(find.text('OCR识别预览'), findsOneWidget);
      expect(
        find.text('以下内容来自营业执照 OCR 识别结果，仅用于当前页核对与回填。正式认证资料以认证状态页中的“正式认证资料”为准。'),
        findsOneWidget,
      );
      expect(find.text('法定代表人'), findsOneWidget);
      expect(find.text('张三'), findsOneWidget);
      expect(find.text('住所'), findsOneWidget);
      expect(find.text('重庆市江北区洋河二村73号1幢20-7'), findsOneWidget);
      expect(find.text('成立日期'), findsOneWidget);
      expect(find.text('2016年03月30日'), findsOneWidget);
      expect(find.text('企业类型'), findsNothing);
      expect(find.text('QRCode'), findsNothing);
    },
  );

  testWidgets(
    'certification resubmit expired path success refreshes identity, company and hub back to pending_review truth',
    (WidgetTester tester) async {
      const organizationId = 'org-expired';
      const membershipStatus = 'active';
      String currentCertificationStatus = 'expired';
      String? currentExpiresAt = '2026-04-01';

      final transport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/profile/index': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _profilePayload(
                    organizationId: organizationId,
                    roleKeys: const <String>['buyer_admin'],
                    certificationStatus: currentCertificationStatus,
                    membershipStatus: membershipStatus,
                  ),
                );
              },
            },
      );
      final profileIdentityTransport = FakeAppApiTransport(
        handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
          'GET /api/app/profile/organization/mine':
              (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'items': <Object?>[
                      _organizationItemPayload(
                        organizationId: organizationId,
                        name: '上海展建服务有限公司',
                        organizationType: 'supplier',
                        roleKeys: const <String>['buyer_admin'],
                        membershipStatus: membershipStatus,
                        certificationStatus: currentCertificationStatus,
                        current: true,
                      ),
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
                    'organizationId': organizationId,
                    'certificationStatus': currentCertificationStatus,
                    'submittedAt': '2025-04-01 09:00',
                    'expiresAt': ?currentExpiresAt,
                  },
                );
              },
          'POST /api/app/profile/certification/resubmit':
              (AppApiRequest request) async {
                expect(request.body, const <String, Object?>{
                  'organizationId': organizationId,
                  'legalName': '上海展建服务有限公司',
                  'uscc': '91310000123456789A',
                  'licenseFileId': 'file-asset-cert-resubmit-expired-1',
                  'supplementNote': '已补充最新过期材料',
                });
                currentCertificationStatus = 'approved';
                currentExpiresAt = null;
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'organizationId': organizationId,
                    'certificationStatus': 'approved',
                    'submittedAt': '2026-04-05 10:10',
                    'traceId': 'cert-resubmit-expired-1',
                  },
                );
              },
          'POST /api/app/file/upload/init': (AppApiRequest request) async =>
              AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: const <String, Object?>{
                  'uploadSessionId': 'cert-upload-resubmit-expired-1',
                  'directUpload': <String, Object?>{
                    'url':
                        'https://oss.example.com/cert-upload-resubmit-expired-1',
                    'method': 'PUT',
                    'headers': <String, Object?>{'content-type': 'image/png'},
                  },
                  'confirm': <String, Object?>{
                    'endpoint': '/api/app/file/upload/confirm',
                  },
                },
              ),
          'POST /api/app/file/upload/confirm': (AppApiRequest request) async =>
              AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: const <String, Object?>{
                  'fileAssetId': 'file-asset-cert-resubmit-expired-1',
                },
              ),
          'POST /api/app/profile/certification/license/ocr':
              (AppApiRequest request) async {
                expect(request.body, const <String, Object?>{
                  'organizationId': organizationId,
                  'licenseFileId': 'file-asset-cert-resubmit-expired-1',
                });
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'status': 'recognized',
                    'message': '当前已完成营业执照 OCR 识别，认证主体和统一社会信用代码已自动回填。',
                    'legalName': '上海展建服务有限公司',
                    'uscc': '91310000123456789A',
                    'legalPerson': '张三',
                    'providerRequestId': 'ocr-resubmit-expired-1',
                  },
                );
              },
        },
        uploadHandler: (AppApiUploadRequest request) async =>
            AppApiResponse(statusCode: 200, uri: Uri.parse(request.url)),
      );
      final shellTransport = FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/shell/context': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: _shellContextPayload(
                    organizationId: organizationId,
                    roleKeys: const <String>['buyer_admin'],
                    certificationStatus: currentCertificationStatus,
                    membershipStatus: membershipStatus,
                  ),
                );
              },
            },
      );

      await tester.pumpWidget(
        _buildProfileApp(
          transport: transport,
          profileIdentityTransport: profileIdentityTransport,
          shellContextConsumer: AppShellContextConsumer(
            client: AppApiClient(
              config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
              transport: shellTransport,
            ),
          ),
          shellContext: AppShellContextData(
            userId: '13812345678',
            organizationId: organizationId,
            certificationStatus: 'expired',
            membershipStatus: membershipStatus,
            roleKeys: const <String>['buyer_admin'],
            visibleBuildings: const <String>[
              'exhibition',
              'messages',
              'profile',
            ],
          ),
        ),
      );
      ProfileAvatarPicker.install(
        _FakeProfileAvatarPicker(
          result: ProfileAvatarPickResult.selected(
            ProfileAvatarPickedFile(
              fileName: 'license-expired.png',
              mimeType: 'image/png',
              bytes: _tinyPngBytes,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('已过期'), findsWidgets);
      await scrollTo(tester, find.text('我的公司'));
      await tester.tap(find.text('我的公司').first);
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('公司认证与我的身份'));
      await tester.tap(find.text('公司认证与我的身份'));
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('当前认证状态'));
      expect(find.text('已过期'), findsOneWidget);
      expect(find.text('有效期'), findsOneWidget);
      expect(find.text('2026-04-01'), findsOneWidget);

      expect(find.widgetWithText(FilledButton, '重新提交认证'), findsOneWidget);
      await scrollTo(tester, find.widgetWithText(FilledButton, '重新提交认证'));
      await tester.tap(find.widgetWithText(FilledButton, '重新提交认证'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          '当前认证只接收 1 张营业执照图片。请先选择并确认上传，上传完成后会自动尝试 OCR 识别、展示营业执照摘要并回填认证主体与统一社会信用代码；重新提交后会基于 OCR 自动核验，符合直接通过，不符合直接打回。',
        ),
        findsOneWidget,
      );
      await tester.enterText(
        find.widgetWithText(TextField, '认证主体'),
        '上海展建服务有限公司',
      );
      await tester.enterText(
        find.widgetWithText(TextField, '统一社会信用代码'),
        '91310000123456789A',
      );
      await tester.enterText(
        find.widgetWithText(TextField, '补充说明'),
        '已补充最新过期材料',
      );
      await scrollTo(tester, find.widgetWithText(FilledButton, '选择营业执照'));
      await tester.tap(find.widgetWithText(FilledButton, '选择营业执照'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('从相册选择'));
      await tester.pumpAndSettle();
      await scrollTo(tester, find.widgetWithText(FilledButton, '确认上传营业执照'));
      await tester.tap(find.widgetWithText(FilledButton, '确认上传营业执照'));
      await tester.pumpAndSettle();
      expect(find.text('营业执照已完成上传绑定'), findsNothing);
      await scrollTo(tester, find.widgetWithText(FilledButton, '重新提交认证'));
      await tester.tap(find.widgetWithText(FilledButton, '重新提交认证'));
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('当前认证状态'));
      expect(find.text('已认证'), findsWidgets);
      expect(find.text('有效期'), findsNothing);
      expect(find.text('2026-04-01'), findsNothing);

      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.drag(find.byType(Scrollable).first, const Offset(0, 2000));
      await tester.pumpAndSettle();

      expect(find.textContaining('已认证'), findsWidgets);
      await scrollTo(tester, find.text('我的公司'));
      await tester.tap(find.text('我的公司').first);
      await tester.pumpAndSettle();

      expect(find.text('功能状态'), findsNothing);
      expect(find.text('当前公司/组织现状'), findsNothing);
      expect(find.text('认证资料'), findsNothing);
      expect(find.text('认证状态'), findsNothing);
      expect(find.text('已认证'), findsWidgets);
      expect(find.text('2026-04-01'), findsNothing);
    },
  );

  testWidgets(
    'certification resubmit keeps controlled failure when current truth does not allow resubmit',
    (WidgetTester tester) async {
      ProfileAvatarPicker.install(
        _FakeProfileAvatarPicker(
          result: ProfileAvatarPickResult.selected(
            ProfileAvatarPickedFile(
              fileName: 'license-blocked.png',
              mimeType: 'image/png',
              bytes: _tinyPngBytes,
            ),
          ),
        ),
      );
      await tester.pumpWidget(
        _buildProfileApp(
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
                      body: _profilePayload(
                        organizationId: 'org-approved',
                        certificationStatus: 'approved',
                        membershipStatus: 'active',
                      ),
                    );
                  },
                },
          ),
          initialRoute: '/profile/certification/resubmit',
          profileIdentityTransport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'POST /api/app/file/upload/init':
                      (AppApiRequest request) async => AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'uploadSessionId': 'cert-upload-blocked-1',
                          'directUpload': <String, Object?>{
                            'url':
                                'https://oss.example.com/cert-upload-blocked-1',
                            'method': 'PUT',
                            'headers': <String, Object?>{
                              'content-type': 'image/png',
                            },
                          },
                          'confirm': <String, Object?>{
                            'endpoint': '/api/app/file/upload/confirm',
                          },
                        },
                      ),
                  'POST /api/app/file/upload/confirm':
                      (AppApiRequest request) async => AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'fileAssetId': 'file-asset-cert-blocked-1',
                        },
                      ),
                  'POST /api/app/profile/certification/license/ocr':
                      (AppApiRequest request) async {
                        expect(request.body, const <String, Object?>{
                          'organizationId': 'org-approved',
                          'licenseFileId': 'file-asset-cert-blocked-1',
                        });
                        return AppApiResponse(
                          statusCode: 200,
                          uri: request.uri,
                          body: const <String, Object?>{
                            'status': 'recognized',
                            'message': '当前已完成营业执照 OCR 识别，认证主体和统一社会信用代码已自动回填。',
                            'legalName': '上海展建服务有限公司',
                            'uscc': '91310000123456789A',
                            'legalPerson': '张三',
                            'providerRequestId': 'ocr-cert-blocked-1',
                          },
                        );
                      },
                  'POST /api/app/profile/certification/resubmit':
                      (AppApiRequest request) async {
                        expect(request.body, const <String, Object?>{
                          'organizationId': 'org-approved',
                          'legalName': '上海展建服务有限公司',
                          'uscc': '91310000123456789A',
                          'licenseFileId': 'file-asset-cert-blocked-1',
                          'supplementNote': null,
                        });
                        return AppApiResponse(
                          statusCode: 409,
                          uri: request.uri,
                          body: const <String, Object?>{
                            'message': '当前认证状态不允许重新提交，请先返回查看最新认证状态。',
                          },
                        );
                      },
                },
            uploadHandler: (AppApiUploadRequest request) async =>
                AppApiResponse(statusCode: 200, uri: Uri.parse(request.url)),
          ),
          shellContext: AppShellContextData(
            userId: '13812345678',
            organizationId: 'org-approved',
            certificationStatus: 'approved',
            membershipStatus: 'active',
            visibleBuildings: const <String>[
              'exhibition',
              'messages',
              'profile',
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, '认证主体'),
        '上海展建服务有限公司',
      );
      await tester.enterText(
        find.widgetWithText(TextField, '统一社会信用代码'),
        '91310000123456789A',
      );
      await scrollTo(tester, find.widgetWithText(FilledButton, '选择营业执照'));
      await tester.tap(find.widgetWithText(FilledButton, '选择营业执照'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('从相册选择'));
      await tester.pumpAndSettle();
      await scrollTo(tester, find.widgetWithText(FilledButton, '确认上传营业执照'));
      await tester.tap(find.widgetWithText(FilledButton, '确认上传营业执照'));
      await tester.pumpAndSettle();
      await scrollTo(tester, find.widgetWithText(FilledButton, '重新提交认证'));
      await tester.tap(find.widgetWithText(FilledButton, '重新提交认证'));
      await tester.pumpAndSettle();

      expect(find.text('认证提交当前未完成'), findsNothing);
      expect(find.text('当前认证状态不允许重新提交，请先返回查看最新认证状态。'), findsOneWidget);
    },
  );

  testWidgets(
    'certification resubmit keeps controlled failure when upload confirm fails',
    (WidgetTester tester) async {
      ProfileAvatarPicker.install(
        _FakeProfileAvatarPicker(
          result: ProfileAvatarPickResult.selected(
            ProfileAvatarPickedFile(
              fileName: 'license-confirm-failure.png',
              mimeType: 'image/png',
              bytes: _tinyPngBytes,
            ),
          ),
        ),
      );
      await tester.pumpWidget(
        _buildProfileApp(
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
                      body: _profilePayload(
                        organizationId: 'org-expired',
                        certificationStatus: 'expired',
                        membershipStatus: 'active',
                      ),
                    );
                  },
                },
          ),
          initialRoute: '/profile/certification/resubmit',
          profileIdentityTransport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'POST /api/app/file/upload/init':
                      (AppApiRequest request) async => AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'uploadSessionId': 'cert-upload-confirm-failure-1',
                          'directUpload': <String, Object?>{
                            'url':
                                'https://oss.example.com/cert-upload-confirm-failure-1',
                            'method': 'PUT',
                            'headers': <String, Object?>{
                              'content-type': 'image/png',
                            },
                          },
                          'confirm': <String, Object?>{
                            'endpoint': '/api/app/file/upload/confirm',
                          },
                        },
                      ),
                  'POST /api/app/file/upload/confirm':
                      (AppApiRequest request) async => AppApiResponse(
                        statusCode: 409,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'message': '当前营业执照上传确认失败，请重新上传后再试。',
                        },
                      ),
                  'POST /api/app/profile/certification/resubmit':
                      (AppApiRequest request) async => AppApiResponse(
                        statusCode: 409,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'message': '当前不应直接进入重新提交。',
                        },
                      ),
                },
            uploadHandler: (AppApiUploadRequest request) async =>
                AppApiResponse(statusCode: 200, uri: Uri.parse(request.url)),
          ),
          shellContext: AppShellContextData(
            userId: '13812345678',
            organizationId: 'org-expired',
            certificationStatus: 'expired',
            membershipStatus: 'active',
            visibleBuildings: const <String>[
              'exhibition',
              'messages',
              'profile',
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, '认证主体'),
        '上海展建服务有限公司',
      );
      await tester.enterText(
        find.widgetWithText(TextField, '统一社会信用代码'),
        '91310000123456789A',
      );
      await tester.enterText(
        find.widgetWithText(TextField, '补充说明'),
        '已补充说明但确认失败',
      );
      await scrollTo(tester, find.widgetWithText(FilledButton, '选择营业执照'));
      await tester.tap(find.widgetWithText(FilledButton, '选择营业执照'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('从相册选择'));
      await tester.pumpAndSettle();
      await scrollTo(tester, find.widgetWithText(FilledButton, '确认上传营业执照'));
      await tester.tap(find.widgetWithText(FilledButton, '确认上传营业执照'));
      await tester.pumpAndSettle();

      expect(find.text('营业执照确认当前未完成'), findsOneWidget);
      expect(find.text('当前营业执照上传确认失败，请重新上传后再试。'), findsOneWidget);
      expect(find.text('营业执照文件 ID'), findsNothing);
    },
  );
}

class _PassthroughHttpOverrides extends HttpOverrides {}

class _FakeProfileAvatarPicker implements ProfileAvatarPicker {
  _FakeProfileAvatarPicker({required this.result});

  final ProfileAvatarPickResult result;

  @override
  Future<ProfileAvatarPickResult> pick({
    required ProfileAvatarPickSource source,
  }) async {
    return result;
  }
}
