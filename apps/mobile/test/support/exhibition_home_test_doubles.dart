import 'dart:async';

import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/location/device_location_service.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/exhibition_home_aggregation_client.dart';

class FakeDeviceLocationService implements DeviceLocationService {
  FakeDeviceLocationService({
    FutureOr<DeviceLocationSnapshot> Function()? resolver,
  }) : _resolver =
           resolver ??
           (() => const DeviceLocationSnapshot(
             permissionState: DeviceLocationPermissionState.granted,
             latitude: 30.5728,
             longitude: 104.0668,
           ));

  final FutureOr<DeviceLocationSnapshot> Function() _resolver;
  int requestCount = 0;

  @override
  Future<DeviceLocationSnapshot> resolveCurrentPosition() async {
    requestCount += 1;
    return _resolver();
  }
}

class FakeExhibitionHomeAggregationClient
    implements ExhibitionHomeAggregationClient {
  FakeExhibitionHomeAggregationClient({
    FutureOr<ExhibitionLoadResult> Function(
      ExhibitionHomeLocationContextRequest? locationContext,
    )?
    onLoad,
    FutureOr<ExhibitionLoadResult> Function(
      ExhibitionHomeLocationContextRequest? locationContext,
    )?
    onRefresh,
    FutureOr<ExhibitionLoadResult> Function(
      ExhibitionHomeLocationSelectRequest selection,
    )?
    onSelectLocation,
  }) : _onLoad = onLoad ?? ((_) => unavailableHomeResult()),
       _onRefresh =
           onRefresh ?? ((_) => unavailableHomeResult(isRefresh: true)),
       _onSelectLocation =
           onSelectLocation ?? ((_) => unavailableHomeResult(isSelect: true));

  final FutureOr<ExhibitionLoadResult> Function(
    ExhibitionHomeLocationContextRequest? locationContext,
  )
  _onLoad;
  final FutureOr<ExhibitionLoadResult> Function(
    ExhibitionHomeLocationContextRequest? locationContext,
  )
  _onRefresh;
  final FutureOr<ExhibitionLoadResult> Function(
    ExhibitionHomeLocationSelectRequest selection,
  )
  _onSelectLocation;

  int loadCount = 0;
  int refreshCount = 0;
  int selectLocationCount = 0;
  ExhibitionHomeLocationContextRequest? lastLoadLocationContext;
  ExhibitionHomeLocationContextRequest? lastRefreshLocationContext;
  ExhibitionHomeLocationSelectRequest? lastSelectedLocation;

  @override
  Future<ExhibitionLoadResult> load({
    ExhibitionHomeLocationContextRequest? locationContext,
  }) async {
    loadCount += 1;
    lastLoadLocationContext = locationContext;
    return _onLoad(locationContext);
  }

  @override
  Future<ExhibitionLoadResult> refresh({
    ExhibitionHomeLocationContextRequest? locationContext,
  }) async {
    refreshCount += 1;
    lastRefreshLocationContext = locationContext;
    return _onRefresh(locationContext);
  }

  @override
  Future<ExhibitionLoadResult> selectLocation({
    required ExhibitionHomeLocationSelectRequest selection,
  }) async {
    selectLocationCount += 1;
    lastSelectedLocation = selection;
    return _onSelectLocation(selection);
  }
}

ExhibitionLoadResult unavailableHomeResult({
  bool isRefresh = false,
  bool isSelect = false,
  AppPageState state = AppPageState.errorRetryable,
  String errorCode = 'HOME_AGGREGATION_UNAVAILABLE',
  String message = '天气信息同步中，请稍候。',
}) {
  return ExhibitionLoadResult(
    state: state,
    method: isRefresh || isSelect ? 'POST' : 'GET',
    path: isRefresh
        ? ExhibitionCanonicalPaths.exhibitionHomeRefresh
        : isSelect
        ? ExhibitionCanonicalPaths.exhibitionHomeLocationSelect
        : ExhibitionCanonicalPaths.exhibitionHome,
    errorCode: errorCode,
    message: message,
  );
}

ExhibitionLoadResult contentHomeResult({
  String displayName = '成都市成华区',
  String provinceName = '四川',
  double latitude = 30.5728,
  double longitude = 104.0668,
  String selectionScope = 'request_only',
  String selectionNotice = '当前定位仅用于本次首页聚合',
  String sourceLabel = '首页聚合返回',
  String currentWeather = '多云',
  double currentTemperature = 21,
  double highTemperature = 25,
  double lowTemperature = 17,
  int precipitationProbability = 20,
  String constructionRiskLevel = 'low',
  String constructionRiskSummary = '天气平稳，按计划推进常规施工。',
  List<String> riskTags = const <String>[],
  String? riskTimeLabel,
  bool nightRainExpected = false,
  String? nightRainTimeLabel,
  List<String> officialAlerts = const <String>[],
  List<String> constructionSuggestions = const <String>[
    '建议按计划推进当日施工并保持常规巡检。',
    '建议收工前复核临电和材料堆放安全。',
    '建议关注后续天气变化并预留机动时段。',
  ],
  String updatedAt = '2026-03-28T09:30:00Z',
}) {
  return ExhibitionLoadResult(
    state: AppPageState.content,
    method: 'GET',
    path: ExhibitionCanonicalPaths.exhibitionHome,
    payload: <String, Object?>{
      'currentLocation': <String, Object?>{
        'displayName': displayName,
        'provinceName': provinceName,
        'latitude': latitude,
        'longitude': longitude,
        'source': 'device_location',
        'persisted': false,
      },
      'selectionScope': selectionScope,
      'isUsingDeviceLocation': true,
      'currentWeather': currentWeather,
      'currentTemperature': currentTemperature,
      'highTemperature': highTemperature,
      'lowTemperature': lowTemperature,
      'precipitationProbability': precipitationProbability,
      'constructionRiskLevel': constructionRiskLevel,
      'constructionRiskSummary': constructionRiskSummary,
      'riskTags': riskTags,
      'riskTimeLabel': riskTimeLabel,
      'nightRainExpected': nightRainExpected,
      'nightRainTimeLabel': nightRainTimeLabel,
      'officialAlerts': officialAlerts,
      'constructionSuggestions': constructionSuggestions,
      'hourlyForecast': <Object?>[
        <String, Object?>{
          'timeLabel': '10:00',
          'weather': '多云',
          'temperature': 21,
          'precipitationProbability': 20,
        },
        <String, Object?>{
          'timeLabel': '13:00',
          'weather': '晴间多云',
          'temperature': 24,
          'precipitationProbability': 10,
        },
      ],
      'dailyForecast': <Object?>[
        <String, Object?>{
          'dateLabel': '今天',
          'weekdayLabel': '周六',
          'weather': '多云',
          'highTemperature': 25,
          'lowTemperature': 17,
          'precipitationProbability': 20,
        },
        <String, Object?>{
          'dateLabel': '明天',
          'weekdayLabel': '周日',
          'weather': '小雨',
          'highTemperature': 22,
          'lowTemperature': 16,
          'precipitationProbability': 60,
        },
      ],
      'updatedAt': updatedAt,
      'sourceLabel': sourceLabel,
      'selectionNotice': selectionNotice,
      'canExpand': true,
      'refreshable': true,
      'modules': const <Object?>[],
      'recommendationSections': const <Object?>[],
    },
  );
}
