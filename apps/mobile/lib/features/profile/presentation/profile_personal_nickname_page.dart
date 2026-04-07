part of 'profile_detail_pages.dart';

class ProfilePersonalNicknameRoutePage extends StatefulWidget {
  const ProfilePersonalNicknameRoutePage({super.key});

  @override
  State<ProfilePersonalNicknameRoutePage> createState() =>
      _ProfilePersonalNicknameRoutePageState();
}

class _ProfilePersonalNicknameRoutePageState
    extends State<ProfilePersonalNicknameRoutePage> {
  late final TextEditingController _controller;
  bool _submitting = false;
  String? _statusTitle;
  String? _statusMessage;
  String? _statusSubmittedNickname;
  ProfilePersonalSafetySubmissionView? _statusSubmission;

  @override
  void initState() {
    super.initState();
    final initialNickname =
        AppShellScope.read(context).snapshot.shellContext.displayName ?? '';
    _controller = TextEditingController(text: initialNickname.trim());
    _controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shellContext = AppShellScope.of(context).snapshot.shellContext;
    final hasSession = AppSessionStore.instance.hasAnySession;
    final initialNickname = shellContext.displayName?.trim() ?? '';
    final validationError = profileNicknameValidationError(_controller.text);
    final canSubmit =
        hasSession &&
        !_submitting &&
        profileNicknameSubmitEnabled(
          candidate: _controller.text,
          initialDisplayName: initialNickname,
        );

    return AppShellScaffold(
      currentBuilding: AppBuilding.profile,
      titleOverride: '设置昵称',
      showStageBanner: false,
      child: !hasSession
          ? _ProfileScreenStatePanel(
              title: '当前会话暂不可用',
              message: '当前没有可验证的会话，设置昵称页不会伪装成已保存成功。',
              actionLabel: '进入登录入口',
              onAction: () =>
                  Navigator.of(context).pushNamed(ProfileIdentityRoutes.login),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              children: <Widget>[
                _ProfileCompactCard(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: TextField(
                        controller: _controller,
                        maxLength: 10,
                        decoration: const InputDecoration(
                          labelText: '昵称',
                          hintText: '请输入昵称',
                          counterText: '',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _ProfileCompactCard(
                  children: <Widget>[
                    _ProfileValueRow(
                      title: '当前公开显示',
                      value:
                          '当前公开显示仍为已通过资料：${profileResolvedNickname(shellContext.displayName)}',
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _ProfileCompactCard(
                  children: <Widget>[
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      title: const Text('规则提示'),
                      subtitle: Text(
                        validationError ??
                            '昵称仅支持 1~10 个中文汉字；提交会进行 P0 规则校验，禁止联系方式、保留词、违法低俗明显词与异常字符。审核通过后才会替换当前公开昵称。',
                      ),
                    ),
                  ],
                ),
                if (_statusSubmission != null) ...<Widget>[
                  const SizedBox(height: 14),
                  _ProfilePersonalSafetyStatusCard(
                    fieldLabel: '昵称',
                    currentApprovedValue: profileResolvedNickname(
                      shellContext.displayName,
                    ),
                    pendingValue:
                        _statusSubmission!.pendingNickname ??
                        _statusSubmittedNickname,
                    submission: _statusSubmission!,
                  ),
                ],
                if (_statusTitle != null && _statusMessage != null) ...<Widget>[
                  const SizedBox(height: 14),
                  _ProfileCompactCard(
                    children: <Widget>[
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        title: Text(_statusTitle!),
                        subtitle: Text(_statusMessage!),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: canSubmit ? _submit : null,
                  child: Text(_submitting ? '保存中' : '完成'),
                ),
              ],
            ),
    );
  }

  Future<void> _submit() async {
    final nickname = _controller.text.trim();
    final validationError = profileNicknameValidationError(_controller.text);
    if (validationError != null) {
      setState(() {
        _statusTitle = '昵称当前不可保存';
        _statusMessage = validationError;
      });
      return;
    }

    final previousDisplayName =
        AppShellScope.read(context).snapshot.shellContext.displayName?.trim() ??
        '';
    setState(() {
      _submitting = true;
      _statusTitle = null;
      _statusMessage = null;
      _statusSubmittedNickname = null;
      _statusSubmission = null;
    });

    final result = await ProfilePersonalEditConsumerLayer.instance
        .updateNickname(nickname: nickname);
    if (!mounted) {
      return;
    }
    if (result.state != AppPageState.content || result.data == null) {
      setState(() {
        _submitting = false;
        _statusTitle = '昵称当前未保存';
        _statusMessage = result.message ?? '当前设置昵称失败，请稍后再试。';
      });
      return;
    }

    final safetySubmission = result.data!.safetySubmission;
    if (safetySubmission != null &&
        !profilePersonalSafetyStateUsesApprovedReadback(
          safetySubmission.uiState,
        )) {
      await _handleNicknameSafetySubmission(
        nickname: nickname,
        previousDisplayName: previousDisplayName,
        safetySubmission: safetySubmission,
      );
      return;
    }

    await AppShellScope.read(context).reloadShellContext();
    if (!mounted) {
      return;
    }
    final reloadedDisplayName =
        AppShellScope.read(context).snapshot.shellContext.displayName?.trim() ??
        '';
    if (reloadedDisplayName != nickname ||
        reloadedDisplayName == previousDisplayName) {
      setState(() {
        _submitting = false;
        _statusTitle = '昵称回读当前未更新';
        _statusMessage = '当前昵称写入虽已返回，但正式回读仍未更新，页面保持受控失败。';
      });
      return;
    }

    Navigator.of(context).pop(true);
  }

  Future<void> _handleNicknameSafetySubmission({
    required String nickname,
    required String previousDisplayName,
    required ProfilePersonalSafetySubmissionView safetySubmission,
  }) async {
    await AppShellScope.read(context).reloadShellContext();
    if (!mounted) {
      return;
    }
    final reloadedDisplayName =
        AppShellScope.read(context).snapshot.shellContext.displayName?.trim() ??
        '';
    if (reloadedDisplayName == nickname && previousDisplayName != nickname) {
      setState(() {
        _submitting = false;
        _statusTitle = '昵称审核回读状态异常';
        _statusMessage = '新提交昵称仍处于审核状态，但正式回读已提前替换；页面保持受控失败，不伪装成已生效。';
        _statusSubmittedNickname = null;
        _statusSubmission = null;
      });
      return;
    }
    setState(() {
      _submitting = false;
      _statusTitle = null;
      _statusMessage = null;
      _statusSubmittedNickname = nickname;
      _statusSubmission = safetySubmission;
    });
  }
}
