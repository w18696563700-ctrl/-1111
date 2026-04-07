part of 'exhibition_home_page.dart';

class _HomeWeatherStatusPanel extends StatelessWidget {
  const _HomeWeatherStatusPanel({
    required this.locationSnapshot,
    required this.homeResult,
    required this.weatherProjection,
  });

  final DeviceLocationSnapshot? locationSnapshot;
  final ExhibitionLoadResult? homeResult;
  final _HomeWeatherProjection? weatherProjection;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '今日施工天气总览',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final cellWidth = (constraints.maxWidth - 8) / 2;
                final locationValue =
                    weatherProjection?.displayName ??
                    (locationSnapshot?.hasCoordinates == true
                        ? '所在地区识别中'
                        : '待获取');
                final weatherValue = weatherProjection != null
                    ? '${weatherProjection!.currentWeather} ${weatherProjection!.highTemperature.toStringAsFixed(0)}°/${weatherProjection!.lowTemperature.toStringAsFixed(0)}°'
                    : '同步中';
                final riskValue = weatherProjection != null
                    ? _homeConstructionRiskLevelLabel(
                        weatherProjection!.constructionRiskLevel,
                      )
                    : '待评估';
                final tagsValue = weatherProjection != null
                    ? _homeRiskTagsLabel(weatherProjection!.riskTags)
                    : '待确认';

                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    SizedBox(
                      width: cellWidth,
                      child: _HomeCompactOverviewTile(
                        title: '当前位置',
                        value: locationValue,
                      ),
                    ),
                    SizedBox(
                      width: cellWidth,
                      child: _HomeCompactOverviewTile(
                        title: '今日天气',
                        value: weatherValue,
                      ),
                    ),
                    SizedBox(
                      width: cellWidth,
                      child: _HomeCompactOverviewTile(
                        title: '施工风险',
                        value: riskValue,
                      ),
                    ),
                    SizedBox(
                      width: cellWidth,
                      child: _HomeCompactOverviewTile(
                        title: '风险标签',
                        value: tagsValue,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            _HomeCompactOverviewTile(
              title: '位置与同步状态',
              value: weatherProjection != null
                  ? _homeLocationSyncStatus(weatherProjection!)
                  : _homeUnavailableMessage(homeResult),
              multiline: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeForecastPanel extends StatelessWidget {
  const _HomeForecastPanel({required this.weatherProjection});

  final _HomeWeatherProjection weatherProjection;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _HomeConstructionRiskPanel(weatherProjection: weatherProjection),
        const SizedBox(height: 12),
        _HomeConstructionSuggestionPanel(weatherProjection: weatherProjection),
        if (weatherProjection.officialAlerts.isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          _HomeOfficialAlertPanel(alerts: weatherProjection.officialAlerts),
        ],
      ],
    );
  }
}

class _HomeUnavailableForecastPanel extends StatelessWidget {
  const _HomeUnavailableForecastPanel({
    required this.locationSnapshot,
    required this.homeResult,
  });

  final DeviceLocationSnapshot? locationSnapshot;
  final ExhibitionLoadResult? homeResult;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '施工天气预警模块',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '天气信息正在更新',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              locationSnapshot?.hasCoordinates == true
                  ? '正在识别所在地区，并同步施工天气与风险建议。'
                  : _homeLocationUnavailableGuidance(locationSnapshot),
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
            const SizedBox(height: 12),
            _HomeInfoLine(
              title: '当前状态',
              value: _homeUnavailableMessage(homeResult),
            ),
            _HomeInfoLine(
              title: '建议操作',
              value: '可点击“重新定位并刷新”或“手动选择地区”继续查看施工天气信息。',
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeForecastList extends StatelessWidget {
  const _HomeForecastList({required this.title, required this.items});

  final String title;
  final List<_HomeForecastItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shownItems = items.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        ...shownItems.map(
          (_HomeForecastItem item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _HomeForecastTile(item: item),
          ),
        ),
      ],
    );
  }
}

