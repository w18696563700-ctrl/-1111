import { Controller, Get, Headers, Param } from '@nestjs/common';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { ProjectBidMaterialService } from './project-bid-material.service';

@Controller('server/projects/:projectId/bid-materials')
export class ProjectBidMaterialController {
  constructor(private readonly bidMaterialService: ProjectBidMaterialService) {}

  @Get()
  list(@Param('projectId') projectId: string, @Headers() headers: HeaderBag) {
    return this.bidMaterialService.list(projectId, resolveRequestContext(headers));
  }
}
