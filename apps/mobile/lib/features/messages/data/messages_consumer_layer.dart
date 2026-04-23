import 'dart:io';

import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/features/messages/data/messages_registered_entry_registry.dart';

final class MessagesCanonicalPaths {
  const MessagesCanonicalPaths._();

  static const String messageInteractions = '/api/app/message/interactions';
}

final class MessageInteractionRouteTarget {
  const MessageInteractionRouteTarget({
    required this.objectType,
    required this.actionKey,
    required this.canonicalPath,
    required this.params,
    required this.routeLocation,
  });

  final String objectType;
  final String actionKey;
  final String canonicalPath;
  final Map<String, String> params;
  final String routeLocation;
}

final class MessageInteractionCounterpartView {
  const MessageInteractionCounterpartView({
    required this.organizationId,
    required this.displayName,
    required this.avatarUrl,
    required this.role,
  });

  final String organizationId;
  final String displayName;
  final String? avatarUrl;
  final String role;
}

final class MessageInteractionSeedSummaryView {
  const MessageInteractionSeedSummaryView({
    required this.seedType,
    required this.title,
    required this.summary,
    required this.ctaLabel,
  });

  final String seedType;
  final String title;
  final String summary;
  final String ctaLabel;
}

final class MessageInteractionLastMessageSummaryView {
  const MessageInteractionLastMessageSummaryView({
    required this.text,
    required this.messageKind,
    required this.createdAt,
  });

  final String text;
  final String messageKind;
  final String? createdAt;
}

final class MessageInteractionItemView {
  const MessageInteractionItemView({
    required this.interactionId,
    required this.interactionType,
    required this.threadId,
    required this.projectId,
    required this.bidId,
    required this.counterpart,
    required this.seedSummary,
    required this.lastMessageSummary,
    required this.updatedAt,
    required this.routeTarget,
  });

  final String interactionId;
  final String interactionType;
  final String threadId;
  final String projectId;
  final String bidId;
  final MessageInteractionCounterpartView counterpart;
  final MessageInteractionSeedSummaryView seedSummary;
  final MessageInteractionLastMessageSummaryView? lastMessageSummary;
  final String updatedAt;
  final MessageInteractionRouteTarget routeTarget;
}

final class MessageInteractionListResult {
  const MessageInteractionListResult({
    required this.state,
    required this.method,
    required this.path,
    required this.lane,
    this.items = const <MessageInteractionItemView>[],
    this.message,
  });

  final AppPageState state;
  final String method;
  final String path;
  final String lane;
  final List<MessageInteractionItemView> items;
  final String? message;
}

class MessagesConsumerLayer {
  MessagesConsumerLayer._(this._client);

  factory MessagesConsumerLayer({AppApiClient? client}) {
    return MessagesConsumerLayer._(client ?? AppApiClient());
  }

  static MessagesConsumerLayer _instance = MessagesConsumerLayer();

  static MessagesConsumerLayer get instance => _instance;

  static void install(MessagesConsumerLayer consumerLayer) {
    _instance = consumerLayer;
  }

  static void reset() {
    _instance = MessagesConsumerLayer();
  }

  final AppApiClient _client;

  String get configuredEnvironmentLabel =>
      _client.config.userFacingEnvironmentLabel;

  Future<MessageInteractionListResult> loadInteractions({
    String lane = 'project_communication',
  }) async {
    try {
      final response = await _client.get(
        MessagesCanonicalPaths.messageInteractions,
        queryParameters: <String, String>{'lane': lane},
      );
      return _mapResponse(response);
    } on SocketException {
      return MessageInteractionListResult(
        state: AppPageState.errorRetryable,
        method: 'GET',
        path: MessagesCanonicalPaths.messageInteractions,
        lane: lane,
        message: 'network error while loading message interactions',
      );
    } on HttpException {
      return MessageInteractionListResult(
        state: AppPageState.errorRetryable,
        method: 'GET',
        path: MessagesCanonicalPaths.messageInteractions,
        lane: lane,
        message: 'http error while loading message interactions',
      );
    } on StateError {
      return MessageInteractionListResult(
        state: AppPageState.empty,
        method: 'GET',
        path: MessagesCanonicalPaths.messageInteractions,
        lane: lane,
        message: 'current fake transport did not provide message interactions',
      );
    } on FormatException catch (error) {
      return MessageInteractionListResult(
        state: AppPageState.errorNonRetryable,
        method: 'GET',
        path: MessagesCanonicalPaths.messageInteractions,
        lane: lane,
        message: error.message,
      );
    }
  }

