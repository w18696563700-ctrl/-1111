part of '../exhibition_trade_pages.dart';

enum _MyProjectWorkspaceBucket { published, bids }

enum _MyProjectStageBucket {
  all,
  draft,
  submitted,
  published,
  active,
  archived,
}

enum _MyProjectLifecycleActionKind {
  publish,
  withdraw,
  discardSubmitted,
  withdrawPublished,
  requestCancellation,
  recordPublisherBreach,
  recordFactoryBreach,
  close,
}

final class _MyProjectWorkspaceOption {
  const _MyProjectWorkspaceOption({
    required this.value,
    required this.label,
    required this.description,
  });

  final _MyProjectWorkspaceBucket value;
  final String label;
  final String description;
}

final class _MyProjectStageOption {
  const _MyProjectStageOption({
    required this.value,
    required this.label,
    required this.description,
    required this.cardNextStep,
    required this.detailNextStep,
    required this.emptyTitle,
    required this.emptyMessage,
  });

  final _MyProjectStageBucket value;
  final String label;
  final String description;
  final String cardNextStep;
  final String detailNextStep;
  final String emptyTitle;
  final String emptyMessage;
}

final class _MyProjectLifecycleActionOption {
  const _MyProjectLifecycleActionOption({
    required this.kind,
    required this.buttonLabel,
    required this.confirmTitle,
    required this.confirmMessage,
    required this.confirmLabel,
    required this.successMessage,
    required this.loadingLabel,
  });

  final _MyProjectLifecycleActionKind kind;
  final String buttonLabel;
  final String confirmTitle;
  final String confirmMessage;
  final String confirmLabel;
  final String successMessage;
  final String loadingLabel;
}

const List<_MyProjectWorkspaceOption> _myProjectWorkspaceOptions =
    <_MyProjectWorkspaceOption>[
      _MyProjectWorkspaceOption(
        value: _MyProjectWorkspaceBucket.published,
        label: '我的发布',
        description: '这里承接当前账号或组织作为发布方创建、预发布、发布和履约中的项目。',
      ),
      _MyProjectWorkspaceOption(
        value: _MyProjectWorkspaceBucket.bids,
        label: '我的竞标',
        description: '这里用于承接当前账号或组织作为供应商参与过的竞标，避免和我的发布混在一起。',
      ),
    ];

_MyProjectWorkspaceOption _myProjectWorkspaceOption(
  _MyProjectWorkspaceBucket bucket,
) {
  return _myProjectWorkspaceOptions.firstWhere(
    (_MyProjectWorkspaceOption item) => item.value == bucket,
  );
}

const List<_MyProjectStageOption> _myProjectPrimaryStageOptions =
    <_MyProjectStageOption>[
      _MyProjectStageOption(
        value: _MyProjectStageBucket.all,
        label: '全部',
        description: '展示当前已读取的全部我的发布项目。',
        cardNextStep: '按项目当前阶段处理',
        detailNextStep: '按项目当前阶段处理。',
        emptyTitle: '当前没有项目',
        emptyMessage: '当前还没有可展示的我的发布项目。',
      ),
      _MyProjectStageOption(
        value: _MyProjectStageBucket.draft,
        label: '草稿',
        description: '还在整理项目信息，当前可以继续编辑或直接删除。',
        cardNextStep: '继续编辑 / 删除此项目',
        detailNextStep: '先继续编辑并确认信息；如不再需要，当前可以直接删除。',
        emptyTitle: '当前没有草稿项目',
        emptyMessage: '还没有处于草稿阶段的项目。',
      ),
      _MyProjectStageOption(
        value: _MyProjectStageBucket.submitted,
        label: '预发布列表',
        description: '项目已经进入发布前核对阶段，当前应先补充报价依据资料，再检查无误并正式发布。',
        cardNextStep: '补资料后确认发布 / 返回草稿继续编辑 / 作废并归档',
        detailNextStep: '当前应先补充报价依据资料，再检查无误并正式发布。',
        emptyTitle: '当前没有预发布项目',
        emptyMessage: '还没有进入预发布列表的项目。',
      ),
      _MyProjectStageOption(
        value: _MyProjectStageBucket.published,
        label: '竞标中',
        description: '项目已经进入公域竞标阶段，当前可以补充资料，必要时撤回到预发布并下架公域展示。',
        cardNextStep: '查看详情 / 补充资料 / 撤回到预发布',
        detailNextStep: '优先补充资料；如发现内容需要调整，可以撤回到预发布列表并下架公域展示。',
        emptyTitle: '当前没有竞标中项目',
        emptyMessage: '还没有处于竞标中阶段的项目。',
      ),
      _MyProjectStageOption(
        value: _MyProjectStageBucket.active,
        label: '进行中',
        description: '项目已经进入授标、订单、合同或履约承接，当前以业务继续处理为主。',
        cardNextStep: '查看详情 / 发起取消 / 记录违约',
        detailNextStep: '当前项目已经进入业务继续链；如需退出，应先发起双方取消，单方问题只做违约留痕。',
        emptyTitle: '当前没有进行中项目',
        emptyMessage: '还没有处于进行中阶段的项目。',
      ),
    ];

