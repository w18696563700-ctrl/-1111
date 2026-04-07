part of '../exhibition_trade_pages.dart';

class ContractConfirmPage extends StatefulWidget {
  const ContractConfirmPage({super.key, this.orderId});

  final String? orderId;

  @override
  State<ContractConfirmPage> createState() => _ContractConfirmPageState();
}

class _ContractConfirmPageState extends State<ContractConfirmPage> {
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
    final contractId = _contractIdFromPayload(_detailSnapshot?.result.payload);
    if (contractId == null) {
      setState(() {
        _actionResult = ExhibitionActionResult(
          method: 'POST',
          path: ExhibitionCanonicalPaths.contractConfirm,
          isSuccess: false,
          controlledState: AppPageState.errorNonRetryable,
          message: 'contractId is required from contract detail before confirm',
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

    final result = await ExhibitionConsumerLayer.instance.confirmContract(
      ContractConfirmCommand(contractId: contractId),
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
      _actionResult = ExhibitionStageDemoCatalog.contractConfirm(
        contractId: contractId,
        orderId: orderId,
      );
      _actionOrigin = ExhibitionStageDataOrigin.demo;
    });
  }

  @override
  Widget build(BuildContext context) {
    final routeOrderId = _normalizeId(widget.orderId);
    final detailSnapshot = _detailSnapshot;
    final detailResult = detailSnapshot?.result;
    final displayPayload = _actionResult?.payload ?? detailResult?.payload;
    final contractId = _contractIdFromPayload(displayPayload);
    final contractState = _stateFromPayload(displayPayload);
    final detailSummary = _payloadMap(displayPayload)?['summary'];
    final canSubmit =
        detailResult?.state == AppPageState.content &&
        contractId != null &&
        contractState == 'pending_confirm' &&
        detailSnapshot?.isDemo != true;
    final currentStateMessage = switch (contractState) {
      'pending_confirm' => '当前状态：合同已进入待确认阶段，可以继续完成这次确认。',
      'active' => '当前状态：合同已经生效，当前页改为只读承接。',
      'amended' => '当前状态：合同已经完成改单，当前页保留结果说明。',
      _ when detailSnapshot?.isDemo == true =>
        '当前状态：正在查看演示内容，可先用演示结果继续讲解确认后的页面样子。',
      _ when detailResult?.state == AppPageState.content =>
        '当前状态：合同详情已经承接完成，是否允许确认以后端返回为准。',
      _ => '当前状态：需要先拿到合同详情，才能判断这一步是否继续。',
    };
    final actionMessage = switch (contractState) {
      'pending_confirm' when canSubmit =>
        '当前动作：确认完成后，合同会进入已生效结果承接，并自然回到订单与合同主线。',
      'active' => '当前动作：合同已经生效，当前页保持只读承接，不再继续放开确认提交。',
      'amended' => '当前动作：当前合同已进入改单结果承接，确认动作保持冻结。',
      _ when detailSnapshot?.isDemo == true =>
        '当前动作：真实承接还没稳定到位，你可以先用演示结果继续讲解当前页面。',
      _ when detailResult?.state == AppPageState.content =>
        '当前动作：当前页保持只读承接，请以后端返回结果为准。',
      _ => '当前动作：暂时不能继续确认，请先恢复当前合同详情承接。',
    };
    final continueMessage = _actionResult?.isSuccess == true
        ? '提交后如何继续：页面会停留在已确认结果面，方便继续讲解合同与订单关系。'
        : switch (contractState) {
            'pending_confirm' =>
              '提交后如何继续：确认成功后，会保留当前合同与订单的最小结果承接，再继续回看合同详情或订单工作台。',
            'active' => '提交后如何继续：当前合同已经确认完成，这一页保持只读承接。',
            'amended' => '提交后如何继续：合同已进入改单结果承接，当前页不扩展更多合同流程。',
            _ => '提交后如何继续：当前页保持受控承接，不扩成签署、法务或历史台。',
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
        title: '合同确认',
        summary: '这里确认当前合同是否正式生效。页面会先把合同状态讲清楚，再给出可继续动作和后续承接，不再像命令回执页。',
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
      _buildConfirmOverviewCard(
        routeOrderId: routeOrderId,
        contractId: contractId,
        contractState: contractState,
        detailSummary: detailSummary,
        canSubmit: canSubmit,
        currentStateMessage: currentStateMessage,
        actionMessage: actionMessage,
        continueMessage: continueMessage,
      ),
      const SizedBox(height: 16),
      _buildConfirmActionCard(context, routeOrderId, detailSnapshot),
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

  Widget _buildConfirmOverviewCard({
    required String? routeOrderId,
    required String? contractId,
    required String? contractState,
    required Object? detailSummary,
    required bool canSubmit,
    required String currentStateMessage,
    required String actionMessage,
    required String continueMessage,
  }) {
    return _ActionCard(
      title: '确认前先看',
      summary: '先确认当前合同是否仍在待确认阶段，再决定现在是继续确认、保持只读，还是先停留在演示说明。',
      tone: _ActionCardTone.emphasis,
      children: <Widget>[
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            FilledButton(
              key: const ValueKey<String>('contract_confirm_submit_button'),
              onPressed: _submitting || !canSubmit ? null : _submit,
              child: const Text('提交'),
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
        if (_actionResult != null) ...<Widget>[
          _SubmissionResultPanel(result: _actionResult!),
          const SizedBox(height: 16),
        ],
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
        if (_actionResult?.isSuccess == true &&
            _payloadMap(_actionResult!.payload)?['summary'] is Map) ...<Widget>[
          const SizedBox(height: 12),
          const _DetailLine(label: '页面摘要', value: '当前确认结果已经准备好，可继续讲解后续承接。'),
        ],
      ],
    );
  }

  Widget _buildConfirmActionCard(
    BuildContext context,
    String? routeOrderId,
    ExhibitionStageLoadSnapshot? detailSnapshot,
  ) {
    return _ActionCard(
      title: '确认动作',
      summary: '确认成功后，页面会自然承接到“已确认”结果，并保留回看合同详情与订单工作台的入口。',
      children: <Widget>[
        const _DetailLine(label: '这一步在确认什么', value: '确认当前合同正式生效，并与订单主线保持一致。'),
        const _DetailLine(label: '当前不放开什么', value: '不展开签署流程、法务审核、历史报表或评分链路。'),
        if (routeOrderId == null) ...<Widget>[
          const SizedBox(height: 12),
          const _EmptyNotice(
            title: '当前不可继续',
            message: '当前还没有承接到订单实例时，不能继续合同确认。请先回到订单工作台或合同详情重新进入。',
          ),
        ],
        if (detailSnapshot?.isDemo == true) ...<Widget>[
          const SizedBox(height: 12),
          const _EmptyNotice(
            title: '当前展示：演示内容',
            message: '当前页面正在用演示内容继续讲解，方便连续展示，但不代表真实确认接口已经打通。',
          ),
        ],
        const SizedBox(height: 16),
        if (_submitting)
          const _SubmittingPanel()
        else if (_actionResult != null) ...<Widget>[
          _SubmissionResultPanel(result: _actionResult!),
          if (_actionResult!.isSuccess) ...<Widget>[
            const SizedBox(height: 16),
            _buildConfirmedResultCard(context),
          ],
        ],
      ],
    );
  }

  Widget _buildConfirmedResultCard(BuildContext context) {
    final actionPayload = _actionResult!.payload;
    final orderId = _orderIdFromPayload(actionPayload);
    final confirmedContractId = _contractIdFromPayload(actionPayload);
    final actionState = _stateFromPayload(actionPayload);
    final actionSummary = _payloadMap(actionPayload)?['summary'];

    return _ActionCard(
      title: '合同已确认',
      summary: _actionOrigin == ExhibitionStageDataOrigin.demo
          ? '当前结果来自演示内容，适合继续讲解合同生效后的页面状态。'
          : '当前结果已经进入已确认承接面，可以继续回看合同详情或订单工作台。',
      tone: _ActionCardTone.emphasis,
      children: <Widget>[
        if (orderId != null)
          _InstanceSummaryLine(title: '当前订单 ID', value: orderId),
        if (confirmedContractId != null) ...<Widget>[
          const SizedBox(height: 12),
          _InstanceSummaryLine(title: '当前合同 ID', value: confirmedContractId),
        ],
        if (actionState != null) ...<Widget>[
          const SizedBox(height: 12),
          Text('当前业务状态：${_frontStageStateLabel(actionState)}'),
        ],
        if (actionSummary is Map) ...<Widget>[
          const SizedBox(height: 12),
          const _DetailLine(label: '页面摘要', value: '当前确认结果已经准备好，可继续讲解后续承接。'),
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
