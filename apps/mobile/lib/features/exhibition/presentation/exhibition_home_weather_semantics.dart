part of 'exhibition_home_page.dart';

String _homeConstructionRiskLevelLabel(String? level) {
  return switch (level) {
    'low' => '低风险',
    'medium' => '中风险',
    'high' => '高风险',
    'critical' => '极高风险',
    _ => '待确认',
  };
}

String _homeConstructionFocusSummary(_HomeWeatherProjection projection) {
  final summary = projection.constructionRiskSummary?.trim();
  if (summary == null || summary.isEmpty) {
    return '当前施工重点待更新';
  }
  return summary.replaceFirst(RegExp(r'^今日施工重点[:：]\s*'), '');
}

String _homeRiskTagsLabel(List<String> tags) {
  if (tags.isEmpty) {
    return '无';
  }
  final labels = tags
      .map(_homeRiskTagLabel)
      .whereType<String>()
      .toSet()
      .toList(growable: false);
  if (labels.isEmpty) {
    return '无';
  }
  return labels.join(' / ');
}

String? _homeRiskTagLabel(String tag) {
  return switch (tag) {
    'rain' => '降雨',
    'night_rain' => '夜间降雨',
    'high_temp' => '高温',
    'low_temp' => '低温',
    'strong_wind' => '大风',
    'lightning' => '雷电',
    'official_alert' => '官方预警',
    _ => null,
  };
}

String _homeNightRainLabel({
  required bool? expected,
  required String? timeLabel,
}) {
  if (expected == true) {
    if (timeLabel == null) {
      return '有雨';
    }
    return '有雨（$timeLabel）';
  }
  if (expected == false) {
    return '无雨';
  }
  return '待确认';
}

String _homeNightRainCue({
  required bool? expected,
  required String? timeLabel,
}) {
  if (expected == true) {
    return timeLabel == null ? '今夜有雨' : '今夜有雨（$timeLabel）';
  }
  if (expected == false) {
    return '今夜无雨';
  }
  return '今夜降雨待确认';
}

List<String> _homeConstructionSuggestions(_HomeWeatherProjection projection) {
  if (projection.constructionSuggestions.isEmpty) {
    return const <String>['当前暂无施工建议，请优先做好现场防护并关注天气变化。'];
  }
  return projection.constructionSuggestions;
}
