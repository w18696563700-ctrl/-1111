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
  ForumReadResult<ForumPagedCollectionView<ForumAuthorPostCardView>>?
  _postsResult;
  bool _loading = true;
  bool _followActionPending = false;
  bool? _viewerFollowsAuthorOverride;

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
    setState(() {
      _profileResult = profileResult;
      _postsResult =
          results[1]
              as ForumReadResult<
                ForumPagedCollectionView<ForumAuthorPostCardView>
              >;
      _viewerFollowsAuthorOverride = profileResult.data?.viewerFollowsAuthor;
      _loading = false;
    });
  }

  bool _isCurrentActor(ForumAuthorProfileView profile) {
    final shellUserId = AppShellScope.read(
      context,
    ).snapshot.shellContext.userId?.trim();
    return shellUserId != null &&
        shellUserId.isNotEmpty &&
        shellUserId == profile.authorId;
  }

  Future<void> _toggleAuthorFollow(ForumAuthorProfileView profile) async {
    if (_followActionPending) {
      return;
    }
    final currentlyFollowing =
        _viewerFollowsAuthorOverride ?? profile.viewerFollowsAuthor;
    setState(() => _followActionPending = true);
    final result = await ForumConsumerLayer.instance.toggleAuthorFollow(
      authorId: profile.authorId,
      currentlyFollowing: currentlyFollowing,
    );
    if (!mounted) {
      return;
    }
    if (!result.isSuccess || result.data == null) {
      setState(() => _followActionPending = false);
      _showAuthorActionMessage(result.message);
      return;
    }
    final next = _resolveAcceptedFollowState(
      result.data!,
      fallback: !currentlyFollowing,
    );
    setState(() {
      _viewerFollowsAuthorOverride = next;
      _followActionPending = false;
    });
    _showAuthorActionMessage(next ? '已关注作者' : '已取消关注');
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profileResult?.data;
    final posts =
        _postsResult?.data?.items ?? const <ForumAuthorPostCardView>[];
    final visibleName = forumDisplayActorName(profile?.displayName);
    final isCurrentActor = profile != null && _isCurrentActor(profile);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
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
            viewerFollowsAuthor:
                _viewerFollowsAuthorOverride ?? profile.viewerFollowsAuthor,
            followPending: _followActionPending,
            isCurrentActor: isCurrentActor,
            onToggleFollow: () => _toggleAuthorFollow(profile),
            onOpenMessages: () =>
                Navigator.of(context).pushNamed(AppBuilding.messages.routePath),
            onOpenMine: () =>
                Navigator.of(context).pushNamed(AppBuilding.profile.routePath),
          ),
        if (profile != null) const SizedBox(height: 16),
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
            (ForumAuthorPostCardView item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ForumPublicPostCard.fromAuthorPostCard(item: item),
            ),
          ),
      ],
    );
  }

  bool _resolveAcceptedFollowState(
    ForumToggleAcceptedView result, {
    required bool fallback,
  }) {
    final viewerState = result.viewerFollowsAuthor;
    if (viewerState != null) {
      return viewerState;
    }
    return switch (result.state) {
      'followed' => true,
      'unfollowed' => false,
      _ => fallback,
    };
  }

  void _showAuthorActionMessage(String? message) {
    final visible = message?.trim();
    if (visible == null || visible.isEmpty) {
      return;
    }
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(SnackBar(content: Text(visible)));
  }
}
