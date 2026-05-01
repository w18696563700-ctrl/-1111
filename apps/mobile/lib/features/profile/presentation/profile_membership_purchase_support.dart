part of 'profile_detail_pages.dart';

String _membershipPurchaseOfferTitle(ProfileMembershipPurchaseOfferView offer) {
  return '${profileDisplayPaidMembershipTier(offer.membershipTier)} · ${offer.skuName}';
}

String _membershipPurchaseOfferSubtitle(
  ProfileMembershipPurchaseOfferView offer,
) {
  return <String>[
    _membershipPurchasePriceText(offer),
    offer.serviceFeeDiscountSummary ?? '服务费优惠当前暂未提供',
    if (!offer.isRenewable) '续费暂不开通',
    if (offer.isUpgradable) '支持后续升级引导',
  ].join(' · ');
}

String _membershipPurchasePriceText(ProfileMembershipPurchaseOfferView offer) {
  return '${_membershipMoney(offer.priceAmount, offer.currency)} / ${offer.durationMonths} 个月';
}

String _membershipMoney(num amount, String currency) {
  final normalized = amount == amount.roundToDouble()
      ? amount.toInt().toString()
      : amount.toStringAsFixed(2);
  return currency == 'CNY' ? '$normalized 元' : '$currency $normalized';
}

String _membershipPaymentResultSubtitle(
  ProfileMembershipResult<ProfileMembershipPayInitView> result,
) {
  if (result.state != AppPageState.content || result.data == null) {
    return '支付初始化未完成，请查看错误并稍后重试。';
  }
  return result.data!.callbackAwaiting
      ? '支付已初始化，等待支付通道回调后生效。'
      : '支付已初始化，当前不等待回调。';
}

String _membershipStatusLabel(String status) {
  return switch (status.trim()) {
    'created' => '已创建',
    'pending_payment' => '待支付',
    'paid' => '已支付',
    'active' => '已生效',
    'failed' => '失败',
    'cancelled' => '已取消',
    'expired' => '已过期',
    'not_started' => '未开始',
    'pending_callback' => '等待回调',
    'pending' => '处理中',
    final String other when other.isNotEmpty => other,
    _ => '当前暂未提供',
  };
}
