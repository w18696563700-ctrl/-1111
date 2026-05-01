import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { randomUUID } from 'crypto';
import { DataSource, Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { BidEntity } from '../bid/entities/bid.entity';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { ProjectEntity } from '../project/entities/project.entity';
import { BidSubmittedSeedService } from '../trading_im/bid-submitted-seed.service';
import { FileAssetEntity } from '../upload/entities/file-asset.entity';
import { InquiryQuoteDepositEntity } from './entities/inquiry-quote-deposit.entity';
import { PlatformServiceFeeAuthorizationEntity } from './entities/platform-service-fee-authorization.entity';
import { p0PayInvalid, p0PayPermissionDenied, p0PayResourceUnavailable } from './p0-pay.errors';
import { P0PayAuditService } from './p0-pay-audit.service';
import { P0PayServiceFeeRatePolicy } from './p0-pay-service-fee-rate.policy';
import { P0PayStateActionService } from './p0-pay-state-action.service';

type SummaryRecord = Record<string, unknown>;
@Injectable()
export class P0PayTradeTaskService {
  constructor(
    @InjectRepository(ProjectEntity) private readonly projectRepository: Repository<ProjectEntity>,
    @InjectRepository(BidEntity) private readonly bidRepository: Repository<BidEntity>,
    @InjectRepository(FileAssetEntity) private readonly fileAssetRepository: Repository<FileAssetEntity>,
    @InjectRepository(PlatformServiceFeeAuthorizationEntity)
    private readonly authorizationRepository: Repository<PlatformServiceFeeAuthorizationEntity>,
    @InjectRepository(InquiryQuoteDepositEntity)
    private readonly depositRepository: Repository<InquiryQuoteDepositEntity>,
    private readonly dataSource: DataSource,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly auditService: P0PayAuditService,
    private readonly stateActions: P0PayStateActionService,
    private readonly bidSubmittedSeedService: BidSubmittedSeedService,
    private readonly feeRatePolicy: P0PayServiceFeeRatePolicy
  ) {}

  async createTradeTask(payload: Record<string, unknown>, context: RequestContext) {
    const taskType = this.readEnum(payload.taskType, ['fixed_price_bid', 'inquiry_quote'], 'taskType');
    const { currentSession, scope } = await this.eligibilityService.requireProjectPublishEligibilityFromContext(
      context,
      this.currentSessionVerificationService
    );
    await this.requireFileAssets(payload.authenticityMaterialFileAssetIds, scope.organization.id);
    const now = new Date();
    const project = this.projectRepository.create({
      id: randomUUID(),
      projectNo: this.buildProjectNo(),
      organizationId: scope.organization.id,
      creatorUserId: currentSession.userId,
      creatorActorId: currentSession.actorId,
      title: this.readString(payload.projectName, 'projectName'),
      exhibitionName: this.readString(payload.exhibitionName, 'exhibitionName'),
      brandName: null,
      buildingType: this.readString(payload.projectType, 'projectType'),
      budgetAmount: this.readMoney(payload.budgetAmount, 'budgetAmount'),
      areaSqm: this.readMoney(payload.area, 'area'),
      cityCode: this.readString(payload.cityCode, 'cityCode'),
      description: this.readString(payload.requirementDescription, 'requirementDescription'),
      plannedStartAt: this.readString(payload.buildStartAt, 'buildStartAt').slice(0, 10),
      plannedEndAt: this.readString(payload.dismantleAt, 'dismantleAt').slice(0, 10),
      state: taskType === 'inquiry_quote' ? 'draft' : 'published',
      summary: this.buildTaskSummary(payload, taskType),
      publishedAt: taskType === 'inquiry_quote' ? null : now,
      createdAt: now,
      updatedAt: now
    });
    await this.dataSource.transaction(async (manager) => {
      await manager.getRepository(ProjectEntity).save(project);
      await this.auditService.record(
        {
          objectType: 'trade_task',
          objectId: project.id,
          objectNo: project.projectNo,
          action: 'TradeTaskCreated',
          beforeState: '',
          afterState: project.state,
          actorId: currentSession.userId,
          actorRole: scope.membership.roleKey,
          reason: `taskType=${taskType}`
        },
        context,
        manager
      );
    });
    return this.toCreateResponse(project, taskType);
  }

  async getTradeTaskDetail(taskId: string, context: RequestContext) {
    const project = await this.requireProject(taskId);
    return {
      taskId: project.id,
      taskType: this.taskType(project),
      publisherOrganization: { organizationId: project.organizationId },
      projectSummary: { projectName: project.title, exhibitionName: project.exhibitionName },
      authenticitySummary: this.authenticitySummary(project),
      quoteSeatSummary: await this.quoteSeatSummary(project.id),
      pricingSummary: await this.buildInlinePricingSummary(project, context),
      resultProcessingSummary: this.readP0(project).inquiryResult ?? null,
      messageHandoff: { readOnly: true, routeTarget: `/exhibition/trade-tasks/${project.id}` },
      contractHandoff: { available: true },
      updatedAt: project.updatedAt
    };
  }

  async bindAuthenticityMaterials(taskId: string, payload: Record<string, unknown>, context: RequestContext) {
    const project = await this.requirePublisherProject(taskId, context);
    const scope = await this.currentScope(context);
    const fileAssetIds = await this.requireFileAssets(payload.fileAssetIds, scope.organization.id);
    project.summary = {
      ...project.summary,
      p0PayAuthenticity: {
        fileAssetIds,
        materialType: this.readString(payload.materialType, 'materialType'),
        authenticityLevel: this.authenticityLevel(fileAssetIds.length),
        updatedAt: new Date().toISOString()
      }
    };
    await this.projectRepository.save(project);
    return {
      taskId: project.id,
      authenticityLevel: this.authenticityLevel(fileAssetIds.length),
      materialCount: fileAssetIds.length,
      updatedAt: project.updatedAt
    };
  }

  async submitFixedPriceBid(taskId: string, payload: Record<string, unknown>, context: RequestContext) {
    const project = await this.requireProject(taskId);
    const { currentSession, scope } = await this.eligibilityService.requireBidSubmitEligibilityFromContext(
      context,
      this.currentSessionVerificationService,
      project
    );
    const attachmentIds = await this.requireFileAssets(payload.attachmentFileAssetIds, scope.organization.id);
    const bid = this.bidRepository.create({
      id: randomUUID(),
      bidNo: `BID-${randomUUID().replace(/-/g, '').slice(0, 16).toUpperCase()}`,
      projectId: project.id,
      bidderOrganizationId: scope.organization.id,
      organizationId: scope.organization.id,
      actorId: currentSession.actorId,
      userId: currentSession.userId,
      quoteAmount: this.readMoney(payload.quoteAmount, 'quoteAmount').toFixed(2),
      proposalSummary: this.readProposal(payload),
      projectUnderstandingFileAssetId: attachmentIds[0] ?? null,
      quoteSheetFileAssetId: attachmentIds[1] ?? null,
      schedulePlanFileAssetId: attachmentIds[2] ?? null,
      state: 'submitted',
      submittedBy: currentSession.actorId ?? currentSession.userId,
      submittedAt: new Date()
    });
    const platformServiceFeeRequirement = await this.feeRatePolicy.buildRequirement({
      factoryOrganizationId: scope.organization.id,
      quotedAmount: bid.quoteAmount
    });
    await this.dataSource.transaction(async (manager) => {
      await manager.getRepository(BidEntity).save(bid);
      await this.bidSubmittedSeedService.createForSubmittedBid({
        manager, project, bid,
        bidderDisplayName: scope.organization.name ?? ''
      });
    });
    return {
      bidId: bid.id,
      bidStatus: 'pending_service_fee_authorization',
      platformServiceFeeRequirement,
      nextAction: 'create_service_fee_authorization',
      updatedAt: bid.updatedAt
    };
  }

  async submitInquiryQuotation(taskId: string, payload: Record<string, unknown>, context: RequestContext) {
    const project = await this.requireProject(taskId);
    const { currentSession, scope } = await this.eligibilityService.requireBidSubmitEligibilityFromContext(
      context,
      this.currentSessionVerificationService,
      project
    );
    await this.requireFileAssets(payload.attachmentFileAssetIds, scope.organization.id);
    const p0 = this.readP0(project);
    const quotations = this.readArray<SummaryRecord>(p0.inquiryQuotations);
    if (quotations.length >= 5) {
      throw p0PayInvalid('Inquiry quote seat is full.');
    }
    if (quotations.some((item) => item.factoryOrganizationId === scope.organization.id)) {
      throw p0PayInvalid('Current organization has already submitted inquiry quotation.');
    }
    const quotation = {
      quotationId: randomUUID(),
      factoryOrganizationId: scope.organization.id,
      quotedAmount: this.readMoney(payload.quotedAmount, 'quotedAmount').toFixed(2),
      quotationStatus: 'submitted',
      seatNo: quotations.length + 1,
      submittedBy: currentSession.userId,
      createdAt: new Date().toISOString()
    };
    await this.saveP0(project, { ...p0, inquiryQuotations: [...quotations, quotation] });
    return {
      quotationId: quotation.quotationId,
      quotationStatus: quotation.quotationStatus,
      quoteSeatSummary: this.toSeatSummary(quotations.length + 1),
      updatedAt: new Date()
    };
  }

  async processInquiryResult(taskId: string, payload: Record<string, unknown>, context: RequestContext) {
    const project = await this.requirePublisherProject(taskId, context);
    const action = this.readEnum(payload.processingAction, ['select_factory', 'close_without_deal', 'cancel_project'], 'processingAction');
    const deposit = await this.depositRepository.findOne({ where: { taskId }, order: { updatedAt: 'DESC' } });
    const depositStatus = action === 'select_factory' ? 'refund_pending' : (deposit?.status ?? 'not_required');
    if (deposit && action === 'select_factory' && deposit.status === 'paid') {
      deposit.status = 'refund_pending';
      deposit.refundRequestedAt = new Date();
      await this.depositRepository.save(deposit);
    }
    await this.saveP0(project, {
      ...this.readP0(project),
      inquiryResult: {
        processingStatus: action,
        selectedQuotationId: payload.selectedQuotationId ?? null,
        reasonCode: payload.reasonCode ?? '',
        reasonText: payload.reasonText ?? '',
        processedAt: new Date().toISOString()
      }
    });
    return {
      taskId,
      processingStatus: action,
      inquiryDepositStatus: depositStatus,
      contractHandoff: { available: action === 'select_factory' },
      creditImpactSummary: { candidate: action !== 'select_factory' },
      updatedAt: new Date()
    };
  }

  async getP0PaySummary(taskId: string, context: RequestContext) {
    const project = await this.requireProject(taskId);
    await this.assertRelatedScope(project, context);
    return this.toPricingSummary(project);
  }

  async releaseNonWinning(taskId: string, payload: Record<string, unknown>, context: RequestContext) {
    await this.requirePublisherProject(taskId, context);
    return this.stateActions.releaseNonWinningAuthorizations(taskId, this.readString(payload.winningBidId, 'winningBidId'), context);
  }

  async releasePublisherBreach(taskId: string, payload: Record<string, unknown>, context: RequestContext) {
    await this.requirePublisherProject(taskId, context);
    const bidId = typeof payload.bidId === 'string' && payload.bidId.trim() ? payload.bidId.trim() : null;
    return this.stateActions.releaseForPublisherBreach(taskId, bidId, context);
  }

  async holdFactoryRefusal(taskId: string, payload: Record<string, unknown>, context: RequestContext) {
    await this.requirePublisherProject(taskId, context);
    return this.stateActions.holdForFactoryRefusal(taskId, this.readString(payload.bidId, 'bidId'), context);
  }

  private async buildInlinePricingSummary(project: ProjectEntity, context: RequestContext) {
    try {
      return await this.getP0PaySummary(project.id, context);
    } catch {
      return { readOnly: true };
    }
  }

  private async toPricingSummary(project: ProjectEntity) {
    const [authorization, deposit] = await Promise.all([
      this.authorizationRepository.findOne({ where: { taskId: project.id }, order: { updatedAt: 'DESC' } }),
      this.depositRepository.findOne({ where: { taskId: project.id }, order: { updatedAt: 'DESC' } })
    ]);
    return {
      projectId: project.id,
      pricingRuleVersion: authorization?.ruleVersion ?? deposit?.ruleVersion ?? null,
      bidServiceFeeAuthorization: authorization
        ? {
            authorizationId: authorization.id,
            status: authorization.status,
            quotaAmount: authorization.authorizationQuotaAmount ?? '4000.00',
            chargedAmountUsed: authorization.chargedAmountUsed,
            releasedAmount: authorization.releasedAmount,
            finalFeeAmount: authorization.finalFeeAmount,
            currency: 'CNY'
          }
        : { status: 'not_required' },
      projectAuthenticitySincerity: deposit
        ? {
            orderId: deposit.id,
            status: deposit.status,
            amount: deposit.amount,
            currency: deposit.currency,
            channelCandidates: ['alipay_candidate', 'wechat_candidate', 'other_candidate']
          }
        : { status: 'not_required' },
      dealConfirmation: { status: authorization?.status === 'charged' ? 'confirmed_deal' : 'not_confirmed' },
      messageDisplaySummary: {
        displayAllowed: Boolean(authorization || deposit),
        readOnly: true,
        statusTextKey: authorization?.status ?? deposit?.status ?? 'pricing_status_unavailable',
        routeTarget: {
          objectType: 'project_pricing',
          actionKey: 'pricing_summary.read',
          canonicalPath: `/api/app/project/${project.id}/pricing-summary`,
          params: { projectId: project.id }
        }
      },
      updatedAt: project.updatedAt
    };
  }

  private async assertRelatedScope(project: ProjectEntity, context: RequestContext) {
    const scope = await this.currentScope(context);
    if (scope.organization.id === project.organizationId) return;
    const bid = await this.bidRepository.findOneBy({ projectId: project.id, bidderOrganizationId: scope.organization.id });
    if (!bid) throw p0PayPermissionDenied('Current organization cannot read this P0-Pay summary.');
  }

  private async requirePublisherProject(taskId: string, context: RequestContext) {
    const project = await this.requireProject(taskId);
    const scope = await this.currentScope(context);
    if (scope.organization.id !== project.organizationId) {
      throw p0PayPermissionDenied('Current organization does not own this trade task.');
    }
    return project;
  }

  private async currentScope(context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(context, this.currentSessionVerificationService);
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    if (!scope) throw p0PayPermissionDenied('Current organization scope is required for P0-Pay.');
    return scope;
  }

  private async requireProject(taskId: string) {
    const project = await this.projectRepository.findOneBy({ id: taskId.trim() });
    if (!project) throw p0PayResourceUnavailable('Current trade task is unavailable.');
    return project;
  }

  private async requireFileAssets(value: unknown, organizationId: string) {
    const ids = this.readStringArray(value, 'fileAssetIds');
    if (ids.length === 0) return ids;
    const found = await this.fileAssetRepository.findBy(ids.map((id) => ({ id, organizationId })));
    if (found.length !== ids.length) {
      throw p0PayInvalid('P0-Pay materials must reference confirmed FileAsset truth owned by current organization.');
    }
    return ids;
  }

  private buildTaskSummary(payload: Record<string, unknown>, taskType: string) {
    return {
      heading: 'P0-Pay trade task',
      p0PayTask: {
        taskType,
        quoteDeadlineAt: this.readString(payload.quoteDeadlineAt, 'quoteDeadlineAt'),
        budgetRange: this.readString(payload.budgetRange, 'budgetRange'),
        contactId: this.readString(payload.contactId, 'contactId'),
        authenticityMaterialFileAssetIds: this.readStringArray(payload.authenticityMaterialFileAssetIds, 'authenticityMaterialFileAssetIds'),
        authenticityDeclarations: payload.authenticityDeclarations ?? {},
        createdAt: new Date().toISOString()
      }
    };
  }

  private toCreateResponse(project: ProjectEntity, taskType: string) {
    return {
      taskId: project.id,
      taskType,
      taskStatus: project.state,
      authenticityLevel: this.authenticityLevel(
        this.readArray(this.readP0(project).authenticityMaterialFileAssetIds).length
      ),
      publishGateStatus: project.state === 'published' ? 'passed' : 'payment_required',
      paymentRequirement: taskType === 'inquiry_quote'
        ? { required: true, requirementType: 'inquiry_deposit_payment_required', amount: '200.00', currency: 'CNY', reasonCode: 'inquiry_deposit_required' }
        : { required: false, requirementType: 'none', amount: '0.00', currency: 'CNY', reasonCode: 'not_required' },
      nextAction: taskType === 'inquiry_quote' ? 'create_inquiry_deposit_order' : 'wait_fixed_price_bids',
      updatedAt: project.updatedAt
    };
  }

  private async quoteSeatSummary(taskId: string) {
    const project = await this.requireProject(taskId);
    return this.toSeatSummary(this.readArray(this.readP0(project).inquiryQuotations).length);
  }

  private toSeatSummary(used: number) {
    return { seatLimit: 5, seatUsed: used, seatRemaining: Math.max(0, 5 - used), quoteEntryOpen: used < 5 };
  }

  private authenticitySummary(project: ProjectEntity) {
    const p0 = this.readP0(project);
    const count = this.readArray(p0.authenticityMaterialFileAssetIds).length;
    return { authenticityLevel: this.authenticityLevel(count), materialCount: count };
  }

  private authenticityLevel(count: number) {
    if (count >= 2) return 'T2';
    if (count === 1) return 'T1';
    return 'T0';
  }

  private async saveP0(project: ProjectEntity, p0: SummaryRecord) {
    project.summary = { ...project.summary, p0PayTask: p0 };
    await this.projectRepository.save(project);
  }

  private readP0(project: ProjectEntity) {
    const value = project.summary?.p0PayTask;
    return value && typeof value === 'object' && !Array.isArray(value) ? value as SummaryRecord : {};
  }

  private taskType(project: ProjectEntity) {
    return String(this.readP0(project).taskType ?? 'fixed_price_bid');
  }

  private readProposal(payload: Record<string, unknown>) {
    return [
      this.readString(payload.constructionPlan, 'constructionPlan'),
      this.readString(payload.materialDescription, 'materialDescription'),
      this.readString(payload.craftDescription, 'craftDescription'),
      this.readString(payload.buildProcess, 'buildProcess'),
      this.readString(payload.riskNotes, 'riskNotes')
    ].join('\n');
  }

  private readStringArray(value: unknown, field: string) {
    if (!Array.isArray(value)) throw p0PayInvalid(`Field \`${field}\` must be an array.`);
    return value.map((item) => this.readString(item, field));
  }

  private readArray<T>(value: unknown): T[] {
    return Array.isArray(value) ? value as T[] : [];
  }

  private readEnum(value: unknown, allowed: string[], field: string) {
    const text = this.readString(value, field);
    if (!allowed.includes(text)) throw p0PayInvalid(`Field \`${field}\` is not supported.`);
    return text;
  }

  private readString(value: unknown, field: string) {
    if (typeof value !== 'string' || !value.trim()) throw p0PayInvalid(`Field \`${field}\` is required.`);
    return value.trim();
  }

  private readMoney(value: unknown, field: string) {
    const amount = typeof value === 'number' ? value : Number(value);
    if (!Number.isFinite(amount) || amount <= 0) throw p0PayInvalid(`Field \`${field}\` must be positive.`);
    return amount;
  }

  private buildProjectNo() {
    return `P0PAY-${Date.now()}-${randomUUID().replace(/-/g, '').slice(0, 8).toUpperCase()}`;
  }
}
