import 'dart:io';

import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/features/messages/data/messages_registered_entry_registry.dart';

final class MessagesCanonicalPaths {
  const MessagesCanonicalPaths._();

  static const String messageIndex = '/api/app/message/index';
}

class MessagesRouteTarget {
  const MessagesRouteTarget({
    required this.canonicalPath,
    required this.localEntryKey,
    required this.requiredParams,
    required this.state,
    required this.routeParams,
    required this.routeLocation,
  });

  final String canonicalPath;
  final String localEntryKey;
  final List<String> requiredParams;
  final String state;
  final Map<String, String> routeParams;
  final String routeLocation;
}

class MessagesTodoItem {
  const MessagesTodoItem({
    required this.todoId,
    required this.messageType,
    required this.instanceRef,
    required this.actionKey,
    required this.title,
    required this.summary,
    required this.routeTarget,
    required this.state,
  });

  final String todoId;
  final String messageType;
  final Map<String, String> instanceRef;
  final String actionKey;
  final String title;
  final String summary;
  final MessagesRouteTarget routeTarget;
  final String state;
}

class MessagesIndexResult {
  const MessagesIndexResult({
    required this.state,
    required this.method,
    required this.path,
    this.items = const <MessagesTodoItem>[],
    this.message,
  });

  final AppPageState state;
  final String method;
  final String path;
  final List<MessagesTodoItem> items;
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

  Future<MessagesIndexResult> loadIndex() async {
    try {
      final response = await _client.get(MessagesCanonicalPaths.messageIndex);
      return _mapResponse(response);
    } on SocketException {
      return const MessagesIndexResult(
        state: AppPageState.errorRetryable,
        method: 'GET',
        path: MessagesCanonicalPaths.messageIndex,
        message: 'network error while loading instance_todo items',
      );
    } on HttpException {
      return const MessagesIndexResult(
        state: AppPageState.errorRetryable,
        method: 'GET',
        path: MessagesCanonicalPaths.messageIndex,
        message: 'http error while loading instance_todo items',
      );
    } on StateError {
      return const MessagesIndexResult(
        state: AppPageState.empty,
        method: 'GET',
        path: MessagesCanonicalPaths.messageIndex,
        message: 'current fake transport did not provide message index',
      );
    } on FormatException {
      return const MessagesIndexResult(
        state: AppPageState.errorNonRetryable,
        method: 'GET',
        path: MessagesCanonicalPaths.messageIndex,
        message: 'response decoding failed for instance_todo items',
      );
    }
  }

