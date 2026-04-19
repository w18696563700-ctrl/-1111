part of '../exhibition_consumer_layer.dart';

class ContractConfirmCommand {
  const ContractConfirmCommand({required this.orderId});

  final String orderId;

  Map<String, Object?> toJson() => <String, Object?>{'orderId': orderId};
}
