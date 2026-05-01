part of 'enterprise_hub_workbench_pages.dart';

extension _EnterpriseWorkbenchSupplierHomepageEntries
    on _EnterpriseApplicationPageState {
  Widget _buildSupplierModuleEntry(_SupplierModuleEntryData entry) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        key: ValueKey<String>('supplier-workbench-module-${entry.title}'),
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openSupplierWorkbenchModule(entry.module),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Row(
            children: <Widget>[
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.46),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    entry.icon,
                    size: 22,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            entry.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        _SupplierCompletionBadge(complete: entry.complete),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupplierHomepagePreviewSection({
    required EnterpriseHubPublishedChangeWorkbenchData? publishedData,
  }) {
    final location = _supplierLocationSummary();
    final serviceLines = _supplierServicePreviewLines();
    final cases = _currentCases.take(3).toList(growable: false);
    return EnterpriseSectionCard(
      key: const ValueKey<String>('supplier-workbench-homepage-preview'),
      title: '公开展示预览',
      subtitle: _isPublishedChangeMode
          ? '这里只做入口摘要；线上展示与当前变更稿继续分开核对。'
          : '这里仅按当前工作台资料做摘要，不代表线上公开展示已发布。',
      actions: _isPublishedChangeMode && publishedData != null
          ? <Widget>[
              TextButton(
                onPressed: () => _openSupplierWorkbenchModule(
                  _SupplierWorkbenchModule.livePreview,
                ),
                child: const Text('线上展示'),
              ),
              TextButton(
                onPressed: () => _openSupplierWorkbenchModule(
                  _SupplierWorkbenchModule.draftPreview,
                ),
                child: const Text('变更稿'),
              ),
            ]
          : const <Widget>[],
      child: Column(
        children: <Widget>[
          _SupplierPreviewLine(
            icon: Icons.location_on_outlined,
            title: '企业位置',
            body: location,
          ),
          const SizedBox(height: 10),
          _SupplierPreviewLine(
            icon: Icons.auto_awesome_motion_outlined,
            title: '服务与优势',
            body: serviceLines.isEmpty
                ? '当前还没有可展示的服务能力摘要。'
                : serviceLines.join(' / '),
          ),
          const SizedBox(height: 10),
          _SupplierPreviewLine(
            icon: Icons.folder_special_outlined,
            title: '精选案例',
            body: cases.isEmpty
                ? '当前还没有已保存案例。'
                : cases.map((item) => item.title).join(' / '),
          ),
        ],
      ),
    );
  }
}
