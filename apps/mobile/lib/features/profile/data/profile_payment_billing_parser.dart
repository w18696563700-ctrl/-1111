import 'package:mobile/features/profile/data/profile_payment_billing_models.dart';

final class ProfilePaymentBillingPayloadParser {
  const ProfilePaymentBillingPayloadParser._();

  static ProfilePaymentBillingStatusView? parseStatusView(Object? payload) {
    final body = _map(payload);
    if (body == null) {
      return null;
    }
    final privateSummary = _parsePrivateSummary(body['privateSummary']);
    final paymentStatus = _parsePaymentStatus(body['paymentStatus']);
    final billingReference = _parseBillingReference(body['billingReference']);
    if (privateSummary == null ||
        paymentStatus == null ||
        billingReference == null) {
      return null;
    }
    return ProfilePaymentBillingStatusView(
      privateSummary: privateSummary,
      paymentStatus: paymentStatus,
      billingReference: billingReference,
      dependencyReference: _parseDependencyReference(
        body['dependencyReference'],
      ),
    );
  }

  static ProfilePaymentBillingExplanationView? parseExplanationView(
    Object? payload,
  ) {
    final body = _map(payload);
    if (body == null) {
      return null;
    }
    final paymentExplanation = _parseExplanationBlock(
      body['paymentExplanation'],
    );
    final billingExplanation = _parseExplanationBlock(
      body['billingExplanation'],
    );
    final disclaimer = _readRequiredString(body['disclaimer']);
    if (paymentExplanation == null ||
        billingExplanation == null ||
        disclaimer == null) {
      return null;
    }
    return ProfilePaymentBillingExplanationView(
      paymentExplanation: paymentExplanation,
      billingExplanation: billingExplanation,
      dependencyExplanation: _parseDependencyExplanation(
        body['dependencyExplanation'],
      ),
      disclaimer: disclaimer,
    );
  }

  static ProfilePaymentBillingHandoffView? parseHandoffView(Object? payload) {
    final body = _map(payload);
    if (body == null) {
      return null;
    }
    final paymentHandoff = _parsePaymentHandoff(body['paymentHandoff']);
    final billingHandoff = _parseBillingHandoff(body['billingHandoff']);
    if (paymentHandoff == null || billingHandoff == null) {
      return null;
    }
    return ProfilePaymentBillingHandoffView(
      paymentHandoff: paymentHandoff,
      billingHandoff: billingHandoff,
      dependencyHandoff: _parseDependencyHandoff(body['dependencyHandoff']),
    );
  }

  static String? extractMessage(Object? body) {
    final map = _map(body);
    return _readRequiredString(map?['message']);
  }

  static String? extractErrorCode(Object? body) {
    final map = _map(body);
    return _readRequiredString(map?['code']);
  }

  static PaymentBillingPrivateSummaryView? _parsePrivateSummary(
    Object? payload,
  ) {
    final body = _map(payload);
    final entryKey = _readRequiredString(body?['entryKey']);
    final summaryStatus = _readRequiredString(body?['summaryStatus']);
    final paymentStatus = _readRequiredString(body?['paymentStatus']);
    final billingReferenceStatus = _readRequiredString(
      body?['billingReferenceStatus'],
    );
    final updatedAt = _readRequiredString(body?['updatedAt']);
    if (entryKey == null ||
        summaryStatus == null ||
        paymentStatus == null ||
        billingReferenceStatus == null ||
        updatedAt == null) {
      return null;
    }
    return PaymentBillingPrivateSummaryView(
      entryKey: entryKey,
      summaryStatus: summaryStatus,
      paymentStatus: paymentStatus,
      billingReferenceStatus: billingReferenceStatus,
      updatedAt: updatedAt,
    );
  }

