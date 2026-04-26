import 'package:mobile/core/api/app_ui_contracts.dart';

part 'forum_visible_topic_copy.dart';
part 'forum_visible_governance_copy.dart';

String forumDisplayDraftStateLabel(String? state) {
  return switch (state?.trim()) {
    'ready_to_publish' => '待发布',
    'saved' => '草稿',
    'published' => '已发布',
    _ => '草稿',
  };
}

String forumDisplayContentState(String? state) {
  return switch (state?.trim()) {
    'published' => '已发布',
    'archived' => '已删除',
    'draft' => '草稿',
    'ready_to_publish' => '待发布',
    'hidden' => '暂不可见',
    null || '' => '暂未标记',
    _ => '处理中',
  };
}

String forumDisplayInteractionTargetType(String targetType) {
  return switch (targetType.trim()) {
    'forum_post' => '源对象：帖子',
    'forum_comment' => '源对象：评论',
    'forum_topic' => '源对象：话题',
    _ => '源对象：其他',
  };
}

String forumDisplayInteractionTitle({
  required String rawTitle,
  required String targetType,
  String? topicId,
}) {
  final value = rawTitle.trim();
  if (targetType == 'forum_topic') {
    final label = forumDisplayTopicLabel(
      rawLabel: value,
      topicId: topicId,
      fallback: '关注话题',
    );
    return '$label有新动态';
  }

  if (value.isNotEmpty &&
      (_containsChinese(value) || !_looksTechnicalVisibleMessage(value)) &&
      !_looksTechnicalTopic(value)) {
    return value;
  }

  return switch (targetType.trim()) {
    'forum_post' => '有新的帖子互动',
    'forum_comment' => '有新的评论互动',
    'forum_topic' => '你关注的话题有新动态',
    _ => '有新的互动提醒',
  };
}

String? forumDisplayInteractionPreview(String? rawPreview) {
  final value = rawPreview?.trim();
  if (value == null || value.isEmpty) return null;
  if (_looksTechnicalVisibleMessage(value) || _looksTechnicalTopic(value)) {
    return null;
  }
  return value;
}

String forumVisibleUnavailableFeatureMessage(String featureLabel) {
  return '$featureLabel暂未开放，请稍后再试';
}

String forumDisplayActorName(String? rawName, {String fallback = '论坛用户'}) {
  final value = rawName?.trim();
  if (value == null || value.isEmpty) {
    return fallback;
  }
  if (_looksPhoneNumber(value)) {
    return _maskPhoneNumber(value);
  }
  if (_containsChinese(value) && !_looksTechnicalIdentity(value)) {
    return value;
  }
  if (_looksTechnicalIdentity(value)) {
    return fallback;
  }
  return value;
}

String? forumDisplayOrganizationName(String? rawName, {String? fallback}) {
  final value = rawName?.trim();
  if (value == null || value.isEmpty) {
    return fallback;
  }
  if (_containsChinese(value) && !_looksTechnicalIdentity(value)) {
    return value;
  }
  if (_looksTechnicalIdentity(value) ||
      value.toLowerCase().contains('closure-dev-org')) {
    return fallback;
  }
  return value;
}

String forumDisplayAccountLabel(String? rawUserId) {
  final value = rawUserId?.trim();
  if (value == null || value.isEmpty) {
    return '当前账号：未登录';
  }
  if (_looksPhoneNumber(value)) {
    return '当前账号：${_maskPhoneNumber(value)}';
  }
  if (_looksTechnicalIdentity(value)) {
    return '当前账号：已登录';
  }
  return '当前账号：$value';
}

String forumDisplayTimeLabel(String? rawValue, {String fallback = '时间未知'}) {
  final value = rawValue?.trim();
  if (value == null || value.isEmpty) {
    return fallback;
  }
  final parsed = DateTime.tryParse(value)?.toLocal();
  if (parsed == null) {
    return _containsChinese(value) ? value : fallback;
  }
  final month = parsed.month.toString().padLeft(2, '0');
  final day = parsed.day.toString().padLeft(2, '0');
  final hour = parsed.hour.toString().padLeft(2, '0');
  final minute = parsed.minute.toString().padLeft(2, '0');
  return '$month-$day $hour:$minute';
}

