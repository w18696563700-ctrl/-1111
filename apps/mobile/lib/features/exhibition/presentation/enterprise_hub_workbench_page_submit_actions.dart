part of 'enterprise_hub_workbench_pages.dart';

extension _EnterpriseWorkbenchPageSubmitActions
    on _EnterpriseApplicationPageState {
  Future<void> _submitPrimaryAction() async {
    if (_isPublishedChangeMode) {
      await _submitCurrentChange();
      return;
    }
    await _submitApplication();
  }

  Future<void> _recreateApplicationDraft() async {
    if (_isPublishedChangeMode) {
      _showWorkbenchMessage('当前页只承接已发布展示的正式变更，不创建新的入驻申请草稿。');
      return;
    }
    final applicantName = _applicantNameController.text.trim();
    final applicantMobile = _applicantMobileController.text.trim();
    if (applicantName.isEmpty || applicantMobile.isEmpty) {
      _showWorkbenchMessage('重新创建申请草稿前，请先补齐联系人姓名和联系电话。');
      return;
    }
    await _runAction(() async {
      final result = await EnterpriseHubConsumerLayer.instance
          .createApplication(
            boardType: _boardType,
            applicantName: applicantName,
            applicantMobile: applicantMobile,
          );
      if (!mounted) {
        return;
      }
      _showWorkbenchMessage(
        _localizedWorkbenchMessage(
          result.message ??
              (result.isSuccess ? '已重新创建申请草稿，可继续修改并重新提交。' : '当前无法重新创建申请草稿。'),
        ),
      );
      if (result.isSuccess) {
        await _loadWorkbench();
      }
    });
  }

  Future<void> _submitApplication() async {
    final applicationId =
        _workbenchResult?.data?.latestApplication?.applicationId;
    if (applicationId == null) return;
    await _runAction(() async {
      final result = await EnterpriseHubConsumerLayer.instance
          .submitApplication(
            applicationId: applicationId,
            boardType: _boardType,
          );
      if (!mounted) return;
      if (result.isSuccess) {
        await Navigator.of(context).pushNamed(
          ExhibitionRoutes.enterpriseApplicationStatusWithId(
            applicationId,
            boardType: _boardType.contractName,
          ),
        );
        await _loadWorkbench();
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            enterpriseApplicationVisibleErrorMessage(
              state: result.controlledState,
              errorCode: result.errorCode,
              fallbackMessage: result.message ?? '当前无法提交申请。',
            ),
          ),
        ),
      );
    });
  }

  Future<void> _submitCurrentChange() async {
    final enterpriseId = _currentEnterpriseId;
    if (enterpriseId == null) {
      return;
    }
    await _runAction(() async {
      final result = await EnterpriseHubPublishedChangeConsumerLayer.instance
          .submitCurrentChange(
            boardType: _boardType,
            enterpriseId: enterpriseId,
          );
      if (!mounted) {
        return;
      }
      if (result.isSuccess) {
        await Navigator.of(context).pushNamed(
          ExhibitionRoutes.enterprisePublishedChangeStatusWithEnterpriseId(
            enterpriseId,
            boardType: _boardType.contractName,
          ),
        );
        await _loadWorkbench();
        return;
      }
      _showWorkbenchMessage(
        enterprisePublishedChangeVisibleMessage(
          state: result.controlledState,
          errorCode: result.errorCode,
          fallbackMessage: result.message ?? '当前无法提交变更。',
        ),
      );
    });
  }

  Future<void> _deleteCase(String caseId) async {
    final confirmed = await _confirmDangerAction(
      title: '删除案例',
      content: '删除后当前案例会从企业展示里移除，且不能自动恢复。',
      confirmLabel: '确认删除',
    );
    if (!mounted || confirmed != true) {
      return;
    }
    await _runAction(() async {
      final result = _isPublishedChangeMode
          ? await EnterpriseHubPublishedChangeConsumerLayer.instance
                .deleteCurrentChangeCase(
                  boardType: _boardType,
                  enterpriseId: _currentEnterpriseId ?? '',
                  caseId: caseId,
                )
          : await EnterpriseHubConsumerLayer.instance.deleteCase(
              caseId: caseId,
            );
      if (!mounted) return;
      _showWorkbenchMessage(
        _isPublishedChangeMode
            ? enterprisePublishedChangeVisibleMessage(
                state: result.controlledState,
                errorCode: result.errorCode,
                fallbackMessage: result.isSuccess
                    ? '案例已从当前变更内容移除，线上展示暂未更新。'
                    : result.message,
              )
            : _localizedWorkbenchMessage(
                result.message ?? (result.isSuccess ? '案例已删除。' : '当前无法删除案例。'),
              ),
      );
      if (result.isSuccess) {
        if (_normalizedText(_editingCaseId) == _normalizedText(caseId)) {
          _updateWorkbenchState(_resetCaseComposer);
        }
        await _loadWorkbench();
      }
    });
  }

  Future<void> _deleteCurrentEnterprise() async {
    if (_isPublishedChangeMode) {
      _showWorkbenchMessage('当前页只承接已发布展示的正式变更，不提供删除展示档动作。');
      return;
    }
    final enterpriseId = _currentEnterpriseId;
    if (enterpriseId == null || enterpriseId.isEmpty) {
      _showWorkbenchMessage('当前还没有可删除的板块展示档。');
      return;
    }
    final confirmed = await _confirmDangerAction(
      title: '删除当前板块展示',
      content: '删除后会移除当前${_boardType.displayLabel}的展示资料、案例和申请记录，不影响其他板块。',
      confirmLabel: '确认删除',
    );
    if (!mounted || confirmed != true) {
      return;
    }
    await _runAction(() async {
      final result = await EnterpriseHubConsumerLayer.instance.deleteEnterprise(
        boardType: _boardType,
        enterpriseId: enterpriseId,
      );
      if (!mounted) return;
      _showWorkbenchMessage(
        _localizedWorkbenchMessage(
          result.message ?? (result.isSuccess ? '当前板块展示已删除。' : '当前无法删除板块展示。'),
        ),
      );
      if (result.isSuccess) {
        _updateWorkbenchState(_resetWorkbenchForm);
        await _loadWorkbench();
      }
    });
  }

  Future<bool?> _confirmDangerAction({
    required String title,
    required String content,
    required String confirmLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
  }
}
