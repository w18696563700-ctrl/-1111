final class P0PayReadOnlyStatusLine {
  const P0PayReadOnlyStatusLine({required this.label, required this.value});

  final String label;
  final String value;
}

final class P0PayReadOnlyRouteTargetView {
  const P0PayReadOnlyRouteTargetView({
    required this.objectType,
    required this.actionKey,
    required this.canonicalPath,
  });

  final String? objectType;
  final String? actionKey;
  final String? canonicalPath;

  String get displayText {
    return <String>[?actionKey, ?canonicalPath].join(' · ');
  }
}

final class P0PayReadOnlySummaryView {
  const P0PayReadOnlySummaryView({
    required this.readOnly,
    required this.displayAllowed,
    required this.taskId,
    required this.taskType,
    required this.platformServiceFeeStatus,
    required this.platformServiceFeeEstimatedAmount,
    required this.platformServiceFeeBaseAmount,
    required this.platformServiceFeeDiscountRate,
    required this.platformServiceFeeCapAmount,
    required this.platformServiceFeeFinalAmount,
    required this.platformServiceFeeMembershipTier,
    required this.platformServiceFeeRuleLabel,
    required this.inquiryDepositStatus,
    required this.inquiryDepositAmount,
    required this.inquiryDepositOrderId,
    required this.inquiryDepositChannelCandidates,
    required this.contractConfirmationStatus,
    required this.statusTextKey,
    required this.routeTarget,
    required this.updatedAt,
  });

  final bool readOnly;
  final bool displayAllowed;
  final String? taskId;
  final String? taskType;
  final String? platformServiceFeeStatus;
  final String? platformServiceFeeEstimatedAmount;
  final String? platformServiceFeeBaseAmount;
  final String? platformServiceFeeDiscountRate;
  final String? platformServiceFeeCapAmount;
  final String? platformServiceFeeFinalAmount;
  final String? platformServiceFeeMembershipTier;
  final String? platformServiceFeeRuleLabel;
  final String? inquiryDepositStatus;
  final String? inquiryDepositAmount;
  final String? inquiryDepositOrderId;
  final List<String> inquiryDepositChannelCandidates;
  final String? contractConfirmationStatus;
  final String? statusTextKey;
  final P0PayReadOnlyRouteTargetView? routeTarget;
  final String? updatedAt;

  bool get hasDisplayableStatus {
    return platformServiceFeeStatus != null ||
        inquiryDepositStatus != null ||
        contractConfirmationStatus != null ||
        statusTextKey != null;
  }

  List<P0PayReadOnlyStatusLine> get statusLines {
    return <P0PayReadOnlyStatusLine>[
      if (taskType != null)
        P0PayReadOnlyStatusLine(
          label: '任务类型',
          value: p0PayTaskTypeLabel(taskType),
        ),
      if (platformServiceFeeStatus != null)
        P0PayReadOnlyStatusLine(
          label: '竞标服务费预授权',
          value: p0PayStatusLabel(platformServiceFeeStatus),
        ),
      if (platformServiceFeeEstimatedAmount != null)
        P0PayReadOnlyStatusLine(
          label: '预授权额度',
          value: platformServiceFeeEstimatedAmount!,
        ),
      if (platformServiceFeeRuleLabel != null)
        P0PayReadOnlyStatusLine(
          label: '服务费规则',
          value: platformServiceFeeRuleLabel!,
        ),
      if (platformServiceFeeMembershipTier != null)
        P0PayReadOnlyStatusLine(
          label: '会员档位快照',
          value: p0PayMembershipTierLabel(platformServiceFeeMembershipTier),
        ),
      if (platformServiceFeeBaseAmount != null)
        P0PayReadOnlyStatusLine(
          label: '服务费基础金额',
          value: platformServiceFeeBaseAmount!,
        ),
      if (platformServiceFeeDiscountRate != null)
        P0PayReadOnlyStatusLine(
          label: '会员折扣',
          value: p0PayMembershipDiscountLabel(platformServiceFeeDiscountRate),
        ),
      if (platformServiceFeeCapAmount != null)
        P0PayReadOnlyStatusLine(
          label: '服务费封顶',
          value: platformServiceFeeCapAmount!,
        ),
      if (platformServiceFeeFinalAmount != null)
        P0PayReadOnlyStatusLine(
          label: '最终服务费',
          value: platformServiceFeeFinalAmount!,
        ),
      if (inquiryDepositStatus != null)
        P0PayReadOnlyStatusLine(
          label: '项目真实性诚意金',
          value: p0PayStatusLabel(inquiryDepositStatus),
        ),
      if (inquiryDepositAmount != null)
        P0PayReadOnlyStatusLine(label: '诚意金金额', value: inquiryDepositAmount!),
      if (inquiryDepositOrderId != null)
        P0PayReadOnlyStatusLine(label: '诚意金订单', value: inquiryDepositOrderId!),
      if (contractConfirmationStatus != null)
        P0PayReadOnlyStatusLine(
          label: '合同确认',
          value: p0PayStatusLabel(contractConfirmationStatus),
        ),
      if (statusTextKey != null)
        P0PayReadOnlyStatusLine(
          label: '消息楼状态',
          value: p0PayStatusTextKeyLabel(statusTextKey),
        ),
      P0PayReadOnlyStatusLine(label: '消息楼只读', value: readOnly ? '是' : '否'),
    ];
  }
}

