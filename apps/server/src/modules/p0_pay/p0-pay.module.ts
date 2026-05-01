import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { IdentityAuditLogEntity } from '../audit/identity-audit-log.entity';
import { AuthModule } from '../auth/auth.module';
import { BidEntity } from '../bid/entities/bid.entity';
import { MembershipModule } from '../membership/membership.module';
import { OrganizationModule } from '../organization/organization.module';
import { ProjectEntity } from '../project/entities/project.entity';
import { TradingImModule } from '../trading_im/trading-im.module';
import { FileAssetEntity } from '../upload/entities/file-asset.entity';
import { ContractConfirmationEntity } from './entities/contract-confirmation.entity';
import { InquiryQuoteDepositEntity } from './entities/inquiry-quote-deposit.entity';
import { PaymentCallbackEventEntity } from './entities/payment-callback-event.entity';
import { PaymentIdempotencyRecordEntity } from './entities/payment-idempotency-record.entity';
import { PaymentOrderEntity } from './entities/payment-order.entity';
import { PaymentTransactionEntity } from './entities/payment-transaction.entity';
import { PlatformServiceFeeChargeEntity } from './entities/platform-service-fee-charge.entity';
import { PlatformServiceFeeAuthorizationEntity } from './entities/platform-service-fee-authorization.entity';
import { P0PayAuditService } from './p0-pay-audit.service';
import { P0PayCallbackService } from './p0-pay-callback.service';
import { P0PayCommandParser } from './p0-pay-command.parser';
import { P0PayContractConfirmationService } from './p0-pay-contract-confirmation.service';
import { P0PayController } from './p0-pay.controller';
import { P0PayIdempotencyRecordService } from './p0-pay-idempotency-record.service';
import { P0PayIdempotencyService } from './p0-pay-idempotency.service';
import { P0PayInquiryDepositService } from './p0-pay-inquiry-deposit.service';
import { P0PayPaymentChannelService } from './p0-pay-payment-channel.service';
import { P0PayPresenter } from './p0-pay.presenter';
import { P0PayRefundService } from './p0-pay-refund.service';
import { P0PayServiceFeeAuthorizationService } from './p0-pay-service-fee-authorization.service';
import { P0PayServiceFeeFactory } from './p0-pay-service-fee.factory';
import { P0PayServiceFeeRatePolicy } from './p0-pay-service-fee-rate.policy';
import { P0PaySettlementService } from './p0-pay-settlement.service';
import { P0PayStateActionService } from './p0-pay-state-action.service';
import { P0PayTradeTaskService } from './p0-pay-trade-task.service';

@Module({
  imports: [
    AuthModule,
    MembershipModule,
    OrganizationModule,
    TradingImModule,
    TypeOrmModule.forFeature([
      PlatformServiceFeeAuthorizationEntity,
      PlatformServiceFeeChargeEntity,
      ContractConfirmationEntity,
      InquiryQuoteDepositEntity,
      PaymentOrderEntity,
      PaymentTransactionEntity,
      PaymentCallbackEventEntity,
      PaymentIdempotencyRecordEntity,
      BidEntity,
      ProjectEntity,
      FileAssetEntity,
      IdentityAuditLogEntity
    ])
  ],
  controllers: [P0PayController],
  providers: [
    P0PayAuditService,
    P0PayCallbackService,
    P0PayCommandParser,
    P0PayContractConfirmationService,
    P0PayIdempotencyRecordService,
    P0PayIdempotencyService,
    P0PayInquiryDepositService,
    P0PayPaymentChannelService,
    P0PayPresenter,
    P0PayRefundService,
    P0PayServiceFeeFactory,
    P0PayServiceFeeRatePolicy,
    P0PayServiceFeeAuthorizationService,
    P0PaySettlementService,
    P0PayStateActionService,
    P0PayTradeTaskService
  ],
  exports: [
    P0PayContractConfirmationService,
    P0PayInquiryDepositService,
    P0PayStateActionService,
    P0PayTradeTaskService,
    P0PayRefundService,
    P0PaySettlementService,
    P0PayServiceFeeAuthorizationService
  ]
})
export class P0PayModule {}
