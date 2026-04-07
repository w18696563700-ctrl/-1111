part of 'forum_consumer_layer.dart';

extension ForumConsumerAuthorReads on ForumConsumerLayer {
  Future<ForumReadResult<ForumAuthorProfileView>> loadAuthorProfile({
    required String? authorId,
  }) {
    final resolved = _requiredRouteValue(authorId);
    if (resolved == null) {
      return Future<ForumReadResult<ForumAuthorProfileView>>.value(
        ForumReadResult(
          state: AppPageState.notFound,
          method: 'GET',
          path: ForumCanonicalPaths.authorProfile,
          message: forumVisibleReadMessage(
            path: ForumCanonicalPaths.authorProfile,
            state: AppPageState.notFound,
          ),
        ),
      );
    }

    return _loadRead(
      path: ForumCanonicalPaths.authorProfile,
      queryParameters: <String, String>{'authorId': resolved},
      parser: _parseAuthorProfile,
      isEmpty: (_) => false,
    );
  }

  Future<ForumReadResult<ForumPagedCollectionView<ForumPostCardView>>>
  loadAuthorPosts({
    required String? authorId,
    String? cursor,
    int? pageSize,
  }) {
    final resolved = _requiredRouteValue(authorId);
    if (resolved == null) {
      return Future<ForumReadResult<ForumPagedCollectionView<ForumPostCardView>>>.value(
        ForumReadResult(
          state: AppPageState.notFound,
          method: 'GET',
          path: ForumCanonicalPaths.authorPosts,
          message: forumVisibleReadMessage(
            path: ForumCanonicalPaths.authorPosts,
            state: AppPageState.notFound,
          ),
        ),
      );
    }

    return _loadRead(
      path: ForumCanonicalPaths.authorPosts,
      queryParameters: <String, String>{
        'authorId': resolved,
        if (cursor != null && cursor.trim().isNotEmpty) 'cursor': cursor.trim(),
        if (pageSize != null && pageSize > 0) 'pageSize': '$pageSize',
      },
      parser: _parseAuthorPosts,
      isEmpty: (ForumPagedCollectionView<ForumPostCardView> data) =>
          data.items.isEmpty,
    );
  }
}
