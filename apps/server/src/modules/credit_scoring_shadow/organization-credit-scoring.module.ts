import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from '../auth/auth.module';
import { OrganizationModule } from '../organization/organization.module';
import { OrganizationCreditShadowAggregateEntity } from './entities/organization-credit-shadow-aggregate.entity';
import { OrganizationCreditScoringController } from './organization-credit-scoring.controller';
import { OrganizationCreditScoringPresenter } from './organization-credit-scoring.presenter';
import { OrganizationCreditScoringQueryService } from './organization-credit-scoring.query.service';

@Module({
  imports: [
    AuthModule,
    OrganizationModule,
    TypeOrmModule.forFeature([OrganizationCreditShadowAggregateEntity]),
  ],
  controllers: [OrganizationCreditScoringController],
  providers: [OrganizationCreditScoringPresenter, OrganizationCreditScoringQueryService],
})
export class OrganizationCreditScoringModule {}
