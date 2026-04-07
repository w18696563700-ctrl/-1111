import { Injectable } from '@nestjs/common';
import { RequestContext } from '../../shared/request-context';
import { ProfileSafetyReviewService } from './profile-safety-review.service';
import { ProfileSafetySubmitService } from './profile-safety-submit.service';

@Injectable()
export class ProfileSafetyWriteService {
  constructor(
    private readonly submitService: ProfileSafetySubmitService,
    private readonly reviewService: ProfileSafetyReviewService
  ) {}

  updateNickname(payload: Record<string, unknown>, context: RequestContext) {
    return this.submitService.updateNickname(payload, context);
  }

  updateAvatar(payload: Record<string, unknown>, context: RequestContext) {
    return this.submitService.updateAvatar(payload, context);
  }

  updateIntro(payload: Record<string, unknown>, context: RequestContext) {
    return this.submitService.updateIntro(payload, context);
  }

  approveSubmission(
    submissionId: string,
    body: Record<string, unknown>,
    context: RequestContext
  ) {
    return this.reviewService.approveSubmission(submissionId, body, context);
  }

  rejectSubmission(
    submissionId: string,
    body: Record<string, unknown>,
    context: RequestContext
  ) {
    return this.reviewService.rejectSubmission(submissionId, body, context);
  }
}
