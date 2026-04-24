import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/exhibition/presentation/forum/forum_pages.dart';
import 'package:mobile/features/profile/navigation/profile_routes.dart';

import 'forum_test_support.dart';

void main() {
  testWidgets('forum home renders content-first browse surface', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildForumTestApp(initialRoute: ExhibitionRoutes.forum),
    );
    await tester.pumpAndSettle();

    expect(find.text('广场'), findsWidgets);
    expect(find.text('关注'), findsWidgets);
    expect(find.text('本地'), findsWidgets);
    expect(find.text('全部'), findsOneWidget);
    expect(find.text('夜间进场窗口怎么排吊装和安检顺序？'), findsOneWidget);
    expect(find.text('论坛入口总览'), findsNothing);
    expect(find.text('当前环境：联调环境'), findsNothing);
    expect(find.textContaining('当前筛选：'), findsNothing);
  });

  testWidgets(
    'forum topic chips stay clickable and switch visible filter state',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildForumTestApp(initialRoute: ExhibitionRoutes.forum),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilterChip, '材料协同'));
      await tester.pumpAndSettle();

      expect(find.text('供应商交接模板怎么落地更省沟通'), findsOneWidget);
      expect(find.text('夜间进场窗口怎么排吊装和安检顺序？'), findsNothing);
    },
  );

  testWidgets(
    'forum scope feeds remain reachable and preserve tool placement',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildForumTestApp(initialRoute: ExhibitionRoutes.forumFollowing),
      );
      await tester.pumpAndSettle();

      expect(find.text('关注的协同模板更新'), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    },
  );

  testWidgets('forum detail and comment chain render formal reading path', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildForumTestApp(
        initialRoute: ExhibitionRoutes.forumPostWithPostId('post-materials-1'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('正文'), findsOneWidget);
    expect(find.text('赵工'), findsOneWidget);
    expect(find.byIcon(Icons.mode_comment_outlined), findsWidgets);
    expect(find.text('先看互动，再决定是否继续下钻'), findsNothing);
  });

  testWidgets('forum support routes remain registered', (
    WidgetTester tester,
  ) async {
    for (final route in <String>[
      ExhibitionRoutes.forumCommentsWithPostId('post-materials-1'),
      ExhibitionRoutes.forumAuthorWithAuthorId('member-1'),
      ExhibitionRoutes.forumTopics,
      ExhibitionRoutes.forumPublish,
      ExhibitionRoutes.forumDrafts,
      ExhibitionRoutes.forumSearch,
      ExhibitionRoutes.forumMePosts,
      ExhibitionRoutes.forumMeComments,
      ExhibitionRoutes.forumMeBookmarks,
      ExhibitionRoutes.forumMeFollows,
      ExhibitionRoutes.forumMeReports,
      ExhibitionRoutes.forumMeReportDetailWithTicketId('report-ticket-1'),
    ]) {
      await tester.pumpWidget(buildForumTestApp(initialRoute: route));
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsOneWidget);
    }
  });

  testWidgets('forum my reports consume bounded list and detail routes', (
    WidgetTester tester,
  ) async {
    final requestedPaths = <String>[];

    await tester.pumpWidget(
      buildForumTestAppWithOverrides(
        initialRoute: ExhibitionRoutes.forumMeReports,
        forumHandlerOverrides:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/forum/reports/mine': (AppApiRequest request) async {
                requestedPaths.add(request.canonicalPath);
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'items': <Object?>[
                      <String, Object?>{
                        'reportTicketId': 'report-ticket-1',
                        'targetType': 'post',
                        'targetId': 'post-materials-1',
                        'reasonCode': 'spam_or_flood',
                        'reasonDetail': '该内容重复刷屏。',
                        'status': 'submitted',
                        'targetSnapshot': <String, Object?>{
                          'targetType': 'post',
                          'postId': 'post-materials-1',
                          'title': '夜间进场窗口怎么排吊装和安检顺序？',
                          'excerpt': '当前举报目标快照摘要',
                          'state': 'published',
                          'publishedAt': '2026-03-27T09:30:00Z',
                        },
                        'submittedAt': '2026-03-31T09:00:00Z',
                        'updatedAt': '2026-03-31T09:00:00Z',
                      },
                    ],
                  },
                );
              },
              'GET /api/app/forum/reports/mine/report-ticket-1':
                  (AppApiRequest request) async {
                    requestedPaths.add(request.canonicalPath);
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: const <String, Object?>{
                        'reportTicketId': 'report-ticket-1',
                        'targetType': 'post',
                        'targetId': 'post-materials-1',
                        'reasonCode': 'spam_or_flood',
                        'reasonDetail': '该内容重复刷屏。',
                        'status': 'submitted',
                        'targetSnapshot': <String, Object?>{
                          'targetType': 'post',
                          'postId': 'post-materials-1',
                          'title': '夜间进场窗口怎么排吊装和安检顺序？',
                          'excerpt': '当前举报目标快照摘要',
                          'state': 'published',
                          'publishedAt': '2026-03-27T09:30:00Z',
                        },
                        'submittedAt': '2026-03-31T09:00:00Z',
                        'updatedAt': '2026-03-31T09:00:00Z',
                      },
                    );
                  },
            },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('我的举报记录'), findsWidgets);
    expect(find.text('夜间进场窗口怎么排吊装和安检顺序？'), findsOneWidget);
    expect(find.textContaining('已提交'), findsWidgets);
    expect(find.textContaining('举报处理中心'), findsNothing);
    expect(find.textContaining('Admin Review'), findsNothing);
    expect(find.textContaining('AI'), findsNothing);

    await tester.drag(find.byType(ListView).last, const Offset(0, -320));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '查看详情'));
    await tester.pumpAndSettle();

    expect(find.text('举报详情'), findsWidgets);
    expect(find.text('提交原因'), findsOneWidget);
    expect(find.text('该内容重复刷屏。'), findsOneWidget);
    expect(find.textContaining('举报处理中心'), findsNothing);
    expect(find.textContaining('申诉'), findsNothing);
    expect(find.textContaining('处罚'), findsNothing);
    expect(
      requestedPaths,
      containsAllInOrder(<String>[
        '/api/app/forum/reports/mine',
        '/api/app/forum/reports/mine/report-ticket-1',
      ]),
    );
  });

  testWidgets('profile forum exposes bounded my report entry', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildForumTestApp(initialRoute: ProfileRoutes.forum),
    );
    await tester.pumpAndSettle();

    expect(find.text('我的论坛'), findsWidgets);
    expect(find.text('我的举报记录'), findsOneWidget);

    await tester.drag(find.byType(ListView).last, const Offset(0, -320));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, '我的举报记录'));
    await tester.pumpAndSettle();

    expect(find.text('夜间进场窗口怎么排吊装和安检顺序？'), findsOneWidget);
    expect(find.textContaining('举报处理中心'), findsNothing);
    expect(find.textContaining('Admin Review'), findsNothing);
  });

  testWidgets(
    'profile governance appeals consume bounded list and detail routes',
    (WidgetTester tester) async {
      final requestedPaths = <String>[];

      await tester.pumpWidget(
        buildForumTestAppWithOverrides(
          initialRoute: ProfileRoutes.governanceAppeals,
          profileGovernanceAppealHandlerOverrides:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'GET /api/app/profile/governance/appeals':
                    (AppApiRequest request) async {
                      requestedPaths.add(request.canonicalPath);
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'items': <Object?>[
                            <String, Object?>{
                              'appealCaseId': 'appeal-case-1',
                              'status': 'submitted',
                              'statusLabel': '待审核',
                              'submittedAt': '2026-04-08T10:00:00Z',
                              'decidedAt': null,
                              'penalty': <String, Object?>{
                                'penaltyId': 'penalty-1',
                                'penaltyType': 'restrict_publish',
                                'penaltyTypeLabel': '限制发布',
                                'penaltyStatus': 'active',
                                'penaltyStatusLabel': '生效中',
                                'reasonSummary': '存在重复刷屏与误导性内容。',
                                'effectiveFrom': '2026-04-07T09:00:00Z',
                                'effectiveUntil': '2026-04-15T09:00:00Z',
                              },
                            },
                          ],
                          'pagination': <String, Object?>{
                            'page': 1,
                            'pageSize': 20,
                            'total': 1,
                            'hasMore': false,
                          },
                        },
                      );
                    },
                'GET /api/app/profile/governance/appeals/appeal-case-1':
                    (AppApiRequest request) async {
                      requestedPaths.add(request.canonicalPath);
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'appealCaseId': 'appeal-case-1',
                          'status': 'submitted',
                          'statusLabel': '待审核',
                          'appealReason': '该处罚对当前账号影响过重，申请复核。',
                          'decision': null,
                          'decisionLabel': null,
                          'decisionNote': null,
                          'submittedAt': '2026-04-08T10:00:00Z',
                          'decidedAt': null,
                          'evidenceFileAssetIds': <Object?>[
                            'file-asset-1',
                            'file-asset-2',
                          ],
                          'penalty': <String, Object?>{
                            'penaltyId': 'penalty-1',
                            'penaltyType': 'restrict_publish',
                            'penaltyTypeLabel': '限制发布',
                            'penaltyStatus': 'active',
                            'penaltyStatusLabel': '生效中',
                            'reasonSummary': '存在重复刷屏与误导性内容。',
                            'effectiveFrom': '2026-04-07T09:00:00Z',
                            'effectiveUntil': '2026-04-15T09:00:00Z',
                          },
                        },
                      );
                    },
              },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('我的申诉记录'), findsWidgets);
      expect(find.text('存在重复刷屏与误导性内容。'), findsOneWidget);
      expect(find.textContaining('限制发布'), findsWidgets);
      expect(find.textContaining('处罚历史中心'), findsNothing);
      expect(find.textContaining('治理总控台'), findsNothing);
      expect(find.textContaining('提交申诉'), findsNothing);

      await tester.tap(find.text('存在重复刷屏与误导性内容。').first);
      await tester.pumpAndSettle();

      expect(find.text('申诉详情'), findsWidgets);
      expect(find.text('申诉原因'), findsOneWidget);
      expect(find.text('该处罚对当前账号影响过重，申请复核。'), findsOneWidget);
      expect(find.textContaining('处罚历史中心'), findsNothing);
      expect(find.textContaining('治理总控台'), findsNothing);
      expect(
        requestedPaths,
        containsAllInOrder(<String>[
          '/api/app/profile/governance/appeals',
          '/api/app/profile/governance/appeals/appeal-case-1',
        ]),
      );
    },
  );

  testWidgets('profile home exposes bounded my appeal entry', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildForumTestApp(initialRoute: '/profile'));
    await tester.pumpAndSettle();

    expect(find.text('我的申诉记录'), findsOneWidget);

    await tester.drag(find.byType(ListView).last, const Offset(0, -320));
    await tester.pumpAndSettle();
    await tester.tap(find.text('我的申诉记录').first);
    await tester.pumpAndSettle();

    expect(find.text('申诉列表'), findsOneWidget);
    expect(find.textContaining('治理总控台'), findsNothing);
    expect(find.textContaining('处罚历史中心'), findsNothing);
  });

  testWidgets('forum search surface keeps formal structure', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildForumTestApp(
        initialRoute: ExhibitionRoutes.forumSearchWithQuery('进场窗口'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsWidgets);
    expect(find.textContaining('搜索结果概览'), findsNothing);
  });

  testWidgets('forum publish surface uses light composer layout', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildForumTestApp(initialRoute: ExhibitionRoutes.forumPublish),
    );
    await tester.pumpAndSettle();

    expect(find.text('草稿'), findsOneWidget);
    expect(find.text('发帖主链'), findsNothing);
    expect(find.text('先保存草稿，再进入发布'), findsNothing);
    expect(find.text('请先保存草稿；保存后可直接继续发布，离开后也可从草稿箱继续。'), findsOneWidget);
    expect(find.text('写一个标题'), findsOneWidget);
  });

  testWidgets('forum draft open restores authoritative content into composer', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildForumTestApp(
        initialRoute: ExhibitionRoutes.forumPublishWithDraftId('draft-1'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('本地进场夜班经验分享'), findsOneWidget);
    expect(find.text('这是一条已保存的论坛草稿内容。'), findsOneWidget);
    expect(find.text('当前草稿已保存，可直接继续发布。'), findsOneWidget);
  });

  testWidgets(
    'forum draft open uses targetPostId instead of draftType for edit continuity',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildForumTestAppWithOverrides(
          initialRoute: ExhibitionRoutes.forumPublishWithDraftId(
            'draft-edit-1',
          ),
          forumHandlerOverrides:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'GET /api/app/forum/draft/detail':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'draftId': 'draft-edit-1',
                          'draftType': 'reply',
                          'targetPostId': 'post-owned-1',
                          'topicId': 'expo-materials',
                          'title': '编辑后的帖子标题',
                          'body': '这是 owner post edit continuity 恢复内容。',
                          'attachmentFileAssetIds': <String>['asset-edit-1'],
                          'state': 'saved',
                          'updatedAt': '2026-03-30T09:00:00Z',
                        },
                      );
                    },
              },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('编辑后的帖子标题'), findsOneWidget);
      expect(find.text('这是 owner post edit continuity 恢复内容。'), findsOneWidget);
      await tester.drag(find.byType(ListView).first, const Offset(0, -320));
      await tester.pumpAndSettle();
      expect(find.text('已绑定附件 1'), findsOneWidget);
      expect(find.text('已从草稿恢复并承接'), findsOneWidget);
    },
  );

  testWidgets('forum feed author avatar hands off to public author profile', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildForumTestApp(initialRoute: ExhibitionRoutes.forum),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('赵').first);
    await tester.pumpAndSettle();

    expect(find.text('作者主页'), findsWidgets);
    expect(find.text('公开帖子 2'), findsOneWidget);
    expect(find.text('公开评论 5'), findsOneWidget);
  });

  testWidgets('forum detail author area hands off to public author profile', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildForumTestApp(
        initialRoute: ExhibitionRoutes.forumPostWithPostId('post-materials-1'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('赵').first);
    await tester.pumpAndSettle();

    expect(find.text('作者主页'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('作者公开帖子'),
      180,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('作者公开帖子'), findsOneWidget);
  });

  testWidgets('forum author profile keeps fallback author display controlled', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildForumTestApp(
        initialRoute: ExhibitionRoutes.forumAuthorWithAuthorId(
          'fallback-author',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('论坛用户'), findsWidgets);
    expect(find.textContaining('u_forum_20260327130433'), findsNothing);
    expect(find.textContaining('closure-dev-org-1774694443'), findsNothing);
  });

  testWidgets(
    'forum author profile can offer bounded handoff to my building for self actor',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildForumTestAppWithOverrides(
          initialRoute: ExhibitionRoutes.forumAuthorWithAuthorId('member-1'),
          bootstrapShellContext: AppShellContextData(
            userId: 'member-1',
            visibleBuildings: const <String>[
              'exhibition',
              'messages',
              'profile',
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('进入我的楼'), findsOneWidget);
    },
  );

  testWidgets(
    'forum author profile consumes bounded block status block and unblock',
    (WidgetTester tester) async {
      var relationBlocked = false;
      final requestedPaths = <String>[];
      Map<String, Object?>? blockBody;
      Map<String, Object?>? unblockBody;

      await tester.pumpWidget(
        buildForumTestAppWithOverrides(
          initialRoute: ExhibitionRoutes.forumAuthorWithAuthorId('member-1'),
          forumHandlerOverrides:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'GET /api/app/profile/block/status':
                    (AppApiRequest request) async {
                      requestedPaths.add(request.canonicalPath);
                      expect(
                        request.uri.queryParameters['targetUserId'],
                        'member-1',
                      );
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: <String, Object?>{
                          'targetUserId': 'member-1',
                          'state': relationBlocked ? 'blocked' : 'unblocked',
                          'isBlocked': relationBlocked,
                        },
                      );
                    },
                'POST /api/app/profile/block': (AppApiRequest request) async {
                  requestedPaths.add(request.canonicalPath);
                  blockBody = request.body as Map<String, Object?>?;
                  relationBlocked = true;
                  return AppApiResponse(
                    statusCode: 202,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'targetUserId': 'member-1',
                      'state': 'blocked',
                      'isBlocked': true,
                      'message': '已拉黑该作者',
                    },
                  );
                },
                'POST /api/app/profile/unblock': (AppApiRequest request) async {
                  requestedPaths.add(request.canonicalPath);
                  unblockBody = request.body as Map<String, Object?>?;
                  relationBlocked = false;
                  return AppApiResponse(
                    statusCode: 202,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'targetUserId': 'member-1',
                      'state': 'unblocked',
                      'isBlocked': false,
                      'message': '已解除拉黑',
                    },
                  );
                },
              },
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView).last, const Offset(0, -240));
      await tester.pumpAndSettle();
      expect(find.text('未拉黑该作者'), findsOneWidget);
      expect(find.text('拉黑作者'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('作者公开帖子'),
        180,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('作者公开帖子'), findsOneWidget);

      await tester.ensureVisible(find.text('拉黑作者'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('拉黑作者'));
      await tester.pumpAndSettle();

      expect(blockBody, const <String, Object?>{'targetUserId': 'member-1'});
      expect(find.text('已拉黑该作者'), findsWidgets);
      expect(find.text('解除拉黑'), findsOneWidget);
      expect(find.text('作者公开帖子'), findsOneWidget);

      await tester.ensureVisible(find.text('解除拉黑'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('解除拉黑'));
      await tester.pumpAndSettle();

      expect(unblockBody, const <String, Object?>{'targetUserId': 'member-1'});
      expect(find.text('未拉黑该作者'), findsOneWidget);
      expect(find.text('拉黑作者'), findsOneWidget);
      expect(
        requestedPaths,
        containsAllInOrder(<String>[
          '/api/app/profile/block/status',
          '/api/app/profile/block',
          '/api/app/profile/block/status',
          '/api/app/profile/unblock',
          '/api/app/profile/block/status',
        ]),
      );
    },
  );

  testWidgets('forum publish topic picker hides raw topic labels', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildForumTestAppWithOverrides(
        initialRoute: ExhibitionRoutes.forumPublish,
        forumHandlerOverrides:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/forum/topic/metadata': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 200,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'items': <Object?>[
                      <String, Object?>{
                        'topicId': '96cf8c4e-c3ec-468a-9690-00491b4a4ad8',
                        'title': 'forum-publish-ready-20260327135138-topic',
                        'description':
                            'forum publish ready draft 20260327135138 for app-facing handoff verification.',
                        'selected': false,
                      },
                      <String, Object?>{
                        'topicId': '894f9752-c847-47e9-818b-6d330bcfaa2b',
                        'title': 'forum-bff-publish-20260327',
                        'description':
                            'forum-bff-publish-20260327 body for app-facing publish evidence.',
                        'selected': false,
                      },
                    ],
                  },
                );
              },
            },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('分类：'));
    await tester.pumpAndSettle();

    expect(find.text('选择发帖分类'), findsOneWidget);
    expect(find.text('布展进场'), findsWidgets);
    expect(find.text('材料协同'), findsWidgets);
    expect(
      find.textContaining('forum-publish-ready-20260327135138-topic'),
      findsNothing,
    );
    expect(find.textContaining('forum-bff-publish-20260327'), findsNothing);
  });

  testWidgets(
    'forum publish media upload binds confirmed file asset ids into draft save',
    (WidgetTester tester) async {
      ForumPublishMediaDebugOverrides.installPicker(
        (_) async => const <ForumPublishMediaDraft>[
          ForumPublishMediaDraft(
            fileName: '现场照片.jpg',
            bytes: <int>[1, 2, 3, 4, 5, 6],
          ),
        ],
      );
      addTearDown(ForumPublishMediaDebugOverrides.reset);

      final draftSaveBodies = <Map<String, Object?>>[];

      await tester.pumpWidget(
        buildForumTestAppWithOverrides(
          initialRoute: ExhibitionRoutes.forumPublish,
          exhibitionHandlerOverrides:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'POST /api/app/file/upload/init':
                    (AppApiRequest request) async {
                      final body = request.body! as Map<String, Object?>;
                      expect(body['businessType'], 'forum_draft_attachment');
                      expect(body['businessId'], 'draft-saved-1');
                      expect(body['fileKind'], 'media');
                      expect(body['mimeType'], 'image/jpeg');
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'uploadSessionId': 'upload-session-1',
                          'directUpload': <String, Object?>{
                            'url': 'https://upload.example.com/forum-media-1',
                            'method': 'PUT',
                            'headers': <String, Object?>{
                              'content-type': 'image/jpeg',
                            },
                          },
                          'confirm': <String, Object?>{
                            'endpoint': '/api/app/file/upload/confirm',
                          },
                        },
                      );
                    },
                'POST /api/app/file/upload/confirm':
                    (AppApiRequest request) async {
                      expect(request.body, const <String, Object?>{
                        'uploadSessionId': 'upload-session-1',
                      });
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'fileAssetId': 'asset-uploaded-1',
                        },
                      );
                    },
              },
          exhibitionUploadHandler: (AppApiUploadRequest request) async {
            expect(request.method, 'PUT');
            expect(request.headers['content-type'], 'image/jpeg');
            return AppApiResponse(statusCode: 200, uri: Uri.parse(request.url));
          },
          forumHandlerOverrides:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'POST /api/app/forum/draft/save':
                    (AppApiRequest request) async {
                      final body = Map<String, Object?>.from(
                        request.body! as Map<Object?, Object?>,
                      );
                      draftSaveBodies.add(body);
                      return AppApiResponse(
                        statusCode: 202,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'draftId': 'draft-saved-1',
                          'state': 'ready_to_publish',
                          'updatedAt': '2026-03-27T10:40:00Z',
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
                    body: const <String, Object?>{
                      'draftId': 'draft-saved-1',
                      'topicId': 'expo-materials',
                      'postId': 'post-with-asset-1',
                      'state': 'published',
                      'summary': <String, Object?>{
                        'title': '附件帖子',
                        'publishedAt': '2026-03-27T11:00:00Z',
                      },
                      'decision': 'clear',
                      'message': '发布成功',
                    },
                  );
                },
                'GET /api/app/forum/post/detail':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'postId': 'post-with-asset-1',
                          'topicId': 'expo-materials',
                          'topicTitle': '布展进场',
                          'state': 'published',
                          'author': <String, Object?>{
                            'authorId': 'member-1',
                            'displayName': '赵工',
                          },
                          'content': '正式帖子正文',
                          'attachmentRefs': <Object?>[
                            <String, Object?>{
                              'fileAssetId': 'asset-uploaded-1',
                              'fileName': '现场照片.jpg',
                              'mimeType': 'image/jpeg',
                            },
                          ],
                          'publishedAt': '2026-03-27T09:30:00Z',
                          'viewerHasLiked': false,
                          'viewerHasBookmarked': false,
                          'viewerFollowsTopic': true,
                        },
                      );
                    },
              },
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), '附件发帖验证');
      await tester.enterText(find.byType(TextField).at(1), '这是一条带附件的论坛草稿。');
      await tester.pump();

      await tester.drag(find.byType(ListView).first, const Offset(0, -280));
      await tester.pumpAndSettle();
      await tester.tap(find.text('添加图片'));
      await tester.pumpAndSettle();

      expect(find.text('现场照片.jpg'), findsOneWidget);
      await tester.pumpAndSettle();

      expect(find.text('上传确认完成，请保存草稿'), findsOneWidget);

      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      await tester.tap(find.text('保存草稿'));
      await tester.pumpAndSettle();

      expect(draftSaveBodies.last['attachmentFileAssetIds'], const <String>[
        'asset-uploaded-1',
      ]);
      expect(find.text('已保存到草稿，附件已承接'), findsOneWidget);
      expect(find.text('已承接到当前草稿'), findsWidgets);

      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      await tester.tap(find.text('发布'));
      await tester.pumpAndSettle();

      expect(find.text('附件'), findsOneWidget);
      expect(find.text('现场照片.jpg'), findsOneWidget);
    },
  );

  testWidgets(
    'forum publish media upload failure keeps Chinese controlled feedback',
    (WidgetTester tester) async {
      ForumPublishMediaDebugOverrides.installPicker(
        (_) async => const <ForumPublishMediaDraft>[
          ForumPublishMediaDraft(
            fileName: '失败图片.jpg',
            bytes: <int>[6, 5, 4, 3, 2, 1],
          ),
        ],
      );
      addTearDown(ForumPublishMediaDebugOverrides.reset);

      await tester.pumpWidget(
        buildForumTestAppWithOverrides(
          initialRoute: ExhibitionRoutes.forumPublish,
          exhibitionHandlerOverrides:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'POST /api/app/file/upload/init': (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'uploadSessionId': 'upload-session-failure',
                      'directUpload': <String, Object?>{
                        'url': 'https://upload.example.com/forum-media-failure',
                        'method': 'PUT',
                        'headers': <String, Object?>{},
                      },
                      'confirm': <String, Object?>{
                        'endpoint': '/api/app/file/upload/confirm',
                      },
                    },
                  );
                },
              },
          exhibitionUploadHandler: (AppApiUploadRequest request) async {
            return AppApiResponse(statusCode: 503, uri: Uri.parse(request.url));
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), '上传失败验证');
      await tester.enterText(find.byType(TextField).at(1), '附件上传失败时应给中文提示。');
      await tester.pump();

      await tester.drag(find.byType(ListView).first, const Offset(0, -280));
      await tester.pumpAndSettle();
      await tester.tap(find.text('添加图片'));
      await tester.pumpAndSettle();

      await tester.pumpAndSettle();

      expect(find.text('当前附件上传失败，请重新上传后再试'), findsOneWidget);
      expect(find.textContaining('direct upload failed'), findsNothing);
    },
  );

  testWidgets('forum read error state keeps English transport wording hidden', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildForumTestAppWithOverrides(
        initialRoute: ExhibitionRoutes.forum,
        forumHandlerOverrides:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'GET /api/app/forum/feed': (AppApiRequest request) async {
                return AppApiResponse(
                  statusCode: 502,
                  uri: request.uri,
                  body: const <String, Object?>{
                    'code': 'FORUM_FEED_FAILED',
                    'message':
                        'Forum feed aggregation failed. connect ECONNREFUSED 127.0.0.1:3001',
                    'source': 'bff',
                  },
                );
              },
            },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('论坛内容暂时不可用，请稍后再试'), findsOneWidget);
    expect(find.textContaining('ECONNREFUSED'), findsNothing);
    expect(find.textContaining('Forum feed aggregation failed'), findsNothing);
  });

  testWidgets('forum drafts surface stays lightweight', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildForumTestApp(initialRoute: ExhibitionRoutes.forumDrafts),
    );
    await tester.pumpAndSettle();

    expect(find.text('当前草稿列表已承接'), findsNothing);
    expect(find.text('本地进场夜班经验分享'), findsOneWidget);
  });
}