  static PaymentStatusView? _parsePaymentStatus(Object? payload) {
    final body = _map(payload);
    final paymentStatus = _readRequiredString(body?['paymentStatus']);
    final paymentAvailabilityStatus = _readRequiredString(
      body?['paymentAvailabilityStatus'],
    );
    final paymentHandoffKey = _readRequiredString(body?['paymentHandoffKey']);
    final paymentExplanationKey = _readRequiredString(
      body?['paymentExplanationKey'],
    );
    final updatedAt = _readRequiredString(body?['updatedAt']);
    if (paymentStatus == null ||
        paymentAvailabilityStatus == null ||
        paymentHandoffKey == null ||
        paymentExplanationKey == null ||
        updatedAt == null) {
      return null;
    }
    return PaymentStatusView(
      paymentStatus: paymentStatus,
      paymentAvailabilityStatus: paymentAvailabilityStatus,
      paymentHandoffKey: paymentHandoffKey,
      paymentExplanationKey: paymentExplanationKey,
      paymentDependencyKey: _readNullableString(body?['paymentDependencyKey']),
      updatedAt: updatedAt,
    );
  }

  static BillingReferenceView? _parseBillingReference(Object? payload) {
    final body = _map(payload);
    final billingReferenceStatus = _readRequiredString(
      body?['billingReferenceStatus'],
    );
    final billingReferenceVisibilityStatus = _readRequiredString(
      body?['billingReferenceVisibilityStatus'],
    );
    final billingExplanationKey = _readRequiredString(
      body?['billingExplanationKey'],
    );
    final billingHandoffKey = _readRequiredString(body?['billingHandoffKey']);
    final updatedAt = _readRequiredString(body?['updatedAt']);
    if (billingReferenceStatus == null ||
        billingReferenceVisibilityStatus == null ||
        billingExplanationKey == null ||
        billingHandoffKey == null ||
        updatedAt == null) {
      return null;
    }
    return BillingReferenceView(
      billingReferenceStatus: billingReferenceStatus,
      billingReferenceCode: _readNullableString(body?['billingReferenceCode']),
      billingReferenceVisibilityStatus: billingReferenceVisibilityStatus,
      billingExplanationKey: billingExplanationKey,
      billingHandoffKey: billingHandoffKey,
      billingDependencyKey: _readNullableString(body?['billingDependencyKey']),
      updatedAt: updatedAt,
    );
  }

  static PaymentBillingDependencyReferenceView? _parseDependencyReference(
    Object? payload,
  ) {
    if (payload == null) {
      return null;
    }
    final body = _map(payload);
    final dependencyFamilyKey = _readRequiredString(
      body?['dependencyFamilyKey'],
    );
    final dependencyRequired = _readRequiredBool(body?['dependencyRequired']);
    final dependencyExplanationKey = _readRequiredString(
      body?['dependencyExplanationKey'],
    );
    final dependencyHandoffKey = _readRequiredString(
      body?['dependencyHandoffKey'],
    );
    if (dependencyFamilyKey == null ||
        dependencyRequired == null ||
        dependencyExplanationKey == null ||
        dependencyHandoffKey == null) {
      return null;
    }
    return PaymentBillingDependencyReferenceView(
      dependencyFamilyKey: dependencyFamilyKey,
      dependencyRequired: dependencyRequired,
      dependencyExplanationKey: dependencyExplanationKey,
      dependencyHandoffKey: dependencyHandoffKey,
    );
  }

  static PaymentBillingExplanationBlockView? _parseExplanationBlock(
    Object? payload,
  ) {
    final body = _map(payload);
    final explanationKey = _readRequiredString(body?['explanationKey']);
    final title = _readRequiredString(body?['title']);
    final bodyText = _readRequiredString(body?['body']);
    if (explanationKey == null || title == null || bodyText == null) {
      return null;
    }
    return PaymentBillingExplanationBlockView(
      explanationKey: explanationKey,
      title: title,
      body: bodyText,
    );
  }

  static PaymentBillingDependencyExplanationView? _parseDependencyExplanation(
    Object? payload,
  ) {
    if (payload == null) {
      return null;
    }
    final body = _map(payload);
    final dependencyFamilyKey = _readRequiredString(
      body?['dependencyFamilyKey'],
    );
    final dependencyRequired = _readRequiredBool(body?['dependencyRequired']);
    final dependencyExplanationKey = _readRequiredString(
      body?['dependencyExplanationKey'],
    );
    final title = _readRequiredString(body?['title']);
    final bodyText = _readRequiredString(body?['body']);
    if (dependencyFamilyKey == null ||
        dependencyRequired == null ||
        dependencyExplanationKey == null ||
        title == null ||
        bodyText == null) {
      return null;
    }
    return PaymentBillingDependencyExplanationView(
      dependencyFamilyKey: dependencyFamilyKey,
      dependencyRequired: dependencyRequired,
      dependencyExplanationKey: dependencyExplanationKey,
      title: title,
      body: bodyText,
    );
  }

