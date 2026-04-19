import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { RequestContext } from '../../shared/request-context';
import { invalidBoardType, missingRequiredFields } from './enterprise-hub.errors';
import { EnterpriseHubCaseContinuationSupportService } from './enterprise-hub-case-continuation-support.service';
import { EnterpriseHubMediaTruthService } from './enterprise-hub-media-truth.service';
import { EnterpriseCaseEntity } from './entities/enterprise-case.entity';

@Injectable()
export class EnterpriseHubCaseContinuationWriteService {
  constructor(
    @InjectRepository(EnterpriseCaseEntity)
    private readonly caseRepository: Repository<EnterpriseCaseEntity>,
    private readonly supportService: EnterpriseHubCaseContinuationSupportService,
    private readonly mediaTruthService: EnterpriseHubMediaTruthService,
  ) {}

  async updateCase(caseId: string, payload: Record<string, unknown>, context: RequestContext) {
    const patch = payload ?? {};
    if (Object.prototype.hasOwnProperty.call(patch, 'boardType')) {
      throw invalidBoardType(
        'Case boardType is immutable for direct case continuation.',
      );
    }

    const { entity, listing, latestApplication } =
      await this.supportService.loadOwnedCase(caseId, context);
    this.supportService.ensureDirectUpdateAllowed({
      listing,
      latestApplication,
    });

    const nextMedia = Array.isArray(patch.caseMediaFileAssetIds)
      ? this.readStringArray(patch.caseMediaFileAssetIds).slice(0, 6)
      : entity.caseMediaFileAssetIds;
    const requestedCover = Object.prototype.hasOwnProperty.call(
      patch,
      'caseCoverFileAssetId',
    )
      ? this.readNullableString(patch.caseCoverFileAssetId)
      : entity.caseCoverFileAssetId;

    entity.title = this.readText(patch.title, 'title');
    entity.summary = this.readText(patch.summary, 'summary');
    if (Object.prototype.hasOwnProperty.call(patch, 'exhibitionType')) {
      entity.exhibitionType = this.readNullableString(patch.exhibitionType);
    }
    if (Object.prototype.hasOwnProperty.call(patch, 'city')) {
      entity.city = this.readNullableString(patch.city);
    }
    if (Object.prototype.hasOwnProperty.call(patch, 'eventTime')) {
      entity.eventTime = this.readNullableString(patch.eventTime);
    }
    entity.caseMediaFileAssetIds = nextMedia;
    entity.caseCoverFileAssetId =
      requestedCover ?? nextMedia[0] ?? entity.caseCoverFileAssetId;
    if (Object.prototype.hasOwnProperty.call(patch, 'isFeatured')) {
      entity.isFeatured = patch.isFeatured === true;
    }

    await this.mediaTruthService.validateCaseMedia(listing, {
      caseCoverFileAssetId: entity.caseCoverFileAssetId,
      caseMediaFileAssetIds: entity.caseMediaFileAssetIds,
    });
    await this.caseRepository.save(entity);
    await this.mediaTruthService.syncCaseRefs(listing, 'enterprise_case', entity.id, {
      caseCoverFileAssetId: entity.caseCoverFileAssetId,
      caseMediaFileAssetIds: entity.caseMediaFileAssetIds,
    });
    return {
      caseId: entity.id,
      caseStatus: entity.caseStatus,
    };
  }

  private readText(value: unknown, field: string) {
    if (typeof value === 'string' && value.trim().length > 0) {
      return value.trim();
    }
    throw missingRequiredFields(`Field \`${field}\` is required for enterprise hub truth write.`);
  }

  private readNullableString(value: unknown) {
    return typeof value === 'string' && value.trim().length > 0 ? value.trim() : null;
  }

  private readStringArray(value: unknown) {
    return Array.isArray(value)
      ? value.filter((item): item is string => typeof item === 'string')
      : [];
  }
}
