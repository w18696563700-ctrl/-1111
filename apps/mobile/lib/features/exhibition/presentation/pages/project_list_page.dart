part of '../exhibition_trade_pages.dart';

enum ProjectListSurface { standard, showcase }

class ProjectListPage extends StatefulWidget {
  const ProjectListPage({
    super.key,
    this.surface = ProjectListSurface.standard,
  });

  final ProjectListSurface surface;

  @override
  State<ProjectListPage> createState() => _ProjectListPageState();
}

class _ProjectListPageState extends State<ProjectListPage> {
  static const List<_ProjectBucketOption> _areaBucketOptions =
      <_ProjectBucketOption>[
        _ProjectBucketOption(value: '9_sqm', label: '9㎡'),
        _ProjectBucketOption(value: '18_sqm', label: '18㎡'),
        _ProjectBucketOption(value: '27_sqm', label: '27㎡'),
        _ProjectBucketOption(value: '36_sqm', label: '36㎡'),
        _ProjectBucketOption(value: '54_sqm', label: '54㎡'),
        _ProjectBucketOption(value: '72_sqm', label: '72㎡'),
        _ProjectBucketOption(value: '81_sqm', label: '81㎡'),
        _ProjectBucketOption(value: '90_sqm', label: '90㎡'),
        _ProjectBucketOption(value: '108_sqm', label: '108㎡'),
        _ProjectBucketOption(value: 'gt_108_sqm', label: '108㎡以上'),
        _ProjectBucketOption(value: 'custom_sqm', label: '定制面积'),
      ];
  static const List<_ProjectBucketOption> _budgetBucketOptions =
      <_ProjectBucketOption>[
        _ProjectBucketOption(value: '0_2w', label: '2万以内'),
        _ProjectBucketOption(value: '2_4w', label: '2万-4万'),
        _ProjectBucketOption(value: '4_6w', label: '4万-6万'),
        _ProjectBucketOption(value: '6_8w', label: '6万-8万'),
        _ProjectBucketOption(value: '8_10w', label: '8万-10万'),
        _ProjectBucketOption(value: '10_15w', label: '10万-15万'),
        _ProjectBucketOption(value: '15_20w', label: '15万-20万'),
        _ProjectBucketOption(value: '20w_plus', label: '20万以上'),
      ];
  static const List<_ProjectBucketOption> _stateOptions =
      <_ProjectBucketOption>[
        _ProjectBucketOption(value: 'published', label: '竞标中'),
        _ProjectBucketOption(value: 'bidding_closed', label: '投标已结束'),
        _ProjectBucketOption(value: 'awarded', label: '已授标'),
        _ProjectBucketOption(value: 'converted_to_order', label: '已被承接'),
      ];

  ExhibitionStageLoadSnapshot? _snapshot;
  ChinaRegionCatalog? _regionCatalog;
  ChinaCityOption? _selectedCity;
  String? _selectedState;
  String? _selectedType;
  String? _selectedAreaBucket;
  String? _selectedBudgetBucket;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  ExhibitionStageLoadAutoSource _buildSource() {
    return ExhibitionStageLoadAutoSource(
      futureRealLoader: ({bool forceRefresh = false}) {
        return ExhibitionConsumerLayer.instance.loadProjectList(
          forceRefresh: forceRefresh,
          provinceCode: _selectedCity?.provinceCode,
          cityCode: _selectedCity?.cityCode,
          areaBucket: _selectedAreaBucket,
          budgetBucket: _selectedBudgetBucket,
        );
      },
      demoBuilder: ExhibitionStageDemoCatalog.projectList,
    );
  }

  Future<void> _load({bool forceRefresh = false}) async {
    setState(() => _loading = true);
    final snapshot = await _buildSource().load(forceRefresh: forceRefresh);
    if (!mounted) {
      return;
    }

    setState(() {
      _snapshot = snapshot;
      _loading = false;
    });
  }

