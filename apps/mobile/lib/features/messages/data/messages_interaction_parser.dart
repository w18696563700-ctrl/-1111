import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/features/exhibition/data/p0_pay_read_only_summary.dart';
import 'package:mobile/features/messages/data/messages_interaction_models.dart';
import 'package:mobile/features/messages/data/messages_registered_entry_registry.dart';

const Set<String> _counterpartCardTypes = <String>{
  'project_name_access_request',
  'bid_thread',
  'project_clarification',
  'project_order',
  'system_notice',
};

MessageInteractionPayloadParseResult parseMessageInteractionPayload(
  Object? payload,
) {
  if (payload is! Map) {
    return const MessageInteractionPayloadParseResult(
      state: AppPageState.errorNonRetryable,
      lane: 'project_communication',
      message:
          'message interactions response must be an object containing lane and items',
    );
  }

  final lane = _readRequiredString(payload, 'lane');
  if (lane == null) {
    return const MessageInteractionPayloadParseResult(
      state: AppPageState.errorNonRetryable,
      lane: 'project_communication',
      message: 'message interactions response is missing required field "lane"',
    );
  }
  if (lane != 'project_communication') {
    return MessageInteractionPayloadParseResult(
      state: AppPageState.errorNonRetryable,
      lane: lane,
      message: 'message interactions response returned an unsupported lane',
    );
  }

  final rawItems = payload['items'];
  if (rawItems is! List) {
    return MessageInteractionPayloadParseResult(
      state: AppPageState.errorNonRetryable,
      lane: lane,
      message:
          'message interactions response is missing required field "items"',
    );
  }

  final items = <MessageInteractionItemView>[];
  for (var index = 0; index < rawItems.length; index += 1) {
    final rawItem = rawItems[index];
    if (rawItem is! Map) {
      return MessageInteractionPayloadParseResult(
        state: AppPageState.errorNonRetryable,
        lane: lane,
        message: 'message interactions items[$index] must be an object',
      );
    }
    final item = _parseInteractionItem(
      rawItem.map((Object? key, Object? value) => MapEntry('$key', value)),
    );
    if (item is String) {
      return MessageInteractionPayloadParseResult(
        state: AppPageState.errorNonRetryable,
        lane: lane,
        message: item,
      );
    }
    items.add(item as MessageInteractionItemView);
  }

  return MessageInteractionPayloadParseResult(
    state: items.isEmpty ? AppPageState.empty : AppPageState.content,
    lane: lane,
    items: items,
  );
}

String? extractMessage(Object? payload) {
  if (payload is Map) {
    final message = payload['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message.trim();
    }
    final errorMessage = payload['errorMessage'];
    if (errorMessage is String && errorMessage.trim().isNotEmpty) {
      return errorMessage.trim();
    }
  }
  if (payload is String && payload.trim().isNotEmpty) {
    return payload.trim();
  }
  return null;
}

Object _parseInteractionItem(Map<String, Object?> raw) {
  final interactionId = _readRequiredString(raw, 'interactionId');
  final interactionType = _readRequiredString(raw, 'interactionType');
  final conversationId = _readRequiredString(raw, 'conversationId');
  final projectId = _readRequiredString(raw, 'projectId');
  final updatedAt = _readRequiredString(raw, 'updatedAt');

  if (interactionId == null) {
    return 'message interaction is missing required field "interactionId"';
  }
  if (interactionType == null) {
    return 'message interaction is missing required field "interactionType"';
  }
  if (interactionType != 'counterpart_conversation') {
    return 'message interaction returned an unsupported interactionType';
  }
  if (conversationId == null) {
    return 'message interaction is missing required field "conversationId"';
  }
  if (projectId == null) {
    return 'message interaction is missing required field "projectId"';
  }
  if (updatedAt == null) {
    return 'message interaction is missing required field "updatedAt"';
  }

  final counterpart = _parseCounterpart(raw['counterpart']);
  if (counterpart is String) {
    return counterpart;
  }
  final summary = _parseSummary(raw['summary']);
  if (summary is String) {
    return summary;
  }
  final routeTarget = _parseRouteTarget(raw['routeTarget']);
  if (routeTarget is String) {
    return routeTarget;
  }

  return MessageInteractionItemView(
    interactionId: interactionId,
    interactionType: interactionType,
    conversationId: conversationId,
    projectId: projectId,
    counterpart: counterpart as MessageInteractionCounterpartView,
    summary: summary as MessageInteractionSummaryView,
    p0PaySummary: parseP0PayReadOnlySummary(
      raw['p0PaySummary'] ?? raw['paymentStatusSummary'],
    ),
    updatedAt: updatedAt,
    routeTarget: routeTarget as MessageInteractionRouteTarget,
  );
}

