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
        final exhibitionName = _projectExhibitionName(projectMap);
        final brandName = _projectBrandName(projectMap);
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
        final headline = exhibitionName ?? title;
        final secondaryHeadline = exhibitionName != null
            ? brandName ??
                  _compatibilityTitle(headline: exhibitionName, title: title)
            : brandName;
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
          _ActionCard(
            title: '核心信息',
            tone: _ActionCardTone.emphasis,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          headline,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        if (secondaryHeadline != null) ...<Widget>[
                          const SizedBox(height: 6),
                          Text(
                            secondaryHeadline,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (state != null)
                    _StatusPill(
                      label: _frontStageStateLabel(state),
                      tone: _ActionCardTone.muted,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              _ProjectDetailCompactMetaGrid(
                items: <_ProjectDetailCompactMetaItemData>[
                  _ProjectDetailCompactMetaItemData(
                    label: '项目编号',
                    value: projectNo ?? '未提供',
                    fullWidth: true,
                  ),
                  _ProjectDetailCompactMetaItemData(
                    label: '项目类型',
                    value: _buildingTypeLabel(buildingType),
                  ),
                  _ProjectDetailCompactMetaItemData(
                    label: '预算金额',
                    value: _currencyText(budgetAmount),
                    highlight: true,
                  ),
                  _ProjectDetailCompactMetaItemData(
                    label: '项目面积',
                    value: _areaSqmOrUnavailable(areaSqm),
                  ),
                ],
              ),
              if (buildingTypeRemark != null) ...<Widget>[
                const SizedBox(height: 12),
                _DetailLine(label: '类型备注', value: buildingTypeRemark),
              ],
              if (summaryHeading != null) ...<Widget>[
                const SizedBox(height: 4),
                _DetailLine(label: '项目摘要', value: summaryHeading),
              ],
            ],
          ),
          const SizedBox(height: 16),
          _ActionCard(
            title: '地点与安排',
            children: <Widget>[
              if (arrangementMissing)
                const _EmptyNotice(
                  title: '当前暂无地点与安排信息',
                  message: '当前项目暂未提供地点、范围、说明或时间安排。',
                ),
              if (locationSummary != null)
                _DetailLine(label: '项目地点', value: locationSummary),
              if (scopeSummary != null)
                _DetailLine(label: '范围说明', value: scopeSummary),
              if (scheduleRange != null)
                _DetailLine(label: '计划时间', value: scheduleRange),
              if (scheduleDetail != null)
                _DetailLine(label: '时间说明', value: scheduleDetail),
              if (description != null)
                _DetailLine(label: '补充说明', value: description),
            ],
          ),
          const SizedBox(height: 16),
          _ActionCard(
            title: _isOwnerSurface(viewerProjectRelation)
                ? '继续处理'
                : _canContinueBidFromState(state)
                ? '参与竞标'
                : _canReadBidResultFromState(state)
                ? '竞标结果'
                : '当前状态',
            children: <Widget>[
              _StateMessage(
                title: '当前说明',
                body: _isOwnerSurface(viewerProjectRelation)
                    ? _ownerContinuationBody(state)
                    : _detailContinuationBody(state),
              ),
              if (_isOwnerSurface(viewerProjectRelation)) ...<Widget>[
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      ExhibitionRoutes.myProjectDetailWithProjectId(projectId),
                    );
                  },
                  child: const Text('进入我的项目'),
                ),
              ] else if (_canContinueBidFromState(state)) ...<Widget>[
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => _continueBidWithGuard(projectId),
                  child: const Text('立即参与竞标'),
                ),
              ] else if (_canReadBidResultFromState(state)) ...<Widget>[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => _openBidResultWithGuard(projectId),
                  child: const Text('查看竞标结果'),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          _buildTradingImEntryCard(
            projectId: projectId,
            bidId: _normalizeId(payload?['bidId'] as String?),
            canStartBid:
                !_isOwnerSurface(viewerProjectRelation) &&
                _canContinueBidFromState(state),
          ),
        ];
      },
    );
  }

  Widget _buildTradingImEntryCard({
    required String projectId,
    required String? bidId,
    required bool canStartBid,
  }) {
    return _ActionCard(
      title: '项目沟通',
      children: <Widget>[
        const _StateMessage(
          title: '当前对象',
          body: '项目澄清面向当前项目；沟通与投标需要承接具体 bidId。',
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pushNamed(
                ExhibitionRoutes.projectClarificationWithProjectId(projectId),
              ),
              icon: const Icon(Icons.forum_rounded),
              label: const Text('项目澄清'),
            ),
            if (bidId != null)
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pushNamed(
                  ExhibitionRoutes.bidThreadWithIds(
                    projectId: projectId,
                    bidId: bidId,
                  ),
                ),
                icon: const Icon(Icons.handshake_rounded),
                label: const Text('沟通与投标'),
              )
            else if (canStartBid)
              OutlinedButton.icon(
                onPressed: () => _continueBidWithGuard(projectId),
                icon: const Icon(Icons.handshake_rounded),
                label: const Text('先参与竞标'),
              ),
          ],
        ),
      ],
    );
  }

  bool _isOwnerSurface(String? viewerProjectRelation) {
    return viewerProjectRelation == 'owner';
  }

  bool _canContinueBidFromState(String? state) => state == 'published';

  bool _canReadBidResultFromState(String? state) {
    return state == 'awarded' || state == 'converted_to_order';
  }

  String _ownerContinuationBody(String? state) {
    if (state == null) {
      return '你是当前项目发布方。当前页只保留公域展示；继续处理请进入我的项目。';
    }

    return '你是当前项目发布方。当前项目处于 ${_frontStageStateLabel(state)}；当前页仍只承接公开展示，继续处理请进入我的项目。';
  }

  String _detailContinuationBody(String? state) {
    if (_canContinueBidFromState(state)) {
      return state == null
          ? '当前项目仍处于公开展示阶段，如需继续主链路可立即参与竞标；竞标资格当前要求主体属于供应商或需求方/供应商组织，且企业认证与我的认证同时通过。'
          : '当前项目处于 ${_frontStageStateLabel(state)}；当前页只承接公开展示，下一步可立即参与竞标。竞标资格当前要求主体属于供应商或需求方/供应商组织，且企业认证与我的认证同时通过。';
    }

    return switch (state) {
      'bidding_closed' => '当前项目投标已结束；当前页继续保留公开展示，不再开放参与竞标。',
      'awarded' => '当前项目已授标；如你属于竞标方，可继续进入最小竞标结果读取出口。',
      'converted_to_order' => '当前项目已被承接；如你属于竞标方，可继续读取最小竞标结果。',
      _ => '当前项目暂不处于参与竞标阶段，当前页继续只读展示公开信息。',
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

  static String? _compatibilityTitle({
    required String headline,
    required String title,
  }) {
    return headline == title ? null : title;
  }

  static String? _locationSummary({
    required String? provinceName,
    required String? cityName,
    required String? districtName,
    required String? detailAddress,
  }) {
    final regionParts = <String?>[
      provinceName,
      cityName,
      districtName,
    ].nonNulls.toList(growable: false);
    final regionLabel = regionParts.isEmpty ? null : regionParts.join(' / ');
    if (regionLabel == null && detailAddress == null) {
      return null;
    }
    if (regionLabel != null && detailAddress != null) {
      return '$regionLabel · $detailAddress';
    }
    return regionLabel ?? detailAddress;
  }

  static String? _scheduleRangeSummary({
    required String? plannedStartAt,
    required String? plannedEndAt,
  }) {
    if (plannedStartAt == null && plannedEndAt == null) {
      return null;
    }
    return '${_fieldOrUnavailable(plannedStartAt)} 至 ${_fieldOrUnavailable(plannedEndAt)}';
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
    Navigator.of(
      context,
    ).pushNamed(_resolveBidGuardRouteName(accessGuard, projectId: projectId));
  }

  Future<void> _openBidResultWithGuard(String projectId) async {
    final shellGuard = _deriveBidAccessGuard(
      snapshot: AppShellScope.read(context).snapshot,
      hasSession: AppSessionStore.instance.hasAnySession,
    );
    if (shellGuard != null) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.hideCurrentSnackBar();
      messenger?.showSnackBar(SnackBar(content: Text(shellGuard.message)));
      Navigator.of(
        context,
      ).pushNamed(_resolveBidGuardRouteName(shellGuard, projectId: projectId));
      return;
    }

    final detailResult = await ExhibitionConsumerLayer.instance
        .loadProjectDetail(projectId: projectId);
    if (!mounted) {
      return;
    }

    final projectGuard = _deriveBidResultProjectAccessGuard(
      projectId: projectId,
      detailResult: detailResult,
    );
    if (projectGuard != null) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.hideCurrentSnackBar();
      messenger?.showSnackBar(SnackBar(content: Text(projectGuard.message)));
      Navigator.of(context).pushNamed(
        _resolveBidGuardRouteName(projectGuard, projectId: projectId),
      );
      return;
    }

    Navigator.of(
      context,
    ).pushNamed(ExhibitionRoutes.bidResultWithProjectId(projectId));
  }
}
