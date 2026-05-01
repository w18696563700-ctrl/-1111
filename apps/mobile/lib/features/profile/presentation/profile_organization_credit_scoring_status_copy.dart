part of 'profile_detail_pages.dart';

String _reserveHeroPrimaryLine(int? score) {
  return score == null ? '当前暂无评分' : '评分 $score';
}

String _reserveHeroSecondaryLine(OrganizationCreditScoringStatusView data) {
  final insufficientShadow =
      data.sampleStatus.trim() == 'INSUFFICIENT' &&
      (data.riskPosture?.trim().isEmpty ?? true) &&
      (data.actionableState?.trim().isEmpty ?? true);
  if (insufficientShadow) {
    return '样本不足，暂未生成风险姿态与执行建议。';
  }

  final pieces = <String>[
    _reserveSampleStatusLabel(data.sampleStatus),
    _reserveRiskPostureLabel(data.riskPosture),
    _reserveActionableStateLabel(data.actionableState),
  ];
  return pieces.join(' · ');
}

String _reserveOverviewScoreLabel(int? score) {
  return score == null ? '当前暂无提供' : '评分 $score';
}

_ProfileReserveTone _reserveSampleTone(String sampleStatus) {
  return switch (sampleStatus.trim()) {
    'SUFFICIENT' => _ProfileReserveTone.green,
    'INSUFFICIENT' => _ProfileReserveTone.amber,
    'UNAVAILABLE' => _ProfileReserveTone.gray,
    _ => _ProfileReserveTone.gray,
  };
}

_ProfileReserveTone _reserveRiskTone(String? riskPosture) {
  return switch (riskPosture?.trim()) {
    'LOW' => _ProfileReserveTone.green,
    'MEDIUM' => _ProfileReserveTone.amber,
    'HIGH' => _ProfileReserveTone.red,
    _ => _ProfileReserveTone.red,
  };
}

_ProfileReserveTone _reserveActionableTone(String? actionableState) {
  return (actionableState == null || actionableState.trim().isEmpty)
      ? _ProfileReserveTone.blue
      : _ProfileReserveTone.gold;
}

String _reserveSampleStatusLabel(String? sampleStatus) {
  return switch (sampleStatus?.trim()) {
    null || '' => '样本状态暂未提供',
    'UNAVAILABLE' => '样本暂不可用',
    'INSUFFICIENT' => '样本不足',
    'SUFFICIENT' => '样本充足',
    final String other when _containsChinese(other) => other,
    final String other => other,
  };
}

String _reserveRiskPostureLabel(String? riskPosture) {
  return switch (riskPosture?.trim()) {
    null || '' => '风险姿态暂未提供',
    'UNAVAILABLE' => '风险姿态暂不可用',
    'LOW' => '低风险姿态',
    'MEDIUM' => '中风险姿态',
    'HIGH' => '高风险姿态',
    final String other when _containsChinese(other) => other,
    final String other => other,
  };
}

String _reserveActionableStateLabel(String? actionableState) {
  return _reserveValueOrFallback(actionableState, fallback: '当前暂无可执行建议');
}

String _reserveRateLabel(double? rate) {
  if (rate == null) {
    return '暂未提供';
  }
  final value = rate <= 1 ? rate * 100 : rate;
  final fractionDigits = value.truncateToDouble() == value ? 0 : 2;
  return '${value.toStringAsFixed(fractionDigits)}%';
}

String _reserveStatusRateLabel(double? rate) {
  if (rate == null) {
    return '-';
  }
  return _reserveRateLabel(rate);
}

String _reserveValueOrFallback(String? value, {String fallback = '当前暂未提供'}) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return fallback;
  }
  return trimmed;
}

bool _containsChinese(String value) {
  return RegExp(r'[\u4e00-\u9fff]').hasMatch(value);
}
