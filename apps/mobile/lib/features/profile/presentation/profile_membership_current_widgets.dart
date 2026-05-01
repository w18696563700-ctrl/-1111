part of 'profile_detail_pages.dart';

class _MembershipStatusOverview extends StatelessWidget {
  const _MembershipStatusOverview();

  @override
  Widget build(BuildContext context) {
    return _MembershipSection(
      title: '功能状态',
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final itemWidth = (constraints.maxWidth - 12) / 2;
          const cards = <Widget>[
            _MembershipStatusMiniCard(
              icon: Icons.check_circle_outline,
              color: Color(0xFF22C55E),
              title: '当前已完成',
              value: '全部 4 项',
            ),
            _MembershipStatusMiniCard(
              icon: Icons.schedule_rounded,
              color: Color(0xFFF59E0B),
              title: '当前未完成',
              value: '2 项',
            ),
            _MembershipStatusMiniCard(
              icon: Icons.layers_rounded,
              color: Color(0xFF3B82F6),
              title: '依赖项',
              value: '1 项',
            ),
            _MembershipStatusMiniCard(
              icon: Icons.lock_outline_rounded,
              color: Color(0xFF8B5CF6),
              title: '后续开启条件',
              value: '1 项',
            ),
          ];
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: cards
                .map((Widget child) => SizedBox(width: itemWidth, child: child))
                .toList(growable: false),
          );
        },
      ),
    );
  }
}

