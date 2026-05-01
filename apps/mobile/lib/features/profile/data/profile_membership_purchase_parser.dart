import 'profile_membership_purchase_models.dart';

ProfileMembershipPurchaseOffersView? parseMembershipPurchaseOffers(
  Object? payload,
) {
  final body = _readMap(payload);
  final rawOffers = body?['offers'];
  final context = _readMap(body?['currentOrganizationMembershipContext']);
  final channels = _readStringList(body?['channelCandidates']);
  final disclosure = _readString(body?['commercialDisclosure']);
  final updatedAt = _readString(body?['updatedAt']);
  if (body == null ||
      rawOffers is! List ||
      context == null ||
      channels == null ||
      disclosure == null ||
      updatedAt == null) {
    return null;
  }

  final offers = <ProfileMembershipPurchaseOfferView>[];
  for (final rawOffer in rawOffers) {
    final offer = _parseOffer(rawOffer);
    if (offer == null) {
      return null;
    }
    offers.add(offer);
  }

  final purchaseEligible = _readBool(context['purchaseEligible']);
  if (purchaseEligible == null) {
    return null;
  }

  return ProfileMembershipPurchaseOffersView(
    offers: List<ProfileMembershipPurchaseOfferView>.unmodifiable(offers),
    currentOrganizationMembershipContext: ProfileMembershipPurchaseContextView(
      organizationId: _readNullableString(context['organizationId']),
      paidMembershipTier: _readNullableString(context['paidMembershipTier']),
      purchaseEligible: purchaseEligible,
      ineligibleReasonCode: _readNullableString(
        context['ineligibleReasonCode'],
      ),
    ),
    channelCandidates: channels,
    commercialDisclosure: disclosure,
    updatedAt: updatedAt,
  );
}

ProfileMembershipOrderCreateView? parseMembershipOrderCreate(Object? payload) {
  final body = _readMap(payload);
  final preview = _parseSkuSnapshot(body?['entitlementPreview']);
  final channels = _readStringList(body?['channelCandidates']);
  final membershipOrderId = _readString(body?['membershipOrderId']);
  final orderStatus = _readString(body?['orderStatus']);
  final payableAmount = _readNumber(body?['payableAmount']);
  final currency = _readString(body?['currency']);
  final updatedAt = _readString(body?['updatedAt']);
  if (body == null ||
      preview == null ||
      channels == null ||
      membershipOrderId == null ||
      orderStatus == null ||
      payableAmount == null ||
      currency == null ||
      updatedAt == null) {
    return null;
  }
  return ProfileMembershipOrderCreateView(
    membershipOrderId: membershipOrderId,
    orderStatus: orderStatus,
    payableAmount: payableAmount,
    currency: currency,
    entitlementPreview: preview,
    channelCandidates: channels,
    expiresAt: _readNullableString(body['expiresAt']),
    updatedAt: updatedAt,
  );
}

ProfileMembershipPayInitView? parseMembershipPayInit(Object? payload) {
  final body = _readMap(payload);
  final membershipOrderId = _readString(body?['membershipOrderId']);
  final paymentReferenceId = _readString(body?['paymentReferenceId']);
  final channelActionType = _readString(body?['channelActionType']);
  final channelPayload = _readMap(body?['channelPayload']);
  final callbackAwaiting = _readBool(body?['callbackAwaiting']);
  final paymentInitStatus = _readString(body?['paymentInitStatus']);
  final updatedAt = _readString(body?['updatedAt']);
  if (body == null ||
      membershipOrderId == null ||
      paymentReferenceId == null ||
      channelActionType == null ||
      channelPayload == null ||
      callbackAwaiting == null ||
      paymentInitStatus == null ||
      updatedAt == null) {
    return null;
  }

  return ProfileMembershipPayInitView(
    paymentInitStatus: paymentInitStatus,
    membershipOrderId: membershipOrderId,
    paymentReferenceId: paymentReferenceId,
    channelActionType: channelActionType,
    channelPayload: Map<String, Object?>.unmodifiable(channelPayload),
    callbackAwaiting: callbackAwaiting,
    expiresAt: _readNullableString(body['expiresAt']),
    updatedAt: updatedAt,
  );
}

