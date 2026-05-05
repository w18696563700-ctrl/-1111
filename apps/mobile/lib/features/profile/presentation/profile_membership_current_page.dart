part of 'profile_detail_pages.dart';

const Color _membershipWarmBackground = Color(0xFFFFFAF3);
const Color _membershipGold = Color(0xFFB77A2A);
const Color _membershipGoldSoft = Color(0xFFFFE6C3);

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
      return AppPageStateView(
        state: AppPageState.unauthorized,
        title: '当前会话暂不可用',
        message: '当前没有可验证的会话，我的会员页不展示伪造会员状态。',
        retryLabel: '进入登录入口',
        onRetry: () =>
            Navigator.of(context).pushNamed(ProfileIdentityRoutes.login),
        content: const SizedBox.shrink(),
      );
    }

    final result = _result;
    final data = result?.data;
    if (_loading || result == null) {
      return const AppPageStateView(
        state: AppPageState.loading,
        title: '正在读取会员状态',
        message: '正在同步当前会员档位、权益摘要与配额摘要。',
        content: SizedBox.shrink(),
      );
    }
    if (result.state != AppPageState.content || data == null) {
      return AppPageStateView(
        state: result.state,
        title: '我的会员当前暂不可用',
        message: profileVisibleReadMessage(
          state: result.state,
          rawMessage: result.message,
          surfaceLabel: '我的会员',
        ),
        retryLabel: '重试',
        onRetry: result.state == AppPageState.errorRetryable ? _load : null,
        content: const SizedBox.shrink(),
      );
    }

    return ColoredBox(
      color: _membershipWarmBackground,
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 112),
          children: <Widget>[
            _MembershipHeroCard(data: data),
            const SizedBox(height: 18),
            const _MembershipStatusOverview(),
            const SizedBox(height: 14),
            const _MembershipStatusDetails(),
            const SizedBox(height: 18),
            _MembershipInfoCard(data: data),
            const SizedBox(height: 18),
            _MembershipEntitlementCard(data: data),
            const SizedBox(height: 18),
            _MembershipQuotaSummaryCard(data: data),
            const SizedBox(height: 18),
            const _MembershipContinueCard(),
          ],
        ),
      ),
    );
  }
}

class _MembershipHeroCard extends StatelessWidget {
  const _MembershipHeroCard({required this.data});

  final ProfileMembershipCurrentView data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPaidTier = data.paidMembershipTier != null;
    final title = profileDisplayPaidMembershipTier(data.paidMembershipTier);
    final subtitle = data.serviceFeeDiscountSummary ?? '当前未开通付费会员折扣';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFFFFF8EC), Color(0xFFFFE9C5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFF0D6AE)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: _membershipGold.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF14211B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _membershipGoldSoft, width: 2),
            ),
            child: const Icon(
              Icons.workspace_premium,
              color: _membershipGoldSoft,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF14211B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _MembershipBadge(label: hasPaidTier ? '当前会员' : '未开通'),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF4F5A55),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  data.serviceFeeDiscountSummary != null ? '费率减免' : '会员说明',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: _membershipGold,
                    fontWeight: FontWeight.w800,
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

class _MembershipBadge extends StatelessWidget {
  const _MembershipBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _membershipGoldSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: _membershipGold,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
