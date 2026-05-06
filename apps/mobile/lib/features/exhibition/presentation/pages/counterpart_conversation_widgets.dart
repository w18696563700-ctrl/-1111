part of '../exhibition_trade_pages.dart';

class _ProjectConversationHeaderCard extends StatelessWidget {
  const _ProjectConversationHeaderCard({
    required this.data,
    required this.group,
    required this.thread,
    required this.currentOrganizationId,
    required this.currentDisplayName,
    required this.currentAvatarUrl,
    required this.onBackToProjectList,
    this.onOpenSubjectCard,
    this.canOpenSubjectCard = false,
  });

  final CounterpartConversationDetailView data;
  final CounterpartConversationProjectGroupView group;
  final ProjectCommunicationThreadView? thread;
  final String? currentOrganizationId;
  final String? currentDisplayName;
  final String? currentAvatarUrl;
  final VoidCallback onBackToProjectList;
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
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                IconButton(
                  onPressed: onBackToProjectList,
                  tooltip: '返回项目列表',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                Expanded(
                  child: Text(
                    group.projectDisplayTitle,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(
                  child: _CompactConversationParty(
                    name: ownerName,
                    roleLabel: '发布方',
                    avatarUrl: ownerAvatar,
                    onTap: !ownerIsCurrent && canOpenSubjectCard
                        ? onOpenSubjectCard
                        : null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(
                        alpha: 0.38,
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        Icons.swap_horiz_rounded,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _CompactConversationParty(
                    name: bidderName,
                    roleLabel: '竞标方',
                    avatarUrl: bidderAvatar,
                    onTap: !bidderIsCurrent && canOpenSubjectCard
                        ? onOpenSubjectCard
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const _ConversationPill(
              label: '竞标沟通中',
              foregroundColor: Color(0xFF2E6F43),
              backgroundColor: Color(0xFFE7F5EA),
            ),
          ],
        ),
      ),
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

class _CompactConversationParty extends StatelessWidget {
  const _CompactConversationParty({
    required this.name,
    required this.roleLabel,
    required this.avatarUrl,
    this.onTap,
  });

  final String name;
  final String roleLabel;
  final String? avatarUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalizedAvatar = avatarUrl?.trim();
    final content = Row(
      children: <Widget>[
        SafeRemoteAvatar(radius: 15, imageUrl: normalizedAvatar, label: name),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                roleLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
    if (onTap == null) {
      return content;
    }
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: content,
      ),
    );
  }
}

class _CounterpartProjectEntryList extends StatefulWidget {
  const _CounterpartProjectEntryList({
    required this.data,
    required this.groups,
    required this.onOpenSubjectCard,
    required this.canOpenSubjectCard,
    required this.onOpenProjectCommunication,
    this.searchToggleSignal,
  });

  final CounterpartConversationDetailView data;
  final List<CounterpartConversationProjectGroupView> groups;
  final VoidCallback onOpenSubjectCard;
  final bool canOpenSubjectCard;
  final ValueChanged<CounterpartConversationProjectGroupView>
  onOpenProjectCommunication;
  final ValueListenable<int>? searchToggleSignal;

  @override
  State<_CounterpartProjectEntryList> createState() =>
      _CounterpartProjectEntryListState();
}

class _CounterpartProjectEntryListState
    extends State<_CounterpartProjectEntryList> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedIdentity = 'all';
  String _selectedStatus = 'all';
  String _searchQuery = '';
  int _lastSearchToggleTick = 0;
  bool _searchExpanded = false;

  @override
  void initState() {
    super.initState();
    _bindSearchToggleSignal(widget.searchToggleSignal);
  }

  @override
  void didUpdateWidget(covariant _CounterpartProjectEntryList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchToggleSignal != widget.searchToggleSignal) {
      oldWidget.searchToggleSignal?.removeListener(_handleSearchToggleSignal);
      _bindSearchToggleSignal(widget.searchToggleSignal);
    }
  }

  @override
  void dispose() {
    widget.searchToggleSignal?.removeListener(_handleSearchToggleSignal);
    _searchController.dispose();
    super.dispose();
  }

  void _bindSearchToggleSignal(ValueListenable<int>? signal) {
    _lastSearchToggleTick = signal?.value ?? 0;
    signal?.addListener(_handleSearchToggleSignal);
  }

  void _handleSearchToggleSignal() {
    final signal = widget.searchToggleSignal;
    if (signal == null || signal.value == _lastSearchToggleTick || !mounted) {
      return;
    }
    _lastSearchToggleTick = signal.value;
    setState(() => _searchExpanded = !_searchExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final selectedIdentity = _identityFilterKeys.contains(_selectedIdentity)
        ? _selectedIdentity
        : 'all';
    final selectedStatus = _statusFilterKeys.contains(_selectedStatus)
        ? _selectedStatus
        : 'all';
    final identityGroups = widget.groups
        .where((group) => _matchesIdentityFilter(group, selectedIdentity))
        .toList(growable: false);
    final statusGroups = identityGroups
        .where((group) => _matchesStatusFilter(group, selectedStatus))
        .toList(growable: false);
    final filteredGroups = _filterGroups(statusGroups, _searchQuery);
    final theme = Theme.of(context);
    final subjectName = _subjectName(widget.data);
    final organizationName = _organizationName(widget.data);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _CounterpartProjectListSubjectCard(
              data: widget.data,
              subjectName: subjectName,
              organizationName: organizationName,
              projectCount: widget.groups.length,
              onOpenSubjectCard: widget.onOpenSubjectCard,
              canOpenSubjectCard: widget.canOpenSubjectCard,
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '项目列表',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  '共 ${widget.groups.length} 个',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (_searchExpanded) ...<Widget>[
              const SizedBox(height: 8),
              TextField(
                key: const ValueKey<String>('counterpart-project-search-field'),
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: IconButton(
                    tooltip: '关闭搜索',
                    onPressed: _closeSearch,
                    icon: const Icon(Icons.close_rounded),
                  ),
                  hintText: '搜索项目名称',
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ],
            const SizedBox(height: 12),
            if (widget.groups.isEmpty)
              const _EmptyNotice(
                title: '当前没有项目入口',
                message: '这个对方主体下暂时没有可展示的项目沟通事项。',
              )
            else ...<Widget>[
              Text(
                '身份线（我方）',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              _CounterpartFilterSegmentedControl(
                selected: selectedIdentity,
                values: _identityFilterKeys,
                labelFor: _identityFilterLabel,
                onSelected: (value) =>
                    setState(() => _selectedIdentity = value),
              ),
              const SizedBox(height: 12),
              Text(
                '项目状态',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: <Widget>[
                  for (final status in _statusFilterKeys)
                    ChoiceChip(
                      label: Text(_statusFilterLabel(status)),
                      selected: status == selectedStatus,
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onSelected: (_) =>
                          setState(() => _selectedStatus = status),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (filteredGroups.isEmpty)
                const _EmptyNotice(
                  title: '没有找到项目',
                  message: '当前筛选条件下没有项目，请调整身份线、项目状态或搜索关键词。',
                )
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

  void _closeSearch() {
    setState(() {
      _searchExpanded = false;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  static const List<String> _statusFilterKeys = <String>[
    'all',
    'active',
    'completed',
    'archived',
  ];

  static const List<String> _identityFilterKeys = <String>[
    'all',
    'my_published',
    'my_bid',
  ];

  bool _matchesIdentityFilter(
    CounterpartConversationProjectGroupView group,
    String identity,
  ) {
    return switch (identity) {
      'my_published' => group.projectRelation == 'my_published',
      'my_bid' => group.projectRelation == 'my_bid',
      _ => true,
    };
  }

  bool _matchesStatusFilter(
    CounterpartConversationProjectGroupView group,
    String status,
  ) {
    return switch (status) {
      'active' => !_isCompleted(group) && !_isArchived(group),
      'completed' => _isCompleted(group),
      'archived' => _isArchived(group),
      _ => true,
    };
  }

  bool _isCompleted(CounterpartConversationProjectGroupView group) {
    final state = group.projectState?.trim();
    return state == 'completed' || state == 'ended' || state == 'closed';
  }

  bool _isArchived(CounterpartConversationProjectGroupView group) {
    final state = group.projectState?.trim();
    return state == 'archived';
  }

  String _identityFilterLabel(String identity) {
    return switch (identity) {
      'my_published' => '我发布',
      'my_bid' => '我竞标',
      _ => '全部',
    };
  }

  String _statusFilterLabel(String status) {
    return switch (status) {
      'active' => '进行中',
      'completed' => '已完成',
      'archived' => '已归档',
      _ => '全部',
    };
  }

  String _subjectName(CounterpartConversationDetailView data) {
    final nickname = data.counterpart.nickname?.trim();
    if (nickname != null && nickname.isNotEmpty) {
      return nickname;
    }
    final company = data.counterpart.companyName.trim();
    if (company.isNotEmpty) {
      return company;
    }
    final display = data.counterpart.displayName.trim();
    return display.isEmpty ? '对方主体' : display;
  }

  String _organizationName(CounterpartConversationDetailView data) {
    final company = data.counterpart.companyName.trim();
    if (company.isNotEmpty) {
      return company;
    }
    final display = data.counterpart.displayName.trim();
    return display.isEmpty ? '企业主体' : display;
  }
}

class _CounterpartFilterSegmentedControl extends StatelessWidget {
  const _CounterpartFilterSegmentedControl({
    required this.selected,
    required this.values,
    required this.labelFor,
    required this.onSelected,
  });

  final String selected;
  final List<String> values;
  final String Function(String value) labelFor;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: <Widget>[
          for (var index = 0; index < values.length; index += 1) ...<Widget>[
            Expanded(
              child: _CounterpartSegmentButton(
                label: labelFor(values[index]),
                selected: values[index] == selected,
                onTap: () => onSelected(values[index]),
              ),
            ),
            if (index != values.length - 1)
              SizedBox(
                height: 24,
                child: VerticalDivider(
                  width: 1,
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _CounterpartSegmentButton extends StatelessWidget {
  const _CounterpartSegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFEFD6) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelLarge?.copyWith(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _CounterpartProjectListSubjectCard extends StatelessWidget {
  const _CounterpartProjectListSubjectCard({
    required this.data,
    required this.subjectName,
    required this.organizationName,
    required this.projectCount,
    required this.onOpenSubjectCard,
    required this.canOpenSubjectCard,
  });

  final CounterpartConversationDetailView data;
  final String subjectName;
  final String organizationName;
  final int projectCount;
  final VoidCallback onOpenSubjectCard;
  final bool canOpenSubjectCard;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatarUrl = data.counterpart.avatarUrl?.trim();
    return Material(
      color: const Color(0xFFFFFCF8),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFFECD8B9)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: canOpenSubjectCard ? onOpenSubjectCard : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: <Widget>[
              SafeRemoteAvatar(
                radius: 25,
                imageUrl: avatarUrl,
                label: subjectName,
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
                textStyle: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      subjectName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      organizationName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '相关项目 $projectCount 个',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
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
    final updatedAtLabel =
        _formatProjectTimestamp(group.latestActivityAt) ??
        _formatProjectTimestamp(group.projectUpdatedAt);
    final latestUnreadLabel = _formatProjectTimestamp(
      group.latestUnreadMessageAt,
    );
    final hasUnread = group.hasProjectUnread && group.projectUnreadCount > 0;
    final businessTodoCount = group.businessTodoSummary.totalPendingCount;
    final hasBusinessTodo = businessTodoCount > 0;
    final latestMessageLabel = hasUnread
        ? '最近消息：有 ${group.projectUnreadCount} 条未读项目沟通消息'
        : '最近消息：暂无最新消息';
    const maskedTitleColor = Color(0xFF1F7A3A);
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 390;
        final stateLabel = _projectStateLabel(group.projectState);
        final relationLabel = _mySideProjectRelationLabel(
          group.projectRelation,
        );
        final mainContent = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: <Widget>[
                if (relationLabel != null)
                  _ConversationPill(
                    label: relationLabel,
                    foregroundColor: const Color(0xFF8A4B00),
                    backgroundColor: const Color(0xFFFFF1D6),
                  ),
                _ConversationPill(
                  label: stateLabel,
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
            const SizedBox(height: 7),
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
              latestMessageLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (updatedAtLabel != null) ...<Widget>[
              const SizedBox(height: 6),
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
                      '更新时间：$updatedAtLabel',
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
          width: compact ? double.infinity : 108,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (hasBusinessTodo) ...<Widget>[
                Align(
                  alignment: Alignment.centerRight,
                  child: _BusinessTodoBadge(count: businessTodoCount),
                ),
                const SizedBox(height: 8),
              ],
              FilledButton.icon(
                onPressed: onOpen,
                icon: compact
                    ? const Icon(Icons.forum_outlined)
                    : const Icon(Icons.arrow_forward_rounded),
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
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
              width: hasUnread ? 1.2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
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

class _SelectedProjectBusinessEntrypoints extends StatefulWidget {
  const _SelectedProjectBusinessEntrypoints({
    required this.group,
    required this.participationCard,
    required this.orderId,
    required this.loadingWorkbench,
    required this.workbenchResult,
    required this.onOpenNameAccess,
    required this.onOpenContinuation,
    required this.onOpenProjectAlbum,
    required this.onOpenWorkbenchEntry,
  });

  final CounterpartConversationProjectGroupView group;
  final CounterpartConversationBusinessCardView? participationCard;
  final String? orderId;
  final bool loadingWorkbench;
  final CounterpartConversationResult<ProjectCommunicationWorkbenchView>?
  workbenchResult;
  final ValueChanged<CounterpartConversationBusinessCardView> onOpenNameAccess;
  final VoidCallback onOpenContinuation;
  final VoidCallback onOpenProjectAlbum;
  final ValueChanged<ProjectCommunicationWorkbenchEntryView>
  onOpenWorkbenchEntry;

  @override
  State<_SelectedProjectBusinessEntrypoints> createState() =>
      _SelectedProjectBusinessEntrypointsState();
}

class _SelectedProjectBusinessEntrypointsState
    extends State<_SelectedProjectBusinessEntrypoints> {
  bool _toolsVisible = false;

  @override
  Widget build(BuildContext context) {
    final materialConfirmationCount = _materialConfirmationCount;
    final materialConfirmationLabel = materialConfirmationCount == null
        ? '资料确认单'
        : '资料确认 · $materialConfirmationCount项';
    final todoSummary =
        widget.workbenchResult?.data?.businessTodoSummary ??
        widget.group.businessTodoSummary;
    final hasContinuation = widget.orderId != null || _dealEntries.isNotEmpty;
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (_toolsVisible) ...<Widget>[
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 260),
                  child: SingleChildScrollView(
                    child: _ProjectCommunicationWorkbenchSection(
                      loading: widget.loadingWorkbench,
                      result: widget.workbenchResult,
                      onOpenEntry: widget.onOpenWorkbenchEntry,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: <Widget>[
                  Expanded(
                    child: _ProjectToolEntryButton(
                      icon: Icons.photo_library_outlined,
                      label: '项目相册',
                      enabled: true,
                      onPressed: widget.onOpenProjectAlbum,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ProjectToolEntryButton(
                      icon: Icons.fact_check_outlined,
                      label: '进入审核',
                      badgeCount:
                          todoSummary.bidParticipationReviewPendingCount,
                      enabled: widget.participationCard != null,
                      disabledReason: '当前没有待处理的参与审核。',
                      onPressed: widget.participationCard == null
                          ? null
                          : () => widget.onOpenNameAccess(
                              widget.participationCard!,
                            ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ProjectToolEntryButton(
                      icon: Icons.receipt_long_outlined,
                      label: '后续承接',
                      badgeCount: todoSummary.dealConfirmationPendingCount,
                      enabled: hasContinuation,
                      disabledReason: '当前项目暂无订单、合同或最终成交确认入口。',
                      onPressed: hasContinuation
                          ? widget.onOpenContinuation
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ProjectToolEntryButton(
                      icon: Icons.folder_open_outlined,
                      label: materialConfirmationLabel,
                      badgeCount: todoSummary.materialReviewPendingCount,
                      enabled: true,
                      selected: _toolsVisible,
                      onPressed: () =>
                          setState(() => _toolsVisible = !_toolsVisible),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  int? get _materialConfirmationCount {
    final result = widget.workbenchResult;
    final data = result?.data;
    if (result?.state != AppPageState.content || data == null) {
      return null;
    }
    return data.entries.where(_isMaterialWorkbenchEntry).length;
  }

  List<ProjectCommunicationWorkbenchEntryView> get _dealEntries {
    final result = widget.workbenchResult;
    final data = result?.data;
    if (result?.state != AppPageState.content || data == null) {
      return const <ProjectCommunicationWorkbenchEntryView>[];
    }
    return data.entries.where(_isDealWorkbenchEntry).toList(growable: false);
  }
}

class _ProjectToolEntryButton extends StatelessWidget {
  const _ProjectToolEntryButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onPressed,
    this.selected = false,
    this.badgeCount = 0,
    this.disabledReason,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback? onPressed;
  final bool selected;
  final int badgeCount;
  final String? disabledReason;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Positioned.fill(
          child: OutlinedButton(
            onPressed: enabled
                ? onPressed
                : disabledReason == null
                ? null
                : () => ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(disabledReason!))),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              side: BorderSide(
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant,
              ),
              backgroundColor: selected
                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.28)
                  : theme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(icon, size: 18),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 58),
        if (badgeCount > 0)
          Positioned(
            right: -3,
            top: -5,
            child: _BusinessTodoBadge(count: badgeCount, compact: true),
          ),
      ],
    );
  }
}

class _ContinuationActionTile extends StatelessWidget {
  const _ContinuationActionTile({
    required this.icon,
    required this.title,
    required this.summary,
    required this.enabled,
    required this.onTap,
    this.badgeCount = 0,
    this.disabledReason,
  });

  final IconData icon;
  final String title;
  final String summary;
  final bool enabled;
  final VoidCallback? onTap;
  final int badgeCount;
  final String? disabledReason;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = enabled
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurfaceVariant;
    return Material(
      color: enabled
          ? theme.colorScheme.surfaceContainerLowest
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: enabled
            ? onTap
            : disabledReason == null
            ? null
            : () => ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(disabledReason!))),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: <Widget>[
              Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Icon(icon, color: foreground),
                  if (badgeCount > 0)
                    Positioned(
                      right: -8,
                      top: -8,
                      child: _BusinessTodoBadge(
                        count: badgeCount,
                        compact: true,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Kept as the reserved fallback workbench surface for unreadable project context.
// ignore: unused_element
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

class _BusinessTodoBadge extends StatelessWidget {
  const _BusinessTodoBadge({required this.count, this.compact = false});

  final int count;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = count > 99 ? '99+' : '$count';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.error,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 8,
          vertical: compact ? 2 : 4,
        ),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onError,
            fontWeight: FontWeight.w900,
          ),
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

String? _mySideProjectRelationLabel(String value) {
  return switch (value) {
    'my_published' => '我发布',
    'my_bid' => '我竞标',
    _ => null,
  };
}

String _projectStateLabel(String? value) {
  return switch (value) {
    'published' => '进行中',
    'bidding' => '竞标中',
    'converted_to_order' => '已转订单',
    'archived' => '已归档',
    'completed' => '已完成',
    'ended' => '已完成',
    'closed' => '已关闭',
    null => '项目',
    _ => '项目状态',
  };
}

Color _projectStateForeground(String? value) {
  return switch (value) {
    'published' => const Color(0xFF2F7D43),
    'archived' => const Color(0xFF6B7280),
    'converted_to_order' => const Color(0xFF6F4DBA),
    'submitted' => const Color(0xFFB36B00),
    'bidding' => const Color(0xFF1F6FB2),
    'ended' => const Color(0xFF49635C),
    'completed' => const Color(0xFF49635C),
    'closed' => const Color(0xFF7A4D4D),
    _ => const Color(0xFF6B7280),
  };
}

Color _projectStateBackground(String? value) {
  return switch (value) {
    'published' => const Color(0xFFEAF7EE),
    'archived' => const Color(0xFFF2F4F7),
    'converted_to_order' => const Color(0xFFF1EBFF),
    'submitted' => const Color(0xFFFFF4E3),
    'bidding' => const Color(0xFFEAF4FF),
    'ended' => const Color(0xFFEAF1EF),
    'completed' => const Color(0xFFEAF1EF),
    'closed' => const Color(0xFFF8EAEA),
    _ => const Color(0xFFF2F2F2),
  };
}