P0PayReadOnlySummaryView? parseP0PayReadOnlySummary(Object? payload) {
  final record = _asMap(payload);
  if (record == null) {
    return null;
  }

  final platformServiceFee = _asMap(record['platformServiceFee']);
  final bidServiceFeeAuthorization = _asMap(
    record['bidServiceFeeAuthorization'],
  );
  final platformServiceFeeCharge = _asMap(
    record['platformServiceFeeCharge'],
  );
  final inquiryDeposit = _asMap(record['inquiryDeposit']);
  final projectAuthenticitySincerity = _asMap(
    record['projectAuthenticitySincerity'],
  );
  final publisherPricing = _asMap(record['publisherPricing']);
  final bidderPricing = _asMap(record['bidderPricing']);
  final contractConfirmation = _asMap(record['contractConfirmation']);
  final dealSummary = _asMap(record['dealSummary']);
  final messageDisplaySummary = _asMap(record['messageDisplaySummary']);
  final routeTarget = _parseReadOnlyRouteTarget(
    messageDisplaySummary?['routeTarget'] ??
        _asMap(publisherPricing?['nextAction']) ??
        _asMap(bidderPricing?['nextAction']) ??
        record['routeTarget'],
  );

  final summary = P0PayReadOnlySummaryView(
    readOnly:
        _readBool(messageDisplaySummary?['readOnly']) ??
        _readBool(record['readOnly']) ??
        true,
    displayAllowed:
        _readBool(messageDisplaySummary?['displayAllowed']) ??
        _readBool(record['displayAllowed']) ??
        true,
    taskId: _readText(record['taskId']) ?? _readText(record['projectId']),
    taskType: _readText(record['taskType']),
    platformServiceFeeStatus:
        _readText(record['platformServiceFeeStatus']) ??
        _readText(record['bidServiceFeeAuthorizationStatus']) ??
        _readText(record['authorizationStatus']) ??
        _readText(bidderPricing?['bidServiceFeeAuthorizationStatus']) ??
        _readText(bidderPricing?['authorizationStatus']) ??
        _readText(bidServiceFeeAuthorization?['authorizationStatus']) ??
        _readText(bidServiceFeeAuthorization?['status']) ??
        _readText(platformServiceFee?['platformServiceFeeStatus']) ??
        _readText(platformServiceFee?['authorizationStatus']) ??
        _readText(platformServiceFee?['status']),
    platformServiceFeeEstimatedAmount:
        _readText(record['platformServiceFeeEstimatedAmount']) ??
        _readText(record['quotaAmount']) ??
        _readText(record['authorizationQuotaAmount']) ??
        _readText(bidderPricing?['quotaAmount']) ??
        _readText(bidderPricing?['authorizationQuotaAmount']) ??
        _readText(bidServiceFeeAuthorization?['quotaAmount']) ??
        _readText(bidServiceFeeAuthorization?['authorizationQuotaAmount']) ??
        _readText(platformServiceFee?['quotaAmount']) ??
        _readText(platformServiceFee?['authorizationQuotaAmount']) ??
        _readText(platformServiceFee?['estimatedFeeAmount']) ??
        _readText(platformServiceFee?['estimatedAmount']),
    platformServiceFeeBaseAmount:
        _readText(record['platformServiceFeeBaseAmount']) ??
        _readText(record['baseFeeAmount']) ??
        _readText(platformServiceFeeCharge?['baseFeeAmount']) ??
        _readText(platformServiceFee?['baseFeeAmount']),
    platformServiceFeeDiscountRate:
        _readText(record['platformServiceFeeDiscountRate']) ??
        _readText(record['membershipDiscountRate']) ??
        _readText(platformServiceFeeCharge?['membershipDiscountRate']) ??
        _readText(platformServiceFee?['membershipDiscountRate']),
    platformServiceFeeCapAmount:
        _readText(record['platformServiceFeeCapAmount']) ??
        _readText(record['capAmount']) ??
        _readText(platformServiceFeeCharge?['capAmount']) ??
        _readText(platformServiceFee?['capAmount']),
    platformServiceFeeFinalAmount:
        _readText(record['platformServiceFeeFinalAmount']) ??
        _readText(record['finalFeeAmount']) ??
        _readText(platformServiceFeeCharge?['finalFeeAmount']) ??
        _readText(platformServiceFee?['finalFeeAmount']) ??
        _readText(platformServiceFee?['finalAmount']),
    platformServiceFeeMembershipTier:
        _readText(record['platformServiceFeeMembershipTier']) ??
        _readText(record['membershipTierSnapshot']) ??
        _readText(platformServiceFeeCharge?['membershipTierSnapshot']) ??
        _readText(platformServiceFee?['membershipTierSnapshot']),
    platformServiceFeeRuleLabel:
        _readText(record['platformServiceFeeRuleLabel']) ??
        _readText(record['feeRateLabel']) ??
        _readText(platformServiceFeeCharge?['feeRateLabel']) ??
        _readText(platformServiceFee?['feeRateLabel']),
    inquiryDepositStatus:
        _readText(record['inquiryDepositStatus']) ??
        _readText(record['authenticitySincerityStatus']) ??
        _readText(projectAuthenticitySincerity?['orderStatus']) ??
        _readText(projectAuthenticitySincerity?['depositStatus']) ??
        _readText(projectAuthenticitySincerity?['status']) ??
        _readText(publisherPricing?['authenticitySincerityStatus']) ??
        _readText(inquiryDeposit?['depositStatus']) ??
        _readText(inquiryDeposit?['status']),
    inquiryDepositAmount:
        _readText(record['inquiryDepositAmount']) ??
        _readText(projectAuthenticitySincerity?['amount']) ??
        _readText(publisherPricing?['authenticitySincerityAmount']) ??
        _readText(inquiryDeposit?['amount']),
    inquiryDepositOrderId:
        _readText(record['inquiryDepositOrderId']) ??
        _readText(record['authenticitySincerityOrderId']) ??
        _readText(projectAuthenticitySincerity?['orderId']) ??
        _readText(projectAuthenticitySincerity?['depositOrderId']) ??
        _readText(publisherPricing?['authenticitySincerityOrderId']) ??
        _readText(inquiryDeposit?['orderId']) ??
        _readText(inquiryDeposit?['depositOrderId']),
    inquiryDepositChannelCandidates: _readStringList(
      record['inquiryDepositChannelCandidates'] ??
          record['authenticitySincerityChannelCandidates'] ??
          projectAuthenticitySincerity?['channelCandidates'] ??
          publisherPricing?['authenticitySincerityChannelCandidates'] ??
          inquiryDeposit?['channelCandidates'],
    ),
    contractConfirmationStatus:
        _readText(record['contractConfirmationStatus']) ??
        _readText(record['dealStatus']) ??
        _readText(dealSummary?['dealStatus']) ??
        _readText(dealSummary?['status']) ??
        _readText(contractConfirmation?['contractStatus']) ??
        _readText(contractConfirmation?['status']),
    statusTextKey:
        _readText(messageDisplaySummary?['statusTextKey']) ??
        _readText(record['statusTextKey']),
    routeTarget: routeTarget,
    updatedAt: _readText(record['updatedAt']),
  );

  if (!summary.hasDisplayableStatus &&
      summary.taskId == null &&
      summary.taskType == null &&
      routeTarget == null) {
    return null;
  }
  return summary;
}

