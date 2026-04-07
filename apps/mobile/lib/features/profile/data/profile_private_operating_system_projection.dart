import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/features/profile/data/profile_consumer_layer.dart';

const List<String> _requiredPrivateOperatingSystemFamilyOrder = <String>[
  'my_company',
  'certification_membership_status',
  'my_projects',
  'my_forum',
  'settings',
];

class ProfilePrivateOperatingSystemFamilyPresenceView {
  const ProfilePrivateOperatingSystemFamilyPresenceView({
    required this.familyKey,
    required this.familyPresenceStatus,
    required this.familyOrderReference,
    required this.familyVisibilityReasonKey,
    required this.updatedAt,
  });

  final String familyKey;
  final String familyPresenceStatus;
  final int familyOrderReference;
  final String familyVisibilityReasonKey;
  final String updatedAt;
}

class ProfilePrivateOperatingSystemProjectionView {
  const ProfilePrivateOperatingSystemProjectionView({
    required this.regroupingKey,
    required this.regroupingExplanationKey,
    required this.entryOrderKey,
    required this.entryPriorityBucket,
    required this.orderingExplanationKey,
    required this.corridorKey,
    required this.corridorVisibilityStatus,
    required this.corridorExplanationKey,
    required this.corridorTargetFamily,
    required this.visibleFamilyKeys,
    required this.familyPresence,
    required this.navigationExplanationKey,
    required this.dependencyRequired,
    required this.dependencyFamilyKey,
    required this.dependencyExplanationKey,
    required this.dependencyHandoffKey,
    required this.orderingReferenceVersion,
    required this.updatedAt,
  });

  final String regroupingKey;
  final String regroupingExplanationKey;
  final String entryOrderKey;
  final String entryPriorityBucket;
  final String orderingExplanationKey;
  final String corridorKey;
  final String corridorVisibilityStatus;
  final String corridorExplanationKey;
  final String corridorTargetFamily;
  final List<String> visibleFamilyKeys;
  final List<ProfilePrivateOperatingSystemFamilyPresenceView> familyPresence;
  final String navigationExplanationKey;
  final bool dependencyRequired;
  final String dependencyFamilyKey;
  final String dependencyExplanationKey;
  final String dependencyHandoffKey;
  final String orderingReferenceVersion;
  final String updatedAt;
}

