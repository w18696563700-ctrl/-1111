import 'package:mobile/features/profile/presentation/profile_visible_copy.dart';

String profileDisplayOrganizationCapabilitySummary(
  String? rawType, {
  List<String> roleKeys = const <String>[],
}) {
  final normalizedRoles = roleKeys
      .map((String role) => role.trim().toLowerCase())
      .where((String role) => role.isNotEmpty)
      .toList(growable: false);
  final hasBuyerRole = normalizedRoles.any(
    (String role) => role.contains('buyer'),
  );
  final hasSupplierRole = normalizedRoles.any(
    (String role) => role.contains('supplier'),
  );

  return switch (rawType?.trim()) {
    'demand' => hasBuyerRole ? '当前角色可发布项目' : '主体支持发布项目，当前角色需切到买方侧',
    'supplier' => '当前主体可参与竞标',
    'both' =>
      hasBuyerRole
          ? '当前角色可发布项目；主体也可参与竞标'
          : hasSupplierRole
          ? '主体支持发布项目 / 参与竞标；当前角色偏供应商，发布项目需切到买方侧'
          : '主体支持发布项目 / 参与竞标；当前角色待确认',
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
