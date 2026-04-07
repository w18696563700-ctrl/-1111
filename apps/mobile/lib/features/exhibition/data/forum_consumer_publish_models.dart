part of 'forum_consumer_layer.dart';

class ForumDraftDetailView {
  const ForumDraftDetailView({
    required this.draftId,
    required this.draftType,
    required this.title,
    required this.body,
    required this.attachmentFileAssetIds,
    required this.state,
    required this.updatedAt,
    this.targetPostId,
    this.topicId,
  });

  final String draftId;
  final String draftType;
  final String? targetPostId;
  final String? topicId;
  final String title;
  final String body;
  final List<String> attachmentFileAssetIds;
  final String state;
  final String updatedAt;

  bool get isOwnPostEditDraft => targetPostId != null;
}

enum ForumPublishDecisionView {
  clear('clear'),
  supplementRequired('supplement_required'),
  restricted('restricted'),
  ticketRequired('ticket_required');

  const ForumPublishDecisionView(this.value);

  final String value;

  static ForumPublishDecisionView? fromWire(String? raw) {
    return switch (raw?.trim()) {
      'clear' => ForumPublishDecisionView.clear,
      'supplement_required' => ForumPublishDecisionView.supplementRequired,
      'restricted' => ForumPublishDecisionView.restricted,
      'ticket_required' => ForumPublishDecisionView.ticketRequired,
      _ => null,
    };
  }
}

class ForumPublishResultView {
  const ForumPublishResultView({
    required this.draftId,
    required this.state,
    required this.decision,
    required this.message,
    this.topicId,
    this.postId,
    this.title,
    this.publishedAt,
  });

  final String draftId;
  final String state;
  final ForumPublishDecisionView decision;
  final String message;
  final String? topicId;
  final String? postId;
  final String? title;
  final String? publishedAt;

  bool get isClear => decision == ForumPublishDecisionView.clear;
  bool get isBlocked => !isClear;
}

class ForumDraftDeletedView {
  const ForumDraftDeletedView({required this.draftId, required this.state});

  final String draftId;
  final String state;
}
