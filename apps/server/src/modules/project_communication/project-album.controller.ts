import { Body, Controller, Delete, Get, Headers, HttpCode, Param, Post } from '@nestjs/common';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { ProjectAlbumPhotoService } from './project-album-photo.service';

@Controller('server/projects/:projectId/album/photos')
export class ProjectAlbumController {
  constructor(private readonly photoService: ProjectAlbumPhotoService) {}

  @Get()
  list(@Param('projectId') projectId: string, @Headers() headers: HeaderBag) {
    return this.photoService.list(projectId, resolveRequestContext(headers));
  }

  @Post()
  @HttpCode(202)
  bind(
    @Param('projectId') projectId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.photoService.bind(projectId, body, resolveRequestContext(headers));
  }

  @Delete(':photoId')
  @HttpCode(202)
  remove(
    @Param('projectId') projectId: string,
    @Param('photoId') photoId: string,
    @Headers() headers: HeaderBag
  ) {
    return this.photoService.remove(projectId, photoId, resolveRequestContext(headers));
  }
}
