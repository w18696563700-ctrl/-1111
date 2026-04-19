import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { InjectRepository } from '@nestjs/typeorm';
import { EntityManager, Repository } from 'typeorm';
import { OrganizationCertificationEntity } from '../organization/entities/organization-certification.entity';
import { inferEnterpriseHubRegionFromAddress } from './enterprise-hub-address-region-truth';
import { EnterpriseHubAmapLocationProviderService } from './enterprise-hub-amap-location-provider.service';
import { deriveCityCode, deriveProvinceCode } from './enterprise-hub-location-reader';
import { EnterpriseHubLocationService } from './enterprise-hub-location.service';
import { EnterpriseHubLocationTruth } from './enterprise-hub-location.types';
import { EnterpriseCertificationSnapshotEntity } from './entities/enterprise-certification-snapshot.entity';
import { EnterpriseListingEntity } from './entities/enterprise-listing.entity';

@Injectable()
export class EnterpriseHubCertificationSyncService {
  constructor(
    @InjectRepository(OrganizationCertificationEntity)
    private readonly organizationCertificationRepository: Repository<OrganizationCertificationEntity>,
    @InjectRepository(EnterpriseCertificationSnapshotEntity)
    private readonly enterpriseCertificationRepository: Repository<EnterpriseCertificationSnapshotEntity>,
    @InjectRepository(EnterpriseListingEntity)
    private readonly listingRepository: Repository<EnterpriseListingEntity>,
    private readonly locationService: EnterpriseHubLocationService,
    private readonly amapLocationProvider: EnterpriseHubAmapLocationProviderService,
  ) {}

  async syncForListing(listing: EnterpriseListingEntity, manager?: EntityManager) {
    const repositories = this.resolveRepositories(manager);
    const certification = await repositories.organizationCertificationRepository.findOne({
      where: { organizationId: listing.organizationId },
      order: { updatedAt: 'DESC', createdAt: 'DESC' },
    });
    return this.syncListingWithCertification(listing, certification, repositories);
  }

  async syncOrganizationListings(organizationId: string, manager?: EntityManager) {
    const repositories = this.resolveRepositories(manager);
    const certification = await repositories.organizationCertificationRepository.findOne({
      where: { organizationId },
      order: { updatedAt: 'DESC', createdAt: 'DESC' },
    });
    const listings = await repositories.listingRepository.findBy({ organizationId });
    for (const listing of listings) {
      await this.syncListingWithCertification(listing, certification, repositories);
    }
  }

  async syncListingWithResolvedCertification(
    listing: EnterpriseListingEntity,
    certification: OrganizationCertificationEntity | null,
    manager?: EntityManager,
  ) {
    const repositories = this.resolveRepositories(manager);
    return this.syncListingWithCertification(listing, certification, repositories);
  }

  private resolveRepositories(manager?: EntityManager) {
    return {
      organizationCertificationRepository:
        manager?.getRepository(OrganizationCertificationEntity) ??
        this.organizationCertificationRepository,
      enterpriseCertificationRepository:
        manager?.getRepository(EnterpriseCertificationSnapshotEntity) ??
        this.enterpriseCertificationRepository,
      listingRepository:
        manager?.getRepository(EnterpriseListingEntity) ?? this.listingRepository,
    };
  }

  private async syncListingWithCertification(
    listing: EnterpriseListingEntity,
    certification: OrganizationCertificationEntity | null,
    repositories: {
      organizationCertificationRepository: Repository<OrganizationCertificationEntity>;
      enterpriseCertificationRepository: Repository<EnterpriseCertificationSnapshotEntity>;
      listingRepository: Repository<EnterpriseListingEntity>;
    },
  ) {
    const certifiedLegalName = certification?.legalName?.trim() ?? '';
    listing.legalNameSnapshot = certifiedLegalName || null;
    listing.unifiedSocialCreditCodeSnapshot = certification?.uscc ?? null;
    listing.verificationStatusSnapshot = this.toListingVerificationStatus(
      certification?.certificationStatus ?? null,
    );
    if (certifiedLegalName.length > 0) {
      listing.name = certifiedLegalName;
    }
    await this.applyCertificationLocationTruth(listing, certification);
    await repositories.listingRepository.save(listing);

    if (!certification) {
      await repositories.enterpriseCertificationRepository.delete({
        enterpriseId: listing.id,
        certificationType: 'business_license',
      });
      return null;
    }

    const existingSnapshot = await repositories.enterpriseCertificationRepository.findOne({
      where: {
        enterpriseId: listing.id,
        certificationType: 'business_license',
      },
      order: { id: 'ASC' },
    });
    const snapshot = repositories.enterpriseCertificationRepository.create({
      ...(existingSnapshot ?? {
        id: randomUUID(),
        enterpriseId: listing.id,
        certificationType: 'business_license',
      }),
      certificationName: '营业执照',
      certificationFileAssetId: certification.licenseFileId,
      certStatus: this.toEnterpriseCertStatus(certification.certificationStatus),
      reviewerId: certification.reviewedBy,
      reviewNote: certification.rejectReason,
      verifiedAt: certification.reviewedAt,
    });
    await repositories.enterpriseCertificationRepository.save(snapshot);
    return snapshot;
  }