Object _parseCounterpart(Object? raw) {
  if (raw is! Map) {
    return 'message interaction counterpart must be an object';
  }
  final organizationId = _readRequiredString(raw, 'organizationId');
  final displayName = _readRequiredString(raw, 'displayName');
  final role = _readRequiredString(raw, 'role');
  if (organizationId == null) {
    return 'message interaction counterpart is missing required field "organizationId"';
  }
  if (displayName == null) {
    return 'message interaction counterpart is missing required field "displayName"';
  }
  if (role == null) {
    return 'message interaction counterpart is missing required field "role"';
  }
  final avatarUrl = _readNullableString(raw['avatarUrl']);
  if (raw.containsKey('avatarUrl') &&
      raw['avatarUrl'] != null &&
      avatarUrl == null) {
    return 'message interaction counterpart.avatarUrl must be a string when present';
  }
  return MessageInteractionCounterpartView(
    organizationId: organizationId,
    displayName: displayName,
    avatarUrl: avatarUrl,
    role: role,
  );
}

Object _parseSummary(Object? raw) {
  if (raw is! Map) {
    return 'message interaction summary must be an object';
  }
  final focusProjectId = _readRequiredString(raw, 'focusProjectId');
  final title = _readRequiredString(raw, 'title');
  final text = _readRequiredString(raw, 'text');
  final projectCount = _readRequiredInt(raw, 'projectCount');
  final latestCardType = _readRequiredString(raw, 'latestCardType');
  if (focusProjectId == null) {
    return 'message interaction summary is missing required field "focusProjectId"';
  }
  if (title == null) {
    return 'message interaction summary is missing required field "title"';
  }
  if (text == null) {
    return 'message interaction summary is missing required field "text"';
  }
  if (projectCount == null) {
    return 'message interaction summary is missing required field "projectCount"';
  }
  if (latestCardType == null) {
    return 'message interaction summary is missing required field "latestCardType"';
  }
  if (!_counterpartCardTypes.contains(latestCardType)) {
    return 'message interaction summary returned an unsupported latestCardType';
  }
  return MessageInteractionSummaryView(
    focusProjectId: focusProjectId,
    title: title,
    text: text,
    projectCount: projectCount,
    latestCardType: latestCardType,
  );
}

Object _parseRouteTarget(Object? raw) {
  if (raw is! Map) {
    return 'message interaction routeTarget must be an object';
  }

  final objectType = _readRequiredString(raw, 'objectType');
  final actionKey = _readRequiredString(raw, 'actionKey');
  final canonicalPath = _readRequiredString(raw, 'canonicalPath');
  final params = _parseRouteParams(raw['params']);
  if (objectType == null) {
    return 'message interaction routeTarget is missing required field "objectType"';
  }
  if (actionKey == null) {
    return 'message interaction routeTarget is missing required field "actionKey"';
  }
  if (canonicalPath == null) {
    return 'message interaction routeTarget is missing required field "canonicalPath"';
  }
  if (params is String) {
    return params;
  }

  final definition = messagesRegisteredEntryByActionKey[actionKey];
  if (definition == null) {
    return 'message interaction routeTarget returned an unsupported actionKey';
  }
  if (definition.objectType != objectType) {
    return 'message interaction routeTarget objectType does not match the frozen action mapping';
  }
  if (definition.canonicalPath != canonicalPath) {
    return 'message interaction routeTarget canonicalPath does not match the frozen action mapping';
  }
  if (actionKey != 'counterpart_conversation.open') {
    return 'message interaction routeTarget actionKey is outside the bounded trading scope';
  }

  final routeLocation = definition.buildRouteLocation(
    params as Map<String, String>,
  );
  if (routeLocation == null) {
    return 'message interaction routeTarget failed to build local route location';
  }
  if (routeLocation.startsWith('routeTarget.')) {
    return routeLocation;
  }

  return MessageInteractionRouteTarget(
    objectType: objectType,
    actionKey: actionKey,
    canonicalPath: canonicalPath,
    params: params,
    routeLocation: routeLocation,
  );
}

Object _parseRouteParams(Object? raw) {
  if (raw is! Map) {
    return 'message interaction routeTarget.params must be an object';
  }
  final params = <String, String>{};
  for (final entry in raw.entries) {
    final key = '${entry.key}'.trim();
    final value = _readNullableString(entry.value);
    if (key.isEmpty || value == null || value.trim().isEmpty) {
      return 'message interaction routeTarget.params must contain only non-empty strings';
    }
    params[key] = value;
  }
  return params;
}

String? _readRequiredString(Map raw, String fieldName) {
  return _readNullableString(raw[fieldName]);
}

int? _readRequiredInt(Map raw, String fieldName) {
  final value = raw[fieldName];
  if (value is int) {
    return value;
  }
  return null;
}

String? _readNullableString(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is! String) {
    return null;
  }
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}
