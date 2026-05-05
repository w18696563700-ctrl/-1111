part of 'exhibition_home_page.dart';

class _HomeProjectModulePanel extends StatefulWidget {
  const _HomeProjectModulePanel({
    required this.loading,
    required this.result,
    required this.projectItems,
    required this.provinceCode,
    required this.provinceName,
    required this.onRefreshHome,
    required this.onRelocateHome,
    required this.onOpenProjectList,
    required this.onOpenProjectCreate,
    required this.onOpenProjectDetail,
  });

  final bool loading;
  final ExhibitionLoadResult? result;
  final List<Map<String, Object?>> projectItems;
  final String? provinceCode;
  final String? provinceName;
  final Future<void> Function() onRefreshHome;
  final Future<void> Function() onRelocateHome;
  final VoidCallback onOpenProjectList;
  final VoidCallback onOpenProjectCreate;
  final ValueChanged<String> onOpenProjectDetail;

  @override
  State<_HomeProjectModulePanel> createState() =>
      _HomeProjectModulePanelState();
}

class _HomeProjectModulePanelState extends State<_HomeProjectModulePanel> {
  _HomeProjectFilter _selectedFilter = _HomeProjectFilter.comprehensive;
  ExhibitionLoadResult? _provinceResult;
  String? _resolvedProvinceCode;
  String? _loadedProvinceCode;
  bool _provinceLoading = false;
  bool _provinceCodeResolutionFailed = false;

