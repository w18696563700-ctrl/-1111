part of 'profile_detail_pages.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage>
    with WidgetsBindingObserver {
  DeviceLocationPermissionSnapshot? _locationPermissionStatus;
  bool _locationPermissionLoading = false;
  AppRuntimeInfo? _runtimeInfo;
  bool _runtimeInfoLoading = false;
  bool _cacheCleaning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_refreshLocationPermissionStatus());
    unawaited(_refreshRuntimeInfo());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshLocationPermissionStatus());
    }
  }

  @override
  Widget build(BuildContext context) {
    final shellSnapshot = AppShellScope.of(context).snapshot;
    final shellContext = shellSnapshot.shellContext;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
      children: <Widget>[
        AnimatedBuilder(
          animation: AppSessionStore.instance,
          builder: (BuildContext context, Widget? child) {
            return _ProfileHeaderPanel(
              title: '设置',
              subtitle: '保持当前账号、通知、隐私与显示设置简洁可用',
              detail: _profileSettingsAccountStatusLabel(shellSnapshot),
              avatarLabel: '设',
            );
          },
        ),
        if (profileFeatureStatusVisible) ...<Widget>[
          const SizedBox(height: 18),
          const ProfileFeatureStatusCard(
            snapshot: profileSettingsFeatureStatus,
          ),
          const SizedBox(height: 14),
        ] else
          const SizedBox(height: 18),
        AnimatedBuilder(
          animation: AppSessionStore.instance,
          builder: (BuildContext context, Widget? child) {
            return _ProfileListSection(
              title: '账号与安全',
              children: <Widget>[
                ..._buildProfilePasswordSetupEntryRows(context),
                ..._buildProfileAuthEntryRows(context),
                _ProfileActionRow(
                  title: '会话与设备',
                  subtitle: _profileSettingsSessionSummary(
                    AppSessionStore.instance.snapshot,
                  ),
                  leadingIcon: Icons.devices_other_outlined,
                  onTap: () => Navigator.of(
                    context,
                  ).pushNamed(ProfileRoutes.sessionDeviceStatus),
                ),
                _ProfileActionRow(
                  title: '公司认证与我的身份',
                  subtitle: profileDisplayCertificationIdentitySummary(
                    certificationStatus: shellContext.certificationStatus,
                    personalCertificationStatus:
                        shellContext.personalCertificationStatus,
                    personalCertificationQualified:
                        shellContext.personalCertificationQualified,
                    personalCertificationLockedToOtherActor:
                        shellContext.personalCertificationLockedToOtherActor,
                    membershipStatus: shellContext.membershipStatus,
                  ),
                  leadingIcon: Icons.verified_user_outlined,
                  onTap: () => Navigator.of(
                    context,
                  ).pushNamed(ProfileRoutes.certificationIdentityStatus),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        _ProfileListSection(
          title: '通知',
          children: <Widget>[
            const _ProfileValueRow(title: '论坛互动提醒', value: '跟随系统通知设置'),
            _ProfileActionRow(
              title: '系统通知',
              subtitle: '由设备系统控制，点此打开应用通知设置',
              leadingIcon: Icons.notifications_outlined,
              onTap: _openSystemNotificationSettings,
            ),
          ],
        ),
        const SizedBox(height: 14),
        _ProfileListSection(
          title: '隐私与权限',
          children: <Widget>[
            _ProfileActionRow(
              title: '定位权限',
              subtitle: _locationPermissionStatusLabel(
                _locationPermissionStatus,
                loading: _locationPermissionLoading,
              ),
              leadingIcon: Icons.location_on_outlined,
              trailing: _locationPermissionLoading
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.2),
                    )
                  : null,
              onTap: _showLocationPermissionActions,
            ),
            _ProfileActionRow(
              title: '隐私与权限说明',
              subtitle: '查看用户协议、隐私政策与当前权限使用范围',
              leadingIcon: Icons.privacy_tip_outlined,
              onTap: () => Navigator.of(
                context,
              ).pushNamed(ProfileRoutes.privacyPermissions),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _ProfileListSection(
          title: '界面与显示',
          children: const <Widget>[
            _ProfileValueRow(title: '界面风格', value: '跟随系统'),
            _ProfileValueRow(title: '文字与显示', value: '标准'),
          ],
        ),
        const SizedBox(height: 14),
        _ProfileListSection(
          title: '通用',
          children: <Widget>[
            const _ProfileValueRow(title: '语言', value: '简体中文'),
            _ProfileActionRow(
              title: '清理缓存',
              subtitle: _cacheCleaning ? '正在清理安全缓存' : '清理图片缓存与临时预览文件',
              leadingIcon: Icons.cleaning_services_outlined,
              trailing: _cacheCleaning
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.2),
                    )
                  : null,
              onTap: _cacheCleaning ? null : _confirmAndClearCache,
            ),
          ],
        ),
        const SizedBox(height: 14),
        _ProfileListSection(
          title: '存储空间',
          children: const <Widget>[
            _ProfileValueRow(title: '草稿与附件缓存', value: '按系统回收'),
          ],
        ),
        const SizedBox(height: 14),
        _ProfileListSection(
          title: '关于我们',
          children: <Widget>[
            const _ProfileValueRow(title: '产品名称', value: '展览装修之家'),
            _ProfileActionRow(
              title: '当前版本',
              subtitle: _profileSettingsVersionSummary(
                _runtimeInfo,
                loading: _runtimeInfoLoading,
              ),
              leadingIcon: Icons.info_outline_rounded,
              onTap: () =>
                  Navigator.of(context).pushNamed(ProfileRoutes.versionInfo),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _refreshLocationPermissionStatus() async {
    if (_locationPermissionLoading) {
      return;
    }
    setState(() {
      _locationPermissionLoading = true;
    });

    final status = await DeviceLocationService.instance.readPermissionStatus();
    if (!mounted) {
      return;
    }

    setState(() {
      _locationPermissionStatus = status;
      _locationPermissionLoading = false;
    });
  }

  Future<void> _refreshRuntimeInfo() async {
    if (_runtimeInfoLoading) {
      return;
    }
    setState(() {
      _runtimeInfoLoading = true;
    });

    final runtimeInfo = await AppRuntimeInfoService.instance.load();
    if (!mounted) {
      return;
    }

    setState(() {
      _runtimeInfo = runtimeInfo;
      _runtimeInfoLoading = false;
    });
  }

  Future<void> _confirmAndClearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('清理缓存'),
          content: const Text('只清理图片缓存和临时预览文件，不会退出登录，也不会删除草稿、附件或用户资料。'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('确认清理'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _cacheCleaning = true;
    });

    final result = await LocalCacheCleanupService.instance
        .clearSafeLocalCache();
    if (!mounted) {
      return;
    }

    setState(() {
      _cacheCleaning = false;
    });
    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(SnackBar(content: Text(result.summary)));
  }

  Future<void> _showLocationPermissionActions() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
            children: <Widget>[
              ListTile(
                title: const Text('定位权限'),
                subtitle: Text(
                  _locationPermissionStatusLabel(
                    _locationPermissionStatus,
                    loading: _locationPermissionLoading,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.refresh_rounded),
                title: const Text('刷新状态'),
                subtitle: const Text('只读取系统授权状态，不申请权限、不采集位置'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  unawaited(_refreshLocationPermissionStatus());
                },
              ),
              ListTile(
                leading: const Icon(Icons.app_settings_alt_outlined),
                title: const Text('打开应用权限设置'),
                subtitle: const Text('到系统应用设置中调整定位等权限'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  unawaited(_openAppPermissionSettings());
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('打开系统定位设置'),
                subtitle: const Text('到系统设置中开启或关闭设备定位服务'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  unawaited(_openSystemLocationSettings());
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openSystemNotificationSettings() async {
    final opened = await DeviceLocationService.instance
        .openAppPermissionSettings();
    if (!mounted) {
      return;
    }
    _showSettingsOpenResult(
      opened: opened,
      successMessage: '已打开系统应用设置，请在通知权限中查看或调整。',
      failureMessage: '当前环境暂不能打开系统应用设置。',
    );
    unawaited(_refreshLocationPermissionStatus());
  }

  Future<void> _openAppPermissionSettings() async {
    final opened = await DeviceLocationService.instance
        .openAppPermissionSettings();
    if (!mounted) {
      return;
    }
    _showSettingsOpenResult(
      opened: opened,
      successMessage: '已打开应用权限设置。',
      failureMessage: '当前环境暂不能打开应用权限设置。',
    );
    unawaited(_refreshLocationPermissionStatus());
  }

  Future<void> _openSystemLocationSettings() async {
    final opened = await DeviceLocationService.instance
        .openSystemLocationSettings();
    if (!mounted) {
      return;
    }
    _showSettingsOpenResult(
      opened: opened,
      successMessage: '已打开系统定位设置。',
      failureMessage: '当前环境暂不能打开系统定位设置。',
    );
    unawaited(_refreshLocationPermissionStatus());
  }

  void _showSettingsOpenResult({
    required bool opened,
    required String successMessage,
    required String failureMessage,
  }) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text(opened ? successMessage : failureMessage)),
    );
  }
}
