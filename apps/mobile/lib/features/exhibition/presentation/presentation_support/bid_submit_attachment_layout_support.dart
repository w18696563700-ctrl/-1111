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
      if (!useWideLayout) {
        return Column(
          children: attachmentSlots
              .expand(
                (_BidSubmitAttachmentSlotState slot) => <Widget>[
                  _buildBidSubmitAttachmentSlotCard(
                    context: context,
                    slot: slot,
                    submitting: submitting,
                    onUploadAttachment: onUploadAttachment,
                    onPreviewAttachment: onPreviewAttachment,
                  ),
                  if (!identical(slot, attachmentSlots.last))
                    const SizedBox(height: _bidSubmitAttachmentGridSpacing),
                ],
              )
              .toList(growable: false),
        );
      }

      final rows = _chunkBidSubmitRows(attachmentSlots, 3);
      return Column(
        children: rows
            .expand((List<_BidSubmitAttachmentSlotState> row) {
              final widgets = <Widget>[
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      for (int index = 0; index < 3; index++) ...<Widget>[
                        Expanded(
                          child: index < row.length
                              ? _buildBidSubmitAttachmentSlotCard(
                                  context: context,
                                  slot: row[index],
                                  submitting: submitting,
                                  onUploadAttachment: onUploadAttachment,
                                  onPreviewAttachment: onPreviewAttachment,
                                )
                              : const SizedBox.shrink(),
                        ),
                        if (index < 2)
                          const SizedBox(
                            width: _bidSubmitAttachmentGridSpacing,
                          ),
                      ],
                    ],
                  ),
                ),
              ];
              if (!identical(row, rows.last)) {
                widgets.add(
                  const SizedBox(height: _bidSubmitAttachmentGridSpacing),
                );
              }
              return widgets;
            })
            .toList(growable: false),
      );
    },
  );
}

Widget _buildBidSubmitAttachmentSlotCard({
  required BuildContext context,
  required _BidSubmitAttachmentSlotState slot,
  required bool submitting,
  required Future<void> Function(_BidSubmitAttachmentSlotState slot)
  onUploadAttachment,
  required Future<void> Function(_BidSubmitAttachmentSlotState slot)
  onPreviewAttachment,
}) {
  final theme = Theme.of(context);

  return DecoratedBox(
    key: ValueKey<String>('bid-submit-attachment-card-${slot.key}'),
    decoration: BoxDecoration(
      color: theme.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: theme.colorScheme.outlineVariant),
    ),
    child: SizedBox(
      height: _bidSubmitAttachmentCardHeight,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              slot.label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 44,
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  slot.summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 86,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '支持格式：${slot.supportedTypes}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _bidSubmitAttachmentCompactStatusLine(slot),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: slot.isConfirmed
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: submitting ? null : () => onUploadAttachment(slot),
                child: Text(
                  slot.isConfirmed ? '重新上传${slot.label}' : '上传${slot.label}',
                ),
              ),
            ),
            if (slot.isConfirmed) ...<Widget>[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: submitting || slot.previewOpening
                      ? null
                      : () => onPreviewAttachment(slot),
                  icon: const Icon(Icons.visibility_outlined),
                  label: Text(slot.previewOpening ? '正在打开附件' : '预览检查已上传附件'),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
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
