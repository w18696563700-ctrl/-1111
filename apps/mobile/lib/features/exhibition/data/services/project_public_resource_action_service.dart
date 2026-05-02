part of '../exhibition_consumer_layer.dart';

extension _ProjectPublicResourceActionService on _ExhibitionActionService {
  Future<ExhibitionActionResult> requestProjectPublicResourceDownload({
    required String? fileAssetId,
  }) async {
    final normalizedFileAssetId = _normalize(fileAssetId);
    if (normalizedFileAssetId == null) {
      return ExhibitionActionResult(
        method: 'GET',
        path: ExhibitionCanonicalPaths.fileAccess,
        isSuccess: false,
        controlledState: AppPageState.notFound,
        message: '当前资料暂不可下载，请稍后重试。',
      );
    }

    try {
      final response = await runProtectedAppRequest(
        () => _client.get(
          ExhibitionCanonicalPaths.fileAccess,
          queryParameters: <String, String>{
            'fileAssetId': normalizedFileAssetId,
            'mode': 'download',
            'accessScope': 'public_resource',
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
