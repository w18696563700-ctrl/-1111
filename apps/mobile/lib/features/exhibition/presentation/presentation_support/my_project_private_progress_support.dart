part of '../exhibition_trade_pages.dart';

List<Map<String, Object?>> _myProjectGroupItemsFromPayload(
  Object? payload,
  String groupKey,
) {
  final payloadMap = _payloadMap(payload);
  final rawItems = payloadMap?[groupKey];
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

Map<String, Object?>? _myProjectPublicProjectMap(Map<String, Object?> item) {
  final value = item['publicProject'];
  return value is Map
      ? value.map((Object? key, Object? item) => MapEntry('$key', item))
      : null;
}

Map<String, Object?>? _myProjectPrivateProgressMap(
  Map<String, Object?> item, {
  String field = 'privateSummary',
}) {
  final value = item[field];
  return value is Map
      ? value.map((Object? key, Object? item) => MapEntry('$key', item))
      : null;
}

String? _myProjectSummaryHeading(Map<String, Object?> publicProject) {
  final summary = publicProject['summary'];
  if (summary is! Map) {
    return null;
  }
  return _normalizeId(summary['heading'] as String?);
}

String? _myProjectRegionLabel(Map<String, Object?> publicProject) {
  final provinceName = _normalizeId(publicProject['provinceName'] as String?);
  final cityName = _normalizeId(publicProject['cityName'] as String?);
  final provinceCode = _normalizeId(publicProject['provinceCode'] as String?);
  final cityCode = _normalizeId(publicProject['cityCode'] as String?);
  final hasProvinceCarrier = provinceCode != null || provinceName != null;
  final hasCityCarrier = cityCode != null || cityName != null;
  if (!hasProvinceCarrier && !hasCityCarrier) {
    return null;
  }
  if (provinceName != null && cityName != null) {
    return provinceName == cityName
        ? provinceName
        : '$provinceName / $cityName';
  }
  return cityName ?? provinceName;
}

String _myProjectAreaLabel(num? value) {
  if (value == null) {
    return '当前项目暂未提供';
  }
  final normalized = value
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'\.?0+$'), '');
  return '$normalized ㎡';
}

String _myProjectFormalCompletionLabel(String? value) {
  return switch (_normalizeId(value)) {
    'formally_completed' => '已正式完结',
    'not_formally_completed' => '尚未正式完结',
    _ => '当前状态暂未归类',
  };
}

String _myProjectEvaluationLabel(String? value) {
  return switch (_normalizeId(value)) {
    'submitted' => '已评价',
    'eligible' => '待评价',
    'not_eligible' => '暂不可评价',
    _ => '当前状态暂未归类',
  };
}
