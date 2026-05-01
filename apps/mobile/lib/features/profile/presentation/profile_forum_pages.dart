import 'package:flutter/material.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/features/exhibition/data/forum_consumer_layer.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/profile/presentation/profile_feature_status_copy.dart';
import 'package:mobile/shared/ui/app_visual_components.dart';
import 'package:mobile/shared/ui/app_visual_tokens.dart';

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

    return ColoredBox(
      color: AppVisualTokens.pageBackground,
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppVisualTokens.pagePadding,
            18,
            AppVisualTokens.pagePadding,
            0,
          ),
          children: <Widget>[
            _ProfileForumHeroCard(
              detail: _loading ? '正在同步论坛资产入口' : _forumSummary(),
            ),
            const SizedBox(height: 18),
            _ProfileForumOverviewSection(
              items: <_ProfileForumOverviewItem>[
                _ProfileForumOverviewItem(
                  icon: Icons.article_outlined,
                  label: '帖子',
                  value: _countLabel(
                    _visiblePostsCount(_postsResult?.data?.items),
                    _postsResult?.state,
                  ),
                  onTap: () => Navigator.of(
                    context,
                  ).pushNamed(ExhibitionRoutes.forumMePosts),
                ),
                _ProfileForumOverviewItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: '评论',
                  value: _countLabel(
                    _commentsResult?.data?.items.length,
                    _commentsResult?.state,
                  ),
                  onTap: () => Navigator.of(
                    context,
                  ).pushNamed(ExhibitionRoutes.forumMeComments),
                ),
                _ProfileForumOverviewItem(
                  icon: Icons.star_border_rounded,
                  label: '收藏',
                  value: _countLabel(
                    _bookmarksResult?.data?.items.length,
                    _bookmarksResult?.state,
                  ),
                  onTap: () => Navigator.of(
                    context,
                  ).pushNamed(ExhibitionRoutes.forumMeBookmarks),
                ),
                _ProfileForumOverviewItem(
                  icon: Icons.thumb_up_alt_outlined,
                  label: '点赞',
                  value: _countLabel(
                    _likesResult?.data?.items.length,
                    _likesResult?.state,
                  ),
                  onTap: () => Navigator.of(
                    context,
                  ).pushNamed(ExhibitionRoutes.forumMeLikes),
                ),
                _ProfileForumOverviewItem(
                  icon: Icons.person_add_alt_1_outlined,
                  label: '关注',
                  value: _countLabel(
                    _followsResult?.data?.items.length,
                    _followsResult?.state,
                  ),
                  onTap: () => Navigator.of(
                    context,
                  ).pushNamed(ExhibitionRoutes.forumMeFollows),
                ),
                _ProfileForumOverviewItem(
                  icon: Icons.edit_note_rounded,
                  label: '草稿',
                  value: _countLabel(
                    _draftsResult?.data?.items.length,
                    _draftsResult?.state,
                  ),
                  onTap: () => Navigator.of(
                    context,
                  ).pushNamed(ExhibitionRoutes.forumDrafts),
                ),
              ],
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
            _ProfileForumAssetSection(
              title: '论坛资产入口',
              children: <Widget>[
                _ProfileForumEntryRow(
                  icon: Icons.article_outlined,
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
                  icon: Icons.chat_bubble_outline_rounded,
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
                  icon: Icons.star_border_rounded,
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
                  icon: Icons.thumb_up_alt_outlined,
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
                  icon: Icons.person_add_alt_1_outlined,
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
                  icon: Icons.edit_note_rounded,
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
                  icon: Icons.report_gmailerrorred_outlined,
                  title: '我的举报记录',
                  subtitle: '查看我提交过的论坛举报记录',
                  countLabel: '查看',
                  onTap: () => Navigator.of(
                    context,
                  ).pushNamed(ExhibitionRoutes.forumMeReports),
                ),
              ],
            ),
            const AppBottomSafePadding(extra: 120),
          ],
        ),
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

class _ProfileForumHeroCard extends StatelessWidget {
  const _ProfileForumHeroCard({required this.detail});

  final String detail;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: AppVisualTokens.radiusXLarge,
      withShadow: true,
      backgroundColor: const Color(0xFFFFFCF6),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: <Widget>[
          DecoratedBox(
            decoration: const BoxDecoration(
              color: AppVisualTokens.brandGoldLight,
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              width: 60,
              height: 60,
              child: Center(
                child: Text(
                  '坛',
                  style: AppTextTokens.sectionTitle.copyWith(
                    color: AppVisualTokens.brandGoldDark,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('我的论坛', style: AppTextTokens.sectionTitle),
                const SizedBox(height: 6),
                const Text('帖子、评论、点赞、收藏、关注、草稿与举报记录', style: AppTextTokens.body),
                const SizedBox(height: 8),
                Text(detail, style: AppTextTokens.caption),
              ],
            ),
          ),
        ],
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
    return AppCard(
      backgroundColor: AppVisualTokens.warningSoft,
      borderColor: const Color(0xFFF1D5A7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: AppTextTokens.bodyStrong),
          const SizedBox(height: 6),
          Text(message, style: AppTextTokens.body),
        ],
      ),
    );
  }
}

class _ProfileForumOverviewItem {
  const _ProfileForumOverviewItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
}

class _ProfileForumOverviewSection extends StatelessWidget {
  const _ProfileForumOverviewSection({required this.items});

  final List<_ProfileForumOverviewItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.fromLTRB(4, 0, 4, 10),
          child: Text('内容概览', style: AppTextTokens.bodyStrong),
        ),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final tileWidth = (constraints.maxWidth - 20) / 3;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: items
                  .map(
                    (_ProfileForumOverviewItem item) => SizedBox(
                      width: tileWidth,
                      child: _ProfileForumMetricTile(item: item),
                    ),
                  )
                  .toList(growable: false),
            );
          },
        ),
      ],
    );
  }
}

class _ProfileForumMetricTile extends StatelessWidget {
  const _ProfileForumMetricTile({required this.item});

  final _ProfileForumOverviewItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppVisualTokens.radiusLargeBorder,
        onTap: item.onTap,
        child: AppCard(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
          backgroundColor: const Color(0xFFFEFCF8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppVisualTokens.brandGoldLight,
                  borderRadius: AppVisualTokens.radiusMediumBorder,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(7),
                  child: Icon(
                    item.icon,
                    size: 18,
                    color: AppVisualTokens.brandGoldDark,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(item.label, style: AppTextTokens.caption),
              const SizedBox(height: 4),
              Text(
                item.value,
                style: AppTextTokens.sectionTitle.copyWith(fontSize: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileForumAssetSection extends StatelessWidget {
  const _ProfileForumAssetSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: title,
      subtitle: '集中管理论坛资产，所有状态和数量均以后端回读为准。',
      withShadow: true,
      children: children,
    );
  }
}

class _ProfileForumEntryRow extends StatelessWidget {
  const _ProfileForumEntryRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.countLabel,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String countLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppVisualTokens.radiusLargeBorder,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: <Widget>[
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppVisualTokens.brandGoldLight,
                  borderRadius: AppVisualTokens.radiusMediumBorder,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    icon,
                    size: 20,
                    color: AppVisualTokens.brandGoldDark,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: AppTextTokens.bodyStrong),
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppTextTokens.caption),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              AppStatusBadge(label: countLabel, tone: AppStatusTone.brand),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppVisualTokens.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
