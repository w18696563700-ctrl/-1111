part of 'profile_detail_pages.dart';

enum _ProfileCreditTone { gold, green, purple, blue, gray, red }

const double _profileCreditCardGap = 12;

class _ProfileCreditFeatureCardData {
  const _ProfileCreditFeatureCardData({
    required this.icon,
    required this.title,
    required this.value,
    required this.tone,
  });

  final IconData icon;
  final String title;
  final String value;
  final _ProfileCreditTone tone;
}

class _ProfileCreditInfoRowData {
  const _ProfileCreditInfoRowData({
    required this.icon,
    required this.title,
    required this.value,
    required this.tone,
  });

  final IconData icon;
  final String title;
  final String value;
  final _ProfileCreditTone tone;
}

class _ProfileCreditToneColors {
  const _ProfileCreditToneColors({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;
}

BoxDecoration _profileCreditCardDecoration() {
  return BoxDecoration(
    color: AppVisualTokens.cardBackground,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: AppVisualTokens.borderSoft),
    boxShadow: AppVisualTokens.shadowCard(opacity: 0.05),
  );
}

_ProfileCreditToneColors _profileCreditToneColors(_ProfileCreditTone tone) {
  return switch (tone) {
    _ProfileCreditTone.gold => const _ProfileCreditToneColors(
      background: Color(0xFFFFF1D8),
      foreground: Color(0xFF9A6419),
      border: Color(0xFFF0D9B0),
    ),
    _ProfileCreditTone.green => const _ProfileCreditToneColors(
      background: Color(0xFFEAF7EF),
      foreground: Color(0xFF2D8550),
      border: Color(0xFFCFEBD9),
    ),
    _ProfileCreditTone.purple => const _ProfileCreditToneColors(
      background: Color(0xFFF2ECFF),
      foreground: Color(0xFF7446C8),
      border: Color(0xFFE0D2FF),
    ),
    _ProfileCreditTone.blue => const _ProfileCreditToneColors(
      background: Color(0xFFEAF6FF),
      foreground: Color(0xFF2077B5),
      border: Color(0xFFCFEAFF),
    ),
    _ProfileCreditTone.gray => const _ProfileCreditToneColors(
      background: Color(0xFFF2F3F5),
      foreground: Color(0xFF6E7580),
      border: Color(0xFFE1E4E8),
    ),
    _ProfileCreditTone.red => const _ProfileCreditToneColors(
      background: Color(0xFFFCE8E6),
      foreground: Color(0xFFD14E48),
      border: Color(0xFFF4C9C5),
    ),
  };
}

String _profileCreditHeroSummary(ProfileCreditConstraintsStatusView data) {
  final summary = data.privateSummary;
  return <String>[
    profileDisplayCreditConstraintStatus(summary.creditConstraintStatus),
    profileDisplayDepositPostureStatus(summary.depositPostureStatus),
    profileDisplayTransactionGuaranteeEligibilityStatus(
      summary.transactionGuaranteeEligibilityStatus,
    ),
  ].join('，');
}

List<_ProfileCreditInfoRowData> _profileCreditSummaryRows(
  ProfileCreditConstraintsStatusView data,
) {
  final summary = data.privateSummary;
  return <_ProfileCreditInfoRowData>[
    _ProfileCreditInfoRowData(
      icon: Icons.info_rounded,
      title: '当前状态',
      value: profileDisplayCreditConstraintsSummaryStatus(
        summary.summaryStatus,
      ),
      tone: _profileCreditSummaryTone(summary.summaryStatus),
    ),
    _ProfileCreditInfoRowData(
      icon: Icons.verified_user_rounded,
      title: '当前信用',
      value: profileDisplayCreditConstraintStatus(
        summary.creditConstraintStatus,
      ),
      tone: _profileCreditConstraintTone(summary.creditConstraintStatus),
    ),
    _ProfileCreditInfoRowData(
      icon: Icons.account_balance_wallet_rounded,
      title: '当前保证金姿态',
      value: profileDisplayDepositPostureStatus(summary.depositPostureStatus),
      tone: _profileCreditDepositPostureTone(summary.depositPostureStatus),
    ),
    _ProfileCreditInfoRowData(
      icon: Icons.gpp_good_rounded,
      title: '当前交易保障资格',
      value: profileDisplayTransactionGuaranteeEligibilityStatus(
        summary.transactionGuaranteeEligibilityStatus,
      ),
      tone: _profileCreditGuaranteeEligibilityTone(
        summary.transactionGuaranteeEligibilityStatus,
      ),
    ),
    _ProfileCreditInfoRowData(
      icon: Icons.link_rounded,
      title: '后续依赖',
      value: _profileCreditDependencyReferenceHint(data.dependencyReference),
      tone: (data.dependencyReference?.dependencyRequired ?? false)
          ? _ProfileCreditTone.purple
          : _ProfileCreditTone.gray,
    ),
    _ProfileCreditInfoRowData(
      icon: Icons.schedule_rounded,
      title: '最近更新',
      value: summary.updatedAt,
      tone: _ProfileCreditTone.blue,
    ),
  ];
}

List<_ProfileCreditInfoRowData> _profileCreditConstraintRows(
  CreditConstraintStatusView data,
) {
  return <_ProfileCreditInfoRowData>[
    _ProfileCreditInfoRowData(
      icon: Icons.verified_user_rounded,
      title: '信用姿态',
      value: profileDisplayCreditConstraintStatus(data.creditConstraintStatus),
      tone: _profileCreditConstraintTone(data.creditConstraintStatus),
    ),
    _ProfileCreditInfoRowData(
      icon: Icons.task_alt_rounded,
      title: '履约姿态',
      value: profileDisplayPerformanceConstraintStatus(
        data.performanceConstraintStatus,
      ),
      tone: _profileCreditConstraintTone(data.performanceConstraintStatus),
    ),
    _ProfileCreditInfoRowData(
      icon: Icons.play_circle_rounded,
      title: '可执行状态',
      value: profileDisplayExecutionAvailabilityStatus(
        data.executionAvailabilityStatus,
      ),
      tone: _profileCreditExecutionTone(data.executionAvailabilityStatus),
    ),
    if (data.restrictionReasonCode != null)
      _ProfileCreditInfoRowData(
        icon: Icons.report_problem_rounded,
        title: '限制提示',
        value: profileDisplayCreditReasonHint(data.restrictionReasonCode),
        tone: _ProfileCreditTone.red,
      ),
    if (data.advisoryReasonCode != null)
      _ProfileCreditInfoRowData(
        icon: Icons.tips_and_updates_rounded,
        title: '规则提示',
        value: profileDisplayCreditAdvisoryHint(data.advisoryReasonCode),
        tone: _ProfileCreditTone.gold,
      ),
  ];
}

List<_ProfileCreditInfoRowData> _profileCreditDepositRows(
  ProfileCreditConstraintsStatusView data,
) {
  final deposit = data.deposit;
  return <_ProfileCreditInfoRowData>[
    _ProfileCreditInfoRowData(
      icon: Icons.assignment_late_rounded,
      title: '前置要求',
      value: profileDisplayDepositRequirementStatus(
        deposit.depositRequirementStatus,
      ),
      tone: _profileCreditDepositRequirementTone(
        deposit.depositRequirementStatus,
      ),
    ),
    _ProfileCreditInfoRowData(
      icon: Icons.check_circle_rounded,
      title: '当前资格',
      value: profileDisplayDepositEligibilityStatus(
        deposit.depositEligibilityStatus,
      ),
      tone: _profileCreditEligibilityTone(deposit.depositEligibilityStatus),
    ),
    _ProfileCreditInfoRowData(
      icon: Icons.block_rounded,
      title: '当前限制',
      value: profileDisplayDepositRestrictionStatus(
        deposit.depositRestrictionStatus,
      ),
      tone: _profileCreditRestrictionTone(deposit.depositRestrictionStatus),
    ),
    _ProfileCreditInfoRowData(
      icon: Icons.account_balance_wallet_rounded,
      title: '当前姿态',
      value: profileDisplayDepositPostureStatus(deposit.depositPostureStatus),
      tone: _profileCreditDepositPostureTone(deposit.depositPostureStatus),
    ),
    _ProfileCreditInfoRowData(
      icon: Icons.link_rounded,
      title: '后续依赖',
      value: _profileCreditDependencySentence(
        key: deposit.depositDependencyKey,
        dependencyReference: data.dependencyReference,
        prefix: '当前后续动作仍依赖',
      ),
      tone: _profileCreditDependencyTone(
        key: deposit.depositDependencyKey,
        dependencyReference: data.dependencyReference,
      ),
    ),
  ];
}

List<_ProfileCreditInfoRowData> _profileCreditGuaranteeRows(
  ProfileCreditConstraintsStatusView data,
) {
  final guarantee = data.transactionGuarantee;
  return <_ProfileCreditInfoRowData>[
    _ProfileCreditInfoRowData(
      icon: Icons.gpp_good_rounded,
      title: '保障资格',
      value: profileDisplayTransactionGuaranteeEligibilityStatus(
        guarantee.transactionGuaranteeEligibilityStatus,
      ),
      tone: _profileCreditGuaranteeEligibilityTone(
        guarantee.transactionGuaranteeEligibilityStatus,
      ),
    ),
    _ProfileCreditInfoRowData(
      icon: Icons.block_rounded,
      title: '当前限制',
      value: profileDisplayTransactionGuaranteeRestrictionStatus(
        guarantee.transactionGuaranteeRestrictionStatus,
      ),
      tone: _profileCreditRestrictionTone(
        guarantee.transactionGuaranteeRestrictionStatus,
      ),
    ),
    _ProfileCreditInfoRowData(
      icon: Icons.link_rounded,
      title: '后续依赖',
      value: _profileCreditDependencySentence(
        key: guarantee.transactionGuaranteeDependencyKey,
        dependencyReference: data.dependencyReference,
        prefix: '当前保障后续动作仍依赖',
      ),
      tone: _profileCreditDependencyTone(
        key: guarantee.transactionGuaranteeDependencyKey,
        dependencyReference: data.dependencyReference,
      ),
    ),
  ];
}

String _profileCreditDependencyReferenceHint(
  CreditConstraintsDependencyReferenceView? dependencyReference,
) {
  if (dependencyReference == null || !dependencyReference.dependencyRequired) {
    return '当前暂不需要额外依赖';
  }
  return '依赖 ${profileDisplayCreditConstraintsDependencyFamily(dependencyReference.dependencyFamilyKey)}';
}

String _profileCreditDependencySentence({
  required String? key,
  required CreditConstraintsDependencyReferenceView? dependencyReference,
  required String prefix,
}) {
  if (key == null || key.trim().isEmpty) {
    return '当前暂不需要额外依赖。';
  }
  final family = dependencyReference?.dependencyRequired ?? false
      ? profileDisplayCreditConstraintsDependencyFamily(
          dependencyReference!.dependencyFamilyKey,
        )
      : _profileCreditDependencyFamilyFromKey(key);
  return '$prefix $family。';
}

String _profileCreditDependencyFamilyFromKey(String key) {
  return key.contains('v22_payment_billing')
      ? profileDisplayCreditConstraintsDependencyFamily('v22_payment_billing')
      : key;
}

_ProfileCreditTone _profileCreditSummaryTone(String? state) {
  return switch (state?.trim()) {
    'clear' => _ProfileCreditTone.green,
    'limited' || 'handoff_required' => _ProfileCreditTone.gold,
    'blocked' => _ProfileCreditTone.red,
    null || '' => _ProfileCreditTone.gray,
    _ => _ProfileCreditTone.gray,
  };
}

_ProfileCreditTone _profileCreditConstraintTone(String? state) {
  return switch (state?.trim()) {
    'clear' || 'available' || 'eligible' => _ProfileCreditTone.green,
    'constrained' || 'restricted' || 'blocked' => _ProfileCreditTone.red,
    'limited' || 'handoff_required' => _ProfileCreditTone.gold,
    null || '' => _ProfileCreditTone.gray,
    _ => _ProfileCreditTone.gray,
  };
}

_ProfileCreditTone _profileCreditExecutionTone(String? state) {
  return switch (state?.trim()) {
    'available' => _ProfileCreditTone.green,
    'limited' => _ProfileCreditTone.gold,
    'blocked' => _ProfileCreditTone.red,
    null || '' => _ProfileCreditTone.gray,
    _ => _ProfileCreditTone.gray,
  };
}

_ProfileCreditTone _profileCreditDepositRequirementTone(String? state) {
  return switch (state?.trim()) {
    'not_required' => _ProfileCreditTone.green,
    'required' => _ProfileCreditTone.gold,
    null || '' => _ProfileCreditTone.gray,
    _ => _ProfileCreditTone.gray,
  };
}

_ProfileCreditTone _profileCreditEligibilityTone(String? state) {
  return switch (state?.trim()) {
    'eligible' => _ProfileCreditTone.green,
    'not_eligible' => _ProfileCreditTone.red,
    null || '' => _ProfileCreditTone.gray,
    _ => _ProfileCreditTone.gray,
  };
}

_ProfileCreditTone _profileCreditRestrictionTone(String? state) {
  return switch (state?.trim()) {
    'clear' => _ProfileCreditTone.green,
    'restricted' => _ProfileCreditTone.red,
    null || '' => _ProfileCreditTone.gray,
    _ => _ProfileCreditTone.gray,
  };
}

_ProfileCreditTone _profileCreditDepositPostureTone(String? state) {
  return switch (state?.trim()) {
    'clear' => _ProfileCreditTone.green,
    'restricted' => _ProfileCreditTone.red,
    'handoff_required' => _ProfileCreditTone.gold,
    null || '' => _ProfileCreditTone.gray,
    _ => _ProfileCreditTone.gray,
  };
}

_ProfileCreditTone _profileCreditGuaranteeEligibilityTone(String? state) {
  return switch (state?.trim()) {
    'eligible' => _ProfileCreditTone.green,
    'not_eligible' => _ProfileCreditTone.red,
    null || '' => _ProfileCreditTone.gray,
    _ => _ProfileCreditTone.gray,
  };
}

_ProfileCreditTone _profileCreditDependencyTone({
  required String? key,
  required CreditConstraintsDependencyReferenceView? dependencyReference,
}) {
  if ((key != null && key.trim().isNotEmpty) ||
      (dependencyReference?.dependencyRequired ?? false)) {
    return _ProfileCreditTone.purple;
  }
  return _ProfileCreditTone.gray;
}
