import 'package:mobile/core/config/config_manifest.dart';

class AppShellContextData {
  AppShellContextData({
    this.userId,
    this.displayName,
    this.avatarUrl,
    this.organizationId,
    this.organizationType,
    List<String>? roleKeys,
    this.certificationStatus,
    this.personalCertificationStatus,
    this.personalCertificationQualified,
    this.personalCertificationLockedToOtherActor,
    this.membershipStatus,
    this.projectCreateEligibility,
    this.paidMembershipTier,
    List<String>? paidMembershipEntitlementsSummary,
    List<String>? paidMembershipQuotaSummary,
    this.paidMembershipNextRefreshAt,
    List<String>? visibleBuildings,
    this.featureFlagsVersion,
    Map<String, Object?>? unreadSummary,
    Map<String, Object?>? myBuildingProjection,
  }) : roleKeys = List<String>.unmodifiable(roleKeys ?? const <String>[]),
       paidMembershipEntitlementsSummary = List<String>.unmodifiable(
         paidMembershipEntitlementsSummary ?? const <String>[],
       ),
       paidMembershipQuotaSummary = List<String>.unmodifiable(
         paidMembershipQuotaSummary ?? const <String>[],
       ),
       visibleBuildings = List<String>.unmodifiable(
         visibleBuildings ?? const <String>[],
       ),
       unreadSummary = unreadSummary == null
           ? null
           : Map<String, Object?>.unmodifiable(unreadSummary),
       myBuildingProjection = myBuildingProjection == null
           ? null
           : Map<String, Object?>.unmodifiable(myBuildingProjection);

  factory AppShellContextData.bootstrapDefaults({
    required AppConfigManifest manifest,
  }) {
    return AppShellContextData(
      visibleBuildings: <String>[
        if (manifest.exhibitionVisible) 'exhibition',
        if (manifest.messagesVisible) 'messages',
        if (manifest.profileVisible) 'profile',
        if (manifest.renovationVisible) 'renovation',
        if (manifest.customFurnitureVisible) 'custom_furniture',
      ],
    );
  }

  AppShellContextData copyWith({Map<String, Object?>? unreadSummary}) {
    return AppShellContextData(
      userId: userId,
      displayName: displayName,
      avatarUrl: avatarUrl,
      organizationId: organizationId,
      organizationType: organizationType,
      roleKeys: roleKeys,
      certificationStatus: certificationStatus,
      personalCertificationStatus: personalCertificationStatus,
      personalCertificationQualified: personalCertificationQualified,
      personalCertificationLockedToOtherActor:
          personalCertificationLockedToOtherActor,
      membershipStatus: membershipStatus,
      projectCreateEligibility: projectCreateEligibility,
      paidMembershipTier: paidMembershipTier,
      paidMembershipEntitlementsSummary: paidMembershipEntitlementsSummary,
      paidMembershipQuotaSummary: paidMembershipQuotaSummary,
      paidMembershipNextRefreshAt: paidMembershipNextRefreshAt,
      visibleBuildings: visibleBuildings,
      featureFlagsVersion: featureFlagsVersion,
      unreadSummary: unreadSummary ?? this.unreadSummary,
      myBuildingProjection: myBuildingProjection,
    );
  }

  final String? userId;
  final String? displayName;
  final String? avatarUrl;
  final String? organizationId;
  final String? organizationType;
  final List<String> roleKeys;
  final String? certificationStatus;
  final String? personalCertificationStatus;
  final bool? personalCertificationQualified;
  final bool? personalCertificationLockedToOtherActor;
  final String? membershipStatus;
  final AppProjectCreateEligibilityData? projectCreateEligibility;
  final String? paidMembershipTier;
  final List<String> paidMembershipEntitlementsSummary;
  final List<String> paidMembershipQuotaSummary;
  final String? paidMembershipNextRefreshAt;
  final List<String> visibleBuildings;
  final String? featureFlagsVersion;
  final Map<String, Object?>? unreadSummary;
  final Map<String, Object?>? myBuildingProjection;

  int? get unreadSummaryTotal {
    final summary = unreadSummary;
    if (summary == null || summary.isEmpty) {
      return null;
    }

    var total = 0;
    var hasValidBucket = false;
    for (final value in summary.values) {
      final count = _readUnreadCount(value);
      if (count == null) {
        continue;
      }
      hasValidBucket = true;
      total += count;
    }

    return hasValidBucket ? total : null;
  }

  String? get unreadSummaryBadgeLabel {
    final total = unreadSummaryTotal;
    if (total == null || total <= 0) {
      return null;
    }

    return total > 99 ? '99+' : '$total';
  }

  int? get messagesUnreadCount {
    final summary = unreadSummary;
    if (summary == null || summary.isEmpty) {
      return null;
    }
    return _readUnreadCount(summary['messages']);
  }

  String? get messagesUnreadBadgeLabel {
    final total = messagesUnreadCount;
    if (total == null || total <= 0) {
      return null;
    }

    return total > 99 ? '99+' : '$total';
  }

  static int? _readUnreadCount(Object? raw) {
    if (raw is int && raw >= 0) {
      return raw;
    }
    if (raw is num && raw >= 0 && raw == raw.roundToDouble()) {
      return raw.toInt();
    }
    return null;
  }
}

class AppProjectCreateEligibilityData {
  const AppProjectCreateEligibilityData({required this.canCreateProject});

  final bool canCreateProject;
}
