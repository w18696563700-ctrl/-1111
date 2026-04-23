import 'package:flutter/widgets.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_api_entry_mode.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/core/config/config_manifest.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/forum_consumer_layer.dart';
import 'package:mobile/features/messages/data/messages_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_consumer_layer.dart';
import 'package:mobile/shell/shell_app.dart';

Widget buildForumFormalNavRolloutDemoApp({
  String initialRoute = '/exhibition/forum',
}) {
  const demoBaseUrl = AppApiEntryTarget.sshTunnelBaseUrl;
  final manifest = AppConfigManifest.bootstrapDefaults();
  return ExhibitionMobileApp(
    initialRoute: initialRoute,
    bootstrapManifest: manifest,
    bootstrapShellContext: AppShellContextData.bootstrapDefaults(
      manifest: manifest,
    ),
    exhibitionConsumerLayer: ExhibitionConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: demoBaseUrl),
        transport: FakeAppApiTransport(
          handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{},
        ),
      ),
    ),
    forumConsumerLayer: ForumConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: demoBaseUrl),
        transport: FakeAppApiTransport(handlers: _forumHandlers()),
      ),
    ),
    messagesConsumerLayer: MessagesConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: demoBaseUrl),
        transport: FakeAppApiTransport(
          handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{},
        ),
      ),
    ),
    profileConsumerLayer: ProfileConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: demoBaseUrl),
        transport: FakeAppApiTransport(
          handlers: <String, Future<AppApiResponse> Function(AppApiRequest request)>{
            'GET /api/app/profile/index': (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: <String, Object?>{
                  'organization': <String, Object?>{
                    'organizationId': 'profile-org',
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
          },
        ),
      ),
    ),
  );
}

