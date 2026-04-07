part of '../exhibition_trade_pages.dart';

enum ProjectListSurface { pool, showcase }

class ProjectListPage extends StatefulWidget {
  const ProjectListPage({super.key, this.surface = ProjectListSurface.pool});

  final ProjectListSurface surface;

  @override
  State<ProjectListPage> createState() => _ProjectListPageState();
}

class _ProjectListPageState extends State<ProjectListPage> {
  late final ExhibitionStageLoadAutoSource _source =
      ExhibitionStageLoadAutoSource(
        futureRealLoader: ({bool forceRefresh = false}) {
          return ExhibitionConsumerLayer.instance.loadProjectList(
            forceRefresh: forceRefresh,
          );
        },
        demoBuilder: ExhibitionStageDemoCatalog.projectList,
      );

  ExhibitionStageLoadSnapshot? _snapshot;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool forceRefresh = false}) async {
    setState(() {
      _loading = true;
    });

    final snapshot = await _source.load(forceRefresh: forceRefresh);

    if (!mounted) {
      return;
    }

    setState(() {
      _snapshot = snapshot;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    final result = snapshot?.result;

    return _LoadPageFrame(
      title: _pageTitle,
      summary: _pageSummary,
      loading: _loading,
      result: result,
      onRetry: () => _load(forceRefresh: true),
      showPageSummaryCard: false,
      showContentStateCard: false,
      showSourceNotice: false,
      showFallbackNotice: false,
      showConnectionInfo: false,
      showTechnicalDisclosure: false,
      resultSectionsBuilder: (ExhibitionLoadResult result) =>
          _buildResultSections(context, result, snapshot),
    );
  }

  List<Widget> _buildResultSections(
    BuildContext context,
    ExhibitionLoadResult result,
    ExhibitionStageLoadSnapshot? snapshot,
  ) {
    if (result.state != AppPageState.content &&
        result.state != AppPageState.empty) {
      return const <Widget>[];
    }

    final projectItems = _itemMapsFromPayload(result.payload);
    return <Widget>[
      const SizedBox(height: 16),
      _buildProjectOverviewCard(context, result, snapshot, projectItems),
    ];
  }

  Widget _buildProjectOverviewCard(
    BuildContext context,
    ExhibitionLoadResult result,
    ExhibitionStageLoadSnapshot? snapshot,
    List<Map<String, Object?>> projectItems,
  ) {
    return _ActionCard(
      title: _isShowcase ? '公开项目' : '项目列表',
      tone: _ActionCardTone.standard,
      children: <Widget>[
        _DetailLine(
          label: _isShowcase ? '当前项目' : '项目数量',
          value: '${_itemCountFromPayload(result.payload)} 个',
          highlight: _itemCountFromPayload(result.payload) > 0,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            FilledButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  _isShowcase
                      ? ExhibitionRoutes.workbench
                      : ExhibitionRoutes.projectCreate,
                );
              },
              child: Text(_isShowcase ? '项目工作台' : '创建项目'),
            ),
            FilledButton.tonal(
              onPressed: () => _load(forceRefresh: true),
              child: const Text('刷新列表'),
            ),
          ],
        ),
        ..._buildProjectItemCards(context, projectItems),
      ],
    );
  }

  List<Widget> _buildProjectItemCards(
    BuildContext context,
    List<Map<String, Object?>> projectItems,
  ) {
    if (projectItems.isEmpty) {
      return <Widget>[
        SizedBox(height: 16),
        _EmptyNotice(
          title: _isShowcase ? '当前没有项目' : '当前还没有项目',
          message: _isShowcase ? '暂无可展示项目。' : '创建项目后会显示在这里。',
        ),
      ];
    }

    return <Widget>[
      const SizedBox(height: 16),
      ...projectItems.map((Map<String, Object?> item) {
        final projectId = _normalizeId(item['projectId'] as String?);
        final title = _normalizeId(item['title'] as String?) ?? '未命名项目';
        final buildingType = _buildingTypeLabel(
          item['buildingType'] as String?,
        );
        final budgetAmount = item['budgetAmount'];
        final areaSqm = item['areaSqm'] as num?;
        final provinceCode = _normalizeId(item['provinceCode'] as String?);
        final provinceName = _normalizeId(item['provinceName'] as String?);
        final cityCode = _normalizeId(item['cityCode'] as String?);
        final cityName = _normalizeId(item['cityName'] as String?);
        final state = _normalizeId(item['state'] as String?);
        final summaryHeading = _projectSummaryHeading(item);
        final regionLabel = _projectRegionLabel(
          provinceCode: provinceCode,
          provinceName: provinceName,
          cityCode: cityCode,
          cityName: cityName,
        );
        final lightweightLabels = _projectLightweightLabels(
          regionLabel: regionLabel,
          buildingTypeLabel: buildingType,
          areaSqm: areaSqm,
        );
        final stateGuidance = _projectStateGuidance(state);
        if (projectId == null) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _EntityCard(
            title: title,
            description: summaryHeading ?? stateGuidance,
            statusLabel: state == null ? '可继续跟进' : _frontStageStateLabel(state),
            tone: _ActionCardTone.standard,
            detailLines: <Widget>[
              if (lightweightLabels.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: lightweightLabels.map((String item) {
                    return _StatusPill(
                      label: item,
                      tone: _ActionCardTone.muted,
                    );
                  }).toList(),
                ),
              if (lightweightLabels.isNotEmpty) const SizedBox(height: 8),
              _DetailLine(
                label: '预算金额',
                value: _currencyText(budgetAmount),
                highlight: true,
              ),
              if (regionLabel != null)
                _DetailLine(label: '项目地点', value: regionLabel),
            ],
            actionLabel: '查看详情',
            onPressed: () {
              Navigator.of(context).pushNamed(
                ExhibitionRoutes.projectDetailWithProjectId(
                  projectId,
                  surface: _isShowcase
                      ? ExhibitionRoutes.showcaseSurface
                      : null,
                ),
              );
            },
          ),
        );
      }),
    ];
  }

  bool get _isShowcase => widget.surface == ProjectListSurface.showcase;

  String get _pageTitle => _isShowcase ? '项目展示' : '项目列表';

  String get _pageSummary => _isShowcase ? '查看已发布项目。' : '查看当前项目。';

  String _projectStateGuidance(String? state) {
    if (state == null) {
      return '查看项目详情，确认当前信息。';
    }

    return switch (state) {
      'published' => '当前可继续查看详情。',
      'bidding_closed' => '当前项目投标已结束。',
      'awarded' => '当前项目已授标。',
      'converted_to_order' => '当前项目已转为订单。',
      _ => '当前项目状态：${_frontStageStateLabel(state)}',
    };
  }

  String? _projectSummaryHeading(Map<String, Object?> item) {
    final summary = item['summary'];
    if (summary is! Map) {
      return null;
    }

    final summaryMap = summary.map(
      (Object? key, Object? value) => MapEntry('$key', value),
    );
    return _normalizeId(summaryMap['heading'] as String?);
  }

  String? _projectRegionLabel({
    required String? provinceCode,
    required String? provinceName,
    required String? cityCode,
    required String? cityName,
  }) {
    final hasProvinceCarrier = provinceCode != null || provinceName != null;
    final hasCityCarrier = cityCode != null || cityName != null;
    if (!hasProvinceCarrier && !hasCityCarrier) {
      return null;
    }

    if (provinceName != null && cityName != null) {
      return provinceName == cityName
          ? provinceName
          : '$provinceName / $cityName';
    }
    return cityName ?? provinceName;
  }

  List<String> _projectLightweightLabels({
    required String? regionLabel,
    required String buildingTypeLabel,
    required num? areaSqm,
  }) {
    final labels = <String>[];
    if (regionLabel != null) {
      labels.add(regionLabel);
    }
    if (buildingTypeLabel.isNotEmpty) {
      labels.add(buildingTypeLabel);
    }
    if (areaSqm != null) {
      labels.add(_areaSqmLabel(areaSqm));
    }
    return labels;
  }

  String _areaSqmLabel(num value) {
    final normalized = value
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'\.?0+$'), '');
    return '$normalized ㎡';
  }
}
