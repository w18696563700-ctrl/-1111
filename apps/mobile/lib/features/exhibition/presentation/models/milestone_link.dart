part of '../exhibition_trade_pages.dart';

class _MilestoneLink {
  const _MilestoneLink({required this.milestoneId, required this.label});

  final String milestoneId;
  final String label;

  static _MilestoneLink? fromPayload(Map<String, Object?> payload) {
    final milestoneId = _normalizeId(payload['milestoneId'] as String?);
    if (milestoneId == null) {
      return null;
    }

    final label = _normalizeId(payload['title'] as String?) ?? milestoneId;

    return _MilestoneLink(milestoneId: milestoneId, label: label);
  }
}
