part of 'forum_consumer_layer.dart';

extension ForumConsumerLayerActions on ForumConsumerLayer {
  Future<ForumActionResult<ForumDraftSavedView>> saveDraft({
    required String? draftId,
    required String? topicId,
    required String? title,
    required String? body,
    List<String> attachmentFileAssetIds = const <String>[],
  }) async {
    final resolvedTopicId = _requiredRouteValue(topicId);
    final resolvedTitle = _requiredRouteValue(title);
    final resolvedBody = _requiredRouteValue(body);
    final resolvedDraftId = _requiredRouteValue(draftId);
    if (resolvedTopicId == null ||
        resolvedTitle == null ||
        resolvedBody == null) {
      return const ForumActionResult(
        isSuccess: false,
        method: 'POST',
        path: ForumCanonicalPaths.draftSave,
        controlledState: AppPageState.errorNonRetryable,
        message: '请先填写分类、标题和正文',
      );
    }

    return _postAction<ForumDraftSavedView>(
      path: ForumCanonicalPaths.draftSave,
      body: <String, Object?>{
        'draftId': resolvedDraftId,
        'topicId': resolvedTopicId,
        'title': resolvedTitle,
        'body': resolvedBody,
        'attachmentFileAssetIds': attachmentFileAssetIds,
      },
      parser: _parseDraftSaved,
      networkMessage: '草稿暂时保存失败，请稍后再试',
      httpMessage: '草稿暂时保存失败，请稍后再试',
      decodeMessage: '草稿暂时保存失败，请稍后再试',
    );
  }

  Future<ForumActionResult<ForumPublishResultView>> publishDraft({
    required String? draftId,
  }) async {
    final resolved = _requiredRouteValue(draftId);
    if (resolved == null) {
      return const ForumActionResult(
        isSuccess: false,
        method: 'POST',
        path: ForumCanonicalPaths.publish,
        controlledState: AppPageState.errorNonRetryable,
        message: '请先保存草稿，再继续发布',
      );
    }

    return _postAction<ForumPublishResultView>(
      path: ForumCanonicalPaths.publish,
      body: <String, String>{'draftId': resolved},
      parser: _parsePublishResult,
      networkMessage: '当前暂时还不能发布，请稍后再试',
      httpMessage: '当前暂时还不能发布，请稍后再试',
      decodeMessage: '当前暂时还不能发布，请稍后再试',
    );
  }

  Future<ForumActionResult<ForumDraftDeletedView>> deleteDraft({
    required String? draftId,
  }) async {
    final resolved = _requiredRouteValue(draftId);
    if (resolved == null) {
      return const ForumActionResult(
        isSuccess: false,
        method: 'POST',
        path: ForumCanonicalPaths.draftDelete,
        controlledState: AppPageState.errorNonRetryable,
        message: '请先选择要删除的草稿',
      );
    }

    return _postAction<ForumDraftDeletedView>(
      path: ForumCanonicalPaths.draftDelete,
      body: <String, String>{'draftId': resolved},
      parser: _parseDraftDeleted,
      networkMessage: '当前草稿暂时无法删除，请稍后再试',
      httpMessage: '当前草稿暂时无法删除，请稍后再试',
      decodeMessage: '当前草稿暂时无法删除，请稍后再试',
    );
  }

  Future<ForumActionResult<T>> _postAction<T>({
    required String path,
    required Object body,
    required Object Function(Map<String, Object?> body) parser,
    required String networkMessage,
    required String httpMessage,
    required String decodeMessage,
  }) async {
    try {
      final response = await runProtectedAppRequest(
        () => _client.post(path, body: body),
      );
      return _mapActionResponse(response, parser: parser);
    } on SocketException {
      return ForumActionResult(
        isSuccess: false,
        method: 'POST',
        path: path,
        controlledState: AppPageState.errorRetryable,
        message: networkMessage,
      );
    } on HttpException {
      return ForumActionResult(
        isSuccess: false,
        method: 'POST',
        path: path,
        controlledState: AppPageState.errorRetryable,
        message: httpMessage,
      );
    } on StateError {
      return ForumActionResult(
        isSuccess: false,
        method: 'POST',
        path: path,
        controlledState: AppPageState.errorRetryable,
        message: forumVisibleActionMessage(
          path: path,
          state: AppPageState.errorRetryable,
        ),
      );
    } on FormatException {
      return ForumActionResult(
        isSuccess: false,
        method: 'POST',
        path: path,
        controlledState: AppPageState.errorNonRetryable,
        message: forumVisibleActionMessage(
          path: path,
          state: AppPageState.errorNonRetryable,
          rawMessage: decodeMessage,
        ),
      );
    }
  }
}
