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
      summary: '查看当前合同状态，并继续处理确认或改单。',
      loading: _loading,
      result: result,
      onRetry: () => _load(forceRefresh: true),
      sourceLabel: snapshot?.isDemo == true ? snapshot?.sourceLabel : null,
      sourceMessage: snapshot?.isDemo == true ? snapshot?.sourceMessage : null,
      fallbackTitle: snapshot?.fallbackTitle,
      fallbackMessage: snapshot?.fallbackMessage,
      showPageSummaryCard: false,
      showContentStateCard: false,
      resultSectionsBuilder: (ExhibitionLoadResult result) =>
          _buildResultSections(result, routeOrderId, contractState),
    );
  }

  List<Widget> _buildResultSections(
    ExhibitionLoadResult result,
    String? routeOrderId,
    String? contractState,
  ) {
    if (result.state != AppPageState.content || routeOrderId == null) {
      return const <Widget>[];
    }

    final sections = <Widget>[
      const SizedBox(height: 16),
      _ActionCard(
        title: '合同概览',
        tone: _ActionCardTone.emphasis,
        children: _buildContractChildren(contractState),
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
          _buildConfirmResultCard(),
        ],
      ]);
    } else if (_amendResult != null) {
      sections.addAll(<Widget>[
        const SizedBox(height: 16),
        _SubmissionResultPanel(result: _amendResult!),
        if (_amendResult!.isSuccess) ...<Widget>[
          const SizedBox(height: 16),
          _buildAmendResultCard(),
        ],
      ]);
    }

    return sections;
  }

  List<Widget> _buildContractChildren(String? contractState) {
    final children = <Widget>[
      if (contractState != null) ...<Widget>[
        _DetailLine(
          label: '合同状态',
          value: _frontStageStateLabel(contractState),
          highlight: true,
        ),
      ],
      const SizedBox(height: 12),
      Text(_contractStateHint(contractState)),
      if (contractState == 'pending_confirm') ...<Widget>[
        const SizedBox(height: 12),
        FilledButton(
          key: const ValueKey<String>('contract_confirm_button'),
          onPressed: _confirming || _amending ? null : _confirmContract,
          child: const Text('确认当前合同'),
        ),
      ],
      if (contractState == 'active') ...<Widget>[
        const SizedBox(height: 12),
        FilledButton(
          key: const ValueKey<String>('contract_amend_button'),
          onPressed: _confirming || _amending ? null : _amendContract,
          child: const Text('改单当前合同'),
        ),
      ],
    ];

    return children;
  }

  String _contractStateHint(String? contractState) {
    return switch (contractState) {
      'pending_confirm' => '请确认合同内容无误后再继续。',
      'active' => '合同已生效。如需调整，可发起最小改单。',
      'amended' => '合同已改单，当前以最新合同状态为准。',
      _ => '当前合同仅可查看。',
    };
  }

  Widget _buildConfirmResultCard() {
    final actionState = _stateFromPayload(_confirmResult?.payload);

    return _ActionCard(
      title: '合同确认已受理',
      tone: _ActionCardTone.emphasis,
      children: <Widget>[
        if (actionState != null) ...<Widget>[
          _DetailLine(
            label: '合同状态',
            value: _frontStageStateLabel(actionState),
            highlight: true,
          ),
        ],
        const SizedBox(height: 8),
        const Text('已刷新合同状态。'),
      ],
    );
  }

  Widget _buildAmendResultCard() {
    final actionState = _stateFromPayload(_amendResult?.payload);

    return _ActionCard(
      title: '合同改单已受理',
      tone: _ActionCardTone.emphasis,
      children: <Widget>[
        if (actionState != null) ...<Widget>[
          _DetailLine(
            label: '合同状态',
            value: _frontStageStateLabel(actionState),
            highlight: true,
          ),
        ],
        const SizedBox(height: 8),
        const Text('已刷新合同状态。'),
      ],
    );
  }
}
