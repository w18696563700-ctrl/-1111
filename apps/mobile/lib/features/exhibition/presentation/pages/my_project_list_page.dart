part of '../exhibition_trade_pages.dart';

class MyProjectListPage extends StatefulWidget {
  const MyProjectListPage({super.key, this.initialWorkspace});

  final String? initialWorkspace;

  @override
  State<MyProjectListPage> createState() => _MyProjectListPageState();
}

class _MyProjectListPageState extends State<MyProjectListPage> {
  late final ExhibitionStageLoadAutoSource _source =
      ExhibitionStageLoadAutoSource(
        futureRealLoader: ({bool forceRefresh = false}) {
          return ExhibitionConsumerLayer.instance.loadMyProjectList(
            forceRefresh: forceRefresh,
          );
        },
        demoBuilder: ExhibitionStageDemoCatalog.myProjectList,
      );

  ExhibitionStageLoadSnapshot? _snapshot;
  ExhibitionLoadResult? _myBidResult;
  bool _loading = true;
  bool _myBidLoading = false;
  late _MyProjectWorkspaceBucket _selectedWorkspace;
  _MyProjectStageBucket _selectedStage = _MyProjectStageBucket.draft;

  @override
  void initState() {
    super.initState();
    _selectedWorkspace = _myProjectWorkspaceFromRoute(widget.initialWorkspace);
    _load();
    if (_selectedWorkspace == _MyProjectWorkspaceBucket.bids) {
      _loadMyBidList(forceRefresh: true);
    }
  }

  Future<void> _load({bool forceRefresh = false}) async {
    setState(() => _loading = true);
    final snapshot = await _source.load(forceRefresh: forceRefresh);
    if (!mounted) {
      return;
    }

    setState(() {
      _snapshot = snapshot;
      _selectedStage = _myProjectPreferredStageFromPayload(
        snapshot.result.payload,
      );
      _loading = false;
    });
  }