  Future<void> _pickCityFilter() async {
    final catalog = _regionCatalog ?? await ChinaRegionCatalogLoader.load();
    if (!mounted) {
      return;
    }

    final picked = await showChinaCityPicker(
      context: context,
      catalog: catalog,
      title: '选择展示城市',
      initialProvinceCode: _selectedCity?.provinceCode,
      initialCityCode: _selectedCity?.cityCode,
      allowClear: true,
      clearLabel: '跟随当前城市上下文',
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _regionCatalog = catalog;
      _selectedCity = picked;
    });
    await _load(forceRefresh: true);
  }

  Future<void> _pickAreaBucket() async {
    final picked = await _showBucketPicker(
      title: '选择面积档位',
      clearLabel: '不限面积',
      currentValue: _selectedAreaBucket,
      options: _areaBucketOptions,
    );
    if (!mounted) {
      return;
    }
    setState(() => _selectedAreaBucket = picked);
    await _load(forceRefresh: true);
  }

  Future<void> _pickStateFilter() async {
    final picked = await _showBucketPicker(
      title: '选择状态',
      clearLabel: '全部状态',
      currentValue: _selectedState,
      options: _stateOptions,
    );
    if (!mounted) {
      return;
    }
    setState(() => _selectedState = picked);
  }

  Future<void> _pickTypeFilter() async {
    final options = _typeOptionsFromPayload(_snapshot?.result.payload);
    final picked = await _showBucketPicker(
      title: '选择项目类型',
      clearLabel: '全部类型',
      currentValue: _selectedType,
      options: options,
    );
    if (!mounted) {
      return;
    }
    setState(() => _selectedType = picked);
  }

  Future<void> _pickBudgetBucket() async {
    final picked = await _showBucketPicker(
      title: '选择金额档位',
      clearLabel: '不限金额',
      currentValue: _selectedBudgetBucket,
      options: _budgetBucketOptions,
    );
    if (!mounted) {
      return;
    }
    setState(() => _selectedBudgetBucket = picked);
    await _load(forceRefresh: true);
  }

  Future<String?> _showBucketPicker({
    required String title,
    required String clearLabel,
    required String? currentValue,
    required List<_ProjectBucketOption> options,
  }) {
    return showModalBottomSheet<String?>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: options.length + 1,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0) {
                      return ListTile(
                        title: Text(clearLabel),
                        trailing: currentValue == null
                            ? const Icon(Icons.check_rounded)
                            : null,
                        onTap: () => Navigator.of(context).pop(null),
                      );
                    }

                    final option = options[index - 1];
                    return ListTile(
                      title: Text(option.label),
                      trailing: currentValue == option.value
                          ? const Icon(Icons.check_rounded)
                          : null,
                      onTap: () => Navigator.of(context).pop(option.value),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    final result = snapshot?.result;

    return _LoadPageFrame(
      title: widget.surface == ProjectListSurface.showcase ? '项目展示' : '公开项目',
      summary: '公域项目只读展示；支持按城市、状态、类型、面积档位和金额档位筛选，退出展示不等于项目不存在。',
      loading: _loading,
      result: result,
      onRetry: () => _load(forceRefresh: true),
      fallbackTitle: snapshot?.fallbackTitle,
      fallbackMessage: snapshot?.fallbackMessage,
      showConnectionInfo: false,
      showTechnicalDisclosure: false,
      showPageSummaryCard: false,
      showContentStateCard: false,
      resultSectionsBuilder: (ExhibitionLoadResult result) {
        final rawItems = _itemMapsFromPayload(result.payload);
        final items = _applyLocalFilters(rawItems);
        final isVisualEmptyState =
            result.state == AppPageState.empty ||
            (result.state == AppPageState.content && items.isEmpty);
        final contentReady =
            result.state == AppPageState.content || isVisualEmptyState;
        return <Widget>[
          const SizedBox(height: 16),
          _buildFilterCard(),
          if (contentReady) const SizedBox(height: 16),
          if (isVisualEmptyState)
            const _EmptyNotice(
              title: '当前没有符合条件的公开项目',
              message: '当前展示：真实空结果。请切换城市、状态、类型、面积或金额后再查看。',
            ),
          if (result.state == AppPageState.content)
            ...items.map(
              (Map<String, Object?> item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ProjectShowcaseCompactCard(
                  item: item,
                  onPressed: () {
                    final projectId = _projectIdFromPayload(item);
                    if (projectId == null) {
                      return;
                    }
                    Navigator.of(context).pushNamed(
                      ExhibitionRoutes.projectDetailWithProjectId(projectId),
                    );
                  },
                ),
              ),
            ),
        ];
      },
    );
  }

  Widget _buildFilterCard() {
    final citySummary = _selectedCity == null
        ? '跟随城市'
        : '${_selectedCity!.provinceName} / ${_selectedCity!.cityName}';
    final stateSummary = _bucketLabel(_selectedState, _stateOptions) ?? '全部状态';
    final typeSummary =
        _bucketLabel(
          _selectedType,
          _typeOptionsFromPayload(_snapshot?.result.payload),
        ) ??
        '全部类型';
    final areaSummary =
        _bucketLabel(_selectedAreaBucket, _areaBucketOptions) ?? '不限面积';
    final budgetSummary =
        _bucketLabel(_selectedBudgetBucket, _budgetBucketOptions) ?? '不限金额';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final isWide = constraints.maxWidth >= 520;
                final columns = isWide ? 3 : 2;
                final itemWidth =
                    (constraints.maxWidth - (columns - 1) * 10) / columns;
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    SizedBox(
                      width: itemWidth,
                      child: _ProjectFilterFieldButton(
                        label: '城市',
                        value: _selectedCity == null
                            ? null
                            : '${_selectedCity!.provinceName} / ${_selectedCity!.cityName}',
                        placeholder: '跟随城市',
                        onTap: _pickCityFilter,
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _ProjectFilterFieldButton(
                        label: '状态',
                        value: _bucketLabel(_selectedState, _stateOptions),
                        placeholder: '全部状态',
                        onTap: _pickStateFilter,
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _ProjectFilterFieldButton(
                        label: '类型',
                        value: _bucketLabel(
                          _selectedType,
                          _typeOptionsFromPayload(_snapshot?.result.payload),
                        ),
                        placeholder: '全部类型',
                        onTap: _pickTypeFilter,
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _ProjectFilterFieldButton(
                        label: '面积',
                        value: _bucketLabel(
                          _selectedAreaBucket,
                          _areaBucketOptions,
                        ),
                        placeholder: '不限面积',
                        onTap: _pickAreaBucket,
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _ProjectFilterFieldButton(
                        label: '金额',
                        value: _bucketLabel(
                          _selectedBudgetBucket,
                          _budgetBucketOptions,
                        ),
                        placeholder: '不限金额',
                        onTap: _pickBudgetBucket,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _ProjectFilterSummaryChip(label: '城市', value: citySummary),
                _ProjectFilterSummaryChip(label: '状态', value: stateSummary),
                _ProjectFilterSummaryChip(label: '类型', value: typeSummary),
                _ProjectFilterSummaryChip(label: '面积', value: areaSummary),
                _ProjectFilterSummaryChip(label: '金额', value: budgetSummary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, Object?>> _applyLocalFilters(
    List<Map<String, Object?>> items,
  ) {
    return items
        .where((Map<String, Object?> item) {
          final state = _stateFromPayload(item);
          final buildingType = _normalizeId(item['buildingType'] as String?);
          if (_selectedState != null && state != _selectedState) {
            return false;
          }
          if (_selectedType != null && buildingType != _selectedType) {
            return false;
          }
          return true;
        })
        .toList(growable: false);
  }

  List<_ProjectBucketOption> _typeOptionsFromPayload(Object? payload) {
    final seen = <String>{};
    final options = <_ProjectBucketOption>[];
    for (final item in _itemMapsFromPayload(payload)) {
      final buildingType = _normalizeId(item['buildingType'] as String?);
      if (buildingType == null || !seen.add(buildingType)) {
        continue;
      }
      options.add(
        _ProjectBucketOption(
          value: buildingType,
          label: _buildingTypeLabel(buildingType),
        ),
      );
    }
    return options;
  }

  String? _bucketLabel(String? value, List<_ProjectBucketOption> options) {
    if (value == null) {
      return null;
    }
    for (final option in options) {
      if (option.value == value) {
        return option.label;
      }
    }
    return value;
  }
}

class _ProjectBucketOption {
  const _ProjectBucketOption({required this.value, required this.label});

  final String value;
  final String label;
}
