part of '../exhibition_trade_pages.dart';

class DisputeWithdrawPage extends StatefulWidget {
  const DisputeWithdrawPage({super.key, this.disputeId, this.orderId});

  final String? disputeId;
  final String? orderId;

  @override
  State<DisputeWithdrawPage> createState() => _DisputeWithdrawPageState();
}

class _DisputeWithdrawPageState extends State<DisputeWithdrawPage> {
  bool _submitting = false;
  ExhibitionActionResult? _lastResult;

  @override
  void initState() {
    super.initState();
    if (_normalizeId(widget.disputeId) == null) {
      _lastResult = ExhibitionActionResult(
        method: 'POST',
        path: ExhibitionCanonicalPaths.disputeWithdraw,
        isSuccess: false,
        controlledState: AppPageState.notFound,
        message:
            'disputeId is required from route context before dispute withdraw',
      );
    }
  }

  Future<void> _submit() async {
    final disputeId = _normalizeId(widget.disputeId);
    if (disputeId == null) {
      setState(() {
        _lastResult = ExhibitionActionResult(
          method: 'POST',
          path: ExhibitionCanonicalPaths.disputeWithdraw,
          isSuccess: false,
          controlledState: AppPageState.notFound,
          message:
              'disputeId is required from route context before dispute withdraw',
        );
      });
      return;
    }

    setState(() {
      _submitting = true;
      _lastResult = null;
    });

    final result = await ExhibitionConsumerLayer.instance.withdrawDispute(
      DisputeWithdrawCommand(disputeId: disputeId),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _submitting = false;
      _lastResult = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final routeDisputeId = _normalizeId(widget.disputeId);
    final routeOrderId = _normalizeId(widget.orderId);
    final resultState = _stateFromPayload(_lastResult?.payload);
    final resultSummary = _payloadMap(_lastResult?.payload)?['summary'];
    final isWithdrawnSuccess =
        _lastResult?.isSuccess == true && resultState == 'withdrawn';
    final currentStateMessage = switch (resultState) {
      'withdrawn' => '当前状态：争议已经撤回完成，这一页保留最小撤回结果承接。',
      _ when routeDisputeId != null && _lastResult == null =>
        '当前状态：已承接争议上下文，正在等待本次撤回动作。',
      _ when routeDisputeId != null => '当前状态：本次撤回结果已返回，是否还能继续以后端结果为准。',
      _ => '当前状态：缺少 disputeId，上下文不足以继续撤回争议。',
    };
    final actionMessage = switch ((routeDisputeId, isWithdrawnSuccess)) {
      (_, true) => '当前动作：争议撤回已完成，页面停留在只读结果页，不再继续暴露新的操作。',
      (final String _, false) => '当前动作：可以继续撤回争议；页面不会本地补做资格、范围或治理判断。',
      _ => '当前动作：当前不可继续，请先恢复争议上下文。',
    };

    return _SubmissionPageFrame(
      title: '争议撤回入口',
      summary:
          '这里只做最小争议撤回动作和受控反馈，只消费 disputeId、orderId、state、summary，不扩成 detail、history、resolution、escalation 或治理台。',
      canonicalPath: ExhibitionCanonicalPaths.disputeWithdraw,
      submitting: _submitting,
      lastResult: _lastResult,
      onSubmitPressed: _submit,
      submitButtonKey: const ValueKey<String>('dispute_withdraw_submit_button'),
      showConnectionInfo: false,
      showTechnicalDisclosure: false,
      resultSectionsBuilder: (ExhibitionActionResult result) {
        final disputeId =
            _disputeIdFromPayload(result.payload) ?? routeDisputeId;
        final orderId = _orderIdFromPayload(result.payload) ?? routeOrderId;
        if (!result.isSuccess || disputeId == null) {
          return const <Widget>[];
        }

        return <Widget>[
          const SizedBox(height: 16),
          _ActionCard(
            title: '已撤回结果',
            children: <Widget>[
              _InstanceSummaryLine(title: '当前争议 ID', value: disputeId),
              if (orderId != null) ...<Widget>[
                const SizedBox(height: 12),
                _InstanceSummaryLine(title: '当前订单 ID', value: orderId),
              ],
              if (resultState != null) ...<Widget>[
                const SizedBox(height: 12),
                Text('当前业务状态：${_frontStageStateLabel(resultState)}'),
              ],
              if (resultSummary is Map) ...<Widget>[
                const SizedBox(height: 12),
                const Text('摘要承接：已承接最小 summary'),
              ],
            ],
          ),
          const SizedBox(height: 16),
          _ActionCard(
            title: '提交后如何继续',
            children: <Widget>[
              const Text('争议撤回已完成，页面停留在只读结果承接，不继续暴露协商、平台审理、升级、裁决、详情或治理台动作。'),
            ],
          ),
        ];
      },
      body: <Widget>[
        Text(currentStateMessage),
        const SizedBox(height: 8),
        Text(actionMessage),
        const SizedBox(height: 12),
        if (routeDisputeId != null)
          _InstanceSummaryLine(title: '当前争议 ID', value: routeDisputeId),
      ],
    );
  }
}
