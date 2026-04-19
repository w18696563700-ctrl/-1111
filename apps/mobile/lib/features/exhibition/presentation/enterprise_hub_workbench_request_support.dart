part of 'enterprise_hub_workbench_pages.dart';

Map<String, Object?> enterpriseWorkbenchBasicUpdateBody({
  required String? enterpriseName,
  required String contactNameText,
  required String contactMobileText,
  required String? logoFileAssetId,
  List<String>? albumImageFileAssetIds,
  required String shortIntroText,
  required String fullIntroText,
  required String provinceCode,
  required String provinceName,
  required String cityCode,
  required String cityName,
  required String addressText,
  required String foundedAtText,
  required String? teamSizeRange,
  required Set<String> cooperationModes,
  required bool contactVisible,
  EnterpriseHubLocationData? location,
}) {
  final sortedCooperationModes = cooperationModes.toList()..sort();
  final normalizedAddress = _emptyToNull(addressText);
  return <String, Object?>{
    'name': enterpriseName,
    'contactName': _emptyToNull(contactNameText),
    'contactMobile': _emptyToNull(contactMobileText),
    'logoFileAssetId': logoFileAssetId,
    if (albumImageFileAssetIds case final List<String> value)
      'albumImageFileAssetIds': value,
    'shortIntro': _emptyToNull(shortIntroText),
    'fullIntro': _emptyToNull(fullIntroText),
    'provinceCode': provinceCode,
    'provinceName': provinceName,
    'cityCode': cityCode,
    'cityName': cityName,
    'address': normalizedAddress,
    'location': _enterpriseWorkbenchLocationUpdateBody(
      location: location,
      addressText: normalizedAddress,
      provinceCode: provinceCode,
      provinceName: provinceName,
      cityCode: cityCode,
      cityName: cityName,
    ),
    'foundedAt': _emptyToNull(foundedAtText),
    'teamSizeRange': teamSizeRange,
    'cooperationModes': sortedCooperationModes,
    'contactVisible': contactVisible,
  };
}

Map<String, Object?> _enterpriseWorkbenchLocationUpdateBody({
  required EnterpriseHubLocationData? location,
  required String? addressText,
  required String provinceCode,
  required String provinceName,
  required String cityCode,
  required String cityName,
}) {
  if (location == null) {
    if (addressText == null) {
      return const <String, Object?>{
        'geoSource': 'unknown',
        'geoStatus': 'not_provided',
      };
    }
    return <String, Object?>{
      'addressText': addressText,
      'publicDisplayAddress': addressText,
      'provinceCode': provinceCode,
      'provinceName': provinceName,
      'cityCode': cityCode,
      'cityName': cityName,
      'geoSource': 'manual_text_only',
      'geoStatus': 'text_only',
    };
  }

  return <String, Object?>{
    'addressText': addressText ?? location.addressText,
    'publicDisplayAddress':
        addressText ?? location.publicDisplayAddress ?? location.addressText,
    'provinceCode': location.provinceCode ?? provinceCode,
    'provinceName': location.provinceName ?? provinceName,
    'cityCode': location.cityCode ?? cityCode,
    'cityName': location.cityName ?? cityName,
    'districtCode': location.districtCode,
    'districtName': location.districtName,
    'latitude': location.latitude,
    'longitude': location.longitude,
    'geoSource': location.geoSource,
    'geoStatus': location.geoStatus,
    'lastGeocodedAt': location.lastGeocodedAt,
    'mapProvider': location.mapProvider,
  };
}

Map<String, Object?> enterpriseWorkbenchCaseUpdateBody({
  required String titleText,
  required String exhibitionTypeText,
  required String cityText,
  required String eventTimeText,
  required String summaryText,
  required List<String> caseMediaFileAssetIds,
  required bool isFeatured,
}) {
  final normalizedCaseMediaFileAssetIds = caseMediaFileAssetIds
      .map(_normalizedText)
      .whereType<String>()
      .toList(growable: false);
  return <String, Object?>{
    'title': titleText.trim(),
    'exhibitionType': _emptyToNull(exhibitionTypeText),
    'city': _emptyToNull(cityText),
    'eventTime': _emptyToNull(eventTimeText),
    'summary': summaryText.trim(),
    'caseCoverFileAssetId': normalizedCaseMediaFileAssetIds.isEmpty
        ? null
        : normalizedCaseMediaFileAssetIds.first,
    'caseMediaFileAssetIds': normalizedCaseMediaFileAssetIds,
    'isFeatured': isFeatured,
  };
}

Map<String, Object?> enterpriseWorkbenchCompanyProfileUpdateBody({
  required Set<String> exhibitionTypes,
  required Set<String> serviceItems,
  required String serviceCitiesText,
  required String maxProjectScaleText,
  required String qualificationDescText,
}) {
  final sortedExhibitionTypes = exhibitionTypes.toList()..sort();
  final sortedServiceItems = serviceItems.toList()..sort();
  return <String, Object?>{
    'exhibitionTypes': sortedExhibitionTypes,
    'serviceItems': sortedServiceItems,
    'serviceCities': _csvList(serviceCitiesText),
    'maxProjectScale': _emptyToNull(maxProjectScaleText),
    'qualificationDesc': _emptyToNull(qualificationDescText),
  };
}