  Future<void> _openRoute(String routeName) async {
    await Navigator.of(context).pushNamed(routeName);
    if (!mounted) {
      return;
    }
    await _load(forceRefresh: true);
    if (_selectedWorkspace == _MyProjectWorkspaceBucket.bids) {
      await _loadMyBidList(forceRefresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    final result = snapshot?.result;

    return _LoadPageFrame(
      title: '我的项目',
      summary: '按四个阶段查看当前组织的项目，并先看清每条项目下一步能做什么。',
      loading: _loading,
      result: result,
      onRetry: () => _load(forceRefresh: true),
      recoveryRouteOverride: AppBuilding.profile.routePath,
      recoveryButtonLabelOverride: '回到我的楼',
      sourceLabel: snapshot?.sourceLabel,
      sourceMessage: snapshot?.sourceMessage,
      fallbackTitle: snapshot?.fallbackTitle,
      fallbackMessage: snapshot?.fallbackMessage,
      showConnectionInfo: false,
      showTechnicalDisclosure: false,
      showPageSummaryCard: false,
      showContentStateCard: false,
      resultSectionsBuilder: (ExhibitionLoadResult result) {
        if (result.state != AppPageState.content &&
            result.state != AppPageState.empty) {
          return const <Widget>[];
        }

        return <Widget>[
          const SizedBox(height: 16),
          _buildMyProjectWorkspaceTabsCard(
            selectedWorkspace: _selectedWorkspace,
            onSelected: _selectWorkspace,
          ),
          const SizedBox(height: 16),
          if (_selectedWorkspace == _MyProjectWorkspaceBucket.published) ...[
            _buildStageTabsCard(result.payload),
            const SizedBox(height: 16),
            _buildStageSection(context, result.payload),
          ] else
            _buildMyBidWorkspaceSection(context),
        ];
      },
    );
  }

  void _selectWorkspace(_MyProjectWorkspaceBucket value) {
    if (_selectedWorkspace == value) {
      return;
    }
    setState(() => _selectedWorkspace = value);
    if (value == _MyProjectWorkspaceBucket.bids) {
      _loadMyBidList();
    }
  }

  Widget _buildStageTabsCard(Object? payload) {
    final currentStage = _myProjectStageOption(_selectedStage);
    final currentCount = _myProjectItemsForStage(
      payload,
      _selectedStage,
    ).length;
    final mainlineStageOptions = _myProjectPrimaryStageOptions
        .where(
          (_MyProjectStageOption option) =>
              option.value != _MyProjectStageBucket.draft,
        )
        .toList();

    return _ActionCard(
      title: '项目阶段',
      summary: '预发布、竞标中和进行中保持主流程展示；草稿和已归档收进下方入口。',
      tone: _ActionCardTone.emphasis,
      children: <Widget>[
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: mainlineStageOptions.map((_MyProjectStageOption option) {
            final count = _myProjectItemsForStage(payload, option.value).length;
            return ChoiceChip(
              label: Text('${option.label} · $count'),
              selected: option.value == _selectedStage,
              onSelected: (_) {
                setState(() => _selectedStage = option.value);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _StateMessage(
          title: currentStage.label,
          body:
              '${currentStage.description} 当前只显示${currentStage.label}阶段，共 $currentCount 个项目；切换上方阶段标签可查看其他阶段。',
        ),
        const SizedBox(height: 16),
        _MyProjectSecondaryStageEntrances(
          draftCount: _myProjectItemsForStage(
            payload,
            _MyProjectStageBucket.draft,
          ).length,
          archivedCount: _myProjectArchivedItemsFromPayload(payload).length,
          selectedStage: _selectedStage,
          onSelected: (_MyProjectStageBucket stage) {
            setState(() => _selectedStage = stage);
          },
        ),
      ],
    );
  }

  Widget _buildStageSection(BuildContext context, Object? payload) {
    final currentStage = _myProjectStageOption(_selectedStage);
    final items = _myProjectItemsForStage(payload, _selectedStage);

    return _ActionCard(
      title: _myProjectStageSectionTitle(currentStage.value),
      summary: currentStage.description,
      children: <Widget>[
        if (items.isEmpty)
          _EmptyNotice(
            title: currentStage.emptyTitle,
            message: currentStage.emptyMessage,
          )
        else
          ...items.map((Map<String, Object?> item) {
            final publicProject = _myProjectPublicProjectMap(item);
            final privateSummary = _myProjectPrivateProgressMap(item);
            final projectId = _normalizeId(
              publicProject?['projectId'] as String?,
            );
            if (publicProject == null ||
                privateSummary == null ||
                projectId == null) {
              return const SizedBox.shrink();
            }

            final title =
                _normalizeId(publicProject['title'] as String?) ?? '未命名项目';
            final projectNo =
                _normalizeId(publicProject['projectNo'] as String?) ?? '未提供';
            final summaryHeading =
                _myProjectSummaryHeading(publicProject) ?? '当前项目已保存。';
            final state = _normalizeId(publicProject['state'] as String?);
            final stage = _myProjectStageOption(
              _myProjectStageBucketFromState(state),
            );
            final buildingType = _buildingTypeLabel(
              publicProject['buildingType'] as String?,
            );
            final areaLabel = _myProjectAreaLabel(
              publicProject['areaSqm'] as num?,
            );
            final regionLabel = _myProjectRegionLabel(publicProject);
            final pills = <String>[
              ...?(regionLabel == null ? null : <String>[regionLabel]),
              buildingType,
              if (publicProject['areaSqm'] is num) areaLabel,
              _myProjectFormalCompletionLabel(
                privateSummary['formalCompletionStatus'] as String?,
              ),
              _myProjectEvaluationLabel(
                privateSummary['evaluationStatus'] as String?,
              ),
            ];

            final actionLabel = switch (stage.value) {
              _MyProjectStageBucket.draft => '继续编辑',
              _MyProjectStageBucket.submitted => '补资料后确认发布',
              _ => '查看详情',
            };
            final routeName = stage.value == _MyProjectStageBucket.draft
                ? ExhibitionRoutes.projectEditWithProjectId(projectId)
                : ExhibitionRoutes.myProjectDetailWithProjectId(projectId);

            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _EntityCard(
                title: title,
                description: summaryHeading,
                statusLabel: stage.label,
                detailLines: <Widget>[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: pills.map((String item) {
                      return _StatusPill(
                        label: item,
                        tone: _ActionCardTone.muted,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  _DetailLine(label: '项目编号', value: projectNo),
                  _DetailLine(
                    label: '当前阶段',
                    value: stage.label,
                    highlight: true,
                  ),
                  _DetailLine(
                    label: '当前下一步',
                    value: stage.cardNextStep,
                    highlight: true,
                  ),
                  _DetailLine(
                    label: '预算金额',
                    value: _currencyText(publicProject['budgetAmount']),
                    highlight: true,
                  ),
                  if (regionLabel != null)
                    _DetailLine(label: '项目地点', value: regionLabel),
                  if (publicProject['areaSqm'] is num)
                    _DetailLine(label: '项目面积', value: areaLabel),
                ],
                actionLabel: actionLabel,
                actionSummary: stage.cardNextStep,
                onPressed: () => _openRoute(routeName),
              ),
            );
          }),
      ],
    );
  }
}

String _myProjectStageSectionTitle(_MyProjectStageBucket stage) {
  return switch (stage) {
    _MyProjectStageBucket.draft => '草稿列表',
    _MyProjectStageBucket.archived => '已归档列表',
    _ => _myProjectStageOption(stage).label,
  };
}

class _MyProjectSecondaryStageEntrances extends StatelessWidget {
  const _MyProjectSecondaryStageEntrances({
    required this.draftCount,
    required this.archivedCount,
    required this.selectedStage,
    required this.onSelected,
  });

  final int draftCount;
  final int archivedCount;
  final _MyProjectStageBucket selectedStage;
  final ValueChanged<_MyProjectStageBucket> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '低频入口',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        _MyProjectSecondaryStageTile(
          label: '草稿',
          count: draftCount,
          summary: '未完成项目先收起，需要继续编辑或删除时再进入。',
          selected: selectedStage == _MyProjectStageBucket.draft,
          onPressed: () => onSelected(_MyProjectStageBucket.draft),
        ),
        const SizedBox(height: 10),
        _MyProjectSecondaryStageTile(
          label: '已归档',
          count: archivedCount,
          summary: '历史项目只保留查看入口，不开放删除。',
          selected: selectedStage == _MyProjectStageBucket.archived,
          onPressed: () => onSelected(_MyProjectStageBucket.archived),
        ),
      ],
    );
  }
}

class _MyProjectSecondaryStageTile extends StatelessWidget {
  const _MyProjectSecondaryStageTile({
    required this.label,
    required this.count,
    required this.summary,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final int count;
  final String summary;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderColor = selected
        ? colorScheme.primary.withValues(alpha: 0.38)
        : colorScheme.outlineVariant;
    final backgroundColor = selected
        ? colorScheme.primaryContainer.withValues(alpha: 0.42)
        : colorScheme.surface;

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '$label · $count 个',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          summary,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: selected ? colorScheme.primary : colorScheme.outline,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

_MyProjectWorkspaceBucket _myProjectWorkspaceFromRoute(String? workspace) {
  return workspace?.trim() == 'bids'
      ? _MyProjectWorkspaceBucket.bids
      : _MyProjectWorkspaceBucket.published;
}
