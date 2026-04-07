part of 'forum_visible_copy.dart';

String? forumVisibleReportSubmitMessage({
  required String? status,
  String? rawMessage,
}) {
  final visibleRaw = _visibleChineseMessage(rawMessage);
  if (visibleRaw != null) {
    return visibleRaw;
  }

  return switch (status?.trim()) {
    'submitted' => '举报已提交',
    'accepted_existing' => '已存在处理中举报',
    _ => null,
  };
}
