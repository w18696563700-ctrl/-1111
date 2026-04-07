import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/boot/app_shell_context_consumer.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/core/config/config_manifest.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/forum_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_credit_constraints_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_identity_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_membership_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_payment_billing_consumer_layer.dart';
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
}) {
  return <String, Object?>{
    'organizationId': organizationId,
    'name': name,
    'organizationType': organizationType,
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
  FakeAppApiTransport? profileIdentityTransport,
  ProfileIdentityConsumerLayer? profileIdentityConsumerLayer,
  AppShellContextData? shellContext,
  AppShellContextConsumer? shellContextConsumer,
  AppSessionStore? sessionStore,
}) {
  final resolvedSessionStore = sessionStore ?? AppSessionStore();
  if (!resolvedSessionStore.hasAnySession) {
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
    forumConsumerLayer: ForumConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport:
            forumTransport ?? FakeAppApiTransport(handlers: _forumHandlers()),
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
  );
}

class _FakeOrganizationMembersConsumer implements ProfileIdentityConsumerLayer {
  _FakeOrganizationMembersConsumer({
    required this.organizationsLoader,
    required this.certificationLoader,
    required this.membersLoader,
    required this.rolePatcher,
    required this.memberDisabler,
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
  Future<ProfileIdentityResult<ProfileOrganizationJoinAcceptedView>>
  joinByCode({required String inviteCode}) => throw UnimplementedError();

  @override
  Future<ProfileIdentityResult<AppShellContextData>> switchOrganization({
    required String organizationId,
  }) => throw UnimplementedError();

  @override
  Future<ProfileIdentityResult<ProfileCertificationAcceptedView>>
  submitCertification({
    required String organizationId,
    required String legalName,
    required String uscc,
    required String licenseFileId,
    String? contactName,
    String? contactMobile,
  }) => throw UnimplementedError();

  @override
  Future<ProfileIdentityResult<ProfileCertificationAcceptedView>>
  resubmitCertification({
    required String organizationId,
    required String legalName,
    required String uscc,
    required String licenseFileId,
    String? supplementNote,
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

  setUp(() {
    previousHttpOverrides = HttpOverrides.current;
    HttpOverrides.global = _PassthroughHttpOverrides();
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
    ProfileMembershipConsumerLayer.reset();
  });

  tearDown(() {
    HttpOverrides.global = previousHttpOverrides;
    ProfileCreditConstraintsConsumerLayer.reset();
    ProfilePaymentBillingConsumerLayer.reset();
    ProfileMembershipConsumerLayer.reset();
  });

  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

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
    expect(
      find.text(
        '当前会员状态与权益摘要 · 标准会员 · 更高排序 · 商机提醒剩余 12 次 · 下次刷新 2026-04-06 00:00',
      ),
      findsOneWidget,
    );
    await scrollTo(tester, find.text('我的项目'));
    expect(find.text('当前组织项目资产与继续处理入口 · 进行中 1 个 · 历史 2 个'), findsOneWidget);
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

      await tester.pageBack();
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('我的论坛'));
      await tester.tap(find.text('我的论坛').first);
      await tester.pumpAndSettle();
      expect(find.text('论坛资产'), findsOneWidget);
      expect(find.text('我的帖子'), findsOneWidget);
      expect(find.text('我的评论'), findsOneWidget);
      expect(find.text('我的收藏'), findsOneWidget);
      expect(find.text('我的关注'), findsOneWidget);
      await scrollTo(tester, find.text('草稿箱'));
      expect(find.text('草稿箱'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('我的公司'));
      await tester.tap(find.text('我的公司').first);
      await tester.pumpAndSettle();
      expect(find.text('公司名称'), findsOneWidget);
      expect(find.text('上海展建服务有限公司'), findsWidgets);
      await scrollTo(tester, find.text('可进行的操作'));
      expect(find.text('可进行的操作'), findsOneWidget);
      expect(find.text('公司与组织'), findsWidgets);
      expect(find.text('公司认证与我的身份'), findsWidgets);
      expect(find.text('成员管理'), findsWidgets);
      expect(find.text('当前认证已通过，可查看成员身份与当前组织状态'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('账号与安全、通知、隐私与权限等'));
      await tester.tap(find.text('账号与安全、通知、隐私与权限等'));
      await tester.pumpAndSettle();
      expect(find.text('账号与安全'), findsOneWidget);
      expect(find.text('通知'), findsOneWidget);
      await scrollTo(tester, find.text('关于我们'));
      expect(find.text('关于我们'), findsOneWidget);
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
                              'rateBand': '标准费率档位',
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
                                  'candidateDisplayPrice': '预计年费 ¥9,800',
                                  'candidateDisplayRateBand': '更低费率档位',
                                },
                              ],
                              'upgradeHighlights': <String>['人工撮合优先', '客服优先'],
                              'commercialDisclosure': '当前仅提供升级说明，不提供下单与支付。',
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
      expect(
        find.text(
          '当前会员状态与权益摘要 · 标准会员 · 更高排序 · 商机提醒剩余 12 次 · 下次刷新 2026-04-06 00:00',
        ),
        findsOneWidget,
      );
      expect(find.text('公司认证与我的身份'), findsOneWidget);
      expect(find.text('我的项目'), findsOneWidget);
      expect(find.text('我的论坛'), findsOneWidget);
      expect(find.text('设置'), findsWidgets);

      await tester.tap(find.text('我的会员'));
      await tester.pumpAndSettle();

      expect(find.text('会员档位'), findsOneWidget);
      expect(find.text('标准会员'), findsWidgets);
      expect(find.text('费率档位'), findsOneWidget);
      expect(find.text('标准费率档位'), findsOneWidget);
      expect(find.textContaining('更高排序'), findsWidgets);
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

      await tester.pageBack();
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('配额说明页'));
      await tester.tap(find.text('配额说明页'));
      await tester.pumpAndSettle();
      expect(find.text('当前额度'), findsOneWidget);
      expect(find.text('商机提醒额度'), findsOneWidget);
      expect(find.text('当前剩余 12 · 刷新规则：自然日刷新'), findsOneWidget);
      expect(find.text('刷新时间'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('升级引导页'));
      await tester.tap(find.text('升级引导页'));
      await tester.pumpAndSettle();
      expect(find.text('当前档位'), findsOneWidget);
      expect(find.text('专业会员 · 专业档位'), findsOneWidget);
      expect(find.text('预计年费 ¥9,800 · 费率档位：更低费率档位'), findsOneWidget);
      expect(find.text('人工撮合优先'), findsOneWidget);
      expect(find.text('当前仅提供升级说明，不提供下单与支付。'), findsOneWidget);
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
      expect(find.textContaining('当前信用、保证金与交易保障摘要'), findsOneWidget);
      expect(find.text('我的项目'), findsOneWidget);
      expect(find.text('我的论坛'), findsOneWidget);
      expect(find.text('设置'), findsWidgets);

      await tester.tap(find.text('我的信用与约束'));
      await tester.pumpAndSettle();

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

      await tester.pageBack();
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

  testWidgets('company page keeps controlled empty state when data is absent', (
    WidgetTester tester,
  ) async {
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

    expect(find.text('当前还没有我的公司'), findsOneWidget);
    expect(find.text('去公司与组织'), findsOneWidget);
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
      expect(find.text('去公司与组织'), findsOneWidget);
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

      expect(find.textContaining('未认证'), findsWidgets);
      await scrollTo(tester, find.text('公司认证与我的身份'));
      await tester.tap(find.text('公司认证与我的身份').first);
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('当前认证状态'));
      expect(find.text('未认证'), findsWidgets);

      await tester.pageBack();
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('我的公司'));
      await tester.tap(find.text('我的公司').first);
      await tester.pumpAndSettle();

      expect(find.text(freshOrganizationName), findsWidgets);
      expect(find.text('需求方 / 供应商'), findsWidgets);
      await scrollTo(tester, find.text('认证状态'));
      expect(find.text('未认证'), findsOneWidget);
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

      expect(find.textContaining('认证中'), findsWidgets);
      await scrollTo(tester, find.text('公司认证与我的身份'));
      await tester.tap(find.text('公司认证与我的身份').first);
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('当前认证状态'));
      expect(find.text(freshOrganizationId), findsOneWidget);
      expect(find.text('认证中'), findsWidgets);

      await tester.pageBack();
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('我的公司'));
      await tester.tap(find.text('我的公司').first);
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('认证状态'));
      expect(find.text('认证中'), findsOneWidget);
    },
  );

  testWidgets(
    'certification submit success read-back keeps certification page, company page and hub on pending_review truth',
    (WidgetTester tester) async {
      const organizationId = 'org-submit';
      const staleCertificationStatus = 'not_submitted';
      const currentMembershipStatus = 'active';

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
                    certificationStatus: 'pending_review',
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
                        'organizationId': organizationId,
                        'certificationStatus': 'pending_review',
                        'submittedAt': '2026-04-03 09:00',
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
            organizationId: organizationId,
            roleKeys: const <String>['buyer_admin'],
            certificationStatus: staleCertificationStatus,
            membershipStatus: currentMembershipStatus,
          ),
        );
      }

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.textContaining('认证中'), findsWidgets);
      await scrollTo(tester, find.text('公司认证与我的身份'));
      await tester.tap(find.text('公司认证与我的身份').first);
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('当前认证状态'));
      expect(find.text('认证中'), findsWidgets);
      expect(find.text('提交时间'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('我的公司'));
      await tester.tap(find.text('我的公司').first);
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('认证状态'));
      expect(find.text('认证中'), findsWidgets);
      expect(find.text('未认证'), findsNothing);
    },
  );

  testWidgets(
    'session center consumes devices list and reloads truth after revoke success',
    (WidgetTester tester) async {
      final devices = <Map<String, Object?>>[
        <String, Object?>{
          'deviceId': 'device-1',
          'deviceName': '当前 iPhone',
          'osType': 'iOS',
          'appVersion': '1.0.0',
          'currentDevice': true,
          'trustStatus': 'trusted',
          'lastSeenAt': '2026-04-05 10:00',
          'revokedAt': null,
        },
        <String, Object?>{
          'deviceId': 'device-2',
          'deviceName': '备用 Android',
          'osType': 'Android',
          'appVersion': '1.0.1',
          'currentDevice': false,
          'trustStatus': 'trusted',
          'lastSeenAt': '2026-04-05 09:40',
          'revokedAt': null,
        },
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
                        organizationId: 'org-sec',
                        certificationStatus: 'approved',
                        membershipStatus: 'active',
                      ),
                    );
                  },
                },
          ),
          initialRoute: '/profile/session',
          profileIdentityTransport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/profile/security/devices':
                      (AppApiRequest request) async {
                        return AppApiResponse(
                          statusCode: 200,
                          uri: request.uri,
                          body: <String, Object?>{'items': devices},
                        );
                      },
                  'POST /api/app/profile/security/devices/device-2/revoke':
                      (AppApiRequest request) async {
                        devices[1] = <String, Object?>{
                          ...devices[1],
                          'trustStatus': 'revoked',
                          'revokedAt': '2026-04-05 10:30',
                        };
                        return AppApiResponse(
                          statusCode: 200,
                          uri: request.uri,
                          body: const <String, Object?>{
                            'ok': true,
                            'traceId': 'device-revoke-1',
                          },
                        );
                      },
                },
          ),
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

      expect(find.text('会话与设备'), findsWidgets);
      expect(find.textContaining('设备列表当前待开放'), findsNothing);
      expect(find.text('当前 iPhone'), findsOneWidget);
      expect(find.text('备用 Android'), findsOneWidget);
      expect(find.text('当前设备正在使用中，不能在当前会话内撤销。'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '撤销此设备'), findsOneWidget);

      await scrollTo(tester, find.widgetWithText(FilledButton, '撤销此设备'));
      await tester.tap(find.widgetWithText(FilledButton, '撤销此设备'));
      await tester.pumpAndSettle();

      expect(find.text('设备状态已刷新'), findsOneWidget);
      expect(find.textContaining('traceId device-revoke-1'), findsOneWidget);
      expect(find.text('撤销时间'), findsOneWidget);
      expect(find.text('2026-04-05 10:30'), findsOneWidget);
      expect(find.text('该设备已撤销，当前只展示最新状态。'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '撤销此设备'), findsNothing);
    },
  );

  testWidgets('session center keeps controlled failure when revoke fails', (
    WidgetTester tester,
  ) async {
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
        profileIdentityTransport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'GET /api/app/profile/security/devices':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'items': <Object?>[
                            <String, Object?>{
                              'deviceId': 'device-3',
                              'deviceName': '出差平板',
                              'osType': 'Android',
                              'appVersion': '1.0.2',
                              'currentDevice': false,
                              'trustStatus': 'untrusted',
                              'lastSeenAt': '2026-04-05 08:00',
                              'revokedAt': null,
                            },
                          ],
                        },
                      );
                    },
                'POST /api/app/profile/security/devices/device-3/revoke':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 400,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'code': 'SECURITY_DEVICE_REVOKE_INVALID',
                          'message': '当前设备撤销目标不一致，请刷新后再试。',
                        },
                      );
                    },
              },
        ),
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

    await scrollTo(tester, find.widgetWithText(FilledButton, '撤销此设备'));
    await tester.tap(find.widgetWithText(FilledButton, '撤销此设备'));
    await tester.pumpAndSettle();

    expect(find.text('设备撤销当前未完成'), findsOneWidget);
    expect(find.text('当前设备撤销目标不一致，请刷新后再试。'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '撤销此设备'), findsOneWidget);
    expect(find.text('该设备已撤销，当前只展示最新状态。'), findsNothing);
  });

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

      expect(find.text('公司名称'), findsOneWidget);
      await tester.fling(
        find.byType(Scrollable).first,
        const Offset(0, -600),
        1000,
      );
      await tester.pumpAndSettle();
      await tester.fling(
        find.byType(Scrollable).first,
        const Offset(0, -600),
        1000,
      );
      await tester.pumpAndSettle();
      expect(find.text('成员管理'), findsWidgets);
      await tester.tap(find.text('成员管理').first);
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

      expect(find.text('当前公司/组织'), findsOneWidget);
      await tester.fling(
        find.byType(Scrollable).first,
        const Offset(0, -500),
        1000,
      );
      await tester.pumpAndSettle();
      await tester.fling(
        find.byType(Scrollable).first,
        const Offset(0, -500),
        1000,
      );
      await tester.pumpAndSettle();
      expect(find.text('成员管理'), findsWidgets);
      await tester.tap(find.text('成员管理').first);
      await tester.pumpAndSettle();

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

      await scrollTo(tester, find.text('公司认证与我的身份'));
      await tester.tap(find.text('公司认证与我的身份').first);
      await tester.pumpAndSettle();

      await scrollTo(tester, find.widgetWithText(FilledButton, '加入组织'));
      await tester.tap(find.widgetWithText(FilledButton, '加入组织').first);
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextField, '邀请码'), 'JOIN-001');
      await tester.tap(find.widgetWithText(FilledButton, '加入组织'));
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('当前认证状态'));
      expect(find.text('org-join-1'), findsOneWidget);
      expect(find.text('已认证'), findsWidgets);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.textContaining('已认证'), findsWidgets);
      await scrollTo(tester, find.text('我的公司'));
      await tester.tap(find.text('我的公司').first);
      await tester.pumpAndSettle();

      expect(find.text('北京加入后组织'), findsWidgets);
      await scrollTo(tester, find.text('认证状态'));
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
    'certification page keeps resubmit unavailable without rejected or expired truth',
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

      await scrollTo(tester, find.text('当前认证状态'));
      expect(find.text('已认证'), findsOneWidget);
      expect(find.text('重新提交认证'), findsNothing);
      expect(find.text('提交认证'), findsNothing);
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
                    currentCertificationStatus = 'pending_review';
                    currentRejectReason = null;
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'organizationId': organizationId,
                        'certificationStatus': 'pending_review',
                        'submittedAt': '2026-04-05 10:10',
                        'traceId': 'cert-resubmit-1',
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
      await tester.pumpAndSettle();

      expect(find.textContaining('认证未通过'), findsWidgets);
      await scrollTo(tester, find.text('公司认证与我的身份'));
      await tester.tap(find.text('公司认证与我的身份').first);
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('当前认证状态'));
      expect(find.text('认证未通过'), findsOneWidget);
      expect(find.text('拒绝原因'), findsOneWidget);
      expect(find.text('营业执照信息不一致'), findsOneWidget);

      await scrollTo(tester, find.text('重新提交认证'));
      await tester.tap(find.text('重新提交认证'));
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
        find.widgetWithText(TextField, '营业执照文件 ID'),
        'file-license-2',
      );
      await tester.enterText(
        find.widgetWithText(TextField, '补充说明'),
        '已补充最新营业执照',
      );
      await scrollTo(tester, find.widgetWithText(FilledButton, '重新提交认证'));
      await tester.tap(find.widgetWithText(FilledButton, '重新提交认证'));
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('当前认证状态'));
      expect(find.text('认证中'), findsWidgets);
      expect(find.text('拒绝原因'), findsNothing);
      expect(find.text('营业执照信息不一致'), findsNothing);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.textContaining('认证中'), findsWidgets);
      await scrollTo(tester, find.text('我的公司'));
      await tester.tap(find.text('我的公司').first);
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('认证状态'));
      expect(find.text('认证中'), findsWidgets);
      expect(find.text('拒绝原因'), findsNothing);
      expect(find.text('营业执照信息不一致'), findsNothing);
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
                        'submittedAt': '2025-04-01 09:00',
                        'expiresAt': ?currentExpiresAt,
                      },
                    );
                  },
              'POST /api/app/profile/certification/resubmit':
                  (AppApiRequest request) async {
                    currentCertificationStatus = 'pending_review';
                    currentExpiresAt = null;
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'organizationId': organizationId,
                        'certificationStatus': 'pending_review',
                        'submittedAt': '2026-04-05 10:10',
                        'traceId': 'cert-resubmit-expired-1',
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
      await tester.pumpAndSettle();

      expect(find.textContaining('已过期'), findsWidgets);
      await scrollTo(tester, find.text('公司认证与我的身份'));
      await tester.tap(find.text('公司认证与我的身份').first);
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('当前认证状态'));
      expect(find.text('已过期'), findsOneWidget);
      expect(find.text('有效期'), findsOneWidget);
      expect(find.text('2026-04-01'), findsOneWidget);

      await scrollTo(tester, find.text('重新提交认证'));
      await tester.tap(find.text('重新提交认证'));
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
        find.widgetWithText(TextField, '营业执照文件 ID'),
        'file-license-3',
      );
      await tester.enterText(
        find.widgetWithText(TextField, '补充说明'),
        '已补充最新过期材料',
      );
      await scrollTo(tester, find.widgetWithText(FilledButton, '重新提交认证'));
      await tester.tap(find.widgetWithText(FilledButton, '重新提交认证'));
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('当前认证状态'));
      expect(find.text('认证中'), findsWidgets);
      expect(find.text('有效期'), findsNothing);
      expect(find.text('2026-04-01'), findsNothing);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.textContaining('认证中'), findsWidgets);
      await scrollTo(tester, find.text('我的公司'));
      await tester.tap(find.text('我的公司').first);
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('认证状态'));
      expect(find.text('认证中'), findsWidgets);
      expect(find.text('2026-04-01'), findsNothing);
    },
  );

  testWidgets(
    'certification resubmit keeps controlled failure when current truth does not allow resubmit',
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
                  'POST /api/app/profile/certification/resubmit':
                      (AppApiRequest request) async {
                        return AppApiResponse(
                          statusCode: 409,
                          uri: request.uri,
                          body: const <String, Object?>{
                            'message': '当前认证状态不允许重新提交，请先返回查看最新认证状态。',
                          },
                        );
                      },
                },
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
      await tester.enterText(
        find.widgetWithText(TextField, '营业执照文件 ID'),
        'file-license-2',
      );
      await scrollTo(tester, find.widgetWithText(FilledButton, '重新提交认证'));
      await tester.tap(find.widgetWithText(FilledButton, '重新提交认证'));
      await tester.pumpAndSettle();

      expect(find.text('认证提交当前未完成'), findsOneWidget);
      expect(find.text('当前认证状态不允许重新提交，请先返回查看最新认证状态。'), findsOneWidget);
    },
  );

  testWidgets(
    'certification resubmit keeps controlled failure when license file truth is missing',
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
                  'POST /api/app/profile/certification/resubmit':
                      (AppApiRequest request) async {
                        expect(request.body, <String, Object?>{
                          'organizationId': 'org-expired',
                          'legalName': '上海展建服务有限公司',
                          'uscc': '91310000123456789A',
                          'licenseFileId': '',
                          'supplementNote': '已补充说明但缺少执照文件',
                        });
                        return AppApiResponse(
                          statusCode: 409,
                          uri: request.uri,
                          body: const <String, Object?>{
                            'message': '当前缺少营业执照文件，请重新上传后再试。',
                          },
                        );
                      },
                },
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
        '已补充说明但缺少执照文件',
      );
      await scrollTo(tester, find.widgetWithText(FilledButton, '重新提交认证'));
      await tester.tap(find.widgetWithText(FilledButton, '重新提交认证'));
      await tester.pumpAndSettle();

      expect(find.text('认证提交当前未完成'), findsOneWidget);
      expect(find.text('当前缺少营业执照文件，请重新上传后再试。'), findsOneWidget);
    },
  );
}

class _PassthroughHttpOverrides extends HttpOverrides {}
