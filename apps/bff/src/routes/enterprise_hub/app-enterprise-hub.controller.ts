import {
  Body,
  Controller,
  Delete,
  Get,
  Headers,
  HttpCode,
  HttpStatus,
  Param,
  Post,
  Put,
  Query,
} from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { EnterpriseHubFormalInfoService } from './enterprise-hub-formal-info.service';
import { EnterpriseHubService } from './enterprise-hub.service';
import { EnterpriseHubPublishedChangeService } from './enterprise-hub-published-change.service';
import { EnterpriseHubWorkbenchService } from './enterprise-hub-workbench.service';

@Controller('api/app/exhibition/enterprise-hub')
export class AppEnterpriseHubController {
  constructor(
    private readonly enterpriseHubService: EnterpriseHubService,
    private readonly enterpriseHubFormalInfoService: EnterpriseHubFormalInfoService,
    private readonly enterpriseHubPublishedChangeService: EnterpriseHubPublishedChangeService,
    private readonly enterpriseHubWorkbenchService: EnterpriseHubWorkbenchService,
  ) {}

  @Get('workbench')
  getWorkbench(
    @Headers() headers: IncomingHttpHeaders,
    @Query('boardType') boardType?: string,
  ) {
    return this.enterpriseHubWorkbenchService.getWorkbench(headers, boardType);
  }

  @Get('enterprises')
  listEnterprises(
    @Headers() headers: IncomingHttpHeaders,
    @Query('boardType') boardType?: string,
    @Query('keyword') keyword?: string,
    @Query('provinceCode') provinceCode?: string,
    @Query('cityCode') cityCode?: string,
    @Query('plantAreaRange') plantAreaRange?: string,
    @Query('page') page?: string,
    @Query('pageSize') pageSize?: string,
  ) {
    return this.enterpriseHubService.listEnterprises(headers, {
      boardType,
      keyword,
      provinceCode,
      cityCode,
      plantAreaRange,
      page,
      pageSize,
    });
  }

  @Get('enterprises/:enterpriseId')
  getEnterpriseDetail(
    @Param('enterpriseId') enterpriseId: string,
    @Query('boardType') boardType: string | undefined,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.enterpriseHubService.getEnterpriseDetail(
      enterpriseId,
      boardType,
      headers,
    );
  }

  @Get('enterprises/:enterpriseId/formal-info')
  getTargetEnterpriseFormalInfo(
    @Param('enterpriseId') enterpriseId: string,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.enterpriseHubFormalInfoService.getTargetEnterpriseFormalInfo(
      enterpriseId,
      headers,
    );
  }

  @Get('public-cases/:caseId')
  getPublicCaseDetail(
    @Param('caseId') caseId: string,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.enterpriseHubService.getPublicCaseDetail(caseId, headers);
  }

  @Get('recommendations')
  getRecommendations(
    @Headers() headers: IncomingHttpHeaders,
    @Query('boardType') boardType?: string,
  ) {
    return this.enterpriseHubService.getRecommendations(headers, boardType);
  }

  @Post('enterprises/ensure-shell')
  @HttpCode(HttpStatus.OK)
  ensureShell(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.enterpriseHubService.ensureShell(payload, headers);
  }

  @Post('applications')
  @HttpCode(HttpStatus.OK)
  createApplication(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.enterpriseHubService.createApplication(payload, headers);
  }

  @Post('location/resolve')
  @HttpCode(HttpStatus.OK)
  resolveLocation(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.enterpriseHubService.resolveLocation(payload, headers);
  }

  @Put('enterprises/:enterpriseId/basic')
  updateBasic(
    @Param('enterpriseId') enterpriseId: string,
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.enterpriseHubService.updateBasic(enterpriseId, payload, headers);
  }

  @Put('enterprises/:enterpriseId/profiles/company')
  updateCompanyProfile(
    @Param('enterpriseId') enterpriseId: string,
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.enterpriseHubService.updateCompanyProfile(
      enterpriseId,
      payload,
      headers,
    );
  }

  @Put('enterprises/:enterpriseId/profiles/factory')
  updateFactoryProfile(
    @Param('enterpriseId') enterpriseId: string,
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.enterpriseHubService.updateFactoryProfile(
      enterpriseId,
      payload,
      headers,
    );
  }

  @Put('enterprises/:enterpriseId/profiles/supplier')
  updateSupplierProfile(
    @Param('enterpriseId') enterpriseId: string,
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.enterpriseHubService.updateSupplierProfile(
      enterpriseId,
      payload,
      headers,
    );
  }

  @Post('enterprises/:enterpriseId/cases')
  @HttpCode(HttpStatus.OK)
  createCase(
    @Param('enterpriseId') enterpriseId: string,
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.enterpriseHubService.createCase(enterpriseId, payload, headers);
  }

