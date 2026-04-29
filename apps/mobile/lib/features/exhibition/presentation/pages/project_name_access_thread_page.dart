part of '../exhibition_trade_pages.dart';

class ProjectNameAccessThreadPage extends StatefulWidget {
  const ProjectNameAccessThreadPage({
    super.key,
    this.threadId,
    this.projectId,
    this.requestId,
    this.bidParticipation = false,
  });

  final String? threadId;
  final String? projectId;
  final String? requestId;
  final bool bidParticipation;

  @override
  State<ProjectNameAccessThreadPage> createState() =>
      _ProjectNameAccessThreadPageState();
}

class _ProjectNameAccessThreadPageState
    extends State<ProjectNameAccessThreadPage> {
  ProjectNameAccessResult<ProjectNameAccessThreadDetailView>? _result;
  ProjectNameAccessResult<ProjectNameAccessDecisionView>? _lastDecisionResult;
  bool _loading = true;
  bool _reviewSubmitting = false;

  String? get _threadId => _normalizeId(widget.threadId);
  bool get _isLegacyNameAccess => !widget.bidParticipation;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = widget.bidParticipation
        ? await ProjectNameAccessConsumerLayer.instance
              .loadBidParticipationThreadDetail(threadId: widget.threadId)
        : await ProjectNameAccessConsumerLayer.instance.loadThreadDetail(
            threadId: widget.threadId,
          );
    if (!mounted) {
      return;
    }
    setState(() {
      _result = result;
      _loading = false;
    });
  }

  Future<void> _handlePrimaryReview(
    ProjectNameAccessThreadDetailView data,
  ) async {
    if (_isLegacyNameAccess) {
      return;
    }
    if (_reviewSubmitting) {
      return;
    }
    final decision = await _showDecisionSheet(data);
    if (!mounted || decision == null) {
      return;
    }
    await _submitDecision(data: data, decision: decision);
  }

  Future<String?> _showDecisionSheet(ProjectNameAccessThreadDetailView data) {
    return showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        final availableDecisions =
            data.primaryReviewAction?.availableDecisions ??
            const <String>['approve', 'reject'];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.bidParticipation ? '处理参与竞标申请' : '处理项目名称查看申请',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.bidParticipation
                      ? '当前申请会影响申请方是否可以查看项目名称、报价依据资料并提交竞标。审批只发生在这个受控 review thread 内。'
                      : '当前申请会影响申请方是否可见项目名称。审批只发生在这个受控 review thread 内，不开放自由聊天。',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.45),
                ),
                const SizedBox(height: 16),
                if (availableDecisions.contains('approve'))
                  AppPrimaryButton(
                    expanded: true,
                    onPressed: () => Navigator.of(context).pop('approve'),
                    icon: Icons.check_circle_rounded,
                    label: widget.bidParticipation ? '同意参与竞标' : '同意查看项目名称',
                  ),
                if (availableDecisions.contains('approve'))
                  const SizedBox(height: 12),
                if (availableDecisions.contains('reject'))
                  AppSecondaryButton(
                    expanded: true,
                    onPressed: () => Navigator.of(context).pop('reject'),
                    icon: Icons.block_rounded,
                    label: '拒绝本次申请',
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitDecision({
    required ProjectNameAccessThreadDetailView data,
    required String decision,
  }) async {
    setState(() {
      _reviewSubmitting = true;
      _lastDecisionResult = null;
    });

    final result = switch (decision) {
      'approve' =>
        widget.bidParticipation
            ? ProjectNameAccessConsumerLayer.instance
                  .approveBidParticipationRequest(
                    projectId: data.projectId,
                    requestId: data.requestId,
                  )
            : ProjectNameAccessConsumerLayer.instance.approveRequest(
                projectId: data.projectId,
                requestId: data.requestId,
              ),
      _ =>
        widget.bidParticipation
            ? ProjectNameAccessConsumerLayer.instance
                  .rejectBidParticipationRequest(
                    projectId: data.projectId,
                    requestId: data.requestId,
                  )
            : ProjectNameAccessConsumerLayer.instance.rejectRequest(
                projectId: data.projectId,
                requestId: data.requestId,
              ),
    };
    final resolved = await result;
    if (!mounted) {
      return;
    }

    setState(() {
      _reviewSubmitting = false;
      _lastDecisionResult = resolved;
    });

    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      SnackBar(
        content: Text(
          resolved.isSuccess
              ? (decision == 'approve' ? '已同意该申请。' : '已拒绝该申请。')
              : (resolved.message ?? '当前审批操作未完成，请稍后再试。'),
        ),
      ),
    );

    if (resolved.isSuccess) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final data = result?.data;

    return Material(
      color: AppVisualTokens.pageBackground,
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppVisualTokens.pagePadding,
            20,
            AppVisualTokens.pagePadding,
            0,
          ),
          children: <Widget>[
            const SizedBox(height: 8),
            _buildThreadHero(data),
            const SizedBox(height: 16),
            if (_loading)
              const AppEmptyState(title: '正在加载', message: '请稍候片刻。')
            else if (result == null || result.state != AppPageState.content)
              AppSectionCard(
                title:
                    result?.message ??
                    (widget.bidParticipation
                        ? '当前参与竞标申请会话暂不可用'
                        : '当前项目名称查看会话暂不可用'),
                subtitle:
                    result?.errorCode ??
                    result?.state.contractName ??
                    'unknown',
                children: <Widget>[
                  AppSecondaryButton(label: '重试', onPressed: _load),
                ],
              )
            else ...<Widget>[
              _buildThreadOverview(data!),
              const SizedBox(height: 16),
              _buildThreadItems(data),
            ],
            const AppBottomSafePadding(),
          ],
        ),
      ),
    );
  }

  Widget _buildThreadHero(ProjectNameAccessThreadDetailView? data) {
    final statusLabel = data == null
        ? '同步中'
        : widget.bidParticipation
        ? _bidParticipationReviewStatusLabel(data.requestStatus)
        : _projectNameAccessReviewStatusLabel(data.requestStatus);
    final title = widget.bidParticipation ? '参与竞标申请' : '历史项目名称查看申请';
    final body = widget.bidParticipation
        ? '当前页承接申请状态与审批结果。通过后，申请方可继续查看项目名称、报价依据资料并提交竞标。'
        : '旧项目名称查看申请已合并到申请参与竞标；当前页仅保留历史申请和审批结果，不再开放处理动作。';

    return AppCard(
      radius: AppVisualTokens.radiusXLarge,
      withShadow: true,
      backgroundColor: AppVisualTokens.cardBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: Text(title, style: AppTextTokens.pageTitle)),
              AppStatusBadge(
                label: statusLabel,
                tone: _statusTone(data?.requestStatus),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(body, style: AppTextTokens.body),
          if (!widget.bidParticipation) ...<Widget>[
            const SizedBox(height: 10),
            Text('项目名称查看申请', style: AppTextTokens.caption),
          ],
          if (data != null) ...<Widget>[
            const SizedBox(height: 18),
            AppSectionCard(
              title: '项目信息',
              subtitle: data.displayTitle,
              withShadow: false,
              children: <Widget>[
                Wrap(
                  spacing: AppVisualTokens.chipGap,
                  runSpacing: AppVisualTokens.chipGap,
                  children: <Widget>[
                    AppInfoChip(
                      label: '当前状态',
                      value: statusLabel,
                      icon: Icons.hourglass_top_rounded,
                      highlight: true,
                    ),
                    AppInfoChip(
                      label: widget.bidParticipation ? '申请类型' : '类型',
                      value: widget.bidParticipation ? '竞标申请' : '历史名称查看',
                      icon: Icons.assignment_turned_in_outlined,
                    ),
                  ],
                ),
                if (!widget.bidParticipation) ...<Widget>[
                  const SizedBox(height: 8),
                  Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                      splashColor: Colors.transparent,
                    ),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: EdgeInsets.zero,
                      title: Text('申请编号', style: AppTextTokens.bodyStrong),
                      subtitle: const Text('技术编号仅用于排查和客服定位。'),
                      children: <Widget>[
                        _DetailLine(label: '线程 ID', value: _threadId ?? '未承接'),
                        _DetailLine(label: '项目 ID', value: data.projectId),
                        _DetailLine(label: '申请 ID', value: data.requestId),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildThreadOverview(ProjectNameAccessThreadDetailView data) {
    final primaryReviewAction = data.primaryReviewAction;
    final canReview =
        widget.bidParticipation &&
        primaryReviewAction?.enabled == true &&
        !_reviewSubmitting;
    return AppSectionCard(
      title: widget.bidParticipation ? '申请流程' : '历史记录说明',
      subtitle: widget.bidParticipation
          ? _bidParticipationThreadBody(data.requestStatus)
          : _projectNameAccessReadonlyBody(data.requestStatus),
      children: <Widget>[
        if (_lastDecisionResult != null &&
            !_lastDecisionResult!.isSuccess) ...<Widget>[
          AppEmptyState(
            title: '上次操作未完成',
            message:
                _lastDecisionResult!.message ??
                _lastDecisionResult!.state.contractName,
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            if (widget.bidParticipation && primaryReviewAction?.enabled == true)
              AppPrimaryButton(
                onPressed: canReview ? () => _handlePrimaryReview(data) : null,
                icon: Icons.rule_rounded,
                label: _reviewSubmitting ? '处理中...' : '处理申请',
              ),
            AppSecondaryButton(
              onPressed: _load,
              icon: Icons.refresh_rounded,
              label: '刷新状态',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildThreadItems(ProjectNameAccessThreadDetailView data) {
    if (data.items.isEmpty) {
      return const AppEmptyState(
        title: '当前还没有系统申请项',
        message: '这条 review thread 目前没有可展示的系统项。',
      );
    }

    return AppSectionCard(
      title: '申请记录',
      subtitle: '这里保留系统申请卡和审批结果，不展示自由聊天内容。',
      children: <Widget>[
        ...data.items.map(
          (ProjectNameAccessThreadItemView item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              backgroundColor: const Color(0xFFFEFDFB),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(item.title, style: AppTextTokens.cardTitle),
                      ),
                      AppStatusBadge(
                        label: item.itemKind == 'system_seed'
                            ? '系统申请卡'
                            : '结果通知',
                        tone: item.itemKind == 'system_seed'
                            ? AppStatusTone.brand
                            : AppStatusTone.neutral,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _DetailLine(label: '摘要', value: item.summary),
                  _DetailLine(label: '时间', value: item.createdAt),
                  if (widget.bidParticipation &&
                      item.action != null) ...<Widget>[
                    const SizedBox(height: 10),
                    AppSecondaryButton(
                      onPressed: _actionEnabled(item.action, data)
                          ? () => _handleItemAction(data, item)
                          : null,
                      label: item.action?.label ?? '继续处理',
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  AppStatusTone _statusTone(String? requestStatus) {
    return switch (requestStatus) {
      'pending' => AppStatusTone.warning,
      'approved' => AppStatusTone.success,
      'rejected' => AppStatusTone.danger,
      _ => AppStatusTone.neutral,
    };
  }

  bool _actionEnabled(
    ProjectNameAccessThreadItemActionView? action,
    ProjectNameAccessThreadDetailView data,
  ) {
    if (action == null) {
      return false;
    }
    if (_isLegacyNameAccess) {
      return false;
    }
    if (action.actionKey == 'project_name_access.review') {
      return data.primaryReviewAction?.enabled == true && !_reviewSubmitting;
    }
    if (action.actionKey == 'bid_participation.review') {
      return data.primaryReviewAction?.enabled == true && !_reviewSubmitting;
    }
    return !_loading;
  }

  Future<void> _handleItemAction(
    ProjectNameAccessThreadDetailView data,
    ProjectNameAccessThreadItemView item,
  ) async {
    final actionKey = item.action?.actionKey;
    if (actionKey == 'project_name_access.review') {
      return;
    }
    if (actionKey == 'bid_participation.review') {
      await _handlePrimaryReview(data);
      return;
    }
    if (actionKey == 'bid_submit.open') {
      final projectId =
          _normalizeId(item.action?.params['projectId']) ??
          _normalizeId(data.projectId);
      if (projectId == null) {
        await _load();
        return;
      }
      if (!mounted) {
        return;
      }
      await Navigator.of(
        context,
      ).pushNamed(ExhibitionRoutes.bidSubmitWithProjectId(projectId));
      return;
    }
    await _load();
  }
}

String _projectNameAccessReadonlyBody(String requestStatus) {
  return switch (requestStatus) {
    'pending' => '这是一条历史项目名称查看申请记录；旧审批入口已停用，请统一通过参与竞标申请处理新的准入。',
    'approved' => '这是一条历史项目名称查看申请通过记录；仅用于追溯，不再作为新的准入入口。',
    'rejected' => '这是一条历史项目名称查看申请拒绝记录；仅用于追溯，不再作为新的准入入口。',
    _ => '这是一条历史项目名称查看申请记录；当前状态暂不可识别，可刷新后再查看。',
  };
}

String _projectNameAccessReviewStatusLabel(String requestStatus) {
  return switch (requestStatus) {
    'pending' => '待审批',
    'approved' => '审批已通过',
    'rejected' => '审批已拒绝',
    _ => '状态待确认',
  };
}

String _bidParticipationThreadBody(String requestStatus) {
  return switch (requestStatus) {
    'pending' => '当前申请仍在等待发布方审批；通过后，申请方可查看项目名称、报价依据资料并继续提交竞标。',
    'approved' => '当前申请已经审批通过；申请方可从消息楼或项目详情继续提交竞标。',
    'rejected' => '当前申请已经被拒绝；申请方暂不能查看报价依据资料或提交竞标。',
    _ => '当前申请状态暂不可识别，请刷新后再试。',
  };
}

String _bidParticipationReviewStatusLabel(String requestStatus) {
  return switch (requestStatus) {
    'pending' => '待审批',
    'approved' => '已通过',
    'rejected' => '已拒绝',
    _ => '状态待确认',
  };
}
