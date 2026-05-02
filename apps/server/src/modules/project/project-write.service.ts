import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, EntityManager, Repository } from 'typeorm';
import { ProjectPublishAuditService } from '../audit/project-publish-audit.service';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { authPermissionInsufficient } from '../organization/organization-auth.errors';
import { InquiryQuoteDepositEntity } from '../p0_pay/entities/inquiry-quote-deposit.entity';
import { projectAuthenticitySincerityRequired } from '../p0_pay/p0-pay.errors';
import {
  PROJECT_AUTHENTICITY_SINCERITY_INTERNAL_TEST_GATE_STATUS,
  PROJECT_AUTHENTICITY_SINCERITY_INTERNAL_TEST_STATUS,
  projectAuthenticitySincerityInternalTestNoFreezeEnabled,
} from '../p0_pay/p0-pay-internal-test-no-freeze.policy';
import { VerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { ProjectEntity } from './entities/project.entity';
import {
  projectCreateInvalid,
  projectInvalidState,
  projectPublishInvalid,
  projectSaveInvalid,
  projectSubmitInvalid,
  projectUnavailable,
} from './project.errors';
import { ProjectPresenter } from './project.presenter';

const PROJECT_DRAFT_STATE = 'draft';
const PROJECT_SUBMITTED_STATE = 'submitted';
const PROJECT_PUBLISHED_STATE = 'published';

type ProjectSnapshotCommand = {
  title: string;
  exhibitionName: string | null;
  brandName: string | null;
  buildingType: string;
  budgetAmount: number;
  areaSqm: number | null;
  buildingTypeRemark: string | null;
  provinceCode: string;
  provinceName: string;
  cityCode: string;
  cityName: string;
  districtCode: string | null;
  districtName: string | null;
  detailAddress: string;
  scopeSummary: string | null;
  plannedStartAt: string | null;
  plannedEndAt: string | null;
  scheduleDetail: string | null;
  description: string | null;
};

type SaveProjectCommand = ProjectSnapshotCommand & {
  projectId: string;
};

type ProjectLifecycleActionCommand = {
  projectId: string;
};

@Injectable()
export class ProjectWriteService {
  constructor(
    @InjectRepository(ProjectEntity)
    private readonly projectRepository: Repository<ProjectEntity>,
    private readonly dataSource: DataSource,
    private readonly presenter: ProjectPresenter,
    private readonly auditService: ProjectPublishAuditService,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService
  ) {}

  async createProject(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toProjectSnapshotCommand(payload, projectCreateInvalid);
    const { currentSession, scope } =
      await this.eligibilityService.requireProjectPublishEligibilityFromContext(
        context,
        this.currentSessionVerificationService
      );

    const auditContext = this.buildVerifiedAuditContext(context, currentSession, scope);
    const projectId = randomUUID();
    const now = new Date();
    const project = this.projectRepository.create({
      id: projectId,
      projectNo: this.buildProjectNo(),
      organizationId: scope.organization.id,
      creatorUserId: currentSession.userId,
      creatorActorId: currentSession.actorId,
      ...this.toProjectPersistence(command),
      state: PROJECT_DRAFT_STATE,
      summary: this.buildProjectSummary(PROJECT_DRAFT_STATE),
      publishedAt: null,
      createdAt: now,
      updatedAt: now,
    });

    await this.dataSource.transaction(async (manager) => {
      await manager.getRepository(ProjectEntity).save(project);
      await this.auditService.record(
        {
          aggregateType: 'project',
          aggregateId: project.id,
          eventType: 'project_created',
          payload: {
            state: project.state,
            title: project.title,
            exhibitionName: project.exhibitionName,
            brandName: project.brandName,
            buildingType: project.buildingType,
            budgetAmount: Number(project.budgetAmount),
          },
        },
        auditContext,
        manager
      );
    });

    return this.presenter.toAcceptedResponse(project.id, project.state);
  }

  async saveProject(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toSaveProjectCommand(payload);
    const { currentSession, scope } =
      await this.eligibilityService.requireProjectPublishEligibilityFromContext(
        context,
        this.currentSessionVerificationService
      );
    const auditContext = this.buildVerifiedAuditContext(context, currentSession, scope);

    return this.dataSource.transaction(async (manager) => {
      const repository = manager.getRepository(ProjectEntity);
      const project = await this.requireOwnedProject(command.projectId, scope.organization.id, repository);
      if (project.state !== PROJECT_DRAFT_STATE) {
        throw projectInvalidState('Only draft projects may be saved.');
      }

      Object.assign(project, this.toProjectPersistence(command), {
        state: PROJECT_DRAFT_STATE,
        summary: this.buildProjectSummary(PROJECT_DRAFT_STATE),
      });
      await repository.save(project);
      await this.auditService.record(
        {
          aggregateType: 'project',
          aggregateId: project.id,
          eventType: 'project_saved',
          payload: {
            state: project.state,
            title: project.title,
            exhibitionName: project.exhibitionName,
            brandName: project.brandName,
          },
        },
        auditContext,
        manager
      );

      return this.presenter.toAcceptedResponse(project.id, project.state);
    });
  }

  async submitProject(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toProjectLifecycleActionCommand(
      payload,
      projectSubmitInvalid,
      'Project submit body must be an object.',
      'Field `projectId` is required for project submit.'
    );
    const { currentSession, scope } =
      await this.eligibilityService.requireProjectPublishEligibilityFromContext(
        context,
        this.currentSessionVerificationService
      );
    const auditContext = this.buildVerifiedAuditContext(context, currentSession, scope);

    return this.dataSource.transaction(async (manager) => {
      const repository = manager.getRepository(ProjectEntity);
      const project = await this.requireOwnedProject(command.projectId, scope.organization.id, repository);
      if (project.state !== PROJECT_DRAFT_STATE) {
        throw projectInvalidState('Only draft projects may be submitted.');
      }

      project.state = PROJECT_SUBMITTED_STATE;
      project.summary = this.buildProjectSummary(PROJECT_SUBMITTED_STATE);
      await repository.save(project);
      await this.auditService.record(
        {
          aggregateType: 'project',
          aggregateId: project.id,
          eventType: 'project_submitted',
          payload: {
            state: project.state,
          },
        },
        auditContext,
        manager
      );

      return this.presenter.toAcceptedResponse(project.id, project.state);
    });
  }

  async publishProject(payload: Record<string, unknown>, context: RequestContext) {
    const command = this.toProjectLifecycleActionCommand(
      payload,
      projectPublishInvalid,
      'Project publish body must be an object.',
      'Field `projectId` is required for project publish.'
    );
    const { currentSession, scope } =
      await this.eligibilityService.requireProjectPublishEligibilityFromContext(
        context,
        this.currentSessionVerificationService
      );
    const auditContext = this.buildVerifiedAuditContext(context, currentSession, scope);

    return this.dataSource.transaction(async (manager) => {
      const repository = manager.getRepository(ProjectEntity);
      const project = await this.requireOwnedProject(command.projectId, scope.organization.id, repository);
      if (project.state !== PROJECT_SUBMITTED_STATE) {
        throw projectInvalidState('Only submitted projects may be published.');
      }
      const pricingGate = await this.requirePaidPricingGate(manager, project, auditContext);

      project.state = PROJECT_PUBLISHED_STATE;
      project.summary = this.buildProjectSummary(PROJECT_PUBLISHED_STATE);
      project.publishedAt = new Date();
      await repository.save(project);
      await this.auditService.record(
        {
          aggregateType: 'project',
          aggregateId: project.id,
          eventType: 'project_published',
          payload: {
            state: project.state,
            publishedAt: project.publishedAt?.toISOString() ?? null,
            pricingGateApplied: true,
            authenticitySincerityRequired: true,
            authenticitySincerityStatus: pricingGate.authenticitySincerityStatus,
            authenticitySincerityGateResult: pricingGate.authenticitySincerityGateResult,
            authenticitySincerityOrderId: pricingGate.orderId,
          },
        },
        auditContext,
        manager
      );

      return this.presenter.toAcceptedResponse(project.id, project.state);
    });
  }

  private async requirePaidPricingGate(
    manager: EntityManager,
    project: ProjectEntity,
    auditContext: RequestContext
  ) {
    const order = await manager.getRepository(InquiryQuoteDepositEntity).findOne({
      where: {
        taskId: project.id,
        publisherOrganizationId: project.organizationId,
        status: 'paid',
      },
      order: { updatedAt: 'DESC' },
    });
    if (order) {
      return {
        orderId: order.id,
        authenticitySincerityStatus: 'paid',
        authenticitySincerityGateResult: 'paid',
      };
    }

    const latestOrder = await manager.getRepository(InquiryQuoteDepositEntity).findOne({
      where: {
        taskId: project.id,
        publisherOrganizationId: project.organizationId,
      },
      order: { updatedAt: 'DESC' },
    });
    if (
      projectAuthenticitySincerityInternalTestNoFreezeEnabled() &&
      latestOrder?.paymentOrderId
    ) {
      await this.auditService.record(
        {
          aggregateType: 'project',
          aggregateId: project.id,
          eventType: 'project_publish_pricing_gate_internal_test_no_freeze',
          payload: {
            pricingGateApplied: true,
            authenticitySincerityRequired: true,
            authenticitySincerityStatus: PROJECT_AUTHENTICITY_SINCERITY_INTERNAL_TEST_STATUS,
            authenticitySincerityGateResult: PROJECT_AUTHENTICITY_SINCERITY_INTERNAL_TEST_GATE_STATUS,
            authenticitySincerityOrderId: latestOrder.id,
          },
        },
        auditContext,
        manager
      );
      return {
        orderId: latestOrder.id,
        authenticitySincerityStatus: PROJECT_AUTHENTICITY_SINCERITY_INTERNAL_TEST_STATUS,
        authenticitySincerityGateResult: PROJECT_AUTHENTICITY_SINCERITY_INTERNAL_TEST_GATE_STATUS,
      };
    }

    await this.auditService.record(
      {
        aggregateType: 'project',
        aggregateId: project.id,
        eventType: 'project_publish_blocked_by_pricing_gate',
        payload: {
          pricingGateApplied: true,
          authenticitySincerityRequired: true,
          requiredOrderStatus: 'paid',
          actualOrderStatus: 'missing_or_unpaid',
          pricingErrorCode: 'PROJECT_AUTHENTICITY_SINCERITY_REQUIRED',
        },
      },
      auditContext,
      manager
    );
    throw projectAuthenticitySincerityRequired();
  }

  async deleteProject(projectId: string, context: RequestContext) {
    const normalizedProjectId = projectId.trim();
    if (!normalizedProjectId) {
      throw projectUnavailable('Current project is unavailable.');
    }

    const { currentSession, scope } =
      await this.eligibilityService.requireProjectPublishEligibilityFromContext(
        context,
        this.currentSessionVerificationService
      );
    const auditContext = this.buildVerifiedAuditContext(context, currentSession, scope);

    return this.dataSource.transaction(async (manager) => {
      const repository = manager.getRepository(ProjectEntity);
      const project = await this.requireOwnedProject(
        normalizedProjectId,
        scope.organization.id,
        repository
      );
      if (project.state !== PROJECT_DRAFT_STATE) {
        throw projectInvalidState('Only draft projects may be deleted.');
      }

      await repository.delete({ id: project.id, organizationId: scope.organization.id });
      await this.auditService.record(
        {
          aggregateType: 'project',
          aggregateId: project.id,
          eventType: 'project_deleted',
          payload: {
            state: 'deleted',
            previousState: project.state,
            title: project.title,
            exhibitionName: project.exhibitionName,
            brandName: project.brandName,
          },
        },
        auditContext,
        manager
      );

      return this.presenter.toDeleteAcceptedResponse(project.id);
    });
  }

  private async requireOwnedProject(
    projectId: string,
    organizationId: string,
    repository: Repository<ProjectEntity>
  ) {
    const project = await repository.findOneBy({
      id: projectId,
      organizationId,
    });
    if (!project) {
      throw projectUnavailable('Current project is unavailable.');
    }
    return project;
  }

  private toSaveProjectCommand(payload: Record<string, unknown>) {
    const source = this.asRecord(
      payload,
      projectSaveInvalid,
      'Project save body must be an object.'
    );
    return {
      projectId: this.readRequiredString(
        source.projectId,
        'projectId',
        projectSaveInvalid,
        'Field `projectId` is required for project save.'
      ),
      ...this.toProjectSnapshotCommand(source, projectSaveInvalid),
    } satisfies SaveProjectCommand;
  }

  private toProjectLifecycleActionCommand(
    payload: Record<string, unknown>,
    invalidErrorFactory: (message: string) => Error,
    invalidBodyMessage: string,
    invalidProjectIdMessage: string
  ) {
    const source = this.asRecord(payload, invalidErrorFactory, invalidBodyMessage);
    return {
      projectId: this.readRequiredString(
        source.projectId,
        'projectId',
        invalidErrorFactory,
        invalidProjectIdMessage
      ),
    } satisfies ProjectLifecycleActionCommand;
  }

  private toProjectSnapshotCommand(
    payload: Record<string, unknown>,
    invalidErrorFactory: (message: string) => Error
  ) {
    const source = this.asRecord(payload, invalidErrorFactory, 'Project create body must be an object.');
    const title = this.readOptionalString(source.title, 'title', invalidErrorFactory);
    const exhibitionName = this.readOptionalString(
      source.exhibitionName,
      'exhibitionName',
      invalidErrorFactory
    );
    const brandName = this.readOptionalString(source.brandName, 'brandName', invalidErrorFactory);
    const naming = this.resolveProjectNaming({ title, exhibitionName, brandName }, invalidErrorFactory);

    return {
      title: naming.title,
      exhibitionName: naming.exhibitionName,
      brandName: naming.brandName,
      buildingType: this.readRequiredString(
        source.buildingType,
        'buildingType',
        invalidErrorFactory
      ),
      budgetAmount: this.readBudgetAmount(source.budgetAmount, invalidErrorFactory),
      areaSqm: this.readOptionalAreaSqm(source.areaSqm, invalidErrorFactory),
      buildingTypeRemark: this.readOptionalString(
        source.buildingTypeRemark,
        'buildingTypeRemark',
        invalidErrorFactory,
        100
      ),
      provinceCode: this.readRequiredString(
        source.provinceCode,
        'provinceCode',
        invalidErrorFactory
      ),
      provinceName: this.readRequiredString(
        source.provinceName,
        'provinceName',
        invalidErrorFactory
      ),
      cityCode: this.readRequiredString(source.cityCode, 'cityCode', invalidErrorFactory),
      cityName: this.readRequiredString(source.cityName, 'cityName', invalidErrorFactory),
      ...this.readDistrictLocation(source, invalidErrorFactory),
      detailAddress: this.readRequiredString(
        source.detailAddress,
        'detailAddress',
        invalidErrorFactory
      ),
      scopeSummary: this.readOptionalString(source.scopeSummary, 'scopeSummary', invalidErrorFactory),
      plannedStartAt: this.readOptionalDateString(
        source.plannedStartAt,
        'plannedStartAt',
        invalidErrorFactory
      ),
      plannedEndAt: this.readOptionalDateString(
        source.plannedEndAt,
        'plannedEndAt',
        invalidErrorFactory
      ),
      scheduleDetail: this.readOptionalString(
        source.scheduleDetail,
        'scheduleDetail',
        invalidErrorFactory,
        200
      ),
      description: this.readOptionalString(source.description, 'description', invalidErrorFactory),
    } satisfies ProjectSnapshotCommand;
  }

  private toProjectPersistence(command: ProjectSnapshotCommand) {
    return {
      title: command.title,
      exhibitionName: command.exhibitionName,
      brandName: command.brandName,
      buildingType: command.buildingType,
      budgetAmount: command.budgetAmount.toFixed(2),
      areaSqm: command.areaSqm === null ? null : command.areaSqm.toFixed(2),
      buildingTypeRemark: command.buildingTypeRemark,
      provinceCode: command.provinceCode,
      provinceName: command.provinceName,
      cityCode: command.cityCode,
      cityName: command.cityName,
      districtCode: command.districtCode,
      districtName: command.districtName,
      detailAddress: command.detailAddress,
      scopeSummary: command.scopeSummary,
      plannedStartAt: command.plannedStartAt,
      plannedEndAt: command.plannedEndAt,
      scheduleDetail: command.scheduleDetail,
      description: command.description,
    };
  }

  private resolveProjectNaming(
    source: {
      title: string | null;
      exhibitionName: string | null;
      brandName: string | null;
    },
    invalidErrorFactory: (message: string) => Error
  ) {
    const hasDualFieldInput = Boolean(source.exhibitionName || source.brandName);
    if (hasDualFieldInput && (!source.exhibitionName || !source.brandName)) {
      throw invalidErrorFactory(
        'Fields `exhibitionName` and `brandName` must both be provided for dual-field project create.'
      );
    }
    if (source.exhibitionName && source.brandName) {
      return {
        title: source.title ?? `${source.exhibitionName} / ${source.brandName}`,
        exhibitionName: source.exhibitionName,
        brandName: source.brandName,
      };
    }
    if (!source.title) {
      throw invalidErrorFactory('Field `title` is required for project create.');
    }
    return {
      title: source.title,
      exhibitionName: null,
      brandName: null,
    };
  }

  private buildProjectNo() {
    const now = new Date();
    const year = now.getUTCFullYear();
    const suffix = randomUUID().replace(/-/g, '').slice(0, 6).toUpperCase();
    return `EXH-${year}-${suffix}`;
  }

  private buildProjectSummary(state: string) {
    if (state === PROJECT_DRAFT_STATE) {
      return {
        heading: '项目草稿已创建，可继续编辑后提交。',
        stateLabel: '当前项目为草稿，尚未进入公域展示。'
      };
    }
    if (state === PROJECT_SUBMITTED_STATE) {
      return {
        heading: '项目已提交发布链路，可继续执行发布。',
        stateLabel: '当前项目已提交，尚未进入公域展示。'
      };
    }
    return {
      heading: '项目已进入最小发布走廊。',
      stateLabel: '当前项目已发布，可继续进入最小竞标继续面。'
    };
  }

  private readRequiredString(
    value: unknown,
    field: string,
    invalidErrorFactory: (message: string) => Error,
    message?: string
  ) {
    if (typeof value !== 'string') {
      throw invalidErrorFactory(message ?? `Field \`${field}\` is required for project create.`);
    }
    const normalized = value.trim();
    if (!normalized) {
      throw invalidErrorFactory(message ?? `Field \`${field}\` is required for project create.`);
    }
    return normalized;
  }

  private readOptionalString(
    value: unknown,
    field: string,
    invalidErrorFactory: (message: string) => Error,
    maxLength?: number
  ) {
    if (value === undefined || value === null) {
      return null;
    }
    if (typeof value !== 'string') {
      throw invalidErrorFactory(`Field \`${field}\` must be a string when provided.`);
    }
    const normalized = value.trim();
    if (maxLength !== undefined && normalized.length > maxLength) {
      throw invalidErrorFactory(
        `Field \`${field}\` must not exceed ${maxLength} characters when provided.`
      );
    }
    return normalized ? normalized : null;
  }

  private readOptionalDateString(
    value: unknown,
    field: string,
    invalidErrorFactory: (message: string) => Error
  ) {
    const normalized = this.readOptionalString(value, field, invalidErrorFactory);
    if (!normalized) {
      return null;
    }
    if (!/^\d{4}-\d{2}-\d{2}$/.test(normalized)) {
      throw invalidErrorFactory(`Field \`${field}\` must use YYYY-MM-DD format when provided.`);
    }
    const parsed = new Date(`${normalized}T00:00:00.000Z`);
    if (Number.isNaN(parsed.getTime()) || parsed.toISOString().slice(0, 10) !== normalized) {
      throw invalidErrorFactory(
        `Field \`${field}\` must be a valid YYYY-MM-DD date when provided.`
      );
    }
    return normalized;
  }

  private readOptionalAreaSqm(
    value: unknown,
    invalidErrorFactory: (message: string) => Error
  ) {
    if (value === undefined || value === null) {
      return null;
    }
    const normalized =
      typeof value === 'number'
        ? String(value)
        : typeof value === 'string'
          ? value.trim()
          : null;
    if (!normalized || !/^\d+(\.\d{1,2})?$/.test(normalized)) {
      throw invalidErrorFactory(
        'Field `areaSqm` must be a positive number with up to 2 decimal places when provided.'
      );
    }
    const areaSqm = Number(normalized);
    if (!Number.isFinite(areaSqm) || areaSqm <= 0) {
      throw invalidErrorFactory(
        'Field `areaSqm` must be a positive number with up to 2 decimal places when provided.'
      );
    }
    return areaSqm;
  }

  private readDistrictLocation(
    source: Record<string, unknown>,
    invalidErrorFactory: (message: string) => Error
  ) {
    const districtCode = this.readOptionalString(
      source.districtCode,
      'districtCode',
      invalidErrorFactory
    );
    const districtName = this.readOptionalString(
      source.districtName,
      'districtName',
      invalidErrorFactory
    );
    if (!districtCode && !districtName) {
      return {
        districtCode: null,
        districtName: null,
      };
    }
    if (!districtCode || !districtName) {
      throw invalidErrorFactory(
        'Fields `districtCode` and `districtName` must both be provided or both be null for project create.'
      );
    }
    return {
      districtCode,
      districtName,
    };
  }

  private readBudgetAmount(value: unknown, invalidErrorFactory: (message: string) => Error) {
    const amount = typeof value === 'number' ? value : Number(value);
    if (!Number.isFinite(amount) || amount <= 0) {
      throw invalidErrorFactory(
        'Field `budgetAmount` must be a positive number for project create.'
      );
    }
    return amount;
  }

  private buildVerifiedAuditContext(
    context: RequestContext,
    currentSession: VerifiedCurrentSessionContext,
    scope: Awaited<ReturnType<CurrentActorEligibilityService['getCurrentOrganizationScope']>>
  ): RequestContext {
    if (!scope) {
      throw authPermissionInsufficient(
        'Current actor lacks the required organization scope for project create.'
      );
    }
    return {
      ...context,
      actorId: currentSession.actorId,
      userId: currentSession.userId,
      organizationId: scope.organization.id,
      actorRole: scope.membership.roleKey,
    };
  }

  private asRecord(
    value: unknown,
    invalidErrorFactory: (message: string) => Error,
    message: string
  ) {
    if (!value || Array.isArray(value) || typeof value !== 'object') {
      throw invalidErrorFactory(message);
    }
    return value as Record<string, unknown>;
  }
}
