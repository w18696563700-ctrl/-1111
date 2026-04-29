part of '../exhibition_trade_pages.dart';

extension _ProjectDetailActionsSupport on _ProjectDetailPageState {
  Widget _buildProjectOverviewCard({
    required String projectId,
    required String? projectNo,
    required String headline,
    required String? secondaryHeadline,
    required Map<String, Object?> projectMap,
    required String? buildingType,
    required Object? budgetAmount,
    required num? areaSqm,
    required String? buildingTypeRemark,
    required String? summaryHeading,
    required bool arrangementMissing,
    required String? locationSummary,
    required String? scopeSummary,
    required String? scheduleRange,
    required String? scheduleDetail,
    required String? description,
    required String? state,
    required String? viewerProjectRelation,
  }) {
    return _ProjectDetailOverviewCard(
      title: '项目概要',
      statusLabel: state == null ? null : _frontStageStateLabel(state),
      children: <Widget>[
        _buildProjectOverviewHeadline(
          projectId: projectId,
          projectMap: projectMap,
          headline: headline,
          secondaryHeadline: secondaryHeadline,
          viewerProjectRelation: viewerProjectRelation,
        ),
        const SizedBox(height: 16),
        _ProjectDetailCompactMetaGrid(
          items: _projectOverviewMetaItems(
            projectNo: projectNo,
            buildingType: buildingType,
            budgetAmount: budgetAmount,
            areaSqm: areaSqm,
          ),
        ),
        ..._projectOverviewExtraLines(
          buildingTypeRemark: buildingTypeRemark,
          summaryHeading: summaryHeading,
          arrangementMissing: arrangementMissing,
          locationSummary: locationSummary,
          scopeSummary: scopeSummary,
          scheduleRange: scheduleRange,
          scheduleDetail: scheduleDetail,
          description: description,
        ),
        const SizedBox(height: 12),
        Divider(color: Theme.of(context).colorScheme.outlineVariant),
        const SizedBox(height: 12),
        _buildProjectPrimaryActionSection(
          projectId: projectId,
          projectMap: projectMap,
          currentViewerBidId: _currentViewerBidIdFromPayload(projectMap),
          currentViewerBidState: _currentViewerBidStateFromPayload(projectMap),
          state: state,
          viewerProjectRelation: viewerProjectRelation,
        ),
      ],
    );
  }

