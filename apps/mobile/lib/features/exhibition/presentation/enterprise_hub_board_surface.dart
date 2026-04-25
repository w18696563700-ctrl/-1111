import 'package:mobile/features/exhibition/data/enterprise_hub_consumer_layer.dart';

class EnterpriseBoardFilterOption {
  const EnterpriseBoardFilterOption({required this.label, required this.value});

  final String label;
  final String value;
}

class EnterpriseBoardSurfaceSpec {
  const EnterpriseBoardSurfaceSpec({
    required this.searchHint,
    required this.cityFilterLabel,
    this.plantAreaLabel,
  });

  final String searchHint;
  final String cityFilterLabel;
  final String? plantAreaLabel;
}

EnterpriseBoardSurfaceSpec enterpriseBoardSurfaceSpec(
  EnterpriseBoardType boardType,
) {
  return switch (boardType) {
    EnterpriseBoardType.company => const EnterpriseBoardSurfaceSpec(
      searchHint: '搜索公司名称、业务方向、所在城市',
      cityFilterLabel: '城市',
    ),
    EnterpriseBoardType.factory => const EnterpriseBoardSurfaceSpec(
      searchHint: '搜索工厂名称、工艺类型、所在城市',
      cityFilterLabel: '厂房位置',
      plantAreaLabel: '厂房面积',
    ),
    EnterpriseBoardType.supplier => const EnterpriseBoardSurfaceSpec(
      searchHint: '搜索供应商名称、供应品类、所在城市',
      cityFilterLabel: '城市',
    ),
  };
}

String? enterpriseBoardOptionLabelForValue(
  List<EnterpriseBoardFilterOption> options,
  String? value,
) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  for (final EnterpriseBoardFilterOption option in options) {
    if (option.value == value) {
      return option.label;
    }
  }
  return value;
}

List<String> enterpriseBoardCardSummaryChips(EnterpriseHubListItem item) {
  final highlights = _boardSpecificHighlights(item);
  final chips = <String>[];

  switch (item.boardType) {
    case EnterpriseBoardType.company:
      chips.addAll(_takeList(highlights['exhibitionTypes'], 1));
      chips.addAll(_takeList(highlights['serviceItems'], 1));
    case EnterpriseBoardType.factory:
      chips.addAll(_takeList(highlights['processTypes'], 1));
      chips.addAll(_takeList(highlights['coreProducts'], 1));
      chips.addAll(
        _singleChip('配送', _string(highlights['deliveryRadiusDesc'])),
      );
      if (_bool(highlights['warehouseCapability']) == true) {
        chips.add('支持仓储');
      }
    case EnterpriseBoardType.supplier:
      chips.addAll(_takeList(highlights['supplyCategories'], 1));
      chips.addAll(_singleChip('响应', _string(highlights['responseSlaDesc'])));
  }

  if (item.certificationLabel.trim().isNotEmpty) {
    chips.add(item.certificationLabel.trim());
  }
  if (item.boardType == EnterpriseBoardType.company) {
    chips.addAll(_singleChip('规模', _string(highlights['maxProjectScale'])));
    if (chips.length < 4 && item.caseCount > 0) {
      chips.add('${item.caseCount} 个案例');
    }
  } else if (item.avgScore != null) {
    chips.add('${item.avgScore!.toStringAsFixed(1)} 分');
  } else if (item.caseCount > 0) {
    chips.add('${item.caseCount} 个案例');
  }

  return chips.toSet().take(4).toList(growable: false);
}

