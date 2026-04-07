import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';

import 'forum_test_support.dart';

Map<String, Object?> _clearPublishBody() {
  return const <String, Object?>{
    'draftId': 'draft-saved-1',
    'topicId': 'expo-materials',
    'postId': 'post-materials-1',
    'state': 'published',
    'summary': <String, Object?>{
      'title': 'AI gate clear 样本',
      'publishedAt': '2026-03-29T15:27:07.876Z',
    },
    'decision': 'clear',
    'message': '发布成功',
  };
}

Map<String, Object?> _blockedPublishBody({
  required String decision,
  required String message,
}) {
  return <String, Object?>{
    'draftId': 'draft-saved-1',
    'state': 'blocked',
    'decision': decision,
    'message': message,
  };
}

Future<void> _pumpPublishPage(
  WidgetTester tester, {
  Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
      forumHandlerOverrides =
      const <String, Future<AppApiResponse> Function(AppApiRequest request)>{},
}) async {
  await tester.pumpWidget(
    buildForumTestAppWithOverrides(
      initialRoute: ExhibitionRoutes.forumPublish,
      forumHandlerOverrides: forumHandlerOverrides,
    ),
  );
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField).at(0), '论坛 AI gate 测试帖');
  await tester.enterText(find.byType(TextField).at(1), '这是一条用于 publish gate 的测试正文。');
  await tester.pump();
}

Future<void> _saveDraft(WidgetTester tester) async {
  await tester.tap(find.text('保存草稿'));
  await tester.pumpAndSettle();
  await tester.pump(const Duration(seconds: 4));
  await tester.pumpAndSettle();
}

