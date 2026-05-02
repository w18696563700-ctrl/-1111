part of '../exhibition_trade_pages.dart';

class _BidSubmitTemplateDownloadSection extends StatefulWidget {
  const _BidSubmitTemplateDownloadSection();

  @override
  State<_BidSubmitTemplateDownloadSection> createState() =>
      _BidSubmitTemplateDownloadSectionState();
}

class _BidSubmitTemplateDownloadSectionState
    extends State<_BidSubmitTemplateDownloadSection> {
  ExhibitionLoadResult? _listResult;
  bool _loadingList = true;
  String? _downloadingResourceId;

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  Future<void> _loadResources({bool forceRefresh = false}) async {
    if (mounted) {
      setState(() => _loadingList = true);
    }
    final result = await ExhibitionConsumerLayer.instance
        .loadProjectPublicResources(forceRefresh: forceRefresh);
    if (!mounted) {
      return;
    }

    setState(() {
      _listResult = result;
      _loadingList = false;
    });
  }

  Future<void> _downloadResource(
    ProjectPublicResourceReadModel resource,
  ) async {
    if (_downloadingResourceId != null) {
      return;
    }

    setState(() => _downloadingResourceId = resource.resourceId);
    final result = await ExhibitionConsumerLayer.instance
        .requestProjectPublicResourceDownload(
          fileAssetId: resource.fileAssetId,
        );
    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      setState(() => _downloadingResourceId = null);
      _showMessage(_projectPublicResourceDownloadFailureMessage(result));
      return;
    }

    final access = _projectPublicResourceFileAccessFromPayload(result.payload);
    if (access == null) {
      setState(() => _downloadingResourceId = null);
      _showMessage('当前下载资料结果暂不可用，请稍后再试。');
      return;
    }

    final downloaded = await _downloadProjectPublicResourceFile(
      access: access,
      resource: resource,
    );
    if (!mounted) {
      return;
    }

    setState(() => _downloadingResourceId = null);
    if (downloaded == null) {
      _showMessage('资料文件暂不可下载，请稍后重试。');
      return;
    }

    _showMessage('资料已下载到 App 本地。');
    await _showProjectPublicResourceDownloadedSheet(
      context: context,
      file: downloaded,
      onMessage: _showMessage,
    );
  }

  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      return;
    }
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final loadResult = _listResult;
    final canShowGrid =
        loadResult == null ||
        loadResult.state == AppPageState.content ||
        loadResult.state == AppPageState.empty;

    return _ActionCard(
      title: '模板下载区',
      summary: '下载模板文档后可按统一格式填写，不在这里编辑共享资料。',
      children: <Widget>[
        if (_loadingList && loadResult == null)
          const _StateMessage(title: '正在读取模板目录', body: '正在同步合同模板、流程说明和公共资料。'),
        if (loadResult != null &&
            loadResult.state != AppPageState.content &&
            loadResult.state != AppPageState.empty) ...<Widget>[
          _EmptyNotice(
            title: _projectPublicResourceLoadFailureTitle(loadResult),
            message: _projectPublicResourceLoadFailureMessage(loadResult),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => _loadResources(forceRefresh: true),
            child: const Text('重新读取'),
          ),
        ],
        if (canShowGrid)
          _buildBidSubmitTemplateDownloadGrid(
            context: context,
            tiles: _bidSubmitTemplateTiles(loadResult?.payload),
            downloadingResourceId: _downloadingResourceId,
            onDownload: _downloadResource,
          ),
      ],
    );
  }
}