Object resolveProfilePrivateOperatingSystemProjection({
  required ProfileIndexView? profileData,
  required AppShellContextData shellContext,
}) {
  if (profileData == null) {
    return '当前账号摘要还没有返回可消费的私域整理引用。';
  }

  final profileProjection = _readObjectMap(profileData.myBuildingProjection);
  if (profileProjection == null) {
    return '当前 /api/app/profile/index 还没有返回 myBuildingProjection。';
  }

  final shellProjection = _readObjectMap(shellContext.myBuildingProjection);
  if (shellProjection == null) {
    return '当前 /api/app/shell/context 还没有返回 myBuildingProjection。';
  }

  final regroupingKey = _readRequiredString(profileProjection['regroupingKey']);
  final profileEntryOrderKey = _readRequiredString(profileProjection['entryOrderKey']);
  final profileCorridorVisibilityStatus = _readRequiredString(
    profileProjection['corridorVisibilityStatus'],
  );
  final groupingExplanationKey = _readRequiredString(
    profileProjection['groupingExplanationKey'],
  );
  final profileUpdatedAt = _readRequiredString(profileProjection['updatedAt']);
  if (regroupingKey == null ||
      profileEntryOrderKey == null ||
      profileCorridorVisibilityStatus == null ||
      groupingExplanationKey == null ||
      profileUpdatedAt == null) {
    return '当前 /api/app/profile/index 返回的私域整理引用不完整。';
  }

  final regrouping = _readObjectMap(shellProjection['regrouping']);
  final entryOrder = _readObjectMap(shellProjection['entryOrder']);
  final corridor = _readObjectMap(shellProjection['corridor']);
  final navigationExplanation = _readObjectMap(
    shellProjection['navigationExplanation'],
  );
  final dependencyReference = _readObjectMap(
    shellProjection['dependencyReference'],
  );
  final visibleFamilyKeys = _readStringList(shellProjection['visibleFamilyKeys']);
  final orderingReferenceVersion = _readRequiredString(
    shellProjection['orderingReferenceVersion'],
  );
  final shellUpdatedAt = _readRequiredString(shellProjection['updatedAt']);
  final profileCorridorKey = _readRequiredString(shellProjection['profileCorridorKey']);
  final profileEntryOrderBucket = _readRequiredString(
    shellProjection['profileEntryOrderBucket'],
  );
  if (regrouping == null ||
      entryOrder == null ||
      corridor == null ||
      navigationExplanation == null ||
      dependencyReference == null ||
      visibleFamilyKeys == null ||
      orderingReferenceVersion == null ||
      shellUpdatedAt == null ||
      profileCorridorKey == null ||
      profileEntryOrderBucket == null) {
    return '当前 /api/app/shell/context 返回的私域整理引用不完整。';
  }

  final shellRegroupingKey = _readRequiredString(regrouping['regroupingKey']);
  final regroupingVisibilityStatus = _readRequiredString(
    regrouping['regroupingVisibilityStatus'],
  );
  final regroupingExplanationKey = _readRequiredString(
    regrouping['regroupingExplanationKey'],
  );
  final entryOrderKey = _readRequiredString(entryOrder['entryOrderKey']);
  final entryVisibilityStatus = _readRequiredString(
    entryOrder['entryVisibilityStatus'],
  );
  final entryPriorityBucket = _readRequiredString(entryOrder['entryPriorityBucket']);
  final orderingExplanationKey = _readRequiredString(
    entryOrder['orderingExplanationKey'],
  );
  final corridorKey = _readRequiredString(corridor['corridorKey']);
  final corridorVisibilityStatus = _readRequiredString(
    corridor['corridorVisibilityStatus'],
  );
  final corridorExplanationKey = _readRequiredString(
    corridor['corridorExplanationKey'],
  );
  final corridorTargetFamily = _readRequiredString(corridor['corridorTargetFamily']);
  final navigationExplanationKey = _readRequiredString(
    navigationExplanation['navigationExplanationKey'],
  );
  final dependencyRequired = dependencyReference['dependencyRequired'];
  final dependencyFamilyKey = _readRequiredString(
    dependencyReference['dependencyFamilyKey'],
  );
  final dependencyExplanationKey = _readRequiredString(
    dependencyReference['dependencyExplanationKey'],
  );
  final dependencyHandoffKey = _readRequiredString(
    dependencyReference['dependencyHandoffKey'],
  );

  if (shellRegroupingKey == null ||
      regroupingVisibilityStatus == null ||
      regroupingExplanationKey == null ||
      entryOrderKey == null ||
      entryVisibilityStatus == null ||
      entryPriorityBucket == null ||
      orderingExplanationKey == null ||
      corridorKey == null ||
      corridorVisibilityStatus == null ||
      corridorExplanationKey == null ||
      corridorTargetFamily == null ||
      navigationExplanationKey == null ||
      dependencyRequired is! bool ||
      dependencyFamilyKey == null ||
      dependencyExplanationKey == null ||
      dependencyHandoffKey == null) {
    return '当前 /api/app/shell/context 返回的私域整理明细不完整。';
  }

  final familyPresence = _readFamilyPresence(shellProjection['familyPresence']);
  if (familyPresence == null) {
    return '当前 /api/app/shell/context 返回的 familyPresence 不完整。';
  }

  if (regroupingKey != 'my_building_compact_current_user_hub' ||
      shellRegroupingKey != regroupingKey ||
      regroupingExplanationKey != groupingExplanationKey) {
    return '当前 regrouping 引用超出冻结边界，页面不会伪造整理结果。';
  }
  if (regroupingVisibilityStatus != 'visible') {
    return '当前 regrouping 仍未进入可见态，页面保持既有入口顺序。';
  }
  if (profileEntryOrderKey != 'my_building_compact_hub_first_level' ||
      entryOrderKey != profileEntryOrderKey ||
      entryVisibilityStatus != 'visible' ||
      entryPriorityBucket != 'profile_my_building_first_level' ||
      profileEntryOrderBucket != entryPriorityBucket) {
    return '当前 entry-order 引用超出冻结边界，页面保持既有入口顺序。';
  }
  if (profileCorridorVisibilityStatus != 'visible' ||
      corridorVisibilityStatus != profileCorridorVisibilityStatus ||
      corridorKey != 'my_building_compact_hub_corridor' ||
      profileCorridorKey != corridorKey ||
      corridorTargetFamily != 'profile_my_building') {
    return '当前 corridor 引用超出冻结边界，页面不会伪造跨楼层走廊。';
  }
  if (dependencyFamilyKey != 'future_cross_building_shell_rewrite' ||
      dependencyExplanationKey !=
          'future_cross_building_shell_rewrite_strategic_hold' ||
      dependencyHandoffKey !=
          'strategic_hold_current_private_operating_system_boundary') {
    return '当前 dependency 引用超出冻结边界，页面不会伪造 rewrite-ready 状态。';
  }
  if (!_matchesExpectedFamilyOrder(visibleFamilyKeys, familyPresence)) {
    return '当前 family presence / order 引用不一致，页面保持既有入口顺序。';
  }

  return ProfilePrivateOperatingSystemProjectionView(
    regroupingKey: regroupingKey,
    regroupingExplanationKey: regroupingExplanationKey,
    entryOrderKey: entryOrderKey,
    entryPriorityBucket: entryPriorityBucket,
    orderingExplanationKey: orderingExplanationKey,
    corridorKey: corridorKey,
    corridorVisibilityStatus: corridorVisibilityStatus,
    corridorExplanationKey: corridorExplanationKey,
    corridorTargetFamily: corridorTargetFamily,
    visibleFamilyKeys: visibleFamilyKeys,
    familyPresence: familyPresence,
    navigationExplanationKey: navigationExplanationKey,
    dependencyRequired: dependencyRequired,
    dependencyFamilyKey: dependencyFamilyKey,
    dependencyExplanationKey: dependencyExplanationKey,
    dependencyHandoffKey: dependencyHandoffKey,
    orderingReferenceVersion: orderingReferenceVersion,
    updatedAt: _latestUpdatedAt(<String>[
      profileUpdatedAt,
      shellUpdatedAt,
      _readRequiredString(regrouping['updatedAt']) ?? shellUpdatedAt,
      _readRequiredString(entryOrder['updatedAt']) ?? shellUpdatedAt,
      _readRequiredString(corridor['updatedAt']) ?? shellUpdatedAt,
    ]),
  );
}

