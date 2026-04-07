import 'dart:io';

import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/forum_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_credit_constraints_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_payment_billing_consumer_layer.dart';
import 'package:mobile/shell/shell_app.dart';

Map<String, Object?> privateOperatingSystemProfileProjection({
  String updatedAt = '2026-04-06T10:30:00Z',
}) {
  return <String, Object?>{
    'regroupingKey': 'my_building_compact_current_user_hub',
    'entryOrderKey': 'my_building_compact_hub_first_level',
    'corridorVisibilityStatus': 'visible',
    'groupingExplanationKey': 'my_building_bounded_private_regrouping',
    'updatedAt': updatedAt,
  };
}

Map<String, Object?> privateOperatingSystemShellProjection({
  String updatedAt = '2026-04-06T10:30:00Z',
}) {
  return <String, Object?>{
    'profileCorridorKey': 'my_building_compact_hub_corridor',
    'profileEntryOrderBucket': 'profile_my_building_first_level',
    'visibleFamilyKeys': <Object?>[
      'my_company',
      'certification_membership_status',
      'my_projects',
      'my_forum',
      'settings',
    ],
    'orderingReferenceVersion': 'v23.private-operating-system.package1',
    'regrouping': <String, Object?>{
      'regroupingKey': 'my_building_compact_current_user_hub',
      'regroupingVisibilityStatus': 'visible',
      'regroupingExplanationKey': 'my_building_bounded_private_regrouping',
      'updatedAt': updatedAt,
    },
    'entryOrder': <String, Object?>{
      'entryOrderKey': 'my_building_compact_hub_first_level',
      'entryVisibilityStatus': 'visible',
      'entryPriorityBucket': 'profile_my_building_first_level',
      'orderingExplanationKey': 'my_building_compact_hub_order_preserved',
      'updatedAt': updatedAt,
    },
    'corridor': <String, Object?>{
      'corridorKey': 'my_building_compact_hub_corridor',
      'corridorVisibilityStatus': 'visible',
      'corridorExplanationKey': 'my_building_compact_hub_corridor_visible',
      'corridorTargetFamily': 'profile_my_building',
      'updatedAt': updatedAt,
    },
    'familyPresence': <Object?>[
      _familyPresenceItem(
        familyKey: 'my_company',
        familyOrderReference: 100,
        familyVisibilityReasonKey: 'current_organization_identity_available',
        updatedAt: updatedAt,
      ),
      _familyPresenceItem(
        familyKey: 'certification_membership_status',
        familyOrderReference: 200,
        familyVisibilityReasonKey: 'current_status_reference_available',
        updatedAt: updatedAt,
      ),
      _familyPresenceItem(
        familyKey: 'my_projects',
        familyOrderReference: 300,
        familyVisibilityReasonKey: 'bounded_private_project_entry_preserved',
        updatedAt: updatedAt,
      ),
      _familyPresenceItem(
        familyKey: 'my_forum',
        familyOrderReference: 400,
        familyVisibilityReasonKey: 'bounded_forum_asset_entry_preserved',
        updatedAt: updatedAt,
      ),
      _familyPresenceItem(
        familyKey: 'settings',
        familyOrderReference: 500,
        familyVisibilityReasonKey: 'bottom_most_first_level_entry_preserved',
        updatedAt: updatedAt,
      ),
    ],
    'navigationExplanation': <String, Object?>{
      'navigationExplanationKey': 'my_building_navigation_reference',
    },
    'dependencyReference': <String, Object?>{
      'dependencyRequired': true,
      'dependencyFamilyKey': 'future_cross_building_shell_rewrite',
      'dependencyExplanationKey':
          'future_cross_building_shell_rewrite_strategic_hold',
      'dependencyHandoffKey':
          'strategic_hold_current_private_operating_system_boundary',
    },
    'updatedAt': updatedAt,
  };
}

Map<String, Object?> privateOperatingSystemProfilePayload({
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
  bool includeProjection = true,
}) {
  return <String, Object?>{
    'organization': <String, Object?>{
      'organizationId': organizationId,
      'roleKeys': roleKeys,
      'visibleBuildings': visibleBuildings,
    },
    'certification': <String, Object?>{'status': certificationStatus},
    'membership': <String, Object?>{'status': membershipStatus},
    if (includeProjection)
      'myBuildingProjection': privateOperatingSystemProfileProjection(),
    'settingsEntry': <String, Object?>{'state': settingsState},
  };
}