Map<String, Future<AppApiResponse> Function(AppApiRequest request)> _forumHandlers() {
  return <String, Future<AppApiResponse> Function(AppApiRequest request)>{
    'GET /api/app/forum/feed': (AppApiRequest request) async {
      final scope = request.uri.queryParameters['scope'];
      final items = switch (scope) {
        'following' => <Object?>[
            _feedItem('post-follow-1', 'vendor-collab', '材料协同', '关注的协同模板更新'),
            _feedItem('post-follow-2', 'expo-night', '施工夜班', '搭建夜班排班怎么更稳'),
          ],
        'local' => <Object?>[
            _feedItem('post-local-1', 'shanghai-load-in', '本地供应链', '上海夜间进场窗口更新'),
            _feedItem('post-local-2', 'local-supply', '本地供应链', '本地供应链怎么锁材料替代'),
          ],
        _ => <Object?>[
            _feedItem('post-materials-1', 'expo-materials', '布展进场', '夜间进场窗口怎么排吊装和安检顺序？'),
            _feedItem('post-materials-2', 'vendor-collab', '材料协同', '供应商交接模板怎么落地更省沟通'),
            _feedItem('post-materials-3', 'expo-night', '施工夜班', '夜班搭建复盘里最常见的坑'),
          ],
      };
      return AppApiResponse(
        statusCode: 200,
        uri: request.uri,
        body: <String, Object?>{
          'items': items,
          'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
        },
      );
    },
    'GET /api/app/forum/topic/metadata': (AppApiRequest request) async {
      return AppApiResponse(
        statusCode: 200,
        uri: request.uri,
        body: <String, Object?>{
          'items': <Object?>[
            _topicMetadataItem('expo-materials', '布展进场'),
            _topicMetadataItem('vendor-collab', '材料协同'),
            _topicMetadataItem('local-supply', '本地供应链'),
            _topicMetadataItem('expo-night', '施工夜班'),
          ],
        },
      );
    },
    'GET /api/app/forum/topic/list': (AppApiRequest request) async {
      return AppApiResponse(
        statusCode: 200,
        uri: request.uri,
        body: <String, Object?>{
          'items': <Object?>[
            _topicCard('expo-materials', '展台材料分享'),
            _topicCard('shanghai-load-in', '上海布展进场窗口', categoryKey: 'local'),
          ],
          'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
        },
      );
    },
    'GET /api/app/forum/topic/detail': (AppApiRequest request) async {
      return AppApiResponse(
        statusCode: 200,
        uri: request.uri,
        body: <String, Object?>{
          'topicId': 'expo-materials',
          'title': '展台材料分享',
          'categoryKey': 'expo',
          'state': 'published',
          'author': <String, Object?>{
            'authorId': 'member-1',
            'displayName': '赵工',
          },
          'engagement': <String, Object?>{
            'replyCount': 8,
            'likeCount': 21,
            'viewCount': 132,
          },
          'leadPostId': 'post-materials-1',
          'leadPostExcerpt': '当前 lead-post 摘要',
          'publishedAt': '2026-03-27T09:00:00Z',
          'lastActiveAt': '2026-03-27T10:00:00Z',
        },
      );
    },
    'GET /api/app/forum/post/detail': (AppApiRequest request) async {
      return AppApiResponse(
        statusCode: 200,
        uri: request.uri,
        body: <String, Object?>{
          'postId': 'post-materials-1',
          'topicId': 'expo-materials',
          'topicTitle': '夜间进场窗口怎么排吊装和安检顺序？',
          'state': 'published',
          'author': <String, Object?>{
            'authorId': 'member-1',
            'displayName': '赵工',
          },
          'content': '建议先锁定吊装批次，再排安检顺序；材料外箱贴区域码后，夜间进场能明显少掉一轮沟通。',
          'attachmentRefs': <Object?>[
            <String, Object?>{
              'fileAssetId': 'asset-1',
              'fileName': 'night-shift-checklist.pdf',
              'mimeType': 'application/pdf',
            },
          ],
          'publishedAt': '2026-03-27T09:30:00Z',
          'viewerHasLiked': true,
          'viewerHasBookmarked': false,
          'viewerFollowsTopic': true,
        },
      );
    },
    'GET /api/app/forum/post/comments': (AppApiRequest request) async {
      return AppApiResponse(
        statusCode: 200,
        uri: request.uri,
        body: <String, Object?>{
          'items': <Object?>[
            _commentItem('comment-1', '建议先锁定吊装批次，再排安检顺序。'),
            _commentItem('comment-2', '材料外箱贴区域码，找货和回收都会稳很多。'),
          ],
          'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
        },
      );
    },
    'GET /api/app/forum/draft/list': (AppApiRequest request) async {
      return AppApiResponse(
        statusCode: 200,
        uri: request.uri,
        body: <String, Object?>{
          'items': <Object?>[
            _draftCard('draft-1', '本地进场夜班经验分享'),
          ],
          'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
        },
      );
    },
    'GET /api/app/forum/search': (AppApiRequest request) async {
      return AppApiResponse(
        statusCode: 200,
        uri: request.uri,
        body: <String, Object?>{
          'items': <Object?>[
            <String, Object?>{
              'resultType': 'post',
              'topicId': 'expo-materials',
              'postId': 'post-materials-1',
              'title': '夜间进场窗口怎么排吊装和安检顺序？',
              'excerpt': '搜索命中的帖子摘要',
              'author': <String, Object?>{
                'authorId': 'member-1',
                'displayName': '赵工',
              },
              'publishedAt': '2026-03-27T09:00:00Z',
            },
          ],
          'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
        },
      );
    },
    'GET /api/app/forum/me/index': (AppApiRequest request) async {
      return AppApiResponse(
        statusCode: 200,
        uri: request.uri,
        body: <String, Object?>{
          'memberId': 'member-1',
          'summary': <String, Object?>{
            'topicCount': 3,
            'postCount': 6,
            'draftCount': 1,
            'unreadReplyCount': 2,
          },
          'recentTopics': <Object?>[_topicCard('expo-materials', '展台材料分享')],
          'recentPosts': <Object?>[
            <String, Object?>{
              'postId': 'post-materials-1',
              'topicId': 'expo-materials',
              'topicTitle': '展台材料分享',
              'excerpt': '当前帖子摘要',
              'state': 'published',
              'author': <String, Object?>{
                'authorId': 'member-1',
                'displayName': '赵工',
              },
              'publishedAt': '2026-03-27T09:30:00Z',
            },
          ],
          'recentDrafts': <Object?>[_draftCard('draft-1', '本地进场夜班经验分享')],
        },
      );
    },
    'GET /api/app/forum/me/posts': (AppApiRequest request) async =>
        _pagedResponse(
          request,
          <Object?>[
            _postCard('post-1', '供应商交接模板', '我发布过的一条帖子摘要'),
          ],
        ),
    'GET /api/app/forum/me/comments': (AppApiRequest request) async =>
        _pagedResponse(
          request,
          <Object?>[
            <String, Object?>{
              'comment': _commentItem('comment-3', '我的评论内容'),
              'postId': 'post-1',
              'postTitle': '供应商交接模板',
              'topicId': 'topic-1',
              'topicLabel': '材料协同',
            },
          ],
        ),
    'GET /api/app/forum/me/bookmarks': (AppApiRequest request) async =>
        _pagedResponse(
          request,
          <Object?>[
            _postCard('post-2', '夜班排班经验', '收藏过的一条帖子摘要'),
          ],
        ),
    'GET /api/app/forum/me/follows': (AppApiRequest request) async =>
        _pagedResponse(
          request,
          <Object?>[
            _topicCard('topic-3', '上海布展进场窗口', categoryKey: 'local'),
          ],
        ),
    'GET /api/app/forum/interaction/inbox': (AppApiRequest request) async {
      final tab = request.uri.queryParameters['tab'];
      final items = switch (tab) {
        'likes' => <Object?>[
            _inboxItem(
              notificationId: 'notice-like-1',
              tab: 'likes',
              targetType: 'forum_post',
              targetId: 'post-materials-1',
              title: '赞了你在《搭建夜班排班》下的评论',
            ),
          ],
        'follows' => <Object?>[
            _inboxItem(
              notificationId: 'notice-follow-1',
              tab: 'follows',
              targetType: 'forum_topic',
              targetId: 'topic-3',
              title: '新关注了你的话题更新',
            ),
          ],
        _ => <Object?>[
            _inboxItem(
              notificationId: 'notice-reply-1',
              tab: 'replies',
              targetType: 'forum_post',
              targetId: 'post-materials-1',
              title: '回复了你在《材料交接节点》里的问题',
              preview: '建议先锁定吊装批次。',
            ),
          ],
      };
      return _pagedResponse(request, items);
    },
    'POST /api/app/forum/publish': (AppApiRequest request) async {
      return AppApiResponse(
        statusCode: 202,
        uri: request.uri,
        body: <String, Object?>{
          'draftId': 'draft-1',
          'topicId': 'expo-materials',
          'postId': 'post-materials-1',
          'state': 'published',
          'summary': <String, Object?>{
            'title': '本地进场夜班经验分享',
            'publishedAt': '2026-03-27T11:00:00Z',
          },
          'decision': 'clear',
          'message': '发布成功',
        },
      );
    },
  };
}

