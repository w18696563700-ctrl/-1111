part of 'forum_shared_components.dart';

class ForumCategoryBadge extends StatelessWidget {
  const ForumCategoryBadge({
    super.key,
    required this.label,
    this.compact = false,
  });

  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppVisualTokens.brandGoldLight,
        borderRadius: AppVisualTokens.radiusPillBorder,
        border: Border.all(
          color: AppVisualTokens.brandGold.withValues(alpha: 0.18),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 9 : 11,
          vertical: compact ? 4 : 6,
        ),
        child: Text(
          label.startsWith('#') ? label : '# $label',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextTokens.badgeText.copyWith(
            color: AppVisualTokens.brandGoldDark,
          ),
        ),
      ),
    );
  }
}

class ForumAuthorAvatar extends StatelessWidget {
  const ForumAuthorAvatar({
    super.key,
    required this.label,
    this.avatarUrl,
    this.radius = 18,
  });

  final String label;
  final String? avatarUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final visibleAvatarUrl = avatarUrl?.trim();
    return SafeRemoteAvatar(
      radius: radius,
      imageUrl: visibleAvatarUrl,
      label: label,
      backgroundColor: AppVisualTokens.brandGoldLight,
      foregroundColor: AppVisualTokens.brandGoldDark,
      textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w900,
        color: AppVisualTokens.brandGoldDark,
      ),
    );
  }
}

class ForumAuthorRow extends StatelessWidget {
  const ForumAuthorRow({
    super.key,
    required this.author,
    this.publishedAt,
    this.onTap,
    this.trailing,
    this.dense = false,
    this.showChevron = true,
  });

  final ForumAuthorSummaryView author;
  final String? publishedAt;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool dense;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visibleName = forumDisplayActorName(author.displayName);
    final organizationName = forumDisplayOrganizationName(
      author.organizationName,
    );
    final timeLabel = publishedAt == null
        ? null
        : forumDisplayTimeLabel(publishedAt!);
    final secondary = <String>[?organizationName, ?timeLabel].join(' · ');
    final row = Row(
      children: <Widget>[
        ForumAuthorAvatar(
          label: visibleName,
          avatarUrl: author.avatarUrl,
          radius: dense ? 14 : 17,
        ),
        SizedBox(width: dense ? 7 : 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                visibleName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppVisualTokens.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (secondary.isNotEmpty) ...<Widget>[
                const SizedBox(height: 2),
                Text(
                  secondary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppVisualTokens.textSecondary,
                    fontSize: dense ? 11 : null,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...<Widget>[
          const SizedBox(width: 8),
          trailing!,
        ] else if (showChevron && onTap != null)
          const Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: AppVisualTokens.textTertiary,
          ),
      ],
    );

    if (onTap == null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: dense ? 0 : 2),
        child: row,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppVisualTokens.radiusLarge),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 2, vertical: dense ? 1 : 3),
          child: row,
        ),
      ),
    );
  }
}

class ForumStatsRow extends StatelessWidget {
  const ForumStatsRow({
    super.key,
    this.replyCount,
    this.likeCount,
    this.viewCount,
    this.compact = false,
  });

  final int? replyCount;
  final int? likeCount;
  final int? viewCount;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final items = <_ForumStatSpec>[
      if (replyCount != null)
        _ForumStatSpec(Icons.mode_comment_outlined, '$replyCount 回复'),
      if (likeCount != null)
        _ForumStatSpec(Icons.thumb_up_alt_outlined, '$likeCount 赞'),
      if (viewCount != null)
        _ForumStatSpec(Icons.visibility_outlined, '$viewCount 浏览'),
    ];
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: compact ? 8 : 12,
      runSpacing: 6,
      children: items
          .map(
            (_ForumStatSpec item) => _ForumStatChip(
              icon: item.icon,
              label: item.label,
              compact: compact,
            ),
          )
          .toList(growable: false),
    );
  }
}

class ForumAttachmentPreview extends StatelessWidget {
  const ForumAttachmentPreview({
    super.key,
    required this.attachments,
    this.onOpenAttachment,
    this.compact = false,
  });

  final List<ForumAttachmentRefView> attachments;
  final ValueChanged<ForumAttachmentRefView>? onOpenAttachment;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) {
      return const SizedBox.shrink();
    }

    final visibleItems = attachments.take(compact ? 3 : 4).toList();
    final restCount = attachments.length - visibleItems.length;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (final item in visibleItems)
          _ForumAttachmentChip(
            item: item,
            compact: compact,
            onTap: onOpenAttachment == null
                ? null
                : () => onOpenAttachment!(item),
          ),
        if (restCount > 0)
          _ForumAttachmentRemainderChip(count: restCount, compact: compact),
      ],
    );
  }
}

class _ForumStatSpec {
  const _ForumStatSpec(this.icon, this.label);

  final IconData icon;
  final String label;
}

class _ForumStatChip extends StatelessWidget {
  const _ForumStatChip({
    required this.icon,
    required this.label,
    required this.compact,
  });

  final IconData icon;
  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          icon,
          size: compact ? 14 : 16,
          color: AppVisualTokens.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppVisualTokens.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ForumAttachmentChip extends StatelessWidget {
  const _ForumAttachmentChip({
    required this.item,
    required this.compact,
    this.onTap,
  });

  final ForumAttachmentRefView item;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: AppVisualTokens.radiusMediumBorder,
        border: Border.all(color: AppVisualTokens.borderSoft),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 9 : 10,
          vertical: compact ? 7 : 8,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              _attachmentIcon(item.mimeType),
              size: compact ? 15 : 17,
              color: AppVisualTokens.brandGoldDark,
            ),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: compact ? 96 : 150),
              child: Text(
                item.fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppVisualTokens.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 6),
            _ForumSoftBadge(label: _attachmentTypeLabel(item.mimeType)),
          ],
        ),
      ),
    );
    if (onTap == null) {
      return child;
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppVisualTokens.radiusMediumBorder,
        onTap: onTap,
        child: child,
      ),
    );
  }
}

class _ForumAttachmentRemainderChip extends StatelessWidget {
  const _ForumAttachmentRemainderChip({
    required this.count,
    required this.compact,
  });

  final int count;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppVisualTokens.brandGoldLight,
        borderRadius: AppVisualTokens.radiusMediumBorder,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 9 : 10,
          vertical: compact ? 7 : 8,
        ),
        child: Text(
          '+$count',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppVisualTokens.brandGoldDark,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _ForumSoftBadge extends StatelessWidget {
  const _ForumSoftBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: AppVisualTokens.radiusPillBorder,
        border: Border.all(color: AppVisualTokens.borderSoft),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        child: Text(
          label,
          style: AppTextTokens.badgeText.copyWith(
            color: AppVisualTokens.textSecondary,
          ),
        ),
      ),
    );
  }
}

IconData _attachmentIcon(String mimeType) => switch (mimeType) {
  final value when value.startsWith('image/') => Icons.photo_outlined,
  final value when value.startsWith('video/') => Icons.videocam_outlined,
  final value when value.contains('pdf') => Icons.picture_as_pdf_outlined,
  _ => Icons.description_outlined,
};

String _attachmentTypeLabel(String mimeType) => switch (mimeType) {
  final value when value.startsWith('image/') => '图片',
  final value when value.startsWith('video/') => '视频',
  final value when value.contains('pdf') => 'PDF',
  _ => '文件',
};
