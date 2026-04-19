part of '../exhibition_trade_pages.dart';

class MilestoneListPage extends StatefulWidget {
  const MilestoneListPage({super.key, this.orderId});

  final String? orderId;

  @override
  State<MilestoneListPage> createState() => _MilestoneListPageState();
}

class _MilestoneListPageState extends State<MilestoneListPage> {
  late final ExhibitionStageLoadAutoSource _source =
      ExhibitionStageLoadAutoSource(
        futureRealLoader: ({bool forceRefresh = false}) {
          return ExhibitionConsumerLayer.instance.loadMilestoneList(
            orderId: widget.orderId,
            forceRefresh: forceRefresh,
          );
        },
        demoBuilder: () =>
            ExhibitionStageDemoCatalog.milestoneList(orderId: widget.orderId),
      );

  ExhibitionStageLoadSnapshot? _snapshot;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool forceRefresh = false}) async {
    setState(() {
      _loading = true;
    });

    final snapshot = await _source.load(forceRefresh: forceRefresh);

    if (!mounted) {
      return;
    }

    setState(() {
      _snapshot = snapshot;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final routeOrderId = _normalizeId(widget.orderId);
    final snapshot = _snapshot;
    final result = snapshot?.result;

    return _LoadPageFrame(
      title: '里程碑列表',
      summary: '这里集中读取当前订单下的里程碑。页面只展示金额、状态和可继续查看的验收详情，不放开里程碑提交、验收提交或复检动作。',
      loading: _loading,
      result: result,
      onRetry: () => _load(forceRefresh: true),
      sourceLabel: snapshot?.sourceLabel,
      sourceMessage: snapshot?.sourceMessage,
      fallbackTitle: snapshot?.fallbackTitle,
      fallbackMessage: snapshot?.fallbackMessage,
      showConnectionInfo: false,
      showTechnicalDisclosure: false,
      controls: <Widget>[
        if (routeOrderId != null)
          _InstanceSummaryLine(title: '当前订单 ID', value: routeOrderId),
        if (routeOrderId != null) const SizedBox(height: 12),
        FilledButton.tonal(
          onPressed: () => _load(forceRefresh: true),
          child: const Text('重新加载里程碑'),
        ),
      ],
      resultSectionsBuilder: (ExhibitionLoadResult result) =>
          _buildResultSections(context, result, snapshot),
    );
  }

  List<Widget> _buildResultSections(
    BuildContext context,
    ExhibitionLoadResult result,
    ExhibitionStageLoadSnapshot? snapshot,
  ) {
    final items = _itemMapsFromPayload(result.payload);
    final milestones = _milestonesFromPayload(result.payload);
    if (result.state != AppPageState.content &&
        result.state != AppPageState.empty) {
      return const <Widget>[];
    }

    return <Widget>[
      const SizedBox(height: 16),
      _ActionCard(
        title: '当前订单下的里程碑',
        summary: items.isEmpty
            ? '当前订单下还没有可继续推进的里程碑，页面先保留在只读空态。'
            : '每个里程碑都只保留状态读取和验收详情续接，当前页不再伪装成履约推进台。',
        tone: _ActionCardTone.emphasis,
        eyebrow: '履约节奏',
        children: _buildMilestoneChildren(context, snapshot, items, milestones),
      ),
      const SizedBox(height: 16),
      const _ActionCard(
        title: '讲解建议',
        summary: '先讲清楚每个节点当前状态，再进入对应验收详情看真值，不要把当前页讲成提交台。',
        eyebrow: '讲解节奏',
        children: <Widget>[
          _DetailLine(label: '推荐顺序', value: '订单详情 -> 里程碑列表 -> 验收详情'),
          _DetailLine(label: '当前边界', value: '提交、复检和争议动作当前不从这里放开。'),
        ],
      ),
    ];
  }

  List<Widget> _buildMilestoneChildren(
    BuildContext context,
    ExhibitionStageLoadSnapshot? snapshot,
    List<Map<String, Object?>> items,
    List<_MilestoneLink> milestones,
  ) {
    return <Widget>[
      _DetailLine(label: '当前里程碑数', value: '${items.length} 个', highlight: true),
      _DetailLine(
        label: '当前展示来源',
        value: snapshot?.isDemo == true ? '演示内容' : '已接通内容',
      ),
      const SizedBox(height: 12),
      if (items.isEmpty)
        const _EmptyNotice(
          title: '当前无可继续里程碑',
          message: '订单还没有承接到可继续推进的里程碑。你现在可以先回到订单详情，再确认当前订单是否已经进入履约阶段。',
        )
      else
        ...List<Widget>.generate(items.length, (int index) {
          final item = items[index];
          final milestone = index < milestones.length
              ? milestones[index]
              : null;
          final milestoneId = _normalizeId(item['milestoneId'] as String?);
          final orderId = _normalizeId(item['orderId'] as String?);
          final title = _normalizeId(item['title'] as String?) ?? milestoneId;
          final amount = item['amount'];
          final state = _normalizeId(item['state'] as String?);
          final summary = item['summary'];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _EntityCard(
              title: title ?? '当前里程碑',
              description: state == null
                  ? '当前里程碑已进入只读承接面，可继续查看对应验收详情。'
                  : '当前节点处于 ${_frontStageStateLabel(state)}，当前页只保留状态读取与验收详情续接。',
              statusLabel: state == null
                  ? '可查看详情'
                  : _frontStageStateLabel(state),
              detailLines: <Widget>[
                if (milestoneId != null)
                  _DetailLine(label: '里程碑 ID', value: milestoneId),
                if (orderId != null) _DetailLine(label: '所属订单', value: orderId),
                if (amount is num)
                  _DetailLine(
                    label: '节点金额',
                    value: _currencyText(amount),
                    highlight: true,
                  ),
                if (state != null)
                  _DetailLine(
                    label: '当前状态',
                    value: _frontStageStateLabel(state),
                  ),
                if (summary is Map)
                  const _DetailLine(
                    label: '下一步动作',
                    value: '继续查看当前里程碑对应的验收详情。',
                  ),
              ],
              actionSummary: state == null
                  ? '当前建议先查看这个节点对应的验收详情，确认当前验收真值。'
                  : '当前建议先查看这个节点对应的验收详情，提交和复检动作继续保持冻结。',
              actionLabel: title == null ? '查看验收详情' : '查看 $title 验收详情',
              onPressed: milestone == null
                  ? null
                  : () {
                      Navigator.of(context).pushNamed(
                        ExhibitionRoutes.inspectionDetailWithMilestoneId(
                          milestone.milestoneId,
                        ),
                      );
                    },
            ),
          );
        }),
    ];
  }
}