  static PaymentBillingHandoffView? _parsePaymentHandoff(Object? payload) {
    final body = _map(payload);
    final paymentHandoffKey = _readRequiredString(body?['paymentHandoffKey']);
    final handoffStatus = _readRequiredString(body?['handoffStatus']);
    final handoffTargetFamily = _readRequiredString(
      body?['handoffTargetFamily'],
    );
    final handoffExplanationKey = _readRequiredString(
      body?['handoffExplanationKey'],
    );
    final dependencyRequired = _readRequiredBool(body?['dependencyRequired']);
    final title = _readRequiredString(body?['title']);
    final bodyText = _readRequiredString(body?['body']);
    final updatedAt = _readRequiredString(body?['updatedAt']);
    if (paymentHandoffKey == null ||
        handoffStatus == null ||
        handoffTargetFamily == null ||
        handoffExplanationKey == null ||
        dependencyRequired == null ||
        title == null ||
        bodyText == null ||
        updatedAt == null) {
      return null;
    }
    return PaymentBillingHandoffView(
      paymentHandoffKey: paymentHandoffKey,
      handoffStatus: handoffStatus,
      handoffTargetFamily: handoffTargetFamily,
      handoffExplanationKey: handoffExplanationKey,
      dependencyRequired: dependencyRequired,
      title: title,
      body: bodyText,
      updatedAt: updatedAt,
    );
  }

  static BillingHandoffView? _parseBillingHandoff(Object? payload) {
    final body = _map(payload);
    final billingHandoffKey = _readRequiredString(body?['billingHandoffKey']);
    final title = _readRequiredString(body?['title']);
    final bodyText = _readRequiredString(body?['body']);
    final updatedAt = _readRequiredString(body?['updatedAt']);
    if (billingHandoffKey == null ||
        title == null ||
        bodyText == null ||
        updatedAt == null) {
      return null;
    }
    return BillingHandoffView(
      billingHandoffKey: billingHandoffKey,
      title: title,
      body: bodyText,
      updatedAt: updatedAt,
    );
  }

  static PaymentBillingDependencyHandoffView? _parseDependencyHandoff(
    Object? payload,
  ) {
    if (payload == null) {
      return null;
    }
    final body = _map(payload);
    final dependencyFamilyKey = _readRequiredString(
      body?['dependencyFamilyKey'],
    );
    final dependencyRequired = _readRequiredBool(body?['dependencyRequired']);
    final dependencyHandoffKey = _readRequiredString(
      body?['dependencyHandoffKey'],
    );
    final title = _readRequiredString(body?['title']);
    final bodyText = _readRequiredString(body?['body']);
    if (dependencyFamilyKey == null ||
        dependencyRequired == null ||
        dependencyHandoffKey == null ||
        title == null ||
        bodyText == null) {
      return null;
    }
    return PaymentBillingDependencyHandoffView(
      dependencyFamilyKey: dependencyFamilyKey,
      dependencyRequired: dependencyRequired,
      dependencyHandoffKey: dependencyHandoffKey,
      title: title,
      body: bodyText,
    );
  }

  static Map<String, Object?>? _map(Object? payload) {
    if (payload is Map<String, Object?>) {
      return payload;
    }
    if (payload is Map) {
      return payload.map<String, Object?>(
        (Object? key, Object? value) => MapEntry(key.toString(), value),
      );
    }
    return null;
  }

  static String? _readRequiredString(Object? value) {
    if (value is! String) {
      return null;
    }
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  static String? _readNullableString(Object? value) {
    if (value == null) {
      return null;
    }
    return _readRequiredString(value);
  }

  static bool? _readRequiredBool(Object? value) {
    return value is bool ? value : null;
  }
}
