import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import {
  requireVerifiedCurrentSessionContext,
} from '../../shared/current-session-verification';
import { RequestContext } from '../../shared/request-context';
import { CurrentSessionVerificationService } from '../auth/current-session-verification.service';
import { BidEntity } from '../bid/entities/bid.entity';
import { BidParticipationRequestEntity } from '../bid_participation_request/entities/bid-participation-request.entity';
import { CurrentActorEligibilityService } from '../organization/current-actor-eligibility.service';
import { PaymentOrderEntity } from './entities/payment-order.entity';
import { PlatformServiceFeeAuthorizationEntity } from './entities/platform-service-fee-authorization.entity';
import {
  bidServiceFeeAuthorizationCreateRejected,
  bidServiceFeeAuthorizationNotFound,
  p0PayPermissionDenied,
} from './p0-pay.errors';
import { P0PayCommandParser } from './p0-pay-command.parser';
import { P0PayPresenter } from './p0-pay.presenter';
import { P0PayServiceFeeAuthorizationService } from './p0-pay-service-fee-authorization.service';
import { P0PayServiceFeeRatePolicy } from './p0-pay-service-fee-rate.policy';
import {
  P0_PAY_SERVICE_FEE_AUTHORIZATION_MUTABLE_STATUSES,
} from './p0-pay.state';

@Injectable()
export class P0PayProjectBidServiceFeeAuthorizationService {
  constructor(
    @InjectRepository(BidParticipationRequestEntity)
    private readonly participationRepository: Repository<BidParticipationRequestEntity>,
    @InjectRepository(BidEntity)
    private readonly bidRepository: Repository<BidEntity>,
    @InjectRepository(PlatformServiceFeeAuthorizationEntity)
    private readonly authorizationRepository: Repository<PlatformServiceFeeAuthorizationEntity>,
    @InjectRepository(PaymentOrderEntity)
    private readonly paymentOrderRepository: Repository<PaymentOrderEntity>,
    private readonly commandParser: P0PayCommandParser,
    private readonly currentSessionVerificationService: CurrentSessionVerificationService,
    private readonly eligibilityService: CurrentActorEligibilityService,
    private readonly authorizationService: P0PayServiceFeeAuthorizationService,
    private readonly presenter: P0PayPresenter,
    private readonly feeRatePolicy: P0PayServiceFeeRatePolicy
  ) {}

  async createAuthorization(projectId: string, payload: Record<string, unknown>, context: RequestContext) {
    const command = this.commandParser.toCreateBidServiceFeeAuthorizationCommand(projectId, payload);
    const { bid, request } = await this.resolveApprovedBid(command, context);
    const existing = await this.findCurrentAuthorization(command.projectId, bid);
    if (existing) {
      await this.ensureParticipationAnchor(existing, request.id);
      const order = await this.loadOrder(existing);
      return this.presenter.toServiceFeeAuthorizationResponse(existing, order);
    }

    const response = await this.authorizationService.createAuthorizationOrder(
      command.projectId,
      bid.id,
      {
        expectedQuotedAmount: bid.quoteAmount,
        expectedFeeRate: await this.currentFeeRate(bid),
        expectedAuthorizationAmount: command.expectedAmount,
        currency: command.expectedCurrency,
        idempotencyKey: command.idempotencyKey,
      },
      context
    );
    await this.ensureParticipationAnchorById(response.authorizationId, request.id);
    return response;
  }

  async initFreeze(projectId: string, authorizationId: string, payload: Record<string, unknown>, context: RequestContext) {
    const command = this.commandParser.toBidServiceFeeAuthorizationFreezeInitCommand(
      projectId,
      authorizationId,
      payload
    );
    const authorization = await this.requireAuthorization(command.projectId, command.authorizationId);
    return this.authorizationService.authorizeInit(
      authorization.taskId,
      authorization.bidId,
      authorization.id,
      payload,
      context
    );
  }