Map<String, Object?> privateOperatingSystemShellContextPayload({
  String? organizationId,
  required List<String> roleKeys,
  String? certificationStatus,
  String? membershipStatus,
  String? paidMembershipTier,
  List<String> visibleBuildings = const <String>[
    'exhibition',
    'messages',
    'profile',
  ],
  bool includeProjection = true,
}) {
  return <String, Object?>{
    'userId': '13812345678',
    'organizationId': organizationId,
    'roleKeys': roleKeys,
    'certificationStatus': certificationStatus,
    'membershipStatus': membershipStatus,
    'paidMembershipTier': paidMembershipTier,
    'paidMembershipEntitlementsSummary': const <Object?>['当前权益摘要'],
    'paidMembershipQuotaSummary': const <Object?>['当前额度摘要'],
    'paidMembershipNextRefreshAt': '2026-04-07 09:30',
    'visibleBuildings': visibleBuildings,
    'featureFlagsVersion': '0.1.0',
    'unreadSummary': const <String, Object?>{
      'total': 0,
      'system': 0,
      'business': 0,
    },
    if (includeProjection)
      'myBuildingProjection': privateOperatingSystemShellProjection(),
  };
}

AppShellContextData privateOperatingSystemShellContextData({
  String? organizationId,
  required List<String> roleKeys,
  String? certificationStatus,
  String? membershipStatus,
  String? paidMembershipTier,
  bool includeProjection = true,
}) {
  return AppShellContextData(
    userId: '13812345678',
    organizationId: organizationId,
    roleKeys: roleKeys,
    certificationStatus: certificationStatus,
    membershipStatus: membershipStatus,
    paidMembershipTier: paidMembershipTier,
    paidMembershipEntitlementsSummary: const <String>['当前权益摘要'],
    paidMembershipQuotaSummary: const <String>['当前额度摘要'],
    paidMembershipNextRefreshAt: '2026-04-07 09:30',
    visibleBuildings: const <String>['exhibition', 'messages', 'profile'],
    myBuildingProjection: includeProjection
        ? privateOperatingSystemShellProjection()
        : null,
  );
}

ExhibitionMobileApp buildPrivateOperatingSystemProfileApp({
  required FakeAppApiTransport transport,
  required AppShellContextData shellContext,
  bool establishSession = true,
}) {
  final sessionStore = AppSessionStore();
  if (establishSession && !sessionStore.hasAnySession) {
    sessionStore.establishSession(
      accessToken: 'profile-test-access-token',
      refreshToken: 'profile-test-refresh-token',
      expiresInSeconds: 3600,
      deviceId: 'profile-test-device',
    );
  }

  return ExhibitionMobileApp(
    initialRoute: '/profile',
    bootstrapShellContext: shellContext,
    profileConsumerLayer: ProfileConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: transport,
      ),
    ),
    exhibitionConsumerLayer: ExhibitionConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'GET /api/app/my/projects': (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'ongoingProjects': <Object?>[
                        <String, Object?>{'projectId': 'project-1'},
                      ],
                      'historicalProjects': <Object?>[],
                    },
                  );
                },
              },
        ),
      ),
    ),
    forumConsumerLayer: ForumConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(handlers: _forumHandlers()),
      ),
    ),
    sessionStore: sessionStore,
  );
}

void installDefaultPrivateOperatingSystemSupportConsumers() {
  ProfileCreditConstraintsConsumerLayer.install(
    ProfileCreditConstraintsConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
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
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
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
}

final class PrivateOperatingSystemPassthroughHttpOverrides
    extends HttpOverrides {}

Map<String, Object?> _familyPresenceItem({
  required String familyKey,
  required int familyOrderReference,
  required String familyVisibilityReasonKey,
  required String updatedAt,
}) {
  return <String, Object?>{
    'familyKey': familyKey,
    'familyPresenceStatus': 'visible',
    'familyOrderReference': familyOrderReference,
    'familyVisibilityReasonKey': familyVisibilityReasonKey,
    'updatedAt': updatedAt,
  };
}

Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
_forumHandlers() {
  return <String, Future<AppApiResponse> Function(AppApiRequest request)>{
    'GET /api/app/forum/me/posts': (AppApiRequest request) async =>
        AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: const <String, Object?>{
            'items': <Object?>[
              <String, Object?>{'postId': 'post-1'},
            ],
            'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
          },
        ),
    'GET /api/app/forum/me/comments': (AppApiRequest request) async =>
        AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: const <String, Object?>{
            'items': <Object?>[
              <String, Object?>{'commentId': 'comment-1'},
            ],
            'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
          },
        ),
    'GET /api/app/forum/me/bookmarks': (AppApiRequest request) async =>
        AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: const <String, Object?>{
            'items': <Object?>[
              <String, Object?>{'postId': 'bookmark-1'},
            ],
            'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
          },
        ),
    'GET /api/app/forum/me/follows': (AppApiRequest request) async =>
        AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: const <String, Object?>{
            'items': <Object?>[
              <String, Object?>{'topicId': 'topic-1'},
            ],
            'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
          },
        ),
    'GET /api/app/forum/draft/list': (AppApiRequest request) async =>
        AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: const <String, Object?>{
            'items': <Object?>[
              <String, Object?>{'draftId': 'draft-1'},
            ],
            'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
          },
        ),
  };
}
