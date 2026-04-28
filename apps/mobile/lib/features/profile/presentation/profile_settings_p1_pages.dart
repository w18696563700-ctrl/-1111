part of 'profile_detail_pages.dart';

class ProfileCertificationIdentityStatusPage extends StatelessWidget {
  const ProfileCertificationIdentityStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final shellContext = AppShellScope.of(context).snapshot.shellContext;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
      children: <Widget>[
        _ProfileHeaderPanel(
          title: '公司认证与我的身份',
          subtitle: '当前只展示状态，不在设置页展开认证办理',
          detail: profileDisplayCertificationIdentitySummary(
            certificationStatus: shellContext.certificationStatus,
            personalCertificationStatus:
                shellContext.personalCertificationStatus,
            personalCertificationQualified:
                shellContext.personalCertificationQualified,
            personalCertificationLockedToOtherActor:
                shellContext.personalCertificationLockedToOtherActor,
            membershipStatus: shellContext.membershipStatus,
          ),
          avatarLabel: '证',
        ),
        const SizedBox(height: 18),
        _ProfileListSection(
          title: '当前状态',
          children: <Widget>[
            _ProfileValueRow(
              title: '企业认证',
              value: profileDisplayCertificationStatus(
                shellContext.certificationStatus,
              ),
            ),
            _ProfileValueRow(
              title: '我的认证',
              value: _profileSettingsPersonalCertificationStatus(shellContext),
            ),
            _ProfileValueRow(
              title: '成员身份',
              value: profileDisplayMembershipStatus(
                shellContext.membershipStatus,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const _ProfileListSection(
          title: '状态来源',
          children: <Widget>[
            _ProfileValueRow(
              title: '展示口径',
              value: '来自当前 shell context；缺少字段时显示状态待确认。',
            ),
            _ProfileValueRow(title: '本轮边界', value: '设置页不展开认证提交、重提、审核或 OCR 流程。'),
          ],
        ),
      ],
    );
  }
}

class ProfileSessionDeviceStatusPage extends StatelessWidget {
  const ProfileSessionDeviceStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSessionStore.instance,
      builder: (BuildContext context, Widget? child) {
        final snapshot = AppSessionStore.instance.snapshot;
        final hasSession = AppSessionStore.instance.hasAnySession;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
          children: <Widget>[
            _ProfileHeaderPanel(
              title: '会话与设备',
              subtitle: '当前仅展示本机登录状态',
              detail: hasSession ? '本机存在登录态' : '当前没有本地会话',
              avatarLabel: '设',
            ),
            const SizedBox(height: 18),
            _ProfileListSection(
              title: '本机信息',
              children: <Widget>[
                _ProfileValueRow(
                  title: '设备标识',
                  value: _profileSettingsMaskedDeviceId(snapshot.deviceId),
                ),
                _ProfileValueRow(
                  title: '登录来源',
                  value: _profileSettingsLoginSourceLabel(
                    snapshot.localLoginSource,
                  ),
                ),
                _ProfileValueRow(
                  title: '登录凭证',
                  value: snapshot.hasAccessToken ? '已建立' : '未建立',
                ),
                _ProfileValueRow(
                  title: '续期状态',
                  value: snapshot.hasRefreshToken ? '可续期' : '不可续期',
                ),
                _ProfileValueRow(
                  title: '有效期',
                  value: _profileSettingsSessionExpiryLabel(snapshot.expiresAt),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const _ProfileListSection(
              title: '安全操作',
              children: <Widget>[
                _ProfileValueRow(title: '其他设备', value: '暂不展示。'),
                _ProfileValueRow(title: '退出登录', value: '请在设置页完成二次确认。'),
              ],
            ),
          ],
        );
      },
    );
  }
}

class ProfileVersionInfoPage extends StatefulWidget {
  const ProfileVersionInfoPage({super.key});

  @override
  State<ProfileVersionInfoPage> createState() => _ProfileVersionInfoPageState();
}

class _ProfileVersionInfoPageState extends State<ProfileVersionInfoPage> {
  AppRuntimeInfo? _runtimeInfo;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final runtimeInfo = await AppRuntimeInfoService.instance.load();
    if (!mounted) {
      return;
    }
    setState(() {
      _runtimeInfo = runtimeInfo;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final info = _runtimeInfo;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
      children: <Widget>[
        _ProfileHeaderPanel(
          title: '当前版本',
          subtitle: '查看当前应用版本与运行入口',
          detail: _profileSettingsVersionSummary(info, loading: _loading),
          avatarLabel: '版',
        ),
        const SizedBox(height: 18),
        if (info == null)
          const _ProfileListSection(
            title: '版本信息',
            children: <Widget>[
              _ProfileValueRow(title: '读取状态', value: '正在读取当前版本信息'),
            ],
          )
        else ...<Widget>[
          _ProfileListSection(
            title: '应用信息',
            children: <Widget>[
              _ProfileValueRow(title: '产品名称', value: info.appName),
              _ProfileValueRow(title: '包名', value: info.packageName),
              _ProfileValueRow(title: '版本号', value: info.version),
              _ProfileValueRow(title: '构建号', value: info.buildNumber),
            ],
          ),
          const SizedBox(height: 14),
          _ProfileListSection(
            title: '运行态',
            children: <Widget>[
              _ProfileValueRow(title: '环境', value: info.environmentLabel),
              _ProfileValueRow(title: '入口模式', value: info.entryModeLabel),
              _ProfileValueRow(title: 'API 入口', value: info.apiBaseSummary),
              _ProfileValueRow(title: '构建模式', value: info.debugModeLabel),
            ],
          ),
        ],
      ],
    );
  }
}

String _profileSettingsPersonalCertificationStatus(
  AppShellContextData shellContext,
) {
  if (shellContext.personalCertificationLockedToOtherActor == true) {
    return '已锁定其他账号';
  }
  if (shellContext.personalCertificationQualified == true) {
    return '已通过';
  }
  return profileDisplayCertificationStatus(
    shellContext.personalCertificationStatus,
  );
}

String _profileSettingsSessionSummary(AppSessionSnapshot snapshot) {
  if (!AppSessionStore.instance.hasAnySession) {
    return '当前未登录';
  }
  return '${_profileSettingsLoginSourceLabel(snapshot.localLoginSource)} · '
      '${snapshot.deviceId == null ? '设备未生成' : '当前设备已建立'}';
}

String _profileSettingsLoginSourceLabel(String? source) {
  return switch (source?.trim()) {
    AppSessionLoginSource.otpLogin => '验证码登录',
    AppSessionLoginSource.passwordLogin => '账号密码登录',
    null || '' => '登录来源待确认',
    _ => '登录来源待确认',
  };
}

String _profileSettingsMaskedDeviceId(String? deviceId) {
  final value = deviceId?.trim();
  if (value == null || value.isEmpty) {
    return '未生成';
  }
  if (value.length <= 10) {
    return value;
  }
  return '${value.substring(0, 6)}…${value.substring(value.length - 4)}';
}

String _profileSettingsSessionExpiryLabel(DateTime? expiresAt) {
  if (expiresAt == null) {
    return '待确认';
  }
  final now = DateTime.now();
  if (!expiresAt.isAfter(now)) {
    return '已过期';
  }
  final minutes = expiresAt.difference(now).inMinutes;
  if (minutes <= 1) {
    return '1 分钟内到期';
  }
  if (minutes < 60) {
    return '约 $minutes 分钟后到期';
  }
  return '约 ${minutes ~/ 60} 小时后到期';
}

String _profileSettingsVersionSummary(
  AppRuntimeInfo? info, {
  required bool loading,
}) {
  if (info == null) {
    return loading ? '正在读取版本信息' : '版本信息待确认';
  }
  return '${info.versionSummary} · ${info.environmentLabel}';
}
