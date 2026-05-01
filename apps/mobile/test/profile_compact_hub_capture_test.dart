import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/features/exhibition/data/forum_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_identity_consumer_layer.dart';
import 'package:mobile/features/profile/navigation/profile_routes.dart';
import 'package:mobile/shell/shell_app.dart';

const String _outputDir =
    '/Users/wangweiwei/Desktop/展览装修之家总控/.tmp/agent_reports/profile_my_building_compact_hub_frontend_revision/20260330';

Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
_forumHandlers() {
  return <String, Future<AppApiResponse> Function(AppApiRequest request)>{
    'GET /api/app/forum/me/posts': (AppApiRequest request) async =>
        AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: <String, Object?>{
            'items': <Object?>[
              <String, Object?>{
                'postId': 'post-1',
                'title': '供应商交接模板',
                'topicId': 'topic-1',
                'topicTitle': '供应商交接模板',
                'excerpt': '我发布过的一条帖子摘要',
                'state': 'published',
                'author': <String, Object?>{
                  'authorId': 'member-1',
                  'displayName': '赵工',
                },
                'publishedAt': '2026-03-27T10:00:00Z',
                'updatedAt': '2026-03-28T10:00:00Z',
                'canEdit': true,
                'canDelete': true,
              },
            ],
            'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
          },
        ),
    'GET /api/app/forum/me/comments': (AppApiRequest request) async =>
        AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: <String, Object?>{
            'items': <Object?>[
              <String, Object?>{
                'comment': <String, Object?>{
                  'commentId': 'comment-1',
                  'postId': 'post-1',
                  'parentCommentId': null,
                  'author': <String, Object?>{
                    'authorId': 'member-1',
                    'displayName': '赵工',
                  },
                  'body': '我的评论内容',
                  'state': 'published',
                  'publishedAt': '2026-03-27T11:00:00Z',
                  'replyCount': 1,
                },
                'postId': 'post-1',
                'postTitle': '供应商交接模板',
                'topicId': 'topic-1',
                'topicLabel': '材料协同',
              },
            ],
            'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
          },
        ),
    'GET /api/app/forum/me/bookmarks': (AppApiRequest request) async =>
        AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: <String, Object?>{
            'items': <Object?>[
              <String, Object?>{
                'postId': 'post-2',
                'topicId': 'topic-2',
                'topicTitle': '夜班排班经验',
                'excerpt': '收藏过的一条帖子摘要',
                'state': 'published',
                'author': <String, Object?>{
                  'authorId': 'member-2',
                  'displayName': '王监理',
                },
                'publishedAt': '2026-03-26T20:00:00Z',
              },
            ],
            'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
          },
        ),
    'GET /api/app/forum/me/likes': (AppApiRequest request) async =>
        AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: <String, Object?>{
            'items': <Object?>[
              <String, Object?>{
                'postId': 'post-2',
                'topicId': 'topic-2',
                'topicTitle': '夜班排班经验',
                'excerpt': '点过赞的一条帖子摘要',
                'state': 'published',
                'author': <String, Object?>{
                  'authorId': 'member-2',
                  'displayName': '王监理',
                },
                'publishedAt': '2026-03-26T20:00:00Z',
              },
            ],
            'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
          },
        ),
    'GET /api/app/forum/me/follows': (AppApiRequest request) async =>
        AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: <String, Object?>{
            'items': <Object?>[
              <String, Object?>{
                'topicId': 'topic-3',
                'title': '上海布展进场窗口',
                'excerpt': '关注的话题摘要',
                'categoryKey': 'local',
                'state': 'published',
                'author': <String, Object?>{
                  'authorId': 'member-3',
                  'displayName': '陈设计',
                },
                'engagement': <String, Object?>{
                  'replyCount': 3,
                  'likeCount': 8,
                  'viewCount': 56,
                },
                'lastActiveAt': '2026-03-27T08:30:00Z',
                'highlightedPostId': 'post-3',
              },
            ],
            'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
          },
        ),
    'GET /api/app/forum/draft/list': (AppApiRequest request) async =>
        AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: <String, Object?>{
            'items': <Object?>[
              <String, Object?>{
                'draftId': 'draft-1',
                'draftType': 'topic',
                'topicId': 'topic-1',
                'title': '待发布草稿',
                'excerpt': '草稿摘要',
                'state': 'ready_to_publish',
                'updatedAt': '2026-03-27T12:00:00Z',
                'attachmentRefs': <Object?>[],
              },
            ],
            'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
          },
        ),
  };
}

