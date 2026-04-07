import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, Repository } from 'typeorm';
import { ProjectPublishAuditService } from '../audit/project-publish-audit.service';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { authPermissionInsufficient } from '../organization/organization-auth.errors';
import {
  requireVerifiedCurrentSessionContext,
  VerifiedCurrentSessionContext
} from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { ProjectEntity } from './entities/project.entity';
import { projectCreateInvalid } from './project.errors';
import { ProjectPresenter } from './project.presenter';

type CreateProjectCommand = {
  title: string;
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
  scopeSummary: string;
  plannedStartAt: string | null;
  plannedEndAt: string | null;
  scheduleDetail: string | null;
  description: string | null;
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
    const command = this.toCreateCommand(payload);
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    if (!scope) {
      throw authPermissionInsufficient(
        'Current actor lacks the required organization scope for project create.'
      );
    }

    const auditContext = this.buildVerifiedAuditContext(context, currentSession, scope);
    const projectId = randomUUID();
    const project = this.projectRepository.create({
      id: projectId,
      projectNo: this.buildProjectNo(),
      organizationId: scope.organization.id,
      creatorUserId: currentSession.userId,
      creatorActorId: currentSession.actorId,
      title: command.title,
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
      state: 'published',
      summary: {
        heading: '项目已进入最小发布走廊。',
        stateLabel: '当前项目已发布，可继续进入最小竞标继续面。'
      },
      publishedAt: new Date()
    });

    await this.dataSource.transaction(async (manager) => {
      await manager.getRepository(ProjectEntity).save(project);
      await this.auditService.record(
        {
          aggregateType: 'project',
          aggregateId: project.id,
          eventType: 'project_created',
          payload: {
            title: project.title,
            buildingType: project.buildingType,
            budgetAmount: Number(project.budgetAmount)
          }
        },
        auditContext,
        manager
      );
    });

    return this.presenter.toAcceptedResponse(project.id);
  }

  private toCreateCommand(payload: Record<string, unknown>): CreateProjectCommand {
    const source = this.asRecord(payload);
    const title = this.readRequiredString(source.title, 'title');
    const buildingType = this.readRequiredString(source.buildingType, 'buildingType');
    const budgetAmount = this.readBudgetAmount(source.budgetAmount);
    const areaSqm = this.readOptionalAreaSqm(source.areaSqm);
    const buildingTypeRemark = this.readOptionalString(
      source.buildingTypeRemark,
      'buildingTypeRemark',
      100
    );
    const provinceCode = this.readRequiredString(source.provinceCode, 'provinceCode');
    const provinceName = this.readRequiredString(source.provinceName, 'provinceName');
    const cityCode = this.readRequiredString(source.cityCode, 'cityCode');
    const cityName = this.readRequiredString(source.cityName, 'cityName');
    const { districtCode, districtName } = this.readDistrictLocation(source);
    const detailAddress = this.readRequiredString(source.detailAddress, 'detailAddress');
    const scopeSummary = this.readRequiredString(source.scopeSummary, 'scopeSummary');
    const plannedStartAt = this.readOptionalDateString(source.plannedStartAt, 'plannedStartAt');
    const plannedEndAt = this.readOptionalDateString(source.plannedEndAt, 'plannedEndAt');
    const scheduleDetail = this.readOptionalString(source.scheduleDetail, 'scheduleDetail', 200);
    const description = this.readOptionalString(source.description, 'description');
    return {
      title,
      buildingType,
      budgetAmount,
      areaSqm,
      buildingTypeRemark,
      provinceCode,
      provinceName,
      cityCode,
      cityName,
      districtCode,
      districtName,
      detailAddress,
      scopeSummary,
      plannedStartAt,
      plannedEndAt,
      scheduleDetail,
      description
    };
  }

  private readRequiredString(value: unknown, field: string) {
    if (typeof value !== 'string') {
      throw projectCreateInvalid(`Field \`${field}\` is required for project create.`);
    }
    const normalized = value.trim();
    if (!normalized) {
      throw projectCreateInvalid(`Field \`${field}\` is required for project create.`);
    }
    return normalized;
  }

  private readOptionalString(value: unknown, field: string, maxLength?: number) {
    if (value === undefined || value === null) {
      return null;
    }
    if (typeof value !== 'string') {
      throw projectCreateInvalid(`Field \`${field}\` must be a string when provided.`);
    }
    const normalized = value.trim();
    if (maxLength !== undefined && normalized.length > maxLength) {
      throw projectCreateInvalid(
        `Field \`${field}\` must not exceed ${maxLength} characters when provided.`
      );
    }
    return normalized ? normalized : null;
  }

  private readOptionalDateString(value: unknown, field: string) {
    const normalized = this.readOptionalString(value, field);
    if (!normalized) {
      return null;
    }
    if (!/^\d{4}-\d{2}-\d{2}$/.test(normalized)) {
      throw projectCreateInvalid(`Field \`${field}\` must use YYYY-MM-DD format when provided.`);
    }
    const parsed = new Date(`${normalized}T00:00:00.000Z`);
    if (Number.isNaN(parsed.getTime()) || parsed.toISOString().slice(0, 10) !== normalized) {
      throw projectCreateInvalid(`Field \`${field}\` must be a valid YYYY-MM-DD date when provided.`);
    }
    return normalized;
  }

  private readOptionalAreaSqm(value: unknown) {
    if (value === undefined || value === null) {
      return null;
    }

    const normalized =
      typeof value === 'number'
        ? String(value)
        : typeof value === 'string'
          ? value.trim()
          : null;
    if (!normalized) {
      throw projectCreateInvalid(
        'Field `areaSqm` must be a positive number with up to 2 decimal places when provided.'
      );
    }
    if (!/^\d+(\.\d{1,2})?$/.test(normalized)) {
      throw projectCreateInvalid(
        'Field `areaSqm` must be a positive number with up to 2 decimal places when provided.'
      );
    }

    const areaSqm = Number(normalized);
    if (!Number.isFinite(areaSqm) || areaSqm <= 0) {
      throw projectCreateInvalid(
        'Field `areaSqm` must be a positive number with up to 2 decimal places when provided.'
      );
    }
    return areaSqm;
  }

  private readDistrictLocation(source: Record<string, unknown>) {
    const districtCode = this.readOptionalString(source.districtCode, 'districtCode');
    const districtName = this.readOptionalString(source.districtName, 'districtName');
    if (!districtCode && !districtName) {
      return {
        districtCode: null,
        districtName: null
      };
    }
    if (!districtCode || !districtName) {
      throw projectCreateInvalid(
        'Fields `districtCode` and `districtName` must both be provided or both be null for project create.'
      );
    }
    return {
      districtCode,
      districtName
    };
  }

  private readBudgetAmount(value: unknown) {
    const amount = typeof value === 'number' ? value : Number(value);
    if (!Number.isFinite(amount) || amount <= 0) {
      throw projectCreateInvalid('Field `budgetAmount` must be a positive number for project create.');
    }
    return amount;
  }

  private buildProjectNo() {
    const now = new Date();
    const year = now.getUTCFullYear();
    const suffix = randomUUID().replace(/-/g, '').slice(0, 6).toUpperCase();
    return `EXH-${year}-${suffix}`;
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
      actorRole: scope.membership.roleKey
    };
  }

  private asRecord(value: unknown) {
    if (!value || Array.isArray(value) || typeof value !== 'object') {
      throw projectCreateInvalid('Project create body must be an object.');
    }
    return value as Record<string, unknown>;
  }
}
