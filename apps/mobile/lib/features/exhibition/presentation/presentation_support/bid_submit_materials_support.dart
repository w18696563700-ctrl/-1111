part of '../exhibition_trade_pages.dart';

ProjectBidMaterialListReadModel? _projectBidMaterialListFromPayload(
  Object? payload,
) {
  try {
    return ProjectBidMaterialListReadModel.fromPayload(payload);
  } on FormatException {
    return null;
  }
}

String _projectBidMaterialFailureMessage(ExhibitionLoadResult result) {
  final rawMessage = result.message?.trim();
  if (rawMessage != null &&
      RegExp(
        r'^Cannot GET /api/app/project/bid-materials$',
      ).hasMatch(rawMessage)) {
    return '当前项目材料清单暂不可读，请稍后再试。';
  }

  return switch (result.state) {
    AppPageState.unauthorized => '当前登录状态不可继续查看项目材料，请重新登录后再试。',
    AppPageState.forbidden => '当前项目材料清单暂不可读，请稍后再试。',
    AppPageState.notFound => '当前项目材料清单暂不可读，请稍后再试。',
    _ =>
      rawMessage == 'current fake transport did not provide this canonical path'
          ? '当前项目材料清单暂不可读，请稍后再试。'
          : '当前项目材料清单暂不可读，请稍后再试。',
  };
}

Widget _buildBidSubmitMaterialSection({
  required ExhibitionLoadResult? bidMaterialResult,
  required String? projectId,
  required Set<String> openingAttachmentIds,
  required Set<String> openingReviewEntryKeys,
  required VoidCallback onRetry,
  required Future<void> Function(ProjectBidMaterialReadModel attachment)
  onOpenAttachment,
  required Future<void> Function(ProjectCommunicationWorkbenchEntryView entry)
  onOpenMaterialReview,
}) {
  final result = bidMaterialResult;
  if (result == null || result.state == AppPageState.loading) {
    return const _ActionCard(
      title: '查看报价依据资料',
      summary: '这里只读展示发布方上传的五类报价依据资料，不提供上传、删除或绑定动作。',
      tone: _ActionCardTone.emphasis,
      children: <Widget>[
        _StateMessage(
          title: '正在读取报价依据资料',
          body: '正在同步当前项目的效果图、尺寸图、材质图、设备物料清单和服务清单。',
        ),
      ],
    );
  }

  if (result.state != AppPageState.content &&
      result.state != AppPageState.empty) {
    return _ActionCard(
      title: '查看报价依据资料',
      summary: '这里只读展示发布方上传的五类报价依据资料，不提供上传、删除或绑定动作。',
      tone: _ActionCardTone.emphasis,
      children: <Widget>[
        _StateMessage(
          title: '报价依据资料暂不可读',
          body: _projectBidMaterialFailureMessage(result),
        ),
        const SizedBox(height: 12),
        FilledButton.tonal(onPressed: onRetry, child: const Text('重新读取报价依据资料')),
      ],
    );
  }

  final materials = _projectBidMaterialListFromPayload(result.payload);
  final attachments =
      materials?.attachments ?? const <ProjectBidMaterialReadModel>[];
  final materialReview = materials?.materialReview;
  final attachmentsByKind = <String, List<ProjectBidMaterialReadModel>>{};
  for (final attachment in attachments) {
    attachmentsByKind
        .putIfAbsent(
          attachment.attachmentKind,
          () => <ProjectBidMaterialReadModel>[],
        )
        .add(attachment);
  }

  return _ActionCard(
    title: '查看报价依据资料',
    summary: '这里只读展示发布方上传的五类报价依据资料，不提供上传、删除或绑定动作。',
    tone: _ActionCardTone.emphasis,
    children: <Widget>[
      const _StateMessage(
        title: '温馨提示',
        body: '建议先将资料下载到手机，再导入电脑完成报价测算和方案整理。下载后的资料仅用于本项目竞标，请勿外传。',
      ),
      const SizedBox(height: 12),
      Align(
        alignment: Alignment.centerLeft,
        child: OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('刷新报价依据资料'),
        ),
      ),
      const SizedBox(height: 12),
      if (materials == null)
        const _EmptyNotice(title: '报价依据资料暂不可读', message: '当前项目材料清单暂不可读，请稍后再试。')
      else
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final maxWidth = constraints.maxWidth;
            final itemWidth = maxWidth >= 520
                ? (maxWidth - 16) / 3
                : maxWidth >= 360
                ? (maxWidth - 12) / 2
                : maxWidth;
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _bidSubmitMaterialGridKinds
                  .map((_BidSubmitMaterialGridKind kind) {
                    return SizedBox(
                      width: itemWidth,
                      child: _BidSubmitMaterialGridCell(
                        kind: kind,
                        projectId: projectId,
                        attachments:
                            attachmentsByKind[kind.attachmentKind] ??
                            const <ProjectBidMaterialReadModel>[],
                        reviewEntry: _bidSubmitMaterialReviewEntryForKind(
                          materialReview,
                          kind.attachmentKind,
                        ),
                        openingAttachmentIds: openingAttachmentIds,
                        openingReviewEntryKeys: openingReviewEntryKeys,
                        onOpenAttachment: onOpenAttachment,
                        onOpenMaterialReview: onOpenMaterialReview,
                      ),
                    );
                  })
                  .toList(growable: false),
            );
          },
        ),
    ],
  );
}

