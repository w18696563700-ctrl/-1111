import { Controller, Get, Headers } from '@nestjs/common';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { OrganizationCreditScoringQueryService } from './organization-credit-scoring.query.service';

@Controller('server/profile/organization-credit-scoring')
export class OrganizationCreditScoringController {
  constructor(private readonly queryService: OrganizationCreditScoringQueryService) {}

  @Get('status')
  getStatus(@Headers() headers: HeaderBag) {
    return this.queryService.getStatus(resolveRequestContext(headers));
  }

  @Get('explanation')
  getExplanation(@Headers() headers: HeaderBag) {
    return this.queryService.getExplanation(resolveRequestContext(headers));
  }

  @Get('handoff')
  getHandoff(@Headers() headers: HeaderBag) {
    return this.queryService.getHandoff(resolveRequestContext(headers));
  }
}
