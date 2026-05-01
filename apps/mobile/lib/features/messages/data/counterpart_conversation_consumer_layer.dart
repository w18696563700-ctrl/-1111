import 'dart:io';

import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/auth/protected_app_request.dart';
import 'package:mobile/features/messages/data/counterpart_conversation_models.dart';
import 'package:mobile/features/messages/data/counterpart_conversation_parser.dart';
import 'package:mobile/features/messages/data/messages_interaction_models.dart';
import 'package:mobile/features/messages/data/project_communication_realtime_client.dart';

export 'package:mobile/features/messages/data/counterpart_conversation_models.dart';
export 'package:mobile/features/messages/data/project_communication_realtime_client.dart';

class CounterpartConversationConsumerLayer {
  CounterpartConversationConsumerLayer._(this._client, this._realtimeClient);

  factory CounterpartConversationConsumerLayer({
    AppApiClient? client,
    ProjectCommunicationRealtimeClient? realtimeClient,
  }) {
    final resolvedClient = client ?? AppApiClient();
    return CounterpartConversationConsumerLayer._(
      resolvedClient,
      realtimeClient ??
          ProjectCommunicationIoRealtimeClient(client: resolvedClient),
    );
  }

  static CounterpartConversationConsumerLayer _instance =
      CounterpartConversationConsumerLayer();

  static CounterpartConversationConsumerLayer get instance => _instance;

  static void install(CounterpartConversationConsumerLayer consumerLayer) {
    _instance = consumerLayer;
  }

  static void reset() {
    _instance = CounterpartConversationConsumerLayer();
  }

  final AppApiClient _client;
  final ProjectCommunicationRealtimeClient _realtimeClient;

  ProjectCommunicationRealtimeClient get projectCommunicationRealtimeClient {
    return _realtimeClient;
  }

  Future<CounterpartConversationResult<CounterpartConversationDetailView>>
  loadDetail({required String? conversationId, required String? projectId}) {
    final normalizedConversationId = _normalize(conversationId);
    final normalizedProjectId = _normalize(projectId);
    if (normalizedConversationId == null || normalizedProjectId == null) {
      return Future.value(
        const CounterpartConversationResult<CounterpartConversationDetailView>(
          state: AppPageState.notFound,
          method: 'GET',
          path: MessagesCanonicalPaths.counterpartConversationDetail,
          message:
              'conversationId and projectId are required before loading counterpart conversation',
        ),
      );
    }

    return _get(
      MessagesCanonicalPaths.counterpartConversationDetail,
      queryParameters: <String, String>{
        'conversationId': normalizedConversationId,
        'projectId': normalizedProjectId,
      },
      parser: parseCounterpartConversationDetail,
    );
  }

  Future<CounterpartConversationResult<ProjectCommunicationThreadView>>
  loadProjectCommunicationThread({
    required String? projectId,
    required String? counterpartOrganizationId,
  }) {
    final normalizedProjectId = _normalize(projectId);
    if (normalizedProjectId == null) {
      return Future.value(
        _invalid(
          MessagesCanonicalPaths.projectCommunicationThread,
          'projectId is required before loading project communication thread',
        ),
      );
    }
    final queryParameters = <String, String>{'projectId': normalizedProjectId};
    final normalizedCounterpartId = _normalize(counterpartOrganizationId);
    if (normalizedCounterpartId != null) {
      queryParameters['counterpartOrganizationId'] = normalizedCounterpartId;
    }
    return _get(
      MessagesCanonicalPaths.projectCommunicationThread,
      queryParameters: queryParameters,
      parser: parseProjectCommunicationThread,
    );
  }

  Future<CounterpartConversationResult<ProjectCommunicationMessageListView>>
  loadProjectCommunicationMessages({
    required String? threadId,
    required String? projectId,
    String? cursor,
    int limit = 50,
  }) {
    final normalizedThreadId = _normalize(threadId);
    final normalizedProjectId = _normalize(projectId);
    if (normalizedThreadId == null || normalizedProjectId == null) {
      return Future.value(
        _invalid(
          MessagesCanonicalPaths.projectCommunicationMessages,
          'threadId and projectId are required before loading messages',
        ),
      );
    }
    final queryParameters = <String, String>{
      'threadId': normalizedThreadId,
      'projectId': normalizedProjectId,
      'limit': '$limit',
    };
    final normalizedCursor = _normalize(cursor);
    if (normalizedCursor != null) {
      queryParameters['cursor'] = normalizedCursor;
    }
    return _get(
      MessagesCanonicalPaths.projectCommunicationMessages,
      queryParameters: queryParameters,
      parser: parseProjectCommunicationMessages,
    );
  }

