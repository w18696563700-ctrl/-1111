import { Controller, Get, Headers } from '@nestjs/common';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { CreditConstraintsQueryService } from './credit-constraints.query.service';

@Controller('server/profile/credit-and-constraints')
export class CreditConstraintsController {
  constructor(private readonly queryService: CreditConstraintsQueryService) {}

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
