part of '../exhibition_consumer_layer.dart';

class MilestoneSubmitCommand {
  const MilestoneSubmitCommand({
    required this.milestoneId,
    this.submissionNote,
  });

  final String milestoneId;
  final String? submissionNote;

  Map<String, Object?> toJson() => <String, Object?>{
    'milestoneId': milestoneId,
    if (submissionNote != null && submissionNote!.trim().isNotEmpty)
      'submissionNote': submissionNote,
  };
}
