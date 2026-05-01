import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/profile/navigation/profile_routes.dart';

import 'forum_test_support.dart';

const String _outputDir =
    '/Users/wangweiwei/Desktop/展览装修之家总控/.tmp/agent_reports/forum_asset_management_center/20260501';

Future<void> _pumpCaptureApp(
  WidgetTester tester,
  GlobalKey boundaryKey, {
  required String initialRoute,
  Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
      forumHandlerOverrides =
      const <String, Future<AppApiResponse> Function(AppApiRequest request)>{},
  bool settle = true,
}) async {
  await tester.pumpWidget(
    RepaintBoundary(
      key: boundaryKey,
      child: KeyedSubtree(
        key: UniqueKey(),
        child: buildForumTestAppWithOverrides(
          initialRoute: initialRoute,
          forumHandlerOverrides: forumHandlerOverrides,
        ),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 160));
  }
}

Future<void> _capture(
  WidgetTester tester,
  GlobalKey boundaryKey,
  String filename,
) async {
  await expectLater(
    find.byKey(boundaryKey),
    matchesGoldenFile('$_outputDir/$filename'),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await _loadFont(
      family: 'Ahem',
      path: '/System/Library/Fonts/Supplemental/Arial Unicode.ttf',
    );
    await _loadFont(
      family: 'Roboto',
      path: '/System/Library/Fonts/Supplemental/Arial Unicode.ttf',
    );
    await _loadFont(
      family: 'MaterialIcons',
      path:
          '/Users/wangweiwei/Desktop/展览装修之家总控/apps/mobile/build/unit_test_assets/fonts/MaterialIcons-Regular.otf',
    );
  });

  testWidgets('capture forum asset management center surfaces', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final boundaryKey = GlobalKey();

    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ProfileRoutes.forum,
    );
    await _capture(tester, boundaryKey, '01_my_forum_home.png');

    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumMePosts,
    );
    await _capture(tester, boundaryKey, '02_my_posts.png');

    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumMeComments,
    );
    await _capture(tester, boundaryKey, '03_my_comments.png');

    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumMeBookmarks,
    );
    await _capture(tester, boundaryKey, '04_my_bookmarks.png');

    final likesCompleter = Completer<AppApiResponse>();
    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumMeLikes,
      forumHandlerOverrides:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/forum/me/likes': (AppApiRequest request) =>
                likesCompleter.future,
          },
      settle: false,
    );
    await _capture(tester, boundaryKey, '05_my_likes_loading.png');
    likesCompleter.complete(
      AppApiResponse(
        statusCode: 200,
        uri: Uri.parse('/api/app/forum/me/likes'),
        body: const <String, Object?>{
          'items': <Object?>[],
          'pagination': <String, Object?>{
            'page': 1,
            'pageSize': 20,
            'total': 0,
            'hasMore': false,
          },
        },
      ),
    );
    await tester.pumpAndSettle();

    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumMeFollows,
    );
    await _capture(tester, boundaryKey, '06_my_follows.png');

    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumMeReports,
    );
    await _capture(tester, boundaryKey, '07_my_reports.png');

    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumDrafts,
    );
    await _capture(tester, boundaryKey, '08_drafts.png');
  });
}

Future<void> _loadFont({required String family, required String path}) async {
  final bytes = File(path).readAsBytesSync();
  final fontData = ByteData.view(Uint8List.fromList(bytes).buffer);
  await (FontLoader(family)..addFont(Future<ByteData>.value(fontData))).load();
}
