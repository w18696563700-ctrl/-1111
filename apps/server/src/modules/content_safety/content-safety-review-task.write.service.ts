import { Injectable } from '@nestjs/common';
import { RequestContext } from '../../shared/request-context';
import { ProfileSafetyReviewService } from '../profile/profile-safety-review.service';

@Injectable()
export class ContentSafetyReviewTaskWriteService {
  constructor(private readonly profileSafetyReviewService: ProfileSafetyReviewService) {}

  approveProfileSubmission(
    submissionId: string,
    body: Record<string, unknown>,
    context: RequestContext
  ) {
    return this.profileSafetyReviewService.approveSubmission(submissionId, body, context);
  }

  rejectProfileSubmission(
    submissionId: string,
    body: Record<string, unknown>,
    context: RequestContext
  ) {
    return this.profileSafetyReviewService.rejectSubmission(submissionId, body, context);
  }
}
