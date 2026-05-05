import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from '../auth/auth.module';
import { OrganizationModule } from '../organization/organization.module';
import { OrganizationCertificationEntity } from '../organization/entities/organization-certification.entity';
import { OrganizationMemberEntity } from '../organization/entities/organization-member.entity';
import { OrganizationEntity } from '../organization/entities/organization.entity';
import { CreditConstraintsController } from './credit-constraints.controller';
import { CreditConstraintsPresenter } from './credit-constraints.presenter';
import { CreditConstraintsPostureInitializationService } from './credit-constraints-posture-initialization.service';
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
      OrganizationTransactionGuaranteePostureEntity,
      OrganizationEntity,
      OrganizationCertificationEntity,
      OrganizationMemberEntity
    ])
  ],
  controllers: [CreditConstraintsController],
  providers: [
    CreditConstraintsPresenter,
    CreditConstraintsQueryService,
    CreditConstraintsPostureInitializationService
  ],
  exports: [CreditConstraintsPostureInitializationService]
})
export class CreditConstraintsModule {}
