part of '../exhibition_trade_pages.dart';

class InspectionRecheckPage extends StatefulWidget {
  const InspectionRecheckPage({super.key, this.milestoneId});

  final String? milestoneId;

  @override
  State<InspectionRecheckPage> createState() => _InspectionRecheckPageState();
}

class _InspectionRecheckPageState extends State<InspectionRecheckPage> {
  late final TextEditingController _milestoneIdController =
      TextEditingController(text: widget.milestoneId ?? '');
  late final TextEditingController _recheckNoteController =
      TextEditingController();
  ExhibitionLoadResult? _detailResult;
  ExhibitionActionResult? _actionResult;
  bool _loading = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    if (_milestoneIdController.text.trim().isEmpty) {
      _detailResult = ExhibitionLoadResult(
        state: AppPageState.notFound,
        method: 'GET',
        path: ExhibitionCanonicalPaths.inspectionDetail,
        message:
            'milestoneId is required from route context before inspection recheck',
      );
    } else {
      _load();
    }
  }

  @override
  void dispose() {
    _milestoneIdController.dispose();
    _recheckNoteController.dispose();
    super.dispose();
  }

  Future<void> _load({bool forceRefresh = false}) async {
    setState(() {
      _loading = true;
    });

    final result = await ExhibitionConsumerLayer.instance.loadInspectionDetail(
      milestoneId: _milestoneIdController.text,
      forceRefresh: forceRefresh,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _detailResult = result;
      _loading = false;
    });
  }

  Future<void> _submit() async {
    final inspectionState = _stateFromPayload(_detailResult?.payload);
    final inspectionId = _inspectionIdFromPayload(_detailResult?.payload);
    if (inspectionId == null || inspectionState != 'submitted') {
      setState(() {
        _actionResult = ExhibitionActionResult(
          method: 'POST',
          path: ExhibitionCanonicalPaths.inspectionRecheck,
          isSuccess: false,
          controlledState: AppPageState.errorNonRetryable,
          message: inspectionId == null
              ? 'inspectionId is required from inspection detail before recheck'
              : 'current inspection state does not allow recheck submission',
        );
      });
      return;
    }

    setState(() {
      _submitting = true;
      _actionResult = null;
    });

    final result = await ExhibitionConsumerLayer.instance.recheckInspection(
      InspectionRecheckCommand(
        inspectionId: inspectionId,
        recheckNote: _recheckNoteController.text,
      ),
    );

    if (!mounted) {
      return;
    }

    if (result.isSuccess) {
      ExhibitionConsumerLayer.instance.invalidateInspectionDetail(
        milestoneId: widget.milestoneId ?? _milestoneIdController.text.trim(),
      );
    }

    setState(() {
      _submitting = false;
      _actionResult = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final routeMilestoneId = _normalizeId(widget.milestoneId);
    final inspectionId = _inspectionIdFromPayload(_detailResult?.payload);
    final inspectionState = _stateFromPayload(_detailResult?.payload);
    final detailSummary = _payloadMap(_detailResult?.payload)?['summary'];
    final canSubmit =
        _detailResult?.state == AppPageState.content &&
        inspectionId != null &&
        inspectionState == 'submitted';
    final currentStateMessage = switch (inspectionState) {
      'submitted' => '当前状态：验收已提交，现在可以继续复检提交。',
      'rechecked' => '当前状态：验收已经完成复检，这一页只保留结果承接。',
      _ when _detailResult?.state == AppPageState.content =>
        '当前状态：验收详情已经承接完成，是否允许复检以后端返回为准。',
      _ => '当前状态：需要先完成验收详情承接，才能继续这一步。',
    };
    final actionMessage = canSubmit
        ? '当前动作：可以继续提交复检；页面不会本地补做复检资格、历史链路或治理判断。'
        : inspectionState == 'rechecked'
        ? '当前动作：复检已经完成，当前页保持只读承接。'
        : '当前动作：暂时不能继续提交复检，请先恢复 detail 承接。';
    final continueMessage = _actionResult?.isSuccess == true
        ? '提交后如何继续：页面只停留在后端返回的 rechecked projection 承接面。'
        : '提交后如何继续：如果提交成功，页面只保留 inspectionId、milestoneId 与最小结果摘要。';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: _buildPageChildren(
        routeMilestoneId: routeMilestoneId,
        inspectionId: inspectionId,
        inspectionState: inspectionState,
        detailSummary: detailSummary,
        canSubmit: canSubmit,
        currentStateMessage: currentStateMessage,
        actionMessage: actionMessage,
        continueMessage: continueMessage,
      ),
    );
  }

  List<Widget> _buildPageChildren({
    required String? routeMilestoneId,
    required String? inspectionId,
    required String? inspectionState,
    required Object? detailSummary,
    required bool canSubmit,
    required String currentStateMessage,
    required String actionMessage,
    required String continueMessage,
  }) {
    return <Widget>[
      const _SummaryCard(
        title: '验收复检提交',
        summary: '页面先读取当前验收详情；只有已提交的验收才继续复检提交，其余状态保持只读承接，不扩成历史、治理或平台决策面板。',
      ),
      const SizedBox(height: 16),
      if (_loading)
        const _ContractLoadingCard()
      else if (_detailResult != null)
        _LoadStateCard(
          result: _detailResult!,
          onRetry: () => _load(forceRefresh: true),
        ),
      const SizedBox(height: 16),
      _buildRecheckActionCard(
        routeMilestoneId: routeMilestoneId,
        inspectionId: inspectionId,
        inspectionState: inspectionState,
        detailSummary: detailSummary,
        canSubmit: canSubmit,
        currentStateMessage: currentStateMessage,
        actionMessage: actionMessage,
        continueMessage: continueMessage,
      ),
    ];
  }

  Widget _buildRecheckActionCard({
    required String? routeMilestoneId,
    required String? inspectionId,
    required String? inspectionState,
    required Object? detailSummary,
    required bool canSubmit,
    required String currentStateMessage,
    required String actionMessage,
    required String continueMessage,
  }) {
    return _ActionCard(
      title: '现在提交什么',
      children: <Widget>[
        _StateMessage(title: '当前状态', body: currentStateMessage),
        const SizedBox(height: 12),
        _StateMessage(title: '当前动作', body: actionMessage),
        const SizedBox(height: 12),
        _StateMessage(title: '后续如何继续', body: continueMessage),
        const SizedBox(height: 12),
        if (routeMilestoneId != null)
          _InstanceSummaryLine(title: '当前里程碑 ID', value: routeMilestoneId),
        if (inspectionId != null) ...<Widget>[
          const SizedBox(height: 12),
          _InstanceSummaryLine(title: '当前验收 ID', value: inspectionId),
        ],
        if (inspectionState != null) ...<Widget>[
          const SizedBox(height: 12),
          Text('当前业务状态：${_frontStageStateLabel(inspectionState)}'),
        ],
        if (detailSummary is Map) ...<Widget>[
          const SizedBox(height: 12),
          const Text('摘要承接：已承接最小 summary'),
        ],
        const SizedBox(height: 12),
        _InputField(controller: _recheckNoteController, label: 'recheckNote'),
        const SizedBox(height: 16),
        FilledButton(
          key: const ValueKey<String>('inspection_recheck_button'),
          onPressed: _submitting || !canSubmit ? null : _submit,
          child: const Text('提交复检'),
        ),
        const SizedBox(height: 16),
        if (_submitting)
          const _SubmittingPanel()
        else if (_actionResult != null) ...<Widget>[
          _SubmissionResultPanel(result: _actionResult!),
          if (_actionResult!.isSuccess) ...<Widget>[
            const SizedBox(height: 16),
            ..._buildSuccessSections(routeMilestoneId),
          ],
        ],
      ],
    );
  }

  List<Widget> _buildSuccessSections(String? routeMilestoneId) {
    final actionPayload = _payloadMap(_actionResult!.payload);
    final actionInspectionId = _inspectionIdFromPayload(_actionResult!.payload);
    final actionMilestoneId =
        _normalizeId(actionPayload?['milestoneId'] as String?) ??
        routeMilestoneId;
    final actionState = _stateFromPayload(_actionResult!.payload);
    final actionSummary = actionPayload?['summary'];

    return <Widget>[
      _ActionCard(
        title: '已复检结果',
        children: <Widget>[
          const Text('当前页面只承接后端返回的最小 rechecked projection。'),
          if (actionMilestoneId != null) ...<Widget>[
            const SizedBox(height: 12),
            _InstanceSummaryLine(title: '当前里程碑 ID', value: actionMilestoneId),
          ],
          if (actionInspectionId != null) ...<Widget>[
            const SizedBox(height: 12),
            _InstanceSummaryLine(title: '当前验收 ID', value: actionInspectionId),
          ],
          if (actionState != null) ...<Widget>[
            const SizedBox(height: 12),
            Text('当前状态：${_frontStageStateLabel(actionState)}'),
          ],
          if (actionSummary is Map) ...<Widget>[
            const SizedBox(height: 12),
            const Text('摘要承接：已承接最小 summary'),
          ],
        ],
      ),
      const SizedBox(height: 16),
      _ActionCard(
        title: '提交后如何继续',
        children: <Widget>[
          const Text(
            '验收复检已完成，页面停留在受控 rechecked projection 承接，不扩成历史、治理或平台决策面板。',
          ),
          if (actionMilestoneId != null) ...<Widget>[
            const SizedBox(height: 12),
            _InstanceSummaryLine(title: '当前里程碑 ID', value: actionMilestoneId),
          ],
          if (actionInspectionId != null) ...<Widget>[
            const SizedBox(height: 12),
            _InstanceSummaryLine(title: '当前验收 ID', value: actionInspectionId),
          ],
        ],
      ),
    ];
  }
}
