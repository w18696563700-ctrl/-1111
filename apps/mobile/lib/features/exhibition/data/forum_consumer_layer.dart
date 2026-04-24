import 'dart:io';

import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/auth/protected_app_request.dart';
import 'package:mobile/features/exhibition/data/forum_visible_copy.dart';

part 'forum_consumer_models.dart';
part 'forum_consumer_interaction_models.dart';
part 'forum_consumer_governance_models.dart';
part 'forum_consumer_my_report_models.dart';
part 'forum_consumer_block_models.dart';
part 'forum_consumer_publish_models.dart';
part 'forum_consumer_author_models.dart';
part 'forum_consumer_own_post_models.dart';
part 'forum_consumer_parsers.dart';
part 'forum_consumer_interaction_parsers.dart';
part 'forum_consumer_governance_parsers.dart';
part 'forum_consumer_my_report_parsers.dart';
part 'forum_consumer_block_parsers.dart';
part 'forum_consumer_publish_parsers.dart';
part 'forum_consumer_author_parsers.dart';
part 'forum_consumer_own_post_parsers.dart';
part 'forum_consumer_author_reads.dart';
part 'forum_consumer_item_parsers.dart';
part 'forum_consumer_support.dart';
part 'forum_consumer_actions.dart';
part 'forum_consumer_published_attachment_access_actions.dart';
part 'forum_consumer_interaction_actions.dart';
part 'forum_consumer_governance_actions.dart';
part 'forum_consumer_block_actions.dart';
part 'forum_consumer_own_post_actions.dart';

final class ForumCanonicalPaths {
  const ForumCanonicalPaths._();

  static const String feed = '/api/app/forum/feed';
  static const String topicMetadata = '/api/app/forum/topic/metadata';
  static const String topicList = '/api/app/forum/topic/list';
  static const String topicDetail = '/api/app/forum/topic/detail';
  static const String postDetail = '/api/app/forum/post/detail';
  static const String postComments = '/api/app/forum/post/comments';
  static const String postComment = '/api/app/forum/post/comment';
  static const String postLike = '/api/app/forum/post/like';
  static const String postBookmark = '/api/app/forum/post/bookmark';
  static const String authorFollow = '/api/app/forum/author/follow';
  static const String postEdit = '/api/app/forum/post/edit';
  static const String postDelete = '/api/app/forum/post/delete';
  static const String reportSubmit = '/api/app/forum/report/submit';
  static const String reportsMine = '/api/app/forum/reports/mine';
  static const String relationBlock = '/api/app/profile/block';
  static const String relationUnblock = '/api/app/profile/unblock';
  static const String relationBlockStatus = '/api/app/profile/block/status';
  static const String authorProfile = '/api/app/forum/author/profile';
  static const String authorPosts = '/api/app/forum/author/posts';
  static const String draftSave = '/api/app/forum/draft/save';
  static const String draftDetail = '/api/app/forum/draft/detail';
  static const String draftDelete = '/api/app/forum/draft/delete';
  static const String publish = '/api/app/forum/publish';
  static const String draftList = '/api/app/forum/draft/list';
  static const String search = '/api/app/forum/search';
  static const String meIndex = '/api/app/forum/me/index';
  static const String mePosts = '/api/app/forum/me/posts';
  static const String meComments = '/api/app/forum/me/comments';
  static const String meBookmarks = '/api/app/forum/me/bookmarks';
  static const String meLikes = '/api/app/forum/me/likes';
  static const String meFollows = '/api/app/forum/me/follows';
  static const String interactionInbox = '/api/app/forum/interaction/inbox';
  static const String fileAccess = '/api/app/file/access';

  static String reportMineDetail(String ticketId) {
    return '$reportsMine/${Uri.encodeComponent(ticketId)}';
  }
}

class ForumConsumerLayer {
  ForumConsumerLayer._(this._client);

  factory ForumConsumerLayer({AppApiClient? client}) {
    return ForumConsumerLayer._(client ?? AppApiClient());
  }

  static ForumConsumerLayer _instance = ForumConsumerLayer();

  static ForumConsumerLayer get instance => _instance;

  static void install(ForumConsumerLayer consumerLayer) {
    _instance = consumerLayer;
  }

  static void reset() {
    _instance = ForumConsumerLayer();
  }

  final AppApiClient _client;

  Future<ForumReadResult<ForumMeIndexView>> loadMeIndex() {
    return _loadRead(
      path: ForumCanonicalPaths.meIndex,
      parser: _parseMeIndex,
      isEmpty: (ForumMeIndexView data) =>
          data.recentTopics.isEmpty &&
          data.recentPosts.isEmpty &&
          data.recentDrafts.isEmpty,
      useProtectedSession: true,
    );
  }

