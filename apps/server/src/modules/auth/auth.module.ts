import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CoreModule } from '../../core/core.module';
import { IdentityAuditLogEntity } from '../audit/identity-audit-log.entity';
import { DeviceEntity } from '../identity/entities/device.entity';
import { LoginOtpCodeEntity } from '../identity/entities/login-otp-code.entity';
import { SessionEntity } from '../identity/entities/session.entity';
import { UserEntity } from '../identity/entities/user.entity';
import { OrganizationMemberEntity } from '../organization/entities/organization-member.entity';
import { AccessCarrierService } from './access-carrier.service';
import { AuthAntiAbuseService } from './auth-anti-abuse.service';
import { AuthCommandParser } from './auth-command.parser';
import { AuthController } from './auth.controller';
import { AuthEventMaterializationService } from './auth-event-materialization.service';
import { AuthOtpService } from './auth-otp.service';
import { AuthOtpSmsDeliveryService } from './auth-otp-sms-delivery.service';
import { AuthPresenter } from './auth.presenter';
import { AuthSessionService } from './auth-session.service';
import { CurrentSessionVerificationService } from './current-session-verification.service';
import { AuthSecurityEventEntity } from './entities/auth-security-event.entity';

@Module({
  imports: [
    CoreModule,
    TypeOrmModule.forFeature([
      UserEntity,
      SessionEntity,
      DeviceEntity,
      LoginOtpCodeEntity,
      OrganizationMemberEntity,
      IdentityAuditLogEntity,
      AuthSecurityEventEntity
    ])
  ],
  controllers: [AuthController],
  providers: [
    AuthCommandParser,
    AuthPresenter,
    AccessCarrierService,
    CurrentSessionVerificationService,
    AuthEventMaterializationService,
    AuthAntiAbuseService,
    AuthOtpSmsDeliveryService,
    AuthOtpService,
    AuthSessionService
  ],
  exports: [CurrentSessionVerificationService]
})
export class AuthModule {}
