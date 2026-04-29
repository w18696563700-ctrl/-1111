part of '../exhibition_trade_pages.dart';

class ProjectDetailPage extends StatefulWidget {
  const ProjectDetailPage({super.key, this.projectId});

  final String? projectId;

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  late final ExhibitionStageLoadAutoSource _source =
      ExhibitionStageLoadAutoSource(
        futureRealLoader: ({bool forceRefresh = false}) {
          return ExhibitionConsumerLayer.instance.loadProjectDetail(
            projectId: widget.projectId,
            forceRefresh: forceRefresh,
          );
        },
        demoBuilder: () => ExhibitionStageDemoCatalog.projectDetail(
          projectId: widget.projectId,
        ),
      );

  ExhibitionStageLoadSnapshot? _snapshot;
  ExhibitionLoadResult? _p0PaySummaryResult;
  bool _loading = false;
  bool _p0PaySummaryLoading = false;
  bool _requestingNameAccess = false;
  int _p0PaySummaryLoadToken = 0;

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

    await _loadP0PaySummaryForSnapshot(snapshot, forceRefresh: forceRefresh);
  }

  Future<void> _loadP0PaySummaryForSnapshot(
    ExhibitionStageLoadSnapshot snapshot, {
    required bool forceRefresh,
  }) async {
    final result = snapshot.result;
    final projectId = _projectIdFromPayload(result.payload);
    if (result.state != AppPageState.content || projectId == null) {
      setState(() {
        _p0PaySummaryResult = null;
        _p0PaySummaryLoading = false;
      });
      return;
    }

    final loadToken = ++_p0PaySummaryLoadToken;
    setState(() {
      _p0PaySummaryLoading = true;
      _p0PaySummaryResult = null;
    });

    final summary = await ExhibitionConsumerLayer.instance
        .loadProjectPricingSummary(
          projectId: projectId,
          forceRefresh: forceRefresh,
        );
    if (!mounted || loadToken != _p0PaySummaryLoadToken) {
      return;
    }
    setState(() {
      _p0PaySummaryResult = summary;
      _p0PaySummaryLoading = false;
    });
  }

  Future<bool> _requestProjectNameAccess(String projectId) async {
    if (_requestingNameAccess) {
      return false;
    }
    setState(() => _requestingNameAccess = true);
    final result = await ProjectNameAccessConsumerLayer.instance
        .requestBidParticipation(projectId: projectId);
    if (!mounted) {
      return false;
    }
    setState(() => _requestingNameAccess = false);
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      SnackBar(
        content: Text(
          result.isSuccess
              ? '已提交参与竞标申请，等待发布方审批。'
              : (result.message ?? '当前申请未完成，请稍后再试。'),
        ),
      ),
    );
    if (result.isSuccess) {
      await _load(forceRefresh: true);
    }
    return result.isSuccess;
  }

  void _showProjectNameAccessSheet({
    required String projectId,
    required Map<String, Object?> projectMap,
  }) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return ProjectNameAccessPermissionSheet(
          projectMap: projectMap,
          requesting: _requestingNameAccess,
          onRequest: () async {
            final succeeded = await _requestProjectNameAccess(projectId);
            if (succeeded && sheetContext.mounted) {
              Navigator.of(sheetContext).maybePop();
            }
          },
          onOpenStatus: () {
            final requestId = _projectNameAccessRequestId(projectMap);
            if (requestId == null) {
              return;
            }
            Navigator.of(sheetContext).maybePop();
            Navigator.of(context).pushNamed(
              ExhibitionRoutes.bidParticipationThreadWithIds(
                threadId: requestId,
                projectId: projectId,
                requestId: requestId,
              ),
            );
          },
          onRefresh: () async {
            await _load(forceRefresh: true);
            if (sheetContext.mounted) {
              Navigator.of(sheetContext).maybePop();
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    final result = snapshot?.result;

    return _LoadPageFrame(
      title: '项目详情',
      summary: '查看公域项目展示详情，只读消费公开字段；退出公域展示不等于项目不存在，也不等于 owner 私域不可见。',
      loading: _loading,
      result: result,
      onRetry: () => _load(forceRefresh: true),
      recoveryRouteOverride: ExhibitionRoutes.projectList,
      recoveryButtonLabelOverride: '回到项目展示',
      sourceLabel: snapshot?.isDemo == true ? snapshot?.sourceLabel : null,
      sourceMessage: snapshot?.isDemo == true ? snapshot?.sourceMessage : null,
      fallbackTitle: snapshot?.fallbackTitle,
      fallbackMessage: snapshot?.fallbackMessage,
      showConnectionInfo: false,
      showTechnicalDisclosure: false,
      showPageSummaryCard: false,
      showContentStateCard: false,
      resultSectionsBuilder: (ExhibitionLoadResult result) {
        final payload = _payloadMap(result.payload);
        final projectId = _projectIdFromPayload(result.payload);
        final projectNo = _normalizeId(payload?['projectNo'] as String?);
        final projectMap = payload ?? const <String, Object?>{};
        final embeddedP0PaySummary = parseP0PayReadOnlySummary(
          projectMap['pricingSummary'] ?? projectMap['p0PaySummary'],
        );
        final p0PaySummary =
            parseP0PayReadOnlySummary(_p0PaySummaryResult?.payload) ??
            embeddedP0PaySummary;
        final brandName = _projectDisplayBrandLine(projectMap);
        final title = _projectDisplayTitle(projectMap);
        final buildingType = _normalizeId(payload?['buildingType'] as String?);
        final budgetAmount = payload?['budgetAmount'];
        final areaSqm = payload?['areaSqm'] as num?;
        final buildingTypeRemark = _normalizeId(
          payload?['buildingTypeRemark'] as String?,
        );
        final description = _normalizeId(payload?['description'] as String?);
        final provinceName = _normalizeId(payload?['provinceName'] as String?);
        final cityName = _normalizeId(payload?['cityName'] as String?);
        final districtName = _normalizeId(payload?['districtName'] as String?);
        final detailAddress = _normalizeId(
          payload?['detailAddress'] as String?,
        );
        final scopeSummary = _normalizeId(payload?['scopeSummary'] as String?);
        final plannedStartAt = _normalizeId(
          payload?['plannedStartAt'] as String?,
        );
        final plannedEndAt = _normalizeId(payload?['plannedEndAt'] as String?);
        final scheduleDetail = _normalizeId(
          payload?['scheduleDetail'] as String?,
        );
        final viewerProjectRelation = _normalizeId(
          payload?['viewerProjectRelation'] as String?,
        );
        final state = _stateFromPayload(result.payload);
        final summary = payload?['summary'];
        final summaryMap = summary is Map
            ? summary.map(
                (Object? key, Object? value) => MapEntry('$key', value),
              )
            : null;
        final summaryHeading = _normalizeId(summaryMap?['heading'] as String?);
        final headline = title;
        final secondaryHeadline = brandName;
        final locationSummary = _locationSummary(
          provinceName: provinceName,
          cityName: cityName,
          districtName: districtName,
          detailAddress: detailAddress,
        );
        final scheduleRange = _scheduleRangeSummary(
          plannedStartAt: plannedStartAt,
          plannedEndAt: plannedEndAt,
        );
        final arrangementMissing =
            _addressRangeFullyMissing(
              provinceName: provinceName,
              cityName: cityName,
              districtName: districtName,
              detailAddress: detailAddress,
              scopeSummary: scopeSummary,
              plannedStartAt: plannedStartAt,
              plannedEndAt: plannedEndAt,
              scheduleDetail: scheduleDetail,
            ) &&
            description == null;
        if (result.state != AppPageState.content || projectId == null) {
          return const <Widget>[];
        }

        return <Widget>[
          const SizedBox(height: 16),
          _buildProjectOverviewCard(
            projectId: projectId,
            projectNo: projectNo,
            headline: headline,
            secondaryHeadline: secondaryHeadline,
            projectMap: projectMap,
            buildingType: buildingType,
            budgetAmount: budgetAmount,
            areaSqm: areaSqm,
            buildingTypeRemark: buildingTypeRemark,
            summaryHeading: summaryHeading,
            arrangementMissing: arrangementMissing,
            locationSummary: locationSummary,
            scopeSummary: scopeSummary,
            scheduleRange: scheduleRange,
            scheduleDetail: scheduleDetail,
            description: description,
            state: state,
            viewerProjectRelation: viewerProjectRelation,
          ),
          const SizedBox(height: 16),
          if (_isOwnerSurface(viewerProjectRelation)) ...<Widget>[
            _buildOwnerBidSelectionCard(
              projectId: projectId,
              state: state,
              projectMap: projectMap,
            ),
            const SizedBox(height: 16),
          ],
          if (_orderIdFromProjectMap(projectMap) != null) ...<Widget>[
            _OrderStatusCard(
              orderId: _orderIdFromProjectMap(projectMap)!,
              projectId: projectId,
              placement: _OrderStatusPlacement.projectDetail,
              onChanged: () => _load(forceRefresh: true),
            ),
            const SizedBox(height: 16),
          ],
          if (_shouldShowP0PayReadOnlySummary(
            p0PaySummary,
            _p0PaySummaryResult,
          )) ...<Widget>[
            _buildProjectDetailP0PayReadOnlyCard(
              summary: p0PaySummary,
              result: _p0PaySummaryResult,
              loading: _p0PaySummaryLoading,
              embeddedFallbackAvailable: embeddedP0PaySummary != null,
              onRefresh: () =>
                  _loadP0PaySummaryForSnapshot(snapshot!, forceRefresh: true),
            ),
            const SizedBox(height: 16),
          ],
        ];
      },
    );
  }
}

bool _shouldShowP0PayReadOnlySummary(
  P0PayReadOnlySummaryView? summary,
  ExhibitionLoadResult? result,
) {
  return summary != null ||
      result?.state == AppPageState.content ||
      result?.errorCode == 'P0_PAY_SUMMARY_UNAVAILABLE' ||
      result?.errorCode == 'AUTH_SESSION_INVALID' ||
      result?.errorCode == 'TRADE_TASK_INVALID_STATE';
}

Widget _buildProjectDetailP0PayReadOnlyCard({
  required P0PayReadOnlySummaryView? summary,
  required ExhibitionLoadResult? result,
  required bool loading,
  required bool embeddedFallbackAvailable,
  required VoidCallback onRefresh,
}) {
  final statusLines = summary?.statusLines ?? const <P0PayReadOnlyStatusLine>[];
  final failureText = _projectDetailP0PayFailureText(result);
  final routeTarget = summary?.routeTarget;
  return _ActionCard(
    title: '平台收费只读状态',
    summary: '这里只展示 BFF/Server 聚合后的收费与预授权状态，不执行支付、不修改资金状态、不裁定扣费。',
    tone: _ActionCardTone.muted,
    children: <Widget>[
      const _StateMessage(
        title: '只读边界',
        body:
            '项目详情只承接 200 元项目真实性诚意金、4000 元竞标服务费预授权额度、成交确认 handoff 的只读摘要；Flutter 不接收支付回调，也不生成资金真相。',
      ),
      if (loading) ...<Widget>[
        const SizedBox(height: 12),
        const LinearProgressIndicator(minHeight: 6),
      ],
      if (!loading && statusLines.isNotEmpty) ...<Widget>[
        const SizedBox(height: 12),
        ...statusLines.map(
          (P0PayReadOnlyStatusLine line) =>
              _DetailLine(label: line.label, value: line.value),
        ),
      ],
      if (!loading && routeTarget != null) ...<Widget>[
        const SizedBox(height: 8),
        _DetailLine(
          label: '只读 routeTarget',
          value: routeTarget.displayText.isEmpty
              ? 'BFF 已返回只读 handoff'
              : routeTarget.displayText,
        ),
      ],
      if (!loading && summary?.updatedAt != null)
        _DetailLine(label: '更新时间', value: summary!.updatedAt!),
      if (!loading && failureText != null) ...<Widget>[
        const SizedBox(height: 12),
        _StateMessage(title: '只读状态暂不可用', body: failureText),
      ],
      if (!loading && !embeddedFallbackAvailable) ...<Widget>[
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('刷新只读状态'),
          ),
        ),
      ],
    ],
  );
}

String? _projectDetailP0PayFailureText(ExhibitionLoadResult? result) {
  if (result == null || result.state == AppPageState.content) {
    return null;
  }
  return switch (result.errorCode) {
    'AUTH_SESSION_INVALID' => '登录状态失效后不能读取资金状态，请重新登录。',
    'TRADE_TASK_INVALID_STATE' => '当前交易任务状态暂不可读取 P0-Pay 摘要。',
    'P0_PAY_SUMMARY_UNAVAILABLE' => '当前 P0-Pay 摘要暂不可用，请稍后刷新。',
    _ => result.message ?? result.errorCode ?? '当前 P0-Pay 摘要暂不可用。',
  };
}