  Future<ForumReadResult<ForumFeedView>> loadFeed({
    required String scope,
    String? topicId,
  }) {
    return _loadRead(
      path: ForumCanonicalPaths.feed,
      queryParameters: <String, String>{
        'scope': scope,
        if (topicId != null && topicId.trim().isNotEmpty)
          'topicId': topicId.trim(),
      },
      parser: _parseFeed,
      isEmpty: (ForumFeedView data) => data.items.isEmpty,
      useProtectedSession: true,
    );
  }

  Future<ForumReadResult<List<ForumTopicMetadataItemView>>>
  loadTopicMetadata() {
    return _loadRead(
      path: ForumCanonicalPaths.topicMetadata,
      parser: _parseTopicMetadata,
      isEmpty: (List<ForumTopicMetadataItemView> data) => data.isEmpty,
      useProtectedSession: true,
    );
  }

  Future<ForumReadResult<ForumPagedCollectionView<ForumTopicCardView>>>
  loadTopicList({String? categoryKey}) {
    return _loadRead(
      path: ForumCanonicalPaths.topicList,
      queryParameters: <String, String>{
        if (categoryKey != null && categoryKey.trim().isNotEmpty)
          'categoryKey': categoryKey.trim(),
      },
      parser: _parseTopicCollection,
      isEmpty: (ForumPagedCollectionView<ForumTopicCardView> data) =>
          data.items.isEmpty,
      useProtectedSession: true,
    );
  }

  Future<ForumReadResult<ForumTopicDetailView>> loadTopicDetail({
    required String? topicId,
  }) {
    final resolved = _requiredRouteValue(topicId);
    if (resolved == null) {
      return Future<ForumReadResult<ForumTopicDetailView>>.value(
        ForumReadResult(
          state: AppPageState.notFound,
          method: 'GET',
          path: ForumCanonicalPaths.topicDetail,
          message: forumVisibleReadMessage(
            path: ForumCanonicalPaths.topicDetail,
            state: AppPageState.notFound,
          ),
        ),
      );
    }

    return _loadRead(
      path: ForumCanonicalPaths.topicDetail,
      queryParameters: <String, String>{'topicId': resolved},
      parser: _parseTopicDetail,
      isEmpty: (_) => false,
      useProtectedSession: true,
    );
  }

  Future<ForumReadResult<ForumPostDetailView>> loadPostDetail({
    required String? postId,
  }) {
    final resolved = _requiredRouteValue(postId);
    if (resolved == null) {
      return Future<ForumReadResult<ForumPostDetailView>>.value(
        ForumReadResult(
          state: AppPageState.notFound,
          method: 'GET',
          path: ForumCanonicalPaths.postDetail,
          message: forumVisibleReadMessage(
            path: ForumCanonicalPaths.postDetail,
            state: AppPageState.notFound,
          ),
        ),
      );
    }

    return _loadRead(
      path: ForumCanonicalPaths.postDetail,
      queryParameters: <String, String>{'postId': resolved},
      parser: _parsePostDetail,
      isEmpty: (_) => false,
      useProtectedSession: true,
    );
  }

  Future<ForumReadResult<ForumPagedCollectionView<ForumCommentItemView>>>
  loadPostComments({required String? postId, String? cursor, int? pageSize}) {
    final resolved = _requiredRouteValue(postId);
    if (resolved == null) {
      return Future<
        ForumReadResult<ForumPagedCollectionView<ForumCommentItemView>>
      >.value(
        ForumReadResult(
          state: AppPageState.notFound,
          method: 'GET',
          path: ForumCanonicalPaths.postComments,
          message: forumVisibleReadMessage(
            path: ForumCanonicalPaths.postComments,
            state: AppPageState.notFound,
          ),
        ),
      );
    }

    return _loadRead(
      path: ForumCanonicalPaths.postComments,
      queryParameters: <String, String>{
        'postId': resolved,
        if (cursor != null && cursor.trim().isNotEmpty) 'cursor': cursor.trim(),
        if (pageSize != null && pageSize > 0) 'pageSize': '$pageSize',
      },
      parser: _parseCommentCollection,
      isEmpty: (ForumPagedCollectionView<ForumCommentItemView> data) =>
          data.items.isEmpty,
      useProtectedSession: true,
    );
  }

  Future<ForumReadResult<ForumPagedCollectionView<ForumDraftCardView>>>
  loadDraftList() {
    return _loadRead(
      path: ForumCanonicalPaths.draftList,
      parser: _parseDraftList,
      isEmpty: (ForumPagedCollectionView<ForumDraftCardView> data) =>
          data.items.isEmpty,
      useProtectedSession: true,
    );
  }

