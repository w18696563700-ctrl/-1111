part of 'exhibition_workbench_view_model.dart';

ExhibitionWorkbenchSectionViewModel _projectChainSection(
  ExhibitionWorkbenchProjectChainData chain,
  AppPageState pageState,
) {
  if (_isWorkbenchControlledFailureState(pageState)) {
    return _controlledFailureSection(
      title: 'project_chain',
      pageState: pageState,
    );
  }

  final recentProjectId = _normalizedId(chain.recentProjectId);
  final hasCarrier = recentProjectId != null;
  final state = _resolveContainerState(
    pageState: pageState,
    hasCarrier: hasCarrier,
    hasAction: chain.canCreateProject,
  );

  final summary = switch (state) {
    ExhibitionWorkbenchContainerState.loading => 'project_chain 读取中。',
    ExhibitionWorkbenchContainerState.empty =>
      'project_chain 当前没有可继续实例，且发布入口暂未放开。',
    ExhibitionWorkbenchContainerState.content =>
      hasCarrier
          ? '当前已承接 recentProjectId=$recentProjectId，project_chain 可继续受控推进。'
          : 'project_chain 当前没有 recentProjectId，可从发布入口先进入最小建档。',
    ExhibitionWorkbenchContainerState.controlledFailure =>
      _containerFailureSummary(pageState),
  };

  return ExhibitionWorkbenchSectionViewModel(
    title: 'project_chain',
    state: state,
    stateLabel: _containerStateLabel(state),
    summary: summary,
    nodes: <ExhibitionWorkbenchNodeViewModel>[
      ExhibitionWorkbenchNodeViewModel(
        title: '近期项目承接',
        description: hasCarrier
            ? '当前 recentProjectId=$recentProjectId。工作台只把它作为续接载体，不把项目真相迁移到本地。'
            : '当前未承接 recentProjectId；没有实例时不会伪装成可继续项目详情。',
        statusLabel: hasCarrier ? '需实例承接' : '当前空态',
        tone: hasCarrier
            ? ExhibitionWorkbenchNodeTone.continuation
            : ExhibitionWorkbenchNodeTone.unavailable,
      ),
      ExhibitionWorkbenchNodeViewModel(
        title: '发布项目',
        description: '从私域工作台受控进入项目发布入口。',
        statusLabel: chain.canCreateProject ? '可继续' : '当前受控',
        tone: chain.canCreateProject
            ? ExhibitionWorkbenchNodeTone.primary
            : ExhibitionWorkbenchNodeTone.unavailable,
        actionLabel: chain.canCreateProject ? '创建项目' : null,
        routeName: chain.canCreateProject
            ? ExhibitionRoutes.projectCreate
            : null,
      ),
    ],
  );
}

