part of '../exhibition_trade_pages.dart';

_BidAccessGuard? _deriveBidAccessGuard({
  required AppShellContextSnapshot snapshot,
  required bool hasSession,
}) {
  final blockingState = snapshot.blockingState;
  if (!hasSession || blockingState == GlobalShellState.unauthenticated) {
    return const _BidAccessGuard(
      controlledState: AppPageState.unauthorized,
      title: '当前尚未登录',
      message: '参与竞标属于私域动作，当前需要先登录后再继续。',
      actionLabel: '进入登录入口',
      actionRouteName: ProfileIdentityRoutes.login,
    );
  }

  if (blockingState == GlobalShellState.noOrganization ||
      snapshot.shellContext.organizationId == null) {
    return const _BidAccessGuard(
      controlledState: AppPageState.forbidden,
      title: '当前尚未加入组织',
      message: '参与竞标需要组织归属，当前请先进入组织承接入口。',
      actionLabel: '前往组织承接',
      actionRouteName: ProfileIdentityRoutes.organizationHandoff,
    );
  }

  if (blockingState == GlobalShellState.offline ||
      blockingState == GlobalShellState.maintenance ||
      blockingState == GlobalShellState.hiddenBuildingUnavailable) {
    return const _BidAccessGuard(
      controlledState: AppPageState.errorRetryable,
      title: '当前竞标入口受控',
      message: '当前壳层状态暂不可继续参与竞标，请先回到当前项目详情后重试。',
      actionLabel: '回到当前项目详情',
      actionRouteName: ExhibitionRoutes.showcase,
    );
  }

  if (_isBidOrganizationTypeBlocked(snapshot.shellContext.organizationType)) {
    return const _BidAccessGuard(
      controlledState: AppPageState.forbidden,
      title: '当前组织类型未开放竞标资格',
      message:
          '当前主体还不是可参与竞标的供应商或需求方/供应商组织。请先进入公司与组织切换到可参与竞标的主体，再继续当前项目。',
      actionLabel: '前往公司与组织',
      actionRouteName: ProfileIdentityRoutes.organizationHandoff,
    );
  }

  if (!_isBidOrganizationCertificationApproved(
    snapshot.shellContext.certificationStatus,
  )) {
    return const _BidAccessGuard(
      controlledState: AppPageState.forbidden,
      title: '当前企业认证未通过',
      message:
          '参与竞标或查看竞标结果前，需要企业认证和我的认证同时通过。请先进入公司认证与我的身份完成企业认证。',
      actionLabel: '前往公司认证与我的身份',
      actionRouteName: ProfileIdentityRoutes.certificationCurrent,
    );
  }

  if (!_isBidPersonalCertificationApproved(
    status: snapshot.shellContext.personalCertificationStatus,
    qualifiedForCurrentActor:
        snapshot.shellContext.personalCertificationQualified,
    lockedToOtherActor:
        snapshot.shellContext.personalCertificationLockedToOtherActor,
  )) {
    final lockedToOtherActor =
        snapshot.shellContext.personalCertificationLockedToOtherActor == true;
    return _BidAccessGuard(
      controlledState: AppPageState.forbidden,
      title: lockedToOtherActor ? '当前我的认证已锁定其他账号' : '当前我的认证未通过',
      message: lockedToOtherActor
          ? '参与竞标或查看竞标结果前，需要企业认证和我的认证同时通过。当前公司的我的认证已锁定到其他账号，不支持换人。'
          : '参与竞标或查看竞标结果前，需要企业认证和我的认证同时通过。请先进入公司认证与我的身份完成我的认证。',
      actionLabel: '前往公司认证与我的身份',
      actionRouteName: ProfileIdentityRoutes.certificationCurrent,
    );
  }

  return null;
}

bool _isBidOrganizationTypeBlocked(String? organizationType) {
  final normalized = organizationType?.trim().toLowerCase();
  if (normalized == null || normalized.isEmpty) {
    return false;
  }
  return normalized != 'supplier' && normalized != 'both';
}

bool _isBidOrganizationCertificationApproved(String? status) {
  final normalized = status?.trim().toLowerCase();
  return normalized == 'verified' || normalized == 'approved';
}

bool _isBidPersonalCertificationApproved({
  required String? status,
  required bool? qualifiedForCurrentActor,
  required bool? lockedToOtherActor,
}) {
  if (lockedToOtherActor == true) {
    return false;
  }
  final normalized = status?.trim().toLowerCase();
  final approved = normalized == 'verified' || normalized == 'approved';
  if (!approved) {
    return false;
  }
  if (qualifiedForCurrentActor == null) {
    return true;
  }
  return qualifiedForCurrentActor;
}

_BidAccessGuard _bidMissingProjectGuard() {
  return const _BidAccessGuard(
    controlledState: AppPageState.notFound,
    title: '当前还没有承接到项目',
    message: '当前没有承接到真实项目，暂时不能继续参与竞标。请先回到项目详情，再从当前项目继续进入。',
    actionLabel: '回到项目展示',
    actionRouteName: ExhibitionRoutes.showcase,
  );
}

