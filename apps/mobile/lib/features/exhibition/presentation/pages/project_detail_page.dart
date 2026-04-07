part of '../exhibition_trade_pages.dart';

enum ProjectDetailSurface { standard, showcase }

class ProjectDetailPage extends StatefulWidget {
  const ProjectDetailPage({
    super.key,
    this.projectId,
    this.surface = ProjectDetailSurface.standard,
  });

  final String? projectId;
  final ProjectDetailSurface surface;

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  static const List<String> _ownerManageCandidateActions = <String>[
    '推广此项目',
    '编辑',
    '下架',
    '删除此项目',
  ];

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
    final snapshot = _snapshot;
    final result = snapshot?.result;

    return _LoadPageFrame(
      title: '项目详情',
      summary: '查看项目详情。',
      loading: _loading,
      result: result,
      onRetry: () => _load(forceRefresh: true),
      recoveryRouteOverride: _isShowcase ? ExhibitionRoutes.showcase : null,
      recoveryButtonLabelOverride: _isShowcase ? '回到项目展示' : null,
      showConnectionInfo: false,
      showTechnicalDisclosure: false,
      showPageSummaryCard: false,
      showContentStateCard: false,
      showSourceNotice: false,
      showFallbackNotice: false,
      resultSectionsBuilder: (ExhibitionLoadResult result) {
        final payload = _payloadMap(result.payload);
        final projectId = _projectIdFromPayload(result.payload);
        final projectNo = _normalizeId(payload?['projectNo'] as String?);
        final title = _normalizeId(payload?['title'] as String?);
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
        final hasSummary = summary is Map;
        final summaryMap = hasSummary
            ? summary.map(
                (Object? key, Object? value) => MapEntry('$key', value),
              )
            : null;
        if (result.state != AppPageState.content || projectId == null) {
          return const <Widget>[];
        }

        return <Widget>[
          const SizedBox(height: 16),
          _ActionCard(
            title: '项目概览',
            tone: _ActionCardTone.emphasis,
            children: <Widget>[
              _DetailLine(label: '项目编号', value: projectNo ?? '未提供'),
              _DetailLine(label: '项目名称', value: title ?? '未提供'),
              _DetailLine(
                label: '建筑类型',
                value: _buildingTypeLabel(buildingType),
              ),
              _DetailLine(
                label: '预算金额',
                value: _currencyText(budgetAmount),
                highlight: true,
              ),
              _DetailLine(label: '项目面积', value: _areaSqmOrUnavailable(areaSqm)),
              _DetailLine(
                label: '类型备注',
                value: _fieldOrUnavailable(buildingTypeRemark),
              ),
              if (state != null)
                _DetailLine(
                  label: '项目状态',
                  value: _frontStageStateLabel(state),
                  highlight: true,
                ),
              if (hasSummary)
                _DetailLine(
                  label: '项目摘要',
                  value:
                      _normalizeId(summaryMap?['heading'] as String?) ??
                      '当前项目暂未提供摘要。',
                ),
            ],
          ),
          const SizedBox(height: 16),
          _ActionCard(
            title: '地点与范围',
            children: <Widget>[
              if (_addressRangeFullyMissing(
                provinceName: provinceName,
                cityName: cityName,
                districtName: districtName,
                detailAddress: detailAddress,
                scopeSummary: scopeSummary,
                plannedStartAt: plannedStartAt,
                plannedEndAt: plannedEndAt,
                scheduleDetail: scheduleDetail,
              ))
                const _EmptyNotice(
                  title: '当前暂无地点与安排信息',
                  message: '当前项目暂未提供地点、范围或时间安排。',
                ),
              _DetailLine(label: '省', value: _fieldOrUnavailable(provinceName)),
              _DetailLine(label: '市', value: _fieldOrUnavailable(cityName)),
              _DetailLine(
                label: '区县',
                value: _fieldOrUnavailable(districtName),
              ),
              _DetailLine(
                label: '详细地址',
                value: _fieldOrUnavailable(detailAddress),
              ),
              _DetailLine(
                label: '范围说明',
                value: _fieldOrUnavailable(scopeSummary),
              ),
              _DetailLine(
                label: '计划开始日期',
                value: _fieldOrUnavailable(plannedStartAt),
              ),
              _DetailLine(
                label: '计划结束日期',
                value: _fieldOrUnavailable(plannedEndAt),
              ),
              _DetailLine(
                label: '详细时间',
                value: _fieldOrUnavailable(scheduleDetail),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ActionCard(
            title: '项目说明',
            children: <Widget>[
              if (description == null)
                const _EmptyNotice(title: '当前暂无补充说明', message: '当前项目暂未提供补充说明。'),
              _DetailLine(
                label: '补充说明',
                value: _fieldOrUnavailable(description),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isShowcase)
            _ActionCard(
              title: '项目资料',
              children: <Widget>[
                const _DetailLine(label: '附件', value: '当前公开详情暂未提供正式附件。'),
                const _DetailLine(
                  label: '当前说明',
                  value: '公开详情只展示当前已返回的项目资料与说明。',
                ),
                if (snapshot?.isDemo == true)
                  const _DetailLine(label: '数据来源', value: '当前为演示数据。'),
              ],
            )
          else
            _ProjectAttachmentSection(
              key: ValueKey<String>('project-detail-attachment-$projectId'),
              projectId: projectId,
              title: '项目附件',
              summary: '当前已返回的项目资料会显示在这里。',
              emptyMessage: '当前项目还没有返回正式项目附件结果。',
              showDemoNotice: snapshot?.isDemo == true,
            ),
          const SizedBox(height: 16),
          _ActionCard(
            title: _isOwnerSurface(viewerProjectRelation)
                ? '管理当前'
                : _canContinueBidFromState(state)
                ? '继续竞标'
                : '当前状态',
            children: <Widget>[
              _StateMessage(
                title: '当前说明',
                body: _isOwnerSurface(viewerProjectRelation)
                    ? _detailOwnerBody(state)
                    : _detailContinuationBody(state),
              ),
              if (_isOwnerSurface(viewerProjectRelation)) ...<Widget>[
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _showOwnerManageSheet,
                  child: const Text('管理当前'),
                ),
              ] else if (_canContinueBidFromState(state)) ...<Widget>[
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => _continueBidWithGuard(projectId),
                  child: const Text('继续竞标'),
                ),
              ],
            ],
          ),
        ];
      },
    );
  }

  bool get _isShowcase => widget.surface == ProjectDetailSurface.showcase;

  bool _isOwnerSurface(String? viewerProjectRelation) {
    return viewerProjectRelation == 'owner';
  }

  bool _canContinueBidFromState(String? state) => state == 'published';

  String _detailOwnerBody(String? state) {
    if (state == null) {
      return '当前项目由你发布，可在这里查看当前可见的管理项。';
    }

    return '当前项目处于 ${_frontStageStateLabel(state)}，可在这里查看当前可见的管理项。';
  }

  String _detailContinuationBody(String? state) {
    if (_canContinueBidFromState(state)) {
      return state == null
          ? '当前项目可以继续进入竞标。'
          : '当前项目处于 ${_frontStageStateLabel(state)}，如需继续主链路，下一步可以继续竞标。';
    }

    return switch (state) {
      'bidding_closed' => '当前项目投标已结束，当前页保留项目说明，不再继续竞标。',
      'awarded' => '当前项目已授标，后续处理回到项目工作台。',
      'converted_to_order' => '当前项目已进入订单链路，公开详情不继续后续私域动作。',
      _ => '当前项目暂不处于继续竞标阶段。',
    };
  }

  static bool _addressRangeFullyMissing({
    required String? provinceName,
    required String? cityName,
    required String? districtName,
    required String? detailAddress,
    required String? scopeSummary,
    required String? plannedStartAt,
    required String? plannedEndAt,
    required String? scheduleDetail,
  }) {
    return provinceName == null &&
        cityName == null &&
        districtName == null &&
        detailAddress == null &&
        scopeSummary == null &&
        plannedStartAt == null &&
        plannedEndAt == null &&
        scheduleDetail == null;
  }

  static String _areaSqmOrUnavailable(num? value) {
    if (value == null) {
      return '当前项目暂未提供';
    }

    final normalized = value
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'\.?0+$'), '');
    return '$normalized ㎡';
  }

  static String _fieldOrUnavailable(String? value) {
    return value ?? '当前项目暂未提供';
  }

  Future<void> _showOwnerManageSheet() {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isDismissible: true,
      enableDrag: true,
      builder: (BuildContext context) {
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '管理当前',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '当前可见管理项',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                for (final label in _ownerManageCandidateActions) ...<Widget>[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.45,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              label,
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (label != _ownerManageCandidateActions.last)
                    const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _continueBidWithGuard(String projectId) {
    final accessGuard = _deriveBidAccessGuard(
      snapshot: AppShellScope.read(context).snapshot,
      hasSession: AppSessionStore.instance.hasAnySession,
    );

    if (accessGuard == null) {
      Navigator.of(
        context,
      ).pushNamed(ExhibitionRoutes.bidSubmitWithProjectId(projectId));
      return;
    }

    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(SnackBar(content: Text(accessGuard.message)));
    Navigator.of(context).pushNamed(accessGuard.actionRouteName);
  }
}
