import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { randomUUID } from 'crypto';
import { Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { ProjectEntity } from '../project/entities/project.entity';
import {
  ProjectAuthenticitySincerityFreezeFeedbackChoice,
  ProjectAuthenticitySincerityFreezeFeedbackEntity,
} from './entities/project-authenticity-sincerity-freeze-feedback.entity';
import { p0PayInvalid, p0PayPermissionDenied, p0PayResourceUnavailable } from './p0-pay.errors';
import { PROJECT_AUTHENTICITY_SINCERITY_INTERNAL_TEST_NOTICE } from './p0-pay-internal-test-no-freeze.policy';

const FREEZE_FEEDBACK_CHOICES = new Set<ProjectAuthenticitySincerityFreezeFeedbackChoice>([
  'support_freeze',
  'oppose_freeze',
]);

@Injectable()
export class P0PayInternalTestNoFreezeService {
  constructor(
    @InjectRepository(ProjectAuthenticitySincerityFreezeFeedbackEntity)
    private readonly feedbackRepository: Repository<ProjectAuthenticitySincerityFreezeFeedbackEntity>,
    @InjectRepository(ProjectEntity)
    private readonly projectRepository: Repository<ProjectEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService
  ) {}

  get policyNotice() {
    return PROJECT_AUTHENTICITY_SINCERITY_INTERNAL_TEST_NOTICE;
  }

  async buildFeedbackSummary(projectId: string, context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    const [supportFreezeCount, opposeFreezeCount, mine] = await Promise.all([
      this.feedbackRepository.count({ where: { projectId, choice: 'support_freeze' } }),
      this.feedbackRepository.count({ where: { projectId, choice: 'oppose_freeze' } }),
      this.feedbackRepository.findOne({
        where: { projectId, userId: currentSession.userId },
        order: { updatedAt: 'DESC' },
      }),
    ]);
    return {
      supportFreezeCount,
      opposeFreezeCount,
      myChoice: mine?.choice ?? null,
      updatedAt: mine?.updatedAt?.toISOString() ?? null,
    };
  }

  async submitFeedback(projectId: string, payload: Record<string, unknown>, context: RequestContext) {
    const choice = this.readChoice(payload.choice);
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    const project = await this.projectRepository.findOneBy({ id: projectId.trim() });
    if (!project) {
      throw p0PayResourceUnavailable('Current project is unavailable.');
    }
    if (!scope || scope.organization.id !== project.organizationId) {
      throw p0PayPermissionDenied('Current organization cannot submit this sincerity freeze feedback.');
    }

    let feedback = await this.feedbackRepository.findOne({
      where: { projectId: project.id, userId: currentSession.userId },
    });
    if (!feedback) {
      feedback = this.feedbackRepository.create({
        id: randomUUID(),
        projectId: project.id,
        userId: currentSession.userId,
      });
    }
    feedback.organizationId = scope.organization.id;
    feedback.actorRole = scope.membership.roleKey;
    feedback.choice = choice;
    feedback.requestId = context.requestId;
    feedback.traceId = context.traceId;
    await this.feedbackRepository.save(feedback);

    const summary = await this.buildFeedbackSummary(project.id, context);
    return {
      projectId: project.id,
      myChoice: choice,
      supportFreezeCount: summary.supportFreezeCount,
      opposeFreezeCount: summary.opposeFreezeCount,
      updatedAt: feedback.updatedAt.toISOString(),
      traceId: context.traceId,
    };
  }

  private readChoice(value: unknown): ProjectAuthenticitySincerityFreezeFeedbackChoice {
    if (typeof value !== 'string' || !FREEZE_FEEDBACK_CHOICES.has(value as ProjectAuthenticitySincerityFreezeFeedbackChoice)) {
      throw p0PayInvalid('Project authenticity sincerity freeze feedback choice is invalid.');
    }
    return value as ProjectAuthenticitySincerityFreezeFeedbackChoice;
  }
}
