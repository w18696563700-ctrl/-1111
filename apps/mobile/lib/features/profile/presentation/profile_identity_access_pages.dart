import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/features/profile/data/profile_identity_consumer_layer.dart';
import 'package:mobile/features/profile/navigation/profile_identity_routes.dart';
import 'package:mobile/features/profile/presentation/profile_avatar_picker.dart';
import 'package:mobile/features/profile/presentation/profile_feature_status_copy.dart';
import 'package:mobile/features/profile/presentation/profile_visible_copy.dart';
import 'package:mobile/shell/context/app_shell_scope.dart';

class SessionCenterPage extends StatefulWidget {
  const SessionCenterPage({super.key});

  @override
  State<SessionCenterPage> createState() => _SessionCenterPageState();
}

class _SessionCenterPageState extends State<SessionCenterPage> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSessionStore.instance,
      builder: (BuildContext context, Widget? child) {
        final snapshot = AppSessionStore.instance.snapshot;
        final hasSession = AppSessionStore.instance.hasAnySession;
        final showSetPasswordEntry = AppSessionStore.instance.isOtpLoginSession;

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: <Widget>[
            const _IdentityHeroCard(
              title: '会话与设备',
              summary: '当前仅展示本机登录状态，其他设备管理暂不开放。',
            ),
            const SizedBox(height: 12),
            _IdentityStateCard(
              title: hasSession ? '本机存在登录态' : '当前没有本地会话',
              message:
                  '${_sessionLoginSourceLabel(snapshot.localLoginSource)} · ${hasSession ? '登录状态可用于当前设备' : '请先恢复登录'}',
            ),
            const SizedBox(height: 12),
            _IdentityFormCard(
              title: '本机信息',
              child: _IdentitySummaryList(
                items: <_IdentitySummaryItem>[
                  _IdentitySummaryItem(
                    label: '设备标识',
                    value: _sessionMaskedDeviceId(snapshot.deviceId),
                  ),
                  _IdentitySummaryItem(
                    label: '登录来源',
                    value: _sessionLoginSourceLabel(snapshot.localLoginSource),
                  ),
                  _IdentitySummaryItem(
                    label: '登录凭证',
                    value: snapshot.hasAccessToken ? '已建立' : '未建立',
                  ),
                  _IdentitySummaryItem(
                    label: '续期状态',
                    value: snapshot.hasRefreshToken ? '可续期' : '不可续期',
                  ),
                  _IdentitySummaryItem(
                    label: '有效期',
                    value: _sessionExpiryLabel(snapshot.expiresAt),
                  ),
                ],
              ),
            ),
            if (showSetPasswordEntry) ...<Widget>[
              const SizedBox(height: 12),
              _IdentityFormCard(
                title: '登录密码',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('当前已通过验证码登录，可为这个账号补齐密码登录能力。'),
                    const SizedBox(height: 14),
                    FilledButton.tonal(
                      onPressed: () => Navigator.of(
                        context,
                      ).pushNamed(ProfileIdentityRoutes.passwordSet),
                      child: const Text('设置登录密码'),
                    ),
                  ],
                ),
              ),
            ],
            if (!hasSession) ...<Widget>[
              const SizedBox(height: 12),
              _IdentityFormCard(
                title: '返回路径',
                child: FilledButton.tonal(
                  onPressed: () => Navigator.of(
                    context,
                  ).pushNamed(ProfileIdentityRoutes.login),
                  child: const Text('进入登录入口'),
                ),
              ),
            ],
            const SizedBox(height: 12),
            const _IdentityStateCard(
              title: '安全操作',
              message: '其他设备暂不展示；退出登录请回到设置页完成二次确认。',
            ),
          ],
        );
      },
    );
  }
}

String _sessionLoginSourceLabel(String? source) {
  return switch (source?.trim()) {
    AppSessionLoginSource.otpLogin => '验证码登录',
    AppSessionLoginSource.passwordLogin => '账号密码登录',
    null || '' => '登录来源待确认',
    _ => '登录来源待确认',
  };
}

String _sessionMaskedDeviceId(String? deviceId) {
  final value = deviceId?.trim();
  if (value == null || value.isEmpty) {
    return '未生成';
  }
  if (value.length <= 10) {
    return value;
  }
  return '${value.substring(0, 6)}…${value.substring(value.length - 4)}';
}

