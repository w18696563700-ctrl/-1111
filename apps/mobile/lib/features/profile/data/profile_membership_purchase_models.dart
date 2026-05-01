final class ProfileMembershipPurchaseCanonicalPaths {
  const ProfileMembershipPurchaseCanonicalPaths._();

  static const String purchaseOffers =
      '/api/app/profile/membership/purchase-offers';
  static const String orders = '/api/app/profile/membership/orders';

  static String order(String membershipOrderId) {
    return '$orders/${Uri.encodeComponent(membershipOrderId)}';
  }

  static String payInit(String membershipOrderId) {
    return '${order(membershipOrderId)}/pay-init';
  }
}

class ProfileMembershipPurchaseOfferView {
  const ProfileMembershipPurchaseOfferView({
    required this.skuCode,
    required this.skuName,
    required this.membershipTier,
    required this.durationMonths,
    required this.priceAmount,
    required this.currency,
    required this.entitlementSummary,
    required this.serviceFeeDiscountSummary,
    required this.isRenewable,
    required this.isUpgradable,
    required this.status,
  });

  final String skuCode;
  final String skuName;
  final String membershipTier;
  final int durationMonths;
  final num priceAmount;
  final String currency;
  final List<String> entitlementSummary;
  final String? serviceFeeDiscountSummary;
  final bool isRenewable;
  final bool isUpgradable;
  final String status;

  bool get available => status == 'available';
}

class ProfileMembershipPurchaseContextView {
  const ProfileMembershipPurchaseContextView({
    required this.organizationId,
    required this.paidMembershipTier,
    required this.purchaseEligible,
    required this.ineligibleReasonCode,
  });

  final String? organizationId;
  final String? paidMembershipTier;
  final bool purchaseEligible;
  final String? ineligibleReasonCode;
}

class ProfileMembershipPurchaseOffersView {
  const ProfileMembershipPurchaseOffersView({
    required this.offers,
    required this.currentOrganizationMembershipContext,
    required this.channelCandidates,
    required this.commercialDisclosure,
    required this.updatedAt,
  });

  final List<ProfileMembershipPurchaseOfferView> offers;
  final ProfileMembershipPurchaseContextView
  currentOrganizationMembershipContext;
  final List<String> channelCandidates;
  final String commercialDisclosure;
  final String updatedAt;
}

class ProfileMembershipPurchaseSkuSnapshotView {
  const ProfileMembershipPurchaseSkuSnapshotView({
    required this.skuCode,
    required this.skuName,
    required this.membershipTier,
    required this.durationMonths,
    required this.serviceFeeDiscountSummary,
  });

  final String skuCode;
  final String skuName;
  final String membershipTier;
  final int durationMonths;
  final String? serviceFeeDiscountSummary;
}

class ProfileMembershipOrderCreateView {
  const ProfileMembershipOrderCreateView({
    required this.membershipOrderId,
    required this.orderStatus,
    required this.payableAmount,
    required this.currency,
    required this.entitlementPreview,
    required this.channelCandidates,
    required this.expiresAt,
    required this.updatedAt,
  });

  final String membershipOrderId;
  final String orderStatus;
  final num payableAmount;
  final String currency;
  final ProfileMembershipPurchaseSkuSnapshotView entitlementPreview;
  final List<String> channelCandidates;
  final String? expiresAt;
  final String updatedAt;
}

class ProfileMembershipPayInitView {
  const ProfileMembershipPayInitView({
    required this.paymentInitStatus,
    required this.membershipOrderId,
    required this.paymentReferenceId,
    required this.channelActionType,
    required this.channelPayload,
    required this.callbackAwaiting,
    required this.expiresAt,
    required this.updatedAt,
  });

  final String paymentInitStatus;
  final String membershipOrderId;
  final String paymentReferenceId;
  final String channelActionType;
  final Map<String, Object?> channelPayload;
  final bool callbackAwaiting;
  final String? expiresAt;
  final String updatedAt;
}

class ProfileMembershipOrderResultView {
  const ProfileMembershipOrderResultView({
    required this.membershipOrderId,
    required this.organizationId,
    required this.orderStatus,
    required this.paymentStatus,
    required this.entitlementStatus,
    required this.skuSnapshot,
    required this.payableAmount,
    required this.currency,
    required this.payChannel,
    required this.paymentReferenceId,
    required this.callbackAwaiting,
    required this.effectiveAt,
    required this.expiresAt,
    required this.failureReasonCode,
    required this.updatedAt,
  });

  final String membershipOrderId;
  final String organizationId;
  final String orderStatus;
  final String paymentStatus;
  final String entitlementStatus;
  final ProfileMembershipPurchaseSkuSnapshotView skuSnapshot;
  final num payableAmount;
  final String currency;
  final String? payChannel;
  final String? paymentReferenceId;
  final bool callbackAwaiting;
  final String? effectiveAt;
  final String? expiresAt;
  final String? failureReasonCode;
  final String updatedAt;
}