String p0PayTaskTypeLabel(String? value) {
  return switch (value) {
    'fixed_price_bid' => '明价竞标单',
    'inquiry_quote' => '询价报价单',
    null => '未提供',
    _ => value,
  };
}

String p0PayStatusLabel(String? value) {
  return switch (value) {
    'not_required' => '无需处理',
    'pending_payment' => '待支付',
    'pending_authorization' => '待预授权',
    'pending_user_confirm' => '等待用户确认',
    'paid' => '已支付',
    'frozen' => '已冻结',
    'authorized' => '已预授权',
    'authorization_released' || 'released' => '已释放',
    'pending_contract_confirm' => '待合同确认',
    'charged' => '已扣取',
    'refund_pending' => '退款中',
    'refunded' => '已退回',
    'deducted' => '已扣除',
    'breach_hold' => '违约挂起',
    'dispute_hold' => '争议挂起',
    'cancelled' => '已取消',
    'failed' => '失败',
    'confirmed' => '已确认',
    'pending' => '待处理',
    null => '未提供',
    _ => value,
  };
}

String p0PayStatusTextKeyLabel(String? value) {
  return switch (value) {
    'p0_pay_status_unavailable' => '状态暂不可用',
    'platform_service_fee_authorized' => '平台服务费已预授权',
    'bid_service_fee_authorization_frozen' => '竞标服务费预授权额度已冻结',
    'project_authenticity_sincerity_paid' => '项目真实性诚意金已完成',
    'inquiry_deposit_paid' => '发单诚意金已支付',
    'contract_confirmation_pending' => '合同确认待处理',
    'charged' => '已扣取',
    null => '未提供',
    _ => value,
  };
}

