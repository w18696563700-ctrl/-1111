part of '../exhibition_trade_pages.dart';

class _CounterpartConversationHeader extends StatelessWidget {
  const _CounterpartConversationHeader({
    required this.data,
    required this.onOpenSubjectCard,
    required this.canOpenSubjectCard,
    this.title = '项目沟通',
  });

  final CounterpartConversationDetailView data;
  final VoidCallback onOpenSubjectCard;
  final bool canOpenSubjectCard;
  final String title;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = data.counterpart.avatarUrl?.trim();
    final nickname = data.counterpart.nickname?.trim() ?? '';
    final companyName = data.counterpart.companyName.trim().isNotEmpty
        ? data.counterpart.companyName.trim()
        : data.counterpart.displayName.trim();
    final primaryLabel = nickname.isNotEmpty
        ? nickname
        : (companyName.isNotEmpty ? companyName : '未命名对方');
    final secondaryLabel = nickname.isNotEmpty && companyName.isNotEmpty
        ? companyName
        : '企业主体';
    return _ActionCard(
      title: title,
      tone: _ActionCardTone.emphasis,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: canOpenSubjectCard ? onOpenSubjectCard : null,
              child: CircleAvatar(
                radius: 24,
                backgroundImage: avatarUrl == null || avatarUrl.isEmpty
                    ? null
                    : NetworkImage(avatarUrl),
                child: avatarUrl == null || avatarUrl.isEmpty
                    ? Text(primaryLabel.characters.first)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    primaryLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    secondaryLabel,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CounterpartProjectEntryList extends StatefulWidget {
  const _CounterpartProjectEntryList({
    required this.groups,
    required this.onOpenProjectCommunication,
  });

  final List<CounterpartConversationProjectGroupView> groups;
  final ValueChanged<CounterpartConversationProjectGroupView>
  onOpenProjectCommunication;

  @override
  State<_CounterpartProjectEntryList> createState() =>
      _CounterpartProjectEntryListState();
}

class _CounterpartProjectEntryListState
    extends State<_CounterpartProjectEntryList> {
  String? _selectedRelation;

  @override
  Widget build(BuildContext context) {
    final relationGroups =
        <String, List<CounterpartConversationProjectGroupView>>{
          'my_published': widget.groups
              .where((group) => group.projectRelation == 'my_published')
              .toList(growable: false),
          'my_bid': widget.groups
              .where((group) => group.projectRelation == 'my_bid')
              .toList(growable: false),
          'unknown': widget.groups
              .where((group) => group.projectRelation == 'unknown')
              .toList(growable: false),
        };
    final availableRelations = relationGroups.entries
        .where((entry) => entry.value.isNotEmpty)
        .map((entry) => entry.key)
        .toList(growable: false);
    final selectedRelation = availableRelations.contains(_selectedRelation)
        ? _selectedRelation!
        : (availableRelations.isEmpty ? 'unknown' : availableRelations.first);
    final visibleGroups =
        relationGroups[selectedRelation] ??
        const <CounterpartConversationProjectGroupView>[];
    return _ActionCard(
      title: '项目列表',
      summary: '选择具体项目后进入此项目竞标沟通；总框不承接聊天业务。',
      children: <Widget>[
        if (widget.groups.isEmpty)
          const _EmptyNotice(
            title: '当前没有项目入口',
            message: '这个对方主体下暂时没有可展示的项目沟通事项。',
          )
        else ...<Widget>[
          if (availableRelations.length > 1) ...<Widget>[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (final relation in availableRelations)
                  ChoiceChip(
                    label: Text(
                      '${_projectRelationLabel(relation)} · ${relationGroups[relation]!.length}',
                    ),
                    selected: relation == selectedRelation,
                    onSelected: (_) =>
                        setState(() => _selectedRelation = relation),
                  ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          for (final group in visibleGroups)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _CounterpartProjectEntryTile(
                group: group,
                onOpen: () => widget.onOpenProjectCommunication(group),
              ),
            ),
        ],
      ],
    );
  }

  String _projectRelationLabel(String relation) {
    return switch (relation) {
      'my_published' => '我的发布',
      'my_bid' => '我的竞标',
      _ => '其他项目',
    };
  }
}

class _CounterpartProjectEntryTile extends StatelessWidget {
  const _CounterpartProjectEntryTile({
    required this.group,
    required this.onOpen,
  });

  final CounterpartConversationProjectGroupView group;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maskedTitle = group.titleVisibility == 'masked';
    const maskedTitleColor = Color(0xFF1F7A3A);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _ConversationPill(
                  label: _projectStateLabel(group.projectState),
                ),
                _ConversationPill(label: '${group.cards.length} 项业务'),
              ],
            ),
            const SizedBox(height: 8),
            if (maskedTitle)
              Row(
                children: <Widget>[
                  const Icon(
                    Icons.lock_outline_rounded,
                    size: 16,
                    color: maskedTitleColor,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      group.projectDisplayTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: maskedTitleColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              )
            else
              Text(
                group.projectDisplayTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            const SizedBox(height: 6),
            Text(
              maskedTitle
                  ? '进入后可处理参与竞标申请，并继续项目聊天、订单入口和项目相册。'
                  : '进入后可继续项目聊天、订单入口和项目相册。',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: onOpen,
              icon: const Icon(Icons.forum_outlined),
              label: const Text('进入此项目竞标沟通'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedProjectBusinessEntrypoints extends StatelessWidget {
  const _SelectedProjectBusinessEntrypoints({
    required this.group,
    required this.participationCard,
    required this.orderId,
    required this.onBackToProjectList,
    required this.onOpenNameAccess,
    required this.onOpenOrder,
    required this.onOpenProjectAlbum,
  });

  final CounterpartConversationProjectGroupView group;
  final CounterpartConversationBusinessCardView? participationCard;
  final String? orderId;
  final VoidCallback onBackToProjectList;
  final ValueChanged<CounterpartConversationBusinessCardView> onOpenNameAccess;
  final VoidCallback onOpenOrder;
  final VoidCallback onOpenProjectAlbum;

  @override
  Widget build(BuildContext context) {
    return _ActionCard(
      title: group.projectDisplayTitle,
      summary: '当前页只保留项目级业务入口；订单状态与项目相册进入受控页面查看。',
      children: <Widget>[
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onBackToProjectList,
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('返回项目列表'),
          ),
        ),
        const SizedBox(height: 8),
        _ProjectBusinessEntryButton(
          icon: Icons.fact_check_outlined,
          label: '参与竞标申请 / 审核',
          enabled: participationCard != null,
          disabledMessage: '当前项目暂无参与竞标申请或审核入口。',
          onPressed: participationCard == null
              ? null
              : () => onOpenNameAccess(participationCard!),
        ),
        const SizedBox(height: 10),
        _ProjectBusinessEntryButton(
          icon: Icons.receipt_long_outlined,
          label: '订单状态',
          enabled: orderId != null,
          disabledMessage: '当前项目暂无订单状态入口。',
          onPressed: orderId == null ? null : onOpenOrder,
        ),
        const SizedBox(height: 10),
        _ProjectBusinessEntryButton(
          icon: Icons.photo_library_outlined,
          label: '项目相册',
          enabled: true,
          disabledMessage: '',
          onPressed: onOpenProjectAlbum,
        ),
      ],
    );
  }
}

class _ProjectBusinessEntryButton extends StatelessWidget {
  const _ProjectBusinessEntryButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.disabledMessage,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final String disabledMessage;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        FilledButton.tonalIcon(
          onPressed: enabled ? onPressed : null,
          icon: Icon(icon),
          label: Text(label),
        ),
        if (!enabled) ...<Widget>[
          const SizedBox(height: 6),
          Text(
            disabledMessage,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _ConversationPill extends StatelessWidget {
  const _ConversationPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

String _projectStateLabel(String? value) {
  return switch (value) {
    'published' => '已发布',
    'bidding' => '竞标中',
    'converted_to_order' => '已转订单',
    'completed' => '已完成',
    'closed' => '已关闭',
    null => '项目',
    _ => value,
  };
}