const _MyProjectStageOption _myProjectArchivedStageOption =
    _MyProjectStageOption(
      value: _MyProjectStageBucket.archived,
      label: '已归档',
      description: '项目已经退出当前活跃流转，这里只保留查看入口。',
      cardNextStep: '查看详情 / 当前只读',
      detailNextStep: '当前项目已归档，只支持查看，不再继续编辑、删除或下架关闭。',
      emptyTitle: '当前没有已归档项目',
      emptyMessage: '当前还没有已归档项目。',
    );

const _MyProjectLifecycleActionOption _publishLifecycleAction =
    _MyProjectLifecycleActionOption(
      kind: _MyProjectLifecycleActionKind.publish,
      buttonLabel: '确认并发布',
      confirmTitle: '确认发布项目',
      confirmMessage:
          '确认后，项目将从预发布列表进入公域项目详情，工厂可以查看公开信息并参与竞标。发布后不能直接删除；如需退出公域，后续请走下架关闭。',
      confirmLabel: '确认发布',
      successMessage: '已正式发布',
      loadingLabel: '发布中...',
    );

const _MyProjectLifecycleActionOption _withdrawLifecycleAction =
    _MyProjectLifecycleActionOption(
      kind: _MyProjectLifecycleActionKind.withdraw,
      buttonLabel: '返回草稿继续编辑',
      confirmTitle: '返回草稿继续编辑',
      confirmMessage:
          '撤回后，项目会回到草稿，暂不进入公域展示。附件可见性和后续处理继续按现有项目状态规则与后端返回展示，前端不得伪造草稿态正式附件走廊。',
      confirmLabel: '确认撤回',
      successMessage: '已撤回到草稿',
      loadingLabel: '撤回中...',
    );

const _MyProjectLifecycleActionOption _discardSubmittedLifecycleAction =
    _MyProjectLifecycleActionOption(
      kind: _MyProjectLifecycleActionKind.discardSubmitted,
      buttonLabel: '作废并归档',
      confirmTitle: '作废并归档预发布项目',
      confirmMessage: '预发布项目不会被硬删除，确认后会作废归档并退出当前活跃流转；历史记录和附件审计仍由后端保留。',
      confirmLabel: '确认作废并归档',
      successMessage: '已作废并归档',
      loadingLabel: '作废中...',
    );

const _MyProjectLifecycleActionOption
_withdrawPublishedLifecycleAction = _MyProjectLifecycleActionOption(
  kind: _MyProjectLifecycleActionKind.withdrawPublished,
  buttonLabel: '撤回到预发布',
  confirmTitle: '撤回到预发布',
  confirmMessage:
      '确认后，项目会下架公域展示并回到预发布列表；已产生的竞标记录保留为历史。该动作可能影响竞标方判断，后续按平台信用规则可能产生信用分扣减；本轮仅提示风险，不在前端伪造扣分。',
  confirmLabel: '确认撤回',
  successMessage: '已撤回到预发布',
  loadingLabel: '撤回中...',
);

