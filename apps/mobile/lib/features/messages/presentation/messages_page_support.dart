part of 'messages_page.dart';

class _MessagesInboxTabBar extends StatelessWidget {
  const _MessagesInboxTabBar({
    required this.selectedTab,
    required this.onSelectTab,
  });

  final _MessagesInteractionTab? selectedTab;
  final ValueChanged<_MessagesInteractionTab> onSelectTab;

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
        children: _MessagesInteractionTab.values.map((tab) {
          final selected = tab == selectedTab;
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => onSelectTab(tab),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
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
                    const SizedBox(height: 5),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: selected ? 24 : 10,
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

class _MessagesInteractionCard extends StatelessWidget {
  const _MessagesInteractionCard({
    required this.item,
    required this.onOpenSource,
  });

  final ForumInteractionInboxItemView item;
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

    return Material(
      color: item.unread
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.32)
          : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(24),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onOpenSource,
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 22,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
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
            ],
          ),
        ),
      ),
    );
  }
}

class _MessagesForumInteractionSection extends StatelessWidget {
  const _MessagesForumInteractionSection({
    required this.selectedTab,
    required this.onSelectTab,
    required this.loading,
    required this.state,
    required this.items,
    required this.onRetry,
    required this.onOpenSource,
    this.message,
  });

  final _MessagesInteractionTab? selectedTab;
  final ValueChanged<_MessagesInteractionTab> onSelectTab;
  final bool loading;
  final AppPageState? state;
  final String? message;
  final List<ForumInteractionInboxItemView> items;
  final VoidCallback onRetry;
  final ValueChanged<ForumInteractionInboxItemView> onOpenSource;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedTab = this.selectedTab;
    final showState =
        selectedTab != null &&
        (loading || (state != null && state != AppPageState.content));
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              '论坛互动',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            _MessagesInboxTabBar(
              selectedTab: selectedTab,
              onSelectTab: onSelectTab,
            ),
            const SizedBox(height: 12),
            if (selectedTab == null)
              const _MessagesInlinePanel(
                title: '选择一个分类查看',
                body: '点击“回复我的”“收到的赞”或“新关注”后，再展开对应提醒列表。',
              )
            else if (showState)
              _MessagesInteractionStatePanel(
                loading: loading,
                state: state,
                onRetry: onRetry,
                currentTab: selectedTab,
                message: message,
              )
            else if (items.isEmpty)
              _MessagesInlinePanel(
                title: '${_tabLabel(selectedTab)}当前为空',
                body: '暂无新的${_tabLabel(selectedTab)}提醒。',
              )
            else
              ...items.map(
                (ForumInteractionInboxItemView item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _MessagesInteractionCard(
                    item: item,
                    onOpenSource: () => onOpenSource(item),
                  ),
                ),
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
              const SizedBox(height: 10),
              const LinearProgressIndicator(minHeight: 5),
            ] else if (result?.state == AppPageState.errorRetryable ||
                result?.state == AppPageState.errorNonRetryable ||
                result?.state == AppPageState.unauthorized ||
                result?.state == AppPageState.forbidden ||
                result?.state == AppPageState.notFound) ...<Widget>[
              const SizedBox(height: 10),
              _MessagesInlinePanel(
                title: '项目沟通暂不可用',
                body: result?.message ?? '请稍后再试。',
              ),
            ] else if (items.isEmpty) ...<Widget>[
              const SizedBox(height: 10),
              const _MessagesInlinePanel(
                title: '当前没有新的项目沟通',
                body: '有新的项目沟通后会在这里进入。',
              ),
            ] else
              ...items.map(
                (MessageInteractionItemView item) => Padding(
                  padding: const EdgeInsets.only(top: 10),
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

class _MessagesNotificationCenterSection extends StatelessWidget {
  const _MessagesNotificationCenterSection({
    required this.loading,
    required this.expanded,
    required this.result,
    required this.onToggleExpanded,
    required this.onOpen,
    required this.onRetry,
  });

  final bool loading;
  final bool expanded;
  final AppNotificationListResult? result;
  final VoidCallback onToggleExpanded;
  final ValueChanged<AppNotificationItemView> onOpen;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = result?.data?.items ?? const <AppNotificationItemView>[];
    return Material(
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onToggleExpanded,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 10,
                ),
                child: Row(
                  children: <Widget>[
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.58,
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          Icons.notifications_none_rounded,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '消息中心',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '重要通知、项目沟通等消息',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
            if (expanded) ...<Widget>[
              const SizedBox(height: 12),
              if (loading)
                const LinearProgressIndicator(minHeight: 5)
              else if (_notificationFailed(result)) ...<Widget>[
                _MessagesInlinePanel(
                  title: '消息中心暂不可用',
                  body: result?.message ?? '请稍后再试。',
                  trailing: FilledButton.tonal(
                    onPressed: onRetry,
                    child: const Text('重试'),
                  ),
                ),
              ] else if (items.isEmpty)
                const _MessagesInlinePanel(
                  title: '暂无新的消息',
                  body: '项目沟通、论坛互动和系统提醒会汇总在这里。',
                )
              else
                ...items
                    .take(5)
                    .map(
                      (AppNotificationItemView item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _MessagesNotificationCard(
                          item: item,
                          onOpen: () => onOpen(item),
                        ),
                      ),
                    ),
            ],
          ],
        ),
      ),
    );
  }

