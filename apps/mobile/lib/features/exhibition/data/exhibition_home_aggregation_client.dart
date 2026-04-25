import 'dart:io';

import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';

class ExhibitionHomeLocationContextRequest {
  const ExhibitionHomeLocationContextRequest({
    this.latitude,
    this.longitude,
    this.provinceCode,
    this.provinceName,
    this.cityName,
    this.districtName,
    this.locationPermissionState,
  });

  final double? latitude;
  final double? longitude;
  final String? provinceCode;
  final String? provinceName;
  final String? cityName;
  final String? districtName;
  final String? locationPermissionState;

  bool get hasUsableLocationHints =>
      latitude != null ||
      longitude != null ||
      _normalized(provinceCode) != null ||
      _normalized(provinceName) != null ||
      _normalized(cityName) != null ||
      _normalized(districtName) != null;

  Map<String, String> toQueryParameters() {
    final parameters = <String, String>{};
    if (latitude != null) {
      parameters['latitude'] = latitude!.toString();
    }
    if (longitude != null) {
      parameters['longitude'] = longitude!.toString();
    }
    if (_normalized(provinceCode) case final String value) {
      parameters['provinceCode'] = value;
    }
    if (_normalized(provinceName) case final String value) {
      parameters['provinceName'] = value;
    }
    if (_normalized(cityName) case final String value) {
      parameters['cityName'] = value;
    }
    if (_normalized(districtName) case final String value) {
      parameters['districtName'] = value;
    }
    if (_normalized(locationPermissionState) case final String value) {
      parameters['locationPermissionState'] = value;
    }
    return parameters;
  }

  Map<String, Object?>? toRefreshBody() {
    final locationContext = <String, Object?>{};
    if (latitude != null) {
      locationContext['latitude'] = latitude;
    }
    if (longitude != null) {
      locationContext['longitude'] = longitude;
    }
    if (_normalized(provinceCode) case final String value) {
      locationContext['provinceCode'] = value;
    }
    if (_normalized(provinceName) case final String value) {
      locationContext['provinceName'] = value;
    }
    if (_normalized(cityName) case final String value) {
      locationContext['cityName'] = value;
    }
    if (_normalized(districtName) case final String value) {
      locationContext['districtName'] = value;
    }
    if (_normalized(locationPermissionState) case final String value) {
      locationContext['locationPermissionState'] = value;
    }

    if (locationContext.isEmpty) {
      return null;
    }

    return <String, Object?>{'locationContext': locationContext};
  }