  private async applyCertificationLocationTruth(
    listing: EnterpriseListingEntity,
    certification: OrganizationCertificationEntity | null,
  ) {
    const certifiedAddress =
      certification?.certificationStatus === 'approved'
        ? certification.address?.trim() ?? ''
        : '';
    if (certifiedAddress.length === 0) {
      return;
    }

    const inferredRegion = inferEnterpriseHubRegionFromAddress(certifiedAddress);
    const geocoded = await this.tryGeocodeCertificationAddress(
      certifiedAddress,
      inferredRegion.cityName,
    );
    const location: EnterpriseHubLocationTruth = geocoded
      ? {
          addressText: certifiedAddress,
          publicDisplayAddress: certifiedAddress,
          provinceCode:
            deriveProvinceCode(geocoded.adcode) ?? inferredRegion.provinceCode,
          provinceName: geocoded.provinceName ?? inferredRegion.provinceName,
          cityCode: deriveCityCode(geocoded.adcode) ?? inferredRegion.cityCode,
          cityName: geocoded.cityName ?? inferredRegion.cityName,
          districtCode: geocoded.adcode ?? inferredRegion.districtCode,
          districtName: geocoded.districtName ?? inferredRegion.districtName,
          latitude: geocoded.latitude,
          longitude: geocoded.longitude,
          geoSource: 'manual_address_geocode',
          geoStatus: 'resolved',
          lastGeocodedAt: new Date().toISOString(),
          mapProvider: 'amap',
          mapPreviewUrl: this.amapLocationProvider.buildMapPreviewUrl(
            geocoded.latitude,
            geocoded.longitude,
          ),
          mapLinkUrl: this.amapLocationProvider.buildMapLinkUrl(
            geocoded.latitude,
            geocoded.longitude,
            certifiedAddress,
          ),
        }
      : {
          addressText: certifiedAddress,
          publicDisplayAddress: certifiedAddress,
          provinceCode: inferredRegion.provinceCode,
          provinceName: inferredRegion.provinceName,
          cityCode: inferredRegion.cityCode,
          cityName: inferredRegion.cityName,
          districtCode: inferredRegion.districtCode,
          districtName: inferredRegion.districtName,
          latitude: null,
          longitude: null,
          geoSource: 'manual_text_only',
          geoStatus: 'text_only',
          lastGeocodedAt: null,
          mapProvider: 'amap',
          mapPreviewUrl: null,
          mapLinkUrl: null,
        };
    this.locationService.applyToListing(listing, location);
  }

  private async tryGeocodeCertificationAddress(
    addressText: string,
    cityName: string | null,
  ) {
    try {
      this.amapLocationProvider.requireProviderConfig();
      return await this.amapLocationProvider.geocodeAddress(addressText, cityName);
    } catch {
      try {
        const url = new URL('https://nominatim.openstreetmap.org/search');
        url.searchParams.set('q', addressText);
        url.searchParams.set('format', 'jsonv2');
        url.searchParams.set('limit', '1');
        url.searchParams.set('addressdetails', '1');
        const response = await fetch(url, {
          method: 'GET',
          headers: {
            'User-Agent': 'exhibition-app-enterprise-hub/1.0',
          },
          signal: AbortSignal.timeout(5000),
        });
        if (!response.ok) {
          return null;
        }
        const payload = (await response.json()) as Array<Record<string, unknown>>;
        const first = Array.isArray(payload) ? payload[0] : null;
        if (!first) {
          return null;
        }
        const latitude = Number.parseFloat(String(first.lat ?? ''));
        const longitude = Number.parseFloat(String(first.lon ?? ''));
        if (!Number.isFinite(latitude) || !Number.isFinite(longitude)) {
          return null;
        }
        const address = (first.address ?? {}) as Record<string, unknown>;
        return {
          formattedAddress: String(first.display_name ?? addressText),
          provinceName: this.readFallbackText(
            address.state,
            address.province,
            address.region,
          ),
          cityName: this.readFallbackText(
            address.city,
            address.town,
            address.county,
            cityName,
          ),
          districtName: this.readFallbackText(
            address.suburb,
            address.city_district,
            address.county,
          ),
          adcode: null,
          latitude,
          longitude,
        };
      } catch {
        return null;
      }
    }
  }

  private readFallbackText(...values: unknown[]) {
    for (const value of values) {
      const normalized =
        typeof value === 'string' ? value.trim() : value == null ? '' : String(value).trim();
      if (normalized.length > 0) {
        return normalized;
      }
    }
    return null;
  }

  private toListingVerificationStatus(value: string | null) {
    switch (value) {
      case 'approved':
        return 'verified';
      case 'pending_review':
        return 'pending';
      case 'rejected':
      case 'expired':
        return 'failed';
      default:
        return null;
    }
  }

  private toEnterpriseCertStatus(value: string) {
    switch (value) {
      case 'approved':
        return 'approved';
      case 'rejected':
      case 'expired':
        return 'rejected';
      default:
        return 'pending';
    }
  }
}
