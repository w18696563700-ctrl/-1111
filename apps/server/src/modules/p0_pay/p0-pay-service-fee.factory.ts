import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { createHash, randomUUID } from 'crypto';
import { Repository } from 'typeorm';
import { RequestContext } from '../../shared/request-context';
import { BidEntity } from '../bid/entities/bid.entity';
import { ProjectEntity } from '../project/entities/project.entity';
import { PaymentOrderEntity } from './entities/payment-order.entity';
import { PlatformServiceFeeAuthorizationEntity } from './entities/platform-service-fee-authorization.entity';
import {
  calculatePlatformServiceFeeAmount,
  normalizeFeeRate,
  normalizePositiveMoney
} from './p0-pay-calculator';
import { AuthorizeInitCommand, CreateAuthorizationCommand } from './p0-pay.commands';
import { p0PayInvalid } from './p0-pay.errors';
import { P0PayIdempotencyService } from './p0-pay-idempotency.service';
import {
  P0_PAY_DEFAULT_SERVICE_FEE_RATE,
  P0_PAY_RULE_VERSION,
  P0_PAY_SERVICE_FEE_AGREEMENT_TEXT
} from './p0-pay.state';

@Injectable()
export class P0PayServiceFeeFactory {
  constructor(
    @InjectRepository(PlatformServiceFeeAuthorizationEntity)
    private readonly authorizationRepository: Repository<PlatformServiceFeeAuthorizationEntity>,
    @InjectRepository(PaymentOrderEntity)
    private readonly paymentOrderRepository: Repository<PaymentOrderEntity>,
    private readonly idempotencyService: P0PayIdempotencyService
  ) {}

  assertExpectedAmounts(command: CreateAuthorizationCommand, bid: BidEntity) {
    const quotedAmount = normalizePositiveMoney(bid.quoteAmount, 'quotedAmount');
    const feeRate = normalizeFeeRate(P0_PAY_DEFAULT_SERVICE_FEE_RATE);
    const feeAmount = calculatePlatformServiceFeeAmount(quotedAmount, feeRate);
    if (command.expectedQuotedAmount !== quotedAmount) {
      throw p0PayInvalid('Field `expectedQuotedAmount` does not match Server bid truth.');
    }
    if (command.expectedFeeRate !== feeRate) {
      throw p0PayInvalid('Field `expectedFeeRate` does not match Server fee rule truth.');
    }
    if (command.expectedAuthorizationAmount !== feeAmount) {
      throw p0PayInvalid('Field `expectedAuthorizationAmount` does not match Server fee calculation.');
    }
    if (command.currency !== 'CNY') {
      throw p0PayInvalid('P0-Pay service fee authorization only supports CNY.');
    }
  }

  buildAuthorization(input: {
    bid: BidEntity;
    project: ProjectEntity;
    currentSession: { userId: string; actorId: string };
    context: RequestContext;
  }) {
    const quotedAmount = normalizePositiveMoney(input.bid.quoteAmount, 'quotedAmount');
    const feeRate = normalizeFeeRate(P0_PAY_DEFAULT_SERVICE_FEE_RATE);
    return this.authorizationRepository.create({
      id: randomUUID(),
      taskId: input.project.id,
      bidId: input.bid.id,
      factoryOrganizationId: input.bid.bidderOrganizationId,
      publisherOrganizationId: input.project.organizationId,
      quotedAmount,
      feeRate,
      estimatedFeeAmount: calculatePlatformServiceFeeAmount(quotedAmount, feeRate),
      finalConfirmedAmount: null,
      finalFeeAmount: null,
      paymentChannel: null,
      paymentOrderId: null,
      authorizationOrderId: null,
      status: 'pending_authorization',
      ruleVersion: P0_PAY_RULE_VERSION,
      ruleSnapshotHash: this.ruleSnapshotHash(),
      agreementTextSnapshot: P0_PAY_SERVICE_FEE_AGREEMENT_TEXT,
      agreedAt: new Date(),
      authorizedAt: null,
      releasedAt: null,
      chargedAt: null,
      createdByUserId: input.currentSession.userId,
      createdByActorId: input.currentSession.actorId,
      requestId: input.context.requestId,
      traceId: input.context.traceId
    });
  }

  buildPaymentOrder(input: {
    authorization: PlatformServiceFeeAuthorizationEntity;
    command: AuthorizeInitCommand;
    payerOrganizationId: string;
    context: RequestContext;
  }) {
    return this.paymentOrderRepository.create({
      id: randomUUID(),
      businessType: 'platform_service_fee_authorization',
      businessId: input.authorization.id,
      taskId: input.command.taskId,
      bidId: input.command.bidId,
      payerOrganizationId: input.payerOrganizationId,
      payeeOrganizationId: '',
      amount: normalizePositiveMoney(input.authorization.estimatedFeeAmount, 'estimatedFeeAmount'),
      currency: 'CNY',
      paymentChannel: input.command.payChannel,
      orderRole: 'authorization',
      status: 'pending_user_confirm',
      merchantOrderNo: this.idempotencyService.buildMerchantOrderNo('P0PAY_AUTH'),
      channelOrderId: null,
      idempotencyKeyHash: this.idempotencyService.hashKey(input.command.idempotencyKey),
      requestId: input.context.requestId,
      traceId: input.context.traceId,
      expiresAt: this.buildExpiry()
    });
  }

  private buildExpiry() {
    return new Date(Date.now() + 30 * 60 * 1000);
  }

  private ruleSnapshotHash() {
    return createHash('sha256')
      .update(`${P0_PAY_RULE_VERSION}:${P0_PAY_SERVICE_FEE_AGREEMENT_TEXT}`, 'utf8')
      .digest('hex');
  }
}
