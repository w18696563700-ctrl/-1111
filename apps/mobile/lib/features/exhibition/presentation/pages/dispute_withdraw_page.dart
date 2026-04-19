part of '../exhibition_trade_pages.dart';

class DisputeWithdrawPage extends StatefulWidget {
  const DisputeWithdrawPage({super.key, this.orderId});

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
    if (_normalizeId(widget.orderId) == null) {
      _lastResult = ExhibitionActionResult(
        method: 'POST',
        path: ExhibitionCanonicalPaths.disputeWithdraw,
        isSuccess: false,
        controlledState: AppPageState.notFound,
        message: 'orderId is required from route context before dispute withdraw',
      );
    }
  }

  Future<void> _submit() async {
    final orderId = _normalizeId(widget.orderId);
    if (_submitting || orderId == null) {
      return;
    }

    setState(() {
      _submitting = true;
      _lastResult = null;
    });

    final result = await ExhibitionConsumerLayer.instance.withdrawDispute(
      DisputeWithdrawCommand(orderId: orderId),
    );

    if (result.isSuccess) {
      await ExhibitionConsumerLayer.instance.loadMyProjectList(
        forceRefresh: true,
      );
    }

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
    final routeOrderId = _normalizeId(widget.orderId);
    final disputeId = _normalizeId(
      _payloadMap(_lastResult?.payload)?['disputeId'] as String?,
    );
    final disputeState = _stateFromPayload(_lastResult?.payload);
    final summary = _payloadMap(_lastResult?.payload)?['summary'];

    return _SubmissionPageFrame(
      title: '争议撤回入口',
      summary:
          '这里用于在当前订单下继续争议撤回的最小 shell / handoff。页面只受理当前订单上下文与结果承接，不扩成争议工作台。',
      canonicalPath: ExhibitionCanonicalPaths.disputeWithdraw,
      submitting: _submitting,
      lastResult: _lastResult,
      onSubmitPressed: _submit,
      showSubmitButton: false,
      showConnectionInfo: false,
      body: <Widget>[
        _ActionCard(
          title: '当前能做什么',
          summary: '如果当前订单已承接到可见争议锚点，这里可以继续最小争议撤回。是否真正可撤回仍以后端返回为准。',
          tone: _ActionCardTone.emphasis,
          children: <Widget>[
            _StateMessage(
              title: '当前状态',
              body: routeOrderId == null
                  ? '当前缺少 orderId，页面不能继续执行争议撤回。'
                  : '当前已承接订单上下文，可以继续执行最小争议撤回；页面不会本地补做资格或治理判断。',
            ),
            if (routeOrderId != null) ...<Widget>[
              const SizedBox(height: 12),
              _InstanceSummaryLine(title: '当前订单 ID', value: routeOrderId),
            ],
            const SizedBox(height: 12),
            FilledButton(
              key: const ValueKey<String>('dispute_withdraw_submit_button'),
              onPressed: routeOrderId == null || _submitting ? null : _submit,
              child: const Text('继续争议撤回'),
            ),
          ],
        ),
        if (_submitting) ...<Widget>[
          const SizedBox(height: 16),
          const _SubmittingPanel(),
        ] else if (_lastResult != null) ...<Widget>[
          const SizedBox(height: 16),
          _SubmissionResultPanel(result: _lastResult!),
          if (_lastResult!.isSuccess) ...<Widget>[
            const SizedBox(height: 16),
            _ActionCard(
              title: '争议撤回已受理',
              summary: '当前页承接撤回后的最小结果，并同步刷新我的项目。',
              tone: _ActionCardTone.emphasis,
              children: <Widget>[
                if (routeOrderId != null)
                  _InstanceSummaryLine(title: '当前订单 ID', value: routeOrderId),
                if (disputeId != null) ...<Widget>[
                  const SizedBox(height: 12),
                  _InstanceSummaryLine(title: '当前争议 ID', value: disputeId),
                ],
                if (disputeState != null) ...<Widget>[
                  const SizedBox(height: 12),
                  _DetailLine(
                    label: '当前状态',
                    value: _frontStageStateLabel(disputeState),
                    highlight: true,
                  ),
                ],
                if (summary is Map)
                  const _DetailLine(
                    label: '当前说明',
                    value: '争议撤回已受理；页面已经刷新我的项目缓存。',
                  ),
              ],
            ),
          ],
        ],
        const SizedBox(height: 16),
        const _ActionCard(
          title: '当前边界',
          summary: '这一页只补最小争议撤回，不继续开放争议详情、协商、历史、治理或裁决页面。',
          children: <Widget>[
            _DetailLine(
              label: '这一步会做什么',
              value: '提交当前订单上的最小争议撤回请求，并把结果承接在本页。',
            ),
            _DetailLine(
              label: '这一步不会做什么',
              value: '不会创建争议工作台，也不会展开协商、升级、平台审理或历史列表。',
            ),
          ],
        ),
      ],
    );
  }
}
