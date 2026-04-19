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
  bool _confirming = false;
  bool _amending = false;
  ExhibitionActionResult? _confirmResult;
  ExhibitionActionResult? _amendResult;

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

  Future<void> _confirmContract() async {
    final routeOrderId = _normalizeId(widget.orderId);
    if (routeOrderId == null || _confirming) {
      return;
    }

    setState(() {
      _confirming = true;
      _confirmResult = null;
      _amendResult = null;
    });

    final result = await ExhibitionConsumerLayer.instance.confirmContract(
      ContractConfirmCommand(orderId: routeOrderId),
    );

    ExhibitionStageLoadSnapshot? refreshedSnapshot;
    if (result.isSuccess) {
      refreshedSnapshot = await _source.load(forceRefresh: true);
      await ExhibitionConsumerLayer.instance.loadMyProjectList(
        forceRefresh: true,
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _confirming = false;
      _confirmResult = result;
      if (refreshedSnapshot != null) {
        _snapshot = refreshedSnapshot;
      }
    });
  }

  Future<void> _amendContract() async {
    final routeOrderId = _normalizeId(widget.orderId);
    if (routeOrderId == null || _amending) {
      return;
    }

    setState(() {
      _amending = true;
      _amendResult = null;
      _confirmResult = null;
    });

    final result = await ExhibitionConsumerLayer.instance.amendContract(
      ContractAmendCommand(orderId: routeOrderId),
    );

    ExhibitionStageLoadSnapshot? refreshedSnapshot;
    if (result.isSuccess) {
      refreshedSnapshot = await _source.load(forceRefresh: true);
      await ExhibitionConsumerLayer.instance.loadMyProjectList(
        forceRefresh: true,
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _amending = false;
      _amendResult = result;
      if (refreshedSnapshot != null) {
        _snapshot = refreshedSnapshot;
      }
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
      summary:
          '这里承接当前订单下的合同结果。待确认合同时可直接做最小确认；active 合同时可做最小改单。确认或改单后都会刷新合同详情和我的项目。',
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
            result,
            snapshot,
            routeOrderId,
            contractState,
          ),
    );
  }

  List<Widget> _buildResultSections(
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
      'pending_confirm' => '当前动作：可以确认当前合同',
      'active' => '当前动作：可以改单当前合同',
      _ => '当前动作：当前保持只读',
    };
    final nextStep = switch (contractState) {
      'pending_confirm' =>
        '如果当前合同无误，可以直接在这里确认；确认成功后页面会刷新合同详情和我的项目。',
      'active' =>
        '如果当前合同需要最小改单，可以直接在这里执行；改单成功后页面会刷新合同详情和我的项目。',
      'amended' => '当前合同已改单，后续以回看当前状态为主，不再展开更多闭环。',
      _ => '当前页继续保持只读承接，后续不会在这里展开新的合同动作。',
    };

    final sections = <Widget>[
      const SizedBox(height: 16),
      _ActionCard(
        title: '当前合同结果',
        summary: '先看清当前合同状态；当前页只保留结果读取、最小确认和状态解释，不扩成合同工作台。',
        tone: _ActionCardTone.emphasis,
        children: _buildContractChildren(
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

    if (_confirming) {
      sections.addAll(<Widget>[
        const SizedBox(height: 16),
        const _SubmittingPanel(),
      ]);
    } else if (_amending) {
      sections.addAll(<Widget>[
        const SizedBox(height: 16),
        const _SubmittingPanel(),
      ]);
    } else if (_confirmResult != null) {
      sections.addAll(<Widget>[
        const SizedBox(height: 16),
        _SubmissionResultPanel(result: _confirmResult!),
        if (_confirmResult!.isSuccess) ...<Widget>[
          const SizedBox(height: 16),
          _buildConfirmResultCard(routeOrderId),
        ],
      ]);
    } else if (_amendResult != null) {
      sections.addAll(<Widget>[
        const SizedBox(height: 16),
        _SubmissionResultPanel(result: _amendResult!),
        if (_amendResult!.isSuccess) ...<Widget>[
          const SizedBox(height: 16),
          _buildAmendResultCard(routeOrderId),
        ],
      ]);
    }

    return sections;
  }

  List<Widget> _buildContractChildren(
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
          'pending_confirm' =>
            '当前订单已经承接到合同结果，所以这里可以继续看合同详情并完成最小确认；页面不会顺手放开改单或签约工作台。',
          'active' => '当前合同已经生效，所以这里继续只读承接当前状态；合同改单仍保持关闭。',
          'amended' => '当前合同已经改单完成，所以这里继续只读保留最终结果。',
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
      if (contractState == 'pending_confirm') ...<Widget>[
        const SizedBox(height: 12),
        FilledButton(
          key: const ValueKey<String>('contract_confirm_button'),
          onPressed: _confirming || _amending ? null : _confirmContract,
          child: const Text('确认当前合同'),
        ),
        const SizedBox(height: 8),
        _DetailLine(label: '当前订单 ID', value: routeOrderId),
      ],
      if (contractState == 'active') ...<Widget>[
        const SizedBox(height: 12),
        FilledButton(
          key: const ValueKey<String>('contract_amend_button'),
          onPressed: _confirming || _amending ? null : _amendContract,
          child: const Text('改单当前合同'),
        ),
        const SizedBox(height: 8),
        _DetailLine(label: '当前订单 ID', value: routeOrderId),
      ],
      const SizedBox(height: 12),
      _StateMessage(title: '后续如何继续', body: nextStep),
      if (detailSummary is Map) ...<Widget>[
        const SizedBox(height: 12),
        const _DetailLine(
          label: '当前说明',
          value: '合同最小读模型已经承接完成，页面不会扩展成签约工作台、条款编辑页或历史报表页。',
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
        message: '当前页不展开条款编辑器、签约流、法务审核或历史报表；这轮只开放最小合同确认与最小合同改单入口。',
      ),
    ];

    return children;
  }

  Widget _buildConfirmResultCard(String routeOrderId) {
    final payload = _payloadMap(_confirmResult?.payload);
    final contractId = _contractIdFromPayload(_confirmResult?.payload);
    final actionState = _stateFromPayload(_confirmResult?.payload);
    final summary = payload?['summary'];

    return _ActionCard(
      title: '合同确认已受理',
      summary: '当前页承接确认后的最小结果，并继续回显最新合同真值。',
      tone: _ActionCardTone.emphasis,
      children: <Widget>[
        _InstanceSummaryLine(title: '当前订单 ID', value: routeOrderId),
        if (contractId != null) ...<Widget>[
          const SizedBox(height: 12),
          _InstanceSummaryLine(title: '当前合同 ID', value: contractId),
        ],
        if (actionState != null) ...<Widget>[
          const SizedBox(height: 12),
          _DetailLine(
            label: '当前状态',
            value: _frontStageStateLabel(actionState),
            highlight: true,
          ),
        ],
        if (summary is Map)
          const _DetailLine(
            label: '当前说明',
            value: '合同确认已受理；页面已经刷新合同详情和我的项目缓存。',
          ),
      ],
    );
  }

  Widget _buildAmendResultCard(String routeOrderId) {
    final payload = _payloadMap(_amendResult?.payload);
    final contractId = _contractIdFromPayload(_amendResult?.payload);
    final actionState = _stateFromPayload(_amendResult?.payload);
    final summary = payload?['summary'];

    return _ActionCard(
      title: '合同改单已受理',
      summary: '当前页承接改单后的最小结果，并继续回显最新合同真值。',
      tone: _ActionCardTone.emphasis,
      children: <Widget>[
        _InstanceSummaryLine(title: '当前订单 ID', value: routeOrderId),
        if (contractId != null) ...<Widget>[
          const SizedBox(height: 12),
          _InstanceSummaryLine(title: '当前合同 ID', value: contractId),
        ],
        if (actionState != null) ...<Widget>[
          const SizedBox(height: 12),
          _DetailLine(
            label: '当前状态',
            value: _frontStageStateLabel(actionState),
            highlight: true,
          ),
        ],
        if (summary is Map)
          const _DetailLine(
            label: '当前说明',
            value: '合同改单已受理；页面已经刷新合同详情和我的项目缓存。',
          ),
      ],
    );
  }
}
