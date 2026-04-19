import 'package:mobile/core/api/app_ui_contracts.dart';

final class ProfileGovernanceAppealCanonicalPaths {
  const ProfileGovernanceAppealCanonicalPaths._();

  static const String appeals = '/api/app/profile/governance/appeals';

  static String detail(String appealCaseId) {
    return '$appeals/${Uri.encodeComponent(appealCaseId)}';
  }
}

class ProfileGovernanceAppealPaginationView {
  const ProfileGovernanceAppealPaginationView({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.hasMore,
  });

  final int page;
  final int pageSize;
  final int total;
  final bool hasMore;
}

class ProfileGovernanceAppealPenaltyView {
  const ProfileGovernanceAppealPenaltyView({
    required this.penaltyId,
    required this.penaltyType,
    required this.penaltyTypeLabel,
    required this.penaltyStatus,
    required this.penaltyStatusLabel,
    required this.reasonSummary,
    required this.effectiveFrom,
    required this.effectiveUntil,
  });

  final String penaltyId;
  final String penaltyType;
  final String? penaltyTypeLabel;
  final String penaltyStatus;
  final String? penaltyStatusLabel;
  final String? reasonSummary;
  final String? effectiveFrom;
  final String? effectiveUntil;
}

class ProfileGovernanceAppealListItemView {
  const ProfileGovernanceAppealListItemView({
    required this.appealCaseId,
    required this.status,
    required this.statusLabel,
    required this.submittedAt,
    required this.decidedAt,
    required this.penalty,
  });

  final String appealCaseId;
  final String status;
  final String? statusLabel;
  final String? submittedAt;
  final String? decidedAt;
  final ProfileGovernanceAppealPenaltyView penalty;
}

class ProfileGovernanceAppealListView {
  const ProfileGovernanceAppealListView({
    required this.items,
    required this.pagination,
  });

  final List<ProfileGovernanceAppealListItemView> items;
  final ProfileGovernanceAppealPaginationView pagination;
}

class ProfileGovernanceAppealDetailView {
  const ProfileGovernanceAppealDetailView({
    required this.appealCaseId,
    required this.status,
    required this.statusLabel,
    required this.appealReason,
    required this.decision,
    required this.decisionLabel,
    required this.decisionNote,
    required this.evidenceFileAssetIds,
    required this.submittedAt,
    required this.decidedAt,
    required this.penalty,
  });

  final String appealCaseId;
  final String status;
  final String? statusLabel;
  final String appealReason;
  final String? decision;
  final String? decisionLabel;
  final String? decisionNote;
  final List<String> evidenceFileAssetIds;
  final String? submittedAt;
  final String? decidedAt;
  final ProfileGovernanceAppealPenaltyView penalty;
}

class ProfileGovernanceAppealResult<T> {
  const ProfileGovernanceAppealResult({
    required this.state,
    required this.method,
    required this.path,
    this.data,
    this.message,
    this.errorCode,
  });

  final AppPageState state;
  final String method;
  final String path;
  final T? data;
  final String? message;
  final String? errorCode;
}