String _sessionExpiryLabel(DateTime? expiresAt) {
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
    final certificationOrganizationLabel =
        _resolveCertificationOrganizationLabel(
          items: organizations,
          currentOrganization: currentOrganization,
          certification: data,
          shellOrganizationId: shellContext.organizationId,
        );
    final certificationStatus = profileDisplayCertificationStatus(
      data?.certificationStatus,
    );
    final personalCertification = data?.personalCertification;
    final currentOrganizationSummaryItems = currentOrganization == null
        ? null
        : <_IdentitySummaryItem>[
            _IdentitySummaryItem(
              label: '公司名称',
              value: profileDisplayOrganizationName(currentOrganization.name),
            ),
            _IdentitySummaryItem(
              label: '组织类型',
              value: profileDisplayOrganizationType(
                currentOrganization.organizationType,
              ),
            ),
          ];
    final membershipSummaryItems = <_IdentitySummaryItem>[
      _IdentitySummaryItem(
        label: '成员身份',
        value: profileDisplayRoleSummary(
          currentOrganization?.roleKeys ?? shellContext.roleKeys,
        ),
      ),
      _IdentitySummaryItem(
        label: '成员状态',
        value: profileDisplayMembershipStatus(
          currentOrganization?.membershipStatus ??
              shellContext.membershipStatus,
        ),
      ),
    ];
    final certificationSummaryItems = <_IdentitySummaryItem>[
      _IdentitySummaryItem(label: '企业认证状态', value: certificationStatus),
      _IdentitySummaryItem(
        label: '当前公司/组织',
        value: certificationOrganizationLabel,
      ),
      if (data?.submittedAt != null)
        _IdentitySummaryItem(label: '提交时间', value: data!.submittedAt!),
      if (data?.expiresAt != null)
        _IdentitySummaryItem(label: '有效期', value: data!.expiresAt!),
      if (data?.rejectReason != null)
        _IdentitySummaryItem(label: '拒绝原因', value: data!.rejectReason!),
      if (_certificationResult?.state != null &&
          _certificationResult?.state != AppPageState.content)
        _IdentitySummaryItem(
          label: '当前说明',
          value: _identityResultMessage(
            _certificationResult?.state,
            _certificationResult?.message,
          ),
        ),
    ];
    final personalCertificationSummaryItems =
        _buildPersonalCertificationSummaryItems(
          shellContext: shellContext,
          personalCertification: personalCertification,
          enterpriseCertificationStatus:
              data?.certificationStatus ??
              currentOrganization?.certificationStatus,
        );
    final certificationCurrentTruthItems = _buildCertificationCurrentTruthItems(
      data,
    );
    final personalCertificationTruthItems =
        _buildPersonalCertificationTruthItems(personalCertification);
    final primaryCertificationActionButtons =
        _buildPrimaryCertificationActionButtons(
          currentOrganization: currentOrganization,
          certification: data,
        );
    final primaryPersonalCertificationActionButtons =
        _buildPrimaryPersonalCertificationActionButtons(
          currentOrganization: currentOrganization,
          certification: data,
          shellContext: shellContext,
        );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: <Widget>[
        const _IdentityHeroCard(
          title: '公司认证与我的身份',
          summary: '查看当前公司/组织、我的身份与认证状态；公司与组织在独立入口处理。',
          showTitle: false,
        ),
        if (profileFeatureStatusVisible) ...<Widget>[
          const SizedBox(height: 16),
          const ProfileFeatureStatusCard(
            snapshot: profileCertificationIdentityFeatureStatus,
            showFeatureName: false,
          ),
          const SizedBox(height: 16),
        ] else
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
                : _IdentitySummaryList(items: currentOrganizationSummaryItems!),
          ),
          const SizedBox(height: 16),
          _IdentityFormCard(
            title: '当前成员身份',
            child: _IdentitySummaryList(items: membershipSummaryItems),
          ),
          const SizedBox(height: 16),
          _IdentityFormCard(
            title: '当前认证状态',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _IdentitySummaryList(items: certificationSummaryItems),
                if (primaryCertificationActionButtons.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: primaryCertificationActionButtons,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _IdentityFormCard(
            title: '当前我的认证',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _IdentitySummaryList(items: personalCertificationSummaryItems),
                if (primaryPersonalCertificationActionButtons
                    .isNotEmpty) ...<Widget>[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: primaryPersonalCertificationActionButtons,
                  ),
                ],
              ],
            ),
          ),
          if (certificationCurrentTruthItems.isNotEmpty) ...<Widget>[
            const SizedBox(height: 16),
            _IdentityFormCard(
              title: '正式认证资料',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('以下内容来自当前认证收录结果，是当前页展示的正式认证资料真值。'),
                  const SizedBox(height: 14),
                  _IdentitySummaryList(items: certificationCurrentTruthItems),
                ],
              ),
            ),
          ],
          if (personalCertificationTruthItems.isNotEmpty) ...<Widget>[
            const SizedBox(height: 16),
            _IdentityFormCard(
              title: '我的认证真值',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('以下内容来自当前公司下已收录的我的认证结果；竞标资格会同时检查企业认证与我的认证。'),
                  const SizedBox(height: 14),
                  _IdentitySummaryList(items: personalCertificationTruthItems),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          _IdentityFormCard(
            title: '认证办理',
            child: _buildCertificationActions(
              currentOrganization: currentOrganization,
              certification: data,
              shellContext: shellContext,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCertificationActions({
    required MyOrganizationItemView? currentOrganization,
    required ProfileCertificationCurrentView? certification,
    required AppShellContextData shellContext,
  }) {
    final theme = Theme.of(context);
    const ocrNotice =
        '当前提交链支持上传营业执照图片后自动尝试 OCR 识别并展示完整执照摘要；提交认证后会基于 OCR 自动核验，关键信息一致直接通过，不一致直接打回。';
    const personalCertificationNotice =
        '竞标资格现在必须同时满足企业认证和我的认证。我的认证只接收 1 张身份证正面图片，上传确认后会自动 OCR 识别姓名与身份证号摘要，并与企业认证中的法定代表人真值核对。';
    final personalCertification = certification?.personalCertification;
    final personalCertificationButtons =
        _buildPrimaryPersonalCertificationActionButtons(
          currentOrganization: currentOrganization,
          certification: certification,
          shellContext: shellContext,
        );
    if (currentOrganization == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '企业认证通过后，项目创建、发布和对外展示将以当前公司主体为准；未认证时相关企业能力保持受控。',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Text(
            ocrNotice,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            personalCertificationNotice,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          const Text('当前还没有公司/组织，需先使用上方按钮进入公司与组织后再办理认证。'),
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
            '企业认证通过后，项目创建、发布和对外展示将以当前公司主体为准；未认证时相关企业能力保持受控。',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Text(
            ocrNotice,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            status == 'expired'
                ? '当前认证已过期，可补充最新材料后重新提交。'
                : '当前认证未通过，可按驳回原因补充后重新提交。',
          ),
          const SizedBox(height: 18),
          Text(
            personalCertificationNotice,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Text('企业认证未恢复到已认证前，暂时不能继续办理我的认证。', style: theme.textTheme.bodyMedium),
        ],
      );
    }

    if (status == 'pending_review') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '企业认证通过后，项目创建、发布和对外展示将以当前公司主体为准；未认证时相关企业能力保持受控。',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Text(
            ocrNotice,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          const Text('当前认证审核中，先保留当前公司/组织与我的身份承接。'),
          const SizedBox(height: 18),
          Text(
            personalCertificationNotice,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          const Text('企业认证审核通过前，暂时不能继续办理我的认证。'),
        ],
      );
    }

    if (status == 'approved') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '当前公司已经通过认证，项目创建、发布和对外展示会沿用这个认证主体；如营业执照收录字段缺失、识别错误或主体信息有变化，请走正式“更正认证资料”入口。',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Text(
            ocrNotice,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '当前轮更正资料不会先行冻结当前创建资格、项目发布资格或项目展示；只有 OCR 自动核验通过后，当前正式认证资料才会更新。',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            personalCertificationNotice,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          Text(_buildPersonalCertificationActionCopy(personalCertification)),
          if (personalCertificationButtons.isNotEmpty) ...<Widget>[
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: personalCertificationButtons,
            ),
          ],
          const SizedBox(height: 14),
          const Text('如需更正认证资料或切换主体，请使用上方按钮进入对应入口。'),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '企业认证通过后，项目创建、发布和对外展示将以当前公司主体为准；未认证时相关企业能力保持受控。',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Text(
          ocrNotice,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 14),
        const Text('准备好材料后，可直接使用上方按钮继续正式提交认证。'),
        const SizedBox(height: 18),
        Text(
          personalCertificationNotice,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        const Text('企业认证通过后，才能继续提交我的认证。'),
      ],
    );
  }

  List<Widget> _buildPrimaryCertificationActionButtons({
    required MyOrganizationItemView? currentOrganization,
    required ProfileCertificationCurrentView? certification,
  }) {
    if (currentOrganization == null) {
      return <Widget>[
        FilledButton.tonal(
          onPressed: () =>
              _openRoute(ProfileIdentityRoutes.organizationHandoff),
          child: const Text('先去公司与组织'),
        ),
      ];
    }

    final status =
        certification?.certificationStatus?.trim() ??
        currentOrganization.certificationStatus.trim();
    if (status == 'rejected' || status == 'expired') {
      return <Widget>[
        FilledButton(
          onPressed: () =>
              _openRoute(ProfileIdentityRoutes.certificationResubmit),
          child: const Text('重新提交认证'),
        ),
      ];
    }
    if (status == 'approved') {
      return <Widget>[
        FilledButton(
          onPressed: () =>
              _openRoute(ProfileIdentityRoutes.certificationRevalidate),
          child: const Text('更正认证资料'),
        ),
        FilledButton.tonal(
          onPressed: () =>
              _openRoute(ProfileIdentityRoutes.organizationHandoff),
          child: const Text('管理公司与组织'),
        ),
      ];
    }
    if (status == 'pending_review') {
      return <Widget>[
        FilledButton.tonal(
          onPressed: () =>
              _openRoute(ProfileIdentityRoutes.organizationHandoff),
          child: const Text('管理公司与组织'),
        ),
      ];
    }

    return <Widget>[
      FilledButton(
        onPressed: () => _openRoute(ProfileIdentityRoutes.certificationSubmit),
        child: const Text('提交认证'),
      ),
    ];
  }

  List<_IdentitySummaryItem> _buildPersonalCertificationSummaryItems({
    required AppShellContextData shellContext,
    required ProfilePersonalCertificationCurrentView? personalCertification,
    required String? enterpriseCertificationStatus,
  }) {
    final items = <_IdentitySummaryItem>[
      _IdentitySummaryItem(
        label: '我的认证状态',
        value: profileDisplayCertificationStatus(
          personalCertification?.certificationStatus ??
              shellContext.personalCertificationStatus,
        ),
      ),
    ];

    final qualificationValue = _personalCertificationQualificationLabel(
      shellContext: shellContext,
      personalCertification: personalCertification,
      enterpriseCertificationStatus: enterpriseCertificationStatus,
    );
    if (qualificationValue != null) {
      items.add(
        _IdentitySummaryItem(label: '当前资格说明', value: qualificationValue),
      );
    }
    if (personalCertification?.submittedAt != null) {
      items.add(
        _IdentitySummaryItem(
          label: '提交时间',
          value: personalCertification!.submittedAt!,
        ),
      );
    }
    if (personalCertification?.lockedAt != null) {
      items.add(
        _IdentitySummaryItem(
          label: '锁定时间',
          value: personalCertification!.lockedAt!,
        ),
      );
    }
    if (personalCertification?.rejectReason != null) {
      items.add(
        _IdentitySummaryItem(
          label: '拒绝原因',
          value: personalCertification!.rejectReason!,
        ),
      );
    }
    return List<_IdentitySummaryItem>.unmodifiable(items);
  }

  List<Widget> _buildPrimaryPersonalCertificationActionButtons({
    required MyOrganizationItemView? currentOrganization,
    required ProfileCertificationCurrentView? certification,
    required AppShellContextData shellContext,
  }) {
    if (currentOrganization == null) {
      return <Widget>[
        FilledButton.tonal(
          onPressed: () =>
              _openRoute(ProfileIdentityRoutes.organizationHandoff),
          child: const Text('先去公司与组织'),
        ),
      ];
    }

    final enterpriseStatus =
        certification?.certificationStatus?.trim() ??
        currentOrganization.certificationStatus.trim();
    if (enterpriseStatus != 'approved') {
      return const <Widget>[];
    }

    final personalCertification = certification?.personalCertification;
    if (personalCertification?.lockedToOtherActor == true ||
        shellContext.personalCertificationLockedToOtherActor == true) {
      return const <Widget>[];
    }
    if (personalCertification?.qualifiedForCurrentActor == true) {
      return const <Widget>[];
    }

    final personalStatus =
        personalCertification?.certificationStatus.trim() ??
        shellContext.personalCertificationStatus?.trim();
    final buttonLabel = personalStatus == 'rejected' ? '重新提交我的认证' : '提交我的认证';

    return <Widget>[
      FilledButton(
        onPressed: () =>
            _openRoute(ProfileIdentityRoutes.personalCertificationSubmit),
        child: Text(buttonLabel),
      ),
    ];
  }

  String _buildPersonalCertificationActionCopy(
    ProfilePersonalCertificationCurrentView? personalCertification,
  ) {
    if (personalCertification?.lockedToOtherActor == true) {
      return '当前公司的我的认证已锁定到其他账号，不支持换人。当前账号即使属于供应商，也不能继续取得竞标资格。';
    }
    if (personalCertification?.qualifiedForCurrentActor == true) {
      return '当前账号已通过我的认证；竞标资格中的“我的认证”前提已经成立。';
    }
    if (personalCertification?.certificationStatus == 'rejected') {
      return '当前我的认证未通过，可重新上传身份证正面后再次提交；系统会继续核对身份证姓名与企业认证法定代表人是否一致。';
    }
    return '准备好身份证正面后，可继续提交我的认证；系统会自动 OCR 识别并校验姓名是否与企业认证法定代表人一致。';
  }

  String? _personalCertificationQualificationLabel({
    required AppShellContextData shellContext,
    required ProfilePersonalCertificationCurrentView? personalCertification,
    required String? enterpriseCertificationStatus,
  }) {
    if (enterpriseCertificationStatus?.trim() != 'approved') {
      return '需先完成企业认证，再继续办理我的认证。';
    }
    if (personalCertification?.lockedToOtherActor == true ||
        shellContext.personalCertificationLockedToOtherActor == true) {
      return '当前公司的我的认证已锁定其他账号。';
    }
    if (personalCertification?.qualifiedForCurrentActor == true ||
        shellContext.personalCertificationQualified == true) {
      return '当前账号已满足我的认证资格。';
    }
    return '竞标资格要求企业认证和我的认证同时通过。';
  }

  static MyOrganizationItemView? _resolveCurrentOrganization(
    List<MyOrganizationItemView> items,
    String? currentOrganizationId,
  ) {
    if (currentOrganizationId != null &&
        currentOrganizationId.trim().isNotEmpty) {
      for (final item in items) {
        if (item.organizationId == currentOrganizationId.trim()) {
          return item;
        }
      }
    }
    for (final item in items) {
      if (item.current) {
        return item;
      }
    }
    return items.isEmpty ? null : items.first;
  }

  static String _resolveCertificationOrganizationLabel({
    required List<MyOrganizationItemView> items,
    required MyOrganizationItemView? currentOrganization,
    required ProfileCertificationCurrentView? certification,
    required String? shellOrganizationId,
  }) {
    final organizationIds = <String>[
      if (certification?.organizationId?.trim().isNotEmpty ?? false)
        certification!.organizationId!.trim(),
      if (shellOrganizationId?.trim().isNotEmpty ?? false)
        shellOrganizationId!.trim(),
    ];
    for (final organizationId in organizationIds) {
      for (final item in items) {
        if (item.organizationId == organizationId &&
            item.name.trim().isNotEmpty) {
          return profileDisplayOrganizationName(item.name);
        }
      }
    }
    if (currentOrganization != null &&
        currentOrganization.name.trim().isNotEmpty) {
      return profileDisplayOrganizationName(currentOrganization.name);
    }
    final legalName = certification?.legalName?.trim();
    if (legalName != null && legalName.isNotEmpty) {
      return legalName;
    }
    return '当前公司/组织上下文不可用';
  }

  static List<_IdentitySummaryItem> _buildCertificationCurrentTruthItems(
    ProfileCertificationCurrentView? certification,
  ) {
    if (certification == null) {
      return const <_IdentitySummaryItem>[];
    }

    final items = <_IdentitySummaryItem>[
      if (certification.legalName?.trim().isNotEmpty ?? false)
        _IdentitySummaryItem(
          label: '认证主体',
          value: certification.legalName!.trim(),
        ),
      if (certification.uscc?.trim().isNotEmpty ?? false)
        _IdentitySummaryItem(
          label: '统一社会信用代码',
          value: certification.uscc!.trim(),
        ),
      if (certification.legalPerson?.trim().isNotEmpty ?? false)
        _IdentitySummaryItem(
          label: '法定代表人',
          value: certification.legalPerson!.trim(),
        ),
      if (_normalizedCertificationBusinessType(certification.businessType)
          case final String businessType)
        _IdentitySummaryItem(label: '企业类型', value: businessType),
      if (certification.address?.trim().isNotEmpty ?? false)
        _IdentitySummaryItem(label: '住所', value: certification.address!.trim()),
      if (certification.registeredCapital?.trim().isNotEmpty ?? false)
        _IdentitySummaryItem(
          label: '注册资本',
          value: certification.registeredCapital!.trim(),
        ),
      if (certification.establishedAt?.trim().isNotEmpty ?? false)
        _IdentitySummaryItem(
          label: '成立日期',
          value: certification.establishedAt!.trim(),
        ),
      if (certification.businessTerm?.trim().isNotEmpty ?? false)
        _IdentitySummaryItem(
          label: '营业期限',
          value: certification.businessTerm!.trim(),
        ),
      if (certification.businessScope?.trim().isNotEmpty ?? false)
        _IdentitySummaryItem(
          label: '经营范围',
          value: certification.businessScope!.trim(),
        ),
    ];
    return List<_IdentitySummaryItem>.unmodifiable(items);
  }

  static List<_IdentitySummaryItem> _buildPersonalCertificationTruthItems(
    ProfilePersonalCertificationCurrentView? certification,
  ) {
    if (certification == null) {
      return const <_IdentitySummaryItem>[];
    }

    final items = <_IdentitySummaryItem>[
      if (certification.realName?.trim().isNotEmpty ?? false)
        _IdentitySummaryItem(
          label: '姓名',
          value: certification.realName!.trim(),
        ),
      if (certification.idNumberMasked?.trim().isNotEmpty ?? false)
        _IdentitySummaryItem(
          label: '身份证号摘要',
          value: certification.idNumberMasked!.trim(),
        ),
      _IdentitySummaryItem(
        label: '资格状态',
        value: certification.lockedToOtherActor
            ? '已锁定其他账号'
            : certification.qualifiedForCurrentActor
            ? '当前账号已匹配'
            : '当前账号未取得资格',
      ),
      if (certification.submittedAt?.trim().isNotEmpty ?? false)
        _IdentitySummaryItem(
          label: '提交时间',
          value: certification.submittedAt!.trim(),
        ),
      if (certification.lockedAt?.trim().isNotEmpty ?? false)
        _IdentitySummaryItem(
          label: '锁定时间',
          value: certification.lockedAt!.trim(),
        ),
      if (certification.rejectReason?.trim().isNotEmpty ?? false)
        _IdentitySummaryItem(
          label: '拒绝原因',
          value: certification.rejectReason!.trim(),
        ),
    ];
    return List<_IdentitySummaryItem>.unmodifiable(items);
  }
}

class CertificationSubmitPage extends StatefulWidget {
  const CertificationSubmitPage({super.key});

  @override
  State<CertificationSubmitPage> createState() =>
      _CertificationSubmitPageState();
}

abstract class _CertificationCommandPageState<T extends StatefulWidget>
    extends State<T> {
  bool _handlingLicenseUpload = false;
  bool _licensePreviewExpanded = false;
  ProfileAvatarPickedFile? _pendingLicenseFile;
  CertificationLicenseOcrView? _licenseOcrView;
  String? _selectedLicenseFileName;
  Uint8List? _selectedLicensePreviewBytes;
  String? _confirmedLicenseFileAssetId;
  String? _licenseUploadTitle;
  String? _licenseUploadMessage;
  String? _licenseOcrTitle;
  String? _licenseOcrMessage;

  bool get handlingLicenseUpload => _handlingLicenseUpload;
  String? get confirmedLicenseFileAssetId => _confirmedLicenseFileAssetId;

  void applyLicenseOcr(CertificationLicenseOcrView view);

  void showCertificationCommandMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> pickLicense() async {
    final source = await _openCertificationLicenseUploadSourceSheet(context);
    if (!mounted || source == null) {
      return;
    }

    final pickResult = await ProfileAvatarPicker.instance.pick(source: source);
    if (!mounted) {
      return;
    }
    if (pickResult.cancelled) {
      return;
    }
    if (pickResult.file == null) {
      _setLicenseUploadStatus(
        title: '营业执照当前未选中',
        message: pickResult.message ?? '当前没有读取到可用营业执照图片。',
      );
      return;
    }

    _stageLicenseFile(pickResult.file!);
  }

  Future<void> confirmLicenseUpload() async {
    final file = _pendingLicenseFile;
    if (file == null) {
      _setLicenseUploadStatus(title: '营业执照当前未选中', message: '请先选择营业执照图片，再确认上传。');
      return;
    }

    setState(() {
      _handlingLicenseUpload = true;
      _confirmedLicenseFileAssetId = null;
      _licenseUploadTitle = '营业执照上传准备中';
      _licenseUploadMessage = '正在上传当前已选营业执照图片。';
    });
    await _uploadLicenseFile(file);
  }

  Widget buildLicenseUploadField() {
    final showUploadStateCard =
        _licenseUploadTitle != null && _licenseUploadTitle!.contains('未');
    final showOcrStateCard =
        _licenseOcrTitle != null && _licenseOcrTitle!.contains('未');
    final hasSelectedLicense = _selectedLicensePreviewBytes != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (showUploadStateCard && _licenseUploadMessage != null)
          _IdentityInlineCard(
            title: _licenseUploadTitle!,
            body: _licenseUploadMessage!,
          ),
        if (showOcrStateCard && _licenseOcrMessage != null) ...<Widget>[
          const SizedBox(height: 8),
          _IdentityInlineCard(
            title: _licenseOcrTitle!,
            body: _licenseOcrMessage!,
          ),
        ],
        if (_licenseOcrView != null &&
            _buildLicenseOcrSummaryItems(
              _licenseOcrView!,
            ).isNotEmpty) ...<Widget>[
          const SizedBox(height: 4),
          const _IdentityInlineCard(
            title: 'OCR识别预览',
            body: '以下内容来自营业执照 OCR 识别结果，仅用于当前页核对与回填。正式认证资料以认证状态页中的“正式认证资料”为准。',
          ),
          _IdentitySummaryList(
            items: _buildLicenseOcrSummaryItems(_licenseOcrView!),
          ),
          const SizedBox(height: 12),
        ],
        if (_selectedLicenseFileName != null)
          _IdentityInlineCard(title: '最近选择', body: _selectedLicenseFileName!),
        if (_selectedLicensePreviewBytes != null) ...<Widget>[
          const SizedBox(height: 12),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                setState(() {
                  _licensePreviewExpanded = !_licensePreviewExpanded;
                });
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutCubic,
                        width: double.infinity,
                        height: _licensePreviewExpanded ? 420 : 220,
                        color: Theme.of(context).colorScheme.surface,
                        alignment: Alignment.center,
                        child: Image.memory(
                          _selectedLicensePreviewBytes!,
                          fit: BoxFit.contain,
                          gaplessPlayback: true,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              _selectedLicenseFileName ?? '当前营业执照图片预览',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _licensePreviewExpanded
                                  ? '再次点击图片可恢复常规预览。'
                                  : '点击图片可放大查看完整营业执照。',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            FilledButton.tonal(
              onPressed: _handlingLicenseUpload ? null : pickLicense,
              child: Text(hasSelectedLicense ? '重新选择营业执照' : '选择营业执照'),
            ),
            if (hasSelectedLicense && _confirmedLicenseFileAssetId == null)
              FilledButton(
                onPressed: _handlingLicenseUpload ? null : confirmLicenseUpload,
                child: Text(_handlingLicenseUpload ? '上传中' : '确认上传营业执照'),
              ),
          ],
        ),
      ],
    );
  }

  void _stageLicenseFile(ProfileAvatarPickedFile file) {
    setState(() {
      _handlingLicenseUpload = false;
      _licensePreviewExpanded = false;
      _pendingLicenseFile = file;
      _licenseOcrView = null;
      _selectedLicenseFileName = file.fileName;
      _selectedLicensePreviewBytes = Uint8List.fromList(file.bytes);
      _confirmedLicenseFileAssetId = null;
      _licenseUploadTitle = '营业执照待上传';
      _licenseUploadMessage =
          '已完成图片选择。当前认证仅支持 1 张营业执照图片，请确认图片完整清晰后点击“确认上传营业执照”。';
      _licenseOcrTitle = '营业执照 OCR 待开始';
      _licenseOcrMessage = '当前会在上传确认完成后自动尝试 OCR 识别回填。';
    });
  }

  Future<void> _uploadLicenseFile(ProfileAvatarPickedFile file) async {
    setState(() {
      _pendingLicenseFile = file;
      _licenseOcrView = null;
      _selectedLicenseFileName = file.fileName;
      _selectedLicensePreviewBytes = Uint8List.fromList(file.bytes);
      _licenseOcrTitle = '营业执照 OCR 待开始';
      _licenseOcrMessage = '当前会在上传确认完成后自动尝试 OCR 识别回填。';
    });

    final organizationId = AppShellScope.of(
      context,
    ).snapshot.shellContext.organizationId;
    if (organizationId == null || organizationId.trim().isEmpty) {
      _setLicenseUploadStatus(
        fileName: file.fileName,
        title: '营业执照上传当前未开始',
        message: '当前组织上下文不可用，请返回认证页后重试。',
      );
      return;
    }

    final initResult = await ProfileIdentityConsumerLayer.instance
        .initCertificationLicenseUpload(
          organizationId: organizationId,
          mimeType: file.mimeType,
          bodyBytes: file.bytes,
        );
    if (!mounted) {
      return;
    }
    if (initResult.state != AppUploadState.signedReady ||
        initResult.directive == null) {
      _setLicenseUploadStatus(
        fileName: file.fileName,
        title: '营业执照上传当前未开始',
        message: initResult.message ?? '当前营业执照上传入口暂不可用，请稍后再试。',
      );
      return;
    }

    final directUploadResult = await ProfileIdentityConsumerLayer.instance
        .directCertificationLicenseUpload(
          directive: initResult.directive!,
          bodyBytes: file.bytes,
        );
    if (!mounted) {
      return;
    }
    if (directUploadResult.state != AppUploadState.uploadConfirming) {
      _setLicenseUploadStatus(
        fileName: file.fileName,
        title: '营业执照上传当前未完成',
        message: directUploadResult.message ?? '当前营业执照直传失败，请稍后再试。',
      );
      return;
    }

    final confirmResult = await ProfileIdentityConsumerLayer.instance
        .confirmCertificationLicenseUpload(directive: initResult.directive!);
    if (!mounted) {
      return;
    }
    if (confirmResult.state != AppUploadState.uploadBound ||
        (confirmResult.fileAssetId?.trim().isEmpty ?? true)) {
      _setLicenseUploadStatus(
        fileName: file.fileName,
        title: '营业执照确认当前未完成',
        message: confirmResult.message ?? '当前营业执照上传确认失败，请稍后再试。',
      );
      return;
    }

    _setLicenseUploadStatus(
      fileName: file.fileName,
      title: '营业执照已完成上传绑定',
      message: '当前已完成 init -> direct upload -> confirm，可继续提交认证。',
      confirmedFileAssetId: confirmResult.fileAssetId,
    );
    await _recognizeLicenseFile(organizationId, confirmResult.fileAssetId!);
  }

  void _setLicenseUploadStatus({
    String? fileName,
    required String title,
    required String message,
    String? confirmedFileAssetId,
  }) {
    setState(() {
      _handlingLicenseUpload = false;
      _selectedLicenseFileName = fileName ?? _selectedLicenseFileName;
      _licenseUploadTitle = title;
      _licenseUploadMessage = message;
      _confirmedLicenseFileAssetId = confirmedFileAssetId;
    });
  }

  Future<void> _recognizeLicenseFile(
    String organizationId,
    String fileAssetId,
  ) async {
    setState(() {
      _handlingLicenseUpload = true;
      _licenseOcrTitle = '营业执照 OCR 识别中';
      _licenseOcrMessage = '正在识别营业执照并尝试自动回填认证字段。';
    });

    final result = await ProfileIdentityConsumerLayer.instance
        .recognizeCertificationLicense(
          organizationId: organizationId,
          fileAssetId: fileAssetId,
        );
    if (!mounted) {
      return;
    }
    if (result.state != AppPageState.content || result.data == null) {
      setState(() {
        _handlingLicenseUpload = false;
        _licenseOcrView = null;
        _licenseOcrTitle = '营业执照 OCR 当前未完成';
        _licenseOcrMessage = result.message ?? '当前营业执照 OCR 暂不可用，请先手动填写认证信息。';
      });
      return;
    }

    applyLicenseOcr(result.data!);
    setState(() {
      _handlingLicenseUpload = false;
      _licenseOcrView = result.data!;
      _licenseOcrTitle = switch (result.data!.status) {
        'recognized' => '营业执照 OCR 已完成',
        'partial' => '营业执照 OCR 已部分完成',
        _ => '营业执照 OCR 当前未完成',
      };
      _licenseOcrMessage = result.data!.message;
    });
  }

  List<_IdentitySummaryItem> _buildLicenseOcrSummaryItems(
    CertificationLicenseOcrView view,
  ) {
    final items = <_IdentitySummaryItem>[
      if (view.legalName?.trim().isNotEmpty ?? false)
        _IdentitySummaryItem(label: '名称', value: view.legalName!.trim()),
      if (_normalizedCertificationBusinessType(view.businessType)
          case final String businessType)
        _IdentitySummaryItem(label: '企业类型', value: businessType),
      if (view.address?.trim().isNotEmpty ?? false)
        _IdentitySummaryItem(label: '住所', value: view.address!.trim()),
      if (view.legalPerson?.trim().isNotEmpty ?? false)
        _IdentitySummaryItem(label: '法定代表人', value: view.legalPerson!.trim()),
      if (view.registeredCapital?.trim().isNotEmpty ?? false)
        _IdentitySummaryItem(
          label: '注册资本',
          value: view.registeredCapital!.trim(),
        ),
      if (view.establishedAt?.trim().isNotEmpty ?? false)
        _IdentitySummaryItem(label: '成立日期', value: view.establishedAt!.trim()),
      if (view.businessTerm?.trim().isNotEmpty ?? false)
        _IdentitySummaryItem(label: '营业期限', value: view.businessTerm!.trim()),
      if (view.businessScope?.trim().isNotEmpty ?? false)
        _IdentitySummaryItem(label: '经营范围', value: view.businessScope!.trim()),
      if (view.uscc?.trim().isNotEmpty ?? false)
        _IdentitySummaryItem(label: '统一社会信用代码', value: view.uscc!.trim()),
    ];
    return List<_IdentitySummaryItem>.unmodifiable(items);
  }
}