  Future<CounterpartConversationResult<ProjectCommunicationMessageView>>
  sendProjectCommunicationMessage({
    required String? threadId,
    required String? projectId,
    required String? body,
    required String clientMessageId,
    String messageKind = 'text',
    Map<String, Object?>? payload,
  }) {
    final normalizedThreadId = _normalize(threadId);
    final normalizedProjectId = _normalize(projectId);
    final normalizedMessageKind = _normalize(messageKind) ?? 'text';
    final normalizedBody = normalizedMessageKind == 'text'
        ? _normalize(body)
        : body?.trim();
    final normalizedClientMessageId = _normalize(clientMessageId);
    if (normalizedThreadId == null ||
        normalizedProjectId == null ||
        (normalizedMessageKind == 'text' && normalizedBody == null) ||
        (normalizedMessageKind != 'text' && payload == null) ||
        normalizedClientMessageId == null) {
      return Future.value(
        _invalid(
          MessagesCanonicalPaths.projectCommunicationMessages,
          'threadId, projectId, message body or payload, and clientMessageId are required before sending message',
        ),
      );
    }
    final requestBody = <String, Object?>{
      'threadId': normalizedThreadId,
      'projectId': normalizedProjectId,
      'body': normalizedBody,
      'clientMessageId': normalizedClientMessageId,
    };
    if (normalizedMessageKind != 'text') {
      requestBody['messageKind'] = normalizedMessageKind;
      requestBody['payload'] = payload;
    }
    return _post(
      MessagesCanonicalPaths.projectCommunicationMessages,
      body: requestBody,
      parser: parseProjectCommunicationMessage,
    );
  }

  Future<CounterpartConversationResult<ProjectCommunicationReadCursorView>>
  markProjectCommunicationReadCursor({
    required String? threadId,
    required String? projectId,
    String? lastReadMessageId,
  }) {
    final normalizedThreadId = _normalize(threadId);
    final normalizedProjectId = _normalize(projectId);
    if (normalizedThreadId == null || normalizedProjectId == null) {
      return Future.value(
        _invalid(
          MessagesCanonicalPaths.projectCommunicationReadCursor,
          'threadId and projectId are required before marking read cursor',
        ),
      );
    }
    return _post(
      MessagesCanonicalPaths.projectCommunicationReadCursor,
      body: <String, Object?>{
        'threadId': normalizedThreadId,
        'projectId': normalizedProjectId,
        'lastReadMessageId': _normalize(lastReadMessageId),
      },
      parser: parseProjectCommunicationReadCursor,
    );
  }

  Future<
    CounterpartConversationResult<ProjectCommunicationFilePreviewAccessView>
  >
  loadProjectCommunicationFilePreviewAccess({
    required String? projectId,
    required String? threadId,
    required String? fileAssetId,
  }) {
    final normalizedProjectId = _normalize(projectId);
    final normalizedThreadId = _normalize(threadId);
    final normalizedFileAssetId = _normalize(fileAssetId);
    if (normalizedProjectId == null ||
        normalizedThreadId == null ||
        normalizedFileAssetId == null) {
      return Future.value(
        _invalid(
          MessagesCanonicalPaths.projectCommunicationFilePreviewAccess,
          'projectId, threadId and fileAssetId are required before loading file preview',
        ),
      );
    }
    return _get(
      MessagesCanonicalPaths.projectCommunicationFilePreviewAccess,
      queryParameters: <String, String>{
        'projectId': normalizedProjectId,
        'threadId': normalizedThreadId,
        'fileAssetId': normalizedFileAssetId,
      },
      parser: parseProjectCommunicationFilePreviewAccess,
    );
  }

  Future<
    CounterpartConversationResult<ProjectCommunicationConfirmationSoftLinkView>
  >
  loadProjectCommunicationConfirmationSoftLink({
    required String? projectId,
    required String? threadId,
    required String? messageId,
  }) {
    final normalizedProjectId = _normalize(projectId);
    final normalizedThreadId = _normalize(threadId);
    final normalizedMessageId = _normalize(messageId);
    if (normalizedProjectId == null ||
        normalizedThreadId == null ||
        normalizedMessageId == null) {
      return Future.value(
        _invalid(
          MessagesCanonicalPaths.confirmationSoftLinkDetail,
          'projectId, threadId and messageId are required before loading confirmation softLink',
        ),
      );
    }
    return _get(
      MessagesCanonicalPaths.confirmationSoftLinkDetail,
      queryParameters: <String, String>{
        'projectId': normalizedProjectId,
        'threadId': normalizedThreadId,
        'messageId': normalizedMessageId,
      },
      parser: parseProjectCommunicationConfirmationSoftLink,
    );
  }

