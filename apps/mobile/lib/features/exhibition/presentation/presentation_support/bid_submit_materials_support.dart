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
    return '当前云端 BFF 尚未部署竞标材料读侧路由，请先同步云端后再试。';
  }

  return switch (result.state) {
    AppPageState.unauthorized => '当前登录状态不可继续查看项目附件，请重新登录后再试。',
    AppPageState.forbidden => '当前账号暂不可读取竞标材料。',
    AppPageState.notFound => '当前项目附件暂不可用，请稍后再试。',
    _ =>
      rawMessage == 'current fake transport did not provide this canonical path'
          ? '当前项目附件读侧暂未接通。'
          : result.message ?? '当前项目附件暂不可用，请稍后再试。',
  };
}

Widget _buildBidSubmitMaterialSection({
  required ExhibitionLoadResult? bidMaterialResult,
  required Set<String> openingAttachmentIds,
  required Future<void> Function(ProjectBidMaterialReadModel attachment)
  onPreview,
  required VoidCallback onRetry,
}) {
  final result = bidMaterialResult;
  if (result == null || result.state == AppPageState.loading) {
    return const _ActionCard(
      title: '项目附件',
      summary: '这里只读展示当前项目对竞标开放的效果图与施工图，不提供上传或删除动作。',
      tone: _ActionCardTone.emphasis,
      children: <Widget>[
        _StateMessage(title: '正在读取项目附件', body: '正在同步当前项目的效果图与施工图。'),
      ],
    );
  }

  if (result.state != AppPageState.content &&
      result.state != AppPageState.empty) {
    return _ActionCard(
      title: '项目附件',
      summary: '这里只读展示当前项目对竞标开放的效果图与施工图，不提供上传或删除动作。',
      tone: _ActionCardTone.emphasis,
      children: <Widget>[
        _StateMessage(
          title: '项目附件暂不可读',
          body: _projectBidMaterialFailureMessage(result),
        ),
        const SizedBox(height: 12),
        FilledButton.tonal(onPressed: onRetry, child: const Text('重新读取项目附件')),
      ],
    );
  }

  final materials = _projectBidMaterialListFromPayload(result.payload);
  if (materials == null || materials.attachments.isEmpty) {
    return const _ActionCard(
      title: '项目附件',
      summary: '这里只读展示当前项目对竞标开放的效果图与施工图，不提供上传或删除动作。',
      tone: _ActionCardTone.emphasis,
      children: <Widget>[
        _EmptyNotice(
          title: '当前项目还没有开放附件',
          message: '当前项目暂未提供效果图或施工图，可先继续填写报价与上传竞标必选文档。',
        ),
      ],
    );
  }

  return _ActionCard(
    title: '项目附件',
    summary: '这里只读展示当前项目对竞标开放的效果图与施工图，不提供上传或删除动作。',
    tone: _ActionCardTone.emphasis,
    children: <Widget>[
      ...materials.attachments.asMap().entries.map((
        MapEntry<int, ProjectBidMaterialReadModel> entry,
      ) {
        final attachment = entry.value;
        final isLast = entry.key == materials.attachments.length - 1;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
          child: _BidSubmitMaterialCard(
            attachment: attachment,
            previewing: openingAttachmentIds.contains(attachment.attachmentId),
            onPreview: () => onPreview(attachment),
          ),
        );
      }),
    ],
  );
}

class _BidSubmitMaterialCard extends StatelessWidget {
  const _BidSubmitMaterialCard({
    required this.attachment,
    required this.previewing,
    required this.onPreview,
  });

  final ProjectBidMaterialReadModel attachment;
  final bool previewing;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              attachment.fileName,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            _DetailLine(
              label: '资料类型',
              value: _projectAttachmentKindLabel(attachment.attachmentKind),
              highlight: true,
            ),
            _DetailLine(
              label: '文件类型',
              value: _projectAttachmentMimeTypeLabel(attachment.mimeType),
            ),
            _DetailLine(label: '排序序号', value: '${attachment.sortOrder}'),
            _DetailLine(
              label: '创建时间',
              value: _projectAttachmentTimestampLabel(attachment.createdAt),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: previewing ? null : onPreview,
              icon: previewing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.visibility_outlined),
              label: Text(
                previewing
                    ? '处理中'
                    : _projectAttachmentRecordPreviewButtonLabel(
                        attachment.mimeType,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showBidMaterialRemoteImagePreviewDialog(
  BuildContext context, {
  required String fileName,
  required ProjectPublicResourceFileAccessReadModel access,
}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      final theme = Theme.of(dialogContext);
      return Dialog(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560, maxHeight: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '图片预览',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: InteractiveViewer(
                        child: Image.network(
                          access.accessUrl,
                          fit: BoxFit.contain,
                          loadingBuilder:
                              (
                                BuildContext context,
                                Widget child,
                                ImageChunkEvent? loadingProgress,
                              ) {
                                if (loadingProgress == null) {
                                  return child;
                                }
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                          errorBuilder:
                              (
                                BuildContext context,
                                Object error,
                                StackTrace? stackTrace,
                              ) {
                                return Center(
                                  child: Text(
                                    '当前图片暂时无法预览，请稍后再试',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                );
                              },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('关闭'),
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
