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

    final opened = await _openProjectPublicResourceUrl(access.accessUrl);
    if (!mounted) {
      return;
    }

    setState(() => _downloadingResourceId = null);
    widget.onMessage(opened ? '已开始下载资料。' : '下载链接已生成，但当前设备未能直接打开，请稍后重试。');
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
    final selectedOption = _projectPublicResourceCategoryOptions.firstWhere(
      (_ProjectPublicResourceCategoryOption item) =>
          item.value == _selectedCategory,
      orElse: () => _projectPublicResourceCategoryOptions.first,
    );

    return _ActionCard(
      title: widget.title,
      summary: widget.summary,
      children: <Widget>[
        const _StateMessage(
          title: '当前说明',
          body: '这里用于集中下载平台共享参考资料，帮助理解项目发布与续接规则和流程；当前不提供上传、删除或编辑，也不替代项目详情文书区。',
        ),
        const SizedBox(height: 12),
        _ProjectPublicResourceCategoryPicker(
          selectedValue: _selectedCategory,
          onChanged: (String value) {
            setState(() => _selectedCategory = value);
          },
        ),
        const SizedBox(height: 12),
        _ProjectPublicResourceCategoryHint(option: selectedOption),
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
    required this.onChanged,
  });

  final String selectedValue;
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
              label: Text(item.label),
              selected: item.value == selectedValue,
              onSelected: (_) => onChanged(item.value),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ProjectPublicResourceCategoryHint extends StatelessWidget {
  const _ProjectPublicResourceCategoryHint({required this.option});

  final _ProjectPublicResourceCategoryOption option;

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
              option.label,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(option.summary),
          ],
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
      return const _EmptyNotice(
        title: '正在读取公共资源目录',
        message: '当前正在同步平台共享参考资料；这不影响项目详情文书区。',
      );
    }

    final loadResult = result;
    if (loadResult == null) {
      return const _EmptyNotice(
        title: '当前正在准备公共资源目录',
        message: '稍后会在这里展示平台共享参考资料。',
      );
    }

    if (loadResult.state == AppPageState.empty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _EmptyNotice(
            title: '当前暂无可下载的公共资源',
            message: '这表示共享资料目录当前未承接内容，不代表项目详情文书区为空。',
          ),
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
      return const _EmptyNotice(
        title: '当前暂无可下载的公共资源',
        message: '这表示共享资料目录当前未承接内容，不代表项目详情文书区为空。',
      );
    }

    if (resources.isEmpty) {
      return const _EmptyNotice(
        title: '当前分类暂无资料',
        message: '可以切换到其他分类，继续查看可下载的共享资料。',
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
        const SizedBox(height: 8),
        Text(
          '这里和项目详情文书区分开承接，只展示平台共享的可下载资料。',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45),
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
              label: '资料分类',
              value: _projectPublicResourceCategoryLabel(
                resource.resourceCategory,
              ),
              highlight: true,
            ),
            _DetailLine(
              label: '摘要说明',
              value: resource.summary ?? '当前资料未提供摘要说明。',
            ),
            _DetailLine(label: '文件名称', value: resource.fileName),
            _DetailLine(
              label: '文件类型',
              value: _projectAttachmentMimeTypeLabel(resource.mimeType),
            ),
            _DetailLine(
              label: '可见范围',
              value: _projectPublicResourceVisibilityLabel(resource.visibility),
            ),
            _DetailLine(label: '排序序号', value: '${resource.sortOrder}'),
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
          ],
        ),
      ),
    );
  }
}