class _BidSubmitMaterialGridKind {
  const _BidSubmitMaterialGridKind({
    required this.attachmentKind,
    required this.title,
    required this.summary,
    required this.icon,
  });

  final String attachmentKind;
  final String title;
  final String summary;
  final IconData icon;
}

const List<_BidSubmitMaterialGridKind> _bidSubmitMaterialGridKinds =
    <_BidSubmitMaterialGridKind>[
      _BidSubmitMaterialGridKind(
        attachmentKind: _projectAttachmentKindEffectImage,
        title: '效果图',
        summary: '视觉、造型、灯光',
        icon: Icons.image_outlined,
      ),
      _BidSubmitMaterialGridKind(
        attachmentKind: _projectAttachmentKindConstructionDoc,
        title: '尺寸图 / 施工图',
        summary: '面积、结构、用料',
        icon: Icons.architecture_rounded,
      ),
      _BidSubmitMaterialGridKind(
        attachmentKind: _projectAttachmentKindMaterialSample,
        title: '材质图 / 材料样板',
        summary: '板材、饰面、工艺',
        icon: Icons.texture_rounded,
      ),
      _BidSubmitMaterialGridKind(
        attachmentKind: _projectAttachmentKindEquipmentMaterialList,
        title: '设备物料清单',
        summary: 'LED、电视、桌椅等',
        icon: Icons.inventory_2_outlined,
      ),
      _BidSubmitMaterialGridKind(
        attachmentKind: _projectAttachmentKindServiceList,
        title: '服务清单',
        summary: '保洁、摄影、礼仪等',
        icon: Icons.room_service_outlined,
      ),
    ];

class _BidSubmitMaterialGridCell extends StatelessWidget {
  const _BidSubmitMaterialGridCell({
    required this.kind,
    required this.projectId,
    required this.attachments,
    required this.reviewEntry,
    required this.openingAttachmentIds,
    required this.openingReviewEntryKeys,
    required this.onOpenAttachment,
    required this.onOpenMaterialReview,
  });

