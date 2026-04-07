part of 'forum_pages.dart';

void _openForumAuthorProfile(BuildContext context, String? authorId) {
  final resolved = authorId?.trim();
  if (resolved == null || resolved.isEmpty) {
    return;
  }
  Navigator.of(
    context,
  ).pushNamed(ExhibitionRoutes.forumAuthorWithAuthorId(resolved));
}

class ForumAuthorProfilePage extends StatefulWidget {
  const ForumAuthorProfilePage({super.key, required this.authorId});

  final String? authorId;

  @override
  State<ForumAuthorProfilePage> createState() => _ForumAuthorProfilePageState();
}

class _ForumAuthorProfilePageState extends State<ForumAuthorProfilePage> {
  ForumReadResult<ForumAuthorProfileView>? _profileResult;
  ForumReadResult<ForumPagedCollectionView<ForumPostCardView>>? _postsResult;
  ForumReadResult<ForumBlockRelationStatusView>? _blockStatusResult;
  bool _loading = true;
  bool _blockActionPending = false;
  String? _blockActionMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait<Object>(<Future<Object>>[
      ForumConsumerLayer.instance.loadAuthorProfile(authorId: widget.authorId),
      ForumConsumerLayer.instance.loadAuthorPosts(authorId: widget.authorId),
    ]);
    if (!mounted) {
      return;
    }
    final profileResult = results[0] as ForumReadResult<ForumAuthorProfileView>;
    final blockStatusResult = await _loadBlockStatusForProfile(
      profileResult.data,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _profileResult = profileResult;
      _postsResult =
          results[1]
              as ForumReadResult<ForumPagedCollectionView<ForumPostCardView>>;
      _blockStatusResult = blockStatusResult;
      _blockActionMessage = null;
      _loading = false;
    });
  }

  Future<ForumReadResult<ForumBlockRelationStatusView>?>
  _loadBlockStatusForProfile(ForumAuthorProfileView? profile) {
    if (profile == null || _isCurrentActor(profile)) {
      return Future<ForumReadResult<ForumBlockRelationStatusView>?>.value();
    }
    return ForumConsumerLayer.instance.loadBlockStatus(
      targetUserId: profile.authorId,
    );
  }

  bool _isCurrentActor(ForumAuthorProfileView profile) {
    final shellUserId = AppShellScope.read(
      context,
    ).snapshot.shellContext.userId?.trim();
    return shellUserId != null &&
        shellUserId.isNotEmpty &&
        shellUserId == profile.authorId;
  }

  Future<void> _setBlockRelation({
    required ForumBlockRelationStatusView status,
    required bool shouldBlock,
  }) async {
    if (_blockActionPending) {
      return;
    }
    setState(() {
      _blockActionPending = true;
      _blockActionMessage = null;
    });

    final actionResult = shouldBlock
        ? await ForumConsumerLayer.instance.blockUser(
            targetUserId: status.targetUserId,
          )
        : await ForumConsumerLayer.instance.unblockUser(
            targetUserId: status.targetUserId,
          );
    if (!mounted) {
      return;
    }
    if (!actionResult.isSuccess) {
      setState(() {
        _blockActionPending = false;
        _blockActionMessage = actionResult.message;
      });
      return;
    }

    final refreshed = await ForumConsumerLayer.instance.loadBlockStatus(
      targetUserId: status.targetUserId,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _blockStatusResult = refreshed;
      _blockActionPending = false;
      _blockActionMessage =
          actionResult.data?.message ?? (shouldBlock ? '已提交拉黑请求' : '已提交解除拉黑请求');
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profileResult?.data;
    final posts = _postsResult?.data?.items ?? const <ForumPostCardView>[];
    final visibleName = forumDisplayActorName(profile?.displayName);
    final isCurrentActor = profile != null && _isCurrentActor(profile);

    return ForumPageFrame(
      eyebrow: '公共作者主页',
      title: '作者主页',
      summary: '这里集中展示作者的公开资料和公开帖子，不承接我的私有资产。',
      scopeLabel: 'forum-author',
      routeLabel: ExhibitionRoutes.forumAuthorWithAuthorId(
        _resolvedId(widget.authorId, fallback: 'author-preview'),
      ),
      showRouteMeta: false,
      heroActions: isCurrentActor
          ? <Widget>[
              FilledButton.tonal(
                onPressed: () => Navigator.of(
                  context,
                ).pushNamed(AppBuilding.profile.routePath),
                child: const Text('进入我的楼'),
              ),
            ]
          : const <Widget>[],
      children: <Widget>[
        if (_loading ||
            (_profileResult?.state != null &&
                _profileResult?.state != AppPageState.content))
          ForumReadStateCard(
            loading: _loading,
            state: _profileResult?.state,
            emptyMessage: '当前作者暂未公开资料',
            onRetry: _load,
            message: _profileResult?.message,
            errorCode: _profileResult?.errorCode,
          )
        else if (profile != null)
          _ForumAuthorSummaryCard(
            visibleName: visibleName,
            avatarUrl: profile.avatarUrl,
            organizationName: forumDisplayOrganizationName(
              profile.organizationName,
            ),
            publicPostCount: profile.publicPostCount,
            publicCommentCount: profile.publicCommentCount,
          ),
        if (profile != null && !isCurrentActor) ...<Widget>[
          const SizedBox(height: 14),
          _ForumBlockRelationControlCard(
            result: _blockStatusResult,
            actionPending: _blockActionPending,
            actionMessage: _blockActionMessage,
            onRetry: () async {
              final refreshed = await _loadBlockStatusForProfile(profile);
              if (!mounted) {
                return;
              }
              setState(() => _blockStatusResult = refreshed);
            },
            onToggle: (ForumBlockRelationStatusView status) =>
                _setBlockRelation(
                  status: status,
                  shouldBlock: !status.isBlocked,
                ),
          ),
        ],
        ForumSectionCard(
          eyebrow: '公开帖子',
          title: '作者公开帖子',
          summary: profile == null
              ? '当前作者公开内容暂不可用。'
              : '这里继续显示 $visibleName 当前公开可见的帖子。',
          children: <Widget>[
            if (_loading)
              const ForumSlimStatePanel(
                loading: true,
                state: AppPageState.loading,
                emptyMessage: '正在加载公开帖子',
                onRetry: _noop,
              )
            else if (_postsResult?.state != AppPageState.content)
              ForumSlimStatePanel(
                loading: false,
                state: _postsResult?.state,
                emptyMessage: '当前作者还没有公开帖子',
                onRetry: _load,
                message: _postsResult?.message,
              )
            else if (posts.isEmpty)
              ForumSlimStatePanel(
                loading: false,
                state: AppPageState.empty,
                emptyMessage: '当前作者还没有公开帖子',
                onRetry: _load,
              )
            else
              ...posts.map(
                (ForumPostCardView item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _ForumPublicPostCard.fromPostCard(item: item),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
