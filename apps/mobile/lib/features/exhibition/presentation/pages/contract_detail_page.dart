part of '../exhibition_trade_pages.dart';

class ContractDetailPage extends StatefulWidget {
  const ContractDetailPage({super.key, this.orderId});

  final String? orderId;

  @override
  State<ContractDetailPage> createState() => _ContractDetailPageState();
}

class _ContractDetailPageState extends State<ContractDetailPage> {
  late final ExhibitionStageLoadAutoSource _source =
      ExhibitionStageLoadAutoSource(
        futureRealLoader: ({bool forceRefresh = false}) {
          return ExhibitionConsumerLayer.instance.loadContractDetail(
            orderId: widget.orderId,
            forceRefresh: forceRefresh,
          );
        },
        demoBuilder: () =>
            ExhibitionStageDemoCatalog.contractDetail(orderId: widget.orderId),
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
          path: ExhibitionCanonicalPaths.contractDetail,
          message:
              'orderId is required from route context before contract entry',
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
    final contractState = _stateFromPayload(result?.payload);

    return _LoadPageFrame(
      title: '合同详情',
      summary: '这里承接当前订单下的合同结果。页面会直接告诉你为什么现在能看合同、还能做什么，以及当前阶段不继续开放什么。',
      loading: _loading,
      result: result,
      onRetry: () => _load(forceRefresh: true),
      sourceLabel: snapshot?.sourceLabel,
      sourceMessage: snapshot?.sourceMessage,
      fallbackTitle: snapshot?.fallbackTitle,
      fallbackMessage: snapshot?.fallbackMessage,
      controls: _routeOnlyControls(
        routeId: routeOrderId,
        label: 'orderId',
        onReload: () => _load(forceRefresh: true),
        reloadLabel: '重新读取当前合同',
      ),
      resultSectionsBuilder: (ExhibitionLoadResult result) =>
          _buildResultSections(
            context,
            result,
            snapshot,
            routeOrderId,
            contractState,
          ),
    );
  }

  List<Widget> _buildResultSections(
    BuildContext context,
    ExhibitionLoadResult result,
    ExhibitionStageLoadSnapshot? snapshot,
    String? routeOrderId,
    String? contractState,
  ) {
    final contractId = _contractIdFromPayload(result.payload);
    final detailPayload = _payloadMap(result.payload);
    final detailSummary = detailPayload?['summary'];
    if (result.state != AppPageState.content || routeOrderId == null) {
      return const <Widget>[];
    }

    final actionStatus = switch (contractState) {
      'pending_confirm' => '当前动作：可以继续合同确认',
      'active' => '当前动作：可以继续合同改单',
      _ => '当前动作：当前保持只读',
    };
    final nextStep = switch (contractState) {
      'pending_confirm' => '确认完成后，页面会继续承接已生效合同，再决定是否进入改单。',
      'active' => '如需继续这条后半链路，下一步就是改单；当前页保留只读承接。',
      'amended' => '当前合同已改单，后续以回看当前状态为主，不再展开更多闭环。',
      _ => '当前页继续保持只读承接，后续仍以现有已签收入口为准。',
    };

    return <Widget>[
      const SizedBox(height: 16),
      _ActionCard(
        title: '现在先处理什么',
        summary: '先看清合同当前状态，再决定是否继续合同确认或改单；当前未批准的链路会保持冻结展示。',
        tone: _ActionCardTone.emphasis,
        children: _buildContractChildren(
          context,
          snapshot,
          routeOrderId,
          contractId,
          contractState,
          detailSummary,
          actionStatus,
          nextStep,
        ),
      ),
    ];
  }

  List<Widget> _buildContractChildren(
    BuildContext context,
    ExhibitionStageLoadSnapshot? snapshot,
    String routeOrderId,
    String? contractId,
    String? contractState,
    Object? detailSummary,
    String actionStatus,
    String nextStep,
  ) {
    final children = <Widget>[
      _StateMessage(
        title: '当前为什么能看合同',
        body: switch (contractState) {
          'pending_confirm' => '当前订单已经承接到合同结果，所以这里可以继续查看并完成确认动作。',
          'active' => '当前合同已经生效，所以这里会继续承接生效状态，并放开改单入口。',
          'amended' => '当前合同已经改单完成，所以这里继续保留只读承接结果。',
          _ => '当前合同已经进入受控承接面，这里继续只读展示已返回结果。',
        },
      ),
      if (contractId != null) ...<Widget>[
        const SizedBox(height: 12),
        _InstanceSummaryLine(title: '当前合同 ID', value: contractId),
      ],
      if (contractState != null) ...<Widget>[
        const SizedBox(height: 12),
        _DetailLine(
          label: '当前状态',
          value: _frontStageStateLabel(contractState),
          highlight: true,
        ),
        _DetailLine(
          label: '当前业务状态',
          value: _frontStageStateLabel(contractState),
        ),
      ],
      const SizedBox(height: 12),
      _StatusPill(
        label: actionStatus.replaceFirst('当前动作：', ''),
        tone: contractState == 'pending_confirm' || contractState == 'active'
            ? _ActionCardTone.emphasis
            : _ActionCardTone.muted,
      ),
      const SizedBox(height: 12),
      _StateMessage(title: '后续如何继续', body: nextStep),
      if (detailSummary is Map) ...<Widget>[
        const SizedBox(height: 12),
        const _DetailLine(
          label: '当前说明',
          value: '合同最小读模型已经承接完成，页面不会扩展成签约工作台或历史报表页。',
        ),
      ],
      const SizedBox(height: 12),
      _DetailLine(
        label: '当前展示来源',
        value: snapshot?.isDemo == true ? '演示内容' : '已接通内容',
      ),
      const SizedBox(height: 12),
      const _EmptyNotice(
        title: '当前不能做什么',
        message: '当前页不展开条款编辑、签约流、法务审核、历史报表或评价链动作，只保留已批准的合同确认与改单入口。',
      ),
    ];

    if (contractState == 'pending_confirm') {
      children.addAll(<Widget>[
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pushNamed(
              ExhibitionRoutes.contractConfirmWithOrderId(routeOrderId),
            );
          },
          child: const Text('继续合同确认'),
        ),
      ]);
    } else if (contractState == 'active') {
      children.addAll(<Widget>[
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pushNamed(
              ExhibitionRoutes.contractAmendWithOrderId(routeOrderId),
            );
          },
          child: const Text('继续合同改单'),
        ),
      ]);
    }

    return children;
  }
}
