import 'package:flutter/material.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/features/exhibition/data/forum_consumer_layer.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/profile/presentation/profile_feature_status_copy.dart';

class ProfileForumPage extends StatefulWidget {
  const ProfileForumPage({super.key});

  @override
  State<ProfileForumPage> createState() => _ProfileForumPageState();
}

class _ProfileForumPageState extends State<ProfileForumPage> {
  bool _loading = true;
  ForumReadResult<ForumPagedCollectionView<ForumMyPostItemView>>? _postsResult;
  ForumReadResult<ForumPagedCollectionView<ForumCommentAssetItemView>>?
  _commentsResult;
  ForumReadResult<ForumPagedCollectionView<ForumPostCardView>>?
  _bookmarksResult;
  ForumReadResult<ForumPagedCollectionView<ForumPostCardView>>? _likesResult;
  ForumReadResult<ForumPagedCollectionView<ForumFollowedAuthorItemView>>?
  _followsResult;
  ForumReadResult<ForumPagedCollectionView<ForumDraftCardView>>? _draftsResult;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait<Object>(<Future<Object>>[
      ForumConsumerLayer.instance.loadMyPosts(),
      ForumConsumerLayer.instance.loadMyComments(),
      ForumConsumerLayer.instance.loadMyBookmarks(),
      ForumConsumerLayer.instance.loadMyLikes(),
      ForumConsumerLayer.instance.loadMyFollows(),
      ForumConsumerLayer.instance.loadDraftList(),
    ]);
    if (!mounted) {
      return;
    }

