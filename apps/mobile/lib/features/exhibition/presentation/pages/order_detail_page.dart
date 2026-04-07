part of '../exhibition_trade_pages.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key, this.orderId});

  final String? orderId;

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late final ExhibitionStageLoadAutoSource _source =
      ExhibitionStageLoadAutoSource(
        futureRealLoader: ({bool forceRefresh = false}) {
          return ExhibitionConsumerLayer.instance.loadOrderDetail(
            orderId: widget.orderId,
            forceRefresh: forceRefresh,
          );
        },
        demoBuilder: () =>
            ExhibitionStageDemoCatalog.orderDetail(orderId: widget.orderId),
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
      title: '订单详情',
      summary: '这里是当前订单的工作台。页面会先把订单当前阶段和可继续动作讲清楚，再把你带向履约链、合同详情或受控争议入口。',
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
          child: const Text('重新加载订单'),
        ),
      ],
      resultSectionsBuilder: (ExhibitionLoadResult result) =>
          _buildResultSections(context, result, snapshot, routeOrderId),
    );
  }

  List<Widget> _buildResultSections(
    BuildContext context,
    ExhibitionLoadResult result,
    ExhibitionStageLoadSnapshot? snapshot,
    String? routeOrderId,
  ) {
    final payload = _payloadMap(result.payload);
    final orderId = _orderIdFromPayload(result.payload) ?? routeOrderId;
    final orderNo = _normalizeId(payload?['orderNo'] as String?);
    final projectId = _normalizeId(payload?['projectId'] as String?);
    final bidId = _normalizeId(payload?['bidId'] as String?);
    final orderState = _normalizeId(payload?['state'] as String?);
    final summary = payload?['summary'];
    final milestones = _milestonesFromPayload(result.payload);
    if (result.state != AppPageState.content || orderId == null) {
      return const <Widget>[];
    }

    return <Widget>[
      const SizedBox(height: 16),
      _buildOrderOverviewCard(
        snapshot,
        orderNo,
        projectId,
        bidId,
        orderState,
        summary,
        milestones,
      ),
      const SizedBox(height: 16),
      _buildFulfillmentCard(context, orderId, milestones),
      const SizedBox(height: 16),
      _buildBoundaryCard(context, orderId),
    ];
  }

  Widget _buildOrderOverviewCard(
    ExhibitionStageLoadSnapshot? snapshot,
    String? orderNo,
    String? projectId,
    String? bidId,
    String? orderState,
    Object? summary,
    List<_MilestoneLink> milestones,
  ) {
    return _ActionCard(
      title: '订单概览',
      summary: '当前页面先帮助你判断订单是否已经进入稳定执行阶段，以及后续应该沿哪条分支继续。',
      tone: _ActionCardTone.emphasis,
      eyebrow: '当前订单工作台',
      children: <Widget>[
        if (orderNo != null) _DetailLine(label: '订单编号', value: orderNo),
        if (projectId != null) _DetailLine(label: '关联项目 ID', value: projectId),
        if (bidId != null) _DetailLine(label: '关联投标 ID', value: bidId),
        if (orderState != null)
          _DetailLine(
            label: '当前状态',
            value: _frontStageStateLabel(orderState),
            highlight: true,
          ),
        if (summary is Map)
          const _DetailLine(
            label: '当前说明',
            value: '订单关键信息已经承接完成，可以继续判断履约链或后半链入口。',
          ),
        _DetailLine(
          label: '当前展示来源',
          value: snapshot?.isDemo == true ? '演示内容' : '已接通内容',
        ),
        const SizedBox(height: 8),
        _StateMessage(
          title: '现在先判断什么',
          body: milestones.isEmpty
              ? '当前订单已进入后续承接阶段，下一步可以先查看里程碑列表，再决定是否进入合同或争议边界。'
              : '当前订单已进入后续承接阶段，可以先继续里程碑链路，也可以查看合同或在受控边界内开启争议。',
        ),
        const SizedBox(height: 12),
        const _DetailLine(
          label: '工作台关系',
          value: '订单负责把履约、合同与争议边界收在同一处，方便连续讲解当前订单后续怎么走。',
        ),
      ],
    );
  }

  Widget _buildFulfillmentCard(
    BuildContext context,
    String orderId,
    List<_MilestoneLink> milestones,
  ) {
    return _ActionCard(
      title: '履约链路',
      summary: milestones.isEmpty
          ? '当前订单下还没有明确的里程碑实例，先进入里程碑列表确认后续安排。'
          : '当前订单已经承接到里程碑，可以直接继续查看列表或进入对应提交动作。',
      eyebrow: '继续履约',
      children: <Widget>[
        FilledButton.tonal(
          onPressed: () {
            Navigator.of(
              context,
            ).pushNamed(ExhibitionRoutes.milestoneListWithOrderId(orderId));
          },
          child: const Text('查看里程碑列表'),
        ),
        if (milestones.isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          ...milestones.map(
            (_MilestoneLink milestone) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    ExhibitionRoutes.milestoneSubmitWithMilestoneId(
                      milestone.milestoneId,
                    ),
                  );
                },
                child: Text('去提交 ${milestone.label}'),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBoundaryCard(BuildContext context, String orderId) {
    return _ActionCard(
      title: '合同与争议边界',
      summary: '这部分只保留当前阶段已经批准的后半链入口，不把冻结边界误放成首发主链。',
      eyebrow: '订单后半链',
      children: <Widget>[
        const _DetailLine(
          label: '当前能做什么',
          value: '查看合同详情、开启争议入口，或回到履约链继续推进当前订单。',
        ),
        FilledButton.tonal(
          onPressed: () {
            Navigator.of(
              context,
            ).pushNamed(ExhibitionRoutes.contractDetailWithOrderId(orderId));
          },
          child: const Text('查看合同详情'),
        ),
        const SizedBox(height: 12),
        FilledButton.tonal(
          onPressed: () {
            Navigator.of(
              context,
            ).pushNamed(ExhibitionRoutes.disputeOpenWithOrderId(orderId));
          },
          child: const Text('开启争议入口'),
        ),
        const SizedBox(height: 12),
        const _EmptyNotice(
          title: '当前冻结',
          message: '评价主链和争议撤回暂不从订单工作台直接放开，当前阶段先展示边界，不继续开放动作。',
        ),
      ],
    );
  }
}
