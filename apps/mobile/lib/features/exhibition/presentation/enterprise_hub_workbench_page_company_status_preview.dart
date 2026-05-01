part of 'enterprise_hub_workbench_pages.dart';

extension _EnterpriseWorkbenchCompanyStatusPreview
    on _EnterpriseApplicationPageState {
  Widget _buildCompanyFeaturedCasesSection() {
    final cases = _currentCases.take(3).toList(growable: false);
    final caseRows = <Widget>[];
    for (var index = 0; index < cases.length; index += 1) {
      final item = cases[index];
      caseRows.add(
        _CompanyPreviewLine(
          icon: Icons.folder_special_outlined,
          title: item.title,
          body: _normalizedText(item.summary) ?? '暂无案例摘要',
        ),
      );
      if (index != cases.length - 1) {
        caseRows.add(const SizedBox(height: 10));
      }
    }
    return EnterpriseSectionCard(
      key: const ValueKey<String>('company-workbench-featured-cases'),
      title: '精选案例',
      subtitle: '首页最多展示 3 个现有案例；完整管理继续进入案例模块。',
      actions: <Widget>[
        TextButton(
          onPressed: () =>
              _openCompanyWorkbenchModule(_CompanyWorkbenchModule.cases),
          child: const Text('查看/编辑'),
        ),
      ],
      child: cases.isEmpty ? const Text('暂无案例') : Column(children: caseRows),
    );
  }

  Widget _buildCompanyPrimaryContactSection() {
    final contact = _companyPrimaryContact();
    final contactName = _normalizedText(contact?.contactName);
    final contactMobile = _normalizedText(contact?.mobile);
    return EnterpriseSectionCard(
      key: const ValueKey<String>('company-workbench-primary-contact'),
      title: '联系人',
      subtitle: '首页只展示主要联系人；完整维护继续进入联系人模块。',
      actions: <Widget>[
        TextButton(
          onPressed: () =>
              _openCompanyWorkbenchModule(_CompanyWorkbenchModule.contact),
          child: const Text('管理联系人'),
        ),
      ],
      child: contactName == null && contactMobile == null
          ? const Text('暂无联系人')
          : _CompanyPreviewLine(
              icon: Icons.call_outlined,
              title: contactName ?? '未填写姓名',
              body: contactMobile ?? '未填写手机号',
            ),
    );
  }

  Widget _buildFactoryHighlightSection() {
    final highlights = _factoryHighlightLines();
    final rows = <Widget>[];
    for (var index = 0; index < highlights.length; index += 1) {
      final item = highlights[index];
      rows.add(
        _CompanyPreviewLine(
          icon: item.icon,
          title: item.title,
          body: item.body,
        ),
      );
      if (index != highlights.length - 1) {
        rows.add(const SizedBox(height: 10));
      }
    }
    return EnterpriseSectionCard(
      key: const ValueKey<String>('factory-workbench-highlights'),
      title: '工厂亮点',
      subtitle: '只基于当前已保存工厂资料生成展示摘要，不写回业务真值。',
      actions: <Widget>[
        TextButton(
          onPressed: () =>
              _openCompanyWorkbenchModule(_CompanyWorkbenchModule.display),
          child: const Text('去完善'),
        ),
      ],
      child: rows.isEmpty ? const Text('暂无可展示亮点') : Column(children: rows),
    );
  }

  Widget _buildCompanyNextStepSection(
    EnterpriseHubWorkbenchReadiness readiness,
  ) {
    return EnterpriseSectionCard(
      key: const ValueKey<String>('company-workbench-next-step'),
      title: '下一步建议',
      subtitle: '基于当前 readiness 的展示层建议，不作为业务真值。',
      actions: <Widget>[
        TextButton(
          onPressed: () => _openCompanyWorkbenchModule(
            _companyFirstIncompleteModule(readiness),
          ),
          child: const Text('去处理'),
        ),
      ],
      child: Text(_companyCompletenessSuggestion(readiness)),
    );
  }

  Widget _buildCompanyPreviewSection({
    required EnterpriseHubPublishedChangeWorkbenchData? publishedData,
  }) {
    final serviceLines = _companyServicePreviewLines();
    final cases = _currentCases.take(3).toList(growable: false);
    return EnterpriseSectionCard(
      key: const ValueKey<String>('company-workbench-preview-summary'),
      title: '公开展示摘要',
      subtitle: _isPublishedChangeMode
          ? '这里只做入口摘要；线上展示与当前变更稿继续分开核对。'
          : '这里只按当前工作台资料做摘要，不代表线上公开展示已发布。',
      actions: _isPublishedChangeMode && publishedData != null
          ? <Widget>[
              TextButton(
                key: const ValueKey<String>(
                  'company-workbench-preview-live-entry',
                ),
                onPressed: () => _openCompanyWorkbenchModule(
                  _CompanyWorkbenchModule.livePreview,
                ),
                child: const Text('线上展示'),
              ),
              TextButton(
                key: const ValueKey<String>(
                  'company-workbench-preview-draft-entry',
                ),
                onPressed: () => _openCompanyWorkbenchModule(
                  _CompanyWorkbenchModule.draftPreview,
                ),
                child: const Text('变更稿'),
              ),
            ]
          : const <Widget>[],
      child: Column(
        children: <Widget>[
          _CompanyPreviewLine(
            icon: Icons.location_on_outlined,
            title: '地址与服务区域',
            body: _companyLocationSummary(),
          ),
          const SizedBox(height: 10),
          _CompanyPreviewLine(
            icon: Icons.design_services_outlined,
            title: _boardType == EnterpriseBoardType.factory
                ? '工艺与设备能力'
                : '服务与展示能力',
            body: serviceLines.isEmpty
                ? '当前还没有可展示的服务能力摘要。'
                : serviceLines.join(' / '),
          ),
          const SizedBox(height: 10),
          _CompanyPreviewLine(
            icon: Icons.folder_special_outlined,
            title: '案例展示',
            body: cases.isEmpty
                ? '当前还没有已保存案例。'
                : cases.map((item) => item.title).join(' / '),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyBottomActionBar({
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
        key: const ValueKey<String>('company-workbench-bottom-status'),
        onPressed: () =>
            _openCompanyWorkbenchModule(_CompanyWorkbenchModule.truthStatus),
        icon: const Icon(Icons.fact_check_outlined, size: 18),
        label: const Text('认证与状态'),
      ),
    ];
    if (_isPublishedChangeMode) {
      final enterpriseId = _currentEnterpriseId;
      if (enterpriseId != null &&
          publishedDisposition?.showViewStatusAction == true) {
        actions.add(
          OutlinedButton(
            key: const ValueKey<String>(
              'company-workbench-bottom-view-change-status',
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
              'company-workbench-bottom-submit-change',
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
              'company-workbench-bottom-view-application-status',
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
              'company-workbench-bottom-recreate-draft',
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
              'company-workbench-bottom-submit-application',
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

  Widget _buildCompanyTruthStatusModule() {
    final children = <Widget>[];
    if (_isPublishedChangeMode) {
      children.add(
        _buildPublishedChangeSnapshotSection(_publishedWorkbenchData),
      );
    }
    if (_shouldShowUpstreamTruthSection()) {
      children.add(_buildUpstreamTruthSection());
    }
    if (_shouldShowCertificationSummarySection(_currentCertification)) {
      children.add(_buildCertificationSummarySection(_currentCertification));
    }
    children.add(
      _isPublishedChangeMode
          ? _buildPublishedChangeSubmitSection(
              _publishedWorkbenchData,
              _publishedChangeStatus,
            )
          : _buildCompanySubmitModuleBody(),
    );
    final separated = <Widget>[];
    for (var index = 0; index < children.length; index += 1) {
      separated.add(children[index]);
      if (index != children.length - 1) {
        separated.add(const SizedBox(height: 16));
      }
    }
    return Column(children: separated);
  }

  Widget _buildCompanySubmitModuleBody() {
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
      key: const ValueKey<String>('company-workbench-submit-module'),
      title: '提交申请',
      subtitle: submitDisposition.subtitle,
      actions: <Widget>[
        if (submitDisposition.showViewApplicationStatusAction &&
            latestApplication != null)
          FilledButton.tonal(
            key: const ValueKey<String>(
              'company-workbench-view-application-status',
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
              'company-workbench-recreate-application-draft',
            ),
            onPressed: _submittingAction ? null : _recreateApplicationDraft,
            child: const Text('重新创建申请草稿'),
          ),
        if (submitDisposition.showSubmitAction)
          FilledButton(
            key: const ValueKey<String>('company-workbench-submit-application'),
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

  Widget _buildCompanyLocalPreviewModule() {
    return EnterpriseSectionCard(
      key: const ValueKey<String>('company-workbench-local-preview-module'),
      title: '当前资料预览',
      subtitle: '这里仅展示工作台资料摘要，不代表线上公开展示已发布。',
      child: Column(
        children: <Widget>[
          _CompanyPreviewLine(
            icon: Icons.business_rounded,
            title: '${_companyWorkbenchSubjectLabel()}名称',
            body: _companyHomepageDisplayName(),
          ),
          const SizedBox(height: 10),
          _CompanyPreviewLine(
            icon: Icons.location_on_outlined,
            title: '地址与服务区域',
            body: _companyLocationSummary(),
          ),
          const SizedBox(height: 10),
          _CompanyPreviewLine(
            icon: Icons.design_services_outlined,
            title: _boardType == EnterpriseBoardType.factory
                ? '工艺与设备能力'
                : '服务与展示能力',
            body: _companyServicePreviewLines().isEmpty
                ? '当前还没有可展示的服务能力摘要。'
                : _companyServicePreviewLines().join(' / '),
          ),
        ],
      ),
    );
  }
}
