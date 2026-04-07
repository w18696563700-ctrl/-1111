part of '../exhibition_consumer_layer.dart';

class BidSubmitCommand {
  const BidSubmitCommand({
    required this.projectId,
    required this.quoteAmount,
    required this.proposalSummary,
  });

  final String projectId;
  final double quoteAmount;
  final String proposalSummary;

  Map<String, Object?> toJson() => <String, Object?>{
    'projectId': projectId,
    'quoteAmount': quoteAmount,
    'proposalSummary': proposalSummary,
  };
}
