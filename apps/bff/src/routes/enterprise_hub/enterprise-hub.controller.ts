import {
  Body,
  Controller,
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
import { EnterpriseHubService } from './enterprise-hub.service';

@Controller('bff/exhibition/enterprise-hub')
export class EnterpriseHubController {
  constructor(private readonly enterpriseHubService: EnterpriseHubService) {}

  @Get('enterprises')
  listEnterprises(
    @Headers() headers: IncomingHttpHeaders,
    @Query('boardType') boardType?: string,
    @Query('keyword') keyword?: string,
    @Query('provinceCode') provinceCode?: string,
    @Query('cityCode') cityCode?: string,
    @Query('certifiedOnly') certifiedOnly?: string,
    @Query('sortBy') sortBy?: string,
    @Query('exhibitionType') exhibitionType?: string,
    @Query('serviceCity') serviceCity?: string,
    @Query('caseCountRange') caseCountRange?: string,
    @Query('reputationLevel') reputationLevel?: string,
    @Query('processType') processType?: string,
    @Query('plantAreaRange') plantAreaRange?: string,
    @Query('urgentCapability') urgentCapability?: string,
    @Query('warehouseCapability') warehouseCapability?: string,
    @Query('supplyCategory') supplyCategory?: string,
    @Query('supplyMode') supplyMode?: string,
    @Query('responseLevel') responseLevel?: string,
    @Query('page') page?: string,
    @Query('pageSize') pageSize?: string,
  ) {
    return this.enterpriseHubService.listEnterprises(headers, {
      boardType,
      keyword,
      provinceCode,
      cityCode,
      certifiedOnly,
      sortBy,
      exhibitionType,
      serviceCity,
      caseCountRange,
      reputationLevel,
      processType,
      plantAreaRange,
      urgentCapability,
      warehouseCapability,
      supplyCategory,
      supplyMode,
      responseLevel,
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

  @Get('recommendations')
  getRecommendations(
    @Headers() headers: IncomingHttpHeaders,
    @Query('boardType') boardType?: string,
  ) {
    return this.enterpriseHubService.getRecommendations(headers, boardType);
  }

  @Post('applications')
  @HttpCode(HttpStatus.OK)
  createApplication(
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.enterpriseHubService.createApplication(payload, headers);
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
}
