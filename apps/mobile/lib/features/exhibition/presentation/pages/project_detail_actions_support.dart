part of '../exhibition_trade_pages.dart';

extension _ProjectDetailActionsSupport on _ProjectDetailPageState {
  Widget _buildTradingImEntryCard({
    required String projectId,
    required String? bidId,
    required bool canStartBid,
  }) {
    final messageBody = bidId != null
        ? '项目澄清面向当前项目；沟通与投标承接当前 bidId。'
        : canStartBid
        ? '项目澄清面向当前项目；沟通与投标需要先完成竞标并生成 bidId，当前请使用上方主入口继续参与竞标。'
        : '项目澄清面向当前项目；沟通与投标需要承接具体 bidId。';

    return _ActionCard(
      title: '项目沟通',
      children: <Widget>[
        _StateMessage(title: '当前对象', body: messageBody),
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
