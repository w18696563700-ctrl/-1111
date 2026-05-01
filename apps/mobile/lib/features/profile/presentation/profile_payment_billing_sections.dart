part of 'profile_detail_pages.dart';

class _PaymentBillingSummarySection extends StatelessWidget {
  const _PaymentBillingSummarySection({required this.data});

  final ProfilePaymentBillingStatusView data;

  @override
  Widget build(BuildContext context) {
    final summary = data.privateSummary;
    return _PaymentBillingSection(
      title: '一、当前摘要',
      trailing: '最近更新 ${summary.updatedAt}',
      children: <Widget>[
        _PaymentBillingInfoRow(
          icon: Icons.flag_outlined,
          iconTone: _PaymentBillingTone.gold,
          title: '当前状态',
          description: profileDisplayPaymentBillingSummaryStatus(
            summary.summaryStatus,
          ),
          badgeLabel: _summaryBadgeLabel(summary.summaryStatus),
          badgeTone: _summaryBadgeTone(summary.summaryStatus),
        ),
        _PaymentBillingInfoRow(
          icon: Icons.credit_card_outlined,
          iconTone: _PaymentBillingTone.gold,
          title: '当前支付状态',
          description: profileDisplayPaymentStatus(summary.paymentStatus),
          badgeLabel: _paymentStatusBadgeLabel(summary.paymentStatus),
          badgeTone: _paymentStatusBadgeTone(summary.paymentStatus),
        ),
        _PaymentBillingInfoRow(
          icon: Icons.receipt_long_outlined,
          iconTone: _PaymentBillingTone.red,
          title: '当前账单引用',
          description: profileDisplayBillingReferenceStatus(
            summary.billingReferenceStatus,
          ),
          badgeLabel: _billingReferenceBadgeLabel(
            summary.billingReferenceStatus,
          ),
          badgeTone: _billingReferenceBadgeTone(summary.billingReferenceStatus),
        ),
        _PaymentBillingInfoRow(
          icon: Icons.link_rounded,
          iconTone: _PaymentBillingTone.purple,
          title: '后续依赖',
          description: _paymentBillingDependencyReferenceHint(
            data.dependencyReference,
          ),
          badgeLabel: _dependencyBadgeLabel(data.dependencyReference),
          badgeTone: _PaymentBillingTone.purple,
        ),
        _PaymentBillingInfoRow(
          icon: Icons.schedule_rounded,
          iconTone: _PaymentBillingTone.blue,
          title: '最近更新',
          description: summary.updatedAt,
          badgeLabel: '提示',
          badgeTone: _PaymentBillingTone.blue,
        ),
      ],
    );
  }
}

class _PaymentBillingPaymentSection extends StatelessWidget {
  const _PaymentBillingPaymentSection({required this.data});

  final ProfilePaymentBillingStatusView data;

  @override
  Widget build(BuildContext context) {
    final payment = data.paymentStatus;
    return _PaymentBillingSection(
      title: '二、支付状态',
      children: <Widget>[
        _PaymentBillingInfoRow(
          icon: Icons.account_balance_wallet_outlined,
          iconTone: _PaymentBillingTone.gold,
          title: '当前支付状态',
          description: profileDisplayPaymentStatus(payment.paymentStatus),
          badgeLabel: _paymentStatusBadgeLabel(payment.paymentStatus),
          badgeTone: _paymentStatusBadgeTone(payment.paymentStatus),
        ),
        _PaymentBillingInfoRow(
          icon: Icons.visibility_off_outlined,
          iconTone: _PaymentBillingTone.gray,
          title: '当前可见性',
          description: profileDisplayPaymentAvailabilityStatus(
            payment.paymentAvailabilityStatus,
          ),
          badgeLabel: _paymentAvailabilityBadgeLabel(
            payment.paymentAvailabilityStatus,
          ),
          badgeTone: _paymentAvailabilityBadgeTone(
            payment.paymentAvailabilityStatus,
          ),
        ),
        _PaymentBillingInfoRow(
          icon: Icons.tips_and_updates_outlined,
          iconTone: _PaymentBillingTone.blue,
          title: '处理提示',
          description: profileDisplayPaymentBillingHandoffHint(
            payment.paymentHandoffKey,
          ),
          badgeLabel: '提示',
          badgeTone: _PaymentBillingTone.blue,
        ),
        _PaymentBillingInfoRow(
          icon: Icons.info_outline_rounded,
          iconTone: _PaymentBillingTone.blue,
          title: '说明提示',
          description: profileDisplayPaymentBillingExplanationHint(
            payment.paymentExplanationKey,
          ),
          badgeLabel: '提示',
          badgeTone: _PaymentBillingTone.blue,
        ),
        if (payment.paymentDependencyKey != null)
          _PaymentBillingInfoRow(
            icon: Icons.link_rounded,
            iconTone: _PaymentBillingTone.purple,
            title: '后续依赖',
            description: profileDisplayPaymentBillingDependencyHint(
              payment.paymentDependencyKey,
            ),
            badgeLabel: '需依赖',
            badgeTone: _PaymentBillingTone.purple,
          ),
      ],
    );
  }
}