  async getAuthorization(projectId: string, authorizationId: string, context: RequestContext) {
    const authorization = await this.requireAuthorization(projectId, authorizationId);
    return this.authorizationService.getAuthorization(
      authorization.taskId,
      authorization.bidId,
      authorization.id,
      context
    );
  }

  private async resolveApprovedBid(
    command: {
      projectId: string;
      bidParticipationRequestId: string;
      bidId: string | null;
    },
    context: RequestContext
  ) {
    const currentSession = await requireVerifiedCurrentSessionContext(
      context,
      this.currentSessionVerificationService
    );
    const scope = await this.eligibilityService.requireBidQualifiedScope(
      currentSession,
      'bid submit'
    );
    const request = await this.participationRepository.findOneBy({
      id: command.bidParticipationRequestId,
      projectId: command.projectId,
      requesterOrganizationId: scope.organization.id,
    });
    if (!request) {
      throw bidServiceFeeAuthorizationCreateRejected('Approved bid participation request is required.');
    }
    if (request.state !== 'approved') {
      throw bidServiceFeeAuthorizationCreateRejected('Bid participation request must be approved first.');
    }
    const bid = command.bidId
      ? await this.bidRepository.findOneBy({ id: command.bidId, projectId: command.projectId })
      : await this.bidRepository.findOneBy({
          projectId: command.projectId,
          bidderOrganizationId: request.requesterOrganizationId,
        });
    if (!bid || bid.state !== 'submitted') {
      throw bidServiceFeeAuthorizationCreateRejected('Submitted bid is required before service fee authorization.');
    }
    if (bid.bidderOrganizationId !== scope.organization.id) {
      throw p0PayPermissionDenied('Current organization does not own this submitted bid.');
    }
    return { bid, request };
  }

  private async findCurrentAuthorization(projectId: string, bid: BidEntity) {
    return this.authorizationRepository.findOne({
      where: [
        {
          taskId: projectId,
          bidId: bid.id,
          bidderOrganizationId: bid.bidderOrganizationId,
          status: In([...P0_PAY_SERVICE_FEE_AUTHORIZATION_MUTABLE_STATUSES]),
        },
        {
          taskId: projectId,
          bidId: bid.id,
          factoryOrganizationId: bid.bidderOrganizationId,
          status: In([...P0_PAY_SERVICE_FEE_AUTHORIZATION_MUTABLE_STATUSES]),
        },
      ],
      order: { updatedAt: 'DESC' },
    });
  }

  private async requireAuthorization(projectId: string, authorizationId: string) {
    const authorization = await this.authorizationRepository.findOneBy({
      id: authorizationId.trim(),
      taskId: projectId.trim(),
    });
    if (!authorization) {
      throw bidServiceFeeAuthorizationNotFound();
    }
    return authorization;
  }

  private async currentFeeRate(bid: BidEntity) {
    const requirement = await this.feeRatePolicy.buildRequirement({
      factoryOrganizationId: bid.bidderOrganizationId,
      quotedAmount: bid.quoteAmount,
    });
    return requirement.feeRate;
  }

  private async ensureParticipationAnchor(
    authorization: PlatformServiceFeeAuthorizationEntity,
    requestId: string
  ) {
    if (authorization.bidParticipationRequestId) {
      return;
    }
    authorization.bidParticipationRequestId = requestId;
    await this.authorizationRepository.save(authorization);
  }

  private async ensureParticipationAnchorById(authorizationId: string, requestId: string) {
    const authorization = await this.authorizationRepository.findOneBy({ id: authorizationId });
    if (authorization) {
      await this.ensureParticipationAnchor(authorization, requestId);
    }
  }

  private async loadOrder(authorization: PlatformServiceFeeAuthorizationEntity) {
    return authorization.paymentOrderId
      ? this.paymentOrderRepository.findOneBy({ id: authorization.paymentOrderId })
      : null;
  }
}
