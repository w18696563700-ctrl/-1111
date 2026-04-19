import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/features/exhibition/data/forum_visible_copy.dart';

String profileDisplayTimeLabel(String? rawValue, {String fallback = '时间未知'}) {
  return forumDisplayTimeLabel(rawValue, fallback: fallback);
}

String profileDisplayName(String? rawUserId) {
  final value = rawUserId?.trim();
  if (value == null || value.isEmpty) {
    return '未登录';
  }
  final masked = forumDisplayActorName(value, fallback: '当前用户');
  if (masked == '当前用户' && value == rawUserId) {
    return masked;
  }
  return masked;
}

String profileDisplayAccountLabel(String? rawUserId) {
  return forumDisplayAccountLabel(rawUserId);
}

String profileDisplayCertificationStatus(String? state) {
  return switch (state?.trim()) {
    null || '' => '未认证',
    'not_submitted' => '未认证',
    'pending_review' => '认证中',
    'approved' => '已认证',
    'rejected' => '认证未通过',
    'expired' => '已过期',
    final String other when _containsChinese(other) => other,
    _ => '待补充',
  };
}

String profileDisplayCertificationIdentitySummary({
  required String? certificationStatus,
  required String? personalCertificationStatus,
  required bool? personalCertificationQualified,
  required bool? personalCertificationLockedToOtherActor,
  required String? membershipStatus,
}) {
  final enterpriseLabel =
      '企业${profileDisplayCertificationStatus(certificationStatus)}';
  final personalLabel = personalCertificationLockedToOtherActor == true
      ? '我的认证已锁定其他账号'
      : personalCertificationQualified == true
      ? '我的认证已通过'
      : '我的认证${profileDisplayCertificationStatus(personalCertificationStatus)}';
  return '$enterpriseLabel · $personalLabel · ${profileDisplayMembershipStatus(membershipStatus)}';
}

String profileDisplayMembershipStatus(String? state) {
  return switch (state?.trim()) {
    null || '' => '未开通',
    'invited' => '已邀请',
    'pending_accept' => '待接受',
    'active' => '已开通',
    'disabled' => '已禁用',
    'removed' => '已移除',
    final String other when _containsChinese(other) => other,
    _ => '待补充',
  };
}

String profileDisplayEnterpriseCertificationBadge(String? state) {
  return '企业${profileDisplayCertificationStatus(state)}';
}

String profileDisplayMembershipBadge(String? state) {
  return '成员${profileDisplayMembershipStatus(state)}';
}

String profileDisplayPaidMembershipTier(String? tier) {
  return switch (tier?.trim()) {
    null || '' => '会员档位暂未提供',
    'free_certified' || 'free-certified' || 'free' => '免费认证版',
    'standard' => '标准会员',
    'professional' => '专业会员',
    final String other when _containsChinese(other) => other,
    final String other => other,
  };
}

String profileDisplayCreditConstraintsSummaryStatus(String? state) {
  return switch (state?.trim()) {
    null || '' => '当前摘要暂未提供',
    'clear' => '当前可继续查看',
    'limited' => '当前存在规则提示',
    'blocked' => '当前受限',
    'handoff_required' => '当前需后续衔接',
    final String other when _containsChinese(other) => other,
    final String other => other,
  };
}

String profileDisplayCreditConstraintStatus(String? state) {
  return switch (state?.trim()) {
    null || '' => '信用约束暂未提供',
    'clear' => '当前无信用约束',
    'constrained' => '当前存在信用约束',
    final String other when _containsChinese(other) => other,
    final String other => other,
  };
}

String profileDisplayPerformanceConstraintStatus(String? state) {
  return switch (state?.trim()) {
    null || '' => '履约约束暂未提供',
    'clear' => '当前履约约束正常',
    'constrained' => '当前存在履约约束',
    final String other when _containsChinese(other) => other,
    final String other => other,
  };
}

String profileDisplayExecutionAvailabilityStatus(String? state) {
  return switch (state?.trim()) {
    null || '' => '执行状态暂未提供',
    'available' => '当前可进入后续',
    'limited' => '当前需先确认规则',
    'blocked' => '当前暂不可继续',
    final String other when _containsChinese(other) => other,
    final String other => other,
  };
}

String profileDisplayDepositRequirementStatus(String? state) {
  return switch (state?.trim()) {
    null || '' => '保证金前置暂未提供',
    'not_required' => '当前暂不要求保证金前置',
    'required' => '当前要求保证金前置',
    final String other when _containsChinese(other) => other,
    final String other => other,
  };
}

String profileDisplayDepositEligibilityStatus(String? state) {
  return switch (state?.trim()) {
    null || '' => '保证金资格暂未提供',
    'eligible' => '当前满足保证金资格',
    'not_eligible' => '当前暂不满足保证金资格',
    final String other when _containsChinese(other) => other,
    final String other => other,
  };
}