  Future<CounterpartConversationResult<ProjectAlbumPhotoListView>>
  loadProjectAlbumPhotos({required String? projectId}) {
    final normalizedProjectId = _normalize(projectId);
    if (normalizedProjectId == null) {
      return Future.value(
        _invalid(
          MessagesCanonicalPaths.projectAlbumPhotos('missing-project'),
          'projectId is required before loading project album',
        ),
      );
    }
    return _get(
      MessagesCanonicalPaths.projectAlbumPhotos(normalizedProjectId),
      queryParameters: const <String, String>{},
      parser: parseProjectAlbumPhotoList,
    );
  }

  Future<CounterpartConversationResult<ProjectAlbumPhotoView>>
  bindProjectAlbumPhoto({
    required String? projectId,
    required String? fileAssetId,
    required String category,
    String? caption,
    int? sortOrder,
  }) {
    final normalizedProjectId = _normalize(projectId);
    final normalizedFileAssetId = _normalize(fileAssetId);
    final normalizedCategory = _normalize(category);
    if (normalizedProjectId == null ||
        normalizedFileAssetId == null ||
        normalizedCategory == null) {
      return Future.value(
        _invalid(
          MessagesCanonicalPaths.projectAlbumPhotos(
            normalizedProjectId ?? 'missing-project',
          ),
          'projectId, fileAssetId and category are required before binding project album photo',
        ),
      );
    }
    return _post(
      MessagesCanonicalPaths.projectAlbumPhotos(normalizedProjectId),
      body: <String, Object?>{
        'fileAssetId': normalizedFileAssetId,
        'category': normalizedCategory,
        'caption': _normalize(caption),
        'sortOrder': sortOrder,
      },
      parser: parseProjectAlbumPhoto,
    );
  }

  Future<CounterpartConversationResult<ProjectAlbumPhotoView>>
  deleteProjectAlbumPhoto({
    required String? projectId,
    required String? photoId,
  }) {
    final normalizedProjectId = _normalize(projectId);
    final normalizedPhotoId = _normalize(photoId);
    if (normalizedProjectId == null || normalizedPhotoId == null) {
      return Future.value(
        _invalid(
          MessagesCanonicalPaths.projectAlbumPhotos(
            normalizedProjectId ?? 'missing-project',
          ),
          'projectId and photoId are required before deleting project album photo',
        ),
      );
    }
    return _delete(
      MessagesCanonicalPaths.projectAlbumPhoto(
        normalizedProjectId,
        normalizedPhotoId,
      ),
      parser: parseProjectAlbumPhoto,
    );
  }

  Future<
    CounterpartConversationResult<ProjectCounterpartyRatingSubmitAcceptedView>
  >
  submitProjectCounterpartyRating({
    required String? orderId,
    required String? projectId,
    required String? rateeOrganizationId,
    required String scoreLabel,
    String? commentText,
  }) {
    final normalizedOrderId = _normalize(orderId);
    final normalizedProjectId = _normalize(projectId);
    final normalizedRateeId = _normalize(rateeOrganizationId);
    final normalizedScoreLabel = _normalize(scoreLabel);
    if (normalizedOrderId == null ||
        normalizedProjectId == null ||
        normalizedRateeId == null ||
        normalizedScoreLabel == null) {
      return Future.value(
        _invalid(
          MessagesCanonicalPaths.projectCounterpartyRatingSubmit,
          'orderId, projectId, rateeOrganizationId and scoreLabel are required before submitting counterparty rating',
        ),
      );
    }
    return _post(
      MessagesCanonicalPaths.projectCounterpartyRatingSubmit,
      body: <String, Object?>{
        'orderId': normalizedOrderId,
        'projectId': normalizedProjectId,
        'rateeOrganizationId': normalizedRateeId,
        'scoreLabel': normalizedScoreLabel,
        'commentText': _normalize(commentText),
      },
      parser: parseProjectCounterpartyRatingSubmitAccepted,
    );
  }

