part of 'exhibition_home_page.dart';

class _HomeWeatherProjection {
  const _HomeWeatherProjection({
    required this.displayName,
    required this.provinceName,
    required this.selectionScope,
    required this.selectionNotice,
    required this.sourceLabel,
    required this.currentWeather,
    required this.currentTemperature,
    required this.highTemperature,
    required this.lowTemperature,
    required this.precipitationProbability,
    required this.updatedAt,
    required this.canExpand,
    required this.refreshable,
    required this.hourlyForecast,
    required this.dailyForecast,
    required this.constructionRiskLevel,
    required this.constructionRiskSummary,
    required this.riskTags,
    required this.riskTimeLabel,
    required this.nightRainExpected,
    required this.nightRainTimeLabel,
    required this.officialAlerts,
    required this.constructionSuggestions,
  });

  final String displayName;
  final String provinceName;
  final String selectionScope;
  final String selectionNotice;
  final String sourceLabel;
  final String currentWeather;
  final double currentTemperature;
  final double highTemperature;
  final double lowTemperature;
  final int precipitationProbability;
  final String updatedAt;
  final bool canExpand;
  final bool refreshable;
  final List<_HomeForecastItem> hourlyForecast;
  final List<_HomeForecastItem> dailyForecast;
  final String? constructionRiskLevel;
  final String? constructionRiskSummary;
  final List<String> riskTags;
  final String? riskTimeLabel;
  final bool? nightRainExpected;
  final String? nightRainTimeLabel;
  final List<String> officialAlerts;
  final List<String> constructionSuggestions;

  bool get isControlledPlaceholder =>
      currentWeather.trim() == '待同步' &&
      currentTemperature == 0 &&
      highTemperature == 0 &&
      lowTemperature == 0 &&
      precipitationProbability == 0 &&
      riskTags.isEmpty &&
      officialAlerts.isEmpty &&
      hourlyForecast.isEmpty &&
      dailyForecast.isEmpty;

  bool get isWeatherDegraded =>
      currentWeather.trim() == '天气暂不可用' &&
      currentTemperature == 0 &&
      highTemperature == 0 &&
      lowTemperature == 0 &&
      precipitationProbability == 0 &&
      hourlyForecast.isEmpty &&
      dailyForecast.isEmpty;

  bool get isWeatherUnavailable => isControlledPlaceholder || isWeatherDegraded;
}

class _HomeForecastItem {
  const _HomeForecastItem({
    required this.leadingLabel,
    required this.title,
    required this.temperatureLabel,
    required this.precipitationLabel,
  });

  final String leadingLabel;
  final String title;
  final String temperatureLabel;
  final String precipitationLabel;
}

ExhibitionHomeLocationContextRequest? _homeLocationContextFromSnapshot(
  DeviceLocationSnapshot? snapshot,
) {
  if (snapshot == null) {
    return null;
  }

  return ExhibitionHomeLocationContextRequest(
    latitude: snapshot.latitude,
    longitude: snapshot.longitude,
    provinceCode: snapshot.provinceCode,
    provinceName: snapshot.provinceName,
    locationPermissionState: snapshot.permissionState.contractName,
  );
}

ExhibitionHomeLocationContextRequest _homeLocationContextFromSelection(
  ExhibitionHomeLocationSelectRequest selection, {
  required DeviceLocationPermissionState permissionState,
}) {
  return ExhibitionHomeLocationContextRequest(
    latitude: selection.latitude,
    longitude: selection.longitude,
    provinceCode: selection.provinceCode,
    provinceName: selection.provinceName,
    cityName: selection.cityName,
    districtName: selection.districtName,
    locationPermissionState: permissionState.contractName,
  );
}

ExhibitionHomeLocationContextRequest? _homeLocationContextFromResult(
  ExhibitionLoadResult? result,
) {
  if (result?.state != AppPageState.content) {
    return null;
  }

  final payload = _homeMap(result?.payload);
  final currentLocation = _homeMap(payload?['currentLocation']);
  if (payload == null || currentLocation == null) {
    return null;
  }

  final locationContext = ExhibitionHomeLocationContextRequest(
    latitude: _homeNumber(currentLocation['latitude']),
    longitude: _homeNumber(currentLocation['longitude']),
    provinceCode: _homeString(currentLocation['provinceCode']),
    provinceName: _homeString(currentLocation['provinceName']),
    cityName: _homeString(currentLocation['cityName']),
    districtName: _homeString(currentLocation['districtName']),
    locationPermissionState: _homeString(payload['locationPermissionState']),
  );
  return locationContext.hasUsableLocationHints ? locationContext : null;
}

