part of 'enterprise_hub_workbench_pages.dart';

extension _EnterpriseWorkbenchCompanySupport
    on _EnterpriseApplicationPageState {
  String _companyWorkbenchSubjectLabel() => switch (_boardType) {
    EnterpriseBoardType.factory => '工厂',
    EnterpriseBoardType.company => '公司',
    EnterpriseBoardType.supplier => '供应商',
  };

  String _companyWorkbenchSubjectDisplayLabel() => _boardType.displayLabel;

  String _companyStatusLabel({
    required EnterpriseHubWorkbenchReadiness readiness,
    required EnterpriseHubWorkbenchApplication? latestApplication,
    required EnterpriseHubPublishedChangeWorkbenchData? publishedData,
  }) {
    if (_isPublishedChangeMode) {
      return enterprisePublishedChangeStatusLabel(
        _publishedChangeStatus?.changeStatus ??
            publishedData?.currentChangeRequest?.changeStatus,
      );
    }
    if (latestApplication != null) {
      return enterpriseWorkbenchApplicationStatusLabel(
        latestApplication.applicationStatus,
      );
    }
    return readiness.submitReady ? '资料已齐，可提交申请' : '资料待完善';
  }

  String? _companyHeroImageUrl() {
    final logoUrl = _normalizedText(_logoImage?.imageUrl);
    if (logoUrl != null) {
      return logoUrl;
    }
    final basicLogoUrl = _normalizedText(_currentBasic?.logoUrl);
    if (basicLogoUrl != null) {
      return basicLogoUrl;
    }
    if (_boardType == EnterpriseBoardType.factory) {
      for (final item in _factoryShowcaseItems) {
        final imageUrl = _normalizedText(item.imageUrl);
        if (imageUrl != null) {
          return imageUrl;
        }
      }
    }
    for (final item in _albumShowcaseItems) {
      final imageUrl = _normalizedText(item.imageUrl);
      if (imageUrl != null) {
        return imageUrl;
      }
    }
    return null;
  }

  String _companyHomepageDisplayName() {
    if (_boardType == EnterpriseBoardType.factory) {
      final boardProfile = _isPublishedChangeMode
          ? _publishedWorkbenchData?.boardProfile
          : _workbenchResult?.data?.boardProfile;
      final factoryName = boardProfile?['factoryName'];
      return _normalizedText(_factoryNameController.text) ??
          _normalizedText(factoryName is String ? factoryName : null) ??
          _enterpriseNameTruthValue() ??
          _normalizedText(_currentBasic?.name) ??
          '工厂展示资料';
    }
    return _enterpriseNameTruthValue() ??
        _normalizedText(_currentBasic?.name) ??
        '公司展示资料';
  }

  List<String> _companyHomepageTags() {
    final selected = <String>{
      ..._selectedProfileOneOptions,
      ..._selectedProfileTwoOptions,
    };
    final selectedLabels = _companyOptionLabels(selected);
    if (selectedLabels.isNotEmpty) {
      return selectedLabels;
    }
    final boardProfile = _isPublishedChangeMode
        ? _publishedWorkbenchData?.boardProfile
        : _workbenchResult?.data?.boardProfile;
    final values = <String>[];
    final keys = _boardType == EnterpriseBoardType.factory
        ? <String>['processTypes', 'coreProducts']
        : <String>['exhibitionTypes', 'serviceItems'];
    for (final key in keys) {
      final raw = boardProfile?[key];
      if (raw is List) {
        values.addAll(raw.whereType<String>());
      }
    }
    return _companyOptionLabels(values.toSet());
  }

  List<String> _companyOptionLabels(Set<String> values) {
    final options = <MapEntry<String, String>>[
      if (_boardType == EnterpriseBoardType.factory)
        ...enterpriseWorkbenchFactoryProcessOptions
      else ...<MapEntry<String, String>>[
        ...enterpriseWorkbenchCompanyExhibitionOptions,
        ...enterpriseWorkbenchCompanyServiceItemOptions,
      ],
    ];
    final labels = <String>[];
    for (final value in values) {
      final normalized = _normalizedText(value);
      if (normalized == null) {
        continue;
      }
      var matched = normalized;
      for (final option in options) {
        if (option.key == normalized) {
          matched = option.value;
          break;
        }
      }
      labels.add(matched);
    }
    return labels;
  }

  String _companyLocationSummary() {
    final locationLabel = _companyLocationLabel();
    final address =
        _normalizedText(_currentBasic?.location?.displayAddress) ??
        _normalizedText(_currentBasic?.address);
    if (locationLabel == null && address == null) {
      return '当前还没有可展示的${_companyWorkbenchSubjectLabel()}位置。';
    }
    if (locationLabel == null) {
      return address!;
    }
    if (address == null) {
      return locationLabel;
    }
    return '$locationLabel · $address';
  }

  List<String> _companyServicePreviewLines() {
    final tags = _companyHomepageTags();
    if (_boardType == EnterpriseBoardType.factory) {
      final plantArea = _normalizedText(_factoryPlantAreaController.text);
      final equipmentCount = _factoryEquipmentEntries
          .where((entry) => _normalizedText(entry.nameController.text) != null)
          .length;
      return <String>[
        if (tags.isNotEmpty) tags.take(2).join('、'),
        if (plantArea != null) '厂房面积 $plantArea㎡',
        if (equipmentCount > 0) '设备清单 $equipmentCount 项',
      ].take(3).toList(growable: false);
    }
    final teamSize = _teamSizeDisplayLabel(
      _selectedTeamSizeRange ?? _currentBasic?.teamSizeRange,
    );
    final cooperationModes = _cooperationModeDisplayLabels(
      _selectedCooperationModes.isNotEmpty
          ? _selectedCooperationModes.toList(growable: false)
          : _currentBasic?.cooperationModes ?? const <String>[],
    );
    return <String>[
      if (tags.isNotEmpty) tags.take(2).join('、'),
      if (teamSize != null) '团队规模 $teamSize',
      if (cooperationModes.isNotEmpty) cooperationModes.take(2).join('、'),
    ].take(3).toList(growable: false);
  }

  List<_FactoryHighlightLineData> _factoryHighlightLines() {
    if (_boardType != EnterpriseBoardType.factory) {
      return const <_FactoryHighlightLineData>[];
    }
    final tags = _companyHomepageTags();
    final plantArea = _normalizedText(_factoryPlantAreaController.text);
    final equipmentCount = _factoryEquipmentEntries
        .where((entry) => _normalizedText(entry.nameController.text) != null)
        .length;
    return <_FactoryHighlightLineData>[
      if (tags.isNotEmpty)
        _FactoryHighlightLineData(
          icon: Icons.handyman_outlined,
          title: '工艺能力',
          body: tags.take(3).join('、'),
        ),
      if (plantArea != null)
        _FactoryHighlightLineData(
          icon: Icons.warehouse_outlined,
          title: '厂房面积',
          body: '$plantArea㎡',
        ),
      if (equipmentCount > 0)
        _FactoryHighlightLineData(
          icon: Icons.precision_manufacturing_outlined,
          title: '设备清单',
          body: '已填写 $equipmentCount 项设备',
        ),
      if (_currentCases.isNotEmpty)
        _FactoryHighlightLineData(
          icon: Icons.folder_special_outlined,
          title: '案例沉淀',
          body: '已保存 ${_currentCases.length} 个案例',
        ),
    ];
  }

  EnterpriseHubWorkbenchContact? _companyPrimaryContact() =>
      _isPublishedChangeMode
      ? _publishedWorkbenchData?.primaryContact
      : _workbenchResult?.data?.primaryContact;

  List<_CompanyReadinessItem> _companyReadinessItems(
    EnterpriseHubWorkbenchReadiness readiness,
  ) {
    return <_CompanyReadinessItem>[
      _CompanyReadinessItem('基础资料', readiness.basicCompleted),
      _CompanyReadinessItem('展示标识', readiness.profileCompleted),
      _CompanyReadinessItem('案例', readiness.hasCase),
      _CompanyReadinessItem('联系人', readiness.hasContact),
      _CompanyReadinessItem('认证', readiness.certificationApproved),
      _CompanyReadinessItem(
        _isPublishedChangeMode ? '可提交变更' : '可提交',
        _isPublishedChangeMode
            ? _publishedWorkbenchData?.changeReadiness.submitReady == true
            : readiness.submitReady,
      ),
    ];
  }

  int _companyCompletenessPercent(EnterpriseHubWorkbenchReadiness readiness) {
    final items = <bool>[
      readiness.basicCompleted,
      readiness.profileCompleted,
      readiness.hasCase,
      readiness.hasContact,
      readiness.certificationApproved,
    ];
    final done = items.where((value) => value).length;
    return ((done / items.length) * 100).round();
  }

  _CompanyWorkbenchModule _companyFirstIncompleteModule(
    EnterpriseHubWorkbenchReadiness readiness,
  ) {
    if (!readiness.profileCompleted) {
      return _CompanyWorkbenchModule.display;
    }
    if (!readiness.basicCompleted) {
      return _CompanyWorkbenchModule.basic;
    }
    if (!readiness.hasCase) {
      return _CompanyWorkbenchModule.cases;
    }
    if (!readiness.hasContact) {
      return _CompanyWorkbenchModule.contact;
    }
    if (!readiness.certificationApproved) {
      return _CompanyWorkbenchModule.truthStatus;
    }
    return _CompanyWorkbenchModule.truthStatus;
  }

  String _companyCompletenessSuggestion(
    EnterpriseHubWorkbenchReadiness readiness,
  ) {
    if (readiness.blockers.isNotEmpty) {
      return '当前建议：${readiness.blockers.first}。';
    }
    if (!readiness.hasCase) {
      return '当前建议：补充至少 1 个真实案例，提升公开展示可信度。';
    }
    if (!readiness.hasContact) {
      return '当前建议：补齐联系人，便于审核和后续展示维护。';
    }
    return '当前建议：资料已较完整，请核对展示标识与状态后再提交。';
  }

  List<_CompanyModuleEntryData> _companyModuleEntries({
    required EnterpriseHubWorkbenchReadiness readiness,
    required bool showUpstreamTruthSection,
    required bool showCertificationSummarySection,
  }) {
    return <_CompanyModuleEntryData>[
      _CompanyModuleEntryData(
        module: _CompanyWorkbenchModule.display,
        icon: Icons.badge_outlined,
        title: '展示标识',
        description: _companyHomepageTags().isEmpty
            ? _boardType == EnterpriseBoardType.factory
                  ? 'Logo、工厂名、工艺、设备与面积'
                  : 'Logo、公司名称、展示类型、服务项目'
            : _companyHomepageTags().take(2).join('、'),
        complete: readiness.profileCompleted,
      ),
      _CompanyModuleEntryData(
        module: _CompanyWorkbenchModule.location,
        icon: Icons.location_on_outlined,
        title: '地址与服务区域',
        description: _companyLocationSummary(),
        complete:
            _normalizedText(_currentBasic?.address) != null ||
            _companyLocationLabel() != null,
      ),
      _CompanyModuleEntryData(
        module: _CompanyWorkbenchModule.album,
        icon: Icons.photo_library_outlined,
        title: _boardType == EnterpriseBoardType.factory ? '工厂照片' : '企业画册',
        description: _boardType == EnterpriseBoardType.factory
            ? (_factoryShowcaseItems.isEmpty
                  ? '当前还没有工厂照片'
                  : '已回显 ${_factoryShowcaseItems.length} 张工厂照片')
            : (_albumShowcaseItems.isEmpty
                  ? '当前还没有画册图片'
                  : '已回显 ${_albumShowcaseItems.length} 张图片'),
        complete: _boardType == EnterpriseBoardType.factory
            ? _factoryShowcaseItems.isNotEmpty
            : _albumShowcaseItems.isNotEmpty,
      ),
      _CompanyModuleEntryData(
        module: _CompanyWorkbenchModule.basic,
        icon: Icons.notes_outlined,
        title: '基础资料',
        description: '${_companyWorkbenchSubjectLabel()}介绍、团队规模、合作方式',
        complete: readiness.basicCompleted,
      ),
      _CompanyModuleEntryData(
        module: _CompanyWorkbenchModule.contact,
        icon: Icons.call_outlined,
        title: '联系人',
        description: '联系人、手机号、公开展示开关',
        complete: readiness.hasContact,
      ),
      _CompanyModuleEntryData(
        module: _CompanyWorkbenchModule.cases,
        icon: Icons.folder_copy_outlined,
        title: '案例展示',
        description: _currentCases.isEmpty
            ? '当前还没有已保存案例'
            : '已保存 ${_currentCases.length} 个案例',
        complete: readiness.hasCase,
      ),
      _CompanyModuleEntryData(
        module: _CompanyWorkbenchModule.truthStatus,
        icon: Icons.verified_user_outlined,
        title: '认证与状态',
        description: showUpstreamTruthSection || showCertificationSummarySection
            ? '存在需要核对的上游真值或认证提示'
            : '查看认证、申请与变更状态',
        complete:
            readiness.certificationApproved &&
            !showUpstreamTruthSection &&
            !showCertificationSummarySection,
      ),
    ];
  }

  String _companyModuleTitle(_CompanyWorkbenchModule module) =>
      switch (module) {
        _CompanyWorkbenchModule.display => '展示标识',
        _CompanyWorkbenchModule.location => '地址与服务区域',
        _CompanyWorkbenchModule.album =>
          _boardType == EnterpriseBoardType.factory ? '工厂照片' : '企业画册',
        _CompanyWorkbenchModule.basic => '基础资料',
        _CompanyWorkbenchModule.contact => '联系人',
        _CompanyWorkbenchModule.cases => '案例展示',
        _CompanyWorkbenchModule.truthStatus => '认证与状态',
        _CompanyWorkbenchModule.livePreview => '线上公开展示',
        _CompanyWorkbenchModule.draftPreview => '当前变更稿预览',
        _CompanyWorkbenchModule.localPreview => '当前资料预览',
      };
}
