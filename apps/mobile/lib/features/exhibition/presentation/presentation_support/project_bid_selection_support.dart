part of '../exhibition_trade_pages.dart';

extension _ProjectBidSelectionSupport on _ProjectDetailPageState {
  Widget _buildOwnerBidSelectionCard({
    required String projectId,
    required String? state,
    required Map<String, Object?> projectMap,
  }) {
    final candidates = _ProjectBidCandidate.fromProjectMap(projectMap);
    final selection = _ProjectBidSelectionState.fromProjectMap(projectMap);
    final canSelect = _canSelectProjectBid(state, selection);

    return _ActionCard(
      title: '竞标候选与合作确认',
      tone: canSelect ? _ActionCardTone.emphasis : _ActionCardTone.muted,
      children: <Widget>[
        if (selection != null) ...<Widget>[
          if (selection.winningBidId != null)
            const _DetailLine(label: '已选竞标', value: '已选择'),
          if (selection.orderId != null)
            const _DetailLine(label: '后续承接锚点', value: '已生成'),
          if (selection.contractId != null)
            const _DetailLine(label: '合同承接锚点', value: '已生成'),
        ],
        const SizedBox(height: 12),
        if (candidates.isEmpty)
          const _EmptyNotice(title: '暂无竞标工厂', message: '工厂提交竞标后，会在这里显示报价和方案。')
        else
          ..._buildBidCandidateCards(
            projectId: projectId,
            candidates: candidates,
            canSelect: canSelect,
          ),
      ],
    );
  }

  List<Widget> _buildBidCandidateCards({
    required String projectId,
    required List<_ProjectBidCandidate> candidates,
    required bool canSelect,
  }) {
    final widgets = <Widget>[];
    for (final candidate in candidates) {
      if (widgets.isNotEmpty) {
        widgets.add(const SizedBox(height: 12));
      }
      widgets.add(
        _EntityCard(
          title: candidate.bidderTitle,
          description: _bidCandidateSummaryText(candidate),
          statusLabel: candidate.stateLabel,
          detailLines: <Widget>[
            if (candidate.quoteAmount != null)
              _DetailLine(
                label: '竞标报价',
                value: _currencyText(candidate.quoteAmount),
                highlight: true,
              ),
            if (candidate.submittedAt != null)
              _DetailLine(label: '提交时间', value: candidate.submittedAt!),
          ],
          actionLabel: canSelect ? '选择合作方并生成承接锚点' : null,
          onPressed: canSelect
              ? () => _showBidSelectionConfirmSheet(
                  projectId: projectId,
                  candidate: candidate,
                )
              : null,
          secondaryActionLabel: '进入沟通',
          onSecondaryPressed: () => _openBidCandidateThread(
            projectId: projectId,
            bidId: candidate.bidId,
          ),
        ),
      );
    }
    return widgets;
  }

  String _bidCandidateSummaryText(_ProjectBidCandidate candidate) {
    final summary = candidate.proposalSummary;
    if (summary == null || summary.trim().isEmpty) {
      return '竞标方已提交报价方案，建议先沟通核对资料与报价。';
    }
    final normalized = summary.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.length <= 72) {
      return normalized;
    }
    return '${normalized.substring(0, 72)}...';
  }

  void _openBidCandidateThread({
    required String projectId,
    required String bidId,
  }) {
    Navigator.of(context).pushNamed(
      ExhibitionRoutes.bidThreadWithIds(projectId: projectId, bidId: bidId),
    );
  }

  void _showBidSelectionConfirmSheet({
    required String projectId,
    required _ProjectBidCandidate candidate,
  }) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return _ProjectBidSelectionSheet(
          projectId: projectId,
          candidate: candidate,
          onAccepted: () async {
            await Future.wait<void>(<Future<void>>[
              _load(forceRefresh: true),
              ExhibitionConsumerLayer.instance.loadMyProjectList(
                forceRefresh: true,
              ),
            ]);
          },
        );
      },
    );
  }

  bool _canSelectProjectBid(
    String? state,
    _ProjectBidSelectionState? selection,
  ) {
    return state == 'published' && selection?.orderId == null;
  }
}

