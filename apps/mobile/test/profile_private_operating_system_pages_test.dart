import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/features/profile/data/profile_credit_constraints_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_payment_billing_consumer_layer.dart';
import 'profile_private_operating_system_test_support.dart';

void main() {
  HttpOverrides? previousHttpOverrides;

  setUp(() {
    previousHttpOverrides = HttpOverrides.current;
    HttpOverrides.global = PrivateOperatingSystemPassthroughHttpOverrides();
    installDefaultPrivateOperatingSystemSupportConsumers();
  });

  tearDown(() {
    HttpOverrides.global = previousHttpOverrides;
    AppSessionStore.reset();
    ProfileCreditConstraintsConsumerLayer.reset();
    ProfilePaymentBillingConsumerLayer.reset();
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
    'profile page applies bounded regrouping and preserves family order',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildPrivateOperatingSystemProfileApp(
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
          shellContext: privateOperatingSystemShellContextData(
            organizationId: 'org-v23',
            roleKeys: const <String>['buyer_admin'],
            certificationStatus: 'approved',
            membershipStatus: 'active',
            paidMembershipTier: 'standard',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('当前为私域整理视图'), findsOneWidget);
      expect(find.text('身份与组织'), findsOneWidget);
      expect(find.text('我的资产'), findsOneWidget);
      expect(find.text('常用入口'), findsNothing);
      expect(find.text('我的项目'), findsOneWidget);
      expect(find.text('我的论坛'), findsOneWidget);
      expect(
        find.textContaining('保留 我的公司、认证与成员身份、我的项目、我的论坛、设置 的一层存在与顺序'),
        findsOneWidget,
      );

      await scrollTo(tester, find.text('我的论坛'));
      final projectTop = tester.getTopLeft(find.text('我的项目')).dy;
      final forumTop = tester.getTopLeft(find.text('我的论坛')).dy;
      expect(projectTop, lessThan(forumTop));

      expect(find.text('设置'), findsWidgets);
    },
  );

  testWidgets(
    'profile page keeps legacy order when regrouping projection is unavailable',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildPrivateOperatingSystemProfileApp(
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
                        includeProjection: false,
                      ),
                    );
                  },
                },
          ),
          shellContext: privateOperatingSystemShellContextData(
            organizationId: 'org-v23',
            roleKeys: const <String>['buyer_admin'],
            certificationStatus: 'approved',
            membershipStatus: 'active',
            paidMembershipTier: 'standard',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('私域整理引用当前暂不可用'), findsOneWidget);
      expect(find.textContaining('myBuildingProjection'), findsOneWidget);
      expect(find.text('常用入口'), findsOneWidget);
      expect(find.text('身份与组织'), findsNothing);
      expect(find.text('我的资产'), findsNothing);
    },
  );

  testWidgets(
    'profile page fail-closes regrouping when session is unavailable',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildPrivateOperatingSystemProfileApp(
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
          shellContext: privateOperatingSystemShellContextData(
            organizationId: 'org-v23',
            roleKeys: const <String>['buyer_admin'],
            certificationStatus: 'approved',
            membershipStatus: 'active',
            paidMembershipTier: 'standard',
          ),
          establishSession: false,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('当前会话暂不可用'), findsWidgets);
      expect(find.text('当前没有可验证的会话，我的楼不展示伪造账号摘要或整理结果。'), findsOneWidget);
      expect(find.text('常用入口'), findsOneWidget);
      expect(find.text('身份与组织'), findsNothing);
      expect(find.text('我的资产'), findsNothing);
    },
  );
}
