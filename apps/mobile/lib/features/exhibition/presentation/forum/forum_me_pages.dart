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
  ForumReadResult<ForumPagedCollectionView<ForumPostCardView>>? _likesResult;
  ForumReadResult<ForumPagedCollectionView<ForumFollowedAuthorItemView>>?
  _followsResult;
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
      ForumMeScope.likes => await ForumConsumerLayer.instance.loadMyLikes(),
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
        case ForumMeScope.likes:
          _likesResult =
              result
                  as ForumReadResult<
                    ForumPagedCollectionView<ForumPostCardView>
                  >;
        case ForumMeScope.follows:
          _followsResult =
              result
                  as ForumReadResult<
                    ForumPagedCollectionView<ForumFollowedAuthorItemView>
                  >;
      }
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = _meConfig(widget.scope);
    final cleanPostsContent =
        widget.scope == ForumMeScope.posts &&
        _activeState == AppPageState.content;
    final showLikesLoading = widget.scope == ForumMeScope.likes && _loading;
    return ForumPageFrame(
      eyebrow: '我的论坛',
      title: config.title,
      summary: config.summary,
      scopeLabel: config.scopeLabel,
      routeLabel: config.routeLabel,
      showRouteMeta: false,
      showHero: widget.scope != ForumMeScope.posts,
      heroActions: <Widget>[
        FilledButton.tonal(
          onPressed: () =>
              Navigator.of(context).pushNamed(ExhibitionRoutes.forum),
          child: const Text('回论坛容器'),
        ),
      ],
      children: <Widget>[
        if (showLikesLoading)
          const _ForumLikesLoadingPanel()
        else if (!cleanPostsContent)
          ForumReadStateCard(
            loading: _loading,
            state: _activeState,
            emptyMessage: '${config.title}当前还没有内容。',
            onRetry: _load,
            message: _activeMessage,
            errorCode: _activeErrorCode,
          ),
        if (_activeState == AppPageState.content) ...<Widget>[
          if (widget.scope == ForumMeScope.posts)
            ..._scopeChildren(context)
          else
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
      ForumMeScope.likes => _likesResult?.state,
      ForumMeScope.follows => _followsResult?.state,
    };
  }

  String? get _activeMessage {
    return switch (widget.scope) {
      ForumMeScope.posts => _postsResult?.message,
      ForumMeScope.comments => _commentsResult?.message,
      ForumMeScope.bookmarks => _bookmarksResult?.message,
      ForumMeScope.likes => _likesResult?.message,
      ForumMeScope.follows => _followsResult?.message,
    };
  }

  String? get _activeErrorCode {
    return switch (widget.scope) {
      ForumMeScope.posts => _postsResult?.errorCode,
      ForumMeScope.comments => _commentsResult?.errorCode,
      ForumMeScope.bookmarks => _bookmarksResult?.errorCode,
      ForumMeScope.likes => _likesResult?.errorCode,
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
      ForumMeScope.likes => _likeCards(
        context,
        _likesResult?.data?.items ?? const [],
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
            AppPrimaryButton(
              label: '查看帖子',
              onPressed: () => Navigator.of(
                context,
              ).pushNamed(ExhibitionRoutes.forumPostWithPostId(item.postId)),
            ),
            AppSecondaryButton(
              icon: _editingPostIds.contains(item.postId)
                  ? Icons.hourglass_top_rounded
                  : Icons.edit_outlined,
              label: item.canEdit
                  ? _editingPostIds.contains(item.postId)
                        ? '进入中'
                        : '编辑帖子'
                  : '不可编辑',
              onPressed: item.canEdit && !_editingPostIds.contains(item.postId)
                  ? () => _enterEditContinuation(item)
                  : null,
            ),
            _ForumDangerButton(
              icon: _deletingPostIds.contains(item.postId)
                  ? Icons.hourglass_top_rounded
                  : Icons.delete_outline_rounded,
              label: item.canDelete
                  ? _deletingPostIds.contains(item.postId)
                        ? '删除中'
                        : '删除帖子'
                  : '不可删除',
              onPressed:
                  item.canDelete && !_deletingPostIds.contains(item.postId)
                  ? () => _deleteOwnedPost(item)
                  : null,
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
              AppPrimaryButton(
                label: '查看原帖',
                onPressed: () => Navigator.of(
                  context,
                ).pushNamed(ExhibitionRoutes.forumPostWithPostId(item.postId)),
              ),
              AppSecondaryButton(
                label: '回评论区',
                onPressed: () => Navigator.of(context).pushNamed(
                  ExhibitionRoutes.forumCommentsWithPostId(item.postId),
                ),
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
              AppPrimaryButton(
                label: '查看帖子',
                onPressed: () => Navigator.of(
                  context,
                ).pushNamed(ExhibitionRoutes.forumPostWithPostId(item.postId)),
              ),
              AppSecondaryButton(
                label: '回话题',
                onPressed: () => Navigator.of(context).pushNamed(
                  ExhibitionRoutes.forumTopicWithTopicId(item.topicId),
                ),
              ),
            ],
          ),
        )
        .toList();
  }

  List<Widget> _likeCards(BuildContext context, List<ForumPostCardView> likes) {
    if (likes.isEmpty) {
      return const <Widget>[
        ForumPostPreviewCard(
          title: '当前没有点赞内容',
          summary: '这里暂时还没有点过赞的帖子。',
          meta: '列表：0',
        ),
      ];
    }

    return likes
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
              AppPrimaryButton(
                label: '查看帖子',
                onPressed: () => Navigator.of(
                  context,
                ).pushNamed(ExhibitionRoutes.forumPostWithPostId(item.postId)),
              ),
              AppSecondaryButton(
                label: '看作者',
                onPressed: () =>
                    _openForumAuthorProfile(context, item.author.authorId),
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
    List<ForumFollowedAuthorItemView> authors,
  ) {
    if (authors.isEmpty) {
      return <Widget>[
        const ForumPostPreviewCard(
          title: '当前没有关注内容',
          summary: '这里暂时还没有持续关注的作者。',
          meta: '可以先从帖子详情进入作者主页关注',
        ),
        AppSecondaryButton(
          label: '回论坛',
          onPressed: () =>
              Navigator.of(context).pushNamed(ExhibitionRoutes.forum),
        ),
      ];
    }

    return <Widget>[
      const ForumPostPreviewCard(
        title: '关注作者',
        summary: '这里集中查看最近关注的作者。',
        meta: '点击作者可进入公共作者主页',
      ),
      ...authors.map(
        (ForumFollowedAuthorItemView item) => _ForumActionableCard(
          title: forumDisplayActorName(item.displayName),
          summary: item.organizationName ?? '当前作者未公开机构信息',
          meta:
              '公开帖子 ${item.publicPostCount} | 公开评论 ${item.publicCommentCount}',
          footer: '关注时间：${_compactPublishedAt(item.followedAt)}',
          actions: <Widget>[
            AppPrimaryButton(
              label: '进入主页',
              onPressed: () => _openForumAuthorProfile(context, item.authorId),
            ),
            AppSecondaryButton(
              label: '去消息楼',
              onPressed: () => Navigator.of(
                context,
              ).pushNamed(AppBuilding.messages.routePath),
            ),
          ],
        ),
      ),
    ];
  }
}

class _ForumLikesLoadingPanel extends StatelessWidget {
  const _ForumLikesLoadingPanel();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      withShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const AppStatusBadge(label: '页面提示', tone: AppStatusTone.neutral),
          const SizedBox(height: 14),
          Text('正在加载', style: AppTextTokens.sectionTitle),
          const SizedBox(height: 8),
          const Text('正在同步点赞记录，请稍候', style: AppTextTokens.body),
          const SizedBox(height: 16),
          const LinearProgressIndicator(minHeight: 5),
          const SizedBox(height: 14),
          ...List<Widget>.generate(
            2,
            (int index) => Padding(
              padding: EdgeInsets.only(top: index == 0 ? 0 : 10),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F7F5),
                  borderRadius: AppVisualTokens.radiusMediumBorder,
                ),
                child: const SizedBox(height: 42, width: double.infinity),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
