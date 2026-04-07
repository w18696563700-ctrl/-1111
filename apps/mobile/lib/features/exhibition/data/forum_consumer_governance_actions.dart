part of 'forum_consumer_layer.dart';

const Set<String> _forumReportTargetTypes = <String>{'post', 'comment'};
const Set<String> _forumReportReasonCodes = <String>{
  'ad_or_solicitation',
  'abuse_or_insult',
  'flamebait_or_conflict',
  'spam_or_flood',
  'plagiarism_or_repost',
  'other',
};

extension ForumConsumerLayerGovernanceActions on ForumConsumerLayer {
  Future<ForumActionResult<ForumReportSubmitResultView>> submitReport({
    required String? targetType,
    required String? targetId,
    required String? reasonCode,
    String? reasonDetail,
  }) async {
    final resolvedTargetType = _requiredRouteValue(targetType);
    final resolvedTargetId = _requiredRouteValue(targetId);
    final resolvedReasonCode = _requiredRouteValue(reasonCode);
    final resolvedReasonDetail = _requiredRouteValue(reasonDetail);

    if (resolvedTargetType == null ||
        resolvedTargetId == null ||
        resolvedReasonCode == null) {
      return const ForumActionResult(
        isSuccess: false,
        method: 'POST',
        path: ForumCanonicalPaths.reportSubmit,
        controlledState: AppPageState.errorNonRetryable,
        message: '请先选择举报原因后再提交',
      );
    }
    if (!_forumReportTargetTypes.contains(resolvedTargetType)) {
      return const ForumActionResult(
        isSuccess: false,
        method: 'POST',
        path: ForumCanonicalPaths.reportSubmit,
        controlledState: AppPageState.errorNonRetryable,
        message: '当前举报入口暂不可用',
      );
    }
    if (!_forumReportReasonCodes.contains(resolvedReasonCode)) {
      return const ForumActionResult(
        isSuccess: false,
        method: 'POST',
        path: ForumCanonicalPaths.reportSubmit,
        controlledState: AppPageState.errorNonRetryable,
        message: '请先选择举报原因后再提交',
      );
    }

    final requestBody = <String, Object?>{
      'targetType': resolvedTargetType,
      'targetId': resolvedTargetId,
      'reasonCode': resolvedReasonCode,
      'reasonDetail': resolvedReasonDetail ?? '',
    };

    return _postAction<ForumReportSubmitResultView>(
      path: ForumCanonicalPaths.reportSubmit,
      body: requestBody,
      parser: _parseReportSubmitResult,
      networkMessage: '举报暂时没有提交成功，请稍后再试',
      httpMessage: '举报暂时没有提交成功，请稍后再试',
      decodeMessage: '举报暂时没有提交成功，请稍后再试',
    );
  }
}
