part of '../exhibition_trade_pages.dart';

class InspectionSubmitPage extends StatefulWidget {
  const InspectionSubmitPage({super.key, this.milestoneId});

  final String? milestoneId;

  @override
  State<InspectionSubmitPage> createState() => _InspectionSubmitPageState();
}

class _InspectionSubmitPageState extends State<InspectionSubmitPage> {
  late final ExhibitionStageLoadAutoSource _detailSource =
      ExhibitionStageLoadAutoSource(
        futureRealLoader: ({bool forceRefresh = false}) {
          return ExhibitionConsumerLayer.instance.loadInspectionDetail(
            milestoneId: widget.milestoneId,
            forceRefresh: forceRefresh,
          );
        },
        demoBuilder: () => ExhibitionStageDemoCatalog.inspectionDetail(
          milestoneId: widget.milestoneId,
        ),
      );

  ExhibitionStageLoadSnapshot? _detailSnapshot;
  ExhibitionActionResult? _actionResult;
  ExhibitionStageDataOrigin? _actionOrigin;
  bool _loading = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool forceRefresh = false}) async {
    setState(() {
      _loading = true;
    });

    final snapshot = await _detailSource.load(forceRefresh: forceRefresh);

    if (!mounted) {
      return;
    }

    setState(() {
      _detailSnapshot = snapshot;
      _loading = false;
    });
  }

  Future<void> _submit() async {
    final detailResult = _detailSnapshot?.result;
    final milestoneId =
        _normalizeId(widget.milestoneId) ??
        _normalizeId(
          _payloadMap(detailResult?.payload)?['milestoneId'] as String?,
        ) ??
        ExhibitionStageDemoCatalog.demoMilestoneId;

    if (_detailSnapshot?.isDemo == true) {
      setState(() {
        _actionResult = ExhibitionStageDemoCatalog.inspectionSubmit(
          milestoneId: milestoneId,
        );
        _actionOrigin = ExhibitionStageDataOrigin.demo;
      });
      return;
    }

    final inspectionId = _inspectionIdFromPayload(detailResult?.payload);
    if (inspectionId == null) {
      setState(() {
        _actionResult = ExhibitionActionResult(
          method: 'POST',
          path: ExhibitionCanonicalPaths.inspectionSubmit,
          isSuccess: false,
          controlledState: AppPageState.errorNonRetryable,
          message:
              'inspectionId is required from inspection detail before submit',
        );
        _actionOrigin = ExhibitionStageDataOrigin.futureReal;
      });
      return;
    }

    setState(() {
      _submitting = true;
      _actionResult = null;
      _actionOrigin = null;
    });

    final result = await ExhibitionConsumerLayer.instance.submitInspection(
      InspectionSubmitCommand(inspectionId: inspectionId),
    );

    if (!mounted) {
      return;
    }

    if (result.isSuccess) {
      ExhibitionConsumerLayer.instance.invalidateInspectionDetail(
        milestoneId: milestoneId,
      );
    }

    setState(() {
      _submitting = false;
      _actionResult = result;
      _actionOrigin = ExhibitionStageDataOrigin.futureReal;
    });
  }

  void _applyDemoResult() {
    final milestoneId =
        _normalizeId(widget.milestoneId) ??
        _normalizeId(
          _payloadMap(_detailSnapshot?.result.payload)?['milestoneId']
              as String?,
        ) ??
        ExhibitionStageDemoCatalog.demoMilestoneId;

    setState(() {
      _actionResult = ExhibitionStageDemoCatalog.inspectionSubmit(
        milestoneId: milestoneId,
      );
      _actionOrigin = ExhibitionStageDataOrigin.demo;
    });
  }

  @override
  Widget build(BuildContext context) {
    final routeMilestoneId = _normalizeId(widget.milestoneId);
    final detailSnapshot = _detailSnapshot;
    final detailResult = detailSnapshot?.result;
    final inspectionId = _inspectionIdFromPayload(detailResult?.payload);
    final inspectionState = _stateFromPayload(detailResult?.payload);
    final detailSummary = _payloadMap(detailResult?.payload)?['summary'];
    final canSubmit =
        detailResult?.state == AppPageState.content &&
        inspectionId != null &&
        inspectionState == 'draft';
    final currentStateMessage = switch (inspectionState) {
      'draft' => '当前状态：验收还在草稿态，可以继续做首次提交。',
      'submitted' => '当前状态：验收已经提交完成，这一页改为展示已提交结果，不继续放开复检主链。',
      'rechecked' => '当前状态：验收已经完成复检，这一页只保留结果承接。',
      _ when detailResult?.state == AppPageState.content =>
        '当前状态：验收详情已经承接完成，是否允许提交以后端返回为准。',
      _ => '当前状态：需要先完成验收详情承接，才能继续这一步。',
    };
    final actionMessage = canSubmit
        ? '当前动作：可以继续提交验收；页面不会本地补做整改或复检判断。'
        : inspectionState == 'submitted'
        ? '当前动作：首次提交已经完成；当前页先停留在已提交结果承接，不继续放开复检。'
        : detailSnapshot?.isDemo == true
        ? '当前动作：真实承接暂未就位，你可以先使用演示结果继续讲解当前页面。'
        : '当前动作：暂时不能继续提交，请先恢复当前验收详情承接。';
    final continueMessage = _actionResult?.isSuccess == true
        ? '提交后如何继续：验收会停留在已提交承接结果，当前首发主链先止于这里。'
        : inspectionState == 'submitted'
        ? '提交后如何继续：当前已经是已提交结果，页面保持只读承接。'
        : '提交后如何继续：如果提交成功，页面会保留 inspectionId 与 milestoneId，便于继续当前链路。';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: _buildPageChildren(
        routeMilestoneId: routeMilestoneId,
        detailSnapshot: detailSnapshot,
        detailResult: detailResult,
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
    required ExhibitionStageLoadSnapshot? detailSnapshot,
    required ExhibitionLoadResult? detailResult,
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
        title: '验收提交',
        summary: '页面先读取验收详情，再做最小提交动作；提交完成后停留在已提交结果承接面，不扩成整改治理闭环或复检主链。',
      ),
      ..._buildNoticeCards(detailSnapshot),
      const SizedBox(height: 16),
      if (_loading)
        const _ContractLoadingCard()
      else if (detailResult != null)
        _LoadStateCard(
          result: detailResult,
          onRetry: () => _load(forceRefresh: true),
        ),
      const SizedBox(height: 16),
      _buildSubmitOverviewCard(
        routeMilestoneId: routeMilestoneId,
        detailSnapshot: detailSnapshot,
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

  List<Widget> _buildNoticeCards(ExhibitionStageLoadSnapshot? detailSnapshot) {
    return <Widget>[
      if (detailSnapshot?.sourceLabel != null &&
          detailSnapshot?.sourceMessage != null) ...<Widget>[
        const SizedBox(height: 16),
        _StageNoticeCard(
          title: detailSnapshot!.sourceLabel,
          message: detailSnapshot.sourceMessage,
          tone: _ActionCardTone.muted,
        ),
      ],
      if (detailSnapshot?.fallbackTitle != null &&
          detailSnapshot?.fallbackMessage != null) ...<Widget>[
        const SizedBox(height: 16),
        _StageNoticeCard(
          title: detailSnapshot!.fallbackTitle!,
          message: detailSnapshot.fallbackMessage!,
          tone: _ActionCardTone.emphasis,
        ),
      ],
    ];
  }

  Widget _buildSubmitOverviewCard({
    required String? routeMilestoneId,
    required ExhibitionStageLoadSnapshot? detailSnapshot,
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
      summary: '先确认当前验收是否还处于草稿态。只有草稿态会继续放开提交，其余状态保持只读结果承接。',
      tone: _ActionCardTone.emphasis,
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
          const Text('页面摘要已就位，可继续讲解这次验收提交。'),
        ],
        const SizedBox(height: 12),
        _DetailLine(
          label: '当前展示来源',
          value: detailSnapshot?.isDemo == true ? '演示内容' : '已接通内容',
        ),
        if (routeMilestoneId == null) ...<Widget>[
          const SizedBox(height: 12),
          const _EmptyNotice(
            title: '当前不可继续',
            message: '当前没有承接到真实里程碑时，暂时不能继续真实提交；如需演示，可直接使用演示结果继续讲解。',
          ),
        ],
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            FilledButton(
              key: const ValueKey<String>('inspection_submit_button'),
              onPressed: _submitting || !canSubmit ? null : _submit,
              child: const Text('提交验收'),
            ),
            FilledButton.tonal(
              onPressed: _submitting ? null : _applyDemoResult,
              child: const Text('使用演示结果继续讲解'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_submitting)
          const _SubmittingPanel()
        else if (_actionResult != null) ...<Widget>[
          _SubmissionResultPanel(result: _actionResult!),
          if (_actionResult!.isSuccess) ...<Widget>[
            const SizedBox(height: 16),
            _buildSubmittedResultCard(routeMilestoneId),
          ],
        ],
      ],
    );
  }

  Widget _buildSubmittedResultCard(String? routeMilestoneId) {
    final actionPayload = _payloadMap(_actionResult!.payload);
    final actionInspectionId = _inspectionIdFromPayload(_actionResult!.payload);
    final actionMilestoneId =
        _normalizeId(actionPayload?['milestoneId'] as String?) ??
        routeMilestoneId;
    final actionState = _stateFromPayload(_actionResult!.payload);
    final actionSummary = actionPayload?['summary'];

    return _ActionCard(
      title: '已提交验收结果',
      summary: _actionOrigin == ExhibitionStageDataOrigin.demo
          ? '当前页面先承接演示提交结果，帮助客户继续看已提交态界面，不代表真实提交链路已通。'
          : '当前页面只承接后端返回的已提交结果，不额外扩展新的继续链路。',
      children: <Widget>[
        if (_actionOrigin == ExhibitionStageDataOrigin.demo)
          const _EmptyNotice(
            title: '当前展示：演示内容',
            message: '当前已提交结果只用于继续讲解当前界面，真实链路恢复后会自动切回已接通内容。',
          )
        else
          const Text('当前页面只承接后端返回的已提交结果。'),
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
          _DetailLine(
            label: '当前状态',
            value: _frontStageStateLabel(actionState),
            highlight: true,
          ),
        ],
        if (actionSummary is Map)
          const _DetailLine(label: '当前说明', value: '验收已提交完成，页面继续保留当前结果承接。'),
        if (actionState == 'submitted') ...<Widget>[
          const SizedBox(height: 12),
          const _EmptyNotice(
            title: '当前冻结',
            message: '验收复检链路当前阶段不开放，页面先停留在只读结果面。',
          ),
        ],
      ],
    );
  }
}
