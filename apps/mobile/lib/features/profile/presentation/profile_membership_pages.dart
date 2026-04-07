part of 'profile_detail_pages.dart';

Future<void> openProfileMembershipCurrentPage(BuildContext context) {
  return Navigator.of(context).push(
    _profileMembershipRoute(
      title: '我的会员',
      child: const ProfileMembershipCurrentPage(),
    ),
  );
}

Route<void> _profileMembershipRoute({
  required String title,
  required Widget child,
}) {
  return MaterialPageRoute<void>(
    builder: (_) => AppShellScaffold(
      currentBuilding: AppBuilding.profile,
      titleOverride: title,
      showStageBanner: false,
      child: child,
    ),
  );
}

class ProfileMembershipCurrentPage extends StatefulWidget {
  const ProfileMembershipCurrentPage({super.key});

  @override
  State<ProfileMembershipCurrentPage> createState() =>
      _ProfileMembershipCurrentPageState();
}

class _ProfileMembershipCurrentPageState
    extends State<ProfileMembershipCurrentPage> {
  bool _loading = true;
  ProfileMembershipResult<ProfileMembershipCurrentView>? _result;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await ProfileMembershipConsumerLayer.instance.loadCurrent();
    if (!mounted) {
      return;
    }
    setState(() {
      _result = result;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!AppSessionStore.instance.hasAnySession) {
      return _ProfileScreenStatePanel(
        title: '当前会话暂不可用',
        message: '当前没有可验证的会话，我的会员页不展示伪造会员状态。',
        actionLabel: '进入登录入口',
        onAction: () =>
            Navigator.of(context).pushNamed(ProfileIdentityRoutes.login),
      );
    }

    final result = _result;
    final data = result?.data;
    if (_loading || result == null) {
      return const _ProfileScreenStatePanel(
        title: '正在读取会员状态',
        message: '正在同步当前会员档位、权益摘要与配额摘要。',
      );
    }
    if (result.state != AppPageState.content || data == null) {
      return _ProfileScreenStatePanel(
        title: '我的会员当前暂不可用',
        message: profileVisibleReadMessage(
          state: result.state,
          rawMessage: result.message,
          surfaceLabel: '我的会员',
        ),
        actionLabel: result.state == AppPageState.errorRetryable ? '重试' : null,
        onAction: result.state == AppPageState.errorRetryable ? _load : null,
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: <Widget>[
          _ProfileHeaderPanel(
            title: profileDisplayPaidMembershipTier(data.paidMembershipTier),
            subtitle: data.rateBand?.trim().isNotEmpty ?? false
                ? '费率档位：${data.rateBand}'
                : '当前会员状态与最小权益摘要',
            detail: _membershipCurrentHeaderDetail(data),
            avatarLabel: '会',
          ),
          const SizedBox(height: 18),
          _ProfileListSection(
            title: '当前状态',
            children: <Widget>[
              _ProfileValueRow(
                title: '会员档位',
                value: profileDisplayPaidMembershipTier(
                  data.paidMembershipTier,
                ),
              ),
              if (data.rateBand != null)
                _ProfileValueRow(title: '费率档位', value: data.rateBand!),
              _ProfileValueRow(
                title: '生效时间',
                value: profileValueOrFallback(data.effectiveAt, '当前暂未提供'),
              ),
              _ProfileValueRow(
                title: '到期时间',
                value: profileValueOrFallback(data.expiresAt, '当前暂未提供'),
              ),
              _ProfileValueRow(
                title: '下次刷新',
                value: profileValueOrFallback(data.nextRefreshAt, '当前暂未提供'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ProfileListSection(
            title: '权益摘要',
            children: data.entitlementsSummary.isEmpty
                ? const <Widget>[
                    _ProfileValueRow(title: '当前权益', value: '当前暂未提供'),
                  ]
                : data.entitlementsSummary
                      .map(
                        (String item) =>
                            _ProfileValueRow(title: '当前权益', value: item),
                      )
                      .toList(growable: false),
          ),
          const SizedBox(height: 14),
          _ProfileListSection(
            title: '配额摘要',
            children: data.quotaSummary.isEmpty
                ? const <Widget>[
                    _ProfileValueRow(title: '当前配额', value: '当前暂未提供'),
                  ]
                : data.quotaSummary
                      .map(
                        (String item) =>
                            _ProfileValueRow(title: '当前配额', value: item),
                      )
                      .toList(growable: false),
          ),
          const SizedBox(height: 14),
          _ProfileListSection(
            title: '继续查看',
            children: <Widget>[
              _ProfileActionRow(
                title: '权益说明页',
                subtitle: '查看当前档位说明、权益说明与配额说明',
                onTap: () => Navigator.of(context).push(
                  _profileMembershipRoute(
                    title: '权益说明',
                    child: const ProfileMembershipExplanationPage(),
                  ),
                ),
              ),
              _ProfileActionRow(
                title: '配额说明页',
                subtitle: '查看当前额度摘要与刷新规则',
                onTap: () => Navigator.of(context).push(
                  _profileMembershipRoute(
                    title: '配额说明',
                    child: const ProfileMembershipQuotaPage(),
                  ),
                ),
              ),
              _ProfileActionRow(
                title: '升级引导页',
                subtitle: '查看当前档位、可选档位与非交易化升级说明',
                onTap: () => Navigator.of(context).push(
                  _profileMembershipRoute(
                    title: '升级引导',
                    child: const ProfileMembershipUpgradeGuidePage(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _membershipCurrentHeaderDetail(
    ProfileMembershipCurrentView data,
  ) {
    final pieces = <String>[
      if (data.entitlementsSummary.isNotEmpty) data.entitlementsSummary.first,
      if (data.quotaSummary.isNotEmpty) data.quotaSummary.first,
      if (data.nextRefreshAt != null) '下次刷新 ${data.nextRefreshAt}',
    ];
    if (pieces.isEmpty) {
      return '当前只承接最小会员档位、权益摘要与配额摘要。';
    }
    return pieces.join(' · ');
  }
}

class ProfileMembershipExplanationPage extends StatefulWidget {
  const ProfileMembershipExplanationPage({super.key});

  @override
  State<ProfileMembershipExplanationPage> createState() =>
      _ProfileMembershipExplanationPageState();
}

class _ProfileMembershipExplanationPageState
    extends State<ProfileMembershipExplanationPage> {
  bool _loading = true;
  ProfileMembershipResult<ProfileMembershipExplanationView>? _result;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await ProfileMembershipConsumerLayer.instance
        .loadExplanation();
    if (!mounted) {
      return;
    }
    setState(() {
      _result = result;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final data = result?.data;
    if (_loading || result == null) {
      return const _ProfileScreenStatePanel(
        title: '正在读取权益说明',
        message: '正在同步当前档位说明与权益说明。',
      );
    }
    if (result.state != AppPageState.content || data == null) {
      return _ProfileScreenStatePanel(
        title: '权益说明当前暂不可用',
        message: profileVisibleReadMessage(
          state: result.state,
          rawMessage: result.message,
          surfaceLabel: '权益说明页',
        ),
        actionLabel: result.state == AppPageState.errorRetryable ? '重试' : null,
        onAction: result.state == AppPageState.errorRetryable ? _load : null,
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: <Widget>[
          _ProfileListSection(
            title: '档位说明',
            children: data.tiers
                .map(
                  (MembershipExplanationTierItemView item) => _ProfileValueRow(
                    title:
                        '${profileDisplayPaidMembershipTier(item.tier)} · ${item.title}',
                    value: item.highlights.isEmpty
                        ? '当前暂未提供'
                        : item.highlights.join('、'),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 14),
          _ProfileListSection(
            title: '权益说明',
            children: data.entitlementNotes
                .map(
                  (String item) => _ProfileValueRow(title: '权益说明', value: item),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 14),
          _ProfileListSection(
            title: '配额说明',
            children: data.quotaNotes
                .map(
                  (String item) => _ProfileValueRow(title: '配额说明', value: item),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 14),
          _ProfileListSection(
            title: '当前说明',
            children: <Widget>[
              _ProfileValueRow(title: '说明', value: data.disclaimer),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfileMembershipQuotaPage extends StatefulWidget {
  const ProfileMembershipQuotaPage({super.key});

  @override
  State<ProfileMembershipQuotaPage> createState() =>
      _ProfileMembershipQuotaPageState();
}

class _ProfileMembershipQuotaPageState
    extends State<ProfileMembershipQuotaPage> {
  bool _loading = true;
  ProfileMembershipResult<ProfileMembershipQuotaView>? _result;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await ProfileMembershipConsumerLayer.instance.loadQuota();
    if (!mounted) {
      return;
    }
    setState(() {
      _result = result;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final data = result?.data;
    if (_loading || result == null) {
      return const _ProfileScreenStatePanel(
        title: '正在读取配额说明',
        message: '正在同步当前会员额度摘要与刷新规则。',
      );
    }
    if (result.state != AppPageState.content || data == null) {
      return _ProfileScreenStatePanel(
        title: '配额说明当前暂不可用',
        message: profileVisibleReadMessage(
          state: result.state,
          rawMessage: result.message,
          surfaceLabel: '配额说明页',
        ),
        actionLabel: result.state == AppPageState.errorRetryable ? '重试' : null,
        onAction: result.state == AppPageState.errorRetryable ? _load : null,
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: <Widget>[
          _ProfileListSection(
            title: '当前额度',
            children: data.items
                .map(
                  (MembershipQuotaItemView item) => _ProfileValueRow(
                    title: item.summary,
                    value:
                        <String>[
                          if (item.currentValue != null)
                            '当前剩余 ${item.currentValue}',
                          if (item.refreshRule != null)
                            '刷新规则：${item.refreshRule}',
                        ].join(' · ').trim().isEmpty
                        ? item.quotaType
                        : <String>[
                            if (item.currentValue != null)
                              '当前剩余 ${item.currentValue}',
                            if (item.refreshRule != null)
                              '刷新规则：${item.refreshRule}',
                          ].join(' · '),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 14),
          _ProfileListSection(
            title: '下次刷新',
            children: <Widget>[
              _ProfileValueRow(
                title: '刷新时间',
                value: profileValueOrFallback(data.nextRefreshAt, '当前暂未提供'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfileMembershipUpgradeGuidePage extends StatefulWidget {
  const ProfileMembershipUpgradeGuidePage({super.key});

  @override
  State<ProfileMembershipUpgradeGuidePage> createState() =>
      _ProfileMembershipUpgradeGuidePageState();
}

class _ProfileMembershipUpgradeGuidePageState
    extends State<ProfileMembershipUpgradeGuidePage> {
  bool _loading = true;
  ProfileMembershipResult<ProfileMembershipUpgradeGuideView>? _result;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await ProfileMembershipConsumerLayer.instance
        .loadUpgradeGuide();
    if (!mounted) {
      return;
    }
    setState(() {
      _result = result;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final data = result?.data;
    if (_loading || result == null) {
      return const _ProfileScreenStatePanel(
        title: '正在读取升级引导',
        message: '正在同步当前档位与可选升级说明。',
      );
    }
    if (result.state != AppPageState.content || data == null) {
      return _ProfileScreenStatePanel(
        title: '升级引导当前暂不可用',
        message: profileVisibleReadMessage(
          state: result.state,
          rawMessage: result.message,
          surfaceLabel: '升级引导页',
        ),
        actionLabel: result.state == AppPageState.errorRetryable ? '重试' : null,
        onAction: result.state == AppPageState.errorRetryable ? _load : null,
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: <Widget>[
          _ProfileListSection(
            title: '当前档位',
            children: <Widget>[
              _ProfileValueRow(
                title: '当前会员档位',
                value: profileDisplayPaidMembershipTier(data.currentTier),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ProfileListSection(
            title: '可选档位',
            children: data.availableTiers
                .map(
                  (MembershipUpgradeGuideTierItemView item) => _ProfileValueRow(
                    title:
                        '${profileDisplayPaidMembershipTier(item.tier)} · ${item.title}',
                    value:
                        <String>[
                          if (item.candidateDisplayPrice != null)
                            item.candidateDisplayPrice!,
                          if (item.candidateDisplayRateBand != null)
                            '费率档位：${item.candidateDisplayRateBand!}',
                        ].join(' · ').trim().isEmpty
                        ? '当前暂未提供'
                        : <String>[
                            if (item.candidateDisplayPrice != null)
                              item.candidateDisplayPrice!,
                            if (item.candidateDisplayRateBand != null)
                              '费率档位：${item.candidateDisplayRateBand!}',
                          ].join(' · '),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 14),
          _ProfileListSection(
            title: '升级说明',
            children: data.upgradeHighlights
                .map(
                  (String item) => _ProfileValueRow(title: '升级说明', value: item),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 14),
          _ProfileListSection(
            title: '当前说明',
            children: <Widget>[
              _ProfileValueRow(title: '说明', value: data.commercialDisclosure),
            ],
          ),
        ],
      ),
    );
  }
}
