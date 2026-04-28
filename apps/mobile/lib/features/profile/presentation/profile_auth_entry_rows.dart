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

  return const <Widget>[_ProfileAuthEntryRowsBlock()];
}

class _ProfileAuthEntryRowsBlock extends StatefulWidget {
  const _ProfileAuthEntryRowsBlock();

  @override
  State<_ProfileAuthEntryRowsBlock> createState() =>
      _ProfileAuthEntryRowsBlockState();
}

class _ProfileAuthEntryRowsBlockState
    extends State<_ProfileAuthEntryRowsBlock> {
  _ProfileAuthEntryAction? _busyAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: <Widget>[
        _buildActionRow(_ProfileAuthEntryAction.switchAccount),
        Divider(height: 1, color: theme.colorScheme.outlineVariant),
        _buildActionRow(_ProfileAuthEntryAction.logout),
      ],
    );
  }

  Widget _buildActionRow(_ProfileAuthEntryAction action) {
    final busy = _busyAction == action;
    final disabled = _busyAction != null;
    final title = _profileAuthEntryTitle(action);
    return _ProfileActionRow(
      title: title,
      subtitle: _profileAuthEntrySubtitle(action),
      trailing: busy
          ? const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2.2),
            )
          : null,
      onTap: disabled ? null : () => _handleAction(action),
    );
  }

  Future<void> _handleAction(_ProfileAuthEntryAction action) async {
    final confirmed = await _confirmProfileAuthEntryAction(context, action);
    if (!confirmed || !mounted) {
      return;
    }

    setState(() {
      _busyAction = action;
    });

    final result = await AuthConsumerLayer.instance.logout();
    if (!mounted) {
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

    setState(() {
      _busyAction = null;
    });

    final actionLabel = _profileAuthEntryTitle(action);
    final message = authActionFailureMessage(
      result,
      kind: AuthActionKind.logout,
    );
    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(SnackBar(content: Text('$actionLabel未完成：$message')));
  }
}

Future<bool> _confirmProfileAuthEntryAction(
  BuildContext context,
  _ProfileAuthEntryAction action,
) async {
  final actionLabel = _profileAuthEntryTitle(action);
  final confirmLabel = switch (action) {
    _ProfileAuthEntryAction.logout => '退出登录',
    _ProfileAuthEntryAction.switchAccount => '退出并登录其他账号',
  };
  final result = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(actionLabel),
        content: const Text('会结束当前账号在本设备的登录状态，未提交的本地输入请先保存。'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return result == true;
}

String _profileAuthEntryTitle(_ProfileAuthEntryAction action) {
  return switch (action) {
    _ProfileAuthEntryAction.logout => '退出登录',
    _ProfileAuthEntryAction.switchAccount => '切换账号',
  };
}

String _profileAuthEntrySubtitle(_ProfileAuthEntryAction action) {
  return switch (action) {
    _ProfileAuthEntryAction.logout => '结束当前登录，并返回我的楼',
    _ProfileAuthEntryAction.switchAccount => '退出当前账号后，重新登录其他账号',
  };
}
