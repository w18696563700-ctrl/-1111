part of 'enterprise_hub_workbench_pages.dart';

extension _EnterpriseWorkbenchPageLoad on _EnterpriseApplicationPageState {
  Future<void> _loadWorkbench() async {
    _updateWorkbenchState(() => _loading = true);
    final shellContext = AppShellScope.read(context).snapshot.shellContext;
    if (_isPublishedChangeMode) {
      await _loadPublishedChangeWorkbench();
      return;
    }
    final genericPublishedChangeEnterpriseId =
        _genericPublishedChangeBootstrapEnterpriseId();
    if (genericPublishedChangeEnterpriseId != null) {
      final consumedPublishedChange = await _loadPublishedChangeWorkbench(
        enterpriseId: genericPublishedChangeEnterpriseId,
        allowGenericFallback: true,
      );
      if (consumedPublishedChange) {
        return;
      }
    }
    try {
      final results = await Future.wait<Object>(<Future<Object>>[
        EnterpriseHubWorkbenchConsumerLayer.instance.loadWorkbench(
          boardType: _boardType,
        ),
        ProfileIdentityConsumerLayer.instance.loadMyOrganizations(),
        ProfileIdentityConsumerLayer.instance.loadCertificationCurrent(),
      ]);
      if (!mounted) return;
      final organizationsResult =
          results[1] as ProfileIdentityResult<MyOrganizationsView>;
      final certificationResult =
          results[2] as ProfileIdentityResult<ProfileCertificationCurrentView>;
      final regionCatalog = await _loadRegionCatalogOrFallback();
      final workbenchResult =
          results[0] as EnterpriseHubLoadResult<EnterpriseHubWorkbenchData>;
      final workbenchData = workbenchResult.data;
      if (workbenchData != null) {
        _hydrateFromWorkbench(workbenchData);
        _hydrateRouteCaseComposerFromItems(workbenchData.cases);
      } else {
        _resetWorkbenchForm();
      }
      _syncOrganizationTruth(
        organizations: organizationsResult.data,
        shellContext: shellContext,
        basic: workbenchData?.basic,
        regionCatalog: regionCatalog,
      );
      _certificationSummary = _certificationSummaryFromProfile(
        certificationResult.data,
      );
      _updateWorkbenchState(() {
        _workbenchResult = workbenchResult;
        _publishedChangeWorkbenchResult = null;
        _publishedChangeStatusResult = null;
        _publishedLiveDetailResult = null;
        _regionCatalog = regionCatalog;
        _certificationLegalNameTruth ??= _normalizedText(
          workbenchData?.certification?.legalName,
        );
        _loading = false;
      });
      await _hydrateRouteCaseComposerFromCanonicalSource();
      await _hydrateCertificationTruth(
        certification: certificationResult.data,
        basic: workbenchData?.basic,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      _updateWorkbenchState(() {
        _loading = false;
        _workbenchResult = EnterpriseHubLoadResult<EnterpriseHubWorkbenchData>(
          state: AppPageState.errorNonRetryable,
          method: 'GET',
          path: EnterpriseHubBoardCanonicalFamily.forBoard(
            _boardType,
          ).workbench,
          message: '$error',
        );
      });
    }
  }

  Future<bool> _loadPublishedChangeWorkbench({
    String? enterpriseId,
    bool allowGenericFallback = false,
  }) async {
    final normalizedEnterpriseId = _normalizedText(
      enterpriseId ?? _publishedEnterpriseId,
    );
    try {
      final results = await Future.wait<Object>(<Future<Object>>[
        EnterpriseHubPublishedChangeConsumerLayer.instance
            .loadCurrentChangeWorkbench(
              boardType: _boardType,
              enterpriseId: normalizedEnterpriseId ?? '',
            ),
        EnterpriseHubPublishedChangeConsumerLayer.instance
            .loadCurrentChangeStatus(
              boardType: _boardType,
              enterpriseId: normalizedEnterpriseId ?? '',
            ),
        EnterpriseHubConsumerLayer.instance.loadEnterpriseDetail(
          enterpriseId: normalizedEnterpriseId ?? '',
          boardType: _boardType,
        ),
      ]);
      if (!mounted) {
        return true;
      }
      final publishedChangeWorkbenchResult =
          results[0]
              as EnterpriseHubLoadResult<
                EnterpriseHubPublishedChangeWorkbenchData
              >;
      final publishedChangeStatusResult =
          results[1]
              as EnterpriseHubLoadResult<
                EnterpriseHubPublishedChangeStatusData
              >;
      final publishedLiveDetailResult =
          results[2] as EnterpriseHubLoadResult<EnterpriseHubDetailData>;
      final publishedWorkbenchData = publishedChangeWorkbenchResult.data;
      if (allowGenericFallback &&
          publishedWorkbenchData == null &&
          _normalizedText(publishedChangeWorkbenchResult.errorCode) ==
              'ENTERPRISE_HUB_CHANGE_CORRIDOR_NOT_AVAILABLE') {
        return false;
      }
      if (publishedWorkbenchData != null) {
        _hydrateFromPublishedChangeWorkbench(publishedWorkbenchData);
        _hydrateRouteCaseComposerFromItems(publishedWorkbenchData.cases);
      } else {
        _resetWorkbenchForm();
      }
      _updateWorkbenchState(() {
        _pageMode = _EnterpriseWorkbenchPageMode.publishedChange;
        _publishedEnterpriseId = normalizedEnterpriseId;
        _workbenchResult = null;
        _publishedChangeWorkbenchResult = publishedChangeWorkbenchResult;
        _publishedChangeStatusResult = publishedChangeStatusResult;
        _publishedLiveDetailResult = publishedLiveDetailResult;
        _loading = false;
      });
      await _hydrateRouteCaseComposerFromCanonicalSource();
      await _hydratePublishedChangeSupportingTruth(
        basic: publishedWorkbenchData?.basic,
      );
      return true;
    } catch (error) {
      if (!mounted) {
        return true;
      }
      _updateWorkbenchState(() {
        _pageMode = _EnterpriseWorkbenchPageMode.publishedChange;
        _publishedEnterpriseId = normalizedEnterpriseId;
        _workbenchResult = null;
        _loading = false;
        _publishedChangeWorkbenchResult =
            EnterpriseHubLoadResult<EnterpriseHubPublishedChangeWorkbenchData>(
              state: AppPageState.errorNonRetryable,
              method: 'GET',
              path:
                  EnterpriseHubPublishedChangeCanonicalPaths.workbenchWithEnterpriseId(
                    _boardType,
                    normalizedEnterpriseId ?? '{enterpriseId}',
                  ),
              message: '$error',
            );
        _publishedLiveDetailResult = null;
      });
      return true;
    }
  }

  Future<void> _hydratePublishedChangeSupportingTruth({
    required EnterpriseHubWorkbenchBasic? basic,
  }) async {
    final shellContext = AppShellScope.read(context).snapshot.shellContext;
    try {
      final results = await Future.wait<Object>(<Future<Object>>[
        ProfileIdentityConsumerLayer.instance.loadMyOrganizations(),
        ProfileIdentityConsumerLayer.instance.loadCertificationCurrent(),
      ]);
      if (!mounted) {
        return;
      }
      final organizationsResult =
          results[0] as ProfileIdentityResult<MyOrganizationsView>;
      final certificationResult =
          results[1] as ProfileIdentityResult<ProfileCertificationCurrentView>;
      final regionCatalog = await _loadRegionCatalogOrFallback();
      _syncOrganizationTruth(
        organizations: organizationsResult.data,
        shellContext: shellContext,
        basic: basic,
        regionCatalog: regionCatalog,
      );
      final certificationSummary = _certificationSummaryFromProfile(
        certificationResult.data,
      );
      _updateWorkbenchState(() {
        _regionCatalog = regionCatalog;
        _certificationSummary = certificationSummary;
        _certificationLegalNameTruth ??= _normalizedText(
          basic?.name ?? certificationResult.data?.legalName,
        );
      });
      await _hydrateCertificationTruth(
        certification: certificationResult.data,
        basic: basic,
      );
    } catch (_) {
      // Keep the published-change workbench usable even when supporting truth
      // hydration cannot be completed in this frame.
    }
  }

  Future<ChinaRegionCatalog> _loadRegionCatalogOrFallback() async {
    try {
      return await ChinaRegionCatalogLoader.load();
    } catch (error) {
      if (mounted) {
        _showWorkbenchMessage(_localizedWorkbenchMessage('$error'));
      }
      return ChinaRegionCatalog(provinces: const <ChinaProvinceOption>[]);
    }
  }

  String? _genericPublishedChangeBootstrapEnterpriseId() {
    if (_isPublishedChangeMode) {
      return null;
    }
    final routeEnterpriseId = _routeEnterpriseId;
    if (routeEnterpriseId == null) {
      return null;
    }
    if (_isCaseEditorWorkbench && _routeCaseSeedHydrated) {
      return null;
    }
    return routeEnterpriseId;
  }

  Future<void> _hydrateRouteCaseComposerFromCanonicalSource() async {
    if (!_isCaseEditorWorkbench) {
      return;
    }
    final routeCaseId = _routeCaseId;
    if (routeCaseId == null) {
      return;
    }
    await _continueEditCase(routeCaseId);
  }
}
