import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';

import 'forum_test_support.dart';

const String _outputDir =
    '/Users/wangweiwei/Desktop/展览装修之家总控/.tmp/agent_reports/forum_content_governance_and_report_frontend/20260330';

Future<void> _pumpCaptureApp(
  WidgetTester tester,
  GlobalKey boundaryKey, {
  required String initialRoute,
  Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
      forumHandlerOverrides =
      const <String, Future<AppApiResponse> Function(AppApiRequest request)>{},
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
  await tester.pumpAndSettle();
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

  testWidgets('capture post detail report entry', (WidgetTester tester) async {
    final boundaryKey = GlobalKey();
    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumPostWithPostId('post-materials-1'),
    );
    await tester.scrollUntilVisible(find.text('举报帖子'), 200);
    await tester.pumpAndSettle();
    await _capture(tester, boundaryKey, '01_post_detail_report_entry.png');
  });

  testWidgets('capture post report sheet', (WidgetTester tester) async {
    final boundaryKey = GlobalKey();
    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumPostWithPostId('post-materials-1'),
    );
    await tester.scrollUntilVisible(find.text('举报帖子'), 200);
    await tester.tap(find.text('举报帖子'));
    await tester.pumpAndSettle();
    await _capture(tester, boundaryKey, '02_post_report_sheet.png');
  });

  testWidgets('capture comment report sheet', (WidgetTester tester) async {
    final boundaryKey = GlobalKey();
    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumPostWithPostId('post-materials-1'),
    );
    await tester.scrollUntilVisible(find.text('查看全部评论'), 200);
    await tester.pumpAndSettle();
    final reportFinder = find.byIcon(Icons.flag_outlined).last;
    await tester.ensureVisible(reportFinder);
    await tester.pumpAndSettle();
    await tester.tap(reportFinder);
    await tester.pumpAndSettle();
    await _capture(tester, boundaryKey, '03_comment_report_sheet.png');
  });

  testWidgets('capture report invalid state', (WidgetTester tester) async {
    final boundaryKey = GlobalKey();
    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumPostWithPostId('post-materials-1'),
      forumHandlerOverrides:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'POST /api/app/forum/report/submit': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 400,
                uri: request.uri,
                body: const <String, Object?>{
                  'code': 'FORUM_REPORT_INVALID',
                  'message': '举报目标类型无效，请重新选择后再试。',
                },
              );
            },
          },
    );
    await tester.scrollUntilVisible(find.text('举报帖子'), 200);
    await tester.tap(find.text('举报帖子'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('其他'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '提交举报'));
    await tester.pumpAndSettle();
    await _capture(tester, boundaryKey, '04_report_invalid_state.png');
  });
}
