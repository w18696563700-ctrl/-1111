import { Injectable } from '@nestjs/common';
import { ProjectCounterpartyRatingEntity } from './entities/project-counterparty-rating.entity';

@Injectable()
export class ProjectCounterpartyRatingPresenter {
  toEntry(input: {
    orderId: string;
    projectId: string;
    raterOrganizationId: string;
    rateeOrganizationId: string;
    canRate: boolean;
    reason: string | null;
    ratingState: string | null;
  }) {
    return {
      orderId: input.orderId,
      projectId: input.projectId,
      raterOrganizationId: input.raterOrganizationId,
      rateeOrganizationId: input.rateeOrganizationId,
      canRate: input.canRate,
      reason: input.reason,
      ratingState: input.ratingState
    };
  }

  toSubmitAccepted(rating: ProjectCounterpartyRatingEntity) {
    return {
      ratingId: rating.id,
      orderId: rating.orderId,
      projectId: rating.projectId,
      raterOrganizationId: rating.raterOrganizationId,
      rateeOrganizationId: rating.rateeOrganizationId,
      state: 'submitted',
      ratingState: rating.ratingState,
      scoreValue: rating.scoreValue,
      scoreLabel: rating.scoreLabel,
      submittedAt: rating.submittedAt.toISOString()
    };
  }
}
