part of '../exhibition_consumer_layer.dart';

class OrderCompletionRequestCommand {
  const OrderCompletionRequestCommand({required this.orderId, this.note});

  final String orderId;
  final String? note;

  Map<String, Object?> toJson() => <String, Object?>{
    'orderId': orderId,
    if (note != null && note!.trim().isNotEmpty) 'note': note!.trim(),
  };
}

class OrderCompletionConfirmCommand {
  const OrderCompletionConfirmCommand({required this.orderId});

  final String orderId;

  Map<String, Object?> toJson() => <String, Object?>{'orderId': orderId};
}

class OrderCompletionRejectCommand {
  const OrderCompletionRejectCommand({
    required this.orderId,
    this.reason,
    this.reserveDispute = false,
  });

  final String orderId;
  final String? reason;
  final bool reserveDispute;

  Map<String, Object?> toJson() => <String, Object?>{
    'orderId': orderId,
    if (reason != null && reason!.trim().isNotEmpty) 'reason': reason!.trim(),
    'reserveDispute': reserveDispute,
  };
}
