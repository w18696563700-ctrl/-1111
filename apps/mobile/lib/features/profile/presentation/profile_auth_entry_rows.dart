part of 'profile_detail_pages.dart';

enum _ProfileAuthEntryAction { logout, switchAccount }

List<Widget> _buildProfilePasswordSetupEntryRows(BuildContext context) {
  if (!AppSessionStore.instance.shouldShowPasswordSetupPrompt) {
    return <Widget>[];
  }

  return <Widget>[
    _ProfileActionRow(
      title: '设置登录密码',
      subtitle: '补齐账号密码登录能力，之后可直接使用账号密码登录',
      emphasized: true,
      leadingIcon: Icons.lock_outline_rounded,
      onTap: () =>
          Navigator.of(context).pushNamed(ProfileIdentityRoutes.passwordSet),
    ),
  ];
}

List<Widget> _buildProfileAuthEntryRows(BuildContext context) {
  if (!AppSessionStore.instance.hasAnySession) {
    return <Widget>[
      _ProfileActionRow(
        title: '登录入口',
        subtitle: '去登录',
        onTap: () =>
            Navigator.of(context).pushNamed(ProfileIdentityRoutes.login),
      ),
    ];
  }

  return <Widget>[
    _ProfileActionRow(
      title: '切换账号',
      subtitle: '退出当前账号后，重新登录其他账号',
      onTap: () => _handleProfileAuthEntryAction(
        context,
        _ProfileAuthEntryAction.switchAccount,
      ),
    ),
    _ProfileActionRow(
      title: '退出登录',
      subtitle: '结束当前登录，并返回我的楼',
      onTap: () => _handleProfileAuthEntryAction(
        context,
        _ProfileAuthEntryAction.logout,
      ),
    ),
  ];
}

Future<void> _handleProfileAuthEntryAction(
  BuildContext context,
  _ProfileAuthEntryAction action,
) async {
  final result = await AuthConsumerLayer.instance.logout();
  if (!context.mounted) {
    return;
  }

  if (result.state == AppPageState.content ||
      result.state == AppPageState.unauthorized) {
    AppShellScope.read(context).handleLoggedOut();
    final targetRoute = switch (action) {
      _ProfileAuthEntryAction.logout => AppBuilding.profile.routePath,
      _ProfileAuthEntryAction.switchAccount => ProfileIdentityRoutes.login,
    };
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(targetRoute, (Route<dynamic> route) => false);
    return;
  }

  final actionLabel = switch (action) {
    _ProfileAuthEntryAction.logout => '退出登录',
    _ProfileAuthEntryAction.switchAccount => '切换账号',
  };
  final message = authActionFailureMessage(result, kind: AuthActionKind.logout);
  ScaffoldMessenger.maybeOf(
    context,
  )?.showSnackBar(SnackBar(content: Text('$actionLabel未完成：$message')));
}
