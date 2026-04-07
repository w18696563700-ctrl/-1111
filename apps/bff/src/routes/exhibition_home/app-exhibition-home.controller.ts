import { Body, Controller, Get, Headers, HttpCode, HttpStatus, Post, Query } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { ExhibitionHomeService } from './exhibition-home.service';

@Controller('api/app/exhibition/home')
export class AppExhibitionHomeController {
  constructor(private readonly exhibitionHomeService: ExhibitionHomeService) {}

  @Get()
  getHome(
    @Headers() headers: IncomingHttpHeaders,
    @Query('latitude') latitude?: string,
    @Query('longitude') longitude?: string,
    @Query('provinceCode') provinceCode?: string,
    @Query('provinceName') provinceName?: string,
    @Query('locationPermissionState') locationPermissionState?: string,
  ) {
    return this.exhibitionHomeService.getHome(headers, {
      latitude,
      longitude,
      provinceCode,
      provinceName,
      locationPermissionState,
    });
  }

  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  refreshHome(
    @Body() payload: Record<string, unknown> | undefined,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.exhibitionHomeService.refreshHome(payload, headers);
  }

  @Post('location/select')
  @HttpCode(HttpStatus.OK)
  selectLocation(
    @Body() payload: Record<string, unknown> | undefined,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.exhibitionHomeService.selectLocation(payload, headers);
  }
}
