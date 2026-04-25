import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mobile/core/location/device_location_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'exhibition_home_aggregation_client.dart';

class ExhibitionHomeLocationContextStore {
  ExhibitionHomeLocationContextStore._();

  static const String _storageKey = 'exhibition_home.location_context_store.v1';

  static ExhibitionHomeLocationContextStore _instance =
      ExhibitionHomeLocationContextStore._();

  static ExhibitionHomeLocationContextStore get instance => _instance;

  ExhibitionHomeLocationContextRequest? _lastKnownLocationContext;
  ExhibitionHomeLocationSelectRequest? _lastManualSelection;
  DeviceLocationPermissionState _lastPermissionState =
      DeviceLocationPermissionState.unknown;
  bool _restored = false;
  Future<void>? _restoreFuture;

  ExhibitionHomeLocationContextRequest? get lastKnownLocationContext =>
      _lastKnownLocationContext;

  ExhibitionHomeLocationSelectRequest? get lastManualSelection =>
      _lastManualSelection;

  DeviceLocationPermissionState get lastPermissionState => _lastPermissionState;

  Future<void> restore() {
    if (_restored) {
      return Future<void>.value();
    }

    final inFlight = _restoreFuture;
    if (inFlight != null) {
      return inFlight;
    }

    final future = _restorePersistedState();
    _restoreFuture = future;
    return future;
  }

  void storeDeviceSnapshot(DeviceLocationSnapshot snapshot) {
    _lastPermissionState = snapshot.permissionState;
    final locationContext = ExhibitionHomeLocationContextRequest(
      latitude: snapshot.latitude,
      longitude: snapshot.longitude,
      provinceCode: snapshot.provinceCode,
      provinceName: snapshot.provinceName,
      locationPermissionState: snapshot.permissionState.contractName,
    );
    if (locationContext.hasUsableLocationHints) {
      _lastKnownLocationContext = locationContext;
      _lastManualSelection = null;
    }
    _restored = true;
    unawaited(_persist());
  }

  void storeManualSelection(
    ExhibitionHomeLocationSelectRequest selection, {
    required DeviceLocationPermissionState permissionState,
  }) {
    _lastManualSelection = selection;
    _lastPermissionState = permissionState;
    _lastKnownLocationContext = ExhibitionHomeLocationContextRequest(
      latitude: selection.latitude,
      longitude: selection.longitude,
      provinceCode: selection.provinceCode,
      provinceName: selection.provinceName,
      cityName: selection.cityName,
      districtName: selection.districtName,
      locationPermissionState: permissionState.contractName,
    );
    _restored = true;
    unawaited(_persist());
  }

  void storeResolvedLocationContext(
    ExhibitionHomeLocationContextRequest locationContext, {
    required DeviceLocationPermissionState permissionState,
  }) {
    if (!locationContext.hasUsableLocationHints) {
      return;
    }

    _lastPermissionState = permissionState;
    final previousLocationContext = _lastKnownLocationContext;
    final keepPreviousCoordinates =
        previousLocationContext != null &&
        previousLocationContext.latitude != null &&
        previousLocationContext.longitude != null &&
        (locationContext.latitude == null ||
            locationContext.longitude == null ||
            _hasSameAdministrativeScope(
              previousLocationContext,
              locationContext,
            ));
    _lastKnownLocationContext = ExhibitionHomeLocationContextRequest(
      latitude: keepPreviousCoordinates
          ? previousLocationContext.latitude
          : locationContext.latitude ?? previousLocationContext?.latitude,
      longitude: keepPreviousCoordinates
          ? previousLocationContext.longitude
          : locationContext.longitude ?? previousLocationContext?.longitude,
      provinceCode:
          locationContext.provinceCode ?? previousLocationContext?.provinceCode,
      provinceName:
          locationContext.provinceName ?? previousLocationContext?.provinceName,
      cityName: locationContext.cityName ?? previousLocationContext?.cityName,
      districtName:
          locationContext.districtName ?? previousLocationContext?.districtName,
      locationPermissionState:
          locationContext.locationPermissionState ??
          previousLocationContext?.locationPermissionState ??
          permissionState.contractName,
    );
    _restored = true;
    unawaited(_persist());
  }

  bool _hasSameAdministrativeScope(
    ExhibitionHomeLocationContextRequest previous,
    ExhibitionHomeLocationContextRequest next,
  ) {
    var compared = false;
    if (_hasSameValue(previous.provinceCode, next.provinceCode)) {
      compared = true;
    }
    if (_hasSameValue(previous.provinceName, next.provinceName)) {
      compared = true;
    }
    if (_hasSameValue(previous.cityName, next.cityName)) {
      compared = true;
    }
    if (_hasSameValue(previous.districtName, next.districtName)) {
      compared = true;
    }
    return compared;
  }

