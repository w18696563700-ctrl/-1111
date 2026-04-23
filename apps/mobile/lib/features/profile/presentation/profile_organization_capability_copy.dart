import 'package:mobile/features/profile/presentation/profile_visible_copy.dart';

String profileDisplayOrganizationCapabilitySummary(String? rawType) {
  return switch (rawType?.trim()) {
    'demand' => '当前主体可发布项目',
    'supplier' => '当前主体可参与竞标',
    'both' => '当前主体可发布项目 / 可参与竞标',
    _ => '当前主体能力待确认',
  };
}

List<String> profileBuildOrganizationCapabilityStatusBadges({
  required String? certificationStatus,
  required String? membershipStatus,
}) {
  return <String>[
    profileDisplayEnterpriseCertificationBadge(certificationStatus),
    profileDisplayMembershipBadge(membershipStatus),
  ].where((String item) => item.trim().isNotEmpty).toList(growable: false);
}
