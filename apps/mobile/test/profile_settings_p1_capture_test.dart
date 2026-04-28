import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/core/location/device_location_service.dart';
import 'package:mobile/core/runtime_info/app_runtime_info_service.dart';
import 'package:mobile/features/profile/navigation/profile_routes.dart';
import 'package:mobile/shell/shell_app.dart';

const String _outputDir =
    '/Users/wangweiwei/Desktop/展览装修之家总控/.tmp/agent_reports/profile_settings_p1_acceptance_20260428';

final class _P1DeviceLocationService implements DeviceLocationService {
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
      permissionState: DeviceLocationPermissionState.granted,
      serviceEnabled: true,
      message: '定位权限已开启。',
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
      permissionState: DeviceLocationPermissionState.granted,
      errorMessage: '定位权限已开启。',
    );
  }
}

final class _P1RuntimeInfoService extends AppRuntimeInfoService {
  @override
  Future<AppRuntimeInfo> load() async {
    return const AppRuntimeInfo(
      appName: '展览装修之家',
      packageName: 'mobile',
      version: '1.2.3',
      buildNumber: '45',
      environmentLabel: 'SSH隧道',
      entryModeLabel: 'ssh_tunnel',
      apiBaseSummary: '127.0.0.1:8080/api/app',
      debugModeLabel: 'debug',
    );
  }
}

Future<void> _pumpP1App(
  WidgetTester tester,
  GlobalKey boundaryKey, {
  required String initialRoute,
  required _P1DeviceLocationService locationService,
}) async {
  final sessionStore = AppSessionStore();
  sessionStore.establishSession(
    accessToken: 'p1-capture-access-token',
    refreshToken: 'p1-capture-refresh-token',
    expiresInSeconds: 7200,
    deviceId: 'p1-capture-device',
    localLoginSource: AppSessionLoginSource.passwordLogin,
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
            organizationId: 'org-p1',
            roleKeys: const <String>['buyer_admin'],
            certificationStatus: 'approved',
            personalCertificationStatus: 'approved',
            personalCertificationQualified: true,
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

  setUp(() {
    AppRuntimeInfoService.install(_P1RuntimeInfoService());
  });

  tearDown(() {
    AppRuntimeInfoService.reset();
  });

  testWidgets('capture profile settings P1 acceptance screenshots', (
    WidgetTester tester,
  ) async {
    final boundaryKey = GlobalKey();
    final locationService = _P1DeviceLocationService();
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
    await tester.binding.setSurfaceSize(const Size(393, 852));

    await _pumpP1App(
      tester,
      boundaryKey,
      initialRoute: ProfileRoutes.settings,
      locationService: locationService,
    );
    await _capture(boundaryKey, '01_settings_p1_account_security.png');

    await tester.drag(find.byType(ListView).first, const Offset(0, -520));
    await tester.pumpAndSettle();
    await _capture(boundaryKey, '02_settings_p1_cache_version.png');

    await _pumpP1App(
      tester,
      boundaryKey,
      initialRoute: ProfileRoutes.certificationIdentityStatus,
      locationService: locationService,
    );
    await _capture(boundaryKey, '03_certification_identity_status.png');

    await _pumpP1App(
      tester,
      boundaryKey,
      initialRoute: ProfileRoutes.sessionDeviceStatus,
      locationService: locationService,
    );
    await _capture(boundaryKey, '04_session_device_status.png');

    await _pumpP1App(
      tester,
      boundaryKey,
      initialRoute: ProfileRoutes.versionInfo,
      locationService: locationService,
    );
    await _capture(boundaryKey, '05_version_runtime_info.png');

    expect(locationService.permissionReadCount, 1);
    expect(locationService.positionResolveCount, 0);
  });
}