  Future<ForumReadResult<ForumDraftDetailView>> loadDraftDetail({
    required String? draftId,
  }) {
    final resolved = _requiredRouteValue(draftId);
    if (resolved == null) {
      return Future<ForumReadResult<ForumDraftDetailView>>.value(
        ForumReadResult(
          state: AppPageState.notFound,
          method: 'GET',
          path: ForumCanonicalPaths.draftDetail,
          message: forumVisibleReadMessage(
            path: ForumCanonicalPaths.draftDetail,
            state: AppPageState.notFound,
          ),
        ),
      );
    }

    return _loadRead(
      path: ForumCanonicalPaths.draftDetail,
      queryParameters: <String, String>{'draftId': resolved},
      parser: _parseDraftDetail,
      isEmpty: (_) => false,
      useProtectedSession: true,
    );
  }

  Future<ForumReadResult<ForumSearchView>> loadSearch({
    required String? query,
  }) {
    final resolved = _requiredRouteValue(query);
    if (resolved == null) {
      return Future<ForumReadResult<ForumSearchView>>.value(
        const ForumReadResult(
          state: AppPageState.errorNonRetryable,
          method: 'GET',
          path: ForumCanonicalPaths.search,
          message: '请输入关键词后再搜索',
        ),
      );
    }

    return _loadRead(
      path: ForumCanonicalPaths.search,
      queryParameters: <String, String>{'q': resolved},
      parser: _parseSearch,
      isEmpty: (ForumSearchView data) => data.items.isEmpty,
      useProtectedSession: true,
    );
  }

  Future<ForumReadResult<ForumPagedCollectionView<ForumMyPostItemView>>>
  loadMyPosts() {
    return _loadRead(
      path: ForumCanonicalPaths.mePosts,
      parser: _parseMyPosts,
      isEmpty: (ForumPagedCollectionView<ForumMyPostItemView> data) =>
          data.items.isEmpty,
      useProtectedSession: true,
    );
  }

  Future<ForumReadResult<ForumPagedCollectionView<ForumCommentAssetItemView>>>
  loadMyComments() {
    return _loadRead(
      path: ForumCanonicalPaths.meComments,
      parser: _parseMyComments,
      isEmpty: (ForumPagedCollectionView<ForumCommentAssetItemView> data) =>
          data.items.isEmpty,
      useProtectedSession: true,
    );
  }

  Future<ForumReadResult<ForumPagedCollectionView<ForumPostCardView>>>
  loadMyBookmarks() {
    return _loadRead(
      path: ForumCanonicalPaths.meBookmarks,
      parser: _parseMyBookmarks,
      isEmpty: (ForumPagedCollectionView<ForumPostCardView> data) =>
          data.items.isEmpty,
      useProtectedSession: true,
    );
  }

  Future<ForumReadResult<ForumPagedCollectionView<ForumPostCardView>>>
  loadMyLikes() {
    return _loadRead(
      path: ForumCanonicalPaths.meLikes,
      parser: _parseMyLikes,
      isEmpty: (ForumPagedCollectionView<ForumPostCardView> data) =>
          data.items.isEmpty,
      useProtectedSession: true,
    );
  }

  Future<ForumReadResult<ForumPagedCollectionView<ForumFollowedAuthorItemView>>>
  loadMyFollows() {
    return _loadRead(
      path: ForumCanonicalPaths.meFollows,
      parser: _parseMyFollows,
      isEmpty: (ForumPagedCollectionView<ForumFollowedAuthorItemView> data) =>
          data.items.isEmpty,
      useProtectedSession: true,
    );
  }

  Future<ForumReadResult<ForumPagedCollectionView<ForumMyReportTicketItemView>>>
  loadMyReports() {
    return _loadRead(
      path: ForumCanonicalPaths.reportsMine,
      parser: _parseMyReportTicketList,
      isEmpty: (ForumPagedCollectionView<ForumMyReportTicketItemView> data) =>
          data.items.isEmpty,
      useProtectedSession: true,
    );
  }

  Future<ForumReadResult<ForumMyReportTicketDetailView>> loadMyReportDetail({
    required String? ticketId,
  }) {
    final resolved = _requiredRouteValue(ticketId);
    if (resolved == null) {
      return Future<ForumReadResult<ForumMyReportTicketDetailView>>.value(
        ForumReadResult(
          state: AppPageState.notFound,
          method: 'GET',
          path: ForumCanonicalPaths.reportsMine,
          message: forumVisibleReadMessage(
            path: ForumCanonicalPaths.reportsMine,
            state: AppPageState.notFound,
          ),
        ),
      );
    }

    return _loadRead(
      path: ForumCanonicalPaths.reportMineDetail(resolved),
      parser: _parseMyReportTicketDetail,
      isEmpty: (_) => false,
      useProtectedSession: true,
    );
  }

