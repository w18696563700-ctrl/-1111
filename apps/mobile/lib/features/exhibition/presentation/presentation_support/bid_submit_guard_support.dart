part of '../exhibition_trade_pages.dart';

_BidAccessGuard? _deriveBidAccessGuard({
  required AppShellContextSnapshot snapshot,
  required bool hasSession,
}) {
  final blockingState = snapshot.blockingState;
  if (!hasSession || blockingState == GlobalShellState.unauthenticated) {
    return const _BidAccessGuard(
      title: '当前尚未登录',
      message: '继续竞标属于私域动作，当前需要先登录后再继续。',
      actionLabel: '进入登录入口',
      actionRouteName: ProfileIdentityRoutes.login,
    );
  }

  if (blockingState == GlobalShellState.noOrganization ||
      snapshot.shellContext.organizationId == null) {
    return const _BidAccessGuard(
      title: '当前尚未加入组织',
      message: '继续竞标需要组织归属，当前请先进入组织承接入口。',
      actionLabel: '前往组织承接',
      actionRouteName: ProfileIdentityRoutes.organizationHandoff,
    );
  }

  if (blockingState == GlobalShellState.offline ||
      blockingState == GlobalShellState.maintenance ||
      blockingState == GlobalShellState.hiddenBuildingUnavailable) {
    return const _BidAccessGuard(
      title: '当前竞标入口受控',
      message: '当前壳层状态暂不可继续竞标，请先回到项目工作台重试。',
      actionLabel: '回到项目工作台',
      actionRouteName: ExhibitionRoutes.workbench,
    );
  }

  if (!_isBidCertificationApproved(snapshot.shellContext.certificationStatus)) {
    return const _BidAccessGuard(
      title: '当前认证状态未通过',
      message: '继续竞标需要先完成并通过认证，当前请先进入认证状态页。',
      actionLabel: '查看认证状态',
      actionRouteName: ProfileIdentityRoutes.certificationCurrent,
    );
  }

  if (!_hasBidSupplierRole(snapshot.shellContext.roleKeys)) {
    return const _BidAccessGuard(
      title: '当前身份未开放继续竞标',
      message: '继续竞标需要供应商侧角色或已授权供应商范围，当前请先回到项目工作台确认可执行动作。',
      actionLabel: '回到项目工作台',
      actionRouteName: ExhibitionRoutes.workbench,
    );
  }

  return null;
}

bool _isBidCertificationApproved(String? status) {
  final normalized = status?.trim().toLowerCase();
  return normalized == 'verified' || normalized == 'approved';
}

bool _hasBidSupplierRole(List<String> roleKeys) {
  for (final role in roleKeys) {
    if (role.toLowerCase().contains('supplier')) {
      return true;
    }
  }
  return false;
}

class _BidAccessGuard {
  const _BidAccessGuard({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.actionRouteName,
  });

  final String title;
  final String message;
  final String actionLabel;
  final String actionRouteName;
}