  @Get('cases/:caseId')
  getCaseDetail(
    @Param('caseId') caseId: string,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.enterpriseHubService.getCaseDetail(caseId, headers);
  }

  @Put('cases/:caseId')
  @HttpCode(HttpStatus.OK)
  updateCase(
    @Param('caseId') caseId: string,
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.enterpriseHubService.updateCase(caseId, payload, headers);
  }

  @Delete('cases/:caseId')
  @HttpCode(HttpStatus.OK)
  deleteCase(
    @Param('caseId') caseId: string,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.enterpriseHubService.deleteCase(caseId, headers);
  }

  @Delete('enterprises/:enterpriseId')
  @HttpCode(HttpStatus.OK)
  deleteEnterprise(
    @Param('enterpriseId') enterpriseId: string,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.enterpriseHubService.deleteEnterprise(enterpriseId, headers);
  }

  @Post('applications/:applicationId/submit')
  @HttpCode(HttpStatus.OK)
  submitApplication(
    @Param('applicationId') applicationId: string,
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.enterpriseHubService.submitApplication(
      applicationId,
      payload,
      headers,
    );
  }

  @Get('applications/:applicationId')
  getApplicationStatus(
    @Param('applicationId') applicationId: string,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.enterpriseHubService.getApplicationStatus(applicationId, headers);
  }

  @Get('enterprises/:enterpriseId/changes/current')
  getCurrentChange(
    @Param('enterpriseId') enterpriseId: string,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.enterpriseHubPublishedChangeService.getCurrentChange(
      enterpriseId,
      headers,
    );
  }

  @Put('enterprises/:enterpriseId/changes/current/basic')
  updateCurrentChangeBasic(
    @Param('enterpriseId') enterpriseId: string,
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.enterpriseHubPublishedChangeService.updateCurrentBasic(
      enterpriseId,
      payload,
      headers,
    );
  }

  @Put('enterprises/:enterpriseId/changes/current/profiles/company')
  updateCurrentChangeCompanyProfile(
    @Param('enterpriseId') enterpriseId: string,
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.enterpriseHubPublishedChangeService.updateCurrentCompanyProfile(
      enterpriseId,
      payload,
      headers,
    );
  }

  @Put('enterprises/:enterpriseId/changes/current/profiles/factory')
  updateCurrentChangeFactoryProfile(
    @Param('enterpriseId') enterpriseId: string,
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.enterpriseHubPublishedChangeService.updateCurrentFactoryProfile(
      enterpriseId,
      payload,
      headers,
    );
  }

  @Put('enterprises/:enterpriseId/changes/current/profiles/supplier')
  updateCurrentChangeSupplierProfile(
    @Param('enterpriseId') enterpriseId: string,
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.enterpriseHubPublishedChangeService.updateCurrentSupplierProfile(
      enterpriseId,
      payload,
      headers,
    );
  }

  @Post('enterprises/:enterpriseId/changes/current/cases')
  @HttpCode(HttpStatus.OK)
  createCurrentChangeCase(
    @Param('enterpriseId') enterpriseId: string,
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.enterpriseHubPublishedChangeService.createCurrentCase(
      enterpriseId,
      payload,
      headers,
    );
  }

  @Put('enterprises/:enterpriseId/changes/current/cases/:caseId')
  @HttpCode(HttpStatus.OK)
  updateCurrentChangeCase(
    @Param('enterpriseId') enterpriseId: string,
    @Param('caseId') caseId: string,
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.enterpriseHubPublishedChangeService.updateCurrentCase(
      enterpriseId,
      caseId,
      payload,
      headers,
    );
  }

  @Delete('enterprises/:enterpriseId/changes/current/cases/:caseId')
  @HttpCode(HttpStatus.OK)
  deleteCurrentChangeCase(
    @Param('enterpriseId') enterpriseId: string,
    @Param('caseId') caseId: string,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.enterpriseHubPublishedChangeService.deleteCurrentCase(
      enterpriseId,
      caseId,
      headers,
    );
  }

  @Post('enterprises/:enterpriseId/changes/current/submit')
  @HttpCode(HttpStatus.OK)
  submitCurrentChange(
    @Param('enterpriseId') enterpriseId: string,
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.enterpriseHubPublishedChangeService.submitCurrentChange(
      enterpriseId,
      payload,
      headers,
    );
  }

  @Get('enterprises/:enterpriseId/changes/current/status')
  getCurrentChangeStatus(
    @Param('enterpriseId') enterpriseId: string,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.enterpriseHubPublishedChangeService.getCurrentChangeStatus(
      enterpriseId,
      headers,
    );
  }
}
