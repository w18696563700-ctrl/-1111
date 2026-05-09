import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/profile/navigation/profile_routes.dart';
import 'package:mobile/shell/shell_app.dart';

AppApiClient _client(FakeAppApiTransport transport) {
  return AppApiClient(
    config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
    transport: transport,
  );
}

Map<String, Object?> _projectDetailPayload() {
  return <String, Object?>{
    'projectId': 'project-1',
    'projectNo': 'PROJ-1',
    'title': '重庆电子展项目',
    'buildingType': 'exhibition',
    'budgetAmount': 12000,
    'state': 'published',
    'summary': <String, Object?>{'heading': '重庆电子展项目'},
    'viewerProjectRelation': 'my_bid',
    'currentViewerBid': <String, Object?>{
      'bidId': 'bid-1',
      'state': 'submitted',
    },
  };
}

ExhibitionMobileApp _buildApp(FakeAppApiTransport transport) {
  final sessionStore = AppSessionStore()
    ..establishSession(
      accessToken: 'test-access',
      refreshToken: 'test-refresh',
      expiresInSeconds: 3600,
      deviceId: 'test-device',
    );

  return ExhibitionMobileApp(
    initialRoute: ProfileRoutes.bidServiceFeeAuthorizationWithIds(
      projectId: 'project-1',
      bidParticipationRequestId: 'request-1',
      bidId: 'bid-1',
    ),
    bootstrapShellContext: AppShellContextData(
      userId: 'user-1',
      organizationId: 'org-1',
      organizationType: 'supplier',
      roleKeys: const <String>['supplier'],
      certificationStatus: 'approved',
      personalCertificationStatus: 'approved',
      personalCertificationQualified: true,
      personalCertificationLockedToOtherActor: false,
      membershipStatus: 'active',
      visibleBuildings: const <String>['exhibition', 'messages', 'profile'],
    ),
    sessionStore: sessionStore,
    exhibitionConsumerLayer: ExhibitionConsumerLayer(
      client: _client(transport),
    ),
  );
}

Map<String, Future<AppApiResponse> Function(AppApiRequest request)> _handlers({
  required String authorizationStatus,
  String createAuthorizationStatus = 'pending_freeze',
  bool failCreate = false,
  bool failFreezeInit = false,
}) {
  return <String, Future<AppApiResponse> Function(AppApiRequest request)>{
    'GET ${ExhibitionCanonicalPaths.projectDetail}':
        (AppApiRequest request) async => AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: _projectDetailPayload(),
        ),
    'POST ${ExhibitionCanonicalPaths.projectBidServiceFeeAuthorizations('project-1')}':
        (AppApiRequest request) async {
          if (failCreate) {
            return AppApiResponse(
              statusCode: 409,
              uri: request.uri,
              body: const <String, Object?>{
                'errorCode': 'SERVICE_FEE_AUTHORIZATION_BLOCKED',
                'message': 'Server 返回：当前资料确认状态不满足预授权前置条件。',
              },
            );
          }
          return AppApiResponse(
            statusCode: 201,
            uri: request.uri,
            body: <String, Object?>{
              'authorizationId': 'auth-1',
              'authorizationStatus': createAuthorizationStatus,
              'quotaAmount': '4000.00',
              'currency': 'CNY',
            },
          );
        },
    'POST ${ExhibitionCanonicalPaths.projectBidServiceFeeAuthorizationFreezeInit('project-1', 'auth-1')}':
        (AppApiRequest request) async {
          if (failFreezeInit) {
            return AppApiResponse(
              statusCode: 409,
              uri: request.uri,
              body: const <String, Object?>{
                'code': 'BID_SERVICE_FEE_AUTHORIZATION_FREEZE_INIT_REJECTED',
                'message': '当前竞标服务费预授权状态为 failed，暂不能重新拉起支付宝确认，请刷新状态后处理。',
              },
            );
          }
          return AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: const <String, Object?>{
              'authorizationId': 'auth-1',
              'authorizationStatus': 'pending_freeze',
              'paymentReferenceId': 'auth-ref-1',
              'channelActionType': 'sdk_payload',
              'channelPayload': <String, Object?>{
                'provider': 'alipay',
                'orderString': 'alipay-sdk-order',
              },
              'callbackAwaiting': true,
            },
          );
        },
    'GET ${ExhibitionCanonicalPaths.projectBidServiceFeeAuthorizationStatus('project-1', 'auth-1')}':
        (AppApiRequest request) async => AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: <String, Object?>{
            'authorizationId': 'auth-1',
            'authorizationStatus': authorizationStatus,
            'quotaAmount': '4000.00',
            'currency': 'CNY',
            'updatedAt': '2026-05-13T00:03:00Z',
          },
        ),
  };
}

Future<void> _pumpPage(
  WidgetTester tester,
  FakeAppApiTransport transport,
) async {
  await tester.binding.setSurfaceSize(const Size(420, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(_buildApp(transport));
  await tester.pumpAndSettle();
}

void main() {
  tearDown(AppSessionStore.reset);

  testWidgets(
    'service fee authorization route is RC-unavailable and does not call payment APIs',
    (WidgetTester tester) async {
      final transport = FakeAppApiTransport(
        handlers: _handlers(authorizationStatus: 'pending_freeze'),
      );

      await _pumpPage(tester, transport);

      expect(find.text('该功能暂未开放'), findsWidgets);
      expect(find.textContaining('当前 RC 版本只保留最小可上线闭环'), findsOneWidget);
      expect(find.text('去支付宝确认预授权'), findsNothing);
      expect(find.text('预授权确认'), findsNothing);
      expect(
        transport.requests.any(
          (AppApiRequest request) =>
              request.method == AppApiMethod.post &&
              request.canonicalPath ==
                  ExhibitionCanonicalPaths.projectBidServiceFeeAuthorizations(
                    'project-1',
                  ),
        ),
        isFalse,
      );
      expect(
        transport.requests.any(
          (AppApiRequest request) =>
              request.canonicalPath ==
              ExhibitionCanonicalPaths.projectBidServiceFeeAuthorizationFreezeInit(
                'project-1',
                'auth-1',
              ),
        ),
        isFalse,
      );
      expect(
        transport.requests.any(
          (AppApiRequest request) =>
              request.canonicalPath ==
              ExhibitionCanonicalPaths.projectBidServiceFeeAuthorizationStatus(
                'project-1',
                'auth-1',
              ),
        ),
        isFalse,
      );
    },
  );
}
