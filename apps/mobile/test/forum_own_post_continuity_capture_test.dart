import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';

import 'forum_test_support.dart';

const String _outputDir =
    '/Users/wangweiwei/Desktop/展览装修之家总控/.tmp/agent_reports/forum_own_post_continuity_frontend/20260330';
const String _ownerUserId = '99c99709-3786-4d8a-a0c3-5e1a0e945821';
const String _ownerPostId = '5800954d-e9d5-40a3-a770-dfbc2abe4fc4';
const String _nonOwnerPostId = 'a4515c96-cd98-43f8-be4a-9699c02bfd6f';
const String _deletePostId = 'd8798534-f19e-4d09-b54a-9a981a9d36ee';
const String _draftId = '89d9cbeb-52c8-4014-807d-3f7cd35c5209';

AppShellContextData _ownerShellContext() {
  return AppShellContextData(
    userId: _ownerUserId,
    organizationId: '5564ecfa-0ef2-4545-a15c-bf1b66458d2a',
    roleKeys: const <String>['supplier_admin'],
    visibleBuildings: const <String>['exhibition', 'messages', 'profile'],
  );
}

Future<void> _pumpCaptureApp(
  WidgetTester tester,
  GlobalKey boundaryKey, {
  required String initialRoute,
  AppShellContextData? shellContext,
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
          bootstrapShellContext: shellContext ?? _ownerShellContext(),
          forumHandlerOverrides: forumHandlerOverrides,
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

Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
_ownPostHandlers({bool includeArchivedOnly = false}) {
  final items = includeArchivedOnly
      ? <Object?>[
          const <String, Object?>{
            'postId': _deletePostId,
            'title': '前端 own-post 删除验证 20260330',
            'topicId': '96cf8c4e-c3ec-468a-9690-00491b4a4ad8',
            'topicTitle': 'forum-publish-ready-20260327135138-topic',
            'excerpt': '这是一条用于前端 own-post continuity 的删除样本。',
            'state': 'archived',
            'publishedAt': '2026-03-30T09:57:47.000Z',
            'updatedAt': '2026-03-30T09:57:48.523Z',
            'canEdit': false,
            'canDelete': false,
          },
        ]
      : <Object?>[
          const <String, Object?>{
            'postId': _ownerPostId,
            'title': 'forum-file-release-prep-20260330',
            'topicId': '96cf8c4e-c3ec-468a-9690-00491b4a4ad8',
            'topicTitle': 'forum-publish-ready-20260327135138-topic',
            'excerpt':
                '这是一个用于 forum rich publish file/pdf attachment minimum package 联调发布准备的正常 PDF 样本帖。',
            'state': 'published',
            'publishedAt': '2026-03-29T19:28:49.322Z',
            'updatedAt': '2026-03-29T21:03:37.672Z',
            'canEdit': true,
            'canDelete': true,
          },
          const <String, Object?>{
            'postId': 'd2428a4f-bdc0-4165-9db9-3b0ff506865e',
            'title': 'own-post-delete-probe',
            'topicId': '96cf8c4e-c3ec-468a-9690-00491b4a4ad8',
            'topicTitle': 'forum-publish-ready-20260327135138-topic',
            'excerpt': 'own post delete probe body',
            'state': 'archived',
            'publishedAt': '2026-03-30T09:38:50.231Z',
            'updatedAt': '2026-03-30T09:38:51.578Z',
            'canEdit': false,
            'canDelete': false,
          },
        ];

  return <String, Future<AppApiResponse> Function(AppApiRequest request)>{
    'GET /api/app/forum/me/posts': (AppApiRequest request) async {
      return AppApiResponse(
        statusCode: 200,
        uri: request.uri,
        body: <String, Object?>{
          'items': items,
          'page': const <String, Object?>{'nextCursor': null, 'hasMore': false},
        },
      );
    },
  };
}

Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
_ownerDetailHandlers() {
  return <String, Future<AppApiResponse> Function(AppApiRequest request)>{
    'GET /api/app/forum/post/detail': (AppApiRequest request) async {
      return AppApiResponse(
        statusCode: 200,
        uri: request.uri,
        body: const <String, Object?>{
          'postId': _ownerPostId,
          'topicId': '96cf8c4e-c3ec-468a-9690-00491b4a4ad8',
          'topicTitle': 'forum-publish-ready-20260327135138-topic',
          'state': 'published',
          'author': <String, Object?>{
            'authorId': _ownerUserId,
            'displayName': _ownerUserId,
            'organizationName': '5564ecfa-0ef2-4545-a15c-bf1b66458d2a',
          },
          'content':
              '这是一个用于 forum rich publish file/pdf attachment minimum package 联调发布准备的正常 PDF 样本帖。',
          'attachmentRefs': <Object?>[],
          'publishedAt': '2026-03-29T19:28:49.322Z',
          'viewerHasLiked': false,
          'viewerHasBookmarked': false,
          'viewerFollowsTopic': false,
        },
      );
    },
    'GET /api/app/forum/post/comments': (AppApiRequest request) async {
      return AppApiResponse(
        statusCode: 200,
        uri: request.uri,
        body: const <String, Object?>{
          'items': <Object?>[],
          'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
        },
      );
    },
  };
}

Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
_nonOwnerDetailHandlers() {
  return <String, Future<AppApiResponse> Function(AppApiRequest request)>{
    'GET /api/app/forum/post/detail': (AppApiRequest request) async {
      return AppApiResponse(
        statusCode: 200,
        uri: request.uri,
        body: const <String, Object?>{
          'postId': _nonOwnerPostId,
          'topicId': '96cf8c4e-c3ec-468a-9690-00491b4a4ad8',
          'topicTitle': 'forum-publish-ready-20260327135138-topic',
          'state': 'published',
          'author': <String, Object?>{
            'authorId': 'other-author-id',
            'displayName': '王监理',
            'organizationName': '外部机构',
          },
          'content': '这是一条来自其他作者的公开帖子。',
          'attachmentRefs': <Object?>[],
          'publishedAt': '2026-03-30T08:30:00.000Z',
          'viewerHasLiked': false,
          'viewerHasBookmarked': false,
          'viewerFollowsTopic': false,
        },
      );
    },
    'GET /api/app/forum/post/comments': (AppApiRequest request) async {
      return AppApiResponse(
        statusCode: 200,
        uri: request.uri,
        body: const <String, Object?>{
          'items': <Object?>[],
          'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
        },
      );
    },
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture own-post continuity surfaces', (
    WidgetTester tester,
  ) async {
    final boundaryKey = GlobalKey();
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
    await tester.binding.setSurfaceSize(const Size(393, 852));

    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumMePosts,
      forumHandlerOverrides: _ownPostHandlers(),
    );
    await _capture(boundaryKey, '01_my_posts_continuity_hub.png');

    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumPostWithPostId(_ownerPostId),
      forumHandlerOverrides: _ownerDetailHandlers(),
    );
    await tester.scrollUntilVisible(find.text('编辑帖子'), 200);
    await tester.pumpAndSettle();
    await _capture(boundaryKey, '02_owner_detail_quick_actions.png');

    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumPostWithPostId(_nonOwnerPostId),
      forumHandlerOverrides: _nonOwnerDetailHandlers(),
    );
    await _capture(boundaryKey, '03_non_owner_detail_without_actions.png');

    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumPostWithPostId(_ownerPostId),
      forumHandlerOverrides:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            ..._ownerDetailHandlers(),
            'POST /api/app/forum/post/edit': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 202,
                uri: request.uri,
                body: const <String, Object?>{
                  'draftId': _draftId,
                  'targetPostId': _ownerPostId,
                  'state': 'ready_to_publish',
                  'status': 'resumed_active_edit_draft',
                  'message': '已进入编辑草稿',
                },
              );
            },
          },
    );
    await tester.scrollUntilVisible(find.text('编辑帖子'), 200);
    await tester.tap(find.text('编辑帖子'));
    await tester.pumpAndSettle();
    await _capture(boundaryKey, '04_edit_reenter_publish_corridor.png');

    var deleted = false;
    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumPostWithPostId(_deletePostId),
      forumHandlerOverrides:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/forum/post/detail': (AppApiRequest request) async {
              if (deleted) {
                return AppApiResponse(
                  statusCode: 404,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'code': 'FORUM_POST_UNAVAILABLE',
                    'message': 'Forum post is unavailable.',
                  },
                );
              }
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: const <String, Object?>{
                  'postId': _deletePostId,
                  'topicId': '96cf8c4e-c3ec-468a-9690-00491b4a4ad8',
                  'topicTitle': 'forum-publish-ready-20260327135138-topic',
                  'state': 'published',
                  'author': <String, Object?>{
                    'authorId': _ownerUserId,
                    'displayName': _ownerUserId,
                    'organizationName': '5564ecfa-0ef2-4545-a15c-bf1b66458d2a',
                  },
                  'content': '这是一条用于 own-post continuity 删除确认展示的帖子。',
                  'attachmentRefs': <Object?>[],
                  'publishedAt': '2026-03-30T09:57:47.000Z',
                  'viewerHasLiked': false,
                  'viewerHasBookmarked': false,
                  'viewerFollowsTopic': false,
                },
              );
            },
            'GET /api/app/forum/post/comments': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: const <String, Object?>{
                  'items': <Object?>[],
                  'page': <String, Object?>{
                    'nextCursor': null,
                    'hasMore': false,
                  },
                },
              );
            },
            'POST /api/app/forum/post/delete': (AppApiRequest request) async {
              deleted = true;
              return AppApiResponse(
                statusCode: 202,
                uri: request.uri,
                body: const <String, Object?>{
                  'postId': _deletePostId,
                  'state': 'archived',
                  'archivedAt': '2026-03-30T09:57:48.523Z',
                  'message': '帖子已删除',
                },
              );
            },
          },
    );
    await tester.scrollUntilVisible(find.text('删除帖子'), 200);
    await tester.tap(find.text('删除帖子'));
    await tester.pumpAndSettle();
    await _capture(boundaryKey, '05_delete_confirm_dialog.png');

    await tester.tap(find.text('确认删除'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await _capture(boundaryKey, '06_delete_success_feedback.png');

    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumMePosts,
      forumHandlerOverrides: _ownPostHandlers(includeArchivedOnly: true),
    );
    await _capture(boundaryKey, '07_my_posts_after_delete.png');

    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ExhibitionRoutes.forumPostWithPostId(_deletePostId),
      forumHandlerOverrides:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/forum/post/detail': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 404,
                uri: request.uri,
                body: const <String, Object?>{
                  'code': 'FORUM_POST_UNAVAILABLE',
                  'message': 'Forum post is unavailable.',
                },
              );
            },
            'GET /api/app/forum/post/comments': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: const <String, Object?>{
                  'items': <Object?>[],
                  'page': <String, Object?>{
                    'nextCursor': null,
                    'hasMore': false,
                  },
                },
              );
            },
          },
    );
    await _capture(boundaryKey, '08_deleted_detail_failure_state.png');
  });
}