String forumVisibleReadMessage({
  required String path,
  required AppPageState state,
  String? rawMessage,
  String? errorCode,
}) {
  final visibleRaw = _visibleChineseMessage(rawMessage);
  if (visibleRaw != null) {
    return visibleRaw;
  }
  if (_forumReadRouteMissingMessage(rawMessage) case final String message) {
    return message;
  }

  if (errorCode == 'AUTH_SESSION_INVALID') {
    return '请先登录后再查看';
  }
  if (errorCode == 'FORUM_AUTHOR_INVALID') {
    return '作者入口暂不可用';
  }
  if (errorCode == 'FORUM_AUTHOR_UNAVAILABLE') {
    return '当前作者主页暂不可用';
  }
  if (errorCode == 'FORUM_POST_UNAVAILABLE') {
    if (path.contains('/forum/post/comments')) {
      return '当前帖子暂不可查看评论，请刷新后再试';
    }
    return '当前帖子暂不可用，请刷新后再试';
  }
  if (errorCode == 'FORUM_AUTHOR_POSTS_INVALID') {
    return '公开帖子暂时不可用，请稍后再试';
  }
  if (errorCode == 'FORUM_PUBLISH_INVALID_STATE') {
    return '请先保存草稿，再继续发布';
  }
  if (path.contains('/profile/block')) {
    return '拉黑关系状态暂时不可用，请稍后再试';
  }

  return switch (state) {
    AppPageState.loading => '正在加载，请稍候',
    AppPageState.empty => _readEmptyFallback(path),
    AppPageState.unauthorized => '请先登录后再查看',
    AppPageState.forbidden => '当前账号暂不能查看',
    AppPageState.notFound => _readNotFoundFallback(path),
    AppPageState.errorRetryable || AppPageState.errorNonRetryable =>
      _readFailureFallback(path, errorCode: errorCode),
    AppPageState.content => '内容已准备好',
  };
}

String forumVisibleActionMessage({
  required String path,
  AppPageState? state,
  String? rawMessage,
  String? errorCode,
}) {
  final visibleRaw = _visibleChineseMessage(rawMessage);
  if (visibleRaw != null) {
    return visibleRaw;
  }

  if (errorCode == 'FORUM_PUBLISH_INVALID_STATE') {
    return '请先保存草稿，再继续发布';
  }
  if (errorCode == 'FORUM_REPORT_INVALID') {
    return '请先确认举报信息后再提交';
  }
  if (path.contains('/file/access')) {
    if (errorCode == 'AUTH_SESSION_INVALID') {
      return '当前登录状态已失效，请重新登录后再试';
    }
    if (errorCode == 'FILE_ACCESS_INVALID') {
      return '当前附件读取方式无效，请检查后再试';
    }
    if (errorCode == 'FILE_ACCESS_NOT_FOUND') {
      return '当前附件不存在或暂不可用';
    }
    if (errorCode == 'FILE_ACCESS_UNAVAILABLE') {
      return '当前附件暂时不能读取';
    }
    if (errorCode == 'FILE_ACCESS_PERMISSION_DENIED') {
      return '当前账号没有权限读取这个附件';
    }
    return switch (state) {
      AppPageState.unauthorized => '当前登录状态已失效，请重新登录后再试',
      AppPageState.notFound => '当前附件不存在或暂不可用',
      AppPageState.forbidden => '当前账号没有权限读取这个附件',
      _ => '附件读取暂时失败，请稍后再试',
    };
  }
  if (path.contains('/forum/draft/delete')) {
    return switch (state) {
      AppPageState.notFound => '当前草稿删除入口暂不可用，请稍后再试',
      AppPageState.forbidden => '当前账号暂不能删除这份草稿',
      _ => '当前草稿暂时无法删除，请稍后再试',
    };
  }

  if (path.contains('/forum/draft/save')) {
    if (errorCode == 'AUTH_SESSION_INVALID' ||
        state == AppPageState.unauthorized) {
      return '当前登录状态已失效，请重新登录后再保存草稿';
    }
    if (state == AppPageState.notFound) {
      return '当前云端 BFF 尚未部署草稿保存路由，请先同步云端后再试';
    }
    if (state == AppPageState.forbidden) {
      return '当前账号暂不能保存论坛草稿';
    }
    if (errorCode == 'FORUM_DRAFT_INVALID') {
      return '当前草稿内容不完整，请检查分类、标题和正文后再试';
    }
    if (errorCode == 'FORUM_DRAFT_UNAVAILABLE') {
      return '当前账号或话题暂不能保存论坛草稿，请检查组织身份和话题后再试';
    }
    if (state == AppPageState.errorRetryable) {
      return '云端 BFF 暂时不可达，草稿没有保存，请稍后重试';
    }
    return '草稿未保存，请检查登录状态、组织身份和话题后再试';
  }
  if (path.contains('/forum/publish')) {
    return '当前暂时还不能发布，请稍后再试';
  }
  if (path.contains('/forum/post/comment')) {
    if (errorCode == 'AUTH_SESSION_INVALID' ||
        state == AppPageState.unauthorized) {
      return '当前登录状态已失效，请重新登录后再试';
    }
    if (errorCode == 'FORUM_COMMENT_INVALID') {
      return '请先填写评论内容后再提交';
    }
    if (errorCode == 'FORUM_COMMENT_INVALID_STATE') {
      return '当前回复目标暂不可用，请刷新后再试';
    }
    if (errorCode == 'FORUM_POST_UNAVAILABLE') {
      return '当前帖子暂不可评论，请刷新后再试';
    }
    if (errorCode == 'FORUM_INTERACTION_UNAVAILABLE') {
      return '评论提交能力正在接入，请稍后再试';
    }
    return '回复暂时发送失败，请稍后再试';
  }
  if (path.contains('/forum/post/like')) {
    if (errorCode == 'AUTH_SESSION_INVALID' ||
        state == AppPageState.unauthorized) {
      return '当前登录状态已失效，请重新登录后再试';
    }
    if (errorCode == 'FORUM_INTERACTION_UNAVAILABLE') {
      return '点赞能力尚未接真实写链，本期暂不保存状态';
    }
    return '点赞暂时没有完成，请稍后再试';
  }
  if (path.contains('/forum/post/bookmark')) {
    if (errorCode == 'AUTH_SESSION_INVALID' ||
        state == AppPageState.unauthorized) {
      return '当前登录状态已失效，请重新登录后再试';
    }
    if (errorCode == 'FORUM_INTERACTION_UNAVAILABLE') {
      return '收藏能力尚未接真实写链，本期暂不保存状态';
    }
    return '收藏暂时没有完成，请稍后再试';
  }
  if (path.contains('/forum/report/submit')) {
    return '举报暂时没有提交成功，请稍后再试';
  }
  if (path.contains('/forum/reports/mine')) {
    return '我的举报记录暂时不可用，请稍后再试';
  }
  if (path.contains('/profile/block')) {
    return '拉黑暂时没有完成，请稍后再试';
  }
  if (path.contains('/profile/unblock')) {
    return '解除拉黑暂时没有完成，请稍后再试';
  }

  return switch (state) {
    AppPageState.unauthorized => '请先登录后再继续',
    AppPageState.forbidden => '当前账号暂不能执行这个操作',
    AppPageState.notFound => '当前操作入口暂不可用',
    _ => '当前操作暂时没有完成，请稍后再试',
  };
}

