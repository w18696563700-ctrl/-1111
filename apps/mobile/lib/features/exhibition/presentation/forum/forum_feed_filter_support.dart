part of 'forum_pages.dart';

const List<ForumFeedScope> _forumTopLevelOrder = <ForumFeedScope>[
  ForumFeedScope.square,
  ForumFeedScope.following,
  ForumFeedScope.local,
];

const String _allTopicFilterKey = 'all';

const List<({String fallbackKey, String label})> _fallbackTopicFilters =
    <({String fallbackKey, String label})>[
      (fallbackKey: 'expo', label: '布展进场'),
      (fallbackKey: 'material', label: '材料协同'),
      (fallbackKey: 'local_supply', label: '本地供应链'),
      (fallbackKey: 'night_shift', label: '施工夜班'),
    ];

class _ForumTopicFilterChipData {
  const _ForumTopicFilterChipData({
    required this.filterKey,
    required this.label,
    required this.fallbackKey,
  });

  final String filterKey;
  final String label;
  final String? fallbackKey;
}

List<_ForumTopicFilterChipData> _buildTopicFilterChips(
  List<ForumTopicMetadataItemView> items,
) {
  final chips = <_ForumTopicFilterChipData>[
    const _ForumTopicFilterChipData(
      filterKey: _allTopicFilterKey,
      label: '全部',
      fallbackKey: null,
    ),
  ];
  final seenTopicIds = <String>{};
  final metadataByTitle = <String, ForumTopicMetadataItemView>{
    for (final item in items)
      forumDisplayTopicLabel(rawLabel: item.title, topicId: item.topicId): item,
  };

  for (final item in _fallbackTopicFilters) {
    final metadata = metadataByTitle[item.label];
    chips.add(
      _ForumTopicFilterChipData(
        filterKey: metadata == null
            ? _fallbackFilterKey(item.fallbackKey)
            : _topicFilterKey(metadata.topicId),
        label: item.label,
        fallbackKey: item.fallbackKey,
      ),
    );
    if (metadata != null) {
      seenTopicIds.add(metadata.topicId);
    }
  }

  for (final item in items) {
    if (seenTopicIds.contains(item.topicId)) {
      continue;
    }
    final label = forumDisplayTopicLabel(
      rawLabel: item.title,
      topicId: item.topicId,
    );
    if (label == '论坛分类' || label == '发帖分类') {
      continue;
    }
    if (chips.any((_ForumTopicFilterChipData chip) => chip.label == label)) {
      continue;
    }
    chips.add(
      _ForumTopicFilterChipData(
        filterKey: _topicFilterKey(item.topicId),
        label: label,
        fallbackKey: null,
      ),
    );
  }
  return chips;
}

String _topicFilterKey(String topicId) => 'topic:$topicId';

String _fallbackFilterKey(String fallbackKey) => 'fallback:$fallbackKey';

String? _queryTopicIdForFilter(String filterKey) {
  return filterKey.startsWith('topic:')
      ? filterKey.substring('topic:'.length)
      : null;
}

String? _fallbackKeyForFilter(String filterKey) {
  return filterKey.startsWith('fallback:')
      ? filterKey.substring('fallback:'.length)
      : null;
}

bool _isFilterSelected(
  String selectedFilterKey,
  _ForumTopicFilterChipData chip,
) {
  if (selectedFilterKey == chip.filterKey) {
    return true;
  }

  final selectedFallbackKey = _fallbackKeyForFilter(selectedFilterKey);
  return selectedFallbackKey != null &&
      chip.fallbackKey != null &&
      selectedFallbackKey == chip.fallbackKey;
}

List<ForumFeedItemView> _filterFeedItems(
  List<ForumFeedItemView> items, {
  required String selectedFilterKey,
}) {
  final selectedTopicId = _queryTopicIdForFilter(selectedFilterKey);
  if (selectedTopicId != null) {
    return items
        .where((ForumFeedItemView item) => item.topicId == selectedTopicId)
        .toList(growable: false);
  }

  final fallbackKey = _fallbackKeyForFilter(selectedFilterKey);
  if (fallbackKey == null) {
    return items;
  }

  return items
      .where(
        (ForumFeedItemView item) => _matchesFallbackFilter(item, fallbackKey),
      )
      .toList(growable: false);
}

bool _matchesFallbackFilter(ForumFeedItemView item, String fallbackKey) {
  final topicLabel = forumDisplayTopicLabel(
    rawLabel: item.topicLabel,
    topicId: item.topicId,
  );
  return switch (fallbackKey) {
    'expo' => topicLabel == '布展进场',
    'material' => topicLabel == '材料协同',
    'local_supply' => topicLabel == '本地供应链' || item.title.contains('本地'),
    'night_shift' =>
      topicLabel == '施工夜班' ||
          item.title.contains('夜班') ||
          item.excerpt.contains('夜班'),
    _ => true,
  };
}