String profileDisplayDepositRestrictionStatus(String? state) {
  return switch (state?.trim()) {
    null || '' => '保证金限制暂未提供',
    'clear' => '当前无保证金限制',
    'restricted' => '当前存在保证金限制',
    final String other when _containsChinese(other) => other,
    final String other => other,
  };
}

String profileDisplayDepositPostureStatus(String? state) {
  return switch (state?.trim()) {
    null || '' => '保证金姿态暂未提供',
    'clear' => '当前保证金姿态正常',
    'restricted' => '当前保证金姿态受限',
    'handoff_required' => '当前保证金需后续衔接',
    final String other when _containsChinese(other) => other,
    final String other => other,
  };
}

String profileDisplayTransactionGuaranteeEligibilityStatus(String? state) {
  return switch (state?.trim()) {
    null || '' => '交易保障资格暂未提供',
    'eligible' => '当前具备交易保障资格',
    'not_eligible' => '当前暂不具备交易保障资格',
    final String other when _containsChinese(other) => other,
    final String other => other,
  };
}

String profileDisplayTransactionGuaranteeRestrictionStatus(String? state) {
  return switch (state?.trim()) {
    null || '' => '交易保障限制暂未提供',
    'clear' => '当前无交易保障限制',
    'restricted' => '当前存在交易保障限制',
    final String other when _containsChinese(other) => other,
    final String other => other,
  };
}

String profileDisplayCreditConstraintsDependencyFamily(String? familyKey) {
  return switch (familyKey?.trim()) {
    null || '' => '后续依赖暂未提供',
    'v22_payment_billing' => 'V2.2 支付 / 账单能力',
    final String other when _containsChinese(other) => other,
    final String other => other,
  };
}

String profileDisplayPaymentBillingSummaryStatus(String? state) {
  return switch (state?.trim()) {
    null || '' => '当前摘要暂未提供',
    'pending' => '当前仍在等待边界更新',
    'unavailable' => '当前暂不可用',
    'handoff_required' => '当前需后续衔接',
    'reference_visible' => '当前账单引用可查看',
    'reference_unavailable' => '当前账单引用暂不可用',
    final String other when _containsChinese(other) => other,
    final String other => other,
  };
}

String profileDisplayPaymentStatus(String? state) {
  return switch (state?.trim()) {
    null || '' => '支付状态暂未提供',
    'pending' => '当前支付状态待确认',
    'unavailable' => '当前支付状态暂不可用',
    'handoff_required' => '当前支付状态需后续衔接',
    final String other when _containsChinese(other) => other,
    final String other => other,
  };
}

String profileDisplayPaymentAvailabilityStatus(String? state) {
  return switch (state?.trim()) {
    null || '' => '支付可见性暂未提供',
    'available' => '当前可继续查看边界状态',
    'unavailable' => '当前暂不可继续查看',
    final String other when _containsChinese(other) => other,
    final String other => other,
  };
}

String profileDisplayBillingReferenceStatus(String? state) {
  return switch (state?.trim()) {
    null || '' => '账单引用暂未提供',
    'available' => '当前账单引用已形成',
    'unavailable' => '当前账单引用暂不可用',
    final String other when _containsChinese(other) => other,
    final String other => other,
  };
}

String profileDisplayBillingReferenceVisibilityStatus(String? state) {
  return switch (state?.trim()) {
    null || '' => '账单引用显示状态暂未提供',
    'visible' => '当前账单引用可见',
    'hidden' => '当前账单引用暂不显示',
    final String other when _containsChinese(other) => other,
    final String other => other,
  };
}

String profileDisplayPaymentBillingHandoffStatus(String? state) {
  return switch (state?.trim()) {
    null || '' => '处理状态暂未提供',
    'pending' => '当前等待后续衔接',
    'unavailable' => '当前衔接暂不可用',
    'handoff_required' => '当前需后续衔接',
    final String other when _containsChinese(other) => other,
    final String other => other,
  };
}

String profileDisplayPaymentBillingDependencyFamily(String? familyKey) {
  return switch (familyKey?.trim()) {
    null || '' => '后续依赖暂未提供',
    'future_settlement_clearing_tax_finance_admin' => '后续结算 / 清分 / 税务 / 财务后台依赖',
    final String other when _containsChinese(other) => other,
    final String other => other,
  };
}

String profileDisplayPaymentBillingHandoffTargetFamily(String? familyKey) {
  return switch (familyKey?.trim()) {
    null || '' => '后续目标暂未提供',
    'future_finance_dependency' => '后续结算 / 清分 / 税务 / 财务后台依赖',
    'future_settlement_clearing_tax_finance_admin' => '后续结算 / 清分 / 税务 / 财务后台依赖',
    final String other when _containsChinese(other) => other,
    final String other => other,
  };
}

