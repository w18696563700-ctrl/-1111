part of 'enterprise_hub_workbench_pages.dart';

extension _EnterpriseWorkbenchCompanyModules
    on _EnterpriseApplicationPageState {
  String _companyWorkbenchPublicDetailRoute(String enterpriseId) =>
      switch (_boardType) {
        EnterpriseBoardType.factory =>
          ExhibitionRoutes.factoryDetailWithEnterpriseId(enterpriseId),
        EnterpriseBoardType.supplier =>
          ExhibitionRoutes.supplierDetailWithEnterpriseId(enterpriseId),
        EnterpriseBoardType.company =>
          ExhibitionRoutes.companyDetailWithEnterpriseId(enterpriseId),
      };

  Widget _buildCompanyQuickEntrySection() {
    final enterpriseId = _currentEnterpriseId;
    final canOpenDisplay = enterpriseId != null;
    final canOpenPublishedChange =
        enterpriseId != null &&
        (_isPublishedChangeMode ||
            _shouldRouteCaseEditingThroughPublishedChangeCorridor);
    return EnterpriseSectionCard(
      key: const ValueKey<String>('company-workbench-quick-entries'),
      title: '快捷入口',
      subtitle: '只展示当前已有真实路径的操作；无真实路由的能力本轮不展示。',
      child: Column(
        children: <Widget>[
          _CompanyQuickEntryTile(
            key: const ValueKey<String>('company-workbench-quick-public'),
            icon: Icons.storefront_outlined,
            title: _companyWorkbenchSubjectDisplayLabel(),
            description: canOpenDisplay ? '查看线上公开展示详情' : '需要先生成真实 enterpriseId',
            enabled: canOpenDisplay,
            onTap: canOpenDisplay
                ? () => Navigator.of(
                    context,
                  ).pushNamed(_companyWorkbenchPublicDetailRoute(enterpriseId))
                : null,
          ),
          const SizedBox(height: 10),
          _CompanyQuickEntryTile(
            key: const ValueKey<String>('company-workbench-quick-change'),
            icon: Icons.published_with_changes_outlined,
            title: '发布展示变更',
            description: canOpenPublishedChange
                ? '进入已发布展示的正式变更通道'
                : '仅已发布展示且存在 enterpriseId 时开放',
            enabled: canOpenPublishedChange,
            onTap: canOpenPublishedChange
                ? () => Navigator.of(context).pushNamed(
                    ExhibitionRoutes.enterprisePublishedChangeWorkbenchWithEnterpriseId(
                      enterpriseId,
                      boardType: _boardType.contractName,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 10),
          _CompanyQuickEntryTile(
            key: const ValueKey<String>('company-workbench-quick-preview'),
            icon: Icons.visibility_outlined,
            title: '预览展示',
            description: _isPublishedChangeMode
                ? '分别核对线上展示与当前变更稿'
                : '仅预览当前工作台资料摘要',
            enabled: true,
            onTap: () => _openCompanyWorkbenchModule(
              _isPublishedChangeMode
                  ? _CompanyWorkbenchModule.livePreview
                  : _CompanyWorkbenchModule.localPreview,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyCompletenessCard(
    EnterpriseHubWorkbenchReadiness readiness,
  ) {
    final percent = _companyCompletenessPercent(readiness);
    return EnterpriseSectionCard(
      key: const ValueKey<String>('company-workbench-completeness'),
      title: '信息完整度',
      subtitle: '基于当前 readiness 的展示层辅助进度，不作为业务真值。',
      actions: <Widget>[
        TextButton(
          key: const ValueKey<String>('company-workbench-completeness-action'),
          onPressed: () => _openCompanyWorkbenchModule(
            _companyFirstIncompleteModule(readiness),
          ),
          child: const Text('去完善'),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: LinearProgressIndicator(
                  value: percent / 100,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                '$percent%',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(_companyCompletenessSuggestion(readiness)),
        ],
      ),
    );
  }

  Widget _buildCompanyModuleEntrySection({
    required EnterpriseHubWorkbenchReadiness readiness,
    required bool showUpstreamTruthSection,
    required bool showCertificationSummarySection,
  }) {
    final modules = _companyModuleEntries(
      readiness: readiness,
      showUpstreamTruthSection: showUpstreamTruthSection,
      showCertificationSummarySection: showCertificationSummarySection,
    );
    final basicModules = modules
        .where(
          (entry) =>
              entry.module == _CompanyWorkbenchModule.display ||
              entry.module == _CompanyWorkbenchModule.basic ||
              entry.module == _CompanyWorkbenchModule.location ||
              entry.module == _CompanyWorkbenchModule.album,
        )
        .toList(growable: false);
    final detailModules = modules
        .where(
          (entry) =>
              entry.module == _CompanyWorkbenchModule.cases ||
              entry.module == _CompanyWorkbenchModule.contact ||
              entry.module == _CompanyWorkbenchModule.truthStatus,
        )
        .toList(growable: false);
    return EnterpriseSectionCard(
      key: const ValueKey<String>('company-workbench-module-entries'),
      title: '展示资料管理',
      subtitle: '首页只保留分组入口；完整字段继续进入模块维护。',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildCompanyModuleGroup(
            title: '基础信息',
            description: '决定公开详情的品牌识别、简介、地址和画册。',
            entries: basicModules,
          ),
          const SizedBox(height: 14),
          _buildCompanyModuleGroup(
            title: '详细信息',
            description: '管理案例、联系人、认证与发布状态。',
            entries: detailModules,
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyModuleGroup({
    required String title,
    required String description,
    required List<_CompanyModuleEntryData> entries,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 10),
        ...entries.map(_buildCompanyModuleEntry),
      ],
    );
  }

  Widget _buildCompanyModuleEntry(_CompanyModuleEntryData entry) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        key: ValueKey<String>('company-workbench-module-${entry.title}'),
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openCompanyWorkbenchModule(entry.module),
        child: _CompanyEntryFrame(
          icon: entry.icon,
          title: entry.title,
          description: entry.description,
          complete: entry.complete,
        ),
      ),
    );
  }

  Future<void> _openCompanyWorkbenchModule(
    _CompanyWorkbenchModule module,
  ) async {
    try {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext routeContext) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setRouteState) {
                _companyModuleRouteRefresh = () => setRouteState(() {});
                return Scaffold(
                  appBar: AppBar(title: Text(_companyModuleTitle(module))),
                  body: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                    children: <Widget>[_buildCompanyModuleBody(module)],
                  ),
                );
              },
            );
          },
        ),
      );
    } finally {
      _companyModuleRouteRefresh = null;
    }
  }

  Widget _buildCompanyModuleBody(_CompanyWorkbenchModule module) {
    return switch (module) {
      _CompanyWorkbenchModule.display => _buildDisplayIdentificationSection(),
      _CompanyWorkbenchModule.location => _buildMapLocationSection(),
      _CompanyWorkbenchModule.album => _buildAlbumSection(),
      _CompanyWorkbenchModule.basic => _buildBasicSection(),
      _CompanyWorkbenchModule.contact => _buildContactSection(),
      _CompanyWorkbenchModule.cases => EnterpriseWorkbenchCaseListCard(
        items: _currentCases,
        onContinueEdit: _submittingAction
            ? null
            : (caseId) => _openCaseEditorWorkbench(caseId: caseId),
        onDelete: _submittingAction ? null : _deleteCase,
        onCreateCase: _submittingAction
            ? null
            : () => _openCaseEditorWorkbench(),
      ),
      _CompanyWorkbenchModule.truthStatus => _buildCompanyTruthStatusModule(),
      _CompanyWorkbenchModule.livePreview => _buildPublishedLivePreviewSection(
        _publishedLiveDetailResult,
        AppShellScope.read(context).snapshot.shellContext,
      ),
      _CompanyWorkbenchModule.draftPreview =>
        _buildPublishedChangePreviewSection(
          _publishedWorkbenchData,
          AppShellScope.read(context).snapshot.shellContext,
        ),
      _CompanyWorkbenchModule.localPreview => _buildCompanyLocalPreviewModule(),
    };
  }
}
