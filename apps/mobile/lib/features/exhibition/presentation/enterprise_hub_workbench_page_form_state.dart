part of 'enterprise_hub_workbench_pages.dart';

extension _EnterpriseWorkbenchPageFormState on _EnterpriseApplicationPageState {
  void _removeFactoryEquipmentEntry(int index) {
    final next = List<_FactoryEquipmentEntry>.of(_factoryEquipmentEntries);
    final removed = next.removeAt(index);
    removed.dispose();
    _updateWorkbenchState(() {
      _factoryEquipmentEntries = next.isEmpty
          ? <_FactoryEquipmentEntry>[_FactoryEquipmentEntry()]
          : next;
      _profileDraftDirty = true;
    });
  }

  void _resetWorkbenchForm() {
    _applicantNameController.clear();
    _applicantMobileController.clear();
    _registeredCityController.clear();
    _nameController.clear();
    _shortIntroController.clear();
    _fullIntroController.clear();
    _addressController.clear();
    _foundedAtController.clear();
    _factoryPlantAreaController.clear();
    _factoryNameController.clear();
    _factoryUrgentCycleController.clear();
    _factoryMaxOrderCapacityController.clear();
    _factoryQualificationController.clear();
    _profileTwoController.clear();
    _profileThreeController.clear();
    _profileFourController.clear();
    _profileFiveController.clear();
    _caseTitleController.clear();
    _caseExhibitionTypeController.clear();
    _caseCityController.clear();
    _caseEventTimeController.clear();
    _caseSummaryController.clear();
    for (final entry in _factoryEquipmentEntries) {
      entry.dispose();
    }
    _factoryEquipmentEntries = <_FactoryEquipmentEntry>[
      _FactoryEquipmentEntry(),
    ];
    _logoImage = null;
    _albumShowcaseItems = const <_WorkbenchImageItem>[];
    _factoryShowcaseItems = const <_WorkbenchImageItem>[];
    _caseComposerImages = const <_WorkbenchImageItem>[];
    _certificationLegalNameTruth = null;
    _certificationRegisteredLocationTruth = null;
    _selectedCityCode = null;
    _selectedTeamSizeRange = null;
    _selectedUrgentCapability = null;
    _selectedTransportCapability = null;
    _selectedProfileOneOptions = <String>{};
    _selectedProfileTwoOptions = <String>{};
    _selectedCooperationModes = <String>{};
    _warehouseCapability = null;
    _contactVisible = true;
    _caseFeatured = false;
    _locationStatusMessage = null;
    _resolvedLocationDraft = null;
    _profileDraftDirty = false;
    _ensuredEnterpriseId = null;
    _draftStatusMessage = _isPublishedChangeMode
        ? '当前页只维护已发布展示的 current change carrier；保存修改不会直接改线上展示。'
        : '当前还没有展示档，首次上传图片或保存资料时会先准备展示档；联系人会在真正进入申请流时再建立。';
    _editingCaseId = null;
  }

  void _resetCaseComposer() {
    _caseTitleController.clear();
    _caseExhibitionTypeController.clear();
    _caseCityController.clear();
    _caseEventTimeController.clear();
    _caseSummaryController.clear();
    _caseComposerImages = const <_WorkbenchImageItem>[];
    _caseFeatured = false;
    _editingCaseId = null;
  }

  void _hydrateCaseComposerFromDetail(EnterpriseHubCaseDetailData detail) {
    _editingCaseId = detail.caseId;
    _caseTitleController.text = detail.title;
    _caseExhibitionTypeController.text = detail.exhibitionType ?? '';
    _caseCityController.text = detail.city ?? '';
    _caseEventTimeController.text =
        _normalizeDateStorageValue(detail.eventTime) ?? '';
    _caseSummaryController.text = detail.summary;
    _caseComposerImages = _mergeWorkbenchImageCollection(
      current: _caseComposerImages,
      nextFileAssetIds: _caseComposerImageIdsFromDetail(detail),
      nextImageUrlMap: detail.caseImageUrlMap,
      fallbackPrefix: '案例图片',
    );
    _caseFeatured = detail.isFeatured;
  }

  List<String> _caseComposerImageIdsFromDetail(
    EnterpriseHubCaseDetailData detail,
  ) {
    return _caseComposerImageIds(
      detail.caseCoverFileAssetId,
      detail.caseMediaFileAssetIds,
    );
  }

  List<String> _caseComposerImageIds(
    String? coverFileAssetId,
    List<String> mediaFileAssetIds,
  ) {
    final mergedIds = <String>[];
    final seen = <String>{};
    final normalizedCover = _normalizedText(coverFileAssetId);
    if (normalizedCover != null && seen.add(normalizedCover)) {
      mergedIds.add(normalizedCover);
    }
    for (final fileAssetId in mediaFileAssetIds) {
      final normalized = _normalizedText(fileAssetId);
      if (normalized != null && seen.add(normalized)) {
        mergedIds.add(normalized);
      }
    }
    return mergedIds;
  }

  List<String> _caseComposerFileAssetIds() {
    final confirmedIds = _confirmedImageIds(_caseComposerImages);
    final normalizedIds = <String>[];
    final seen = <String>{};
    for (final fileAssetId in confirmedIds) {
      final normalized = _normalizedText(fileAssetId);
      if (normalized != null && seen.add(normalized)) {
        normalizedIds.add(normalized);
      }
    }
    return normalizedIds;
  }

  Map<String, Object?> _caseUpdateBody() {
    return enterpriseWorkbenchCaseUpdateBody(
      titleText: _caseTitleController.text,
      exhibitionTypeText: _caseExhibitionTypeController.text,
      cityText: _caseCityController.text,
      eventTimeText: _caseEventTimeController.text,
      summaryText: _caseSummaryController.text,
      caseMediaFileAssetIds: _caseComposerFileAssetIds(),
      isFeatured: _caseFeatured,
    );
  }
}
