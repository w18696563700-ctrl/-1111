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
  return _normalizeDynamicText(map?['authorizationStatus']) ??
      _normalizeDynamicText(map?['status']) ??
      _normalizeDynamicText(_payloadMap(map?['authorization'])?['status']) ??
      _normalizeDynamicText(
        _payloadMap(map?['authorization'])?['authorizationStatus'],
      );
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
  return result.message ?? result.errorCode ?? 'BFF/Server 返回失败，当前不本地放行。';
}

String _bidServiceFeeAuthorizationChannelActionText(Object? payload) {
  final map = _payloadMap(payload);
  final actionType =
      _normalizeDynamicText(map?['channelActionType']) ??
      _normalizeDynamicText(_payloadMap(map?['channelPayload'])?['actionType']);
  final payloadSummary = _bidServiceFeeAuthorizationPayloadSummary(
    map?['channelPayload'],
  );
  if (payloadSummary == null) {
    return actionType ?? '通道 payload 暂未返回';
  }
  return actionType == null ? payloadSummary : '$actionType；$payloadSummary';
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
