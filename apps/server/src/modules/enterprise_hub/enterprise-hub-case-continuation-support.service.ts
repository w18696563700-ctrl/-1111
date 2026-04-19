import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { RequestContext } from '../../shared/request-context';
import {
  changeCorridorRequired,
  caseNotFound,
  permissionDenied,
} from './enterprise-hub.errors';
import { EnterpriseHubListingWriteSupportService } from './enterprise-hub-listing-write-support.service';
import { EnterpriseApplicationEntity } from './entities/enterprise-application.entity';
import { EnterpriseCaseEntity } from './entities/enterprise-case.entity';
import { EnterpriseListingEntity } from './entities/enterprise-listing.entity';

@Injectable()
export class EnterpriseHubCaseContinuationSupportService {
  constructor(
    @InjectRepository(EnterpriseCaseEntity)
    private readonly caseRepository: Repository<EnterpriseCaseEntity>,
    @InjectRepository(EnterpriseApplicationEntity)
    private readonly applicationRepository: Repository<EnterpriseApplicationEntity>,
    private readonly listingWriteSupportService: EnterpriseHubListingWriteSupportService,
  ) {}

  async loadOwnedCase(caseId: string, context: RequestContext) {
    const entity = await this.caseRepository.findOneBy({ id: caseId });
    if (!entity) {
      throw caseNotFound();
    }
    const listing = await this.listingWriteSupportService.loadOwnedListing(
      entity.enterpriseId,
      context,
    );
    const latestApplication = await this.applicationRepository.findOne({
      where: { enterpriseId: listing.id },
      order: { createdAt: 'DESC', updatedAt: 'DESC' },
    });

    return {
      entity,
      listing,
      latestApplication,
    };
  }

  ensureDirectReadAllowed(input: {
    listing: EnterpriseListingEntity;
    latestApplication: EnterpriseApplicationEntity | null;
  }) {
    if (this.isDirectContinuationEditable(input)) {
      return;
    }
    throw permissionDenied(
      'Current case continuation read path is only available under the unpublished draft-editable workbench scope.',
    );
  }

  ensureDirectUpdateAllowed(input: {
    listing: EnterpriseListingEntity;
    latestApplication: EnterpriseApplicationEntity | null;
  }) {
    if (input.listing.enterpriseStatus === 'published') {
      throw changeCorridorRequired(
        'Current case has entered the published-governed listing domain and must continue through the published change corridor.',
      );
    }
    if (this.isDirectContinuationEditable(input)) {
      return;
    }
    throw permissionDenied(
      'Current case continuation update path is only available under the unpublished draft-editable workbench scope.',
    );
  }

  private isDirectContinuationEditable(input: {
    listing: EnterpriseListingEntity;
    latestApplication: EnterpriseApplicationEntity | null;
  }) {
    return (
      input.listing.enterpriseStatus === 'unpublished' &&
      input.latestApplication?.applicationStatus === 'draft'
    );
  }
}