Future<void> _publishDraft(WidgetTester tester) async {
  await tester.tap(find.text('发布'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('forum publish clear result still enters post detail', (
    WidgetTester tester,
  ) async {
    await _pumpPublishPage(
      tester,
      forumHandlerOverrides:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/forum/draft/detail': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 409,
                uri: request.uri,
                body: const <String, Object?>{
                  'code': 'FORUM_DRAFT_OPEN_UNAVAILABLE',
                  'message': '当前草稿暂时打不开，请稍后再试',
                },
              );
            },
            'POST /api/app/forum/publish': (AppApiRequest request) async {
              expect(request.body, const <String, Object?>{
                'draftId': 'draft-saved-1',
              });
              return AppApiResponse(
                statusCode: 202,
                uri: request.uri,
                body: _clearPublishBody(),
              );
            },
          },
    );

    await _saveDraft(tester);
    await _publishDraft(tester);

    expect(find.text('正式帖子正文'), findsOneWidget);
    expect(find.text('附件'), findsOneWidget);
    expect(find.text('当前草稿暂时打不开，请稍后再试'), findsNothing);
  });

  testWidgets(
    'forum publish falls back to refreshed topic feed when detail stays unavailable',
    (WidgetTester tester,
  ) async {
      var detailRequestCount = 0;
      var filteredFeedRequestCount = 0;

      await _pumpPublishPage(
        tester,
        forumHandlerOverrides:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/forum/draft/detail': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 409,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'code': 'FORUM_DRAFT_OPEN_UNAVAILABLE',
                    'message': '当前草稿暂时打不开，请稍后再试',
                  },
                );
              },
              'POST /api/app/forum/publish': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 202,
                  uri: request.uri,
                  body: _clearPublishBody(),
                );
              },
              'GET /api/app/forum/post/detail': (AppApiRequest request) async {
                detailRequestCount += 1;
                return AppApiResponse(
                  statusCode: 404,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'code': 'FORUM_POST_NOT_FOUND',
                    'message': '帖子详情暂不可用',
                  },
                );
              },
              'GET /api/app/forum/feed': (AppApiRequest request) async {
                expect(request.uri.queryParameters['scope'], 'square');
                expect(request.uri.queryParameters['topicId'], 'expo-materials');
                filteredFeedRequestCount += 1;
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: <String, Object?>{
                    'items': <Object?>[
                      <String, Object?>{
                        'postId': 'post-materials-1',
                        'topicId': 'expo-materials',
                        'topicLabel': '布展进场',
                        'title': '新发布的真实帖子',
                        'excerpt': '发布成功后从真实 feed 继续承接。',
                        'state': 'published',
                        'author': <String, Object?>{
                          'authorId': 'member-1',
                          'displayName': '赵工',
                          'organizationName': '展览协作组',
                        },
                        'engagement': <String, Object?>{
                          'replyCount': 0,
                          'likeCount': 0,
                          'viewCount': 1,
                        },
                        'publishedAt': '2026-03-30T09:00:00Z',
                        'viewerHasLiked': false,
                        'viewerHasBookmarked': false,
                        'viewerFollowsTopic': true,
                      },
                    ],
                    'page': <String, Object?>{
                      'nextCursor': null,
                      'hasMore': false,
                    },
                  },
                );
              },
            },
      );

      await _saveDraft(tester);
      await _publishDraft(tester);

      expect(detailRequestCount, 2);
      expect(filteredFeedRequestCount, greaterThanOrEqualTo(1));
      expect(find.text('新发布的真实帖子'), findsOneWidget);
      expect(find.text('帖子详情暂不可用'), findsNothing);
      expect(find.text('帖子已发布，详情仍在同步，先回到所属讨论区继续查看。'), findsOneWidget);
    },
  );

  testWidgets('forum publish supplement_required stays in draft corridor', (
    WidgetTester tester,
  ) async {
    await _pumpPublishPage(
      tester,
      forumHandlerOverrides:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'POST /api/app/forum/publish': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 202,
                uri: request.uri,
                body: _blockedPublishBody(
                  decision: 'supplement_required',
                  message: '需修改后再试',
                ),
              );
            },
          },
    );

    await _saveDraft(tester);
    await _publishDraft(tester);

    expect(find.text('需修改后再试'), findsOneWidget);
    expect(find.text('草稿'), findsOneWidget);
    expect(find.text('正式帖子正文'), findsNothing);
  });

  testWidgets('forum publish restricted stays in draft corridor', (
    WidgetTester tester,
  ) async {
    await _pumpPublishPage(
      tester,
      forumHandlerOverrides:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'POST /api/app/forum/publish': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 202,
                uri: request.uri,
                body: _blockedPublishBody(
                  decision: 'restricted',
                  message: '当前内容暂不可发布',
                ),
              );
            },
          },
    );

    await _saveDraft(tester);
    await _publishDraft(tester);

    expect(find.text('当前内容暂不可发布，请修改标题或正文后再试'), findsOneWidget);
    expect(find.text('草稿'), findsOneWidget);
    expect(find.text('正式帖子正文'), findsNothing);
  });

  testWidgets('forum publish ticket_required stays in draft corridor', (
    WidgetTester tester,
  ) async {
    await _pumpPublishPage(
      tester,
      forumHandlerOverrides:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'POST /api/app/forum/publish': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 202,
                uri: request.uri,
                body: _blockedPublishBody(
                  decision: 'ticket_required',
                  message: '已进入受控治理处理',
                ),
              );
            },
          },
    );

    await _saveDraft(tester);
    await _publishDraft(tester);

    expect(find.text('已进入受控治理处理'), findsOneWidget);
    expect(find.text('草稿'), findsOneWidget);
    expect(find.text('正式帖子正文'), findsNothing);
  });

  testWidgets('forum publish invalid-state stays separate from blocked result', (
    WidgetTester tester,
  ) async {
    await _pumpPublishPage(
      tester,
      forumHandlerOverrides:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'POST /api/app/forum/publish': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 409,
                uri: request.uri,
                body: const <String, Object?>{
                  'code': 'FORUM_PUBLISH_INVALID_STATE',
                  'message': '当前账号下没有可发布的论坛草稿，请确认草稿归属和当前组织后再试。',
                },
              );
            },
          },
    );

    await _saveDraft(tester);
    await _publishDraft(tester);

    expect(find.text('当前账号下没有可发布的论坛草稿，请确认草稿归属和当前组织后再试。'), findsOneWidget);
    expect(find.text('需修改后再试'), findsNothing);
    expect(find.text('当前内容暂不可发布'), findsNothing);
    expect(find.text('已进入受控治理处理'), findsNothing);
  });
}
