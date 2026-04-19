export type EnterpriseHubPublishedChangeLocation = {
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
  geoSource:
    | 'device_location'
    | 'manual_address_geocode'
    | 'manual_text_only'
    | 'unknown';
  geoStatus: 'resolved' | 'text_only' | 'failed' | 'not_provided';
  lastGeocodedAt: string | null;
  mapProvider: 'amap' | null;
  mapPreviewUrl: string | null;
  mapLinkUrl: string | null;
};

export type EnterpriseHubPublishedChangeBasic = {
  name: string | null;
  logoFileAssetId: string | null;
  coverFileAssetId: string | null;
  logoUrl: string | null;
  albumImageFileAssetIds: string[];
  albumImageUrlMap: Record<string, string>;
  shortIntro: string | null;
  fullIntro: string | null;
  provinceCode: string | null;
  provinceName: string | null;
  cityCode: string | null;
  cityName: string | null;
  address: string | null;
  location: EnterpriseHubPublishedChangeLocation;
  foundedAt: string | null;
  teamSizeRange: string | null;
  cooperationModes: string[];
  contactVisible: boolean;
};

export type EnterpriseHubPublishedChangePrimaryContact = {
  contactName: string;
  mobile: string | null;
  wechat: string | null;
  phone: string | null;
  email: string | null;
  position: string | null;
  isPrimary: boolean;
  visibleToPublic: boolean;
};

export type EnterpriseHubPublishedChangeCase = {
  caseId: string;
  boardType: string;
  title: string;
  exhibitionType: string | null;
  city: string | null;
  eventTime: string | null;
  summary: string;
  caseCoverFileAssetId: string | null;
  caseMediaFileAssetIds: string[];
  caseImageUrlMap: Record<string, string>;
  isFeatured: boolean;
  caseStatus: string;
};

export type EnterpriseHubPublishedChangeSnapshot = {
  basic: EnterpriseHubPublishedChangeBasic;
  boardProfile: Record<string, unknown> | null;
  primaryContact: EnterpriseHubPublishedChangePrimaryContact | null;
  cases: EnterpriseHubPublishedChangeCase[];
};
