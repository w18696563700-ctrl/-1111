// ignore_for_file: invalid_use_of_protected_member

part of '../exhibition_trade_pages.dart';

const List<int> _p0PayQuoteValidHourOptions = <int>[12, 24, 36, 48, 60, 72];

extension _P0PayBidAuthorizationSupport on _BidSubmitPageState {
  List<Widget> _buildP0PayFixedPriceBidAuthorizationFields() {
    return <Widget>[
      Text(
        '平台成交服务费确认',
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
      ),
      const SizedBox(height: 8),
      const _DetailLine(label: '服务费确认', value: '平台成交服务费确认', highlight: true),
      const _DetailLine(label: '平台服务费率', value: '待平台返回'),
      _DetailLine(label: '预计服务费', value: _p0PayEstimatedFeeText()),
      const _StateMessage(
        title: '你需要做什么',
        body:
            '选择报价有效期，核对平台服务费说明，并勾选规则确认。提交报价后，平台会返回本次费率、费率来源和预计服务费；本页不本地计算正式金额。',
      ),
      const SizedBox(height: 12),
      _buildP0PayQuoteValiditySelector(),
      const SizedBox(height: 8),
      _buildP0PayAuthorizationCheckbox(
        value: _p0PayReadRuleConfirmed,
        title: '我已阅读并同意平台成交服务费规则',
        onChanged: (bool value) =>
            setState(() => _p0PayReadRuleConfirmed = value),
      ),
      _buildP0PayAuthorizationCheckbox(
        value: _p0PayAuthorizationAwarenessConfirmed,
        title: '我知晓未中标自动释放，中标并合同确认后正式扣款',
        onChanged: (bool value) =>
            setState(() => _p0PayAuthorizationAwarenessConfirmed = value),
      ),
      _buildP0PayAuthorizationCheckbox(
        value: _p0PayPublisherBreachReleaseConfirmed,
        title: '我知晓发布方毁约或项目条件重大变化时，预授权应按规则释放',
        onChanged: (bool value) =>
            setState(() => _p0PayPublisherBreachReleaseConfirmed = value),
      ),
      ..._buildP0PayAuthorizationResultLines(),
    ];
  }

  Widget _buildP0PayQuoteValiditySelector() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '报价有效期',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _p0PayQuoteValidHourOptions
              .map((int hours) {
                return ChoiceChip(
                  key: ValueKey<String>('p0-pay-quote-valid-hours-$hours'),
                  label: Text('$hours小时'),
                  selected: _p0PayQuoteValidHours == hours,
                  onSelected: (_) {
                    setState(() => _p0PayQuoteValidHours = hours);
                  },
                );
              })
              .toList(growable: false),
        ),
        const SizedBox(height: 8),
        Text(
          '默认 48 小时；提交时会自动换算成接口需要的 quoteValidUntil。',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildP0PayAuthorizationCheckbox({
    required bool value,
    required String title,
    required ValueChanged<bool> onChanged,
  }) {
    return CheckboxListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      value: value,
      title: Text(title),
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (bool? next) => onChanged(next ?? false),
    );
  }

  String _p0PayEstimatedFeeText() {
    return '待平台返回，正式金额以平台返回为准';
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
  final feeRate = _p0PayRequirementText(requirement, 'feeRate');
  final feeRateLabel = _p0PayRequirementText(requirement, 'feeRateLabel');
  final feeRateSource = _p0PayFeeRateSourceDisplay(
    _p0PayRequirementText(requirement, 'feeRateSource'),
  );
  final membershipTier = _p0PayMembershipTierDisplay(
    _p0PayRequirementText(requirement, 'membershipTierSnapshot') ??
        _p0PayRequirementText(requirement, 'membershipTierAtAuthorization'),
  );
  final quotedAmount =
      _p0PayRequirementText(requirement, 'quotedAmount') ?? '未提供';
  final estimatedFeeAmount =
      _p0PayRequirementText(requirement, 'estimatedFeeAmount') ?? '待平台返回';
  final currency = _p0PayRequirementText(requirement, 'currency') ?? 'CNY';
  final authorizationStatus =
      _p0PayRequirementText(requirement, 'authorizationStatus') ?? '待预授权';
  final ruleVersion = _p0PayRequirementText(requirement, 'feeRateRuleVersion');
  return <String>[
    '报价 $quotedAmount $currency',
    '费率 ${_p0PayFeeRateDisplay(label: feeRateLabel, rate: feeRate)}',
    if (membershipTier != null) '会员等级 $membershipTier',
    if (feeRateSource != null) '来源 $feeRateSource',
    '预计服务费 $estimatedFeeAmount $currency',
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
  final feeRate = _normalizeDynamicText(payload?['feeRate']);
  final feeRateLabel = _normalizeDynamicText(payload?['feeRateLabel']);
  final membershipTier = _p0PayMembershipTierDisplay(
    _normalizeDynamicText(payload?['membershipTierSnapshot']) ??
        _normalizeDynamicText(payload?['membershipTierAtAuthorization']),
  );
  final estimatedFeeAmount = _normalizeDynamicText(
    payload?['estimatedFeeAmount'],
  );
  final currency = _normalizeDynamicText(payload?['currency']) ?? 'CNY';
  final suffix = status == 'authorized' ? '；已预授权，不是已扣款' : '';
  return <String>[
    '状态：$status$suffix',
    if (feeRate != null || feeRateLabel != null)
      '费率：${_p0PayFeeRateDisplay(label: feeRateLabel, rate: feeRate)}',
    if (membershipTier != null) '会员等级：$membershipTier',
    if (estimatedFeeAmount != null) '预计服务费：$estimatedFeeAmount $currency',
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

String _p0PayFeeRateDisplay({String? label, String? rate}) {
  final formattedRate = _p0PayFeeRatePercent(rate);
  if (label != null &&
      formattedRate != null &&
      !label.contains(formattedRate)) {
    return '$label（$formattedRate）';
  }
  return label ?? formattedRate ?? '待平台返回';
}

String? _p0PayFeeRatePercent(String? value) {
  final text = value?.trim();
  if (text == null || text.isEmpty) {
    return null;
  }
  if (text.endsWith('%')) {
    return text;
  }
  final parsed = double.tryParse(text);
  if (parsed == null) {
    return text;
  }
  final percent = parsed * 100;
  final fixed = percent.toStringAsFixed(2);
  final trimmed = fixed
      .replaceFirst(RegExp(r'\.00$'), '')
      .replaceFirst(RegExp(r'0$'), '');
  return '$trimmed%';
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
