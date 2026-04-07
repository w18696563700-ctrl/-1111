part of 'forum_consumer_layer.dart';

class ForumBlockRelationStatusView {
  const ForumBlockRelationStatusView({
    required this.targetUserId,
    required this.isBlocked,
    required this.state,
    this.message,
    this.traceId,
    this.updatedAt,
  });

  final String targetUserId;
  final bool isBlocked;
  final String state;
  final String? message;
  final String? traceId;
  final String? updatedAt;
}
