part of 'enterprise_hub_workbench_pages.dart';

extension _EnterpriseWorkbenchPageBasicSections
    on _EnterpriseApplicationPageState {
  Widget _buildBasicSection() {
    return EnterpriseSectionCard(
      key: const ValueKey<String>('enterprise-workbench-basic-section'),
      title: '基础资料',
      subtitle: _isPublishedChangeMode
          ? '先完善公司介绍、团队规模和合作方式；保存后只进入 current change carrier。'
          : '先完善公司介绍、团队规模和合作方式。',
      actions: <Widget>[
        FilledButton.tonal(
          key: const ValueKey<String>('enterprise-workbench-save-basic'),
          onPressed: _submittingAction ? null : _saveBasic,
          child: const Text('保存基础资料'),
        ),
      ],
      child: Column(
        children: <Widget>[
          _buildRequiredHint(_basicMissingFields()),
          const SizedBox(height: 12),
          TextField(
            controller: _fullIntroController,
            maxLength: 2000,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: '公司介绍（2000字以内）',
              helperText: '沿用当前展示介绍内容，收口为正式公司介绍。',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          EnterpriseWorkbenchDropdownField(
            label: '团队规模',
            value: _selectedTeamSizeRange,
            items: enterpriseWorkbenchTeamSizeOptions,
            onChanged: (value) =>
                _updateWorkbenchState(() => _selectedTeamSizeRange = value),
          ),
          const SizedBox(height: 12),
          EnterpriseWorkbenchMultiSelectField(
            label: '合作方式',
            helperText: '可多选，用来说明你主要承接哪类合作方式。',
            options: enterpriseWorkbenchCooperationModeOptions,
            selectedValues: _selectedCooperationModes,
            onChanged: (next) =>
                _updateWorkbenchState(() => _selectedCooperationModes = next),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    final hasBoard = _isPublishedChangeMode
        ? _publishedWorkbenchData?.boardType != null
        : _workbenchResult?.data?.boardType != null;
    return EnterpriseSectionCard(
      key: const ValueKey<String>('enterprise-workbench-contact-section'),
      title: '联系人',
      subtitle: !hasBoard
          ? '联系人不再影响首次保存资料或上传图片；真正进入申请流前仍需补齐。'
          : (_isPublishedChangeMode
                ? '联系人会跟随当前变更内容继续维护；保存后不会直接改线上展示。'
                : '联系人会跟随当前展示档继续维护；真正提交申请前仍要补齐。'),
      child: Column(
        children: <Widget>[
          _buildRequiredHint(_contactMissingFields()),
          const SizedBox(height: 12),
          TextField(
            controller: _applicantNameController,
            decoration: _fieldDecoration(
              label: '联系人姓名',
              required: true,
              hintText: '请填写联系人姓名',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _applicantMobileController,
            decoration: _fieldDecoration(
              label: '联系人手机号',
              required: true,
              hintText: '请填写联系人手机号',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile.adaptive(
            value: _contactVisible,
            contentPadding: EdgeInsets.zero,
            title: const Text('公开展示联系人'),
            subtitle: const Text('关闭后联系人只作为内部资料保存，不出现在公开展示中。'),
            onChanged: (value) =>
                _updateWorkbenchState(() => _contactVisible = value),
          ),
        ],
      ),
    );
  }
}
