part of 'forum_pages.dart';

class ForumMeCollectionPage extends StatefulWidget {
  const ForumMeCollectionPage({super.key, required this.scope});

  final ForumMeScope scope;

  @override
  State<ForumMeCollectionPage> createState() => _ForumMeCollectionPageState();
}

class _ForumMeCollectionPageState extends State<ForumMeCollectionPage> {
  ForumReadResult<ForumPagedCollectionView<ForumMyPostItemView>>? _postsResult;
  ForumReadResult<ForumPagedCollectionView<ForumCommentAssetItemView>>?
  _commentsResult;
  ForumReadResult<ForumPagedCollectionView<ForumPostCardView>>?
  _bookmarksResult;
  ForumReadResult<ForumPagedCollectionView<ForumTopicCardView>>? _followsResult;
  final Set<String> _editingPostIds = <String>{};
  final Set<String> _deletingPostIds = <String>{};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = switch (widget.scope) {
      ForumMeScope.posts => await ForumConsumerLayer.instance.loadMyPosts(),
      ForumMeScope.comments =>
        await ForumConsumerLayer.instance.loadMyComments(),
      ForumMeScope.bookmarks =>
        await ForumConsumerLayer.instance.loadMyBookmarks(),
      ForumMeScope.follows => await ForumConsumerLayer.instance.loadMyFollows(),
    };
    if (!mounted) {
      return;
    }
    setState(() {
      switch (widget.scope) {
        case ForumMeScope.posts:
          _postsResult =
              result
                  as ForumReadResult<
                    ForumPagedCollectionView<ForumMyPostItemView>
                  >;
        case ForumMeScope.comments:
          _commentsResult =
              result
                  as ForumReadResult<
                    ForumPagedCollectionView<ForumCommentAssetItemView>
                  >;
        case ForumMeScope.bookmarks:
          _bookmarksResult =
              result
                  as ForumReadResult<
                    ForumPagedCollectionView<ForumPostCardView>
                  >;
        case ForumMeScope.follows:
          _followsResult =
              result
                  as ForumReadResult<
                    ForumPagedCollectionView<ForumTopicCardView>
                  >;
      }
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = _meConfig(widget.scope);
    return ForumPageFrame(
      eyebrow: '我的论坛',
      title: config.title,
      summary: config.summary,
      scopeLabel: config.scopeLabel,
      routeLabel: config.routeLabel,
      showRouteMeta: false,
      heroActions: <Widget>[
        FilledButton.tonal(
          onPressed: () =>
              Navigator.of(context).pushNamed(ExhibitionRoutes.forum),
          child: const Text('回论坛容器'),
        ),
      ],
      children: <Widget>[
        ForumReadStateCard(
          loading: _loading,
          state: _activeState,
          emptyMessage: '${config.title}当前还没有内容。',
          onRetry: _load,
          message: _activeMessage,
          errorCode: _activeErrorCode,
        ),
        if (_activeState == AppPageState.content) ...<Widget>[
          ForumSectionCard(
            eyebrow: '资产列表',
            title: config.listTitle,
            summary: config.listSummary,
            children: _scopeChildren(context),
          ),
        ],
      ],
    );
  }

  AppPageState? get _activeState {
    return switch (widget.scope) {
      ForumMeScope.posts => _postsResult?.state,
      ForumMeScope.comments => _commentsResult?.state,
      ForumMeScope.bookmarks => _bookmarksResult?.state,
      ForumMeScope.follows => _followsResult?.state,
    };
  }

  String? get _activeMessage {
    return switch (widget.scope) {
      ForumMeScope.posts => _postsResult?.message,
      ForumMeScope.comments => _commentsResult?.message,
      ForumMeScope.bookmarks => _bookmarksResult?.message,
      ForumMeScope.follows => _followsResult?.message,
    };
  }

  String? get _activeErrorCode {
    return switch (widget.scope) {
      ForumMeScope.posts => _postsResult?.errorCode,
      ForumMeScope.comments => _commentsResult?.errorCode,
      ForumMeScope.bookmarks => _bookmarksResult?.errorCode,
      ForumMeScope.follows => _followsResult?.errorCode,
    };
  }

  List<Widget> _scopeChildren(BuildContext context) {
    return switch (widget.scope) {
      ForumMeScope.posts => _postCards(
        context,
        _postsResult?.data?.items ?? const [],
      ),
      ForumMeScope.comments => _commentCards(
        context,
        _commentsResult?.data?.items ?? const [],
      ),
      ForumMeScope.bookmarks => _bookmarkCards(
        context,
        _bookmarksResult?.data?.items ?? const [],
      ),
      ForumMeScope.follows => _followCards(
        context,
        _followsResult?.data?.items ?? const [],
      ),
    };
  }

  List<Widget> _postCards(
    BuildContext context,
    List<ForumMyPostItemView> posts,
  ) {
    final activePosts = posts
        .where((ForumMyPostItemView item) => item.state != 'archived')
        .toList(growable: false);

    if (activePosts.isEmpty) {
      return const <Widget>[
        ForumPostPreviewCard(
          title: '当前没有已发布帖子',
          summary: '这里暂时还没有仍在公开面可见的帖子。',
          meta: '列表：0',
        ),
      ];
    }

    return <Widget>[
      ...activePosts.map(
        (ForumMyPostItemView item) => _ForumActionableCard(
          title: item.title,
          summary: item.excerpt,
          meta:
              '分类：${forumDisplayTopicLabel(rawLabel: item.topicTitle, topicId: item.topicId)} | 状态：${forumDisplayContentState(item.state)}',
          footer:
              '发布时间：${_compactPublishedAt(item.publishedAt)} | 最近更新：${_compactPublishedAt(item.updatedAt)}',
          actions: <Widget>[
            FilledButton(
              onPressed: () => Navigator.of(
                context,
              ).pushNamed(ExhibitionRoutes.forumPostWithPostId(item.postId)),
              child: const Text('查看帖子'),
            ),
            FilledButton.icon(
              onPressed: item.canEdit && !_editingPostIds.contains(item.postId)
                  ? () => _enterEditContinuation(item)
                  : null,
              icon: Icon(
                _editingPostIds.contains(item.postId)
                    ? Icons.hourglass_top_rounded
                    : Icons.edit_outlined,
              ),
              label: Text(
                item.canEdit
                    ? _editingPostIds.contains(item.postId)
                          ? '进入中'
                          : '编辑帖子'
                    : '不可编辑',
              ),
            ),
            FilledButton.tonalIcon(
              onPressed:
                  item.canDelete && !_deletingPostIds.contains(item.postId)
                  ? () => _deleteOwnedPost(item)
                  : null,
              icon: Icon(
                _deletingPostIds.contains(item.postId)
                    ? Icons.hourglass_top_rounded
                    : Icons.delete_outline_rounded,
              ),
              label: Text(
                item.canDelete
                    ? _deletingPostIds.contains(item.postId)
                          ? '删除中'
                          : '删除帖子'
                    : '不可删除',
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _commentCards(
    BuildContext context,
    List<ForumCommentAssetItemView> comments,
  ) {
    if (comments.isEmpty) {
      return <Widget>[
        ForumPostPreviewCard(
          title: '当前没有评论内容',
          summary: '这里暂时还没有可继续查看的评论。',
          meta: '列表：0',
        ),
      ];
    }

    return comments
        .map(
          (ForumCommentAssetItemView item) => _ForumActionableCard(
            title: item.postTitle,
            summary: item.comment.body,
            meta:
                '评论时间：${_compactPublishedAt(item.comment.publishedAt)} | ${item.comment.replyCount} 条后续回复',
            footer:
                '所属话题：${forumDisplayTopicLabel(rawLabel: item.topicLabel, topicId: item.topicId)}',
            actions: <Widget>[
              FilledButton(
                onPressed: () => Navigator.of(
                  context,
                ).pushNamed(ExhibitionRoutes.forumPostWithPostId(item.postId)),
                child: const Text('查看原帖'),
              ),
              FilledButton.tonal(
                onPressed: () => Navigator.of(context).pushNamed(
                  ExhibitionRoutes.forumCommentsWithPostId(item.postId),
                ),
                child: const Text('回评论区'),
              ),
            ],
          ),
        )
        .toList();
  }

  List<Widget> _bookmarkCards(
    BuildContext context,
    List<ForumPostCardView> bookmarks,
  ) {
    if (bookmarks.isEmpty) {
      return const <Widget>[
        ForumPostPreviewCard(
          title: '当前没有收藏内容',
          summary: '这里暂时还没有已收藏的帖子。',
          meta: '列表：0',
        ),
      ];
    }

    return bookmarks
        .map(
          (ForumPostCardView item) => _ForumActionableCard(
            title: forumDisplayTopicLabel(
              rawLabel: item.topicTitle,
              topicId: item.topicId,
            ),
            summary: item.excerpt,
            meta:
                '发布时间：${_compactPublishedAt(item.publishedAt)} | 状态：${forumDisplayContentState(item.state)}',
            footer: '作者：${forumDisplayActorName(item.author.displayName)}',
            actions: <Widget>[
              FilledButton(
                onPressed: () => Navigator.of(
                  context,
                ).pushNamed(ExhibitionRoutes.forumPostWithPostId(item.postId)),
                child: const Text('查看帖子'),
              ),
              FilledButton.tonal(
                onPressed: () => Navigator.of(context).pushNamed(
                  ExhibitionRoutes.forumTopicWithTopicId(item.topicId),
                ),
                child: const Text('回话题'),
              ),
            ],
          ),
        )
        .toList();
  }

  Future<void> _enterEditContinuation(ForumMyPostItemView item) async {
    setState(() => _editingPostIds.add(item.postId));
    final result = await ForumConsumerLayer.instance.enterPostEdit(
      postId: item.postId,
    );
    if (!mounted) {
      return;
    }
    setState(() => _editingPostIds.remove(item.postId));
    if (!result.isSuccess || result.data == null) {
      _showOwnPostMessage(result.message);
      return;
    }

    _showOwnPostMessage(result.data!.message);
    await Navigator.of(
      context,
    ).pushNamed(ExhibitionRoutes.forumPublishWithDraftId(result.data!.draftId));
    if (!mounted) {
      return;
    }
    _load();
  }

  Future<void> _deleteOwnedPost(ForumMyPostItemView item) async {
    final confirmed = await _confirmForumPostDelete(context);
    if (!confirmed || !mounted) {
      return;
    }

    setState(() => _deletingPostIds.add(item.postId));
    final result = await ForumConsumerLayer.instance.deletePost(
      postId: item.postId,
    );
    if (!mounted) {
      return;
    }
    setState(() => _deletingPostIds.remove(item.postId));
    _showOwnPostMessage(result.data?.message ?? result.message);
    if (result.isSuccess) {
      _load();
    }
  }

  void _showOwnPostMessage(String? message) {
    final visible = message?.trim();
    if (visible == null || visible.isEmpty) {
      return;
    }
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(SnackBar(content: Text(visible)));
  }

  List<Widget> _followCards(
    BuildContext context,
    List<ForumTopicCardView> topics,
  ) {
    if (topics.isEmpty) {
      return <Widget>[
        const ForumPostPreviewCard(
          title: '当前没有关注内容',
          summary: '这里暂时还没有可继续查看的话题。',
          meta: '可以先回关注流看看',
        ),
        FilledButton.tonal(
          onPressed: () =>
              Navigator.of(context).pushNamed(ExhibitionRoutes.forumFollowing),
          child: const Text('回关注流'),
        ),
      ];
    }

    return <Widget>[
      const ForumPostPreviewCard(
        title: '关注入口',
        summary: '这里集中查看最近关注的话题。',
        meta: '可以继续回到关注流',
      ),
      ..._topicCards(context, topics, includeFollowingAction: true),
    ];
  }

  List<Widget> _topicCards(
    BuildContext context,
    List<ForumTopicCardView> topics, {
    bool includeFollowingAction = false,
  }) {
    if (topics.isEmpty) {
      return const <Widget>[];
    }

    return topics
        .map(
          (ForumTopicCardView item) => _ForumActionableCard(
            title: forumDisplayTopicLabel(
              rawLabel: item.title,
              topicId: item.topicId,
              categoryKey: item.categoryKey,
            ),
            summary: forumDisplayTopicDescription(
              rawDescription: item.excerpt,
              rawLabel: item.title,
              topicId: item.topicId,
              categoryKey: item.categoryKey,
            ),
            meta:
                '分类：${_topicLabel(item.categoryKey)} | 回复：${item.engagement.replyCount} | 最近活跃：${_compactPublishedAt(item.lastActiveAt)}',
            footer: '作者：${forumDisplayActorName(item.author.displayName)}',
            actions: <Widget>[
              FilledButton(
                onPressed: () => Navigator.of(context).pushNamed(
                  ExhibitionRoutes.forumTopicWithTopicId(item.topicId),
                ),
                child: const Text('查看话题'),
              ),
              if (includeFollowingAction)
                FilledButton.tonal(
                  onPressed: () => Navigator.of(
                    context,
                  ).pushNamed(ExhibitionRoutes.forumFollowing),
                  child: const Text('回关注流'),
                ),
            ],
          ),
        )
        .toList();
  }
}
