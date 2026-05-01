part of 'profile_detail_pages.dart';

const double _profileCreditSectionGap = 18;
const double _profileCreditBottomRunway = 172;

class _ProfileCreditConstraintsStatusContent extends StatelessWidget {
  const _ProfileCreditConstraintsStatusContent({required this.data});

  final ProfileCreditConstraintsStatusView data;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        16,
        18,
        16,
        _profileCreditBottomRunway,
      ),
      children: <Widget>[
        _ProfileCreditHeroCard(data: data),
        const SizedBox(height: _profileCreditSectionGap),
        const _ProfileCreditSectionHeader(title: '功能状态总览'),
        const SizedBox(height: 12),
        _ProfileCreditFeatureGrid(
          items: <_ProfileCreditFeatureCardData>[
            _ProfileCreditFeatureCardData(
              icon: Icons.check_circle_rounded,
              title: '已完成',
              value: profileCreditConstraintsFeatureStatus.completedSummary,
              tone: _ProfileCreditTone.green,
            ),
            _ProfileCreditFeatureCardData(
              icon: Icons.hourglass_bottom_rounded,
              title: '未完成',
              value: profileCreditConstraintsFeatureStatus.incompleteSummary,
              tone: _ProfileCreditTone.gold,
            ),
            _ProfileCreditFeatureCardData(
              icon: Icons.link_rounded,
              title: '依赖项',
              value: profileCreditConstraintsFeatureStatus.dependencySummary,
              tone: _ProfileCreditTone.purple,
            ),
            _ProfileCreditFeatureCardData(
              icon: Icons.lock_clock_rounded,
              title: '开启条件',
              value:
                  profileCreditConstraintsFeatureStatus.unlockConditionSummary,
              tone: _ProfileCreditTone.blue,
            ),
          ],
        ),
        const SizedBox(height: _profileCreditSectionGap),
        _ProfileCreditSectionCard(
          icon: Icons.dashboard_customize_rounded,
          title: '当前摘要',
          tone: _ProfileCreditTone.gold,
          rows: _profileCreditSummaryRows(data),
        ),
        const SizedBox(height: _profileCreditSectionGap),
        _ProfileCreditSectionCard(
          icon: Icons.verified_user_rounded,
          title: '信用约束',
          tone: _ProfileCreditTone.green,
          rows: _profileCreditConstraintRows(data.creditConstraint),
        ),
        const SizedBox(height: _profileCreditSectionGap),
        _ProfileCreditSectionCard(
          icon: Icons.account_balance_wallet_rounded,
          title: '保证金姿态',
          tone: _ProfileCreditTone.gold,
          rows: _profileCreditDepositRows(data),
        ),
        const SizedBox(height: _profileCreditSectionGap),
        _ProfileCreditSectionCard(
          icon: Icons.gpp_good_rounded,
          title: '交易保障姿态',
          tone: _ProfileCreditTone.blue,
          rows: _profileCreditGuaranteeRows(data),
        ),
        const SizedBox(height: _profileCreditSectionGap),
        const _ProfileCreditSectionHeader(title: '继续查看'),
        const SizedBox(height: 12),
        _ProfileCreditActionCard(
          icon: Icons.menu_book_rounded,
          title: '规则说明页',
          subtitle: '查看当前信用、保证金与交易保障规则说明',
          onTap: () => Navigator.of(context).push(
            _profileCreditConstraintsRoute(
              title: '规则说明',
              child: const ProfileCreditConstraintsExplanationPage(),
            ),
          ),
        ),
        const SizedBox(height: _profileCreditCardGap),
        _ProfileCreditActionCard(
          icon: Icons.alt_route_rounded,
          title: '处理与衔接页',
          subtitle: '查看当前处理方向、后续依赖与衔接说明',
          onTap: () => Navigator.of(context).push(
            _profileCreditConstraintsRoute(
              title: '处理与衔接',
              child: const ProfileCreditConstraintsHandoffPage(),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileCreditHeroCard extends StatelessWidget {
  const _ProfileCreditHeroCard({required this.data});

  final ProfileCreditConstraintsStatusView data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summary = data.privateSummary;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFFFFFBF4), Color(0xFFFFEBC8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF0D9B0)),
        boxShadow: AppVisualTokens.shadowCard(opacity: 0.06),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      Text(
                        '我的信用与约束',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppVisualTokens.textPrimary,
                        ),
                      ),
                      _ProfileCreditBadge(
                        label:
                            profileCreditConstraintsFeatureStatus.statusLabel,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profileDisplayCreditConstraintsSummaryStatus(
                      summary.summaryStatus,
                    ),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: _profileCreditToneColors(
                        _profileCreditSummaryTone(summary.summaryStatus),
                      ).foreground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _profileCreditHeroSummary(data),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppVisualTokens.textSecondary,
                      height: 1.42,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      _ProfileCreditInlineChip(
                        icon: Icons.link_rounded,
                        label: _profileCreditDependencyReferenceHint(
                          data.dependencyReference,
                        ),
                        tone:
                            (data.dependencyReference?.dependencyRequired ??
                                false)
                            ? _ProfileCreditTone.purple
                            : _ProfileCreditTone.gray,
                      ),
                      _ProfileCreditInlineChip(
                        icon: Icons.schedule_rounded,
                        label: summary.updatedAt,
                        tone: _ProfileCreditTone.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '当前页面只承接 status / explanation / handoff 只读 posture，不执行缴纳、冻结、退款、结算或交易保障开通。',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppVisualTokens.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const _ProfileCreditHeroArtwork(),
          ],
        ),
      ),
    );
  }
}

class _ProfileCreditHeroArtwork extends StatelessWidget {
  const _ProfileCreditHeroArtwork();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 112,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned(
            top: 6,
            right: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.78),
                shape: BoxShape.circle,
                boxShadow: AppVisualTokens.shadowSoft(opacity: 0.08),
              ),
              child: const Padding(
                padding: EdgeInsets.all(15),
                child: Icon(
                  Icons.shield_rounded,
                  size: 34,
                  color: AppVisualTokens.brandGold,
                ),
              ),
            ),
          ),
          Positioned(
            left: 2,
            bottom: 4,
            child: Transform.rotate(
              angle: -0.09,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFF0D9B0)),
                  boxShadow: AppVisualTokens.shadowSoft(opacity: 0.08),
                ),
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(12, 14, 12, 12),
                  child: Icon(
                    Icons.fact_check_rounded,
                    size: 34,
                    color: AppVisualTokens.brandGoldDark,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
