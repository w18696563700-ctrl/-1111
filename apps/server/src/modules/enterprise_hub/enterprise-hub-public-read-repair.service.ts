import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { OrganizationCertificationEntity } from '../organization/entities/organization-certification.entity';
import { inferEnterpriseHubRegionFromAddress } from './enterprise-hub-address-region-truth';
import { EnterpriseHubCertificationSyncService } from './enterprise-hub-certification-sync.service';
import { EnterpriseListingEntity } from './entities/enterprise-listing.entity';

@Injectable()
export class EnterpriseHubPublicReadRepairService {
  constructor(
    @InjectRepository(OrganizationCertificationEntity)
    private readonly organizationCertificationRepository: Repository<OrganizationCertificationEntity>,
    private readonly certificationSyncService: EnterpriseHubCertificationSyncService,
  ) {}

  async repairListingFromCertificationIfNeeded(listing: EnterpriseListingEntity | null) {
    if (!listing) {
      return;
    }

    const certificationMap = await this.loadLatestCertificationMap([listing.organizationId]);
    await this.repairListingWithResolvedCertification(
      listing,
      certificationMap.get(listing.organizationId) ?? null,
    );
  }

  async repairListingsFromCertificationIfNeeded(listings: EnterpriseListingEntity[]) {
    const normalizedListings = listings.filter(Boolean);
    if (!normalizedListings.length) {
      return;
    }

    const certificationMap = await this.loadLatestCertificationMap(
      normalizedListings.map((item) => item.organizationId),
    );
    for (const listing of normalizedListings) {
      await this.repairListingWithResolvedCertification(
        listing,
        certificationMap.get(listing.organizationId) ?? null,
      );
    }
  }

  private async repairListingWithResolvedCertification(
    listing: EnterpriseListingEntity,
    certification: OrganizationCertificationEntity | null,
  ) {
    if (!this.shouldRepairListing(listing, certification)) {
      return;
    }
    await this.certificationSyncService.syncListingWithResolvedCertification(
      listing,
      certification,
    );
  }

  private async loadLatestCertificationMap(organizationIds: string[]) {
    const normalizedOrganizationIds = [
      ...new Set(organizationIds.map((item) => item.trim()).filter((item) => item.length > 0)),
    ];
    if (!normalizedOrganizationIds.length) {
      return new Map<string, OrganizationCertificationEntity>();
    }

    const certifications = await this.organizationCertificationRepository.find({
      where: { organizationId: In(normalizedOrganizationIds) },
      order: { updatedAt: 'DESC', createdAt: 'DESC' },
    });
    const certificationMap = new Map<string, OrganizationCertificationEntity>();
    for (const certification of certifications) {
      if (!certificationMap.has(certification.organizationId)) {
        certificationMap.set(certification.organizationId, certification);
      }
    }
    return certificationMap;
  }

  private shouldRepairListing(
    listing: EnterpriseListingEntity,
    certification: OrganizationCertificationEntity | null,
  ) {
    const certifiedLegalName = certification?.legalName?.trim() ?? '';
    const certifiedAddress =
      certification?.certificationStatus === 'approved'
        ? certification.address?.trim() ?? ''
        : '';
    const listingAddress = listing.address?.trim() ?? '';
    const publicDisplayAddress = listing.publicDisplayAddress?.trim() ?? '';
    const listingProvinceName = listing.provinceName?.trim() ?? '';
    const listingCityName = listing.cityName?.trim() ?? '';

    if (
      certifiedLegalName.length > 0 &&
      listing.legalNameSnapshot?.trim() !== certifiedLegalName
    ) {
      return true;
    }
    if (certifiedAddress.length === 0) {
      return false;
    }

    const inferredRegion = inferEnterpriseHubRegionFromAddress(certifiedAddress);
    const inferredProvinceName = inferredRegion.provinceName?.trim() ?? '';
    const inferredCityName = inferredRegion.cityName?.trim() ?? '';

    return (
      listingAddress !== certifiedAddress ||
      publicDisplayAddress !== certifiedAddress ||
      listing.geoStatus !== 'resolved' ||
      listing.latitude == null ||
      listing.longitude == null ||
      listingProvinceName.length === 0 ||
      listingCityName.length === 0 ||
      (inferredProvinceName.length > 0 && listingProvinceName !== inferredProvinceName) ||
      (inferredCityName.length > 0 && listingCityName !== inferredCityName)
    );
  }
}
