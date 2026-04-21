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
          FilledButton(onPressed: onCreate, child: const Text('去发帖')),
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
