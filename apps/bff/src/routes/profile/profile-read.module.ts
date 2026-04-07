import { Module } from '@nestjs/common';
import { CoreModule } from '../../core/core.module';
import { AppProfileCommandController } from './app-profile-command.controller';
import { ProfileBlockErrorService } from './profile-block-error.service';
import { ProfileBlockService } from './profile-block.service';
import { ProfileCreditConstraintsErrorService } from './profile-credit-constraints-error.service';
import { ProfileCreditConstraintsService } from './profile-credit-constraints.service';
import { ProfilePaymentBillingStatusErrorService } from './profile-payment-billing-status-error.service';
import { ProfilePaymentBillingStatusService } from './profile-payment-billing-status.service';
import { ProfileMembershipErrorService } from './profile-membership-error.service';
import { ProfileMembershipService } from './profile-membership.service';
import { AppProfileReadController } from './app-profile-read.controller';
import { ProfileCommandController } from './profile-command.controller';
import { ProfileCommandErrorService } from './profile-command-error.service';
import { ProfileCommandService } from './profile-command.service';
import { ProfileMembersErrorService } from './profile-members-error.service';
import { ProfileMembersService } from './profile-members.service';
import { ProfileReadController } from './profile-read.controller';
import { ProfileReadService } from './profile-read.service';
import { ProfileSafetyErrorService } from './profile-safety-error.service';
import { ProfileSafetyService } from './profile-safety.service';
import { ProfileSecurityErrorService } from './profile-security-error.service';
import { ProfileSecurityService } from './profile-security.service';

@Module({
  imports: [CoreModule],
  controllers: [
    ProfileReadController,
    AppProfileReadController,
    ProfileCommandController,
    AppProfileCommandController,
  ],
  providers: [
    ProfileReadService,
    ProfileBlockService,
    ProfileBlockErrorService,
    ProfileCreditConstraintsService,
    ProfileCreditConstraintsErrorService,
    ProfilePaymentBillingStatusService,
    ProfilePaymentBillingStatusErrorService,
    ProfileMembershipService,
    ProfileMembershipErrorService,
    ProfileCommandService,
    ProfileCommandErrorService,
    ProfileSafetyService,
    ProfileSafetyErrorService,
    ProfileMembersService,
    ProfileMembersErrorService,
    ProfileSecurityService,
    ProfileSecurityErrorService,
  ],
})
export class ProfileReadModule {}
