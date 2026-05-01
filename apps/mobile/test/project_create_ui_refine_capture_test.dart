import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';

import 'forum_test_support.dart';

const String _outputDir =
    '/Users/wangweiwei/Desktop/展览装修之家总控/.tmp/agent_reports/project_create_ui_refine/20260502';

AppShellContextData _publisherShellContext() {
  return AppShellContextData(
    userId: 'publisher-user-1',
    displayName: '发布方',
    organizationId: 'org-publisher-1',
    organizationType: 'exhibition_design_company',
    roleKeys: const <String>['supplier_admin'],
    certificationStatus: 'verified',
    projectCreateEligibility: const AppProjectCreateEligibilityData(
      canCreateProject: true,
    ),
    visibleBuildings: const <String>['exhibition', 'messages', 'profile'],
  );
}

AppSessionStore _publisherSessionStore() {
  final store = AppSessionStore();
  store.establishSession(
    accessToken: 'token-publisher',
    refreshToken: 'refresh-publisher',
    expiresInSeconds: 3600,
    deviceId: 'device-project-create-ui-refine',
  );
  return store;
}

Future<void> _pumpCaptureApp(
  WidgetTester tester,
  GlobalKey boundaryKey, {
  required Size surfaceSize,
}) async {
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(surfaceSize);
  await tester.pumpWidget(
    RepaintBoundary(
      key: boundaryKey,
      child: KeyedSubtree(
        key: UniqueKey(),
        child: buildForumTestAppWithOverrides(
          initialRoute: ExhibitionRoutes.projectCreate,
          bootstrapShellContext: _publisherShellContext(),
          sessionStore: _publisherSessionStore(),
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
  testWidgets('captures project create regular viewport top', (
    WidgetTester tester,
  ) async {
    final boundaryKey = GlobalKey();
    await _pumpCaptureApp(
      tester,
      boundaryKey,
      surfaceSize: const Size(390, 1000),
    );

    expect(find.text('正在填写项目基础信息'), findsOneWidget);
    expect(find.text('报价依据资料'), findsOneWidget);
    await _capture(boundaryKey, 'project_create_regular_top.png');
  });

  testWidgets('captures project create narrow viewport bottom action', (
    WidgetTester tester,
  ) async {
    final boundaryKey = GlobalKey();
    await _pumpCaptureApp(
      tester,
      boundaryKey,
      surfaceSize: const Size(320, 780),
    );

    for (var attempt = 0; attempt < 12; attempt++) {
      if (find.text('保存并查看我的项目').evaluate().isNotEmpty) {
        break;
      }
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
      await tester.pumpAndSettle();
    }
    await tester.ensureVisible(find.text('保存并查看我的项目'));
    await tester.pumpAndSettle();

    expect(find.text('保存并查看我的项目'), findsOneWidget);
    expect(find.text('展览'), findsOneWidget);
    await _capture(boundaryKey, 'project_create_narrow_bottom.png');
  });
}
