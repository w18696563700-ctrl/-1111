part of 'enterprise_hub_workbench_pages.dart';

extension _EnterpriseWorkbenchSupplierModules
    on _EnterpriseApplicationPageState {
  Widget _buildSupplierBottomActionBar({
    required EnterpriseHubWorkbenchData? data,
    required EnterpriseHubWorkbenchReadiness readiness,
    required EnterpriseHubWorkbenchApplication? latestApplication,
    required EnterpriseWorkbenchSubmitDisposition? submitDisposition,
    required EnterpriseHubPublishedChangeWorkbenchData? publishedData,
    required EnterprisePublishedChangeDisposition? publishedDisposition,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final actions = <Widget>[
      OutlinedButton.icon(
        key: const ValueKey<String>('supplier-workbench-bottom-status'),
        onPressed: () =>
            _openSupplierWorkbenchModule(_SupplierWorkbenchModule.submit),
        icon: const Icon(Icons.fact_check_outlined, size: 18),
        label: const Text('提交与状态'),
      ),
    ];
    if (_isPublishedChangeMode) {
      final enterpriseId = _currentEnterpriseId;
      if (enterpriseId != null &&
          publishedDisposition?.showViewStatusAction == true) {
        actions.add(
          OutlinedButton(
            key: const ValueKey<String>(
              'supplier-workbench-bottom-view-change-status',
            ),
            onPressed: _submittingAction
                ? null
                : () => Navigator.of(context).pushNamed(
                    ExhibitionRoutes.enterprisePublishedChangeStatusWithEnterpriseId(
                      enterpriseId,
                      boardType: _boardType.contractName,
                    ),
                  ),
            child: const Text('查看变更状态'),
          ),
        );
      }
      if (publishedDisposition?.showSubmitAction == true) {
        actions.add(
          FilledButton(
            key: const ValueKey<String>(
              'supplier-workbench-bottom-submit-change',
            ),
            onPressed:
                publishedData?.changeReadiness.submitReady == true &&
                    !_submittingAction
                ? _submitPrimaryAction
                : null,
            child: const Text('提交变更'),
          ),
        );
      }
    } else {
      if (submitDisposition?.showViewApplicationStatusAction == true &&
          latestApplication != null) {
        actions.add(
          OutlinedButton(
            key: const ValueKey<String>(
              'supplier-workbench-bottom-view-application-status',
            ),
            onPressed: _submittingAction
                ? null
                : () => Navigator.of(context).pushNamed(
                    ExhibitionRoutes.enterpriseApplicationStatusWithId(
                      latestApplication.applicationId,
                      boardType: _boardType.contractName,
                    ),
                  ),
            child: const Text('查看申请状态'),
          ),
        );
      }
      if (submitDisposition?.showRecreateDraftAction == true) {
        actions.add(
          FilledButton(
            key: const ValueKey<String>(
              'supplier-workbench-bottom-recreate-draft',
            ),
            onPressed: _submittingAction ? null : _recreateApplicationDraft,
            child: const Text('重新创建草稿'),
          ),
        );
      }
      if (submitDisposition?.showSubmitAction == true) {
        actions.add(
          FilledButton(
            key: const ValueKey<String>(
              'supplier-workbench-bottom-submit-application',
            ),
            onPressed: readiness.submitReady && !_submittingAction
                ? _submitPrimaryAction
                : null,
            child: const Text('提交入驻申请'),
          ),
        );
      }
    }
    return Material(
      elevation: 12,
      color: colorScheme.surface,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: actions
                .map(
                  (action) => Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: action,
                  ),
                )
                .toList(growable: false),
          ),
        ),
      ),
    );
  }

  Future<void> _openSupplierWorkbenchModule(
    _SupplierWorkbenchModule module,
  ) async {
    try {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext routeContext) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setRouteState) {
                _supplierModuleRouteRefresh = () => setRouteState(() {});
                return Scaffold(
                  appBar: AppBar(title: Text(_supplierModuleTitle(module))),
                  body: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                    children: <Widget>[_buildSupplierModuleBody(module)],
                  ),
                );
              },
            );
          },
        ),
      );
    } finally {
      _supplierModuleRouteRefresh = null;
    }
  }

  Widget _buildSupplierModuleBody(_SupplierWorkbenchModule module) {
    return switch (module) {
      _SupplierWorkbenchModule.core => _buildBasicSection(),
      _SupplierWorkbenchModule.contact => _buildContactSection(),
      _SupplierWorkbenchModule.capability =>
        _buildDisplayIdentificationSection(),
      _SupplierWorkbenchModule.cases => EnterpriseWorkbenchCaseListCard(
        items: _currentCases,
        onContinueEdit: _submittingAction
            ? null
            : (caseId) => _openCaseEditorWorkbench(caseId: caseId),
        onDelete: _submittingAction ? null : _deleteCase,
        onCreateCase: _submittingAction
            ? null
            : () => _openCaseEditorWorkbench(),
      ),
      _SupplierWorkbenchModule.truth => _buildSupplierTruthModuleBody(),
      _SupplierWorkbenchModule.submit => _buildSupplierSubmitModuleBody(),
      _SupplierWorkbenchModule.livePreview => _buildPublishedLivePreviewSection(
        _publishedLiveDetailResult,
        AppShellScope.read(context).snapshot.shellContext,
      ),
      _SupplierWorkbenchModule.draftPreview =>
        _buildPublishedChangePreviewSection(
          _publishedWorkbenchData,
          AppShellScope.read(context).snapshot.shellContext,
        ),
    };
  }

  Widget _buildSupplierTruthModuleBody() {
    final children = <Widget>[];
    if (_shouldShowUpstreamTruthSection()) {
      children.add(_buildUpstreamTruthSection());
    }
    if (_shouldShowCertificationSummarySection(_currentCertification)) {
      children.add(_buildCertificationSummarySection(_currentCertification));
    }
    if (children.isEmpty) {
      return const EnterpriseSectionCard(
        title: '认证与资料真值',
        subtitle: '当前不常驻展示上游真值卡，只在缺失或异常时提示。',
        child: Text('当前没有需要额外处理的上游真值或认证提示。'),
      );
    }
    return Column(
      children:
          children
              .expand((child) => <Widget>[child, const SizedBox(height: 16)])
              .toList(growable: false)
            ..removeLast(),
    );
  }

  Widget _buildSupplierSubmitModuleBody() {
    if (_isPublishedChangeMode) {
      return _buildPublishedChangeSubmitSection(
        _publishedWorkbenchData,
        _publishedChangeStatus,
      );
    }
    final result = _workbenchResult;
    final data = result?.data;
    final readiness =
        data?.readiness ??
        const EnterpriseHubWorkbenchReadiness(
          hasApplication: false,
          draftEditable: false,
          basicCompleted: false,
          profileCompleted: false,
          hasCase: false,
          hasContact: false,
          certificationApproved: false,
          submitReady: false,
          blockers: <String>[],
        );
    final latestApplication = data?.latestApplication;
    final submitDisposition = enterpriseWorkbenchSubmitDisposition(
      latestApplication: latestApplication,
      readiness: readiness,
    );
    return EnterpriseSectionCard(
      key: const ValueKey<String>('supplier-workbench-submit-module'),
      title: '提交申请',
      subtitle: submitDisposition.subtitle,
      actions: <Widget>[
        if (submitDisposition.showViewApplicationStatusAction &&
            latestApplication != null)
          FilledButton.tonal(
            key: const ValueKey<String>(
              'supplier-workbench-view-application-status',
            ),
            onPressed: _submittingAction
                ? null
                : () => Navigator.of(context).pushNamed(
                    ExhibitionRoutes.enterpriseApplicationStatusWithId(
                      latestApplication.applicationId,
                      boardType: _boardType.contractName,
                    ),
                  ),
            child: const Text('查看申请状态'),
          ),
        if (submitDisposition.showRecreateDraftAction)
          FilledButton(
            key: const ValueKey<String>(
              'supplier-workbench-recreate-application-draft',
            ),
            onPressed: _submittingAction ? null : _recreateApplicationDraft,
            child: const Text('重新创建申请草稿'),
          ),
        if (submitDisposition.showSubmitAction)
          FilledButton(
            key: const ValueKey<String>(
              'supplier-workbench-submit-application',
            ),
            onPressed: readiness.submitReady && !_submittingAction
                ? _submitPrimaryAction
                : null,
            child: const Text('提交入驻申请'),
          ),
        if (data?.enterpriseId != null)
          TextButton(
            onPressed: _submittingAction ? null : _deleteCurrentEnterprise,
            child: const Text('删除当前板块展示'),
          ),
      ],
      child: result == null || _loading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            )
          : _buildLoadState(result, readiness),
    );
  }

  String _supplierModuleTitle(_SupplierWorkbenchModule module) =>
      switch (module) {
        _SupplierWorkbenchModule.core => '核心信息',
        _SupplierWorkbenchModule.contact => '联系方式',
        _SupplierWorkbenchModule.capability => '服务能力',
        _SupplierWorkbenchModule.cases => '项目案例',
        _SupplierWorkbenchModule.truth => '认证与资料真值',
        _SupplierWorkbenchModule.submit => '提交与状态',
        _SupplierWorkbenchModule.livePreview => '线上公开展示',
        _SupplierWorkbenchModule.draftPreview => '当前变更稿预览',
      };
}
