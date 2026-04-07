part of 'profile_detail_pages.dart';

class ProfilePersonalPage extends StatelessWidget {
  const ProfilePersonalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final shellContext = AppShellScope.of(context).snapshot.shellContext;
    if (!AppSessionStore.instance.hasAnySession) {
      return _ProfileScreenStatePanel(
        title: '当前会话暂不可用',
        message: '当前没有可验证的会话，个人资料页不展示伪造账号信息。',
        actionLabel: '进入登录入口',
        onAction: () =>
            Navigator.of(context).pushNamed(ProfileIdentityRoutes.login),
      );
    }
    if ((shellContext.userId?.trim().isEmpty ?? true)) {
      return _ProfileScreenStatePanel(
        title: '当前账号上下文暂不可用',
        message: '当前会话尚未返回可消费账号上下文，个人资料页先停留在受控状态。',
        actionLabel: '返回我的楼',
        onAction: () => Navigator.of(context).pushNamed('/profile'),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
      children: <Widget>[
        _ProfileHeaderPanel(
          title: profileResolvedDisplayName(
            displayName: shellContext.displayName,
            rawUserId: shellContext.userId,
          ),
          subtitle: profileDisplayAccountLabel(shellContext.userId),
          detail:
              '${profileDisplayCertificationStatus(shellContext.certificationStatus)} · '
              '${profileDisplayMembershipStatus(shellContext.membershipStatus)}',
          avatarLabel: profileResolvedAvatarFallbackLabel(
            displayName: shellContext.displayName,
            rawUserId: shellContext.userId,
          ),
          avatarUrl: profileResolvedAvatarUrl(shellContext.avatarUrl),
          badgeText: '个人资料',
          supportingText: '当前只展示资料摘要；头像和昵称请通过下方两项单独设置。',
        ),
        const SizedBox(height: 18),
        _ProfileCompactCard(
          children: <Widget>[
            _ProfileActionRow(
              title: '头像',
              subtitle: profileResolvedAvatarUrl(shellContext.avatarUrl) == null
                  ? '当前未设置头像，点击进入个人头像'
                  : '查看当前个人头像并继续更换',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ProfileAvatarBadge(
                    avatarUrl: shellContext.avatarUrl,
                    fallbackLabel: profileResolvedAvatarFallbackLabel(
                      displayName: shellContext.displayName,
                      rawUserId: shellContext.userId,
                    ),
                    semanticLabel:
                        profileResolvedAvatarUrl(shellContext.avatarUrl) == null
                        ? '头像缩略图未设置'
                        : '头像缩略图已设置',
                    size: 32,
                    textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
              onTap: () => openProfilePersonalAvatarPage(context),
            ),
            _ProfileActionRow(
              title: '昵称',
              subtitle: '仅支持 1~10 个中文汉字',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 120),
                    child: Text(
                      profileResolvedNickname(shellContext.displayName),
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
              onTap: () => openProfilePersonalNicknamePage(context),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const _ProfileListSection(
          title: '资料审核提示',
          children: <Widget>[
            _ProfileValueRow(
              title: '先审后显',
              value: '新提交内容审核中时，当前公开显示仍为已通过资料；审核通过后才会替换。拒绝会展示原因并可重新提交。',
            ),
            _ProfileValueRow(
              title: '简介规则提示',
              value: '简介编辑入口当前未开放；后续提交须遵守 P0 规则，禁止联系方式、引流、保留词与违法低俗明显词。',
            ),
          ],
        ),
        const SizedBox(height: 14),
        _ProfileListSection(
          title: '资料摘要',
          children: <Widget>[
            _ProfileValueRow(
              title: '当前账号',
              value: profileDisplayAccountLabel(shellContext.userId),
            ),
            _ProfileActionRow(
              title: '我的公司',
              subtitle: '查看我的公司，并继续进入公司与组织',
              onTap: () =>
                  Navigator.of(context).pushNamed(ProfileRoutes.company),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _ProfileListSection(
          title: '身份与安全',
          children: <Widget>[
            _ProfileActionRow(
              title: '公司认证与我的身份',
              subtitle:
                  '${profileDisplayCertificationStatus(shellContext.certificationStatus)} · ${profileDisplayMembershipStatus(shellContext.membershipStatus)}',
              onTap: () => Navigator.of(
                context,
              ).pushNamed(ProfileIdentityRoutes.certificationCurrent),
            ),
            _ProfileValueRow(
              title: '成员身份',
              value: profileDisplayMembershipStatus(
                shellContext.membershipStatus,
              ),
            ),
            _ProfileActionRow(
              title: '会话与设备',
              subtitle: '管理当前登录设备与安全状态',
              onTap: () => Navigator.of(
                context,
              ).pushNamed(ProfileIdentityRoutes.sessionCenter),
            ),
            _ProfileActionRow(
              title: '登录入口',
              subtitle: shellContext.userId == null ? '去登录' : '切换或恢复登录',
              onTap: () =>
                  Navigator.of(context).pushNamed(ProfileIdentityRoutes.login),
            ),
          ],
        ),
      ],
    );
  }
}