    setState(() {
      _postsResult =
          results[0]
              as ForumReadResult<ForumPagedCollectionView<ForumMyPostItemView>>;
      _commentsResult =
          results[1]
              as ForumReadResult<
                ForumPagedCollectionView<ForumCommentAssetItemView>
              >;
      _bookmarksResult =
          results[2]
              as ForumReadResult<ForumPagedCollectionView<ForumPostCardView>>;
      _likesResult =
          results[3]
              as ForumReadResult<ForumPagedCollectionView<ForumPostCardView>>;
      _followsResult =
          results[4]
              as ForumReadResult<
                ForumPagedCollectionView<ForumFollowedAuthorItemView>
              >;
      _draftsResult =
          results[5]
              as ForumReadResult<ForumPagedCollectionView<ForumDraftCardView>>;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final warningMessage = _primaryMessage();
    final ready =
        !_loading &&
        _isReadyState(_postsResult?.state) &&
        _isReadyState(_commentsResult?.state) &&
        _isReadyState(_bookmarksResult?.state) &&
        _isReadyState(_likesResult?.state) &&
        _isReadyState(_followsResult?.state) &&
        _isReadyState(_draftsResult?.state);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: <Widget>[
          _ProfileForumHeader(
            detail: _loading ? '正在同步论坛资产入口' : _forumSummary(),
          ),
          if (profileFeatureStatusVisible) ...<Widget>[
            const SizedBox(height: 12),
            ProfileFeatureStatusCard(
              snapshot: profileForumFeatureStatus(runtimeReady: ready),
            ),
          ],
          if (warningMessage != null) ...<Widget>[
            const SizedBox(height: 12),
            _ProfileForumStatusPanel(
              title: '论坛资产暂未完整返回',
              message: warningMessage,
            ),
          ],
          const SizedBox(height: 18),
          _ProfileForumSection(
            title: '论坛资产',
            children: <Widget>[
              _ProfileForumEntryRow(
                title: '我的帖子',
                subtitle: '查看我发布过的内容',
                countLabel: _countLabel(
                  _visiblePostsCount(_postsResult?.data?.items),
                  _postsResult?.state,
                ),
                onTap: () => Navigator.of(
                  context,
                ).pushNamed(ExhibitionRoutes.forumMePosts),
              ),
              _ProfileForumEntryRow(
                title: '我的评论',
                subtitle: '查看我参与过的讨论',
                countLabel: _countLabel(
                  _commentsResult?.data?.items.length,
                  _commentsResult?.state,
                ),
                onTap: () => Navigator.of(
                  context,
                ).pushNamed(ExhibitionRoutes.forumMeComments),
              ),
              _ProfileForumEntryRow(
                title: '我的收藏',
                subtitle: '查看我收藏过的帖子',
                countLabel: _countLabel(
                  _bookmarksResult?.data?.items.length,
                  _bookmarksResult?.state,
                ),
                onTap: () => Navigator.of(
                  context,
                ).pushNamed(ExhibitionRoutes.forumMeBookmarks),
              ),
              _ProfileForumEntryRow(
                title: '我的点赞',
                subtitle: '查看我点过赞的帖子',
                countLabel: _countLabel(
                  _likesResult?.data?.items.length,
                  _likesResult?.state,
                ),
                onTap: () => Navigator.of(
                  context,
                ).pushNamed(ExhibitionRoutes.forumMeLikes),
              ),
              _ProfileForumEntryRow(
                title: '我的关注',
                subtitle: '查看我持续关注的作者',
                countLabel: _countLabel(
                  _followsResult?.data?.items.length,
                  _followsResult?.state,
                ),
                onTap: () => Navigator.of(
                  context,
                ).pushNamed(ExhibitionRoutes.forumMeFollows),
              ),
              _ProfileForumEntryRow(
                title: '草稿箱',
                subtitle: '查看还未发布的内容',
                countLabel: _countLabel(
                  _draftsResult?.data?.items.length,
                  _draftsResult?.state,
                ),
                onTap: () => Navigator.of(
                  context,
                ).pushNamed(ExhibitionRoutes.forumDrafts),
              ),
              _ProfileForumEntryRow(
                title: '我的举报记录',
                subtitle: '查看我提交过的论坛举报记录',
                countLabel: '查看',
                onTap: () => Navigator.of(
                  context,
                ).pushNamed(ExhibitionRoutes.forumMeReports),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _forumSummary() {
    return '帖子 ${_countLabel(_visiblePostsCount(_postsResult?.data?.items), _postsResult?.state)} · '
        '评论 ${_countLabel(_commentsResult?.data?.items.length, _commentsResult?.state)} · '
        '收藏 ${_countLabel(_bookmarksResult?.data?.items.length, _bookmarksResult?.state)} · '
        '点赞 ${_countLabel(_likesResult?.data?.items.length, _likesResult?.state)} · '
        '关注 ${_countLabel(_followsResult?.data?.items.length, _followsResult?.state)} · '
        '草稿 ${_countLabel(_draftsResult?.data?.items.length, _draftsResult?.state)}';
  }

  String? _primaryMessage() {
    if (_loading) {
      return null;
    }
    final results = <({AppPageState? state, String? message})>[
      (state: _postsResult?.state, message: _postsResult?.message),
      (state: _commentsResult?.state, message: _commentsResult?.message),
      (state: _bookmarksResult?.state, message: _bookmarksResult?.message),
      (state: _likesResult?.state, message: _likesResult?.message),
      (state: _followsResult?.state, message: _followsResult?.message),
      (state: _draftsResult?.state, message: _draftsResult?.message),
    ];
    for (final result in results) {
      if (result.state == null || result.state == AppPageState.content) {
        continue;
      }
      if (result.state == AppPageState.empty) {
        continue;
      }
      return result.message;
    }
    return null;
  }

  static String _countLabel(int? count, AppPageState? state) {
    return switch (state) {
      AppPageState.content => '${count ?? 0}',
      AppPageState.empty => '0',
      _ => '—',
    };
  }

  static int? _visiblePostsCount(List<ForumMyPostItemView>? posts) {
    return posts
        ?.where((ForumMyPostItemView item) => item.state != 'archived')
        .length;
  }

  static bool _isReadyState(AppPageState? state) {
    return state == AppPageState.content || state == AppPageState.empty;
  }
}

class _ProfileForumHeader extends StatelessWidget {
  const _ProfileForumHeader({required this.detail});

  final String detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
              child: Text(
                '坛',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '我的论坛',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '帖子、评论、点赞、收藏、关注、草稿与举报记录',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(detail, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileForumStatusPanel extends StatelessWidget {
  const _ProfileForumStatusPanel({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileForumSection extends StatelessWidget {
  const _ProfileForumSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = <Widget>[];
    for (var index = 0; index < children.length; index += 1) {
      if (index > 0) {
        rows.add(Divider(height: 1, color: theme.colorScheme.outlineVariant));
      }
      rows.add(children[index]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
          child: Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(children: rows),
        ),
      ],
    );
  }
}

class _ProfileForumEntryRow extends StatelessWidget {
  const _ProfileForumEntryRow({
    required this.title,
    required this.subtitle,
    required this.countLabel,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String countLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Text(
                countLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
      onTap: onTap,
    );
  }
}
