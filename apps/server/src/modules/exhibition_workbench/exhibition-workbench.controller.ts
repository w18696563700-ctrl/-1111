import { Controller, Get, Headers } from '@nestjs/common';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { ExhibitionWorkbenchQueryService } from './exhibition-workbench.query.service';

@Controller('server/exhibition/workbench')
export class ExhibitionWorkbenchController {
  constructor(private readonly queryService: ExhibitionWorkbenchQueryService) {}

  @Get()
  getSummary(@Headers() headers: HeaderBag) {
    return this.queryService.getSummary(resolveRequestContext(headers));
  }
}
