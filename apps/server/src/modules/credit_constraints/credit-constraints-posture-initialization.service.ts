import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { randomUUID } from 'crypto';
import { EntityManager, Repository } from 'typeorm';
import { OrganizationCertificationEntity } from '../organization/entities/organization-certification.entity';
import { OrganizationMemberEntity } from '../organization/entities/organization-member.entity';
import { OrganizationEntity } from '../organization/entities/organization.entity';
import { OrganizationCreditConstraintPostureEntity } from './entities/organization-credit-constraint-posture.entity';
import { OrganizationDepositPostureEntity } from './entities/organization-deposit-posture.entity';
import { OrganizationTransactionGuaranteePostureEntity } from './entities/organization-transaction-guarantee-posture.entity';

export type CreditConstraintsPostureFamily = 'credit' | 'deposit' | 'transaction_guarantee';

type InitializationRepositories = {
  credit: Repository<OrganizationCreditConstraintPostureEntity>;
  deposit: Repository<OrganizationDepositPostureEntity>;
  transactionGuarantee: Repository<OrganizationTransactionGuaranteePostureEntity>;
  organization: Repository<OrganizationEntity>;
  certification: Repository<OrganizationCertificationEntity>;
  member: Repository<OrganizationMemberEntity>;
};

export type CreditConstraintsPostureInitializationResult = {
  eligible: boolean;
  organizationId: string;
  createdFamilies: CreditConstraintsPostureFamily[];
  existingFamilies: CreditConstraintsPostureFamily[];
  skippedReason?: string;
};

@Injectable()
export class CreditConstraintsPostureInitializationService {
  constructor(
    @InjectRepository(OrganizationCreditConstraintPostureEntity)
    private readonly creditPostureRepository: Repository<OrganizationCreditConstraintPostureEntity>,
    @InjectRepository(OrganizationDepositPostureEntity)
    private readonly depositPostureRepository: Repository<OrganizationDepositPostureEntity>,
    @InjectRepository(OrganizationTransactionGuaranteePostureEntity)
    private readonly transactionGuaranteePostureRepository: Repository<OrganizationTransactionGuaranteePostureEntity>,
    @InjectRepository(OrganizationEntity)
    private readonly organizationRepository: Repository<OrganizationEntity>,
    @InjectRepository(OrganizationCertificationEntity)
    private readonly certificationRepository: Repository<OrganizationCertificationEntity>,
    @InjectRepository(OrganizationMemberEntity)
    private readonly memberRepository: Repository<OrganizationMemberEntity>
  ) {}

  async ensureDefaultPosturesForApprovedOrganization(
    organizationId: string,
    manager?: EntityManager
  ): Promise<CreditConstraintsPostureInitializationResult> {
    const normalizedOrganizationId = organizationId.trim();
    const emptyResult = {
      eligible: false,
      organizationId: normalizedOrganizationId,
      createdFamilies: [],
      existingFamilies: []
    };
    if (!normalizedOrganizationId) {
      return {
        ...emptyResult,
        skippedReason: 'organization_id_missing'
      };
    }

    const repositories = this.resolveRepositories(manager);
    const eligibility = await this.checkEligibility(normalizedOrganizationId, repositories);
    if (eligibility.eligible === false) {
      return {
        ...emptyResult,
        skippedReason: eligibility.reason
      };
    }

    const createdFamilies: CreditConstraintsPostureFamily[] = [];
    const existingFamilies: CreditConstraintsPostureFamily[] = [];
    const [creditPosture, depositPosture, transactionGuaranteePosture] = await Promise.all([
      repositories.credit.findOneBy({ organizationId: normalizedOrganizationId }),
      repositories.deposit.findOneBy({ organizationId: normalizedOrganizationId }),
      repositories.transactionGuarantee.findOneBy({ organizationId: normalizedOrganizationId })
    ]);

    if (creditPosture) {
      existingFamilies.push('credit');
    } else {
      await repositories.credit.save(this.buildCreditPosture(repositories, normalizedOrganizationId));
      createdFamilies.push('credit');
    }

    if (depositPosture) {
      existingFamilies.push('deposit');
    } else {
      await repositories.deposit.save(this.buildDepositPosture(repositories, normalizedOrganizationId));
      createdFamilies.push('deposit');
    }

    if (transactionGuaranteePosture) {
      existingFamilies.push('transaction_guarantee');
    } else {
      await repositories.transactionGuarantee.save(
        this.buildTransactionGuaranteePosture(repositories, normalizedOrganizationId)
      );
      createdFamilies.push('transaction_guarantee');
    }

    return {
      eligible: true,
      organizationId: normalizedOrganizationId,
      createdFamilies,
      existingFamilies
    };
  }

