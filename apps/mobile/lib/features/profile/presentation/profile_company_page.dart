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
    final resolvedCertificationStatus = _resolvedCertificationStatus(
      organization: organization,
      certification: certification,
    );
    final certificationStatusLabel = profileDisplayCertificationStatus(
      resolvedCertificationStatus,
    );
    final membershipStatusLabel = profileDisplayMembershipStatus(
      organization?.membershipStatus ?? shellContext.membershipStatus,
    );
    final routeIsFirst = ModalRoute.of(context)?.isFirst ?? false;
    final primaryMessage = _primaryMessage(
      organizationsResult: organizationsResult,
      certificationResult: certificationResult,
    );

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

    if (organization == null &&
        !_canRenderCompanyWorkspace(organizationsResult)) {
      return _ProfileScreenStatePanel(
        title: _companyStateTitle(
          organizationsState: organizationsResult?.state,
          certification: certification,
        ),
        message: primaryMessage ?? '当前账号暂时没有可见的公司与组织信息。',
        actionLabel: '公司与组织',
        onAction: () =>
            _openIdentityRoute(ProfileIdentityRoutes.organizationHandoff),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
      children: <Widget>[
        _ProfileCompanySummaryPanel(
          title: organization == null
              ? _companyStateTitle(
                  organizationsState: organizationsResult?.state,
                  certification: certification,
                )
              : profileDisplayOrganizationName(organization.name),
          subtitle: organization == null
              ? '创建组织或加入已有组织后，这里会成为当前公司工作台'
              : profileDisplayOrganizationType(organization.organizationType),
          statusText: organization == null
              ? (primaryMessage ?? '当前还没有可见的公司主体，可先创建组织或加入已有组织。')
              : '',
          avatarLabel: '企',
          statusBadges: organization == null
              ? <String>[certificationStatusLabel, membershipStatusLabel]
              : profileBuildOrganizationStatusBadges(
                  roleKeys: organization.roleKeys,
                  membershipStatus: organization.membershipStatus,
                  certificationStatus: resolvedCertificationStatus,
                ),
          message: organization == null
              ? '这里保留当前公司摘要入口，并从公司与组织、公司认证与我的身份继续后续办理。创建或加入成功后，组织与认证详情统一在后续页面查看。'
              : '这里保留当前公司摘要入口；组织现状与认证资料统一放到公司与组织、公司认证与我的身份页查看，避免同一信息重复铺开。',
        ),
        if (organization != null &&
            routeIsFirst &&
            resolvedCertificationStatus?.trim() != 'approved') ...<Widget>[
          const SizedBox(height: 18),
          _ProfileListSection(
            title: '直接继续',
            children: <Widget>[
              _ProfileActionRow(
                title: '编辑当前组织',
                subtitle: '继续修改当前组织名称、地区与联系人等基础资料',
                leadingIcon: Icons.edit_rounded,
                emphasized: true,
                onTap: () => _openIdentityRoute(
                  ProfileIdentityRoutes.organizationCreate,
                ),
              ),
              _ProfileActionRow(
                title: '再创建一个组织',
                subtitle: '在当前账号下继续新增一个独立组织主体',
                leadingIcon: Icons.add_business_rounded,
                onTap: () => _openIdentityRoute(
                  ProfileIdentityRoutes.organizationCreateWithMode(
                    'create_another',
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 18),
        _ProfileListSection(
          title: '可进行的操作',
          children: <Widget>[
            _ProfileActionRow(
              tileKey: const ValueKey<String>(
                'profile-company-action-organization',
              ),
              title: '公司与组织',
              subtitle: _organizationHandoffSummary(
                organizationExists: organization != null,
              ),
              leadingIcon: Icons.apartment_rounded,
              emphasized: true,
              onTap: () =>
                  _openIdentityRoute(ProfileIdentityRoutes.organizationHandoff),
            ),
            _ProfileActionRow(
              tileKey: const ValueKey<String>(
                'profile-company-action-certification',
              ),
              title: '公司认证与我的身份',
              subtitle: _certificationHandoffSummary(certification),
              leadingIcon: Icons.verified_user_rounded,
              emphasized: true,
              onTap: () => _openIdentityRoute(
                ProfileIdentityRoutes.certificationCurrent,
              ),
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
    if (currentId != null && currentId.isNotEmpty) {
      for (final item in items) {
        if (item.organizationId == currentId) {
          return item;
        }
      }
    }
    for (final item in items) {
      if (item.current) {
        return item;
      }
    }
    return items.first;
  }

  String? _resolvedCertificationStatus({
    required MyOrganizationItemView? organization,
    required ProfileCertificationCurrentView? certification,
  }) {
    final certificationOrganizationId = certification?.organizationId?.trim();
    final currentOrganizationId = organization?.organizationId.trim();
    final certificationStatus = certification?.certificationStatus?.trim();
    if (organization != null &&
        certificationOrganizationId != null &&
        certificationOrganizationId.isNotEmpty &&
        certificationOrganizationId == currentOrganizationId &&
        certificationStatus != null &&
        certificationStatus.isNotEmpty) {
      return certificationStatus;
    }
    return organization?.certificationStatus ??
        certification?.certificationStatus;
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
    switch (organizationsState) {
      case AppPageState.unauthorized:
        return '当前会话未授权';
      case AppPageState.forbidden:
        return '组织上下文未开放';
      case AppPageState.notFound:
        return '公司信息暂不可用';
      case AppPageState.errorRetryable:
        return '公司信息暂时没有加载成功';
      case AppPageState.errorNonRetryable:
        return '公司信息当前暂不可用';
      case AppPageState.content:
      case AppPageState.empty:
        if (certification?.organizationId?.trim().isNotEmpty ?? false) {
          return '组织摘要当前未闭环';
        }
        return '当前还没有我的公司';
      case AppPageState.loading:
        return '正在读取公司信息';
      case null:
        return '公司信息当前暂不可用';
    }
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

  static String _organizationHandoffSummary({
    required bool organizationExists,
  }) {
    if (!organizationExists) {
      return '从这里进入公司与组织，继续创建组织、加入组织或确认当前主体。';
    }
    return '从这里进入公司与组织，继续编辑当前组织、再创建一个组织、加入组织或切换当前公司/组织。';
  }

  static bool _canRenderCompanyWorkspace(
    ProfileIdentityResult<MyOrganizationsView>? result,
  ) {
    return result?.state == AppPageState.content ||
        result?.state == AppPageState.empty;
  }
}

class _ProfileCompanySummaryPanel extends StatelessWidget {
  const _ProfileCompanySummaryPanel({
    required this.title,
    required this.subtitle,
    required this.statusText,
    required this.statusBadges,
    required this.message,
    required this.avatarLabel,
  });

  final String title;
  final String subtitle;
  final String statusText;
  final List<String> statusBadges;
  final String message;
  final String avatarLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = theme.colorScheme.primary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: Text(
                    avatarLabel,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (statusBadges.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: statusBadges
                          .where((String item) => item.trim().isNotEmpty)
                          .map(
                            (String item) => DecoratedBox(
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                child: Text(
                                  item,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ],
                  if (statusText.trim().isNotEmpty) ...<Widget>[
                    const SizedBox(height: 10),
                    Text(
                      statusText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
