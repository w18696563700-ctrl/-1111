import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/auth/auth_consumer_layer.dart';
import 'package:mobile/features/messages/data/counterpart_conversation_models.dart';

typedef ProjectCommunicationWebSocketConnector =
    Future<WebSocket> Function(Uri uri, Map<String, String> headers);

abstract interface class ProjectCommunicationRealtimeClient {
  Future<ProjectCommunicationRealtimeSubscription> subscribe({
    required String threadId,
    required String projectId,
    required String counterpartOrganizationId,
  });
}

final class ProjectCommunicationRealtimeSubscription {
  const ProjectCommunicationRealtimeSubscription({
    required this.events,
    required this.done,
    required this.close,
  });

  final Stream<ProjectCommunicationMessageCreatedEvent> events;
  final Future<void> done;
  final Future<void> Function() close;
}

final class ProjectCommunicationMessageCreatedEvent {
  const ProjectCommunicationMessageCreatedEvent({
    required this.eventId,
    required this.messageId,
    required this.threadId,
    required this.projectId,
    required this.senderOrganizationId,
    required this.messageKind,
    required this.body,
    required this.clientMessageId,
    required this.createdAt,
    this.attachment,
    this.confirmation,
  });

  final String eventId;
  final String messageId;
  final String threadId;
  final String projectId;
  final String senderOrganizationId;
  final String messageKind;
  final String body;
  final ProjectCommunicationAttachmentView? attachment;
  final ProjectCommunicationConfirmationView? confirmation;
  final String? clientMessageId;
  final String createdAt;

  ProjectCommunicationMessageView toMessageView() {
    return ProjectCommunicationMessageView(
      messageId: messageId,
      threadId: threadId,
      projectId: projectId,
      senderUserId: senderOrganizationId,
      senderActorId: null,
      senderOrganizationId: senderOrganizationId,
      messageKind: messageKind,
      body: body,
      attachment: attachment,
      confirmation: confirmation,
      clientMessageId: clientMessageId,
      messageState: 'active',
      deliveryState: 'persisted',
      readState: 'not_applicable',
      readByCounterpartAt: null,
      createdAt: createdAt,
    );
  }
}

final class ProjectCommunicationIoRealtimeClient
    implements ProjectCommunicationRealtimeClient {
  ProjectCommunicationIoRealtimeClient({
    required AppApiClient client,
    ProjectCommunicationWebSocketConnector? connector,
  }) : _client = client,
       _connector = connector ?? _connect;

  static const String canonicalPath =
      '/api/app/message/project-communication/realtime';

  final AppApiClient _client;
  final ProjectCommunicationWebSocketConnector _connector;

  @override
  Future<ProjectCommunicationRealtimeSubscription> subscribe({
    required String threadId,
    required String projectId,
    required String counterpartOrganizationId,
  }) async {
    if (AppSessionStore.instance.shouldRefresh) {
      await AuthConsumerLayer.instance.refreshSession();
    }
    final uri = _webSocketUri(
      _client.config.resolveCanonicalPath(canonicalPath),
    );
    final socket = await _connector(uri, <String, String>{
      ..._client.config.defaultHeaders,
      ...AppSessionStore.instance.authorizationHeaders,
    }).timeout(_client.config.requestTimeout);
    socket.add(
      jsonEncode(<String, Object?>{
        'action': 'project_communication.subscribe',
        'threadId': threadId,
        'projectId': projectId,
        'counterpartOrganizationId': counterpartOrganizationId,
      }),
    );
    return ProjectCommunicationRealtimeSubscription(
      events: socket
          .map(_decodeSocketMessage)
          .map(_parseMessageCreatedEvent)
          .where((ProjectCommunicationMessageCreatedEvent? event) {
            return event != null;
          })
          .cast<ProjectCommunicationMessageCreatedEvent>(),
      done: socket.done.then((_) {}),
      close: () async {
        await socket.close();
      },
    );
  }

  static Future<WebSocket> _connect(Uri uri, Map<String, String> headers) {
    return WebSocket.connect(uri.toString(), headers: headers);
  }
}

