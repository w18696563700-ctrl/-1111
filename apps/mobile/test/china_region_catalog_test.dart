import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('china region asset exposes districts for prefecture cities', () async {
    final asset =
        jsonDecode(
              await File(
                'assets/location/china_province_city.json',
              ).readAsString(),
            )
            as Map<String, Object?>;

    final provinces = asset['provinces'] as List<Object?>;
    final hebei = provinces.cast<Map<String, Object?>>().firstWhere(
      (Map<String, Object?> province) => province['provinceCode'] == '130000',
    );
    final city = (hebei['cities'] as List<Object?>)
        .cast<Map<String, Object?>>()
        .firstWhere(
          (Map<String, Object?> item) => item['cityCode'] == '130100',
        );
    final districts = (city['districts'] as List<Object?>)
        .cast<Map<String, Object?>>();

    expect(city['provinceName'], '河北省');
    expect(city['cityName'], '石家庄市');
    expect(
      districts.any(
        (Map<String, Object?> district) =>
            district['districtCode'] == '130102' &&
            district['districtName'] == '长安区',
      ),
      isTrue,
    );
    expect(districts.length, greaterThan(10));
  });

  test('china region asset exposes districts for municipalities', () async {
    final asset =
        jsonDecode(
              await File(
                'assets/location/china_province_city.json',
              ).readAsString(),
            )
            as Map<String, Object?>;

    final provinces = asset['provinces'] as List<Object?>;
    final beijing = provinces.cast<Map<String, Object?>>().firstWhere(
      (Map<String, Object?> province) => province['provinceCode'] == '110000',
    );
    final city = (beijing['cities'] as List<Object?>)
        .cast<Map<String, Object?>>()
        .firstWhere(
          (Map<String, Object?> item) => item['cityCode'] == '110100',
        );
    final districts = (city['districts'] as List<Object?>)
        .cast<Map<String, Object?>>();

    expect(city['provinceName'], '北京市');
    expect(city['cityName'], '北京市');
    expect(
      districts.any(
        (Map<String, Object?> district) =>
            district['districtCode'] == '110105' &&
            district['districtName'] == '朝阳区',
      ),
      isTrue,
    );
    expect(
      districts.any(
        (Map<String, Object?> district) =>
            district['districtCode'] == '110108' &&
            district['districtName'] == '海淀区',
      ),
      isTrue,
    );
  });
}