String? enterpriseBoardCardSummaryText(EnterpriseHubListItem item) {
  final highlights = _boardSpecificHighlights(item);
  final summary = switch (item.boardType) {
    EnterpriseBoardType.company => _joinPieces(<String?>[
      _labelledList('展会类型', _list(highlights['exhibitionTypes']), maxItems: 99),
      _labelledList('服务项目', _list(highlights['serviceItems']), maxItems: 99),
    ]),
    EnterpriseBoardType.factory => _joinPieces(<String?>[
      _labelledList('工艺', _list(highlights['processTypes']), maxItems: 99),
      _labelledList('产品', _list(highlights['coreProducts']), maxItems: 99),
    ]),
    EnterpriseBoardType.supplier => _joinPieces(<String?>[
      _labelledList('品类', _list(highlights['supplyCategories']), maxItems: 99),
    ]),
  };

  if (summary != null && summary.isNotEmpty) {
    return summary;
  }
  final intro = item.shortIntro.trim();
  return intro.isEmpty ? null : intro;
}

String enterpriseBoardDisplayTitle(EnterpriseHubListItem item) {
  if (item.boardType != EnterpriseBoardType.factory) {
    return item.name;
  }
  final highlights = _boardSpecificHighlights(item);
  final factoryName = _string(highlights['factoryName']);
  return factoryName ?? item.name;
}

String? enterpriseBoardCompanyLine(EnterpriseHubListItem item) {
  if (item.boardType != EnterpriseBoardType.factory) {
    return null;
  }
  final highlights = _boardSpecificHighlights(item);
  final factoryName = _string(highlights['factoryName']);
  if (factoryName == null || factoryName == item.name) {
    return null;
  }
  return '所属公司：${item.name}';
}

String enterpriseBoardHeaderTitle({
  required EnterpriseBoardType boardType,
  required String fallbackName,
  required Map<String, Object?>? boardProfile,
}) {
  if (boardType != EnterpriseBoardType.factory || boardProfile == null) {
    return fallbackName;
  }
  final factoryName = _string(boardProfile['factoryName']);
  return factoryName ?? fallbackName;
}

String? enterpriseBoardHeaderCompanyLine({
  required EnterpriseBoardType boardType,
  required String companyName,
  required Map<String, Object?>? boardProfile,
}) {
  if (boardType != EnterpriseBoardType.factory || boardProfile == null) {
    return null;
  }
  final factoryName = _string(boardProfile['factoryName']);
  if (factoryName == null || factoryName == companyName) {
    return null;
  }
  return '所属公司：$companyName';
}

Map<String, Object?> _boardSpecificHighlights(EnterpriseHubListItem item) {
  final raw = switch (item.boardType) {
    EnterpriseBoardType.company => item.boardHighlights['company'],
    EnterpriseBoardType.factory => item.boardHighlights['factory'],
    EnterpriseBoardType.supplier => item.boardHighlights['supplier'],
  };
  if (raw is Map) {
    return raw.map((Object? key, Object? value) => MapEntry('$key', value));
  }
  return const <String, Object?>{};
}

List<String> _list(Object? raw) {
  if (raw is! List) {
    return const <String>[];
  }
  return raw
      .map((Object? item) => '$item'.trim())
      .where((String item) => item.isNotEmpty)
      .toList(growable: false);
}

List<String> _takeList(Object? raw, int count) {
  final values = _list(raw);
  if (values.isEmpty) {
    return const <String>[];
  }
  return values.take(count).toList(growable: false);
}

List<String> _singleChip(String label, String? value) {
  if (value == null || value.isEmpty) {
    return const <String>[];
  }
  return <String>['$label $value'];
}

String? _string(Object? raw) {
  final value = '$raw'.trim();
  if (raw == null || value.isEmpty || value == 'null') {
    return null;
  }
  return value;
}

bool? _bool(Object? raw) {
  return raw is bool ? raw : null;
}

String? _labelledList(String label, List<String> values, {int maxItems = 2}) {
  if (values.isEmpty) {
    return null;
  }
  return '$label：${values.take(maxItems).join(' / ')}';
}

String? _joinPieces(List<String?> pieces) {
  final values = pieces
      .whereType<String>()
      .where((String item) => item.isNotEmpty)
      .toList(growable: false);
  if (values.isEmpty) {
    return null;
  }
  return values.join('  |  ');
}