  MessagesIndexResult _mapResponse(AppApiResponse response) {
    if (response.statusCode >= 500) {
      return MessagesIndexResult(
        state: AppPageState.errorRetryable,
        method: 'GET',
        path: MessagesCanonicalPaths.messageIndex,
        message: _extractMessage(response.body) ?? 'instance_todo index failed',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return MessagesIndexResult(
        state: AppPageState.errorNonRetryable,
        method: 'GET',
        path: MessagesCanonicalPaths.messageIndex,
        message:
            _extractMessage(response.body) ??
            'instance_todo index returned a controlled failure',
      );
    }

    final payload = response.body;
    if (payload is! Map) {
      return const MessagesIndexResult(
        state: AppPageState.errorNonRetryable,
        method: 'GET',
        path: MessagesCanonicalPaths.messageIndex,
        message:
            'instance_todo index response must be an object containing items',
      );
    }

    final rawItems = payload['items'];
    if (rawItems is! List) {
      return const MessagesIndexResult(
        state: AppPageState.errorNonRetryable,
        method: 'GET',
        path: MessagesCanonicalPaths.messageIndex,
        message:
            'instance_todo index response is missing required field "items"',
      );
    }

    final items = <MessagesTodoItem>[];
    for (var index = 0; index < rawItems.length; index += 1) {
      final rawItem = rawItems[index];
      if (rawItem is! Map) {
        return MessagesIndexResult(
          state: AppPageState.errorNonRetryable,
          method: 'GET',
          path: MessagesCanonicalPaths.messageIndex,
          message: 'instance_todo items[$index] must be an object',
        );
      }

      final item = _parseTodoItem(
        rawItem.map((Object? key, Object? value) => MapEntry('$key', value)),
      );
      if (item is String) {
        return MessagesIndexResult(
          state: AppPageState.errorNonRetryable,
          method: 'GET',
          path: MessagesCanonicalPaths.messageIndex,
          message: item,
        );
      }
      items.add(item as MessagesTodoItem);
    }

    return MessagesIndexResult(
      state: items.isEmpty ? AppPageState.empty : AppPageState.content,
      method: 'GET',
      path: MessagesCanonicalPaths.messageIndex,
      items: items,
    );
  }
}

Object _parseTodoItem(Map<String, Object?> raw) {
  final todoId = _readRequiredString(raw, 'todoId');
  final messageType = _readRequiredString(raw, 'messageType');
  final actionKey = _readRequiredString(raw, 'actionKey');
  final title = _readRequiredString(raw, 'title');
  final summary = _readRequiredString(raw, 'summary');
  final state = _readRequiredString(raw, 'state');
  final instanceRef = _parseInstanceRef(raw['instanceRef']);

  if (todoId == null) {
    return 'instance_todo is missing required field "todoId"';
  }
  if (messageType == null) {
    return 'instance_todo is missing required field "messageType"';
  }
  if (messageType != 'instance_todo') {
    return 'instance_todo item must carry messageType "instance_todo"';
  }
  if (actionKey == null) {
    return 'instance_todo is missing required field "actionKey"';
  }
  if (!messagesAllowedActionKeys.contains(actionKey)) {
    return 'instance_todo actionKey "$actionKey" is outside the frozen first batch';
  }
  if (title == null) {
    return 'instance_todo is missing required field "title"';
  }
  if (summary == null) {
    return 'instance_todo is missing required field "summary"';
  }
  if (state == null) {
    return 'instance_todo is missing required field "state"';
  }
  if (state != 'pending') {
    return 'instance_todo state "$state" is outside the frozen minimal state';
  }
  if (instanceRef is String) {
    return instanceRef;
  }

  final routeTarget = _parseRouteTarget(actionKey, raw['routeTarget']);
  if (routeTarget is String) {
    return routeTarget;
  }

  final sanitizedInstanceRef = instanceRef as Map<String, String>;
  if (messagesActionKeyToObjectType[actionKey] !=
      sanitizedInstanceRef['objectType']) {
    return 'instance_todo objectType must align with actionKey "$actionKey"';
  }

  return MessagesTodoItem(
    todoId: todoId,
    messageType: messageType,
    instanceRef: sanitizedInstanceRef,
    actionKey: actionKey,
    title: title,
    summary: summary,
    routeTarget: routeTarget as MessagesRouteTarget,
    state: state,
  );
}

Object _parseInstanceRef(Object? raw) {
  if (raw is! Map) {
    return 'instance_todo instanceRef must be an object';
  }

  final map = raw.map((Object? key, Object? value) => MapEntry('$key', value));
  final objectType = _readRequiredString(map, 'objectType');
  final instanceId = _readRequiredString(map, 'instanceId');

  if (objectType == null) {
    return 'instance_todo is missing required field "objectType"';
  }
  if (!messagesAllowedObjectTypes.contains(objectType)) {
    return 'instance_todo objectType "$objectType" is outside the frozen first batch';
  }
  if (instanceId == null) {
    return 'instance_todo is missing required field "instanceId"';
  }

  return <String, String>{'objectType': objectType, 'instanceId': instanceId};
}

Object _parseRouteTarget(String actionKey, Object? raw) {
  if (raw is! Map) {
    return 'instance_todo routeTarget must be an object';
  }

  final definition = messagesRegisteredEntryByActionKey[actionKey];
  if (definition == null) {
    return 'instance_todo actionKey "$actionKey" is outside the frozen first batch';
  }

  final map = raw.map((Object? key, Object? value) => MapEntry('$key', value));
  final canonicalPath = _readRequiredString(map, 'canonicalPath');
  final localEntryKey = _readRequiredString(map, 'localEntryKey');
  final state = _readRequiredString(map, 'state');
  final requiredParams = _parseRequiredParams(map['requiredParams']);
  final routeParams = _parseRouteParams(map['routeParams']);

  if (canonicalPath == null) {
    return 'instance_todo routeTarget is missing required field "canonicalPath"';
  }
  if (localEntryKey == null) {
    return 'instance_todo routeTarget is missing required field "localEntryKey"';
  }
  if (state == null) {
    return 'instance_todo routeTarget is missing required field "state"';
  }
  if (requiredParams is String) {
    return requiredParams;
  }
  if (routeParams is String) {
    return routeParams;
  }

  final validationError = definition.validateSkeleton(
    canonicalPath: canonicalPath,
    localEntryKey: localEntryKey,
    requiredParams: requiredParams as List<String>,
    state: state,
  );
  if (validationError != null) {
    return validationError;
  }

  final routeLocation = definition.buildRouteLocation(
    routeParams as Map<String, String>,
  );
  if (routeLocation == null) {
    return 'routeTarget actionKey "$actionKey" is unsupported';
  }
  if (routeLocation.startsWith('routeTarget')) {
    return routeLocation;
  }

  return MessagesRouteTarget(
    canonicalPath: canonicalPath,
    localEntryKey: localEntryKey,
    requiredParams: requiredParams,
    state: state,
    routeParams: routeParams,
    routeLocation: routeLocation,
  );
}

Object _parseRequiredParams(Object? raw) {
  if (raw is! List) {
    return 'instance_todo routeTarget.requiredParams must be an array of non-empty strings';
  }

  final requiredParams = <String>[];
  for (final value in raw) {
    final sanitized = '$value'.trim();
    if (sanitized.isEmpty) {
      return 'instance_todo routeTarget.requiredParams must be an array of non-empty strings';
    }
    requiredParams.add(sanitized);
  }
  return requiredParams;
}

Object _parseRouteParams(Object? raw) {
  if (raw is! Map) {
    return 'instance_todo routeTarget.routeParams must be an object';
  }

  final routeParams = <String, String>{};
  for (final entry in raw.entries) {
    final key = '${entry.key}'.trim();
    final value = '${entry.value ?? ''}'.trim();
    if (key.isEmpty || value.isEmpty) {
      return 'instance_todo routeTarget.routeParams must contain non-empty string values';
    }
    routeParams[key] = value;
  }
  return routeParams;
}

String? _readRequiredString(Map<String, Object?> raw, String field) {
  final value = '${raw[field] ?? ''}'.trim();
  return value.isEmpty ? null : value;
}

String? _extractMessage(Object? payload) {
  if (payload is! Map) {
    return null;
  }

  final value = '${payload['message'] ?? ''}'.trim();
  return value.isEmpty ? null : value;
}
