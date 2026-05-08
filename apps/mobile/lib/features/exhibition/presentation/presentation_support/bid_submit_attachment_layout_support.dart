part of '../exhibition_trade_pages.dart';

Widget _buildBidSubmitAttachmentGrid({
  required BuildContext context,
  required List<_BidSubmitAttachmentSlotState> attachmentSlots,
  required bool submitting,
  required Future<void> Function(_BidSubmitAttachmentSlotState slot)
  onUploadAttachment,
  required Future<void> Function(_BidSubmitAttachmentSlotState slot)
  onPreviewAttachment,
}) {
  return LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      final useWideLayout =
          constraints.maxWidth >= _bidSubmitAttachmentWideLayoutBreakpoint;

      return _BidSubmitAttachmentChecklist(
        slots: attachmentSlots,
        useWideLayout: useWideLayout,
        submitting: submitting,
        onUploadAttachment: onUploadAttachment,
        onPreviewAttachment: onPreviewAttachment,
      );
    },
  );
}

class _BidSubmitAttachmentChecklist extends StatelessWidget {
  const _BidSubmitAttachmentChecklist({
    required this.slots,
    required this.useWideLayout,
    required this.submitting,
    required this.onUploadAttachment,
    required this.onPreviewAttachment,
  });

  final List<_BidSubmitAttachmentSlotState> slots;
  final bool useWideLayout;
  final bool submitting;
  final Future<void> Function(_BidSubmitAttachmentSlotState slot)
  onUploadAttachment;
  final Future<void> Function(_BidSubmitAttachmentSlotState slot)
  onPreviewAttachment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final confirmedCount = slots.where((slot) => slot.isConfirmed).length;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.72),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '必传资料',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                _BidSubmitAttachmentMiniBadge(
                  label: '$confirmedCount/${slots.length} 已完成',
                  emphasized: confirmedCount == slots.length,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '按清单补齐项目理解、报价表和进度安排，三项完成后才能提交。',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 10),
            if (useWideLayout)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    for (int index = 0; index < slots.length; index++) ...[
                      Expanded(
                        child: _buildBidSubmitAttachmentSlotCard(
                          context: context,
                          slot: slots[index],
                          submitting: submitting,
                          onUploadAttachment: onUploadAttachment,
                          onPreviewAttachment: onPreviewAttachment,
                          compact: false,
                        ),
                      ),
                      if (index < slots.length - 1)
                        const SizedBox(width: _bidSubmitAttachmentGridSpacing),
                    ],
                  ],
                ),
              )
            else
              Column(
                children: <Widget>[
                  for (int index = 0; index < slots.length; index++) ...[
                    _buildBidSubmitAttachmentSlotCard(
                      context: context,
                      slot: slots[index],
                      submitting: submitting,
                      onUploadAttachment: onUploadAttachment,
                      onPreviewAttachment: onPreviewAttachment,
                      compact: true,
                    ),
                    if (index < slots.length - 1)
                      Divider(
                        height: 14,
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.54,
                        ),
                      ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}

Widget _buildBidSubmitAttachmentSlotCard({
  required BuildContext context,
  required _BidSubmitAttachmentSlotState slot,
  required bool submitting,
  required Future<void> Function(_BidSubmitAttachmentSlotState slot)
  onUploadAttachment,
  required Future<void> Function(_BidSubmitAttachmentSlotState slot)
  onPreviewAttachment,
  required bool compact,
}) {
  final theme = Theme.of(context);
  final statusLabel = _bidSubmitAttachmentStatusLabel(slot);
  final statusColor = _bidSubmitAttachmentStatusColor(theme, slot);
  final statusLine = _bidSubmitAttachmentCompactStatusLine(slot);

  return DecoratedBox(
    key: slot.focusKey,
    decoration: BoxDecoration(
      color: compact
          ? Colors.transparent
          : theme.colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(16),
      border: compact
          ? null
          : Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.64),
            ),
    ),
    child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 0 : 12,
        vertical: compact ? 8 : 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _BidSubmitAttachmentIconBadge(
                confirmed: slot.isConfirmed,
                color: statusColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        Text(
                          slot.label,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const _BidSubmitAttachmentMiniBadge(label: '必传'),
                        _BidSubmitAttachmentMiniBadge(
                          label: statusLabel,
                          emphasized: slot.isConfirmed,
                          color: statusColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      slot.summary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 34,
                child: FilledButton(
                  onPressed: submitting ? null : () => onUploadAttachment(slot),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(slot.isConfirmed ? '重新上传' : '上传${slot.label}'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 34),
            child: Text(
              '支持格式：${slot.supportedTypes}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 34, top: 3),
            child: Text(
              statusLine,
              maxLines: slot.isConfirmed ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ),
          if (slot.isConfirmed) ...<Widget>[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 26),
                child: TextButton.icon(
                  onPressed: submitting || slot.previewOpening
                      ? null
                      : () => onPreviewAttachment(slot),
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: Text(slot.previewOpening ? '正在打开附件' : '预览检查已上传附件'),
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

class _BidSubmitAttachmentIconBadge extends StatelessWidget {
  const _BidSubmitAttachmentIconBadge({
    required this.confirmed,
    required this.color,
  });

  final bool confirmed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Icon(
          confirmed ? Icons.check_rounded : Icons.upload_file_outlined,
          size: 16,
          color: color,
        ),
      ),
    );
  }
}

class _BidSubmitAttachmentMiniBadge extends StatelessWidget {
  const _BidSubmitAttachmentMiniBadge({
    required this.label,
    this.emphasized = false,
    this.color,
  });

  final String label;
  final bool emphasized;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = color ?? theme.colorScheme.onSurfaceVariant;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: emphasized
            ? foreground.withValues(alpha: 0.12)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ),
    );
  }
}

Color _bidSubmitAttachmentStatusColor(
  ThemeData theme,
  _BidSubmitAttachmentSlotState slot,
) {
  if (slot.isConfirmed) {
    return theme.colorScheme.primary;
  }
  if (slot.uploadMessage != null ||
      slot.uploadState == AppUploadState.uploadFailedRetryable ||
      slot.uploadState == AppUploadState.uploadConfirmFailed) {
    return theme.colorScheme.error;
  }
  if (slot.uploadState == AppUploadState.uploading ||
      slot.uploadState == AppUploadState.uploadConfirming ||
      slot.uploadState == AppUploadState.localValidating ||
      slot.uploadState == AppUploadState.signedReady) {
    return theme.colorScheme.tertiary;
  }
  return theme.colorScheme.onSurfaceVariant;
}

String _bidSubmitAttachmentCompactStatusLine(
  _BidSubmitAttachmentSlotState slot,
) {
  if (slot.uploadMessage case final String message
      when message.trim().isNotEmpty) {
    return message;
  }

  final resolvedDraft = slot.resolvedDraft;
  final fileName = resolvedDraft?.fileName ?? slot.draft?.fileName;
  final statusLabel = _bidSubmitAttachmentStatusLabel(slot);
  if (fileName == null) {
    return '当前状态：$statusLabel';
  }

  final metadata = resolvedDraft == null
      ? fileName
      : '$fileName · ${_bidSubmitAttachmentMimeTypeLabel(resolvedDraft.mimeType)} · ${_bidSubmitAttachmentSizeLabel(resolvedDraft.sizeInBytes)}';
  return '当前状态：$statusLabel · $metadata';
}
