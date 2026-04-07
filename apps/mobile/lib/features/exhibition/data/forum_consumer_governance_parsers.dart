part of 'forum_consumer_layer.dart';

Object _parseReportSubmitResult(Map<String, Object?> body) {
  final status = _readRequiredString(body['status']);
  final message = forumVisibleReportSubmitMessage(
    status: status,
    rawMessage: _readOptionalString(body['message']),
  );
  if (status == null || message == null) {
    return 'forum report submit result is missing required fields';
  }

  return ForumReportSubmitResultView(status: status, message: message);
}
