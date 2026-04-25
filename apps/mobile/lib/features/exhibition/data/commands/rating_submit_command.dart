part of '../exhibition_consumer_layer.dart';

class RatingSubmitCommand {
  const RatingSubmitCommand({required this.orderId});

  final String orderId;

  Map<String, Object?> toJson() => <String, Object?>{'orderId': orderId};
}

class ProjectCounterpartyRatingSubmitCommand {
  const ProjectCounterpartyRatingSubmitCommand({
    required this.orderId,
    required this.projectId,
    required this.rateeOrganizationId,
    required this.scoreLabel,
    this.commentText,
  });

  final String orderId;
  final String projectId;
  final String rateeOrganizationId;
  final String scoreLabel;
  final String? commentText;

  Map<String, Object?> toJson() => <String, Object?>{
    'orderId': orderId,
    'projectId': projectId,
    'rateeOrganizationId': rateeOrganizationId,
    'scoreLabel': scoreLabel,
    'commentText': commentText,
  };
}
