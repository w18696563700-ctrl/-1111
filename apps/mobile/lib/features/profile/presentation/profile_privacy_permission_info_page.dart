part of 'profile_detail_pages.dart';

class ProfilePrivacyPermissionInfoPage extends StatelessWidget {
  const ProfilePrivacyPermissionInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
      children: <Widget>[
        const _ProfileHeaderPanel(
          title: '隐私与权限说明',
          subtitle: '查看当前 App 使用的法律文书与系统权限范围',
          detail: '权限由设备系统授权管理，拒绝后不影响基础浏览。',
          avatarLabel: '隐',
        ),
        const SizedBox(height: 18),
        _ProfileListSection(
          title: '法律文书',
          children: <Widget>[
            _ProfileActionRow(
              title: '用户协议',
              subtitle: '查看账号使用、内容发布、平台规则等说明',
              leadingIcon: Icons.description_outlined,
              onTap: () => Navigator.of(
                context,
              ).pushNamed(ProfileIdentityRoutes.userAgreement),
            ),
            _ProfileActionRow(
              title: '隐私政策',
              subtitle: '查看个人信息处理、权限授权与联系方式',
              leadingIcon: Icons.policy_outlined,
              onTap: () => Navigator.of(
                context,
              ).pushNamed(ProfileIdentityRoutes.privacyPolicy),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const _ProfileListSection(
          title: '当前权限范围',
          children: <Widget>[
            _ProfileValueRow(
              title: '定位权限',
              value: '用于地区天气、地区选择辅助与本地化展示；设置页只读取授权状态，不采集坐标。',
            ),
            _ProfileValueRow(
              title: '图片与文件',
              value: '用于头像、证照、案例、论坛附件、项目附件等用户主动选择的文件。',
            ),
            _ProfileValueRow(
              title: '系统通知',
              value: '由设备系统统一管理；当前入口只跳转系统设置，不表示已接入完整推送链路。',
            ),
          ],
        ),
      ],
    );
  }
}
