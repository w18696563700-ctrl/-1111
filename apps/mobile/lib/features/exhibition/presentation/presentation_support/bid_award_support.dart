part of '../exhibition_trade_pages.dart';

class _BidAwardEntrySheet extends StatefulWidget {
  const _BidAwardEntrySheet({
    required this.projectId,
    required this.onRefreshAccepted,
  });

  final String projectId;
  final Future<void> Function() onRefreshAccepted;

  @override
  State<_BidAwardEntrySheet> createState() => _BidAwardEntrySheetState();
}

class _BidAwardEntrySheetState extends State<_BidAwardEntrySheet> {
  final TextEditingController _winningBidIdController = TextEditingController();
  final TextEditingController _reasonCodeController = TextEditingController();
  final TextEditingController _reasonTextController = TextEditingController();

  bool _submitting = false;
  ExhibitionActionResult? _lastResult;

  @override
  void dispose() {
    _winningBidIdController.dispose();
    _reasonCodeController.dispose();
    _reasonTextController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final winningBidId = _winningBidIdController.text.trim();
    final reasonCode = _reasonCodeController.text.trim();
    final reasonText = _reasonTextController.text.trim();

    if (winningBidId.isEmpty) {
      _setLocalFailure('请先填写中标投标 ID，再继续定标。');
      return;
    }
    if (reasonCode.isEmpty) {
      _setLocalFailure('请先填写定标原因编码，再继续定标。');
      return;
    }
    if (reasonText.isEmpty) {
      _setLocalFailure('请先填写定标原因说明，再继续定标。');
      return;
    }

    setState(() {
      _submitting = true;
      _lastResult = null;
    });

    final result = await ExhibitionConsumerLayer.instance.awardBid(
      BidAwardCommand(
        projectId: widget.projectId,
        winningBidId: winningBidId,
        reasonCode: reasonCode,
        reasonText: reasonText,
      ),
    );

    if (result.isSuccess) {
      final projectId = _projectIdFromPayload(result.payload) ?? widget.projectId;
      await Future.wait<void>(<Future<void>>[
        ExhibitionConsumerLayer.instance.loadProjectDetail(
          projectId: projectId,
          forceRefresh: true,
        ),
        ExhibitionConsumerLayer.instance.loadMyProjectList(forceRefresh: true),
        widget.onRefreshAccepted(),
      ]);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _submitting = false;
      _lastResult = result;
    });
  }

  void _setLocalFailure(String message) {
    setState(() {
      _lastResult = ExhibitionActionResult(
        method: 'POST',
        path: ExhibitionCanonicalPaths.bidAward,
        isSuccess: false,
        controlledState: AppPageState.errorNonRetryable,
        message: message,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const _ActionCard(
                title: '最小定标承接',
                summary: '这里只收口当前 bridge 必需的最小定标参数，不扩成 compare board、订单控制台或合同种子控制台。',
                tone: _ActionCardTone.emphasis,
                children: <Widget>[
                  _DetailLine(label: '当前页面边界', value: '只提交 projectId、winningBidId、reasonCode、reasonText。'),
                ],
              ),
              const SizedBox(height: 16),
              _ActionCard(
                title: '当前项目',
                children: <Widget>[
                  _InstanceSummaryLine(title: '当前项目 ID', value: widget.projectId),
                  const SizedBox(height: 12),
                  const _StateMessage(
                    title: '当前动作',
                    body: '定标成功后只承接 bridge 返回的最小 continuation anchors，并同步刷新项目详情与我的项目。',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _ActionCard(
                title: '填写最小定标参数',
                children: <Widget>[
                  _InputField(
                    controller: _winningBidIdController,
                    label: '中标投标 ID',
                    hintText: '例如：bid-winning',
                    helperText: '填写当前应被定标为 winner 的投标 ID。',
                  ),
                  _InputField(
                    controller: _reasonCodeController,
                    label: '定标原因编码',
                    hintText: '例如：commercial_fit',
                    helperText: '填写当前最小原因编码。',
                  ),
                  _InputField(
                    controller: _reasonTextController,
                    label: '定标原因说明',
                    maxLines: 3,
                    hintText: '例如：综合报价与交付能力最优',
                    helperText: '填写最小定标原因说明。',
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    key: const ValueKey<String>('bid_award_submit_button'),
                    onPressed: _submitting ? null : _submit,
                    child: const Text('继续最小定标'),
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
                  _buildBidAwardAcceptedSection(_lastResult!),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBidAwardAcceptedSection(ExhibitionActionResult result) {
    final payload = _payloadMap(result.payload);
    final bidAwardId = _bidAwardIdFromPayload(result.payload);
    final projectId = _projectIdFromPayload(result.payload) ?? widget.projectId;
    final winningBidId = _normalizeId(payload?['winningBidId'] as String?);
    final orderId = _orderIdFromPayload(result.payload);
    final contractId = _contractIdFromPayload(result.payload);
    final state = _stateFromPayload(result.payload);

    return _ActionCard(
      title: '定标桥接已承接',
      summary: '当前页只展示 bridge accepted response，不把返回结果扩成订单、合同或第二套续接真相页。',
      tone: _ActionCardTone.emphasis,
      children: <Widget>[
        if (bidAwardId != null)
          _InstanceSummaryLine(title: '当前定标 ID', value: bidAwardId),
        const SizedBox(height: 12),
        _InstanceSummaryLine(title: '当前项目 ID', value: projectId),
        if (winningBidId != null) ...<Widget>[
          const SizedBox(height: 12),
          _InstanceSummaryLine(title: '当前中标投标 ID', value: winningBidId),
        ],
        if (orderId != null) ...<Widget>[
          const SizedBox(height: 12),
          _InstanceSummaryLine(title: '当前订单 ID', value: orderId),
        ],
        if (contractId != null) ...<Widget>[
          const SizedBox(height: 12),
          _InstanceSummaryLine(title: '当前合同 ID', value: contractId),
        ],
        if (state != null) ...<Widget>[
          const SizedBox(height: 12),
          _DetailLine(
            label: '当前状态',
            value: _frontStageStateLabel(state),
            highlight: true,
          ),
        ],
      ],
    );
  }
}
