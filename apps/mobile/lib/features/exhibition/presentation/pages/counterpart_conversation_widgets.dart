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
    final nickname = data.counterpart.displayName.trim();
    final displayName = nickname.isEmpty ? '未命名对方' : nickname;
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
                    ? Text(displayName.characters.first)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    displayName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '昵称',
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

class _CounterpartProjectEntryList extends StatelessWidget {
  const _CounterpartProjectEntryList({
    required this.groups,
    required this.onOpenProjectCommunication,
  });

  final List<CounterpartConversationProjectGroupView> groups;
  final ValueChanged<CounterpartConversationProjectGroupView>
  onOpenProjectCommunication;

  @override
  Widget build(BuildContext context) {
    return _ActionCard(
      title: '项目列表',
      summary: '选择具体项目后进入此项目竞标沟通；总框不承接聊天业务。',
      children: <Widget>[
        if (groups.isEmpty)
          const _EmptyNotice(
            title: '当前没有项目入口',
            message: '这个对方主体下暂时没有可展示的项目沟通事项。',
          )
        else
          for (final group in groups)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _CounterpartProjectEntryTile(
                group: group,
                onOpen: () => onOpenProjectCommunication(group),
              ),
            ),
      ],
    );
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
                  ? '进入后可申请查看项目名称，并继续项目聊天、订单入口和项目相册。'
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
    required this.nameAccessCard,
    required this.orderId,
    required this.onBackToProjectList,
    required this.onOpenNameAccess,
    required this.onOpenOrder,
    required this.onOpenProjectAlbum,
  });

  final CounterpartConversationProjectGroupView group;
  final CounterpartConversationBusinessCardView? nameAccessCard;
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
          label: '项目名称查看申请 / 审核',
          enabled: nameAccessCard != null,
          disabledMessage: '当前项目暂无名称查看申请或审核入口。',
          onPressed: nameAccessCard == null
              ? null
              : () => onOpenNameAccess(nameAccessCard!),
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
