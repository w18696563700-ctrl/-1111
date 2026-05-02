part of '../exhibition_trade_pages.dart';

class _ProjectPublicResourceSection extends StatefulWidget {
  const _ProjectPublicResourceSection({
    super.key,
    required this.title,
    required this.summary,
    required this.onMessage,
  });

  final String title;
  final String summary;
  final ValueChanged<String> onMessage;

  @override
  State<_ProjectPublicResourceSection> createState() =>
      _ProjectPublicResourceSectionState();
}

class _ProjectPublicResourceSectionState
    extends State<_ProjectPublicResourceSection> {
  String _selectedCategory = _projectPublicResourceCategoryContractTemplate;
  ExhibitionLoadResult? _listResult;
  bool _loadingList = false;
  String? _downloadingResourceId;

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  Future<void> _loadResources({bool forceRefresh = false}) async {
    setState(() => _loadingList = true);
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
      widget.onMessage(_projectPublicResourceDownloadFailureMessage(result));
      return;
    }

    final access = _projectPublicResourceFileAccessFromPayload(result.payload);
    if (access == null) {
      setState(() => _downloadingResourceId = null);
      widget.onMessage('当前下载资料结果暂不可用，请稍后再试。');
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
      widget.onMessage('资料文件暂不可下载，请稍后重试。');
      return;
    }

    widget.onMessage('资料已下载到 App 本地。');
    await _showProjectPublicResourceDownloadedSheet(
      context: context,
      file: downloaded,
      onMessage: widget.onMessage,
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalog = _projectPublicResourceCatalogFromPayload(
      _listResult?.payload,
    );
    final allResources =
        catalog?.resources ?? const <ProjectPublicResourceReadModel>[];
    final filteredResources = allResources
        .where(
          (ProjectPublicResourceReadModel item) =>
              item.resourceCategory == _selectedCategory,
        )
        .toList(growable: false);
    final categoryCounts = _projectPublicResourceCategoryCounts(allResources);
    final selectedOption = _projectPublicResourceCategoryOptions.firstWhere(
      (_ProjectPublicResourceCategoryOption item) =>
          item.value == _selectedCategory,
      orElse: () => _projectPublicResourceCategoryOptions.first,
    );

    return _ActionCard(
      title: widget.title,
      summary: widget.summary,
      children: <Widget>[
        _ProjectPublicResourceCategoryPicker(
          selectedValue: _selectedCategory,
          categoryCounts: categoryCounts,
          onChanged: (String value) {
            setState(() => _selectedCategory = value);
          },
        ),
        _ProjectPublicResourceCategoryMarker(option: selectedOption),
        const SizedBox(height: 16),
        _ProjectPublicResourceListPanel(
          loading: _loadingList,
          result: _listResult,
          resources: filteredResources,
          hasAnyResource: allResources.isNotEmpty,
          downloadingResourceId: _downloadingResourceId,
          onRetry: () => _loadResources(forceRefresh: true),
          onDownload: _downloadResource,
        ),
      ],
    );
  }
}

class _ProjectPublicResourceCategoryPicker extends StatelessWidget {
  const _ProjectPublicResourceCategoryPicker({
    required this.selectedValue,
    required this.categoryCounts,
    required this.onChanged,
  });

  final String selectedValue;
  final Map<String, int> categoryCounts;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '资料分类',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _projectPublicResourceCategoryOptions.map((
            _ProjectPublicResourceCategoryOption item,
          ) {
            return ChoiceChip(
              label: Text('${item.label} · ${categoryCounts[item.value] ?? 0}'),
              selected: item.value == selectedValue,
              onSelected: (_) => onChanged(item.value),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ProjectPublicResourceCategoryMarker extends StatelessWidget {
  const _ProjectPublicResourceCategoryMarker({required this.option});

  final _ProjectPublicResourceCategoryOption option;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        '当前分类：${option.label}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ProjectPublicResourceListPanel extends StatelessWidget {
  const _ProjectPublicResourceListPanel({
    required this.loading,
    required this.result,
    required this.resources,
    required this.hasAnyResource,
    required this.downloadingResourceId,
    required this.onRetry,
    required this.onDownload,
  });

  final bool loading;
  final ExhibitionLoadResult? result;
  final List<ProjectPublicResourceReadModel> resources;
  final bool hasAnyResource;
  final String? downloadingResourceId;
  final VoidCallback onRetry;
  final ValueChanged<ProjectPublicResourceReadModel> onDownload;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const _EmptyNotice(title: '正在读取公共资源目录', message: '正在同步平台共享资料。');
    }

    final loadResult = result;
    if (loadResult == null) {
      return const _EmptyNotice(title: '当前正在准备公共资源目录', message: '稍后会展示可下载资料。');
    }

    if (loadResult.state == AppPageState.empty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _EmptyNotice(title: '当前暂无可下载的公共资源', message: '暂无可下载公共资源。'),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('重新读取')),
        ],
      );
    }

    if (loadResult.state != AppPageState.content) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _EmptyNotice(
            title: _projectPublicResourceLoadFailureTitle(loadResult),
            message: _projectPublicResourceLoadFailureMessage(loadResult),
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('重新读取')),
        ],
      );
    }

    if (!hasAnyResource) {
      return const _EmptyNotice(title: '当前暂无可下载的公共资源', message: '暂无可下载公共资源。');
    }

    if (resources.isEmpty) {
      return const _EmptyNotice(
        title: '当前暂无该类资料',
        message: '可以切换到其他分类，继续查看平台共享资料。',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '共享资料列表',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        ...resources.asMap().entries.map((
          MapEntry<int, ProjectPublicResourceReadModel> entry,
        ) {
          final item = entry.value;
          final isLast = entry.key == resources.length - 1;
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
            child: _ProjectPublicResourceRecordCard(
              resource: item,
              downloading: downloadingResourceId == item.resourceId,
              onDownload: () => onDownload(item),
            ),
          );
        }),
      ],
    );
  }
}

class _ProjectPublicResourceRecordCard extends StatelessWidget {
  const _ProjectPublicResourceRecordCard({
    required this.resource,
    required this.downloading,
    required this.onDownload,
  });

  final ProjectPublicResourceReadModel resource;
  final bool downloading;
  final VoidCallback onDownload;

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
              resource.title,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            _DetailLine(
              label: '文件类型',
              value: _projectAttachmentMimeTypeLabel(resource.mimeType),
              highlight: true,
            ),
            const _DetailLine(label: '文件大小', value: '下载后确认'),
            _DetailLine(
              label: '发布时间',
              value: _projectAttachmentTimestampLabel(resource.publishedAt),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: downloading ? null : onDownload,
                icon: downloading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download_rounded),
                label: Text(downloading ? '下载中...' : '下载资料'),
              ),
            ),
            const SizedBox(height: 6),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              title: Text(
                '更多信息',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              children: <Widget>[
                _DetailLine(
                  label: '资料分类',
                  value: _projectPublicResourceCategoryLabel(
                    resource.resourceCategory,
                  ),
                ),
                _DetailLine(
                  label: '摘要说明',
                  value: resource.summary ?? '当前资料未提供摘要说明。',
                ),
                _DetailLine(label: '文件名称', value: resource.fileName),
                _DetailLine(
                  label: '可见范围',
                  value: _projectPublicResourceVisibilityLabel(
                    resource.visibility,
                  ),
                ),
                _DetailLine(label: '排序序号', value: '${resource.sortOrder}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
