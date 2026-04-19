export function inferEnterpriseHubRegionFromAddress(addressText: string) {
  const normalized = addressText.trim();
  const municipality = readMunicipality(normalized);
  if (municipality) {
    return {
      provinceCode: municipality.provinceCode,
      provinceName: municipality.name,
      cityCode: municipality.cityCode,
      cityName: municipality.name,
      districtCode: null,
      districtName: readDistrictName(normalized),
    };
  }

  const provinceName = normalized.match(/^(.+?省)/)?.[1] ?? null;
  const cityName = normalized.match(/^.+?(?:省)?(.+?市)/)?.[1] ?? null;
  return {
    provinceCode: null,
    provinceName,
    cityCode: null,
    cityName,
    districtCode: null,
    districtName: readDistrictName(normalized),
  };
}

function readMunicipality(addressText: string) {
  const candidates = [
    { name: '北京市', provinceCode: '110000', cityCode: '110100' },
    { name: '天津市', provinceCode: '120000', cityCode: '120100' },
    { name: '上海市', provinceCode: '310000', cityCode: '310100' },
    { name: '重庆市', provinceCode: '500000', cityCode: '500100' },
  ];
  return candidates.find((item) => addressText.startsWith(item.name)) ?? null;
}

function readDistrictName(addressText: string) {
  return addressText.match(/(.*?(?:区|县|旗))/)?.[1] ?? null;
}
