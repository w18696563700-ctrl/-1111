import { Controller, Get, Headers } from '@nestjs/common';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { ProjectPublicResourceService } from './project-public-resource.service';

@Controller('server/projects/public-resources')
export class ProjectPublicResourceController {
  constructor(private readonly resourceService: ProjectPublicResourceService) {}

  @Get()
  list(@Headers() headers: HeaderBag) {
    return this.resourceService.list(resolveRequestContext(headers));
  }
}
