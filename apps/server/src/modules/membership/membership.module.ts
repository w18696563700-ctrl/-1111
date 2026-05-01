import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from '../auth/auth.module';
import { OrganizationModule } from '../organization/organization.module';
import { PaymentIdempotencyRecordEntity } from '../p0_pay/entities/payment-idempotency-record.entity';
import { PaymentOrderEntity } from '../p0_pay/entities/payment-order.entity';
import { P0PayPaymentChannelService } from '../p0_pay/p0-pay-payment-channel.service';
import { MembershipOrderEntity } from './entities/membership-order.entity';
import { OrganizationMembershipQuotaSnapshotEntity } from './entities/organization-membership-quota-snapshot.entity';
import { OrganizationPaidMembershipEntity } from './entities/organization-paid-membership.entity';
import { MembershipAdminController } from './membership-admin.controller';
import { MembershipAdminQueryService } from './membership-admin-query.service';
import { MembershipController } from './membership.controller';
import { MembershipPresenter } from './membership.presenter';
import { MembershipPurchasePresenter } from './membership.purchase.presenter';
import { MembershipPurchaseService } from './membership.purchase.service';
import { MembershipQueryService } from './membership.query.service';

@Module({
  imports: [
    AuthModule,
    OrganizationModule,
    TypeOrmModule.forFeature([
      MembershipOrderEntity,
      OrganizationPaidMembershipEntity,
      OrganizationMembershipQuotaSnapshotEntity,
      PaymentOrderEntity,
      PaymentIdempotencyRecordEntity
    ])
  ],
  controllers: [MembershipController, MembershipAdminController],
  providers: [
    MembershipAdminQueryService,
    MembershipPresenter,
    MembershipPurchasePresenter,
    MembershipPurchaseService,
    MembershipQueryService,
    P0PayPaymentChannelService
  ],
  exports: [MembershipQueryService, MembershipPurchaseService]
})
export class MembershipModule {}