String p0PayMembershipTierLabel(String? value) {
  return switch (value) {
    'none' => '未匹配付费会员',
    'free_certified' => '免费认证版',
    'standard' => '标准会员',
    'professional' => '专业会员',
    'ka' || 'flagship' => 'KA / 旗舰预留',
    null => '未提供',
    _ => value,
  };
}

String p0PayMembershipDiscountLabel(String? value) {
  return switch (value) {
    '0.9000' || '0.9' => '9 折',
    '0.8000' || '0.8' => '8 折',
    '1.0000' || '1' => '无会员折扣',
    null => '未提供',
    _ => value,
  };
}

P0PayReadOnlyRouteTargetView? _parseReadOnlyRouteTarget(Object? payload) {
  final record = _asMap(payload);
  if (record == null) {
    return null;
  }
  final actionKey = _readText(record['actionKey']);
  final canonicalPath = _readText(record['canonicalPath']);
  final objectType = _readText(record['objectType']);
  if (actionKey == null && canonicalPath == null && objectType == null) {
    return null;
  }
  return P0PayReadOnlyRouteTargetView(
    objectType: objectType,
    actionKey: actionKey,
    canonicalPath: canonicalPath,
  );
}

Map<String, Object?>? _asMap(Object? payload) {
  if (payload is Map) {
    return payload.map((Object? key, Object? value) => MapEntry('$key', value));
  }
  return null;
}

String? _readText(Object? value) {
  if (value == null) {
    return null;
  }
  final normalized = '$value'.trim();
  return normalized.isEmpty ? null : normalized;
}

bool? _readBool(Object? value) {
  return value is bool ? value : null;
}

List<String> _readStringList(Object? value) {
  if (value is! Iterable) {
    return const <String>[];
  }
  return value
      .map(_readText)
      .whereType<String>()
      .where((String item) => item.isNotEmpty)
      .toList(growable: false);
}
