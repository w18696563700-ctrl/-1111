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
        const SizedBox(height: 14),
        _ProfileListSection(
          title: '客服、注销与上架说明',
          children: <Widget>[
            _ProfileActionRow(
              title: '客服与投诉',
              subtitle: '客服邮箱：182401625@qq.com；客服电话暂未公示',
              leadingIcon: Icons.support_agent_outlined,
              onTap: () => _showProfileComplianceInfoSheet(
                context,
                title: '客服与投诉',
                message:
                    '如需咨询产品服务、账号登录、企业认证、举报处理、隐私权利或投诉事项，请通过客服邮箱 182401625@qq.com 联系平台。',
              ),
            ),
            _ProfileActionRow(
              title: '账号注销 / 删除账号',
              subtitle: '通过客服邮箱受理申请；不承诺一键自助注销',
              leadingIcon: Icons.delete_outline_rounded,
              onTap: () => _showProfileComplianceInfoSheet(
                context,
                title: '账号注销 / 删除账号受理说明',
                message:
                    '当前阶段不提供一键自助注销。你可以通过客服邮箱 182401625@qq.com 提交账号注销或个人信息删除申请；平台会先核验身份、处理未完结项目/举报/争议/合规留痕，再在符合法律法规和平台规则的范围内处理。',
              ),
            ),
            const _ProfileValueRow(
              title: 'SDK 与第三方能力',
              value:
                  '当前说明覆盖短信、图片/文件选择、图片裁剪、定位/地理编码、对象存储、OCR 与支付唤起等能力；正式上架前需与应用商店 SDK 清单逐项核对。',
            ),
            const _ProfileValueRow(
              title: '支付说明',
              value: '如页面出现支付、预授权或诚意金说明，以对应项目页面和平台规则展示为准；设置页不发起支付，也不修改资金真值。',
            ),
          ],
        ),
      ],
    );
  }
}

Future<void> _showProfileComplianceInfoSheet(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: Theme.of(
                  sheetContext,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Text(message, style: Theme.of(sheetContext).textTheme.bodyMedium),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: const Text('我知道了'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
