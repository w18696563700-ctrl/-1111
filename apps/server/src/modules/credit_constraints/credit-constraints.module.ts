import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from '../auth/auth.module';
import { OrganizationModule } from '../organization/organization.module';
import { CreditConstraintsController } from './credit-constraints.controller';
import { CreditConstraintsPresenter } from './credit-constraints.presenter';
import { CreditConstraintsQueryService } from './credit-constraints.query.service';
import { OrganizationCreditConstraintPostureEntity } from './entities/organization-credit-constraint-posture.entity';
import { OrganizationDepositPostureEntity } from './entities/organization-deposit-posture.entity';
import { OrganizationTransactionGuaranteePostureEntity } from './entities/organization-transaction-guarantee-posture.entity';

@Module({
  imports: [
    AuthModule,
    OrganizationModule,
    TypeOrmModule.forFeature([
      OrganizationCreditConstraintPostureEntity,
      OrganizationDepositPostureEntity,
      OrganizationTransactionGuaranteePostureEntity
    ])
  ],
  controllers: [CreditConstraintsController],
  providers: [CreditConstraintsPresenter, CreditConstraintsQueryService]
})
export class CreditConstraintsModule {}
