part of '../exhibition_trade_pages.dart';

Future<void> _showBidSubmissionSnapshotSheet(
  BuildContext context, {
  required String? projectId,
  required String? bidId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => FractionallySizedBox(
      heightFactor: 0.88,
      child: _BidSubmissionSnapshotSheet(projectId: projectId, bidId: bidId),
    ),
  );
}

class _BidSubmissionSnapshotSheet extends StatefulWidget {
  const _BidSubmissionSnapshotSheet({
    required this.projectId,
    required this.bidId,
  });

  final String? projectId;
  final String? bidId;

  @override
  State<_BidSubmissionSnapshotSheet> createState() =>
      _BidSubmissionSnapshotSheetState();
}

class _BidSubmissionSnapshotSheetState
    extends State<_BidSubmissionSnapshotSheet> {
  TradingImResult<BidSubmissionSnapshotView>? _result;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await TradingImConsumerLayer.instance
        .loadBidSubmissionSnapshot(
          projectId: widget.projectId,
          bidId: widget.bidId,
        );
    if (!mounted) {
      return;
    }
    setState(() {
      _result = result;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final data = result?.data;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
            child: Row(
              children: <Widget>[
                const Expanded(
                  child: Text(
                    '竞标摘要',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.close_rounded),
                  tooltip: '关闭',
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                children: <Widget>[
                  if (_loading)
                    const _StateMessage(title: '正在加载', body: '请稍候片刻。')
                  else if (result == null ||
                      result.state != AppPageState.content)
                    _ActionCard(
                      title: result?.message ?? '当前竞标摘要暂不可用',
                      children: <Widget>[
                        _StateMessage(
                          title: '受控状态',
                          body:
                              result?.errorCode ??
                              result?.state.contractName ??
                              'unknown',
                        ),
                        const SizedBox(height: 12),
                        FilledButton.tonal(
                          onPressed: _load,
                          child: const Text('重试'),
                        ),
                      ],
                    )
                  else ...<Widget>[
                    _ActionCard(
                      title: data!.bidder.displayName,
                      summary: '这里只承接最小只读竞标摘要，不扩成修改、重提或比较工作台。',
                      tone: _ActionCardTone.emphasis,
                      children: <Widget>[
                        _DetailLine(
                          label: '组织 ID',
                          value: data.bidder.organizationId,
                        ),
                        _DetailLine(label: '提交时间', value: data.submittedAt),
                        _DetailLine(
                          label: '报价金额',
                          value: _currencyText(data.quoteAmount),
                          highlight: true,
                        ),
                        _DetailLine(
                          label: '附件摘要',
                          value: _snapshotAttachmentSummaryText(
                            data.attachmentSummary,
                          ),
                        ),
                        _DetailLine(
                          label: '当前可用性',
                          value: _snapshotAvailabilityText(data.availability),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _ActionCard(
                      title: '方案说明',
                      children: <Widget>[
                        _DetailLine(label: '内容', value: data.proposalSummary),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _snapshotAttachmentSummaryText(Map<String, Object?> summary) {
  final count = summary['count'];
  if (count is num) {
    return '已确认 $count 份附件';
  }
  return '未提供';
}

String _snapshotAvailabilityText(Map<String, Object?> availability) {
  final canOpenBidThread = availability['canOpenBidThread'];
  if (canOpenBidThread is bool) {
    return canOpenBidThread ? '可继续沟通与投标' : '当前不可继续沟通';
  }
  return '未提供';
}
