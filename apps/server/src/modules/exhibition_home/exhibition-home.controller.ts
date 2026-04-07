import { Body, Controller, Get, HttpCode, Post, Query } from '@nestjs/common';
import { ExhibitionHomeQueryService } from './exhibition-home.query.service';

@Controller('server/exhibition/home')
export class ExhibitionHomeController {
  constructor(private readonly queryService: ExhibitionHomeQueryService) {}

  @Get()
  getHome(@Query() query: Record<string, unknown>) {
    return this.queryService.getHome(query);
  }

  @Post('refresh')
  @HttpCode(200)
  refreshHome(@Body() body: unknown) {
    return this.queryService.refreshHome(body);
  }

  @Post('location/select')
  @HttpCode(200)
  selectLocation(@Body() body: unknown) {
    return this.queryService.selectLocation(body);
  }
}
