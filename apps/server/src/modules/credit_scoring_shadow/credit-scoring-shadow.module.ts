import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CreditScoringShadowAggregationService } from './credit-scoring-shadow.aggregation.service';
import { CreditScoringShadowBootstrapService } from './credit-scoring-shadow.bootstrap.service';
import { OrganizationCreditShadowAggregateEntity } from './entities/organization-credit-shadow-aggregate.entity';
import { OrganizationCreditShadowLedgerEntryEntity } from './entities/organization-credit-shadow-ledger-entry.entity';
import { OrganizationCreditShadowReasonCodeEntity } from './entities/organization-credit-shadow-reason-code.entity';
import { OrganizationCreditShadowRecomputeTriggerEntity } from './entities/organization-credit-shadow-recompute-trigger.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      OrganizationCreditShadowAggregateEntity,
      OrganizationCreditShadowLedgerEntryEntity,
      OrganizationCreditShadowReasonCodeEntity,
      OrganizationCreditShadowRecomputeTriggerEntity
    ])
  ],
  providers: [CreditScoringShadowBootstrapService, CreditScoringShadowAggregationService],
  exports: [CreditScoringShadowAggregationService]
})
export class CreditScoringShadowModule {}

