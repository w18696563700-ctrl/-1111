import 'package:mobile/features/profile/data/profile_identity_consumer_layer.dart';

const Set<String> _appOrganizationRoleKeys = <String>{
  'buyer_admin',
  'buyer_member(scoped)',
  'supplier_admin',
  'supplier_member(scoped)',
};

bool profileCanSwitchToOrganization(MyOrganizationItemView item) {
  final organizationType = item.organizationType.trim();
  final membershipStatus = item.membershipStatus.trim();
  return membershipStatus == 'active' &&
      organizationType != 'platform' &&
      item.roleKeys.any(
        (String roleKey) => _appOrganizationRoleKeys.contains(roleKey.trim()),
      );
}
