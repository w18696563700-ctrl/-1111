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
    if (_normalizeId(widget.orderId) == null) {
      _snapshot = ExhibitionStageLoadSnapshot(
        result: ExhibitionLoadResult(
          state: AppPageState.notFound,
          method: 'GET',
          path: ExhibitionCanonicalPaths.orderDetail,
          message: 'orderId is required from route context before order entry',
        ),
        origin: ExhibitionStageDataOrigin.futureReal,
      );
      return;
    }
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
      summary:
          '这里只读承接当前订单结果。页面会先讲清订单当前状态，并在需要时继续进入合同详情或最小评价入口；履约与争议不在这里直接放开。',
      loading: _loading,
      result: result,
      onRetry: () => _load(forceRefresh: true),
      sourceLabel: snapshot?.sourceLabel,
      sourceMessage: snapshot?.sourceMessage,
      fallbackTitle: snapshot?.fallbackTitle,
      fallbackMessage: snapshot?.fallbackMessage,
      showConnectionInfo: false,
      showTechnicalDisclosure: false,
      controls: _routeOnlyControls(
        routeId: routeOrderId,
        label: 'orderId',
        onReload: () => _load(forceRefresh: true),
        reloadLabel: '重新加载订单',
      ),
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
      ),
      const SizedBox(height: 16),
      _buildReadOnlyContinuationCard(context, orderId),
    ];
  }

  Widget _buildOrderOverviewCard(
    ExhibitionStageLoadSnapshot? snapshot,
    String? orderNo,
    String? projectId,
    String? bidId,
    String? orderState,
    Object? summary,
  ) {
    return _ActionCard(
      title: '订单概览',
      summary: '当前页先帮助你判断订单是否处于稳定可回看状态，并明确这轮只读承接还能继续到哪里。',
      tone: _ActionCardTone.emphasis,
      eyebrow: '当前订单',
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
            value: '订单最小读模型已经承接完成，当前页不会扩成订单后台或履约指挥台。',
          ),
        _DetailLine(
          label: '当前展示来源',
          value: snapshot?.isDemo == true ? '演示内容' : '已接通内容',
        ),
        const SizedBox(height: 8),
        _StateMessage(
          title: '现在先判断什么',
          body: '先确认当前订单状态是否稳定，再决定是否继续查看合同详情或评价入口。履约、争议和更大范围写入动作不从这里直接展开。',
        ),
        const SizedBox(height: 12),
        const _DetailLine(
          label: '当前页面边界',
          value: '当前页只承担订单读取与合同详情导流，不承担履约推进、争议处理或提交动作。',
        ),
      ],
    );
  }

  Widget _buildReadOnlyContinuationCard(BuildContext context, String orderId) {
    return _ActionCard(
      title: '当前可继续',
      summary: '订单详情当前只保留读侧续接。需要查看合同时，可继续进入合同详情；其余链路继续保持边界提示。',
      eyebrow: '只读续接',
      children: <Widget>[
        const _DetailLine(
          label: '当前能做什么',
          value: '查看合同详情，或继续进入最小评价入口；是否真正可评价以后端评价锚点返回为准。',
        ),
        const SizedBox(height: 12),
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
            ).pushNamed(ExhibitionRoutes.ratingEntryWithOrderId(orderId));
          },
          child: const Text('查看评价入口'),
        ),
        const SizedBox(height: 12),
        const _EmptyNotice(
          title: '当前不在这里开放',
          message: '里程碑列表、里程碑提交、争议开启和更大范围写入动作不从订单详情页直接放开。',
        ),
      ],
    );
  }
}