Uri _webSocketUri(Uri uri) {
  final scheme = switch (uri.scheme) {
    'https' => 'wss',
    'http' => 'ws',
    final value => value,
  };
  return uri.replace(scheme: scheme);
}

Object? _decodeSocketMessage(Object? payload) {
  if (payload is String) {
    return jsonDecode(payload);
  }
  if (payload is List<int>) {
    return jsonDecode(utf8.decode(payload));
  }
  throw const FormatException('unsupported project communication ws payload');
}

ProjectCommunicationMessageCreatedEvent? _parseMessageCreatedEvent(
  Object? payload,
) {
  final map = _requiredMap(payload);
  final eventType = _requiredString(map, 'eventType');
  if (eventType != 'project_communication.message.created') {
    return null;
  }
  return ProjectCommunicationMessageCreatedEvent(
    eventId: _requiredString(map, 'eventId'),
    messageId: _requiredString(map, 'messageId'),
    threadId: _requiredString(map, 'threadId'),
    projectId: _requiredString(map, 'projectId'),
    senderOrganizationId: _requiredString(map, 'senderOrganizationId'),
    messageKind: _requiredString(map, 'messageKind'),
    body: _bodyString(map, 'body'),
    attachment: _parseAttachment(map['payload']),
    confirmation: _parseConfirmation(map['payload']),
    clientMessageId: _nullableString(map['clientMessageId']),
    createdAt: _requiredString(map, 'createdAt'),
  );
}

ProjectCommunicationAttachmentView? _parseAttachment(Object? payload) {
  if (payload == null) {
    return null;
  }
  final map = _requiredMap(payload);
  final attachment = map['attachment'];
  if (attachment == null) {
    return null;
  }
  final attachmentMap = _requiredMap(attachment);
  return ProjectCommunicationAttachmentView(
    fileAssetId: _requiredString(attachmentMap, 'fileAssetId'),
    fileName: _requiredString(attachmentMap, 'fileName'),
    mimeType: _requiredString(attachmentMap, 'mimeType'),
    size: _requiredInt(attachmentMap, 'size'),
    category: _requiredString(attachmentMap, 'category'),
  );
}

ProjectCommunicationConfirmationView? _parseConfirmation(Object? payload) {
  if (payload == null) {
    return null;
  }
  final map = _requiredMap(payload);
  final confirmation = map['confirmation'];
  if (confirmation == null) {
    return null;
  }
  final confirmationMap = _requiredMap(confirmation);
  return ProjectCommunicationConfirmationView(
    confirmationType: _requiredString(confirmationMap, 'confirmationType'),
    title: _requiredString(confirmationMap, 'title'),
    summary: _requiredString(confirmationMap, 'summary'),
    status: _nullableString(confirmationMap['status']) ?? 'proposed',
  );
}

Map<String, Object?> _requiredMap(Object? payload) {
  if (payload is! Map) {
    throw const FormatException(
      'project communication event must be an object',
    );
  }
  return payload.map((Object? key, Object? value) => MapEntry('$key', value));
}

String _requiredString(Map<String, Object?> payload, String field) {
  final value = payload[field];
  if (value is! String) {
    throw FormatException('field "$field" must be a string');
  }
  final normalized = value.trim();
  if (normalized.isEmpty) {
    throw FormatException('field "$field" must be a non-empty string');
  }
  return normalized;
}

String _bodyString(Map<String, Object?> payload, String field) {
  final value = payload[field];
  if (value is! String) {
    throw FormatException('field "$field" must be a string');
  }
  return value;
}

int _requiredInt(Map<String, Object?> payload, String field) {
  final value = payload[field];
  if (value is int) {
    return value;
  }
  throw FormatException('field "$field" must be an int');
}

String? _nullableString(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is! String) {
    throw const FormatException('nullable field must be a string');
  }
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}