Map<String, Object?> _enterpriseWorkbenchFactoryProfileUpdateBody({
  required String factoryNameText,
  required Set<String> processTypes,
  required String coreProductsText,
  required List<_FactoryEquipmentEntry> equipmentEntries,
  required List<_WorkbenchImageItem> showcaseItems,
  required String plantAreaText,
  required String monthlyCapacityDescText,
  required String? urgentCapability,
  required String urgentCycleText,
  required String? transportCapability,
  required bool? warehouseCapability,
  required String maxOrderCapacityText,
  required String productionQualificationText,
  required String deliveryRadiusText,
}) {
  final sortedProcessTypes = processTypes.toList()..sort();
  return <String, Object?>{
    'factoryName': _emptyToNull(factoryNameText),
    'processTypes': sortedProcessTypes,
    'coreProducts': _csvList(coreProductsText),
    'equipmentList': _serializeFactoryEquipmentEntries(equipmentEntries),
    'showcaseImageFileAssetIds': _confirmedImageIds(showcaseItems),
    'plantAreaSqm': _nullableInt(plantAreaText),
    'monthlyCapacityDesc': _emptyToNull(monthlyCapacityDescText),
    'urgentOrderCapability': urgentCapability,
    'urgentCycleDesc': _emptyToNull(urgentCycleText),
    'transportCapability': transportCapability,
    'warehouseCapability': warehouseCapability,
    'maxOrderCapacityDesc': _emptyToNull(maxOrderCapacityText),
    'productionQualificationDesc': _emptyToNull(productionQualificationText),
    'deliveryRadiusDesc': _emptyToNull(deliveryRadiusText),
  };
}

bool enterpriseWorkbenchShouldHydrateBoardProfileFromWorkbench({
  required bool hasPendingLocalProfileDraft,
}) {
  return !hasPendingLocalProfileDraft;
}

String? _emptyToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

List<String> _csvList(String value) => value
    .split(',')
    .map((item) => item.trim())
    .where((item) => item.isNotEmpty)
    .toList(growable: false);

String _joinList([Object? a, Object? b, Object? c]) {
  final values = <String>[];
  for (final raw in <Object?>[a, b, c]) {
    if (raw is List) {
      values.addAll(raw.whereType<String>());
      break;
    }
  }
  return values.join(',');
}

String _stringValue([Object? a, Object? b, Object? c]) {
  for (final raw in <Object?>[a, b, c]) {
    if (raw is String && raw.trim().isNotEmpty) {
      return raw.trim();
    }
  }
  return '';
}

String _scalarStringValue(Object? raw) {
  if (raw is num) {
    return raw.toString();
  }
  if (raw is String && raw.trim().isNotEmpty) {
    return raw.trim();
  }
  return '';
}

List<_FactoryEquipmentEntry> _parseFactoryEquipmentEntries(Object? raw) {
  final entries = _readStringList(raw)
      .map(_FactoryEquipmentEntry.fromStorage)
      .where((item) => item.hasValue)
      .toList(growable: false);
  if (entries.isEmpty) {
    return <_FactoryEquipmentEntry>[_FactoryEquipmentEntry()];
  }
  return entries;
}

List<String> _serializeFactoryEquipmentEntries(
  List<_FactoryEquipmentEntry> entries,
) {
  return entries
      .map((item) => item.toStorageValue())
      .whereType<String>()
      .toList(growable: false);
}

int? _nullableInt(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  return int.tryParse(trimmed);
}

List<String> _readStringList(Object? raw) {
  if (raw is! List) {
    return const <String>[];
  }
  return raw
      .whereType<String>()
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

Map<String, String> _readStringMap(Object? raw) {
  if (raw is! Map) {
    return const <String, String>{};
  }
  final result = <String, String>{};
  for (final entry in raw.entries) {
    final key = '${entry.key}'.trim();
    final value = entry.value is String ? (entry.value as String).trim() : '';
    if (key.isEmpty || value.isEmpty) {
      continue;
    }
    result[key] = value;
  }
  return result;
}

List<String> _confirmedImageIds(List<_WorkbenchImageItem> items) {
  return items
      .map((item) => item.fileAssetId?.trim())
      .whereType<String>()
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

MyOrganizationItemView? _currentOrganization(
  MyOrganizationsView? organizations,
  AppShellContextData shellContext,
) {
  final items = organizations?.items;
  if (items == null || items.isEmpty) {
    return null;
  }
  final currentId = shellContext.organizationId?.trim();
  for (final item in items) {
    if (item.current) {
      return item;
    }
    if (currentId != null &&
        currentId.isNotEmpty &&
        item.organizationId == currentId) {
      return item;
    }
  }
  return items.first;
}

String _cityDisplayLabel({
  required ChinaRegionCatalog regionCatalog,
  required String? cityCode,
  String? fallbackProvinceName,
  String? fallbackCityName,
}) {
  final option = regionCatalog.cityByCode(cityCode);
  if (option != null) {
    return '${option.provinceName} / ${option.cityName}';
  }
  final provinceName = _normalizedText(fallbackProvinceName);
  final cityName = _normalizedText(fallbackCityName);
  if (provinceName == null && cityName == null) {
    return '';
  }
  if (provinceName == null) {
    return cityName!;
  }
  if (cityName == null) {
    return provinceName;
  }
  return '$provinceName / $cityName';
}

InputDecoration _fieldDecoration({
  required String label,
  required bool required,
  String? helperText,
  String? hintText,
  InputBorder border = const OutlineInputBorder(),
  bool alignLabelWithHint = false,
}) {
  return InputDecoration(
    label: _buildFieldLabel(label, required: required),
    helperText: helperText,
    hintText: hintText,
    border: border,
    alignLabelWithHint: alignLabelWithHint,
  );
}

Widget _buildFieldLabel(String label, {required bool required}) {
  if (!required) {
    return Text(label);
  }
  return Builder(
    builder: (context) => Text.rich(
      TextSpan(
        style: Theme.of(context).inputDecorationTheme.labelStyle,
        children: <InlineSpan>[
          TextSpan(
            text: '* ',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          TextSpan(text: label),
        ],
      ),
    ),
  );
}

String? _normalizedText(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