ExhibitionWorkbenchSectionViewModel _orderChainSection(
  ExhibitionWorkbenchOrderChainData chain,
  String? activeOrderId,
  AppPageState pageState,
) {
  if (_isWorkbenchControlledFailureState(pageState)) {
    return _controlledFailureSection(
      title: 'order_chain',
      pageState: pageState,
    );
  }

  final orderId = _normalizedId(activeOrderId);
  final hasCarrier = orderId != null;
  final hasAction =
      orderId != null &&
      (chain.canOpenOrderDetail ||
          chain.canOpenContractDetail ||
          chain.canOpenDisputeOpen);
  final state = _resolveContainerState(
    pageState: pageState,
    hasCarrier: hasCarrier,
    hasAction: hasAction,
  );

  final summary = switch (state) {
    ExhibitionWorkbenchContainerState.loading => 'order_chain 读取中。',
    ExhibitionWorkbenchContainerState.empty => 'order_chain 当前没有可继续实例。',
    ExhibitionWorkbenchContainerState.content =>
      hasCarrier
          ? '当前已承接 activeOrderId=$orderId，可继续受控进入订单相关下游入口。'
          : 'order_chain 当前未承接 activeOrderId，相关入口保持受控。',
    ExhibitionWorkbenchContainerState.controlledFailure =>
      _containerFailureSummary(pageState),
  };

  return ExhibitionWorkbenchSectionViewModel(
    title: 'order_chain',
    state: state,
    stateLabel: _containerStateLabel(state),
    summary: summary,
    nodes: <ExhibitionWorkbenchNodeViewModel>[
      ExhibitionWorkbenchNodeViewModel(
        title: '当前订单承接',
        description: hasCarrier
            ? '当前 activeOrderId=$orderId。'
            : '当前未承接 activeOrderId。',
        statusLabel: hasCarrier ? '需实例承接' : '当前空态',
        tone: hasCarrier
            ? ExhibitionWorkbenchNodeTone.continuation
            : ExhibitionWorkbenchNodeTone.unavailable,
      ),
      ExhibitionWorkbenchNodeViewModel(
        title: '订单详情',
        description: '受控 handoff 到既有订单详情入口。',
        statusLabel: chain.canOpenOrderDetail && hasCarrier ? '可继续' : '当前受控',
        tone: chain.canOpenOrderDetail && hasCarrier
            ? ExhibitionWorkbenchNodeTone.continuation
            : ExhibitionWorkbenchNodeTone.unavailable,
        actionLabel: chain.canOpenOrderDetail && hasCarrier ? '订单详情' : null,
        routeName: chain.canOpenOrderDetail && hasCarrier
            ? ExhibitionRoutes.orderDetailWithOrderId(orderId!)
            : null,
      ),
      ExhibitionWorkbenchNodeViewModel(
        title: '合同详情',
        description: '受控 handoff 到既有合同详情入口。',
        statusLabel: chain.canOpenContractDetail && hasCarrier ? '可继续' : '当前受控',
        tone: chain.canOpenContractDetail && hasCarrier
            ? ExhibitionWorkbenchNodeTone.continuation
            : ExhibitionWorkbenchNodeTone.unavailable,
        actionLabel: chain.canOpenContractDetail && hasCarrier ? '合同详情' : null,
        routeName: chain.canOpenContractDetail && hasCarrier
            ? ExhibitionRoutes.contractDetailWithOrderId(orderId!)
            : null,
      ),
      ExhibitionWorkbenchNodeViewModel(
        title: '争议开启',
        description: '受控 handoff 到既有争议开启入口。',
        statusLabel: chain.canOpenDisputeOpen && hasCarrier ? '可继续' : '当前受控',
        tone: chain.canOpenDisputeOpen && hasCarrier
            ? ExhibitionWorkbenchNodeTone.continuation
            : ExhibitionWorkbenchNodeTone.unavailable,
        actionLabel: chain.canOpenDisputeOpen && hasCarrier ? '争议开启' : null,
        routeName: chain.canOpenDisputeOpen && hasCarrier
            ? ExhibitionRoutes.disputeOpenWithOrderId(orderId!)
            : null,
      ),
    ],
  );
}

