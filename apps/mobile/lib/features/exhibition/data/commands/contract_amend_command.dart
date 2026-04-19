part of '../exhibition_consumer_layer.dart';

class ContractAmendCommand {
  const ContractAmendCommand({required this.orderId});

  final String orderId;

  Map<String, Object?> toJson() => <String, Object?>{'orderId': orderId};
}
