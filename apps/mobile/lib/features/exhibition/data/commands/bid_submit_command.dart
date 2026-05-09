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

class BidSubmissionSupplementCommand extends BidSubmitCommand {
  const BidSubmissionSupplementCommand({
    required super.projectId,
    required this.bidId,
    required this.entryKey,
    required this.sourceVersionToken,
    required super.quoteAmount,
    required super.proposalSummary,
    required super.projectUnderstandingFileAssetId,
    required super.quoteSheetFileAssetId,
    required super.schedulePlanFileAssetId,
    this.bidMaterialSlot,
  });

  final String bidId;
  final String entryKey;
  final String sourceVersionToken;
  final String? bidMaterialSlot;

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    ...super.toJson(),
    'bidId': bidId,
    'entryKey': entryKey,
    'sourceVersionToken': sourceVersionToken,
    if (bidMaterialSlot != null && bidMaterialSlot!.trim().isNotEmpty)
      'bidMaterialSlot': bidMaterialSlot,
  };
}
