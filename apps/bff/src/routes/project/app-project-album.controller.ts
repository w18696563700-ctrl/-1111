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
} from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { ProjectAlbumService } from './project-album.service';

@Controller('api/app/project/:projectId/album/photos')
export class AppProjectAlbumController {
  constructor(private readonly service: ProjectAlbumService) {}

  @Get()
  listPhotos(
    @Param('projectId') projectId: string | undefined,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.service.listPhotos(projectId, headers);
  }

  @Post()
  @HttpCode(HttpStatus.ACCEPTED)
  bindPhoto(
    @Param('projectId') projectId: string | undefined,
    @Body() payload: Record<string, unknown>,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.service.bindPhoto(projectId, payload, headers);
  }

  @Delete(':photoId')
  @HttpCode(HttpStatus.ACCEPTED)
  removePhoto(
    @Param('projectId') projectId: string | undefined,
    @Param('photoId') photoId: string | undefined,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.service.removePhoto(projectId, photoId, headers);
  }
}
