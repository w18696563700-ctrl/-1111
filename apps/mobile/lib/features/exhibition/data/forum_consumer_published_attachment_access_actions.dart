part of 'forum_consumer_layer.dart';

extension ForumConsumerLayerPublishedAttachmentAccessActions
    on ForumConsumerLayer {
  Future<ForumActionResult<ForumFileAccessView>> requestFileAccess({
    required String? fileAssetId,
    required String mode,
  }) async {
    final resolvedFileAssetId = _requiredRouteValue(fileAssetId);
    final resolvedMode = _requiredRouteValue(mode);
    if (resolvedFileAssetId == null) {
      return const ForumActionResult(
        isSuccess: false,
        method: 'GET',
        path: ForumCanonicalPaths.fileAccess,
        controlledState: AppPageState.errorNonRetryable,
        message: '请先选择要读取的附件',
      );
    }
    if (resolvedMode == null ||
        (resolvedMode != 'preview' && resolvedMode != 'download')) {
      return const ForumActionResult(
        isSuccess: false,
        method: 'GET',
        path: ForumCanonicalPaths.fileAccess,
        controlledState: AppPageState.errorNonRetryable,
        message: '当前附件读取方式无效，请稍后再试',
      );
    }

    try {
      final response = await _client.get(
        ForumCanonicalPaths.fileAccess,
        queryParameters: <String, String>{
          'fileAssetId': resolvedFileAssetId,
          'mode': resolvedMode,
        },
      );

      final failure = _mapFailure(response, method: 'GET');
      if (failure != null) {
        return ForumActionResult<ForumFileAccessView>(
          isSuccess: false,
          method: failure.method,
          path: failure.path,
          controlledState: failure.state,
          message: forumVisibleActionMessage(
            path: failure.path,
            state: failure.state,
            rawMessage: _extractMessage(response.body),
            errorCode: failure.errorCode,
          ),
          errorCode: failure.errorCode,
        );
      }

      final body = _readBodyMap(response.body);
      if (body == null) {
        return const ForumActionResult(
          isSuccess: false,
          method: 'GET',
          path: ForumCanonicalPaths.fileAccess,
          controlledState: AppPageState.errorNonRetryable,
          message: '附件读取结果暂时不可用，请稍后再试',
        );
      }

      final parsed = _parseFileAccess(body);
      if (parsed is String) {
        return ForumActionResult(
          isSuccess: false,
          method: 'GET',
          path: ForumCanonicalPaths.fileAccess,
          controlledState: AppPageState.errorNonRetryable,
          message: forumVisibleActionMessage(
            path: ForumCanonicalPaths.fileAccess,
            state: AppPageState.errorNonRetryable,
            rawMessage: parsed,
          ),
        );
      }

      return ForumActionResult(
        isSuccess: true,
        method: 'GET',
        path: ForumCanonicalPaths.fileAccess,
        data: parsed as ForumFileAccessView,
      );
    } on SocketException {
      return const ForumActionResult(
        isSuccess: false,
        method: 'GET',
        path: ForumCanonicalPaths.fileAccess,
        controlledState: AppPageState.errorRetryable,
        message: '附件读取暂时失败，请检查网络后重试',
      );
    } on HttpException {
      return const ForumActionResult(
        isSuccess: false,
        method: 'GET',
        path: ForumCanonicalPaths.fileAccess,
        controlledState: AppPageState.errorRetryable,
        message: '附件读取服务暂时不可用，请稍后再试',
      );
    } on StateError {
      return const ForumActionResult(
        isSuccess: false,
        method: 'GET',
        path: ForumCanonicalPaths.fileAccess,
        controlledState: AppPageState.errorRetryable,
        message: '附件读取服务暂时不可用，请稍后再试',
      );
    } on FormatException {
      return const ForumActionResult(
        isSuccess: false,
        method: 'GET',
        path: ForumCanonicalPaths.fileAccess,
        controlledState: AppPageState.errorNonRetryable,
        message: '附件读取结果暂时不可用，请稍后再试',
      );
    }
  }
}
