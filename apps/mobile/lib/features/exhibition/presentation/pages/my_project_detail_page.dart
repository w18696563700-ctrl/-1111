part of '../exhibition_trade_pages.dart';

class MyProjectDetailPage extends StatefulWidget {
  const MyProjectDetailPage({super.key, this.projectId});

  final String? projectId;

  @override
  State<MyProjectDetailPage> createState() => _MyProjectDetailPageState();
}

class _MyProjectDetailPageState extends State<MyProjectDetailPage> {
  late final ExhibitionStageLoadAutoSource _source =
      ExhibitionStageLoadAutoSource(
        futureRealLoader: ({bool forceRefresh = false}) {
          return ExhibitionConsumerLayer.instance.loadMyProjectDetail(
            projectId: widget.projectId,
            forceRefresh: forceRefresh,
          );
        },
        demoBuilder: () => ExhibitionStageDemoCatalog.myProjectDetail(
          projectId: widget.projectId,
        ),
      );

  final GlobalKey _attachmentSectionKey = GlobalKey();
  ExhibitionStageLoadSnapshot? _snapshot;
  bool _loading = true;
  bool _deletingProject = false;
  _MyProjectLifecycleActionKind? _submittingLifecycleAction;

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
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    final result = snapshot?.result;

    return _LoadPageFrame(
      title: '项目详情',
      summary: '查看当前项目已保存的信息、所在阶段和下一步能做什么。',
      loading: _loading,
      result: result,
      onRetry: () => _load(forceRefresh: true),
      recoveryRouteOverride: ExhibitionRoutes.myProjectList,
      recoveryButtonLabelOverride: '回到我的项目',
      fallbackTitle: snapshot?.fallbackTitle,
      fallbackMessage: snapshot?.fallbackMessage,
      showConnectionInfo: false,
      showTechnicalDisclosure: false,
      showPageSummaryCard: false,
      showContentStateCard: false,
      resultSectionsBuilder: (ExhibitionLoadResult result) {
        if (result.state != AppPageState.content) {
          return const <Widget>[];
        }

        final payload = _payloadMap(result.payload);
        final publicProject = payload?['publicProject'];
        final privateProgress = payload?['privateProgress'];
        final publicMap = publicProject is Map
            ? publicProject.map(
                (Object? key, Object? value) => MapEntry('$key', value),
              )
            : null;
        final privateMap = privateProgress is Map
            ? privateProgress.map(
                (Object? key, Object? value) => MapEntry('$key', value),
              )
            : null;
        if (publicMap == null || privateMap == null) {
          return const <Widget>[];
        }

        final projectId =
            _normalizeId(publicMap['projectId'] as String?) ??
            _normalizeId(widget.projectId);
        final projectNo = _normalizeId(publicMap['projectNo'] as String?);
        final title = _normalizeId(publicMap['title'] as String?);
        final buildingType = _normalizeId(publicMap['buildingType'] as String?);
        final budgetAmount = publicMap['budgetAmount'];
        final areaSqm = publicMap['areaSqm'] as num?;
        final state = _normalizeId(publicMap['state'] as String?);
        final stage = _myProjectStageOption(
          _myProjectStageBucketFromState(state),
        );
        final viewerProjectRelation = _normalizeId(
          publicMap['viewerProjectRelation'] as String?,
        );
        final summaryHeading = _myProjectSummaryHeading(publicMap);
        final isOwnerSurface = viewerProjectRelation == 'owner';
        final canRunLifecycleActions =
            isOwnerSurface && snapshot?.isDemo != true;
        final canManageAttachments =
            isOwnerSurface &&
            snapshot?.isDemo != true &&
            _myProjectCanOpenAttachmentStage(state);
        final showContinueAttachmentAction =
            canManageAttachments &&
            (stage.value == _MyProjectStageBucket.submitted ||
                stage.value == _MyProjectStageBucket.published);

        return <Widget>[
          const SizedBox(height: 16),
          _buildSavedSummaryCard(
            title: title,
            projectNo: projectNo,
            buildingType: buildingType,
            budgetAmount: budgetAmount,
            areaSqm: areaSqm,
            summaryHeading: summaryHeading,
            stage: stage,
            privateMap: privateMap,
            showContinueAttachmentAction: showContinueAttachmentAction,
            onContinueAttachmentAction: showContinueAttachmentAction
                ? _scrollToAttachments
                : null,
          ),
          // Published detail intentionally keeps only the summary-card
          // handoff for materials to avoid duplicating a second action block.
          if (stage.value != _MyProjectStageBucket.published) ...<Widget>[
            const SizedBox(height: 16),
            _buildStageActionCard(
              context,
              projectId: projectId,
              stage: stage,
              state: state,
              isOwnerSurface: isOwnerSurface,
              canRunLifecycleActions: canRunLifecycleActions,
              canManageAttachments: canManageAttachments,
            ),
          ],
          if (projectId != null) ...<Widget>[
            const SizedBox(height: 16),
            _buildOwnerTradingImEntryCard(projectId),
          ],
          if (canManageAttachments && projectId != null) ...<Widget>[
            const SizedBox(height: 16),
            KeyedSubtree(
              key: _attachmentSectionKey,
              child: _ProjectAttachmentSection(
                key: ValueKey<String>('my-project-attachment-$projectId'),
                projectId: projectId,
                title: '项目详情文书区',
                summary: '预发布阶段已开放效果图、施工图和其他资料。补齐后再检查无误并正式发布。',
                // Keep the detail surface compact: no duplicated technical
                // upload-chain explanation above the attachment controls.
                showIntroCopy: false,
                compactKindHints: true,
                emptyMessage: '当前还没有补充效果图、施工图或其他资料。',
              ),
            ),
            const SizedBox(height: 16),
            _ProjectPublicResourceSection(
              key: ValueKey<String>('my-project-public-resource-$projectId'),
              title: '公共资源下载区',
              summary: '这里提供平台共享参考资料，用于帮助项目发布与续接过程理解规则和流程，不替代私域项目文书区。',
              onMessage: _showPageMessage,
            ),
          ],
        ];
      },
    );
  }

  Widget _buildOwnerTradingImEntryCard(String projectId) {
    return _ActionCard(
      title: '项目沟通',
      children: <Widget>[
        const _StateMessage(
          title: '当前对象',
          body: '项目澄清绑定当前项目；具体投标沟通从 bidId 承接入口进入。',
        ),
        const SizedBox(height: 12),
        FilledButton.tonalIcon(
          onPressed: () => Navigator.of(context).pushNamed(
            ExhibitionRoutes.projectClarificationWithProjectId(projectId),
          ),
          icon: const Icon(Icons.forum_rounded),
          label: const Text('项目澄清'),
        ),
      ],
    );
  }

  Widget _buildSavedSummaryCard({
    required String? title,
    required String? projectNo,
    required String? buildingType,
    required Object? budgetAmount,
    required num? areaSqm,
    required String? summaryHeading,
    required _MyProjectStageOption stage,
    required Map<String, Object?> privateMap,
    required bool showContinueAttachmentAction,
    required VoidCallback? onContinueAttachmentAction,
  }) {
    return _ActionCard(
      title: '已保存的项目基础信息摘要',
      tone: _ActionCardTone.emphasis,
      children: <Widget>[
        _DetailLine(label: '项目名称', value: title ?? '未提供'),
        _DetailLine(label: '项目编号', value: projectNo ?? '未提供'),
        _DetailLine(label: '项目类型', value: _buildingTypeLabel(buildingType)),
        _DetailLine(
          label: '预算金额',
          value: _currencyText(budgetAmount),
          highlight: true,
        ),
        _DetailLine(label: '项目面积', value: _areaOrUnavailable(areaSqm)),
        _DetailLine(label: '当前阶段', value: stage.label, highlight: true),
        _DetailLine(
          label: '当前下一步',
          value: stage.detailNextStep,
          highlight: true,
        ),
        _DetailLine(label: '项目摘要', value: summaryHeading ?? '当前项目暂未提供摘要。'),
        _DetailLine(
          label: '正式完结补充',
          value: _myProjectFormalCompletionLabel(
            privateMap['formalCompletionStatus'] as String?,
          ),
        ),
        if (showContinueAttachmentAction) ...<Widget>[
          const _DetailLine(
            label: '项目详情文书',
            value: '预发布阶段已开放效果图、施工图和其他资料。',
            highlight: true,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: onContinueAttachmentAction,
              child: const Text('补充项目详情文书'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStageActionCard(
    BuildContext context, {
    required String? projectId,
    required _MyProjectStageOption stage,
    required String? state,
    required bool isOwnerSurface,
    required bool canRunLifecycleActions,
    required bool canManageAttachments,
  }) {
    if (!isOwnerSurface) {
      return _ActionCard(
        title: '当前阶段动作',
        summary: '当前仅支持查看，不展示 owner 私域动作。',
        children: <Widget>[
          _StateMessage(title: '当前下一步', body: stage.detailNextStep),
        ],
      );
    }

    final children = <Widget>[
      _StateMessage(title: '当前下一步', body: stage.detailNextStep),
      if (stage.value == _MyProjectStageBucket.submitted) ...<Widget>[
        const SizedBox(height: 12),
        const _StateMessage(
          title: '发布前确认',
          body: '预发布阶段已开放项目详情文书区，请先补充效果图、施工图和其他资料；确认无误后再点击“检查无误，确定发布”。',
        ),
      ],
      const SizedBox(height: 12),
    ];

    switch (stage.value) {
      case _MyProjectStageBucket.draft:
        children.add(
          FilledButton(
            onPressed: projectId == null
                ? null
                : () => _openProjectEdit(projectId),
            child: const Text('继续编辑'),
          ),
        );
        children.add(const SizedBox(height: 12));
        children.add(
          OutlinedButton(
            onPressed: _deletingProject ? null : _deleteCurrentProject,
            child: Text(_deletingProject ? '删除中...' : '删除此项目'),
          ),
        );
      case _MyProjectStageBucket.submitted:
        children.add(
          FilledButton(
            onPressed: !canRunLifecycleActions || !_myProjectCanPublish(state)
                ? null
                : () => _runLifecycleAction(
                    _MyProjectLifecycleActionKind.publish,
                    projectId: projectId,
                  ),
            child: Text(
              _buttonLabelForLifecycleAction(
                _MyProjectLifecycleActionKind.publish,
              ),
            ),
          ),
        );
        children.add(const SizedBox(height: 12));
        children.add(
          OutlinedButton(
            onPressed: !canRunLifecycleActions || !_myProjectCanWithdraw(state)
                ? null
                : () => _runLifecycleAction(
                    _MyProjectLifecycleActionKind.withdraw,
                    projectId: projectId,
                  ),
            child: Text(
              _buttonLabelForLifecycleAction(
                _MyProjectLifecycleActionKind.withdraw,
              ),
            ),
          ),
        );
        children.add(const SizedBox(height: 12));
        children.add(
          OutlinedButton(
            onPressed: !canRunLifecycleActions || !_myProjectCanArchive(state)
                ? null
                : () => _runLifecycleAction(
                    _MyProjectLifecycleActionKind.archive,
                    projectId: projectId,
                  ),
            child: Text(
              _buttonLabelForLifecycleAction(
                _MyProjectLifecycleActionKind.archive,
              ),
            ),
          ),
        );
      case _MyProjectStageBucket.published:
        children.add(
          FilledButton(
            onPressed: canManageAttachments ? _scrollToAttachments : null,
            child: Text(canManageAttachments ? '补充项目详情文书' : '补充资料（当前待开放）'),
          ),
        );
        children.add(const SizedBox(height: 12));
        children.add(
          OutlinedButton(
            onPressed: !canRunLifecycleActions || !_myProjectCanClose(state)
                ? null
                : () => _runLifecycleAction(
                    _MyProjectLifecycleActionKind.close,
                    projectId: projectId,
                  ),
            child: Text(
              _buttonLabelForLifecycleAction(
                _MyProjectLifecycleActionKind.close,
              ),
            ),
          ),
        );
      case _MyProjectStageBucket.active:
        children.add(
          const OutlinedButton(onPressed: null, child: Text('业务继续处理入口待开放')),
        );
      case _MyProjectStageBucket.archived:
        children.add(
          const OutlinedButton(onPressed: null, child: Text('当前已归档，仅支持查看')),
        );
    }

    return _ActionCard(
      title: '当前阶段动作',
      summary: stage.value == _MyProjectStageBucket.submitted
          ? '先补资料后确认发布；返回草稿和作废归档继续使用现有动作。'
          : '动作区严格跟随当前阶段，不再混放跨阶段入口。',
      children: children,
    );
  }

  String _buttonLabelForLifecycleAction(_MyProjectLifecycleActionKind kind) {
    if (_submittingLifecycleAction == kind) {
      return _myProjectLifecycleActionOption(kind).loadingLabel;
    }
    return _myProjectLifecycleActionOption(kind).buttonLabel;
  }

  Future<void> _runLifecycleAction(
    _MyProjectLifecycleActionKind kind, {
    required String? projectId,
  }) async {
    if (_submittingLifecycleAction != null) {
      return;
    }
    if (projectId == null) {
      _showPageMessage('当前项目不可用。');
      return;
    }

    final action = _myProjectLifecycleActionOption(kind);
    final confirmed = await _confirmDangerAction(
      title: action.confirmTitle,
      content: action.confirmMessage,
      confirmLabel: action.confirmLabel,
    );
    if (!mounted || confirmed != true) {
      return;
    }

    setState(() => _submittingLifecycleAction = kind);
    final result = switch (kind) {
      _MyProjectLifecycleActionKind.publish =>
        ExhibitionConsumerLayer.instance.publishProject(
          ProjectLifecycleActionCommand(projectId: projectId),
        ),
      _MyProjectLifecycleActionKind.withdraw =>
        ExhibitionConsumerLayer.instance.withdrawProject(projectId: projectId),
      _MyProjectLifecycleActionKind.archive =>
        ExhibitionConsumerLayer.instance.archiveProject(projectId: projectId),
      _MyProjectLifecycleActionKind.close =>
        ExhibitionConsumerLayer.instance.closeProject(projectId: projectId),
    };
    final actionResult = await result;
    if (!mounted) {
      return;
    }

    setState(() => _submittingLifecycleAction = null);
    if (!actionResult.isSuccess) {
      _showPageMessage(_userFacingActionFailureMessage(actionResult));
      return;
    }

    ExhibitionConsumerLayer.instance.invalidateMyProjectList();
    await _load(forceRefresh: true);
    if (!mounted) {
      return;
    }
    _showPageMessage(action.successMessage);
  }

  Future<void> _openProjectEdit(String projectId) async {
    final refreshed = await Navigator.of(
      context,
    ).pushNamed(ExhibitionRoutes.projectEditWithProjectId(projectId));
    if (refreshed == true && mounted) {
      await _load(forceRefresh: true);
    }
  }

  Future<void> _scrollToAttachments() async {
    final attachmentContext = _attachmentSectionKey.currentContext;
    if (attachmentContext == null) {
      _showPageMessage('当前还没有可补充的项目详情文书区。');
      return;
    }

    await Scrollable.ensureVisible(
      attachmentContext,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      alignment: 0.12,
    );
  }

  static String _areaOrUnavailable(num? value) {
    return value == null ? '当前项目暂未提供' : _myProjectAreaLabel(value);
  }

  Future<void> _deleteCurrentProject() async {
    if (_deletingProject) {
      return;
    }

    final projectId = _currentProjectId();
    if (projectId == null) {
      _showPageMessage('当前项目不可用。');
      return;
    }

    final state = _currentProjectState();
    if (!_myProjectCanDelete(state)) {
      _showPageMessage('只有草稿项目可以删除。');
      return;
    }

    final confirmed = await _confirmDangerAction(
      title: '删除此项目',
      content: '只有草稿项目可以删除。删除后不可恢复。',
      confirmLabel: '确认删除',
    );
    if (!mounted || confirmed != true) {
      return;
    }

    setState(() => _deletingProject = true);
    final result = await ExhibitionConsumerLayer.instance.deleteMyProject(
      projectId: projectId,
    );
    if (!mounted) {
      return;
    }

    setState(() => _deletingProject = false);
    if (!result.isSuccess) {
      _showPageMessage(_userFacingActionFailureMessage(result));
      return;
    }

    ExhibitionConsumerLayer.instance.invalidateMyProjectList();
    _showPageMessage('项目已删除。');
    await Navigator.of(
      context,
    ).pushReplacementNamed(ExhibitionRoutes.myProjectList);
  }

  String? _currentProjectId() {
    final payload = _payloadMap(_snapshot?.result.payload);
    final publicProject = payload?['publicProject'];
    if (publicProject is Map) {
      return _normalizeId('${publicProject['projectId'] ?? ''}') ??
          _normalizeId(widget.projectId);
    }
    return _normalizeId(widget.projectId);
  }

  String? _currentProjectState() {
    final payload = _payloadMap(_snapshot?.result.payload);
    final publicProject = payload?['publicProject'];
    if (publicProject is Map) {
      return _normalizeId('${publicProject['state'] ?? ''}');
    }
    return null;
  }

  Future<bool?> _confirmDangerAction({
    required String title,
    required String content,
    required String confirmLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
  }

  void _showPageMessage(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(SnackBar(content: Text(message)));
  }
}
