part of '../exhibition_consumer_layer.dart';

extension _ProjectAttachmentActionService on _ExhibitionActionService {
  Future<ExhibitionActionResult> bindProjectAttachment({
    required String? projectId,
    required ProjectAttachmentBindCommand command,
  }) async {
    final normalizedProjectId = _normalize(projectId);
    if (normalizedProjectId == null) {
      return ExhibitionActionResult(
        method: 'POST',
        path: ExhibitionCanonicalPaths.myProjectAttachmentsPattern,
        isSuccess: false,
        controlledState: AppPageState.notFound,
        message:
            'projectId is required from route context or page context before calling BFF',
      );
    }

    return _submitProtected(
      ExhibitionCanonicalPaths.myProjectAttachments(normalizedProjectId),
      body: command.toJson(),
    );
  }

  Future<ExhibitionActionResult> deleteProjectAttachment({
    required String? projectId,
    required String? attachmentId,
  }) async {
    final normalizedProjectId = _normalize(projectId);
    final normalizedAttachmentId = _normalize(attachmentId);
    if (normalizedProjectId == null || normalizedAttachmentId == null) {
      return ExhibitionActionResult(
        method: 'DELETE',
        path: ExhibitionCanonicalPaths.myProjectAttachmentsPattern,
        isSuccess: false,
        controlledState: AppPageState.notFound,
        message:
            'projectId and attachmentId are required from route context or page context before calling BFF',
      );
    }

    final canonicalPath = ExhibitionCanonicalPaths.myProjectAttachmentDelete(
      normalizedProjectId,
      normalizedAttachmentId,
    );

    try {
      final response = await runProtectedAppRequest(
        () => _client.delete(canonicalPath),
      );
      return _mapActionResponse(
        response,
        canonicalPath,
        requestMethod: 'DELETE',
      );
    } on SocketException {
      return ExhibitionActionResult(
        method: 'DELETE',
        path: canonicalPath,
        isSuccess: false,
        controlledState: AppPageState.errorRetryable,
        message: 'network error while submitting to canonical BFF path',
      );
    } on HttpException {
      return ExhibitionActionResult(
        method: 'DELETE',
        path: canonicalPath,
        isSuccess: false,
        controlledState: AppPageState.errorRetryable,
        message: 'http error while submitting to canonical BFF path',
      );
    } on FormatException {
      return ExhibitionActionResult(
        method: 'DELETE',
        path: canonicalPath,
        isSuccess: false,
        controlledState: AppPageState.errorNonRetryable,
        message: 'response decoding failed for canonical BFF path',
      );
    }
  }

  Future<ExhibitionActionResult> requestProjectAttachmentAccess({
    required String? fileAssetId,
    required String mode,
    String? projectId,
    String? accessScope,
  }) async {
    final normalizedFileAssetId = _normalize(fileAssetId);
    final normalizedMode = _normalize(mode);
    if (normalizedFileAssetId == null ||
        normalizedMode == null ||
        (normalizedMode != 'preview' && normalizedMode != 'download')) {
      return ExhibitionActionResult(
        method: 'GET',
        path: ExhibitionCanonicalPaths.fileAccess,
        isSuccess: false,
        controlledState: AppPageState.notFound,
        message: '当前资料暂不可读取，请稍后再试。',
      );
    }

    try {
      final response = await runProtectedAppRequest(
        () => _client.get(
          ExhibitionCanonicalPaths.fileAccess,
          queryParameters: <String, String>{
            'fileAssetId': normalizedFileAssetId,
            'mode': normalizedMode,
            if (_normalize(projectId) case final String normalizedProjectId)
              'projectId': normalizedProjectId,
            if (_normalize(accessScope) case final String normalizedAccessScope)
              'accessScope': normalizedAccessScope,
          },
        ),
      );

      final payload = response.body;
      final failurePayload = _sanitizeFailurePayload(payload);
      final failureCode = _extractErrorCode(failurePayload);
      final failureMessage = _failureMessage(
        payload,
        'canonical BFF request failed',
      );

      if (response.statusCode == 401) {
        return ExhibitionActionResult(
          method: 'GET',
          path: ExhibitionCanonicalPaths.fileAccess,
          isSuccess: false,
          controlledState: AppPageState.unauthorized,
          payload: failurePayload,
          errorCode: failureCode,
          message: failureMessage,
        );
      }

      if (response.statusCode == 403) {
        return ExhibitionActionResult(
          method: 'GET',
          path: ExhibitionCanonicalPaths.fileAccess,
          isSuccess: false,
          controlledState: AppPageState.forbidden,
          payload: failurePayload,
          errorCode: failureCode,
          message: failureMessage,
        );
      }

      if (response.statusCode == 404) {
        return ExhibitionActionResult(
          method: 'GET',
          path: ExhibitionCanonicalPaths.fileAccess,
          isSuccess: false,
          controlledState: AppPageState.notFound,
          payload: failurePayload,
          errorCode: failureCode,
          message: failureMessage,
        );
      }

      if (response.statusCode >= 500) {
        return ExhibitionActionResult(
          method: 'GET',
          path: ExhibitionCanonicalPaths.fileAccess,
          isSuccess: false,
          controlledState: AppPageState.errorRetryable,
          payload: failurePayload,
          errorCode: failureCode,
          message: failureMessage,
        );
      }

      if (response.statusCode >= 400) {
        return ExhibitionActionResult(
          method: 'GET',
          path: ExhibitionCanonicalPaths.fileAccess,
          isSuccess: false,
          controlledState: AppPageState.errorNonRetryable,
          payload: failurePayload,
          errorCode: failureCode,
          message: failureMessage,
        );
      }

      final sanitized = _sanitizeProjectPublicResourceFileAccessPayload(
        payload,
      );
      final accessUrl = sanitized?['accessUrl'];
      if (sanitized == null || accessUrl is! String || accessUrl.isEmpty) {
        return ExhibitionActionResult(
          method: 'GET',
          path: ExhibitionCanonicalPaths.fileAccess,
          isSuccess: false,
          controlledState: AppPageState.errorNonRetryable,
          payload: sanitized,
          message: 'response decoding failed for canonical BFF path',
        );
      }

      return ExhibitionActionResult(
        method: 'GET',
        path: ExhibitionCanonicalPaths.fileAccess,
        isSuccess: true,
        payload: sanitized,
      );
    } on SocketException catch (error) {
      return ExhibitionActionResult(
        method: 'GET',
        path: ExhibitionCanonicalPaths.fileAccess,
        isSuccess: false,
        controlledState: AppPageState.errorRetryable,
        message: error.message.toLowerCase().contains('request timed out')
            ? error.message
            : 'network error while requesting canonical BFF path',
      );
    } on HttpException {
      return ExhibitionActionResult(
        method: 'GET',
        path: ExhibitionCanonicalPaths.fileAccess,
        isSuccess: false,
        controlledState: AppPageState.errorRetryable,
        message: 'http error while requesting canonical BFF path',
      );
    } on StateError {
      return ExhibitionActionResult(
        method: 'GET',
        path: ExhibitionCanonicalPaths.fileAccess,
        isSuccess: false,
        controlledState: AppPageState.errorRetryable,
        message: 'current fake transport did not provide this canonical path',
      );
    } on FormatException {
      return ExhibitionActionResult(
        method: 'GET',
        path: ExhibitionCanonicalPaths.fileAccess,
        isSuccess: false,
        controlledState: AppPageState.errorNonRetryable,
        message: 'response decoding failed for canonical BFF path',
      );
    }
  }
}
