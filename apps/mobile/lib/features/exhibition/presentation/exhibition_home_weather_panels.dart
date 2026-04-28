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
    final isWeatherDegraded = weatherProjection?.isWeatherDegraded == true;
    final isWeatherUnavailable =
        weatherProjection?.isWeatherUnavailable == true;

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
              isWeatherUnavailable ? '当前地区天气总览' : '今日施工天气总览',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final cellWidth = (constraints.maxWidth - 6) / 2;
                final locationValue =
                    weatherProjection?.displayName ??
                    (locationSnapshot?.hasCoordinates == true
                        ? '所在地区识别中'
                        : '待获取');
                final weatherValue = weatherProjection == null
                    ? '天气待更新'
                    : isWeatherDegraded
                    ? '天气暂不可用'
                    : weatherProjection!.isControlledPlaceholder
                    ? '天气待更新'
                    : '${weatherProjection!.currentWeather} ${weatherProjection!.highTemperature.toStringAsFixed(0)}°/${weatherProjection!.lowTemperature.toStringAsFixed(0)}°';
                final riskValue = weatherProjection == null
                    ? '待评估'
                    : isWeatherUnavailable
                    ? _homeConstructionRiskLevelLabel(
                        weatherProjection!.constructionRiskLevel,
                      )
                    : _homeConstructionRiskLevelLabel(
                        weatherProjection!.constructionRiskLevel,
                      );
                final tagsValue = weatherProjection == null
                    ? '待确认'
                    : isWeatherUnavailable
                    ? _homeRiskTagsLabel(weatherProjection!.riskTags)
                    : _homeRiskTagsLabel(weatherProjection!.riskTags);

                return Wrap(
                  spacing: 6,
                  runSpacing: 6,
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
            const SizedBox(height: 8),
            _HomeCompactOverviewTile(
              title: isWeatherUnavailable ? '地区与天气状态' : '位置与同步状态',
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
        const SizedBox(height: 8),
        _HomeConstructionSuggestionPanel(weatherProjection: weatherProjection),
        if (weatherProjection.officialAlerts.isNotEmpty) ...<Widget>[
          const SizedBox(height: 8),
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
    this.weatherProjection,
  });

  final DeviceLocationSnapshot? locationSnapshot;
  final ExhibitionLoadResult? homeResult;
  final _HomeWeatherProjection? weatherProjection;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isWeatherUnavailable =
        weatherProjection?.isWeatherUnavailable == true;
    final summary = isWeatherUnavailable
        ? '已同步到 ${weatherProjection!.displayName}。${_homeUnavailableWeatherSummary(weatherProjection!)}'
        : (locationSnapshot?.hasCoordinates == true
              ? '当前位置已获取，但当前还未拿到可展示的天气结果。'
              : _homeLocationUnavailableGuidance(locationSnapshot));

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
              '天气与施工说明',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isWeatherUnavailable ? '地区已同步，天气暂不可用' : '当前地区说明尚未就绪',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              summary,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(height: 1.35),
            ),
            const SizedBox(height: 8),
            _HomeInfoLine(
              title: '当前状态',
              value: isWeatherUnavailable && weatherProjection != null
                  ? _homeLocationSyncStatus(weatherProjection!)
                  : _homeUnavailableMessage(homeResult),
            ),
            if (isWeatherUnavailable && weatherProjection != null)
              _HomeInfoLine(
                title: '地区来源',
                value: weatherProjection!.sourceLabel,
              ),
            _HomeInfoLine(
              title: '建议操作',
              value: isWeatherUnavailable
                  ? '可点击“整页刷新”更新当前地区说明；如需切换地区，可使用“重新定位并刷新”或“手动选择地区”。'
                  : '可点击“重新定位并刷新”或“手动选择地区”继续查看当前地区说明。',
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
        const SizedBox(height: 8),
        ...shownItems.map(
          (_HomeForecastItem item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 70,
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w900,
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
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
      padding: const EdgeInsets.only(bottom: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(height: 1.32),
          ),
        ],
      ),
    );
  }
}