Widget _buildBidSubmitTemplateDownloadGrid({
  required BuildContext context,
  required List<_BidSubmitTemplateTileData> tiles,
  required String? downloadingResourceId,
  required ValueChanged<ProjectPublicResourceReadModel> onDownload,
}) {
  return LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      final cards = tiles
          .map(
            (_BidSubmitTemplateTileData tile) =>
                _buildBidSubmitTemplateDownloadCard(
                  context: context,
                  tile: tile,
                  downloading:
                      downloadingResourceId == tile.resource?.resourceId,
                  onDownload: tile.resource == null
                      ? null
                      : () => onDownload(tile.resource!),
                ),
          )
          .toList(growable: false);

      final rows = _chunkBidSubmitRows(cards, 3);
      return Column(
        children: rows
            .expand((List<Widget> row) {
              final widgets = <Widget>[
                SizedBox(
                  height: _bidSubmitTemplateCardHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      for (int index = 0; index < 3; index++) ...<Widget>[
                        Expanded(
                          child: index < row.length
                              ? row[index]
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

Widget _buildBidSubmitTemplateDownloadCard({
  required BuildContext context,
  required _BidSubmitTemplateTileData tile,
  required bool downloading,
  required VoidCallback? onDownload,
}) {
  final theme = Theme.of(context);
  final enabled = tile.resource != null && !downloading;

  return Material(
    color: theme.colorScheme.surfaceContainerLow,
    borderRadius: BorderRadius.circular(16),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      key: ValueKey<String>('bid-submit-template-download-${tile.keyId}'),
      onTap: enabled ? onDownload : null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                _bidSubmitTemplateIcon(tile.category),
                size: 22,
                color: enabled
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 6),
              Text(
                tile.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tile.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
              ),
              const Spacer(),
              Text(
                downloading
                    ? '下载中...'
                    : tile.resource == null
                    ? '暂不可用'
                    : _bidSubmitTemplateActionLabel(tile.category),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: enabled
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

List<_BidSubmitTemplateTileData> _bidSubmitTemplateTiles(Object? payload) {
  final catalog = _projectPublicResourceCatalogFromPayload(payload);
  final resources = <ProjectPublicResourceReadModel>[...?catalog?.resources]
    ..sort((
      ProjectPublicResourceReadModel left,
      ProjectPublicResourceReadModel right,
    ) {
      final orderCompare = left.sortOrder.compareTo(right.sortOrder);
      if (orderCompare != 0) {
        return orderCompare;
      }
      return left.publishedAt.compareTo(right.publishedAt);
    });

  if (resources.isNotEmpty) {
    return resources
        .map(
          (ProjectPublicResourceReadModel resource) =>
              _BidSubmitTemplateTileData(
                keyId: resource.resourceId,
                title: resource.title,
                subtitle: _projectPublicResourceCategoryLabel(
                  resource.resourceCategory,
                ),
                category: resource.resourceCategory,
                resource: resource,
              ),
        )
        .toList(growable: false);
  }

  return _projectPublicResourceCategoryOptions
      .map(
        (_ProjectPublicResourceCategoryOption option) =>
            _BidSubmitTemplateTileData(
              keyId: option.value,
              title: option.label,
              subtitle: _bidSubmitTemplatePlaceholderLine(option),
              category: option.value,
            ),
      )
      .toList(growable: false);
}

String _bidSubmitTemplatePlaceholderLine(
  _ProjectPublicResourceCategoryOption option,
) {
  return switch (option.value) {
    _projectPublicResourceCategoryContractTemplate => '待配置模板',
    _projectPublicResourceCategoryProcessGuide => '待配置说明',
    _projectPublicResourceCategoryOtherResource => '待配置资料',
    _ => '待配置',
  };
}

String _bidSubmitTemplateActionLabel(String category) {
  return switch (category) {
    _projectPublicResourceCategoryContractTemplate => '下载模板',
    _projectPublicResourceCategoryProcessGuide => '下载说明',
    _projectPublicResourceCategoryOtherResource => '下载资料',
    _ => '下载资料',
  };
}

IconData _bidSubmitTemplateIcon(String category) {
  return switch (category) {
    _projectPublicResourceCategoryContractTemplate =>
      Icons.description_outlined,
    _projectPublicResourceCategoryProcessGuide => Icons.account_tree_outlined,
    _projectPublicResourceCategoryOtherResource => Icons.folder_copy_outlined,
    _ => Icons.file_download_outlined,
  };
}

class _BidSubmitTemplateTileData {
  const _BidSubmitTemplateTileData({
    required this.keyId,
    required this.title,
    required this.subtitle,
    required this.category,
    this.resource,
  });

  final String keyId;
  final String title;
  final String subtitle;
  final String category;
  final ProjectPublicResourceReadModel? resource;
}
