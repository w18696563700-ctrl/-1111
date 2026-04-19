import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class ChinaCityOption {
  const ChinaCityOption({
    required this.provinceCode,
    required this.provinceName,
    required this.cityCode,
    required this.cityName,
    this.districts = const <ChinaDistrictOption>[],
  });

  final String provinceCode;
  final String provinceName;
  final String cityCode;
  final String cityName;
  final List<ChinaDistrictOption> districts;

  String get shortProvinceName => chinaRegionShortName(provinceName);

  String get shortCityName => chinaRegionShortName(cityName);

  String get displayName => '$provinceName $cityName';

  ChinaDistrictOption? districtByCode(String? districtCode) {
    final normalized = ChinaRegionCatalog._normalizedCode(districtCode);
    if (normalized == null) {
      return null;
    }
    for (final district in districts) {
      if (district.districtCode == normalized) {
        return district;
      }
    }
    return null;
  }
}

class ChinaProvinceOption {
  const ChinaProvinceOption({
    required this.provinceCode,
    required this.provinceName,
    required this.cities,
  });

  final String provinceCode;
  final String provinceName;
  final List<ChinaCityOption> cities;

  String get shortProvinceName => chinaRegionShortName(provinceName);
}

class ChinaDistrictOption {
  const ChinaDistrictOption({
    required this.districtCode,
    required this.districtName,
  });

  final String districtCode;
  final String districtName;

  String get shortDistrictName => chinaRegionShortName(districtName);
}

class ChinaRegionCatalog {
  ChinaRegionCatalog({required List<ChinaProvinceOption> provinces})
    : provinces = List<ChinaProvinceOption>.unmodifiable(provinces),
      _allCities = List<ChinaCityOption>.unmodifiable(
        provinces.expand((ChinaProvinceOption item) => item.cities),
      );

  final List<ChinaProvinceOption> provinces;
  final List<ChinaCityOption> _allCities;

  List<ChinaCityOption> get allCities => _allCities;

  ChinaProvinceOption? provinceByCode(String? provinceCode) {
    final normalized = _normalizedCode(provinceCode);
    if (normalized == null) {
      return null;
    }
    for (final province in provinces) {
      if (province.provinceCode == normalized) {
        return province;
      }
    }
    return null;
  }

  ChinaCityOption? cityByCode(String? cityCode) {
    final normalized = _normalizedCode(cityCode);
    if (normalized == null) {
      return null;
    }
    for (final city in _allCities) {
      if (city.cityCode == normalized) {
        return city;
      }
    }
    return null;
  }

  ChinaCityOption? cityByName(String? cityName) {
    final normalized = _normalizedName(cityName);
    if (normalized == null) {
      return null;
    }
    for (final city in _allCities) {
      if (city.cityName == normalized ||
          city.shortCityName == normalized ||
          city.displayName == normalized) {
        return city;
      }
    }
    return null;
  }

  String cityDisplayLabel({
    String? cityCode,
    String? fallbackCityName,
    bool useShortName = false,
  }) {
    final matched = cityByCode(cityCode);
    if (matched != null) {
      return useShortName ? matched.shortCityName : matched.cityName;
    }
    return _normalizedName(fallbackCityName) ?? '';
  }

  static ChinaRegionCatalog fromJsonMap(Map<String, Object?> payload) {
    final provinceItems = payload['provinces'];
    if (provinceItems is! List) {
      return ChinaRegionCatalog(provinces: const <ChinaProvinceOption>[]);
    }

    final provinces = <ChinaProvinceOption>[];
    for (final provinceItem in provinceItems) {
      if (provinceItem is! Map) {
        continue;
      }
      final provinceCode = _normalizedCode(provinceItem['provinceCode']);
      final provinceName = _normalizedName(provinceItem['provinceName']);
      final cityItems = provinceItem['cities'];
      if (provinceCode == null || provinceName == null || cityItems is! List) {
        continue;
      }
      final cities = <ChinaCityOption>[];
      for (final cityItem in cityItems) {
        if (cityItem is! Map) {
          continue;
        }
        final cityCode = _normalizedCode(cityItem['cityCode']);
        final cityName = _normalizedName(cityItem['cityName']);
        final districtItems = cityItem['districts'];
        if (cityCode == null || cityName == null) {
          continue;
        }
        final districts = <ChinaDistrictOption>[];
        if (districtItems is List) {
          for (final districtItem in districtItems) {
            if (districtItem is! Map) {
              continue;
            }
            final districtCode = _normalizedCode(districtItem['districtCode']);
            final districtName = _normalizedName(districtItem['districtName']);
            if (districtCode == null || districtName == null) {
              continue;
            }
            districts.add(
              ChinaDistrictOption(
                districtCode: districtCode,
                districtName: districtName,
              ),
            );
          }
        }
        cities.add(
          ChinaCityOption(
            provinceCode: provinceCode,
            provinceName: provinceName,
            cityCode: cityCode,
            cityName: cityName,
            districts: List<ChinaDistrictOption>.unmodifiable(districts),
          ),
        );
      }
      provinces.add(
        ChinaProvinceOption(
          provinceCode: provinceCode,
          provinceName: provinceName,
          cities: List<ChinaCityOption>.unmodifiable(cities),
        ),
      );
    }
    return ChinaRegionCatalog(provinces: provinces);
  }

  static String? _normalizedCode(Object? value) {
    if (value == null) {
      return null;
    }
    final normalized = value.toString().trim();
    return normalized.isEmpty ? null : normalized;
  }

  static String? _normalizedName(Object? value) {
    if (value == null) {
      return null;
    }
    final normalized = value.toString().trim();
    return normalized.isEmpty ? null : normalized;
  }
}

class ChinaRegionCatalogLoader {
  ChinaRegionCatalogLoader._();

  static Future<ChinaRegionCatalog>? _loading;
  static ChinaRegionCatalog? _cached;
  static Future<ChinaRegionCatalog> Function()? _overrideLoad;

  static Future<ChinaRegionCatalog> load() {
    final overrideLoad = _overrideLoad;
    if (overrideLoad != null) {
      return overrideLoad();
    }
    final cached = _cached;
    if (cached != null) {
      return Future<ChinaRegionCatalog>.value(cached);
    }
    return _loading ??= _read();
  }

  static void installLoadOverrideForTest(
    Future<ChinaRegionCatalog> Function() loader,
  ) {
    _overrideLoad = loader;
    _cached = null;
    _loading = null;
  }

  static void reset() {
    _cached = null;
    _loading = null;
    _overrideLoad = null;
  }

  static Future<ChinaRegionCatalog> _read() async {
    try {
      final raw = await rootBundle.loadString(
        'assets/location/china_province_city.json',
      );
      final decoded = jsonDecode(raw);
      final payload = decoded is Map<String, Object?>
          ? decoded
          : <String, Object?>{};
      final catalog = ChinaRegionCatalog.fromJsonMap(payload);
      _cached = catalog;
      return catalog;
    } catch (_) {
      _loading = null;
      rethrow;
    }
  }
}

String chinaRegionShortName(String value) {
  var result = value.trim();
  const suffixes = <String>[
    '特别行政区',
    '维吾尔自治区',
    '回族自治区',
    '壮族自治区',
    '自治区',
    '自治州',
    '地区',
    '盟',
    '省',
    '市',
  ];
  for (final suffix in suffixes) {
    if (result.endsWith(suffix) && result.length > suffix.length) {
      result = result.substring(0, result.length - suffix.length);
      break;
    }
  }
  return result;
}
