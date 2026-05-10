part of 'forum_pages.dart';

class ForumDraftsPage extends StatefulWidget {
  const ForumDraftsPage({super.key});

  @override
  State<ForumDraftsPage> createState() => _ForumDraftsPageState();
}

class _ForumDraftsPageState extends State<ForumDraftsPage> {
  ForumReadResult<ForumPagedCollectionView<ForumDraftCardView>>? _result;
  final Set<String> _deletingDraftIds = <String>{};
  final Set<String> _publishingDraftIds = <String>{};
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
    if (!RcReleaseFlags.forumPublishingEnabled) {
      _showDraftMessage('当前 RC 版本只保留论坛只读浏览，草稿删除暂未开放。');
      return;
    }
    if (_deletingDraftIds.contains(draft.draftId) ||
        _publishingDraftIds.contains(draft.draftId)) {
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

    _removeDraftFromResult(draft.draftId);
    await _load();
  }

  Future<void> _publishDraft(ForumDraftCardView draft) async {
    if (!RcReleaseFlags.forumPublishingEnabled) {
      _showDraftMessage('当前 RC 版本只保留论坛只读浏览，发帖发布暂未开放。');
      return;
    }
    if (!_canPublishDraft(draft) ||
        _publishingDraftIds.contains(draft.draftId) ||
        _deletingDraftIds.contains(draft.draftId)) {
      return;
    }

    setState(() => _publishingDraftIds.add(draft.draftId));
    final result = await ForumConsumerLayer.instance.publishDraft(
      draftId: draft.draftId,
    );
    if (!mounted) {
      return;
    }
    setState(() => _publishingDraftIds.remove(draft.draftId));

    if (!result.isSuccess || result.data == null) {
      _showDraftMessage(result.message);
      return;
    }

    _removeDraftFromResult(draft.draftId);
    final plan = await _resolveForumPublishContinuation(result.data!);
    if (!mounted) {
      return;
    }
    _showDraftMessage(plan.message);
    Navigator.of(context).pushReplacementNamed(plan.routeName);
  }

  void _removeDraftFromResult(String draftId) {
    final current = _result;
    if (current?.data == null) {
      return;
    }
    final remaining = current!.data!.items
        .where((ForumDraftCardView item) => item.draftId != draftId)
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

    return ColoredBox(
      color: AppVisualTokens.pageBackground,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
              onCreate: () => Navigator.of(
                context,
              ).pushNamed(ExhibitionRoutes.forumPublish),
            )
          else ...<Widget>[
            AppCard(
              backgroundColor: const Color(0xFFFFFCF6),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.swipe_left_rounded,
                    color: AppVisualTokens.brandGoldDark,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      '左滑草稿，点右侧红色删除区即可删除。',
                      style: AppTextTokens.body,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...drafts.map(
              (ForumDraftCardView draft) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ForumSwipeDeleteCard(
                  enabled:
                      RcReleaseFlags.forumPublishingEnabled &&
                      !_deletingDraftIds.contains(draft.draftId) &&
                      !_publishingDraftIds.contains(draft.draftId),
                  onDelete: () => _deleteDraft(draft),
                  child: _ForumDraftListCard(
                    draft: draft,
                    onOpen: () => Navigator.of(context).pushNamed(
                      ExhibitionRoutes.forumPublishWithDraftId(draft.draftId),
                    ),
                    onPublish: _canPublishDraft(draft)
                        ? () => _publishDraft(draft)
                        : null,
                    publishing: _publishingDraftIds.contains(draft.draftId),
                    actionLabel: _deletingDraftIds.contains(draft.draftId)
                        ? '删除中'
                        : null,
                    actionEnabled:
                        RcReleaseFlags.forumPublishingEnabled &&
                        !_deletingDraftIds.contains(draft.draftId) &&
                        !_publishingDraftIds.contains(draft.draftId),
                  ),
                ),
              ),
            ),
            const AppBottomSafePadding(extra: 16),
          ],
        ],
      ),
    );
  }
}

bool _canPublishDraft(ForumDraftCardView draft) {
  return RcReleaseFlags.forumPublishingEnabled &&
      draft.state.trim() == 'ready_to_publish';
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
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: _actionWidth,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppVisualTokens.dangerSoft,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFEBC2BD)),
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
                        color: const Color(0xFFA13B34),
                        size: 28,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '删除',
                        style: AppTextTokens.badgeText.copyWith(
                          color: const Color(0xFFA13B34),
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
          AppPrimaryButton(label: '去发帖', onPressed: onCreate),
        ],
      ),
    );
  }
}

class _ForumDraftListCard extends StatelessWidget {
  const _ForumDraftListCard({
    required this.draft,
    required this.onOpen,
    required this.onPublish,
    required this.publishing,
    this.actionLabel,
    this.actionEnabled = true,
  });

  final ForumDraftCardView draft;
  final VoidCallback onOpen;
  final VoidCallback? onPublish;
  final bool publishing;
  final String? actionLabel;
  final bool actionEnabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppVisualTokens.radiusLargeBorder,
        onTap: onOpen,
        child: AppCard(
          withShadow: true,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  AppStatusBadge(
                    label: forumDisplayDraftStateLabel(draft.state),
                    tone: draft.state.contains('ready')
                        ? AppStatusTone.brand
                        : AppStatusTone.warning,
                  ),
                  const Spacer(),
                  if (actionLabel != null)
                    Text(
                      actionLabel!,
                      style: AppTextTokens.badgeText.copyWith(
                        color: actionEnabled
                            ? const Color(0xFFA13B34)
                            : AppVisualTokens.textTertiary,
                      ),
                    )
                  else
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: AppVisualTokens.textTertiary,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                draft.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextTokens.cardTitle,
              ),
              const SizedBox(height: 6),
              Text(
                draft.excerpt,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextTokens.body.copyWith(
                  color: AppVisualTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '更新于 ${_compactPublishedAt(draft.updatedAt)}',
                style: AppTextTokens.caption,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: <Widget>[
                  AppPrimaryButton(
                    icon: publishing
                        ? Icons.hourglass_top_rounded
                        : Icons.send_rounded,
                    label: publishing ? '发布中' : '发布帖子',
                    onPressed: publishing ? null : onPublish,
                  ),
                  AppSecondaryButton(
                    icon: Icons.edit_outlined,
                    label: '继续编辑',
                    onPressed: actionEnabled ? onOpen : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