String profileDisplayPaymentBillingExplanationHint(String? key) {
  return switch (key?.trim()) {
    null || '' => '当前说明提示暂未提供',
    'payment_pending' => '当前支付仍停在边界读取与说明阶段',
    'payment_unavailable' => '当前支付只保留只读边界状态',
    'payment_handoff_required' => '当前支付需后续依赖衔接',
    'billing_reference_visible' => '当前账单引用可查看',
    'billing_reference_hidden' => '当前账单引用暂不展示',
    'billing_reference_unavailable' => '当前账单引用暂不可用',
    'requires_future_finance_dependency' => '当前更大范围动作仍依赖后续财务能力',
    final String other when _containsChinese(other) => other,
    final String other => other,
  };
}

String profileDisplayPaymentBillingHandoffHint(String? key) {
  return switch (key?.trim()) {
    null || '' => '当前处理提示暂未提供',
    'payment_open_future_finance_dependency' => '当前只允许衔接到后续财务依赖',
    'payment_wait_current_boundary' => '当前先保持边界只读状态',
    'billing_reference_view_current_reference' => '当前可查看边界账单引用',
    'billing_reference_wait_future_reference' => '当前需等待后续依赖',
    'open_future_finance_dependency' => '当前仅允许打开后续依赖方向',
    final String other when _containsChinese(other) => other,
    final String other => other,
  };
}

String profileDisplayPaymentBillingDependencyHint(String? key) {
  return switch (key?.trim()) {
    null || '' => '当前依赖提示暂未提供',
    'future_finance_dependency_required' => '当前更大范围动作仍依赖后续财务能力',
    final String other when _containsChinese(other) => other,
    final String other => other,
  };
}

class ProfilePaymentBillingUnavailableVisibleCopy {
  const ProfilePaymentBillingUnavailableVisibleCopy({
    required this.title,
    required this.message,
    required this.actionLabel,
  });

  final String title;
  final String message;
  final String actionLabel;
}

ProfilePaymentBillingUnavailableVisibleCopy?
profilePaymentBillingUnavailableVisibleCopy({
  required AppPageState state,
  String? errorCode,
  String? rawMessage,
}) {
  if (!profileIsPaymentBillingCurrentOrganizationUnavailable(
    state: state,
    errorCode: errorCode,
    rawMessage: rawMessage,
  )) {
    return null;
  }

  return const ProfilePaymentBillingUnavailableVisibleCopy(
    title: '当前组织暂无支付与账单状态',
    message: '当前组织暂无支付与账单状态。这不是支付执行失败，也不是系统异常。若你在其他组织下也有身份，可以切换组织后再查看。',
    actionLabel: '切换组织查看',
  );
}

bool profileIsPaymentBillingCurrentOrganizationUnavailable({
  required AppPageState state,
  String? errorCode,
  String? rawMessage,
}) {
  if (state != AppPageState.notFound) {
    return false;
  }

  if (errorCode?.trim() == 'PAYMENT_STATUS_UNAVAILABLE') {
    return true;
  }

  final value = rawMessage?.trim();
  if (value == null || value.isEmpty) {
    return false;
  }

  return _looksLikeCurrentOrganizationPaymentBillingUnavailableMessage(value);
}

String profileDisplayCreditReasonHint(String? restrictionReasonCode) {
  if ((restrictionReasonCode?.trim().isEmpty ?? true)) {
    return '当前限制原因以规则说明页为准';
  }
  return '当前存在限制原因，请先查看规则说明页';
}

String profileDisplayCreditAdvisoryHint(String? advisoryReasonCode) {
  if ((advisoryReasonCode?.trim().isEmpty ?? true)) {
    return '当前规则提示以说明页为准';
  }
  return '当前存在规则提示，请先查看规则说明页';
}

String profileDisplayOrganizationType(String? rawType) {
  return switch (rawType?.trim()) {
    null || '' => '未标记',
    'demand' => '需求方',
    'supplier' => '供应商',
    'both' => '需求方 / 供应商',
    'factory' => '工厂',
    'brand' => '品牌方',
    'service_provider' => '服务商',
    final String other when _containsChinese(other) => other,
    _ => '其他',
  };
}

String profileDisplayOrganizationName(String? rawName) {
  return forumDisplayOrganizationName(rawName, fallback: '我的公司') ?? '我的公司';
}

String profileDisplaySecurityTrustStatus(String? rawStatus) {
  return switch (rawStatus?.trim()) {
    null || '' => '未标记',
    'unknown' => '未标记',
    'trusted' => '可信',
    'untrusted' => '待确认',
    'revoked' => '已撤销',
    final String other when _containsChinese(other) => other,
    _ => '待补充',
  };
}

