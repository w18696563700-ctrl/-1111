final class ProfileIdentityRoutes {
  const ProfileIdentityRoutes._();

  static const String login = '/profile/login';
  static const String organizationHandoff = '/profile/organization';
  static const String organizationSwitch = '/profile/organization/switch';
  static const String organizationCreate = '/profile/organization/create';
  static const String organizationJoin = '/profile/organization/join';
  static const String certificationCurrent = '/profile/certification/current';
  static const String certificationSubmit = '/profile/certification/submit';
  static const String personalCertificationSubmit =
      '/profile/certification/personal/submit';
  static const String certificationRevalidate =
      '/profile/certification/revalidate';
  static const String certificationResubmit = '/profile/certification/resubmit';
  static const String sessionCenter = '/profile/session';
  static const String userAgreement = '/profile/legal/user-agreement';
  static const String privacyPolicy = '/profile/legal/privacy-policy';
  static const String passwordReset = '/profile/auth/password/reset';
  static const String passwordSet = '/profile/auth/password/set';

  static String organizationCreateWithMode(String mode) {
    return Uri(
      path: organizationCreate,
      queryParameters: <String, String>{'mode': mode},
    ).toString();
  }
}
