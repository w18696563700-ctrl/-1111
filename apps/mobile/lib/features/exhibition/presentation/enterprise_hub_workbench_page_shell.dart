part of 'enterprise_hub_workbench_pages.dart';

extension _EnterpriseWorkbenchPageShell on _EnterpriseApplicationPageState {
  Widget _buildWorkbenchHeaderSection() {
    final hasEnterprise = _currentEnterpriseId != null;
    return EnterpriseSectionCard(
      key: const ValueKey<String>('enterprise-workbench-header-section'),
      title: _isCaseEditorWorkbench
          ? '${_boardType.displayLabel}案例编辑工作台'
          : (_isPublishedChangeMode
                ? '${_boardType.displayLabel}变更工作台'
                : '${_boardType.displayLabel}工作台'),
      subtitle: _workbenchHeaderStatus(),
      actions: _isCaseEditorWorkbench
          ? <Widget>[
              if (_isPublishedChangeMode && _currentEnterpriseId != null)
                FilledButton.tonal(
                  onPressed: () => Navigator.of(context).pushNamed(
                    ExhibitionRoutes.enterprisePublishedChangeStatusWithEnterpriseId(
                      _currentEnterpriseId!,
                      boardType: _boardType.contractName,
                    ),
                  ),
                  child: const Text('查看变更状态'),
                ),
              FilledButton.tonal(
                onPressed: () => Navigator.of(
                  context,
                ).pushReplacementNamed(_fullWorkbenchRoute()),
                child: Text(_isPublishedChangeMode ? '返回变更工作台' : '返回企业工作台'),
              ),
            ]
          : const <Widget>[],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (_isCaseEditorWorkbench)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                Chip(label: Text(_boardType.displayLabel)),
                Chip(label: Text(_isCaseEditing ? '编辑已有案例' : '新增案例')),
              ],
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                Chip(label: Text(_boardType.displayLabel)),
                Chip(label: Text(_isPublishedChangeMode ? '正式变更通道' : '固定板块入口')),
              ],
            ),
          if (hasEnterprise && _draftStatusMessage != null) ...<Widget>[
            const SizedBox(height: 10),
            Text(
              _draftStatusMessage!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWorkbenchPage(BuildContext context) {
    final snapshot = AppShellScope.read(context).snapshot;
    final guard = _buildGuard(snapshot);
    if (guard != null) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[guard],
      );
    }
    final result = _workbenchResult;
    final data = result?.data;
    final publishedWorkbenchResult = _publishedChangeWorkbenchResult;
    final publishedData = publishedWorkbenchResult?.data;
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
    final submitDisposition = !_isPublishedChangeMode
        ? enterpriseWorkbenchSubmitDisposition(
            latestApplication: latestApplication,
            readiness: readiness,
          )
        : null;
    final hasWorkbenchContent = _isPublishedChangeMode
        ? publishedWorkbenchResult?.state == AppPageState.content
        : result?.state == AppPageState.content;
    final showUpstreamTruthSection =
        hasWorkbenchContent && _shouldShowUpstreamTruthSection();
    final showCertificationSummarySection =
        hasWorkbenchContent &&
        _shouldShowCertificationSummarySection(_currentCertification);

    if (_isCaseEditorWorkbench) {
      return _buildCaseEditorWorkbenchPage(context);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: <Widget>[
        _buildWorkbenchHeaderSection(),
        if (_isPublishedChangeMode) ...<Widget>[
          const SizedBox(height: 16),
          _buildPublishedChangeSnapshotSection(publishedData),
          const SizedBox(height: 16),
          _buildPublishedLivePreviewSection(
            _publishedLiveDetailResult,
            AppShellScope.read(context).snapshot.shellContext,
          ),
          const SizedBox(height: 16),
          _buildPublishedChangePreviewSection(
            publishedData,
            AppShellScope.read(context).snapshot.shellContext,
          ),
        ],
        const SizedBox(height: 16),
        _buildDisplayIdentificationSection(),
        const SizedBox(height: 16),
        _buildAlbumSection(),
        const SizedBox(height: 16),
        _buildMapLocationSection(),
        const SizedBox(height: 16),
        _buildBasicSection(),
        const SizedBox(height: 16),
        _buildContactSection(),
        const SizedBox(height: 16),
        EnterpriseWorkbenchCaseListCard(
          items: _currentCases,
          onContinueEdit: _submittingAction
              ? null
              : (caseId) => _openCaseEditorWorkbench(caseId: caseId),
          onDelete: _submittingAction ? null : _deleteCase,
          onCreateCase: _submittingAction
              ? null
              : () => _openCaseEditorWorkbench(),
        ),
        if (showUpstreamTruthSection) ...<Widget>[
          const SizedBox(height: 16),
          _buildUpstreamTruthSection(),
        ],
        if (showCertificationSummarySection) ...<Widget>[
          const SizedBox(height: 16),
          _buildCertificationSummarySection(_currentCertification),
        ],
        const SizedBox(height: 16),
        _isPublishedChangeMode
            ? _buildPublishedChangeSubmitSection(
                publishedData,
                _publishedChangeStatus,
              )
            : EnterpriseSectionCard(
                key: const ValueKey<String>(
                  'enterprise-workbench-submit-section',
                ),
                title: '提交申请',
                subtitle: submitDisposition!.subtitle,
                actions: <Widget>[
                  if (submitDisposition.showViewApplicationStatusAction &&
                      latestApplication != null)
                    (submitDisposition.viewApplicationStatusPrimary
                        ? FilledButton(
                            key: const ValueKey<String>(
                              'enterprise-workbench-view-application-status',
                            ),
                            onPressed: () => Navigator.of(context).pushNamed(
                              ExhibitionRoutes.enterpriseApplicationStatusWithId(
                                latestApplication.applicationId,
                                boardType: _boardType.contractName,
                              ),
                            ),
                            child: const Text('查看申请状态'),
                          )
                        : FilledButton.tonal(
                            key: const ValueKey<String>(
                              'enterprise-workbench-view-application-status',
                            ),
                            onPressed: () => Navigator.of(context).pushNamed(
                              ExhibitionRoutes.enterpriseApplicationStatusWithId(
                                latestApplication.applicationId,
                                boardType: _boardType.contractName,
                              ),
                            ),
                            child: const Text('查看申请状态'),
                          )),
                  if (submitDisposition.showRecreateDraftAction)
                    FilledButton(
                      key: const ValueKey<String>(
                        'enterprise-workbench-recreate-application-draft',
                      ),
                      onPressed: _submittingAction
                          ? null
                          : _recreateApplicationDraft,
                      child: const Text('重新创建申请草稿'),
                    ),
                  if (submitDisposition.showSubmitAction)
                    FilledButton(
                      key: const ValueKey<String>(
                        'enterprise-workbench-submit-application',
                      ),
                      onPressed: readiness.submitReady && !_submittingAction
                          ? _submitPrimaryAction
                          : null,
                      child: const Text('提交入驻申请'),
                    ),
                  if (data?.enterpriseId != null)
                    TextButton(
                      onPressed: _submittingAction
                          ? null
                          : _deleteCurrentEnterprise,
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
              ),
      ],
    );
  }

  Widget _buildCaseEditorWorkbenchPage(BuildContext context) {
    final result = _isPublishedChangeMode
        ? _publishedChangeWorkbenchResult
        : _workbenchResult;
    if (result == null || _loading) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: <Widget>[
          _buildWorkbenchHeaderSection(),
          const SizedBox(height: 16),
          const EnterpriseSectionCard(
            title: '案例编辑器',
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ],
      );
    }
    if ((_isPublishedChangeMode &&
            _publishedChangeWorkbenchResult?.state != AppPageState.content) ||
        (!_isPublishedChangeMode &&
            _workbenchResult?.state != AppPageState.content)) {
      final message = _isPublishedChangeMode
          ? enterprisePublishedChangeVisibleMessage(
              state: _publishedChangeWorkbenchResult?.state,
              errorCode: _publishedChangeWorkbenchResult?.errorCode,
              fallbackMessage: _publishedChangeWorkbenchResult?.message,
            )
          : _localizedWorkbenchMessage(
              _workbenchResult?.message ?? '当前无法读取案例编辑工作台。',
            );
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: <Widget>[
          _buildWorkbenchHeaderSection(),
          const SizedBox(height: 16),
          EnterpriseSectionCard(title: '案例编辑器', child: Text(message)),
        ],
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: <Widget>[
        _buildWorkbenchHeaderSection(),
        const SizedBox(height: 16),
        _buildCaseComposerSection(),
      ],
    );
  }
}
