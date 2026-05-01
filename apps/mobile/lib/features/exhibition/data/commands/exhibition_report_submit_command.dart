part of '../exhibition_consumer_layer.dart';

class ExhibitionReportSubmitCommand {
  const ExhibitionReportSubmitCommand({
    required this.targetType,
    required this.targetId,
    required this.reasonCode,
    this.reasonDetail,
    this.evidenceFileAssetIds = const <String>[],
  });

  final String targetType;
  final String targetId;
  final String reasonCode;
  final String? reasonDetail;
  final List<String> evidenceFileAssetIds;

  Map<String, Object?> toJson() => <String, Object?>{
    'targetType': targetType,
    'targetId': targetId,
    'reasonCode': reasonCode,
    if (reasonDetail != null && reasonDetail!.trim().isNotEmpty)
      'reasonDetail': reasonDetail!.trim(),
    if (evidenceFileAssetIds.isNotEmpty)
      'evidenceFileAssetIds': evidenceFileAssetIds,
  };
}
