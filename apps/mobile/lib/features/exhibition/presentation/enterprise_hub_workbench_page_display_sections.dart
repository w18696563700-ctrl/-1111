part of 'enterprise_hub_workbench_pages.dart';

extension _EnterpriseWorkbenchPageDisplaySections
    on _EnterpriseApplicationPageState {
  Widget _buildDisplayIdentificationSection() {
    return EnterpriseSectionCard(
      key: const ValueKey<String>(
        'enterprise-workbench-display-identification-section',
      ),
      title: '展示标识',
      actions: <Widget>[
        FilledButton.tonal(
          key: const ValueKey<String>(
            'enterprise-workbench-save-display-identification',
          ),
          onPressed: _submittingAction ? null : _saveProfile,
          child: const Text('保存展示标识'),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildRequiredHint(_profileMissingFields()),
          const SizedBox(height: 12),
          _buildSingleImageField(
            title: '展示标识 / Logo',
            item: _logoImage,
            emptyLabel: '上传企业 Logo，用于列表和详情页识别。',
            onPick: _replaceLogoImage,
            onClear: () => _updateWorkbenchState(() => _logoImage = null),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: _ReadonlyTruthField(
                  key: const ValueKey<String>(
                    'enterprise-workbench-enterprise-name-readonly',
                  ),
                  label: '公司名称',
                  sourceLabel: '认证真值',
                  value: _enterpriseNameTruthValue(),
                  placeholder: '当前还没有同步到认证公司名称',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ReadonlyTruthField(
                  key: const ValueKey<String>(
                    'enterprise-workbench-company-location-readonly',
                  ),
                  label: '公司位置',
                  sourceLabel: '认证注册地',
                  value: _companyLocationLabel(),
                  placeholder: '当前还没有同步到可展示的省市真值',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_boardType != EnterpriseBoardType.supplier) ...<Widget>[
            EnterpriseWorkbenchBoardProfileHeader(boardType: _boardType),
            const SizedBox(height: 12),
          ],
          EnterpriseWorkbenchMultiSelectField(
            label: _profileLabelOne(_boardType),
            helperText: _boardType == EnterpriseBoardType.supplier
                ? '请选择 1 个主营供应品类；前台左侧导航、筛选和工作台使用同一套口径。'
                : '请按系统预设标签选择，避免展示页筛选口径不一致。',
            options: _profileOneOptions(_boardType),
            selectedValues: _selectedProfileOneOptions,
            required: true,
            singleSelect: _boardType == EnterpriseBoardType.supplier,
            onChanged: (next) => _updateWorkbenchState(() {
              _selectedProfileOneOptions = next;
              _profileDraftDirty = true;
            }),
          ),
          const SizedBox(height: 12),
          if (_boardType == EnterpriseBoardType.factory) ...<Widget>[
            TextField(
              key: const ValueKey<String>(
                'enterprise-workbench-factory-name-field',
              ),
              controller: _factoryNameController,
              onChanged: (_) => _markProfileDraftDirty(),
              decoration: _fieldDecoration(
                label: '工厂名',
                required: true,
                hintText: '请填写对外展示的工厂名',
                border: const OutlineInputBorder(),
                helperText: '工厂展示时会显示为“工厂名 + 所属公司”。',
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (_boardType != EnterpriseBoardType.supplier)
            EnterpriseWorkbenchMultiSelectField(
              label: _profileLabelTwo(_boardType),
              helperText: '请按系统预设标签选择，和前台筛选保持同一套口径。',
              options: _profileTwoOptions(_boardType),
              selectedValues: _selectedProfileTwoOptions,
              required: true,
              onChanged: (next) => _updateWorkbenchState(() {
                _selectedProfileTwoOptions = next;
                _profileDraftDirty = true;
              }),
            ),
          if (_boardType == EnterpriseBoardType.factory) ...<Widget>[
            const SizedBox(height: 12),
            _buildFactoryEquipmentField(),
            const SizedBox(height: 12),
            TextField(
              controller: _factoryPlantAreaController,
              onChanged: (_) => _markProfileDraftDirty(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '厂房面积（㎡）',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            _buildFactoryOptionalCapabilitySection(),
          ],
          const SizedBox(height: 12),
          _buildCompanyCreditPlaceholder(),
          if (_boardType == EnterpriseBoardType.supplier) ...<Widget>[
            const SizedBox(height: 12),
            TextField(
              key: const ValueKey<String>(
                'enterprise-workbench-profile-three-field',
              ),
              controller: _profileThreeController,
              onChanged: (_) => _markProfileDraftDirty(),
              decoration: InputDecoration(
                labelText: _profileLabelThree(_boardType),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _profileFourController,
              onChanged: (_) => _markProfileDraftDirty(),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: _profileLabelFour(_boardType),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _profileFiveController,
              onChanged: (_) => _markProfileDraftDirty(),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: _profileLabelFive(_boardType),
                border: const OutlineInputBorder(),
              ),
            ),
          ] else if (_boardType == EnterpriseBoardType.company) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              '公司的服务城市、最大项目规模和资质说明已从主编辑流中收起，不再作为当前页的主要填写项。',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFactoryEquipmentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '设备清单',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text('前面填写设备名称，后面填写数量。', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 10),
        ...List<Widget>.generate(_factoryEquipmentEntries.length, (index) {
          final entry = _factoryEquipmentEntries[index];
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == _factoryEquipmentEntries.length - 1 ? 0 : 12,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: entry.nameController,
                    onChanged: (_) => _markProfileDraftDirty(),
                    decoration: const InputDecoration(
                      labelText: '设备名称',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: entry.quantityController,
                    onChanged: (_) => _markProfileDraftDirty(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '数量',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _factoryEquipmentEntries.length == 1
                      ? _addFactoryEquipmentEntry
                      : () => _removeFactoryEquipmentEntry(index),
                  icon: Icon(
                    _factoryEquipmentEntries.length == 1
                        ? Icons.add_circle_outline_rounded
                        : Icons.remove_circle_outline_rounded,
                  ),
                ),
              ],
            ),
          );
        }),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _addFactoryEquipmentEntry,
            icon: const Icon(Icons.add_rounded),
            label: const Text('添加设备'),
          ),
        ),
      ],
    );
  }

  Widget _buildFactoryOptionalCapabilitySection() {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: const ValueKey<String>(
            'enterprise-workbench-factory-optional-section',
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(
            '履约与扩展能力（选填）',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Text(
            '整块均为选填，默认收起，不干扰当前展示主信息。',
            style: theme.textTheme.bodySmall,
          ),
          children: <Widget>[
            EnterpriseWorkbenchDropdownField(
              label: '加急能力',
              value: _selectedUrgentCapability,
              items: enterpriseWorkbenchUrgentOptions,
              onChanged: (value) => _updateWorkbenchState(() {
                _selectedUrgentCapability = value;
                _profileDraftDirty = true;
              }),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _factoryUrgentCycleController,
              onChanged: (_) => _markProfileDraftDirty(),
              decoration: const InputDecoration(
                labelText: '加急周期说明',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            EnterpriseWorkbenchDropdownField(
              label: '运输能力',
              value: _selectedTransportCapability,
              items: enterpriseWorkbenchTransportOptions,
              onChanged: (value) => _updateWorkbenchState(() {
                _selectedTransportCapability = value;
                _profileDraftDirty = true;
              }),
            ),
            SwitchListTile.adaptive(
              value: _warehouseCapability ?? false,
              contentPadding: EdgeInsets.zero,
              title: const Text('支持仓储'),
              onChanged: (value) => _updateWorkbenchState(() {
                _warehouseCapability = value;
                _profileDraftDirty = true;
              }),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _profileFourController,
              onChanged: (_) => _markProfileDraftDirty(),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: _profileLabelFour(_boardType),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _factoryMaxOrderCapacityController,
              onChanged: (_) => _markProfileDraftDirty(),
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: '最大订单承接能力',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _factoryQualificationController,
              onChanged: (_) => _markProfileDraftDirty(),
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: '生产资质说明',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _profileFiveController,
              onChanged: (_) => _markProfileDraftDirty(),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: _profileLabelFive(_boardType),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _companyLocationLabel() {
    final certificationLocationTruth = _normalizedText(
      _certificationRegisteredLocationTruth,
    );
    if (certificationLocationTruth != null) {
      return certificationLocationTruth;
    }
    final organizationCityTruth = _normalizedText(
      _registeredCityController.text,
    );
    if (organizationCityTruth != null) {
      return organizationCityTruth;
    }
    final location = _currentBasic?.location;
    final provinceName =
        _normalizedText(location?.provinceName) ??
        _normalizedText(_currentBasic?.provinceName);
    final cityName =
        _normalizedText(location?.cityName) ??
        _normalizedText(_currentBasic?.cityName);
    if (provinceName == null && cityName == null) {
      return organizationCityTruth;
    }
    if (provinceName == null) {
      return cityName;
    }
    if (cityName == null) {
      return provinceName;
    }
    return '$provinceName / $cityName';
  }

  Widget _buildCompanyCreditPlaceholder() {
    return _SectionNotice(
      title: '公司信用评分（建设中）',
      tone: _SectionNoticeTone.neutral,
      lines: const <String>['当前阶段只保留占位，不展示真实分值。', '等信用系统接通后再回填，不会用 0 分冒充。'],
    );
  }
}
