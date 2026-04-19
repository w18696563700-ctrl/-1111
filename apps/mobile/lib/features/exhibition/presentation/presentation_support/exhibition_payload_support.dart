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

String _projectDisplayTitle(Map<String, Object?> item) {
  return _projectExhibitionName(item) ??
      _normalizeId(item['title'] as String?) ??
      '未命名项目';
}

String? _projectDisplayBrandLine(Map<String, Object?> item) {
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