_HomeWeatherProjection? _homeWeatherProjectionFromResult(
  ExhibitionLoadResult? result,
) {
  if (result?.state != AppPageState.content) {
    return null;
  }

  final payload = _homeMap(result?.payload);
  final currentLocation = _homeMap(payload?['currentLocation']);
  if (payload == null || currentLocation == null) {
    return null;
  }

  final displayName = _homeString(currentLocation['displayName']);
  final provinceName = _homeString(currentLocation['provinceName']);
  final selectionScope = _homeString(payload['selectionScope']);
  final selectionNotice = _homeString(payload['selectionNotice']);
  final sourceLabel = _homeString(payload['sourceLabel']);
  final currentWeather = _homeString(payload['currentWeather']);
  final currentTemperature = _homeNumber(payload['currentTemperature']);
  final highTemperature = _homeNumber(payload['highTemperature']);
  final lowTemperature = _homeNumber(payload['lowTemperature']);
  final precipitationProbability = _homeInt(
    payload['precipitationProbability'],
  );
  final updatedAt = _homeString(payload['updatedAt']);
  final canExpand = _homeBool(payload['canExpand']);
  final refreshable = _homeBool(payload['refreshable']);
  final constructionRiskLevel = _homeString(payload['constructionRiskLevel']);
  final constructionRiskSummary = _homeString(
    payload['constructionRiskSummary'],
  );
  final riskTags = _homeStringList(payload['riskTags']);
  final riskTimeLabel = _homeString(payload['riskTimeLabel']);
  final nightRainExpected = _homeBool(payload['nightRainExpected']);
  final nightRainTimeLabel = _homeString(payload['nightRainTimeLabel']);
  final officialAlerts = _homeStringList(payload['officialAlerts']);
  final constructionSuggestions = _homeStringList(
    payload['constructionSuggestions'],
  );

  if (displayName == null ||
      provinceName == null ||
      selectionScope == null ||
      selectionNotice == null ||
      sourceLabel == null ||
      currentWeather == null ||
      currentTemperature == null ||
      highTemperature == null ||
      lowTemperature == null ||
      precipitationProbability == null ||
      updatedAt == null ||
      canExpand == null ||
      refreshable == null) {
    return null;
  }

  return _HomeWeatherProjection(
    displayName: displayName,
    provinceName: provinceName,
    selectionScope: selectionScope,
    selectionNotice: selectionNotice,
    sourceLabel: sourceLabel,
    currentWeather: currentWeather,
    currentTemperature: currentTemperature,
    highTemperature: highTemperature,
    lowTemperature: lowTemperature,
    precipitationProbability: precipitationProbability,
    updatedAt: updatedAt,
    canExpand: canExpand,
    refreshable: refreshable,
    hourlyForecast: _homeForecastList(
      payload['hourlyForecast'],
      isDaily: false,
    ),
    dailyForecast: _homeForecastList(payload['dailyForecast'], isDaily: true),
    constructionRiskLevel: constructionRiskLevel,
    constructionRiskSummary: constructionRiskSummary,
    riskTags: riskTags,
    riskTimeLabel: riskTimeLabel,
    nightRainExpected: nightRainExpected,
    nightRainTimeLabel: nightRainTimeLabel,
    officialAlerts: officialAlerts,
    constructionSuggestions: constructionSuggestions,
  );
}

List<_HomeForecastItem> _homeForecastList(
  Object? payload, {
  required bool isDaily,
}) {
  if (payload is! List) {
    return const <_HomeForecastItem>[];
  }

  final items = payload
      .whereType<Map>()
      .map<_HomeForecastItem?>((Map item) {
        final map = item.map(
          (Object? key, Object? value) => MapEntry('$key', value),
        );
        final leadingLabel = _homeString(
          isDaily ? map['dateLabel'] : map['timeLabel'],
        );
        final title = _homeString(map['weather']);
        final precipitation = _homeInt(map['precipitationProbability']);
        if (leadingLabel == null || title == null || precipitation == null) {
          return null;
        }

        if (isDaily) {
          final high = _homeNumber(map['highTemperature']);
          final low = _homeNumber(map['lowTemperature']);
          if (high == null || low == null) {
            return null;
          }
          return _HomeForecastItem(
            leadingLabel: leadingLabel,
            title: title,
            temperatureLabel:
                '${high.toStringAsFixed(0)}° / ${low.toStringAsFixed(0)}°',
            precipitationLabel: '$precipitation%',
          );
        }

        final temperature = _homeNumber(map['temperature']);
        if (temperature == null) {
          return null;
        }
        return _HomeForecastItem(
          leadingLabel: leadingLabel,
          title: title,
          temperatureLabel: '${temperature.toStringAsFixed(0)}°',
          precipitationLabel: '$precipitation%',
        );
      })
      .whereType<_HomeForecastItem>()
      .toList();

  if (isDaily || items.isEmpty) {
    return items;
  }

  return _homeFutureHourlyForecast(items, now: DateTime.now());
}