class _HomeForecastTile extends StatelessWidget {
  const _HomeForecastTile({required this.item});

  final _HomeForecastItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 82,
              child: Text(
                item.leadingLabel,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              child: Text(
                item.title,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Text(item.temperatureLabel),
            const SizedBox(width: 12),
            Text(item.precipitationLabel),
          ],
        ),
      ),
    );
  }
}

class _HomeMetricChip extends StatelessWidget {
  const _HomeMetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeCompactOverviewTile extends StatelessWidget {
  const _HomeCompactOverviewTile({
    required this.title,
    required this.value,
    this.multiline = false,
  });

  final String title;
  final String value;
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              maxLines: multiline ? 3 : 1,
              overflow: multiline
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeInfoLine extends StatelessWidget {
  const _HomeInfoLine({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.4),
          ),
        ],
      ),
    );
  }
}

String _homeUnavailableMessage(ExhibitionLoadResult? result) {
  if (result == null) {
    return '正在同步施工天气信息，请稍候。';
  }

  switch (result.errorCode) {
    case 'AUTH_SESSION_INVALID':
      return '登录状态已失效，请先登录后再刷新天气信息。';
    case 'LOCATION_REQUIRED':
    case 'LOCATION_PERMISSION_UNAVAILABLE':
      return '请先开启定位或手动选择地区，再查看施工天气建议。';
    case 'HOME_WEATHER_UPSTREAM_UNAVAILABLE':
    case 'HOME_AGGREGATION_UNAVAILABLE':
    case 'HOME_REFRESH_TIMEOUT':
      return '天气服务暂时繁忙，请稍后再试。';
  }

  return switch (result.state) {
    AppPageState.content => '天气信息已同步完成。',
    AppPageState.empty => '当前地区暂未获取天气信息，请稍后再试。',
    AppPageState.errorRetryable => '天气信息更新失败，可点击“整页刷新”重试。',
    AppPageState.errorNonRetryable => '天气服务暂不可用，请稍后再试。',
    AppPageState.unauthorized => '登录状态已失效，请先登录后再试。',
    AppPageState.forbidden => '当前账号暂不可使用该能力。',
    AppPageState.notFound => '当前地区天气信息暂未开放。',
    _ => '天气信息同步中。',
  };
}

String _homeLocationUnavailableGuidance(DeviceLocationSnapshot? snapshot) {
  return switch (snapshot?.permissionState) {
    DeviceLocationPermissionState.denied => '定位权限未开启，可先授权定位或手动选择地区查看施工天气信息。',
    DeviceLocationPermissionState.unavailable => '当前设备定位暂不可用，可先手动选择地区查看施工天气信息。',
    DeviceLocationPermissionState.granted => '暂未获取到稳定定位，可先手动选择地区查看施工天气信息。',
    DeviceLocationPermissionState.unknown ||
    null => '暂未获取当前位置，可先手动选择地区查看施工天气信息。',
  };
}

String _homeManualLocationSelectFailureMessage(ExhibitionLoadResult result) {
  return switch (result.errorCode) {
    'AUTH_SESSION_INVALID' => '登录状态已失效，请先登录后再手动选择地区。',
    'LOCATION_REQUIRED' ||
    'LOCATION_PERMISSION_UNAVAILABLE' => '地区信息不完整，请重新选择后再试。',
    _ => _homeUnavailableMessage(result),
  };
}

String _homeLocationSyncStatus(_HomeWeatherProjection projection) {
  return switch (projection.selectionScope) {
    'persisted' => '当前地区已作为常用地区生效，可随时重新定位或手动切换。',
    'session_only' => '当前地区仅用于本次天气查看，可重新定位或手动切换，不影响长期设置。',
    'request_only' => '当前地区仅用于本次天气查看，可重新定位或手动切换，不影响长期设置。',
    _ => '当前地区仅用于本次天气查看，可重新定位或手动切换。',
  };
}
