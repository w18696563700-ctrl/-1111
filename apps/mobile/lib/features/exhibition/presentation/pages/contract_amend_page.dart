part of '../exhibition_trade_pages.dart';

class ContractAmendPage extends StatefulWidget {
  const ContractAmendPage({super.key, this.orderId});

  final String? orderId;

  @override
  State<ContractAmendPage> createState() => _ContractAmendPageState();
}

class _ContractAmendPageState extends State<ContractAmendPage> {
  late final ExhibitionStageLoadAutoSource _detailSource =
      ExhibitionStageLoadAutoSource(
        futureRealLoader: ({bool forceRefresh = false}) {
          return ExhibitionConsumerLayer.instance.loadContractDetail(
            orderId: widget.orderId,
            forceRefresh: forceRefresh,
          );
        },
        demoBuilder: () =>
            ExhibitionStageDemoCatalog.contractDetail(orderId: widget.orderId),
      );

  final TextEditingController _amendmentSummaryController =
      TextEditingController();

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

  @override
  void dispose() {
    _amendmentSummaryController.dispose();
    super.dispose();
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
    final contractId = _contractIdFromPayload(_detailSnapshot?.result.payload);
    if (contractId == null) {
      setState(() {
        _actionResult = ExhibitionActionResult(
          method: 'POST',
          path: ExhibitionCanonicalPaths.contractAmend,
          isSuccess: false,
          controlledState: AppPageState.errorNonRetryable,
          message: 'contractId is required from contract detail before amend',
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

    final result = await ExhibitionConsumerLayer.instance.amendContract(
      ContractAmendCommand(
        contractId: contractId,
        amendmentSummary: _amendmentSummaryController.text.trim(),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _submitting = false;
      _actionResult = result;
      _actionOrigin = ExhibitionStageDataOrigin.futureReal;
    });
  }

  void _applyDemoResult() {
    final detailPayload = _detailSnapshot?.result.payload;
    final contractId =
        _contractIdFromPayload(detailPayload) ??
        ExhibitionStageDemoCatalog.demoContractId;
    final orderId =
        _orderIdFromPayload(detailPayload) ??
        _normalizeId(widget.orderId) ??
        ExhibitionStageDemoCatalog.demoOrderId;

    setState(() {
      _actionResult = ExhibitionStageDemoCatalog.contractAmend(
        contractId: contractId,
        orderId: orderId,
        amendmentSummary: _amendmentSummaryController.text.trim(),
      );
      _actionOrigin = ExhibitionStageDataOrigin.demo;
    });
  }

  @override
  Widget build(BuildContext context) {
    final routeOrderId = _normalizeId(widget.orderId);
    final detailSnapshot = _detailSnapshot;
    final detailResult = detailSnapshot?.result;
    final contractId = _contractIdFromPayload(detailResult?.payload);
    final contractState = _stateFromPayload(detailResult?.payload);
    final detailSummary = _payloadMap(detailResult?.payload)?['summary'];
    final canSubmit =
        detailResult?.state == AppPageState.content &&
        contractId != null &&
        contractState == 'active' &&
        detailSnapshot?.isDemo != true;
    final currentStateMessage = switch (contractState) {
      'active' => '当前状态：合同已经生效，可以继续补充本次改单说明。',
      'amended' => '当前状态：合同已经产生改单结果，当前页保留结果说明。',
      'pending_confirm' => '当前状态：合同还在待确认，这一页保持只读承接。',
      _ when detailSnapshot?.isDemo == true =>
        '当前状态：正在查看演示内容，可先用演示结果继续讲解改单后的页面样子。',
      _ when detailResult?.state == AppPageState.content =>
        '当前状态：合同详情已经承接完成，是否允许改单以后端返回为准。',
      _ => '当前状态：需要先拿到合同详情，才能判断这一步是否继续。',
    };
    final actionMessage = switch (contractState) {
      'active' when canSubmit => '当前动作：可以继续提交改单说明；提交完成后，页面会停留在当前合同的已改单结果面。',
      'amended' => '当前动作：合同已经改单，当前页保持只读承接，不再继续放开改单提交。',
      'pending_confirm' => '当前动作：合同仍待确认，需先完成确认后才能进入改单。',
      _ when detailSnapshot?.isDemo == true =>
        '当前动作：真实承接还没稳定到位，你可以先用演示结果继续讲解当前页面。',
      _ when detailResult?.state == AppPageState.content =>
        '当前动作：当前页保持只读承接，请以后端返回结果为准。',
      _ => '当前动作：暂时不能继续改单，请先恢复当前合同详情承接。',
    };
    final continueMessage = _actionResult?.isSuccess == true
        ? '提交后如何继续：页面会停留在已改单结果面，方便继续讲解合同与订单关系。'
        : switch (contractState) {
            'active' => '提交后如何继续：改单成功后，会保留当前合同与订单的最小结果承接，再继续回看合同详情或订单工作台。',
            'amended' => '提交后如何继续：当前合同已经进入已改单结果承接，这一页保持只读。',
            'pending_confirm' => '提交后如何继续：当前需先回到合同确认，再决定是否进入改单。',
            _ => '提交后如何继续：当前页保持受控承接，不扩成条款编辑、法务或历史台。',
          };

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: _buildPageChildren(
        context,
        routeOrderId: routeOrderId,
        detailSnapshot: detailSnapshot,
        detailResult: detailResult,
        contractId: contractId,
        contractState: contractState,
        detailSummary: detailSummary,
        canSubmit: canSubmit,
        currentStateMessage: currentStateMessage,
        actionMessage: actionMessage,
        continueMessage: continueMessage,
      ),
    );
  }

  List<Widget> _buildPageChildren(
    BuildContext context, {
    required String? routeOrderId,
    required ExhibitionStageLoadSnapshot? detailSnapshot,
    required ExhibitionLoadResult? detailResult,
    required String? contractId,
    required String? contractState,
    required Object? detailSummary,
    required bool canSubmit,
    required String currentStateMessage,
    required String actionMessage,
    required String continueMessage,
  }) {
    return <Widget>[
      const _SummaryCard(
        title: '合同改单',
        summary: '这里承接当前合同的改单动作。页面会先讲清合同现在是否允许改单，再收口成一个可提交、可查看结果、可继续讲解的产品页。',
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
      _buildAmendOverviewCard(
        routeOrderId: routeOrderId,
        contractId: contractId,
        contractState: contractState,
        detailSummary: detailSummary,
        currentStateMessage: currentStateMessage,
        actionMessage: actionMessage,
        continueMessage: continueMessage,
      ),
      const SizedBox(height: 16),
      _buildAmendActionCard(context, routeOrderId, detailSnapshot, canSubmit),
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

  Widget _buildAmendOverviewCard({
    required String? routeOrderId,
    required String? contractId,
    required String? contractState,
    required Object? detailSummary,
    required String currentStateMessage,
    required String actionMessage,
    required String continueMessage,
  }) {
    return _ActionCard(
      title: '改单前先看',
      summary: '先确认当前合同是否已经生效。只有已生效合同会继续放开改单说明，其余状态保持只读结果承接。',
      tone: _ActionCardTone.emphasis,
      children: <Widget>[
        _StateMessage(title: '当前状态', body: currentStateMessage),
        const SizedBox(height: 12),
        _StateMessage(title: '当前动作', body: actionMessage),
        const SizedBox(height: 12),
        _StateMessage(title: '后续如何继续', body: continueMessage),
        if (routeOrderId != null) ...<Widget>[
          const SizedBox(height: 12),
          _InstanceSummaryLine(title: '当前订单 ID', value: routeOrderId),
        ],
        if (contractId != null) ...<Widget>[
          const SizedBox(height: 12),
          _InstanceSummaryLine(title: '当前合同 ID', value: contractId),
        ],
        if (contractState != null) ...<Widget>[
          const SizedBox(height: 12),
          Text('当前业务状态：${_frontStageStateLabel(contractState)}'),
        ],
        if (detailSummary is Map) ...<Widget>[
          const SizedBox(height: 12),
          const _DetailLine(label: '页面摘要', value: '当前合同重点已经准备好，可继续讲解这一步。'),
        ],
      ],
    );
  }

  Widget _buildAmendActionCard(
    BuildContext context,
    String? routeOrderId,
    ExhibitionStageLoadSnapshot? detailSnapshot,
    bool canSubmit,
  ) {
    return _ActionCard(
      title: '改单说明',
      summary: '用一段简洁说明告诉客户这次调整的重点。提交成功后，页面会自然承接到已改单结果面。',
      children: <Widget>[
        _InputField(
          controller: _amendmentSummaryController,
          label: '改单说明',
          fieldKey: const ValueKey<String>('contract_amend_summary_field'),
          maxLines: 3,
          hintText: '例如：本轮调整灯光回路与材料清单',
          helperText: '用于说明这次合同调整的范围和重点。',
        ),
        const _DetailLine(
          label: '当前不放开什么',
          value: '不展开条款编辑器、签署流程、法务审核、历史台或评价主链。',
        ),
        if (routeOrderId == null) ...<Widget>[
          const SizedBox(height: 12),
          const _EmptyNotice(
            title: '当前不可继续',
            message: '当前还没有承接到订单实例时，不能继续合同改单。请先回到订单工作台或合同详情重新进入。',
          ),
        ],
        if (detailSnapshot?.isDemo == true) ...<Widget>[
          const SizedBox(height: 12),
          const _EmptyNotice(
            title: '当前展示：演示内容',
            message: '当前页面正在用演示内容继续讲解，方便连续展示，但不代表真实改单接口已经打通。',
          ),
        ],
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            FilledButton(
              key: const ValueKey<String>('contract_amend_submit_button'),
              onPressed: _submitting || !canSubmit ? null : _submit,
              child: const Text('提交改单说明'),
            ),
            FilledButton.tonal(
              onPressed: _submitting ? null : _applyDemoResult,
              child: const Text('使用演示结果继续讲解'),
            ),
            FilledButton.tonal(
              onPressed: _submitting ? null : () => _load(forceRefresh: true),
              child: const Text('重新加载合同'),
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
            _buildAmendedResultCard(context),
          ],
        ],
      ],
    );
  }

  Widget _buildAmendedResultCard(BuildContext context) {
    final actionPayload = _actionResult!.payload;
    final orderId = _orderIdFromPayload(actionPayload);
    final amendedContractId = _contractIdFromPayload(actionPayload);
    final actionState = _stateFromPayload(actionPayload);
    final actionSummary = _payloadMap(actionPayload)?['summary'];

    return _ActionCard(
      title: '合同已改单',
      summary: _actionOrigin == ExhibitionStageDataOrigin.demo
          ? '当前结果来自演示内容，适合继续讲解改单后的页面状态。'
          : '当前结果已经进入已改单承接面，可以继续回看合同详情或订单工作台。',
      tone: _ActionCardTone.emphasis,
      children: <Widget>[
        if (orderId != null)
          _InstanceSummaryLine(title: '当前订单 ID', value: orderId),
        if (amendedContractId != null) ...<Widget>[
          const SizedBox(height: 12),
          _InstanceSummaryLine(title: '当前合同 ID', value: amendedContractId),
        ],
        if (actionState != null) ...<Widget>[
          const SizedBox(height: 12),
          Text('当前业务状态：${_frontStageStateLabel(actionState)}'),
        ],
        if (actionSummary is Map) ...<Widget>[
          const SizedBox(height: 12),
          const _DetailLine(label: '页面摘要', value: '当前改单结果已经准备好，可继续讲解后续承接。'),
        ],
        if (orderId != null) ...<Widget>[
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              FilledButton.tonal(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushNamed(ExhibitionRoutes.orderDetailWithOrderId(orderId));
                },
                child: const Text('回到订单工作台'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    ExhibitionRoutes.contractDetailWithOrderId(orderId),
                  );
                },
                child: const Text('回看合同详情'),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
