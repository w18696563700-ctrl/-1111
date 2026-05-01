import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { ProjectEntity } from '../project/entities/project.entity';
import { PlatformServiceFeeChargeEntity } from './entities/platform-service-fee-charge.entity';
import { p0PayPermissionDenied, p0PayResourceUnavailable } from './p0-pay.errors';

@Injectable()
export class P0PaySettlementService {
  constructor(
    @InjectRepository(PlatformServiceFeeChargeEntity)
    private readonly chargeRepository: Repository<PlatformServiceFeeChargeEntity>,
    @InjectRepository(ProjectEntity)
    private readonly projectRepository: Repository<ProjectEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService
  ) {}

  async getProjectSettlementSummary(projectId: string, context: RequestContext) {
    const ownership = await this.requireProjectParticipant(projectId, context);
    const charges = await this.chargeRepository.find({ where: { taskId: ownership.project.id } });
    return this.toSettlementSummary(ownership.project.id, charges);
  }

  async createProjectSettlementBatchDraft(projectId: string, context: RequestContext) {
    const summary = await this.getProjectSettlementSummary(projectId, context);
    return {
      ...summary,
      batchDraft: {
        batchDraftId: `draft-${summary.projectId}`,
        status: summary.settlementSummary.settlementStatus,
        autoPayoutEnabled: false,
        payoutAction: 'disabled',
        note: '当前只生成结算草稿摘要，不自动打款。'
      }
    };
  }

  async getProjectReconciliationSummary(projectId: string, context: RequestContext) {
    const summary = await this.getProjectSettlementSummary(projectId, context);
    return {
      projectId: summary.projectId,
      reconciliationSummary: {
        status: summary.settlementSummary.reconciliationStatus,
        chargeCount: summary.charges.length,
        chargedAmount: summary.settlementSummary.platformIncomeAmount,
        refundedAmount: summary.settlementSummary.refundedAmount,
        differenceAmount: summary.settlementSummary.reconciliationDifferenceAmount,
        updatedAt: summary.updatedAt
      }
    };
  }

  private async requireProjectParticipant(projectId: string, context: RequestContext) {
    const project = await this.projectRepository.findOneBy({ id: projectId });
    if (!project) {
      throw p0PayResourceUnavailable('Current project settlement summary is unavailable.');
    }
    const currentSession = await requireVerifiedCurrentSessionContext(context, this.currentSessionVerificationService);
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    if (!scope) {
      throw p0PayPermissionDenied('Current organization scope is required for project settlement summary.');
    }
    if (scope.organization.id === project.organizationId) {
      return { project, scope, currentSession };
    }
    const participantCharge = await this.chargeRepository.findOneBy({
      taskId: project.id,
      factoryOrganizationId: scope.organization.id
    });
    if (!participantCharge) {
      throw p0PayPermissionDenied('Current organization cannot read this project settlement summary.');
    }
    return { project, scope, currentSession };
  }

  private toSettlementSummary(projectId: string, charges: PlatformServiceFeeChargeEntity[]) {
    const charged = charges.filter((item) => item.chargeStatus === 'charged');
    const refundPending = charges.filter((item) => item.chargeStatus === 'refund_pending');
    const refunded = charges.filter((item) => item.chargeStatus === 'refunded');
    const failed = charges.filter((item) => item.chargeStatus === 'charge_failed');
    const platformIncomeAmount = this.sum(charged.map((item) => item.finalFeeAmount));
    const refundedAmount = this.sum(refunded.map((item) => item.finalFeeAmount));
    const pendingSettlementAmount = this.sum(charged.map((item) => item.finalFeeAmount));
    const abnormalHoldAmount = this.sum([...failed, ...refundPending].map((item) => item.finalFeeAmount));
    const latestUpdatedAt = charges
      .map((item) => item.updatedAt?.getTime?.() ?? 0)
      .sort((a, b) => b - a)[0] ?? Date.now();

    return {
      projectId,
      settlementSummary: {
        settlementStatus: charged.length > 0 ? 'draft' : 'empty',
        platformIncomeAmount,
        pendingSettlementAmount,
        settledAmount: '0.00',
        refundedAmount,
        abnormalHoldAmount,
        reconciliationStatus: failed.length > 0 ? 'attention_required' : 'balanced',
        reconciliationDifferenceAmount: '0.00',
        autoPayoutEnabled: false,
        payoutStatus: 'not_started',
        updatedAt: new Date(latestUpdatedAt).toISOString()
      },
      charges: charges.map((item) => ({
        chargeId: item.id,
        chargeStatus: item.chargeStatus,
        finalConfirmedAmount: item.finalConfirmedAmount,
        finalFeeAmount: item.finalFeeAmount,
        feeRate: item.feeRate,
        feeRateSource: item.feeRateSource,
        membershipTierSnapshot: item.membershipTierSnapshot,
        updatedAt: item.updatedAt
      })),
      updatedAt: new Date(latestUpdatedAt).toISOString()
    };
  }

  private sum(values: Array<string | number>) {
    const total = values.reduce<number>((sum, value) => sum + Number(value || 0), 0);
    return total.toFixed(2);
  }
}
