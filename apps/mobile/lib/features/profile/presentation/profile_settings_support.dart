part of 'profile_detail_pages.dart';

String _profileSettingsAccountStatusLabel(AppShellContextSnapshot snapshot) {
  if (!AppSessionStore.instance.hasAnySession ||
      snapshot.blockingState == GlobalShellState.unauthenticated) {
    return '当前账号：未登录';
  }

  if (snapshot.blockingState == GlobalShellState.sessionRefreshing) {
    return '当前账号：刷新中';
  }

  final userId = snapshot.shellContext.userId;
  if (userId != null && userId.trim().isNotEmpty) {
    return profileDisplayAccountLabel(userId);
  }

  return '当前账号：已登录';
}

String _locationPermissionStatusLabel(
  DeviceLocationPermissionSnapshot? status, {
  required bool loading,
}) {
  if (loading && status == null) {
    return '正在读取系统授权状态';
  }
  if (status == null) {
    return '点击读取系统授权状态';
  }

  final message = status.message?.trim();
  if (message != null && message.isNotEmpty) {
    return message;
  }

  if (status.serviceEnabled == false) {
    return '设备定位服务未开启。';
  }

  return switch (status.permissionState) {
    DeviceLocationPermissionState.granted => '定位权限已开启。',
    DeviceLocationPermissionState.denied => '定位权限未授予。',
    DeviceLocationPermissionState.unknown => '定位权限状态暂未确定。',
    DeviceLocationPermissionState.unavailable => '设备定位权限状态当前不可用。',
  };
}