  bool _notificationFailed(AppNotificationListResult? result) {
    final state = result?.state;
    return state == AppPageState.errorRetryable ||
        state == AppPageState.errorNonRetryable ||
        state == AppPageState.unauthorized ||
        state == AppPageState.forbidden ||
        state == AppPageState.notFound;
  }
}

class _MessagesNotificationCard extends StatelessWidget {
  const _MessagesNotificationCard({required this.item, required this.onOpen});

  final AppNotificationItemView item;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: item.unread
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.14)
          : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.42,
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(9),
                  child: Icon(
                    _notificationIcon(item.source),
                    size: 22,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _MessagesMetaPill(label: _notificationSource(item.source)),
                    const SizedBox(height: 6),
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (item.body != null) ...<Widget>[
                      const SizedBox(height: 4),
                      Text(
                        item.body!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  if (_relativeCreatedAt(item.createdAt) != null) ...<Widget>[
                    const SizedBox(height: 16),
                    Text(
                      _relativeCreatedAt(item.createdAt)!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _notificationIcon(String source) {
    return switch (source) {
      'project_communication' => Icons.forum_outlined,
      'forum_interaction' => Icons.dynamic_feed_outlined,
      _ => Icons.notifications_none_rounded,
    };
  }

  String _notificationSource(String source) {
    return switch (source) {
      'project_communication' => '项目沟通',
      'forum_interaction' => '论坛互动',
      _ => '系统提醒',
    };
  }

  String? _relativeCreatedAt(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    final createdAt = DateTime.tryParse(raw.trim());
    if (createdAt == null) {
      return null;
    }
    final now = DateTime.now();
    final delta = now.difference(createdAt.toLocal());
    if (delta.inMinutes < 1) {
      return '刚刚';
    }
    if (delta.inMinutes < 60) {
      return '${delta.inMinutes} 分钟前';
    }
    if (delta.inHours < 24) {
      return '${delta.inHours} 小时前';
    }
    if (delta.inDays < 7) {
      return '${delta.inDays} 天前';
    }
    return '${createdAt.month}月${createdAt.day}日';
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
    final identity = item.counterpart;
    final nickname = identity.nickname?.trim() ?? '';
    final companyName = identity.companyName.trim().isNotEmpty
        ? identity.companyName.trim()
        : identity.displayName.trim();
    final primaryLabel = nickname.isNotEmpty
        ? nickname
        : (companyName.isNotEmpty ? companyName : '对方主体');
    final secondaryLabel = nickname.isNotEmpty && companyName.isNotEmpty
        ? '$companyName · 项目 ${item.summary.projectCount} 个'
        : '项目 ${item.summary.projectCount} 个';
    final avatarUrl = identity.avatarUrl?.trim();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  backgroundImage: avatarUrl == null || avatarUrl.isEmpty
                      ? null
                      : NetworkImage(avatarUrl),
                  child: avatarUrl == null || avatarUrl.isEmpty
                      ? Text(
                          primaryLabel.characters.first,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w900,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        primaryLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        secondaryLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(38),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: onOpen,
                icon: const Icon(Icons.forum_outlined),
                label: Text(_projectCommunicationOpenLabel(item)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessagesInteractionStatePanel extends StatelessWidget {
  const _MessagesInteractionStatePanel({
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
      AppPageState.notFound => '互动通知暂不可用',
      AppPageState.content => '$tabLabel已准备好',
    };
    final body = switch (resolved) {
      AppPageState.loading => '请稍候片刻。',
      AppPageState.empty => '暂无新的$tabLabel提醒。',
      AppPageState.errorRetryable => '你可以稍后重试。',
      AppPageState.errorNonRetryable => '当前暂时还不能查看，请稍后再试。',
      AppPageState.unauthorized => '登录后可以继续查看。',
      AppPageState.forbidden => '当前账号暂时没有查看权限。',
      AppPageState.notFound => _notFoundHint(currentTab),
      AppPageState.content => '$tabLabel已经可以继续查看。',
    };

    return _MessagesInlinePanel(
      title: title,
      body: body,
      trailing: resolved == AppPageState.loading
          ? const LinearProgressIndicator(minHeight: 5)
          : (resolved == AppPageState.content || resolved == AppPageState.empty)
          ? null
          : FilledButton.tonal(onPressed: onRetry, child: const Text('重试')),
    );
  }
}

class _MessagesInlinePanel extends StatelessWidget {
  const _MessagesInlinePanel({
    required this.title,
    required this.body,
    this.trailing,
  });

  final String title;
  final String body;
  final Widget? trailing;

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
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              body,
              style: theme.textTheme.bodySmall?.copyWith(
                height: 1.45,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (trailing != null) ...<Widget>[
              const SizedBox(height: 12),
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

String _notFoundHint(_MessagesInteractionTab tab) {
  return switch (tab) {
    _MessagesInteractionTab.replies => '当前“回复我的”入口暂不可用，请稍后再试。',
    _MessagesInteractionTab.likes => '当前“收到的赞”入口暂不可用，请稍后再试。',
    _MessagesInteractionTab.follows => '当前“新关注”入口暂不可用，请稍后再试。',
  };
}

String _projectCommunicationOpenLabel(MessageInteractionItemView item) {
  return switch (item.interactionType) {
    'counterpart_conversation' => '进入项目沟通',
    _ => '进入沟通',
  };
}
