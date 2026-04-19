part of '../exhibition_trade_pages.dart';

class _ProjectStandardizedLocationOption {
  const _ProjectStandardizedLocationOption({
    required this.provinceCode,
    required this.provinceName,
    required this.cityCode,
    required this.cityName,
    this.districts = const <_ProjectStandardizedLocationDistrictOption>[],
  });

  final String provinceCode;
  final String provinceName;
  final String cityCode;
  final String cityName;
  final List<_ProjectStandardizedLocationDistrictOption> districts;

  String get displayLabel => '$provinceName / $cityName';

  String get pickerDescription => districts.isEmpty ? '可直接填写详细地址' : '可继续补充区/县';

  _ProjectStandardizedLocationDistrictOption? districtByCode(String? code) {
    if (code == null) {
      return null;
    }

    for (final district in districts) {
      if (district.districtCode == code) {
        return district;
      }
    }
    return null;
  }
}

class _ProjectStandardizedLocationDistrictOption {
  const _ProjectStandardizedLocationDistrictOption({
    required this.districtCode,
    required this.districtName,
  });

  final String districtCode;
  final String districtName;
}

_ProjectStandardizedLocationOption _projectLocationOptionFromChinaCity(
  ChinaCityOption city,
) {
  return _ProjectStandardizedLocationOption(
    provinceCode: city.provinceCode,
    provinceName: city.provinceName,
    cityCode: city.cityCode,
    cityName: city.cityName,
    districts: city.districts
        .map(
          (ChinaDistrictOption district) =>
              _ProjectStandardizedLocationDistrictOption(
                districtCode: district.districtCode,
                districtName: district.districtName,
              ),
        )
        .toList(growable: false),
  );
}
