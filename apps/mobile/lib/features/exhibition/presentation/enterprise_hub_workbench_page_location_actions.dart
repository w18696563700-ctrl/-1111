part of 'enterprise_hub_workbench_pages.dart';

extension _EnterpriseWorkbenchPageLocationActions
    on _EnterpriseApplicationPageState {
  Future<void> _fillAddressFromCurrentLocation() async {
    _updateWorkbenchState(() => _resolvingLocation = true);
    try {
      final location = await DeviceLocationService.instance
          .resolveCurrentPosition();
      if (!mounted) return;
      if (!location.hasCoordinates) {
        _showWorkbenchMessage(location.errorMessage ?? '当前定位不可用。');
        return;
      }

      final fallbackAddress = _locationFallbackAddress(location);
      final result = await EnterpriseHubConsumerLayer.instance.resolveLocation(
        body: <String, Object?>{
          'resolveMode': 'device_location',
          'latitude': location.latitude,
          'longitude': location.longitude,
          'addressText':
              _emptyToNull(_addressController.text) ?? fallbackAddress,
          ..._enterpriseLocationResolveContext(),
        },
      );
      if (!mounted) return;
      if (!result.isSuccess || result.data == null) {
        _showWorkbenchMessage(
          enterpriseLocationResolveVisibleMessage(
            errorCode: result.errorCode,
            fallbackMessage: result.message,
          ),
        );
        return;
      }
      _applyResolvedLocationDraft(
        result.data!,
        fallbackMessage: result.message ?? '已按当前位置解析企业位置。',
      );
    } finally {
      if (mounted) {
        _updateWorkbenchState(() => _resolvingLocation = false);
      }
    }
  }

  Future<void> _resolveManualAddress() async {
    final addressText = _emptyToNull(_addressController.text);
    if (addressText == null) {
      _showWorkbenchMessage('请先填写位置补充说明，再解析文字地址。');
      return;
    }

    _updateWorkbenchState(() => _resolvingLocation = true);
    try {
      final result = await EnterpriseHubConsumerLayer.instance.resolveLocation(
        body: <String, Object?>{
          'resolveMode': 'manual_address',
          'addressText': addressText,
          ..._enterpriseLocationResolveContext(),
        },
      );
      if (!mounted) return;
      if (!result.isSuccess || result.data == null) {
        _showWorkbenchMessage(
          enterpriseLocationResolveVisibleMessage(
            errorCode: result.errorCode,
            fallbackMessage: result.message,
          ),
        );
        return;
      }
      _applyResolvedLocationDraft(
        result.data!,
        fallbackMessage: result.message ?? '文字地址已解析为企业位置候选。',
      );
    } finally {
      if (mounted) {
        _updateWorkbenchState(() => _resolvingLocation = false);
      }
    }
  }

  void _applyResolvedLocationDraft(
    EnterpriseHubLocationData location, {
    required String fallbackMessage,
  }) {
    _updateWorkbenchState(() {
      _resolvedLocationDraft = location;
      final resolvedAddress = location.displayAddress;
      if (resolvedAddress != null) {
        _addressController.text = resolvedAddress;
      }
      _locationStatusMessage = fallbackMessage;
    });
  }

  void _handleAddressTextChanged(String value) {
    final current = _resolvedLocationDraft;
    if (current == null) {
      return;
    }
    final normalized = _emptyToNull(value);
    if (current.geoSource == 'device_location') {
      _updateWorkbenchState(() {
        _resolvedLocationDraft = current.copyWith(
          addressText: normalized,
          publicDisplayAddress: normalized,
        );
        _locationStatusMessage = '位置补充说明已更新，当前位置坐标仍会随保存进入企业位置真值。';
      });
      return;
    }

    _updateWorkbenchState(() {
      _resolvedLocationDraft = null;
      _locationStatusMessage = '位置补充说明已变更，请重新解析文字地址；也可以直接保存为文字地址。';
    });
  }

  Map<String, Object?> _enterpriseLocationResolveContext() {
    final city = _regionCatalog?.cityByCode(_selectedCityCode);
    final basicTruth = _currentBasic;
    return <String, Object?>{
      'provinceCode':
          city?.provinceCode ?? _normalizedText(basicTruth?.provinceCode),
      'provinceName':
          city?.provinceName ?? _normalizedText(basicTruth?.provinceName),
      'cityCode': city?.cityCode ?? _normalizedText(basicTruth?.cityCode),
      'cityName': city?.cityName ?? _normalizedText(basicTruth?.cityName),
    };
  }
}
