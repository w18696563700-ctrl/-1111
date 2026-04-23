part of 'messages_page.dart';

class _MessagesInboxTabBar extends StatelessWidget {
  const _MessagesInboxTabBar({
    required this.selectedTab,
    required this.onSelectTab,
  });

  final _MessagesInteractionTab selectedTab;
  final ValueChanged<_MessagesInteractionTab> onSelectTab;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: _MessagesInteractionTab.values.map((tab) {
          final selected = tab == selectedTab;
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => onSelectTab(tab),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: selected
                      ? theme.colorScheme.primaryContainer
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      _tabLabel(tab),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: selected
                            ? FontWeight.w900
                            : FontWeight.w700,
                        color: selected
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: selected ? 24 : 10,
                      height: 4,
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

class _MessagesInteractionCard extends StatelessWidget {
  const _MessagesInteractionCard({
    required this.item,
    required this.sourceActionLabel,
    required this.showQuickReply,
    required this.onOpenSource,
  });

  final ForumInteractionInboxItemView item;
  final String sourceActionLabel;
  final bool showQuickReply;
  final VoidCallback onOpenSource;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actorName = forumDisplayActorName(item.actor.displayName);
    final createdAt = forumDisplayTimeLabel(item.createdAt);
    final title = forumDisplayInteractionTitle(
      rawTitle: item.title,
      targetType: item.targetType,
      topicId: item.targetType == 'forum_topic' ? item.targetId : null,
    );
    final preview = forumDisplayInteractionPreview(item.preview);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: item.unread
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.32)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _MessagesMetaPill(label: actorName),
                _MessagesMetaPill(label: _targetTypeLabel(item.targetType)),
                if (item.unread) const _MessagesMetaPill(label: '未读'),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            if (preview != null && preview.isNotEmpty) ...<Widget>[
              const SizedBox(height: 10),
              Text(
                preview,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              '发生时间：$createdAt',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                FilledButton.tonalIcon(
                  onPressed: onOpenSource,
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: Text(sourceActionLabel),
                ),
                if (showQuickReply)
                  OutlinedButton.icon(
                    onPressed: onOpenSource,
                    icon: const Icon(Icons.reply_rounded),
                    label: const Text('继续回复'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MessagesProjectCommunicationSection extends StatelessWidget {
  const _MessagesProjectCommunicationSection({
    required this.loading,
    required this.result,
    required this.items,
    required this.onOpen,
  });

  final bool loading;
  final MessageInteractionListResult? result;
  final List<MessageInteractionItemView> items;
  final ValueChanged<MessageInteractionItemView> onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '项目沟通',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            if (loading) ...<Widget>[
              const SizedBox(height: 12),
              const LinearProgressIndicator(minHeight: 6),
            ] else if (result?.state == AppPageState.errorRetryable ||
                result?.state == AppPageState.errorNonRetryable ||
                result?.state == AppPageState.unauthorized ||
                result?.state == AppPageState.forbidden ||
                result?.state == AppPageState.notFound) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                result?.message ?? '当前项目沟通入口暂不可用，请稍后再试。',
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
              ),
            ] else if (items.isEmpty) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                '当前还没有新的项目沟通会话。',
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
              ),
            ] else
              ...items.map(
                (MessageInteractionItemView item) => Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: _MessagesProjectCommunicationCard(
                    item: item,
                    onOpen: () => onOpen(item),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MessagesProjectCommunicationCard extends StatelessWidget {
  const _MessagesProjectCommunicationCard({
    required this.item,
    required this.onOpen,
  });

  final MessageInteractionItemView item;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _MessagesMetaPill(label: _projectCounterpartRoleLabel(item.counterpart.role)),
                _MessagesMetaPill(label: item.seedSummary.title),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              item.counterpart.displayName,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(item.seedSummary.summary, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text(
              item.lastMessageSummary?.text ?? '当前竞标已提交，可直接进入沟通。',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: onOpen,
              icon: const Icon(Icons.chat_bubble_outline_rounded),
              label: const Text('进入沟通'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessagesTabHintCard extends StatelessWidget {
  const _MessagesTabHintCard({required this.currentTab});

  final _MessagesInteractionTab currentTab;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Text(
          _tabHint(currentTab),
          style: theme.textTheme.bodySmall?.copyWith(
            height: 1.45,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _MessagesInteractionStateCard extends StatelessWidget {
  const _MessagesInteractionStateCard({
    required this.loading,
    required this.state,
    required this.onRetry,
    required this.currentTab,
    this.message,
  });

  final bool loading;
  final AppPageState? state;
  final VoidCallback onRetry;
  final _MessagesInteractionTab currentTab;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final resolved = loading
        ? AppPageState.loading
        : state ?? AppPageState.loading;
    final tabLabel = _tabLabel(currentTab);
    final title = switch (resolved) {
      AppPageState.loading => '正在加载$tabLabel',
      AppPageState.empty => '${_tabLabel(currentTab)}当前为空',
      AppPageState.errorRetryable => message ?? '$tabLabel暂时没有加载出来',
      AppPageState.errorNonRetryable => message ?? '$tabLabel暂不可用',
      AppPageState.unauthorized => message ?? '请先登录后查看$tabLabel',
      AppPageState.forbidden => message ?? '当前账号暂不能查看$tabLabel',
      AppPageState.notFound => message ?? '$tabLabel入口暂不可用',
      AppPageState.content => '$tabLabel已准备好',
    };
    final body = switch (resolved) {
      AppPageState.loading => '请稍候片刻。',
      AppPageState.empty => _tabHint(currentTab),
      AppPageState.errorRetryable => '你可以稍后重试。',
      AppPageState.errorNonRetryable => '当前暂时还不能查看，请稍后再试。',
      AppPageState.unauthorized => '登录后可以继续查看。',
      AppPageState.forbidden => '当前账号暂时没有查看权限。',
      AppPageState.notFound => _notFoundHint(currentTab),
      AppPageState.content => '$tabLabel已经可以继续查看。',
    };

    return _MessagesStaticCard(
      title: title,
      body: body,
      trailing: resolved == AppPageState.loading
          ? const LinearProgressIndicator(minHeight: 6)
          : (resolved == AppPageState.content || resolved == AppPageState.empty)
          ? null
          : FilledButton.tonal(onPressed: onRetry, child: const Text('重试')),
    );
  }
}

class _MessagesStaticCard extends StatelessWidget {
  const _MessagesStaticCard({
    required this.title,
    required this.body,
    this.trailing,
  });

  final String title;
  final String body;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(
              body,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
            if (trailing != null) ...<Widget>[
              const SizedBox(height: 14),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

class _MessagesMetaPill extends StatelessWidget {
  const _MessagesMetaPill({required this.label});

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
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

String _tabKey(_MessagesInteractionTab tab) {
  return switch (tab) {
    _MessagesInteractionTab.replies => 'replies',
    _MessagesInteractionTab.likes => 'likes',
    _MessagesInteractionTab.follows => 'follows',
  };
}

String _tabLabel(_MessagesInteractionTab tab) {
  return switch (tab) {
    _MessagesInteractionTab.replies => '回复我的',
    _MessagesInteractionTab.likes => '收到的赞',
    _MessagesInteractionTab.follows => '新关注',
  };
}

String _targetTypeLabel(String targetType) {
  return forumDisplayInteractionTargetType(targetType);
}

String _tabHint(_MessagesInteractionTab tab) {
  return switch (tab) {
    _MessagesInteractionTab.replies => '这里只显示别人回复你的帖子或评论；你自己发表评论，不会进入“回复我的”。',
    _MessagesInteractionTab.likes => '这里只显示别人给你的帖子或评论点的赞。',
    _MessagesInteractionTab.follows => '这里只显示已经进入消息楼的新关注提醒。',
  };
}

String _notFoundHint(_MessagesInteractionTab tab) {
  return switch (tab) {
    _MessagesInteractionTab.replies => '当前“回复我的”入口暂不可用，请稍后再试。',
    _MessagesInteractionTab.likes => '当前“收到的赞”入口暂不可用，请稍后再试。',
    _MessagesInteractionTab.follows => '当前“新关注”入口暂不可用，请稍后再试。',
  };
}

String _sourceActionLabel(String targetType) {
  return targetType == 'forum_comment' ? '查看说明' : '回到源对象';
}

String _projectCounterpartRoleLabel(String role) {
  return switch (role) {
    'project_owner' => '项目方',
    'bidder' => '竞标方',
    _ => role,
  };
}
