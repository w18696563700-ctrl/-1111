import 'package:flutter/material.dart';
import 'package:mobile/shared/ui/app_visual_components.dart';
import 'package:mobile/shared/ui/app_visual_tokens.dart';

class AttachmentTile extends StatelessWidget {
  const AttachmentTile({
    super.key,
    required this.fileName,
    this.fileSizeLabel,
    this.fileTypeLabel,
    this.subtitle,
    this.statusLabel,
    this.statusTone = AppStatusTone.neutral,
    this.leadingIcon,
    this.onOpen,
    this.onDelete,
    this.onMore,
    this.opening = false,
    this.deleting = false,
    this.enabled = true,
  });

  final String fileName;
  final String? fileSizeLabel;
  final String? fileTypeLabel;
  final String? subtitle;
  final String? statusLabel;
  final AppStatusTone statusTone;
  final IconData? leadingIcon;
  final VoidCallback? onOpen;
  final VoidCallback? onDelete;
  final VoidCallback? onMore;
  final bool opening;
  final bool deleting;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final meta = <String>[
      if (fileTypeLabel != null && fileTypeLabel!.trim().isNotEmpty)
        fileTypeLabel!.trim(),
      if (fileSizeLabel != null && fileSizeLabel!.trim().isNotEmpty)
        fileSizeLabel!.trim(),
      if (subtitle != null && subtitle!.trim().isNotEmpty) subtitle!.trim(),
    ].join(' · ');
    final canOpen = enabled && !opening && !deleting && onOpen != null;
    final canDelete = enabled && !opening && !deleting && onDelete != null;
    final canMore = enabled && !deleting && onMore != null;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: <Widget>[
          _AttachmentTypeIcon(icon: leadingIcon),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextTokens.cardTitle,
                ),
                if (meta.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 5),
                  Text(
                    meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextTokens.caption,
                  ),
                ],
                if (statusLabel != null && statusLabel!.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  AppStatusBadge(label: statusLabel!, tone: statusTone),
                ],
              ],
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            onPressed: canOpen ? onOpen : null,
            tooltip: '打开',
            icon: opening
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.open_in_new_rounded),
          ),
          if (onDelete != null)
            IconButton(
              onPressed: canDelete ? onDelete : null,
              tooltip: '删除',
              icon: deleting
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_outline_rounded),
            ),
          if (onMore != null)
            IconButton(
              onPressed: canMore ? onMore : null,
              tooltip: '更多',
              icon: const Icon(Icons.more_horiz_rounded),
            ),
        ],
      ),
    );
  }
}

class FileTile extends StatelessWidget {
  const FileTile({
    super.key,
    required this.fileName,
    this.fileSizeLabel,
    this.fileTypeLabel,
    this.statusLabel,
    this.statusTone = AppStatusTone.neutral,
    this.onOpen,
    this.onDelete,
    this.onMore,
  });

  final String fileName;
  final String? fileSizeLabel;
  final String? fileTypeLabel;
  final String? statusLabel;
  final AppStatusTone statusTone;
  final VoidCallback? onOpen;
  final VoidCallback? onDelete;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    return AttachmentTile(
      fileName: fileName,
      fileSizeLabel: fileSizeLabel,
      fileTypeLabel: fileTypeLabel,
      statusLabel: statusLabel,
      statusTone: statusTone,
      onOpen: onOpen,
      onDelete: onDelete,
      onMore: onMore,
    );
  }
}

class _AttachmentTypeIcon extends StatelessWidget {
  const _AttachmentTypeIcon({this.icon});

  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppVisualTokens.brandGold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox.square(
        dimension: 42,
        child: Icon(
          icon ?? Icons.insert_drive_file_outlined,
          size: 22,
          color: AppVisualTokens.brandGold,
        ),
      ),
    );
  }
}
