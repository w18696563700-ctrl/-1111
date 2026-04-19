import { Controller, Delete, Get, Headers, HttpCode, HttpStatus, Param } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { MyProjectService } from './my-project.service';

@Controller('api/app/my/projects')
export class MyProjectController {
  constructor(private readonly myProjectService: MyProjectService) {}

  @Get()
  getMyProjects(@Headers() headers: IncomingHttpHeaders) {
    return this.myProjectService.getMyProjects(headers);
  }

  @Get(':projectId')
  getMyProjectDetail(
    @Param('projectId') projectId: string,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.myProjectService.getMyProjectDetail(projectId, headers);
  }

  @Delete(':projectId')
  @HttpCode(HttpStatus.ACCEPTED)
  deleteMyProject(
    @Param('projectId') projectId: string,
    @Headers() headers: IncomingHttpHeaders,
  ) {
    return this.myProjectService.deleteMyProject(projectId, headers);
  }
}