  @override
  void didUpdateWidget(covariant _HomeProjectModulePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.provinceCode != widget.provinceCode ||
        oldWidget.provinceName != widget.provinceName) {
      _provinceResult = null;
      _resolvedProvinceCode = null;
      _loadedProvinceCode = null;
      _provinceCodeResolutionFailed = false;
      if (_selectedFilter == _HomeProjectFilter.province && _hasProvinceHint) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _ensureProvinceLoaded(forceRefresh: false);
          }
        });
      }
    }
  }

  Future<void> _handleFilterSelected(_HomeProjectFilter filter) async {
    if (_selectedFilter == filter) {
      return;
    }
    setState(() {
      _selectedFilter = filter;
    });
    if (filter == _HomeProjectFilter.province) {
      await _ensureProvinceLoaded(forceRefresh: false);
    }
  }

  Future<void> _refreshActiveFilter() async {
    if (_selectedFilter == _HomeProjectFilter.province) {
      if (!_hasProvinceHint || _provinceCodeResolutionFailed) {
        await widget.onRelocateHome();
        return;
      }
      await _ensureProvinceLoaded(forceRefresh: true);
      return;
    }
    await widget.onRefreshHome();
  }

  Future<void> _ensureProvinceLoaded({required bool forceRefresh}) async {
    if (!_hasProvinceHint) {
      return;
    }
    if (_provinceLoading) {
      return;
    }

    setState(() {
      _provinceLoading = true;
      _provinceCodeResolutionFailed = false;
    });
    final provinceCode = await _resolveProvinceCode();
    if (!mounted) {
      return;
    }
    if (provinceCode == null) {
      setState(() {
        _provinceLoading = false;
        _provinceCodeResolutionFailed = true;
      });
      return;
    }
    if (!forceRefresh &&
        _provinceResult != null &&
        _loadedProvinceCode == provinceCode) {
      setState(() {
        _provinceLoading = false;
      });
      return;
    }
    final result = await ExhibitionConsumerLayer.instance.loadProjectList(
      forceRefresh: true,
      provinceCode: provinceCode,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _provinceLoading = false;
      _provinceResult = result;
      _loadedProvinceCode = provinceCode;
      _provinceCodeResolutionFailed = false;
    });
  }

  bool get _hasProvinceHint =>
      _homeTrimmedString(widget.provinceCode) != null ||
      _homeTrimmedString(_resolvedProvinceCode) != null ||
      _homeTrimmedString(widget.provinceName) != null;

  Future<String?> _resolveProvinceCode() async {
    final direct =
        _homeTrimmedString(widget.provinceCode) ??
        _homeTrimmedString(_resolvedProvinceCode);
    if (direct != null) {
      return direct;
    }

    final provinceName = _homeTrimmedString(widget.provinceName);
    if (provinceName == null) {
      return null;
    }

    try {
      final catalog = await ChinaRegionCatalogLoader.load();
      if (!mounted) {
        return null;
      }
      final province = catalog.provinceByName(provinceName);
      if (province == null) {
        return null;
      }
      setState(() {
        _resolvedProvinceCode = province.provinceCode;
        _provinceCodeResolutionFailed = false;
      });
      return province.provinceCode;
    } on Object {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = _buildBody(context);

    return _HomeModulePanelShell(
      children: <Widget>[
        _HomeChannelActionRail(
          actions: <_HomeChannelAction>[
            _HomeChannelAction(
              label: '进入项目列表',
              onPressed: widget.onOpenProjectList,
              primary: true,
              icon: Icons.snippet_folder_outlined,
            ),
            _HomeChannelAction(
              label: '去发布项目',
              onPressed: widget.onOpenProjectCreate,
              icon: Icons.workspace_premium_outlined,
            ),
            _HomeChannelAction(
              label: '刷新',
              onPressed: _refreshActiveFilter,
              icon: Icons.refresh_rounded,
            ),
          ],
        ),
        const SizedBox(height: 6),
        _HomeChannelFilterRail<_HomeProjectFilter>(
          options: _HomeProjectFilter.values
              .map(
                (_HomeProjectFilter filter) => _HomeChannelFilterOption(
                  value: filter,
                  label: filter.label,
                ),
              )
              .toList(growable: false),
          selectedValue: _selectedFilter,
          onSelected: _handleFilterSelected,
        ),
        const SizedBox(height: 6),
        ...body,
      ],
    );
  }

  List<Widget> _buildBody(BuildContext context) {
    final activeResult = _selectedFilter == _HomeProjectFilter.province
        ? _provinceResult
        : widget.result;
    final activeItems = _selectedFilter == _HomeProjectFilter.province
        ? _homeProjectItemsFromPayload(_provinceResult?.payload)
        : widget.projectItems;
    final activeLoading = _selectedFilter == _HomeProjectFilter.province
        ? _provinceLoading
        : widget.loading && widget.result == null;
    final activeState = activeResult?.state;

    if (_selectedFilter == _HomeProjectFilter.province &&
        (!_hasProvinceHint || _provinceCodeResolutionFailed)) {
      return <Widget>[
        _HomeStateNotice(
          title: '当前还没拿到本省定位',
          message: '先刷新定位，再看本省项目；当前不会把综合项目伪装成“本省”。',
          actions: <Widget>[
            OutlinedButton(
              onPressed: () => unawaited(widget.onRelocateHome()),
              child: const Text('重新定位并刷新'),
            ),
            OutlinedButton(
              onPressed: widget.onOpenProjectList,
              child: const Text('进入项目列表'),
            ),
          ],
        ),
      ];
    }

    if (_selectedFilter == _HomeProjectFilter.province &&
        _homeTrimmedString(widget.provinceCode) == null &&
        _homeTrimmedString(_resolvedProvinceCode) == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _ensureProvinceLoaded(forceRefresh: false);
        }
      });
      return <Widget>[
        _HomeLoadingNotice(message: '正在同步${widget.provinceName ?? '本省'}项目'),
      ];
    }

    if (activeLoading && activeResult == null) {
      return const <Widget>[_HomeLoadingNotice(message: '正在读取项目推荐')];
    }

    if (activeState == AppPageState.content && activeItems.isNotEmpty) {
      final visibleItems = activeItems.take(3).toList(growable: false);
      return List<Widget>.generate(visibleItems.length, (int index) {
        final item = visibleItems[index];
        final isLast = index == visibleItems.length - 1;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
          child: _HomeProjectCard(
            title:
                _homeTrimmedString(item['displayTitle']) ??
                _homeTrimmedString(item['title']) ??
                '未命名项目',
            budgetLabel: _homeCurrencyText(item['budgetAmount']),
            stateLabel: _homeFrontStateLabel(_homeTrimmedString(item['state'])),
            cityLabel: _homeProjectCityLabel(item),
            areaLabel: _homeProjectAreaLabel(item['areaSqm']),
            exampleAssetPath: _homeProjectExampleAsset(item['areaSqm']),
            typeLabel: _homeProjectTypeLabel(item['buildingType']),
            entryTimeLabel: _homeProjectEntryTimeLabel(item),
            publishedAtLabel: _homeProjectPublishedAtLabel(item),
            actionLabel: _homeCanContinueBid(_homeTrimmedString(item['state']))
                ? '进入项目详情'
                : '查看项目详情',
            onPressed: switch (_homeTrimmedString(item['projectId'])) {
              final String projectId => () => widget.onOpenProjectDetail(
                projectId,
              ),
              _ => null,
            },
          ),
        );
      });
    }

    if (activeState == AppPageState.empty) {
      final title = _selectedFilter == _HomeProjectFilter.province
          ? '${widget.provinceName ?? '本省'}当前还没有公开项目'
          : '当前还没有公开项目';
      return <Widget>[
        AppPageStateView(
          state: AppPageState.empty,
          title: title,
          message: '可以先进入项目列表继续查看，或直接发布项目。',
          retryLabel: '进入项目列表',
          onRetry: widget.onOpenProjectList,
          content: const SizedBox.shrink(),
          scope: AppPageStateViewScope.card,
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: widget.onOpenProjectCreate,
          child: const Text('去发布项目'),
        ),
      ];
    }

    final message = _selectedFilter == _HomeProjectFilter.province
        ? '当前不会把综合项目伪装成本省结果。你可以先刷新，或进入项目列表查看。'
        : '当前不会用本地演示项目替代云端推荐。你可以先刷新，或进入项目列表查看。';
    return <Widget>[
      AppPageStateView(
        state: activeState == AppPageState.content
            ? AppPageState.errorRetryable
            : activeState ?? AppPageState.errorRetryable,
        title: _selectedFilter == _HomeProjectFilter.province
            ? '${widget.provinceName ?? '本省'}项目推荐暂时没有刷新成功'
            : '当前项目推荐暂时没有刷新成功',
        message: message,
        retryLabel: '刷新当前频道',
        onRetry: _refreshActiveFilter,
        content: const SizedBox.shrink(),
        scope: AppPageStateViewScope.card,
      ),
      const SizedBox(height: 8),
      OutlinedButton(
        onPressed: widget.onOpenProjectList,
        child: const Text('进入项目列表'),
      ),
    ];
  }
}