  Future<
    ForumReadResult<ForumPagedCollectionView<ForumInteractionInboxItemView>>
  >
  loadInteractionInbox({required String tab}) {
    return _loadRead(
      path: ForumCanonicalPaths.interactionInbox,
      queryParameters: <String, String>{'tab': tab},
      parser: _parseInteractionInbox,
      isEmpty: (ForumPagedCollectionView<ForumInteractionInboxItemView> data) =>
          data.items.isEmpty,
      useProtectedSession: true,
    );
  }

  Future<ForumReadResult<T>> _loadRead<T>({
    required String path,
    required Object Function(Map<String, Object?> body) parser,
    required bool Function(T data) isEmpty,
    Map<String, String>? queryParameters,
    bool useProtectedSession = false,
  }) async {
    try {
      final response = await (useProtectedSession
          ? runProtectedAppRequest(
              () => _client.get(path, queryParameters: queryParameters),
            )
          : _client.get(path, queryParameters: queryParameters));
      return _mapReadResponse(response, parser: parser, isEmpty: isEmpty);
    } on SocketException {
      return _readTransportFailure(path, '读取论坛内容时网络暂不可用');
    } on HttpException {
      return _readTransportFailure(path, '当前服务暂时不可用');
    } on StateError {
      return _readTransportFailure(path, '论坛接口状态异常，请重新加载后再试');
    } on FormatException {
      return ForumReadResult<T>(
        state: AppPageState.errorNonRetryable,
        method: 'GET',
        path: path,
        message: forumVisibleReadMessage(
          path: path,
          state: AppPageState.errorNonRetryable,
        ),
      );
    }
  }

  ForumReadResult<T> _mapReadResponse<T>(
    AppApiResponse response, {
    required Object Function(Map<String, Object?> body) parser,
    required bool Function(T data) isEmpty,
  }) {
    final failure = _mapFailure(response, method: 'GET');
    if (failure != null) {
      return ForumReadResult<T>(
        state: failure.state,
        method: failure.method,
        path: failure.path,
        message: failure.message,
        errorCode: failure.errorCode,
      );
    }

    final body = _readBodyMap(response.body);
    if (body == null) {
      return ForumReadResult<T>(
        state: AppPageState.errorNonRetryable,
        method: 'GET',
        path: response.uri.path,
        message: forumVisibleReadMessage(
          path: response.uri.path,
          state: AppPageState.errorNonRetryable,
        ),
      );
    }

    final parsed = parser(body);
    if (parsed is String) {
      return ForumReadResult<T>(
        state: AppPageState.errorNonRetryable,
        method: 'GET',
        path: response.uri.path,
        message: forumVisibleReadMessage(
          path: response.uri.path,
          state: AppPageState.errorNonRetryable,
          rawMessage: parsed,
        ),
      );
    }

    final data = parsed as T;
    return ForumReadResult<T>(
      state: isEmpty(data) ? AppPageState.empty : AppPageState.content,
      method: 'GET',
      path: response.uri.path,
      data: data,
    );
  }

  ForumActionResult<T> _mapActionResponse<T>(
    AppApiResponse response, {
    required Object Function(Map<String, Object?> body) parser,
  }) {
    final failure = _mapFailure(response, method: 'POST');
    if (failure != null) {
      return ForumActionResult<T>(
        isSuccess: false,
        method: failure.method,
        path: failure.path,
        controlledState: failure.state,
        message: forumVisibleActionMessage(
          path: failure.path,
          state: failure.state,
          rawMessage: _extractMessage(response.body),
          errorCode: failure.errorCode,
        ),
        errorCode: failure.errorCode,
      );
    }

    final body = _readBodyMap(response.body);
    if (body == null) {
      return ForumActionResult<T>(
        isSuccess: false,
        method: 'POST',
        path: response.uri.path,
        controlledState: AppPageState.errorNonRetryable,
        message: forumVisibleActionMessage(
          path: response.uri.path,
          state: AppPageState.errorNonRetryable,
        ),
      );
    }

    final parsed = parser(body);
    if (parsed is String) {
      return ForumActionResult<T>(
        isSuccess: false,
        method: 'POST',
        path: response.uri.path,
        controlledState: AppPageState.errorNonRetryable,
        message: forumVisibleActionMessage(
          path: response.uri.path,
          state: AppPageState.errorNonRetryable,
          rawMessage: parsed,
        ),
      );
    }

    return ForumActionResult<T>(
      isSuccess: true,
      method: 'POST',
      path: response.uri.path,
      data: parsed as T,
    );
  }
}
