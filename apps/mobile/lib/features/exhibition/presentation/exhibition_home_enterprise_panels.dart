part of 'exhibition_home_page.dart';

class _HomeEnterpriseModulePanel extends StatefulWidget {
  const _HomeEnterpriseModulePanel({
    required this.boardType,
    required this.openBoardLabel,
    required this.provinceCode,
    required this.provinceName,
    required this.onRelocateHome,
    required this.onOpenBoard,
    required this.onOpenEnterpriseItem,
  });

  final EnterpriseBoardType boardType;
  final String openBoardLabel;
  final String? provinceCode;
  final String? provinceName;
  final Future<void> Function() onRelocateHome;
  final VoidCallback onOpenBoard;
  final ValueChanged<EnterpriseHubListItem> onOpenEnterpriseItem;

  @override
  State<_HomeEnterpriseModulePanel> createState() =>
      _HomeEnterpriseModulePanelState();
}

class _HomeEnterpriseModulePanelState
    extends State<_HomeEnterpriseModulePanel> {
  _HomeEnterpriseFilter _selectedFilter = _HomeEnterpriseFilter.comprehensive;
  final Map<_HomeEnterpriseFilter, _HomeEnterprisePanelSnapshot> _snapshots =
      <_HomeEnterpriseFilter, _HomeEnterprisePanelSnapshot>{};
  final Set<_HomeEnterpriseFilter> _loadingFilters = <_HomeEnterpriseFilter>{};

  @override
  void initState() {
    super.initState();
    unawaited(
      _ensureFilterLoaded(
        _HomeEnterpriseFilter.comprehensive,
        forceRefresh: false,
      ),
    );
    if (_usesConditionalFeaturedFilter) {
      unawaited(
        _ensureFilterLoaded(
          _HomeEnterpriseFilter.featured,
          forceRefresh: false,
        ),
      );
    }
  }

  bool get _usesConditionalFeaturedFilter {
    return widget.boardType != EnterpriseBoardType.factory;
  }

  bool get _shouldShowFeaturedFilter {
    if (!_usesConditionalFeaturedFilter) {
      return true;
    }
    final snapshot = _snapshots[_HomeEnterpriseFilter.featured];
    if (snapshot == null) {
      return false;
    }
    if (snapshot.state == AppPageState.empty) {
      return false;
    }
    if (snapshot.state == AppPageState.content) {
      return snapshot.items.isNotEmpty;
    }
    return true;
  }

  List<_HomeEnterpriseFilter> get _visibleFilters {
    return <_HomeEnterpriseFilter>[
      _HomeEnterpriseFilter.comprehensive,
      _HomeEnterpriseFilter.province,
      if (_shouldShowFeaturedFilter) _HomeEnterpriseFilter.featured,
    ];
  }

  @override
  void didUpdateWidget(covariant _HomeEnterpriseModulePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.provinceCode != widget.provinceCode) {
      _snapshots.remove(_HomeEnterpriseFilter.province);
      if (_selectedFilter == _HomeEnterpriseFilter.province &&
          widget.provinceCode != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _ensureFilterLoaded(
              _HomeEnterpriseFilter.province,
              forceRefresh: false,
            );
          }
        });
      }
    }
  }

  Future<void> _handleFilterSelected(_HomeEnterpriseFilter filter) async {
    if (_selectedFilter == filter) {
      return;
    }
    setState(() {
      _selectedFilter = filter;
    });
    await _ensureFilterLoaded(filter, forceRefresh: false);
  }

  Future<void> _refreshSelected() async {
    if (_selectedFilter == _HomeEnterpriseFilter.province &&
        (widget.provinceCode == null || widget.provinceCode!.trim().isEmpty)) {
      await widget.onRelocateHome();
      return;
    }
    await _ensureFilterLoaded(_selectedFilter, forceRefresh: true);
    if (_usesConditionalFeaturedFilter &&
        _selectedFilter != _HomeEnterpriseFilter.featured) {
      await _ensureFilterLoaded(
        _HomeEnterpriseFilter.featured,
        forceRefresh: true,
      );
    }
  }

  Future<void> _ensureFilterLoaded(
    _HomeEnterpriseFilter filter, {
    required bool forceRefresh,
  }) async {
    if (_loadingFilters.contains(filter)) {
      return;
    }
    if (filter == _HomeEnterpriseFilter.province &&
        (widget.provinceCode == null || widget.provinceCode!.trim().isEmpty)) {
      return;
    }
    if (!forceRefresh && _snapshots.containsKey(filter)) {
      return;
    }

    setState(() {
      _loadingFilters.add(filter);
    });
    final snapshot = await _loadSnapshot(filter);
    if (!mounted) {
      return;
    }
    setState(() {
      _loadingFilters.remove(filter);
      _snapshots[filter] = snapshot;
      if (filter == _HomeEnterpriseFilter.featured &&
          !_shouldShowFeaturedFilter &&
          _selectedFilter == _HomeEnterpriseFilter.featured) {
        _selectedFilter = _HomeEnterpriseFilter.comprehensive;
      }
    });
  }

  Future<_HomeEnterprisePanelSnapshot> _loadSnapshot(
    _HomeEnterpriseFilter filter,
  ) async {
    switch (filter) {
      case _HomeEnterpriseFilter.comprehensive:
        final result = await EnterpriseHubConsumerLayer.instance
            .loadEnterprises(
              EnterpriseHubListQuery(boardType: widget.boardType, pageSize: 3),
            );
        return _HomeEnterprisePanelSnapshot.fromListResult(result);
      case _HomeEnterpriseFilter.province:
        final result = await EnterpriseHubConsumerLayer.instance
            .loadEnterprises(
              EnterpriseHubListQuery(
                boardType: widget.boardType,
                provinceCode: widget.provinceCode,
                pageSize: 3,
              ),
            );
        return _HomeEnterprisePanelSnapshot.fromListResult(result);
      case _HomeEnterpriseFilter.featured:
        final result = await EnterpriseHubConsumerLayer.instance
            .loadRecommendations(widget.boardType);
        return _HomeEnterprisePanelSnapshot.fromRecommendationResult(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshots[_selectedFilter];
    final loading = _loadingFilters.contains(_selectedFilter);

    return _HomeModulePanelShell(
      children: <Widget>[
        _HomeChannelActionRail(
          actions: <_HomeChannelAction>[
            _HomeChannelAction(
              label: widget.openBoardLabel,
              onPressed: widget.onOpenBoard,
              primary: true,
              icon: Icons.apartment_rounded,
            ),
            _HomeChannelAction(
              label: '刷新',
              onPressed: _refreshSelected,
              icon: Icons.refresh_rounded,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _HomeChannelFilterRail<_HomeEnterpriseFilter>(
          options: _visibleFilters
              .map(
                (_HomeEnterpriseFilter filter) => _HomeChannelFilterOption(
                  value: filter,
                  label: filter.label,
                ),
              )
              .toList(growable: false),
          selectedValue: _selectedFilter,
          onSelected: _handleFilterSelected,
        ),
        const SizedBox(height: 12),
        ..._buildBody(snapshot: snapshot, loading: loading),
      ],
    );
  }

  List<Widget> _buildBody({
    required _HomeEnterprisePanelSnapshot? snapshot,
    required bool loading,
  }) {
    final channelLabel = _homeEnterpriseChannelLabel(widget.boardType);

    if (_selectedFilter == _HomeEnterpriseFilter.province &&
        (widget.provinceCode == null || widget.provinceCode!.trim().isEmpty)) {
      return <Widget>[
        _HomeStateNotice(
          title: '当前还没拿到本省定位',
          message: '先刷新定位，再看本省$channelLabel；当前不会把综合列表伪装成本省结果。',
          actions: <Widget>[
            OutlinedButton(
              onPressed: () => unawaited(widget.onRelocateHome()),
              child: const Text('重新定位并刷新'),
            ),
            OutlinedButton(
              onPressed: widget.onOpenBoard,
              child: Text(widget.openBoardLabel),
            ),
          ],
        ),
      ];
    }

    if (loading && snapshot == null) {
      return <Widget>[_HomeLoadingNotice(message: '正在读取$channelLabel推荐')];
    }

    if (snapshot?.state == AppPageState.content && snapshot!.items.isNotEmpty) {
      return snapshot.items
          .map(
            (EnterpriseHubListItem item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _HomeEnterpriseRecommendationCard(
                title: item.name,
                summary: _homeEnterpriseCardSummary(item),
                badgeLabel: item.boardType == EnterpriseBoardType.company
                    ? null
                    : _homeEnterpriseCardBadgeLabel(item),
                actionLabel: _homeEnterpriseDetailActionLabel(item.boardType),
                onPressed: () => widget.onOpenEnterpriseItem(item),
              ),
            ),
          )
          .toList(growable: false);
    }

    if (snapshot?.state == AppPageState.empty) {
      final title = switch (_selectedFilter) {
        _HomeEnterpriseFilter.comprehensive => '当前还没有公开$channelLabel',
        _HomeEnterpriseFilter.province =>
          '${widget.provinceName ?? '本省'}当前还没有公开$channelLabel',
        _HomeEnterpriseFilter.featured => '当前还没有优选$channelLabel',
      };
      return <Widget>[
        _HomeStateNotice(
          title: title,
          message: '可以先进入列表继续查看，当前不会用演示文案替代真实推荐。',
          actions: <Widget>[
            OutlinedButton(
              onPressed: widget.onOpenBoard,
              child: Text(widget.openBoardLabel),
            ),
            OutlinedButton(
              onPressed: _refreshSelected,
              child: const Text('刷新当前频道'),
            ),
          ],
        ),
      ];
    }

    return <Widget>[
      _HomeStateNotice(
        title: '当前$channelLabel列表暂时没有刷新成功',
        message: snapshot?.message?.trim().isNotEmpty == true
            ? snapshot!.message!
            : '当前保持受控失败态，不会把未接通链路伪装成只是“暂无内容”。',
        actions: <Widget>[
          OutlinedButton(
            onPressed: _refreshSelected,
            child: const Text('刷新当前频道'),
          ),
          OutlinedButton(
            onPressed: widget.onOpenBoard,
            child: Text(widget.openBoardLabel),
          ),
        ],
      ),
    ];
  }
}

class _HomeSupplierModulePanel extends StatelessWidget {
  const _HomeSupplierModulePanel({
    required this.provinceCode,
    required this.provinceName,
    required this.onRelocateHome,
    required this.onOpenSupplierBoard,
    required this.onOpenEnterpriseItem,
  });

  final String? provinceCode;
  final String? provinceName;
  final Future<void> Function() onRelocateHome;
  final VoidCallback onOpenSupplierBoard;
  final ValueChanged<EnterpriseHubListItem> onOpenEnterpriseItem;

  @override
  Widget build(BuildContext context) {
    return _HomeEnterpriseModulePanel(
      boardType: EnterpriseBoardType.supplier,
      openBoardLabel: '进入供应商列表',
      provinceCode: provinceCode,
      provinceName: provinceName,
      onRelocateHome: onRelocateHome,
      onOpenBoard: onOpenSupplierBoard,
      onOpenEnterpriseItem: onOpenEnterpriseItem,
    );
  }
}