const _MyProjectLifecycleActionOption _requestCancellationLifecycleAction =
    _MyProjectLifecycleActionOption(
      kind: _MyProjectLifecycleActionKind.requestCancellation,
      buttonLabel: '发起取消申请',
      confirmTitle: '发起取消申请',
      confirmMessage: '进行中项目不能单方直接撤回。确认后只发起双方取消申请，不删除订单、合同或支付记录，也不会自动扣钱。',
      confirmLabel: '确认发起',
      successMessage: '已发起取消申请',
      loadingLabel: '提交中...',
    );

const _MyProjectLifecycleActionOption _recordPublisherBreachLifecycleAction =
    _MyProjectLifecycleActionOption(
      kind: _MyProjectLifecycleActionKind.recordPublisherBreach,
      buttonLabel: '记录发布方违约',
      confirmTitle: '记录发布方违约',
      confirmMessage: '本期只记录违约留痕和信用候选，不自动扣钱、不删除订单合同。',
      confirmLabel: '确认记录',
      successMessage: '已记录发布方违约',
      loadingLabel: '记录中...',
    );

const _MyProjectLifecycleActionOption _recordFactoryBreachLifecycleAction =
    _MyProjectLifecycleActionOption(
      kind: _MyProjectLifecycleActionKind.recordFactoryBreach,
      buttonLabel: '记录工厂违约',
      confirmTitle: '记录工厂违约',
      confirmMessage: '本期只记录违约留痕和信用候选，不自动扣钱、不删除订单合同。',
      confirmLabel: '确认记录',
      successMessage: '已记录工厂违约',
      loadingLabel: '记录中...',
    );

const _MyProjectLifecycleActionOption _closeLifecycleAction =
    _MyProjectLifecycleActionOption(
      kind: _MyProjectLifecycleActionKind.close,
      buttonLabel: '下架关闭',
      confirmTitle: '下架关闭',
      confirmMessage: '关闭后项目会退出公域展示。',
      confirmLabel: '确认关闭',
      successMessage: '已下架关闭',
      loadingLabel: '关闭中...',
    );

_MyProjectStageOption _myProjectStageOption(_MyProjectStageBucket bucket) {
  return switch (bucket) {
    _MyProjectStageBucket.archived => _myProjectArchivedStageOption,
    _ => _myProjectPrimaryStageOptions.firstWhere(
      (_MyProjectStageOption item) => item.value == bucket,
    ),
  };
}

_MyProjectLifecycleActionOption _myProjectLifecycleActionOption(
  _MyProjectLifecycleActionKind kind,
) {
  return switch (kind) {
    _MyProjectLifecycleActionKind.publish => _publishLifecycleAction,
    _MyProjectLifecycleActionKind.withdraw => _withdrawLifecycleAction,
    _MyProjectLifecycleActionKind.discardSubmitted =>
      _discardSubmittedLifecycleAction,
    _MyProjectLifecycleActionKind.withdrawPublished =>
      _withdrawPublishedLifecycleAction,
    _MyProjectLifecycleActionKind.requestCancellation =>
      _requestCancellationLifecycleAction,
    _MyProjectLifecycleActionKind.recordPublisherBreach =>
      _recordPublisherBreachLifecycleAction,
    _MyProjectLifecycleActionKind.recordFactoryBreach =>
      _recordFactoryBreachLifecycleAction,
    _MyProjectLifecycleActionKind.close => _closeLifecycleAction,
  };
}

_MyProjectStageBucket _myProjectStageBucketFromState(String? state) {
  return switch (_normalizeId(state)) {
    'draft' => _MyProjectStageBucket.draft,
    'submitted' => _MyProjectStageBucket.submitted,
    'published' || 'bidding_closed' => _MyProjectStageBucket.published,
    'awarded' || 'converted_to_order' => _MyProjectStageBucket.active,
    'archived' => _MyProjectStageBucket.archived,
    _ => _MyProjectStageBucket.draft,
  };
}

