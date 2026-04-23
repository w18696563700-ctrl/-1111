part of '../exhibition_trade_pages.dart';

Future<void> _showTradingImParticipantCardSheet(
  BuildContext context, {
  required String? projectId,
  required String? bidId,
  required String? participantOrganizationId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => FractionallySizedBox(
      heightFactor: 0.9,
      child: _TradingImParticipantCardSheet(
        projectId: projectId,
        bidId: bidId,
        participantOrganizationId: participantOrganizationId,
      ),
    ),
  );
}

class _TradingImParticipantCardSheet extends StatefulWidget {
  const _TradingImParticipantCardSheet({
    required this.projectId,
    required this.bidId,
    required this.participantOrganizationId,
  });

  final String? projectId;
  final String? bidId;
  final String? participantOrganizationId;

  @override
  State<_TradingImParticipantCardSheet> createState() =>
      _TradingImParticipantCardSheetState();
}

class _TradingImParticipantCardSheetState
    extends State<_TradingImParticipantCardSheet> {
  TradingImResult<TradingImParticipantCardView>? _result;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await TradingImConsumerLayer.instance.loadParticipantCard(
      projectId: widget.projectId,
      bidId: widget.bidId,
      participantOrganizationId: widget.participantOrganizationId,
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
                    '合作方名片',
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
                      title: result?.message ?? '当前合作方名片暂不可用',
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
                      title: data!.enterpriseSummary.displayName,
                      summary: '这里只承接线程内的最小可信公司摘要，不扩成完整企业详情中心。',
                      tone: _ActionCardTone.emphasis,
                      children: <Widget>[
                        Center(
                          child: CircleAvatar(
                            radius: 28,
                            backgroundImage:
                                data.enterpriseSummary.logoUrl == null
                                ? null
                                : NetworkImage(data.enterpriseSummary.logoUrl!),
                            child: data.enterpriseSummary.logoUrl == null
                                ? Text(
                                    data.enterpriseSummary.displayName
                                            .trim()
                                            .characters
                                            .first
                                            .toUpperCase(),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _DetailLine(
                          label: '当前角色',
                          value: _tradingImRoleLabel(data.participantRole),
                          highlight: true,
                        ),
                        _DetailLine(
                          label: '企业类型',
                          value: data.enterpriseSummary.primaryBoardType,
                        ),
                        _DetailLine(
                          label: '所在地区',
                          value:
                              '${data.enterpriseSummary.provinceName} / ${data.enterpriseSummary.cityName}',
                        ),
                        _DetailLine(
                          label: '认证状态',
                          value: data.enterpriseSummary.verificationStatus,
                        ),
                        _DetailLine(
                          label: '法定名称',
                          value: data.formalInfoSummary.legalName,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _ActionCard(
                      title: '合作摘要',
                      children: <Widget>[
                        _DetailLine(
                          label: '综合评分',
                          value: _participantScoreText(data.reviewSummary),
                        ),
                        _DetailLine(
                          label: '评价数',
                          value: '${data.reviewSummary.reviewCount}',
                        ),
                        _DetailLine(
                          label: '关键词',
                          value: data.reviewSummary.keywordTags.isEmpty
                              ? '暂无'
                              : data.reviewSummary.keywordTags.join(' / '),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _ActionCard(
                      title: '正式认证摘要',
                      children: <Widget>[
                        _DetailLine(
                          label: '法定名称',
                          value: data.formalInfoSummary.legalName,
                        ),
                        _DetailLine(
                          label: '企业类型',
                          value: data.formalInfoSummary.businessType ?? '未提供',
                        ),
                        _DetailLine(
                          label: '注册资本',
                          value:
                              data.formalInfoSummary.registeredCapital ?? '未提供',
                        ),
                        _DetailLine(
                          label: '成立时间',
                          value: data.formalInfoSummary.establishedAt ?? '未提供',
                        ),
                        _DetailLine(
                          label: '认证状态',
                          value: data.formalInfoSummary.certificationStatus,
                        ),
                        _DetailLine(
                          label: '经营范围',
                          value: data.formalInfoSummary.businessScope ?? '未提供',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const _ActionCard(
                      title: '合作建议',
                      summary: '合作前建议查看对方的企查查信息，并在平台内保留关键沟通记录。',
                      children: <Widget>[],
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

String _participantScoreText(TradingImParticipantReviewSummaryView reviewSummary) {
  final avgScore = reviewSummary.avgScore;
  if (avgScore == null) {
    return '暂无';
  }
  return avgScore.toStringAsFixed(1);
}
