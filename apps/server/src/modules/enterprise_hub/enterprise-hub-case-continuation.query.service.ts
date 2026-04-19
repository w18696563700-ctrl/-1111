import { Injectable } from '@nestjs/common';
import { RequestContext } from '../../shared/request-context';
import { EnterpriseHubCaseContinuationSupportService } from './enterprise-hub-case-continuation-support.service';
import { EnterpriseHubMediaProjectionService } from './enterprise-hub-media-projection.service';

@Injectable()
export class EnterpriseHubCaseContinuationQueryService {
  constructor(
    private readonly supportService: EnterpriseHubCaseContinuationSupportService,
    private readonly mediaProjectionService: EnterpriseHubMediaProjectionService,
  ) {}

  async getCaseDetail(caseId: string, context: RequestContext) {
    const { entity, listing, latestApplication } =
      await this.supportService.loadOwnedCase(caseId, context);
    this.supportService.ensureDirectReadAllowed({
      listing,
      latestApplication,
    });
    const imageFileAssetIds = [
      entity.caseCoverFileAssetId,
      ...(entity.caseMediaFileAssetIds ?? []),
    ];
    const displayUrlMap = await this.mediaProjectionService.buildDisplayUrlMap(
      imageFileAssetIds,
    );

    return {
      caseId: entity.id,
      enterpriseId: entity.enterpriseId,
      boardType: entity.boardType,
      title: entity.title,
      exhibitionType: entity.exhibitionType,
      city: entity.city,
      eventTime: entity.eventTime,
      summary: entity.summary,
      caseCoverFileAssetId: entity.caseCoverFileAssetId ?? null,
      caseMediaFileAssetIds: entity.caseMediaFileAssetIds ?? [],
      caseImageUrlMap: Object.fromEntries(
        imageFileAssetIds.flatMap((item) => {
          const url = this.mediaProjectionService.readDisplayUrl(item, displayUrlMap);
          return url ? [[item, url] as const] : [];
        }),
      ),
      isFeatured: entity.isFeatured,
      caseStatus: entity.caseStatus,
    };
  }
}
