import { Controller, Get, Headers } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { ExhibitionWorkbenchService } from './exhibition-workbench.service';

@Controller('api/app/exhibition')
export class AppExhibitionWorkbenchController {
  constructor(
    private readonly exhibitionWorkbenchService: ExhibitionWorkbenchService,
  ) {}

  @Get('workbench')
  getSummary(@Headers() headers: IncomingHttpHeaders) {
    return this.exhibitionWorkbenchService.getSummary(headers);
  }
}
