part of 'forum_consumer_layer.dart';

extension ForumConsumerLayerBlockActions on ForumConsumerLayer {
  Future<ForumReadResult<ForumBlockRelationStatusView>> loadBlockStatus({
    required String? targetUserId,
  }) {
    final resolvedTargetUserId = _requiredRouteValue(targetUserId);
    if (resolvedTargetUserId == null) {
      return Future<ForumReadResult<ForumBlockRelationStatusView>>.value(
        const ForumReadResult<ForumBlockRelationStatusView>(
          state: AppPageState.notFound,
          method: 'GET',
          path: ForumCanonicalPaths.relationBlockStatus,
          message: '当前作者暂不可用',
        ),
      );
    }

    return _loadRead(
      path: ForumCanonicalPaths.relationBlockStatus,
      queryParameters: <String, String>{'targetUserId': resolvedTargetUserId},
      parser: _parseBlockRelationStatus,
      isEmpty: (_) => false,
      useProtectedSession: true,
    );
  }

  Future<ForumActionResult<ForumBlockRelationStatusView>> blockUser({
    required String? targetUserId,
  }) {
    return _submitBlockRelationAction(
      path: ForumCanonicalPaths.relationBlock,
      targetUserId: targetUserId,
      missingMessage: '请先选择要拉黑的作者',
      networkMessage: '拉黑暂时没有完成，请稍后再试',
    );
  }

  Future<ForumActionResult<ForumBlockRelationStatusView>> unblockUser({
    required String? targetUserId,
  }) {
    return _submitBlockRelationAction(
      path: ForumCanonicalPaths.relationUnblock,
      targetUserId: targetUserId,
      missingMessage: '请先选择要解除拉黑的作者',
      networkMessage: '解除拉黑暂时没有完成，请稍后再试',
    );
  }

  Future<ForumActionResult<ForumBlockRelationStatusView>>
  _submitBlockRelationAction({
    required String path,
    required String? targetUserId,
    required String missingMessage,
    required String networkMessage,
  }) {
    final resolvedTargetUserId = _requiredRouteValue(targetUserId);
    if (resolvedTargetUserId == null) {
      return Future<ForumActionResult<ForumBlockRelationStatusView>>.value(
        ForumActionResult<ForumBlockRelationStatusView>(
          isSuccess: false,
          method: 'POST',
          path: path,
          controlledState: AppPageState.errorNonRetryable,
          message: missingMessage,
        ),
      );
    }

    return _postAction<ForumBlockRelationStatusView>(
      path: path,
      body: <String, Object?>{'targetUserId': resolvedTargetUserId},
      parser: _parseBlockRelationStatus,
      networkMessage: networkMessage,
      httpMessage: networkMessage,
      decodeMessage: networkMessage,
    );
  }
}
