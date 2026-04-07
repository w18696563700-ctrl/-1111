part of '../exhibition_trade_pages.dart';

class MyProjectDetailPage extends StatefulWidget {
  const MyProjectDetailPage({super.key, this.projectId});

  final String? projectId;

  @override
  State<MyProjectDetailPage> createState() => _MyProjectDetailPageState();
}

class _MyProjectDetailPageState extends State<MyProjectDetailPage> {
  static const List<String> _ownerManageCandidateActions = <String>[
    '推广此项目',
    '编辑',
    '下架',
    '删除此项目',
  ];

  late final ExhibitionStageLoadAutoSource _source =
      ExhibitionStageLoadAutoSource(
        futureRealLoader: ({bool forceRefresh = false}) {
          return ExhibitionConsumerLayer.instance.loadMyProjectDetail(
            projectId: widget.projectId,
            forceRefresh: forceRefresh,
          );
        },
        demoBuilder: () => ExhibitionStageDemoCatalog.myProjectDetail(
          projectId: widget.projectId,
        ),
      );

  ExhibitionStageLoadSnapshot? _snapshot;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool forceRefresh = false}) async {
    setState(() => _loading = true);
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
      summary: '查看项目详情与当前进度。',
      loading: _loading,
      result: result,
      onRetry: () => _load(forceRefresh: true),
      recoveryRouteOverride: ExhibitionRoutes.myProjectList,
      recoveryButtonLabelOverride: '回到我的项目',
      showConnectionInfo: false,
      showTechnicalDisclosure: false,
      showPageSummaryCard: false,
      showContentStateCard: false,
      showSourceNotice: false,
      showFallbackNotice: false,
      resultSectionsBuilder: (ExhibitionLoadResult result) {
        if (result.state != AppPageState.content) {
          return const <Widget>[];
        }

        final payload = _payloadMap(result.payload);
        final publicProject = payload?['publicProject'];
        final privateProgress = payload?['privateProgress'];
        final publicMap = publicProject is Map
            ? publicProject.map(
                (Object? key, Object? value) => MapEntry('$key', value),
              )
            : null;
        final privateMap = privateProgress is Map
            ? privateProgress.map(
                (Object? key, Object? value) => MapEntry('$key', value),
              )
            : null;
        if (publicMap == null || privateMap == null) {
          return const <Widget>[];
        }

        final projectNo = _normalizeId(publicMap['projectNo'] as String?);
        final title = _normalizeId(publicMap['title'] as String?);
        final buildingType = _normalizeId(publicMap['buildingType'] as String?);
        final budgetAmount = publicMap['budgetAmount'];
        final areaSqm = publicMap['areaSqm'] as num?;
        final buildingTypeRemark = _normalizeId(
          publicMap['buildingTypeRemark'] as String?,
        );
        final state = _normalizeId(publicMap['state'] as String?);
        final viewerProjectRelation = _normalizeId(
          publicMap['viewerProjectRelation'] as String?,
        );
        final summaryHeading = _myProjectSummaryHeading(publicMap);
        final provinceName = _normalizeId(publicMap['provinceName'] as String?);
        final cityName = _normalizeId(publicMap['cityName'] as String?);
        final districtName = _normalizeId(publicMap['districtName'] as String?);
        final detailAddress = _normalizeId(
          publicMap['detailAddress'] as String?,
        );
        final scopeSummary = _normalizeId(publicMap['scopeSummary'] as String?);
        final plannedStartAt = _normalizeId(
          publicMap['plannedStartAt'] as String?,
        );
        final plannedEndAt = _normalizeId(publicMap['plannedEndAt'] as String?);
        final scheduleDetail = _normalizeId(
          publicMap['scheduleDetail'] as String?,
        );
        final description = _normalizeId(publicMap['description'] as String?);

        return <Widget>[
          const SizedBox(height: 16),
          _ActionCard(
            title: '项目信息',
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
              _DetailLine(label: '项目面积', value: _areaOrUnavailable(areaSqm)),
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
              _DetailLine(
                label: '项目摘要',
                value: summaryHeading ?? '当前项目暂未提供摘要。',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ActionCard(
            title: '项目地点与安排',
            children: <Widget>[
              if (_publicAddressFullyMissing(
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
          _ActionCard(
            title: '当前进度',
            tone: _ActionCardTone.emphasis,
            children: <Widget>[
              _DetailLine(
                label: '进度摘要',
                value: _myProjectPrivateSummaryText(privateMap),
                highlight: true,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _myProjectPrivateSummaryPills(privateMap).map((
                  String item,
                ) {
                  return _StatusPill(label: item, tone: _ActionCardTone.muted);
                }).toList(),
              ),
              const SizedBox(height: 12),
              _DetailLine(
                label: '是否已接单',
                value: _myProjectAcceptedOrderLabel(
                  privateMap['hasAcceptedOrder'] == true,
                ),
              ),
              _DetailLine(
                label: '当前订单状态',
                value: _myProjectOrderStatusLabel(
                  privateMap['orderStatus'] as String?,
                ),
              ),
              _DetailLine(
                label: '合同状态',
                value: _myProjectContractStatusLabel(
                  privateMap['contractStatus'] as String?,
                ),
              ),
              _DetailLine(
                label: '履约进度',
                value: _myProjectFulfillmentStatusLabel(
                  privateMap['fulfillmentStatus'] as String?,
                ),
              ),
              _DetailLine(
                label: '验收状态',
                value: _myProjectAcceptanceStatusLabel(
                  privateMap['acceptanceStatus'] as String?,
                ),
              ),
              _DetailLine(
                label: '争议 / 售后状态',
                value: _myProjectAfterSalesStatusLabel(
                  privateMap['afterSalesOrDisputeStatus'] as String?,
                ),
              ),
              _DetailLine(
                label: '正式完结',
                value: _myProjectFormalCompletionLabel(
                  privateMap['formalCompletionStatus'] as String?,
                ),
                highlight:
                    _normalizeId(
                      privateMap['formalCompletionStatus'] as String?,
                    ) ==
                    'formally_completed',
              ),
              _DetailLine(
                label: '评价状态',
                value: _myProjectEvaluationLabel(
                  privateMap['evaluationStatus'] as String?,
                ),
                highlight:
                    _normalizeId(privateMap['evaluationStatus'] as String?) ==
                    'eligible',
              ),
            ],
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
              ],
            ],
          ),
        ];
      },
    );
  }

  bool _isOwnerSurface(String? viewerProjectRelation) {
    return viewerProjectRelation == 'owner';
  }

  bool _canContinueBidFromState(String? state) => state == 'published';

  String _detailOwnerBody(String? state) {
    if (state == null) {
      return '当前项目由当前组织发布，可在这里查看当前可见的管理项。';
    }

    return '当前项目处于 ${_frontStageStateLabel(state)}，可在这里查看当前可见的管理项。';
  }

  String _detailContinuationBody(String? state) {
    if (_canContinueBidFromState(state)) {
      return '当前项目仍处于公开阶段；如需继续竞标，请按现有公域主线办理。';
    }

    return switch (state) {
      'bidding_closed' => '当前项目投标已结束，这里继续保留项目信息与当前进度。',
      'awarded' => '当前项目已授标，这里继续保留项目信息与当前进度。',
      'converted_to_order' => '当前项目已进入订单链路，这里继续保留项目信息与当前进度。',
      _ => '当前项目暂不处于继续竞标阶段。',
    };
  }

  static bool _publicAddressFullyMissing({
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

  static String _areaOrUnavailable(num? value) {
    return value == null ? '当前项目暂未提供' : _myProjectAreaLabel(value);
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
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
