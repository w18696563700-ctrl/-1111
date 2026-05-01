import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/core/config/config_manifest.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/forum_consumer_layer.dart';
import 'package:mobile/features/messages/data/messages_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_consumer_layer.dart';
import 'package:mobile/features/profile/data/profile_governance_appeal_consumer_layer.dart';
import 'package:mobile/shell/shell_app.dart';

Map<String, Object?> _feedItem(
  String postId,
  String topicId,
  String topicLabel,
  String title, {
  String excerpt = '当前帖子摘要',
}) {
  return <String, Object?>{
    'postId': postId,
    'topicId': topicId,
    'topicLabel': topicLabel,
    'title': title,
    'excerpt': excerpt,
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

Map<String, Object?> _topicMetadataItem(String topicId, String title) {
  return <String, Object?>{
    'topicId': topicId,
    'title': title,
    'description': null,
    'selected': false,
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
    'author': <String, Object?>{'authorId': 'member-1', 'displayName': '赵工'},
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
    'author': <String, Object?>{'authorId': 'member-2', 'displayName': '王监理'},
    'body': body,
    'state': 'published',
    'publishedAt': '2026-03-27T11:00:00Z',
    'replyCount': 1,
  };
}

Map<String, Object?> _postCard(String postId, String topicTitle) {
  return <String, Object?>{
    'postId': postId,
    'topicId': 'expo-materials',
    'topicTitle': topicTitle,
    'title': topicTitle,
    'excerpt': '当前帖子摘要',
    'state': 'published',
    'author': <String, Object?>{'authorId': 'member-1', 'displayName': '赵工'},
    'publishedAt': '2026-03-27T09:30:00Z',
    'updatedAt': '2026-03-27T09:30:00Z',
    'canEdit': false,
    'canDelete': false,
  };
}

Map<String, Object?> _myPostItem(String postId, String title) {
  return <String, Object?>{
    'postId': postId,
    'title': title,
    'topicId': 'expo-materials',
    'topicTitle': '布展进场',
    'excerpt': '当前帖子摘要',
    'state': 'published',
    'publishedAt': '2026-03-27T09:30:00Z',
    'updatedAt': '2026-03-30T09:30:00Z',
    'canEdit': true,
    'canDelete': true,
  };
}

Map<String, Object?> _authorProfile({
  required String authorId,
  required String displayName,
  String? avatarUrl,
  String? organizationName,
  int publicPostCount = 2,
  int publicCommentCount = 3,
}) {
  return <String, Object?>{
    'authorId': authorId,
    'displayName': displayName,
    'avatarUrl': avatarUrl,
    'organizationName': organizationName,
    'publicPostCount': publicPostCount,
    'publicCommentCount': publicCommentCount,
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

Map<String, Object?> _draftDetail(
  String draftId, {
  String draftType = 'topic',
  String? targetPostId,
  String topicId = 'expo-materials',
  String title = '本地进场夜班经验分享',
  String body = '这是一条已保存的论坛草稿内容。',
  List<String> attachmentFileAssetIds = const <String>[],
  String state = 'ready_to_publish',
}) {
  return <String, Object?>{
    'draftId': draftId,
    'draftType': draftType,
    'targetPostId': targetPostId,
    'topicId': topicId,
    'title': title,
    'body': body,
    'attachmentFileAssetIds': attachmentFileAssetIds,
    'state': state,
    'updatedAt': '2026-03-27T09:00:00Z',
  };
}

Map<String, Object?> _myReportTicket(String reportTicketId) {
  return <String, Object?>{
    'reportTicketId': reportTicketId,
    'targetType': 'post',
    'targetId': 'post-materials-1',
    'reasonCode': 'spam_or_flood',
    'reasonDetail': '该内容重复刷屏。',
    'status': 'submitted',
    'targetSnapshot': const <String, Object?>{
      'targetType': 'post',
      'postId': 'post-materials-1',
      'title': '夜间进场窗口怎么排吊装和安检顺序？',
      'excerpt': '当前举报目标快照摘要',
      'state': 'published',
      'publishedAt': '2026-03-27T09:30:00Z',
    },
    'submittedAt': '2026-03-31T09:00:00Z',
    'updatedAt': '2026-03-31T09:00:00Z',
  };
}

Map<String, Object?> _myAppealListItem(String appealCaseId) {
  return <String, Object?>{
    'appealCaseId': appealCaseId,
    'status': 'submitted',
    'statusLabel': '待审核',
    'submittedAt': '2026-04-08T10:00:00Z',
    'decidedAt': null,
    'penalty': const <String, Object?>{
      'penaltyId': 'penalty-1',
      'penaltyType': 'restrict_publish',
      'penaltyTypeLabel': '限制发布',
      'penaltyStatus': 'active',
      'penaltyStatusLabel': '生效中',
      'reasonSummary': '存在重复刷屏与误导性内容。',
      'effectiveFrom': '2026-04-07T09:00:00Z',
      'effectiveUntil': '2026-04-15T09:00:00Z',
    },
  };
}

Map<String, Object?> _myAppealDetail(String appealCaseId) {
  return <String, Object?>{
    'appealCaseId': appealCaseId,
    'status': 'submitted',
    'statusLabel': '待审核',
    'appealReason': '该处罚对当前账号影响过重，申请复核。',
    'decision': null,
    'decisionLabel': null,
    'decisionNote': null,
    'submittedAt': '2026-04-08T10:00:00Z',
    'decidedAt': null,
    'evidenceFileAssetIds': const <Object?>['file-asset-1', 'file-asset-2'],
    'penalty': const <String, Object?>{
      'penaltyId': 'penalty-1',
      'penaltyType': 'restrict_publish',
      'penaltyTypeLabel': '限制发布',
      'penaltyStatus': 'active',
      'penaltyStatusLabel': '生效中',
      'reasonSummary': '存在重复刷屏与误导性内容。',
      'effectiveFrom': '2026-04-07T09:00:00Z',
      'effectiveUntil': '2026-04-15T09:00:00Z',
    },
  };
}

Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
_forumHandlers() {
  var relationBlocked = false;
  return <String, Future<AppApiResponse> Function(AppApiRequest request)>{
    'GET /api/app/forum/feed': (AppApiRequest request) async {
      final scope = request.uri.queryParameters['scope'];
      expect(scope, isNotNull);
      final items = switch (scope) {
        'following' => <Object?>[
          _feedItem('post-follow-1', 'vendor-collab', '材料协同', '关注的协同模板更新'),
        ],
        'local' => <Object?>[
          _feedItem('post-local-1', 'shanghai-load-in', '本地供应链', '上海夜间进场窗口更新'),
        ],
        _ => <Object?>[
          _feedItem(
            'post-materials-1',
            'expo-materials',
            '布展进场',
            '夜间进场窗口怎么排吊装和安检顺序？',
          ),
          _feedItem(
            'post-materials-2',
            'vendor-collab',
            '材料协同',
            '供应商交接模板怎么落地更省沟通',
          ),
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
          'content': '正式帖子正文',
          'attachmentRefs': <Object?>[
            <String, Object?>{
              'fileAssetId': 'asset-1',
              'fileName': 'materials.pdf',
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
            _commentItem('comment-2', '材料外箱贴区域码会更稳。'),
          ],
          'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
        },
      );
    },
    'POST /api/app/forum/post/comment': (AppApiRequest request) async {
      final body =
          request.body as Map<String, Object?>? ?? const <String, Object?>{};
      return AppApiResponse(
        statusCode: 202,
        uri: request.uri,
        body: <String, Object?>{
          'commentId': 'comment-new-1',
          'postId': body['postId'] ?? 'post-materials-1',
          'parentCommentId': body['parentCommentId'],
          'state': 'published',
          'publishedAt': '2026-03-30T09:00:00Z',
        },
      );
    },
    'POST /api/app/forum/post/like': (AppApiRequest request) async {
      final body =
          request.body as Map<String, Object?>? ?? const <String, Object?>{};
      final liked = body['action'] == 'like';
      return AppApiResponse(
        statusCode: 202,
        uri: request.uri,
        body: <String, Object?>{
          'postId': body['postId'] ?? 'post-materials-1',
          'state': liked ? 'liked' : 'unliked',
          'viewerHasLiked': liked,
          'likeCount': liked ? 1 : 0,
        },
      );
    },
    'POST /api/app/forum/post/bookmark': (AppApiRequest request) async {
      final body =
          request.body as Map<String, Object?>? ?? const <String, Object?>{};
      final bookmarked = body['action'] == 'add';
      return AppApiResponse(
        statusCode: 202,
        uri: request.uri,
        body: <String, Object?>{
          'postId': body['postId'] ?? 'post-materials-1',
          'state': bookmarked ? 'bookmarked' : 'unbookmarked',
          'viewerHasBookmarked': bookmarked,
        },
      );
    },
    'POST /api/app/forum/report/submit': (AppApiRequest request) async {
      return AppApiResponse(
        statusCode: 202,
        uri: request.uri,
        body: const <String, Object?>{
          'status': 'submitted',
          'message': '举报已提交',
        },
      );
    },
    'GET /api/app/forum/reports/mine': (AppApiRequest request) async {
      return AppApiResponse(
        statusCode: 200,
        uri: request.uri,
        body: <String, Object?>{
          'items': <Object?>[_myReportTicket('report-ticket-1')],
        },
      );
    },
    'GET /api/app/forum/reports/mine/report-ticket-1':
        (AppApiRequest request) async {
          return AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: _myReportTicket('report-ticket-1'),
          );
        },
    'GET /api/app/profile/block/status': (AppApiRequest request) async {
      final targetUserId = request.uri.queryParameters['targetUserId'];
      if (targetUserId == null || targetUserId.trim().isEmpty) {
        return AppApiResponse(
          statusCode: 400,
          uri: request.uri,
          body: const <String, Object?>{
            'code': 'BLOCK_TARGET_INVALID',
            'message': 'targetUserId is required for block status.',
          },
        );
      }
      return AppApiResponse(
        statusCode: 200,
        uri: request.uri,
        body: <String, Object?>{
          'targetUserId': targetUserId,
          'state': relationBlocked ? 'blocked' : 'unblocked',
          'isBlocked': relationBlocked,
        },
      );
    },
    'POST /api/app/profile/block': (AppApiRequest request) async {
      final body =
          request.body as Map<String, Object?>? ?? const <String, Object?>{};
      final targetUserId = body['targetUserId'] as String?;
      if (targetUserId == null || targetUserId.trim().isEmpty) {
        return AppApiResponse(
          statusCode: 400,
          uri: request.uri,
          body: const <String, Object?>{
            'code': 'BLOCK_TARGET_INVALID',
            'message': 'targetUserId is required for block.',
          },
        );
      }
      relationBlocked = true;
      return AppApiResponse(
        statusCode: 202,
        uri: request.uri,
        body: <String, Object?>{
          'targetUserId': targetUserId,
          'state': 'blocked',
          'isBlocked': true,
          'message': '已拉黑该作者',
        },
      );
    },
    'POST /api/app/profile/unblock': (AppApiRequest request) async {
      final body =
          request.body as Map<String, Object?>? ?? const <String, Object?>{};
      final targetUserId = body['targetUserId'] as String?;
      if (targetUserId == null || targetUserId.trim().isEmpty) {
        return AppApiResponse(
          statusCode: 400,
          uri: request.uri,
          body: const <String, Object?>{
            'code': 'BLOCK_TARGET_INVALID',
            'message': 'targetUserId is required for unblock.',
          },
        );
      }
      relationBlocked = false;
      return AppApiResponse(
        statusCode: 202,
        uri: request.uri,
        body: <String, Object?>{
          'targetUserId': targetUserId,
          'state': 'unblocked',
          'isBlocked': false,
          'message': '已解除拉黑',
        },
      );
    },
    'GET /api/app/profile/governance/appeals': (AppApiRequest request) async {
      return AppApiResponse(
        statusCode: 200,
        uri: request.uri,
        body: <String, Object?>{
          'items': <Object?>[_myAppealListItem('appeal-case-1')],
          'pagination': const <String, Object?>{
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
          return AppApiResponse(
            statusCode: 200,
            uri: request.uri,
            body: _myAppealDetail('appeal-case-1'),
          );
        },
    'GET /api/app/forum/author/profile': (AppApiRequest request) async {
      final authorId = request.uri.queryParameters['authorId'];
      if (authorId == null || authorId.trim().isEmpty) {
        return AppApiResponse(
          statusCode: 400,
          uri: request.uri,
          body: const <String, Object?>{
            'code': 'FORUM_AUTHOR_INVALID',
            'message': 'authorId is required for forum author profile.',
          },
        );
      }
      if (authorId == 'fallback-author') {
        return AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: _authorProfile(
            authorId: 'fallback-author',
            displayName: 'u_forum_20260327130433',
            organizationName: 'closure-dev-org-1774694443',
            publicPostCount: 1,
            publicCommentCount: 0,
          ),
        );
      }
      return AppApiResponse(
        statusCode: 200,
        uri: request.uri,
        body: _authorProfile(
          authorId: 'member-1',
          displayName: '赵工',
          organizationName: '展览协作组',
          publicPostCount: 2,
          publicCommentCount: 5,
        ),
      );
    },
    'GET /api/app/forum/author/posts': (AppApiRequest request) async {
      final authorId = request.uri.queryParameters['authorId'];
      if (authorId == null || authorId.trim().isEmpty) {
        return AppApiResponse(
          statusCode: 400,
          uri: request.uri,
          body: const <String, Object?>{
            'code': 'FORUM_AUTHOR_INVALID',
            'message': 'authorId is required for forum author posts.',
          },
        );
      }
      if (authorId == 'empty-author') {
        return AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: const <String, Object?>{
            'items': <Object?>[],
            'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
          },
        );
      }
      if (authorId == 'fallback-author') {
        return AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: <String, Object?>{
            'items': <Object?>[
              <String, Object?>{
                'postId': 'post-fallback-1',
                'topicId': 'expo-materials',
                'topicTitle': 'forum-publish-ready-20260327135138-topic',
                'title': 'forum-publish-ready-20260327135138-topic',
                'excerpt': 'fallback author 的公开帖子摘要。',
                'state': 'published',
                'publishedAt': '2026-03-27T09:30:00Z',
                'updatedAt': '2026-03-27T09:30:00Z',
                'canEdit': false,
                'canDelete': false,
              },
            ],
            'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
          },
        );
      }
      return AppApiResponse(
        statusCode: 200,
        uri: request.uri,
        body: <String, Object?>{
          'items': <Object?>[
            _postCard('post-materials-1', '布展进场'),
            _postCard('post-materials-2', '材料协同'),
          ],
          'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
        },
      );
    },
    'POST /api/app/forum/draft/save': (AppApiRequest request) async {
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
    'GET /api/app/forum/draft/list': (AppApiRequest request) async {
      return AppApiResponse(
        statusCode: 200,
        uri: request.uri,
        body: <String, Object?>{
          'items': <Object?>[_draftCard('draft-1', '本地进场夜班经验分享')],
          'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
        },
      );
    },
    'GET /api/app/forum/draft/detail': (AppApiRequest request) async {
      final draftId = request.uri.queryParameters['draftId'] ?? 'draft-1';
      return AppApiResponse(
        statusCode: 200,
        uri: request.uri,
        body: _draftDetail(draftId),
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
            'unreadReplyCount': 1,
          },
          'recentTopics': <Object?>[_topicCard('expo-materials', '展台材料分享')],
          'recentPosts': <Object?>[_postCard('post-materials-1', '展台材料分享')],
          'recentDrafts': <Object?>[_draftCard('draft-1', '本地进场夜班经验分享')],
        },
      );
    },
    'GET /api/app/forum/me/posts': (AppApiRequest request) async =>
        AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: <String, Object?>{
            'items': <Object?>[_myPostItem('post-materials-1', '展台材料分享')],
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
                'commentId': 'comment-1',
                'postId': 'post-materials-1',
                'parentCommentId': null,
                'author': <String, Object?>{
                  'authorId': 'member-1',
                  'displayName': '赵工',
                },
                'body': '我的评论内容',
                'state': 'published',
                'publishedAt': '2026-03-27T11:00:00Z',
                'replyCount': 1,
                'post': <String, Object?>{
                  'postId': 'post-materials-1',
                  'topicId': 'expo-materials',
                  'topicLabel': '布展进场',
                  'title': '展台材料分享',
                  'excerpt': '当前帖子摘要',
                  'publishedAt': '2026-03-27T09:30:00Z',
                },
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
                'bookmarkId': 'bookmark-1',
                'postId': 'post-materials-2',
                'state': 'bookmarked',
                'bookmarkedAt': '2026-03-27T12:00:00Z',
                'post': <String, Object?>{
                  'postId': 'post-materials-2',
                  'topicId': 'expo-materials',
                  'topicLabel': '布展进场',
                  'title': '供应商交接模板',
                  'excerpt': '当前帖子摘要',
                  'author': <String, Object?>{
                    'authorId': 'member-1',
                    'displayName': '赵工',
                  },
                  'publishedAt': '2026-03-27T09:30:00Z',
                },
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
                'postId': 'post-materials-1',
                'topicId': 'expo-materials',
                'topicTitle': '布展进场',
                'excerpt': '我点过赞的一条帖子摘要',
                'state': 'published',
                'author': <String, Object?>{
                  'authorId': 'member-1',
                  'displayName': '赵工',
                },
                'publishedAt': '2026-03-27T09:30:00Z',
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
            'items': <Object?>[_topicCard('vendor-collab', '供应协同模板')],
            'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
          },
        ),
    'GET /api/app/forum/interaction/inbox': (AppApiRequest request) async =>
        AppApiResponse(
          statusCode: 200,
          uri: request.uri,
          body: const <String, Object?>{
            'items': <Object?>[],
            'page': <String, Object?>{'nextCursor': null, 'hasMore': false},
          },
        ),
    'POST /api/app/forum/publish': (AppApiRequest request) async =>
        AppApiResponse(
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
        ),
  };
}

ExhibitionMobileApp buildForumTestApp({required String initialRoute}) {
  return buildForumTestAppWithOverrides(initialRoute: initialRoute);
}

ExhibitionMobileApp buildForumTestAppWithOverrides({
  required String initialRoute,
  AppShellContextData? bootstrapShellContext,
  Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
      exhibitionHandlerOverrides =
      const <String, Future<AppApiResponse> Function(AppApiRequest request)>{},
  Future<AppApiResponse> Function(AppApiUploadRequest request)?
  exhibitionUploadHandler,
  Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
      forumHandlerOverrides =
      const <String, Future<AppApiResponse> Function(AppApiRequest request)>{},
  Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
      profileGovernanceAppealHandlerOverrides =
      const <String, Future<AppApiResponse> Function(AppApiRequest request)>{},
  AppSessionStore? sessionStore,
}) {
  final manifest = AppConfigManifest.bootstrapDefaults();
  final forumHandlers =
      <String, Future<AppApiResponse> Function(AppApiRequest request)>{
        ..._forumHandlers(),
        ...forumHandlerOverrides,
      };
  final profileGovernanceAppealHandlers =
      <String, Future<AppApiResponse> Function(AppApiRequest request)>{
        'GET /api/app/profile/governance/appeals':
            (AppApiRequest request) async {
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: <String, Object?>{
                  'items': <Object?>[_myAppealListItem('appeal-case-1')],
                  'pagination': const <String, Object?>{
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
              return AppApiResponse(
                statusCode: 200,
                uri: request.uri,
                body: _myAppealDetail('appeal-case-1'),
              );
            },
        ...profileGovernanceAppealHandlerOverrides,
      };
  return ExhibitionMobileApp(
    initialRoute: initialRoute,
    bootstrapManifest: manifest,
    bootstrapShellContext:
        bootstrapShellContext ??
        AppShellContextData.bootstrapDefaults(manifest: manifest),
    exhibitionConsumerLayer: ExhibitionConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers: exhibitionHandlerOverrides,
          uploadHandler: exhibitionUploadHandler,
        ),
      ),
    ),
    forumConsumerLayer: ForumConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(handlers: forumHandlers),
      ),
    ),
    messagesConsumerLayer: MessagesConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers:
              <
                String,
                Future<AppApiResponse> Function(AppApiRequest request)
              >{},
        ),
      ),
    ),
    profileConsumerLayer: ProfileConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers:
              <String, Future<AppApiResponse> Function(AppApiRequest request)>{
                'GET /api/app/profile/index': (AppApiRequest request) async {
                  return AppApiResponse(
                    statusCode: 200,
                    uri: request.uri,
                    body: const <String, Object?>{
                      'organization': <String, Object?>{
                        'organizationId': null,
                        'roleKeys': <String>[],
                        'visibleBuildings': <String>[
                          'exhibition',
                          'messages',
                          'profile',
                        ],
                      },
                      'certification': <String, Object?>{'status': null},
                      'membership': <String, Object?>{'status': null},
                      'settingsEntry': <String, Object?>{'state': 'visible'},
                    },
                  );
                },
                'GET /api/app/profile/governance/appeals':
                    (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: <String, Object?>{
                          'items': <Object?>[
                            _myAppealListItem('appeal-case-1'),
                          ],
                          'pagination': const <String, Object?>{
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
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: _myAppealDetail('appeal-case-1'),
                      );
                    },
              },
        ),
      ),
    ),
    profileGovernanceAppealConsumerLayer: ProfileGovernanceAppealConsumerLayer(
      client: AppApiClient(
        config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
        transport: FakeAppApiTransport(
          handlers: profileGovernanceAppealHandlers,
        ),
      ),
    ),
    sessionStore: sessionStore,
  );
}
