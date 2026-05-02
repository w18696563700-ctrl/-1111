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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
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
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.16)),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[colorScheme.surface, const Color(0xFFFFF6E8)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const _ConversationGuideHint(),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: <Widget>[
                InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: canOpenSubjectCard ? onOpenSubjectCard : null,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: colorScheme.primaryContainer,
                    backgroundImage: avatarUrl == null || avatarUrl.isEmpty
                        ? null
                        : NetworkImage(avatarUrl),
                    child: avatarUrl == null || avatarUrl.isEmpty
                        ? Text(
                            primaryLabel.characters.first,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        primaryLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        secondaryLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const _ConversationDecorativeBubbles(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationGuideHint extends StatelessWidget {
  const _ConversationGuideHint();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          Icons.assignment_outlined,
          size: 18,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 6),
        Text(
          '沟通指南',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _ConversationDecorativeBubbles extends StatelessWidget {
  const _ConversationDecorativeBubbles();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary.withValues(alpha: 0.16);
    return SizedBox(
      width: 112,
      height: 72,
      child: Stack(
        children: <Widget>[
          Positioned(
            right: 4,
            top: 4,
            child: _ConversationBubbleIcon(size: 58, color: color),
          ),
          Positioned(
            left: 10,
            bottom: 4,
            child: _ConversationBubbleIcon(
              size: 42,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.10),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationBubbleIcon extends StatelessWidget {
  const _ConversationBubbleIcon({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: SizedBox(
        width: size,
        height: size * 0.72,
        child: Icon(
          Icons.more_horiz_rounded,
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.42),
          size: size * 0.46,
        ),
      ),
    );
  }
}

class _ProjectConversationHeaderCard extends StatelessWidget {
  const _ProjectConversationHeaderCard({
    required this.data,
    required this.group,
    required this.thread,
    required this.currentOrganizationId,
    required this.currentDisplayName,
    required this.currentAvatarUrl,
    this.onOpenSubjectCard,
    this.canOpenSubjectCard = false,
  });

  final CounterpartConversationDetailView data;
  final CounterpartConversationProjectGroupView group;
  final ProjectCommunicationThreadView? thread;
  final String? currentOrganizationId;
  final String? currentDisplayName;
  final String? currentAvatarUrl;
  final VoidCallback? onOpenSubjectCard;
  final bool canOpenSubjectCard;

  @override
  Widget build(BuildContext context) {
    final ownerOrgId = thread?.ownerOrganizationId;
    final counterpartOrgId = thread?.counterpartOrganizationId;
    final currentOrgId = currentOrganizationId?.trim();
    final ownerIsCurrent = ownerOrgId != null && ownerOrgId == currentOrgId;
    final bidderIsCurrent =
        counterpartOrgId != null && counterpartOrgId == currentOrgId;
    final ownerName = ownerIsCurrent ? _currentName : _counterpartName;
    final bidderName = bidderIsCurrent ? _currentName : _counterpartName;
    final ownerAvatar = ownerIsCurrent
        ? currentAvatarUrl
        : data.counterpart.avatarUrl;
    final bidderAvatar = bidderIsCurrent
        ? currentAvatarUrl
        : data.counterpart.avatarUrl;
    return _ActionCard(
      title: '当前项目沟通',
      tone: _ActionCardTone.emphasis,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: _ConversationPartyBlock(
                name: ownerName,
                roleLabel: '发布方',
                avatarUrl: ownerAvatar,
                badgeColor: const Color(0xFFE8F0FF),
                badgeTextColor: const Color(0xFF245BA7),
                onTap: !ownerIsCurrent && canOpenSubjectCard
                    ? onOpenSubjectCard
                    : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                children: <Widget>[
                  Text(
                    group.projectDisplayTitle,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const _ConversationPill(
                    label: '竞标沟通中',
                    foregroundColor: Color(0xFF2E6F43),
                    backgroundColor: Color(0xFFE7F5EA),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ConversationPartyBlock(
                name: bidderName,
                roleLabel: '竞标方',
                avatarUrl: bidderAvatar,
                badgeColor: const Color(0xFFE7F5EA),
                badgeTextColor: const Color(0xFF2E6F43),
                onTap: !bidderIsCurrent && canOpenSubjectCard
                    ? onOpenSubjectCard
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String get _counterpartName {
    final nickname = data.counterpart.nickname?.trim();
    if (nickname != null && nickname.isNotEmpty) {
      return nickname;
    }
    final company = data.counterpart.companyName.trim();
    if (company.isNotEmpty) {
      return company;
    }
    return data.counterpart.displayName.trim().isEmpty
        ? '对方主体'
        : data.counterpart.displayName.trim();
  }

  String get _currentName {
    final normalized = currentDisplayName?.trim();
    return normalized == null || normalized.isEmpty ? '我方主体' : normalized;
  }
}

class _ConversationPartyBlock extends StatelessWidget {
  const _ConversationPartyBlock({
    required this.name,
    required this.roleLabel,
    required this.avatarUrl,
    required this.badgeColor,
    required this.badgeTextColor,
    this.onTap,
  });

  final String name;
  final String roleLabel;
  final String? avatarUrl;
  final Color badgeColor;
  final Color badgeTextColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final normalizedAvatar = avatarUrl?.trim();
    final content = Column(
      children: <Widget>[
        _ConversationPill(
          label: roleLabel,
          backgroundColor: badgeColor,
          foregroundColor: badgeTextColor,
        ),
        const SizedBox(height: 10),
        CircleAvatar(
          radius: 24,
          backgroundImage: normalizedAvatar == null || normalizedAvatar.isEmpty
              ? null
              : NetworkImage(normalizedAvatar),
          child: normalizedAvatar == null || normalizedAvatar.isEmpty
              ? Text(name.trim().isEmpty ? '?' : name.characters.first)
              : null,
        ),
        const SizedBox(height: 8),
        Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w900,
            height: 1.2,
          ),
        ),
      ],
    );
    if (onTap == null) {
      return content;
    }
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: content,
      ),
    );
  }
}

class _ConversationGuidanceBanner extends StatelessWidget {
  const _ConversationGuidanceBanner();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEED3A5)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              Icons.tips_and_updates_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '请尽量围绕当前项目在平台内沟通，便于留存关键记录，方便后续协同与核验。',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CounterpartProjectEntryList extends StatefulWidget {
  const _CounterpartProjectEntryList({
    required this.data,
    required this.groups,
    required this.onOpenProjectCommunication,
  });

  final CounterpartConversationDetailView data;
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
  String _searchQuery = '';

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
    final filteredGroups = _filterGroups(visibleGroups, _searchQuery);
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            LayoutBuilder(
              builder: (context, constraints) {
                final searchField = SizedBox(
                  width: constraints.maxWidth >= 560 ? 260 : double.infinity,
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search_rounded),
                      hintText: '搜索项目名称',
                      isDense: true,
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                );
                final heading = Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '项目列表',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '选择具体项目后进入此项目竞标沟通；总框不承接聊天业务。',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                );
                if (constraints.maxWidth < 560) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(children: <Widget>[heading]),
                      const SizedBox(height: 14),
                      searchField,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    heading,
                    const SizedBox(width: 16),
                    searchField,
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            if (widget.groups.isEmpty)
              const _EmptyNotice(
                title: '当前没有项目入口',
                message: '这个对方主体下暂时没有可展示的项目沟通事项。',
              )
            else ...<Widget>[
              if (availableRelations.isNotEmpty) ...<Widget>[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    for (final relation in availableRelations)
                      ChoiceChip(
                        avatar: Icon(_projectRelationIcon(relation), size: 18),
                        label: Text(
                          _projectRelationChipLabel(
                            relation,
                            relationGroups[relation]!.length,
                          ),
                        ),
                        selected: relation == selectedRelation,
                        onSelected: (_) =>
                            setState(() => _selectedRelation = relation),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              if (filteredGroups.isEmpty)
                const _EmptyNotice(title: '没有找到项目', message: '请换一个项目名称关键词再试。')
              else
                for (final group in filteredGroups)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _CounterpartProjectEntryTile(
                      group: group,
                      onOpen: () => widget.onOpenProjectCommunication(group),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }

  List<CounterpartConversationProjectGroupView> _filterGroups(
    List<CounterpartConversationProjectGroupView> groups,
    String query,
  ) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return groups;
    }
    return groups
        .where(
          (group) =>
              group.projectDisplayTitle.toLowerCase().contains(normalized),
        )
        .toList(growable: false);
  }

  String _projectRelationLabel(String relation) {
    return switch (relation) {
      'my_published' => '我的发布',
      'my_bid' => '我的竞标',
      _ => '其他项目',
    };
  }

  String _projectRelationChipLabel(String relation, int projectCount) {
    final unreadCount = _relationUnreadCount(relation);
    final base = '${_projectRelationLabel(relation)} · $projectCount';
    if (unreadCount <= 0) {
      return base;
    }
    return '$base · 未读 $unreadCount';
  }

  int _relationUnreadCount(String relation) {
    return switch (relation) {
      'my_published' => widget.data.myPublishedUnreadCount,
      'my_bid' => widget.data.myBidUnreadCount,
      _ => 0,
    };
  }

  IconData _projectRelationIcon(String relation) {
    return switch (relation) {
      'my_published' => Icons.send_outlined,
      'my_bid' => Icons.flag_outlined,
      _ => Icons.folder_open_outlined,
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
    final publishedAtLabel = _formatProjectTimestamp(group.projectPublishedAt);
    final latestUnreadLabel = _formatProjectTimestamp(
      group.latestUnreadMessageAt,
    );
    final hasUnread = group.hasProjectUnread && group.projectUnreadCount > 0;
    const maskedTitleColor = Color(0xFF1F7A3A);
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 390;
        final mainContent = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _ConversationPill(
                  label: _projectStateLabel(group.projectState),
                  foregroundColor: _projectStateForeground(group.projectState),
                  backgroundColor: _projectStateBackground(group.projectState),
                ),
                _ConversationPill(
                  label: '${group.cards.length} 项业务',
                  foregroundColor: const Color(0xFF1F6FB2),
                  backgroundColor: const Color(0xFFEAF4FF),
                ),
                if (group.hasProjectUnread && group.projectUnreadCount > 0)
                  _ProjectUnreadPill(
                    projectId: group.projectId,
                    count: group.projectUnreadCount,
                  ),
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            const SizedBox(height: 6),
            Text(
              maskedTitle
                  ? '进入后可处理参与竞标申请，并继续项目聊天、后续承接入口和项目相册。'
                  : '进入后可继续项目聊天、后续承接入口和项目相册。',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            if (publishedAtLabel != null) ...<Widget>[
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.schedule_rounded,
                    size: 15,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '发布时间：$publishedAtLabel',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (latestUnreadLabel != null && hasUnread) ...<Widget>[
              const SizedBox(height: 6),
              Text(
                '最新未读：$latestUnreadLabel',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ],
        );
        final actionColumn = SizedBox(
          width: compact ? double.infinity : 132,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (!compact) ...<Widget>[
                Align(
                  alignment: Alignment.center,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(
                        alpha: 0.52,
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.forum_outlined,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
              ],
              FilledButton.icon(
                onPressed: onOpen,
                icon: compact
                    ? const Icon(Icons.forum_outlined)
                    : const Icon(Icons.arrow_forward_rounded),
                label: const Text('进入沟通'),
              ),
            ],
          ),
        );
        return DecoratedBox(
          decoration: BoxDecoration(
            color: hasUnread
                ? theme.colorScheme.errorContainer.withValues(alpha: 0.16)
                : theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: hasUnread
                  ? theme.colorScheme.error.withValues(alpha: 0.64)
                  : theme.colorScheme.outlineVariant,
              width: hasUnread ? 1.4 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: compact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      mainContent,
                      const SizedBox(height: 12),
                      actionColumn,
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(child: mainContent),
                      const SizedBox(width: 16),
                      actionColumn,
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _SelectedProjectBusinessEntrypoints extends StatelessWidget {
  const _SelectedProjectBusinessEntrypoints({
    required this.group,
    required this.participationCard,
    required this.orderId,
    required this.loadingWorkbench,
    required this.workbenchResult,
    required this.onBackToProjectList,
    required this.onOpenNameAccess,
    required this.onOpenOrder,
    required this.onOpenProjectAlbum,
    required this.onOpenWorkbenchEntry,
  });

  final CounterpartConversationProjectGroupView group;
  final CounterpartConversationBusinessCardView? participationCard;
  final String? orderId;
  final bool loadingWorkbench;
  final CounterpartConversationResult<ProjectCommunicationWorkbenchView>?
  workbenchResult;
  final VoidCallback onBackToProjectList;
  final ValueChanged<CounterpartConversationBusinessCardView> onOpenNameAccess;
  final VoidCallback onOpenOrder;
  final VoidCallback onOpenProjectAlbum;
  final ValueChanged<ProjectCommunicationWorkbenchEntryView>
  onOpenWorkbenchEntry;

  @override
  Widget build(BuildContext context) {
    return _ActionCard(
      title: '项目工作入口',
      summary: '围绕当前项目完成资料审阅、合同与成交金额确认。',
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
        Row(
          children: <Widget>[
            Expanded(
              child: _ProjectBusinessEntryButton(
                icon: Icons.fact_check_outlined,
                label: '进入审核',
                enabled: participationCard != null,
                disabledMessage: '',
                onPressed: participationCard == null
                    ? null
                    : () => onOpenNameAccess(participationCard!),
                primary: true,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ProjectBusinessEntryButton(
                icon: Icons.receipt_long_outlined,
                label: '后续承接状态',
                enabled: orderId != null,
                disabledMessage: '',
                onPressed: orderId == null ? null : onOpenOrder,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ProjectBusinessEntryButton(
                icon: Icons.photo_library_outlined,
                label: '项目相册',
                enabled: true,
                disabledMessage: '',
                onPressed: onOpenProjectAlbum,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _ProjectCommunicationWorkbenchSection(
          loading: loadingWorkbench,
          result: workbenchResult,
          onOpenEntry: onOpenWorkbenchEntry,
        ),
        if (orderId == null) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            '当前项目暂无后续承接入口。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

}

class _UnknownProjectWorkbenchSection extends StatelessWidget {
  const _UnknownProjectWorkbenchSection();

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
        child: Row(
          children: <Widget>[
            Icon(
              Icons.info_outline_rounded,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '当前项目工作入口暂不可读',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
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
    this.primary = false,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final String disabledMessage;
  final VoidCallback? onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        primary
            ? FilledButton.icon(
                onPressed: enabled ? onPressed : null,
                icon: Icon(icon),
                label: Text(label, textAlign: TextAlign.center),
              )
            : FilledButton.tonalIcon(
                onPressed: enabled ? onPressed : null,
                icon: Icon(icon),
                label: Text(label, textAlign: TextAlign.center),
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
  const _ConversationPill({
    required this.label,
    this.foregroundColor,
    this.backgroundColor,
  });

  final String label;
  final Color? foregroundColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: foregroundColor ?? theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _ProjectUnreadPill extends StatelessWidget {
  const _ProjectUnreadPill({required this.projectId, required this.count});

  final String projectId;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.error,
        borderRadius: BorderRadius.circular(999),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: theme.colorScheme.error.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          key: ValueKey<String>('counterpart-project-unread-badge-$projectId'),
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.mark_chat_unread_outlined,
              size: 15,
              color: theme.colorScheme.onError,
            ),
            const SizedBox(width: 4),
            Text(
              '未读 $count',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onError,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String? _formatProjectTimestamp(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }
  final parsed = DateTime.tryParse(normalized);
  if (parsed == null) {
    return normalized;
  }
  final local = parsed.toLocal();
  String two(int number) => number.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} '
      '${two(local.hour)}:${two(local.minute)}';
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

Color _projectStateForeground(String? value) {
  return switch (value) {
    'published' => const Color(0xFF2F7D43),
    'converted_to_order' => const Color(0xFF6F4DBA),
    'submitted' => const Color(0xFFB36B00),
    'bidding' => const Color(0xFF1F6FB2),
    'completed' => const Color(0xFF49635C),
    'closed' => const Color(0xFF7A4D4D),
    _ => const Color(0xFF6B7280),
  };
}

Color _projectStateBackground(String? value) {
  return switch (value) {
    'published' => const Color(0xFFEAF7EE),
    'converted_to_order' => const Color(0xFFF1EBFF),
    'submitted' => const Color(0xFFFFF4E3),
    'bidding' => const Color(0xFFEAF4FF),
    'completed' => const Color(0xFFEAF1EF),
    'closed' => const Color(0xFFF8EAEA),
    _ => const Color(0xFFF2F2F2),
  };
}
