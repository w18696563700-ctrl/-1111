part of '../exhibition_trade_pages.dart';

final class _WorkbenchGroupData {
  const _WorkbenchGroupData({
    required this.key,
    required this.title,
    required this.summary,
    required this.entries,
  });

  final String key;
  final String title;
  final String summary;
  final List<ProjectCommunicationWorkbenchEntryView> entries;
}

String _workbenchEntryState(ProjectCommunicationWorkbenchEntryView entry) {
  return (entry.reviewState ?? entry.availabilityState).trim();
}

String _groupStatus(List<ProjectCommunicationWorkbenchEntryView> entries) {
  if (entries.isEmpty) {
    return 'unavailable';
  }
  final states = entries.map(_workbenchEntryState).toList(growable: false);
  if (states.contains('needs_supplement')) {
    return 'needs_supplement';
  }
  if (states.contains('pending_review')) {
    return 'pending_review';
  }
  if (states.every((state) => state == 'confirmed')) {
    return 'confirmed';
  }
  if (states.contains('unsubmitted')) {
    return 'unsubmitted';
  }
  return 'unavailable';
}

String _groupStatusLabel(
  List<ProjectCommunicationWorkbenchEntryView> entries,
  String status,
) {
  final count = entries.length;
  return switch (status) {
    'needs_supplement' => '需补充',
    'pending_review' => '有待确认资料',
    'confirmed' => '已确认完成',
    'unsubmitted' => '$count 项未提交',
    _ => '$count 项暂不可读',
  };
}

_ProjectMaterialConfirmationTileStyle _workbenchStatusStyle(
  ThemeData theme,
  String status,
) {
  final colorScheme = theme.colorScheme;
  return switch (status) {
    'pending_review' => const _ProjectMaterialConfirmationTileStyle(
      foreground: Color(0xFF8A5600),
      background: Color(0xFFFFF7E8),
      border: Color(0xFFE4B266),
      pillForeground: Color(0xFF8A5600),
      pillBackground: Color(0xFFFFE8B8),
    ),
    'confirmed' => const _ProjectMaterialConfirmationTileStyle(
      foreground: Color(0xFF176D38),
      background: Color(0xFFEAF7EF),
      border: Color(0xFF6FC58D),
      pillForeground: Color(0xFF176D38),
      pillBackground: Color(0xFFD7F1DF),
    ),
    'needs_supplement' => const _ProjectMaterialConfirmationTileStyle(
      foreground: Color(0xFFB42318),
      background: Color(0xFFFFEDEA),
      border: Color(0xFFFFA39A),
      pillForeground: Color(0xFFB42318),
      pillBackground: Color(0xFFFFD4CF),
    ),
    _ => _ProjectMaterialConfirmationTileStyle(
      foreground: colorScheme.onSurfaceVariant,
      background: colorScheme.surfaceContainerLowest,
      border: colorScheme.outlineVariant,
      pillForeground: colorScheme.onSurfaceVariant,
      pillBackground: colorScheme.surfaceContainerHighest,
    ),
  };
}