  bool _hasSameValue(String? left, String? right) {
    final normalizedLeft = _stringFromObject(left);
    final normalizedRight = _stringFromObject(right);
    if (normalizedLeft == null || normalizedRight == null) {
      return false;
    }
    return normalizedLeft == normalizedRight;
  }

  @visibleForTesting
  static void reset() {
    _instance = ExhibitionHomeLocationContextStore._();
  }

  Future<void> _restorePersistedState() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final raw = preferences.getString(_storageKey);
      final payload = _mapFromObject(
        raw == null || raw.trim().isEmpty ? null : jsonDecode(raw),
      );
      if (payload == null) {
        return;
      }

      _lastKnownLocationContext = _locationContextFromObject(
        payload['lastKnownLocationContext'],
      );
      _lastManualSelection = _manualSelectionFromObject(
        payload['lastManualSelection'],
      );
      _lastPermissionState = _permissionStateFromObject(
        payload['lastPermissionState'],
      );
    } on Object {
      return;
    } finally {
      _restored = true;
      _restoreFuture = null;
    }
  }

  Future<void> _persist() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(
        _storageKey,
        jsonEncode(<String, Object?>{
          'lastKnownLocationContext': _lastKnownLocationContext == null
              ? null
              : _locationContextToJson(_lastKnownLocationContext!),
          'lastManualSelection': _lastManualSelection == null
              ? null
              : _manualSelectionToJson(_lastManualSelection!),
          'lastPermissionState': _lastPermissionState.contractName,
        }),
      );
    } on Object {
      return;
    }
  }

  Map<String, Object?> _locationContextToJson(
    ExhibitionHomeLocationContextRequest locationContext,
  ) {
    return <String, Object?>{
      'latitude': locationContext.latitude,
      'longitude': locationContext.longitude,
      'provinceCode': locationContext.provinceCode,
      'provinceName': locationContext.provinceName,
      'cityName': locationContext.cityName,
      'districtName': locationContext.districtName,
      'locationPermissionState': locationContext.locationPermissionState,
    };
  }

  ExhibitionHomeLocationContextRequest? _locationContextFromObject(
    Object? value,
  ) {
    final payload = _mapFromObject(value);
    if (payload == null) {
      return null;
    }

    final locationContext = ExhibitionHomeLocationContextRequest(
      latitude: _doubleFromObject(payload['latitude']),
      longitude: _doubleFromObject(payload['longitude']),
      provinceCode: _stringFromObject(payload['provinceCode']),
      provinceName: _stringFromObject(payload['provinceName']),
      cityName: _stringFromObject(payload['cityName']),
      districtName: _stringFromObject(payload['districtName']),
      locationPermissionState: _stringFromObject(
        payload['locationPermissionState'],
      ),
    );
    return locationContext.hasUsableLocationHints ? locationContext : null;
  }

  Map<String, Object?> _manualSelectionToJson(
    ExhibitionHomeLocationSelectRequest selection,
  ) {
    return <String, Object?>{
      'provinceCode': selection.provinceCode,
      'provinceName': selection.provinceName,
      'cityName': selection.cityName,
      'districtName': selection.districtName,
      'displayName': selection.displayName,
      'latitude': selection.latitude,
      'longitude': selection.longitude,
    };
  }

  ExhibitionHomeLocationSelectRequest? _manualSelectionFromObject(
    Object? value,
  ) {
    final payload = _mapFromObject(value);
    final provinceName = _stringFromObject(payload?['provinceName']);
    if (provinceName == null) {
      return null;
    }

    return ExhibitionHomeLocationSelectRequest(
      provinceCode: _stringFromObject(payload?['provinceCode']),
      provinceName: provinceName,
      cityName: _stringFromObject(payload?['cityName']),
      districtName: _stringFromObject(payload?['districtName']),
      displayName: _stringFromObject(payload?['displayName']),
      latitude: _doubleFromObject(payload?['latitude']),
      longitude: _doubleFromObject(payload?['longitude']),
    );
  }

  DeviceLocationPermissionState _permissionStateFromObject(Object? value) {
    return switch (_stringFromObject(value)) {
      'granted' => DeviceLocationPermissionState.granted,
      'denied' => DeviceLocationPermissionState.denied,
      'unavailable' => DeviceLocationPermissionState.unavailable,
      _ => DeviceLocationPermissionState.unknown,
    };
  }

  Map<String, Object?>? _mapFromObject(Object? value) {
    if (value is! Map<Object?, Object?>) {
      return null;
    }

    return value.map<String, Object?>(
      (Object? key, Object? value) =>
          MapEntry<String, Object?>(key.toString(), value),
    );
  }

  String? _stringFromObject(Object? value) {
    final normalized = value?.toString().trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  double? _doubleFromObject(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '');
  }
}
