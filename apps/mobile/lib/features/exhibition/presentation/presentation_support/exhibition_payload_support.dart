part of '../exhibition_trade_pages.dart';

List<Widget> _routeOnlyControls({
  required String? routeId,
  required String label,
  required VoidCallback onReload,
  required String reloadLabel,
}) {
  if (routeId == null) {
    return const <Widget>[];
  }

  return <Widget>[
    _InstanceSummaryLine(title: _instanceTitleForLabel(label), value: routeId),
    const SizedBox(height: 12),
    FilledButton.tonal(onPressed: onReload, child: Text(reloadLabel)),
  ];
}

String _instanceTitleForLabel(String label) {
  return switch (label) {
    'projectId' => '当前项目 ID',
    'bidId' => '当前竞标 ID',
    'bidAwardId' => '当前定标 ID',
    'orderId' => '当前订单 ID',
    'contractId' => '当前合同 ID',
    'milestoneId' => '当前里程碑 ID',
    'inspectionId' => '当前验收 ID',
    'ratingId' => '当前评价 ID',
    'disputeId' => '当前争议 ID',
    _ => '当前实例 $label',
  };
}

String? _normalizeId(String? value) {
  if (value == null) {
    return null;
  }

  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String _buildingTypeLabel(String? value) {
  final normalized = _normalizeId(value);
  return switch (normalized) {
    'exhibition' => '会展',
    'renovation' => '装修',
    'custom_furniture' => '定制',
    null => '未提供',
    _ => normalized,
  };
}

String _currencyText(Object? value) {
  if (value is int) {
    return '¥$value';
  }
  if (value is double) {
    final isWhole = value == value.roundToDouble();
    return isWhole ? '¥${value.toInt()}' : '¥${value.toStringAsFixed(2)}';
  }
  if (value is num) {
    return '¥$value';
  }
  return '未提供';
}

Map<String, Object?>? _payloadMap(Object? payload) {
  if (payload is Map) {
    return payload.map((Object? key, Object? value) => MapEntry('$key', value));
  }

  return null;
}

String? _projectIdFromPayload(Object? payload) {
  return _normalizeId(_payloadMap(payload)?['projectId'] as String?);
}

String? _currentViewerBidIdFromPayload(Object? payload) {
  return _normalizeDynamicText(
    _payloadMap(_payloadMap(payload)?['currentViewerBid'])?['bidId'],
  );
}

String? _currentViewerBidStateFromPayload(Object? payload) {
  return _normalizeDynamicText(
    _payloadMap(_payloadMap(payload)?['currentViewerBid'])?['state'],
  );
}

bool _hasCurrentViewerBid(Object? payload) {
  return _currentViewerBidIdFromPayload(payload) != null;
}

String? _taskIdFromPayload(Object? payload) {
  return _stringFromPayload(payload, 'taskId') ??
      _projectIdFromPayload(payload);
}

String? _depositOrderIdFromPayload(Object? payload) {
  return _stringFromPayload(payload, 'depositOrderId');
}

String? _paymentReferenceIdFromPayload(Object? payload) {
  final payloadMap = _payloadMap(payload);
  return _normalizeDynamicText(payloadMap?['paymentReferenceId']) ??
      _normalizeDynamicText(payloadMap?['merchantOrderNo']) ??
      _normalizeDynamicText(
        _payloadMap(payloadMap?['channelPayload'])?['merchantOrderNo'],
      );
}

String _depositStatusText(ExhibitionLoadResult? result) {
  if (result == null) {
    return '未查询';
  }
  if (result.state != AppPageState.content) {
    return result.message ?? result.errorCode ?? '暂不可用';
  }
  final payload = _payloadMap(result.payload);
  final status =
      _normalizeDynamicText(payload?['depositStatus']) ??
      _normalizeDynamicText(payload?['status']) ??
      _normalizeDynamicText(_payloadMap(payload?['channelSummary'])?['status']);
  final refundStatus = _normalizeDynamicText(payload?['refundStatus']);
  final deductionStatus = _normalizeDynamicText(payload?['deductionStatus']);
  final summary = <String>[
    if (status != null) '状态：$status',
    if (refundStatus != null) '退款：$refundStatus',
    if (deductionStatus != null) '扣除：$deductionStatus',
  ].join('；');
  return summary.isEmpty ? '状态已回读' : summary;
}

String _p0PayActionFailureText(ExhibitionActionResult result) {
  final errorCode = _normalizeDynamicText(result.errorCode);
  final message = _normalizeDynamicText(result.message);
  if (errorCode == 'PAYMENT_CHANNEL_UNAVAILABLE') {
    return '支付通道暂不可用，请稍后重新拉起。';
  }
  if (errorCode == 'PAYMENT_CHANNEL_CONSTRAINT_REQUIRES_REVERIFICATION') {
    return '支付通道要求重新核验，请返回后重新拉起。';
  }
  if (errorCode == 'IDEMPOTENCY_KEY_CONFLICT') {
    return '检测到重复提交冲突，请先刷新状态，不自动视为成功。';
  }
  return message ?? errorCode ?? '拉起失败';
}

String _p0PayPaymentPollResultText(P0PayPaymentPollResult result) {
  final status = result.status ?? '未返回状态';
  final attempts = result.attempts;
  final state = result.result.state;
  final errorCode = _normalizeDynamicText(result.result.errorCode);
  final message = _normalizeDynamicText(result.result.message);

  if (result.timedOut) {
    return '已轮询 $attempts 次仍未获得最终状态，当前状态 $status。请刷新状态或重新拉起支付，不把等待中伪装为成功。';
  }

  if (result.outcome == P0PayPaymentOutcome.controlledFailure) {
    return _p0PayControlledFailureText(
      errorCode: errorCode,
      message: message,
      fallback: '状态查询失败：$state。',
    );
  }

  final prefix = switch (result.kind) {
    P0PayPaymentKind.inquiryDeposit => '发单诚意金',
    P0PayPaymentKind.projectAuthenticitySincerity => '项目真实性诚意金',
    P0PayPaymentKind.serviceFeeAuthorization => '平台服务费预授权',
  };

  return switch (result.outcome) {
    P0PayPaymentOutcome.pending =>
      '$prefix 仍在等待支付通道确认，状态 $status；Flutter 只读取 BFF 状态，不接收回调真相。',
    P0PayPaymentOutcome.success =>
      '$prefix 已确认，状态 $status；该结果来自 BFF/Server 只读回读。',
    P0PayPaymentOutcome.charged =>
      '$prefix 已扣取，状态 $status；合同确认后扣费真相以 Server 为准。',
    P0PayPaymentOutcome.released => '$prefix 已释放，状态 $status；Flutter 只展示只读结果。',
    P0PayPaymentOutcome.refunded => '$prefix 已退回，状态 $status；Flutter 不裁定退款。',
    P0PayPaymentOutcome.deducted =>
      '$prefix 已按规则处理为扣除状态 $status；Flutter 不裁定扣除。',
    P0PayPaymentOutcome.held => '$prefix 处于挂起状态 $status；Flutter 不裁定资金状态。',
    P0PayPaymentOutcome.processing => '$prefix 处于处理中状态 $status；请以 BFF 后续回读为准。',
    P0PayPaymentOutcome.failed ||
    P0PayPaymentOutcome.cancelled ||
    P0PayPaymentOutcome.expired ||
    P0PayPaymentOutcome.unknown => '$prefix 未完成，状态 $status；可重新拉起支付或返回后刷新。',
    P0PayPaymentOutcome.controlledFailure ||
    P0PayPaymentOutcome.timedOut => '$prefix 状态暂不可确认，请刷新状态。',
  };
}

String _p0PayControlledFailureText({
  required String? errorCode,
  required String? message,
  required String fallback,
}) {
  return switch (errorCode) {
    'AUTH_SESSION_INVALID' => '登录状态失效，请重新登录后再查看支付结果。',
    'ORGANIZATION_CERTIFICATION_REQUIRED' => '当前组织需先完成认证，不能伪装为可支付成功。',
    'TRADE_TASK_INVALID_STATE' => '当前交易任务状态不可继续支付。',
    'PROJECT_AUTHENTICITY_SINCERITY_RESULT_UNAVAILABLE' =>
      '项目真实性诚意金结果暂不可用，请稍后刷新。',
    'SERVICE_FEE_AUTHORIZATION_RESULT_UNAVAILABLE' => '平台服务费预授权结果暂不可用，请稍后刷新。',
    'INQUIRY_DEPOSIT_RESULT_UNAVAILABLE' => '发单诚意金结果暂不可用，请稍后刷新。',
    'PAYMENT_CHANNEL_UNAVAILABLE' => '支付通道暂不可用，请稍后重试。',
    'PAYMENT_CHANNEL_CONSTRAINT_REQUIRES_REVERIFICATION' => '支付通道要求重新核验，请重新拉起。',
    'IDEMPOTENCY_KEY_CONFLICT' => '检测到重复提交冲突，请先刷新状态。',
    _ => message ?? errorCode ?? fallback,
  };
}

String? _channelPayloadUrl(Object? payload) {
  final payloadMap = _payloadMap(payload);
  final channelPayload =
      _payloadMap(payloadMap?['channelPayload']) ?? payloadMap;
  if (channelPayload == null) {
    return null;
  }

  const candidateKeys = <String>[
    'url',
    'redirectUrl',
    'paymentUrl',
    'h5Url',
    'qrCodeUrl',
  ];
  for (final key in candidateKeys) {
    final value = _normalizeDynamicText(channelPayload[key]);
    if (value != null && Uri.tryParse(value)?.hasScheme == true) {
      return value;
    }
  }
  return null;
}

String? _stringFromPayload(Object? payload, String key) {
  return _normalizeDynamicText(_payloadMap(payload)?[key]);
}

String? _normalizeDynamicText(Object? value) {
  if (value == null) {
    return null;
  }
  return _normalizeId('$value');
}

String? _bidIdFromPayload(Object? payload) {
  return _normalizeId(_payloadMap(payload)?['bidId'] as String?);
}

String? _bidAwardIdFromPayload(Object? payload) {
  return _normalizeId(_payloadMap(payload)?['bidAwardId'] as String?);
}

String? _orderIdFromPayload(Object? payload) {
  return _normalizeId(_payloadMap(payload)?['orderId'] as String?);
}

String? _contractIdFromPayload(Object? payload) {
  return _normalizeId(_payloadMap(payload)?['contractId'] as String?);
}

String? _resultFromPayload(Object? payload) {
  return _normalizeId(_payloadMap(payload)?['result'] as String?);
}

String? _stateFromPayload(Object? payload) {
  return _normalizeId(_payloadMap(payload)?['state'] as String?);
}

String? _inspectionIdFromPayload(Object? payload) {
  return _normalizeId(_payloadMap(payload)?['inspectionId'] as String?);
}

String? _disputeIdFromPayload(Object? payload) {
  return _normalizeId(_payloadMap(payload)?['disputeId'] as String?);
}

List<_MilestoneLink> _milestonesFromPayload(Object? payload) {
  final payloadMap = _payloadMap(payload);
  if (payloadMap == null) {
    return const <_MilestoneLink>[];
  }

  final rawItems = payloadMap['milestones'] ?? payloadMap['items'];
  if (rawItems is! List) {
    return const <_MilestoneLink>[];
  }

  return rawItems
      .whereType<Map>()
      .map<Map<String, Object?>>(
        (Map item) =>
            item.map((Object? key, Object? value) => MapEntry('$key', value)),
      )
      .map(_MilestoneLink.fromPayload)
      .whereType<_MilestoneLink>()
      .toList();
}

List<Map<String, Object?>> _itemMapsFromPayload(Object? payload) {
  final payloadMap = _payloadMap(payload);
  final rawItems = payloadMap?['items'];
  if (rawItems is! List) {
    return const <Map<String, Object?>>[];
  }

  return rawItems
      .whereType<Map>()
      .map<Map<String, Object?>>(
        (Map item) =>
            item.map((Object? key, Object? value) => MapEntry('$key', value)),
      )
      .toList();
}

String? _projectExhibitionName(Map<String, Object?> item) {
  return _normalizeId(item['exhibitionName'] as String?);
}

String? _projectBrandName(Map<String, Object?> item) {
  return _normalizeId(item['brandName'] as String?);
}

String? _projectMaskedDisplayTitle(Map<String, Object?> item) {
  return _normalizeId(item['displayTitle'] as String?);
}

Map<String, Object?>? _projectNameAccessMap(Map<String, Object?> item) {
  return _payloadMap(item['nameAccess']);
}

String? _projectNameAccessStatus(Map<String, Object?> item) {
  return _normalizeId(_projectNameAccessMap(item)?['status'] as String?);
}

bool _projectCanRequestNameAccess(Map<String, Object?> item) {
  return _projectNameAccessMap(item)?['canRequest'] == true;
}

String? _projectNameAccessRequestId(Map<String, Object?> item) {
  return _normalizeId(_projectNameAccessMap(item)?['requestId'] as String?);
}

bool _projectNameIsVisible(Map<String, Object?> item) {
  final status = _projectNameAccessStatus(item);
  return status == null || status == 'visible';
}

bool _projectShouldShowNameAccessControls(Map<String, Object?> item) {
  final status = _projectNameAccessStatus(item);
  return status != null && status != 'visible';
}

String _projectDisplayTitle(Map<String, Object?> item) {
  final displayTitle = _projectMaskedDisplayTitle(item);
  if (!_projectNameIsVisible(item)) {
    return displayTitle ?? '项目名称需申请查看';
  }
  return displayTitle ??
      _projectExhibitionName(item) ??
      _normalizeId(item['title'] as String?) ??
      '未命名项目';
}

String? _projectDisplayBrandLine(Map<String, Object?> item) {
  if (!_projectNameIsVisible(item)) {
    return null;
  }
  return _projectBrandName(item);
}

String? _projectDateRangeLabel(Map<String, Object?> item) {
  final plannedStartAt = _normalizeId(item['plannedStartAt'] as String?);
  final plannedEndAt = _normalizeId(item['plannedEndAt'] as String?);
  if (plannedStartAt == null && plannedEndAt == null) {
    return null;
  }
  if (plannedStartAt != null && plannedEndAt != null) {
    return '$plannedStartAt 至 $plannedEndAt';
  }
  return plannedStartAt ?? plannedEndAt;
}

String _projectNameAccessStatusLabel(String? status) {
  return switch (status) {
    'requestable' => '可申请参与',
    'pending' => '待审批',
    'rejected' => '已拒绝',
    'visible' => '已通过',
    _ => '状态待确认',
  };
}

String _projectNameAccessStatusBody(Map<String, Object?> item) {
  final status = _projectNameAccessStatus(item);
  final canRequest = _projectCanRequestNameAccess(item);
  return switch (status) {
    'requestable' =>
      canRequest
          ? '当前项目需先申请参与竞标；发布方同意后可查看名称、报价依据资料并提交竞标。'
          : '当前项目需先申请参与竞标，请先登录并切换可申请主体后再试。',
    'pending' => '你已经提交参与竞标申请，等待发布方审批。',
    'rejected' =>
      canRequest ? '本次参与申请已被拒绝；如仍需参与，可重新发起申请。' : '本次参与申请已被拒绝，当前暂不可重新发起申请。',
    'visible' => '当前参与申请已通过，可以继续查看资料并提交竞标。',
    _ => '当前项目仍处于参与申请受控状态。',
  };
}

String _projectNameAccessActionLabel(Map<String, Object?> item) {
  final status = _projectNameAccessStatus(item);
  final canRequest = _projectCanRequestNameAccess(item);
  return switch (status) {
    'pending' => '等待审批中',
    'rejected' => canRequest ? '重新申请参与竞标' : '当前不可重新申请',
    _ => canRequest ? '申请参与竞标' : '申请参与竞标',
  };
}

String _projectAreaText(num? value, {String fallback = '当前项目暂未提供'}) {
  if (value == null) {
    return fallback;
  }

  final normalized = value
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'\.?0+$'), '');
  return '$normalized ㎡';
}

String _projectPrimaryLocationText(
  Map<String, Object?> item, {
  String fallback = '当前项目暂未提供',
}) {
  final cityName = _normalizeId(item['cityName'] as String?);
  if (cityName != null) {
    return cityName;
  }
  final provinceName = _normalizeId(item['provinceName'] as String?);
  return provinceName ?? fallback;
}
