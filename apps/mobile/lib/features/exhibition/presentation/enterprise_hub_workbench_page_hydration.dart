part of 'enterprise_hub_workbench_pages.dart';

extension _EnterpriseWorkbenchPageHydration on _EnterpriseApplicationPageState {
  void _hydrateFromWorkbench(EnterpriseHubWorkbenchData data) {
    if (data.boardType != null) {
      _boardType = data.boardType!;
    }
    final basic = data.basic;
    final boardProfile = data.boardProfile ?? const <String, Object?>{};
    final certification = data.certification;
    _certificationLegalNameTruth = _normalizedText(certification?.legalName);
    _ensuredEnterpriseId = _normalizedText(data.enterpriseId);
    final primaryContact = data.primaryContact;
    _draftStatusMessage = data.enterpriseId == null
        ? '当前还没有展示档，首次上传图片或保存资料时会先准备展示档；联系人会在真正进入申请流时再建立。'
        : '当前板块展示档已就绪，可以继续维护资料、上传图片和后续申请。';
    final incomingContactName = primaryContact?.contactName.trim() ?? '';
    final incomingContactMobile = primaryContact?.mobile?.trim() ?? '';
    if (incomingContactName.isNotEmpty) {
      _applicantNameController.text = incomingContactName;
    }
    if (incomingContactMobile.isNotEmpty) {
      _applicantMobileController.text = incomingContactMobile;
    }
    _nameController.text = basic?.name?.trim().isNotEmpty == true
        ? basic!.name!
        : (_certificationLegalNameTruth ?? '');
    _shortIntroController.text = basic?.shortIntro ?? '';
    _fullIntroController.text = basic?.fullIntro ?? '';
    _addressController.text = basic?.address ?? '';
    _resolvedLocationDraft = basic?.location;
    _foundedAtController.text =
        _normalizeDateStorageValue(basic?.foundedAt) ?? '';
    _selectedCooperationModes = Set<String>.of(
      basic?.cooperationModes ?? const <String>[],
    );
    _selectedTeamSizeRange = basic?.teamSizeRange;
    _contactVisible = basic?.contactVisible ?? true;
    _logoImage = _mergeSingleWorkbenchImage(
      current: _logoImage,
      nextFileAssetId: basic?.logoFileAssetId,
      nextImageUrl: basic?.logoUrl,
      fallbackLabel: '企业 Logo',
    );
    _albumShowcaseItems = _mergeWorkbenchImageCollection(
      current: _albumShowcaseItems,
      nextFileAssetIds: basic?.albumImageFileAssetIds ?? const <String>[],
      nextImageUrlMap: basic?.albumImageUrlMap ?? const <String, String>{},
      fallbackPrefix: '画册',
    );
    _factoryShowcaseItems = _mergeWorkbenchImageCollection(
      current: _factoryShowcaseItems,
      nextFileAssetIds: _readStringList(
        boardProfile['showcaseImageFileAssetIds'],
      ),
      nextImageUrlMap: _readStringMap(boardProfile['showcaseImageUrlMap']),
      fallbackPrefix: '工厂照片',
    );
    if (enterpriseWorkbenchShouldHydrateBoardProfileFromWorkbench(
      hasPendingLocalProfileDraft: _profileDraftDirty,
    )) {
      _factoryPlantAreaController.text = _scalarStringValue(
        boardProfile['plantAreaSqm'],
      );
      final incomingFactoryName = _stringValue(boardProfile['factoryName']);
      if (incomingFactoryName.trim().isNotEmpty) {
        _factoryNameController.text = incomingFactoryName;
      }
      _factoryUrgentCycleController.text = _stringValue(
        boardProfile['urgentCycleDesc'],
      );
      _factoryMaxOrderCapacityController.text = _stringValue(
        boardProfile['maxOrderCapacityDesc'],
      );
      _factoryQualificationController.text = _stringValue(
        boardProfile['productionQualificationDesc'],
      );
      _selectedProfileOneOptions = _readStringList(
        boardProfile['exhibitionTypes'] ??
            boardProfile['processTypes'] ??
            boardProfile['supplyCategories'],
      ).take(_boardType == EnterpriseBoardType.supplier ? 1 : 999).toSet();
      if (_boardType == EnterpriseBoardType.supplier) {
        _selectedProfileTwoOptions = <String>{};
        _profileTwoController.clear();
      } else {
        _selectedProfileTwoOptions = _readStringList(
          boardProfile['serviceItems'] ?? boardProfile['coreProducts'],
        ).toSet();
        _profileTwoController.text = _joinList(
          boardProfile['serviceItems'],
          boardProfile['coreProducts'],
        );
      }
      _profileThreeController.text = _joinList(
        boardProfile['serviceCities'],
        boardProfile['coreProductsOrServices'],
      );
      for (final entry in _factoryEquipmentEntries) {
        entry.dispose();
      }
      _factoryEquipmentEntries = _parseFactoryEquipmentEntries(
        boardProfile['equipmentList'],
      );
      _profileFourController.text = _stringValue(
        boardProfile['maxProjectScale'],
        boardProfile['monthlyCapacityDesc'],
        boardProfile['responseSlaDesc'],
      );
      _profileFiveController.text = _stringValue(
        boardProfile['qualificationDesc'],
        boardProfile['deliveryRadiusDesc'],
        boardProfile['deliveryRange'],
      );
      _selectedUrgentCapability = _stringValue(
        boardProfile['urgentOrderCapability'],
      );
      _selectedTransportCapability = _stringValue(
        boardProfile['transportCapability'],
      );
      _warehouseCapability = boardProfile['warehouseCapability'] is bool
          ? boardProfile['warehouseCapability'] as bool
          : null;
    }
  }

