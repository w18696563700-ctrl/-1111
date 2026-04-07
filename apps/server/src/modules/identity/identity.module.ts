import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DeviceEntity } from './entities/device.entity';
import { LoginOtpCodeEntity } from './entities/login-otp-code.entity';
import { SessionEntity } from './entities/session.entity';
import { UserEntity } from './entities/user.entity';

@Module({
  imports: [TypeOrmModule.forFeature([UserEntity, SessionEntity, DeviceEntity, LoginOtpCodeEntity])],
  exports: [TypeOrmModule]
})
export class IdentityModule {}
