import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/auth/auth_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/forum_consumer_layer.dart';

void main() {
  setUp(_resetSessionState);
  tearDown(_resetSessionState);

  test('forum save draft recovers after one refresh retry', () async {
    _installSession(expired: false);
    var refreshRequests = 0;
    var saveRequests = 0;
    _installAuthConsumer(
      FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'POST /api/app/auth/refresh': (AppApiRequest request) async {
                refreshRequests += 1;
                return _refreshSuccess(
                  request,
                  accessToken: 'forum-save-token',
                );
              },
            },
      ),
    );

    final consumer = ForumConsumerLayer(
      client: AppApiClient(
        config: _config(),
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'POST /api/app/forum/draft/save':
                    (AppApiRequest request) async {
                      saveRequests += 1;
                      if (saveRequests == 1) {
                        return _unauthorized(
                          request,
                          path: ForumCanonicalPaths.draftSave,
                        );
                      }
                      expect(
                        request.headers['authorization'],
                        'Bearer forum-save-token',
                      );
                      return AppApiResponse(
                        statusCode: 202,
                        uri: request.uri,
                        body: const <String, Object?>{
                          'draftId': 'draft-1',
                          'state': 'draft_saved',
                          'updatedAt': '2026-04-03T09:30:00Z',
                        },
                      );
                    },
              },
        ),
      ),
    );

    final result = await consumer.saveDraft(
      draftId: 'draft-1',
      topicId: 'topic-1',
      title: 'draft title',
      body: 'draft body',
    );

    expect(result.isSuccess, isTrue);
    expect(refreshRequests, 1);
    expect(saveRequests, 2);
  });

  test('forum publish recovers with pre-refresh', () async {
    _installSession(expired: true);
    var refreshRequests = 0;
    var publishRequests = 0;
    _installAuthConsumer(
      FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'POST /api/app/auth/refresh': (AppApiRequest request) async {
                refreshRequests += 1;
                return _refreshSuccess(
                  request,
                  accessToken: 'forum-publish-token',
                );
              },
            },
      ),
    );

    final consumer = ForumConsumerLayer(
      client: AppApiClient(
        config: _config(),
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'POST /api/app/forum/publish': (AppApiRequest request) async {
                  publishRequests += 1;
                  expect(
                    request.headers['authorization'],
                    'Bearer forum-publish-token',
                  );
                  return AppApiResponse(
                    statusCode: 202,
                    uri: request.uri,
                    body: _publishClearBody(),
                  );
                },
              },
        ),
      ),
    );

    final result = await consumer.publishDraft(draftId: 'draft-1');

    expect(result.isSuccess, isTrue);
    expect(refreshRequests, 1);
    expect(publishRequests, 1);
  });

  test('forum draft list recovers after one refresh retry', () async {
    _installSession(expired: false);
    var refreshRequests = 0;
    var draftListRequests = 0;
    _installAuthConsumer(
      FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'POST /api/app/auth/refresh': (AppApiRequest request) async {
                refreshRequests += 1;
                return _refreshSuccess(
                  request,
                  accessToken: 'forum-draft-list-token',
                );
              },
            },
      ),
    );

    final consumer = ForumConsumerLayer(
      client: AppApiClient(
        config: _config(),
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'GET /api/app/forum/draft/list': (AppApiRequest request) async {
                  draftListRequests += 1;
                  if (draftListRequests == 1) {
                    return _unauthorized(
                      request,
                      path: ForumCanonicalPaths.draftList,
                    );
                  }
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: _draftListBody(),
                  );
                },
              },
        ),
      ),
    );

    final result = await consumer.loadDraftList();

    expect(result.state, AppPageState.content);
    expect(result.data?.items.length, 1);
    expect(refreshRequests, 1);
    expect(draftListRequests, 2);
  });

  test('forum me index recovers with pre-refresh', () async {
    _installSession(expired: true);
    var refreshRequests = 0;
    var meIndexRequests = 0;
    _installAuthConsumer(
      FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'POST /api/app/auth/refresh': (AppApiRequest request) async {
                refreshRequests += 1;
                return _refreshSuccess(request, accessToken: 'forum-me-token');
              },
            },
      ),
    );

    final consumer = ForumConsumerLayer(
      client: AppApiClient(
        config: _config(),
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'GET /api/app/forum/me/index': (AppApiRequest request) async {
                  meIndexRequests += 1;
                  expect(
                    request.headers['authorization'],
                    'Bearer forum-me-token',
                  );
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: _meIndexBody(),
                  );
                },
              },
        ),
      ),
    );

    final result = await consumer.loadMeIndex();

    expect(result.state, AppPageState.content);
    expect(result.data?.memberId, 'member-1');
    expect(refreshRequests, 1);
    expect(meIndexRequests, 1);
  });

  test(
    'forum feed recovers with pre-refresh for cloud carrier reads',
    () async {
      _installSession(expired: true);
      var refreshRequests = 0;
      var feedRequests = 0;
      _installAuthConsumer(
        FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'POST /api/app/auth/refresh': (AppApiRequest request) async {
                  refreshRequests += 1;
                  return _refreshSuccess(
                    request,
                    accessToken: 'forum-feed-token',
                  );
                },
              },
        ),
      );

      final consumer = ForumConsumerLayer(
        client: AppApiClient(
          config: _config(),
          transport: FakeAppApiTransport(
            handlers:
                <
                  String,
                  Future<AppApiResponse> Function(AppApiRequest request)
                >{
                  'GET /api/app/forum/feed': (AppApiRequest request) async {
                    feedRequests += 1;
                    expect(
                      request.headers['authorization'],
                      'Bearer forum-feed-token',
                    );
                    expect(request.uri.queryParameters['scope'], 'square');
                    return AppApiResponse(
                      statusCode: 200,
                      uri: request.uri,
                      body: _feedBody(),
                    );
                  },
                },
          ),
        ),
      );

      final result = await consumer.loadFeed(scope: 'square');

      expect(result.state, AppPageState.content);
      expect(result.data?.items.length, 1);
      expect(refreshRequests, 1);
      expect(feedRequests, 1);
    },
  );

  test('forum post detail recovers after one refresh retry', () async {
    _installSession(expired: false);
    var refreshRequests = 0;
    var detailRequests = 0;
    _installAuthConsumer(
      FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'POST /api/app/auth/refresh': (AppApiRequest request) async {
                refreshRequests += 1;
                return _refreshSuccess(
                  request,
                  accessToken: 'forum-detail-token',
                );
              },
            },
      ),
    );

    final consumer = ForumConsumerLayer(
      client: AppApiClient(
        config: _config(),
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'GET /api/app/forum/post/detail':
                    (AppApiRequest request) async {
                      detailRequests += 1;
                      if (detailRequests == 1) {
                        return _unauthorized(
                          request,
                          path: ForumCanonicalPaths.postDetail,
                        );
                      }
                      expect(
                        request.headers['authorization'],
                        'Bearer forum-detail-token',
                      );
                      expect(request.uri.queryParameters['postId'], 'post-1');
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: _postDetailBody(),
                      );
                    },
              },
        ),
      ),
    );

    final result = await consumer.loadPostDetail(postId: 'post-1');

    expect(result.state, AppPageState.content);
    expect(result.data?.author.avatarUrl, 'https://example.test/avatar.png');
    expect(refreshRequests, 1);
    expect(detailRequests, 2);
  });

  test('forum interaction inbox recovers after one refresh retry', () async {
    _installSession(expired: false);
    var refreshRequests = 0;
    var inboxRequests = 0;
    _installAuthConsumer(
      FakeAppApiTransport(
        handlers:
            <String, Future<AppApiResponse> Function(AppApiRequest request)>{
              'POST /api/app/auth/refresh': (AppApiRequest request) async {
                refreshRequests += 1;
                return _refreshSuccess(
                  request,
                  accessToken: 'forum-inbox-token',
                );
              },
            },
      ),
    );

    final consumer = ForumConsumerLayer(
      client: AppApiClient(
        config: _config(),
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'GET /api/app/forum/interaction/inbox':
                    (AppApiRequest request) async {
                      inboxRequests += 1;
                      if (inboxRequests == 1) {
                        return _unauthorized(
                          request,
                          path: ForumCanonicalPaths.interactionInbox,
                        );
                      }
                      expect(request.uri.queryParameters['tab'], 'reply');
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: _interactionInboxBody(),
                      );
                    },
              },
        ),
      ),
    );

    final result = await consumer.loadInteractionInbox(tab: 'reply');

    expect(result.state, AppPageState.content);
    expect(result.data?.items.length, 1);
    expect(refreshRequests, 1);
    expect(inboxRequests, 2);
  });
}