List<_HomeForecastItem> _homeFutureHourlyForecast(
  List<_HomeForecastItem> items, {
  required DateTime now,
}) {
  final nowMinute = now.hour * 60 + now.minute;
  final future = <_HomeForecastItem>[];
  var dayOffset = 0;
  int? previousHour;

  for (final item in items) {
    final hour = _homeHourFromTimeLabel(item.leadingLabel);
    if (hour == null) {
      continue;
    }
    if (previousHour != null && hour < previousHour) {
      dayOffset += 24;
    }
    previousHour = hour;
    final forecastMinute = (dayOffset + hour) * 60;
    if (forecastMinute > nowMinute) {
      future.add(item);
    }
  }

  if (future.isNotEmpty) {
    return future;
  }
  return items
      .where((item) {
        final hour = _homeHourFromTimeLabel(item.leadingLabel);
        return hour != null && hour > now.hour;
      })
      .toList(growable: false);
}

int? _homeHourFromTimeLabel(String label) {
  final match = RegExp(r'^(\d{1,2})').firstMatch(label.trim());
  if (match == null) {
    return null;
  }
  return int.tryParse(match.group(1)!);
}

List<Map<String, Object?>> _homeProjectItemsFromPayload(Object? payload) {
  if (payload is! Map) {
    return const <Map<String, Object?>>[];
  }

  final rawItems = payload['items'];
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

Map<String, Object?>? _homeMap(Object? payload) {
  if (payload is! Map) {
    return null;
  }

  return payload.map((Object? key, Object? value) => MapEntry('$key', value));
}

String? _homeString(Object? value) {
  if (value is! String) {
    return null;
  }

  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

double? _homeNumber(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  return null;
}

int? _homeInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return null;
}

bool? _homeBool(Object? value) {
  if (value is bool) {
    return value;
  }
  return null;
}

List<String> _homeStringList(Object? value) => value is List
    ? value
          .whereType<String>()
          .map((String item) => item.trim())
          .where((String item) => item.isNotEmpty)
          .toList(growable: false)
    : const <String>[];

String? _homeTrimmedString(Object? value) {
  if (value is! String) {
    return null;
  }

  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String _homeCurrencyText(Object? value) {
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

String _homeFrontStateLabel(String? state) => switch (state) {
  'published' => '竞标中',
  'bidding_closed' => '投标已结束',
  'awarded' => '已授标',
  'converted_to_order' => '已被承接',
  null => '状态待确认',
  _ => state,
};

bool _homeCanContinueBid(String? state) => state == 'published';

String? _homeProjectExampleAsset(Object? value) {
  final areaSqm = _homeNumber(value);
  if (areaSqm == null || areaSqm <= 0) {
    return null;
  }

  const assetRoot = 'assets/exhibition/project_examples/';
  if (areaSqm <= 9) return '${assetRoot}area_009.png';
  if (areaSqm <= 18) return '${assetRoot}area_018.png';
  if (areaSqm <= 27) return '${assetRoot}area_027.png';
  if (areaSqm <= 36) return '${assetRoot}area_036.png';
  if (areaSqm <= 45) return '${assetRoot}area_045.png';
  if (areaSqm <= 54) return '${assetRoot}area_054.png';
  if (areaSqm <= 63) return '${assetRoot}area_063.png';
  if (areaSqm <= 72) return '${assetRoot}area_072.png';
  if (areaSqm <= 81) return '${assetRoot}area_081.png';
  if (areaSqm <= 90) return '${assetRoot}area_090.png';
  if (areaSqm <= 108) return '${assetRoot}area_108.png';
  return '${assetRoot}area_108_plus.png';
}

String _homeProjectTypeLabel(Object? value) {
  final raw = _homeTrimmedString(value);
  if (raw == null) {
    return '类型待确认';
  }

  final normalized = raw.toLowerCase();
  return switch (normalized) {
    'exhibition' => '会展',
    'renovation' => '装修',
    'custom_furniture' => '定制',
    'showroom' => '展厅',
    'commercial_activity' || 'commercial_event' => '商业活动',
    _ => raw,
  };
}

String _homeProjectAreaLabel(Object? value) {
  final areaSqm = _homeNumber(value);
  if (areaSqm == null) {
    return '当前项目暂未提供';
  }

  final normalized = areaSqm
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'\.?0+$'), '');
  return '$normalized ㎡';
}

String _homeProjectCityLabel(Map<String, Object?> item) {
  return _homeTrimmedString(item['cityName']) ??
      _homeTrimmedString(item['provinceName']) ??
      '当前项目暂未提供';
}

String _homeProjectEntryTimeLabel(Map<String, Object?> item) {
  return _homeTrimmedString(item['plannedStartAt']) ?? '当前项目暂未提供';
}

String? _homeProjectPublishedAtLabel(Map<String, Object?> item) {
  final raw = _homeTrimmedString(item['publishedAt']);
  if (raw == null) {
    return null;
  }

  final parsed = DateTime.tryParse(raw);
  if (parsed == null) {
    return null;
  }

  final local = parsed.isUtc ? parsed.toLocal() : parsed;
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '发布 ${local.month}月${local.day}日 $hour:$minute';
}