class _MembershipStatusMiniCard extends StatelessWidget {
  const _MembershipStatusMiniCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: _membershipCardDecoration(),
      child: Column(
        children: <Widget>[
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(title, style: theme.textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MembershipStatusDetails extends StatelessWidget {
  const _MembershipStatusDetails();

  @override
  Widget build(BuildContext context) {
    return _MembershipListCard(
      title: '功能详情',
      children: const <Widget>[
        _MembershipInfoRow(
          icon: Icons.check_circle,
          iconColor: Color(0xFF22C55E),
          title: '当前已完成',
          value: '会员当前态、权益摘要、配额摘要、说明/配额/升级引导页。',
        ),
        _MembershipInfoRow(
          icon: Icons.schedule,
          iconColor: Color(0xFFF59E0B),
          title: '当前未完成',
          value: '支付沙箱验收未完成；续费、取消、退款、发票、KA/旗舰仍关闭。',
        ),
        _MembershipInfoRow(
          icon: Icons.layers,
          iconColor: Color(0xFF3B82F6),
          title: '当前依赖项',
          value: '会员真值、组织 scope、Server 订单与支付回调。',
        ),
        _MembershipInfoRow(
          icon: Icons.lock_outline,
          iconColor: Color(0xFF8B5CF6),
          title: '后续开启条件',
          value: 'Admin 查询、支付治理与发布门禁解锁。',
        ),
      ],
    );
  }
}

class _MembershipInfoCard extends StatelessWidget {
  const _MembershipInfoCard({required this.data});

  final ProfileMembershipCurrentView data;

  @override
  Widget build(BuildContext context) {
    return _MembershipListCard(
      title: '会员信息',
      children: <Widget>[
        _MembershipInfoRow(
          icon: Icons.workspace_premium_outlined,
          iconColor: _membershipGold,
          title: '会员档位',
          value: profileDisplayPaidMembershipTier(data.paidMembershipTier),
        ),
        _MembershipInfoRow(
          icon: Icons.account_balance_wallet_outlined,
          iconColor: const Color(0xFF3B82F6),
          title: '服务费优惠',
          value: profileValueOrFallback(
            data.serviceFeeDiscountSummary,
            '当前暂未提供',
          ),
        ),
        _MembershipInfoRow(
          icon: Icons.event_available_outlined,
          iconColor: const Color(0xFF3B82F6),
          title: '生效时间',
          value: profileValueOrFallback(data.effectiveAt, '当前暂未提供'),
        ),
        _MembershipInfoRow(
          icon: Icons.event_busy_outlined,
          iconColor: const Color(0xFF3B82F6),
          title: '到期时间',
          value: profileValueOrFallback(data.expiresAt, '当前暂未提供'),
        ),
        _MembershipInfoRow(
          icon: Icons.sync_rounded,
          iconColor: const Color(0xFF22C55E),
          title: '下次刷新',
          value: profileValueOrFallback(data.nextRefreshAt, '当前暂未提供'),
        ),
      ],
    );
  }
}

class _MembershipEntitlementCard extends StatelessWidget {
  const _MembershipEntitlementCard({required this.data});

  final ProfileMembershipCurrentView data;

  @override
  Widget build(BuildContext context) {
    final entitlementRows = <Widget>[
      if (data.serviceFeeDiscountSummary != null)
        _MembershipInfoRow(
          icon: Icons.pie_chart_rounded,
          iconColor: _membershipGold,
          title: '费率减免',
          value: data.serviceFeeDiscountSummary!,
        ),
      for (final item in data.entitlementsSummary)
        _MembershipInfoRow(
          icon: item.contains('曝光')
              ? Icons.star_rounded
              : Icons.bar_chart_rounded,
          iconColor: item.contains('曝光')
              ? const Color(0xFF8B5CF6)
              : const Color(0xFF3B82F6),
          title: '当前权益',
          value: item,
        ),
    ];
    return _MembershipListCard(
      title: '权益摘要',
      children: entitlementRows.isEmpty
          ? const <Widget>[
              _MembershipInfoRow(
                icon: Icons.info_outline,
                iconColor: Color(0xFF66736B),
                title: '当前权益',
                value: '当前暂未提供',
              ),
            ]
          : entitlementRows,
    );
  }
}

class _MembershipQuotaSummaryCard extends StatelessWidget {
  const _MembershipQuotaSummaryCard({required this.data});

  final ProfileMembershipCurrentView data;

  @override
  Widget build(BuildContext context) {
    return _MembershipListCard(
      title: '配额摘要',
      children: data.quotaSummary.isEmpty
          ? const <Widget>[
              _MembershipInfoRow(
                icon: Icons.wallet_outlined,
                iconColor: Color(0xFF22C55E),
                title: '当前配额',
                value: '当前暂未提供。后续将根据会员档位与支付主线开放。',
              ),
            ]
          : data.quotaSummary
                .map(
                  (String item) => _MembershipInfoRow(
                    icon: Icons.wallet_outlined,
                    iconColor: const Color(0xFF22C55E),
                    title: '当前配额',
                    value: item,
                  ),
                )
                .toList(growable: false),
    );
  }
}

class _MembershipContinueCard extends StatelessWidget {
  const _MembershipContinueCard();

  @override
  Widget build(BuildContext context) {
    return _MembershipListCard(
      title: '继续查看',
      children: <Widget>[
        _ProfileActionRow(
          title: '权益说明页',
          subtitle: '查看当前档位说明、权益说明与配额说明',
          leadingIcon: Icons.description_outlined,
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
          leadingIcon: Icons.account_balance_wallet_outlined,
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
          leadingIcon: Icons.trending_up_rounded,
          onTap: () => Navigator.of(context).push(
            _profileMembershipRoute(
              title: '升级引导',
              child: const ProfileMembershipUpgradeGuidePage(),
            ),
          ),
        ),
      ],
    );
  }
}

class _MembershipSection extends StatelessWidget {
  const _MembershipSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[_MembershipSectionTitle(title), child],
    );
  }
}

class _MembershipListCard extends StatelessWidget {
  const _MembershipListCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = <Widget>[];
    for (var index = 0; index < children.length; index += 1) {
      if (index > 0) {
        rows.add(Divider(height: 1, color: theme.colorScheme.outlineVariant));
      }
      rows.add(children[index]);
    }
    return _MembershipSection(
      title: title,
      child: DecoratedBox(
        decoration: _membershipCardDecoration(),
        child: Column(children: rows),
      ),
    );
  }
}

class _MembershipSectionTitle extends StatelessWidget {
  const _MembershipSectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: const Color(0xFF14211B),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MembershipInfoRow extends StatelessWidget {
  const _MembershipInfoRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 17,
            backgroundColor: iconColor.withValues(alpha: 0.12),
            child: Icon(icon, size: 19, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _membershipCardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(22),
    border: Border.all(color: const Color(0xFFE8E1D6)),
    boxShadow: <BoxShadow>[
      BoxShadow(
        color: const Color(0xFF8A6A3D).withValues(alpha: 0.06),
        blurRadius: 18,
        offset: const Offset(0, 10),
      ),
    ],
  );
}
