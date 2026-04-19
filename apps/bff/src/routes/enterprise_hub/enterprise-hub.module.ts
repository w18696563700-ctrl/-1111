import { Module } from "@nestjs/common";
import { CoreModule } from "../../core/core.module";
import { ForumCommandContextService } from "../forum/forum-command-context.service";
import { AppEnterpriseHubController } from "./app-enterprise-hub.controller";
import {
  AppEnterpriseHubCompanyController,
  AppEnterpriseHubFactoryController,
  AppEnterpriseHubSupplierController,
  EnterpriseHubCompanyController,
  EnterpriseHubFactoryController,
  EnterpriseHubSupplierController,
} from './enterprise-hub-board-scoped.controller';
import { EnterpriseHubController } from "./enterprise-hub.controller";
import { EnterpriseHubFormalInfoService } from "./enterprise-hub-formal-info.service";
import { EnterpriseHubPublishedChangeService } from "./enterprise-hub-published-change.service";
import { EnterpriseHubService } from "./enterprise-hub.service";
import { EnterpriseHubWorkbenchService } from "./enterprise-hub-workbench.service";

@Module({
  imports: [CoreModule],
  controllers: [
    EnterpriseHubController,
    EnterpriseHubCompanyController,
    EnterpriseHubFactoryController,
    EnterpriseHubSupplierController,
    AppEnterpriseHubController,
    AppEnterpriseHubCompanyController,
    AppEnterpriseHubFactoryController,
    AppEnterpriseHubSupplierController,
  ],
  providers: [
    EnterpriseHubService,
    EnterpriseHubFormalInfoService,
    EnterpriseHubPublishedChangeService,
    EnterpriseHubWorkbenchService,
    ForumCommandContextService,
  ],
})
export class EnterpriseHubModule {}
