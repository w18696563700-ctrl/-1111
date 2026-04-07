import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from '../auth/auth.module';
import { OrganizationModule } from '../organization/organization.module';
import { OrganizationBillingReferenceEntity } from './entities/organization-billing-reference.entity';
import { OrganizationPaymentHandoffEntity } from './entities/organization-payment-handoff.entity';
import { OrganizationPaymentStatusEntity } from './entities/organization-payment-status.entity';
import { PaymentBillingController } from './payment-billing.controller';
import { PaymentBillingPresenter } from './payment-billing.presenter';
import { PaymentBillingQueryService } from './payment-billing.query.service';

@Module({
  imports: [
    AuthModule,
    OrganizationModule,
    TypeOrmModule.forFeature([
      OrganizationPaymentStatusEntity,
      OrganizationBillingReferenceEntity,
      OrganizationPaymentHandoffEntity
    ])
  ],
  controllers: [PaymentBillingController],
  providers: [PaymentBillingPresenter, PaymentBillingQueryService]
})
export class PaymentBillingModule {}