void _resetSessionState() {
  AppApiConfig.resetRuntimeBaseUrlOverride();
  AppSessionStore.reset();
  AuthConsumerLayer.reset();
}

AppApiConfig _config() {
  return AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app');
}

void _installSession({required bool expired}) {
  final store = AppSessionStore();
  AppSessionStore.install(store);
  store.establishSession(
    accessToken: 'stale-access-token',
    refreshToken: 'refresh-token-1',
    expiresInSeconds: expired ? 0 : 3600,
    deviceId: 'device-1',
  );
}

void _installAuthConsumer(FakeAppApiTransport transport) {
  AuthConsumerLayer.install(
    AuthConsumerLayer(
      client: AppApiClient(config: _config(), transport: transport),
    ),
  );
}

AppApiResponse _refreshSuccess(
  AppApiRequest request, {
  required String accessToken,
}) {
  return AppApiResponse(
    statusCode: 200,
    uri: request.uri,
    body: <String, Object?>{
      'accessToken': accessToken,
      'refreshToken': 'refresh-token-2',
      'expiresInSeconds': 3600,
    },
  );
}

AppApiResponse _unauthorized(AppApiRequest request, {required String path}) {
  return AppApiResponse(
    statusCode: 401,
    uri: request.uri.replace(path: path),
    body: const <String, Object?>{'code': 'UNAUTHORIZED', 'message': '当前登录已失效'},
  );
}

