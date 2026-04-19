import 'package:mobile/core/location/china_region_catalog.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_consumer_layer.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_board_surface.dart';

class EnterpriseHubCityOption {
  const EnterpriseHubCityOption({
    required this.provinceCode,
    required this.provinceName,
    required this.cityCode,
    required this.cityName,
    required this.displayName,
  });

  final String provinceCode;
  final String provinceName;
  final String cityCode;
  final String cityName;
  final String displayName;
}

const List<EnterpriseBoardFilterOption>
enterpriseHubFactoryAreaOptions = <EnterpriseBoardFilterOption>[
  EnterpriseBoardFilterOption(label: '500㎡以下', value: 'under_500'),
  EnterpriseBoardFilterOption(label: '500-1199㎡', value: 'from_500_to_1199'),
  EnterpriseBoardFilterOption(label: '1200-1999㎡', value: 'from_1200_to_1999'),
  EnterpriseBoardFilterOption(label: '2000-3499㎡', value: 'from_2000_to_3499'),
  EnterpriseBoardFilterOption(label: '3500㎡以上', value: 'over_3500'),
];

List<EnterpriseHubCityOption> enterpriseHubCityOptions(
  ChinaRegionCatalog? catalog,
) {
  if (catalog == null) {
    return const <EnterpriseHubCityOption>[];
  }
  return catalog.allCities
      .map(
        (ChinaCityOption city) => EnterpriseHubCityOption(
          provinceCode: city.provinceCode,
          provinceName: city.provinceName,
          cityCode: city.cityCode,
          cityName: city.cityName,
          displayName: city.shortCityName,
        ),
      )
      .toList(growable: false);
}

EnterpriseHubCityOption? enterpriseHubCityOptionByCode(
  ChinaRegionCatalog? catalog,
  String? cityCode,
) {
  final matched = catalog?.cityByCode(cityCode);
  if (matched == null) {
    return null;
  }
  return EnterpriseHubCityOption(
    provinceCode: matched.provinceCode,
    provinceName: matched.provinceName,
    cityCode: matched.cityCode,
    cityName: matched.cityName,
    displayName: matched.shortCityName,
  );
}

List<EnterpriseHubCityOption> enterpriseHubCityOptionsFromListItems(
  List<EnterpriseHubListItem> items,
) {
  final seen = <String>{};
  final options = <EnterpriseHubCityOption>[];
  for (final item in items) {
    final provinceCode = item.provinceCode?.trim();
    final cityCode = item.cityCode?.trim();
    if (provinceCode == null ||
        provinceCode.isEmpty ||
        cityCode == null ||
        cityCode.isEmpty) {
      continue;
    }
    final dedupeKey = '$provinceCode::$cityCode';
    if (!seen.add(dedupeKey)) {
      continue;
    }
    options.add(
      EnterpriseHubCityOption(
        provinceCode: provinceCode,
        provinceName: item.provinceName,
        cityCode: cityCode,
        cityName: item.cityName,
        displayName: chinaRegionShortName(item.cityName),
      ),
    );
  }
  options.sort((left, right) => left.displayName.compareTo(right.displayName));
  return options;
}

EnterpriseHubCityOption? enterpriseHubCityOptionByCodeFromOptions(
  List<EnterpriseHubCityOption> options,
  String? cityCode,
) {
  final normalized = cityCode?.trim();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }
  for (final option in options) {
    if (option.cityCode == normalized) {
      return option;
    }
  }
  return null;
}
