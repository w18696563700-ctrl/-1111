part of 'forum_pages.dart';

class _ForumMetricsSection extends StatelessWidget {
  const _ForumMetricsSection({
    required this.eyebrow,
    required this.title,
    required this.summary,
    required this.metrics,
  });

  final String eyebrow;
  final String title;
  final String summary;
  final List<Widget> metrics;

  @override
  Widget build(BuildContext context) {
    return ForumSectionCard(
      eyebrow: eyebrow,
      title: title,
      summary: summary,
      children: <Widget>[
        Wrap(spacing: 12, runSpacing: 12, children: metrics),
      ],
    );
  }
}

class _ForumActionableCard extends StatelessWidget {
  const _ForumActionableCard({
    required this.title,
    required this.summary,
    required this.meta,
    required this.actions,
    this.footer,
  });

  final String title;
  final String summary;
  final String meta;
  final String? footer;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ForumPostPreviewCard(
          title: title,
          summary: summary,
          meta: meta,
          footer: footer,
        ),
        const SizedBox(height: 10),
        Wrap(spacing: 12, runSpacing: 12, children: actions),
      ],
    );
  }
}

String _scopeOverview(ForumMeScope scope) {
  return switch (scope) {
    ForumMeScope.posts => '这里集中查看最近发布过的帖子。',
    ForumMeScope.comments => '这里集中查看最近参与过的评论上下文。',
    ForumMeScope.bookmarks => '这里集中查看最近收藏过的内容。',
    ForumMeScope.follows => '这里集中查看最近关注的话题。',
  };
}
