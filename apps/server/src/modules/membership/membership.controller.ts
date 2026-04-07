import { Controller, Get, Headers } from '@nestjs/common';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { MembershipQueryService } from './membership.query.service';

@Controller('server/profile/membership')
export class MembershipController {
  constructor(private readonly queryService: MembershipQueryService) {}

  @Get('current')
  getCurrent(@Headers() headers: HeaderBag) {
    return this.queryService.getCurrent(resolveRequestContext(headers));
  }

  @Get('explanation')
  getExplanation(@Headers() headers: HeaderBag) {
    return this.queryService.getExplanation(resolveRequestContext(headers));
  }

  @Get('quota')
  getQuota(@Headers() headers: HeaderBag) {
    return this.queryService.getQuota(resolveRequestContext(headers));
  }

  @Get('upgrade-guide')
  getUpgradeGuide(@Headers() headers: HeaderBag) {
    return this.queryService.getUpgradeGuide(resolveRequestContext(headers));
  }
}
