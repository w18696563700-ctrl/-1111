part of '../exhibition_trade_pages.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key, this.orderId, this.projectId});

  final String? orderId;
  final String? projectId;

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late final ExhibitionStageLoadAutoSource _source =
      ExhibitionStageLoadAutoSource(
        futureRealLoader: ({bool forceRefresh = false}) {
          return ExhibitionConsumerLayer.instance.loadOrderDetail(
            orderId: widget.orderId,
            projectId: widget.projectId,
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
      title: '后续承接状态',
      summary: '查看 Order seed 承接状态；这里不代表最终合同金额已确认。',
      loading: _loading,
      result: result,
      onRetry: () => _load(forceRefresh: true),
      sourceLabel: snapshot?.isDemo == true ? snapshot?.sourceLabel : null,
      sourceMessage: snapshot?.isDemo == true ? snapshot?.sourceMessage : null,
      fallbackTitle: snapshot?.fallbackTitle,
      fallbackMessage: snapshot?.fallbackMessage,
      showConnectionInfo: false,
      showTechnicalDisclosure: false,
      showPageSummaryCard: false,
      showContentStateCard: false,
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
    final projectId =
        _normalizeId(payload?['projectId'] as String?) ??
        _normalizeId(widget.projectId);
    final orderState = _normalizeId(payload?['state'] as String?);
    final completionRequestState = _normalizeId(
      payload?['completionRequestState'] as String?,
    );
    final exitGovernanceSnapshot = _projectExitGovernanceSnapshotFromMap(
      payload,
    );
    if (result.state != AppPageState.content || orderId == null) {
      return const <Widget>[];
    }

    return <Widget>[
      const SizedBox(height: 16),
      _buildOrderOverviewCard(orderNo, orderState, completionRequestState),
      if (exitGovernanceSnapshot != null) ...<Widget>[
        const SizedBox(height: 16),
        _ProjectExitGovernanceStatusCard(
          snapshot: exitGovernanceSnapshot,
          placement: _ProjectExitGovernancePlacement.orderDetail,
          projectId: projectId,
          orderId: orderId,
        ),
      ],
      const SizedBox(height: 16),
      _OrderStatusCard(
        orderId: orderId,
        projectId: projectId,
        initialResult: result,
        placement: _OrderStatusPlacement.orderDetail,
        onChanged: () => _load(forceRefresh: true),
      ),
      const SizedBox(height: 16),
      _buildReadOnlyContinuationCard(
        context,
        _EffectiveOrderStatus.from(
          payload: payload ?? const <String, Object?>{},
          actionPayload: null,
          fallbackOrderId: orderId,
          fallbackProjectId: projectId,
        ),
      ),
    ];
  }

  Widget _buildOrderOverviewCard(
    String? orderNo,
    String? orderState,
    String? completionRequestState,
  ) {
    return _ActionCard(
      title: '订单概览',
      tone: _ActionCardTone.emphasis,
      children: <Widget>[
        if (orderNo != null) _DetailLine(label: '订单编号', value: orderNo),
        if (orderState != null)
          _DetailLine(
            label: '订单状态',
            value: _frontStageStateLabel(orderState),
            highlight: true,
          ),
        if (completionRequestState != null)
          _DetailLine(
            label: '完工申请',
            value: _frontStageStateLabel(completionRequestState),
          ),
      ],
    );
  }

  Widget _buildReadOnlyContinuationCard(
    BuildContext context,
    _EffectiveOrderStatus order,
  ) {
    final ratingRoute = _projectCounterpartyRatingRouteForOrder(context, order);
    return _ActionCard(
      title: '当前可继续',
      children: <Widget>[
        FilledButton.tonal(
          onPressed: () {
            Navigator.of(context).pushNamed(
              ExhibitionRoutes.contractDetailWithOrderId(order.orderId),
            );
          },
          child: const Text('查看合同承接状态'),
        ),
        const SizedBox(height: 12),
        if (ratingRoute != null)
          FilledButton.tonal(
            onPressed: () {
              Navigator.of(context).pushNamed(ratingRoute);
            },
            child: const Text('查看双方互评入口'),
          )
        else
          const Text('订单完成后开放双方互评。'),
      ],
    );
  }
}
