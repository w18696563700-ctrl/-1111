part of 'profile_detail_pages.dart';

class ProfilePersonalAvatarRoutePage extends StatefulWidget {
  const ProfilePersonalAvatarRoutePage({super.key});

  @override
  State<ProfilePersonalAvatarRoutePage> createState() =>
      _ProfilePersonalAvatarRoutePageState();
}

class _ProfilePersonalAvatarRoutePageState
    extends State<ProfilePersonalAvatarRoutePage> {
  bool _handlingAction = false;
  String? _statusTitle;
  String? _statusMessage;
  String? _lastSelectedFileName;
  String? _statusSubmittedAvatar;
  ProfilePersonalSafetySubmissionView? _statusSubmission;

  @override
  Widget build(BuildContext context) {
    final shellContext = AppShellScope.of(context).snapshot.shellContext;
    final hasSession = AppSessionStore.instance.hasAnySession;
    final displayName = profileResolvedDisplayName(
      displayName: shellContext.displayName,
      rawUserId: shellContext.userId,
    );
    final avatarUrl = profileResolvedAvatarUrl(shellContext.avatarUrl);
    final fallbackLabel = profileResolvedAvatarFallbackLabel(
      displayName: shellContext.displayName,
      rawUserId: shellContext.userId,
    );

    return AppShellScaffold(
      currentBuilding: AppBuilding.profile,
      titleOverride: '个人头像',
      showStageBanner: false,
      appBarActions: <Widget>[
        TextButton(
          onPressed: hasSession && !_handlingAction
              ? _openChangeAvatarSheet
              : null,
          child: const Text('更换头像'),
        ),
      ],
      child: !hasSession
          ? _ProfileScreenStatePanel(
              title: '当前会话暂不可用',
              message: '当前没有可验证的会话，个人头像页不会伪装成已完成更新。',
              actionLabel: '进入登录入口',
              onAction: () =>
                  Navigator.of(context).pushNamed(ProfileIdentityRoutes.login),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              children: <Widget>[
                Center(
                  child: ProfileAvatarBadge(
                    avatarUrl: avatarUrl,
                    fallbackLabel: fallbackLabel,
                    semanticLabel: avatarUrl == null
                        ? '个人头像当前未设置'
                        : '个人头像当前已设置',
                    size: 120,
                    textStyle: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    displayName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    avatarUrl == null ? '当前还没有设置个人头像。' : '当前头像以正式回读结果为准。',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                const _ProfileCompactCard(
                  children: <Widget>[
                    ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      title: Text('合规提示'),
                      subtitle: Text(
                        '头像上传会进行文件类型、文件大小、图片 mime、FileAsset 与当前用户归属校验；新提交头像审核通过后才会替换当前公开头像。',
                      ),
                    ),
                  ],
                ),
                if (_lastSelectedFileName != null) ...<Widget>[
                  const SizedBox(height: 16),
                  _ProfileCompactCard(
                    children: <Widget>[
                      _ProfileValueRow(
                        title: '最近选择',
                        value: _lastSelectedFileName!,
                      ),
                    ],
                  ),
                ],
                if (_statusSubmission != null) ...<Widget>[
                  const SizedBox(height: 16),
                  _ProfilePersonalSafetyStatusCard(
                    fieldLabel: '头像',
                    currentApprovedValue: avatarUrl == null
                        ? '当前未设置头像'
                        : '当前头像以正式回读结果为准',
                    pendingValue:
                        _statusSubmission!.pendingAvatarUrl ??
                        _statusSubmittedAvatar ??
                        _lastSelectedFileName,
                    submission: _statusSubmission!,
                  ),
                ],
                if (_statusTitle != null && _statusMessage != null) ...<Widget>[
                  const SizedBox(height: 16),
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
              ],
            ),
    );
  }

  Future<void> _openChangeAvatarSheet() async {
    final source = await showModalBottomSheet<ProfileAvatarPickSource?>(
      context: context,
      useSafeArea: true,
      builder: (BuildContext context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('拍照'),
              onTap: () =>
                  Navigator.of(context).pop(ProfileAvatarPickSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('从相册选择'),
              onTap: () =>
                  Navigator.of(context).pop(ProfileAvatarPickSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('取消'),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
    if (!mounted || source == null) {
      return;
    }

    setState(() {
      _handlingAction = true;
      _statusTitle = null;
      _statusMessage = null;
      _statusSubmission = null;
      _statusSubmittedAvatar = null;
    });

    final pickResult = await ProfileAvatarPicker.instance.pick(source: source);
    if (!mounted) {
      return;
    }
    if (pickResult.cancelled) {
      setState(() {
        _handlingAction = false;
      });
      return;
    }
    if (pickResult.file == null) {
      setState(() {
        _handlingAction = false;
        _statusTitle = '头像当前未更新';
        _statusMessage = pickResult.message ?? '当前没有读取到可用头像图片。';
      });
      return;
    }

    final selectedFile = pickResult.file!;
    final editedFile = await openProfileAvatarEditConfirmationPage(
      context,
      file: selectedFile,
    );
    if (!mounted) {
      return;
    }
    if (editedFile == null) {
      setState(() {
        _handlingAction = false;
      });
      return;
    }

    await _uploadEditedAvatar(editedFile);
  }

  Future<void> _uploadEditedAvatar(ProfileAvatarPickedFile file) async {
    final currentUserId = AppShellScope.read(
      context,
    ).snapshot.shellContext.userId;
    final initResult = await ProfilePersonalEditConsumerLayer.instance
        .initAvatarUpload(
          currentUserId: currentUserId,
          fileName: file.fileName,
          mimeType: file.mimeType,
          bodyBytes: file.bytes,
        );
    if (!mounted) {
      return;
    }
    if (initResult.state != AppUploadState.signedReady ||
        initResult.directive == null) {
      _showAvatarStatus(
        fileName: file.fileName,
        title: '头像上传当前未开始',
        message: initResult.message ?? '当前头像上传入口暂时不可用，请稍后再试。',
      );
      return;
    }

    final directUploadResult = await ProfilePersonalEditConsumerLayer.instance
        .directUpload(directive: initResult.directive!, bodyBytes: file.bytes);
    if (!mounted) {
      return;
    }
    if (directUploadResult.state != AppUploadState.uploadConfirming) {
      _showAvatarStatus(
        fileName: file.fileName,
        title: '头像上传当前未完成',
        message: directUploadResult.message ?? '当前头像图片上传失败，请稍后再试。',
      );
      return;
    }

    final confirmResult = await ProfilePersonalEditConsumerLayer.instance
        .confirmAvatarUpload(directive: initResult.directive!);
    if (!mounted) {
      return;
    }
    if (confirmResult.state != AppUploadState.uploadBound ||
        (confirmResult.fileAssetId?.trim().isEmpty ?? true)) {
      _showAvatarStatus(
        fileName: file.fileName,
        title: '头像确认当前未完成',
        message: confirmResult.message ?? '当前头像确认失败，请稍后再试。',
      );
      return;
    }

    await _commitAvatar(file: file, fileAssetId: confirmResult.fileAssetId!);
  }

  Future<void> _commitAvatar({
    required ProfileAvatarPickedFile file,
    required String fileAssetId,
  }) async {
    final previousAvatarUrl = profileResolvedAvatarUrl(
      AppShellScope.read(context).snapshot.shellContext.avatarUrl,
    );
    final commitResult = await ProfilePersonalEditConsumerLayer.instance
        .commitAvatar(fileAssetId: fileAssetId.trim());
    if (!mounted) {
      return;
    }
    if (commitResult.state != AppPageState.content ||
        commitResult.data == null) {
      _showAvatarStatus(
        fileName: file.fileName,
        title: '头像保存当前未完成',
        message: commitResult.message ?? '当前个人头像保存失败，请稍后再试。',
      );
      return;
    }

    final committedAvatarUrl = profileResolvedAvatarUrl(
      commitResult.data?.avatarUrl,
    );
    final safetySubmission = commitResult.data!.safetySubmission;
    if (safetySubmission != null &&
        !profilePersonalSafetyStateUsesApprovedReadback(
          safetySubmission.uiState,
        )) {
      await _handleAvatarSafetySubmission(
        file: file,
        previousAvatarUrl: previousAvatarUrl,
        committedAvatarUrl: committedAvatarUrl,
        safetySubmission: safetySubmission,
      );
      return;
    }

    await AppShellScope.read(context).reloadShellContext();
    if (!mounted) {
      return;
    }
    final reloadedAvatarUrl = profileResolvedAvatarUrl(
      AppShellScope.read(context).snapshot.shellContext.avatarUrl,
    );
    if (reloadedAvatarUrl == null ||
        (committedAvatarUrl != null &&
            reloadedAvatarUrl != committedAvatarUrl)) {
      _showAvatarStatus(
        fileName: file.fileName,
        title: '头像回读当前未更新',
        message: '当前头像写入虽已返回，但正式回读仍未更新，页面保持受控失败。',
      );
      return;
    }

    Navigator.of(context).pop(true);
  }

  Future<void> _handleAvatarSafetySubmission({
    required ProfileAvatarPickedFile file,
    required String? previousAvatarUrl,
    required String? committedAvatarUrl,
    required ProfilePersonalSafetySubmissionView safetySubmission,
  }) async {
    await AppShellScope.read(context).reloadShellContext();
    if (!mounted) {
      return;
    }
    final reloadedAvatarUrl = profileResolvedAvatarUrl(
      AppShellScope.read(context).snapshot.shellContext.avatarUrl,
    );
    if (committedAvatarUrl != null &&
        reloadedAvatarUrl == committedAvatarUrl &&
        previousAvatarUrl != committedAvatarUrl) {
      setState(() {
        _handlingAction = false;
        _lastSelectedFileName = file.fileName;
        _statusTitle = '头像审核回读状态异常';
        _statusMessage = '新提交头像仍处于审核状态，但正式回读已提前替换；页面保持受控失败，不伪装成已生效。';
        _statusSubmittedAvatar = null;
        _statusSubmission = null;
      });
      return;
    }
    setState(() {
      _handlingAction = false;
      _lastSelectedFileName = file.fileName;
      _statusTitle = null;
      _statusMessage = null;
      _statusSubmittedAvatar = file.fileName;
      _statusSubmission = safetySubmission;
    });
  }

  void _showAvatarStatus({
    required String fileName,
    required String title,
    required String message,
  }) {
    setState(() {
      _handlingAction = false;
      _lastSelectedFileName = fileName;
      _statusTitle = title;
      _statusMessage = message;
    });
  }
}