List<ProfilePrivateOperatingSystemFamilyPresenceView>? _readFamilyPresence(
  Object? raw,
) {
  if (raw is! List || raw.isEmpty) {
    return null;
  }

  final items = <ProfilePrivateOperatingSystemFamilyPresenceView>[];
  for (final item in raw) {
    final map = _readObjectMap(item);
    final familyKey = _readRequiredString(map?['familyKey']);
    final familyPresenceStatus = _readRequiredString(map?['familyPresenceStatus']);
    final familyOrderReference = _readRequiredInt(map?['familyOrderReference']);
    final familyVisibilityReasonKey = _readRequiredString(
      map?['familyVisibilityReasonKey'],
    );
    final updatedAt = _readRequiredString(map?['updatedAt']);
    if (familyKey == null ||
        familyPresenceStatus == null ||
        familyOrderReference == null ||
        familyVisibilityReasonKey == null ||
        updatedAt == null) {
      return null;
    }
    items.add(
      ProfilePrivateOperatingSystemFamilyPresenceView(
        familyKey: familyKey,
        familyPresenceStatus: familyPresenceStatus,
        familyOrderReference: familyOrderReference,
        familyVisibilityReasonKey: familyVisibilityReasonKey,
        updatedAt: updatedAt,
      ),
    );
  }

  items.sort(
    (ProfilePrivateOperatingSystemFamilyPresenceView left,
            ProfilePrivateOperatingSystemFamilyPresenceView right) =>
        left.familyOrderReference.compareTo(right.familyOrderReference),
  );
  return List<ProfilePrivateOperatingSystemFamilyPresenceView>.unmodifiable(items);
}

bool _matchesExpectedFamilyOrder(
  List<String> visibleFamilyKeys,
  List<ProfilePrivateOperatingSystemFamilyPresenceView> familyPresence,
) {
  final orderedVisible = familyPresence
      .where(
        (ProfilePrivateOperatingSystemFamilyPresenceView item) =>
            item.familyPresenceStatus == 'visible',
      )
      .map((ProfilePrivateOperatingSystemFamilyPresenceView item) => item.familyKey)
      .toList(growable: false);
  if (orderedVisible.length != _requiredPrivateOperatingSystemFamilyOrder.length ||
      visibleFamilyKeys.length != _requiredPrivateOperatingSystemFamilyOrder.length) {
    return false;
  }

  for (var index = 0; index < _requiredPrivateOperatingSystemFamilyOrder.length; index += 1) {
    final expected = _requiredPrivateOperatingSystemFamilyOrder[index];
    if (orderedVisible[index] != expected || visibleFamilyKeys[index] != expected) {
      return false;
    }
  }

  return true;
}

Map<String, Object?>? _readObjectMap(Object? raw) {
  if (raw is! Map) {
    return null;
  }

  return raw.map((Object? key, Object? value) => MapEntry('$key', value));
}

String? _readRequiredString(Object? raw) {
  if (raw is! String) {
    return null;
  }

  final value = raw.trim();
  return value.isEmpty ? null : value;
}

int? _readRequiredInt(Object? raw) {
  if (raw is int) {
    return raw;
  }
  if (raw is num && raw == raw.roundToDouble()) {
    return raw.toInt();
  }
  return null;
}

List<String>? _readStringList(Object? raw) {
  if (raw is! List) {
    return null;
  }

  final values = raw
      .whereType<String>()
      .map((String value) => value.trim())
      .where((String value) => value.isNotEmpty)
      .toList(growable: false);
  return values.isEmpty ? null : values;
}

String _latestUpdatedAt(List<String> values) {
  final normalized = values
      .map((String value) => value.trim())
      .where((String value) => value.isNotEmpty)
      .toList(growable: false);
  if (normalized.isEmpty) {
    return '';
  }

  normalized.sort();
  return normalized.last;
}
