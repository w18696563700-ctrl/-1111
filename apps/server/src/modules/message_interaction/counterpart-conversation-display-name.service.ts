import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { OrganizationCertificationEntity } from '../organization/entities/organization-certification.entity';
import { OrganizationEntity } from '../organization/entities/organization.entity';

@Injectable()
export class CounterpartConversationDisplayNameService {
  constructor(
    @InjectRepository(OrganizationCertificationEntity)
    private readonly certificationRepository: Repository<OrganizationCertificationEntity>,
  ) {}

  async loadApprovedLegalNameMap(organizationIds: Iterable<string>) {
    const ids = [...new Set([...organizationIds].map((id) => id.trim()).filter(Boolean))];
    if (!ids.length) {
      return new Map<string, string>();
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
    const legalNameByOrganizationId = new Map<string, string>();
    for (const certification of certifications) {
      const legalName = certification.legalName?.trim() ?? '';
      if (!legalName || legalNameByOrganizationId.has(certification.organizationId)) {
        continue;
      }
      legalNameByOrganizationId.set(certification.organizationId, legalName);
    }
    return legalNameByOrganizationId;
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
}
