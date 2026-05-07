part of '../exhibition_trade_pages.dart';

void _showProjectCommunicationWorkbenchEntryListSheet({
  required BuildContext context,
  required CounterpartConversationResult<ProjectCommunicationWorkbenchView>?
  result,
  required Set<String> groups,
  required String title,
  required ValueChanged<String> onUnavailable,
  required ValueChanged<ProjectCommunicationWorkbenchEntryView> onOpenEntry,
}) {
  final data = result?.data;
  final wantsDealConfirmation = groups.contains('deal_confirmation');
  if (result?.state != AppPageState.content || data == null) {
    onUnavailable(
      wantsDealConfirmation ? '后续承接状态暂不可读，请稍后重试。' : '资料确认单状态暂不可读，请稍后重试。',
    );
    return;
  }
  final entries = data.entries
      .where((entry) => groups.contains(entry.group))
      .toList(growable: false);
  if (entries.isEmpty) {
    onUnavailable(wantsDealConfirmation ? '当前没有可处理的成交确认项。' : '当前没有可处理的资料确认项。');
    return;
  }
  final sheetResult =
      CounterpartConversationResult<ProjectCommunicationWorkbenchView>(
        state: AppPageState.content,
        method: result!.method,
        path: result.path,
        data: ProjectCommunicationWorkbenchView(
          projectId: data.projectId,
          threadId: data.threadId,
          viewerRole: data.viewerRole,
          businessTodoSummary: data.businessTodoSummary,
          chatAvailability: data.chatAvailability,
          entries: entries,
          generatedAt: data.generatedAt,
        ),
      );
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            0,
            16,
            16 + MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetContext).size.height * 0.72,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '先选择资料项进入预览，确认无误后再提交确认。',
                  style: Theme.of(sheetContext).textTheme.bodySmall?.copyWith(
                    color: Theme.of(sheetContext).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: SingleChildScrollView(
                    child: _ProjectCommunicationWorkbenchSection(
                      loading: false,
                      result: sheetResult,
                      allowedGroupKeys: groups,
                      initialExpandedGroupKeys: groups,
                      onOpenEntry: (entry) {
                        Navigator.of(sheetContext).pop();
                        scheduleMicrotask(() => onOpenEntry(entry));
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _WorkbenchStatusHeader extends StatelessWidget {
  const _WorkbenchStatusHeader({required this.entry});

  final ProjectCommunicationWorkbenchEntryView entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = _materialReviewStatusCode(entry);
    final style = _workbenchStatusStyle(theme, status);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: style.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  _materialReviewStatusIcon(status),
                  color: style.foreground,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: style.foreground,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                _MaterialConfirmationStatusPill(
                  label: _materialReviewStatusLabel(status),
                  foreground: style.pillForeground,
                  background: style.pillBackground,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _materialReviewStatusDescription(entry, status),
              style: theme.textTheme.bodySmall?.copyWith(
                color: style.foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkbenchSourceFileCard extends StatelessWidget {
  const _WorkbenchSourceFileCard({
    required this.file,
    required this.previewed,
    required this.loading,
    required this.onPreview,
  });

  final _WorkbenchSourceFile file;
  final bool previewed;
  final bool loading;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = previewed
        ? const Color(0xFF176D38)
        : theme.colorScheme.onSurface;
    final border = previewed
        ? const Color(0xFF6FC58D)
        : theme.colorScheme.outlineVariant;
    return Material(
      color: previewed
          ? const Color(0xFFEAF7EF)
          : theme.colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: loading ? null : onPreview,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: <Widget>[
              Icon(Icons.insert_drive_file_outlined, color: foreground),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      file.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      file.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (loading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                TextButton.icon(
                  onPressed: onPreview,
                  icon: Icon(
                    previewed
                        ? Icons.check_circle_outline
                        : Icons.visibility_outlined,
                  ),
                  label: Text(previewed ? '已预览' : '预览'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String _materialReviewStatusCode(ProjectCommunicationWorkbenchEntryView entry) {
  final code = (entry.reviewState ?? entry.availabilityState).trim();
  return code.isEmpty ? 'unavailable' : code;
}

String _materialReviewStatusLabel(String status) {
  return switch (status) {
    'pending_review' => '待确认',
    'confirmed' => '已确认',
    'needs_supplement' => '需补充',
    'unsubmitted' => '未提交',
    _ => '暂不可读',
  };
}

IconData _materialReviewStatusIcon(String status) {
  return switch (status) {
    'confirmed' => Icons.check_circle_outline,
    'needs_supplement' => Icons.error_outline,
    'unsubmitted' => Icons.hourglass_empty_outlined,
    _ => Icons.assignment_turned_in_outlined,
  };
}

String _materialReviewStatusDescription(
  ProjectCommunicationWorkbenchEntryView entry,
  String status,
) {
  final owner = entry.group == 'publisher_materials' ? '发布方' : '竞标方';
  return switch (status) {
    'pending_review' => '$owner资料已提交，请先预览文件，再确认无误或要求补充。',
    'confirmed' => '该资料已确认，确认结果来自 Server 持久化状态。',
    'needs_supplement' => '该资料已要求补充，请等待对方按反馈重新提交。',
    'unsubmitted' => '$owner尚未提交该资料，当前不能确认。',
    _ => '当前资料状态暂不可读，请刷新后重试。',
  };
}