Future<AppApiResponse> _pagedResponse(
  AppApiRequest request,
  List<Object?> items,
) async {
  return AppApiResponse(
    statusCode: 200,
    uri: request.uri,
    body: <String, Object?>{
      'items': items,
      'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
    },
  );
}

Map<String, Object?> _topicMetadataItem(String topicId, String title) {
  return <String, Object?>{
    'topicId': topicId,
    'title': title,
    'description': null,
    'selected': false,
  };
}

Map<String, Object?> _feedItem(
  String postId,
  String topicId,
  String topicLabel,
  String title,
) {
  return <String, Object?>{
    'postId': postId,
    'topicId': topicId,
    'topicLabel': topicLabel,
    'title': title,
    'excerpt': '当前帖子摘要',
    'state': 'published',
    'author': <String, Object?>{
      'authorId': 'member-1',
      'displayName': '赵工',
      'organizationName': '展览协作组',
    },
    'engagement': <String, Object?>{
      'replyCount': 8,
      'likeCount': 21,
      'viewCount': 132,
    },
    'publishedAt': '2026-03-27T10:00:00Z',
    'viewerHasLiked': false,
    'viewerHasBookmarked': false,
    'viewerFollowsTopic': topicId == 'expo-materials',
  };
}

Map<String, Object?> _topicCard(
  String topicId,
  String title, {
  String categoryKey = 'expo',
}) {
  return <String, Object?>{
    'topicId': topicId,
    'title': title,
    'excerpt': '当前话题摘要',
    'categoryKey': categoryKey,
    'state': 'published',
    'author': <String, Object?>{
      'authorId': 'member-1',
      'displayName': '赵工',
    },
    'engagement': <String, Object?>{
      'replyCount': 8,
      'likeCount': 21,
      'viewCount': 132,
    },
    'lastActiveAt': '2026-03-27T10:00:00Z',
    'highlightedPostId': 'post-materials-1',
  };
}

Map<String, Object?> _commentItem(String commentId, String body) {
  return <String, Object?>{
    'commentId': commentId,
    'postId': 'post-materials-1',
    'parentCommentId': null,
    'author': <String, Object?>{
      'authorId': 'member-2',
      'displayName': '王监理',
    },
    'body': body,
    'state': 'published',
    'publishedAt': '2026-03-27T11:00:00Z',
    'replyCount': 1,
  };
}

Map<String, Object?> _draftCard(String draftId, String title) {
  return <String, Object?>{
    'draftId': draftId,
    'draftType': 'topic',
    'topicId': 'expo-materials',
    'title': title,
    'excerpt': '当前草稿摘要',
    'state': 'ready_to_publish',
    'updatedAt': '2026-03-27T09:00:00Z',
    'attachmentRefs': <Object?>[],
  };
}

Map<String, Object?> _postCard(
  String postId,
  String topicTitle,
  String excerpt,
) {
  return <String, Object?>{
    'postId': postId,
    'topicId': 'topic-1',
    'topicTitle': topicTitle,
    'excerpt': excerpt,
    'state': 'published',
    'author': <String, Object?>{
      'authorId': 'member-1',
      'displayName': '赵工',
    },
    'publishedAt': '2026-03-27T09:30:00Z',
  };
}

Map<String, Object?> _inboxItem({
  required String notificationId,
  required String tab,
  required String targetType,
  required String targetId,
  required String title,
  String? preview,
}) {
  return <String, Object?>{
    'notificationId': notificationId,
    'tab': tab,
    'actor': <String, Object?>{
      'authorId': 'member-1',
      'displayName': '王监理',
      'organizationName': '现场协作组',
    },
    'targetType': targetType,
    'targetId': targetId,
    'title': title,
    'preview': preview,
    'createdAt': '2026-03-27T10:00:00Z',
    'unread': true,
    'canQuickReply': true,
  };
}
