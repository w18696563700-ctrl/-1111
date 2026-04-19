import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { OrganizationCertificationEntity } from '../organization/entities/organization-certification.entity';
import { enterpriseNotFound, permissionDenied } from './enterprise-hub.errors';
import { EnterpriseListingEntity } from './entities/enterprise-listing.entity';

@Injectable()
export class EnterpriseHubFormalInfoQueryService {
  constructor(
    @InjectRepository(EnterpriseListingEntity)
    private readonly listingRepository: Repository<EnterpriseListingEntity>,
    @InjectRepository(OrganizationCertificationEntity)
    private readonly organizationCertificationRepository: Repository<OrganizationCertificationEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
  ) {}

  async getEnterpriseFormalInfo(enterpriseId: string, context: RequestContext) {
    await this.requireFormalInfoReadAccess(context);

    const listing = await this.listingRepository.findOneBy({
      id: enterpriseId,
      enterpriseStatus: 'published',
      displayStatus: 'visible',
    });
    if (!listing) {
      throw enterpriseNotFound();
    }

    const certification =
      await this.organizationCertificationRepository.findOne({
        where: { organizationId: listing.organizationId },
        order: { updatedAt: 'DESC', createdAt: 'DESC' },
      });
    if (!certification || certification.certificationStatus !== 'approved') {
      throw enterpriseNotFound('Target enterprise formal-info is unavailable.');
    }

    return {
      legalName: certification.legalName,
      uscc: certification.uscc,
      legalPerson: certification.legalPerson,
      businessType: certification.businessType,
      address: certification.address,
      registeredCapital: certification.registeredCapital,
      establishedAt: certification.establishedAt,
      businessTerm: certification.businessTerm,
      businessScope: certification.businessScope,
      certificationStatus: certification.certificationStatus,
    };
  }

  private async requireFormalInfoReadAccess(context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService,
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(
      currentSession,
    );
    if (!scope) {
      throw permissionDenied(
        'Current actor lacks the required organization scope for target enterprise formal-info read.',
      );
    }
    if (scope.certification.certificationStatus !== 'approved') {
      throw permissionDenied(
        'Current organization certification is not approved for target enterprise formal-info read.',
      );
    }
    if (
      scope.personalCertification.certificationStatus !== 'approved' ||
      !scope.personalCertification.qualifiedForCurrentActor ||
      scope.personalCertification.lockedToOtherActor === true
    ) {
      throw permissionDenied(
        scope.personalCertification.lockedToOtherActor
          ? 'Current personal certification is locked to another actor for target enterprise formal-info read.'
          : 'Current personal certification is not approved for target enterprise formal-info read.',
      );
    }
  }
}
