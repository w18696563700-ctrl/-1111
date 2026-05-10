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
  static const String bidServiceFeeAuthorization =
      '/profile/payment-billing/bid-service-fee-authorization';
  static const String rcFeatureUnavailable = '/profile/rc-feature-unavailable';
  static const String settings = '/profile/settings';
  static const String privacyPermissions =
      '/profile/settings/privacy-permissions';
  static const String certificationIdentityStatus =
      '/profile/settings/certification-identity-status';
  static const String sessionDeviceStatus =
      '/profile/settings/session-device-status';
  static const String versionInfo = '/profile/settings/version-info';

  static String governanceAppealDetailWithCaseId(String appealCaseId) {
    return '$governanceAppeals/${Uri.encodeComponent(appealCaseId)}';
  }

  static String bidServiceFeeAuthorizationWithIds({
    required String projectId,
    required String bidParticipationRequestId,
    String? bidId,
  }) {
    final query = <String, String>{
      'projectId': projectId,
      'bidParticipationRequestId': bidParticipationRequestId,
      if (bidId != null && bidId.trim().isNotEmpty) 'bidId': bidId,
    };
    return Uri(
      path: bidServiceFeeAuthorization,
      queryParameters: query,
    ).toString();
  }

  static String rcFeatureUnavailableFor(String featureKey) {
    return Uri(
      path: rcFeatureUnavailable,
      queryParameters: <String, String>{'feature': featureKey},
    ).toString();
  }
}