String? forumVisiblePublishDecisionMessage({
  required String? decision,
  String? rawMessage,
}) {
  final visibleRaw = _visibleChineseMessage(rawMessage);
  if (decision?.trim() == 'restricted' &&
      (visibleRaw == null || visibleRaw == '当前内容暂不可发布')) {
    return '当前内容暂不可发布，请修改标题或正文后再试';
  }
  if (visibleRaw != null) {
    return visibleRaw;
  }

  return switch (decision?.trim()) {
    'clear' => '发布成功',
    'supplement_required' => '需修改后再试',
    'restricted' => '当前内容暂不可发布',
    'ticket_required' => '已进入受控治理处理',
    _ => null,
  };
}

bool _containsChinese(String value) {
  return RegExp(r'[\u4e00-\u9fff]').hasMatch(value);
}

String? _visibleChineseMessage(String? rawMessage) {
  final value = rawMessage?.trim();
  if (value == null || value.isEmpty) {
    return null;
  }
  if (!_containsChinese(value)) {
    return null;
  }
  if (_looksTechnicalVisibleMessage(value)) {
    return null;
  }
  return value;
}

bool _looksTechnicalVisibleMessage(String value) {
  final lower = value.toLowerCase();
  return lower.contains('source=') ||
      lower.contains('source:') ||
      lower.contains('details') ||
      lower.contains('slug') ||
      lower.contains('raw key') ||
      lower.contains('fallback') ||
      lower.contains('transport') ||
      lower.contains('upstream') ||
      lower.contains('econnrefused') ||
      lower.contains('socketexception') ||
      lower.contains('formatexception') ||
      lower.contains('stateerror') ||
      lower.contains('cannot ') ||
      lower.contains('must be an array') ||
      lower.contains('missing required') ||
      lower.contains('missing required field') ||
      lower.contains('unsupported state') ||
      lower.contains('validation') ||
      lower.contains('parser') ||
      lower.contains('exception') ||
      lower.contains('actorid') ||
      lower.contains('organizationid') ||
      lower.contains('attachmentrefs') ||
      lower.contains('mimetype') ||
      lower.contains('network error') ||
      lower.contains('http error') ||
      lower.contains('contract drift') ||
      lower.contains('canonical path') ||
      lower.contains('unrecognized error code') ||
      lower.contains('forum feed item') ||
      lower.contains('forum topic') ||
      lower.contains('forum post') ||
      lower.contains('forum comment') ||
      lower.contains('/api/app/') ||
      lower.contains('topicid') ||
      lower.contains('draftid') ||
      lower.contains('postid');
}

