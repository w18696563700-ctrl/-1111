final class ProfileRoutes {
  const ProfileRoutes._();

  static const String personal = '/profile/me';
  static const String personalAvatar = '/profile/me/avatar';
  static const String personalNickname = '/profile/me/nickname';
  static const String company = '/profile/company';
  static const String organizationCreditScoring =
      '/profile/organization-credit-scoring';
  static const String organizationCreditScoringExplanation =
      '/profile/organization-credit-scoring/explanation';
  static const String organizationCreditScoringHandoff =
      '/profile/organization-credit-scoring/handoff';
  static const String forum = '/profile/forum';
  static const String governanceAppeals = '/profile/governance/appeals';
  static const String settings = '/profile/settings';

  static String governanceAppealDetailWithCaseId(String appealCaseId) {
    return '$governanceAppeals/${Uri.encodeComponent(appealCaseId)}';
  }
}
