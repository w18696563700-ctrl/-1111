import { Module } from '@nestjs/common';
import { PrivateOperatingSystemReorganizationService } from './private-operating-system-reorganization.service';

@Module({
  providers: [PrivateOperatingSystemReorganizationService],
  exports: [PrivateOperatingSystemReorganizationService]
})
export class PrivateOperatingSystemReorganizationModule {}

