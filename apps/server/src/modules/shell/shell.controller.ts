import { Controller, Get, Headers } from '@nestjs/common';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { ShellQueryService } from './shell-query.service';

@Controller('server/shell')
export class ShellController {
  constructor(private readonly queryService: ShellQueryService) {}

  @Get('context')
  getContext(@Headers() headers: HeaderBag) {
    return this.queryService.getContext(resolveRequestContext(headers));
  }
}