  String? _normalized(String? value) {
    if (value == null) {
      return null;
    }

    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class ExhibitionHomeLocationSelectRequest {
  const ExhibitionHomeLocationSelectRequest({
    required this.provinceName,
    this.provinceCode,
    this.cityName,
    this.districtName,
    this.displayName,
    this.latitude,
    this.longitude,
  });

  final String provinceName;
  final String? provinceCode;
  final String? cityName;
  final String? districtName;
  final String? displayName;
  final double? latitude;
  final double? longitude;

  Map<String, Object?> toBody() {
    final body = <String, Object?>{
      'provinceName': provinceName.trim(),
      if (_normalized(provinceCode) case final String value)
        'provinceCode': value,
      if (_normalized(cityName) case final String value) 'cityName': value,
      if (_normalized(districtName) case final String value)
        'districtName': value,
      if (_normalized(displayName) case final String value)
        'displayName': value,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
    return body;
  }

  String? _normalized(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

abstract class ExhibitionHomeAggregationClient {
  static ExhibitionHomeAggregationClient _instance =
      CanonicalExhibitionHomeAggregationClient();

  static ExhibitionHomeAggregationClient get instance => _instance;

  static void install(ExhibitionHomeAggregationClient client) {
    _instance = client;
  }

  static void reset() {
    _instance = CanonicalExhibitionHomeAggregationClient();
  }

  Future<ExhibitionLoadResult> load({
    ExhibitionHomeLocationContextRequest? locationContext,
  });

  Future<ExhibitionLoadResult> refresh({
    ExhibitionHomeLocationContextRequest? locationContext,
  });

  Future<ExhibitionLoadResult> selectLocation({
    required ExhibitionHomeLocationSelectRequest selection,
  });
}

class CanonicalExhibitionHomeAggregationClient
    implements ExhibitionHomeAggregationClient {
  CanonicalExhibitionHomeAggregationClient({AppApiClient? client})
    : _client = client ?? AppApiClient();

  final AppApiClient _client;

  @override
  Future<ExhibitionLoadResult> load({
    ExhibitionHomeLocationContextRequest? locationContext,
  }) async {
    try {
      final response = await _client.get(
        ExhibitionCanonicalPaths.exhibitionHome,
        queryParameters: locationContext?.toQueryParameters(),
      );
      return _mapResponse(
        response,
        method: 'GET',
        canonicalPath: ExhibitionCanonicalPaths.exhibitionHome,
      );
    } on SocketException {
      return _transportFailure(
        method: 'GET',
        canonicalPath: ExhibitionCanonicalPaths.exhibitionHome,
      );
    } on StateError {
      return _transportFailure(
        method: 'GET',
        canonicalPath: ExhibitionCanonicalPaths.exhibitionHome,
      );
    } on FormatException {
      return ExhibitionLoadResult(
        state: AppPageState.errorNonRetryable,
        method: 'GET',
        path: ExhibitionCanonicalPaths.exhibitionHome,
        message: 'response decoding failed for canonical BFF path',
      );
    }
  }

  @override
  Future<ExhibitionLoadResult> refresh({
    ExhibitionHomeLocationContextRequest? locationContext,
  }) async {
    try {
      final response = await _client.post(
        ExhibitionCanonicalPaths.exhibitionHomeRefresh,
        body: locationContext?.toRefreshBody(),
      );
      return _mapResponse(
        response,
        method: 'POST',
        canonicalPath: ExhibitionCanonicalPaths.exhibitionHomeRefresh,
      );
    } on SocketException {
      return _transportFailure(
        method: 'POST',
        canonicalPath: ExhibitionCanonicalPaths.exhibitionHomeRefresh,
      );
    } on StateError {
      return _transportFailure(
        method: 'POST',
        canonicalPath: ExhibitionCanonicalPaths.exhibitionHomeRefresh,
      );
    } on FormatException {
      return ExhibitionLoadResult(
        state: AppPageState.errorNonRetryable,
        method: 'POST',
        path: ExhibitionCanonicalPaths.exhibitionHomeRefresh,
        message: 'response decoding failed for canonical BFF path',
      );
    }
  }

  @override
  Future<ExhibitionLoadResult> selectLocation({
    required ExhibitionHomeLocationSelectRequest selection,
  }) async {
    try {
      final response = await _client.post(
        ExhibitionCanonicalPaths.exhibitionHomeLocationSelect,
        body: selection.toBody(),
      );
      return _mapResponse(
        response,
        method: 'POST',
        canonicalPath: ExhibitionCanonicalPaths.exhibitionHomeLocationSelect,
      );
    } on SocketException {
      return _transportFailure(
        method: 'POST',
        canonicalPath: ExhibitionCanonicalPaths.exhibitionHomeLocationSelect,
      );
    } on StateError {
      return _transportFailure(
        method: 'POST',
        canonicalPath: ExhibitionCanonicalPaths.exhibitionHomeLocationSelect,
      );
    } on FormatException {
      return ExhibitionLoadResult(
        state: AppPageState.errorNonRetryable,
        method: 'POST',
        path: ExhibitionCanonicalPaths.exhibitionHomeLocationSelect,
        message: 'response decoding failed for canonical BFF path',
      );
    }
  }

  ExhibitionLoadResult _mapResponse(
    AppApiResponse response, {
    required String method,
    required String canonicalPath,
  }) {
    final payload = response.body;
    final failureCode = _extractErrorCode(payload);
    final failureMessage =
        _extractMessage(payload) ?? 'canonical BFF request failed';

    if (response.statusCode == 401) {
      return ExhibitionLoadResult(
        state: AppPageState.unauthorized,
        method: method,
        path: canonicalPath,
        payload: payload,
        errorCode: failureCode,
        message: failureMessage,
      );
    }

    if (response.statusCode == 403) {
      return ExhibitionLoadResult(
        state: AppPageState.forbidden,
        method: method,
        path: canonicalPath,
        payload: payload,
        errorCode: failureCode,
        message: failureMessage,
      );
    }

    if (response.statusCode == 404) {
      return ExhibitionLoadResult(
        state: AppPageState.notFound,
        method: method,
        path: canonicalPath,
        payload: payload,
        errorCode: failureCode,
        message: failureMessage,
      );
    }

    if (response.statusCode == 503 || response.statusCode == 504) {
      return ExhibitionLoadResult(
        state: AppPageState.errorRetryable,
        method: method,
        path: canonicalPath,
        payload: payload,
        errorCode: failureCode,
        message: failureMessage,
      );
    }

    if (response.statusCode >= 500) {
      return ExhibitionLoadResult(
        state: AppPageState.errorRetryable,
        method: method,
        path: canonicalPath,
        payload: payload,
        errorCode: failureCode,
        message: failureMessage,
      );
    }

    if (response.statusCode >= 400) {
      return ExhibitionLoadResult(
        state: AppPageState.errorNonRetryable,
        method: method,
        path: canonicalPath,
        payload: payload,
        errorCode: failureCode,
        message: failureMessage,
      );
    }

    if (payload is! Map) {
      return ExhibitionLoadResult(
        state: AppPageState.errorNonRetryable,
        method: method,
        path: canonicalPath,
        payload: payload,
        message: 'contract drift on $canonicalPath: response must be an object',
      );
    }

    return ExhibitionLoadResult(
      state: AppPageState.content,
      method: method,
      path: canonicalPath,
      payload: payload.map(
        (Object? key, Object? value) => MapEntry('$key', value),
      ),
    );
  }

  ExhibitionLoadResult _transportFailure({
    required String method,
    required String canonicalPath,
  }) {
    return ExhibitionLoadResult(
      state: AppPageState.errorRetryable,
      method: method,
      path: canonicalPath,
      message: 'current canonical exhibition home path is not yet reachable',
    );
  }

  String? _extractErrorCode(Object? payload) {
    if (payload is! Map) {
      return null;
    }

    final value = payload['code'] ?? payload['errorCode'];
    if (value is! String || value.trim().isEmpty) {
      return null;
    }
    return value.trim();
  }

  String? _extractMessage(Object? payload) {
    if (payload is! Map) {
      return null;
    }

    final value = payload['message'];
    if (value is! String || value.trim().isEmpty) {
      return null;
    }
    return value.trim();
  }
}
