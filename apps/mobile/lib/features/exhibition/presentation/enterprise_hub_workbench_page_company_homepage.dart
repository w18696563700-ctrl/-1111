part of 'enterprise_hub_workbench_pages.dart';

enum _CompanyWorkbenchModule {
  display,
  location,
  album,
  basic,
  contact,
  cases,
  truthStatus,
  livePreview,
  draftPreview,
  localPreview,
}

extension _EnterpriseWorkbenchCompanyHomepage
    on _EnterpriseApplicationPageState {
  Widget _buildCompanyWorkbenchHomepage({
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
    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            key: ValueKey<String>(
              _boardType == EnterpriseBoardType.factory
                  ? 'factory-workbench-homepage'
                  : 'company-workbench-homepage',
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (_boardType == EnterpriseBoardType.company) ...<Widget>[
                  _buildCompanyCompletenessCard(readiness),
                  const SizedBox(height: 16),
                  _buildCompanyIdentityCard(
                    readiness: readiness,
                    latestApplication: latestApplication,
                    publishedData: publishedData,
                  ),
                  const SizedBox(height: 16),
                  _buildCompanyPreviewSection(publishedData: publishedData),
                  const SizedBox(height: 16),
                  _buildCompanyQuickEntrySection(),
                  const SizedBox(height: 16),
                  _buildCompanyModuleEntrySection(
                    readiness: readiness,
                    showUpstreamTruthSection: showUpstreamTruthSection,
                    showCertificationSummarySection:
                        showCertificationSummarySection,
                  ),
                  const SizedBox(height: 16),
                  _buildCompanyStatusCard(
                    result: result,
                    publishedWorkbenchResult: publishedWorkbenchResult,
                    readiness: readiness,
                    latestApplication: latestApplication,
                    publishedData: publishedData,
                  ),
                ] else ...<Widget>[
                  _buildCompanyIdentityCard(
                    readiness: readiness,
                    latestApplication: latestApplication,
                    publishedData: publishedData,
                  ),
                  const SizedBox(height: 16),
                  _buildCompanyStatusCard(
                    result: result,
                    publishedWorkbenchResult: publishedWorkbenchResult,
                    readiness: readiness,
                    latestApplication: latestApplication,
                    publishedData: publishedData,
                  ),
                  const SizedBox(height: 16),
                  _buildCompanyQuickEntrySection(),
                  const SizedBox(height: 16),
                  _buildCompanyCompletenessCard(readiness),
                  const SizedBox(height: 16),
                  _buildCompanyModuleEntrySection(
                    readiness: readiness,
                    showUpstreamTruthSection: showUpstreamTruthSection,
                    showCertificationSummarySection:
                        showCertificationSummarySection,
                  ),
                  if (_boardType == EnterpriseBoardType.factory) ...<Widget>[
                    const SizedBox(height: 16),
                    _buildCompanyActivityEmptySection(),
                    const SizedBox(height: 16),
                    _buildCompanyAnalyticsEmptySection(),
                  ],
                  const SizedBox(height: 16),
                  _buildCompanyFeaturedCasesSection(),
                  const SizedBox(height: 16),
                  _buildCompanyPrimaryContactSection(),
                  if (_boardType == EnterpriseBoardType.factory) ...<Widget>[
                    const SizedBox(height: 16),
                    _buildFactoryHighlightSection(),
                  ],
                  const SizedBox(height: 16),
                  _buildCompanyNextStepSection(readiness),
                  const SizedBox(height: 16),
                  _buildCompanyPreviewSection(publishedData: publishedData),
                ],
              ],
            ),
          ),
        ),
        _buildCompanyBottomActionBar(
          data: data,
          readiness: readiness,
          latestApplication: latestApplication,
          submitDisposition: submitDisposition,
          publishedData: publishedData,
          publishedDisposition: publishedDisposition,
        ),
      ],
    );
  }

  Widget _buildCompanyIdentityCard({
    required EnterpriseHubWorkbenchReadiness readiness,
    required EnterpriseHubWorkbenchApplication? latestApplication,
    required EnterpriseHubPublishedChangeWorkbenchData? publishedData,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final name = _companyHomepageDisplayName();
    final shortIntro =
        _normalizedText(_shortIntroController.text) ??
        _normalizedText(_currentBasic?.shortIntro) ??
        '当前还没有填写一句话简介。';
    final statusLabel = _companyStatusLabel(
      readiness: readiness,
      latestApplication: latestApplication,
      publishedData: publishedData,
    );
    final tags = _companyHomepageTags();
    return EnterpriseSectionCard(
      key: const ValueKey<String>('company-workbench-identity-card'),
      title: _boardType == EnterpriseBoardType.company
          ? '公司展示预览'
          : '${_companyWorkbenchSubjectDisplayLabel()}工作台',
      subtitle: _isPublishedChangeMode
          ? '当前展示待发布变更稿效果；线上公开展示仍以 liveSnapshot 为准。'
          : _boardType == EnterpriseBoardType.company
          ? '当前只展示工作台资料预览，不代表线上公司详情已发布。'
          : '当前只维护组织侧${_companyWorkbenchSubjectDisplayLabel()}资料，不作为线上公开详情页。',
      actions: <Widget>[
        FilledButton.tonalIcon(
          key: const ValueKey<String>('company-workbench-edit-core-entry'),
          onPressed: () =>
              _openCompanyWorkbenchModule(_CompanyWorkbenchModule.display),
          icon: const Icon(Icons.edit_note_rounded, size: 18),
          label: const Text('编辑资料'),
        ),
      ],
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final compact = constraints.maxWidth < 520;
          final image = _CompanyHomepageImage(
            imageUrl: _companyHeroImageUrl(),
            fallback:
                name.characters.firstOrNull ?? _companyWorkbenchSubjectLabel(),
          );
          final info = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _CompanyStatusBadge(label: statusLabel),
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
                    ? <Widget>[
                        _CompanyHomepagePill(
                          label: _companyWorkbenchSubjectDisplayLabel(),
                        ),
                      ]
                    : tags
                          .take(3)
                          .map((label) => _CompanyHomepagePill(label: label))
                          .toList(growable: false),
              ),
              const SizedBox(height: 10),
              Text(
                shortIntro,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
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

  Widget _buildCompanyActivityEmptySection() {
    return const EnterpriseSectionCard(
      key: ValueKey<String>('factory-workbench-activity-empty'),
      title: '最新动态',
      subtitle: '当前工厂工作台没有独立动态流，本轮只展示真实空态。',
      child: Text('暂无动态'),
    );
  }

  Widget _buildCompanyAnalyticsEmptySection() {
    return const EnterpriseSectionCard(
      key: ValueKey<String>('factory-workbench-analytics-empty'),
      title: '数据看板',
      subtitle: '当前工厂工作台没有曝光、访客、询盘、收藏等真实指标。',
      child: Text('暂无数据'),
    );
  }

  Widget _buildCompanyStatusCard({
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
      key: const ValueKey<String>('company-workbench-status-card'),
      title: '${_companyWorkbenchSubjectDisplayLabel()}状态',
      subtitle: _companyStatusLabel(
        readiness: readiness,
        latestApplication: latestApplication,
        publishedData: publishedData,
      ),
      actions: <Widget>[
        TextButton(
          key: const ValueKey<String>('company-workbench-status-entry'),
          onPressed: () =>
              _openCompanyWorkbenchModule(_CompanyWorkbenchModule.truthStatus),
          child: const Text('查看详情'),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _companyReadinessItems(readiness)
                .map(
                  (item) => EnterpriseWorkbenchReadinessPill(
                    label: item.label,
                    done: item.done,
                  ),
                )
                .toList(growable: false),
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
                      result?.message ??
                          '当前无法读取${_companyWorkbenchSubjectDisplayLabel()}工作台。',
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
}
