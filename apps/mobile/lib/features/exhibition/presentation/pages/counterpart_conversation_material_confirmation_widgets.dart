part of '../exhibition_trade_pages.dart';

// Kept as the reserved publisher-side material confirmation surface.
// ignore: unused_element
class _PublisherConfirmationSection extends StatelessWidget {
  const _PublisherConfirmationSection({
    required this.snapshot,
    required this.onOpenItem,
  });

  final _PublisherConfirmationSnapshot snapshot;
  final ValueChanged<_PublisherConfirmationItem> onOpenItem;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(
              Icons.assignment_turned_in_outlined,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              '确认事项',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        if (snapshot.unavailableMessage != null) ...<Widget>[
          const SizedBox(height: 6),
          Text(
            snapshot.unavailableMessage!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final twoColumns = constraints.maxWidth >= 320;
            final tileWidth = twoColumns
                ? (constraints.maxWidth - 8) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (var index = 0; index < snapshot.items.length; index += 1)
                  SizedBox(
                    width: twoColumns && index == 2
                        ? constraints.maxWidth
                        : tileWidth,
                    child: _PublisherConfirmationTile(
                      item: snapshot.items[index],
                      onTap: () => onOpenItem(snapshot.items[index]),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _PublisherConfirmationTile extends StatelessWidget {
  const _PublisherConfirmationTile({required this.item, required this.onTap});

  final _PublisherConfirmationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = _styleForStatus(theme, item.status);
    return Material(
      color: style.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: style.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: <Widget>[
              Icon(
                _iconForConfirmation(item.confirmationKey),
                color: style.foreground,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: style.foreground,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _MaterialConfirmationStatusPill(
                label: _statusLabel(item.status),
                foreground: style.pillForeground,
                background: style.pillBackground,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _ProjectMaterialConfirmationTileStyle _styleForStatus(
    ThemeData theme,
    _PublisherConfirmationStatus status,
  ) {
    final colorScheme = theme.colorScheme;
    return switch (status) {
      _PublisherConfirmationStatus.pending =>
        _ProjectMaterialConfirmationTileStyle(
          foreground: const Color(0xFF8A5600),
          background: const Color(0xFFFFF7E8),
          border: const Color(0xFFE4B266),
          pillForeground: const Color(0xFF8A5600),
          pillBackground: const Color(0xFFFFE8B8),
        ),
      _PublisherConfirmationStatus.confirmed =>
        _ProjectMaterialConfirmationTileStyle(
          foreground: const Color(0xFF176D38),
          background: const Color(0xFFEAF7EF),
          border: const Color(0xFF6FC58D),
          pillForeground: const Color(0xFF176D38),
          pillBackground: const Color(0xFFD7F1DF),
        ),
      _PublisherConfirmationStatus.unavailable =>
        _ProjectMaterialConfirmationTileStyle(
          foreground: colorScheme.onSurfaceVariant,
          background: colorScheme.surfaceContainerLowest,
          border: colorScheme.outlineVariant,
          pillForeground: colorScheme.onSurfaceVariant,
          pillBackground: colorScheme.surfaceContainerHighest,
        ),
    };
  }

  IconData _iconForConfirmation(String key) {
    return switch (key) {
      _publisherConfirmationQuote => Icons.receipt_long_outlined,
      _publisherConfirmationSchedule => Icons.event_note_outlined,
      _publisherConfirmationMaterialProcess => Icons.construction_outlined,
      _ => Icons.assignment_turned_in_outlined,
    };
  }

  String _statusLabel(_PublisherConfirmationStatus status) {
    return switch (status) {
      _PublisherConfirmationStatus.pending => '待确认',
      _PublisherConfirmationStatus.confirmed => '已确认',
      _PublisherConfirmationStatus.unavailable => '暂不可读',
    };
  }
}

// Kept as the reserved bidder-side material confirmation surface.
// ignore: unused_element
class _BidderMaterialSection extends StatelessWidget {
  const _BidderMaterialSection({
    required this.snapshot,
    required this.onOpenItem,
  });

  final _ProjectMaterialConfirmationSnapshot snapshot;
  final ValueChanged<_ProjectMaterialConfirmationItem> onOpenItem;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(
              Icons.assignment_turned_in_outlined,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              '资料',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            if (snapshot.loading) ...<Widget>[
              const SizedBox(width: 8),
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ],
        ),
        if (snapshot.unavailableMessage != null) ...<Widget>[
          const SizedBox(height: 6),
          Text(
            snapshot.unavailableMessage!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final twoColumns = constraints.maxWidth >= 320;
            final tileWidth = twoColumns
                ? (constraints.maxWidth - 8) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (final item in snapshot.items)
                  SizedBox(
                    width:
                        item.attachmentKind ==
                                _projectMaterialConfirmationEquipmentMaterialList &&
                            twoColumns
                        ? constraints.maxWidth
                        : tileWidth,
                    child: _ProjectMaterialConfirmationTile(
                      item: item,
                      onTap: () => onOpenItem(item),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ProjectMaterialConfirmationTile extends StatelessWidget {
  const _ProjectMaterialConfirmationTile({
    required this.item,
    required this.onTap,
  });

  final _ProjectMaterialConfirmationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = _styleForStatus(theme, item.status);
    return Material(
      color: style.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: style.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: <Widget>[
              Icon(_iconForKind(item.attachmentKind), color: style.foreground),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: style.foreground,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _MaterialConfirmationStatusPill(
                label: _statusLabel(item.status),
                foreground: style.pillForeground,
                background: style.pillBackground,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _ProjectMaterialConfirmationTileStyle _styleForStatus(
    ThemeData theme,
    _ProjectMaterialConfirmationStatus status,
  ) {
    final colorScheme = theme.colorScheme;
    return switch (status) {
      _ProjectMaterialConfirmationStatus.pending =>
        _ProjectMaterialConfirmationTileStyle(
          foreground: const Color(0xFF8A5600),
          background: const Color(0xFFFFF7E8),
          border: const Color(0xFFE4B266),
          pillForeground: const Color(0xFF8A5600),
          pillBackground: const Color(0xFFFFE8B8),
        ),
      _ProjectMaterialConfirmationStatus.confirmed =>
        _ProjectMaterialConfirmationTileStyle(
          foreground: const Color(0xFF176D38),
          background: const Color(0xFFEAF7EF),
          border: const Color(0xFF6FC58D),
          pillForeground: const Color(0xFF176D38),
          pillBackground: const Color(0xFFD7F1DF),
        ),
      _ProjectMaterialConfirmationStatus.unavailable =>
        _ProjectMaterialConfirmationTileStyle(
          foreground: colorScheme.onSurfaceVariant,
          background: colorScheme.surfaceContainerLowest,
          border: colorScheme.outlineVariant,
          pillForeground: colorScheme.onSurfaceVariant,
          pillBackground: colorScheme.surfaceContainerHighest,
        ),
      _ProjectMaterialConfirmationStatus.unsubmitted =>
        _ProjectMaterialConfirmationTileStyle(
          foreground: colorScheme.onSurfaceVariant,
          background: colorScheme.surfaceContainerLowest,
          border: colorScheme.outlineVariant,
          pillForeground: colorScheme.onSurfaceVariant,
          pillBackground: colorScheme.surfaceContainerHighest,
        ),
    };
  }

  IconData _iconForKind(String kind) {
    return switch (kind) {
      _projectMaterialConfirmationEffectImage => Icons.image_outlined,
      _projectMaterialConfirmationMaterialSample => Icons.texture_outlined,
      _projectMaterialConfirmationConstructionDoc => Icons.straighten_outlined,
      _projectMaterialConfirmationEquipmentMaterialList =>
        Icons.inventory_2_outlined,
      _projectMaterialConfirmationServiceList => Icons.fact_check_outlined,
      _ => Icons.description_outlined,
    };
  }

  String _statusLabel(_ProjectMaterialConfirmationStatus status) {
    return switch (status) {
      _ProjectMaterialConfirmationStatus.unsubmitted => '未提交',
      _ProjectMaterialConfirmationStatus.pending => '待查看',
      _ProjectMaterialConfirmationStatus.confirmed => '已确认',
      _ProjectMaterialConfirmationStatus.unavailable => '暂不可读',
    };
  }
}

class _MaterialConfirmationStatusPill extends StatelessWidget {
  const _MaterialConfirmationStatusPill({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

final class _ProjectMaterialConfirmationTileStyle {
  const _ProjectMaterialConfirmationTileStyle({
    required this.foreground,
    required this.background,
    required this.border,
    required this.pillForeground,
    required this.pillBackground,
  });

  final Color foreground;
  final Color background;
  final Color border;
  final Color pillForeground;
  final Color pillBackground;
}
