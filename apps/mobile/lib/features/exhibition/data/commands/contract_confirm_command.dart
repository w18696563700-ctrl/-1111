part of '../exhibition_consumer_layer.dart';

class ContractConfirmCommand {
  const ContractConfirmCommand({required this.contractId});

  final String contractId;

  Map<String, Object?> toJson() => <String, Object?>{'contractId': contractId};
}
