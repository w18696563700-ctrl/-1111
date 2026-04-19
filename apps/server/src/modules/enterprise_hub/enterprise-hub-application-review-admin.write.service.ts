import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import {
  applicationNotFound,
  invalidStateTransition,
  missingRequiredFields,
} from './enterprise-hub.errors';
import { EnterpriseApplicationEntity } from './entities/enterprise-application.entity';

const REVIEW_ACTIONS = ['approved', 'revision_required', 'rejected'] as const;
const REVIEW_REASON_VALUES = [
  'basic_info_incomplete',
  'profile_incomplete',
  'case_incomplete',
  'contact_incomplete',
  'certification_not_approved',
  'other',
] as const;

type ReviewAction = (typeof REVIEW_ACTIONS)[number];
type ReviewReason = (typeof REVIEW_REASON_VALUES)[number];

@Injectable()
export class EnterpriseHubApplicationReviewAdminWriteService {
  constructor(
    @InjectRepository(EnterpriseApplicationEntity)
    private readonly applicationRepository: Repository<EnterpriseApplicationEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
  ) {}

  async reviewApplication(
    applicationId: string,
    payload: Record<string, unknown>,
    context: RequestContext,
  ) {
    const reviewer = await this.requireReviewer(context);
    const application = await this.applicationRepository.findOneBy({ id: applicationId });
    if (!application) {
      throw applicationNotFound();
    }

    const action = this.readAction(payload.action);
    if (!action) {
      throw invalidStateTransition('Review action is invalid for enterprise hub application.');
    }
    if (!this.isReviewableState(application)) {
      throw invalidStateTransition('Application is not in a reviewable state.');
    }

    const reason = this.readReason(payload.reason, action);
    const reviewNote = this.readOptionalString(payload.reviewNote);

    application.applicationStatus = action;
    application.reviewedAt = new Date();
    application.reviewerId = reviewer.currentSession.actorId;
    application.reviewNote = reviewNote;
    application.rejectionReason = reason;
    await this.applicationRepository.save(application);

    return { ok: true, traceId: context.traceId };
  }

  private async requireReviewer(context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService,
    );
    const reviewer = await this.eligibilityService.requireReviewer(currentSession);
    return { currentSession, actorRole: reviewer.actorRole };
  }

  private readAction(value: unknown): ReviewAction | null {
    const action = this.readOptionalString(value);
    if (!action || !REVIEW_ACTIONS.includes(action as ReviewAction)) {
      return null;
    }
    return action as ReviewAction;
  }

  private readReason(value: unknown, action: ReviewAction): ReviewReason | null {
    const reason = this.readOptionalString(value);
    if (action === 'approved') {
      return null;
    }
    if (!reason) {
      throw missingRequiredFields(
        'Review reason is required for revision_required or rejected enterprise hub application review.',
      );
    }
    if (!REVIEW_REASON_VALUES.includes(reason as ReviewReason)) {
      throw missingRequiredFields('Review reason is invalid for enterprise hub application review.');
    }
    return reason as ReviewReason;
  }

  private readOptionalString(value: unknown) {
    if (typeof value !== 'string') {
      return null;
    }
    const trimmed = value.trim();
    return trimmed.length > 0 ? trimmed : null;
  }

  private isReviewableState(application: EnterpriseApplicationEntity) {
    if (['submitted', 'under_review'].includes(application.applicationStatus)) {
      return true;
    }
    return (
      ['approved', 'revision_required'].includes(application.applicationStatus) &&
      application.reviewerId === 'system:auto-review'
    );
  }
}
