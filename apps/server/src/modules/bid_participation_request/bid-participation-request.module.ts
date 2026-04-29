import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { IdentityAuditLogEntity } from '../audit/identity-audit-log.entity';
import { AuthModule } from '../auth/auth.module';
import { UserEntity } from '../identity/entities/user.entity';
import { OrganizationModule } from '../organization/organization.module';
import { OrganizationCertificationEntity } from '../organization/entities/organization-certification.entity';
import { OrganizationEntity } from '../organization/entities/organization.entity';
import { ProjectEntity } from '../project/entities/project.entity';
import { BidParticipationRequestAccessService } from './bid-participation-request-access.service';
import { BidParticipationRequestController } from './bid-participation-request.controller';
import { BidParticipationRequestPresenter } from './bid-participation-request.presenter';
import { BidParticipationRequestQueryService } from './bid-participation-request.query.service';
import { BidParticipationRequestWriteService } from './bid-participation-request.write.service';
import { BidParticipationRequestEntity } from './entities/bid-participation-request.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      BidParticipationRequestEntity,
      ProjectEntity,
      OrganizationEntity,
      OrganizationCertificationEntity,
      UserEntity,
      IdentityAuditLogEntity,
    ]),
    AuthModule,
    OrganizationModule,
  ],
  controllers: [BidParticipationRequestController],
  providers: [
    BidParticipationRequestAccessService,
    BidParticipationRequestPresenter,
    BidParticipationRequestQueryService,
    BidParticipationRequestWriteService,
  ],
  exports: [BidParticipationRequestAccessService, TypeOrmModule],
})
export class BidParticipationRequestModule {}

