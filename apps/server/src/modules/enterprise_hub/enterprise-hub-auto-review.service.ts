import { EnterpriseApplicationEntity } from './entities/enterprise-application.entity';
import { EnterpriseCaseEntity } from './entities/enterprise-case.entity';
import { EnterpriseListingEntity } from './entities/enterprise-listing.entity';

export type EnterpriseHubAutoReviewDecision =
  | 'approved'
  | 'revision_required'
  | 'manual_review_required';

export class EnterpriseHubAutoReviewService {
  evaluate(input: {
    application: EnterpriseApplicationEntity;
    listing: EnterpriseListingEntity;
    cases: EnterpriseCaseEntity[];
  }): EnterpriseHubAutoReviewDecision {
    if (!this.hasAtLeastOneValidCase(input.cases)) {
      return 'revision_required';
    }
    if (this.readManualReviewRequiredNote(input) != null) {
      return 'manual_review_required';
    }
    return 'approved';
  }

  readReviewNote(
    input: {
      application: EnterpriseApplicationEntity;
      listing: EnterpriseListingEntity;
      cases: EnterpriseCaseEntity[];
    },
    decision: EnterpriseHubAutoReviewDecision,
  ) {
    if (decision === 'approved') {
      return 'auto-review rule v1';
    }
    if (decision === 'revision_required') {
      return '自动审核未通过：至少需要保留 1 条带封面或案例图片的案例。';
    }
    return (
      this.readManualReviewRequiredNote(input) ??
      '自动审核未命中：当前申请已转人工审核。'
    );
  }

  private hasAtLeastOneValidCase(cases: EnterpriseCaseEntity[]) {
    return cases.some((item) => {
      const coverReady =
        typeof item.caseCoverFileAssetId === 'string' &&
        item.caseCoverFileAssetId.trim().length > 0;
      const mediaReady =
        Array.isArray(item.caseMediaFileAssetIds) &&
        item.caseMediaFileAssetIds.some(
          (mediaId) => typeof mediaId === 'string' && mediaId.trim().length > 0,
        );
      return coverReady || mediaReady;
    });
  }

  private readManualReviewRequiredNote(input: {
    application: EnterpriseApplicationEntity;
    listing: EnterpriseListingEntity;
    cases: EnterpriseCaseEntity[];
  }) {
    if (input.listing.primaryBoardType !== input.application.applyBoardType) {
      return '自动审核未命中：当前申请板块与企业主板块不一致，已转人工审核。';
    }
    if (input.listing.enterpriseStatus !== 'unpublished') {
      return `自动审核未命中：当前企业展示不是首次未发布申请，已转人工审核。当前展示状态：${input.listing.enterpriseStatus}。`;
    }
    return null;
  }
}
