import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from '../auth/auth.module';
import { OrganizationModule } from '../organization/organization.module';
import { OrganizationMembershipQuotaSnapshotEntity } from './entities/organization-membership-quota-snapshot.entity';
import { OrganizationPaidMembershipEntity } from './entities/organization-paid-membership.entity';
import { MembershipController } from './membership.controller';
import { MembershipPresenter } from './membership.presenter';
import { MembershipQueryService } from './membership.query.service';

@Module({
  imports: [
    AuthModule,
    OrganizationModule,
    TypeOrmModule.forFeature([
      OrganizationPaidMembershipEntity,
      OrganizationMembershipQuotaSnapshotEntity
    ])
  ],
  controllers: [MembershipController],
  providers: [MembershipPresenter, MembershipQueryService],
  exports: [MembershipQueryService]
})
export class MembershipModule {}
