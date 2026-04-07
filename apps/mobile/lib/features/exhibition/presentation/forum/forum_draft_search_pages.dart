part of 'forum_pages.dart';

class ForumDraftsPage extends StatefulWidget {
  const ForumDraftsPage({super.key});

  @override
  State<ForumDraftsPage> createState() => _ForumDraftsPageState();
}

class _ForumDraftsPageState extends State<ForumDraftsPage> {
  ForumReadResult<ForumPagedCollectionView<ForumDraftCardView>>? _result;
  final Set<String> _deletingDraftIds = <String>{};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await ForumConsumerLayer.instance.loadDraftList();
    if (!mounted) {
      return;
    }
    setState(() {
      _result = result;
      _loading = false;
    });
  }

  Future<void> _deleteDraft(ForumDraftCardView draft) async {
    if (_deletingDraftIds.contains(draft.draftId)) {
      return;
    }

    setState(() => _deletingDraftIds.add(draft.draftId));
    final result = await ForumConsumerLayer.instance.deleteDraft(
      draftId: draft.draftId,
    );
    if (!mounted) {
      return;
    }

    setState(() => _deletingDraftIds.remove(draft.draftId));
    _showDraftMessage(result.isSuccess ? '草稿已删除' : result.message);
    if (!result.isSuccess) {
      return;
    }

    final current = _result;
    if (current?.data != null) {
      final remaining = current!.data!.items
          .where((ForumDraftCardView item) => item.draftId != draft.draftId)
          .toList(growable: false);
      setState(() {
        _result = ForumReadResult<ForumPagedCollectionView<ForumDraftCardView>>(
          state: remaining.isEmpty ? AppPageState.empty : AppPageState.content,
          method: current.method,
          path: current.path,
          data: ForumPagedCollectionView<ForumDraftCardView>(
            items: remaining,
            page: current.data!.page,
          ),
        );
      });
    }
    await _load();
  }

  void _showDraftMessage(String? message) {
    final visible = message?.trim();
    if (visible == null || visible.isEmpty) {
      return;
    }
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(SnackBar(content: Text(visible)));
  }

  @override
  Widget build(BuildContext context) {
    final drafts = _result?.data?.items ?? const <ForumDraftCardView>[];
    final state = _result?.state;
    final showState =
        _loading || (state != null && state != AppPageState.content);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: <Widget>[
        if (showState)
          ForumSlimStatePanel(
            loading: _loading,
            state: state,
            emptyMessage: '暂无草稿',
            onRetry: _load,
            message: _result?.message,
          )
        else if (drafts.isEmpty)
          _ForumDraftEmptyState(
            onCreate: () =>
                Navigator.of(context).pushNamed(ExhibitionRoutes.forumPublish),
          )
        else ...<Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.swipe_left_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '左滑草稿，点右侧红色减号即可删除。',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...drafts.map(
            (ForumDraftCardView draft) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ForumSwipeDeleteCard(
                enabled: !_deletingDraftIds.contains(draft.draftId),
                onDelete: () => _deleteDraft(draft),
                child: _ForumDraftListCard(
                  draft: draft,
                  onOpen: () => Navigator.of(context).pushNamed(
                    ExhibitionRoutes.forumPublishWithDraftId(draft.draftId),
                  ),
                  actionLabel: _deletingDraftIds.contains(draft.draftId)
                      ? '删除中'
                      : null,
                  actionEnabled: !_deletingDraftIds.contains(draft.draftId),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ForumSwipeDeleteCard extends StatefulWidget {
  const _ForumSwipeDeleteCard({
    required this.child,
    required this.onDelete,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback onDelete;
  final bool enabled;

  @override
  State<_ForumSwipeDeleteCard> createState() => _ForumSwipeDeleteCardState();
}

class _ForumSwipeDeleteCardState extends State<_ForumSwipeDeleteCard> {
  static const double _actionWidth = 88;
  double _offset = 0;

  void _close() {
    if (_offset == 0) {
      return;
    }
    setState(() => _offset = 0);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: _actionWidth,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.error,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: widget.enabled
                      ? () {
                          _close();
                          widget.onDelete();
                        }
                      : null,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.remove_rounded,
                        color: colorScheme.onError,
                        size: 28,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '删除',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.onError,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Transform.translate(
          offset: Offset(_offset, 0),
          child: GestureDetector(
            onTap: _offset == 0 ? null : _close,
            onHorizontalDragUpdate: widget.enabled
                ? (DragUpdateDetails details) {
                    final nextOffset = (_offset + (details.primaryDelta ?? 0))
                        .clamp(-_actionWidth, 0.0);
                    setState(() => _offset = nextOffset);
                  }
                : null,
            onHorizontalDragEnd: widget.enabled
                ? (DragEndDetails details) {
                    final shouldReveal =
                        _offset.abs() > _actionWidth / 2 ||
                        (details.primaryVelocity ?? 0) < -240;
                    setState(() => _offset = shouldReveal ? -_actionWidth : 0);
                  }
                : null,
            child: widget.child,
          ),
        ),
      ],
    );
  }
}

class ForumSearchPage extends StatefulWidget {
  const ForumSearchPage({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  State<ForumSearchPage> createState() => _ForumSearchPageState();
}

class _ForumSearchPageState extends State<ForumSearchPage> {
  static const List<String> _suggestions = <String>['进场窗口', '材料替代', '供应协同'];

  late final TextEditingController _controller;
  ForumReadResult<ForumSearchView>? _result;
  String? _submittedQuery;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final initialQuery = widget.initialQuery?.trim() ?? '';
    _controller = TextEditingController(text: initialQuery);
    if (initialQuery.isNotEmpty) {
      _search(initialQuery);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search([String? nextQuery]) async {
    final query = (nextQuery ?? _controller.text).trim();
    if (query.isEmpty) {
      setState(() {
        _submittedQuery = null;
        _result = null;
        _loading = false;
      });
      return;
    }

    setState(() {
      _submittedQuery = query;
      _loading = true;
    });

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
    final result = _result?.data;
    final items = result?.items ?? const <ForumSearchResultItemView>[];
    final state = _pageState;
    final showState =
        _loading || (_submittedQuery != null && state != AppPageState.content);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: <Widget>[
        _searchBar(context),
        const SizedBox(height: 12),
        if (_submittedQuery == null) ...<Widget>[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestions
                .map(
                  (String item) => ActionChip(
                    label: Text(item),
                    onPressed: _loading
                        ? null
                        : () {
                            _controller.text = item;
                            _search(item);
                          },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 18),
          Text(
            '搜帖子，也搜分类',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            '输入关键词后直接进入结果页。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ] else if (!showState) ...<Widget>[
          Text(
            '“$_submittedQuery” · ${items.length} 条结果',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (showState)
          ForumSlimStatePanel(
            loading: _loading,
            state: state,
            emptyMessage: _submittedQuery == null ? '输入关键词开始搜索' : '没有找到相关内容',
            onRetry: _submittedQuery == null ? () {} : () => _search(),
            message: _result?.message,
          )
        else if (_submittedQuery != null)
          ...items.map(
            (ForumSearchResultItemView item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ForumSearchResultCard(
                item: item,
                onOpen: () => Navigator.of(context).pushNamed(
                  item.postId == null
                      ? ExhibitionRoutes.forumTopicWithTopicId(item.topicId)
                      : ExhibitionRoutes.forumPostWithPostId(item.postId!),
                ),
              ),
            ),
          ),
      ],
    );
  }

  AppPageState get _pageState {
    return _loading
        ? AppPageState.loading
        : _submittedQuery == null
        ? AppPageState.empty
        : _result?.state ?? AppPageState.empty;
  }

  Widget _searchBar(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        child: Row(
          children: <Widget>[
            const Icon(Icons.search_rounded),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: '搜索帖子或话题',
                  border: InputBorder.none,
                  isDense: true,
                ),
                textInputAction: TextInputAction.search,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _search(),
              ),
            ),
            if (_controller.text.trim().isNotEmpty)
              IconButton(
                tooltip: '清空关键词',
                onPressed: _loading
                    ? null
                    : () {
                        _controller.clear();
                        _search('');
                      },
                icon: const Icon(Icons.close_rounded),
              )
            else
              TextButton(
                onPressed: _loading ? null : () => _search(),
                child: const Text('搜索'),
              ),
          ],
        ),
      ),
    );
  }
}

class _ForumDraftEmptyState extends StatelessWidget {
  const _ForumDraftEmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 72),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.edit_note_rounded,
            size: 72,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 18),
          Text(
            '暂无草稿',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '你写下的内容会先保存在这里。',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(onPressed: onCreate, child: const Text('去发帖')),
        ],
      ),
    );
  }
}

class _ForumDraftListCard extends StatelessWidget {
  const _ForumDraftListCard({
    required this.draft,
    required this.onOpen,
    this.actionLabel,
    this.actionEnabled = true,
  });

  final ForumDraftCardView draft;
  final VoidCallback onOpen;
  final String? actionLabel;
  final bool actionEnabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onOpen,
        child: Ink(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    ForumInfoPill(
                      label: forumDisplayDraftStateLabel(draft.state),
                      highlighted: draft.state.contains('ready'),
                    ),
                    const Spacer(),
                    if (actionLabel != null)
                      Text(
                        actionLabel!,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: actionEnabled
                              ? theme.colorScheme.error
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    else
                      const Icon(Icons.chevron_right_rounded, size: 20),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  draft.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  draft.excerpt,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
                ),
                const SizedBox(height: 8),
                Text(
                  '更新于 ${_compactPublishedAt(draft.updatedAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ForumSearchResultCard extends StatelessWidget {
  const _ForumSearchResultCard({required this.item, required this.onOpen});

  final ForumSearchResultItemView item;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = item.postId == null
        ? forumDisplayTopicLabel(rawLabel: item.title, topicId: item.topicId)
        : item.title;
    final summary = item.postId == null
        ? forumDisplayTopicDescription(
            rawDescription: item.excerpt,
            rawLabel: item.title,
            topicId: item.topicId,
          )
        : item.excerpt;
    final authorName = forumDisplayActorName(item.author.displayName);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onOpen,
        child: Ink(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    ForumInfoPill(
                      label: item.postId == null ? '话题' : '帖子',
                      highlighted: item.postId != null,
                    ),
                    Text(
                      '$authorName · ${_compactPublishedAt(item.publishedAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