class _PaymentBillingFundsSection extends StatelessWidget {
  const _PaymentBillingFundsSection({required this.data});

  final ProfilePaymentBillingStatusView data;

  @override
  Widget build(BuildContext context) {
    final paymentState = data.paymentStatus.paymentStatus;
    return _PaymentBillingSection(
      title: '三、资金摘要',
      children: <Widget>[
        _PaymentBillingInfoRow(
          icon: Icons.payments_outlined,
          iconTone: _PaymentBillingTone.gold,
          title: '支付',
          description: profileDisplayPaymentStatus(paymentState),
          badgeLabel: _paymentStatusBadgeLabel(paymentState),
          badgeTone: _paymentStatusBadgeTone(paymentState),
        ),
        const _PaymentBillingInfoRow(
          icon: Icons.request_quote_outlined,
          iconTone: _PaymentBillingTone.gold,
          title: '扣款',
          description: '以项目合同确认后的服务费扣取记录为准。',
          badgeLabel: '待完善',
          badgeTone: _PaymentBillingTone.gold,
        ),
        const _PaymentBillingInfoRow(
          icon: Icons.assignment_return_outlined,
          iconTone: _PaymentBillingTone.gold,
          title: '退款',
          description: '以项目诚意金或服务费的云端回读状态为准，不承诺即时到账。',
          badgeLabel: '待完善',
          badgeTone: _PaymentBillingTone.gold,
        ),
        const _PaymentBillingInfoRow(
          icon: Icons.account_balance_outlined,
          iconTone: _PaymentBillingTone.blue,
          title: '结算',
          description: '当前只展示结算摘要和对账状态，不自动打款。',
          badgeLabel: '提示',
          badgeTone: _PaymentBillingTone.blue,
        ),
      ],
    );
  }
}

class _PaymentBillingReferenceSection extends StatelessWidget {
  const _PaymentBillingReferenceSection({required this.data});

  final ProfilePaymentBillingStatusView data;

  @override
  Widget build(BuildContext context) {
    final reference = data.billingReference;
    final referenceCode = reference.billingReferenceCode;
    return _PaymentBillingSection(
      title: '四、账单引用',
      children: <Widget>[
        _PaymentBillingInfoRow(
          icon: Icons.receipt_outlined,
          iconTone: _PaymentBillingTone.blue,
          title: '当前状态',
          description: profileDisplayBillingReferenceStatus(
            reference.billingReferenceStatus,
          ),
          badgeLabel: _billingReferenceBadgeLabel(
            reference.billingReferenceStatus,
          ),
          badgeTone: _billingReferenceBadgeTone(
            reference.billingReferenceStatus,
          ),
        ),
        _PaymentBillingInfoRow(
          icon: Icons.visibility_off_outlined,
          iconTone: _PaymentBillingTone.gray,
          title: '显示状态',
          description: profileDisplayBillingReferenceVisibilityStatus(
            reference.billingReferenceVisibilityStatus,
          ),
          badgeLabel: _billingVisibilityBadgeLabel(
            reference.billingReferenceVisibilityStatus,
          ),
          badgeTone: _billingVisibilityBadgeTone(
            reference.billingReferenceVisibilityStatus,
          ),
        ),
        _PaymentBillingInfoRow(
          icon: Icons.confirmation_number_outlined,
          iconTone: _PaymentBillingTone.red,
          title: '当前引用',
          description: referenceCode ?? '当前账单引用暂未显示',
          badgeLabel: referenceCode == null ? '不可用' : '仅展示',
          badgeTone: referenceCode == null
              ? _PaymentBillingTone.red
              : _PaymentBillingTone.blue,
        ),
        _PaymentBillingInfoRow(
          icon: Icons.tips_and_updates_outlined,
          iconTone: _PaymentBillingTone.blue,
          title: '处理提示',
          description: profileDisplayPaymentBillingHandoffHint(
            reference.billingHandoffKey,
          ),
          badgeLabel: '提示',
          badgeTone: _PaymentBillingTone.blue,
        ),
        _PaymentBillingInfoRow(
          icon: Icons.info_outline_rounded,
          iconTone: _PaymentBillingTone.blue,
          title: '说明提示',
          description: profileDisplayPaymentBillingExplanationHint(
            reference.billingExplanationKey,
          ),
          badgeLabel: '提示',
          badgeTone: _PaymentBillingTone.blue,
        ),
        if (reference.billingDependencyKey != null)
          _PaymentBillingInfoRow(
            icon: Icons.link_rounded,
            iconTone: _PaymentBillingTone.purple,
            title: '后续依赖',
            description: profileDisplayPaymentBillingDependencyHint(
              reference.billingDependencyKey,
            ),
            badgeLabel: '需依赖',
            badgeTone: _PaymentBillingTone.purple,
          ),
      ],
    );
  }
}