Future<void> _pumpCaptureApp(
  WidgetTester tester,
  GlobalKey boundaryKey, {
  required String initialRoute,
  Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
      profileHandlers =
      const <String, Future<AppApiResponse> Function(AppApiRequest request)>{},
  Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
      profileIdentityHandlers =
      const <String, Future<AppApiResponse> Function(AppApiRequest request)>{},
}) async {
  await tester.pumpWidget(
    RepaintBoundary(
      key: boundaryKey,
      child: KeyedSubtree(
        key: UniqueKey(),
        child: ExhibitionMobileApp(
          initialRoute: initialRoute,
          bootstrapShellContext: AppShellContextData(
            userId: '13812345678',
            organizationId: 'org-profile',
            roleKeys: const <String>['buyer_admin'],
            certificationStatus: 'verified',
            membershipStatus: 'active',
            visibleBuildings: const <String>[
              'exhibition',
              'messages',
              'profile',
            ],
          ),
          profileConsumerLayer: ProfileConsumerLayer(
            client: AppApiClient(
              config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
              transport: FakeAppApiTransport(handlers: profileHandlers),
            ),
          ),
          forumConsumerLayer: ForumConsumerLayer(
            client: AppApiClient(
              config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
              transport: FakeAppApiTransport(handlers: _forumHandlers()),
            ),
          ),
          profileIdentityConsumerLayer: ProfileIdentityConsumerLayer(
            client: AppApiClient(
              config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
              transport: FakeAppApiTransport(handlers: profileIdentityHandlers),
            ),
          ),
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

  final profileHandlers =
      <String, Future<AppApiResponse> Function(AppApiRequest request)>{
        'GET /api/app/profile/index': (AppApiRequest request) async {
          return AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: <String, Object?>{
              'organization': <String, Object?>{
                'organizationId': 'org-profile',
                'roleKeys': <Object?>['buyer_admin'],
                'visibleBuildings': <Object?>[
                  'exhibition',
                  'messages',
                  'profile',
                ],
              },
              'certification': <String, Object?>{'status': 'verified'},
              'membership': <String, Object?>{'status': 'active'},
              'settingsEntry': <String, Object?>{'state': 'visible'},
            },
          );
        },
      };

  final companyHandlers =
      <String, Future<AppApiResponse> Function(AppApiRequest request)>{
        'GET /api/app/profile/organization/mine':
            (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: <String, Object?>{
                  'items': <Object?>[
                    <String, Object?>{
                      'organizationId': 'org-profile',
                      'name': '上海展建服务有限公司',
                      'organizationType': 'supplier',
                      'roleKeys': <Object?>['buyer_admin'],
                      'membershipStatus': 'active',
                      'certificationStatus': 'verified',
                      'current': true,
                    },
                  ],
                },
              );
            },
        'GET /api/app/profile/certification/current':
            (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: <String, Object?>{
                  'organizationId': 'org-profile',
                  'certificationStatus': 'verified',
                  'legalName': '上海展建服务有限公司',
                  'uscc': '91310000123456789A',
                  'submittedAt': '2026-03-27 10:00',
                  'expiresAt': '2027-03-27',
                },
              );
            },
      };

  testWidgets('capture compact profile surfaces', (WidgetTester tester) async {
    final boundaryKey = GlobalKey();
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
    await tester.binding.setSurfaceSize(const Size(393, 852));

    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: '/profile',
      profileHandlers: profileHandlers,
    );
    await _capture(tester, boundaryKey, '01_profile_hub_home.png');

    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ProfileRoutes.forum,
      profileHandlers: profileHandlers,
    );
    await _capture(tester, boundaryKey, '02_profile_forum_page.png');

    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: '/profile',
      profileHandlers: profileHandlers,
    );
    await tester.tap(find.text('138****5678').first);
    await tester.pumpAndSettle();
    await _capture(tester, boundaryKey, '03_profile_personal_page.png');

    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ProfileRoutes.company,
      profileHandlers: profileHandlers,
      profileIdentityHandlers: companyHandlers,
    );
    await _capture(tester, boundaryKey, '04_profile_company_page.png');

    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ProfileRoutes.settings,
      profileHandlers: profileHandlers,
    );
    await tester.drag(find.byType(ListView).first, const Offset(0, -220));
    await tester.pumpAndSettle();
    await _capture(tester, boundaryKey, '05_profile_settings_page.png');

    await _pumpCaptureApp(
      tester,
      boundaryKey,
      initialRoute: ProfileRoutes.company,
      profileHandlers: profileHandlers,
      profileIdentityHandlers:
          <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/profile/organization/mine':
                (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{'items': <Object?>[]},
                  );
                },
            'GET /api/app/profile/certification/current':
                (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 404,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'code': 'PROFILE_CERTIFICATION_UNAVAILABLE',
                      'message': 'profile certification unavailable',
                    },
                  );
                },
          },
    );
    await _capture(tester, boundaryKey, '06_profile_company_empty_state.png');
  });
}
