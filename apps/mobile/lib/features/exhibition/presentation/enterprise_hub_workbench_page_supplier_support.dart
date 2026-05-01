part of 'enterprise_hub_workbench_pages.dart';

extension _EnterpriseWorkbenchSupplierSupport
    on _EnterpriseApplicationPageState {
  String _supplierStatusLabel({
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
    if (readiness.submitReady) {
      return '资料已齐，可提交申请。';
    }
    return '资料待完善。';
  }

  String? _supplierHeroImageUrl() {
    final logoUrl = _normalizedText(_logoImage?.imageUrl);
    if (logoUrl != null) {
      return logoUrl;
    }
    final basicLogoUrl = _normalizedText(_currentBasic?.logoUrl);
    if (basicLogoUrl != null) {
      return basicLogoUrl;
    }
    for (final item in _albumShowcaseItems) {
      final imageUrl = _normalizedText(item.imageUrl);
      if (imageUrl != null) {
        return imageUrl;
      }
    }
    return null;
  }

  String _supplierHomepageDisplayName() {
    return _normalizedText(_currentBasic?.name) ??
        _enterpriseNameTruthValue() ??
        '供应商展示资料';
  }

  List<String> _supplierHomepageTags() {
    final tags = _supplierOptionLabels(_selectedProfileOneOptions);
    if (tags.isNotEmpty) {
      return tags;
    }
    final boardProfile = _isPublishedChangeMode
        ? _publishedWorkbenchData?.boardProfile
        : _workbenchResult?.data?.boardProfile;
    final rawCategories = boardProfile?['supplyCategories'];
    if (rawCategories is List) {
      return _supplierOptionLabels(rawCategories.whereType<String>().toSet());
    }
    return const <String>[];
  }

  List<String> _supplierOptionLabels(Set<String> values) {
    final labels = <String>[];
    for (final value in values) {
      final normalized = _normalizedText(value);
      if (normalized == null) {
        continue;
      }
      var matched = normalized;
      for (final option in enterpriseWorkbenchSupplierCategoryOptions) {
        if (option.key == normalized) {
          matched = option.value;
          break;
        }
      }
      labels.add(matched);
    }
    return labels;
  }

  String _supplierLocationSummary() {
    final locationLabel = _companyLocationLabel();
    final address =
        _normalizedText(_currentBasic?.location?.displayAddress) ??
        _normalizedText(_currentBasic?.address);
    if (locationLabel == null && address == null) {
      return '当前还没有可展示的企业位置。';
    }
    if (locationLabel == null) {
      return address!;
    }
    if (address == null) {
      return locationLabel;
    }
    return '$locationLabel · $address';
  }

  List<String> _supplierServicePreviewLines() {
    final lines = <String>[];
    final tags = _supplierHomepageTags();
    if (tags.isNotEmpty) {
      lines.add(tags.take(2).join('、'));
    }
    final coreProducts = _normalizedText(_profileThreeController.text);
    if (coreProducts != null) {
      lines.add(coreProducts);
    }
    final response = _normalizedText(_profileFourController.text);
    if (response != null) {
      lines.add(response);
    }
    final delivery = _normalizedText(_profileFiveController.text);
    if (delivery != null) {
      lines.add(delivery);
    }
    return lines.take(3).toList(growable: false);
  }
}