String? _normalizedCertificationBusinessType(String? raw) {
  final value = raw?.trim();
  if (value == null || value.isEmpty) {
    return null;
  }

  final normalized = value.toLowerCase().replaceAll(RegExp(r'\s+'), '');
  if (normalized == 'qrcode' ||
      normalized == 'qr码' ||
      value == 'QRCode' ||
      value == '二维码') {
    return null;
  }

  return value;
}

class _CertificationSubmitPageState
    extends _CertificationCommandPageState<CertificationSubmitPage> {
  final TextEditingController _legalNameController = TextEditingController();
  final TextEditingController _usccController = TextEditingController();
  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _contactMobileController =
      TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _legalNameController.dispose();
    _usccController.dispose();
    _contactNameController.dispose();
    _contactMobileController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final organizationId = AppShellScope.of(
      context,
    ).snapshot.shellContext.organizationId;
    if (organizationId == null || organizationId.trim().isEmpty) {
      showCertificationCommandMessage('当前组织上下文不可用。');
      return;
    }
    final fileAssetId = confirmedLicenseFileAssetId?.trim();
    if (fileAssetId == null || fileAssetId.isEmpty) {
      showCertificationCommandMessage('请先选择并确认上传营业执照图片后再提交认证。');
      return;
    }

    setState(() {
      _submitting = true;
    });

    final result = await ProfileIdentityConsumerLayer.instance
        .submitCertification(
          organizationId: organizationId,
          legalName: _legalNameController.text,
          uscc: _usccController.text,
          fileAssetId: fileAssetId,
          contactName: _contactNameController.text,
          contactMobile: _contactMobileController.text,
        );
    if (!mounted) {
      return;
    }

    if (result.state == AppPageState.content) {
      final shellController = AppShellScope.read(context);
      Navigator.of(context).pop(true);
      await shellController.reloadShellContext();
      return;
    }

    setState(() {
      _submitting = false;
    });
    showCertificationCommandMessage(
      _identityResultMessage(result.state, result.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _CertificationCommandScaffold(
      title: '提交认证',
      summary:
          '当前认证只接收 1 张营业执照图片。请先选择并确认上传，上传完成后会自动尝试 OCR 识别、展示营业执照摘要并回填认证主体与统一社会信用代码；提交认证后会基于 OCR 自动核验，符合直接通过，不符合直接打回。',
      submitLabel: _submitting ? '提交中' : '提交认证',
      onSubmit: _submitting || handlingLicenseUpload ? null : _submit,
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
        buildLicenseUploadField(),
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

  @override
  void applyLicenseOcr(CertificationLicenseOcrView view) {
    if ((view.legalName?.trim().isNotEmpty ?? false)) {
      _legalNameController.text = view.legalName!.trim();
    }
    if ((view.uscc?.trim().isNotEmpty ?? false)) {
      _usccController.text = view.uscc!.trim();
    }
  }
}

class CertificationResubmitPage extends StatefulWidget {
  const CertificationResubmitPage({super.key});

  @override
  State<CertificationResubmitPage> createState() =>
      _CertificationResubmitPageState();
}

class _CertificationResubmitPageState
    extends _CertificationCommandPageState<CertificationResubmitPage> {
  final TextEditingController _legalNameController = TextEditingController();
  final TextEditingController _usccController = TextEditingController();
  final TextEditingController _supplementNoteController =
      TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _legalNameController.dispose();
    _usccController.dispose();
    _supplementNoteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final organizationId = AppShellScope.of(
      context,
    ).snapshot.shellContext.organizationId;
    if (organizationId == null || organizationId.trim().isEmpty) {
      showCertificationCommandMessage('当前组织上下文不可用。');
      return;
    }
    final fileAssetId = confirmedLicenseFileAssetId?.trim();
    if (fileAssetId == null || fileAssetId.isEmpty) {
      showCertificationCommandMessage('请先选择并确认上传最新营业执照图片后再重新提交认证。');
      return;
    }

    setState(() {
      _submitting = true;
    });

    final result = await ProfileIdentityConsumerLayer.instance
        .resubmitCertification(
          organizationId: organizationId,
          legalName: _legalNameController.text,
          uscc: _usccController.text,
          fileAssetId: fileAssetId,
          supplementNote: _supplementNoteController.text,
        );
    if (!mounted) {
      return;
    }

    if (result.state == AppPageState.content) {
      final shellController = AppShellScope.read(context);
      Navigator.of(context).pop(true);
      await shellController.reloadShellContext();
      return;
    }

    setState(() {
      _submitting = false;
    });
    showCertificationCommandMessage(
      _identityResultMessage(result.state, result.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _CertificationCommandScaffold(
      title: '重新提交认证',
      summary:
          '当前认证只接收 1 张营业执照图片。请先选择并确认上传，上传完成后会自动尝试 OCR 识别、展示营业执照摘要并回填认证主体与统一社会信用代码；重新提交后会基于 OCR 自动核验，符合直接通过，不符合直接打回。',
      submitLabel: _submitting ? '提交中' : '重新提交认证',
      onSubmit: _submitting || handlingLicenseUpload ? null : _submit,
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
        buildLicenseUploadField(),
        const SizedBox(height: 12),
        TextField(
          controller: _supplementNoteController,
          maxLines: 3,
          decoration: const InputDecoration(labelText: '补充说明'),
        ),
      ],
    );
  }

  @override
  void applyLicenseOcr(CertificationLicenseOcrView view) {
    if ((view.legalName?.trim().isNotEmpty ?? false)) {
      _legalNameController.text = view.legalName!.trim();
    }
    if ((view.uscc?.trim().isNotEmpty ?? false)) {
      _usccController.text = view.uscc!.trim();
    }
  }
}

class CertificationRevalidatePage extends StatefulWidget {
  const CertificationRevalidatePage({super.key});

  @override
  State<CertificationRevalidatePage> createState() =>
      _CertificationRevalidatePageState();
}

class _CertificationRevalidatePageState
    extends _CertificationCommandPageState<CertificationRevalidatePage> {
  final TextEditingController _legalNameController = TextEditingController();
  final TextEditingController _usccController = TextEditingController();
  final TextEditingController _correctionNoteController =
      TextEditingController();
  ProfileIdentityResult<ProfileCertificationCurrentView>? _currentResult;
  bool _loadingCurrent = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadCurrent();
  }

  @override
  void dispose() {
    _legalNameController.dispose();
    _usccController.dispose();
    _correctionNoteController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrent() async {
    final result = await ProfileIdentityConsumerLayer.instance
        .loadCertificationCurrent();
    if (!mounted) {
      return;
    }
    final current = result.data;
    if ((_legalNameController.text.trim().isEmpty) &&
        (current?.legalName?.trim().isNotEmpty ?? false)) {
      _legalNameController.text = current!.legalName!.trim();
    }
    if ((_usccController.text.trim().isEmpty) &&
        (current?.uscc?.trim().isNotEmpty ?? false)) {
      _usccController.text = current!.uscc!.trim();
    }
    setState(() {
      _currentResult = result;
      _loadingCurrent = false;
    });
  }

  Future<void> _submit() async {
    final organizationId = AppShellScope.of(
      context,
    ).snapshot.shellContext.organizationId;
    if (organizationId == null || organizationId.trim().isEmpty) {
      showCertificationCommandMessage('当前组织上下文不可用。');
      return;
    }
    final fileAssetId = confirmedLicenseFileAssetId?.trim();
    if (fileAssetId == null || fileAssetId.isEmpty) {
      showCertificationCommandMessage('请先选择并确认上传最新营业执照图片后再提交资料更正。');
      return;
    }

    setState(() {
      _submitting = true;
    });

    final result = await ProfileIdentityConsumerLayer.instance
        .revalidateCertification(
          organizationId: organizationId,
          legalName: _legalNameController.text,
          uscc: _usccController.text,
          fileAssetId: fileAssetId,
          correctionNote: _correctionNoteController.text,
        );
    if (!mounted) {
      return;
    }

    if (result.state == AppPageState.content) {
      final shellController = AppShellScope.read(context);
      Navigator.of(context).pop(true);
      await shellController.reloadShellContext();
      return;
    }

    setState(() {
      _submitting = false;
    });
    showCertificationCommandMessage(
      _identityResultMessage(result.state, result.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentTruthItems =
        _CertificationStatusPageState._buildCertificationCurrentTruthItems(
          _currentResult?.data,
        );

    return _CertificationCommandScaffold(
      title: '更正认证资料',
      summary:
          '当前入口仅用于已认证公司的正式资料更正。请先选择并确认上传最新营业执照，上传完成后会自动尝试 OCR 识别并展示预览；只有 OCR 自动核验通过后，当前正式认证资料才会更新并继续保持已认证。',
      submitLabel: _submitting ? '提交中' : '提交资料更正',
      onSubmit: _submitting || handlingLicenseUpload || _loadingCurrent
          ? null
          : _submit,
      fields: <Widget>[
        const _IdentityInlineCard(
          title: '项目主线影响',
          body:
              '本轮资料更正失败不会先行冻结当前创建资格（workbench.canCreateProject）、项目发布资格或项目展示；只有核验通过后，正式认证资料才会更新。',
        ),
        const SizedBox(height: 12),
        const _IdentityInlineCard(
          title: '待审核更正状态',
          body: '当前轮没有单独的待审核更正状态，也不会生成并行资格真值；当前页展示的“正式认证资料”仍然是当前有效真值。',
        ),
        const SizedBox(height: 12),
        if (_loadingCurrent)
          const _IdentityInlineCard(
            title: '正式认证资料同步中',
            body: '正在读取当前正式认证资料，稍后会在本页展示。',
          )
        else if (currentTruthItems.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const _IdentityInlineCard(
                title: '当前正式认证资料',
                body: '以下内容来自当前正式认证收录结果。即使你正在准备本次资料更正，这里仍然是当前有效真值。',
              ),
              const SizedBox(height: 8),
              _IdentitySummaryList(items: currentTruthItems),
            ],
          )
        else
          _IdentityInlineCard(
            title: '当前正式认证资料暂不可读',
            body: _identityResultMessage(
              _currentResult?.state,
              _currentResult?.message,
            ),
          ),
        const SizedBox(height: 12),
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
        buildLicenseUploadField(),
        const SizedBox(height: 12),
        TextField(
          controller: _correctionNoteController,
          maxLines: 3,
          decoration: const InputDecoration(labelText: '更正说明'),
        ),
      ],
    );
  }

  @override
  void applyLicenseOcr(CertificationLicenseOcrView view) {
    if ((view.legalName?.trim().isNotEmpty ?? false)) {
      _legalNameController.text = view.legalName!.trim();
    }
    if ((view.uscc?.trim().isNotEmpty ?? false)) {
      _usccController.text = view.uscc!.trim();
    }
  }
}

class PersonalCertificationSubmitPage extends StatefulWidget {
  const PersonalCertificationSubmitPage({super.key});

  @override
  State<PersonalCertificationSubmitPage> createState() =>
      _PersonalCertificationSubmitPageState();
}

class _PersonalCertificationSubmitPageState
    extends State<PersonalCertificationSubmitPage> {
  ProfileIdentityResult<ProfileCertificationCurrentView>? _currentResult;
  bool _loadingCurrent = true;
  bool _submitting = false;
  bool _handlingIdCardUpload = false;
  bool _idCardPreviewExpanded = false;
  ProfileAvatarPickedFile? _pendingIdCardFile;
  PersonalCertificationIdCardOcrView? _idCardOcrView;
  String? _selectedIdCardFileName;
  Uint8List? _selectedIdCardPreviewBytes;
  String? _confirmedIdCardFrontFileId;
  String? _idCardUploadTitle;
  String? _idCardUploadMessage;
  String? _idCardOcrTitle;
  String? _idCardOcrMessage;

  @override
  void initState() {
    super.initState();
    _loadCurrent();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadCurrent() async {
    final result = await ProfileIdentityConsumerLayer.instance
        .loadCertificationCurrent();
    if (!mounted) {
      return;
    }
    setState(() {
      _currentResult = result;
      _loadingCurrent = false;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickIdCardFront() async {
    final source = await _openCertificationLicenseUploadSourceSheet(context);
    if (!mounted || source == null) {
      return;
    }

    final pickResult = await ProfileAvatarPicker.instance.pick(source: source);
    if (!mounted) {
      return;
    }
    if (pickResult.cancelled) {
      return;
    }
    if (pickResult.file == null) {
      _setIdCardUploadStatus(
        title: '身份证正面当前未选中',
        message: pickResult.message ?? '当前没有读取到可用的身份证正面图片。',
      );
      return;
    }

    final file = pickResult.file!;
    setState(() {
      _handlingIdCardUpload = false;
      _idCardPreviewExpanded = false;
      _pendingIdCardFile = file;
      _idCardOcrView = null;
      _selectedIdCardFileName = file.fileName;
      _selectedIdCardPreviewBytes = Uint8List.fromList(file.bytes);
      _confirmedIdCardFrontFileId = null;
      _idCardUploadTitle = '身份证正面待上传';
      _idCardUploadMessage =
          '已完成图片选择。当前我的认证仅支持 1 张身份证正面图片，请确认姓名和身份证号清晰可见后点击“确认上传身份证正面”。';
      _idCardOcrTitle = '身份证 OCR 待开始';
      _idCardOcrMessage = '当前会在上传确认完成后自动尝试 OCR 识别回填。';
    });
  }

  Future<void> _confirmIdCardUpload() async {
    final file = _pendingIdCardFile;
    if (file == null) {
      _setIdCardUploadStatus(
        title: '身份证正面当前未选中',
        message: '请先选择身份证正面图片，再确认上传。',
      );
      return;
    }

    setState(() {
      _handlingIdCardUpload = true;
      _confirmedIdCardFrontFileId = null;
      _idCardUploadTitle = '身份证正面上传准备中';
      _idCardUploadMessage = '正在上传当前已选身份证正面图片。';
    });

    final organizationId = AppShellScope.of(
      context,
    ).snapshot.shellContext.organizationId;
    if (organizationId == null || organizationId.trim().isEmpty) {
      _setIdCardUploadStatus(
        fileName: file.fileName,
        title: '身份证正面上传当前未开始',
        message: '当前组织上下文不可用，请返回认证页后重试。',
      );
      return;
    }

    final initResult = await ProfileIdentityConsumerLayer.instance
        .initPersonalCertificationIdCardUpload(
          organizationId: organizationId,
          mimeType: file.mimeType,
          bodyBytes: file.bytes,
        );
    if (!mounted) {
      return;
    }
    if (initResult.state != AppUploadState.signedReady ||
        initResult.directive == null) {
      _setIdCardUploadStatus(
        fileName: file.fileName,
        title: '身份证正面上传当前未开始',
        message: initResult.message ?? '当前身份证正面上传入口暂不可用，请稍后再试。',
      );
      return;
    }

    final directResult = await ProfileIdentityConsumerLayer.instance
        .directPersonalCertificationIdCardUpload(
          directive: initResult.directive!,
          bodyBytes: file.bytes,
        );
    if (!mounted) {
      return;
    }
    if (directResult.state != AppUploadState.uploadConfirming) {
      _setIdCardUploadStatus(
        fileName: file.fileName,
        title: '身份证正面上传当前未完成',
        message: directResult.message ?? '当前身份证正面直传失败，请稍后再试。',
      );
      return;
    }

    final confirmResult = await ProfileIdentityConsumerLayer.instance
        .confirmPersonalCertificationIdCardUpload(
          directive: initResult.directive!,
        );
    if (!mounted) {
      return;
    }
    if (confirmResult.state != AppUploadState.uploadBound ||
        (confirmResult.fileAssetId?.trim().isEmpty ?? true)) {
      _setIdCardUploadStatus(
        fileName: file.fileName,
        title: '身份证正面确认当前未完成',
        message: confirmResult.message ?? '当前身份证正面上传确认失败，请稍后再试。',
      );
      return;
    }

    _setIdCardUploadStatus(
      fileName: file.fileName,
      title: '身份证正面已完成上传绑定',
      message: '当前已完成 init -> direct upload -> confirm，可继续提交我的认证。',
      confirmedFileAssetId: confirmResult.fileAssetId,
    );
    await _recognizeIdCardFront(organizationId, confirmResult.fileAssetId!);
  }

  void _setIdCardUploadStatus({
    String? fileName,
    required String title,
    required String message,
    String? confirmedFileAssetId,
  }) {
    setState(() {
      _handlingIdCardUpload = false;
      _selectedIdCardFileName = fileName ?? _selectedIdCardFileName;
      _idCardUploadTitle = title;
      _idCardUploadMessage = message;
      _confirmedIdCardFrontFileId = confirmedFileAssetId;
    });
  }

  Future<void> _recognizeIdCardFront(
    String organizationId,
    String fileAssetId,
  ) async {
    setState(() {
      _handlingIdCardUpload = true;
      _idCardOcrTitle = '身份证 OCR 识别中';
      _idCardOcrMessage = '正在识别身份证正面并核对姓名、身份证号摘要。';
    });

    final result = await ProfileIdentityConsumerLayer.instance
        .recognizePersonalCertificationIdCard(
          organizationId: organizationId,
          fileAssetId: fileAssetId,
        );
    if (!mounted) {
      return;
    }
    if (result.state != AppPageState.content || result.data == null) {
      setState(() {
        _handlingIdCardUpload = false;
        _idCardOcrView = null;
        _idCardOcrTitle = '身份证 OCR 当前未完成';
        _idCardOcrMessage = result.message ?? '当前身份证 OCR 暂不可用，请重新上传清晰的身份证正面。';
      });
      return;
    }

    setState(() {
      _handlingIdCardUpload = false;
      _idCardOcrView = result.data!;
      _idCardOcrTitle = result.data!.status == 'recognized'
          ? '身份证 OCR 已完成'
          : '身份证 OCR 当前未完成';
      _idCardOcrMessage = result.data!.message;
    });
  }

  Future<void> _submit() async {
    final organizationId = AppShellScope.of(
      context,
    ).snapshot.shellContext.organizationId;
    if (organizationId == null || organizationId.trim().isEmpty) {
      _showMessage('当前组织上下文不可用。');
      return;
    }
    final fileAssetId = _confirmedIdCardFrontFileId?.trim();
    if (fileAssetId == null || fileAssetId.isEmpty) {
      _showMessage('请先选择并确认上传身份证正面图片后再提交我的认证。');
      return;
    }

    setState(() {
      _submitting = true;
    });

    final result = await ProfileIdentityConsumerLayer.instance
        .submitPersonalCertification(
          organizationId: organizationId,
          fileAssetId: fileAssetId,
        );
    if (!mounted) {
      return;
    }

    if (result.state == AppPageState.content) {
      final shellController = AppShellScope.read(context);
      Navigator.of(context).pop(true);
      await shellController.reloadShellContext();
      return;
    }

    setState(() {
      _submitting = false;
    });
    _showMessage(_identityResultMessage(result.state, result.message));
  }

  @override
  Widget build(BuildContext context) {
    final current = _currentResult?.data;
    final currentPersonal = current?.personalCertification;
    final enterpriseTruthItems =
        _CertificationStatusPageState._buildCertificationCurrentTruthItems(
          current,
        );
    final personalTruthItems =
        _CertificationStatusPageState._buildPersonalCertificationTruthItems(
          currentPersonal,
        );
    final enterpriseApproved =
        current?.certificationStatus?.trim() == 'approved';
    final lockedToOtherActor = currentPersonal?.lockedToOtherActor == true;
    final submitLabel = currentPersonal?.certificationStatus == 'rejected'
        ? '重新提交我的认证'
        : '提交我的认证';

    return _CertificationCommandScaffold(
      title: submitLabel,
      summary: '竞标资格现在必须同时满足企业认证和我的认证。当前入口只承接身份证正面上传、OCR 识别和正式提交，不扩成第二套身份中心。',
      submitLabel: _submitting ? '提交中' : submitLabel,
      onSubmit:
          _submitting ||
              _handlingIdCardUpload ||
              _loadingCurrent ||
              !enterpriseApproved ||
              lockedToOtherActor
          ? null
          : _submit,
      fields: <Widget>[
        if (_loadingCurrent)
          const _IdentityInlineCard(
            title: '认证真值同步中',
            body: '正在读取当前企业认证与我的认证状态。',
          )
        else ...<Widget>[
          const _IdentityInlineCard(
            title: '竞标资格说明',
            body:
                '进入竞标前，系统会同时检查企业认证与我的认证。企业认证用于确认公司主体，我的认证用于确认当前账号就是该主体对应的法定代表人。',
          ),
          const SizedBox(height: 12),
          if (enterpriseTruthItems.isNotEmpty) ...<Widget>[
            const _IdentityInlineCard(
              title: '当前企业认证真值',
              body: '以下内容来自当前正式企业认证；我的认证会用其中的法定代表人真值做校验。',
            ),
            const SizedBox(height: 8),
            _IdentitySummaryList(items: enterpriseTruthItems),
            const SizedBox(height: 12),
          ],
          if (personalTruthItems.isNotEmpty) ...<Widget>[
            const _IdentityInlineCard(
              title: '当前我的认证真值',
              body: '如果这里已经是“当前账号已匹配”，说明双重认证中的我的认证部分已成立。',
            ),
            const SizedBox(height: 8),
            _IdentitySummaryList(items: personalTruthItems),
            const SizedBox(height: 12),
          ],
          if (!enterpriseApproved)
            const _IdentityInlineCard(
              title: '当前不能继续提交我的认证',
              body: '请先让企业认证进入“已认证”，再继续提交我的认证。',
            )
          else if (lockedToOtherActor)
            const _IdentityInlineCard(
              title: '当前不能继续提交我的认证',
              body: '当前公司的我的认证已锁定到其他账号，不支持换人。',
            )
          else
            const _IdentityInlineCard(
              title: '当前上传规则',
              body:
                  '只支持身份证正面图片。上传确认后会自动 OCR 识别姓名与身份证号摘要；提交时会校验姓名是否与企业认证中的法定代表人一致。',
            ),
          const SizedBox(height: 12),
        ],
        _buildIdCardUploadField(),
      ],
    );
  }

  Widget _buildIdCardUploadField() {
    final showUploadStateCard =
        _idCardUploadTitle != null && _idCardUploadTitle!.contains('未');
    final showOcrStateCard =
        _idCardOcrTitle != null && _idCardOcrTitle!.contains('未');
    final hasSelectedIdCard = _selectedIdCardPreviewBytes != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (showUploadStateCard && _idCardUploadMessage != null)
          _IdentityInlineCard(
            title: _idCardUploadTitle!,
            body: _idCardUploadMessage!,
          ),
        if (showOcrStateCard && _idCardOcrMessage != null) ...<Widget>[
          const SizedBox(height: 8),
          _IdentityInlineCard(
            title: _idCardOcrTitle!,
            body: _idCardOcrMessage!,
          ),
        ],
        if (_idCardOcrView != null &&
            _buildIdCardOcrSummaryItems(
              _idCardOcrView!,
            ).isNotEmpty) ...<Widget>[
          const SizedBox(height: 4),
          const _IdentityInlineCard(
            title: 'OCR识别预览',
            body: '以下内容来自身份证正面 OCR 识别结果，仅用于当前页核对；正式资格以“我的认证真值”为准。',
          ),
          _IdentitySummaryList(
            items: _buildIdCardOcrSummaryItems(_idCardOcrView!),
          ),
          const SizedBox(height: 12),
        ],
        if (_selectedIdCardFileName != null)
          _IdentityInlineCard(title: '最近选择', body: _selectedIdCardFileName!),
        if (_selectedIdCardPreviewBytes != null) ...<Widget>[
          const SizedBox(height: 12),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                setState(() {
                  _idCardPreviewExpanded = !_idCardPreviewExpanded;
                });
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutCubic,
                        width: double.infinity,
                        height: _idCardPreviewExpanded ? 420 : 220,
                        color: Theme.of(context).colorScheme.surface,
                        alignment: Alignment.center,
                        child: Image.memory(
                          _selectedIdCardPreviewBytes!,
                          fit: BoxFit.contain,
                          gaplessPlayback: true,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              _selectedIdCardFileName ?? '当前身份证正面图片预览',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _idCardPreviewExpanded
                                  ? '再次点击图片可恢复常规预览。'
                                  : '点击图片可放大查看完整身份证正面。',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            FilledButton.tonal(
              onPressed: _handlingIdCardUpload ? null : _pickIdCardFront,
              child: Text(hasSelectedIdCard ? '重新选择身份证正面' : '选择身份证正面'),
            ),
            if (hasSelectedIdCard && _confirmedIdCardFrontFileId == null)
              FilledButton(
                onPressed: _handlingIdCardUpload ? null : _confirmIdCardUpload,
                child: Text(_handlingIdCardUpload ? '上传中' : '确认上传身份证正面'),
              ),
          ],
        ),
      ],
    );
  }

  List<_IdentitySummaryItem> _buildIdCardOcrSummaryItems(
    PersonalCertificationIdCardOcrView view,
  ) {
    final items = <_IdentitySummaryItem>[
      if (view.realName?.trim().isNotEmpty ?? false)
        _IdentitySummaryItem(label: '姓名', value: view.realName!.trim()),
      if (view.idNumberMasked?.trim().isNotEmpty ?? false)
        _IdentitySummaryItem(
          label: '身份证号摘要',
          value: view.idNumberMasked!.trim(),
        ),
    ];
    return List<_IdentitySummaryItem>.unmodifiable(items);
  }
}

Future<ProfileAvatarPickSource?> _openCertificationLicenseUploadSourceSheet(
  BuildContext context,
) {
  return showModalBottomSheet<ProfileAvatarPickSource?>(
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
}

class _CertificationCommandScaffold extends StatelessWidget {
  const _CertificationCommandScaffold({
    required this.title,
    required this.summary,
    required this.submitLabel,
    required this.fields,
    required this.onSubmit,
  });

  final String title;
  final String summary;
  final String submitLabel;
  final List<Widget> fields;
  final VoidCallback? onSubmit;

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
      ],
    );
  }
}

class _IdentityHeroCard extends StatelessWidget {
  const _IdentityHeroCard({
    required this.title,
    required this.summary,
    this.showTitle = true,
  });

  final String title;
  final String summary;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    if (!showTitle) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(summary, style: Theme.of(context).textTheme.bodyLarge),
        ),
      );
    }
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

class _IdentitySummaryItem {
  const _IdentitySummaryItem({required this.label, required this.value});

  final String label;
  final String value;
}

class _IdentitySummaryList extends StatelessWidget {
  const _IdentitySummaryList({required this.items});

  final List<_IdentitySummaryItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: <Widget>[
          for (var index = 0; index < items.length; index++) ...<Widget>[
            _IdentitySummaryRow(item: items[index]),
            if (index != items.length - 1)
              Divider(height: 1, color: theme.colorScheme.outlineVariant),
          ],
        ],
      ),
    );
  }
}

class _IdentitySummaryRow extends StatelessWidget {
  const _IdentitySummaryRow({required this.item});

  final _IdentitySummaryItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 96,
            child: Text(
              item.label,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(item.value, style: theme.textTheme.bodyMedium)),
        ],
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
