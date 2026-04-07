import { Module } from '@nestjs/common';
import { CoreModule } from '../../core/core.module';
import { AppEnterpriseHubController } from './app-enterprise-hub.controller';
import { EnterpriseHubController } from './enterprise-hub.controller';
import { EnterpriseHubService } from './enterprise-hub.service';

@Module({
  imports: [CoreModule],
  controllers: [EnterpriseHubController, AppEnterpriseHubController],
  providers: [EnterpriseHubService],
})
export class EnterpriseHubModule {}