  final _BidSubmitMaterialGridKind kind;
  final String? projectId;
  final List<ProjectBidMaterialReadModel> attachments;
  final ProjectCommunicationWorkbenchEntryView? reviewEntry;
  final Set<String> openingAttachmentIds;
  final Set<String> openingReviewEntryKeys;
  final Future<void> Function(ProjectBidMaterialReadModel attachment)
  onOpenAttachment;
  final Future<void> Function(ProjectCommunicationWorkbenchEntryView entry)
  onOpenMaterialReview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(kind.icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    kind.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              kind.summary,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            _BidSubmitMaterialReviewStatusPill(
              entry: reviewEntry,
              hasAttachments: attachments.isNotEmpty,
            ),
            const SizedBox(height: 12),
            if (attachments.isEmpty)
              Text(
                '发布方暂未上传',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              )
            else
              ...attachments.map((ProjectBidMaterialReadModel attachment) {
                final opening = openingAttachmentIds.contains(
                  attachment.attachmentId,
                );
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            attachment.fileName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _DetailLine(
                            label: '文件类型',
                            value: _projectAttachmentMimeTypeLabel(
                              attachment.mimeType,
                            ),
                          ),
                          _DetailLine(
                            label: '创建时间',
                            value: _projectAttachmentTimestampLabel(
                              attachment.createdAt,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: projectId == null || opening
                                  ? null
                                  : () => onOpenAttachment(attachment),
                              icon: opening
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.file_download_outlined),
                              label: Text(opening ? '正在打开' : '查看 / 下载'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            if (attachments.isNotEmpty) ...<Widget>[
              const SizedBox(height: 2),
              SizedBox(
                width: double.infinity,
                child: _BidSubmitMaterialReviewButton(
                  entry: reviewEntry,
                  opening: reviewEntry == null
                      ? false
                      : openingReviewEntryKeys.contains(reviewEntry!.entryKey),
                  onOpenMaterialReview: onOpenMaterialReview,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BidSubmitMaterialReviewStatusPill extends StatelessWidget {
  const _BidSubmitMaterialReviewStatusPill({
    required this.entry,
    required this.hasAttachments,
  });

  final ProjectCommunicationWorkbenchEntryView? entry;
  final bool hasAttachments;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = _style(theme);
    return Align(
      alignment: Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: style.background,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: style.border),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Text(
            _label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: style.foreground,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  String get _state => entry?.reviewState ?? entry?.availabilityState ?? '';

  String get _label {
    if (!hasAttachments) {
      return '未提交';
    }
    if (entry == null) {
      return '待同步';
    }
    return switch (_state) {
      'confirmed' => '已确认',
      'needs_supplement' => '需补充',
      'pending_review' => '待确认',
      'unsubmitted' => '未提交',
      _ => '暂不可读',
    };
  }

  _BidSubmitMaterialReviewPillStyle _style(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    if (!hasAttachments || entry == null || _state == 'unsubmitted') {
      return _BidSubmitMaterialReviewPillStyle(
        foreground: colorScheme.onSurfaceVariant,
        background: colorScheme.surfaceContainerLowest,
        border: colorScheme.outlineVariant,
      );
    }
    return switch (_state) {
      'confirmed' => const _BidSubmitMaterialReviewPillStyle(
        foreground: Color(0xFF176D38),
        background: Color(0xFFEAF7EF),
        border: Color(0xFF6FC58D),
      ),
      'needs_supplement' => _BidSubmitMaterialReviewPillStyle(
        foreground: colorScheme.error,
        background: colorScheme.errorContainer.withValues(alpha: 0.32),
        border: colorScheme.error,
      ),
      'pending_review' => const _BidSubmitMaterialReviewPillStyle(
        foreground: Color(0xFF8A5600),
        background: Color(0xFFFFF7E8),
        border: Color(0xFFE4B266),
      ),
      _ => _BidSubmitMaterialReviewPillStyle(
        foreground: colorScheme.onSurfaceVariant,
        background: colorScheme.surfaceContainerLowest,
        border: colorScheme.outlineVariant,
      ),
    };
  }
}

class _BidSubmitMaterialReviewButton extends StatelessWidget {
  const _BidSubmitMaterialReviewButton({
    required this.entry,
    required this.opening,
    required this.onOpenMaterialReview,
  });

  final ProjectCommunicationWorkbenchEntryView? entry;
  final bool opening;
  final Future<void> Function(ProjectCommunicationWorkbenchEntryView entry)
  onOpenMaterialReview;

  @override
  Widget build(BuildContext context) {
    final current = entry;
    return OutlinedButton.icon(
      onPressed: current == null || opening
          ? null
          : () => onOpenMaterialReview(current),
      icon: opening
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(_icon),
      label: Text(opening ? '正在打开' : _label),
    );
  }

  String get _state => entry?.reviewState ?? entry?.availabilityState ?? '';

  IconData get _icon {
    return switch (_state) {
      'confirmed' => Icons.check_circle_outline,
      'needs_supplement' => Icons.report_gmailerrorred_outlined,
      _ => Icons.rate_review_outlined,
    };
  }

  String get _label {
    return switch (_state) {
      'confirmed' => '查看确认',
      'needs_supplement' => '查看反馈',
      'pending_review' => '确认资料',
      _ => '确认入口暂不可用',
    };
  }
}

final class _BidSubmitMaterialReviewPillStyle {
  const _BidSubmitMaterialReviewPillStyle({
    required this.foreground,
    required this.background,
    required this.border,
  });

  final Color foreground;
  final Color background;
  final Color border;
}

ProjectCommunicationWorkbenchEntryView? _bidSubmitMaterialReviewEntryForKind(
  ProjectBidMaterialReviewProjectionReadModel? materialReview,
  String attachmentKind,
) {
  if (materialReview == null) {
    return null;
  }
  for (final entry in materialReview.entries) {
    if (entry.truthAnchor.materialKind == attachmentKind) {
      return entry;
    }
  }
  return null;
}

String? _bidSubmitPublisherMaterialReviewSubmitDisabledMessage(
  ExhibitionLoadResult? bidMaterialResult,
) {
  final result = bidMaterialResult;
  if (result == null || result.state == AppPageState.loading) {
    return '正在读取报价依据资料确认状态，请稍候。';
  }
  if (result.state != AppPageState.content) {
    return '报价依据资料暂不可读，请刷新后再提交竞标。';
  }
  final materials = _projectBidMaterialListFromPayload(result.payload);
  if (materials == null) {
    return '报价依据资料确认状态暂不可读，请刷新后再提交竞标。';
  }
  final review = materials.materialReview;
  if (review == null) {
    return '报价依据资料确认入口暂不可用，请刷新后重试。';
  }
  final blockingLabels = <String>[];
  for (final kind in _bidSubmitMaterialGridKinds) {
    final entry = _bidSubmitMaterialReviewEntryForKind(
      review,
      kind.attachmentKind,
    );
    if (entry == null) {
      blockingLabels.add(kind.title);
      continue;
    }
    if (entry.availabilityState == 'unsubmitted' &&
        entry.attachmentCount == 0) {
      continue;
    }
    if (entry.reviewState != 'confirmed') {
      blockingLabels.add(kind.title);
    }
  }
  if (blockingLabels.isEmpty) {
    return null;
  }
  return '请先确认报价依据资料：${blockingLabels.join('、')}，再提交竞标。';
}
