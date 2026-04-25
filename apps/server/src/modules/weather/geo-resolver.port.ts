import type { GeoLookupRequest, ResolvedGeoLocation } from './weather.types';

export const GEO_RESOLVER = Symbol('GEO_RESOLVER');

export interface GeoResolver {
  resolve(request: GeoLookupRequest): Promise<ResolvedGeoLocation | null>;
}
