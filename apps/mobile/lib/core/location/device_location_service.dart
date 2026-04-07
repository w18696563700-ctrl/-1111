import 'dart:io';

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

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
    this.errorMessage,
  });

  final DeviceLocationPermissionState permissionState;
  final double? latitude;
  final double? longitude;
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

  Future<DeviceLocationSnapshot> resolveCurrentPosition();
}

class GeolocatorDeviceLocationService implements DeviceLocationService {
  @override
  Future<DeviceLocationSnapshot> resolveCurrentPosition() async {
    if (!_supportsDeviceLocation()) {
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

      return DeviceLocationSnapshot(
        permissionState: DeviceLocationPermissionState.granted,
        latitude: position.latitude,
        longitude: position.longitude,
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
}
