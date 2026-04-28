import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/core/location/device_location_service.dart';
import 'package:mobile/features/profile/navigation/profile_routes.dart';
import 'package:mobile/shell/shell_app.dart';

const String _outputDir =
    '/Users/wangweiwei/Desktop/展览装修之家总控/.tmp/agent_reports/profile_settings_p0_day6_acceptance_20260428';

final class _Day6DeviceLocationService implements DeviceLocationService {
  int permissionReadCount = 0;
  int positionResolveCount = 0;

  @override
  bool get supportsDeviceLocation => true;

  @override
  bool get supportsReverseGeocoding => false;

  @override
  Future<DeviceLocationPermissionSnapshot> readPermissionStatus() async {
    permissionReadCount += 1;
    return const DeviceLocationPermissionSnapshot(
      permissionState: DeviceLocationPermissionState.denied,
      serviceEnabled: true,
      message: '定位权限未授予。',
    );
  }

  @override
  Future<bool> openAppPermissionSettings() async => true;

  @override
  Future<bool> openSystemLocationSettings() async => true;

  @override
  Future<DeviceLocationSnapshot> resolveCurrentPosition() async {
    positionResolveCount += 1;
    return const DeviceLocationSnapshot(
      permissionState: DeviceLocationPermissionState.denied,
      errorMessage: '定位权限未授予。',
    );
  }
}

Future<void> _pumpDay6App(
  WidgetTester tester,
  GlobalKey boundaryKey, {
  required String initialRoute,
  required _Day6DeviceLocationService locationService,
}) async {
  final sessionStore = AppSessionStore();
  sessionStore.establishSession(
    accessToken: 'day6-capture-access-token',
    refreshToken: 'day6-capture-refresh-token',
    expiresInSeconds: 3600,
    deviceId: 'day6-capture-device',
  );

  await tester.pumpWidget(
    RepaintBoundary(
      key: boundaryKey,
      child: KeyedSubtree(
        key: UniqueKey(),
        child: ExhibitionMobileApp(
          initialRoute: initialRoute,
          bootstrapShellContext: AppShellContextData(
            userId: '13812345678',
            organizationId: 'org-day6',
            roleKeys: const <String>['buyer_admin'],
            certificationStatus: 'approved',
            membershipStatus: 'active',
            visibleBuildings: const <String>[
              'exhibition',
              'messages',
              'profile',
            ],
          ),
          deviceLocationService: locationService,
          sessionStore: sessionStore,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _capture(GlobalKey boundaryKey, String filename) async {
  await expectLater(
    find.byKey(boundaryKey),
    matchesGoldenFile('$_outputDir/$filename'),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture profile settings P0 day6 acceptance screenshots', (
    WidgetTester tester,
  ) async {
    final boundaryKey = GlobalKey();
    final locationService = _Day6DeviceLocationService();
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
    await tester.binding.setSurfaceSize(const Size(393, 852));

    await _pumpDay6App(
      tester,
      boundaryKey,
      initialRoute: ProfileRoutes.settings,
      locationService: locationService,
    );
    await _capture(boundaryKey, '01_settings_top_account_notification.png');

    await tester.drag(find.byType(ListView).first, const Offset(0, -260));
    await tester.pumpAndSettle();
    await _capture(
      boundaryKey,
      '02_settings_privacy_location_notification.png',
    );

    expect(locationService.permissionReadCount, 1);
    expect(locationService.positionResolveCount, 0);

    await _pumpDay6App(
      tester,
      boundaryKey,
      initialRoute: ProfileRoutes.privacyPermissions,
      locationService: locationService,
    );
    await _capture(boundaryKey, '03_privacy_permission_info.png');
  });
}
