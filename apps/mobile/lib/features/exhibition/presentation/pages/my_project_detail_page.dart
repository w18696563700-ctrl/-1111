part of '../exhibition_trade_pages.dart';

class MyProjectDetailPage extends StatefulWidget {
  const MyProjectDetailPage({super.key, this.projectId, this.initialFocus});

  final String? projectId;
  final String? initialFocus;

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
  final GlobalKey _sinceritySectionKey = GlobalKey();
  ExhibitionStageLoadSnapshot? _snapshot;
  bool _loading = true;
  bool _deletingProject = false;
  bool _summaryExpanded = false;
  bool _pricingSummaryLoading = false;
  bool _continuingSincerityPayment = false;
  String? _submittingSincerityFeedbackChoice;
  _MyProjectLifecycleActionKind? _submittingLifecycleAction;
  ExhibitionLoadResult? _pricingSummaryResult;
  ExhibitionLoadResult? _quoteBasisAttachmentResult;
  bool _quoteBasisAttachmentsLoading = false;
  bool _initialFocusHandled = false;

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

    _publishProjectEditHeaderStatus(
      widget.projectId,
      _myProjectDetailHeaderState(snapshot.result.payload),
    );
    setState(() {
      _snapshot = snapshot;
      _loading = false;
    });
    final payload = _payloadMap(snapshot.result.payload);
    final publicProject = _payloadMap(payload?['publicProject']);
    final state = _normalizeId(publicProject?['state'] as String?);
    final projectId =
        _normalizeId(publicProject?['projectId'] as String?) ??
        _normalizeId(widget.projectId);
    final shouldReadPricing =
        _shouldReadProjectPricingSummary(state) && projectId != null;
    if (shouldReadPricing) {
      await _loadProjectPricingSummary(projectId, forceRefresh: forceRefresh);
    } else if (mounted) {
      setState(() {
        _pricingSummaryResult = null;
        _pricingSummaryLoading = false;
      });
    }
    if (!mounted) {
      return;
    }
    if (projectId != null && _myProjectCanOpenAttachmentStage(state)) {
      await _loadQuoteBasisAttachments(projectId, forceRefresh: forceRefresh);
      _scheduleInitialFocus();
    } else if (mounted) {
      setState(() {
        _quoteBasisAttachmentResult = null;
        _quoteBasisAttachmentsLoading = false;
      });
    }
  }

  void _scheduleInitialFocus() {
    if (_initialFocusHandled || widget.initialFocus != 'attachments') {
      return;
    }
    _initialFocusHandled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      unawaited(_scrollToAttachments());
    });
  }

  String? _myProjectDetailHeaderState(Object? payload) {
    final payloadMap = _payloadMap(payload);
    final publicProject = _payloadMap(payloadMap?['publicProject']);
    return _normalizeId(publicProject?['state'] as String?) ??
        _stateFromPayload(payload);
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    final result = snapshot?.result;

    return _LoadPageFrame(
      title: '预发布补资料并发布页',
      summary: '先补齐必传报价依据资料，再完成诚意金绿色通道表态并确认发布。',
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
      bottomPinnedBuilder: _buildBottomPublishCta,
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
        final sinceritySnapshot =
            _projectAuthenticitySinceritySnapshotFromPayload(
              _pricingSummaryResult?.payload,
            );
        final quoteBasisProgress = _quoteBasisProgress();
        final basePublishProgressStep = _projectPublishProgressStepForState(
          state: state,
          sincerity: sinceritySnapshot,
        );
        final showPrepublishTodo =
            isOwnerSurface &&
            projectId != null &&
            stage.value == _MyProjectStageBucket.submitted;
        final publishProgressStep = showPrepublishTodo
            ? !quoteBasisProgress.allRequiredKindsPresent
                  ? _ProjectPublishProgressStep.quoteBasis
                  : !_sincerityGreenChannelChoiceCompleted(sinceritySnapshot)
                  ? _ProjectPublishProgressStep.sincerity
                  : _ProjectPublishProgressStep.confirmation
            : basePublishProgressStep;
        final pendingSummary = _myProjectPrepublishPendingSummary(
          stage: stage,
          sincerity: sinceritySnapshot,
          pricingLoading: _pricingSummaryLoading,
          quoteBasis: quoteBasisProgress,
        );
        final bottomPlan = _myProjectBottomPublishCtaPlan(
          projectId: projectId,
          state: state,
          sincerity: sinceritySnapshot,
          pricingLoading: _pricingSummaryLoading,
          quoteBasis: quoteBasisProgress,
          canRunLifecycleActions: canRunLifecycleActions,
        );

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
            pendingSummary: pendingSummary,
            showContinueAttachmentAction: showContinueAttachmentAction,
            onContinueAttachmentAction: showContinueAttachmentAction
                ? _scrollToAttachments
                : null,
          ),
          const SizedBox(height: 16),
          _ProjectPublishProgressCard(
            currentStep: publishProgressStep,
            sincerity: showPrepublishTodo ? null : sinceritySnapshot,
            compact: showPrepublishTodo,
            showStepNotice: !showPrepublishTodo,
          ),
          if (canManageAttachments && projectId != null) ...<Widget>[
            const SizedBox(height: 16),
            KeyedSubtree(
              key: _attachmentSectionKey,
              child: _ProjectAttachmentSection(
                key: ValueKey<String>('my-project-attachment-$projectId'),
                projectId: projectId,
                title: '报价依据资料',
                summary: '必传：效果图、尺寸图 / 施工图、材质图 / 材料样板；设备物料清单、服务清单建议补充。',
                // Keep the detail surface compact: no duplicated technical
                // upload-chain explanation above the attachment controls.
                showIntroCopy: false,
                compactKindHints: true,
                showKindHint: false,
                showIdleUploadState: false,
                workbenchMode: true,
                autoUploadOnSelect: true,
                emptyMessage: '请至少补充一类资料，方便接单方准确报价。',
                onListResultChanged: _handleQuoteBasisAttachmentResult,
              ),
            ),
          ],
          if (showPrepublishTodo) ...<Widget>[
            const SizedBox(height: 16),
            KeyedSubtree(
              key: _sinceritySectionKey,
              child: _MyProjectPrepublishTodoCard(
                sincerity: sinceritySnapshot,
                pricingLoading: _pricingSummaryLoading,
                quoteBasis: quoteBasisProgress,
                bottomPlan: bottomPlan,
                continuingSincerity: _continuingSincerityPayment,
                onContinueSincerity: () =>
                    _continueSincerityFromTodo(projectId),
                onRefreshSincerity: () =>
                    _loadProjectPricingSummary(projectId, forceRefresh: true),
                onAddAttachments: _scrollToAttachments,
                onPublish:
                    bottomPlan.kind == _MyProjectBottomPublishCtaKind.publish
                    ? () => _runLifecycleAction(
                        _MyProjectLifecycleActionKind.publish,
                        projectId: projectId,
                      )
                    : null,
                onWithdraw: _myProjectCanWithdraw(state)
                    ? () => _runLifecycleAction(
                        _MyProjectLifecycleActionKind.withdraw,
                        projectId: projectId,
                      )
                    : null,
                onDiscard: _myProjectCanDiscardSubmitted(state)
                    ? () => _runLifecycleAction(
                        _MyProjectLifecycleActionKind.discardSubmitted,
                        projectId: projectId,
                      )
                    : null,
                submittingLifecycleAction: _submittingLifecycleAction,
                submittingFeedbackChoice: _submittingSincerityFeedbackChoice,
                onFeedbackChoice: (String choice) =>
                    _submitProjectAuthenticitySincerityFreezeFeedback(
                      projectId,
                      choice,
                    ),
              ),
            ),
          ] else ...<Widget>[
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
          if (canManageAttachments && projectId != null) ...<Widget>[
            const SizedBox(height: 16),
            _ProjectPublicResourceSection(
              key: ValueKey<String>('my-project-public-resource-$projectId'),
              title: '公共资源下载区',
              summary: '可下载平台共享模板与公共资料。',
              onMessage: _showPageMessage,
            ),
          ],
        ];
      },
    );
  }

  Widget? _buildBottomPublishCta(ExhibitionLoadResult _) {
    return null;
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
    required String pendingSummary,
    required bool showContinueAttachmentAction,
    required VoidCallback? onContinueAttachmentAction,
  }) {
    final children = <Widget>[
      _ProjectSummaryWorkbenchHeader(
        title: title ?? '未提供',
        projectNo: projectNo ?? '未提供',
        stageLabel: stage.label,
        pendingSummary: pendingSummary,
      ),
      if (_summaryExpanded) ...<Widget>[
        const SizedBox(height: 14),
        _DetailLine(label: '项目类型', value: _buildingTypeLabel(buildingType)),
        _DetailLine(
          label: '预算金额',
          value: _currencyText(budgetAmount),
          highlight: true,
        ),
        _DetailLine(label: '项目面积', value: _areaOrUnavailable(areaSqm)),
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
        if (showContinueAttachmentAction)
          const _DetailLine(
            label: '报价依据资料',
            value: '请补充五类报价依据资料，接单方会在竞标提交第二步查看。',
            highlight: true,
          ),
      ],
      const SizedBox(height: 14),
      Align(
        alignment: Alignment.centerRight,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.end,
          children: <Widget>[
            OutlinedButton.icon(
              onPressed: () {
                setState(() => _summaryExpanded = !_summaryExpanded);
              },
              icon: Icon(
                _summaryExpanded
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
              ),
              label: Text(_summaryExpanded ? '收起全部信息' : '展开全部信息'),
            ),
            if (showContinueAttachmentAction)
              FilledButton(
                onPressed: onContinueAttachmentAction,
                child: const Text('补充报价依据资料'),
              ),
          ],
        ),
      ),
    ];

    return _ActionCard(
      title: '项目基础信息',
      tone: _ActionCardTone.emphasis,
      children: children,
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
          body:
              '预发布阶段已开放报价依据资料，请先补充效果图、尺寸图 / 施工图、材质图 / 材料样板；设备物料清单和服务清单建议继续补齐。确认无误后再发布。',
        ),
      ],
      const SizedBox(height: 12),
    ];

    switch (stage.value) {
      case _MyProjectStageBucket.all:
        children.add(
          const OutlinedButton(onPressed: null, child: Text('按项目当前阶段查看')),
        );
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
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              FilledButton(
                onPressed:
                    !canRunLifecycleActions || !_myProjectCanPublish(state)
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
              OutlinedButton(
                onPressed:
                    !canRunLifecycleActions || !_myProjectCanWithdraw(state)
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
              OutlinedButton(
                style: _dangerOutlinedButtonStyle(context),
                onPressed:
                    !canRunLifecycleActions ||
                        !_myProjectCanDiscardSubmitted(state)
                    ? null
                    : () => _runLifecycleAction(
                        _MyProjectLifecycleActionKind.discardSubmitted,
                        projectId: projectId,
                      ),
                child: Text(
                  _buttonLabelForLifecycleAction(
                    _MyProjectLifecycleActionKind.discardSubmitted,
                  ),
                ),
              ),
            ],
          ),
        );
      case _MyProjectStageBucket.published:
        children.add(
          FilledButton(
            onPressed: canManageAttachments ? _scrollToAttachments : null,
            child: Text(canManageAttachments ? '补充报价依据资料' : '补充资料（当前待开放）'),
          ),
        );
        children.add(const SizedBox(height: 12));
        children.add(
          OutlinedButton(
            onPressed:
                !canRunLifecycleActions ||
                    !_myProjectCanWithdrawPublished(state)
                ? null
                : () => _runLifecycleAction(
                    _MyProjectLifecycleActionKind.withdrawPublished,
                    projectId: projectId,
                  ),
            child: Text(
              _buttonLabelForLifecycleAction(
                _MyProjectLifecycleActionKind.withdrawPublished,
              ),
            ),
          ),
        );
      case _MyProjectStageBucket.active:
        children.add(
          FilledButton(
            onPressed:
                !canRunLifecycleActions ||
                    !_myProjectCanUseActiveExitGovernance(state)
                ? null
                : () => _runLifecycleAction(
                    _MyProjectLifecycleActionKind.requestCancellation,
                    projectId: projectId,
                  ),
            child: Text(
              _buttonLabelForLifecycleAction(
                _MyProjectLifecycleActionKind.requestCancellation,
              ),
            ),
          ),
        );
        children.add(const SizedBox(height: 12));
        children.add(
          OutlinedButton(
            onPressed:
                !canRunLifecycleActions ||
                    !_myProjectCanUseActiveExitGovernance(state)
                ? null
                : () => _runLifecycleAction(
                    _MyProjectLifecycleActionKind.recordPublisherBreach,
                    projectId: projectId,
                  ),
            child: Text(
              _buttonLabelForLifecycleAction(
                _MyProjectLifecycleActionKind.recordPublisherBreach,
              ),
            ),
          ),
        );
        children.add(const SizedBox(height: 12));
        children.add(
          OutlinedButton(
            onPressed:
                !canRunLifecycleActions ||
                    !_myProjectCanUseActiveExitGovernance(state)
                ? null
                : () => _runLifecycleAction(
                    _MyProjectLifecycleActionKind.recordFactoryBreach,
                    projectId: projectId,
                  ),
            child: Text(
              _buttonLabelForLifecycleAction(
                _MyProjectLifecycleActionKind.recordFactoryBreach,
              ),
            ),
          ),
        );
      case _MyProjectStageBucket.archived:
        children.add(
          const OutlinedButton(onPressed: null, child: Text('当前已归档，仅支持查看')),
        );
    }

    return _ActionCard(
      title: '当前阶段动作',
      summary: stage.value == _MyProjectStageBucket.submitted
          ? '先补资料后确认发布；返回草稿和作废并归档继续使用受控动作。'
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

  ButtonStyle _dangerOutlinedButtonStyle(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return OutlinedButton.styleFrom(
      foregroundColor: colorScheme.error,
      side: BorderSide(color: colorScheme.error.withValues(alpha: 0.55)),
    );
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
    if (kind == _MyProjectLifecycleActionKind.publish &&
        !await _ensureRequiredQuoteBasisBeforePublish(projectId)) {
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
    if (kind == _MyProjectLifecycleActionKind.publish) {
      final greenChannelChoiceReady =
          await _ensureSincerityGreenChannelChoiceBeforePublish(projectId);
      if (!mounted) {
        return;
      }
      if (!greenChannelChoiceReady) {
        setState(() => _submittingLifecycleAction = null);
        return;
      }
    }

    final result = switch (kind) {
      _MyProjectLifecycleActionKind.publish =>
        ExhibitionConsumerLayer.instance.publishProject(
          ProjectLifecycleActionCommand(projectId: projectId),
        ),
      _MyProjectLifecycleActionKind.withdraw =>
        ExhibitionConsumerLayer.instance.withdrawProject(projectId: projectId),
      _MyProjectLifecycleActionKind.discardSubmitted =>
        ExhibitionConsumerLayer.instance.discardSubmittedProject(
          projectId: projectId,
        ),
      _MyProjectLifecycleActionKind.withdrawPublished =>
        ExhibitionConsumerLayer.instance.withdrawPublishedProject(
          projectId: projectId,
        ),
      _MyProjectLifecycleActionKind.requestCancellation =>
        ExhibitionConsumerLayer.instance.requestProjectCancellation(
          projectId: projectId,
        ),
      _MyProjectLifecycleActionKind.recordPublisherBreach =>
        ExhibitionConsumerLayer.instance.recordPublisherBreach(
          projectId: projectId,
        ),
      _MyProjectLifecycleActionKind.recordFactoryBreach =>
        ExhibitionConsumerLayer.instance.recordFactoryBreach(
          projectId: projectId,
        ),
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
    if (kind == _MyProjectLifecycleActionKind.withdraw) {
      final editResult = await ExhibitionConsumerLayer.instance
          .loadProjectEditDetail(projectId: projectId, forceRefresh: true);
      if (!mounted) {
        return;
      }
      if (editResult.state != AppPageState.content ||
          _stateFromPayload(editResult.payload) != 'draft') {
        await _load(forceRefresh: true);
        if (!mounted) {
          return;
        }
        _showPageMessage('项目已提交撤回请求；草稿编辑页尚未回读到草稿状态，请稍后刷新。');
        return;
      }
      _showPageMessage(action.successMessage);
      Navigator.of(context).pushReplacementNamed(
        ExhibitionRoutes.projectEditWithProjectId(projectId),
      );
      return;
    }

    await _load(forceRefresh: true);
    if (!mounted) {
      return;
    }
    _showPageMessage(action.successMessage);
  }

  Future<bool> _ensureProjectAuthenticitySincerityBeforePublish(
    String projectId,
  ) async {
    final summary = await ExhibitionConsumerLayer.instance
        .loadProjectPricingSummary(projectId: projectId, forceRefresh: true);
    if (!mounted) {
      return false;
    }
    if (summary.state == AppPageState.content &&
        _projectAuthenticitySinceritySatisfied(summary.payload)) {
      return true;
    }
    if (summary.state != AppPageState.content) {
      _showPageMessage(_userFacingLoadFailureMessage(summary));
      return false;
    }
    final existingOrderId = _projectAuthenticitySincerityOrderId(
      summary.payload,
    );
    if (existingOrderId != null) {
      return _continueProjectAuthenticitySincerityPayment(
        projectId,
        summary.payload,
      );
    }

    final orderResult = await ExhibitionConsumerLayer.instance
        .createProjectAuthenticitySincerityOrder(
          projectId: projectId,
          command: ProjectAuthenticitySincerityOrderCommand(
            ruleVersion: 'platform_pricing_rules_master_v1',
            ruleSnapshotHash: 'platform_pricing_rules_master_v1',
          ),
        );
    if (!mounted) {
      return false;
    }
    if (!orderResult.isSuccess) {
      _showPageMessage(_userFacingActionFailureMessage(orderResult));
      return false;
    }
    if (_projectAuthenticitySinceritySatisfied(orderResult.payload)) {
      return true;
    }

    final orderId = _projectAuthenticitySincerityOrderId(orderResult.payload);
    if (orderId == null) {
      _showPageMessage('项目真实性诚意金订单缺少订单编号，请刷新后重试。');
      return false;
    }

    return _continueProjectAuthenticitySincerityPayment(
      projectId,
      orderResult.payload,
    );
  }

  Future<bool> _continueProjectAuthenticitySincerityPayment(
    String projectId,
    Object? sourcePayload,
  ) async {
    if (_continuingSincerityPayment) {
      return false;
    }
    final orderId = _projectAuthenticitySincerityOrderId(sourcePayload);
    if (orderId == null) {
      _showPageMessage('暂未取得当前项目的诚意金订单编号，请先刷新状态，不要重复创建。');
      return false;
    }

    setState(() => _continuingSincerityPayment = true);
    final initResult = await ExhibitionConsumerLayer.instance
        .initProjectAuthenticitySincerityPayment(
          projectId: projectId,
          orderId: orderId,
          command: ProjectPricingPayInitCommand(
            payChannel:
                _firstProjectPricingChannelCandidate(sourcePayload) ??
                'alipay_candidate',
          ),
        );
    if (!mounted) {
      return false;
    }
    if (!initResult.isSuccess) {
      setState(() => _continuingSincerityPayment = false);
      _showPageMessage(_userFacingActionFailureMessage(initResult));
      return false;
    }

    final opened = await _openProjectPricingChannelPayload(initResult.payload);
    if (!mounted) {
      return false;
    }
    if (!opened) {
      final hasAlipaySdkPayload =
          _channelPayloadAlipayOrderString(initResult.payload) != null;
      _showPageMessage(
        hasAlipaySdkPayload
            ? '支付参数已返回；当前设备暂不能直接打开支付宝，请换用已支持环境或稍后重试。'
            : '支付通道已创建，但暂未取得可打开的支付链接。正在刷新当前订单状态。',
      );
    }

    final pollResult = await ExhibitionConsumerLayer.instance
        .pollProjectAuthenticitySincerityOrderStatus(
          projectId: projectId,
          orderId: orderId,
          maxAttempts: 1,
          interval: Duration.zero,
        );
    if (!mounted) {
      return false;
    }
    setState(() => _continuingSincerityPayment = false);
    await _loadProjectPricingSummary(projectId, forceRefresh: true);
    if (!mounted) {
      return false;
    }
    final pollSatisfied =
        pollResult.isSuccess ||
        _projectAuthenticitySinceritySatisfied(pollResult.result.payload);
    if (pollSatisfied) {
      setState(() => _pricingSummaryResult = pollResult.result);
      return true;
    }

    _showPageMessage(
      opened
          ? _projectAuthenticitySincerityPendingMessage(pollResult)
          : _channelPayloadAlipayOrderString(initResult.payload) != null
          ? '当前设备暂不能直接打开支付宝；诚意金仍未完成，请换用已支持环境或稍后重试。'
          : '暂未取得可打开的支付链接；当前诚意金仍未完成，请刷新状态或稍后再试。',
    );
    return false;
  }

  Future<void> _continueSincerityFromTodo(String projectId) async {
    final satisfied = await _ensureProjectAuthenticitySincerityBeforePublish(
      projectId,
    );
    if (!mounted) {
      return;
    }
    if (satisfied) {
      _showPageMessage('项目真实性诚意金已满足，可以继续发布确认。');
      return;
    }
    await _loadProjectPricingSummary(projectId, forceRefresh: true);
    if (!mounted) {
      return;
    }
  }

  Future<void> _submitProjectAuthenticitySincerityFreezeFeedback(
    String projectId,
    String choice,
  ) async {
    if (_submittingSincerityFeedbackChoice != null) {
      return;
    }
    setState(() => _submittingSincerityFeedbackChoice = choice);
    final result = await ExhibitionConsumerLayer.instance
        .submitProjectAuthenticitySincerityFreezeFeedback(
          projectId: projectId,
          command: ProjectAuthenticitySincerityFreezeFeedbackCommand(
            choice: choice,
          ),
        );
    if (!mounted) {
      return;
    }
    setState(() => _submittingSincerityFeedbackChoice = null);
    if (!result.isSuccess) {
      _showPageMessage(_userFacingActionFailureMessage(result));
      return;
    }
    await _loadProjectPricingSummary(projectId, forceRefresh: true);
    if (!mounted) {
      return;
    }
    _showPageMessage('反馈已记录，仅用于内测统计。');
  }

  Future<bool> _openProjectPricingChannelPayload(Object? payload) async {
    return _openPaymentChannelPayload(payload);
  }

  Future<bool> _ensureRequiredQuoteBasisBeforePublish(String projectId) async {
    final result = await ExhibitionConsumerLayer.instance
        .loadProjectAttachments(projectId: projectId, forceRefresh: true);
    if (!mounted) {
      return false;
    }
    if (result.state != AppPageState.content &&
        result.state != AppPageState.empty) {
      _showPageMessage('当前附件列表暂不可用，请刷新后再试。');
      return false;
    }
    final attachments =
        _projectAttachmentListFromPayload(result.payload)?.attachments ??
        const <ProjectAttachmentReadModel>[];
    final counts = <String, int>{
      for (final String kind in _projectRequiredQuoteBasisAttachmentKinds)
        kind: 0,
    };
    for (final attachment in attachments) {
      final current = counts[attachment.attachmentKind];
      if (current != null) {
        counts[attachment.attachmentKind] = current + 1;
      }
    }
    final missingLabels = _projectRequiredQuoteBasisAttachmentKinds
        .where((String kind) => (counts[kind] ?? 0) <= 0)
        .map(_projectAttachmentKindLabel)
        .toList(growable: false);
    if (missingLabels.isNotEmpty) {
      _showPageMessage('请先补齐必传资料：${missingLabels.join('、')}。');
      await _scrollToAttachments();
      return false;
    }
    return true;
  }

  Future<bool> _ensureSincerityGreenChannelChoiceBeforePublish(
    String projectId,
  ) async {
    final summary = await ExhibitionConsumerLayer.instance
        .loadProjectPricingSummary(projectId: projectId, forceRefresh: true);
    if (!mounted) {
      return false;
    }
    if (summary.state != AppPageState.content) {
      _showPageMessage(_userFacingLoadFailureMessage(summary));
      return false;
    }
    final snapshot = _projectAuthenticitySinceritySnapshotFromPayload(
      summary.payload,
    );
    setState(() => _pricingSummaryResult = summary);
    if (_sincerityGreenChannelChoiceCompleted(snapshot)) {
      return true;
    }
    _showPageMessage('请先选择是否支持项目真实性诚意金机制；选择暂不支持也可继续发布。');
    await _scrollToSincerity();
    return false;
  }

  bool _projectAuthenticitySinceritySatisfied(Object? payload) {
    final status = _projectAuthenticitySincerityStatus(payload);
    return switch (status) {
      'paid' ||
      'frozen' ||
      'succeeded' ||
      'satisfied' ||
      'internal_test_no_freeze_required' ||
      'internal_test_no_freeze_allowed' ||
      'not_required' => true,
      _ => false,
    };
  }

  String? _projectAuthenticitySincerityStatus(Object? payload) {
    final payloadMap = _payloadMap(payload);
    if (payloadMap == null) {
      return null;
    }
    final publisherPricing = _payloadMap(payloadMap['publisherPricing']);
    final sincerity =
        _payloadMap(payloadMap['projectAuthenticitySincerity']) ??
        _payloadMap(payloadMap['inquiryDeposit']);
    return _normalizeDynamicText(
      publisherPricing?['authenticitySincerityStatus'] ??
          publisherPricing?['publishGateStatus'] ??
          sincerity?['orderStatus'] ??
          sincerity?['depositStatus'] ??
          sincerity?['status'] ??
          payloadMap['orderStatus'] ??
          payloadMap['depositStatus'] ??
          payloadMap['status'],
    );
  }

  String? _projectAuthenticitySincerityOrderId(Object? payload) {
    final payloadMap = _payloadMap(payload);
    final publisherPricing = _payloadMap(payloadMap?['publisherPricing']);
    final sincerity =
        _payloadMap(payloadMap?['projectAuthenticitySincerity']) ??
        _payloadMap(payloadMap?['inquiryDeposit']);
    return _normalizeDynamicText(
          publisherPricing?['authenticitySincerityOrderId'],
        ) ??
        _normalizeDynamicText(sincerity?['orderId']) ??
        _normalizeDynamicText(sincerity?['depositOrderId']) ??
        _orderIdFromPayload(payload) ??
        _depositOrderIdFromPayload(payload);
  }

  String? _firstProjectPricingChannelCandidate(Object? payload) {
    final payloadMap = _payloadMap(payload);
    final publisherPricing = _payloadMap(payloadMap?['publisherPricing']);
    final sincerity =
        _payloadMap(payloadMap?['projectAuthenticitySincerity']) ??
        _payloadMap(payloadMap?['inquiryDeposit']);
    final candidates =
        publisherPricing?['authenticitySincerityChannelCandidates'] ??
        sincerity?['channelCandidates'] ??
        payloadMap?['channelCandidates'];
    if (candidates is! Iterable) {
      return null;
    }
    for (final candidate in candidates) {
      final normalized = _normalizeDynamicText(candidate);
      if (normalized != null) {
        return normalized;
      }
    }
    return null;
  }

  bool _shouldReadProjectPricingSummary(String? state) {
    return switch (_normalizeDynamicText(state)) {
      'submitted' || 'published' || 'awarded' || 'converted_to_order' => true,
      _ => false,
    };
  }

  Future<void> _loadProjectPricingSummary(
    String projectId, {
    bool forceRefresh = false,
  }) async {
    setState(() => _pricingSummaryLoading = true);
    final result = await ExhibitionConsumerLayer.instance
        .loadProjectPricingSummary(
          projectId: projectId,
          forceRefresh: forceRefresh,
        );
    if (!mounted) {
      return;
    }
    setState(() {
      _pricingSummaryResult = result;
      _pricingSummaryLoading = false;
    });
  }

  Future<void> _loadQuoteBasisAttachments(
    String projectId, {
    bool forceRefresh = false,
  }) async {
    setState(() => _quoteBasisAttachmentsLoading = true);
    final result = await ExhibitionConsumerLayer.instance
        .loadProjectAttachments(
          projectId: projectId,
          forceRefresh: forceRefresh,
        );
    if (!mounted) {
      return;
    }
    setState(() {
      _quoteBasisAttachmentResult = result;
      _quoteBasisAttachmentsLoading = false;
    });
  }

  void _handleQuoteBasisAttachmentResult(ExhibitionLoadResult? result) {
    if (!mounted) {
      return;
    }
    setState(() {
      _quoteBasisAttachmentResult = result;
      _quoteBasisAttachmentsLoading = false;
    });
  }

  _QuoteBasisChecklistProgress _quoteBasisProgress() {
    final result = _quoteBasisAttachmentResult;
    final attachments = _projectAttachmentListFromPayload(
      result?.payload,
    )?.attachments;
    final unavailable =
        result != null &&
        result.state != AppPageState.content &&
        result.state != AppPageState.empty;
    return _quoteBasisChecklistProgressFromAttachments(
      attachments: attachments,
      loading: _quoteBasisAttachmentsLoading,
      unavailable: unavailable,
    );
  }

  String _projectAuthenticitySincerityPendingMessage(
    P0PayPaymentPollResult result,
  ) {
    if (result.result.state != AppPageState.content) {
      return _userFacingLoadFailureMessage(result.result);
    }
    final status = _projectAuthenticitySincerityStatus(result.result.payload);
    if (status == null) {
      return '项目真实性诚意金状态暂不可用，请稍后刷新后再发布。';
    }
    return '项目真实性诚意金尚未完成支付，当前状态：$status。完成后再点击发布。';
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
      _showPageMessage('当前还没有可补充的报价依据资料。');
      return;
    }

    await Scrollable.ensureVisible(
      attachmentContext,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      alignment: 0.12,
    );
  }

  Future<void> _scrollToSincerity() async {
    final sincerityContext = _sinceritySectionKey.currentContext;
    if (sincerityContext == null) {
      _showPageMessage('当前还没有可处理的诚意金绿色通道。');
      return;
    }

    await Scrollable.ensureVisible(
      sincerityContext,
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

class _ProjectSummaryWorkbenchHeader extends StatelessWidget {
  const _ProjectSummaryWorkbenchHeader({
    required this.title,
    required this.projectNo,
    required this.stageLabel,
    required this.pendingSummary,
  });

  final String title;
  final String projectNo;
  final String stageLabel;
  final String pendingSummary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final showIllustration = constraints.maxWidth >= 310;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _ProjectSummaryLine(label: '项目名称', value: title),
                      const SizedBox(height: 8),
                      _ProjectSummaryLine(label: '项目编号', value: projectNo),
                      const SizedBox(height: 8),
                      _ProjectSummaryLine(
                        label: '当前阶段',
                        value: stageLabel,
                        highlighted: true,
                      ),
                      const SizedBox(height: 8),
                      _ProjectSummaryLine(
                        label: '待处理事项',
                        value: pendingSummary,
                        highlighted: true,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
                if (showIllustration) ...<Widget>[
                  const SizedBox(width: 14),
                  const _ProjectSummaryIllustration(),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProjectSummaryLine extends StatelessWidget {
  const _ProjectSummaryLine({
    required this.label,
    required this.value,
    this.highlighted = false,
    this.maxLines = 2,
  });

  final String label;
  final String value;
  final bool highlighted;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: highlighted ? colorScheme.onSurface : null,
              fontWeight: highlighted ? FontWeight.w900 : FontWeight.w700,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProjectSummaryIllustration extends StatelessWidget {
  const _ProjectSummaryIllustration();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(18),
      ),
      child: SizedBox(
        width: 72,
        height: 72,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              right: 12,
              top: 12,
              child: Icon(
                Icons.description_outlined,
                size: 36,
                color: colorScheme.primary.withValues(alpha: 0.55),
              ),
            ),
            Positioned(
              left: 14,
              bottom: 15,
              child: Icon(
                Icons.fact_check_outlined,
                size: 30,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
