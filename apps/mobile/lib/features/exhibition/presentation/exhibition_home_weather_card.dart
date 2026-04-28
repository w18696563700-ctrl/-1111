part of 'exhibition_home_page.dart';

class _HomeWeatherCard extends StatelessWidget {
  const _HomeWeatherCard({
    required this.expanded,
    required this.refreshing,
    required this.locating,
    required this.locationSnapshot,
    required this.manualLocationSelection,
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
  final ExhibitionHomeLocationSelectRequest? manualLocationSelection;
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
    final visualKey = resolveCityVisualKey(
      regionName: _locationLabel(),
      cityName: manualLocationSelection?.cityName,
      districtName: manualLocationSelection?.districtName,
      cityCode: manualLocationSelection?.provinceCode,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(
        ExhibitionHomeVisualTokens.radiusLarge,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: ExhibitionHomeVisualTokens.cardBackground,
          borderRadius: BorderRadius.circular(
            ExhibitionHomeVisualTokens.radiusLarge,
          ),
          boxShadow: ExhibitionHomeVisualTokens.cardShadow(opacity: 0.08),
        ),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: ExhibitionCityHeroBackground(visualKey: visualKey),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: <Color>[
                      Colors.white.withValues(alpha: 0.96),
                      Colors.white.withValues(alpha: 0.82),
                      Colors.white.withValues(alpha: 0.28),
                    ],
                    stops: const <double>[0, 0.58, 1],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.72),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Icon(
                                  Icons.location_on_rounded,
                                  size: 16,
                                  color: Color(0xFF2F7DCB),
                                ),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    _locationLabel(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: ExhibitionHomeVisualTokens
                                          .textPrimary,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _HomePill(
                        label: _statusLabel(),
                        backgroundColor:
                            ExhibitionHomeVisualTokens.brandGoldLight,
                        foregroundColor:
                            ExhibitionHomeVisualTokens.brandGoldDeep,
                        dense: true,
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: refreshing ? '正在整页刷新' : '整页刷新',
                        onPressed: refreshing ? null : onRefreshPressed,
                        icon: Icon(
                          refreshing ? Icons.sync : Icons.refresh_rounded,
                          size: 18,
                        ),
                        color: colorScheme.onSurfaceVariant,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.64),
                          visualDensity: VisualDensity.compact,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      IconButton(
                        tooltip: expanded ? '收起天气卡' : '展开天气卡',
                        onPressed: onToggleExpanded,
                        icon: Icon(
                          expanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 20,
                        ),
                        color: colorScheme.onSurfaceVariant,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.64),
                          visualDensity: VisualDensity.compact,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Text(
                    _heroTitle(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: ExhibitionHomeVisualTokens.textPrimary,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  if (_heroSubtitle() case final String subtitle) ...<Widget>[
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      maxLines: expanded ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: ExhibitionHomeVisualTokens.textSecondary,
                        fontWeight: FontWeight.w600,
                        height: 1.28,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: _heroInfoPills(context)
                          .map(
                            (Widget pill) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: pill,
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ),
                  const SizedBox(height: 9),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      OutlinedButton.icon(
                        onPressed: refreshing ? null : onRelocatePressed,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.7),
                          foregroundColor:
                              ExhibitionHomeVisualTokens.textPrimary,
                          visualDensity: VisualDensity.compact,
                          side: BorderSide(
                            color: ExhibitionHomeVisualTokens.borderSoft
                                .withValues(alpha: 0.72),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                        ),
                        icon: const Icon(Icons.my_location_outlined, size: 16),
                        label: Text(_locationActionLabel(), maxLines: 1),
                      ),
                      OutlinedButton.icon(
                        onPressed: onManualSelectionPressed,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.78),
                          foregroundColor:
                              ExhibitionHomeVisualTokens.brandGoldDeep,
                          visualDensity: VisualDensity.compact,
                          side: BorderSide(
                            color: ExhibitionHomeVisualTokens.brandGold
                                .withValues(alpha: 0.24),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                        ),
                        icon: const Icon(Icons.map_outlined, size: 16),
                        label: const Text('手动选择地区', maxLines: 1),
                      ),
                    ],
                  ),
                  if (expanded) ...<Widget>[
                    const SizedBox(height: 16),
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
          ],
        ),
      ),
    );
  }

  String _heroTitle() {
    if (refreshing) {
      return '正在刷新城市天气与推荐频道';
    }
    if (locating) {
      return '正在定位当前城市';
    }
    final projection = weatherProjection;
    if (projection == null) {
      return locationSnapshot?.hasCoordinates == true
          ? '城市已定位，天气加载中'
          : '选择城市后查看展览商机天气';
    }
    if (projection.isWeatherDegraded) {
      return '${projection.displayName} 已同步，天气暂不可用';
    }
    if (projection.isControlledPlaceholder) {
      return '${projection.displayName} 已同步，天气暂未更新';
    }
    return '${projection.currentWeather} ${projection.currentTemperature.toStringAsFixed(0)}°';
  }

  String? _heroSubtitle() {
    final projection = weatherProjection;
    if (projection == null) {
      return locationSnapshot?.hasCoordinates == true
          ? '城市已同步，天气数据正在更新。'
          : '定位或手动选择地区后，首页会按城市展示天气与项目机会。';
    }
    if (projection.isWeatherDegraded) {
      return '天气接口异常不影响项目列表和推荐频道，可稍后刷新。';
    }
    if (projection.isControlledPlaceholder) {
      return '天气数据暂未返回，项目与公开入口仍可正常使用。';
    }
    return '${_homeConstructionFocusSummary(projection)}，${_homeNightRainCue(expected: projection.nightRainExpected, timeLabel: projection.nightRainTimeLabel)}。';
  }

  List<Widget> _heroInfoPills(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final projection = weatherProjection;
    if (projection == null) {
      return <Widget>[
        _HomeIconPill(
          icon: Icons.cloud_queue_rounded,
          label: locationSnapshot?.hasCoordinates == true ? '天气加载中' : '等待定位',
        ),
      ];
    }
    if (projection.isWeatherUnavailable) {
      return <Widget>[
        _HomeIconPill(
          icon: Icons.cloud_off_outlined,
          label: projection.isWeatherDegraded ? '天气暂不可用' : '天气暂未更新',
        ),
      ];
    }
    final pills = <Widget>[
      _HomeIconPill(
        icon: Icons.thermostat_rounded,
        label:
            '${projection.lowTemperature.toStringAsFixed(0)}°-${projection.highTemperature.toStringAsFixed(0)}°',
      ),
      _HomeIconPill(
        icon: Icons.health_and_safety_outlined,
        label:
            '施工${_homeConstructionRiskLevelLabel(projection.constructionRiskLevel)}',
      ),
      _HomeIconPill(
        icon: Icons.water_drop_outlined,
        label:
            '降雨 ${_homeNightRainLabel(expected: projection.nightRainExpected, timeLabel: projection.nightRainTimeLabel)}',
      ),
    ];
    if (projection.officialAlerts.isNotEmpty) {
      pills.add(
        _HomeIconPill(
          icon: Icons.campaign_outlined,
          label: '有官方预警',
          backgroundColor: colorScheme.errorContainer.withValues(alpha: 0.78),
        ),
      );
    }
    return pills;
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
