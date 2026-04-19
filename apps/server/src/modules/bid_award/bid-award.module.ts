import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from '../auth/auth.module';
import { IdentityAuditLogEntity } from '../audit/identity-audit-log.entity';
import { BidEntity } from '../bid/entities/bid.entity';
import { OrganizationModule } from '../organization/organization.module';
import { ProjectEntity } from '../project/entities/project.entity';
import { BidAwardController } from './bid-award.controller';
import { BidAwardPresenter } from './bid-award.presenter';
import { BidAwardQueryService } from './bid-award.query.service';
import { BidAwardWriteService } from './bid-award.write.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([ProjectEntity, BidEntity, IdentityAuditLogEntity]),
    AuthModule,
    OrganizationModule
  ],
  controllers: [BidAwardController],
  providers: [BidAwardPresenter, BidAwardQueryService, BidAwardWriteService]
})
export class BidAwardModule {}
