part of '../exhibition_trade_pages.dart';

class ProjectNameAccessThreadPage extends StatefulWidget {
  const ProjectNameAccessThreadPage({
    super.key,
    this.threadId,
    this.projectId,
    this.requestId,
  });

  final String? threadId;
  final String? projectId;
  final String? requestId;

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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await ProjectNameAccessConsumerLayer.instance
        .loadThreadDetail(threadId: widget.threadId);
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
                  '处理项目名称查看申请',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '当前申请会影响申请方是否可见项目名称。审批只发生在这个受控 review thread 内，不开放自由聊天。',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.45),
                ),
                const SizedBox(height: 16),
                if (availableDecisions.contains('approve'))
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.of(context).pop('approve'),
                      icon: const Icon(Icons.check_circle_rounded),
                      label: const Text('同意查看项目名称'),
                    ),
                  ),
                if (availableDecisions.contains('approve'))
                  const SizedBox(height: 12),
                if (availableDecisions.contains('reject'))
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop('reject'),
                      icon: const Icon(Icons.block_rounded),
                      label: const Text('拒绝本次申请'),
                    ),
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
      'approve' => ProjectNameAccessConsumerLayer.instance.approveRequest(
        projectId: data.projectId,
        requestId: data.requestId,
      ),
      _ => ProjectNameAccessConsumerLayer.instance.rejectRequest(
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
      color: Theme.of(context).colorScheme.surface,
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: <Widget>[
            const SizedBox(height: 8),
            _ActionCard(
              title: '项目名称查看申请',
              summary: '当前页是受控 review thread，只承接系统申请卡和审批结果，不开放自由聊天。',
              tone: _ActionCardTone.emphasis,
              children: <Widget>[
                _DetailLine(label: '线程 ID', value: _threadId ?? '未承接'),
                if (data != null) ...<Widget>[
                  _DetailLine(label: '项目 ID', value: data.projectId),
                  _DetailLine(label: '申请 ID', value: data.requestId),
                  _DetailLine(
                    label: '当前状态',
                    value: _projectNameAccessReviewStatusLabel(
                      data.requestStatus,
                    ),
                    highlight: true,
                  ),
                  _DetailLine(label: '项目名称', value: data.displayTitle),
                ],
              ],
            ),
            const SizedBox(height: 16),
            if (_loading)
              const _StateMessage(title: '正在加载', body: '请稍候片刻。')
            else if (result == null || result.state != AppPageState.content)
              _ActionCard(
                title: result?.message ?? '当前项目名称查看会话暂不可用',
                children: <Widget>[
                  _StateMessage(
                    title: '受控状态',
                    body:
                        result?.errorCode ??
                        result?.state.contractName ??
                        'unknown',
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonal(onPressed: _load, child: const Text('重试')),
                ],
              )
            else ...<Widget>[
              _buildThreadOverview(data!),
              const SizedBox(height: 16),
              _buildThreadItems(data),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildThreadOverview(ProjectNameAccessThreadDetailView data) {
    final primaryReviewAction = data.primaryReviewAction;
    final canReview =
        primaryReviewAction?.enabled == true && !_reviewSubmitting;
    return _ActionCard(
      title: '处理说明',
      children: <Widget>[
        _StateMessage(
          title: '当前说明',
          body: _projectNameAccessThreadBody(data.requestStatus),
        ),
        if (_lastDecisionResult != null &&
            !_lastDecisionResult!.isSuccess) ...<Widget>[
          const SizedBox(height: 12),
          _StateMessage(
            title: '上次操作未完成',
            body:
                _lastDecisionResult!.message ??
                _lastDecisionResult!.state.contractName,
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            if (primaryReviewAction?.enabled == true)
              FilledButton.icon(
                onPressed: canReview ? () => _handlePrimaryReview(data) : null,
                icon: const Icon(Icons.rule_rounded),
                label: Text(_reviewSubmitting ? '处理中...' : '处理申请'),
              ),
            OutlinedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('刷新状态'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildThreadItems(ProjectNameAccessThreadDetailView data) {
    if (data.items.isEmpty) {
      return const _EmptyNotice(
        title: '当前还没有系统申请项',
        message: '这条 review thread 目前没有可展示的系统项。',
      );
    }

    return Column(
      children: data.items
          .map(
            (ProjectNameAccessThreadItemView item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ActionCard(
                title: item.title,
                summary: item.itemKind == 'system_seed' ? '系统申请卡' : '系统结果通知',
                tone: item.itemKind == 'system_seed'
                    ? _ActionCardTone.emphasis
                    : _ActionCardTone.standard,
                children: <Widget>[
                  _DetailLine(label: '摘要', value: item.summary),
                  _DetailLine(label: '时间', value: item.createdAt),
                  if (item.action != null) ...<Widget>[
                    const SizedBox(height: 10),
                    FilledButton.tonal(
                      onPressed: _actionEnabled(item.action, data)
                          ? () => _handleItemAction(data, item)
                          : null,
                      child: Text(item.action?.label ?? '继续处理'),
                    ),
                  ],
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }

  bool _actionEnabled(
    ProjectNameAccessThreadItemActionView? action,
    ProjectNameAccessThreadDetailView data,
  ) {
    if (action == null) {
      return false;
    }
    if (action.actionKey == 'project_name_access.review') {
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
      await _handlePrimaryReview(data);
      return;
    }
    await _load();
  }
}

String _projectNameAccessThreadBody(String requestStatus) {
  return switch (requestStatus) {
    'pending' => '当前申请仍在等待发布方审批；审批通过后，申请方才会看到真实项目名称。',
    'approved' => '当前申请已经审批通过；申请方刷新项目列表和详情后即可看到真实项目名称。',
    'rejected' => '当前申请已经被拒绝；如后续状态允许，可以回到项目详情重新发起申请。',
    _ => '当前申请状态暂不可识别，请刷新后再试。',
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
