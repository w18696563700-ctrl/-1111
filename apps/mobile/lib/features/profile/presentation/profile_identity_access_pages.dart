import 'package:flutter/material.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/auth/auth_action_result_presenter.dart';
import 'package:mobile/core/auth/auth_consumer_layer.dart';
import 'package:mobile/core/auth/otp_send_cooldown_controller.dart';
import 'package:mobile/features/profile/data/profile_identity_consumer_layer.dart';
import 'package:mobile/features/profile/navigation/profile_routes.dart';
import 'package:mobile/features/profile/navigation/profile_identity_routes.dart';
import 'package:mobile/features/profile/presentation/profile_identity_legal_pages.dart';
import 'package:mobile/features/profile/presentation/profile_member_management_sheet.dart';
import 'package:mobile/features/profile/presentation/profile_visible_copy.dart';
import 'package:mobile/shell/context/app_shell_scope.dart';

class LoginEntryPage extends StatefulWidget {
  const LoginEntryPage({super.key});

  @override
  State<LoginEntryPage> createState() => _LoginEntryPageState();
}

class _LoginEntryPageState extends State<LoginEntryPage> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final OtpSendCooldownController _cooldownController =
      OtpSendCooldownController();
  AuthActionResult<OtpSendView>? _sendResult;
  AuthActionResult<SessionEnvelope>? _loginResult;
  bool _sending = false;
  bool _loggingIn = false;
  String? _lastOtpSendMobile;

  @override
  void dispose() {
    _cooldownController.dispose();
    _mobileController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_sending || _loggingIn || _cooldownController.isCoolingDown) {
      return;
    }

    setState(() {
      _sending = true;
      _sendResult = null;
    });

    final result = await AuthConsumerLayer.instance.sendOtp(
      mobile: _mobileController.text,
    );
    if (!mounted) {
      return;
    }

    if (result.state == AppPageState.content && result.data != null) {
      _cooldownController.start(result.data!.cooldownSeconds);
      _lastOtpSendMobile = _mobileController.text.trim();
    }

    setState(() {
      _sendResult = result;
      _sending = false;
    });
  }

  Future<void> _login() async {
    setState(() {
      _loggingIn = true;
      _loginResult = null;
    });

    final result = await AuthConsumerLayer.instance.loginWithOtp(
      mobile: _mobileController.text,
      otpCode: _otpController.text,
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _loginResult = result;
      _loggingIn = false;
    });

    await _completeLogin(result);
  }

  Future<void> _completeLogin(AuthActionResult<SessionEnvelope> result) async {
    final session = result.data;
    if (result.state != AppPageState.content || session == null) {
      return;
    }

    await AppShellScope.read(context).bootstrapAfterLogin(
      shellBootstrapState: session.shellBootstrapState ?? 'authenticated',
    );
    if (!mounted) {
      return;
    }

    final routeName = '/';
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(routeName, (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final sendResult = _sendResult;
    final loginResult = _loginResult;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: <Widget>[
        const _IdentityHeroCard(
          title: '登录入口',
          summary:
              '当前入口承接手机号验证码登录。未注册手机号首次验证通过后会自动创建账号；若验证码、会话或壳层未准备好，页面继续保持受控失败，不伪造完整账号中心成功面。',
        ),
        const SizedBox(height: 16),
        _IdentityFormCard(
          title: '验证码登录 / 注册承接',
          child: AnimatedBuilder(
            animation: _cooldownController,
            builder: (BuildContext context, Widget? child) {
              final remainingSeconds = _cooldownController.remainingSeconds;
              return Column(
                children: <Widget>[
                  TextField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: '手机号',
                      hintText: '请输入可接收验证码的手机号',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '验证码',
                      hintText: '收到短信验证码后输入',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: <Widget>[
                      FilledButton(
                        onPressed:
                            _sending ||
                                _loggingIn ||
                                _cooldownController.isCoolingDown
                            ? null
                            : _sendOtp,
                        child: Text(
                          authCooldownButtonLabel(
                            sending: _sending,
                            remainingSeconds: remainingSeconds,
                          ),
                        ),
                      ),
                      FilledButton.tonal(
                        onPressed: _sending || _loggingIn ? null : _login,
                        child: Text(_loggingIn ? '登录中' : '验证码登录 / 注册'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const LoginLegalEntryStrip(),
                  const SizedBox(height: 12),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '当前只承接手机号 + 验证码登录。未注册手机号首次验证成功后会自动创建账号；登录成功后先回展览首页；消息、我的及需要组织上下文的动作仍保持各自受控。',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        if (sendResult != null) ...<Widget>[
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _cooldownController,
            builder: (BuildContext context, Widget? child) =>
                _IdentityStateCard(
                  title: sendResult.state == AppPageState.content
                      ? '验证码已发送'
                      : authActionFailureTitle(
                          sendResult,
                          kind: AuthActionKind.sendOtp,
                        ),
                  message: sendResult.state == AppPageState.content
                      ? authActionSuccessMessageForOtpSend(
                          mobile: _lastOtpSendMobile ?? _mobileController.text,
                          remainingSeconds:
                              _cooldownController.remainingSeconds,
                          traceId: sendResult.data!.traceId,
                        )
                      : authActionFailureMessage(
                          sendResult,
                          kind: AuthActionKind.sendOtp,
                        ),
                ),
          ),
        ],
        if (loginResult != null) ...<Widget>[
          const SizedBox(height: 16),
          _IdentityStateCard(
            title: loginResult.state == AppPageState.content
                ? '登录已进入壳层承接'
                : authActionFailureTitle(
                    loginResult,
                    kind: AuthActionKind.login,
                  ),
            message: loginResult.state == AppPageState.content
                ? authActionSuccessMessageForShell(loginResult.data!)
                : authActionFailureMessage(
                    loginResult,
                    kind: AuthActionKind.login,
                  ),
          ),
        ],
      ],
    );
  }
}

class SessionCenterPage extends StatefulWidget {
  const SessionCenterPage({super.key});

  @override
  State<SessionCenterPage> createState() => _SessionCenterPageState();
}

class _SessionCenterPageState extends State<SessionCenterPage> {
  bool _loading = true;
  String? _revokingDeviceId;
  String? _lastHandledDeviceId;
  String? _lastHandledDeviceLabel;
  ProfileIdentityResult<SecurityDevicesView>? _devicesResult;
  ProfileIdentityResult<ProfileActionAckView>? _revokeResult;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });

    final result = await ProfileIdentityConsumerLayer.instance
        .loadSecurityDevices();
    if (!mounted) {
      return;
    }

    setState(() {
      _devicesResult = result;
      _loading = false;
    });
  }

  Future<void> _revokeDevice(SecurityDeviceItemView device) async {
    setState(() {
      _revokingDeviceId = device.deviceId;
      _lastHandledDeviceId = device.deviceId;
      _revokeResult = null;
      _lastHandledDeviceLabel = _deviceLabel(device);
    });

    final result = await ProfileIdentityConsumerLayer.instance
        .revokeSecurityDevice(deviceId: device.deviceId);
    if (!mounted) {
      return;
    }

    if (result.state == AppPageState.content) {
      setState(() {
        _revokingDeviceId = null;
        _revokeResult = result;
      });
      await _load();
      return;
    }

    setState(() {
      _revokingDeviceId = null;
      _revokeResult = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = AppSessionStore.instance.snapshot;
    final hasSession = AppSessionStore.instance.hasAnySession;
    final devicesResult = _devicesResult;
    final devices =
        devicesResult?.data?.items ?? const <SecurityDeviceItemView>[];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: <Widget>[
        const _IdentityHeroCard(
          title: '会话与设备',
          summary: '查看当前登录设备，并撤销不再使用的设备会话。',
        ),
        const SizedBox(height: 16),
        _IdentityStateCard(
          title: hasSession ? '当前存在本地会话' : '当前没有可验证会话',
          message:
              'accessToken：${snapshot.hasAccessToken ? '已存在' : '缺失'}；refreshToken：${snapshot.hasRefreshToken ? '已存在' : '缺失'}；设备标识：${snapshot.deviceId ?? '未生成'}',
        ),
        if (!hasSession) ...<Widget>[
          const SizedBox(height: 16),
          _IdentityFormCard(
            title: '返回路径',
            child: FilledButton.tonal(
              onPressed: () =>
                  Navigator.of(context).pushNamed(ProfileIdentityRoutes.login),
              child: const Text('进入登录入口'),
            ),
          ),
        ] else if (_loading) ...<Widget>[
          const SizedBox(height: 16),
          const _IdentityStateCard(
            title: '正在同步设备列表',
            message: '正在读取当前设备与撤销状态。',
          ),
        ] else if (devicesResult == null ||
            devicesResult.state != AppPageState.content) ...<Widget>[
          const SizedBox(height: 16),
          _IdentityFormCard(
            title: '设备列表暂不可用',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _identityResultMessage(
                    devicesResult?.state,
                    devicesResult?.message,
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.tonal(onPressed: _load, child: const Text('重试')),
              ],
            ),
          ),
        ] else ...<Widget>[
          const SizedBox(height: 16),
          _IdentityStateCard(
            title: '设备摘要',
            message:
                '当前共 ${devices.length} 台设备；当前设备 ${devices.where((SecurityDeviceItemView item) => item.currentDevice).length} 台；已撤销 ${devices.where(_isRevoked).length} 台。',
          ),
          const SizedBox(height: 16),
          _IdentityFormCard(
            title: devices.isEmpty ? '当前没有可见设备' : '当前设备列表',
            child: devices.isEmpty
                ? const Text('当前没有返回可展示的设备列表。')
                : Column(
                    children: devices
                        .map(
                          (SecurityDeviceItemView item) =>
                              _buildDeviceTile(item),
                        )
                        .toList(growable: false),
                  ),
          ),
          if (_revokeResult != null) ...<Widget>[
            const SizedBox(height: 16),
            _IdentityStateCard(
              title: _revokeResult!.state == AppPageState.content
                  ? '设备状态已刷新'
                  : '设备撤销当前未完成',
              message: _revokeResultMessage(_revokeResult!),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildDeviceTile(SecurityDeviceItemView item) {
    final theme = Theme.of(context);
    final revoked = _isRevoked(item);
    final revoking = _revokingDeviceId == item.deviceId;
    final labels = <String>{
      if (item.currentDevice) '当前设备',
      if (!item.currentDevice)
        profileDisplaySecurityTrustStatus(item.trustStatus),
      if (revoked) '已撤销',
    }.toList(growable: false);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _deviceLabel(item),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (labels.isNotEmpty) ...<Widget>[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: labels
                      .map(
                        (String label) => Chip(
                          label: Text(label),
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                      .toList(growable: false),
                ),
              ],
              const SizedBox(height: 12),
              _IdentityInlineCard(
                title: '操作系统',
                body: profileValueOrFallback(item.osType, '暂未提供'),
              ),
              _IdentityInlineCard(
                title: '应用版本',
                body: profileValueOrFallback(item.appVersion, '暂未提供'),
              ),
              _IdentityInlineCard(
                title: '最近活跃',
                body: profileValueOrFallback(item.lastSeenAt, '暂未提供'),
              ),
              _IdentityInlineCard(
                title: '当前状态',
                body: revoked
                    ? '已撤销'
                    : item.currentDevice
                    ? '当前设备'
                    : profileDisplaySecurityTrustStatus(item.trustStatus),
              ),
              if (item.revokedAt != null)
                _IdentityInlineCard(title: '撤销时间', body: item.revokedAt!),
              const SizedBox(height: 4),
              if (item.currentDevice)
                Text(
                  '当前设备正在使用中，不能在当前会话内撤销。',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
              else if (revoked)
                Text(
                  '该设备已撤销，当前只展示最新状态。',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
              else
                FilledButton.tonal(
                  onPressed: revoking ? null : () => _revokeDevice(item),
                  child: Text(revoking ? '撤销中' : '撤销此设备'),
                ),
              if (_revokeResult != null &&
                  _lastHandledDeviceId == item.deviceId)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: _IdentityInlineCard(
                    title: _revokeResult!.state == AppPageState.content
                        ? '设备状态已刷新'
                        : '设备撤销当前未完成',
                    body: _revokeResultMessage(_revokeResult!),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _revokeResultMessage(
    ProfileIdentityResult<ProfileActionAckView> result,
  ) {
    if (result.state == AppPageState.content) {
      return '${_lastHandledDeviceLabel ?? '所选设备'}已撤销，当前列表已按最新状态刷新。traceId ${result.data!.traceId}。';
    }
    return _identityResultMessage(result.state, result.message);
  }

  static bool _isRevoked(SecurityDeviceItemView item) {
    return item.trustStatus == 'revoked' ||
        (item.revokedAt?.trim().isNotEmpty ?? false);
  }

  static String _deviceLabel(SecurityDeviceItemView item) {
    final deviceName = item.deviceName?.trim();
    if (deviceName != null && deviceName.isNotEmpty) {
      return deviceName;
    }
    return item.currentDevice ? '当前设备' : '未命名设备';
  }
}

class CertificationStatusPage extends StatefulWidget {
  const CertificationStatusPage({super.key});

  @override
  State<CertificationStatusPage> createState() =>
      _CertificationStatusPageState();
}

class _CertificationStatusPageState extends State<CertificationStatusPage> {
  bool _loading = true;
  ProfileIdentityResult<MyOrganizationsView>? _organizationsResult;
  ProfileIdentityResult<ProfileCertificationCurrentView>? _certificationResult;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });

    final results = await Future.wait<Object>(<Future<Object>>[
      ProfileIdentityConsumerLayer.instance.loadMyOrganizations(),
      ProfileIdentityConsumerLayer.instance.loadCertificationCurrent(),
    ]);
    if (!mounted) {
      return;
    }

    setState(() {
      _organizationsResult =
          results[0] as ProfileIdentityResult<MyOrganizationsView>;
      _certificationResult =
          results[1] as ProfileIdentityResult<ProfileCertificationCurrentView>;
      _loading = false;
    });
  }

  Future<void> _openRoute(String routeName) async {
    await Navigator.of(context).pushNamed(routeName);
    if (!mounted) {
      return;
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final hasSession = AppSessionStore.instance.hasAnySession;
    final shellContext = AppShellScope.of(context).snapshot.shellContext;
    final organizations =
        _organizationsResult?.data?.items ?? const <MyOrganizationItemView>[];
    final currentOrganization = _resolveCurrentOrganization(
      organizations,
      shellContext.organizationId,
    );
    final data = _certificationResult?.data;
    final certificationStatus = profileDisplayCertificationStatus(
      data?.certificationStatus,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: <Widget>[
        const _IdentityHeroCard(
          title: '公司认证与我的身份',
          summary: '查看当前公司/组织、我的身份与认证状态，并继续进入公司与组织或认证办理。',
        ),
        const SizedBox(height: 16),
        if (_loading)
          const _IdentityStateCard(
            title: '正在同步公司认证与我的身份',
            message: '正在读取当前公司/组织、我的身份与认证状态。',
          )
        else if (!hasSession)
          _IdentityFormCard(
            title: '当前会话暂不可用',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('当前没有可验证的会话，认证状态页不会伪装成已认证成功。'),
                const SizedBox(height: 14),
                FilledButton.tonal(
                  onPressed: () => Navigator.of(
                    context,
                  ).pushNamed(ProfileIdentityRoutes.login),
                  child: const Text('进入登录入口'),
                ),
              ],
            ),
          )
        else ...<Widget>[
          _IdentityFormCard(
            title: '当前公司/组织',
            child: currentOrganization == null
                ? Text(
                    _organizationsResult?.state == AppPageState.content
                        ? '当前还没有公司/组织，可先创建或加入。'
                        : _identityResultMessage(
                            _organizationsResult?.state,
                            _organizationsResult?.message,
                          ),
                  )
                : Column(
                    children: <Widget>[
                      _IdentityInlineCard(
                        title: '公司名称',
                        body: profileDisplayOrganizationName(
                          currentOrganization.name,
                        ),
                      ),
                      _IdentityInlineCard(
                        title: '组织类型',
                        body: profileDisplayOrganizationType(
                          currentOrganization.organizationType,
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 16),
          _IdentityFormCard(
            title: '当前成员身份',
            child: Column(
              children: <Widget>[
                _IdentityInlineCard(
                  title: '成员身份',
                  body: profileDisplayRoleSummary(
                    currentOrganization?.roleKeys ?? shellContext.roleKeys,
                  ),
                ),
                _IdentityInlineCard(
                  title: '成员状态',
                  body: profileDisplayMembershipStatus(
                    currentOrganization?.membershipStatus ??
                        shellContext.membershipStatus,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _IdentityFormCard(
            title: '当前认证状态',
            child: Column(
              children: <Widget>[
                _IdentityInlineCard(title: '认证状态', body: certificationStatus),
                _IdentityInlineCard(
                  title: '当前公司/组织',
                  body:
                      data?.organizationId ??
                      shellContext.organizationId ??
                      '当前公司/组织上下文不可用',
                ),
                if (data?.legalName != null)
                  _IdentityInlineCard(title: '认证主体', body: data!.legalName!),
                if (data?.uscc != null)
                  _IdentityInlineCard(title: '统一社会信用代码', body: data!.uscc!),
                if (data?.submittedAt != null)
                  _IdentityInlineCard(title: '提交时间', body: data!.submittedAt!),
                if (data?.expiresAt != null)
                  _IdentityInlineCard(title: '有效期', body: data!.expiresAt!),
                if (data?.rejectReason != null)
                  _IdentityInlineCard(title: '拒绝原因', body: data!.rejectReason!),
                if (_certificationResult?.state != null &&
                    _certificationResult?.state != AppPageState.content)
                  _IdentityInlineCard(
                    title: '当前说明',
                    body: _identityResultMessage(
                      _certificationResult?.state,
                      _certificationResult?.message,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _IdentityFormCard(
            title: '公司与组织',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                FilledButton(
                  onPressed: () =>
                      _openRoute(ProfileIdentityRoutes.organizationCreate),
                  child: const Text('创建组织'),
                ),
                FilledButton.tonal(
                  onPressed: () =>
                      _openRoute(ProfileIdentityRoutes.organizationJoin),
                  child: const Text('加入组织'),
                ),
                if (currentOrganization != null)
                  FilledButton.tonal(
                    onPressed: () => showOrganizationMembersSheet(context),
                    child: const Text('成员管理'),
                  ),
                if (organizations.isNotEmpty)
                  FilledButton.tonal(
                    onPressed: () =>
                        _openRoute(ProfileIdentityRoutes.organizationHandoff),
                    child: const Text('切换当前公司/组织'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _IdentityFormCard(
            title: '认证办理',
            child: _buildCertificationActions(
              currentOrganization: currentOrganization,
              certification: data,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCertificationActions({
    required MyOrganizationItemView? currentOrganization,
    required ProfileCertificationCurrentView? certification,
  }) {
    if (currentOrganization == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('当前还没有公司/组织，需先进入公司与组织后再办理认证。'),
          const SizedBox(height: 14),
          FilledButton.tonal(
            onPressed: () =>
                _openRoute(ProfileIdentityRoutes.organizationHandoff),
            child: const Text('先去公司与组织'),
          ),
        ],
      );
    }

    final status =
        certification?.certificationStatus?.trim() ??
        currentOrganization.certificationStatus.trim();
    if (status == 'rejected' || status == 'expired') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            status == 'expired'
                ? '当前认证已过期，可补充最新材料后重新提交。'
                : '当前认证未通过，可按驳回原因补充后重新提交。',
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () =>
                _openRoute(ProfileIdentityRoutes.certificationResubmit),
            child: const Text('重新提交认证'),
          ),
        ],
      );
    }

    if (status == 'pending_review') {
      return const Text('当前认证审核中，先保留当前公司/组织与我的身份承接。');
    }

    if (status == 'approved') {
      return FilledButton.tonal(
        onPressed: () => Navigator.of(context).pushNamed(ProfileRoutes.company),
        child: const Text('查看我的公司'),
      );
    }

    return FilledButton(
      onPressed: () => _openRoute(ProfileIdentityRoutes.certificationSubmit),
      child: const Text('提交认证'),
    );
  }

  static MyOrganizationItemView? _resolveCurrentOrganization(
    List<MyOrganizationItemView> items,
    String? currentOrganizationId,
  ) {
    for (final item in items) {
      if (item.current) {
        return item;
      }
    }
    if (currentOrganizationId != null &&
        currentOrganizationId.trim().isNotEmpty) {
      for (final item in items) {
        if (item.organizationId == currentOrganizationId.trim()) {
          return item;
        }
      }
    }
    return items.isEmpty ? null : items.first;
  }
}

class CertificationSubmitPage extends StatefulWidget {
  const CertificationSubmitPage({super.key});

  @override
  State<CertificationSubmitPage> createState() =>
      _CertificationSubmitPageState();
}

class _CertificationSubmitPageState extends State<CertificationSubmitPage> {
  final TextEditingController _legalNameController = TextEditingController();
  final TextEditingController _usccController = TextEditingController();
  final TextEditingController _licenseFileIdController =
      TextEditingController();
  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _contactMobileController =
      TextEditingController();
  bool _submitting = false;
  ProfileIdentityResult<ProfileCertificationAcceptedView>? _result;

  @override
  void dispose() {
    _legalNameController.dispose();
    _usccController.dispose();
    _licenseFileIdController.dispose();
    _contactNameController.dispose();
    _contactMobileController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final organizationId = AppShellScope.of(
      context,
    ).snapshot.shellContext.organizationId;
    if (organizationId == null || organizationId.trim().isEmpty) {
      setState(() {
        _result = const ProfileIdentityResult<ProfileCertificationAcceptedView>(
          state: AppPageState.errorNonRetryable,
          method: 'POST',
          path: ProfileIdentityCanonicalPaths.certificationSubmit,
          message: '当前组织上下文不可用。',
        );
      });
      return;
    }

    setState(() {
      _submitting = true;
      _result = null;
    });

    final result = await ProfileIdentityConsumerLayer.instance
        .submitCertification(
          organizationId: organizationId,
          legalName: _legalNameController.text,
          uscc: _usccController.text,
          licenseFileId: _licenseFileIdController.text,
          contactName: _contactNameController.text,
          contactMobile: _contactMobileController.text,
        );
    if (!mounted) {
      return;
    }

    if (result.state == AppPageState.content) {
      await AppShellScope.read(context).reloadShellContext();
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _submitting = false;
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _CertificationCommandScaffold(
      title: '提交认证',
      summary: '当前只承接最小 certification submit command，不扩成完整资料中心。',
      submitLabel: _submitting ? '提交中' : '提交认证',
      onSubmit: _submitting ? null : _submit,
      result: _result,
      fields: <Widget>[
        TextField(
          controller: _legalNameController,
          decoration: const InputDecoration(labelText: '认证主体'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _usccController,
          decoration: const InputDecoration(labelText: '统一社会信用代码'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _licenseFileIdController,
          decoration: const InputDecoration(labelText: '营业执照文件 ID'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _contactNameController,
          decoration: const InputDecoration(labelText: '联系人'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _contactMobileController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: '联系电话'),
        ),
      ],
    );
  }
}

class CertificationResubmitPage extends StatefulWidget {
  const CertificationResubmitPage({super.key});

  @override
  State<CertificationResubmitPage> createState() =>
      _CertificationResubmitPageState();
}

class _CertificationResubmitPageState extends State<CertificationResubmitPage> {
  final TextEditingController _legalNameController = TextEditingController();
  final TextEditingController _usccController = TextEditingController();
  final TextEditingController _licenseFileIdController =
      TextEditingController();
  final TextEditingController _supplementNoteController =
      TextEditingController();
  bool _submitting = false;
  ProfileIdentityResult<ProfileCertificationAcceptedView>? _result;

  @override
  void dispose() {
    _legalNameController.dispose();
    _usccController.dispose();
    _licenseFileIdController.dispose();
    _supplementNoteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final organizationId = AppShellScope.of(
      context,
    ).snapshot.shellContext.organizationId;
    if (organizationId == null || organizationId.trim().isEmpty) {
      setState(() {
        _result = const ProfileIdentityResult<ProfileCertificationAcceptedView>(
          state: AppPageState.errorNonRetryable,
          method: 'POST',
          path: ProfileIdentityCanonicalPaths.certificationResubmit,
          message: '当前组织上下文不可用。',
        );
      });
      return;
    }

    setState(() {
      _submitting = true;
      _result = null;
    });

    final result = await ProfileIdentityConsumerLayer.instance
        .resubmitCertification(
          organizationId: organizationId,
          legalName: _legalNameController.text,
          uscc: _usccController.text,
          licenseFileId: _licenseFileIdController.text,
          supplementNote: _supplementNoteController.text,
        );
    if (!mounted) {
      return;
    }

    if (result.state == AppPageState.content) {
      await AppShellScope.read(context).reloadShellContext();
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _submitting = false;
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _CertificationCommandScaffold(
      title: '重新提交认证',
      summary: '当前只承接最小 certification resubmit command，不扩成治理流转页。',
      submitLabel: _submitting ? '提交中' : '重新提交认证',
      onSubmit: _submitting ? null : _submit,
      result: _result,
      fields: <Widget>[
        TextField(
          controller: _legalNameController,
          decoration: const InputDecoration(labelText: '认证主体'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _usccController,
          decoration: const InputDecoration(labelText: '统一社会信用代码'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _licenseFileIdController,
          decoration: const InputDecoration(labelText: '营业执照文件 ID'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _supplementNoteController,
          maxLines: 3,
          decoration: const InputDecoration(labelText: '补充说明'),
        ),
      ],
    );
  }
}

class _CertificationCommandScaffold extends StatelessWidget {
  const _CertificationCommandScaffold({
    required this.title,
    required this.summary,
    required this.submitLabel,
    required this.fields,
    required this.onSubmit,
    required this.result,
  });

  final String title;
  final String summary;
  final String submitLabel;
  final List<Widget> fields;
  final VoidCallback? onSubmit;
  final ProfileIdentityResult<ProfileCertificationAcceptedView>? result;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: <Widget>[
        _IdentityHeroCard(title: title, summary: summary),
        const SizedBox(height: 16),
        _IdentityFormCard(
          title: '认证资料',
          child: Column(
            children: <Widget>[
              ...fields,
              const SizedBox(height: 16),
              FilledButton(onPressed: onSubmit, child: Text(submitLabel)),
            ],
          ),
        ),
        if (result != null) ...<Widget>[
          const SizedBox(height: 16),
          _IdentityStateCard(
            title: '认证提交当前未完成',
            message: _identityResultMessage(result!.state, result!.message),
          ),
        ],
      ],
    );
  }
}

class _IdentityHeroCard extends StatelessWidget {
  const _IdentityHeroCard({required this.title, required this.summary});

  final String title;
  final String summary;

  @override
  Widget build(BuildContext context) {
    return _IdentityFormCard(
      title: title,
      child: Text(summary, style: Theme.of(context).textTheme.bodyLarge),
    );
  }
}

class _IdentityFormCard extends StatelessWidget {
  const _IdentityFormCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _IdentityStateCard extends StatelessWidget {
  const _IdentityStateCard({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return _IdentityFormCard(
      title: title,
      child: Text(message, style: Theme.of(context).textTheme.bodyLarge),
    );
  }
}

class _IdentityInlineCard extends StatelessWidget {
  const _IdentityInlineCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 6),
              Text(body, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}

String _identityResultMessage(AppPageState? state, String? fallback) {
  if (fallback != null && fallback.trim().isNotEmpty) {
    return fallback;
  }

  return switch (state) {
    AppPageState.unauthorized => '当前会话未授权，请先恢复登录态。',
    AppPageState.forbidden => '当前入口暂未开放。',
    AppPageState.notFound => '当前路径暂未承接。',
    AppPageState.errorRetryable => '当前请求暂时没有成功，可以稍后重试。',
    AppPageState.errorNonRetryable => '当前请求处于受控失败态。',
    _ => '当前内容正在准备中。',
  };
}
