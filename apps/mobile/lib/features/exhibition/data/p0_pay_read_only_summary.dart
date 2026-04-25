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
    required this.platformServiceFeeFinalAmount,
    required this.inquiryDepositStatus,
    required this.inquiryDepositAmount,
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
  final String? platformServiceFeeFinalAmount;
  final String? inquiryDepositStatus;
  final String? inquiryDepositAmount;
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
          label: '平台服务费',
          value: p0PayStatusLabel(platformServiceFeeStatus),
        ),
      if (platformServiceFeeEstimatedAmount != null)
        P0PayReadOnlyStatusLine(
          label: '预计服务费',
          value: platformServiceFeeEstimatedAmount!,
        ),
      if (platformServiceFeeFinalAmount != null)
        P0PayReadOnlyStatusLine(
          label: '最终服务费',
          value: platformServiceFeeFinalAmount!,
        ),
      if (inquiryDepositStatus != null)
        P0PayReadOnlyStatusLine(
          label: '发单诚意金',
          value: p0PayStatusLabel(inquiryDepositStatus),
        ),
      if (inquiryDepositAmount != null)
        P0PayReadOnlyStatusLine(label: '诚意金金额', value: inquiryDepositAmount!),
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
  final inquiryDeposit = _asMap(record['inquiryDeposit']);
  final contractConfirmation = _asMap(record['contractConfirmation']);
  final messageDisplaySummary = _asMap(record['messageDisplaySummary']);
  final routeTarget = _parseReadOnlyRouteTarget(
    messageDisplaySummary?['routeTarget'] ?? record['routeTarget'],
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
    taskId: _readText(record['taskId']),
    taskType: _readText(record['taskType']),
    platformServiceFeeStatus:
        _readText(record['platformServiceFeeStatus']) ??
        _readText(record['authorizationStatus']) ??
        _readText(platformServiceFee?['platformServiceFeeStatus']) ??
        _readText(platformServiceFee?['authorizationStatus']) ??
        _readText(platformServiceFee?['status']),
    platformServiceFeeEstimatedAmount:
        _readText(record['platformServiceFeeEstimatedAmount']) ??
        _readText(platformServiceFee?['estimatedFeeAmount']) ??
        _readText(platformServiceFee?['estimatedAmount']),
    platformServiceFeeFinalAmount:
        _readText(record['platformServiceFeeFinalAmount']) ??
        _readText(record['finalFeeAmount']) ??
        _readText(platformServiceFee?['finalFeeAmount']) ??
        _readText(platformServiceFee?['finalAmount']),
    inquiryDepositStatus:
        _readText(record['inquiryDepositStatus']) ??
        _readText(inquiryDeposit?['depositStatus']) ??
        _readText(inquiryDeposit?['status']),
    inquiryDepositAmount:
        _readText(record['inquiryDepositAmount']) ??
        _readText(inquiryDeposit?['amount']),
    contractConfirmationStatus:
        _readText(record['contractConfirmationStatus']) ??
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
    'inquiry_deposit_paid' => '发单诚意金已支付',
    'contract_confirmation_pending' => '合同确认待处理',
    'charged' => '已扣取',
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
