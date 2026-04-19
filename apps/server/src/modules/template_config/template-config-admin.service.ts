import { Injectable } from '@nestjs/common';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import {
  TemplateConfigArchiveCommand,
  TemplateConfigCreateTemplateCommand,
  TemplateConfigCreateVersionCommand,
  TemplateConfigGroupingCommand,
  TemplateConfigListQuery,
  TemplateConfigPublishCommand,
  TemplateConfigVersionListQuery
} from './template-config.types';
import { TemplateConfigStore } from './template-config.store';
import { TemplateConfigPresenter } from './template-config.presenter';

@Injectable()
export class TemplateConfigAdminService {
  constructor(
    private readonly store: TemplateConfigStore,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: TemplateConfigPresenter
  ) {}

  async list(query: TemplateConfigListQuery, context: RequestContext) {
    await this.requireReviewer(context);
    const result = this.store.listTemplates(query);
    return {
      items: result.items.map((item) => this.presenter.toTemplateListItem(item)),
      pagination: {
        page: query.page,
        pageSize: query.pageSize,
        total: result.total
      }
    };
  }

  async detail(templateId: string, context: RequestContext) {
    await this.requireReviewer(context);
    return this.presenter.toTemplateDetail(this.store.getTemplate(templateId));
  }

  async versions(templateId: string, query: TemplateConfigVersionListQuery, context: RequestContext) {
    await this.requireReviewer(context);
    const result = this.store.listVersions(templateId, query);
    return {
      items: result.items.map((item) => this.presenter.toVersionListItem(item)),
      pagination: {
        page: query.page,
        pageSize: query.pageSize,
        total: result.total
      }
    };
  }

  async versionDetail(templateId: string, templateVersionId: string, context: RequestContext) {
    await this.requireReviewer(context);
    return this.presenter.toVersionDetail(this.store.getVersion(templateId, templateVersionId));
  }

  async compare(
    templateId: string,
    baseVersionId: string,
    targetVersionId: string,
    context: RequestContext
  ) {
    await this.requireReviewer(context);
    return this.presenter.toCompareProjection(
      this.store.compareVersions(templateId, baseVersionId, targetVersionId)
    );
  }

  async createTemplate(command: TemplateConfigCreateTemplateCommand, context: RequestContext) {
    await this.requireReviewer(context);
    return this.presenter.toTemplateDetail(this.store.createTemplate(command).template);
  }

  async createVersion(
    templateId: string,
    command: TemplateConfigCreateVersionCommand,
    context: RequestContext
  ) {
    await this.requireReviewer(context);
    return this.presenter.toVersionDetail(this.store.createVersion(templateId, command).version);
  }

  async publishVersion(
    templateId: string,
    templateVersionId: string,
    command: TemplateConfigPublishCommand,
    context: RequestContext
  ) {
    await this.requireReviewer(context);
    const result = this.store.publishVersion(templateId, templateVersionId, command);
    return {
      template: this.presenter.toTemplateDetail(result.template),
      version: this.presenter.toVersionDetail(result.version)
    };
  }

  async archiveVersion(
    templateId: string,
    templateVersionId: string,
    command: TemplateConfigArchiveCommand,
    context: RequestContext
  ) {
    await this.requireReviewer(context);
    const result = this.store.archiveVersion(templateId, templateVersionId, command);
    return {
      template: this.presenter.toTemplateDetail(result.template),
      version: this.presenter.toVersionDetail(result.version)
    };
  }

  async updateGrouping(
    templateId: string,
    command: TemplateConfigGroupingCommand,
    context: RequestContext
  ) {
    await this.requireReviewer(context);
    return this.presenter.toTemplateDetail(this.store.updateGrouping(templateId, command).template);
  }

  private async requireReviewer(context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    await this.eligibilityService.requireReviewer(currentSession);
  }
}
