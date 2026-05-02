part of 'enterprise_hub_workbench_pages.dart';

extension _EnterpriseWorkbenchPageCaseSections
    on _EnterpriseApplicationPageState {
  bool get _caseComposerEditable {
    if (!_isPublishedChangeMode) {
      return true;
    }
    return _publishedWorkbenchData?.changeReadiness.draftEditable == true;
  }

  String? get _caseComposerLockReason {
    if (_caseComposerEditable || !_isPublishedChangeMode) {
      return null;
    }
    final status =
        _publishedChangeStatus?.changeStatus ??
        _publishedWorkbenchData?.currentChangeRequest?.changeStatus;
    return '当前变更处于${enterprisePublishedChangeStatusLabel(status)}，案例编辑已锁定。请先查看变更状态。';
  }

  Widget _buildCaseComposerSection() {
    final editable = _caseComposerEditable;
    return EnterpriseSectionCard(
      title: '案例编辑器',
      subtitle: _isCaseEditing
          ? (_isPublishedChangeMode
                ? '当前正在编辑待发布变更稿中的已保存案例，保存修改后会回写当前变更内容。'
                : '当前正在编辑案例库中的已保存案例，保存修改后会回写当前案例。')
          : (_isPublishedChangeMode
                ? '当前编辑的是已发布展示里的单条案例。先在这里编辑，再保存进待发布变更稿。'
                : '提交当前入驻申请前，至少需要保存 1 个案例。先在这里编辑单个案例，再保存进当前展示档的案例库。'),
      actions: <Widget>[
        FilledButton.tonal(
          key: const ValueKey<String>('enterprise-workbench-save-case'),
          onPressed: _submittingAction || !editable
              ? null
              : (_isCaseEditing ? _saveCaseModification : _createCase),
          child: Text(_caseSaveActionLabel),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _isCaseEditing
                  ? (_isPublishedChangeMode
                        ? '当前正在编辑待发布变更稿中的已保存案例，点击“保存修改”后会覆盖当前变更内容。'
                        : '当前正在编辑案例库中的已保存案例，点击“保存修改”后会覆盖当前案例。')
                  : (_isPublishedChangeMode
                        ? '当前页保存只进入待发布变更稿，不会直接更新线上展示。'
                        : '提交门槛认下面的案例库，不认当前还没保存的输入内容。'),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          if (_caseComposerLockReason != null) ...<Widget>[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _caseComposerLockReason!,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey<String>(
              'enterprise-workbench-case-title-field',
            ),
            controller: _caseTitleController,
            enabled: editable,
            decoration: const InputDecoration(
              labelText: '案例标题',
              hintText: '请填写案例标题',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _caseExhibitionTypeController,
            enabled: editable,
            decoration: const InputDecoration(
              labelText: '展会类型',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          SelectLikeField(
            label: '案例城市',
            value: _caseCityController.text,
            placeholder: '点击选择案例城市',
            onTap: editable ? _selectCaseCity : null,
          ),
          const SizedBox(height: 12),
          SelectLikeField(
            label: '举办时间',
            value: _displayDateLabel(_caseEventTimeController.text),
            placeholder: '点击选择举办时间',
            onTap: editable ? _selectCaseEventTime : null,
            trailing: const Icon(Icons.calendar_today_rounded),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey<String>(
              'enterprise-workbench-case-summary-field',
            ),
            controller: _caseSummaryController,
            enabled: editable,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: '案例摘要',
              hintText: '请简要说明案例亮点、执行内容和结果',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          _buildImageCollectionField(
            title: '案例图片',
            subtitle: _isCaseEditing
                ? (_isPublishedChangeMode
                      ? '最多 6 张。图片上传后会先留在当前案例编辑器里，点击“保存修改”后再正式写入当前变更内容。'
                      : '最多 6 张。图片上传后会先留在当前案例编辑器里，点击“保存修改”后再正式更新当前案例。')
                : (_isPublishedChangeMode
                      ? '最多 6 张。图片上传后会先留在当前案例编辑器里，点击“保存案例”后再正式进入当前变更内容。'
                      : '最多 6 张。图片上传后会先留在当前案例编辑器里，点击“保存案例”后再正式进入案例库。'),
            items: _caseComposerImages,
            onAdd: editable
                ? _addCaseImage
                : () async => _showWorkbenchMessage(_caseComposerLockReason!),
            onRemove: editable
                ? _removeCaseImage
                : (_) => _showWorkbenchMessage(_caseComposerLockReason!),
          ),
          SwitchListTile.adaptive(
            value: _caseFeatured,
            contentPadding: EdgeInsets.zero,
            title: const Text('标记为重点案例'),
            onChanged: editable
                ? (value) => _updateWorkbenchState(() => _caseFeatured = value)
                : null,
          ),
        ],
      ),
    );
  }
}
