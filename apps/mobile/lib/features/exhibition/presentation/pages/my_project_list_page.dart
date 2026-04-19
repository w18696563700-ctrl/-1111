part of '../exhibition_trade_pages.dart';

class MyProjectListPage extends StatefulWidget {
  const MyProjectListPage({super.key});

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
  bool _loading = true;
  _MyProjectWorkspaceBucket _selectedWorkspace =
      _MyProjectWorkspaceBucket.published;
  _MyProjectStageBucket _selectedStage = _MyProjectStageBucket.draft;
  String? _publishingProjectId;

  @override
  void initState() {
    super.initState();
    _load();
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
  }

  Future<bool?> _confirmLifecycleAction({
    required String title,
    required String content,
    required String confirmLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
  }

  Future<void> _publishSubmittedProject({
    required String projectId,
    required String? state,
  }) async {
    if (_publishingProjectId != null) {
      return;
    }
    if (!_myProjectCanPublish(state)) {
      _showPageMessage('当前项目尚未进入预发布列表，暂不支持正式发布。');
      return;
    }

    final action = _myProjectLifecycleActionOption(
      _MyProjectLifecycleActionKind.publish,
    );
    final confirmed = await _confirmLifecycleAction(
      title: action.confirmTitle,
      content: action.confirmMessage,
      confirmLabel: action.confirmLabel,
    );
    if (!mounted || confirmed != true) {
      return;
    }

    setState(() => _publishingProjectId = projectId);
    final result = await ExhibitionConsumerLayer.instance.publishProject(
      ProjectLifecycleActionCommand(projectId: projectId),
    );
    if (!mounted) {
      return;
    }

    setState(() => _publishingProjectId = null);
    if (!result.isSuccess) {
      _showPageMessage(_userFacingActionFailureMessage(result));
      return;
    }

    ExhibitionConsumerLayer.instance.invalidateMyProjectList();
    await _load(forceRefresh: true);
    if (!mounted) {
      return;
    }

    setState(() => _selectedStage = _MyProjectStageBucket.published);
    _showPageMessage(action.successMessage);
  }

  void _showPageMessage(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(SnackBar(content: Text(message)));
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
            onSelected: (value) {
              setState(() => _selectedWorkspace = value);
            },
          ),
          const SizedBox(height: 16),
          if (_selectedWorkspace == _MyProjectWorkspaceBucket.published) ...[
            _buildStageTabsCard(result.payload),
            const SizedBox(height: 16),
            _buildStageSection(context, result.payload),
            ..._buildArchivedSection(context, result.payload),
          ] else
            _buildMyProjectBidPlaceholderSection(context),
        ];
      },
    );
  }

  Widget _buildStageTabsCard(Object? payload) {
    final currentStage = _myProjectStageOption(_selectedStage);
    final currentCount = _myProjectItemsForStage(
      payload,
      _selectedStage,
    ).length;

    return _ActionCard(
      title: '项目阶段',
      summary: '先按阶段分栏，再查看当前项目最推荐的下一步。',
      tone: _ActionCardTone.emphasis,
      children: <Widget>[
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _myProjectPrimaryStageOptions.map((
            _MyProjectStageOption option,
          ) {
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
          body: '${currentStage.description} 当前共有 $currentCount 个项目。',
        ),
      ],
    );
  }

  Widget _buildStageSection(BuildContext context, Object? payload) {
    final currentStage = _myProjectStageOption(_selectedStage);
    final items = _myProjectItemsForStage(payload, _selectedStage);

    return _ActionCard(
      title: currentStage.label,
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
              _MyProjectStageBucket.submitted =>
                _publishingProjectId == projectId
                    ? _myProjectLifecycleActionOption(
                        _MyProjectLifecycleActionKind.publish,
                      ).loadingLabel
                    : _myProjectLifecycleActionOption(
                        _MyProjectLifecycleActionKind.publish,
                      ).buttonLabel,
              _ => '查看详情',
            };
            final routeName = stage.value == _MyProjectStageBucket.draft
                ? ExhibitionRoutes.projectEditWithProjectId(projectId)
                : ExhibitionRoutes.myProjectDetailWithProjectId(projectId);
            final secondaryActionLabel =
                stage.value == _MyProjectStageBucket.submitted ? '查看详情' : null;

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
                onPressed: () {
                  if (stage.value == _MyProjectStageBucket.submitted) {
                    _publishSubmittedProject(
                      projectId: projectId,
                      state: state,
                    );
                    return;
                  }
                  _openRoute(routeName);
                },
                secondaryActionLabel: secondaryActionLabel,
                onSecondaryPressed: secondaryActionLabel == null
                    ? null
                    : () => _openRoute(routeName),
              ),
            );
          }),
      ],
    );
  }

  List<Widget> _buildArchivedSection(BuildContext context, Object? payload) {
    final archivedItems = _myProjectArchivedItemsFromPayload(payload);
    if (archivedItems.isEmpty) {
      return const <Widget>[];
    }

    final archivedStage = _myProjectStageOption(_MyProjectStageBucket.archived);
    return <Widget>[
      const SizedBox(height: 16),
      _ActionCard(
        title: archivedStage.label,
        summary: archivedStage.description,
        tone: _ActionCardTone.muted,
        children: archivedItems.map((Map<String, Object?> item) {
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
              _myProjectSummaryHeading(publicProject) ?? '当前项目已归档。';
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
          ];

          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: _EntityCard(
              title: title,
              description: summaryHeading,
              statusLabel: archivedStage.label,
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
                  value: archivedStage.label,
                  highlight: true,
                ),
                _DetailLine(
                  label: '当前下一步',
                  value: archivedStage.cardNextStep,
                  highlight: true,
                ),
              ],
              actionLabel: '查看详情',
              actionSummary: archivedStage.cardNextStep,
              onPressed: () => _openRoute(
                ExhibitionRoutes.myProjectDetailWithProjectId(projectId),
              ),
            ),
          );
        }).toList(),
      ),
    ];
  }
}
