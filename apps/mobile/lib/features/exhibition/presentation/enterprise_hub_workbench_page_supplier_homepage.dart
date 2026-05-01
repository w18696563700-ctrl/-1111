part of 'enterprise_hub_workbench_pages.dart';

enum _SupplierWorkbenchModule {
  core,
  contact,
  capability,
  cases,
  truth,
  submit,
  livePreview,
  draftPreview,
}

extension _EnterpriseWorkbenchSupplierHomepage
    on _EnterpriseApplicationPageState {
  Widget _buildSupplierWorkbenchHomepage({
    required EnterpriseHubLoadResult<EnterpriseHubWorkbenchData>? result,
    required EnterpriseHubWorkbenchData? data,
    required EnterpriseHubWorkbenchReadiness readiness,
    required EnterpriseHubWorkbenchApplication? latestApplication,
    required EnterpriseWorkbenchSubmitDisposition? submitDisposition,
    required EnterpriseHubLoadResult<EnterpriseHubPublishedChangeWorkbenchData>?
    publishedWorkbenchResult,
    required EnterpriseHubPublishedChangeWorkbenchData? publishedData,
    required bool showUpstreamTruthSection,
    required bool showCertificationSummarySection,
  }) {
    final publishedDisposition = _isPublishedChangeMode
        ? enterprisePublishedChangeDisposition(
            currentChangeRequest: publishedData?.currentChangeRequest,
            status: _publishedChangeStatus,
            readiness: publishedData?.changeReadiness,
          )
        : null;
    return Stack(
      children: <Widget>[
        ListView(
          key: const ValueKey<String>('supplier-workbench-homepage'),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 132),
          children: <Widget>[
            _buildSupplierIdentityCard(
              readiness: readiness,
              latestApplication: latestApplication,
              publishedData: publishedData,
            ),
            const SizedBox(height: 16),
            _buildSupplierStatusSummaryCard(
              result: result,
              publishedWorkbenchResult: publishedWorkbenchResult,
              readiness: readiness,
              latestApplication: latestApplication,
              publishedData: publishedData,
            ),
            const SizedBox(height: 16),
            _buildSupplierModuleEntrySection(
              readiness: readiness,
              showUpstreamTruthSection: showUpstreamTruthSection,
              showCertificationSummarySection: showCertificationSummarySection,
            ),
            const SizedBox(height: 16),
            _buildSupplierHomepagePreviewSection(publishedData: publishedData),
          ],
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: _buildSupplierBottomActionBar(
            data: data,
            readiness: readiness,
            latestApplication: latestApplication,
            submitDisposition: submitDisposition,
            publishedData: publishedData,
            publishedDisposition: publishedDisposition,
          ),
        ),
      ],
    );
  }

  Widget _buildSupplierIdentityCard({
    required EnterpriseHubWorkbenchReadiness readiness,
    required EnterpriseHubWorkbenchApplication? latestApplication,
    required EnterpriseHubPublishedChangeWorkbenchData? publishedData,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final name = _supplierHomepageDisplayName();
    final shortIntro =
        _normalizedText(_currentBasic?.shortIntro) ?? '当前还没有填写一句话简介。';
    final statusLabel = _supplierStatusLabel(
      readiness: readiness,
      latestApplication: latestApplication,
      publishedData: publishedData,
    );
    final tags = _supplierHomepageTags();
    return EnterpriseSectionCard(
      key: const ValueKey<String>('supplier-workbench-identity-card'),
      title: '供应商展示工作台',
      subtitle: _isPublishedChangeMode
          ? '当前维护待发布变更稿，线上展示仍以 liveSnapshot 为准。'
          : '当前只维护组织侧供应商展示资料，不作为公开展示页。',
      actions: <Widget>[
        FilledButton.tonalIcon(
          key: const ValueKey<String>('supplier-workbench-edit-core-entry'),
          onPressed: () =>
              _openSupplierWorkbenchModule(_SupplierWorkbenchModule.core),
          icon: const Icon(Icons.edit_note_rounded, size: 18),
          label: const Text('编辑资料'),
        ),
      ],
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final compact = constraints.maxWidth < 520;
          final image = _SupplierHomepageImage(
            imageUrl: _supplierHeroImageUrl(),
            fallback: name.characters.firstOrNull ?? '供',
          );
          final info = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.58),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: Text(
                    statusLabel,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags.isEmpty
                    ? <Widget>[const _SupplierHomepagePill(label: '供应商展示')]
                    : tags
                          .take(3)
                          .map((label) => _SupplierHomepagePill(label: label))
                          .toList(growable: false),
              ),
              const SizedBox(height: 10),
              Text(
                shortIntro,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
              ),
            ],
          );
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[image, const SizedBox(height: 14), info],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              image,
              const SizedBox(width: 16),
              Expanded(child: info),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSupplierStatusSummaryCard({
    required EnterpriseHubLoadResult<EnterpriseHubWorkbenchData>? result,
    required EnterpriseHubLoadResult<EnterpriseHubPublishedChangeWorkbenchData>?
    publishedWorkbenchResult,
    required EnterpriseHubWorkbenchReadiness readiness,
    required EnterpriseHubWorkbenchApplication? latestApplication,
    required EnterpriseHubPublishedChangeWorkbenchData? publishedData,
  }) {
    final state = _isPublishedChangeMode
        ? publishedWorkbenchResult?.state
        : result?.state;
    final hasContent = state == AppPageState.content;
    final blockers = _isPublishedChangeMode
        ? publishedData?.changeReadiness.blockers ?? const <String>[]
        : readiness.blockers;
    return EnterpriseSectionCard(
      key: const ValueKey<String>('supplier-workbench-status-summary'),
      title: '当前状态',
      subtitle: _supplierStatusLabel(
        readiness: readiness,
        latestApplication: latestApplication,
        publishedData: publishedData,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              EnterpriseWorkbenchReadinessPill(
                label: '基础资料',
                done: readiness.basicCompleted,
              ),
              EnterpriseWorkbenchReadinessPill(
                label: '服务能力',
                done: readiness.profileCompleted,
              ),
              EnterpriseWorkbenchReadinessPill(
                label: '案例',
                done: readiness.hasCase,
              ),
              EnterpriseWorkbenchReadinessPill(
                label: '联系人',
                done: readiness.hasContact,
              ),
              EnterpriseWorkbenchReadinessPill(
                label: '认证',
                done: readiness.certificationApproved,
              ),
              EnterpriseWorkbenchReadinessPill(
                label: _isPublishedChangeMode ? '可提交变更' : '可提交',
                done: _isPublishedChangeMode
                    ? publishedData?.changeReadiness.submitReady == true
                    : readiness.submitReady,
              ),
            ],
          ),
          if (!hasContent) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              _isPublishedChangeMode
                  ? enterprisePublishedChangeVisibleMessage(
                      state: publishedWorkbenchResult?.state,
                      errorCode: publishedWorkbenchResult?.errorCode,
                      fallbackMessage:
                          publishedWorkbenchResult?.message ?? '当前无法读取变更工作台。',
                    )
                  : _localizedWorkbenchMessage(
                      result?.message ?? '当前无法读取供应商展示工作台。',
                    ),
            ),
          ] else if (blockers.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              '还差这些：${blockers.take(2).join('、')}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSupplierModuleEntrySection({
    required EnterpriseHubWorkbenchReadiness readiness,
    required bool showUpstreamTruthSection,
    required bool showCertificationSummarySection,
  }) {
    final modules = <_SupplierModuleEntryData>[
      _SupplierModuleEntryData(
        module: _SupplierWorkbenchModule.core,
        icon: Icons.badge_outlined,
        title: '核心信息',
        description: '公司介绍、团队规模、合作方式',
        complete: readiness.basicCompleted,
      ),
      _SupplierModuleEntryData(
        module: _SupplierWorkbenchModule.contact,
        icon: Icons.call_outlined,
        title: '联系方式',
        description: '联系人、手机号、公开展示开关',
        complete: readiness.hasContact,
      ),
      _SupplierModuleEntryData(
        module: _SupplierWorkbenchModule.capability,
        icon: Icons.inventory_2_outlined,
        title: '服务能力',
        description: '供应品类、核心产品、响应与配送范围',
        complete: readiness.profileCompleted,
      ),
      _SupplierModuleEntryData(
        module: _SupplierWorkbenchModule.cases,
        icon: Icons.folder_copy_outlined,
        title: '项目案例',
        description: '已保存案例与新增案例入口',
        complete: readiness.hasCase,
      ),
      _SupplierModuleEntryData(
        module: _SupplierWorkbenchModule.truth,
        icon: Icons.verified_user_outlined,
        title: '认证与资料真值',
        description: showUpstreamTruthSection || showCertificationSummarySection
            ? '存在需要核对的上游真值或认证提示'
            : '当前无常驻阻断，仅保留核对入口',
        complete:
            readiness.certificationApproved &&
            !showUpstreamTruthSection &&
            !showCertificationSummarySection,
      ),
      _SupplierModuleEntryData(
        module: _SupplierWorkbenchModule.submit,
        icon: Icons.task_alt_outlined,
        title: '提交与状态',
        description: _isPublishedChangeMode ? '提交变更与查看变更状态' : '提交申请与查看申请状态',
        complete: _isPublishedChangeMode
            ? _publishedWorkbenchData?.changeReadiness.submitReady == true
            : readiness.submitReady,
      ),
    ];
    return EnterpriseSectionCard(
      key: const ValueKey<String>('supplier-workbench-module-entries'),
      title: '模块管理',
      subtitle: '详细编辑内容已收进模块入口，首页只保留当前状态和关键预览。',
      child: Column(
        children: modules
            .map((entry) => _buildSupplierModuleEntry(entry))
            .toList(growable: false),
      ),
    );
  }
}
