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
    final riskLevel = weatherProjection == null
        ? '待评估'
        : _homeConstructionRiskLevelLabel(
            weatherProjection!.constructionRiskLevel,
          );
    final tonightRainLabel = weatherProjection == null
        ? '待判断'
        : _homeNightRainLabel(
            expected: weatherProjection!.nightRainExpected,
            timeLabel: weatherProjection!.nightRainTimeLabel,
          );
    final warningLabel = weatherProjection == null
        ? '待判断'
        : (weatherProjection!.officialAlerts.isEmpty ? '无预警' : '有预警');

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            colorScheme.surfaceContainerHighest,
            colorScheme.secondaryContainer.withValues(alpha: 0.92),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                _HomePill(
                  label: '天气与定位',
                  backgroundColor: colorScheme.surface,
                  foregroundColor: colorScheme.onSurface,
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
            const SizedBox(height: 6),
            Text(
              title,
              maxLines: expanded ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            if (expanded) ...<Widget>[
              const SizedBox(height: 6),
              Text(
                summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
              ),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: <Widget>[
                _HomePill(
                  label: '地区：${_locationLabel()}',
                  backgroundColor: colorScheme.onSecondaryContainer.withValues(
                    alpha: 0.12,
                  ),
                  foregroundColor: colorScheme.onSecondaryContainer,
                ),
                _HomePill(
                  label: '风险：$riskLevel',
                  backgroundColor: colorScheme.tertiaryContainer,
                  foregroundColor: colorScheme.onTertiaryContainer,
                ),
                _HomePill(
                  label: '今夜降雨：$tonightRainLabel',
                  backgroundColor: colorScheme.surface,
                  foregroundColor: colorScheme.onSurface,
                ),
                _HomePill(
                  label: '官方预警：$warningLabel',
                  backgroundColor: colorScheme.surface,
                  foregroundColor: colorScheme.onSurface,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: refreshing ? null : onRelocatePressed,
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                    ),
                    icon: const Icon(Icons.my_location_outlined, size: 16),
                    label: Text(_locationActionLabel(), maxLines: 1),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: onManualSelectionPressed,
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                    ),
                    icon: const Icon(Icons.map_outlined, size: 16),
                    label: const Text('手动选择地区', maxLines: 1),
                  ),
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
              if (weatherProjection != null)
                _HomeForecastPanel(weatherProjection: weatherProjection!)
              else
                _HomeUnavailableForecastPanel(
                  locationSnapshot: locationSnapshot,
                  homeResult: homeResult,
                ),
            ],
          ],
        ),
      ),
    );
  }

  String _cardTitle() {
    if (refreshing) {
      return '今日施工重点：正在更新全页天气信息';
    }
    if (locating) {
      return '今日施工重点：正在定位当前施工地区';
    }
    if (weatherProjection != null) {
      return '今日施工重点：${_homeConstructionFocusSummary(weatherProjection!)}';
    }
    if (locationSnapshot?.hasCoordinates == true) {
      return '今日施工重点：正在识别所在地区并同步施工天气';
    }
    return '今日施工重点：请先定位或手动选择地区';
  }

  String _cardSummary() {
    if (refreshing) {
      return '正在刷新首页天气与推荐信息，请稍候查看最新施工建议。';
    }
    if (locating) {
      return '正在获取当前位置，用于生成更准确的施工天气提示。';
    }
    if (weatherProjection != null) {
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
      return '正在识别所在地区并同步今日天气与施工建议，请稍候。';
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
      return _homeConstructionRiskLevelLabel(
        weatherProjection!.constructionRiskLevel,
      );
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