String profileDisplayOrganizationMemberStatus(String? state) {
  return switch (state?.trim()) {
    null || '' => '待补充',
    'invited' => '已邀请',
    'pending_accept' => '待接受',
    'active' => '启用中',
    'disabled' => '已禁用',
    'removed' => '已移除',
    final String other when _containsChinese(other) => other,
    _ => '待补充',
  };
}

String profileDisplayRoleSummary(List<String> roleKeys) {
  final resolved = roleKeys
      .map(_roleKeyToVisibleLabel)
      .whereType<String>()
      .toSet()
      .toList(growable: false);
  if (resolved.isEmpty) {
    return '当前成员';
  }
  return resolved.join('、');
}

List<String> profileBuildOrganizationStatusBadges({
  required List<String> roleKeys,
  required String? membershipStatus,
  required String? certificationStatus,
}) {
  final badges = <String>[
    profileDisplayMembershipBadge(membershipStatus),
    profileDisplayEnterpriseCertificationBadge(certificationStatus),
    profileDisplayRoleSummary(roleKeys),
  ];
  return badges
      .where((String item) => item.trim().isNotEmpty)
      .toList(growable: false);
}

String profileDisplayRoleKey(String? roleKey) {
  final normalized = roleKey?.trim();
  if (normalized == null || normalized.isEmpty) {
    return '当前成员';
  }
  return _roleKeyToVisibleLabel(normalized) ?? normalized;
}

String profileVisibleReadMessage({
  required AppPageState state,
  String? rawMessage,
  String surfaceLabel = '当前页面',
}) {
  final visibleRaw = _visibleChineseMessage(rawMessage);
  if (visibleRaw != null) {
    return visibleRaw;
  }

  return switch (state) {
    AppPageState.loading => '正在加载，请稍候',
    AppPageState.empty => '$surfaceLabel暂时没有内容',
    AppPageState.unauthorized => '请先登录后再查看',
    AppPageState.forbidden => '当前账号暂不能查看',
    AppPageState.notFound => '$surfaceLabel暂不可用',
    AppPageState.errorRetryable => '$surfaceLabel暂时没有加载成功，请稍后再试',
    AppPageState.errorNonRetryable => '$surfaceLabel当前暂不可用',
    AppPageState.content => '$surfaceLabel已准备好',
  };
}

String profileValueOrFallback(String? value, String fallback) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? fallback : trimmed;
}

String? _roleKeyToVisibleLabel(String roleKey) {
  return switch (roleKey.trim()) {
    'buyer_admin' => '需求管理员',
    'buyer_member(scoped)' => '需求成员',
    'supplier_admin' => '供应商管理员',
    'supplier_member(scoped)' => '供应成员',
    'factory_admin' => '工厂管理员',
    'member' => '普通成员',
    final String other when _containsChinese(other) => other,
    _ => null,
  };
}

String? _visibleChineseMessage(String? rawMessage) {
  final value = rawMessage?.trim();
  if (value == null || value.isEmpty) {
    return null;
  }
  if (!_containsChinese(value)) {
    return null;
  }
  if (_looksTechnicalVisibleMessage(value)) {
    return null;
  }
  return value;
}

bool _containsChinese(String value) {
  return RegExp(r'[\u4e00-\u9fff]').hasMatch(value);
}

bool _looksTechnicalVisibleMessage(String value) {
  final lower = value.toLowerCase();
  return lower.contains('source=') ||
      lower.contains('source:') ||
      lower.contains('transport') ||
      lower.contains('upstream') ||
      lower.contains('econnrefused') ||
      lower.contains('socketexception') ||
      lower.contains('formatexception') ||
      lower.contains('stateerror') ||
      lower.contains('cannot ') ||
      lower.contains('missing required') ||
      lower.contains('missing required field') ||
      lower.contains('validation') ||
      lower.contains('parser') ||
      lower.contains('exception') ||
      lower.contains('network error') ||
      lower.contains('http error') ||
      lower.contains('/api/app/') ||
      lower.contains('organizationid') ||
      lower.contains('userid') ||
      lower.contains('settingsentry');
}

bool _looksLikeCurrentOrganizationPaymentBillingUnavailableMessage(
  String value,
) {
  final lower = value.toLowerCase();
  final compact = lower.replaceAll(RegExp(r'\s+'), ' ');
  return ((compact.contains('current organization') ||
              compact.contains('current organisation') ||
              compact.contains('organization') ||
              compact.contains('organisation') ||
              compact.contains('当前组织')) &&
          (compact.contains('payment status') ||
              compact.contains('payment-and-billing') ||
              compact.contains('支付状态') ||
              compact.contains('支付与账单状态'))) &&
      (compact.contains('unavailable') || compact.contains('不可用'));
}
