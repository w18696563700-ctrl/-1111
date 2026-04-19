part of '../exhibition_consumer_layer.dart';

class DisputeWithdrawCommand {
  const DisputeWithdrawCommand({required this.orderId});

  final String orderId;

  Map<String, Object?> toJson() => <String, Object?>{'orderId': orderId};
}
