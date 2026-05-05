part of 'forum_pages.dart';

class ForumSearchPage extends StatefulWidget {
  const ForumSearchPage({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  State<ForumSearchPage> createState() => _ForumSearchPageState();
}

class _ForumSearchPageState extends State<ForumSearchPage> {
  late final TextEditingController _queryController;
  ForumReadResult<ForumSearchView>? _result;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController(text: widget.initialQuery ?? '');
    if (_queryController.text.trim().isNotEmpty) {
      _load();
    }
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final query = _queryController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _loading = false;
        _result = const ForumReadResult<ForumSearchView>(
          state: AppPageState.empty,
          method: 'GET',
          path: ForumCanonicalPaths.search,
          message: '请输入关键词后再搜索',
        );
      });
      return;
    }

    setState(() => _loading = true);
    final result = await ForumConsumerLayer.instance.loadSearch(query: query);
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
    final showState =
        _loading ||
        (_result?.state != null && _result?.state != AppPageState.content);

    return ForumPageFrame(
      eyebrow: '搜索',
      title: '搜索论坛内容',
      summary: '先输入关键词，再查看匹配到的话题或帖子。',
      scopeLabel: 'forum/search',
      routeLabel: ExhibitionRoutes.forumSearch,
      showRouteMeta: false,
      children: <Widget>[
        ForumSectionCard(
          eyebrow: '关键词',
          title: '输入要查找的内容',
          summary: '搜索结果只承接论坛内容，不混入其他业务对象。',
          children: <Widget>[
            TextField(
              controller: _queryController,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(hintText: '例如：主场搭建、展台设计、报价'),
              onSubmitted: (_) => _load(),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton(
                onPressed: _loading ? null : _load,
                child: const Text('开始搜索'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (showState)
          ForumSlimStatePanel(
            loading: _loading,
            state: _result?.state,
            emptyMessage: '当前没有匹配结果',
            onRetry: _load,
            message: _result?.message,
          )
        else if (data != null)
          ForumSectionCard(
            eyebrow: '结果',
            title: '匹配内容',
            summary: '搜索结果会继续跳回对应话题或帖子详情。',
            children: data.items
                .map(
                  (ForumSearchResultItemView item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ForumActionableCard(
                      title: item.title,
                      summary: item.excerpt,
                      meta:
                          '结果类型：${item.postId == null ? '话题' : '帖子'} | 发布时间：${_compactPublishedAt(item.publishedAt)}',
                      footer:
                          '作者：${forumDisplayActorName(item.author.displayName)}',
                      actions: <Widget>[
                        FilledButton.tonal(
                          onPressed: () => Navigator.of(context).pushNamed(
                            item.postId == null
                                ? ExhibitionRoutes.forumTopicWithTopicId(
                                    item.topicId,
                                  )
                                : ExhibitionRoutes.forumPostWithPostId(
                                    item.postId!,
                                    title: item.title,
                                  ),
                          ),
                          child: Text(item.postId == null ? '查看话题' : '查看帖子'),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(growable: false),
          ),
      ],
    );
  }
}