ExhibitionWorkbenchSectionViewModel _fulfillmentChainSection(
  ExhibitionWorkbenchFulfillmentChainData chain,
  String? activeOrderId,
  String? activeMilestoneId,
  AppPageState pageState,
) {
  if (_isWorkbenchControlledFailureState(pageState)) {
    return _controlledFailureSection(
      title: 'fulfillment_chain',
      pageState: pageState,
    );
  }

  final orderId = _normalizedId(activeOrderId);
  final milestoneId = _normalizedId(activeMilestoneId);
  final hasCarrier = milestoneId != null;
  final hasAction =
      (orderId != null && chain.canOpenMilestoneList) ||
      (milestoneId != null &&
          (chain.canOpenMilestoneSubmit ||
              chain.canOpenInspectionDetail ||
              chain.canOpenInspectionSubmit));
  final state = _resolveContainerState(
    pageState: pageState,
    hasCarrier: hasCarrier,
    hasAction: hasAction,
  );

  final summary = switch (state) {
    ExhibitionWorkbenchContainerState.loading => 'fulfillment_chain 读取中。',
    ExhibitionWorkbenchContainerState.empty => 'fulfillment_chain 当前没有可继续实例。',
    ExhibitionWorkbenchContainerState.content =>
      hasCarrier
          ? '当前已承接 activeMilestoneId=$milestoneId，可继续受控进入履约下游入口。'
          : 'fulfillment_chain 当前未承接 activeMilestoneId，相关入口按受控态展示。',
    ExhibitionWorkbenchContainerState.controlledFailure =>
      _containerFailureSummary(pageState),
  };

  return ExhibitionWorkbenchSectionViewModel(
    title: 'fulfillment_chain',
    state: state,
    stateLabel: _containerStateLabel(state),
    summary: summary,
    nodes: <ExhibitionWorkbenchNodeViewModel>[
      ExhibitionWorkbenchNodeViewModel(
        title: '当前里程碑承接',
        description: hasCarrier
            ? '当前 activeMilestoneId=$milestoneId。'
            : '当前未承接 activeMilestoneId。',
        statusLabel: hasCarrier ? '需实例承接' : '当前空态',
        tone: hasCarrier
            ? ExhibitionWorkbenchNodeTone.continuation
            : ExhibitionWorkbenchNodeTone.unavailable,
      ),
      ExhibitionWorkbenchNodeViewModel(
        title: '里程碑列表',
        description: '受控 handoff 到既有里程碑列表入口。',
        statusLabel: orderId != null && chain.canOpenMilestoneList
            ? '可继续'
            : '当前受控',
        tone: orderId != null && chain.canOpenMilestoneList
            ? ExhibitionWorkbenchNodeTone.continuation
            : ExhibitionWorkbenchNodeTone.unavailable,
        actionLabel: orderId != null && chain.canOpenMilestoneList
            ? '里程碑列表'
            : null,
        routeName: orderId != null && chain.canOpenMilestoneList
            ? ExhibitionRoutes.milestoneListWithOrderId(orderId)
            : null,
      ),
      ExhibitionWorkbenchNodeViewModel(
        title: '里程碑提交',
        description: '受控 handoff 到既有里程碑提交入口。',
        statusLabel: milestoneId != null && chain.canOpenMilestoneSubmit
            ? '可继续'
            : '当前受控',
        tone: milestoneId != null && chain.canOpenMilestoneSubmit
            ? ExhibitionWorkbenchNodeTone.continuation
            : ExhibitionWorkbenchNodeTone.unavailable,
        actionLabel: milestoneId != null && chain.canOpenMilestoneSubmit
            ? '里程碑提交'
            : null,
        routeName: milestoneId != null && chain.canOpenMilestoneSubmit
            ? ExhibitionRoutes.milestoneSubmitWithMilestoneId(milestoneId)
            : null,
      ),
      ExhibitionWorkbenchNodeViewModel(
        title: '验收详情',
        description: '受控 handoff 到既有验收详情入口。',
        statusLabel: milestoneId != null && chain.canOpenInspectionDetail
            ? '可继续'
            : '当前受控',
        tone: milestoneId != null && chain.canOpenInspectionDetail
            ? ExhibitionWorkbenchNodeTone.continuation
            : ExhibitionWorkbenchNodeTone.unavailable,
        actionLabel: milestoneId != null && chain.canOpenInspectionDetail
            ? '验收详情'
            : null,
        routeName: milestoneId != null && chain.canOpenInspectionDetail
            ? ExhibitionRoutes.inspectionDetailWithMilestoneId(milestoneId)
            : null,
      ),
      ExhibitionWorkbenchNodeViewModel(
        title: '验收提交',
        description: '受控 handoff 到既有验收提交入口。',
        statusLabel: milestoneId != null && chain.canOpenInspectionSubmit
            ? '可继续'
            : '当前受控',
        tone: milestoneId != null && chain.canOpenInspectionSubmit
            ? ExhibitionWorkbenchNodeTone.continuation
            : ExhibitionWorkbenchNodeTone.unavailable,
        actionLabel: milestoneId != null && chain.canOpenInspectionSubmit
            ? '验收提交'
            : null,
        routeName: milestoneId != null && chain.canOpenInspectionSubmit
            ? ExhibitionRoutes.inspectionSubmitWithMilestoneId(milestoneId)
            : null,
      ),
    ],
  );
}

