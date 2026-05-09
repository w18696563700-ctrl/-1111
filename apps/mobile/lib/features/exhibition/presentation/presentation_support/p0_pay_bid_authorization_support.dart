// ignore_for_file: invalid_use_of_protected_member

part of '../exhibition_trade_pages.dart';

extension _P0PayBidAuthorizationSupport on _BidSubmitPageState {
  List<Widget> _buildP0PayFixedPriceBidAuthorizationFields() {
    final serviceFeeAuthorizationMode = _isServiceFeeAuthorizationMode;
    return <Widget>[
      Text(
        '竞标服务费预授权说明',
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
      ),
      const SizedBox(height: 8),
      _DetailLine(
        label: '当前阶段',
        value: serviceFeeAuthorizationMode ? '资料确认已通过，待完成预授权' : '先提交报价和三份资料',
        highlight: true,
      ),
      _StateMessage(
        title: serviceFeeAuthorizationMode ? '处理说明' : '后续处理',
        body: serviceFeeAuthorizationMode
            ? '当前入口只处理 4000 元竞标服务费预授权额度；完成后项目级自由发送开启。预授权不是扣款。'
            : '发布方资料确认通过后，系统会提醒完成 4000 元竞标服务费预授权额度；完成后项目级自由发送开启。预授权不是扣款。',
      ),
      ..._buildP0PayAuthorizationResultLines(),
    ];
  }
}

Map<String, Object?>? _p0PayServiceFeeRequirement(Object? payload) {
  final payloadMap = _payloadMap(payload);
  return _payloadMap(payloadMap?['platformServiceFeeRequirement']);
}

String _p0PayServiceFeeRequirementSummary(Object? payload) {
  final requirement = _p0PayServiceFeeRequirement(payload);
  if (requirement == null) {
    return '平台暂未返回服务费快照；请刷新或重新提交后以平台返回为准';
  }
  final feeRateLabel = _p0PayRequirementText(requirement, 'feeRateLabel');
  final baseFeeAmount = _p0PayRequirementText(requirement, 'baseFeeAmount');
  final membershipDiscountRate = _p0PayRequirementText(
    requirement,
    'membershipDiscountRate',
  );
  final capAmount = _p0PayRequirementText(requirement, 'capAmount');
  final finalFeeAmount =
      _p0PayRequirementText(requirement, 'finalFeeAmount') ??
      _p0PayRequirementText(requirement, 'estimatedFeeAmount');
  final feeRateSource = _p0PayFeeRateSourceDisplay(
    _p0PayRequirementText(requirement, 'feeRateSource'),
  );
  final membershipTier = _p0PayMembershipTierDisplay(
    _p0PayRequirementText(requirement, 'membershipTierSnapshot') ??
        _p0PayRequirementText(requirement, 'membershipTierAtAuthorization'),
  );
  final quotedAmount =
      _p0PayRequirementText(requirement, 'quotedAmount') ?? '未提供';
  final quotaAmount =
      _p0PayRequirementText(requirement, 'quotaAmount') ??
      _p0PayRequirementText(requirement, 'authorizationQuotaAmount') ??
      _p0PayRequirementText(requirement, 'estimatedFeeAmount') ??
      '4000.00';
  final currency = _p0PayRequirementText(requirement, 'currency') ?? 'CNY';
  final authorizationStatus =
      _p0PayRequirementText(requirement, 'authorizationStatus') ?? '待预授权';
  final ruleVersion = _p0PayRequirementText(requirement, 'feeRateRuleVersion');
  return <String>[
    '报价 $quotedAmount $currency',
    '服务费规则 ${feeRateLabel ?? '待平台返回'}',
    if (membershipTier != null) '会员等级 $membershipTier',
    if (baseFeeAmount != null) '基础服务费 $baseFeeAmount $currency',
    if (membershipDiscountRate != null)
      '会员折扣 ${_p0PayMembershipDiscountDisplay(membershipDiscountRate)}',
    if (capAmount != null) '封顶 $capAmount $currency',
    if (finalFeeAmount != null) '平台记录金额 $finalFeeAmount $currency',
    if (feeRateSource != null) '来源 $feeRateSource',
    '预授权额度 $quotaAmount $currency',
    '状态 $authorizationStatus',
    if (ruleVersion != null) '规则 $ruleVersion',
  ].join('；');
}

