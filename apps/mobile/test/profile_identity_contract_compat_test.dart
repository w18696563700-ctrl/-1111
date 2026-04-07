import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/auth/auth_consumer_layer.dart';
import 'package:mobile/core/boot/app_shell_context_consumer.dart';
import 'package:mobile/features/profile/data/profile_credit_constraints_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_identity_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_membership_consumer_layer.dart';
import 'package:mobile/features/profile/presentation/profile_organization_pages.dart';
import 'package:mobile/features/profile/presentation/profile_visible_copy.dart';

void main() {
  HttpOverrides? previousHttpOverrides;

  setUp(() {
    previousHttpOverrides = HttpOverrides.current;
    HttpOverrides.global = _PassthroughHttpOverrides();
    AppSessionStore.reset();
    AuthConsumerLayer.reset();
    ProfileCreditConstraintsConsumerLayer.reset();
    ProfileIdentityConsumerLayer.reset();
    ProfileMembershipConsumerLayer.reset();
  });

  tearDown(() {
    HttpOverrides.global = previousHttpOverrides;
    AppSessionStore.reset();
    AuthConsumerLayer.reset();
    ProfileCreditConstraintsConsumerLayer.reset();
    ProfileIdentityConsumerLayer.reset();
    ProfileMembershipConsumerLayer.reset();
  });

  test('otp send/login stays content on HTTP 200 (not 201-only)', () async {
    final consumer = AuthConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'POST /api/app/auth/otp/send': (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'cooldownSeconds': 60,
                      'traceId': 'trace-otp-send',
                    },
                  );
                },
                'POST /api/app/auth/otp/login': (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'accessToken': 'sess-token',
                      'refreshToken': 'refresh-token',
                      'expiresInSeconds': 3600,
                      'shellBootstrapState': 'authenticated',
                    },
                  );
                },
              },
        ),
      ),
    );

    final sendResult = await consumer.sendOtp(mobile: '13800000000');
    expect(sendResult.state, AppPageState.content);
    expect(sendResult.data?.traceId, 'trace-otp-send');

    final loginResult = await consumer.loginWithOtp(
      mobile: '13800000000',
      otpCode: '123456',
    );
    expect(loginResult.state, AppPageState.content);
    expect(loginResult.data?.shellBootstrapState, 'authenticated');
    expect(AppSessionStore.instance.snapshot.hasAccessToken, isTrue);
    expect(AppSessionStore.instance.snapshot.hasRefreshToken, isTrue);
  });

  test(
    'organization create stays content on HTTP 200 (not 201-only)',
    () async {
      final consumer = ProfileIdentityConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'POST /api/app/profile/organization/create':
                      (AppApiRequest request) async {
                        return AppApiResponse(
                          statusCode: 200,
                          uri: request.uri,
                          body: const <String, Object?>{
                            'organizationId': 'org-200',
                            'roleKeys': <String>['buyer_admin'],
                            'membershipStatus': 'active',
                            'certificationStatus': 'not_submitted',
                          },
                        );
                      },
                },
          ),
        ),
      );

      final result = await consumer.createOrganization(
        name: '前端联调组织',
        organizationType: 'demand',
        provinceCode: '510000',
        cityCode: '510100',
        contactName: '联调用户',
        contactMobile: '13800000000',
      );

      expect(result.state, AppPageState.content);
      expect(result.data?.organizationId, 'org-200');
    },
  );

  testWidgets('organization create only exposes frozen organization types', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: OrganizationCreatePage())),
    );

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();

    expect(find.text('需求方'), findsWidgets);
    expect(find.text('供应商'), findsOneWidget);
    expect(find.text('需求方 / 供应商'), findsOneWidget);
    expect(find.text('工厂'), findsNothing);
    expect(find.text('品牌方'), findsNothing);
    expect(find.text('服务商'), findsNothing);
  });

  test('profile visible copy stays aligned to frozen truth', () {
    expect(profileDisplayCertificationStatus('not_submitted'), '未认证');
    expect(profileDisplayCertificationStatus('pending_review'), '认证中');
    expect(profileDisplayCertificationStatus('approved'), '已认证');
    expect(profileDisplayCertificationStatus('rejected'), '认证未通过');
    expect(profileDisplayCertificationStatus('expired'), '已过期');
    expect(profileDisplayCertificationStatus('pending'), '待补充');
    expect(profileDisplayCertificationStatus('verified'), '待补充');
    expect(profileDisplayOrganizationType('both'), '需求方 / 供应商');
    expect(profileDisplayRoleKey('buyer_member(scoped)'), '需求成员');
    expect(profileDisplayOrganizationMemberStatus('disabled'), '已禁用');
  });

  test('organization join-by-code stays content on HTTP 200', () async {
    final consumer = ProfileIdentityConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'POST /api/app/profile/organization/join-by-code':
                    (AppApiRequest request) async {
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
        ),
      ),
    );

    final result = await consumer.joinByCode(inviteCode: 'JOIN-001');

    expect(
      result.state,
      AppPageState.content,
      reason: 'message=${result.message}',
    );
    expect(result.data?.organizationId, 'org-join-1');
    expect(result.data?.traceId, 'join-trace-1');
  });

  test('organization switch stays content on HTTP 200', () async {
    final consumer = ProfileIdentityConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'POST /api/app/profile/organization/switch':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'userId': 'user-1',
                          'organizationId': 'org-switch-1',
                          'roleKeys': <String>['buyer_admin'],
                          'certificationStatus': 'approved',
                          'membershipStatus': 'active',
                          'visibleBuildings': <String>[
                            'exhibition',
                            'messages',
                            'profile',
                          ],
                          'featureFlagsVersion': '0.1.0',
                          'unreadSummary': <String, Object?>{
                            'total': 0,
                            'system': 0,
                            'business': 0,
                          },
                        },
                      );
                    },
              },
        ),
      ),
    );

    final result = await consumer.switchOrganization(
      organizationId: 'org-switch-1',
    );

    expect(
      result.state,
      AppPageState.content,
      reason: 'message=${result.message}',
    );
    expect(result.data?.organizationId, 'org-switch-1');
    expect(result.data?.certificationStatus, 'approved');
  });

  test('certification submit stays content on HTTP 200', () async {
    final consumer = ProfileIdentityConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'POST /api/app/profile/certification/submit':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'organizationId': 'org-cert-1',
                          'certificationStatus': 'pending_review',
                          'submittedAt': '2026-04-05T10:00:00Z',
                          'traceId': 'cert-submit-1',
                        },
                      );
                    },
              },
        ),
      ),
    );

    final result = await consumer.submitCertification(
      organizationId: 'org-cert-1',
      legalName: '上海展建服务有限公司',
      uscc: '91310000123456789A',
      licenseFileId: 'file-license-1',
      contactName: '张三',
      contactMobile: '13800000000',
    );

    expect(result.state, AppPageState.content);
    expect(result.data?.organizationId, 'org-cert-1');
    expect(result.data?.traceId, 'cert-submit-1');
  });

  test('certification resubmit stays content on HTTP 200', () async {
    final consumer = ProfileIdentityConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'POST /api/app/profile/certification/resubmit':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'organizationId': 'org-cert-1',
                          'certificationStatus': 'pending_review',
                          'submittedAt': '2026-04-05T10:10:00Z',
                          'traceId': 'cert-resubmit-1',
                        },
                      );
                    },
              },
        ),
      ),
    );

    final result = await consumer.resubmitCertification(
      organizationId: 'org-cert-1',
      legalName: '上海展建服务有限公司',
      uscc: '91310000123456789A',
      licenseFileId: 'file-license-2',
      supplementNote: '已补充新执照',
    );

    expect(result.state, AppPageState.content);
    expect(result.data?.organizationId, 'org-cert-1');
    expect(result.data?.traceId, 'cert-resubmit-1');
  });

  test('membership current stays content on HTTP 200', () async {
    final consumer = ProfileMembershipConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'GET /api/app/profile/membership/current':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'organizationId': 'org-member-1',
                          'paidMembershipTier': 'standard',
                          'rateBand': '标准费率档位',
                          'entitlementsSummary': <String>['更高排序'],
                          'quotaSummary': <String>['商机提醒剩余 12 次'],
                          'effectiveAt': '2026-04-01T00:00:00Z',
                          'expiresAt': '2027-04-01T00:00:00Z',
                          'nextRefreshAt': '2026-04-06T00:00:00Z',
                        },
                      );
                    },
              },
        ),
      ),
    );

    final result = await consumer.loadCurrent();

    expect(result.state, AppPageState.content);
    expect(result.data?.paidMembershipTier, 'standard');
    expect(result.data?.rateBand, '标准费率档位');
    expect(result.data?.entitlementsSummary, const <String>['更高排序']);
  });

  test('membership explanation stays content on HTTP 200', () async {
    final consumer = ProfileMembershipConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'GET /api/app/profile/membership/explanation':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'tiers': <Object?>[
                            <String, Object?>{
                              'tier': 'standard',
                              'title': '标准档位',
                              'highlights': <String>['更高排序'],
                            },
                          ],
                          'entitlementNotes': <String>['权益说明一'],
                          'quotaNotes': <String>['配额说明一'],
                          'disclaimer': '当前仅提供读面说明。',
                        },
                      );
                    },
              },
        ),
      ),
    );

    final result = await consumer.loadExplanation();

    expect(result.state, AppPageState.content);
    expect(result.data?.tiers.single.title, '标准档位');
    expect(result.data?.disclaimer, '当前仅提供读面说明。');
  });

  test('membership quota stays content on HTTP 200', () async {
    final consumer = ProfileMembershipConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
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
                          'nextRefreshAt': '2026-04-06T00:00:00Z',
                        },
                      );
                    },
              },
        ),
      ),
    );

    final result = await consumer.loadQuota();

    expect(result.state, AppPageState.content);
    expect(result.data?.items.single.summary, '商机提醒额度');
    expect(result.data?.items.single.currentValue, 12);
  });

  test('membership upgrade-guide stays content on HTTP 200', () async {
    final consumer = ProfileMembershipConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
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
                          'upgradeHighlights': <String>['人工撮合优先'],
                          'commercialDisclosure': '当前仅提供升级说明。',
                        },
                      );
                    },
              },
        ),
      ),
    );

    final result = await consumer.loadUpgradeGuide();

    expect(result.state, AppPageState.content);
    expect(result.data?.currentTier, 'standard');
    expect(result.data?.availableTiers.single.title, '专业档位');
    expect(result.data?.commercialDisclosure, '当前仅提供升级说明。');
  });

  test('credit-and-constraints status stays content on HTTP 200', () async {
    final consumer = ProfileCreditConstraintsConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
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
                            'updatedAt': '2026-04-06T09:30:00Z',
                          },
                          'creditConstraint': <String, Object?>{
                            'creditConstraintStatus': 'clear',
                            'performanceConstraintStatus': 'clear',
                            'executionAvailabilityStatus': 'limited',
                            'restrictionReasonCode': null,
                            'advisoryReasonCode': 'credit_advisory',
                            'updatedAt': '2026-04-06T09:30:00Z',
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
                            'updatedAt': '2026-04-06T09:30:00Z',
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
                            'updatedAt': '2026-04-06T09:30:00Z',
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
              },
        ),
      ),
    );

    final result = await consumer.loadStatus();

    expect(result.state, AppPageState.content);
    expect(result.data?.privateSummary.entryKey, 'my_credit_and_constraints');
    expect(result.data?.privateSummary.summaryStatus, 'handoff_required');
    expect(
      result.data?.dependencyReference?.dependencyFamilyKey,
      'v22_payment_billing',
    );
  });

  test('credit-and-constraints explanation stays content on HTTP 200', () async {
    final consumer = ProfileCreditConstraintsConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
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
                        'body': '当前交易保障仍停在 eligibility 与 handoff posture。',
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
          },
        ),
      ),
    );

    final result = await consumer.loadExplanation();

    expect(result.state, AppPageState.content);
    expect(result.data?.creditExplanation.title, '当前信用约束');
    expect(result.data?.depositExplanation.title, '当前保证金姿态');
    expect(result.data?.dependencyExplanation?.dependencyRequired, isTrue);
  });

  test('credit-and-constraints handoff stays content on HTTP 200', () async {
    final consumer = ProfileCreditConstraintsConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/profile/credit-and-constraints/handoff':
                (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'creditHandoff': <String, Object?>{
                        'handoffKey': 'credit_rule_explanation',
                        'title': '信用处理方向',
                        'body': '当前建议先查看规则说明。',
                      },
                      'depositHandoff': <String, Object?>{
                        'handoffKey': 'deposit_open_payment_dependency',
                        'title': '保证金处理方向',
                        'body':
                            '当前只允许 handoff 到后续 payment/billing capability family。',
                      },
                      'transactionGuaranteeHandoff': <String, Object?>{
                        'handoffKey': 'transaction_guarantee_open_dependency',
                        'title': '交易保障处理方向',
                        'body': '当前保障语义只表达 handoff 与 dependency posture。',
                      },
                      'dependencyHandoff': <String, Object?>{
                        'dependencyFamilyKey': 'v22_payment_billing',
                        'dependencyRequired': true,
                        'dependencyHandoffKey': 'open_v22_payment_billing',
                        'title': '后续依赖方向',
                        'body':
                            '当前后续动作仍需 V2.2 payment/billing package dependency。',
                      },
                    },
                  );
                },
          },
        ),
      ),
    );

    final result = await consumer.loadHandoff();

    expect(result.state, AppPageState.content);
    expect(result.data?.creditHandoff.title, '信用处理方向');
    expect(
      result.data?.depositHandoff.handoffKey,
      'deposit_open_payment_dependency',
    );
    expect(
      result.data?.dependencyHandoff?.dependencyFamilyKey,
      'v22_payment_billing',
    );
  });

  test('security devices list stays content on HTTP 200', () async {
    final consumer = ProfileIdentityConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
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
                              'deviceId': 'device-1',
                              'deviceName': 'iPhone 15 Pro',
                              'osType': 'iOS',
                              'appVersion': '1.0.0',
                              'currentDevice': true,
                              'trustStatus': 'trusted',
                              'lastSeenAt': '2026-04-05 10:00',
                              'revokedAt': null,
                            },
                          ],
                        },
                      );
                    },
              },
        ),
      ),
    );

    final result = await consumer.loadSecurityDevices();

    expect(result.state, AppPageState.content);
    expect(result.data?.items.single.deviceId, 'device-1');
    expect(result.data?.items.single.currentDevice, isTrue);
    expect(result.data?.items.single.trustStatus, 'trusted');
  });

  test('security device revoke stays content on HTTP 200', () async {
    final consumer = ProfileIdentityConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'POST /api/app/profile/security/devices/device-2/revoke':
                    (AppApiRequest request) async {
                      expect(request.body, const <String, Object?>{
                        'deviceId': 'device-2',
                      });
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
      ),
    );

    final result = await consumer.revokeSecurityDevice(deviceId: 'device-2');

    expect(result.state, AppPageState.content);
    expect(result.data?.ok, isTrue);
    expect(result.data?.traceId, 'device-revoke-1');
  });

  test('organization members list stays content on HTTP 200', () async {
    final consumer = ProfileIdentityConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'GET /api/app/profile/organization/members':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'items': <Object?>[
                            <String, Object?>{
                              'memberId': 'member-1',
                              'userId': 'user-1',
                              'displayName': '张三',
                              'mobileMasked': '138****1111',
                              'roleKey': 'buyer_admin',
                              'memberStatus': 'active',
                              'joinedAt': '2026-04-05T10:00:00Z',
                              'disabledAt': null,
                            },
                          ],
                        },
                      );
                    },
              },
        ),
      ),
    );

    final result = await consumer.loadOrganizationMembers();

    expect(result.state, AppPageState.content);
    expect(result.data?.items.single.memberId, 'member-1');
    expect(result.data?.items.single.roleKey, 'buyer_admin');
    expect(result.data?.items.single.memberStatus, 'active');
  });

  test('organization member role patch stays content on HTTP 200', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() async {
      await server.close(force: true);
    });

    unawaited(() async {
      await for (final HttpRequest request in server) {
        if (request.method == 'PATCH' &&
            request.uri.path ==
                '/api/app/profile/organization/members/member-2/role') {
          final rawBody = await utf8.decoder.bind(request).join();
          expect(jsonDecode(rawBody), const <String, Object?>{
            'roleKey': 'supplier_admin',
            'reason': null,
          });
          request.response
            ..statusCode = 200
            ..headers.contentType = ContentType.json
            ..write(
              jsonEncode(const <String, Object?>{
                'ok': true,
                'traceId': 'member-role-1',
              }),
            );
          await request.response.close();
          continue;
        }

        request.response.statusCode = 404;
        await request.response.close();
      }
    }());

    final consumer = ProfileIdentityConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(
          baseUrl: 'http://${server.address.host}:${server.port}/api/app',
        ),
      ),
    );

    final result = await consumer.patchOrganizationMemberRole(
      memberId: 'member-2',
      roleKey: 'supplier_admin',
    );

    expect(result.state, AppPageState.content);
    expect(result.data?.ok, isTrue);
    expect(result.data?.traceId, 'member-role-1');
  });

  test('organization member disable stays content on HTTP 200', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() async {
      await server.close(force: true);
    });

    unawaited(() async {
      await for (final HttpRequest request in server) {
        if (request.method == 'PATCH' &&
            request.uri.path ==
                '/api/app/profile/organization/members/member-3/disable') {
          final rawBody = await utf8.decoder.bind(request).join();
          expect(jsonDecode(rawBody), const <String, Object?>{'reason': null});
          request.response
            ..statusCode = 200
            ..headers.contentType = ContentType.json
            ..write(
              jsonEncode(const <String, Object?>{
                'ok': true,
                'traceId': 'member-disable-1',
              }),
            );
          await request.response.close();
          continue;
        }

        request.response.statusCode = 404;
        await request.response.close();
      }
    }());

    final consumer = ProfileIdentityConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(
          baseUrl: 'http://${server.address.host}:${server.port}/api/app',
        ),
      ),
    );

    final result = await consumer.disableOrganizationMember(
      memberId: 'member-3',
    );

    expect(result.state, AppPageState.content);
    expect(result.data?.ok, isTrue);
    expect(result.data?.traceId, 'member-disable-1');
  });

  test(
    'shell/context consumes successfully without optional extra fields',
    () async {
      final consumer = AppShellContextConsumer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/shell/context': (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'userId': 'user-1',
                        'organizationId': null,
                        'roleKeys': <String>[],
                        'certificationStatus': null,
                        'membershipStatus': null,
                        'visibleBuildings': <String>[
                          'exhibition',
                          'messages',
                          'profile',
                        ],
                        'featureFlagsVersion': '0.1.0',
                        'unreadSummary': <String, Object?>{
                          'total': 0,
                          'system': 0,
                          'business': 0,
                        },
                      },
                    );
                  },
                },
          ),
        ),
      );

      final result = await consumer.loadResult();

      expect(result.state, AppPageState.content);
      expect(result.data?.userId, 'user-1');
      expect(result.data?.organizationId, isNull);
      expect(result.data?.visibleBuildings, const <String>[
        'exhibition',
        'messages',
        'profile',
      ]);
    },
  );

  test(
    'shell/context consumes paid membership summary extension without polluting membershipStatus',
    () async {
      final consumer = AppShellContextConsumer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/shell/context': (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'userId': 'user-1',
                        'organizationId': 'org-member-1',
                        'roleKeys': <String>['buyer_admin'],
                        'certificationStatus': 'approved',
                        'membershipStatus': 'active',
                        'paidMembershipTier': 'standard',
                        'paidMembershipEntitlementsSummary': <String>['更高排序'],
                        'paidMembershipQuotaSummary': <String>['商机提醒剩余 12 次'],
                        'paidMembershipNextRefreshAt': '2026-04-06T00:00:00Z',
                        'visibleBuildings': <String>[
                          'exhibition',
                          'messages',
                          'profile',
                        ],
                        'featureFlagsVersion': '0.1.0',
                        'unreadSummary': <String, Object?>{
                          'total': 0,
                          'system': 0,
                          'business': 0,
                        },
                      },
                    );
                  },
                },
          ),
        ),
      );

      final result = await consumer.loadResult();

      expect(result.state, AppPageState.content);
      expect(result.data?.membershipStatus, 'active');
      expect(result.data?.paidMembershipTier, 'standard');
      expect(result.data?.paidMembershipEntitlementsSummary, const <String>[
        '更高排序',
      ]);
      expect(result.data?.paidMembershipQuotaSummary, const <String>[
        '商机提醒剩余 12 次',
      ]);
      expect(result.data?.paidMembershipNextRefreshAt, '2026-04-06T00:00:00Z');
    },
  );

  test(
    'shell/context consumes displayName and avatarUrl for personal minimal edit readback',
    () async {
      final consumer = AppShellContextConsumer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/shell/context': (AppApiRequest request) async {
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'userId': 'user-1',
                        'displayName': '张三',
                        'avatarUrl': 'http://127.0.0.1:1/avatar.png',
                        'organizationId': 'org-1',
                        'roleKeys': <String>['buyer_admin'],
                        'certificationStatus': 'approved',
                        'membershipStatus': 'active',
                        'visibleBuildings': <String>[
                          'exhibition',
                          'messages',
                          'profile',
                        ],
                        'featureFlagsVersion': '0.1.0',
                        'unreadSummary': <String, Object?>{
                          'total': 0,
                          'system': 0,
                          'business': 0,
                        },
                      },
                    );
                  },
                },
          ),
        ),
      );

      final result = await consumer.loadResult();

      expect(result.state, AppPageState.content);
      expect(result.data?.displayName, '张三');
      expect(result.data?.avatarUrl, 'http://127.0.0.1:1/avatar.png');
      expect(result.data?.organizationId, 'org-1');
    },
  );
}

class _PassthroughHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.userAgent = 'flutter-test';
    return client;
  }
}
