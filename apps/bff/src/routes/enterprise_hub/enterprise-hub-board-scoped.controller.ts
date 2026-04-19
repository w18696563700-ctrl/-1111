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
import { EnterpriseHubPublishedChangeService } from './enterprise-hub-published-change.service';
import { EnterpriseHubService } from './enterprise-hub.service';
import { EnterpriseHubWorkbenchService } from './enterprise-hub-workbench.service';

type EnterpriseHubBoardType = 'company' | 'factory' | 'supplier';

type EnterpriseHubBoardScopedControllerOptions = {
  basePath: string;
  boardType: EnterpriseHubBoardType;
};

type EnterpriseHubBoardScopedControllerClass = new (
  enterpriseHubService: EnterpriseHubService,
  enterpriseHubFormalInfoService: EnterpriseHubFormalInfoService,
  enterpriseHubPublishedChangeService: EnterpriseHubPublishedChangeService,
  enterpriseHubWorkbenchService: EnterpriseHubWorkbenchService,
) => unknown;

function createEnterpriseHubBoardScopedController(
  options: EnterpriseHubBoardScopedControllerOptions,
): EnterpriseHubBoardScopedControllerClass {
  @Controller(options.basePath)
  class EnterpriseHubBoardScopedController {
    constructor(
      private readonly enterpriseHubService: EnterpriseHubService,
      private readonly enterpriseHubFormalInfoService: EnterpriseHubFormalInfoService,
      private readonly enterpriseHubPublishedChangeService: EnterpriseHubPublishedChangeService,
      private readonly enterpriseHubWorkbenchService: EnterpriseHubWorkbenchService,
    ) {}

    @Get('workbench')
    getWorkbench(@Headers() headers: IncomingHttpHeaders) {
      return this.enterpriseHubWorkbenchService.getWorkbench(
        headers,
        options.boardType,
      );
    }

    @Get('enterprises')
    listEnterprises(
      @Headers() headers: IncomingHttpHeaders,
      @Query('keyword') keyword?: string,
      @Query('provinceCode') provinceCode?: string,
      @Query('cityCode') cityCode?: string,
      @Query('plantAreaRange') plantAreaRange?: string,
      @Query('page') page?: string,
      @Query('pageSize') pageSize?: string,
    ) {
      return this.enterpriseHubService.listEnterprisesForBoard(
        headers,
        options.boardType,
        {
          keyword,
          provinceCode,
          cityCode,
          plantAreaRange,
          page,
          pageSize,
        },
      );
    }

    @Get('enterprises/:enterpriseId')
    getEnterpriseDetail(
      @Param('enterpriseId') enterpriseId: string,
      @Headers() headers: IncomingHttpHeaders,
    ) {
      return this.enterpriseHubService.getEnterpriseDetailForBoard(
        enterpriseId,
        options.boardType,
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
    getRecommendations(@Headers() headers: IncomingHttpHeaders) {
      return this.enterpriseHubService.getRecommendationsForBoard(
        headers,
        options.boardType,
      );
    }

    @Post('enterprises/ensure-shell')
    @HttpCode(HttpStatus.OK)
    ensureShell(
      @Body() payload: Record<string, unknown>,
      @Headers() headers: IncomingHttpHeaders,
    ) {
      return this.enterpriseHubService.ensureShellForBoard(
        options.boardType,
        payload,
        headers,
      );
    }

    @Post('applications')
    @HttpCode(HttpStatus.OK)
    createApplication(
      @Body() payload: Record<string, unknown>,
      @Headers() headers: IncomingHttpHeaders,
    ) {
      return this.enterpriseHubService.createApplicationForBoard(
        options.boardType,
        payload,
        headers,
      );
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

    @Put(`enterprises/:enterpriseId/profiles/${options.boardType}`)
    updateBoardProfile(
      @Param('enterpriseId') enterpriseId: string,
      @Body() payload: Record<string, unknown>,
      @Headers() headers: IncomingHttpHeaders,
    ) {
      switch (options.boardType) {
        case 'company':
          return this.enterpriseHubService.updateCompanyProfile(
            enterpriseId,
            payload,
            headers,
          );
        case 'factory':
          return this.enterpriseHubService.updateFactoryProfile(
            enterpriseId,
            payload,
            headers,
          );
        case 'supplier':
          return this.enterpriseHubService.updateSupplierProfile(
            enterpriseId,
            payload,
            headers,
          );
      }
    }

    @Post('enterprises/:enterpriseId/cases')
    @HttpCode(HttpStatus.OK)
    createCase(
      @Param('enterpriseId') enterpriseId: string,
      @Body() payload: Record<string, unknown>,
      @Headers() headers: IncomingHttpHeaders,
    ) {
      return this.enterpriseHubService.createCaseForBoard(
        enterpriseId,
        options.boardType,
        payload,
        headers,
      );
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
      return this.enterpriseHubService.getApplicationStatus(
        applicationId,
        headers,
      );
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

    @Put(`enterprises/:enterpriseId/changes/current/profiles/${options.boardType}`)
    updateCurrentChangeBoardProfile(
      @Param('enterpriseId') enterpriseId: string,
      @Body() payload: Record<string, unknown>,
      @Headers() headers: IncomingHttpHeaders,
    ) {
      switch (options.boardType) {
        case 'company':
          return this.enterpriseHubPublishedChangeService.updateCurrentCompanyProfile(
            enterpriseId,
            payload,
            headers,
          );
        case 'factory':
          return this.enterpriseHubPublishedChangeService.updateCurrentFactoryProfile(
            enterpriseId,
            payload,
            headers,
          );
        case 'supplier':
          return this.enterpriseHubPublishedChangeService.updateCurrentSupplierProfile(
            enterpriseId,
            payload,
            headers,
          );
      }
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

  return Object.defineProperty(EnterpriseHubBoardScopedController, 'name', {
    value: `${options.basePath.replace(/[^a-zA-Z0-9]/g, '_')}_controller`,
  });
}

export const AppEnterpriseHubCompanyController: EnterpriseHubBoardScopedControllerClass =
  createEnterpriseHubBoardScopedController({
    basePath: 'api/app/exhibition/enterprise-hub/company',
    boardType: 'company',
  });

export const AppEnterpriseHubFactoryController: EnterpriseHubBoardScopedControllerClass =
  createEnterpriseHubBoardScopedController({
    basePath: 'api/app/exhibition/enterprise-hub/factory',
    boardType: 'factory',
  });

export const AppEnterpriseHubSupplierController: EnterpriseHubBoardScopedControllerClass =
  createEnterpriseHubBoardScopedController({
    basePath: 'api/app/exhibition/enterprise-hub/supplier',
    boardType: 'supplier',
  });

export const EnterpriseHubCompanyController: EnterpriseHubBoardScopedControllerClass =
  createEnterpriseHubBoardScopedController({
    basePath: 'bff/exhibition/enterprise-hub/company',
    boardType: 'company',
  });

export const EnterpriseHubFactoryController: EnterpriseHubBoardScopedControllerClass =
  createEnterpriseHubBoardScopedController({
    basePath: 'bff/exhibition/enterprise-hub/factory',
    boardType: 'factory',
  });

export const EnterpriseHubSupplierController: EnterpriseHubBoardScopedControllerClass =
  createEnterpriseHubBoardScopedController({
    basePath: 'bff/exhibition/enterprise-hub/supplier',
    boardType: 'supplier',
  });
