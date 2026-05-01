part of 'profile_detail_pages.dart';

const double _reserveSectionGap = 18;
const double _reserveCardGap = 12;
const double _reserveBottomRunway = 156;

class _ProfileOrganizationCreditScoringStatusContent extends StatelessWidget {
  const _ProfileOrganizationCreditScoringStatusContent({required this.data});

  final OrganizationCreditScoringStatusView data;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, _reserveBottomRunway),
      children: <Widget>[
        _ProfileOrganizationCreditScoringHeroCard(data: data),
        const SizedBox(height: _reserveSectionGap),
        const _ProfileReserveSectionHeader(title: '当前概览'),
        const SizedBox(height: 12),
        _ProfileReserveOverviewGrid(
          items: <_ProfileReserveInfoCardData>[
            _ProfileReserveInfoCardData(
              icon: Icons.star_rounded,
              title: '评分',
              value: _reserveOverviewScoreLabel(data.score),
              tone: data.score == null
                  ? _ProfileReserveTone.gray
                  : _ProfileReserveTone.gold,
            ),
            _ProfileReserveInfoCardData(
              icon: Icons.qr_code_2_rounded,
              title: '档位编码',
              value: _reserveValueOrFallback(data.tierCode),
              tone: data.tierCode == null
                  ? _ProfileReserveTone.gray
                  : _ProfileReserveTone.gold,
            ),
            _ProfileReserveInfoCardData(
              icon: Icons.sell_rounded,
              title: '档位标签',
              value: _reserveValueOrFallback(data.tierLabel),
              tone: data.tierLabel == null
                  ? _ProfileReserveTone.gray
                  : _ProfileReserveTone.gold,
            ),
            _ProfileReserveInfoCardData(
              icon: Icons.layers_rounded,
              title: '样本状态',
              value: _reserveSampleStatusLabel(data.sampleStatus),
              tone: _reserveSampleTone(data.sampleStatus),
            ),
            _ProfileReserveInfoCardData(
              icon: Icons.warning_amber_rounded,
              title: '风险姿态',
              value: _reserveRiskPostureLabel(data.riskPosture),
              tone: _reserveRiskTone(data.riskPosture),
            ),
            _ProfileReserveInfoCardData(
              icon: Icons.assignment_turned_in_rounded,
              title: '可执行状态',
              value: _reserveActionableStateLabel(data.actionableState),
              tone: _reserveActionableTone(data.actionableState),
            ),
          ],
        ),
        const SizedBox(height: _reserveSectionGap),
        const _ProfileReserveSectionHeader(title: '当前统计'),
        const SizedBox(height: 12),
        _ProfileReserveStatsGrid(
          items: <_ProfileReserveStatCardData>[
            _ProfileReserveStatCardData(
              icon: Icons.task_alt_rounded,
              title: '已评分完成订单数',
              value: data.ratedCompletedOrderCount.toString(),
              tone: _ProfileReserveTone.gold,
            ),
            _ProfileReserveStatCardData(
              icon: Icons.trending_up_rounded,
              title: '正向率',
              value: _reserveStatusRateLabel(data.positiveRate),
              tone: data.positiveRate == null
                  ? _ProfileReserveTone.gray
                  : _ProfileReserveTone.blue,
            ),
            _ProfileReserveStatCardData(
              icon: Icons.trending_down_rounded,
              title: '负向率',
              value: _reserveStatusRateLabel(data.negativeRate),
              tone: data.negativeRate == null
                  ? _ProfileReserveTone.gray
                  : _ProfileReserveTone.red,
            ),
            _ProfileReserveStatCardData(
              icon: Icons.sentiment_very_satisfied_rounded,
              title: '非常满意',
              value: data.verySatisfiedCount.toString(),
              tone: _ProfileReserveTone.green,
            ),
            _ProfileReserveStatCardData(
              icon: Icons.sentiment_satisfied_rounded,
              title: '满意',
              value: data.satisfiedCount.toString(),
              tone: _ProfileReserveTone.green,
            ),
            _ProfileReserveStatCardData(
              icon: Icons.sentiment_neutral_rounded,
              title: '可接受',
              value: data.passableCount.toString(),
              tone: _ProfileReserveTone.amber,
            ),
            _ProfileReserveStatCardData(
              icon: Icons.sentiment_dissatisfied_rounded,
              title: '负向',
              value: data.negativeCount.toString(),
              tone: _ProfileReserveTone.red,
            ),
            _ProfileReserveStatCardData(
              icon: Icons.schedule_rounded,
              title: '最近更新',
              value: profileDisplayTimeLabel(data.updatedAt, fallback: '时间未知'),
              tone: _ProfileReserveTone.blue,
            ),
          ],
        ),
        const SizedBox(height: _reserveSectionGap),
        const _ProfileReserveSectionHeader(title: '继续查看'),
        const SizedBox(height: 12),
        _ProfileReserveActionCard(
          icon: Icons.menu_book_rounded,
          title: '说明页',
          subtitle: '了解组织信用评分 reserve 的规则说明',
          onTap: () => Navigator.of(context).push(
            _profileOrganizationCreditScoringRoute(
              title: '组织信用评分说明',
              child: const ProfileOrganizationCreditScoringExplanationPage(),
            ),
          ),
        ),
        const SizedBox(height: _reserveCardGap),
        _ProfileReserveActionCard(
          icon: Icons.link_rounded,
          title: '衔接页',
          subtitle: '查看 future-mainline reserve 与 current V2.1 的衔接边界',
          onTap: () => Navigator.of(context).push(
            _profileOrganizationCreditScoringRoute(
              title: '组织信用评分衔接',
              child: const ProfileOrganizationCreditScoringHandoffPage(),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileOrganizationCreditScoringHeroCard extends StatelessWidget {
  const _ProfileOrganizationCreditScoringHeroCard({required this.data});

  final OrganizationCreditScoringStatusView data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                        '组织信用评分',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppVisualTokens.textPrimary,
                        ),
                      ),
                      _ProfileReserveBadge(label: 'future-mainline reserve'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _reserveHeroPrimaryLine(data.score),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppVisualTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _reserveHeroSecondaryLine(data),
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
                      _ProfileReserveInlineChip(
                        icon: Icons.inventory_2_outlined,
                        label: '已评分完成订单 ${data.ratedCompletedOrderCount}',
                      ),
                      _ProfileReserveInlineChip(
                        icon: Icons.schedule_rounded,
                        label: profileDisplayTimeLabel(
                          data.updatedAt,
                          fallback: '时间未知',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '当前页面仅承接 future-mainline reserve read surface，与 current V2.1 并行隔离。',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppVisualTokens.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const _ProfileReserveHeroArtwork(),
          ],
        ),
      ),
    );
  }
}