_BidAccessGuard? _deriveBidProjectAccessGuard({
  required String projectId,
  required ExhibitionLoadResult detailResult,
}) {
  if (detailResult.state != AppPageState.content) {
    return _bidProjectReadFailureGuard(
      projectId: projectId,
      detailResult: detailResult,
    );
  }

  final payload = _payloadMap(detailResult.payload);
  final viewerProjectRelation = _normalizeId(
    payload?['viewerProjectRelation'] as String?,
  );
  if (viewerProjectRelation == 'owner') {
    return _BidAccessGuard(
      controlledState: AppPageState.forbidden,
      title: '当前项目属于你方发布',
      message: '发布方不从公开竞标入口继续提交；请进入我的项目继续处理。',
      actionLabel: '进入我的项目',
      actionRouteName: ExhibitionRoutes.myProjectDetailWithProjectId(projectId),
    );
  }

  final projectState = _normalizeId(payload?['state'] as String?);
  if (projectState != 'published') {
    return _BidAccessGuard(
      controlledState: AppPageState.forbidden,
      title: '当前项目暂不可参与竞标',
      message: _bidProjectStateBlockedMessage(projectState),
      actionLabel: '回到项目详情',
      actionRouteName: ExhibitionRoutes.projectDetailWithProjectId(projectId),
    );
  }

  return null;
}

_BidAccessGuard _bidProjectReadFailureGuard({
  required String projectId,
  required ExhibitionLoadResult detailResult,
}) {
  return switch (detailResult.state) {
    AppPageState.unauthorized => const _BidAccessGuard(
      controlledState: AppPageState.unauthorized,
      title: '当前尚未登录',
      message: '当前需要先登录并回到项目详情后，再参与竞标。',
      actionLabel: '进入登录入口',
      actionRouteName: ProfileIdentityRoutes.login,
    ),
    AppPageState.forbidden => _BidAccessGuard(
      controlledState: AppPageState.forbidden,
      title: '当前项目暂不可访问',
      message: '当前项目详情暂不可访问，请先回到项目展示确认可公开查看的项目。',
      actionLabel: '回到项目展示',
      actionRouteName: ExhibitionRoutes.showcase,
    ),
    AppPageState.notFound => _BidAccessGuard(
      controlledState: AppPageState.notFound,
      title: '当前项目不可用',
      message: '当前项目详情不存在或已下线，暂时不能继续参与竞标。',
      actionLabel: '回到项目展示',
      actionRouteName: ExhibitionRoutes.showcase,
    ),
    AppPageState.errorRetryable ||
    AppPageState.errorNonRetryable => _BidAccessGuard(
      controlledState: detailResult.state,
      title: '当前项目暂不可参与竞标',
      message: '当前项目详情暂不可用，请稍后重试或先回到项目详情确认当前状态。',
      actionLabel: '回到项目详情',
      actionRouteName: ExhibitionRoutes.projectDetailWithProjectId(projectId),
    ),
    AppPageState.empty ||
    AppPageState.loading ||
    AppPageState.content => _BidAccessGuard(
      controlledState: AppPageState.errorRetryable,
      title: '当前项目暂不可参与竞标',
      message: '当前项目状态暂未准备完成，请先回到项目详情确认当前状态。',
      actionLabel: '回到项目详情',
      actionRouteName: ExhibitionRoutes.projectDetailWithProjectId(projectId),
    ),
  };
}

String _bidProjectStateBlockedMessage(String? projectState) {
  return switch (projectState) {
    'bidding_closed' => '当前项目投标已结束，暂时不能继续提交竞标。',
    'awarded' => '当前项目已授标，公开竞标入口不再继续后续私域动作。',
    'converted_to_order' => '当前项目已被承接，当前不再开放参与竞标。',
    _ => '当前项目暂不处于参与竞标阶段，请先回到项目详情确认当前状态。',
  };
}

_BidAccessGuard? _deriveBidResultProjectAccessGuard({
  required String projectId,
  required ExhibitionLoadResult detailResult,
}) {
  if (detailResult.state != AppPageState.content) {
    return _bidProjectReadFailureGuard(
      projectId: projectId,
      detailResult: detailResult,
    );
  }

  final payload = _payloadMap(detailResult.payload);
  final viewerProjectRelation = _normalizeId(
    payload?['viewerProjectRelation'] as String?,
  );
  if (viewerProjectRelation == 'owner') {
    return _BidAccessGuard(
      controlledState: AppPageState.forbidden,
      title: '当前项目属于你方发布',
      message: '发布方不从公开竞标结果入口继续读取；请进入我的项目继续处理。',
      actionLabel: '进入我的项目',
      actionRouteName: ExhibitionRoutes.myProjectDetailWithProjectId(projectId),
    );
  }

  final projectState = _normalizeId(payload?['state'] as String?);
  if (!_canReadBidResultFromProjectState(projectState)) {
    return _BidAccessGuard(
      controlledState: AppPageState.forbidden,
      title: '当前项目暂不可查看竞标结果',
      message: _bidResultStateBlockedMessage(projectState),
      actionLabel: '回到项目详情',
      actionRouteName: ExhibitionRoutes.projectDetailWithProjectId(projectId),
    );
  }

  return null;
}

bool _canReadBidResultFromProjectState(String? projectState) {
  return projectState == 'awarded' || projectState == 'converted_to_order';
}

String _bidResultStateBlockedMessage(String? projectState) {
  return switch (projectState) {
    'published' => '当前项目仍处于竞标中，竞标结果尚未开放查看。',
    'bidding_closed' => '当前项目投标已结束，竞标结果尚未回读。',
    _ => '当前项目暂不处于可查看竞标结果阶段，请先回到项目详情确认当前状态。',
  };
}

String _resolveBidGuardRouteName(
  _BidAccessGuard accessGuard, {
  String? projectId,
}) {
  if (projectId == null) {
    return accessGuard.actionRouteName;
  }
  if (accessGuard.actionRouteName == ExhibitionRoutes.showcase) {
    return ExhibitionRoutes.projectDetailWithProjectId(projectId);
  }
  return accessGuard.actionRouteName;
}

class _BidAccessGuard {
  const _BidAccessGuard({
    required this.controlledState,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.actionRouteName,
  });

  final AppPageState controlledState;
  final String title;
  final String message;
  final String actionLabel;
  final String actionRouteName;
}