String _p0PayAuthorizationStatusText(ExhibitionLoadResult? result) {
  if (result == null) {
    return '未查询';
  }
  if (result.state != AppPageState.content) {
    return result.message ?? result.errorCode ?? '暂不可用';
  }
  final payload = _payloadMap(result.payload);
  final status =
      _normalizeDynamicText(payload?['authorizationStatus']) ??
      _normalizeDynamicText(payload?['status']) ??
      '已回读';
  final feeRateLabel = _normalizeDynamicText(payload?['feeRateLabel']);
  final baseFeeAmount = _normalizeDynamicText(payload?['baseFeeAmount']);
  final membershipDiscountRate = _normalizeDynamicText(
    payload?['membershipDiscountRate'],
  );
  final capAmount = _normalizeDynamicText(payload?['capAmount']);
  final estimatedFeeAmount = _normalizeDynamicText(
    payload?['estimatedFeeAmount'],
  );
  final membershipTier = _p0PayMembershipTierDisplay(
    _normalizeDynamicText(payload?['membershipTierSnapshot']) ??
        _normalizeDynamicText(payload?['membershipTierAtAuthorization']),
  );
  final quotaAmount =
      _normalizeDynamicText(payload?['quotaAmount']) ??
      _normalizeDynamicText(payload?['authorizationQuotaAmount']) ??
      _normalizeDynamicText(payload?['estimatedFeeAmount']);
  final currency = _normalizeDynamicText(payload?['currency']) ?? 'CNY';
  final suffix = status == 'authorized' ? '；已预授权，不是已扣款' : '';
  return <String>[
    '状态：$status$suffix',
    if (feeRateLabel != null) '服务费规则：$feeRateLabel',
    if (membershipTier != null) '会员等级：$membershipTier',
    if (baseFeeAmount != null) '基础服务费：$baseFeeAmount $currency',
    if (membershipDiscountRate != null)
      '会员折扣：${_p0PayMembershipDiscountDisplay(membershipDiscountRate)}',
    if (capAmount != null) '封顶：$capAmount $currency',
    if (estimatedFeeAmount != null) '平台记录金额：$estimatedFeeAmount $currency',
    if (quotaAmount != null) '预授权额度：$quotaAmount $currency',
  ].join('；');
}

String? _authorizationIdFromPayload(Object? payload) {
  return _stringFromPayload(payload, 'authorizationId');
}

String? _p0PayRequirementText(Map<String, Object?> requirement, String key) {
  return _normalizeDynamicText(requirement[key]);
}

double? _p0PayRequirementNumber(Map<String, Object?> requirement, String key) {
  final value = requirement[key];
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(_normalizeDynamicText(value) ?? '');
}

String? _p0PayMembershipTierDisplay(String? value) {
  switch (value) {
    case null:
    case '':
      return null;
    case 'none':
      return '未匹配会员等级';
    case 'free_certified':
      return '免费认证企业';
    case 'standard':
      return '标准会员';
    case 'professional':
      return '专业会员';
    case 'ka':
    case 'flagship':
      return 'KA / 旗舰';
    default:
      return value;
  }
}

String? _p0PayFeeRateSourceDisplay(String? value) {
  switch (value) {
    case null:
    case '':
      return null;
    case 'fixed_default':
      return '默认规则';
    case 'paid_membership_tier':
      return '会员等级';
    default:
      return value;
  }
}

String _p0PayMembershipDiscountDisplay(String value) {
  return switch (value.trim()) {
    '0.9000' || '0.9' => '9 折',
    '0.8000' || '0.8' => '8 折',
    '1.0000' || '1' => '无会员折扣',
    _ => value,
  };
}
