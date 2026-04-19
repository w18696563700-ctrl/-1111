part of '../exhibition_trade_pages.dart';

class InspectionDetailPage extends StatefulWidget {
  const InspectionDetailPage({super.key, this.milestoneId});

  final String? milestoneId;

  @override
  State<InspectionDetailPage> createState() => _InspectionDetailPageState();
}

class _InspectionDetailPageState extends State<InspectionDetailPage> {
  late final ExhibitionStageLoadAutoSource _source =
      ExhibitionStageLoadAutoSource(
        futureRealLoader: ({bool forceRefresh = false}) {
          return ExhibitionConsumerLayer.instance.loadInspectionDetail(
            milestoneId: widget.milestoneId,
            forceRefresh: forceRefresh,
          );
        },
        demoBuilder: () => ExhibitionStageDemoCatalog.inspectionDetail(
          milestoneId: widget.milestoneId,
        ),
      );

  ExhibitionStageLoadSnapshot? _snapshot;
  bool _loading = false;
  bool _rechecking = false;
  ExhibitionActionResult? _recheckResult;

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

  Future<void> _recheckInspection() async {
    final payload = _payloadMap(_snapshot?.result.payload);
    final inspectionId = _inspectionIdFromPayload(_snapshot?.result.payload);
    final milestoneId =
        _normalizeId(payload?['milestoneId'] as String?) ??
        _normalizeId(widget.milestoneId);
    if (_rechecking || inspectionId == null || milestoneId == null) {
      return;
    }

    setState(() {
      _rechecking = true;
      _recheckResult = null;
    });

    final result = await ExhibitionConsumerLayer.instance.recheckInspection(
      InspectionRecheckCommand(inspectionId: inspectionId),
    );

    ExhibitionStageLoadSnapshot? refreshedSnapshot;
    if (result.isSuccess) {
      refreshedSnapshot = await _source.load(forceRefresh: true);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _rechecking = false;
      _recheckResult = result;
      if (refreshedSnapshot != null) {
        _snapshot = refreshedSnapshot;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final routeMilestoneId = _normalizeId(widget.milestoneId);
    final snapshot = _snapshot;
    final result = snapshot?.result;

    return _LoadPageFrame(
      title: '验收详情',
      summary: '这里承接当前验收真值。草稿态继续只读；已提交验收可做最小复检；复检后会刷新验收详情。争议和整改流仍冻结。',
      loading: _loading,
      result: result,
      onRetry: () => _load(forceRefresh: true),
      sourceLabel: snapshot?.sourceLabel,
      sourceMessage: snapshot?.sourceMessage,
      fallbackTitle: snapshot?.fallbackTitle,
      fallbackMessage: snapshot?.fallbackMessage,
      controls: _routeOnlyControls(
        routeId: routeMilestoneId,
        label: 'milestoneId',
        onReload: () => _load(forceRefresh: true),
        reloadLabel: '重新读取当前验收',
      ),
      resultSectionsBuilder: (ExhibitionLoadResult result) =>
          _buildResultSections(context, result, snapshot, routeMilestoneId),
    );
  }

  List<Widget> _buildResultSections(
    BuildContext context,
    ExhibitionLoadResult result,
    ExhibitionStageLoadSnapshot? snapshot,
    String? routeMilestoneId,
  ) {
    final payload = _payloadMap(result.payload);
    final milestoneId =
        _normalizeId(payload?['milestoneId'] as String?) ?? routeMilestoneId;
    final inspectionId = _inspectionIdFromPayload(result.payload);
    final inspectionState = _stateFromPayload(result.payload);
    final summary = payload?['summary'];
    if (result.state != AppPageState.content || milestoneId == null) {
      return const <Widget>[];
    }

    final actionStatus = switch (inspectionState) {
      'draft' => '当前动作：当前保持只读查看',
      'submitted' => '当前动作：可以复检当前验收',
      'rechecked' => '当前动作：当前保持结果承接',
      _ => '当前动作：当前保持只读',
    };
    final nextStep = switch (inspectionState) {
      'draft' => '当前验收真值仍停留在草稿态，但本页不开放提交。当前页只保留受控读取，避免伪装成可推进的小型交易台。',
      'submitted' => '当前验收已经提交完成；如果需要最小复检，可以直接在这里执行。复检成功后页面会刷新验收详情。',
      'rechecked' => '当前验收已经完成复检，页面继续保留只读结果承接。',
      _ => '当前验收停留在受控承接面，后续不会在这里展开整改或治理闭环。',
    };

    final sections = <Widget>[
      const SizedBox(height: 16),
      _ActionCard(
        title: '现在先处理什么',
        summary: '先看清当前验收状态，再判断这一页现在是可提交、只读承接，还是保持冻结边界。',
        tone: _ActionCardTone.emphasis,
        children: _buildInspectionChildren(
          context,
          snapshot,
          milestoneId,
          inspectionId,
          inspectionState,
          summary,
          actionStatus,
          nextStep,
        ),
      ),
    ];

    if (_rechecking) {
      sections.addAll(<Widget>[
        const SizedBox(height: 16),
        const _SubmittingPanel(),
      ]);
    } else if (_recheckResult != null) {
      sections.addAll(<Widget>[
        const SizedBox(height: 16),
        _SubmissionResultPanel(result: _recheckResult!),
        if (_recheckResult!.isSuccess) ...<Widget>[
          const SizedBox(height: 16),
          _buildRecheckResultCard(milestoneId),
        ],
      ]);
    }

    return sections;
  }

  List<Widget> _buildInspectionChildren(
    BuildContext context,
    ExhibitionStageLoadSnapshot? snapshot,
    String milestoneId,
    String? inspectionId,
    String? inspectionState,
    Object? summary,
    String actionStatus,
    String nextStep,
  ) {
    final children = <Widget>[
      _StateMessage(
        title: '当前验收说明',
        body: switch (inspectionState) {
          'draft' => '当前验收还未正式提交，当前页只保留受控读取，不在这里继续开放提交动作。',
          'submitted' => '当前验收已经提交完成，当前页保留只读结果承接，不把复检做成首发必走动作。',
          'rechecked' => '当前验收已经完成复检，当前页面继续保留只读结果承接。',
          _ => '当前验收停留在受控承接面，下一步仍以现有入口为准。',
        },
      ),
      const SizedBox(height: 12),
      _InstanceSummaryLine(title: '当前里程碑 ID', value: milestoneId),
      if (inspectionId != null) ...<Widget>[
        const SizedBox(height: 12),
        _InstanceSummaryLine(title: '当前验收 ID', value: inspectionId),
      ],
      if (inspectionState != null) ...<Widget>[
        const SizedBox(height: 12),
        Text('当前状态：${_frontStageStateLabel(inspectionState)}'),
      ],
      if (summary is Map) ...<Widget>[
        const SizedBox(height: 12),
        const Text('页面摘要已就位，可继续讲解当前验收情况。'),
      ],
      const SizedBox(height: 12),
      const _DetailLine(
        label: '当前说明',
        value: '先看清当前验收状态，再判断这一页现在是可提交、只读承接，还是保持冻结边界。',
      ),
      const SizedBox(height: 12),
      _DetailLine(
        label: '当前展示来源',
        value: snapshot?.isDemo == true ? '演示内容' : '已接通内容',
      ),
      const SizedBox(height: 12),
      _StatusPill(
        label: actionStatus.replaceFirst('当前动作：', ''),
        tone: inspectionState == 'draft'
            ? _ActionCardTone.emphasis
            : _ActionCardTone.muted,
      ),
      if (inspectionState == 'submitted' && inspectionId != null) ...<Widget>[
        const SizedBox(height: 12),
        FilledButton(
          key: const ValueKey<String>('inspection_recheck_button'),
          onPressed: _rechecking ? null : _recheckInspection,
          child: const Text('继续验收复检'),
        ),
      ],
      const SizedBox(height: 12),
      _StateMessage(title: '后续如何继续', body: nextStep),
    ];

    if (inspectionState == 'draft') {
      children.addAll(<Widget>[
        const SizedBox(height: 12),
        _EmptyNotice(
          title: '当前不在这里开放',
          message:
              '验收提交动作当前不从详情页继续放开。当前页只读取当前验收真值，不伪装成可继续推进的小型交易台。',
        ),
      ]);
    }

    return children;
  }

  Widget _buildRecheckResultCard(String milestoneId) {
    final payload = _payloadMap(_recheckResult?.payload);
    final inspectionId = _inspectionIdFromPayload(_recheckResult?.payload);
    final actionState = _stateFromPayload(_recheckResult?.payload);
    final summary = payload?['summary'];

    return _ActionCard(
      title: '验收复检入口已受理',
      summary: '当前页承接复检后的最小结果，并继续回显最新验收真值。',
      tone: _ActionCardTone.emphasis,
      children: <Widget>[
        _InstanceSummaryLine(title: '当前里程碑 ID', value: milestoneId),
        if (inspectionId != null) ...<Widget>[
          const SizedBox(height: 12),
          _InstanceSummaryLine(title: '当前验收 ID', value: inspectionId),
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
            value: '验收复检入口已受理；页面已经刷新验收详情缓存。',
          ),
      ],
    );
  }
}
