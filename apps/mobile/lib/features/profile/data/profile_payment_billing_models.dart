import 'package:mobile/core/api/app_ui_contracts.dart';

final class ProfilePaymentBillingCanonicalPaths {
  const ProfilePaymentBillingCanonicalPaths._();

  static const String status =
      '/api/app/profile/payment-and-billing-status/status';
  static const String explanation =
      '/api/app/profile/payment-and-billing-status/explanation';
  static const String handoff =
      '/api/app/profile/payment-and-billing-status/handoff';
}

class PaymentBillingPrivateSummaryView {
  const PaymentBillingPrivateSummaryView({
    required this.entryKey,
    required this.summaryStatus,
    required this.paymentStatus,
    required this.billingReferenceStatus,
    required this.updatedAt,
  });

  final String entryKey;
  final String summaryStatus;
  final String paymentStatus;
  final String billingReferenceStatus;
  final String updatedAt;
}

class PaymentStatusView {
  const PaymentStatusView({
    required this.paymentStatus,
    required this.paymentAvailabilityStatus,
    required this.paymentHandoffKey,
    required this.paymentExplanationKey,
    required this.paymentDependencyKey,
    required this.updatedAt,
  });

  final String paymentStatus;
  final String paymentAvailabilityStatus;
  final String paymentHandoffKey;
  final String paymentExplanationKey;
  final String? paymentDependencyKey;
  final String updatedAt;
}

class BillingReferenceView {
  const BillingReferenceView({
    required this.billingReferenceStatus,
    required this.billingReferenceCode,
    required this.billingReferenceVisibilityStatus,
    required this.billingExplanationKey,
    required this.billingHandoffKey,
    required this.billingDependencyKey,
    required this.updatedAt,
  });

  final String billingReferenceStatus;
  final String? billingReferenceCode;
  final String billingReferenceVisibilityStatus;
  final String billingExplanationKey;
  final String billingHandoffKey;
  final String? billingDependencyKey;
  final String updatedAt;
}

class PaymentBillingDependencyReferenceView {
  const PaymentBillingDependencyReferenceView({
    required this.dependencyFamilyKey,
    required this.dependencyRequired,
    required this.dependencyExplanationKey,
    required this.dependencyHandoffKey,
  });

  final String dependencyFamilyKey;
  final bool dependencyRequired;
  final String dependencyExplanationKey;
  final String dependencyHandoffKey;
}

class ProfilePaymentBillingStatusView {
  const ProfilePaymentBillingStatusView({
    required this.privateSummary,
    required this.paymentStatus,
    required this.billingReference,
    required this.dependencyReference,
  });

  final PaymentBillingPrivateSummaryView privateSummary;
  final PaymentStatusView paymentStatus;
  final BillingReferenceView billingReference;
  final PaymentBillingDependencyReferenceView? dependencyReference;
}

class PaymentBillingExplanationBlockView {
  const PaymentBillingExplanationBlockView({
    required this.explanationKey,
    required this.title,
    required this.body,
  });

  final String explanationKey;
  final String title;
  final String body;
}

class PaymentBillingDependencyExplanationView {
  const PaymentBillingDependencyExplanationView({
    required this.dependencyFamilyKey,
    required this.dependencyRequired,
    required this.dependencyExplanationKey,
    required this.title,
    required this.body,
  });

  final String dependencyFamilyKey;
  final bool dependencyRequired;
  final String dependencyExplanationKey;
  final String title;
  final String body;
}

class ProfilePaymentBillingExplanationView {
  const ProfilePaymentBillingExplanationView({
    required this.paymentExplanation,
    required this.billingExplanation,
    required this.dependencyExplanation,
    required this.disclaimer,
  });

  final PaymentBillingExplanationBlockView paymentExplanation;
  final PaymentBillingExplanationBlockView billingExplanation;
  final PaymentBillingDependencyExplanationView? dependencyExplanation;
  final String disclaimer;
}

class PaymentBillingHandoffView {
  const PaymentBillingHandoffView({
    required this.paymentHandoffKey,
    required this.handoffStatus,
    required this.handoffTargetFamily,
    required this.handoffExplanationKey,
    required this.dependencyRequired,
    required this.title,
    required this.body,
    required this.updatedAt,
  });

  final String paymentHandoffKey;
  final String handoffStatus;
  final String handoffTargetFamily;
  final String handoffExplanationKey;
  final bool dependencyRequired;
  final String title;
  final String body;
  final String updatedAt;
}

class BillingHandoffView {
  const BillingHandoffView({
    required this.billingHandoffKey,
    required this.title,
    required this.body,
    required this.updatedAt,
  });

  final String billingHandoffKey;
  final String title;
  final String body;
  final String updatedAt;
}

class PaymentBillingDependencyHandoffView {
  const PaymentBillingDependencyHandoffView({
    required this.dependencyFamilyKey,
    required this.dependencyRequired,
    required this.dependencyHandoffKey,
    required this.title,
    required this.body,
  });

  final String dependencyFamilyKey;
  final bool dependencyRequired;
  final String dependencyHandoffKey;
  final String title;
  final String body;
}

class ProfilePaymentBillingHandoffView {
  const ProfilePaymentBillingHandoffView({
    required this.paymentHandoff,
    required this.billingHandoff,
    required this.dependencyHandoff,
  });

  final PaymentBillingHandoffView paymentHandoff;
  final BillingHandoffView billingHandoff;
  final PaymentBillingDependencyHandoffView? dependencyHandoff;
}

class ProfilePaymentBillingResult<T> {
  const ProfilePaymentBillingResult({
    required this.state,
    required this.method,
    required this.path,
    this.data,
    this.message,
    this.errorCode,
  });

  final AppPageState state;
  final String method;
  final String path;
  final T? data;
  final String? message;
  final String? errorCode;
}
