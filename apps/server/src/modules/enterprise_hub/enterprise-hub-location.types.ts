export type EnterpriseHubLocationResolveMode =
  | 'device_location'
  | 'manual_address';

export type EnterpriseHubLocationGeoSource =
  | 'device_location'
  | 'manual_address_geocode'
  | 'manual_text_only'
  | 'unknown';

export type EnterpriseHubLocationGeoStatus =
  | 'resolved'
  | 'text_only'
  | 'failed'
  | 'not_provided';

export type EnterpriseHubLocationMapProvider = 'amap';

export type EnterpriseHubLocationTruth = {
  addressText: string | null;
  publicDisplayAddress: string | null;
  provinceCode: string | null;
  provinceName: string | null;
  cityCode: string | null;
  cityName: string | null;
  districtCode: string | null;
  districtName: string | null;
  latitude: number | null;
  longitude: number | null;
  geoSource: EnterpriseHubLocationGeoSource;
  geoStatus: EnterpriseHubLocationGeoStatus;
  lastGeocodedAt: string | null;
  mapProvider: EnterpriseHubLocationMapProvider | null;
  mapPreviewUrl: string | null;
  mapLinkUrl: string | null;
};

export type EnterpriseHubLocationFallback = {
  addressText: string | null;
  provinceCode: string | null;
  provinceName: string | null;
  cityCode: string | null;
  cityName: string | null;
};

export type EnterpriseHubResolvedAmapLocation = {
  formattedAddress: string | null;
  provinceName: string | null;
  cityName: string | null;
  districtName: string | null;
  adcode: string | null;
  latitude: number;
  longitude: number;
};

export type EnterpriseHubReverseAmapLocation = {
  formattedAddress: string | null;
  provinceName: string | null;
  cityName: string | null;
  districtName: string | null;
  adcode: string | null;
};
