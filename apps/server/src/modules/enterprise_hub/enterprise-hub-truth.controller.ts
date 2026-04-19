import { Body, Controller, Delete, Get, Headers, Param, Post, Put, Query } from '@nestjs/common';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { EnterpriseHubCaseContinuationQueryService } from './enterprise-hub-case-continuation.query.service';
import { EnterpriseHubCaseContinuationWriteService } from './enterprise-hub-case-continuation.write.service';
import { EnterpriseHubFormalInfoQueryService } from './enterprise-hub-formal-info.query.service';
import { EnterpriseHubPublishedChangeAppService } from './enterprise-hub-published-change-app.service';
import { EnterpriseHubQueryService } from './enterprise-hub-query.service';
import { EnterpriseHubWorkbenchQueryService } from './enterprise-hub-workbench.query.service';
import { EnterpriseHubWriteService } from './enterprise-hub-write.service';

@Controller('server/exhibition/enterprise-hub')
export class EnterpriseHubTruthController {
  constructor(
    private readonly queryService: EnterpriseHubQueryService,
    private readonly workbenchQueryService: EnterpriseHubWorkbenchQueryService,
    private readonly caseContinuationQueryService: EnterpriseHubCaseContinuationQueryService,
    private readonly caseContinuationWriteService: EnterpriseHubCaseContinuationWriteService,
    private readonly formalInfoQueryService: EnterpriseHubFormalInfoQueryService,
    private readonly publishedChangeAppService: EnterpriseHubPublishedChangeAppService,
    private readonly writeService: EnterpriseHubWriteService
  ) {}

  @Get('workbench')
  getWorkbench(@Headers() headers: HeaderBag, @Query('boardType') boardType: string) {
    return this.workbenchQueryService.getWorkbench(
      resolveRequestContext(headers),
      boardType,
    );
  }

  @Get('enterprises')
  getEnterprises(@Query() query: Record<string, unknown>) {
    return this.queryService.getEnterprises(query);
  }

  @Get('enterprises/:enterpriseId')
  getEnterpriseDetail(@Param('enterpriseId') enterpriseId: string, @Query('boardType') boardType: string) {
    return this.queryService.getEnterpriseDetail(enterpriseId, boardType);
  }

  @Get('public-cases/:caseId')
  getPublicCaseDetail(@Param('caseId') caseId: string) {
    return this.queryService.getPublicCaseDetail(caseId);
  }

  @Get('enterprises/:enterpriseId/formal-info')
  getEnterpriseFormalInfo(
    @Param('enterpriseId') enterpriseId: string,
    @Headers() headers: HeaderBag,
  ) {
    return this.formalInfoQueryService.getEnterpriseFormalInfo(
      enterpriseId,
      resolveRequestContext(headers),
    );
  }

  @Get('recommendations')
  getRecommendations(@Query() query: Record<string, unknown>) {
    return this.queryService.getRecommendations(query);
  }

  @Post('location/resolve')
  resolveLocation(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
  ) {
    return this.writeService.resolveLocation(
      body,
      resolveRequestContext(headers),
    );
  }

  @Post('enterprises/ensure-shell')
  ensureShell(
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag,
  ) {
    return this.writeService.ensureShell(body, resolveRequestContext(headers));
  }

  @Post('applications')
  createApplication(@Body() body: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.writeService.createApplication(body, resolveRequestContext(headers));
  }

  @Put('enterprises/:enterpriseId/basic')
  updateBasic(
    @Param('enterpriseId') enterpriseId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.writeService.updateBasic(enterpriseId, body, resolveRequestContext(headers));
  }

  @Put('enterprises/:enterpriseId/profiles/company')
  updateCompanyProfile(
    @Param('enterpriseId') enterpriseId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.writeService.updateCompanyProfile(enterpriseId, body, resolveRequestContext(headers));
  }

  @Put('enterprises/:enterpriseId/profiles/factory')
  updateFactoryProfile(
    @Param('enterpriseId') enterpriseId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.writeService.updateFactoryProfile(enterpriseId, body, resolveRequestContext(headers));
  }

  @Put('enterprises/:enterpriseId/profiles/supplier')
  updateSupplierProfile(
    @Param('enterpriseId') enterpriseId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.writeService.updateSupplierProfile(enterpriseId, body, resolveRequestContext(headers));
  }

  @Post('enterprises/:enterpriseId/cases')
  createCase(
    @Param('enterpriseId') enterpriseId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.writeService.createCase(enterpriseId, body, resolveRequestContext(headers));
  }

