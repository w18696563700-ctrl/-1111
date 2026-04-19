part of 'forum_pages.dart';

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
