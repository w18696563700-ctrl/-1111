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
    final routeMilestoneId = _normalizeId(widget.milestoneId);
    final snapshot = _snapshot;
    final result = snapshot?.result;

    return _LoadPageFrame(
      title: '验收详情',
      summary: '这里承接当前验收状态。草稿态可以继续验收提交，已提交和已复检会停留在结果承接面，不把复检放成首发必走路径。',
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
      'draft' => '当前动作：可以继续验收提交',
      'submitted' => '当前动作：当前保持结果承接',
      _ => '当前动作：当前保持只读',
    };
    final nextStep = switch (inspectionState) {
      'draft' => '提交完成后，页面会继续承接已提交验收状态，并停留在当前结果页。',
      'submitted' => '当前验收已经提交完成，首发阶段先停留在已提交承接面，不继续放开复检主链。',
      'rechecked' => '当前验收已经完成复检，页面保持只读承接，不再继续放开动作。',
      _ => '当前验收停留在受控承接面，后续不会在这里展开整改或治理闭环。',
    };

    return <Widget>[
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
          'draft' => '当前验收还未提交，现在先完成提交，后续结果继续由这条链路承接。',
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
      const SizedBox(height: 12),
      _StateMessage(title: '后续如何继续', body: nextStep),
    ];

    if (inspectionState == 'draft') {
      children.addAll(<Widget>[
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pushNamed(
              ExhibitionRoutes.inspectionSubmitWithMilestoneId(milestoneId),
            );
          },
          child: const Text('继续验收提交'),
        ),
      ]);
    } else if (inspectionState == 'submitted') {
      children.addAll(<Widget>[
        const SizedBox(height: 12),
        const _EmptyNotice(
          title: '当前冻结',
          message: '复检链路当前阶段不开放。当前页只继续展示已提交结果，不放开新的继续动作。',
        ),
      ]);
    }

    return children;
  }
}
