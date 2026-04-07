part of 'forum_pages.dart';

class ForumTopicDetailPage extends StatefulWidget {
  const ForumTopicDetailPage({super.key, required this.topicId});

  final String? topicId;

  @override
  State<ForumTopicDetailPage> createState() => _ForumTopicDetailPageState();
}

class _ForumTopicDetailPageState extends State<ForumTopicDetailPage> {
  ForumReadResult<ForumTopicDetailView>? _result;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await ForumConsumerLayer.instance.loadTopicDetail(
      topicId: widget.topicId,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _result = result;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final resolvedTopicId = _resolvedId(
      widget.topicId,
      fallback: 'topic-preview',
    );
    final data = _result?.data;
    final showStateCard =
        _loading ||
        (_result?.state != null && _result?.state != AppPageState.content);

    return ForumPageFrame(
      eyebrow: '分类',
      title: '分类概览',
      summary: '这里集中查看这一类讨论的概览和入口。',
      scopeLabel: 'topic:$resolvedTopicId',
      routeLabel: ExhibitionRoutes.forumTopicWithTopicId(resolvedTopicId),
      showRouteMeta: false,
      children: <Widget>[
        if (showStateCard)
          ForumReadStateCard(
            loading: _loading,
            state: _result?.state,
            emptyMessage: '当前分类下还没有可见内容。',
            onRetry: _load,
            message: _result?.message,
            errorCode: _result?.errorCode,
          ),
        if (data != null && _result?.state == AppPageState.content)
          _topicSummary(context, data),
      ],
    );
  }

  Widget _topicSummary(BuildContext context, ForumTopicDetailView data) {
    final topicTitle = forumDisplayTopicLabel(
      rawLabel: data.title,
      topicId: data.topicId,
      categoryKey: data.categoryKey,
    );
    final authorName = forumDisplayActorName(data.author.displayName);
    return ForumSectionCard(
      eyebrow: '当前分类',
      title: topicTitle,
      summary: '先看这个分类，再继续进入相关帖子。',
      children: <Widget>[
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            ForumInfoPill(
              label: '# ${_topicLabel(data.categoryKey)}',
              highlighted: true,
            ),
            ForumInfoPill(label: '作者：$authorName'),
            ForumInfoPill(
              label: '最近活跃：${_compactPublishedAt(data.lastActiveAt)}',
            ),
          ],
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            ForumMetricTile(
              label: '回复',
              value: '${data.engagement.replyCount}',
              highlighted: true,
            ),
            ForumMetricTile(label: '点赞', value: '${data.engagement.likeCount}'),
            ForumMetricTile(label: '浏览', value: '${data.engagement.viewCount}'),
          ],
        ),
        ForumPostPreviewCard(
          title: '相关帖子摘要',
          summary: data.leadPostExcerpt,
          meta: '状态：${forumDisplayContentState(data.state)}',
          footer: '发布时间：${_compactPublishedAt(data.publishedAt)}',
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            FilledButton(
              onPressed: () => Navigator.of(context).pushNamed(
                ExhibitionRoutes.forumPostWithPostId(data.leadPostId),
              ),
              child: const Text('查看相关帖子'),
            ),
            FilledButton.tonal(
              onPressed: () => Navigator.of(context).pushNamed(
                _routeForScope(_scopeForCategoryKey(data.categoryKey)),
              ),
              child: const Text('回同类列表'),
            ),
          ],
        ),
      ],
    );
  }
}

class ForumPostDetailPage extends StatefulWidget {
  const ForumPostDetailPage({super.key, required this.postId});

  final String? postId;

  @override
  State<ForumPostDetailPage> createState() => _ForumPostDetailPageState();
}

