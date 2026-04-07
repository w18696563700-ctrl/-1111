part of '../exhibition_consumer_layer.dart';

class ContractAmendCommand {
  const ContractAmendCommand({
    required this.contractId,
    required this.amendmentSummary,
  });

  final String contractId;
  final String amendmentSummary;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'contractId': contractId,
      'amendmentSummary': amendmentSummary,
    };
  }
}