Map<String, Object?> _draftListBody() {
  return <String, Object?>{
    'items': <Object?>[_draftCard('draft-1')],
    'page': const <String, Object?>{'nextCursor': null, 'hasMore': false},
  };
}

Map<String, Object?> _meIndexBody() {
  return <String, Object?>{
    'memberId': 'member-1',
    'summary': const <String, Object?>{
      'topicCount': 1,
      'postCount': 2,
      'draftCount': 1,
      'unreadReplyCount': 1,
    },
    'recentTopics': const <Object?>[],
    'recentPosts': const <Object?>[],
    'recentDrafts': <Object?>[_draftCard('draft-1')],
  };
}

Map<String, Object?> _interactionInboxBody() {
  return <String, Object?>{
    'items': <Object?>[
      <String, Object?>{
        'notificationId': 'notice-1',
        'tab': 'reply',
        'targetType': 'post',
        'targetId': 'post-1',
        'title': '有人回复了你',
        'preview': '请查看最新回复',
        'createdAt': '2026-04-03T09:30:00Z',
        'unread': true,
        'canQuickReply': true,
        'actor': _authorSummary(),
      },
    ],
    'page': const <String, Object?>{'nextCursor': null, 'hasMore': false},
  };
}

Map<String, Object?> _feedBody() {
  return <String, Object?>{
    'items': <Object?>[
      <String, Object?>{
        'postId': 'post-1',
        'topicId': 'topic-1',
        'topicLabel': '布展进场',
        'title': '论坛读链帖子',
        'excerpt': '论坛读链摘要',
        'state': 'published',
        'author': _authorSummary(),
        'engagement': const <String, Object?>{
          'replyCount': 0,
          'likeCount': 0,
          'viewCount': 0,
        },
        'publishedAt': '2026-04-03T09:30:00Z',
        'viewerHasLiked': false,
        'viewerHasBookmarked': false,
        'viewerFollowsTopic': false,
      },
    ],
    'page': const <String, Object?>{'nextCursor': null, 'hasMore': false},
  };
}

Map<String, Object?> _postDetailBody() {
  return <String, Object?>{
    'postId': 'post-1',
    'topicId': 'topic-1',
    'topicTitle': '布展进场',
    'state': 'published',
    'author': <String, Object?>{
      ..._authorSummary(),
      'avatarUrl': 'https://example.test/avatar.png',
    },
    'content': '论坛详情正文',
    'attachmentRefs': const <Object?>[],
    'publishedAt': '2026-04-03T09:30:00Z',
    'viewerHasLiked': false,
    'viewerHasBookmarked': false,
    'viewerFollowsTopic': false,
  };
}

Map<String, Object?> _publishClearBody() {
  return const <String, Object?>{
    'draftId': 'draft-1',
    'topicId': 'topic-1',
    'postId': 'post-1',
    'state': 'published',
    'decision': 'clear',
    'message': '发布成功',
    'summary': <String, Object?>{
      'title': 'forum publish success',
      'publishedAt': '2026-04-03T09:30:00Z',
    },
  };
}

Map<String, Object?> _draftCard(String draftId) {
  return <String, Object?>{
    'draftId': draftId,
    'draftType': 'post',
    'topicId': 'topic-1',
    'title': 'draft title',
    'excerpt': 'draft excerpt',
    'state': 'draft_saved',
    'updatedAt': '2026-04-03T09:30:00Z',
    'attachmentRefs': const <Object?>[],
  };
}

Map<String, Object?> _authorSummary() {
  return const <String, Object?>{
    'authorId': 'author-1',
    'displayName': '论坛作者',
    'organizationName': '展览团队',
  };
}
