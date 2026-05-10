part of 'exhibition_home_page.dart';

class _HomeForumModulePanel extends StatefulWidget {
  const _HomeForumModulePanel({
    required this.onOpenForum,
    required this.onOpenForumPublish,
    required this.onOpenForumPost,
  });

  final VoidCallback onOpenForum;
  final VoidCallback onOpenForumPublish;
  final void Function(String postId, {String? title}) onOpenForumPost;

  @override
  State<_HomeForumModulePanel> createState() => _HomeForumModulePanelState();
}

class _HomeForumModulePanelState extends State<_HomeForumModulePanel> {
  ForumReadResult<ForumFeedView>? _result;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    if (_loading) {
      return;
    }
    setState(() {
      _loading = true;
    });
    final result = await ForumConsumerLayer.instance.loadFeed(scope: 'square');
    if (!mounted) {
      return;
    }
    setState(() {
      _loading = false;
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final feedItems = _result?.data?.items ?? const <ForumFeedItemView>[];
    final state = _result?.state;

    return _HomeModulePanelShell(
      children: <Widget>[
        _HomeChannelActionRail(
          actions: <_HomeChannelAction>[
            _HomeChannelAction(
              label: '打开论坛',
              onPressed: widget.onOpenForum,
              primary: true,
            ),
            if (RcReleaseFlags.forumPublishingEnabled)
              _HomeChannelAction(
                label: '去写帖子',
                onPressed: widget.onOpenForumPublish,
              ),
            _HomeChannelAction(label: '刷新', onPressed: _loadFeed),
          ],
        ),
        const SizedBox(height: 12),
        _HomeChannelFilterRail<_HomeForumFilter>(
          options: const <_HomeChannelFilterOption<_HomeForumFilter>>[
            _HomeChannelFilterOption(
              value: _HomeForumFilter.comprehensive,
              label: '综合',
            ),
          ],
          selectedValue: _HomeForumFilter.comprehensive,
          onSelected: (_) {},
        ),
        const SizedBox(height: 12),
        if (_loading && _result == null)
          const _HomeLoadingNotice(message: '正在读取论坛帖子')
        else if (state == AppPageState.content && feedItems.isNotEmpty)
          ...feedItems
              .take(3)
              .map(
                (ForumFeedItemView item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ForumPostCard.fromFeed(
                    item: item,
                    compact: true,
                    onTap: () =>
                        widget.onOpenForumPost(item.postId, title: item.title),
                  ),
                ),
              )
        else if (state == AppPageState.empty)
          _HomeStateNotice(
            title: '当前论坛还没有公开帖子',
            message: RcReleaseFlags.forumPublishingEnabled
                ? '可以先打开论坛查看全部内容，或直接去写帖子。'
                : '可以先打开论坛查看全部内容。论坛发帖入口当前暂未开放。',
            actions: <Widget>[
              OutlinedButton(
                onPressed: widget.onOpenForum,
                child: const Text('打开论坛'),
              ),
              if (RcReleaseFlags.forumPublishingEnabled)
                FilledButton(
                  onPressed: widget.onOpenForumPublish,
                  child: const Text('去写帖子'),
                ),
            ],
          )
        else
          _HomeStateNotice(
            title: '当前论坛列表暂时没有刷新成功',
            message: '这一版只展示真实论坛 feed，不会把说明文字伪装成内容。',
            actions: <Widget>[
              OutlinedButton(onPressed: _loadFeed, child: const Text('刷新当前频道')),
              OutlinedButton(
                onPressed: widget.onOpenForum,
                child: const Text('打开论坛'),
              ),
            ],
          ),
      ],
    );
  }
}
