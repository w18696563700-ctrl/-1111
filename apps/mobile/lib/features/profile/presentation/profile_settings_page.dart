part of 'profile_detail_pages.dart';

class ProfileSettingsPage extends StatelessWidget {
  const ProfileSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final shellContext = AppShellScope.of(context).snapshot.shellContext;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
      children: <Widget>[
        _ProfileHeaderPanel(
          title: '设置',
          subtitle: '保持当前账号、通知、隐私与显示设置简洁可用',
          detail: profileDisplayAccountLabel(shellContext.userId),
          avatarLabel: '设',
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
                  subtitle: '管理当前设备与安全状态',
                  onTap: () => Navigator.of(
                    context,
                  ).pushNamed(ProfileIdentityRoutes.sessionCenter),
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
                  onTap: () => Navigator.of(
                    context,
                  ).pushNamed(ProfileIdentityRoutes.certificationCurrent),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        _ProfileListSection(
          title: '通知',
          children: const <Widget>[
            _ProfileValueRow(title: '论坛互动提醒', value: '跟随系统'),
            _ProfileValueRow(title: '系统通知', value: '按设备设置'),
          ],
        ),
        const SizedBox(height: 14),
        _ProfileListSection(
          title: '隐私与权限',
          children: const <Widget>[
            _ProfileValueRow(title: '定位权限', value: '按系统授权'),
            _ProfileValueRow(title: '隐私与权限说明', value: '当前保持受控开放'),
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
          children: const <Widget>[
            _ProfileValueRow(title: '语言', value: '简体中文'),
            _ProfileValueRow(title: '清理缓存', value: '暂未单独开放'),
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
        const _ProfileListSection(
          title: '关于我们',
          children: <Widget>[
            _ProfileValueRow(title: '产品名称', value: '展览装修之家'),
            _ProfileValueRow(title: '当前版本', value: '开发中'),
          ],
        ),
      ],
    );
  }
}