String _homeUnavailableMessage(ExhibitionLoadResult? result) {
  if (result == null) {
    return '当前地区说明同步中，请稍候。';
  }

  switch (result.errorCode) {
    case 'AUTH_SESSION_INVALID':
      return '登录状态已失效，请先登录后再刷新当前地区说明。';
    case 'LOCATION_REQUIRED':
    case 'LOCATION_PERMISSION_UNAVAILABLE':
      return '请先开启定位或手动选择地区，再查看当前地区说明。';
    case 'HOME_WEATHER_UPSTREAM_UNAVAILABLE':
      return '当前地区已同步，但天气暂不可用，请稍后再试。';
    case 'HOME_AGGREGATION_UNAVAILABLE':
    case 'HOME_REFRESH_TIMEOUT':
      return '地区说明服务暂时繁忙，请稍后再试。';
  }

  return switch (result.state) {
    AppPageState.content => '当前地区说明已同步，但天气暂不可用。',
    AppPageState.empty => '当前地区暂未获取到地区说明，请稍后再试。',
    AppPageState.errorRetryable => '当前地区说明更新失败，可点击“整页刷新”重试。',
    AppPageState.errorNonRetryable => '地区说明服务暂不可用，请稍后再试。',
    AppPageState.unauthorized => '登录状态已失效，请先登录后再试。',
    AppPageState.forbidden => '当前账号暂不可使用该能力。',
    AppPageState.notFound => '当前地区说明暂未开放。',
    _ => '当前地区说明同步中。',
  };
}

String _homeLocationUnavailableGuidance(DeviceLocationSnapshot? snapshot) {
  return switch (snapshot?.permissionState) {
    DeviceLocationPermissionState.denied => '定位权限未开启，可先授权定位或手动选择地区查看当前地区说明。',
    DeviceLocationPermissionState.unavailable => '当前设备定位暂不可用，可先手动选择地区查看当前地区说明。',
    DeviceLocationPermissionState.granted => '暂未获取到稳定定位，可先手动选择地区查看当前地区说明。',
    DeviceLocationPermissionState.unknown ||
    null => '暂未获取当前位置，可先手动选择地区查看当前地区说明。',
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
  final scopeNotice = projection.selectionNotice.trim();
  final fallbackNotice = switch (projection.selectionScope) {
    'persisted' => '当前地区已作为常用地区生效，可随时重新定位或手动切换。',
    'session_only' => '当前地区仅用于当前会话，可重新定位或手动切换，不影响长期设置。',
    'request_only' => '当前地区仅用于当前首页聚合，可重新定位或手动切换。',
    _ => '当前地区仅用于当前首页聚合，可重新定位或手动切换。',
  };
  final effectiveNotice = scopeNotice.isEmpty ? fallbackNotice : scopeNotice;
  final capabilityNotice = projection.isWeatherDegraded
      ? '天气暂不可用，当前已切到受控降级展示。'
      : projection.isControlledPlaceholder
      ? '天气仍在更新中，请以现场实时天气和官方预警为准。'
      : '天气与施工建议已按当前地区同步。';
  return '$effectiveNotice 来源：${projection.sourceLabel}。$capabilityNotice';
}

String _homeUnavailableWeatherSummary(_HomeWeatherProjection projection) {
  final notice = projection.selectionNotice.trim();
  final selectionNotice = notice.isEmpty ? '当前地区仅用于当前首页聚合' : notice;
  if (projection.isWeatherDegraded) {
    return '$selectionNotice 当前地区已同步，但天气服务暂不可用；施工前请以现场实时天气和官方预警为准。';
  }
  return '$selectionNotice 当前天气仍在更新中；施工前请以现场实时天气和官方预警为准。';
}
