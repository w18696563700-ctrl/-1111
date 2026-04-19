part of 'forum_consumer_layer.dart';

class ForumMyReportTicketItemView {
  const ForumMyReportTicketItemView({
    required this.reportTicketId,
    required this.targetType,
    required this.targetId,
    required this.reasonCode,
    required this.reasonDetail,
    required this.status,
    required this.targetSnapshot,
    required this.submittedAt,
    required this.updatedAt,
  });

  final String reportTicketId;
  final String targetType;
  final String targetId;
  final String reasonCode;
  final String? reasonDetail;
  final String status;
  final ForumMyReportTargetSnapshotView targetSnapshot;
  final String submittedAt;
  final String updatedAt;
}

class ForumMyReportTicketDetailView {
  const ForumMyReportTicketDetailView({
    required this.reportTicketId,
    required this.targetType,
    required this.targetId,
    required this.reasonCode,
    required this.reasonDetail,
    required this.status,
    required this.targetSnapshot,
    required this.submittedAt,
    required this.updatedAt,
  });

  final String reportTicketId;
  final String targetType;
  final String targetId;
  final String reasonCode;
  final String? reasonDetail;
  final String status;
  final ForumMyReportTargetSnapshotView targetSnapshot;
  final String submittedAt;
  final String updatedAt;
}

class ForumMyReportTargetSnapshotView {
  const ForumMyReportTargetSnapshotView({
    required this.title,
    required this.body,
    required this.excerpt,
    required this.postId,
    required this.commentId,
    required this.publishedAt,
  });

  final String? title;
  final String? body;
  final String? excerpt;
  final String? postId;
  final String? commentId;
  final String? publishedAt;
}