  Future<CounterpartConversationResult<T>> _get<T>(
    String canonicalPath, {
    required Map<String, String> queryParameters,
    required T Function(Object? payload) parser,
  }) async {
    try {
      final response = await runProtectedAppRequest(
        () => _client.get(canonicalPath, queryParameters: queryParameters),
      );
      return _mapResponse(response, canonicalPath, 'GET', parser);
    } on SocketException catch (error) {
      return _transportFailure(canonicalPath, 'GET', error.message);
    } on HttpException {
      return _transportFailure(
        canonicalPath,
        'GET',
        'http error while loading counterpart conversation',
      );
    } on StateError {
      return _transportFailure(
        canonicalPath,
        'GET',
        'current fake transport did not provide counterpart conversation',
      );
    } on FormatException catch (error) {
      return _formatFailure(canonicalPath, 'GET', error.message);
    }
  }

  Future<CounterpartConversationResult<T>> _post<T>(
    String canonicalPath, {
    required Object body,
    required T Function(Object? payload) parser,
  }) async {
    try {
      final response = await runProtectedAppRequest(
        () => _client.post(canonicalPath, body: body),
      );
      return _mapResponse(response, canonicalPath, 'POST', parser);
    } on SocketException catch (error) {
      return _transportFailure(canonicalPath, 'POST', error.message);
    } on HttpException {
      return _transportFailure(
        canonicalPath,
        'POST',
        'http error while sending counterpart conversation request',
      );
    } on StateError {
      return _transportFailure(
        canonicalPath,
        'POST',
        'current fake transport did not provide counterpart conversation',
      );
    } on FormatException catch (error) {
      return _formatFailure(canonicalPath, 'POST', error.message);
    }
  }

  Future<CounterpartConversationResult<T>> _delete<T>(
    String canonicalPath, {
    required T Function(Object? payload) parser,
  }) async {
    try {
      final response = await runProtectedAppRequest(
        () => _client.delete(canonicalPath),
      );
      return _mapResponse(response, canonicalPath, 'DELETE', parser);
    } on SocketException catch (error) {
      return _transportFailure(canonicalPath, 'DELETE', error.message);
    } on HttpException {
      return _transportFailure(
        canonicalPath,
        'DELETE',
        'http error while deleting counterpart conversation resource',
      );
    } on StateError {
      return _transportFailure(
        canonicalPath,
        'DELETE',
        'current fake transport did not provide counterpart conversation',
      );
    } on FormatException catch (error) {
      return _formatFailure(canonicalPath, 'DELETE', error.message);
    }
  }

  CounterpartConversationResult<T> _mapResponse<T>(
    AppApiResponse response,
    String canonicalPath,
    String method,
    T Function(Object? payload) parser,
  ) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return CounterpartConversationResult<T>(
        state: _failureState(response.statusCode),
        method: method,
        path: canonicalPath,
        message:
            _message(response.body) ??
            'counterpart conversation request failed',
        errorCode: _errorCode(response.body),
      );
    }

    return CounterpartConversationResult<T>(
      state: AppPageState.content,
      method: method,
      path: canonicalPath,
      data: parser(response.body),
    );
  }

  CounterpartConversationResult<T> _transportFailure<T>(
    String path,
    String method,
    String message,
  ) {
    return CounterpartConversationResult<T>(
      state: AppPageState.errorRetryable,
      method: method,
      path: path,
      message: message,
    );
  }

  CounterpartConversationResult<T> _formatFailure<T>(
    String path,
    String method,
    String message,
  ) {
    return CounterpartConversationResult<T>(
      state: AppPageState.errorNonRetryable,
      method: method,
      path: path,
      message: message,
    );
  }

  CounterpartConversationResult<T> _invalid<T>(String path, String message) {
    return CounterpartConversationResult<T>(
      state: AppPageState.errorNonRetryable,
      method: 'LOCAL',
      path: path,
      message: message,
      errorCode: 'PROJECT_COMMUNICATION_INVALID',
    );
  }
}

AppPageState _failureState(int statusCode) {
  if (statusCode == 401) {
    return AppPageState.unauthorized;
  }
  if (statusCode == 403) {
    return AppPageState.forbidden;
  }
  if (statusCode == 404) {
    return AppPageState.notFound;
  }
  if (statusCode >= 500) {
    return AppPageState.errorRetryable;
  }
  return AppPageState.errorNonRetryable;
}

String? _message(Object? payload) {
  if (payload is Map) {
    final value = payload['message'];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return null;
}

String? _errorCode(Object? payload) {
  if (payload is Map) {
    final value = payload['code'];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return null;
}

String? _normalize(String? value) {
  final normalized = value?.trim() ?? '';
  return normalized.isEmpty ? null : normalized;
}
