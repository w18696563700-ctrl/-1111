part of 'forum_pages.dart';

class _ForumBrowsePane extends StatelessWidget {
  const _ForumBrowsePane({
    required this.scope,
    required this.loading,
    required this.feedResult,
    required this.topicResult,
    required this.selectedFilterKey,
    required this.onRetry,
    required this.onOpenScope,
    required this.onSelectTopic,
  });

  final ForumFeedScope scope;
  final bool loading;
  final ForumReadResult<ForumFeedView>? feedResult;
  final ForumReadResult<List<ForumTopicMetadataItemView>>? topicResult;
  final String selectedFilterKey;
  final VoidCallback onRetry;
  final ValueChanged<ForumFeedScope> onOpenScope;
  final ValueChanged<String> onSelectTopic;

  @override
  Widget build(BuildContext context) {
    final feedState = feedResult?.state;
    final items = feedResult?.data?.items ?? const <ForumFeedItemView>[];
    final topicItems =
        topicResult?.data ?? const <ForumTopicMetadataItemView>[];
    final topicChips = _buildTopicFilterChips(topicItems);
    final visibleItems = _filterFeedItems(
      items,
      selectedFilterKey: selectedFilterKey,
    );
    final showStateCard =
        loading || (feedState != null && feedState != AppPageState.content);

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
      children: <Widget>[
        _ForumTopScopeNav(currentScope: scope, onOpenScope: onOpenScope),
        const SizedBox(height: 10),
        _ForumTopicFilterBar(
          selectedFilterKey: selectedFilterKey,
          chips: topicChips,
          onSelectTopic: onSelectTopic,
        ),
        const SizedBox(height: 10),
        if (showStateCard)
          ForumSlimStatePanel(
            loading: loading,
            state: feedState,
            emptyMessage: '暂时还没有帖子',
            onRetry: onRetry,
            message: feedResult?.message,
          )
        else if (visibleItems.isEmpty)
          ForumSlimStatePanel(
            loading: false,
            state: AppPageState.empty,
            emptyMessage: '当前分类下暂时没有帖子',
            onRetry: onRetry,
          )
        else
          ...visibleItems.map(
            (ForumFeedItemView item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ForumFeedCard(item: item),
            ),
          ),
      ],
    );
  }
}

class _ForumTopScopeNav extends StatelessWidget {
  const _ForumTopScopeNav({
    required this.currentScope,
    required this.onOpenScope,
  });

  final ForumFeedScope currentScope;
  final ValueChanged<ForumFeedScope> onOpenScope;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: _forumTopLevelOrder.map((ForumFeedScope item) {
          final selected = item == currentScope;
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: selected ? null : () => onOpenScope(item),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: selected
                      ? theme.colorScheme.primaryContainer
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      _labelForScope(item),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: selected
                            ? FontWeight.w900
                            : FontWeight.w700,
                        color: selected
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: selected ? 22 : 10,
                      height: 3,
                      decoration: BoxDecoration(
                        color: selected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ForumTopicFilterBar extends StatelessWidget {
  const _ForumTopicFilterBar({
    required this.selectedFilterKey,
    required this.chips,
    required this.onSelectTopic,
  });

  final String selectedFilterKey;
  final List<_ForumTopicFilterChipData> chips;
  final ValueChanged<String> onSelectTopic;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(width: 6),
        itemBuilder: (BuildContext context, int index) {
          final chip = chips[index];
          return FilterChip(
            selected: _isFilterSelected(selectedFilterKey, chip),
            onSelected: (_) => onSelectTopic(chip.filterKey),
            label: Text(chip.label),
            showCheckmark: false,
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );
        },
      ),
    );
  }
}

class _ForumFeedCard extends StatelessWidget {
  const _ForumFeedCard({required this.item});

  final ForumFeedItemView item;

  @override
  Widget build(BuildContext context) {
    return _ForumPublicPostCard.fromFeed(item: item);
  }
}

class _ForumThreadCommentCard extends StatelessWidget {
  const _ForumThreadCommentCard({
    required this.author,
    required this.target,
    required this.content,
    required this.meta,
    required this.onOpenAuthor,
    this.onReport,
  });

  final ForumAuthorSummaryView author;
  final String target;
  final String content;
  final String meta;
  final VoidCallback onOpenAuthor;
  final VoidCallback? onReport;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visibleName = forumDisplayActorName(author.displayName);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: onOpenAuthor,
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: _ForumAuthorAvatar(
                      label: visibleName,
                      avatarUrl: null,
                      radius: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '$visibleName · $target',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
            const SizedBox(height: 10),
            Text(
              meta,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (onReport != null) ...<Widget>[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onReport,
                  icon: const Icon(Icons.flag_outlined, size: 18),
                  label: const Text('举报'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _labelForScope(ForumFeedScope scope) {
  return switch (scope) {
    ForumFeedScope.square => '广场',
    ForumFeedScope.local => '本地',
    ForumFeedScope.following => '关注',
  };
}

String _feedScopeKey(ForumFeedScope scope) {
  return switch (scope) {
    ForumFeedScope.square => 'square',
    ForumFeedScope.local => 'local',
    ForumFeedScope.following => 'following',
  };
}

String _routeForScope(ForumFeedScope scope) {
  return switch (scope) {
    ForumFeedScope.square => ExhibitionRoutes.forumSquare,
    ForumFeedScope.local => ExhibitionRoutes.forumLocal,
    ForumFeedScope.following => ExhibitionRoutes.forumFollowing,
  };
}

ForumFeedScope _scopeForCategoryKey(String categoryKey) {
  return switch (categoryKey.trim()) {
    'local' => ForumFeedScope.local,
    _ => ForumFeedScope.square,
  };
}

String _topicLabel(String categoryKey) {
  return forumDisplayTopicLabel(categoryKey: categoryKey);
}

String _compactPublishedAt(String value) {
  return forumDisplayTimeLabel(value);
}
