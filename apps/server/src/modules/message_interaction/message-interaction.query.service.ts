import { Injectable } from '@nestjs/common';
import { requireVerifiedCurrentSessionContext } from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import {
  messageInteractionForbidden,
  messageInteractionInvalid,
} from './message-interaction.errors';
import { CounterpartConversationProjectionService } from './counterpart-conversation.projection.service';
import { MessageInteractionPresenter } from './message-interaction.presenter';

type InteractionLane = 'project_communication';

@Injectable()
export class MessageInteractionQueryService {
  constructor(
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly counterpartConversationProjectionService: CounterpartConversationProjectionService,
    private readonly presenter: MessageInteractionPresenter,
  ) {}

  async listInteractions(lane: string | undefined, context: RequestContext) {
    const normalizedLane = this.readLane(lane);
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService,
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(currentSession);
    const organizationId = scope?.organization.id?.trim() ?? '';
    if (!organizationId) {
      throw messageInteractionForbidden(
        'Current organization scope is required for message interactions.',
      );
    }
    const items = await this.counterpartConversationProjectionService.listConversations(
      organizationId,
      {
        requestId: context.requestId,
        traceId: context.traceId,
        source: 'message_interactions',
      },
    );
    return this.presenter.toListResponse(normalizedLane, items);
  }

  async getCounterpartConversationDetail(
    conversationId: string | undefined,
    projectId: string | undefined,
    context: RequestContext,
  ) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService,
    );
    await this.eligibilityService.requireAuthenticatedActor(currentSession);
    const scope = await this.eligibilityService.getCurrentOrganizationScope(
      currentSession,
    );
    const organizationId = scope?.organization.id?.trim() ?? '';
    if (!organizationId) {
      throw messageInteractionForbidden(
        'Current organization scope is required for counterpart conversation detail.',
      );
    }

    return this.presenter.toCounterpartConversationDetail(
      await this.counterpartConversationProjectionService.getConversationDetail({
        viewerOrganizationId: organizationId,
        conversationId: this.readRequiredId(conversationId, 'conversationId'),
        focusProjectId: projectId?.trim() ?? '',
      }),
    );
  }

  private readLane(value: string | undefined): InteractionLane {
    const normalized = value?.trim() ?? '';
    if (!normalized || normalized === 'project_communication') {
      return 'project_communication';
    }
    throw messageInteractionInvalid('Field `lane` only admits `project_communication`.');
  }

  private readRequiredId(value: string | undefined, fieldName: string) {
    const normalized = value?.trim() ?? '';
    if (!normalized) {
      throw messageInteractionInvalid(`Field \`${fieldName}\` is required.`);
    }
    return normalized;
  }
}
