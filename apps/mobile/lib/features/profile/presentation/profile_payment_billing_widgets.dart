part of 'profile_detail_pages.dart';

class _PaymentBillingStatusOverview extends StatelessWidget {
  const _PaymentBillingStatusOverview({
    required this.data,
    required this.onOpenExplanation,
    required this.onOpenHandoff,
  });

  final ProfilePaymentBillingStatusView data;
  final VoidCallback onOpenExplanation;
  final VoidCallback onOpenHandoff;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFFFFBF6),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
        children: <Widget>[
          _PaymentBillingHeroCard(data: data),
          const SizedBox(height: 18),
          _PaymentBillingSummarySection(data: data),
          const SizedBox(height: 14),
          _PaymentBillingPaymentSection(data: data),
          const SizedBox(height: 14),
          _PaymentBillingFundsSection(data: data),
          const SizedBox(height: 14),
          _PaymentBillingReferenceSection(data: data),
          const SizedBox(height: 14),
          _PaymentBillingSection(
            title: '五、继续查看',
            children: <Widget>[
              _PaymentBillingInfoRow(
                icon: Icons.menu_book_outlined,
                iconTone: _PaymentBillingTone.gold,
                title: '规则说明页',
                description: '查看当前支付状态、账单引用与依赖说明',
                onTap: onOpenExplanation,
              ),
              _PaymentBillingInfoRow(
                icon: Icons.route_outlined,
                iconTone: _PaymentBillingTone.purple,
                title: '处理与衔接页',
                description: '查看当前处理方向、后续依赖与衔接说明',
                onTap: onOpenHandoff,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentBillingHeroCard extends StatelessWidget {
  const _PaymentBillingHeroCard({required this.data});

  final ProfilePaymentBillingStatusView data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = profileDisplayPaymentBillingSummaryStatus(
      data.privateSummary.summaryStatus,
    );

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFFFFF7EA), Color(0xFFFFE8BE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFEBD7B4)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x1AB77A20),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: <Widget>[
            _PaymentBillingAccountMark(theme: theme),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: const Color(0xFF17151A),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const _PaymentBillingBadge(
                        label: '待完善',
                        tone: _PaymentBillingTone.gold,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '当前支付状态、账单引用与后续衔接摘要',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6A5D4B),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _paymentBillingHeaderDetail(data),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF5D5145),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: const <Widget>[
                      _PaymentBillingMiniChip(label: '依赖：清分'),
                      _PaymentBillingMiniChip(label: '税务'),
                      _PaymentBillingMiniChip(label: '财务后台依赖'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.fact_check_outlined,
              color: Color(0xFFC9892D),
              size: 48,
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentBillingAccountMark extends StatelessWidget {
  const _PaymentBillingAccountMark({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFD49537), width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        '账',
        style: theme.textTheme.titleLarge?.copyWith(
          color: const Color(0xFF9B6418),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