  private async checkEligibility(
    organizationId: string,
    repositories: InitializationRepositories
  ): Promise<{ eligible: true } | { eligible: false; reason: string }> {
    const organization = await repositories.organization.findOneBy({ id: organizationId });
    if (!organization || organization.status !== 'active') {
      return { eligible: false, reason: 'organization_not_active' };
    }

    const certification = await repositories.certification.findOne({
      where: { organizationId },
      order: { updatedAt: 'DESC' }
    });
    if (!certification || certification.certificationStatus !== 'approved') {
      return { eligible: false, reason: 'certification_not_approved' };
    }

    const activeMemberCount = await repositories.member.count({
      where: { organizationId, memberStatus: 'active' }
    });
    if (activeMemberCount < 1) {
      return { eligible: false, reason: 'active_member_missing' };
    }

    return { eligible: true };
  }

  private resolveRepositories(manager?: EntityManager): InitializationRepositories {
    if (!manager) {
      return {
        credit: this.creditPostureRepository,
        deposit: this.depositPostureRepository,
        transactionGuarantee: this.transactionGuaranteePostureRepository,
        organization: this.organizationRepository,
        certification: this.certificationRepository,
        member: this.memberRepository
      };
    }

    return {
      credit: manager.getRepository(OrganizationCreditConstraintPostureEntity),
      deposit: manager.getRepository(OrganizationDepositPostureEntity),
      transactionGuarantee: manager.getRepository(OrganizationTransactionGuaranteePostureEntity),
      organization: manager.getRepository(OrganizationEntity),
      certification: manager.getRepository(OrganizationCertificationEntity),
      member: manager.getRepository(OrganizationMemberEntity)
    };
  }

  private buildCreditPosture(
    repositories: InitializationRepositories,
    organizationId: string
  ) {
    return repositories.credit.create({
      id: randomUUID(),
      organizationId,
      creditConstraintStatus: 'clear',
      performanceConstraintStatus: 'clear',
      restrictionReasonCode: null,
      advisoryReasonCode: null,
      executionAvailabilityStatus: 'available',
      explanationKey: 'credit_clear',
      handoffKey: 'credit_readonly_no_action',
      dependencyKey: 'v22_payment_billing_required'
    });
  }

  private buildDepositPosture(
    repositories: InitializationRepositories,
    organizationId: string
  ) {
    return repositories.deposit.create({
      id: randomUUID(),
      organizationId,
      requirementStatus: 'required',
      eligibilityStatus: 'eligible',
      restrictionStatus: 'clear',
      depositPostureStatus: 'handoff_required',
      handoffKey: 'deposit_open_payment_dependency',
      dependencyKey: 'v22_payment_billing_required'
    });
  }

  private buildTransactionGuaranteePosture(
    repositories: InitializationRepositories,
    organizationId: string
  ) {
    return repositories.transactionGuarantee.create({
      id: randomUUID(),
      organizationId,
      eligibilityStatus: 'eligible',
      restrictionStatus: 'clear',
      explanationKey: 'transaction_guarantee_dependency_required',
      handoffKey: 'transaction_guarantee_open_dependency',
      dependencyKey: 'v22_payment_billing_required'
    });
  }
}