  @Get('cases/:caseId')
  getCaseDetail(@Param('caseId') caseId: string, @Headers() headers: HeaderBag) {
    return this.caseContinuationQueryService.getCaseDetail(
      caseId,
      resolveRequestContext(headers),
    );
  }

  @Put('cases/:caseId')
  updateCase(
    @Param('caseId') caseId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.caseContinuationWriteService.updateCase(
      caseId,
      body,
      resolveRequestContext(headers),
    );
  }

  @Delete('cases/:caseId')
  deleteCase(@Param('caseId') caseId: string, @Headers() headers: HeaderBag) {
    return this.writeService.deleteCase(caseId, resolveRequestContext(headers));
  }

  @Delete('enterprises/:enterpriseId')
  deleteEnterprise(
    @Param('enterpriseId') enterpriseId: string,
    @Headers() headers: HeaderBag
  ) {
    return this.writeService.deleteEnterprise(enterpriseId, resolveRequestContext(headers));
  }

  @Post('applications/:applicationId/submit')
  submitApplication(
    @Param('applicationId') applicationId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.writeService.submitApplication(applicationId, body, resolveRequestContext(headers));
  }

  @Get('applications/:applicationId')
  getApplicationStatus(@Param('applicationId') applicationId: string, @Headers() headers: HeaderBag) {
    return this.queryService.getApplicationStatus(applicationId, resolveRequestContext(headers));
  }

  @Get('enterprises/:enterpriseId/changes/current')
  getCurrentChange(
    @Param('enterpriseId') enterpriseId: string,
    @Headers() headers: HeaderBag
  ) {
    return this.publishedChangeAppService.getCurrentChange(
      enterpriseId,
      resolveRequestContext(headers),
    );
  }

  @Put('enterprises/:enterpriseId/changes/current/basic')
  updateCurrentChangeBasic(
    @Param('enterpriseId') enterpriseId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.publishedChangeAppService.updateCurrentBasic(
      enterpriseId,
      body,
      resolveRequestContext(headers),
    );
  }

  @Put('enterprises/:enterpriseId/changes/current/profiles/company')
  updateCurrentChangeCompanyProfile(
    @Param('enterpriseId') enterpriseId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.publishedChangeAppService.updateCurrentCompanyProfile(
      enterpriseId,
      body,
      resolveRequestContext(headers),
    );
  }

  @Put('enterprises/:enterpriseId/changes/current/profiles/factory')
  updateCurrentChangeFactoryProfile(
    @Param('enterpriseId') enterpriseId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.publishedChangeAppService.updateCurrentFactoryProfile(
      enterpriseId,
      body,
      resolveRequestContext(headers),
    );
  }

  @Put('enterprises/:enterpriseId/changes/current/profiles/supplier')
  updateCurrentChangeSupplierProfile(
    @Param('enterpriseId') enterpriseId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.publishedChangeAppService.updateCurrentSupplierProfile(
      enterpriseId,
      body,
      resolveRequestContext(headers),
    );
  }

  @Post('enterprises/:enterpriseId/changes/current/cases')
  createCurrentChangeCase(
    @Param('enterpriseId') enterpriseId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.publishedChangeAppService.createCurrentCase(
      enterpriseId,
      body,
      resolveRequestContext(headers),
    );
  }

  @Put('enterprises/:enterpriseId/changes/current/cases/:caseId')
  updateCurrentChangeCase(
    @Param('enterpriseId') enterpriseId: string,
    @Param('caseId') caseId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.publishedChangeAppService.updateCurrentCase(
      enterpriseId,
      caseId,
      body,
      resolveRequestContext(headers),
    );
  }

  @Delete('enterprises/:enterpriseId/changes/current/cases/:caseId')
  deleteCurrentChangeCase(
    @Param('enterpriseId') enterpriseId: string,
    @Param('caseId') caseId: string,
    @Headers() headers: HeaderBag
  ) {
    return this.publishedChangeAppService.deleteCurrentCase(
      enterpriseId,
      caseId,
      resolveRequestContext(headers),
    );
  }

  @Post('enterprises/:enterpriseId/changes/current/submit')
  submitCurrentChange(
    @Param('enterpriseId') enterpriseId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.publishedChangeAppService.submitCurrentChange(
      enterpriseId,
      body,
      resolveRequestContext(headers),
    );
  }

  @Get('enterprises/:enterpriseId/changes/current/status')
  getCurrentChangeStatus(
    @Param('enterpriseId') enterpriseId: string,
    @Headers() headers: HeaderBag
  ) {
    return this.publishedChangeAppService.getCurrentChangeStatus(
      enterpriseId,
      resolveRequestContext(headers),
    );
  }
}
