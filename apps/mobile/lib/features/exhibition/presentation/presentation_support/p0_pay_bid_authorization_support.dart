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
      const _DetailLine(label: '平台服务费率', value: '成交金额的 3%'),
      _DetailLine(label: '预计服务费', value: _p0PayEstimatedFeeText()),
      const _StateMessage(
        title: '你需要做什么',
        body: '选择报价有效期，核对平台服务费说明，并勾选规则确认。页面预计服务费用于理解，最终金额以平台提交后返回为准。',
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
    final quoteAmount = double.tryParse(_quoteAmountController.text.trim());
    if (quoteAmount == null || quoteAmount <= 0) {
      return '填写竞标报价后自动预估，最终以平台返回为准';
    }
    final estimatedFee = quoteAmount * 0.03;
    return '约 ${estimatedFee.toStringAsFixed(2)} 元，最终以平台返回为准';
  }
}

Map<String, Object?>? _p0PayServiceFeeRequirement(Object? payload) {
  final payloadMap = _payloadMap(payload);
  return _payloadMap(payloadMap?['platformServiceFeeRequirement']);
}

String _p0PayServiceFeeRequirementSummary(Object? payload) {
  final requirement = _p0PayServiceFeeRequirement(payload);
  if (requirement == null) {
    return 'BFF 未返回 platformServiceFeeRequirement';
  }
  final feeRate = _p0PayRequirementText(requirement, 'feeRate') ?? '未提供';
  final quotedAmount =
      _p0PayRequirementText(requirement, 'quotedAmount') ?? '未提供';
  final estimatedFeeAmount =
      _p0PayRequirementText(requirement, 'estimatedFeeAmount') ?? '未提供';
  final currency = _p0PayRequirementText(requirement, 'currency') ?? 'CNY';
  final authorizationStatus =
      _p0PayRequirementText(requirement, 'authorizationStatus') ?? '待预授权';
  return '报价 $quotedAmount $currency；费率 $feeRate；预计服务费 $estimatedFeeAmount $currency；状态 $authorizationStatus';
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
  final estimatedFeeAmount = _normalizeDynamicText(
    payload?['estimatedFeeAmount'],
  );
  final currency = _normalizeDynamicText(payload?['currency']) ?? 'CNY';
  final suffix = status == 'authorized' ? '；已预授权，不是已扣款' : '';
  return <String>[
    '状态：$status$suffix',
    if (feeRate != null) '费率：$feeRate',
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
