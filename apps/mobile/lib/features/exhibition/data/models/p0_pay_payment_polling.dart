part of '../exhibition_consumer_layer.dart';

enum P0PayPaymentKind {
  inquiryDeposit,
  projectAuthenticitySincerity,
  serviceFeeAuthorization,
}

enum P0PayPaymentOutcome {
  pending,
  success,
  charged,
  released,
  refunded,
  deducted,
  held,
  processing,
  failed,
  cancelled,
  expired,
  controlledFailure,
  timedOut,
  unknown,
}

class P0PayPaymentPollResult {
  const P0PayPaymentPollResult({
    required this.kind,
    required this.result,
    required this.outcome,
    required this.attempts,
    this.status,
    this.timedOut = false,
  });

  final P0PayPaymentKind kind;
  final ExhibitionLoadResult result;
  final P0PayPaymentOutcome outcome;
  final int attempts;
  final String? status;
  final bool timedOut;

  bool get isPending => outcome == P0PayPaymentOutcome.pending;

  bool get isSuccess {
    return switch (outcome) {
      P0PayPaymentOutcome.success ||
      P0PayPaymentOutcome.charged ||
      P0PayPaymentOutcome.released ||
      P0PayPaymentOutcome.refunded => true,
      _ => false,
    };
  }

  bool get isFailure {
    return switch (outcome) {
      P0PayPaymentOutcome.failed ||
      P0PayPaymentOutcome.cancelled ||
      P0PayPaymentOutcome.expired ||
      P0PayPaymentOutcome.controlledFailure ||
      P0PayPaymentOutcome.timedOut ||
      P0PayPaymentOutcome.unknown => true,
      _ => false,
    };
  }
}
