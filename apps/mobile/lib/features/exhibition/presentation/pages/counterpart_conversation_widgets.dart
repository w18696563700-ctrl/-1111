part of '../exhibition_trade_pages.dart';

class _CounterpartConversationHeader extends StatelessWidget {
  const _CounterpartConversationHeader({
    required this.data,
    required this.onOpenSubjectCard,
    required this.canOpenSubjectCard,
  });

  final CounterpartConversationDetailView data;
  final VoidCallback onOpenSubjectCard;
  final bool canOpenSubjectCard;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = data.counterpart.avatarUrl?.trim();
    final nickname = data.counterpart.displayName.trim();
    final title = nickname.isEmpty ? '未命名对方' : nickname;
    return _ActionCard(
      title: '项目沟通',
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
                    ? Text(title.characters.first)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
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

class _CounterpartProjectGroupSection extends StatelessWidget {
  const _CounterpartProjectGroupSection({
    required this.group,
    required this.onOpenCard,
  });

  final CounterpartConversationProjectGroupView group;
  final ValueChanged<CounterpartConversationBusinessCardView> onOpenCard;

  @override
  Widget build(BuildContext context) {
    return _ActionCard(
      title: group.projectDisplayTitle,
      children: <Widget>[
        if (group.cards.isEmpty)
          const _StateMessage(title: '当前项目暂无业务卡', body: '可以下拉刷新状态。')
        else
          ...group.cards.map(
            (CounterpartConversationBusinessCardView card) => Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                width: double.infinity,
                child: _CounterpartBusinessCard(
                  card: card,
                  onOpen: () => onOpenCard(card),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CounterpartBusinessCard extends StatelessWidget {
  const _CounterpartBusinessCard({required this.card, required this.onOpen});

  final CounterpartConversationBusinessCardView card;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                _ConversationPill(label: _cardTypeLabel(card.cardType)),
                if (card.status != null)
                  _ConversationPill(label: _businessStatusLabel(card.status!)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              card.title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              card.summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
            ),
            const SizedBox(height: 10),
            FilledButton.tonalIcon(
              onPressed: onOpen,
              icon: Icon(_cardActionIcon(card.cardType)),
              label: Text(_cardActionLabel(card.cardType)),
            ),
          ],
        ),
      ),
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

String _cardTypeLabel(String type) {
  return switch (type) {
    'project_name_access_request' => '项目名称申请',
    'bid_thread' => '竞标沟通',
    'project_clarification' => '项目澄清',
    'project_order' => '订单状态',
    'system_notice' => '系统通知',
    _ => type,
  };
}

String _cardActionLabel(String type) {
  return switch (type) {
    'project_name_access_request' => '查看申请',
    'bid_thread' => '进入竞标沟通',
    'project_clarification' => '查看澄清',
    'project_order' => '查看订单',
    _ => '查看详情',
  };
}

IconData _cardActionIcon(String type) {
  return switch (type) {
    'project_name_access_request' => Icons.fact_check_outlined,
    'bid_thread' => Icons.chat_bubble_outline_rounded,
    'project_clarification' => Icons.help_outline_rounded,
    'project_order' => Icons.receipt_long_outlined,
    _ => Icons.open_in_new_rounded,
  };
}

String _businessStatusLabel(String value) {
  return switch (value) {
    'pending' => '待审批',
    'approved' => '已通过',
    'rejected' => '已拒绝',
    'open' => '进行中',
    'submitted' => '已提交',
    'active' => '履约中',
    'completed' => '已完成',
    'requested' => '待确认完工',
    'confirmed' => '已确认',
    'none' => '未申请',
    _ => value,
  };
}
