part of 'enterprise_hub_workbench_pages.dart';

extension _EnterpriseWorkbenchPageCaseActions
    on _EnterpriseApplicationPageState {
  bool get _publishedChangeCaseEditingAllowed =>
      _publishedWorkbenchData?.changeReadiness.draftEditable == true;

  String _publishedChangeCaseEditingLockedMessage() {
    final status =
        _publishedChangeStatus?.changeStatus ??
        _publishedWorkbenchData?.currentChangeRequest?.changeStatus;
    return '当前变更处于${enterprisePublishedChangeStatusLabel(status)}，请先查看变更状态。';
  }

  void _hydrateCaseComposerFromWorkbenchCaseItem(
    EnterpriseHubWorkbenchCaseItem currentItem,
  ) {
    _editingCaseId = currentItem.caseId;
    _caseTitleController.text = currentItem.title;
    _caseExhibitionTypeController.text = currentItem.exhibitionType ?? '';
    _caseCityController.text = currentItem.city ?? '';
    _caseEventTimeController.text =
        _normalizeDateStorageValue(currentItem.eventTime) ?? '';
    _caseSummaryController.text = currentItem.summary;
    _caseComposerImages = _mergeWorkbenchImageCollection(
      current: _caseComposerImages,
      nextFileAssetIds: _caseComposerImageIds(
        currentItem.caseCoverFileAssetId,
        currentItem.caseMediaFileAssetIds,
      ),
      nextImageUrlMap: currentItem.caseImageUrlMap,
      fallbackPrefix: '案例图片',
    );
    _caseFeatured = currentItem.isFeatured;
  }

  EnterpriseHubWorkbenchCaseItem? _findCurrentCaseItem(String caseId) {
    for (final item in _currentCases) {
      if (_normalizedText(item.caseId) == caseId) {
        return item;
      }
    }
    return null;
  }

  Future<void> _enterPublishedChangeCaseEditing({
    required String enterpriseId,
    required String caseId,
  }) async {
    _updateWorkbenchState(() => _loading = true);
    try {
      final results = await Future.wait<Object>(<Future<Object>>[
        EnterpriseHubPublishedChangeConsumerLayer.instance
            .loadCurrentChangeWorkbench(
              boardType: _boardType,
              enterpriseId: enterpriseId,
            ),
        EnterpriseHubPublishedChangeConsumerLayer.instance
            .loadCurrentChangeStatus(
              boardType: _boardType,
              enterpriseId: enterpriseId,
            ),
      ]);
      if (!mounted) {
        return;
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
      final publishedWorkbenchData = publishedChangeWorkbenchResult.data;
      if (publishedChangeWorkbenchResult.state != AppPageState.content ||
          publishedWorkbenchData == null) {
        _updateWorkbenchState(() => _loading = false);
        _showWorkbenchMessage(
          enterprisePublishedChangeVisibleMessage(
            state: publishedChangeWorkbenchResult.state,
            errorCode: publishedChangeWorkbenchResult.errorCode,
            fallbackMessage: publishedChangeWorkbenchResult.message,
          ),
        );
        return;
      }
      EnterpriseHubWorkbenchCaseItem? item;
      for (final current in publishedWorkbenchData.cases) {
        if (_normalizedText(current.caseId) == caseId) {
          item = current;
          break;
        }
      }
      if (item == null) {
        _updateWorkbenchState(() => _loading = false);
        _showWorkbenchMessage('当前案例不存在或已不可访问。');
        return;
      }
      _hydrateFromPublishedChangeWorkbench(publishedWorkbenchData);
      _hydrateCaseComposerFromWorkbenchCaseItem(item);
      _updateWorkbenchState(() {
        _pageMode = _EnterpriseWorkbenchPageMode.publishedChange;
        _publishedEnterpriseId = enterpriseId;
        _workbenchResult = null;
        _publishedChangeWorkbenchResult = publishedChangeWorkbenchResult;
        _publishedChangeStatusResult = publishedChangeStatusResult;
        _loading = false;
      });
      unawaited(
        _hydratePublishedChangeSupportingTruth(
          basic: publishedWorkbenchData.basic,
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      _updateWorkbenchState(() => _loading = false);
      _showWorkbenchMessage(
        enterprisePublishedChangeVisibleMessage(fallbackMessage: '$error'),
      );
      return;
    }
  }

  Future<void> _createCase() async {
    if (_isPublishedChangeMode && !_publishedChangeCaseEditingAllowed) {
      _showWorkbenchMessage(_publishedChangeCaseEditingLockedMessage());
      return;
    }
    final enterpriseId = await _ensureEnterpriseId();
    if (enterpriseId == null || enterpriseId.isEmpty) return;
    final body = _isPublishedChangeMode
        ? _caseUpdateBody()
        : <String, Object?>{
            'title': _caseTitleController.text.trim(),
            'exhibitionType': _emptyToNull(_caseExhibitionTypeController.text),
            'city': _emptyToNull(_caseCityController.text),
            'eventTime': _emptyToNull(_caseEventTimeController.text),
            'summary': _caseSummaryController.text.trim(),
            'caseMediaFileAssetIds': _confirmedImageIds(_caseComposerImages),
            'isFeatured': _caseFeatured,
          };
    await _runAction(() async {
      final result = _isPublishedChangeMode
          ? await EnterpriseHubPublishedChangeConsumerLayer.instance
                .createCurrentChangeCase(
                  boardType: _boardType,
                  enterpriseId: enterpriseId,
                  body: body,
                )
          : await EnterpriseHubConsumerLayer.instance.createCase(
              boardType: _boardType,
              enterpriseId: enterpriseId,
              body: body,
            );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _localizedWorkbenchMessage(
              result.message ??
                  (result.isSuccess
                      ? (_isPublishedChangeMode
                            ? '案例已保存到当前变更内容，线上展示暂未更新。'
                            : '案例已保存到当前展示档。')
                      : '当前无法保存案例。'),
            ),
          ),
        ),
      );
      if (result.isSuccess) {
        _updateWorkbenchState(() {
          _resetCaseComposer();
        });
        await _loadWorkbench();
      }
    });
  }

  Future<void> _continueEditCase(String caseId) async {
    final normalizedCaseId = _normalizedText(caseId);
    if (normalizedCaseId == null) {
      return;
    }
    if (_isPublishedChangeMode) {
      if (!_publishedChangeCaseEditingAllowed) {
        _showWorkbenchMessage(_publishedChangeCaseEditingLockedMessage());
        return;
      }
      final enterpriseId = _currentEnterpriseId;
      if (enterpriseId == null || enterpriseId.isEmpty) {
        _showWorkbenchMessage('当前变更稿缺少企业标识，请返回工作台后重试。');
        return;
      }
      await _enterPublishedChangeCaseEditing(
        enterpriseId: enterpriseId,
        caseId: normalizedCaseId,
      );
      return;
    }
    final currentItem = _findCurrentCaseItem(normalizedCaseId);
    if (currentItem != null) {
      _updateWorkbenchState(() {
        _hydrateCaseComposerFromWorkbenchCaseItem(currentItem);
      });
    }
    await _runAction(() async {
      final result = await EnterpriseHubConsumerLayer.instance.getCaseDetail(
        caseId: normalizedCaseId,
      );
      if (!mounted) {
        return;
      }
      if (result.state != AppPageState.content || result.data == null) {
        final enterpriseId = _normalizedText(
          _workbenchResult?.data?.enterpriseId,
        );
        final applicationStatus = _normalizedText(
          _workbenchResult?.data?.latestApplication?.applicationStatus,
        );
        if (enterpriseId != null &&
            applicationStatus != null &&
            applicationStatus != 'draft' &&
            (result.state == AppPageState.forbidden ||
                enterpriseWorkbenchShouldExitDirectCaseEditing(
                  result.errorCode,
                ))) {
          await _enterPublishedChangeCaseEditing(
            enterpriseId: enterpriseId,
            caseId: normalizedCaseId,
          );
          return;
        }
        _showWorkbenchMessage(
          enterpriseWorkbenchCaseContinuationVisibleMessage(
            state: result.state,
            errorCode: result.errorCode,
            fallbackMessage: result.message,
          ),
        );
        return;
      }
      _updateWorkbenchState(() {
        _hydrateCaseComposerFromDetail(result.data!);
      });
    });
  }

  Future<void> _saveCaseModification() async {
    if (_isPublishedChangeMode && !_publishedChangeCaseEditingAllowed) {
      _showWorkbenchMessage(_publishedChangeCaseEditingLockedMessage());
      return;
    }
    final caseId = _normalizedText(_editingCaseId);
    if (caseId == null) {
      return;
    }
    final enterpriseId = _currentEnterpriseId;
    await _runAction(() async {
      final result = _isPublishedChangeMode
          ? await EnterpriseHubPublishedChangeConsumerLayer.instance
                .updateCurrentChangeCase(
                  boardType: _boardType,
                  enterpriseId: enterpriseId ?? '',
                  caseId: caseId,
                  body: _caseUpdateBody(),
                )
          : await EnterpriseHubConsumerLayer.instance.updateCase(
              caseId: caseId,
              body: _caseUpdateBody(),
            );
      if (!mounted) {
        return;
      }
      final successMessage = _isPublishedChangeMode
          ? '案例修改已保存到当前变更内容，线上展示暂未更新。'
          : '案例修改已保存。';
      _showWorkbenchMessage(
        _isPublishedChangeMode
            ? enterprisePublishedChangeVisibleMessage(
                state: result.controlledState,
                errorCode: result.errorCode,
                fallbackMessage: result.isSuccess
                    ? successMessage
                    : result.message,
              )
            : enterpriseWorkbenchCaseContinuationVisibleMessage(
                state: result.controlledState,
                errorCode: result.errorCode,
                fallbackMessage: result.isSuccess
                    ? successMessage
                    : result.message,
              ),
      );
      if (result.isSuccess) {
        _updateWorkbenchState(_resetCaseComposer);
        await _loadWorkbench();
        return;
      }
      if (!_isPublishedChangeMode &&
          enterpriseWorkbenchShouldExitDirectCaseEditing(result.errorCode)) {
        _updateWorkbenchState(_resetCaseComposer);
        await _loadWorkbench();
      }
    });
  }
}
