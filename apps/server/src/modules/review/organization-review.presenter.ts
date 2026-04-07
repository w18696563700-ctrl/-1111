import { Injectable } from '@nestjs/common';

@Injectable()
export class OrganizationReviewPresenter {
  toPagination(page: number, pageSize: number, total: number) {
    return {
      page,
      pageSize,
      total,
      hasMore: page * pageSize < total
    };
  }

  toListItem(input: {
    organizationId: string;
    name: string;
    organizationType: string;
    certificationStatus: string;
    submittedAt: Date | null;
  }) {
    return {
      organizationId: input.organizationId,
      name: input.name,
      organizationType: input.organizationType,
      certificationStatus: input.certificationStatus,
      submittedAt: input.submittedAt?.toISOString() ?? null
    };
  }

  toDetail(input: {
    organizationId: string;
    name: string;
    organizationType: string;
    certificationStatus: string;
    legalName: string | null;
    uscc: string | null;
    licenseFileId: string | null;
    contactName: string | null;
    contactMobile: string | null;
    submittedAt: Date | null;
    reviewedAt: Date | null;
    rejectReason: string | null;
  }) {
    return {
      organizationId: input.organizationId,
      name: input.name,
      organizationType: input.organizationType,
      certificationStatus: input.certificationStatus,
      legalName: input.legalName,
      uscc: input.uscc,
      licenseFileId: input.licenseFileId,
      contactName: input.contactName,
      contactMobile: input.contactMobile,
      submittedAt: input.submittedAt?.toISOString() ?? null,
      reviewedAt: input.reviewedAt?.toISOString() ?? null,
      rejectReason: input.rejectReason
    };
  }

  toActionAck(traceId: string) {
    return {
      ok: true,
      traceId
    };
  }
}