class _ProjectBidSelectionSheet extends StatefulWidget {
  const _ProjectBidSelectionSheet({
    required this.projectId,
    required this.candidate,
    required this.onAccepted,
  });

  final String projectId;
  final _ProjectBidCandidate candidate;
  final Future<void> Function() onAccepted;

  @override
  State<_ProjectBidSelectionSheet> createState() =>
      _ProjectBidSelectionSheetState();
}

class _ProjectBidSelectionSheetState extends State<_ProjectBidSelectionSheet> {
  final TextEditingController _reasonTextController = TextEditingController();
  bool _submitting = false;
  ExhibitionActionResult? _lastResult;

  @override
  void initState() {
    super.initState();
    _reasonTextController.text = '发布方确认与该竞标方继续合作，并生成后续订单/合同承接锚点。';
  }

  @override
  void dispose() {
    _reasonTextController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final reasonText = _reasonTextController.text.trim();
    if (reasonText.isEmpty) {
      _setLocalFailure('请先填写选择合作方原因说明。');
      return;
    }

    setState(() {
      _submitting = true;
      _lastResult = null;
    });

    final result = await ExhibitionConsumerLayer.instance.awardBid(
      BidAwardCommand(
        projectId: widget.projectId,
        winningBidId: widget.candidate.bidId,
        reasonCode: 'publisher_selected_partner',
        reasonText: reasonText,
      ),
    );

    if (result.isSuccess) {
      await widget.onAccepted();
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
              _ActionCard(
                title: '发起合作确认',
                summary: '确认后将生成后续订单/合同承接锚点；这不等于成交成立。',
                tone: _ActionCardTone.emphasis,
                children: <Widget>[
                  const _InstanceSummaryLine(title: '项目记录', value: '已承接'),
                  const SizedBox(height: 10),
                  const _InstanceSummaryLine(title: '竞标记录', value: '已选择'),
                  if (widget.candidate.bidderOrganizationName !=
                      null) ...<Widget>[
                    const SizedBox(height: 10),
                    _DetailLine(
                      label: '候选主体',
                      value: widget.candidate.bidderOrganizationName!,
                    ),
                  ],
                  if (widget.candidate.quoteAmount != null)
                    _DetailLine(
                      label: '竞标报价',
                      value: _currencyText(widget.candidate.quoteAmount),
                      highlight: true,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              _ActionCard(
                title: '选择原因',
                children: <Widget>[
                  _InputField(
                    controller: _reasonTextController,
                    label: '原因说明',
                    maxLines: 3,
                    helperText: '原因将随本次合作确认提交并留痕。',
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    key: const ValueKey<String>('project_bid_select_submit'),
                    onPressed: _submitting ? null : _submit,
                    icon: const Icon(Icons.handshake_rounded),
                    label: Text(
                      _submitting ? '提交中...' : '选择合作方并生成承接锚点',
                    ),
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
                  _buildAcceptedSection(_lastResult!),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAcceptedSection(ExhibitionActionResult result) {
    final payload = _payloadMap(result.payload);
    final orderId = _orderIdFromPayload(result.payload);
    final contractId = _contractIdFromPayload(result.payload);
    final winningBidId = _normalizeId(payload?['winningBidId'] as String?);
    return _ActionCard(
      title: '合作确认已受理',
      summary: '后续请按返回的承接入口继续确认；本页不展开完整订单工作台。',
      tone: _ActionCardTone.emphasis,
      children: <Widget>[
        if (winningBidId != null)
          const _InstanceSummaryLine(title: '已选竞标', value: '已确认'),
        if (orderId != null) ...<Widget>[
          const SizedBox(height: 10),
          const _InstanceSummaryLine(title: '后续承接锚点', value: '已生成'),
        ],
        if (contractId != null) ...<Widget>[
          const SizedBox(height: 10),
          const _InstanceSummaryLine(title: '合同记录', value: '已生成'),
        ],
        if (orderId != null) ...<Widget>[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(
              context,
            ).pushNamed(ExhibitionRoutes.orderDetailWithOrderId(orderId)),
            icon: const Icon(Icons.receipt_long_rounded),
            label: const Text('查看后续承接状态'),
          ),
        ],
      ],
    );
  }
}
