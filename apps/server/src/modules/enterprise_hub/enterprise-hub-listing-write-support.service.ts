import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { randomUUID } from 'crypto';
import { Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { enterpriseNotFound, permissionDenied } from './enterprise-hub.errors';
import { EnterpriseListingEntity } from './entities/enterprise-listing.entity';
import { EnterpriseServiceAreaEntity } from './entities/enterprise-service-area.entity';

@Injectable()
export class EnterpriseHubListingWriteSupportService {
  constructor(
    @InjectRepository(EnterpriseListingEntity)
    private readonly listingRepository: Repository<EnterpriseListingEntity>,
    @InjectRepository(EnterpriseServiceAreaEntity)
    private readonly serviceAreaRepository: Repository<EnterpriseServiceAreaEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
  ) {}

  async loadOwnedListing(enterpriseId: string, context: RequestContext) {
    const organizationId = await this.resolveOrganizationContext(context);
    const listing = await this.listingRepository.findOneBy({ id: enterpriseId });
    if (!listing) {
      throw enterpriseNotFound();
    }
    if (listing.organizationId !== organizationId) {
      throw permissionDenied('Current actor organization scope cannot mutate this enterprise listing.');
    }
    return listing;
  }

  async upsertRegisteredArea(listing: EnterpriseListingEntity) {
    const existing = await this.serviceAreaRepository.findOneBy({
      enterpriseId: listing.id,
      areaType: 'registered_location',
    });
    await this.serviceAreaRepository.save(
      this.serviceAreaRepository.create({
        ...(existing ?? {
          id: randomUUID(),
          enterpriseId: listing.id,
          areaType: 'registered_location',
        }),
        provinceCode: listing.provinceCode,
        provinceName: listing.provinceName,
        cityCode: listing.cityCode,
        cityName: listing.cityName,
      }),
    );
  }

  async resolveOrganizationContext(context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService,
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    const organizationId = scope?.organization.id?.trim() ?? '';
    if (organizationId) {
      return organizationId;
    }
    throw permissionDenied('Current actor must carry organization context for enterprise hub write truth.');
  }
}