  @Deprecated('Use loadInteractions() instead.')
  Future<MessageInteractionListResult> loadIndex() {
    return loadInteractions();
  }

  MessageInteractionListResult _mapResponse(AppApiResponse response) {
    if (response.statusCode >= 500) {
      return MessageInteractionListResult(
        state: AppPageState.errorRetryable,
        method: 'GET',
        path: MessagesCanonicalPaths.messageInteractions,
        lane: 'project_communication',
        message:
            _extractMessage(response.body) ??
            'message interactions temporarily unavailable',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return MessageInteractionListResult(
        state: AppPageState.errorNonRetryable,
        method: 'GET',
        path: MessagesCanonicalPaths.messageInteractions,
        lane: 'project_communication',
        message:
            _extractMessage(response.body) ??
            'message interactions returned a controlled failure',
      );
    }

    final payload = response.body;
    if (payload is! Map) {
      return const MessageInteractionListResult(
        state: AppPageState.errorNonRetryable,
        method: 'GET',
        path: MessagesCanonicalPaths.messageInteractions,
        lane: 'project_communication',
        message:
            'message interactions response must be an object containing lane and items',
      );
    }

    final lane = _readRequiredString(payload, 'lane');
    if (lane == null) {
      return const MessageInteractionListResult(
        state: AppPageState.errorNonRetryable,
        method: 'GET',
        path: MessagesCanonicalPaths.messageInteractions,
        lane: 'project_communication',
        message:
            'message interactions response is missing required field "lane"',
      );
    }
    if (lane != 'project_communication') {
      return MessageInteractionListResult(
        state: AppPageState.errorNonRetryable,
        method: 'GET',
        path: MessagesCanonicalPaths.messageInteractions,
        lane: lane,
        message: 'message interactions response returned an unsupported lane',
      );
    }

    final rawItems = payload['items'];
    if (rawItems is! List) {
      return MessageInteractionListResult(
        state: AppPageState.errorNonRetryable,
        method: 'GET',
        path: MessagesCanonicalPaths.messageInteractions,
        lane: lane,
        message:
            'message interactions response is missing required field "items"',
      );
    }

    final items = <MessageInteractionItemView>[];
    for (var index = 0; index < rawItems.length; index += 1) {
      final rawItem = rawItems[index];
      if (rawItem is! Map) {
        return MessageInteractionListResult(
          state: AppPageState.errorNonRetryable,
          method: 'GET',
          path: MessagesCanonicalPaths.messageInteractions,
          lane: lane,
          message: 'message interactions items[$index] must be an object',
        );
      }
      final item = _parseInteractionItem(
        rawItem.map((Object? key, Object? value) => MapEntry('$key', value)),
      );
      if (item is String) {
        return MessageInteractionListResult(
          state: AppPageState.errorNonRetryable,
          method: 'GET',
          path: MessagesCanonicalPaths.messageInteractions,
          lane: lane,
          message: item,
        );
      }
      items.add(item as MessageInteractionItemView);
    }

    return MessageInteractionListResult(
      state: items.isEmpty ? AppPageState.empty : AppPageState.content,
      method: 'GET',
      path: MessagesCanonicalPaths.messageInteractions,
      lane: lane,
      items: items,
    );
  }
}

Object _parseInteractionItem(Map<String, Object?> raw) {
  final interactionId = _readRequiredString(raw, 'interactionId');
  final interactionType = _readRequiredString(raw, 'interactionType');
  final threadId = _readRequiredString(raw, 'threadId');
  final projectId = _readRequiredString(raw, 'projectId');
  final bidId = _readRequiredString(raw, 'bidId');
  final updatedAt = _readRequiredString(raw, 'updatedAt');

  if (interactionId == null) {
    return 'message interaction is missing required field "interactionId"';
  }
  if (interactionType == null) {
    return 'message interaction is missing required field "interactionType"';
  }
  if (interactionType != 'bid_thread') {
    return 'message interaction returned an unsupported interactionType';
  }
  if (threadId == null) {
    return 'message interaction is missing required field "threadId"';
  }
  if (projectId == null) {
    return 'message interaction is missing required field "projectId"';
  }
  if (bidId == null) {
    return 'message interaction is missing required field "bidId"';
  }
  if (updatedAt == null) {
    return 'message interaction is missing required field "updatedAt"';
  }

  final counterpart = _parseCounterpart(raw['counterpart']);
  if (counterpart is String) {
    return counterpart;
  }
  final seedSummary = _parseSeedSummary(raw['seedSummary']);
  if (seedSummary is String) {
    return seedSummary;
  }
  final lastMessageSummary = _parseLastMessageSummary(raw['lastMessageSummary']);
  if (lastMessageSummary is String) {
    return lastMessageSummary;
  }
  final routeTarget = _parseRouteTarget(raw['routeTarget']);
  if (routeTarget is String) {
    return routeTarget;
  }

  return MessageInteractionItemView(
    interactionId: interactionId,
    interactionType: interactionType,
    threadId: threadId,
    projectId: projectId,
    bidId: bidId,
    counterpart: counterpart as MessageInteractionCounterpartView,
    seedSummary: seedSummary as MessageInteractionSeedSummaryView,
    lastMessageSummary:
        lastMessageSummary as MessageInteractionLastMessageSummaryView?,
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
  if (raw.containsKey('avatarUrl') && raw['avatarUrl'] != null && avatarUrl == null) {
    return 'message interaction counterpart.avatarUrl must be a string when present';
  }
  return MessageInteractionCounterpartView(
    organizationId: organizationId,
    displayName: displayName,
    avatarUrl: avatarUrl,
    role: role,
  );
}

Object _parseSeedSummary(Object? raw) {
  if (raw is! Map) {
    return 'message interaction seedSummary must be an object';
  }
  final seedType = _readRequiredString(raw, 'seedType');
  final title = _readRequiredString(raw, 'title');
  final summary = _readRequiredString(raw, 'summary');
  final ctaLabel = _readRequiredString(raw, 'ctaLabel');
  if (seedType == null) {
    return 'message interaction seedSummary is missing required field "seedType"';
  }
  if (seedType != 'bid_submitted') {
    return 'message interaction seedSummary returned an unsupported seedType';
  }
  if (title == null) {
    return 'message interaction seedSummary is missing required field "title"';
  }
  if (summary == null) {
    return 'message interaction seedSummary is missing required field "summary"';
  }
  if (ctaLabel == null) {
    return 'message interaction seedSummary is missing required field "ctaLabel"';
  }
  return MessageInteractionSeedSummaryView(
    seedType: seedType,
    title: title,
    summary: summary,
    ctaLabel: ctaLabel,
  );
}

Object? _parseLastMessageSummary(Object? raw) {
  if (raw == null) {
    return null;
  }
  if (raw is String) {
    final normalized = raw.trim();
    if (normalized.isEmpty) {
      return 'message interaction lastMessageSummary must be non-empty when present';
    }
    return MessageInteractionLastMessageSummaryView(
      text: normalized,
      messageKind: 'plain_text',
      createdAt: null,
    );
  }
  if (raw is! Map) {
    return 'message interaction lastMessageSummary must be either an object or a string';
  }
  final text = _readRequiredString(raw, 'text');
  final messageKind = _readRequiredString(raw, 'messageKind');
  if (text == null) {
    return 'message interaction lastMessageSummary is missing required field "text"';
  }
  if (messageKind == null) {
    return 'message interaction lastMessageSummary is missing required field "messageKind"';
  }
  final createdAt = _readNullableString(raw['createdAt']);
  if (raw.containsKey('createdAt') && raw['createdAt'] != null && createdAt == null) {
    return 'message interaction lastMessageSummary.createdAt must be a string when present';
  }
  return MessageInteractionLastMessageSummaryView(
    text: text,
    messageKind: messageKind,
    createdAt: createdAt,
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
  if (actionKey != 'bid_thread.open') {
    return 'message interaction routeTarget actionKey is outside the bounded trading scope';
  }

  final routeLocation = definition.buildRouteLocation(params as Map<String, String>);
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

String? _extractMessage(Object? payload) {
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

String? _readRequiredString(Map raw, String fieldName) {
  return _readNullableString(raw[fieldName]);
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