class _ForumPostDetailPageState extends State<ForumPostDetailPage> {
  final TextEditingController _inlineCommentController =
      TextEditingController();
  final FocusNode _inlineCommentFocusNode = FocusNode();
  ForumReadResult<ForumPostDetailView>? _detailResult;
  ForumReadResult<ForumPagedCollectionView<ForumCommentItemView>>?
  _commentResult;
  bool? _viewerHasLikedOverride;
  bool? _viewerHasBookmarkedOverride;
  bool _loading = true;
  bool _likePending = false;
  bool _bookmarkPending = false;
  bool _inlineCommentVisible = false;
  bool _inlineCommentSubmitting = false;
  final Set<String> _openingAttachmentAssetIds = <String>{};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _inlineCommentController.dispose();
    _inlineCommentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait<Object>(<Future<Object>>[
      ForumConsumerLayer.instance.loadPostDetail(postId: widget.postId),
      ForumConsumerLayer.instance.loadPostComments(postId: widget.postId),
    ]);
    if (!mounted) {
      return;
    }
    setState(() {
      _detailResult = results[0] as ForumReadResult<ForumPostDetailView>;
      _commentResult =
          results[1]
              as ForumReadResult<
                ForumPagedCollectionView<ForumCommentItemView>
              >;
      final detail = _detailResult?.data;
      if (detail?.viewerHasLiked != null) {
        _viewerHasLikedOverride = detail!.viewerHasLiked;
      }
      if (detail?.viewerHasBookmarked != null) {
        _viewerHasBookmarkedOverride = detail!.viewerHasBookmarked;
      }
      _loading = false;
    });
  }

  Future<void> _reloadDetailAfterInteraction({
    required String pendingMessage,
    required Future<ForumActionResult<ForumToggleAcceptedView>> Function()
    action,
    required void Function(bool value) setPending,
    required void Function(ForumToggleAcceptedView result) applyAcceptedResult,
    required String Function(ForumToggleAcceptedView result) successMessage,
  }) async {
    setState(() => setPending(true));
    final result = await action();
    if (!mounted) {
      return;
    }
    if (!result.isSuccess) {
      setState(() => setPending(false));
      _showActionMessage(context, result.message);
      return;
    }

    final acceptedResult = result.data;
    if (acceptedResult != null) {
      setState(() => applyAcceptedResult(acceptedResult));
      _showActionMessage(context, successMessage(acceptedResult));
    }

    final refreshed = await ForumConsumerLayer.instance.loadPostDetail(
      postId: widget.postId,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _detailResult = refreshed;
      final detail = refreshed.data;
      if (detail?.viewerHasLiked != null) {
        _viewerHasLikedOverride = detail!.viewerHasLiked;
      }
      if (detail?.viewerHasBookmarked != null) {
        _viewerHasBookmarkedOverride = detail!.viewerHasBookmarked;
      }
      setPending(false);
    });
    if (refreshed.state != AppPageState.content) {
      _showActionMessage(context, pendingMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = _detailResult?.data;
    final comments =
        _commentResult?.data?.items ?? const <ForumCommentItemView>[];
    final isOwner = detail != null && _isOwnedForumPost(context, detail.author);
    final effectiveViewerHasLiked = detail == null
        ? false
        : _effectiveViewerHasLiked(detail);
    final effectiveViewerHasBookmarked = detail == null
        ? false
        : _effectiveViewerHasBookmarked(detail);
    final topicTitle = detail == null
        ? '论坛分类'
        : forumDisplayTopicLabel(
            rawLabel: detail.topicTitle,
            topicId: detail.topicId,
          );
    final showStateCard =
        _loading ||
        (_detailResult?.state != null &&
            _detailResult?.state != AppPageState.content);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: <Widget>[
        if (showStateCard)
          ForumReadStateCard(
            loading: _loading,
            state: _detailResult?.state,
            emptyMessage: '当前帖子暂时还没有可见内容。',
            onRetry: _load,
            message: _detailResult?.message,
            errorCode: _detailResult?.errorCode,
          )
        else if (detail != null) ...<Widget>[
          _ForumDetailHero(
            topicLabel: topicTitle,
            author: detail.author,
            publishedAt: _compactPublishedAt(detail.publishedAt),
            viewerFollowsTopic: detail.viewerFollowsTopic == true,
            onOpenAuthor: () =>
                _openForumAuthorProfile(context, detail.author.authorId),
          ),
          const SizedBox(height: 24),
          _ForumDetailBodySection(
            content: detail.content,
            stateLabel: forumDisplayContentState(detail.state),
          ),
          if (isOwner) ...<Widget>[
            const SizedBox(height: 18),
            ForumSectionCard(
              eyebrow: '管理入口',
              title: '回我的帖子管理',
              summary: '帖子编辑与删除请在“我的楼 / 我的帖子”里完成，避免在公域展示页误触。',
              children: <Widget>[
                FilledButton.tonal(
                  onPressed: () => Navigator.of(
                    context,
                  ).pushNamed(ExhibitionRoutes.forumMePosts),
                  child: const Text('进入我的帖子'),
                ),
              ],
            ),
          ],
          if (detail.attachmentRefs.isNotEmpty) ...<Widget>[
            const SizedBox(height: 22),
            const _ForumDetailSectionHeading(
              title: '附件',
              summary: '点击图片或视频可预览，文档文件可下载。',
            ),
            const SizedBox(height: 12),
            ...detail.attachmentRefs.map(
              (ForumAttachmentRefView item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ForumDetailAttachmentRow(
                  item: item,
                  actionLabel: _attachmentActionLabel(item.mimeType),
                  loading: _openingAttachmentAssetIds.contains(
                    item.fileAssetId,
                  ),
                  onTap: () => _openAttachment(item),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          _ForumDetailActionBar(
            viewerHasLiked: effectiveViewerHasLiked,
            viewerHasBookmarked: effectiveViewerHasBookmarked,
            likePending: _likePending,
            bookmarkPending: _bookmarkPending,
            onLike: _likePending
                ? () {}
                : () => _toggleLike(effectiveViewerHasLiked),
            onBookmark: _bookmarkPending
                ? () {}
                : () => _toggleBookmark(effectiveViewerHasBookmarked),
            onReply: () => _openInlineComments(detail.postId),
          ),
          if (_inlineCommentVisible) ...<Widget>[
            const SizedBox(height: 14),
            ForumSectionCard(
              eyebrow: '评论输入',
              title: '写评论',
              summary: '输入后直接发送，不再跳转新页面。',
              children: <Widget>[
                TextField(
                  controller: _inlineCommentController,
                  focusNode: _inlineCommentFocusNode,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: '说说你的看法（支持中文）',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: _inlineCommentSubmitting
                        ? null
                        : () => _submitInlineComment(detail.postId),
                    icon: const Icon(Icons.send_rounded),
                    label: Text(_inlineCommentSubmitting ? '发送中' : '发送'),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _showForumReportSheet(
                context,
                target: _ForumReportTarget(
                  targetType: 'post',
                  targetId: detail.postId,
                  sheetTitle: '举报帖子',
                ),
              ),
              icon: const Icon(Icons.flag_outlined, size: 18),
              label: const Text('举报帖子'),
            ),
          ),
          const SizedBox(height: 24),
          _buildForumCommentPreview(
            context: context,
            detail: detail,
            comments: comments,
            loading: _loading,
            commentResult: _commentResult,
            onRetry: _load,
          ),
        ],
      ],
    );
  }

  void _openInlineComments(String postId) {
    if (_inlineCommentVisible) {
      _inlineCommentFocusNode.requestFocus();
      return;
    }
    setState(() => _inlineCommentVisible = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _inlineCommentFocusNode.requestFocus();
      }
    });
  }

  Future<void> _submitInlineComment(String postId) async {
    if (_inlineCommentSubmitting) {
      return;
    }
    final body = _inlineCommentController.text.trim();
    if (body.isEmpty) {
      _showActionMessage(context, '请先输入评论内容');
      return;
    }

    setState(() => _inlineCommentSubmitting = true);
    final result = await ForumConsumerLayer.instance.submitComment(
      postId: postId,
      body: body,
    );
    if (!mounted) {
      return;
    }
    if (!result.isSuccess) {
      setState(() => _inlineCommentSubmitting = false);
      _showActionMessage(context, result.message);
      return;
    }

    _inlineCommentController.clear();
    await _load();
    if (!mounted) {
      return;
    }
    setState(() => _inlineCommentSubmitting = false);
    _showActionMessage(context, '评论已发送');
  }

  Future<void> _openAttachment(ForumAttachmentRefView item) async {
    if (_openingAttachmentAssetIds.contains(item.fileAssetId)) {
      return;
    }
    setState(() => _openingAttachmentAssetIds.add(item.fileAssetId));
    final mode = _fileAccessModeForAttachment(item.mimeType);
    final accessResult = await ForumConsumerLayer.instance.requestFileAccess(
      fileAssetId: item.fileAssetId,
      mode: mode,
    );
    if (!mounted) {
      return;
    }
    if (!accessResult.isSuccess || accessResult.data == null) {
      setState(() => _openingAttachmentAssetIds.remove(item.fileAssetId));
      _showActionMessage(context, accessResult.message);
      return;
    }

    final access = accessResult.data!;
    if (_isImageAttachment(item.mimeType)) {
      setState(() => _openingAttachmentAssetIds.remove(item.fileAssetId));
      await _openImagePreview(access: access, attachment: item);
      return;
    }

    setState(() => _openingAttachmentAssetIds.remove(item.fileAssetId));
    final opened = await _openExternalAccessUrl(access.accessUrl);
    if (!mounted) {
      return;
    }
    if (opened) {
      _showActionMessage(
        context,
        _isVideoAttachment(item.mimeType) ? '已打开视频预览' : '已交给系统处理下载',
      );
      return;
    }
    await _showAttachmentAccessSheet(attachment: item, access: access);
  }

  Future<void> _openImagePreview({
    required ForumFileAccessView access,
    required ForumAttachmentRefView attachment,
  }) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560, maxHeight: 620),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '图片预览',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    attachment.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: InteractiveViewer(
                          child: Image.network(
                            access.accessUrl,
                            fit: BoxFit.contain,
                            loadingBuilder:
                                (
                                  BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress,
                                ) {
                                  if (loadingProgress == null) {
                                    return child;
                                  }
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                            errorBuilder:
                                (
                                  BuildContext context,
                                  Object error,
                                  StackTrace? stackTrace,
                                ) {
                                  return Center(
                                    child: Text(
                                      '当前图片暂时无法预览，请稍后再试',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  );
                                },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('关闭'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAttachmentAccessSheet({
    required ForumAttachmentRefView attachment,
    required ForumFileAccessView access,
  }) async {
    final isVideo = _isVideoAttachment(attachment.mimeType);
    final actionLabel = isVideo ? '视频预览' : '文件下载';
    final primaryActionLabel = isVideo ? '在系统中打开预览' : '在系统中下载文件';
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '$actionLabel链接',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '当前设备暂不能直接打开，已为你准备好真实访问链接。',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                ),
                const SizedBox(height: 10),
                SelectableText(
                  access.accessUrl,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      child: const Text('关闭'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () async {
                        final navigator = Navigator.of(sheetContext);
                        final opened = await _openExternalAccessUrl(
                          access.accessUrl,
                        );
                        if (navigator.canPop()) {
                          navigator.pop();
                        }
                        if (!mounted) {
                          return;
                        }
                        if (opened) {
                          _showActionMessage(
                            context,
                            isVideo ? '已打开视频预览' : '已交给系统处理下载',
                          );
                        } else {
                          _showActionMessage(
                            context,
                            '$actionLabel链接已准备好，可复制后在系统浏览器打开',
                          );
                        }
                      },
                      child: Text(primaryActionLabel),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.tonal(
                      onPressed: () async {
                        final navigator = Navigator.of(sheetContext);
                        await Clipboard.setData(
                          ClipboardData(text: access.accessUrl),
                        );
                        if (navigator.canPop()) {
                          navigator.pop();
                        }
                      },
                      child: const Text('复制链接'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> _openExternalAccessUrl(String accessUrl) async {
    final uri = Uri.tryParse(accessUrl);
    if (uri == null || uri.scheme.isEmpty) {
      return false;
    }
    final override = ForumDetailAttachmentDebugOverrides.externalUrlOpener;
    if (override != null) {
      return override(uri);
    }

    try {
      if (Platform.isMacOS) {
        final result = await Process.run('open', <String>[uri.toString()]);
        return result.exitCode == 0;
      }
      if (Platform.isLinux) {
        final result = await Process.run('xdg-open', <String>[uri.toString()]);
        return result.exitCode == 0;
      }
      if (Platform.isWindows) {
        final result = await Process.run('cmd', <String>[
          '/c',
          'start',
          '',
          uri.toString(),
        ]);
        return result.exitCode == 0;
      }
    } on ProcessException {
      return false;
    }
    return false;
  }

  String _fileAccessModeForAttachment(String mimeType) {
    return _isImageAttachment(mimeType) || _isVideoAttachment(mimeType)
        ? 'preview'
        : 'download';
  }

  String _attachmentActionLabel(String mimeType) {
    if (_isImageAttachment(mimeType)) {
      return '预览';
    }
    if (_isVideoAttachment(mimeType)) {
      return '预览';
    }
    return '下载';
  }

  bool _isImageAttachment(String mimeType) => mimeType.startsWith('image/');

  bool _isVideoAttachment(String mimeType) => mimeType.startsWith('video/');

  Future<void> _toggleLike(bool currentlyLiked) {
    return _reloadDetailAfterInteraction(
      pendingMessage: '点赞结果已提交，请稍后刷新查看',
      action: () => ForumConsumerLayer.instance.togglePostLike(
        postId: widget.postId,
        currentlyLiked: currentlyLiked,
      ),
      setPending: (bool value) => _likePending = value,
      applyAcceptedResult: (ForumToggleAcceptedView result) {
        _viewerHasLikedOverride = _resolveAcceptedLikeState(
          result,
          fallback: !currentlyLiked,
        );
      },
      successMessage: (ForumToggleAcceptedView result) {
        final liked = _resolveAcceptedLikeState(
          result,
          fallback: !currentlyLiked,
        );
        return liked ? '已点赞' : '已取消点赞';
      },
    );
  }

  Future<void> _toggleBookmark(bool currentlyBookmarked) {
    return _reloadDetailAfterInteraction(
      pendingMessage: '收藏结果已提交，请稍后刷新查看',
      action: () => ForumConsumerLayer.instance.togglePostBookmark(
        postId: widget.postId,
        currentlyBookmarked: currentlyBookmarked,
      ),
      setPending: (bool value) => _bookmarkPending = value,
      applyAcceptedResult: (ForumToggleAcceptedView result) {
        _viewerHasBookmarkedOverride = _resolveAcceptedBookmarkState(
          result,
          fallback: !currentlyBookmarked,
        );
      },
      successMessage: (ForumToggleAcceptedView result) {
        final bookmarked = _resolveAcceptedBookmarkState(
          result,
          fallback: !currentlyBookmarked,
        );
        return bookmarked ? '已收藏' : '已取消收藏';
      },
    );
  }

  bool _effectiveViewerHasLiked(ForumPostDetailView detail) {
    return _viewerHasLikedOverride ?? detail.viewerHasLiked == true;
  }

  bool _effectiveViewerHasBookmarked(ForumPostDetailView detail) {
    return _viewerHasBookmarkedOverride ?? detail.viewerHasBookmarked == true;
  }

  bool _resolveAcceptedLikeState(
    ForumToggleAcceptedView result, {
    required bool fallback,
  }) {
    final viewerState = result.viewerHasLiked;
    if (viewerState != null) {
      return viewerState;
    }
    return switch (result.state) {
      'liked' => true,
      'unliked' => false,
      _ => fallback,
    };
  }

  bool _resolveAcceptedBookmarkState(
    ForumToggleAcceptedView result, {
    required bool fallback,
  }) {
    final viewerState = result.viewerHasBookmarked;
    if (viewerState != null) {
      return viewerState;
    }
    return switch (result.state) {
      'bookmarked' => true,
      'unbookmarked' => false,
      _ => fallback,
    };
  }

  void _showActionMessage(BuildContext context, String? message) {
    final visible = message?.trim();
    if (visible == null || visible.isEmpty) {
      return;
    }
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(SnackBar(content: Text(visible)));
  }
}
