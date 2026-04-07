import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/boot/app_shell_context_consumer.dart';
import 'package:mobile/features/profile/data/profile_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_private_operating_system_projection.dart';
import 'profile_private_operating_system_test_support.dart';

void main() {
  HttpOverrides? previousHttpOverrides;

  setUp(() {
    previousHttpOverrides = HttpOverrides.current;
    HttpOverrides.global = PrivateOperatingSystemPassthroughHttpOverrides();
    ProfileConsumerLayer.reset();
  });

  tearDown(() {
    HttpOverrides.global = previousHttpOverrides;
    ProfileConsumerLayer.reset();
  });

  test(
    'profile and shell carriers keep myBuildingProjection for V2.3',
    () async {
      final profileConsumer = ProfileConsumerLayer(
        client: AppApiClient(
          config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
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
                      body: privateOperatingSystemProfilePayload(
                        organizationId: 'org-v23',
                        roleKeys: const <String>['buyer_admin'],
                        certificationStatus: 'approved',
                        membershipStatus: 'active',
                      ),
                    );
                  },
                },
          ),
        ),
      );
      final shellConsumer = AppShellContextConsumer(
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
                      body: privateOperatingSystemShellContextPayload(
                        organizationId: 'org-v23',
                        roleKeys: const <String>['buyer_admin'],
                        certificationStatus: 'approved',
                        membershipStatus: 'active',
                        paidMembershipTier: 'standard',
                      ),
                    );
                  },
                },
          ),
        ),
      );

      final profileResult = await profileConsumer.loadIndex();
      final shellResult = await shellConsumer.loadResult();
      final resolved = resolveProfilePrivateOperatingSystemProjection(
        profileData: profileResult.data,
        shellContext: shellResult.data!,
      );

      expect(profileResult.state, AppPageState.content);
      expect(shellResult.state, AppPageState.content);
      expect(
        profileResult.data?.myBuildingProjection?['regroupingKey'],
        'my_building_compact_current_user_hub',
      );
      expect(
        shellResult.data?.myBuildingProjection?['orderingReferenceVersion'],
        'v23.private-operating-system.package1',
      );
      expect(resolved, isA<ProfilePrivateOperatingSystemProjectionView>());
      expect(
        (resolved as ProfilePrivateOperatingSystemProjectionView)
            .visibleFamilyKeys,
        const <String>[
          'my_company',
          'certification_membership_status',
          'my_projects',
          'my_forum',
          'settings',
        ],
      );
    },
  );

  test(
    'shell context keeps unauthorized state controlled on HTTP 401',
    () async {
      final shellConsumer = AppShellContextConsumer(
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
                      statusCode: 401,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'message': '当前会话已失效，请重新登录。',
                        'code': 'AUTH_SESSION_INVALID',
                      },
                    );
                  },
                },
          ),
        ),
      );

      final result = await shellConsumer.loadResult();

      expect(result.state, AppPageState.unauthorized);
      expect(result.errorCode, 'AUTH_SESSION_INVALID');
      expect(result.message, '当前会话已失效，请重新登录。');
    },
  );
}
