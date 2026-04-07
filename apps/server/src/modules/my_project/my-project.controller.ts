import { Controller, Get, Headers, Param } from '@nestjs/common';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { MyProjectQueryService } from './my-project.query.service';

@Controller('server/my/projects')
export class MyProjectController {
  constructor(private readonly queryService: MyProjectQueryService) {}

  @Get()
  listProjects(@Headers() headers: HeaderBag) {
    return this.queryService.listProjects(resolveRequestContext(headers));
  }

  @Get(':projectId')
  getProjectById(@Param('projectId') projectId: string, @Headers() headers: HeaderBag) {
    return this.queryService.getProjectById(projectId, resolveRequestContext(headers));
  }
}