String? _forumReadRouteMissingMessage(String? rawMessage) {
  final normalized = rawMessage?.trim();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }

  if (normalized == 'Cannot GET /api/app/forum/me/posts') {
    return '当前云端 BFF 尚未部署我的帖子读侧路由，请先同步云端后再试。';
  }

  return null;
}

String _readFailureFallback(String path, {String? errorCode}) {
  if (path.contains('/forum/feed')) {
    return '论坛内容暂时不可用，请稍后再试';
  }
  if (path.contains('/forum/topic/metadata') ||
      path.contains('/forum/topic/')) {
    return '分类内容暂时不可用，请稍后再试';
  }
  if (path.contains('/forum/post/comments')) {
    return '评论内容暂时不可用，请稍后再试';
  }
  if (path.contains('/forum/post/detail')) {
    return '帖子内容暂时不可用，请稍后再试';
  }
  if (path.contains('/forum/author/profile')) {
    return '作者主页暂时不可用，请稍后再试';
  }
  if (path.contains('/forum/author/posts')) {
    return '公开帖子暂时不可用，请稍后再试';
  }
  if (path.contains('/forum/search')) {
    return '搜索结果暂时不可用，请稍后再试';
  }
  if (path.contains('/forum/reports/mine')) {
    return '我的举报记录暂时不可用，请稍后再试';
  }
  if (path.contains('/forum/draft/')) {
    return '草稿内容暂时不可用，请稍后再试';
  }
  if (path.contains('/forum/me/')) {
    return '论坛资产暂时不可用，请稍后再试';
  }
  if (path.contains('/forum/interaction/')) {
    return '互动通知暂时不可用，请稍后再试';
  }
  if (path.contains('/profile/block')) {
    return '拉黑关系状态暂时不可用，请稍后再试';
  }
  if (errorCode == 'AUTH_SESSION_INVALID') {
    return '请先登录后再查看';
  }
  return '内容暂时没有加载出来，请稍后再试';
}

String _readNotFoundFallback(String path) {
  if (path.contains('/forum/interaction/')) {
    return '互动通知暂不可用';
  }
  if (path.contains('/forum/post/detail')) {
    return '没有找到这条帖子，可能已删除或暂不公开';
  }
  if (path.contains('/forum/post/comments')) {
    return '没有找到这条帖子的评论入口';
  }
  if (path.contains('/forum/author/profile')) {
    return '没有找到这个作者主页';
  }
  if (path.contains('/forum/author/posts')) {
    return '没有找到这个作者的公开帖子';
  }
  if (path.contains('/forum/me/')) {
    return '没有找到对应的论坛资产';
  }
  if (path.contains('/forum/topic/')) {
    return '没有找到这个论坛分类';
  }
  return '没有找到对应的论坛内容';
}

String _readEmptyFallback(String path) {
  if (path.contains('/forum/search')) {
    return '没有找到相关内容';
  }
  if (path.contains('/forum/author/posts')) {
    return '当前作者还没有公开帖子';
  }
  if (path.contains('/forum/reports/mine')) {
    return '当前还没有举报记录';
  }
  if (path.contains('/forum/draft/')) {
    return '暂无草稿';
  }
  if (path.contains('/forum/me/')) {
    return '当前还没有可见内容';
  }
  if (path.contains('/forum/interaction/')) {
    return '当前没有新互动';
  }
  return '当前还没有内容';
}

bool _looksTechnicalIdentity(String value) {
  final lower = value.toLowerCase();
  return RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      ).hasMatch(lower) ||
      lower.startsWith('u_') ||
      lower.startsWith('org_') ||
      lower.contains('forum_') ||
      lower.contains('phase2') ||
      lower.contains('actor') ||
      lower.contains('topic') ||
      lower.contains('draft');
}

bool _looksPhoneNumber(String value) {
  return RegExp(r'^1\d{10}$').hasMatch(value);
}

String _maskPhoneNumber(String value) {
  return '${value.substring(0, 3)}****${value.substring(7)}';
}
