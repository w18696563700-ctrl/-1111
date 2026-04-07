part of 'forum_visible_copy.dart';

String forumDisplayTopicLabel({
  String? rawLabel,
  String? topicId,
  String? categoryKey,
  String fallback = '论坛分类',
}) {
  final direct = _normalizeVisibleTopicLabel(
    rawLabel,
    topicId: topicId,
    categoryKey: categoryKey,
  );
  if (direct != null) {
    return direct;
  }

  return _topicLabelFromKey(topicId) ??
      _topicLabelFromKey(categoryKey) ??
      fallback;
}

String forumDisplayTopicDescription({
  String? rawDescription,
  String? rawLabel,
  String? topicId,
  String? categoryKey,
}) {
  final label = forumDisplayTopicLabel(
    rawLabel: rawLabel,
    topicId: topicId,
    categoryKey: categoryKey,
    fallback: '论坛分类',
  );
  final byLabel = switch (label) {
    '布展进场' => '适合讨论进场排期、搭建窗口和现场衔接。',
    '材料协同' => '适合讨论材料替代、交接模板和协作效率。',
    '本地供应链' => '适合讨论本地找货、备货和供应协同。',
    '施工夜班' => '适合讨论夜班施工、吊装顺序和现场安全。',
    '关注话题' => '优先查看你持续关注的话题动态。',
    '发帖分类' => '当前分类恢复后，可以继续选择发帖分类。',
    _ => null,
  };
  if (byLabel != null) {
    return byLabel;
  }

  final value = rawDescription?.trim();
  if (value != null &&
      value.isNotEmpty &&
      _containsChinese(value) &&
      !_looksTechnicalVisibleMessage(value)) {
    return value;
  }
  return '选择这个分类后，帖子会进入对应讨论区。';
}

String? _topicLabelFromKey(String? raw) {
  final value = raw?.trim().toLowerCase();
  if (value == null || value.isEmpty) {
    return null;
  }
  if (value.contains('expo') ||
      value.contains('entry') ||
      value.contains('进场')) {
    return '布展进场';
  }
  if (value.contains('material') || value.contains('材料')) {
    return '材料协同';
  }
  if (value.contains('local') ||
      value.contains('supply') ||
      value.contains('supplier') ||
      value.contains('本地')) {
    return '本地供应链';
  }
  if (value.contains('night') ||
      value.contains('shift') ||
      value.contains('夜班')) {
    return '施工夜班';
  }
  if (value.contains('follow') || value.contains('关注')) {
    return '关注话题';
  }
  if (value.contains('publish')) {
    return '发帖分类';
  }
  return null;
}

bool _looksTechnicalTopic(String value) {
  final lower = value.toLowerCase();
  return lower.startsWith('forum-') ||
      lower.startsWith('topic-') ||
      lower.contains('slug') ||
      lower.contains('raw') ||
      lower.contains('key') ||
      lower.contains('topic') ||
      lower.contains('publish-ready') ||
      lower.contains('bff-publish') ||
      lower.contains('metadata') ||
      lower.contains('sample') ||
      lower.contains('probe') ||
      lower.contains('fresh-') ||
      lower.contains('draft') ||
      lower.contains('publish') ||
      RegExp(r'[_-]').hasMatch(lower) ||
      RegExp(r'\d{4,}').hasMatch(lower);
}

String? _normalizeVisibleTopicLabel(
  String? rawLabel, {
  String? topicId,
  String? categoryKey,
}) {
  final value = rawLabel?.trim();
  final byId = _topicAliasById(topicId);
  if (byId != null) {
    return byId;
  }

  final fromKey = _topicLabelFromKey(value);
  if (fromKey != null) {
    return fromKey;
  }

  final byPattern = _topicAliasByPattern(value);
  if (byPattern != null) {
    return byPattern;
  }

  final byCategory = _topicLabelFromKey(categoryKey);
  if (byCategory != null) {
    return byCategory;
  }

  if (value == null || value.isEmpty) {
    return null;
  }

  if (_containsChinese(value) && !_looksTechnicalTopic(value)) {
    return value;
  }
  return null;
}

String? _topicAliasById(String? topicId) {
  return switch (topicId?.trim()) {
    '96cf8c4e-c3ec-468a-9690-00491b4a4ad8' => '布展进场',
    '894f9752-c847-47e9-818b-6d330bcfaa2b' => '材料协同',
    '7da5c32e-54da-4b6c-8dde-2f317d67a57d' => '本地供应链',
    '2f35ab93-73e1-4ffb-9e27-69783676d5d4' => '施工夜班',
    _ => null,
  };
}

String? _topicAliasByPattern(String? rawLabel) {
  final value = rawLabel?.trim().toLowerCase();
  if (value == null || value.isEmpty) {
    return null;
  }
  if (value.contains('expo') || value.contains('entry-window')) {
    return '布展进场';
  }
  if (value.contains('material') || value.contains('co-work')) {
    return '材料协同';
  }
  if (value.contains('local-supply') ||
      value.contains('supply-chain') ||
      value.contains('supplier')) {
    return '本地供应链';
  }
  if (value.contains('night-shift') ||
      value.contains('late-night') ||
      value.contains('overtime')) {
    return '施工夜班';
  }
  if (value.contains('publish-ready')) {
    return '布展进场';
  }
  if (value.contains('bff-publish')) {
    return '材料协同';
  }
  if (value.contains('fresh') && value.contains('draft')) {
    return '本地供应链';
  }
  if (value.contains('fresh') && value.contains('topic')) {
    return '施工夜班';
  }
  return null;
}
