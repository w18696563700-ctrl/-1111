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
  String? _downloadingCategory;

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

  Future<void> _downloadCategory(String category) async {
    if (_downloadingCategory != null) {
      return;
    }

    final resourcesByCategory = _bidSubmitPrimaryPublicResources(
      _listResult?.payload,
    );
    final resource = resourcesByCategory[category];
    if (resource == null) {
      _showMessage('当前分类暂无可下载资料，请稍后再试。');
      return;
    }

    setState(() => _downloadingCategory = category);
    final result = await ExhibitionConsumerLayer.instance
        .requestProjectPublicResourceDownload(
          fileAssetId: resource.fileAssetId,
        );
    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      setState(() => _downloadingCategory = null);
      _showMessage(_projectPublicResourceDownloadFailureMessage(result));
      return;
    }

    final access = _projectPublicResourceFileAccessFromPayload(result.payload);
    if (access == null) {
      setState(() => _downloadingCategory = null);
      _showMessage('当前下载资料结果暂不可用，请稍后再试。');
      return;
    }

    final opened = await _openProjectPublicResourceUrl(access.accessUrl);
    if (!mounted) {
      return;
    }

    setState(() => _downloadingCategory = null);
    _showMessage(opened ? '已开始下载资料。' : '下载链接已生成，但当前设备未能直接打开，请稍后重试。');
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
            resourcesByCategory: _bidSubmitPrimaryPublicResources(
              loadResult?.payload,
            ),
            downloadingCategory: _downloadingCategory,
            onDownload: _downloadCategory,
          ),
      ],
    );
  }
}

Widget _buildBidSubmitTemplateDownloadGrid({
  required BuildContext context,
  required Map<String, ProjectPublicResourceReadModel> resourcesByCategory,
  required String? downloadingCategory,
  required ValueChanged<String> onDownload,
}) {
  return LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      final useWideLayout =
          constraints.maxWidth >= _bidSubmitAttachmentWideLayoutBreakpoint;
      final cards = _projectPublicResourceCategoryOptions
          .map(
            (_ProjectPublicResourceCategoryOption option) =>
                _buildBidSubmitTemplateDownloadCard(
                  context: context,
                  option: option,
                  resource: resourcesByCategory[option.value],
                  downloading: downloadingCategory == option.value,
                  onDownload: () => onDownload(option.value),
                ),
          )
          .toList(growable: false);

      if (!useWideLayout) {
        return Column(
          children: cards
              .expand(
                (Widget card) => <Widget>[
                  card,
                  if (!identical(card, cards.last))
                    const SizedBox(height: _bidSubmitAttachmentGridSpacing),
                ],
              )
              .toList(growable: false),
        );
      }

      final rows = _chunkBidSubmitRows(cards, 3);
      return Column(
        children: rows
            .expand((List<Widget> row) {
              final widgets = <Widget>[
                IntrinsicHeight(
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
  required _ProjectPublicResourceCategoryOption option,
  required ProjectPublicResourceReadModel? resource,
  required bool downloading,
  required VoidCallback onDownload,
}) {
  final theme = Theme.of(context);

  return DecoratedBox(
    key: ValueKey<String>('bid-submit-template-card-${option.value}'),
    decoration: BoxDecoration(
      color: theme.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: theme.colorScheme.outlineVariant),
    ),
    child: SizedBox(
      height: _bidSubmitTemplateCardHeight,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              option.label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  _bidSubmitTemplateResourceLine(option, resource),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                key: ValueKey<String>(
                  'bid-submit-template-download-${option.value}',
                ),
                onPressed: resource == null || downloading ? null : onDownload,
                child: Text(
                  downloading
                      ? '下载中...'
                      : resource == null
                      ? '暂不可用'
                      : _bidSubmitTemplateActionLabel(option.value),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Map<String, ProjectPublicResourceReadModel> _bidSubmitPrimaryPublicResources(
  Object? payload,
) {
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
  final primaryByCategory = <String, ProjectPublicResourceReadModel>{};
  for (final resource in resources) {
    primaryByCategory.putIfAbsent(resource.resourceCategory, () => resource);
  }
  return primaryByCategory;
}

String _bidSubmitTemplateResourceLine(
  _ProjectPublicResourceCategoryOption option,
  ProjectPublicResourceReadModel? resource,
) {
  if (resource != null) {
    return resource.title;
  }

  return switch (option.value) {
    _projectPublicResourceCategoryContractTemplate => '下载共享合同模板，按统一格式填写。',
    _projectPublicResourceCategoryProcessGuide => '下载流程说明，核对提交与衔接口径。',
    _projectPublicResourceCategoryOtherResource => '下载共享资料，补充编制时的参考。',
    _ => '当前分类暂未提供资料。',
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
