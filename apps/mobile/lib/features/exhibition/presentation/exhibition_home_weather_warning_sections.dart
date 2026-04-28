part of 'exhibition_home_page.dart';

class _HomeConstructionRiskPanel extends StatelessWidget {
  const _HomeConstructionRiskPanel({required this.weatherProjection});

  final _HomeWeatherProjection weatherProjection;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '施工风险卡',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: <Widget>[
                _HomeMetricChip(
                  label: '风险等级',
                  value: _homeConstructionRiskLevelLabel(
                    weatherProjection.constructionRiskLevel,
                  ),
                ),
                _HomeMetricChip(
                  label: '风险标签',
                  value: _homeRiskTagsLabel(weatherProjection.riskTags),
                ),
                _HomeMetricChip(
                  label: '今夜降雨',
                  value: _homeNightRainLabel(
                    expected: weatherProjection.nightRainExpected,
                    timeLabel: weatherProjection.nightRainTimeLabel,
                  ),
                ),
                _HomeMetricChip(
                  label: '官方预警',
                  value: weatherProjection.officialAlerts.isEmpty
                      ? '暂无'
                      : '${weatherProjection.officialAlerts.length}条',
                ),
              ],
            ),
            const SizedBox(height: 8),
            _HomeInfoLine(
              title: '风险时段',
              value: weatherProjection.riskTimeLabel ?? '风险时段待确认',
            ),
            const SizedBox(height: 8),
            if (weatherProjection.hourlyForecast.isNotEmpty)
              _HomeForecastList(
                title: '小时预报',
                items: weatherProjection.hourlyForecast,
              ),
          ],
        ),
      ),
    );
  }
}

class _HomeConstructionSuggestionPanel extends StatelessWidget {
  const _HomeConstructionSuggestionPanel({required this.weatherProjection});

  final _HomeWeatherProjection weatherProjection;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final suggestions = _homeConstructionSuggestions(weatherProjection);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '今日施工建议',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            ...suggestions.map(
              (String item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '• $item',
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.35),
                ),
              ),
            ),
            if (weatherProjection.dailyForecast.isNotEmpty) ...<Widget>[
              const SizedBox(height: 6),
              _HomeForecastList(
                title: '每日预报',
                items: weatherProjection.dailyForecast,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HomeOfficialAlertPanel extends StatelessWidget {
  const _HomeOfficialAlertPanel({required this.alerts});

  final List<String> alerts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final shownAlerts = alerts.take(2).toList(growable: false);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '官方预警',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            ...shownAlerts.map(
              (String alert) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _HomeInfoLine(title: alert, value: '请结合现场安排及时调整施工计划。'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
