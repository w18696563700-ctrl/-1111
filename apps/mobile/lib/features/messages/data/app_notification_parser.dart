import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/features/messages/data/app_notification_models.dart';
import 'package:mobile/features/messages/data/messages_interaction_parser.dart';
import 'package:mobile/features/messages/data/messages_registered_entry_registry.dart';

AppNotificationListView parseAppNotificationList(Object? payload) {
  final map = _requiredMap(payload, 'app notification list');
  final rawItems = map['items'];
  final items = rawItems is List
      ? rawItems
            .map<AppNotificationItemView>(parseAppNotificationItem)
            .toList(growable: false)
      : const <AppNotificationItemView>[];
  final page = _optionalMap(map['page']);
  return AppNotificationListView(
    items: items,
    nextCursor: _nullableString(page?['nextCursor']),
    hasMore: page?['hasMore'] == true,
    unread: parseAppNotificationUnread(map['unread']),
  );
}

AppNotificationItemView parseAppNotificationItem(Object? payload) {
  final map = _requiredMap(payload, 'app notification item');
  final routeTarget = parseAppNotificationRouteTarget(map['routeTarget']);
  return AppNotificationItemView(
    notificationId: _requiredString(map, 'notificationId'),
    type: _requiredString(map, 'type'),
    source: _requiredString(map, 'source'),
    title: _requiredString(map, 'title'),
    body: _nullableString(map['body']),
    projectId: _nullableString(map['projectId']),
    threadId: _nullableString(map['threadId']),
    routeTarget: routeTarget,
    routeTargetAvailability: parseAppNotificationRouteTargetAvailability(
      map['routeTargetAvailability'],
      routeTarget: routeTarget,
      source: _requiredString(map, 'source'),
      type: _requiredString(map, 'type'),
    ),
    createdAt: _nullableString(map['createdAt']),
    readAt: _nullableString(map['readAt']),
    unread: map['unread'] == true,
  );
}

AppNotificationRouteTargetAvailabilityView
parseAppNotificationRouteTargetAvailability(
  Object? payload, {
  required AppNotificationRouteTargetView? routeTarget,
  required String source,
  required String type,
}) {
  final map = _optionalMap(payload);
  if (map == null || map.isEmpty) {
    final fallbackRouteTarget = _legacyProjectCommunicationFallback(
      routeTarget: routeTarget,
      source: source,
      type: type,
    );
    if (fallbackRouteTarget != null) {
      return AppNotificationRouteTargetAvailabilityView(
        state: 'unavailable',
        reasonCode: 'LEGACY_PROJECT_COMMUNICATION_AVAILABILITY_MISSING',
        reasonText: '入口已失效，可从主体项目列表重新进入。',
        fallbackAction: 'open_subject_list',
        fallbackRouteTarget: fallbackRouteTarget,
      );
    }
    final canLocate = routeTarget?.routeLocation?.trim().isNotEmpty == true;
    return AppNotificationRouteTargetAvailabilityView(
      state: canLocate ? 'available' : 'missing_context',
      reasonCode: canLocate ? 'ROUTE_TARGET_AVAILABLE' : 'ROUTE_TARGET_MISSING',
      reasonText: canLocate ? '当前通知入口可用。' : '当前通知暂时无法定位，请稍后重试或从对应入口进入。',
      fallbackAction: 'none',
      fallbackRouteTarget: null,
    );
  }
  final fallbackRouteTarget = parseAppNotificationRouteTarget(
    map['fallbackRouteTarget'],
  );
  return AppNotificationRouteTargetAvailabilityView(
    state: _nullableString(map['state']) ?? 'missing_context',
    reasonCode:
        _nullableString(map['reasonCode']) ??
        'ROUTE_TARGET_AVAILABILITY_UNKNOWN',
    reasonText:
        _nullableString(map['reasonText']) ?? '当前通知暂时无法定位，请稍后重试或从对应入口进入。',
    fallbackAction: _nullableString(map['fallbackAction']) ?? 'none',
    fallbackRouteTarget: fallbackRouteTarget,
  );
}

AppNotificationRouteTargetView? _legacyProjectCommunicationFallback({
  required AppNotificationRouteTargetView? routeTarget,
  required String source,
  required String type,
}) {
  if (routeTarget == null) {
    return null;
  }
  final isProjectCommunication =
      source == 'project_communication' ||
      type == 'project_communication_message' ||
      routeTarget.canonicalPath ==
          '/api/app/message/counterpart-conversation/detail';
  if (!isProjectCommunication) {
    return null;
  }
  final conversationId = routeTarget.params['conversationId']?.trim();
  final projectId = routeTarget.params['projectId']?.trim();
  if (conversationId == null ||
      conversationId.isEmpty ||
      projectId == null ||
      projectId.isEmpty) {
    return null;
  }
  return AppNotificationRouteTargetView(
    canonicalPath: routeTarget.canonicalPath,
    localEntryKey: routeTarget.localEntryKey,
    params: Map<String, String>.unmodifiable(<String, String>{
      'conversationId': conversationId,
      'projectId': projectId,
    }),
    routeLocation: _buildRouteLocation(
      canonicalPath: routeTarget.canonicalPath,
      localEntryKey: routeTarget.localEntryKey,
      state: 'enabled',
      params: <String, String>{
        'conversationId': conversationId,
        'projectId': projectId,
      },
    ),
  );
}

