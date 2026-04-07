part of 'profile_detail_pages.dart';

class ProfileCompanyPage extends StatefulWidget {
  const ProfileCompanyPage({super.key});

  @override
  State<ProfileCompanyPage> createState() => _ProfileCompanyPageState();
}

class _ProfileCompanyPageState extends State<ProfileCompanyPage> {
  bool _loading = true;
  ProfileIdentityResult<MyOrganizationsView>? _organizationsResult;
  ProfileIdentityResult<ProfileCertificationCurrentView>? _certificationResult;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
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

  @override
  Widget build(BuildContext context) {
    final shellContext = AppShellScope.of(context).snapshot.shellContext;
    final hasSession = AppSessionStore.instance.hasAnySession;
    final organizationsResult = _organizationsResult;
    final certificationResult = _certificationResult;
    final organization = _currentOrganization(shellContext);
    final certification = _certificationResult?.data;

    if (!hasSession) {
      return _ProfileScreenStatePanel(
        title: '当前会话暂不可用',
        message: '当前没有可验证的会话，我的公司页不展示伪造企业卡片。',
        actionLabel: '进入登录入口',
        onAction: () =>
            Navigator.of(context).pushNamed(ProfileIdentityRoutes.login),
      );
    }

    if (_loading) {
      return const _ProfileScreenStatePanel(
        title: '正在读取公司信息',
        message: '正在同步当前组织与认证信息。',
      );
    }

    if (organization == null) {
      final message = _primaryMessage(
        organizationsResult: organizationsResult,
        certificationResult: certificationResult,
      );
      return _ProfileScreenStatePanel(
        title: _companyStateTitle(
          organizationsState: organizationsResult?.state,
          certification: certification,
        ),
        message: message ?? '当前账号暂时没有可见的公司与组织信息。',
        actionLabel: '去公司与组织',
        onAction: () =>
            _openIdentityRoute(ProfileIdentityRoutes.organizationHandoff),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
      children: <Widget>[
        _ProfileHeaderPanel(
          title: profileDisplayOrganizationName(organization.name),
          subtitle: profileDisplayOrganizationType(
            organization.organizationType,
          ),
          detail:
              '${profileDisplayCertificationStatus(organization.certificationStatus)} · '
              '${profileDisplayMembershipStatus(organization.membershipStatus)}',
          avatarLabel: '企',
          badgeText: '我的公司',
          supportingText: '这里展示当前公司摘要；公司与组织、公司认证与我的身份、成员管理统一从下方进入。',
        ),
        const SizedBox(height: 18),
        _ProfileListSection(
          title: '公司信息',
          children: <Widget>[
            _ProfileValueRow(
              title: '公司名称',
              value: profileDisplayOrganizationName(organization.name),
            ),
            _ProfileValueRow(
              title: '组织类型',
              value: profileDisplayOrganizationType(
                organization.organizationType,
              ),
            ),
            _ProfileValueRow(
              title: '当前身份',
              value: profileDisplayRoleSummary(organization.roleKeys),
            ),
            _ProfileValueRow(
              title: '成员状态',
              value: profileDisplayMembershipStatus(
                organization.membershipStatus,
              ),
            ),
            _ProfileValueRow(
              title: '认证状态',
              value: profileDisplayCertificationStatus(
                certification?.certificationStatus ??
                    organization.certificationStatus,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _ProfileListSection(
          title: '认证资料',
          children: <Widget>[
            _ProfileValueRow(
              title: '认证主体',
              value: profileValueOrFallback(
                certification?.legalName,
                _certificationFieldFallback(certificationResult),
              ),
            ),
            _ProfileValueRow(
              title: '统一社会信用代码',
              value: profileValueOrFallback(
                certification?.uscc,
                _certificationFieldFallback(certificationResult),
              ),
            ),
            _ProfileValueRow(
              title: '提交时间',
              value: profileValueOrFallback(
                certification?.submittedAt,
                _certificationFieldFallback(certificationResult),
              ),
            ),
            _ProfileValueRow(
              title: '有效期',
              value: profileValueOrFallback(
                certification?.expiresAt,
                _certificationFieldFallback(certificationResult),
              ),
            ),
            if (certification?.rejectReason != null)
              _ProfileValueRow(
                title: '拒绝原因',
                value: certification!.rejectReason!,
              ),
          ],
        ),
        if (_needsCertificationSubmit(certification)) ...<Widget>[
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(
              onPressed: () => _openIdentityRoute(
                certification?.certificationStatus == 'rejected' ||
                        certification?.certificationStatus == 'expired'
                    ? ProfileIdentityRoutes.certificationResubmit
                    : ProfileIdentityRoutes.certificationSubmit,
              ),
              child: Text(
                certification?.certificationStatus == 'rejected' ||
                        certification?.certificationStatus == 'expired'
                    ? '重新提交认证'
                    : '提交认证',
              ),
            ),
          ),
        ],
        const SizedBox(height: 14),
        _ProfileListSection(
          title: '可进行的操作',
          children: <Widget>[
            _ProfileActionRow(
              title: '公司与组织',
              subtitle: '创建公司/组织、加入公司/组织或切换当前公司/组织',
              onTap: () =>
                  _openIdentityRoute(ProfileIdentityRoutes.organizationHandoff),
            ),
            _ProfileActionRow(
              title: '公司认证与我的身份',
              subtitle: _certificationHandoffSummary(certification),
              onTap: () => _openIdentityRoute(
                ProfileIdentityRoutes.certificationCurrent,
              ),
            ),
            _ProfileActionRow(
              title: '成员管理',
              subtitle: '查看成员列表并处理最小角色调整与禁用',
              onTap: () => showOrganizationMembersSheet(context),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _openIdentityRoute(String routeName) async {
    await Navigator.of(context).pushNamed(routeName);
    if (!mounted) {
      return;
    }
    await _load();
  }

  MyOrganizationItemView? _currentOrganization(
    AppShellContextData shellContext,
  ) {
    final items = _organizationsResult?.data?.items;
    if (items == null || items.isEmpty) {
      return null;
    }
    final currentId = shellContext.organizationId?.trim();
    for (final item in items) {
      if (item.current) {
        return item;
      }
      if (currentId != null &&
          currentId.isNotEmpty &&
          item.organizationId == currentId) {
        return item;
      }
    }
    return items.first;
  }

  String? _primaryMessage({
    required ProfileIdentityResult<MyOrganizationsView>? organizationsResult,
    required ProfileIdentityResult<ProfileCertificationCurrentView>?
    certificationResult,
  }) {
    final organizationMessage = organizationsResult == null
        ? null
        : profileVisibleReadMessage(
            state: organizationsResult.state,
            rawMessage: organizationsResult.message,
            surfaceLabel: '公司信息',
          );
    final certificationMessage = certificationResult == null
        ? null
        : profileVisibleReadMessage(
            state: certificationResult.state,
            rawMessage: certificationResult.message,
            surfaceLabel: '认证信息',
          );
    final certificationStatus = certificationResult?.data?.certificationStatus;
    final certificationStatusLabel =
        (certificationStatus?.trim().isEmpty ?? true)
        ? null
        : profileDisplayCertificationStatus(certificationStatus);
    if (organizationsResult?.state == AppPageState.content ||
        organizationsResult?.state == AppPageState.empty) {
      if (certificationStatusLabel != null) {
        final suffix = certificationMessage == null
            ? ''
            : '；${certificationMessage.trim()}';
        return '组织上下文当前不可用。当前认证状态：$certificationStatusLabel$suffix';
      }
      return certificationMessage ?? '组织上下文当前不可用。';
    }
    return organizationMessage ?? certificationMessage;
  }

  static String _companyStateTitle({
    required AppPageState? organizationsState,
    required ProfileCertificationCurrentView? certification,
  }) {
    if (organizationsState == AppPageState.unauthorized) {
      return '当前会话未授权';
    }
    if (organizationsState == AppPageState.forbidden) {
      return '组织上下文未开放';
    }
    if (organizationsState == AppPageState.notFound ||
        organizationsState == AppPageState.errorNonRetryable) {
      return '组织上下文暂不可用';
    }
    if ((certification?.organizationId?.trim().isNotEmpty ?? false)) {
      return '组织摘要当前未闭环';
    }
    return '当前还没有我的公司';
  }

  static String _certificationFieldFallback(
    ProfileIdentityResult<ProfileCertificationCurrentView>? result,
  ) {
    if (result == null) {
      return '认证信息暂不可用';
    }
    if (result.state != AppPageState.content) {
      return '认证信息暂不可用';
    }
    return '暂未补充';
  }

  static bool _needsCertificationSubmit(
    ProfileCertificationCurrentView? certification,
  ) {
    return switch (certification?.certificationStatus?.trim()) {
      null || '' || 'not_submitted' || 'rejected' || 'expired' => true,
      _ => false,
    };
  }

  static String _certificationHandoffSummary(
    ProfileCertificationCurrentView? certification,
  ) {
    return switch (certification?.certificationStatus?.trim()) {
      'rejected' => '当前认证未通过，可补充后重新提交',
      'expired' => '当前认证已过期，可补充最新材料后重新提交',
      'pending_review' => '当前认证审核中，可查看当前成员身份与组织状态',
      'approved' => '当前认证已通过，可查看成员身份与当前组织状态',
      _ => '查看当前公司认证状态、我的身份与可继续办理的认证动作',
    };
  }
}
