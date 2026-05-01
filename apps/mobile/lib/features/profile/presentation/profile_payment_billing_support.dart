part of 'profile_detail_pages.dart';

String _paymentBillingHeaderDetail(ProfilePaymentBillingStatusView data) {
  final pieces = <String>[
    profileDisplayPaymentStatus(data.privateSummary.paymentStatus),
    profileDisplayBillingReferenceStatus(
      data.privateSummary.billingReferenceStatus,
    ),
    if (data.dependencyReference?.dependencyRequired ?? false)
      _paymentBillingDependencyReferenceHint(data.dependencyReference),
  ];
  return pieces.join(' · ');
}

String _paymentBillingDependencyReferenceHint(
  PaymentBillingDependencyReferenceView? dependencyReference,
) {
  if (dependencyReference == null || !dependencyReference.dependencyRequired) {
    return '当前暂不需要额外依赖';
  }
  return '依赖 ${profileDisplayPaymentBillingDependencyFamily(dependencyReference.dependencyFamilyKey)}';
}

String _summaryBadgeLabel(String? state) {
  return switch (state?.trim()) {
    'unavailable' || 'reference_unavailable' => '不可用',
    'reference_visible' => '仅展示',
    _ => '待完善',
  };
}

_PaymentBillingTone _summaryBadgeTone(String? state) {
  return switch (state?.trim()) {
    'unavailable' || 'reference_unavailable' => _PaymentBillingTone.red,
    'reference_visible' => _PaymentBillingTone.blue,
    _ => _PaymentBillingTone.gold,
  };
}

String _paymentStatusBadgeLabel(String? state) {
  return switch (state?.trim()) {
    'unavailable' => '不可用',
    _ => '待完善',
  };
}

_PaymentBillingTone _paymentStatusBadgeTone(String? state) {
  return state?.trim() == 'unavailable'
      ? _PaymentBillingTone.red
      : _PaymentBillingTone.gold;
}

String _paymentAvailabilityBadgeLabel(String? state) {
  return switch (state?.trim()) {
    'unavailable' => '不可见',
    _ => '仅展示',
  };
}

_PaymentBillingTone _paymentAvailabilityBadgeTone(String? state) {
  return state?.trim() == 'unavailable'
      ? _PaymentBillingTone.gray
      : _PaymentBillingTone.blue;
}

String _billingReferenceBadgeLabel(String? state) {
  return switch (state?.trim()) {
    'available' => '仅展示',
    _ => '不可用',
  };
}

_PaymentBillingTone _billingReferenceBadgeTone(String? state) {
  return state?.trim() == 'available'
      ? _PaymentBillingTone.blue
      : _PaymentBillingTone.red;
}

String _billingVisibilityBadgeLabel(String? state) {
  return switch (state?.trim()) {
    'visible' => '仅展示',
    _ => '不可见',
  };
}

_PaymentBillingTone _billingVisibilityBadgeTone(String? state) {
  return state?.trim() == 'visible'
      ? _PaymentBillingTone.blue
      : _PaymentBillingTone.gray;
}

String _dependencyBadgeLabel(
  PaymentBillingDependencyReferenceView? dependencyReference,
) {
  return dependencyReference?.dependencyRequired ?? false ? '需依赖' : '提示';
}