ProfileMembershipOrderResultView? parseMembershipOrderResult(Object? payload) {
  final body = _readMap(payload);
  final snapshot = _parseSkuSnapshot(body?['skuSnapshot']);
  final amountSummary = _readMap(body?['amountSummary']);
  final channelSummary = _readMap(body?['channelSummary']);
  final callbackAwaiting = _readBool(channelSummary?['callbackAwaiting']);
  final membershipOrderId = _readString(body?['membershipOrderId']);
  final organizationId = _readString(body?['organizationId']);
  final orderStatus = _readString(body?['orderStatus']);
  final paymentStatus = _readString(body?['paymentStatus']);
  final entitlementStatus = _readString(body?['entitlementStatus']);
  final payableAmount = _readNumber(amountSummary?['payableAmount']);
  final currency = _readString(amountSummary?['currency']);
  final updatedAt = _readString(body?['updatedAt']);
  if (body == null ||
      snapshot == null ||
      amountSummary == null ||
      channelSummary == null ||
      callbackAwaiting == null ||
      membershipOrderId == null ||
      organizationId == null ||
      orderStatus == null ||
      paymentStatus == null ||
      entitlementStatus == null ||
      payableAmount == null ||
      currency == null ||
      updatedAt == null) {
    return null;
  }

  return ProfileMembershipOrderResultView(
    membershipOrderId: membershipOrderId,
    organizationId: organizationId,
    orderStatus: orderStatus,
    paymentStatus: paymentStatus,
    entitlementStatus: entitlementStatus,
    skuSnapshot: snapshot,
    payableAmount: payableAmount,
    currency: currency,
    payChannel: _readNullableString(channelSummary['payChannel']),
    paymentReferenceId: _readNullableString(
      channelSummary['paymentReferenceId'],
    ),
    callbackAwaiting: callbackAwaiting,
    effectiveAt: _readNullableString(body['effectiveAt']),
    expiresAt: _readNullableString(body['expiresAt']),
    failureReasonCode: _readNullableString(body['failureReasonCode']),
    updatedAt: updatedAt,
  );
}

String? extractMembershipPurchaseMessage(Object? payload) {
  final body = _readMap(payload);
  return _readNullableString(body?['message']);
}

String? extractMembershipPurchaseErrorCode(Object? payload) {
  final body = _readMap(payload);
  return _readNullableString(body?['code']);
}

ProfileMembershipPurchaseOfferView? _parseOffer(Object? raw) {
  final item = _readMap(raw);
  if (item == null) {
    return null;
  }
  final skuCode = _readString(item['skuCode']);
  final skuName = _readString(item['skuName']);
  final membershipTier = _readString(item['membershipTier']);
  final durationMonths = _readInt(item['durationMonths']);
  final priceAmount = _readNumber(item['priceAmount']);
  final currency = _readString(item['currency']);
  final entitlementSummary = _readStringList(item['entitlementSummary']);
  final status = _readString(item['status']);
  if (skuCode == null ||
      skuName == null ||
      membershipTier == null ||
      durationMonths == null ||
      priceAmount == null ||
      currency == null ||
      entitlementSummary == null ||
      status == null) {
    return null;
  }

  return ProfileMembershipPurchaseOfferView(
    skuCode: skuCode,
    skuName: skuName,
    membershipTier: membershipTier,
    durationMonths: durationMonths,
    priceAmount: priceAmount,
    currency: currency,
    entitlementSummary: entitlementSummary,
    serviceFeeDiscountSummary: _readNullableString(
      item['serviceFeeDiscountSummary'],
    ),
    isRenewable: _readBool(item['isRenewable']) ?? false,
    isUpgradable: _readBool(item['isUpgradable']) ?? false,
    status: status,
  );
}

ProfileMembershipPurchaseSkuSnapshotView? _parseSkuSnapshot(Object? raw) {
  final item = _readMap(raw);
  final skuCode = _readString(item?['skuCode']);
  final skuName = _readString(item?['skuName']);
  final membershipTier = _readString(item?['membershipTier']);
  final durationMonths = _readInt(item?['durationMonths']);
  if (item == null ||
      skuCode == null ||
      skuName == null ||
      membershipTier == null ||
      durationMonths == null) {
    return null;
  }

  return ProfileMembershipPurchaseSkuSnapshotView(
    skuCode: skuCode,
    skuName: skuName,
    membershipTier: membershipTier,
    durationMonths: durationMonths,
    serviceFeeDiscountSummary: _readNullableString(
      item['serviceFeeDiscountSummary'],
    ),
  );
}

Map<String, Object?>? _readMap(Object? raw) {
  if (raw is! Map) {
    return null;
  }
  return raw.map((Object? key, Object? value) => MapEntry('$key', value));
}

String? _readString(Object? raw) {
  final value = _readNullableString(raw);
  return value == null || value.isEmpty ? null : value;
}

String? _readNullableString(Object? raw) {
  if (raw is! String) {
    return null;
  }
  final value = raw.trim();
  return value.isEmpty ? null : value;
}

bool? _readBool(Object? raw) {
  return raw is bool ? raw : null;
}

int? _readInt(Object? raw) {
  if (raw is int) {
    return raw;
  }
  if (raw is num && raw == raw.roundToDouble()) {
    return raw.toInt();
  }
  return null;
}

num? _readNumber(Object? raw) {
  if (raw is num && raw.isFinite) {
    return raw;
  }
  return null;
}

List<String>? _readStringList(Object? raw) {
  if (raw is! List) {
    return null;
  }
  return raw
      .whereType<String>()
      .map((String item) => item.trim())
      .where((String item) => item.isNotEmpty)
      .toList(growable: false);
}
