part of 'exhibition_page.dart';

class _WorkbenchContainerDeck extends StatelessWidget {
  const _WorkbenchContainerDeck({
    required this.viewModel,
    required this.onRefresh,
  });

  final ExhibitionWorkbenchPageViewModel viewModel;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: viewModel.sections
          .map((ExhibitionWorkbenchSectionViewModel section) {
            final isLast = identical(section, viewModel.sections.last);
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: _WorkbenchContainerCard(
                section: section,
                onRefresh: onRefresh,
              ),
            );
          })
          .toList(growable: false),
    );
  }
}

class _WorkbenchContainerCard extends StatelessWidget {
  const _WorkbenchContainerCard({
    required this.section,
    required this.onRefresh,
  });

  final ExhibitionWorkbenchSectionViewModel section;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tone = _containerToneTheme(theme, section.state);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tone.surfaceColor,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: tone.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Text(
                    section.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _NodeStatusPill(
                  label: section.stateLabel,
                  backgroundColor: tone.pillColor,
                  foregroundColor: tone.pillTextColor,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              section.summary,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
            if (section.state ==
                ExhibitionWorkbenchContainerState.loading) ...<Widget>[
              const SizedBox(height: 14),
              const LinearProgressIndicator(),
            ],
            if (section.state ==
                ExhibitionWorkbenchContainerState
                    .controlledFailure) ...<Widget>[
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text('刷新当前容器'),
              ),
            ],
            if (section.nodes.isNotEmpty) ...<Widget>[
              const SizedBox(height: 14),
              ...section.nodes.map((ExhibitionWorkbenchNodeViewModel node) {
                final isLast = identical(node, section.nodes.last);
                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                  child: _WorkbenchNodeTile(node: node),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class _WorkbenchNodeTile extends StatelessWidget {
  const _WorkbenchNodeTile({required this.node});

  final ExhibitionWorkbenchNodeViewModel node;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tone = _nodeToneTheme(theme, node.tone);
    final canContinue = node.routeName != null && node.actionLabel != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tone.surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tone.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Text(
                    node.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _NodeStatusPill(
                  label: node.statusLabel,
                  backgroundColor: tone.pillColor,
                  foregroundColor: tone.pillTextColor,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              node.description,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
            if (canContinue) ...<Widget>[
              const SizedBox(height: 10),
              FilledButton.tonal(
                onPressed: () =>
                    Navigator.of(context).pushNamed(node.routeName!),
                child: Text(node.actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BoundaryFootnoteCard extends StatelessWidget {
  const _BoundaryFootnoteCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          '当前工作台只保留私域四容器摘要和受控导流。rating/submit、dispute/withdraw、inspection/recheck 继续保持冻结，不在这里放开。',
          style: theme.textTheme.bodySmall?.copyWith(
            height: 1.45,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
