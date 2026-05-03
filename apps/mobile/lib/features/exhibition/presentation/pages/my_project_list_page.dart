part of '../exhibition_trade_pages.dart';

class MyProjectListPage extends StatefulWidget {
  const MyProjectListPage({
    super.key,
    this.initialWorkspace,
    this.initialStage,
    this.highlightProjectId,
  });

  final String? initialWorkspace;
  final String? initialStage;
  final String? highlightProjectId;

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
  late _MyProjectStageBucket _selectedStage;
  late final bool _hasInitialStage;
  final GlobalKey _highlightedProjectKey = GlobalKey();
  bool _highlightScrollScheduled = false;

  @override
  void initState() {
    super.initState();
    _selectedWorkspace = _myProjectWorkspaceFromRoute(widget.initialWorkspace);
    final initialStage = _myProjectStageBucketFromRoute(widget.initialStage);
    _selectedStage = initialStage ?? _MyProjectStageBucket.draft;
    _hasInitialStage = initialStage != null;
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
      if (!_hasInitialStage) {
        _selectedStage = _myProjectPreferredStageFromPayload(
          snapshot.result.payload,
        );
      }
      _loading = false;
    });
    _scheduleHighlightScroll();
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
          _buildMyProjectOverviewCard(result.payload),
          const SizedBox(height: 14),
          _buildMyProjectWorkspaceTabsCard(
            selectedWorkspace: _selectedWorkspace,
            onSelected: _selectWorkspace,
          ),
          const SizedBox(height: 14),
          if (_selectedWorkspace == _MyProjectWorkspaceBucket.published) ...[
            _buildStageTabsCard(context, result.payload),
            const SizedBox(height: 14),
            _buildStageSection(result.payload),
          ] else
            _buildMyBidWorkspaceSection(context),
          const SizedBox(height: 68),
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

  String? get _highlightProjectId => _normalizeId(widget.highlightProjectId);

  void _scheduleHighlightScroll() {
    if (_highlightProjectId == null || _highlightScrollScheduled) {
      return;
    }
    _highlightScrollScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _highlightScrollScheduled = false;
      if (!mounted) {
        return;
      }
      final targetContext = _highlightedProjectKey.currentContext;
      if (targetContext == null) {
        return;
      }
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        alignment: 0.18,
      );
    });
  }

  Widget _buildMyProjectOverviewCard(Object? payload) {
    final publishCount = _myProjectAllItemsFromPayload(payload).length;
    final myBidCount = _myBidResult == null
        ? null
        : _myBidItemsFromPayload(_myBidResult?.payload).length;

    return _MyProjectOverviewCard(
      publishCount: publishCount,
      bidCount: myBidCount,
      bidLoading: _myBidLoading,
    );
  }

  Widget _buildStageTabsCard(BuildContext context, Object? payload) {
    final currentStage = _myProjectStageOption(_selectedStage);
    final currentCount = _myProjectItemsForStage(
      payload,
      _selectedStage,
    ).length;
    final stageOptions = <_MyProjectStageOption>[
      ..._myProjectPrimaryStageOptions,
      _myProjectArchivedStageOption,
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '项目阶段',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: stageOptions.map((_MyProjectStageOption option) {
                  final count = _myProjectItemsForStage(
                    payload,
                    option.value,
                  ).length;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('${option.label} · $count'),
                      selected: option.value == _selectedStage,
                      onSelected: (_) {
                        setState(() => _selectedStage = option.value);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            _MyProjectStageHint(
              label: currentStage.label,
              count: currentCount,
              body: _myProjectStageShortDescription(currentStage.value),
            ),
            const SizedBox(height: 12),
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
        ),
      ),
    );
  }

  Widget _buildStageSection(Object? payload) {
    final currentStage = _myProjectStageOption(_selectedStage);
    final items = _myProjectItemsForStage(payload, _selectedStage);

    return _ActionCard(
      title: _myProjectStageSectionTitle(currentStage.value),
      summary: _myProjectStageSectionSummary(currentStage.value),
      children: <Widget>[
        if (items.isNotEmpty)
          _MyProjectSectionCountLine(
            count: items.length,
            stageLabel: currentStage.label,
          ),
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
              _currencyText(publicProject['budgetAmount']),
            ];

            final actionLabel = switch (stage.value) {
              _MyProjectStageBucket.draft => '继续编辑',
              _MyProjectStageBucket.submitted => '补资料后确认发布',
              _ => '查看详情',
            };
            final routeName = stage.value == _MyProjectStageBucket.draft
                ? ExhibitionRoutes.projectEditWithProjectId(projectId)
                : ExhibitionRoutes.myProjectDetailWithProjectId(
                    projectId,
                    stage: _myProjectDetailRouteStageHint(stage.value),
                  );
            final detailRouteName =
                ExhibitionRoutes.myProjectDetailWithProjectId(
                  projectId,
                  stage: _myProjectDetailRouteStageHint(stage.value),
                );
            final highlighted = projectId == _highlightProjectId;

            Widget card = _MyProjectCompactCard(
              title: title,
              description: summaryHeading,
              statusLabel: stage.label,
              chips: pills,
              stageLabel: stage.label,
              nextStep: _myProjectStageListNextStep(stage.value),
              projectNo: projectNo,
              formalStatus: _myProjectFormalCompletionLabel(
                privateSummary['formalCompletionStatus'] as String?,
              ),
              evaluationStatus: _myProjectEvaluationLabel(
                privateSummary['evaluationStatus'] as String?,
              ),
              actionLabel: actionLabel,
              onPressed: () => _openRoute(routeName),
              secondaryActionLabel: stage.value == _MyProjectStageBucket.draft
                  ? '查看详情'
                  : null,
              onSecondaryPressed: stage.value == _MyProjectStageBucket.draft
                  ? () => _openRoute(detailRouteName)
                  : null,
              highlighted: highlighted,
            );
            if (highlighted) {
              card = KeyedSubtree(key: _highlightedProjectKey, child: card);
            }

            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: card,
            );
          }),
      ],
    );
  }
}

_MyProjectWorkspaceBucket _myProjectWorkspaceFromRoute(String? workspace) {
  return workspace?.trim() == 'bids'
      ? _MyProjectWorkspaceBucket.bids
      : _MyProjectWorkspaceBucket.published;
}

String? _myProjectDetailRouteStageHint(_MyProjectStageBucket stage) {
  return switch (stage) {
    _MyProjectStageBucket.submitted => 'submitted',
    _MyProjectStageBucket.published => 'published',
    _ => null,
  };
}
