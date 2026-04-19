part of '../exhibition_consumer_layer.dart';

class BidSubmitCommand {
  const BidSubmitCommand({
    required this.projectId,
    required this.quoteAmount,
    required this.proposalSummary,
    required this.projectUnderstandingFileAssetId,
    required this.quoteSheetFileAssetId,
    required this.schedulePlanFileAssetId,
  });

  final String projectId;
  final double quoteAmount;
  final String proposalSummary;
  final String projectUnderstandingFileAssetId;
  final String quoteSheetFileAssetId;
  final String schedulePlanFileAssetId;

  Map<String, Object?> toJson() => <String, Object?>{
    'projectId': projectId,
    'quoteAmount': quoteAmount,
    'proposalSummary': proposalSummary,
    'projectUnderstandingFileAssetId': projectUnderstandingFileAssetId,
    'quoteSheetFileAssetId': quoteSheetFileAssetId,
    'schedulePlanFileAssetId': schedulePlanFileAssetId,
  };
}
