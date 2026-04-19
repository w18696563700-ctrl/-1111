import 'dart:io';

import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'china_region_catalog.dart';

enum DeviceLocationPermissionState { unknown, granted, denied, unavailable }

extension DeviceLocationPermissionStateX on DeviceLocationPermissionState {
  String get contractName => switch (this) {
    DeviceLocationPermissionState.unknown => 'unknown',
    DeviceLocationPermissionState.granted => 'granted',
    DeviceLocationPermissionState.denied => 'denied',
    DeviceLocationPermissionState.unavailable => 'unavailable',
  };
}

class DeviceLocationSnapshot {
  const DeviceLocationSnapshot({
    required this.permissionState,
    this.latitude,
    this.longitude,
    this.provinceCode,
    this.provinceName,
    this.errorMessage,
  });

  final DeviceLocationPermissionState permissionState;
  final double? latitude;
  final double? longitude;
  final String? provinceCode;
  final String? provinceName;
  final String? errorMessage;

  bool get hasCoordinates => latitude != null && longitude != null;

  String get coordinatesLabel {
    if (!hasCoordinates) {
      return '设备位置未就绪';
    }

    final latitudeText = latitude!.toStringAsFixed(4);
    final longitudeText = longitude!.toStringAsFixed(4);
    return '$latitudeText, $longitudeText';
  }
}

abstract class DeviceLocationService {
  static DeviceLocationService _instance = GeolocatorDeviceLocationService();

  static DeviceLocationService get instance => _instance;

  static void install(DeviceLocationService service) {
    _instance = service;
  }

  static void reset() {
    _instance = GeolocatorDeviceLocationService();
  }

  bool get supportsDeviceLocation => false;

  bool get supportsReverseGeocoding => false;

  Future<DeviceLocationSnapshot> resolveCurrentPosition();
}

class GeolocatorDeviceLocationService implements DeviceLocationService {
  @override
  bool get supportsDeviceLocation => _supportsDeviceLocation();

  @override
  bool get supportsReverseGeocoding => _supportsReverseGeocoding();

  @override
  Future<DeviceLocationSnapshot> resolveCurrentPosition() async {
    if (!supportsDeviceLocation) {
      return const DeviceLocationSnapshot(
        permissionState: DeviceLocationPermissionState.unavailable,
        errorMessage: '当前平台暂不支持设备定位。',
      );
    }

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const DeviceLocationSnapshot(
          permissionState: DeviceLocationPermissionState.unavailable,
          errorMessage: '设备定位服务未开启。',
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      final permissionState = _mapPermissionState(permission);
      if (permissionState != DeviceLocationPermissionState.granted) {
        return DeviceLocationSnapshot(
          permissionState: permissionState,
          errorMessage: permission == LocationPermission.deniedForever
              ? '定位权限已被永久拒绝。'
              : '定位权限未授予。',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      final provinceScope = await _resolveProvinceScope(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      return DeviceLocationSnapshot(
        permissionState: DeviceLocationPermissionState.granted,
        latitude: position.latitude,
        longitude: position.longitude,
        provinceCode: provinceScope?.provinceCode,
        provinceName: provinceScope?.provinceName,
      );
    } on MissingPluginException {
      return const DeviceLocationSnapshot(
        permissionState: DeviceLocationPermissionState.unavailable,
        errorMessage: '当前环境未注册设备定位能力。',
      );
    } on PlatformException catch (error) {
      return DeviceLocationSnapshot(
        permissionState: DeviceLocationPermissionState.unavailable,
        errorMessage: error.message ?? '设备定位当前不可用。',
      );
    } on Exception {
      return const DeviceLocationSnapshot(
        permissionState: DeviceLocationPermissionState.unavailable,
        errorMessage: '设备定位当前不可用。',
      );
    }
  }

  bool _supportsDeviceLocation() {
    return Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
  }

  bool _supportsReverseGeocoding() {
    return Platform.isAndroid || Platform.isIOS;
  }

  DeviceLocationPermissionState _mapPermissionState(
    LocationPermission permission,
  ) {
    return switch (permission) {
      LocationPermission.always ||
      LocationPermission.whileInUse => DeviceLocationPermissionState.granted,
      LocationPermission.denied => DeviceLocationPermissionState.denied,
      LocationPermission.deniedForever =>
        DeviceLocationPermissionState.unavailable,
      LocationPermission.unableToDetermine =>
        DeviceLocationPermissionState.unknown,
    };
  }

  Future<_DeviceProvinceScope?> _resolveProvinceScope({
    required double latitude,
    required double longitude,
  }) async {
    if (!supportsReverseGeocoding) {
      return null;
    }

    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      return _provinceScopeFromPlacemarks(placemarks);
    } on Object {
      return null;
    }
  }

  Future<_DeviceProvinceScope?> _provinceScopeFromPlacemarks(
    List<Placemark> placemarks,
  ) async {
    if (placemarks.isEmpty) {
      return null;
    }

    final catalog = await ChinaRegionCatalogLoader.load();
    for (final placemark in placemarks) {
      final city =
          catalog.cityByName(placemark.locality) ??
          catalog.cityByName(placemark.subAdministrativeArea) ??
          catalog.cityByName(placemark.subLocality);
      if (city != null) {
        return _DeviceProvinceScope(
          provinceCode: city.provinceCode,
          provinceName: city.provinceName,
        );
      }

      final province = _matchProvinceByName(
        catalog,
        placemark.administrativeArea,
      );
      if (province != null) {
        return _DeviceProvinceScope(
          provinceCode: province.provinceCode,
          provinceName: province.provinceName,
        );
      }

      final administrativeArea = _normalizedRegionName(
        placemark.administrativeArea,
      );
      if (administrativeArea != null) {
        return _DeviceProvinceScope(provinceName: administrativeArea);
      }
    }

    return null;
  }

  ChinaProvinceOption? _matchProvinceByName(
    ChinaRegionCatalog catalog,
    String? rawProvinceName,
  ) {
    final normalized = _normalizedRegionName(rawProvinceName);
    if (normalized == null) {
      return null;
    }

    for (final province in catalog.provinces) {
      if (_normalizedRegionName(province.provinceName) == normalized ||
          _normalizedRegionName(chinaRegionShortName(province.provinceName)) ==
              normalized) {
        return province;
      }
    }
    return null;
  }

  String? _normalizedRegionName(String? value) {
    if (value == null) {
      return null;
    }

    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed.replaceAll(' ', '');
  }
}

class _DeviceProvinceScope {
  const _DeviceProvinceScope({this.provinceCode, this.provinceName});

  final String? provinceCode;
  final String? provinceName;
}
