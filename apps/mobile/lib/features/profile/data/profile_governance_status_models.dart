import 'package:mobile/core/api/app_ui_contracts.dart';

final class ProfileGovernanceStatusCanonicalPaths {
  const ProfileGovernanceStatusCanonicalPaths._();

  static const String status = '/api/app/profile/governance/status';
}

class ProfileGovernanceStatusView {
  const ProfileGovernanceStatusView({
    required this.violationScoreSnapshot,
    required this.violationScoreUpdatedAt,
  });

  final int violationScoreSnapshot;
  final String violationScoreUpdatedAt;
}

class ProfileGovernanceStatusResult {
  const ProfileGovernanceStatusResult({
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
  final ProfileGovernanceStatusView? data;
  final String? message;
  final String? errorCode;
}
