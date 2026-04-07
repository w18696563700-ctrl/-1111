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

class _HomeModuleProjection {
  const _HomeModuleProjection({
    required this.title,
    required this.summary,
    required this.statusLabel,
    required this.actionLabel,
    required this.enabled,
    required this.placeholder,
  });

  final String title;
  final String summary;
  final String statusLabel;
  final String actionLabel;
  final bool enabled;
  final bool placeholder;
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
    locationPermissionState: snapshot.permissionState.contractName,
  );
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

String _homeRecommendationAreaLabel(_HomeWeatherProjection? projection) {
  if (projection == null) {
    return '当前位置';
  }

  return projection.provinceName;
}

_HomeModuleProjection _homeModuleProjectionFromPayload(
  Object? payload,
  String moduleKey, {
  required String fallbackTitle,
  required String fallbackSummary,
  required String fallbackStatusLabel,
  required String fallbackActionLabel,
}) {
  final root = _homeMap(payload);
  final modules = root?['modules'];
  if (modules is List) {
    for (final item in modules.whereType<Map>()) {
      final map = item.map(
        (Object? key, Object? value) => MapEntry('$key', value),
      );
      if (_homeString(map['moduleKey']) != moduleKey) {
        continue;
      }
      return _HomeModuleProjection(
        title: _homeString(map['title']) ?? fallbackTitle,
        summary: _homeString(map['summary']) ?? fallbackSummary,
        statusLabel: _homeString(map['statusLabel']) ?? fallbackStatusLabel,
        actionLabel: _homeString(map['actionLabel']) ?? fallbackActionLabel,
        enabled: _homeBool(map['enabled']) ?? true,
        placeholder: _homeBool(map['placeholder']) ?? false,
      );
    }
  }

  return _HomeModuleProjection(
    title: fallbackTitle,
    summary: fallbackSummary,
    statusLabel: fallbackStatusLabel,
    actionLabel: fallbackActionLabel,
    enabled: true,
    placeholder: false,
  );
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
  'published' => '已发布',
  'bidding_closed' => '投标已结束',
  'awarded' => '已授标',
  'converted_to_order' => '已转为订单',
  null => '状态待确认',
  _ => state,
};

bool _homeCanContinueBid(String? state) => state == 'published';

String _homeProjectGuidance(String? state) {
  return switch (state) {
    'published' => '当前项目仍在公开展示阶段，适合先进入详情，再判断是否继续竞标。',
    'bidding_closed' => '当前项目投标窗口已结束，首页保留只读说明，不在这里继续竞标。',
    'awarded' => '当前项目已经授标，后续私域推进回到项目工作台继续。',
    'converted_to_order' => '当前项目已经进入订单链路，首页只保留公开说明，不混入后续履约动作。',
    null => '当前项目已经进入推荐区，可先查看详情，再确认下一步。',
    _ => '当前项目处于 ${_homeFrontStateLabel(state)}，先看清详情，再决定后续承接。',
  };
}

String _homeSectionTag({
  required bool loading,
  required ExhibitionLoadResult? result,
}) {
  if (loading && result == null) {
    return '正在读取';
  }

  return switch (result?.state) {
    AppPageState.content => '已接通内容',
    AppPageState.empty => '当前为空',
    AppPageState.errorRetryable => '待重试',
    AppPageState.errorNonRetryable => '受控失败',
    AppPageState.unauthorized => '待恢复登录',
    AppPageState.forbidden => '当前未开放',
    AppPageState.notFound => '暂未承接',
    _ => loading ? '正在刷新' : '准备中',
  };
}

String _homeSectionMessage({
  required String areaLabel,
  required bool loading,
  required ExhibitionLoadResult? result,
}) {
  if (loading && result == null) {
    return '正在读取$areaLabel项目推荐。页面会继续保持整页刷新节奏，不会只刷新天气卡。';
  }

  return switch (result?.state) {
    AppPageState.content => '当前优先承接的是$areaLabel项目推荐。天气聚合未接通时，本区仍继续保留现有推荐消费层。',
    AppPageState.empty =>
      '$areaLabel当前还没有公开项目。可以先发布项目或回到工作台继续；页面不会用本地演示项目补齐这个区域。',
    AppPageState.errorRetryable =>
      '$areaLabel项目推荐暂时没有刷新成功。你可以重试整页刷新；在恢复前，页面不会用本地演示项目把这里填满。',
    AppPageState.errorNonRetryable =>
      '$areaLabel项目推荐当前不能继续承接。页面会停在受控状态，不会把未接通内容伪装成已完成。',
    AppPageState.unauthorized => '$areaLabel项目推荐当前需要先恢复登录或授权状态，页面不会继续假装可进入。',
    AppPageState.forbidden => '$areaLabel项目推荐当前未开放，页面会明确说明边界，不会伪装成只是“还没做完”。',
    AppPageState.notFound => '$areaLabel项目推荐当前还没有稳定承接到这一页，所以先停留在受控状态。',
    _ => '当前推荐区正在准备中。',
  };
}

String _homeUpdatedAtLabel(String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) {
    return value;
  }

  final local = parsed.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${local.month}月${local.day}日 $hour:$minute';
}