  Widget _buildProjectOverviewHeadline({
    required String projectId,
    required Map<String, Object?> projectMap,
    required String headline,
    required String? secondaryHeadline,
    required String? viewerProjectRelation,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _ProjectDetailHeadline(
          headline: headline,
          accessControlled:
              _projectShouldShowNameAccessControls(projectMap) &&
              !_isOwnerSurface(viewerProjectRelation),
          onTap: () => _showProjectNameAccessSheet(
            projectId: projectId,
            projectMap: projectMap,
          ),
        ),
        if (secondaryHeadline != null) ...<Widget>[
          const SizedBox(height: 6),
          Text(
            secondaryHeadline,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  List<_ProjectDetailCompactMetaItemData> _projectOverviewMetaItems({
    required String? projectNo,
    required String? buildingType,
    required Object? budgetAmount,
    required num? areaSqm,
  }) {
    return <_ProjectDetailCompactMetaItemData>[
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
        label: '项目面积',
        value: _projectAreaText(areaSqm),
      ),
      _ProjectDetailCompactMetaItemData(
        label: '预算金额',
        value: _currencyText(budgetAmount),
        highlight: true,
        fullWidth: true,
      ),
    ];
  }

  List<Widget> _projectOverviewExtraLines({
    required String? buildingTypeRemark,
    required String? summaryHeading,
    required bool arrangementMissing,
    required String? locationSummary,
    required String? scopeSummary,
    required String? scheduleRange,
    required String? scheduleDetail,
    required String? description,
  }) {
    return <Widget>[
      if (buildingTypeRemark != null) ...<Widget>[
        const SizedBox(height: 12),
        _DetailLine(label: '类型备注', value: buildingTypeRemark),
      ],
      if (summaryHeading != null) ...<Widget>[
        const SizedBox(height: 4),
        _DetailLine(label: '项目摘要', value: summaryHeading),
      ],
      const SizedBox(height: 8),
      if (arrangementMissing)
        const _EmptyNotice(
          title: '当前暂无地点与安排信息',
          message: '当前项目暂未提供地点、范围、说明或时间安排。',
        ),
      if (locationSummary != null)
        _DetailLine(label: '项目地点', value: locationSummary),
      if (scopeSummary != null) _DetailLine(label: '范围说明', value: scopeSummary),
      if (scheduleRange != null)
        _DetailLine(label: '计划时间', value: scheduleRange),
      if (scheduleDetail != null)
        _DetailLine(label: '时间说明', value: scheduleDetail),
      if (description != null) _DetailLine(label: '补充说明', value: description),
    ];
  }

  Widget _buildProjectPrimaryActionSection({
    required String projectId,
    required Map<String, Object?> projectMap,
    required String? currentViewerBidId,
    required String? currentViewerBidState,
    required String? state,
    required String? viewerProjectRelation,
  }) {
    final ownerSurface = _isOwnerSurface(viewerProjectRelation);
    final hasCurrentViewerBid = currentViewerBidId != null;
    final canContinueBid = !ownerSurface && _canContinueBidFromState(state);
    final nameAccessStatus = _projectNameAccessStatus(projectMap);
    final canRequestParticipation = _projectCanRequestNameAccess(projectMap);
    final participationApproved =
        nameAccessStatus == null || nameAccessStatus == 'visible';
    final canReadBidResult =
        !ownerSurface &&
        !hasCurrentViewerBid &&
        _canReadBidResultFromState(state);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          ownerSurface
              ? '继续处理'
              : hasCurrentViewerBid
              ? '已提交竞标'
              : canContinueBid
              ? participationApproved
                    ? '参与竞标'
                    : '申请参与竞标'
              : canReadBidResult
              ? '竞标结果'
              : '当前状态',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          _projectPrimaryActionBody(
            state,
            ownerSurface: ownerSurface,
            currentViewerBidId: currentViewerBidId,
            currentViewerBidState: currentViewerBidState,
            projectMap: projectMap,
          ),
        ),
        const SizedBox(height: 12),
        if (ownerSurface)
          FilledButton(
            onPressed: () => Navigator.of(context).pushNamed(
              ExhibitionRoutes.myProjectDetailWithProjectId(projectId),
            ),
            child: const Text('进入我的项目'),
          )
        else if (currentViewerBidId != null)
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pushNamed(
              ExhibitionRoutes.bidThreadWithIds(
                projectId: projectId,
                bidId: currentViewerBidId,
              ),
            ),
            icon: const Icon(Icons.handshake_rounded),
            label: const Text('沟通与投标'),
          )
        else if (canContinueBid && participationApproved)
          FilledButton(
            onPressed: () => _continueBidWithGuard(projectId),
            child: const Text('继续提交竞标'),
          )
        else if (canContinueBid && canRequestParticipation)
          FilledButton(
            onPressed: _requestingNameAccess
                ? null
                : () => _requestProjectNameAccess(projectId),
            child: Text(
              _requestingNameAccess
                  ? '提交中...'
                  : _projectNameAccessActionLabel(projectMap),
            ),
          )
        else if (canContinueBid && nameAccessStatus == 'pending')
          FilledButton.tonal(
            onPressed: () => _showProjectNameAccessSheet(
              projectId: projectId,
              projectMap: projectMap,
            ),
            child: const Text('参与申请审核中'),
          )
        else if (canContinueBid && nameAccessStatus == 'rejected')
          OutlinedButton(
            onPressed: canRequestParticipation
                ? () => _requestProjectNameAccess(projectId)
                : null,
            child: const Text('参与申请已拒绝'),
          )
        else if (canReadBidResult)
          OutlinedButton(
            onPressed: () => _openBidResultWithGuard(projectId),
            child: const Text('查看竞标结果'),
          ),
      ],
    );
  }

  String _projectPrimaryActionBody(
    String? state, {
    required bool ownerSurface,
    required String? currentViewerBidId,
    required String? currentViewerBidState,
    required Map<String, Object?> projectMap,
  }) {
    if (ownerSurface) {
      return '你是当前项目发布方，可进入我的项目继续处理。';
    }
    if (currentViewerBidId != null) {
      final stateLabel = currentViewerBidState == null
          ? null
          : _frontStageStateLabel(currentViewerBidState);
      return stateLabel == null
          ? '当前账号已对该项目提交竞标，本页不再开放重复提交。'
          : '当前账号已对该项目提交竞标，竞标状态：$stateLabel。';
    }
    final nameAccessStatus = _projectNameAccessStatus(projectMap);
    if (state == 'published' &&
        nameAccessStatus != null &&
        nameAccessStatus != 'visible') {
      return _projectNameAccessStatusBody(projectMap);
    }
    return switch (state) {
      'published' => '当前项目正在竞标中，可继续提交竞标资料。',
      'bidding_closed' => '当前项目投标已结束。',
      'awarded' => '当前项目已授标。',
      'converted_to_order' => '当前项目已被承接。',
      _ => '当前项目暂不开放参与竞标。',
    };
  }

  bool _isOwnerSurface(String? viewerProjectRelation) {
    return viewerProjectRelation == 'owner';
  }

  bool _canContinueBidFromState(String? state) => state == 'published';

  bool _canReadBidResultFromState(String? state) {
    return state == 'awarded' || state == 'converted_to_order';
  }

  bool _addressRangeFullyMissing({
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
