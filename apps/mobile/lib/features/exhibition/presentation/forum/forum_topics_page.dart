part of 'forum_pages.dart';

class ForumTopicsPage extends StatefulWidget {
  const ForumTopicsPage({super.key});

  @override
  State<ForumTopicsPage> createState() => _ForumTopicsPageState();
}

class _ForumTopicsPageState extends State<ForumTopicsPage> {
  ForumReadResult<ForumPagedCollectionView<ForumTopicCardView>>? _result;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await ForumConsumerLayer.instance.loadTopicList();
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
    final data = _result?.data;
    final showStateCard =
        _loading ||
        (_result?.state != null && _result?.state != AppPageState.content);

    return ForumPageFrame(
      eyebrow: '分类',
      title: '分类列表',
      summary: '分类会继续用于筛选和发帖选择。',
      scopeLabel: 'forum/topics',
      routeLabel: ExhibitionRoutes.forumTopics,
      showRouteMeta: false,
      children: <Widget>[
        if (showStateCard)
          ForumReadStateCard(
            loading: _loading,
            state: _result?.state,
            emptyMessage: '当前还没有可见分类。',
            onRetry: _load,
            message: _result?.message,
            errorCode: _result?.errorCode,
          ),
        if (data != null && _result?.state == AppPageState.content)
          _topicSection(context, data)
        else if (_result?.state == AppPageState.empty)
          _topicEmptySection(context),
      ],
    );
  }

  Widget _topicSection(
    BuildContext context,
    ForumPagedCollectionView<ForumTopicCardView> data,
  ) {
    return ForumSectionCard(
      eyebrow: '分类',
      title: '按分类继续筛选',
      summary: '你可以从这里继续进入对应内容。',
      children: data.items.take(4).map((ForumTopicCardView item) {
        return _ForumActionableCard(
          title:
              '# ${forumDisplayTopicLabel(rawLabel: item.title, topicId: item.topicId, categoryKey: item.categoryKey)}',
          summary: forumDisplayTopicDescription(
            rawDescription: item.excerpt,
            rawLabel: item.title,
            topicId: item.topicId,
            categoryKey: item.categoryKey,
          ),
          meta:
              '分类：${_topicLabel(item.categoryKey)} | 最近活跃：${_compactPublishedAt(item.lastActiveAt)}',
          footer: '作者：${forumDisplayActorName(item.author.displayName)}',
          actions: <Widget>[
            FilledButton(
              onPressed: () => Navigator.of(
                context,
              ).pushNamed(ExhibitionRoutes.forumTopicWithTopicId(item.topicId)),
              child: const Text('查看当前分类'),
            ),
            FilledButton.tonal(
              onPressed: () => Navigator.of(context).pushNamed(
                _routeForScope(_scopeForCategoryKey(item.categoryKey)),
              ),
              child: const Text('回同类列表'),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _topicEmptySection(BuildContext context) {
    return ForumSectionCard(
      eyebrow: '当前状态',
      title: '当前没有可用分类',
      summary: '你可以先回论坛首页，或先去发帖。',
      children: <Widget>[
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            FilledButton.tonal(
              onPressed: () => Navigator.of(
                context,
              ).pushNamed(ExhibitionRoutes.forumPublish),
              child: const Text('去发帖'),
            ),
            FilledButton.tonal(
              onPressed: () =>
                  Navigator.of(context).pushNamed(ExhibitionRoutes.forum),
              child: const Text('回论坛首页'),
            ),
          ],
        ),
      ],
    );
  }
}
