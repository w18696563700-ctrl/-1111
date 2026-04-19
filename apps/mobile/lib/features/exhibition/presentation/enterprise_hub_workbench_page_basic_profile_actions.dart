part of 'enterprise_hub_workbench_pages.dart';

extension _EnterpriseWorkbenchPageBasicProfileActions
    on _EnterpriseApplicationPageState {
  Future<void> _runAction(Future<void> Function() action) async {
    _updateWorkbenchState(() => _submittingAction = true);
    try {
      await action();
    } finally {
      if (mounted) {
        _updateWorkbenchState(() => _submittingAction = false);
      }
    }
  }

  Future<void> _saveBasic() async {
    await _submitBasicUpdate(
      successMessage: _isPublishedChangeMode
          ? '基础资料已保存到当前变更内容，线上展示暂未更新。'
          : '基础资料已保存。',
      failureMessage: '当前无法保存基础资料。',
    );
  }

  Future<void> _saveAlbum() async {
    await _submitBasicUpdate(
      successMessage: _isPublishedChangeMode
          ? '企业画册已保存到当前变更内容，线上展示暂未更新。'
          : '企业画册已保存。',
      failureMessage: '当前无法保存企业画册。',
    );
  }

  Future<void> _saveAlbumSection() async {
    if (_boardType == EnterpriseBoardType.factory) {
      await _saveFactoryShowcase();
      return;
    }
    await _saveAlbum();
  }

  Future<void> _saveFactoryShowcase() async {
    final enterpriseId = await _ensureEnterpriseId();
    if (enterpriseId == null || enterpriseId.isEmpty) return;
    final body = <String, Object?>{
      'showcaseImageFileAssetIds': _confirmedImageIds(_factoryShowcaseItems),
    };
    await _runAction(() async {
      final result = _isPublishedChangeMode
          ? await EnterpriseHubPublishedChangeConsumerLayer.instance
                .updateCurrentChangeFactoryProfile(
                  enterpriseId: enterpriseId,
                  body: body,
                )
          : await EnterpriseHubConsumerLayer.instance.updateFactoryProfile(
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
                            ? '工厂实景图已保存到当前变更内容，线上展示暂未更新。'
                            : '工厂实景图已保存。')
                      : '当前无法保存工厂实景图。'),
            ),
          ),
        ),
      );
      if (result.isSuccess) {
        await _loadWorkbench();
      }
    });
  }

  Future<void> _submitBasicUpdate({
    required String successMessage,
    required String failureMessage,
  }) async {
    final city = _regionCatalog?.cityByCode(_selectedCityCode);
    final basicTruth = _currentBasic;
    final provinceCode =
        city?.provinceCode ?? _normalizedText(basicTruth?.provinceCode);
    final provinceName =
        city?.provinceName ?? _normalizedText(basicTruth?.provinceName);
    final cityCode = city?.cityCode ?? _normalizedText(basicTruth?.cityCode);
    final cityName = city?.cityName ?? _normalizedText(basicTruth?.cityName);
    if (provinceCode == null ||
        provinceName == null ||
        cityCode == null ||
        cityName == null) {
      _showWorkbenchMessage(
        '当前还没有同步到可用的组织所在城市真值，基础资料暂不能保存。请先去我的公司补全有效城市，再返回当前页重试。',
      );
      return;
    }
    final enterpriseId = await _ensureEnterpriseId();
    if (enterpriseId == null || enterpriseId.isEmpty) return;
    final body = enterpriseWorkbenchBasicUpdateBody(
      enterpriseName: _enterpriseNameTruthValue(),
      contactNameText: _applicantNameController.text,
      contactMobileText: _applicantMobileController.text,
      logoFileAssetId: _logoImage?.fileAssetId,
      albumImageFileAssetIds: _confirmedImageIds(_albumShowcaseItems),
      shortIntroText: _shortIntroController.text,
      fullIntroText: _fullIntroController.text,
      provinceCode: provinceCode,
      provinceName: provinceName,
      cityCode: cityCode,
      cityName: cityName,
      addressText: _addressController.text,
      foundedAtText: _foundedAtController.text,
      teamSizeRange: _selectedTeamSizeRange,
      cooperationModes: _selectedCooperationModes,
      contactVisible: _contactVisible,
      location: _resolvedLocationDraft,
    );
    await _runAction(() async {
      final result = _isPublishedChangeMode
          ? await EnterpriseHubPublishedChangeConsumerLayer.instance
                .updateCurrentChangeBasic(
                  boardType: _boardType,
                  enterpriseId: enterpriseId,
                  body: body,
                )
          : await EnterpriseHubConsumerLayer.instance.updateBasic(
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
                  (result.isSuccess ? successMessage : failureMessage),
            ),
          ),
        ),
      );
      if (result.isSuccess) {
        await _loadWorkbench();
      }
    });
  }

  Future<void> _saveProfile() async {
    await _submitProfileUpdate(
      successMessage: _isPublishedChangeMode
          ? '展示标识已保存到当前变更内容，线上展示暂未更新。'
          : '展示标识已保存。',
      failureMessage: '当前无法保存展示标识。',
    );
  }

  Future<void> _submitProfileUpdate({
    required String successMessage,
    required String failureMessage,
  }) async {
    final enterpriseId = await _ensureEnterpriseId();
    if (enterpriseId == null || enterpriseId.isEmpty) return;
    await _runAction(() async {
      final body = switch (_boardType) {
        EnterpriseBoardType.company =>
          enterpriseWorkbenchCompanyProfileUpdateBody(
            exhibitionTypes: _selectedProfileOneOptions,
            serviceItems: _selectedProfileTwoOptions,
            serviceCitiesText: _profileThreeController.text,
            maxProjectScaleText: _profileFourController.text,
            qualificationDescText: _profileFiveController.text,
          ),
        EnterpriseBoardType.factory =>
          _enterpriseWorkbenchFactoryProfileUpdateBody(
            factoryNameText: _factoryNameController.text,
            processTypes: _selectedProfileOneOptions,
            coreProductsText: _profileTwoController.text,
            equipmentEntries: _factoryEquipmentEntries,
            showcaseItems: _factoryShowcaseItems,
            plantAreaText: _factoryPlantAreaController.text,
            monthlyCapacityDescText: _profileFourController.text,
            urgentCapability: _selectedUrgentCapability,
            urgentCycleText: _factoryUrgentCycleController.text,
            transportCapability: _selectedTransportCapability,
            warehouseCapability: _warehouseCapability,
            maxOrderCapacityText: _factoryMaxOrderCapacityController.text,
            productionQualificationText: _factoryQualificationController.text,
            deliveryRadiusText: _profileFiveController.text,
          ),
        EnterpriseBoardType.supplier => <String, Object?>{
          'supplyCategories': _selectedProfileOneOptions.toList()..sort(),
          'supplyMode': _selectedProfileTwoOptions.toList()..sort(),
          'coreProductsOrServices': _csvList(_profileThreeController.text),
          'responseSlaDesc': _emptyToNull(_profileFourController.text),
          'deliveryRange': _emptyToNull(_profileFiveController.text),
        },
      };
      final result = _isPublishedChangeMode
          ? await switch (_boardType) {
              EnterpriseBoardType.company =>
                EnterpriseHubPublishedChangeConsumerLayer.instance
                    .updateCurrentChangeCompanyProfile(
                      enterpriseId: enterpriseId,
                      body: body,
                    ),
              EnterpriseBoardType.factory =>
                EnterpriseHubPublishedChangeConsumerLayer.instance
                    .updateCurrentChangeFactoryProfile(
                      enterpriseId: enterpriseId,
                      body: body,
                    ),
              EnterpriseBoardType.supplier =>
                EnterpriseHubPublishedChangeConsumerLayer.instance
                    .updateCurrentChangeSupplierProfile(
                      enterpriseId: enterpriseId,
                      body: body,
                    ),
            }
          : await switch (_boardType) {
              EnterpriseBoardType.company =>
                EnterpriseHubConsumerLayer.instance.updateCompanyProfile(
                  enterpriseId: enterpriseId,
                  body: body,
                ),
              EnterpriseBoardType.factory =>
                EnterpriseHubConsumerLayer.instance.updateFactoryProfile(
                  enterpriseId: enterpriseId,
                  body: body,
                ),
              EnterpriseBoardType.supplier =>
                EnterpriseHubConsumerLayer.instance.updateSupplierProfile(
                  enterpriseId: enterpriseId,
                  body: body,
                ),
            };
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _localizedWorkbenchMessage(
              result.message ??
                  (result.isSuccess ? successMessage : failureMessage),
            ),
          ),
        ),
      );
      if (result.isSuccess) {
        _profileDraftDirty = false;
        await _loadWorkbench();
      }
    });
  }
}
