import { Body, Controller, Get, Headers, Param, Post, Put, Query } from '@nestjs/common';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { EnterpriseHubQueryService } from './enterprise-hub-query.service';
import { EnterpriseHubWriteService } from './enterprise-hub-write.service';

@Controller('server/exhibition/enterprise-hub')
export class EnterpriseHubTruthController {
  constructor(
    private readonly queryService: EnterpriseHubQueryService,
    private readonly writeService: EnterpriseHubWriteService
  ) {}

  @Get('enterprises')
  getEnterprises(@Query() query: Record<string, unknown>) {
    return this.queryService.getEnterprises(query);
  }

  @Get('enterprises/:enterpriseId')
  getEnterpriseDetail(@Param('enterpriseId') enterpriseId: string, @Query('boardType') boardType: string) {
    return this.queryService.getEnterpriseDetail(enterpriseId, boardType);
  }

  @Get('recommendations')
  getRecommendations(@Query() query: Record<string, unknown>) {
    return this.queryService.getRecommendations(query);
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
}
