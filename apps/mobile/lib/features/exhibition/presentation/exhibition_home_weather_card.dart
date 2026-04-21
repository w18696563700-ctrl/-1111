part of 'exhibition_home_page.dart';

class _HomeWeatherCard extends StatelessWidget {
  const _HomeWeatherCard({
    required this.expanded,
    required this.refreshing,
    required this.locating,
    required this.locationSnapshot,
    required this.homeResult,
    required this.weatherProjection,
    required this.onToggleExpanded,
    required this.onRefreshPressed,
    required this.onRelocatePressed,
    required this.onManualSelectionPressed,
  });

  final bool expanded;
  final bool refreshing;
  final bool locating;
  final DeviceLocationSnapshot? locationSnapshot;
  final ExhibitionLoadResult? homeResult;
  final _HomeWeatherProjection? weatherProjection;
  final VoidCallback onToggleExpanded;
  final VoidCallback onRefreshPressed;
  final VoidCallback onRelocatePressed;
  final VoidCallback onManualSelectionPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final title = _cardTitle();
    final summary = _cardSummary();
    final statusLabel = _statusLabel();
    final isWeatherUnavailable =
        weatherProjection?.isWeatherUnavailable == true;
    final isWeatherDegraded = weatherProjection?.isWeatherDegraded == true;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                _HomePill(
                  label: '天气与定位',
                  backgroundColor: colorScheme.surfaceContainerLowest,
                  foregroundColor: colorScheme.onSurface,
                  borderColor: colorScheme.outlineVariant,
                ),
                const SizedBox(width: 6),
                _HomePill(
                  label: statusLabel,
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                ),
                const Spacer(),
                IconButton(
                  tooltip: refreshing ? '正在整页刷新' : '整页刷新',
                  onPressed: refreshing ? null : onRefreshPressed,
                  icon: Icon(refreshing ? Icons.sync : Icons.refresh, size: 18),
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  tooltip: expanded ? '收起天气卡' : '展开天气卡',
                  onPressed: onToggleExpanded,
                  icon: Icon(
                    expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              title,
              maxLines: expanded ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              style:
                  (expanded
                          ? theme.textTheme.titleLarge
                          : theme.textTheme.titleMedium)
                      ?.copyWith(fontWeight: FontWeight.w800),
            ),
            if (expanded) ...<Widget>[
              const SizedBox(height: 4),
              Text(
                summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
              ),
            ],
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: expanded
                  ? <Widget>[
                      _HomePill(
                        label: '地区：${_locationLabel()}',
                        backgroundColor: colorScheme.surfaceContainerLowest,
                        foregroundColor: colorScheme.onSurface,
                        borderColor: colorScheme.outlineVariant,
                      ),
                      if (isWeatherUnavailable)
                        _HomePill(
                          label: isWeatherDegraded ? '天气：暂不可用' : '天气：待更新',
                          backgroundColor: colorScheme.surfaceContainerLowest,
                          foregroundColor: colorScheme.onSurface,
                          borderColor: colorScheme.outlineVariant,
                        )
                      else ...<Widget>[
                        _HomePill(
                          label:
                              '风险：${_homeConstructionRiskLevelLabel(weatherProjection?.constructionRiskLevel)}',
                          backgroundColor: colorScheme.surfaceContainerLowest,
                          foregroundColor: colorScheme.onSurface,
                          borderColor: colorScheme.outlineVariant,
                        ),
                        _HomePill(
                          label:
                              '今夜降雨：${_homeNightRainLabel(expected: weatherProjection?.nightRainExpected, timeLabel: weatherProjection?.nightRainTimeLabel)}',
                          backgroundColor: colorScheme.surfaceContainerLowest,
                          foregroundColor: colorScheme.onSurface,
                          borderColor: colorScheme.outlineVariant,
                        ),
                        _HomePill(
                          label:
                              '官方预警：${weatherProjection == null ? '待判断' : (weatherProjection!.officialAlerts.isEmpty ? '无预警' : '有预警')}',
                          backgroundColor: colorScheme.surfaceContainerLowest,
                          foregroundColor: colorScheme.onSurface,
                          borderColor: colorScheme.outlineVariant,
                        ),
                      ],
                    ]
                  : <Widget>[
                      _HomePill(
                        label: '地区：${_locationLabel()}',
                        backgroundColor: colorScheme.surfaceContainerLowest,
                        foregroundColor: colorScheme.onSurface,
                        borderColor: colorScheme.outlineVariant,
                      ),
                      if (isWeatherUnavailable)
                        _HomePill(
                          label: isWeatherDegraded ? '天气：暂不可用' : '天气：待更新',
                          backgroundColor: colorScheme.surfaceContainerLowest,
                          foregroundColor: colorScheme.onSurface,
                          borderColor: colorScheme.outlineVariant,
                        )
                      else if (weatherProjection != null)
                        _HomePill(
                          label:
                              '风险：${_homeConstructionRiskLevelLabel(weatherProjection?.constructionRiskLevel)}',
                          backgroundColor: colorScheme.surfaceContainerLowest,
                          foregroundColor: colorScheme.onSurface,
                          borderColor: colorScheme.outlineVariant,
                        ),
                    ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                TextButton.icon(
                  onPressed: refreshing ? null : onRelocatePressed,
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.onSurfaceVariant,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                  ),
                  icon: const Icon(Icons.my_location_outlined, size: 16),
                  label: Text(_locationActionLabel(), maxLines: 1),
                ),
                OutlinedButton.icon(
                  onPressed: onManualSelectionPressed,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: colorScheme.primaryContainer.withValues(
                      alpha: 0.58,
                    ),
                    foregroundColor: colorScheme.onPrimaryContainer,
                    side: BorderSide(
                      color: colorScheme.primary.withValues(alpha: 0.14),
                    ),
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  icon: const Icon(Icons.map_outlined, size: 16),
                  label: const Text('手动选择地区', maxLines: 1),
                ),
              ],
            ),
            if (expanded) ...<Widget>[
              const SizedBox(height: 12),
              _HomeWeatherStatusPanel(
                locationSnapshot: locationSnapshot,
                homeResult: homeResult,
                weatherProjection: weatherProjection,
              ),
              const SizedBox(height: 12),
              if (weatherProjection != null &&
                  !weatherProjection!.isControlledPlaceholder)
                _HomeForecastPanel(weatherProjection: weatherProjection!)
              else
                _HomeUnavailableForecastPanel(
                  locationSnapshot: locationSnapshot,
                  homeResult: homeResult,
                  weatherProjection: weatherProjection,
                ),
            ],
          ],
        ),
      ),
    );
  }

  String _cardTitle() {
    if (refreshing) {
      return '当前地区说明：正在刷新地区与天气卡片';
    }
    if (locating) {
      return '当前地区说明：正在定位当前地区';
    }
    if (weatherProjection != null) {
      if (weatherProjection!.isWeatherDegraded) {
        return '当前地区说明：地区已同步，天气暂不可用';
      }
      if (weatherProjection!.isControlledPlaceholder) {
        return '当前地区说明：地区已同步，天气待更新';
      }
      return '今日施工重点：${_homeConstructionFocusSummary(weatherProjection!)}';
    }
    if (locationSnapshot?.hasCoordinates == true) {
      return '当前地区说明：正在识别所在地区';
    }
    return '当前地区说明：请先定位或手动选择地区';
  }

  String _cardSummary() {
    if (refreshing) {
      return '正在刷新首页地区说明与推荐频道，请稍候。';
    }
    if (locating) {
      return '正在获取当前位置，用于同步首页当前地区说明。';
    }
    if (weatherProjection != null) {
      if (weatherProjection!.isWeatherDegraded) {
        return '当前位置 ${weatherProjection!.displayName}。地区已同步，但天气服务暂不可用；当前按受控降级返回施工建议。更新时间 ${_homeUpdatedAtLabel(weatherProjection!.updatedAt)}。';
      }
      if (weatherProjection!.isControlledPlaceholder) {
        return '当前位置 ${weatherProjection!.displayName}。地区已同步，天气仍在更新中；施工前请以现场实时天气和官方预警为准。';
      }
      final risk = _homeConstructionRiskLevelLabel(
        weatherProjection!.constructionRiskLevel,
      );
      final riskTime = weatherProjection!.riskTimeLabel ?? '风险时段待确认';
      final tonightRain = _homeNightRainCue(
        expected: weatherProjection!.nightRainExpected,
        timeLabel: weatherProjection!.nightRainTimeLabel,
      );
      final warning = weatherProjection!.officialAlerts.isEmpty ? '无预警' : '有预警';
      return '当前位置 ${weatherProjection!.displayName}。$risk（$riskTime），$tonightRain，官方$warning。更新时间 ${_homeUpdatedAtLabel(weatherProjection!.updatedAt)}。';
    }
    if (locationSnapshot?.hasCoordinates == true) {
      return '正在识别所在地区；当前还未拿到可展示的天气结果。';
    }
    return _homeLocationUnavailableGuidance(locationSnapshot);
  }

  String _statusLabel() {
    if (refreshing) {
      return '整页刷新中';
    }
    if (locating) {
      return '正在定位';
    }
    if (weatherProjection != null) {
      if (weatherProjection!.isWeatherDegraded) {
        return '天气降级';
      }
      if (weatherProjection!.isControlledPlaceholder) {
        return '天气待更新';
      }
      return '天气已同步';
    }
    if (locationSnapshot?.hasCoordinates == true) {
      return '地区识别中';
    }
    if (locationSnapshot?.permissionState ==
        DeviceLocationPermissionState.denied) {
      return '待开启定位';
    }
    return '待获取位置';
  }

  String _locationLabel() {
    if (weatherProjection != null) {
      return weatherProjection!.displayName;
    }
    if (locationSnapshot?.hasCoordinates == true) {
      return '所在地区识别中';
    }
    return switch (locationSnapshot?.permissionState) {
      DeviceLocationPermissionState.granted => '所在地区待识别',
      DeviceLocationPermissionState.denied => '定位权限未授予',
      DeviceLocationPermissionState.unavailable => '定位当前不可用',
      DeviceLocationPermissionState.unknown || null => '定位状态待确认',
    };
  }

  String _locationActionLabel() {
    if (locationSnapshot?.hasCoordinates == true) {
      return '重新定位并刷新';
    }
    if (locationSnapshot?.permissionState ==
        DeviceLocationPermissionState.denied) {
      return '申请定位权限';
    }
    return '重新定位';
  }
}