  void _hydrateFromPublishedChangeWorkbench(
    EnterpriseHubPublishedChangeWorkbenchData data,
  ) {
    _boardType = data.boardType;
    final basic = data.basic;
    final boardProfile = data.boardProfile ?? const <String, Object?>{};
    final primaryContact = data.primaryContact;
    _draftStatusMessage =
        '当前展示已进入正式变更通道；保存修改只写入 current change carrier，不会直接更新线上展示。';
    final incomingContactName = primaryContact?.contactName.trim() ?? '';
    final incomingContactMobile = primaryContact?.mobile?.trim() ?? '';
    if (incomingContactName.isNotEmpty) {
      _applicantNameController.text = incomingContactName;
    }
    if (incomingContactMobile.isNotEmpty) {
      _applicantMobileController.text = incomingContactMobile;
    }
    _nameController.text = basic?.name?.trim().isNotEmpty == true
        ? basic!.name!
        : (_certificationLegalNameTruth ?? '');
    _shortIntroController.text = basic?.shortIntro ?? '';
    _fullIntroController.text = basic?.fullIntro ?? '';
    _addressController.text = basic?.address ?? '';
    _resolvedLocationDraft = basic?.location;
    _foundedAtController.text =
        _normalizeDateStorageValue(basic?.foundedAt) ?? '';
    _selectedCooperationModes = Set<String>.of(
      basic?.cooperationModes ?? const <String>[],
    );
    _selectedTeamSizeRange = basic?.teamSizeRange;
    _contactVisible = basic?.contactVisible ?? true;
    _logoImage = _mergeSingleWorkbenchImage(
      current: _logoImage,
      nextFileAssetId: basic?.logoFileAssetId,
      nextImageUrl: basic?.logoUrl,
      fallbackLabel: '企业 Logo',
    );
    _albumShowcaseItems = _mergeWorkbenchImageCollection(
      current: _albumShowcaseItems,
      nextFileAssetIds: basic?.albumImageFileAssetIds ?? const <String>[],
      nextImageUrlMap: basic?.albumImageUrlMap ?? const <String, String>{},
      fallbackPrefix: '画册',
    );
    _factoryShowcaseItems = _mergeWorkbenchImageCollection(
      current: _factoryShowcaseItems,
      nextFileAssetIds: _readStringList(
        boardProfile['showcaseImageFileAssetIds'],
      ),
      nextImageUrlMap: _readStringMap(boardProfile['showcaseImageUrlMap']),
      fallbackPrefix: '工厂照片',
    );
    if (enterpriseWorkbenchShouldHydrateBoardProfileFromWorkbench(
      hasPendingLocalProfileDraft: _profileDraftDirty,
    )) {
      _factoryPlantAreaController.text = _scalarStringValue(
        boardProfile['plantAreaSqm'],
      );
      final incomingFactoryName = _stringValue(boardProfile['factoryName']);
      if (incomingFactoryName.trim().isNotEmpty) {
        _factoryNameController.text = incomingFactoryName;
      }
      _factoryUrgentCycleController.text = _stringValue(
        boardProfile['urgentCycleDesc'],
      );
      _factoryMaxOrderCapacityController.text = _stringValue(
        boardProfile['maxOrderCapacityDesc'],
      );
      _factoryQualificationController.text = _stringValue(
        boardProfile['productionQualificationDesc'],
      );
      _selectedProfileOneOptions = _readStringList(
        boardProfile['exhibitionTypes'] ??
            boardProfile['processTypes'] ??
            boardProfile['supplyCategories'],
      ).take(_boardType == EnterpriseBoardType.supplier ? 1 : 999).toSet();
      if (_boardType == EnterpriseBoardType.supplier) {
        _selectedProfileTwoOptions = <String>{};
        _profileTwoController.clear();
      } else {
        _selectedProfileTwoOptions = _readStringList(
          boardProfile['serviceItems'] ?? boardProfile['coreProducts'],
        ).toSet();
        _profileTwoController.text = _joinList(
          boardProfile['serviceItems'],
          boardProfile['coreProducts'],
        );
      }
      _profileThreeController.text = _joinList(
        boardProfile['serviceCities'],
        boardProfile['coreProductsOrServices'],
      );
      for (final entry in _factoryEquipmentEntries) {
        entry.dispose();
      }
      _factoryEquipmentEntries = _parseFactoryEquipmentEntries(
        boardProfile['equipmentList'],
      );
      _profileFourController.text = _stringValue(
        boardProfile['maxProjectScale'],
        boardProfile['monthlyCapacityDesc'],
        boardProfile['responseSlaDesc'],
      );
      _profileFiveController.text = _stringValue(
        boardProfile['qualificationDesc'],
        boardProfile['deliveryRadiusDesc'],
        boardProfile['deliveryRange'],
      );
      _selectedUrgentCapability = _stringValue(
        boardProfile['urgentOrderCapability'],
      );
      _selectedTransportCapability = _stringValue(
        boardProfile['transportCapability'],
      );
      _warehouseCapability = boardProfile['warehouseCapability'] is bool
          ? boardProfile['warehouseCapability'] as bool
          : null;
    }
  }

