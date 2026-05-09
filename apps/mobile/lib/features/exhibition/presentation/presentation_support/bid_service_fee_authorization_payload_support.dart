part of '../exhibition_trade_pages.dart';

String? _projectBidServiceFeeAuthorizationIdFromPayload(Object? payload) {
  final map = _payloadMap(payload);
  return _normalizeDynamicText(map?['authorizationId']) ??
      _normalizeDynamicText(
        _payloadMap(map?['authorization'])?['authorizationId'],
      ) ??
      _normalizeDynamicText(_payloadMap(map?['status'])?['authorizationId']);
}

String? _bidServiceFeeAuthorizationStatusFromPayload(Object? payload) {
  final map = _payloadMap(payload);
  final status =
      _normalizeDynamicText(map?['authorizationStatus']) ??
      _normalizeDynamicText(map?['status']) ??
      _normalizeDynamicText(_payloadMap(map?['authorization'])?['status']) ??
      _normalizeDynamicText(
        _payloadMap(map?['authorization'])?['authorizationStatus'],
      );
  return _normalizeBidServiceFeeAuthorizationStatus(status);
}

String? _normalizeBidServiceFeeAuthorizationStatus(String? status) {
  return switch (status) {
    'authorized' => 'frozen',
    'pending_authorization' => 'pending_freeze',
    'authorization_released' || 'refund_pending' || 'refunded' => 'released',
    'pending_contract_confirm' => 'charge_pending',
    'expired' => 'failed',
    _ => status,
  };
}

String _bidServiceFeeAuthorizationStatusText(ExhibitionLoadResult result) {
  if (result.state != AppPageState.content) {
    return result.message ?? result.errorCode ?? '状态暂不可回读';
  }
  final map = _payloadMap(result.payload);
  final status = _bidServiceFeeAuthorizationStatusFromPayload(result.payload);
  final quotaAmount =
      _normalizeDynamicText(map?['quotaAmount']) ??
      _normalizeDynamicText(map?['authorizationQuotaAmount']) ??
      '4000.00';
  final currency = _normalizeDynamicText(map?['currency']) ?? 'CNY';
  final updatedAt = _normalizeDynamicText(map?['updatedAt']);
  return <String>[
    if (status == 'frozen') '预授权已完成',
    if (status != 'frozen') '状态：${status ?? '已回读，等待 Server 确认'}',
    '额度：$quotaAmount $currency',
    if (updatedAt != null) '最近更新：$updatedAt',
  ].join('；');
}

String _bidServiceFeeAuthorizationActionFailureText(
  ExhibitionActionResult result,
) {
  if (result.errorCode ==
      'BID_SERVICE_FEE_AUTHORIZATION_FREEZE_INIT_REJECTED') {
    return result.message ?? '当前预授权状态暂不能重新拉起，请刷新状态后处理。';
  }
  if ((result.message ?? '').contains(
    'Current service fee authorization cannot be initialized',
  )) {
    return '当前预授权状态暂不能重新拉起支付宝，请刷新状态后处理。';
  }
  return result.message ?? result.errorCode ?? 'BFF/Server 返回失败，当前不本地放行。';
}

String _bidServiceFeeAuthorizationChannelActionText(Object? payload) {
  final map = _payloadMap(payload);
  final actionType = _bidServiceFeeAuthorizationChannelActionType(payload);
  final payloadSummary = _bidServiceFeeAuthorizationPayloadSummary(
    map?['channelPayload'],
  );
  if (payloadSummary == null) {
    return actionType ?? '通道 payload 暂未返回';
  }
  return actionType == null ? payloadSummary : '$actionType；$payloadSummary';
}

String? _bidServiceFeeAuthorizationChannelActionType(Object? payload) {
  final map = _payloadMap(payload);
  return _normalizeDynamicText(map?['channelActionType']) ??
      _normalizeDynamicText(_payloadMap(map?['channelPayload'])?['actionType']);
}

String _bidServiceFeeAuthorizationChannelHandoffText(
  Object? payload, {
  required bool channelOpened,
}) {
  final actionType = _bidServiceFeeAuthorizationChannelActionType(payload);
  if (actionType == 'unavailable') {
    return '通道暂不可用，当前不本地判定完成。';
  }
  if (actionType == 'sdk_payload') {
    return channelOpened
        ? '已请求拉起支付宝 SDK，等待 Server callback。'
        : '当前环境未能拉起支付宝 SDK，继续等待 Server 状态回读。';
  }
  if (actionType == 'web_redirect') {
    return channelOpened
        ? '已打开通道页面，等待 Server callback。'
        : '当前环境未能打开通道页面，继续等待 Server 状态回读。';
  }
  if (actionType == 'qr_code') {
    return '已收到二维码通道 payload，本页仅等待 Server 状态回读。';
  }
  return channelOpened ? '已请求通道拉起。' : '未识别可拉起通道，等待 Server 状态回读。';
}

String _bidServiceFeeAuthorizationPollText(P0PayPaymentPollResult result) {
  if (result.status == 'frozen') {
    return 'Server 已回读完成，状态：${result.status ?? 'frozen'}。';
  }
  if (result.outcome == P0PayPaymentOutcome.success) {
    return 'Server 回读成功态 ${result.status ?? '未知'}，本页继续等待 frozen 真值。';
  }
  if (result.timedOut) {
    return '等待 Server 回调超时，状态：${result.status ?? '未完成'}。';
  }
  if (result.isFailure) {
    return 'Server 回读失败或终态异常，状态：${result.status ?? '未知'}。';
  }
  return '已回读 ${result.attempts} 次，状态：${result.status ?? '等待中'}。';
}

String? _bidServiceFeeAuthorizationPayloadSummary(Object? payload) {
  final map = _payloadMap(payload);
  if (map == null || map.isEmpty) {
    return null;
  }
  final keys = map.keys.take(4).join(' / ');
  return 'payload 字段：$keys';
}

bool _bidServiceFeeAuthorizationCallbackAwaiting(Object? payload) {
  final value = _payloadMap(payload)?['callbackAwaiting'];
  if (value is bool) {
    return value;
  }
  return _normalizeDynamicText(value) == 'true';
}

String _bidServiceFeeAuthorizationCallbackText(Object? payload) {
  return _bidServiceFeeAuthorizationCallbackAwaiting(payload)
      ? '等待 Server 受控回调确认'
      : '未返回等待回调标记，请以后续状态回读为准';
}
