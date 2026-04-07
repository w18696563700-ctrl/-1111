import 'dart:io';

import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/forum_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_credit_constraints_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_payment_billing_consumer_layer.dart';
import 'package:mobile/shell/shell_app.dart';

Map<String, Object?> paymentBillingProfilePayload({
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

AppShellContextData paymentBillingShellContextData({
  String? organizationId,
  required List<String> roleKeys,
  String? certificationStatus,
  String? membershipStatus,
}) {
  return AppShellContextData(
    userId: '13812345678',
    organizationId: organizationId,
    roleKeys: roleKeys,
    certificationStatus: certificationStatus,
    membershipStatus: membershipStatus,
    visibleBuildings: const <String>['exhibition', 'messages', 'profile'],
  );
}

ExhibitionMobileApp buildPaymentBillingProfileApp({
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
                      'ongoingProjects': <Object?>[],
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

void installDefaultPaymentBillingSupportConsumers() {
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
                'GET /api/app/profile/payment-and-billing-status/explanation':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 404,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'message': '当前支付与账单说明暂不可用，请稍后再试。',
                          'code': 'PAYMENT_STATUS_UNAVAILABLE',
                        },
                      );
                    },
                'GET /api/app/profile/payment-and-billing-status/handoff':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 404,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'message': '当前支付与账单引导暂不可用，请稍后再试。',
                          'code': 'PAYMENT_HANDOFF_UNAVAILABLE',
                        },
                      );
                    },
              },
        ),
      ),
    ),
  );
}

final class PassthroughHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context);
  }
}

Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
_forumHandlers() {
  return <String, Future<AppApiResponse> Function(AppApiRequest request)>{
    'GET /api/app/forum/me/posts': (AppApiRequest request) async =>
        AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: const <String, Object?>{
            'items': <Object?>[],
            'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
          },
        ),
    'GET /api/app/forum/me/comments': (AppApiRequest request) async =>
        AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: const <String, Object?>{
            'items': <Object?>[],
            'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
          },
        ),
    'GET /api/app/forum/me/bookmarks': (AppApiRequest request) async =>
        AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: const <String, Object?>{
            'items': <Object?>[],
            'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
          },
        ),
    'GET /api/app/forum/me/follows': (AppApiRequest request) async =>
        AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: const <String, Object?>{
            'items': <Object?>[],
            'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
          },
        ),
    'GET /api/app/forum/draft/list': (AppApiRequest request) async =>
        AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: const <String, Object?>{
            'items': <Object?>[],
            'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
          },
        ),
  };
}
