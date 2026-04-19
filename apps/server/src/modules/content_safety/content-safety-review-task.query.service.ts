import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { ForumReportTicketEntity } from '../forum/entities/forum-report-ticket.entity';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { ProfileSafetySubmissionEntity } from '../profile/entities/profile-safety-submission.entity';
import {
  contentSafetyReviewTaskInvalid,
  contentSafetyReviewTaskUnavailable
} from '../review/review.errors';
import { ContentSafetyReviewTaskPresenter } from './content-safety-review-task.presenter';

const PROFILE_SAFETY_TASK_TYPE = 'profile_safety_submission';
const FORUM_REPORT_TASK_TYPE = 'forum_report_ticket';
const DEFAULT_REVIEW_TASK_LIMIT = 50;

@Injectable()
export class ContentSafetyReviewTaskQueryService {
  constructor(
    @InjectRepository(ProfileSafetySubmissionEntity)
    private readonly profileSubmissionRepository: Repository<ProfileSafetySubmissionEntity>,
    @InjectRepository(ForumReportTicketEntity)
    private readonly forumReportRepository: Repository<ForumReportTicketEntity>,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly presenter: ContentSafetyReviewTaskPresenter
  ) {}

  async list(context: RequestContext) {
    await this.requireManualReviewer(context);
    const [profileSubmissions, forumTickets] = await Promise.all([
      this.profileSubmissionRepository.find({
        where: { status: 'pending_review' },
        order: { createdAt: 'DESC' },
        take: DEFAULT_REVIEW_TASK_LIMIT
      }),
      this.forumReportRepository.find({
        where: { status: 'submitted' },
        order: { createdAt: 'DESC' },
        take: DEFAULT_REVIEW_TASK_LIMIT
      })
    ]);

    const items = [
      ...profileSubmissions.map((item) => ({
        submittedAt: item.createdAt.getTime(),
        value: this.presenter.toProfileTaskListItem(item)
      })),
      ...forumTickets.map((item) => ({
        submittedAt: item.createdAt.getTime(),
        value: this.presenter.toForumReportTaskListItem(item)
      }))
    ]
      .sort((left, right) => right.submittedAt - left.submittedAt)
      .map((item) => item.value);

    return this.presenter.toListResponse(items, context.traceId);
  }

  async detail(taskId: string, context: RequestContext) {
    await this.requireManualReviewer(context);
    const reference = this.readTaskReference(taskId);
    if (reference.taskType === PROFILE_SAFETY_TASK_TYPE) {
      const submission = await this.profileSubmissionRepository.findOneBy({ id: reference.subjectId });
      if (!submission) {
        throw contentSafetyReviewTaskUnavailable('Current content safety review task is unavailable.');
      }
      return this.presenter.toProfileTaskDetail(submission);
    }

    if (reference.taskType === FORUM_REPORT_TASK_TYPE) {
      const ticket = await this.forumReportRepository.findOneBy({ id: reference.subjectId });
      if (!ticket) {
        throw contentSafetyReviewTaskUnavailable('Current content safety review task is unavailable.');
      }
      return this.presenter.toForumReportTaskDetail(ticket);
    }

    throw contentSafetyReviewTaskInvalid('Current content safety review task id is invalid.');
  }

  private async requireManualReviewer(context: RequestContext) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    const eligibilityService = this.eligibilityService as {
      requireManualReviewer?: (session: typeof currentSession) => Promise<unknown>;
      requireReviewer: (session: typeof currentSession) => Promise<unknown>;
    };
    if (eligibilityService.requireManualReviewer) {
      await eligibilityService.requireManualReviewer(currentSession);
      return;
    }
    await eligibilityService.requireReviewer(currentSession);
  }

  private readTaskReference(taskId: string) {
    const normalized = taskId.trim();
    if (!normalized) {
      throw contentSafetyReviewTaskInvalid('Current content safety review task id is invalid.');
    }

    const [taskType, ...rest] = normalized.split(':');
    if (!rest.length) {
      return {
        taskType: PROFILE_SAFETY_TASK_TYPE,
        subjectId: normalized
      };
    }

    const subjectId = rest.join(':').trim();
    if (!subjectId) {
      throw contentSafetyReviewTaskInvalid('Current content safety review task id is invalid.');
    }
    if (![PROFILE_SAFETY_TASK_TYPE, FORUM_REPORT_TASK_TYPE].includes(taskType)) {
      throw contentSafetyReviewTaskInvalid('Current content safety review task id is invalid.');
    }
    return {
      taskType,
      subjectId
    };
  }
}