  EnterpriseHubWorkbenchCertification? _certificationSummaryFromProfile(
    ProfileCertificationCurrentView? certification,
  ) {
    final status = _normalizedText(certification?.certificationStatus);
    if (status == null) {
      return null;
    }
    return EnterpriseHubWorkbenchCertification(
      certificationStatus: status,
      legalName: certification?.legalName,
      uscc: certification?.uscc,
      licenseFileId: certification?.licenseFileId,
      submittedAt: certification?.submittedAt,
      rejectReason: certification?.rejectReason,
    );
  }

  void _syncOrganizationTruth({
    required MyOrganizationsView? organizations,
    required AppShellContextData shellContext,
    required EnterpriseHubWorkbenchBasic? basic,
    required ChinaRegionCatalog regionCatalog,
  }) {
    final organization = _currentOrganization(organizations, shellContext);
    _organizationContactName = _normalizedText(organization?.contactName);
    _organizationContactMobile = _normalizedText(organization?.contactMobile);
    final cityCode = organization?.cityCode?.trim();
    final fallbackCityCode = basic?.cityCode?.trim();
    _selectedCityCode = cityCode != null && cityCode.isNotEmpty
        ? cityCode
        : fallbackCityCode;
    if (_applicantNameController.text.trim().isEmpty &&
        _organizationContactName != null) {
      _applicantNameController.text = _organizationContactName!;
    }
    if (_applicantMobileController.text.trim().isEmpty &&
        _organizationContactMobile != null) {
      _applicantMobileController.text = _organizationContactMobile!;
    }
    _registeredCityController.text = _cityDisplayLabel(
      regionCatalog: regionCatalog,
      cityCode: _selectedCityCode,
      fallbackProvinceName: basic?.provinceName,
      fallbackCityName: basic?.cityName,
    );
  }