_MyProjectStageBucket? _myProjectStageBucketFromRoute(String? stage) {
  return switch (_normalizeId(stage)) {
    'all' => _MyProjectStageBucket.all,
    'draft' => _MyProjectStageBucket.draft,
    'submitted' => _MyProjectStageBucket.submitted,
    'published' => _MyProjectStageBucket.published,
    'active' => _MyProjectStageBucket.active,
    'archived' => _MyProjectStageBucket.archived,
    _ => null,
  };
}

List<Map<String, Object?>> _myProjectAllItemsFromPayload(Object? payload) {
  final combined = <Map<String, Object?>>[
    ..._myProjectGroupItemsFromPayload(payload, 'ongoingProjects'),
    ..._myProjectGroupItemsFromPayload(payload, 'historicalProjects'),
  ];
  if (combined.isEmpty) {
    return const <Map<String, Object?>>[];
  }

  final seenProjectIds = <String>{};
  final normalized = <Map<String, Object?>>[];
  for (final item in combined) {
    final publicProject = _myProjectPublicProjectMap(item);
    final projectId = _normalizeId(publicProject?['projectId'] as String?);
    if (projectId == null) {
      normalized.add(item);
      continue;
    }
    if (seenProjectIds.add(projectId)) {
      normalized.add(item);
    }
  }
  return normalized;
}

List<Map<String, Object?>> _myProjectItemsForStage(
  Object? payload,
  _MyProjectStageBucket stage,
) {
  if (stage == _MyProjectStageBucket.all) {
    return _myProjectAllItemsFromPayload(payload);
  }
  if (stage == _MyProjectStageBucket.archived) {
    return _myProjectArchivedItemsFromPayload(payload);
  }

  return _myProjectAllItemsFromPayload(payload).where((
    Map<String, Object?> item,
  ) {
    final publicProject = _myProjectPublicProjectMap(item);
    final state = _normalizeId(publicProject?['state'] as String?);
    return _myProjectStageBucketFromState(state) == stage;
  }).toList();
}

List<Map<String, Object?>> _myProjectArchivedItemsFromPayload(Object? payload) {
  return _myProjectAllItemsFromPayload(payload).where((
    Map<String, Object?> item,
  ) {
    final publicProject = _myProjectPublicProjectMap(item);
    final state = _normalizeId(publicProject?['state'] as String?);
    return _myProjectStageBucketFromState(state) ==
        _MyProjectStageBucket.archived;
  }).toList();
}

_MyProjectStageBucket _myProjectPreferredStageFromPayload(Object? payload) {
  for (final option in _myProjectPrimaryStageOptions.where(
    (_MyProjectStageOption option) =>
        option.value != _MyProjectStageBucket.all &&
        option.value != _MyProjectStageBucket.draft,
  )) {
    if (_myProjectItemsForStage(payload, option.value).isNotEmpty) {
      return option.value;
    }
  }
  return _MyProjectStageBucket.submitted;
}

bool _myProjectCanDelete(String? state) {
  return _myProjectStageBucketFromState(state) == _MyProjectStageBucket.draft;
}

bool _myProjectCanOpenAttachmentStage(String? state) {
  final stage = _myProjectStageBucketFromState(state);
  if (stage == _MyProjectStageBucket.submitted) {
    return true;
  }
  return stage == _MyProjectStageBucket.published ||
      stage == _MyProjectStageBucket.active;
}

bool _myProjectCanWithdraw(String? state) {
  return _myProjectStageBucketFromState(state) ==
      _MyProjectStageBucket.submitted;
}

bool _myProjectCanPublish(String? state) {
  return _myProjectStageBucketFromState(state) ==
      _MyProjectStageBucket.submitted;
}

bool _myProjectCanDiscardSubmitted(String? state) {
  return _myProjectStageBucketFromState(state) ==
      _MyProjectStageBucket.submitted;
}

bool _myProjectCanWithdrawPublished(String? state) {
  return _myProjectStageBucketFromState(state) ==
      _MyProjectStageBucket.published;
}

bool _myProjectCanUseActiveExitGovernance(String? state) {
  return _myProjectStageBucketFromState(state) == _MyProjectStageBucket.active;
}