AppNotificationUnreadView parseAppNotificationUnread(Object? payload) {
  final map = _optionalMap(payload);
  return AppNotificationUnreadView(
    total: _optionalNonNegativeInt(map?['total']),
    projectCommunication: _optionalNonNegativeInt(map?['projectCommunication']),
    businessTodo: _optionalNonNegativeInt(
      map?['businessTodo'] ?? map?['bidParticipationRequest'],
    ),
    bidParticipationRequest: _optionalNonNegativeInt(
      map?['bidParticipationRequest'],
    ),
    forumInteraction: _optionalNonNegativeInt(map?['forumInteraction']),
    system: _optionalNonNegativeInt(map?['system']),
  );
}

AppNotificationRouteTargetView? parseAppNotificationRouteTarget(
  Object? payload,
) {
  final map = _optionalMap(payload);
  if (map == null || map.isEmpty) {
    return null;
  }
  final canonicalPath = _nullableString(map['canonicalPath']);
  if (canonicalPath == null) {
    return null;
  }
  final localEntryKey = _nullableString(map['localEntryKey']);
  final state = _nullableString(map['state']);
  final params = _parseParams(map['routeParams'] ?? map['params']);
  return AppNotificationRouteTargetView(
    canonicalPath: canonicalPath,
    localEntryKey: localEntryKey,
    params: params,
    routeLocation: _buildRouteLocation(
      canonicalPath: canonicalPath,
      localEntryKey: localEntryKey,
      state: state,
      params: params,
    ),
  );
}

DevicePushTokenRegisterResult parseDevicePushTokenRegisterResult({
  required Object? payload,
}) {
  final map = _requiredMap(payload, 'device push token register');
  return DevicePushTokenRegisterResult(
    state: AppPageState.content,
    method: 'POST',
    path: AppNotificationCanonicalPaths.deviceTokenRegister,
    registered: map['registered'] == true,
    tokenId: _nullableString(map['tokenId']),
    platform: _nullableString(map['platform']),
    provider: _nullableString(map['provider']),
  );
}

AppNotificationReadResult parseAppNotificationReadResult(Object? payload) {
  final map = _requiredMap(payload, 'app notification read result');
  final rawIds = map['readNotificationIds'];
  return AppNotificationReadResult(
    state: AppPageState.content,
    method: 'POST',
    path: AppNotificationCanonicalPaths.notificationRead,
    readNotificationIds: rawIds is List
        ? rawIds.whereType<String>().toList(growable: false)
        : const <String>[],
    unread: parseAppNotificationUnread(map['unread']),
  );
}

String? extractNotificationMessage(Object? payload) => extractMessage(payload);

String? _buildRouteLocation({
  required String canonicalPath,
  required String? localEntryKey,
  required String? state,
  required Map<String, String> params,
}) {
  if (state != 'enabled') {
    return null;
  }
  final actionKey = _resolveActionKey(
    canonicalPath: canonicalPath,
    localEntryKey: localEntryKey,
  );
  if (actionKey == null) {
    return null;
  }
  final definition = messagesRegisteredEntryByActionKey[actionKey];
  if (definition == null || definition.canonicalPath != canonicalPath) {
    return null;
  }
  final routeLocation = definition.buildRouteLocation(params);
  if (routeLocation == null || routeLocation.startsWith('routeTarget.')) {
    return null;
  }
  return routeLocation;
}

String? _resolveActionKey({
  required String canonicalPath,
  required String? localEntryKey,
}) {
  if (localEntryKey != null &&
      messagesRegisteredEntryByActionKey.containsKey(localEntryKey)) {
    return localEntryKey;
  }
  for (final entry in messagesRegisteredEntryByActionKey.entries) {
    final definition = entry.value;
    if (definition.canonicalPath != canonicalPath) {
      continue;
    }
    if (localEntryKey == null ||
        localEntryKey == definition.localEntryKey ||
        localEntryKey == definition.actionKey) {
      return entry.key;
    }
  }
  return null;
}

Map<String, Object?> _requiredMap(Object? value, String label) {
  if (value is Map) {
    return value.map((Object? key, Object? entry) => MapEntry('$key', entry));
  }
  throw FormatException('$label response must be an object');
}

Map<String, Object?>? _optionalMap(Object? value) {
  if (value is! Map) {
    return null;
  }
  return value.map((Object? key, Object? entry) => MapEntry('$key', entry));
}

Map<String, String> _parseParams(Object? value) {
  final map = _optionalMap(value);
  if (map == null) {
    return const <String, String>{};
  }
  final result = <String, String>{};
  for (final entry in map.entries) {
    final normalized = _nullableString(entry.value);
    if (normalized != null && entry.key.trim().isNotEmpty) {
      result[entry.key.trim()] = normalized;
    }
  }
  return Map<String, String>.unmodifiable(result);
}

String _requiredString(Map<String, Object?> map, String key) {
  final value = _nullableString(map[key]);
  if (value == null) {
    throw FormatException('app notification response missing "$key"');
  }
  return value;
}

String? _nullableString(Object? value) {
  if (value is! String) {
    return null;
  }
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

int _optionalNonNegativeInt(Object? value) {
  final parsed = value is int
      ? value
      : value is num && value == value.roundToDouble()
      ? value.toInt()
      : value is String
      ? int.tryParse(value)
      : null;
  return parsed == null || parsed < 0 ? 0 : parsed;
}