  Future<void> _hydrateCertificationTruth({
    required ProfileCertificationCurrentView? certification,
    required EnterpriseHubWorkbenchBasic? basic,
  }) async {
    _applyCertificationTruth(null, certification: certification, basic: basic);
    final organizationId = certification?.organizationId?.trim();
    final fileAssetId = certification?.licenseFileId?.trim();
    if (organizationId == null ||
        organizationId.isEmpty ||
        fileAssetId == null ||
        fileAssetId.isEmpty) {
      return;
    }

    final result = await ProfileIdentityConsumerLayer.instance
        .recognizeCertificationLicense(
          organizationId: organizationId,
          fileAssetId: fileAssetId,
        );
    if (!mounted) return;
    _applyCertificationTruth(
      result.data,
      certification: certification,
      basic: basic,
    );
  }

  void _applyCertificationTruth(
    CertificationLicenseOcrView? ocrView, {
    required ProfileCertificationCurrentView? certification,
    required EnterpriseHubWorkbenchBasic? basic,
  }) {
    final legalName =
        _normalizedText(basic?.name) ??
        _normalizedText(certification?.legalName) ??
        _normalizedText(ocrView?.legalName);
    _certificationLegalNameTruth = legalName;
    if (_nameController.text.trim().isEmpty && legalName != null) {
      _nameController.text = legalName;
    }
    _certificationRegisteredLocationTruth = _certificationLocationLabel(
      _normalizedText(ocrView?.address) ??
          _normalizedText(certification?.address),
    );
    final foundedAt =
        _normalizedText(ocrView?.establishedAt) ??
        _normalizedText(basic?.foundedAt) ??
        '';
    _foundedAtController.text = _normalizeDateStorageValue(foundedAt) ?? '';
    if (_addressController.text.trim().isEmpty) {
      final certificationAddress = _normalizedText(ocrView?.address);
      if (certificationAddress != null) {
        _addressController.text = certificationAddress;
      }
    }
    if (mounted) {
      _updateWorkbenchState(() {});
    }
  }

  String? _certificationLocationLabel(String? address) {
    final normalized = _normalizedText(address);
    if (normalized == null) {
      return null;
    }

    const municipalities = <String>['北京市', '上海市', '天津市', '重庆市'];
    for (final municipality in municipalities) {
      if (normalized.startsWith(municipality)) {
        return '$municipality / $municipality';
      }
    }

    const specialRegions = <String>['香港特别行政区', '澳门特别行政区'];
    for (final region in specialRegions) {
      if (normalized.startsWith(region)) {
        return '$region / $region';
      }
    }

    final autonomousMatch = RegExp(
      r'^(内蒙古自治区|广西壮族自治区|西藏自治区|宁夏回族自治区|新疆维吾尔自治区)(.*?(?:市|州|地区|盟))',
    ).firstMatch(normalized);
    if (autonomousMatch != null) {
      final province = _normalizedText(autonomousMatch.group(1));
      final city = _normalizedText(autonomousMatch.group(2));
      if (province != null && city != null) {
        return '$province / $city';
      }
    }

    final provinceMatch = RegExp(
      r'^(.*?省)(.*?(?:市|州|地区|盟))',
    ).firstMatch(normalized);
    if (provinceMatch != null) {
      final province = _normalizedText(provinceMatch.group(1));
      final city = _normalizedText(provinceMatch.group(2));
      if (province != null && city != null) {
        return '$province / $city';
      }
    }

    final cityMatch = RegExp(r'^(.*?市)').firstMatch(normalized);
    final city = _normalizedText(cityMatch?.group(1));
    return city;
  }
}
