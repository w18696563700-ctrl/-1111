import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { OrganizationCertificationEntity } from '../organization/entities/organization-certification.entity';
import { OrganizationEntity } from '../organization/entities/organization.entity';
import { CounterpartConversationCertificationSummaryProjection } from './counterpart-conversation.types';

@Injectable()
export class CounterpartConversationDisplayNameService {
  constructor(
    @InjectRepository(OrganizationCertificationEntity)
    private readonly certificationRepository: Repository<OrganizationCertificationEntity>,
  ) {}

  async loadApprovedLegalNameMap(organizationIds: Iterable<string>) {
    const summaries = await this.loadApprovedCertificationSummaryMap(organizationIds);
    return this.toApprovedLegalNameMap(summaries);
  }

  async loadApprovedCertificationSummaryMap(organizationIds: Iterable<string>) {
    const ids = [...new Set([...organizationIds].map((id) => id.trim()).filter(Boolean))];
    if (!ids.length) {
      return new Map<string, CounterpartConversationCertificationSummaryProjection>();
    }

    const certifications = await this.certificationRepository.find({
      where: {
        organizationId: In(ids),
        certificationStatus: 'approved',
      },
      order: {
        updatedAt: 'DESC',
        createdAt: 'DESC',
      },
    });
    const summaryByOrganizationId = new Map<
      string,
      CounterpartConversationCertificationSummaryProjection
    >();
    for (const certification of certifications) {
      const legalName = certification.legalName?.trim() ?? '';
      if (!legalName || summaryByOrganizationId.has(certification.organizationId)) {
        continue;
      }
      summaryByOrganizationId.set(certification.organizationId, {
        certificationStatus: 'approved',
        legalName,
        usccMasked: this.maskUscc(certification.uscc),
        businessType: this.trimOrNull(certification.businessType),
        address: this.trimOrNull(certification.address),
        establishedAt: this.trimOrNull(certification.establishedAt),
        reviewedAt: certification.reviewedAt?.toISOString() ?? null,
      });
    }
    return summaryByOrganizationId;
  }

  toApprovedLegalNameMap(
    summaries: Map<string, CounterpartConversationCertificationSummaryProjection>,
  ) {
    return new Map(
      [...summaries.entries()].map(([organizationId, summary]) => [
        organizationId,
        summary.legalName,
      ]),
    );
  }

  resolveDisplayName(input: {
    organizationId: string;
    organizationMap: Map<string, OrganizationEntity>;
    approvedLegalNameByOrganizationId: Map<string, string>;
    fallback?: string | null;
  }) {
    const certifiedName = input.approvedLegalNameByOrganizationId
      .get(input.organizationId)
      ?.trim();
    if (certifiedName) {
      return certifiedName;
    }

    const organizationName = input.organizationMap
      .get(input.organizationId)
      ?.name
      ?.trim();
    if (organizationName) {
      return organizationName;
    }

    const fallback = input.fallback?.trim();
    return fallback || '当前沟通对象';
  }

  resolveCompanyName(input: {
    organizationId: string;
    organizationMap: Map<string, OrganizationEntity>;
    approvedLegalNameByOrganizationId: Map<string, string>;
    fallback?: string | null;
  }) {
    return this.resolveDisplayName(input);
  }

  resolveNickname(user: { nickname?: string | null } | null | undefined) {
    return this.trimOrNull(user?.nickname);
  }

  private trimOrNull(value: string | null | undefined) {
    const normalized = value?.trim() ?? '';
    return normalized || null;
  }

  private maskUscc(value: string | null | undefined) {
    const normalized = value?.trim() ?? '';
    if (!normalized) {
      return null;
    }
    if (normalized.length <= 8) {
      return `${normalized.slice(0, 2)}****`;
    }
    return `${normalized.slice(0, 4)}****${normalized.slice(-4)}`;
  }
}
