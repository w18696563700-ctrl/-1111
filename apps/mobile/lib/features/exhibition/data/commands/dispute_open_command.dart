part of '../exhibition_consumer_layer.dart';

class DisputeOpenCommand {
  const DisputeOpenCommand({required this.orderId, this.reason});

  final String orderId;
  final String? reason;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'orderId': orderId,
      if (reason != null && reason!.trim().isNotEmpty) 'reason': reason!.trim(),
    };
  }
}