ExhibitionWorkbenchSectionViewModel _extensionBoundarySection(
  ExhibitionWorkbenchExtensionBoundaryData boundary,
  String? activeOrderId,
  AppPageState pageState,
) {
  if (_isWorkbenchControlledFailureState(pageState)) {
    return _controlledFailureSection(
      title: 'extension_boundary',
      pageState: pageState,
    );
  }

  final orderId = _normalizedId(activeOrderId);
  final hasAction =
      orderId != null &&
      (boundary.canOpenContractDetail || boundary.canOpenDisputeOpen);
  final state = _resolveContainerState(
    pageState: pageState,
    hasCarrier: true,
    hasAction: hasAction,
  );

  final summary = switch (state) {
    ExhibitionWorkbenchContainerState.loading => 'extension_boundary 读取中。',
    ExhibitionWorkbenchContainerState.empty =>
      'extension_boundary 当前没有可执行入口，仅保留边界状态。',
    ExhibitionWorkbenchContainerState.content =>
      'extension_boundary 只保留合同详情/争议开启的受控 handoff，rating/dispute withdraw 继续冻结。',
    ExhibitionWorkbenchContainerState.controlledFailure =>
      _containerFailureSummary(pageState),
  };

  return ExhibitionWorkbenchSectionViewModel(
    title: 'extension_boundary',
    state: state,
    stateLabel: _containerStateLabel(state),
    summary: summary,
    nodes: <ExhibitionWorkbenchNodeViewModel>[
      ExhibitionWorkbenchNodeViewModel(
        title: '合同详情',
        description: '受控 handoff 到既有合同详情入口。',
        statusLabel: orderId != null && boundary.canOpenContractDetail
            ? '可继续'
            : '当前受控',
        tone: orderId != null && boundary.canOpenContractDetail
            ? ExhibitionWorkbenchNodeTone.continuation
            : ExhibitionWorkbenchNodeTone.unavailable,
        actionLabel: orderId != null && boundary.canOpenContractDetail
            ? '合同详情'
            : null,
        routeName: orderId != null && boundary.canOpenContractDetail
            ? ExhibitionRoutes.contractDetailWithOrderId(orderId)
            : null,
      ),
      ExhibitionWorkbenchNodeViewModel(
        title: '争议开启',
        description: '受控 handoff 到既有争议开启入口。',
        statusLabel: orderId != null && boundary.canOpenDisputeOpen
            ? '可继续'
            : '当前受控',
        tone: orderId != null && boundary.canOpenDisputeOpen
            ? ExhibitionWorkbenchNodeTone.continuation
            : ExhibitionWorkbenchNodeTone.unavailable,
        actionLabel: orderId != null && boundary.canOpenDisputeOpen
            ? '争议开启'
            : null,
        routeName: orderId != null && boundary.canOpenDisputeOpen
            ? ExhibitionRoutes.disputeOpenWithOrderId(orderId)
            : null,
      ),
      ExhibitionWorkbenchNodeViewModel(
        title: '评价入口边界',
        description: _ratingBoundaryDescription(boundary.ratingEntryState),
        statusLabel: _ratingBoundaryLabel(boundary.ratingEntryState),
        tone: ExhibitionWorkbenchNodeTone.frozen,
      ),
      ExhibitionWorkbenchNodeViewModel(
        title: '争议撤回边界',
        description: _disputeWithdrawDescription(boundary.disputeWithdrawState),
        statusLabel: _disputeWithdrawLabel(boundary.disputeWithdrawState),
        tone: ExhibitionWorkbenchNodeTone.frozen,
      ),
    ],
  );
}

ExhibitionWorkbenchSectionViewModel _controlledFailureSection({
  required String title,
  required AppPageState pageState,
}) {
  return ExhibitionWorkbenchSectionViewModel(
    title: title,
    state: ExhibitionWorkbenchContainerState.controlledFailure,
    stateLabel: _containerStateLabel(
      ExhibitionWorkbenchContainerState.controlledFailure,
    ),
    summary: _containerFailureSummary(pageState),
    nodes: <ExhibitionWorkbenchNodeViewModel>[
      ExhibitionWorkbenchNodeViewModel(
        title: '当前受控',
        description: _containerFailureGuidance(pageState),
        statusLabel: '等待重试',
        tone: ExhibitionWorkbenchNodeTone.unavailable,
      ),
    ],
  );
}

ExhibitionWorkbenchContainerState _resolveContainerState({
  required AppPageState pageState,
  required bool hasCarrier,
  required bool hasAction,
}) {
  if (pageState == AppPageState.loading) {
    return ExhibitionWorkbenchContainerState.loading;
  }
  if (pageState == AppPageState.empty) {
    return ExhibitionWorkbenchContainerState.empty;
  }
  if (hasCarrier || hasAction) {
    return ExhibitionWorkbenchContainerState.content;
  }
  return ExhibitionWorkbenchContainerState.empty;
}

bool _isWorkbenchControlledFailureState(AppPageState state) {
  return state == AppPageState.unauthorized ||
      state == AppPageState.forbidden ||
      state == AppPageState.notFound ||
      state == AppPageState.errorRetryable ||
      state == AppPageState.errorNonRetryable;
}

String? _normalizedId(String? raw) {
  if (raw == null) {
    return null;
  }
  final trimmed = raw.trim();
  return trimmed.isEmpty ? null : trimmed;
}
