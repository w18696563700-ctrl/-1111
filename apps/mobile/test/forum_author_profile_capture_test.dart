import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';

import 'forum_test_support.dart';

const String _outputDir =
    '/Users/wangweiwei/Desktop/展览装修之家总控/.tmp/agent_reports/forum_author_profile_frontend/20260329';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture forum author profile formal surfaces', (
    WidgetTester tester,
  ) async {
    final boundaryKey = GlobalKey();
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
    await tester.binding.setSurfaceSize(const Size(393, 852));

    Future<void> pumpFormalApp(
      String initialRoute, {
      AppShellContextData? shellContext,
      Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
      forumHandlerOverrides = const <String,
          Future<AppApiResponse> Function(AppApiRequest request)>{},
    }) async {
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundaryKey,
          child: buildForumTestAppWithOverrides(
            initialRoute: initialRoute,
            bootstrapShellContext: shellContext,
            forumHandlerOverrides: forumHandlerOverrides,
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> capture(String filename) async {
      await expectLater(
        find.byKey(boundaryKey),
        matchesGoldenFile('$_outputDir/$filename'),
      );
    }

    await pumpFormalApp(ExhibitionRoutes.forum);
    await capture('01_forum_list_before_author_handoff.png');

    await tester.tap(find.text('赵工').first);
    await tester.pumpAndSettle();
    await capture('02_forum_author_profile_from_list.png');

    await pumpFormalApp(
      ExhibitionRoutes.forumPostWithPostId('post-materials-1'),
    );
    await capture('03_forum_post_detail_author_area.png');

    await tester.tap(find.text('赵工').first);
    await tester.pumpAndSettle();
    await capture('04_forum_author_profile_from_detail.png');

    await pumpFormalApp(
      ExhibitionRoutes.forumAuthorWithAuthorId('member-1'),
    );
    await capture('05_forum_author_profile_header_summary.png');

    await tester.drag(find.byType(ListView).last, const Offset(0, -220));
    await tester.pumpAndSettle();
    await capture('06_forum_author_profile_posts_list.png');

    await pumpFormalApp(
      ExhibitionRoutes.forumAuthorWithAuthorId('missing-author'),
      forumHandlerOverrides: <String,
          Future<AppApiResponse> Function(AppApiRequest request)>{
        'GET /api/app/forum/author/profile': (AppApiRequest request) async {
          return AppApiResponse(
            statusCode: 404,
            uri: request.uri,
            body: const <String, Object?>{
              'code': 'FORUM_AUTHOR_UNAVAILABLE',
              'message': 'Forum author is unavailable.',
              'source': 'server',
            },
          );
        },
        'GET /api/app/forum/author/posts': (AppApiRequest request) async {
          return AppApiResponse(
            statusCode: 404,
            uri: request.uri,
            body: const <String, Object?>{
              'code': 'FORUM_AUTHOR_UNAVAILABLE',
              'message': 'Forum author is unavailable.',
              'source': 'server',
            },
          );
        },
      },
    );
    await capture('07_forum_author_profile_error_state.png');

    await pumpFormalApp(
      ExhibitionRoutes.forumAuthorWithAuthorId('member-1'),
      shellContext: AppShellContextData(
        userId: 'member-1',
        visibleBuildings: const <String>['exhibition', 'messages', 'profile'],
      ),
    );
    await capture('08_forum_author_profile_self_handoff.png');
  });
}
