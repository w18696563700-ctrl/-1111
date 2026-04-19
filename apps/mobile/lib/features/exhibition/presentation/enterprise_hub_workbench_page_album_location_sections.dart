part of 'enterprise_hub_workbench_pages.dart';

extension _EnterpriseWorkbenchPageAlbumLocationSections
    on _EnterpriseApplicationPageState {
  Widget _buildAlbumSection() {
    final useFactoryShowcase = _boardType == EnterpriseBoardType.factory;
    final items = useFactoryShowcase
        ? _factoryShowcaseItems
        : _albumShowcaseItems;
    final albumCount = items.length;
    return EnterpriseSectionCard(
      key: const ValueKey<String>('enterprise-workbench-album-section'),
      title: '企业画册',
      actions: <Widget>[
        FilledButton.tonal(
          key: const ValueKey<String>('enterprise-workbench-confirm-album'),
          onPressed: _submittingAction || albumCount == 0
              ? null
              : _saveAlbumSection,
          child: const Text('确认上传'),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (albumCount == 0)
            _buildAlbumEmptyState(useFactoryShowcase: useFactoryShowcase)
          else
            SizedBox(
              height: 188,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: albumCount,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return SizedBox(
                    width: 240,
                    child: _buildAlbumTile(
                      item: item,
                      onRemove: item.stage == _WorkbenchImageStage.uploading
                          ? null
                          : () => useFactoryShowcase
                                ? _removeFactoryShowcaseImage(item.localId)
                                : _removeAlbumImage(item.localId),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 12),
          if (albumCount < _workbenchImageLimit)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                key: const ValueKey<String>('enterprise-workbench-add-album'),
                onPressed: _submittingAction
                    ? null
                    : (useFactoryShowcase
                          ? _addFactoryShowcaseImage
                          : _addAlbumShowcaseImage),
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('添加图片'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMapLocationSection() {
    return EnterpriseSectionCard(
      key: const ValueKey<String>('enterprise-workbench-map-location-section'),
      title: '地图 / 位置',
      subtitle: _isPublishedChangeMode
          ? '当前只用真实位置真值，不伪装成完整高德地图预览；保存后只进入 current change carrier。'
          : '当前只用真实位置真值，不伪装成完整高德地图预览，不把未接通的地图能力写成已接通。',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            key: const ValueKey<String>('enterprise-workbench-address-field'),
            controller: _addressController,
            maxLines: 2,
            onChanged: _handleAddressTextChanged,
            decoration: const InputDecoration(
              labelText: '位置补充说明（选填）',
              border: OutlineInputBorder(),
              helperText: '如需修正公开展示位置，可补充园区、楼栋或门牌信息。',
            ),
          ),
          const SizedBox(height: 8),
          _buildAddressAssistSection(),
          if (_locationStatusMessage != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              _locationStatusMessage!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 12),
          if (_resolvedLocationDraft != null)
            _buildLocationTruthPreview(_resolvedLocationDraft!)
          else
            const _SectionNotice(
              title: '地图预览',
              lines: <String>['当前没有可展示的地图预览。', '这里只承接位置真值，不伪装成 Amap 预览卡。'],
              tone: _SectionNoticeTone.neutral,
            ),
        ],
      ),
    );
  }

  Widget _buildSingleImageField({
    required String title,
    required _WorkbenchImageItem? item,
    required String emptyLabel,
    required Future<void> Function() onPick,
    required VoidCallback onClear,
  }) {
    final isLogo = title.contains('Logo');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        if (item == null)
          _WorkbenchEmptyUploadState(
            message: emptyLabel,
            actionLabel: '上传$title',
            onAction: onPick,
          )
        else
          _WorkbenchImageTile(
            item: item,
            imageFit: isLogo ? BoxFit.contain : BoxFit.cover,
            imageHeight: isLogo ? 84 : 96,
            showMetadata: !isLogo,
            onReplace: onPick,
            onRemove: item.stage == _WorkbenchImageStage.uploading
                ? null
                : onClear,
          ),
      ],
    );
  }

  Widget _buildImageCollectionField({
    required String title,
    required String subtitle,
    required List<_WorkbenchImageItem> items,
    required Future<void> Function() onAdd,
    required ValueChanged<String> onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            ...items.map(
              (item) => SizedBox(
                width: 152,
                child: _WorkbenchImageTile(
                  item: item,
                  onReplace: null,
                  onRemove: item.stage == _WorkbenchImageStage.uploading
                      ? null
                      : () => onRemove(item.localId),
                ),
              ),
            ),
            if (items.length < _workbenchImageLimit)
              SizedBox(
                width: 152,
                child: _WorkbenchEmptyUploadState(
                  message: '还可以继续添加 ${_workbenchImageLimit - items.length} 张。',
                  actionLabel: '添加图片',
                  onAction: onAdd,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildAlbumTile({
    required _WorkbenchImageItem item,
    required VoidCallback? onRemove,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final teamSize = _teamSizeDisplayLabel(
      _selectedTeamSizeRange ?? _currentBasic?.teamSizeRange,
    );
    final cooperationModes = _cooperationModeDisplayLabels(
      _selectedCooperationModes.isNotEmpty
          ? _selectedCooperationModes.toList(growable: false)
          : _currentBasic?.cooperationModes ?? const <String>[],
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: item.bytes != null
                  ? Image.memory(item.bytes!, fit: BoxFit.cover)
                  : item.imageUrl?.trim().isNotEmpty == true
                  ? Image.network(
                      item.imageUrl!.trim(),
                      fit: BoxFit.cover,
                      errorBuilder:
                          (
                            BuildContext context,
                            Object error,
                            StackTrace? stackTrace,
                          ) => ColoredBox(
                            color: colorScheme.surfaceContainerHighest,
                            child: const Center(
                              child: Icon(Icons.photo_library_outlined, size: 36),
                            ),
                          ),
                    )
                  : ColoredBox(
                      color: colorScheme.surfaceContainerHighest,
                      child: const Center(
                        child: Icon(Icons.photo_library_outlined, size: 36),
                      ),
                    ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.72),
                    ],
                    stops: const <double>[0, 0.58, 1],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    '团队规模：${teamSize ?? '暂未补充'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '合作方式：${cooperationModes.isEmpty ? '暂未补充' : cooperationModes.join(' / ')}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.92),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            if (onRemove != null)
              Positioned(
                top: 8,
                right: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.48),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: IconButton(
                    iconSize: 18,
                    visualDensity: VisualDensity.compact,
                    color: Colors.white,
                    onPressed: onRemove,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumEmptyState({required bool useFactoryShowcase}) {
    final colorScheme = Theme.of(context).colorScheme;
    final title = useFactoryShowcase ? '当前还没有可回显的工厂实景图。' : '当前还没有可回显的画册图片。';
    final body = useFactoryShowcase
        ? '可以先添加工厂实景图，确认上传后再写入当前工厂展示资料。'
        : '可以先添加图片，确认上传后再写入企业画册真值。';
    return Container(
      width: double.infinity,
      height: 172,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
        color: colorScheme.surfaceContainerLowest,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(Icons.photo_album_outlined, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(body, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  String? _teamSizeDisplayLabel(String? value) {
    final normalized = _normalizedText(value);
    if (normalized == null) {
      return null;
    }
    for (final option in enterpriseWorkbenchTeamSizeOptions) {
      if (option.key == normalized) {
        return option.value;
      }
    }
    return normalized;
  }

  List<String> _cooperationModeDisplayLabels(List<String> values) {
    final labels = <String>[];
    for (final value in values) {
      final normalized = _normalizedText(value);
      if (normalized == null) {
        continue;
      }
      String? matched;
      for (final option in enterpriseWorkbenchCooperationModeOptions) {
        if (option.key == normalized) {
          matched = option.value;
          break;
        }
      }
      labels.add(matched ?? normalized);
    }
    return labels;
  }
}