class _ProfileReserveHeroArtwork extends StatelessWidget {
  const _ProfileReserveHeroArtwork();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      height: 132,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned(
            top: 8,
            right: 8,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                shape: BoxShape.circle,
                boxShadow: AppVisualTokens.shadowSoft(opacity: 0.08),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Icon(
                  Icons.verified_user_rounded,
                  size: 36,
                  color: AppVisualTokens.brandGold,
                ),
              ),
            ),
          ),
          Positioned(
            left: 10,
            bottom: 0,
            child: Transform.rotate(
              angle: -0.12,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFF0D9B0)),
                  boxShadow: AppVisualTokens.shadowSoft(opacity: 0.08),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.query_stats_rounded,
                        size: 30,
                        color: AppVisualTokens.brandGold,
                      ),
                      SizedBox(height: 8),
                      _ProfileReserveHeroBarRow(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Positioned(
            top: 0,
            left: 6,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 18,
              color: AppVisualTokens.brandGold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileReserveHeroBarRow extends StatelessWidget {
  const _ProfileReserveHeroBarRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: const <Widget>[
        _ProfileReserveHeroBar(height: 12),
        SizedBox(width: 4),
        _ProfileReserveHeroBar(height: 18),
        SizedBox(width: 4),
        _ProfileReserveHeroBar(height: 22),
        SizedBox(width: 4),
        _ProfileReserveHeroBar(height: 16),
      ],
    );
  }
}

class _ProfileReserveHeroBar extends StatelessWidget {
  const _ProfileReserveHeroBar({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: height,
      decoration: BoxDecoration(
        color: AppVisualTokens.brandGold.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _ProfileReserveSectionHeader extends StatelessWidget {
  const _ProfileReserveSectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: <Widget>[
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppVisualTokens.brandGold,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppVisualTokens.textPrimary,
          ),
        ),
      ],
    );
  }
}
