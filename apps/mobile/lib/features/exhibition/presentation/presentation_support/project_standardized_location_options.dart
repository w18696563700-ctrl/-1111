part of '../exhibition_trade_pages.dart';

const List<_ProjectStandardizedLocationOption>
_projectStandardizedLocationOptions = <_ProjectStandardizedLocationOption>[
  _ProjectStandardizedLocationOption(
    provinceCode: '510000',
    provinceName: '四川',
    cityCode: '510100',
    cityName: '成都',
    districts: <_ProjectStandardizedLocationDistrictOption>[
      _ProjectStandardizedLocationDistrictOption(
        districtCode: '510104',
        districtName: '锦江区',
      ),
      _ProjectStandardizedLocationDistrictOption(
        districtCode: '510107',
        districtName: '武侯区',
      ),
      _ProjectStandardizedLocationDistrictOption(
        districtCode: '510108',
        districtName: '成华区',
      ),
    ],
  ),
  _ProjectStandardizedLocationOption(
    provinceCode: '500000',
    provinceName: '重庆',
    cityCode: '500100',
    cityName: '重庆',
    districts: <_ProjectStandardizedLocationDistrictOption>[
      _ProjectStandardizedLocationDistrictOption(
        districtCode: '500103',
        districtName: '渝中区',
      ),
      _ProjectStandardizedLocationDistrictOption(
        districtCode: '500108',
        districtName: '南岸区',
      ),
      _ProjectStandardizedLocationDistrictOption(
        districtCode: '500112',
        districtName: '渝北区',
      ),
    ],
  ),
  _ProjectStandardizedLocationOption(
    provinceCode: '310000',
    provinceName: '上海',
    cityCode: '310100',
    cityName: '上海',
    districts: <_ProjectStandardizedLocationDistrictOption>[
      _ProjectStandardizedLocationDistrictOption(
        districtCode: '310104',
        districtName: '徐汇区',
      ),
      _ProjectStandardizedLocationDistrictOption(
        districtCode: '310112',
        districtName: '闵行区',
      ),
      _ProjectStandardizedLocationDistrictOption(
        districtCode: '310115',
        districtName: '浦东新区',
      ),
    ],
  ),
  _ProjectStandardizedLocationOption(
    provinceCode: '440000',
    provinceName: '广东',
    cityCode: '440100',
    cityName: '广州',
    districts: <_ProjectStandardizedLocationDistrictOption>[
      _ProjectStandardizedLocationDistrictOption(
        districtCode: '440105',
        districtName: '海珠区',
      ),
      _ProjectStandardizedLocationDistrictOption(
        districtCode: '440106',
        districtName: '天河区',
      ),
      _ProjectStandardizedLocationDistrictOption(
        districtCode: '440111',
        districtName: '白云区',
      ),
    ],
  ),
  _ProjectStandardizedLocationOption(
    provinceCode: '440000',
    provinceName: '广东',
    cityCode: '440300',
    cityName: '深圳',
    districts: <_ProjectStandardizedLocationDistrictOption>[
      _ProjectStandardizedLocationDistrictOption(
        districtCode: '440304',
        districtName: '福田区',
      ),
      _ProjectStandardizedLocationDistrictOption(
        districtCode: '440305',
        districtName: '南山区',
      ),
      _ProjectStandardizedLocationDistrictOption(
        districtCode: '440306',
        districtName: '宝安区',
      ),
    ],
  ),
  _ProjectStandardizedLocationOption(
    provinceCode: '110000',
    provinceName: '北京',
    cityCode: '110100',
    cityName: '北京',
    districts: <_ProjectStandardizedLocationDistrictOption>[
      _ProjectStandardizedLocationDistrictOption(
        districtCode: '110105',
        districtName: '朝阳区',
      ),
      _ProjectStandardizedLocationDistrictOption(
        districtCode: '110106',
        districtName: '丰台区',
      ),
      _ProjectStandardizedLocationDistrictOption(
        districtCode: '110108',
        districtName: '海淀区',
      ),
    ],
  ),
  _ProjectStandardizedLocationOption(
    provinceCode: '320000',
    provinceName: '江苏',
    cityCode: '320100',
    cityName: '南京',
    districts: <_ProjectStandardizedLocationDistrictOption>[
      _ProjectStandardizedLocationDistrictOption(
        districtCode: '320105',
        districtName: '建邺区',
      ),
      _ProjectStandardizedLocationDistrictOption(
        districtCode: '320106',
        districtName: '鼓楼区',
      ),
      _ProjectStandardizedLocationDistrictOption(
        districtCode: '320115',
        districtName: '江宁区',
      ),
    ],
  ),
  _ProjectStandardizedLocationOption(
    provinceCode: '330000',
    provinceName: '浙江',
    cityCode: '330100',
    cityName: '杭州',
    districts: <_ProjectStandardizedLocationDistrictOption>[
      _ProjectStandardizedLocationDistrictOption(
        districtCode: '330106',
        districtName: '西湖区',
      ),
      _ProjectStandardizedLocationDistrictOption(
        districtCode: '330108',
        districtName: '滨江区',
      ),
      _ProjectStandardizedLocationDistrictOption(
        districtCode: '330109',
        districtName: '萧山区',
      ),
    ],
  ),
];

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
