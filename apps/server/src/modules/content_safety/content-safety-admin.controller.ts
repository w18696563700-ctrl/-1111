import { Body, Controller, Get, Headers, HttpCode, Param, Post } from '@nestjs/common';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { ContentSafetyReviewTaskQueryService } from './content-safety-review-task.query.service';
import { ContentSafetyReviewTaskWriteService } from './content-safety-review-task.write.service';

@Controller('server/admin/content-safety')
export class ContentSafetyAdminController {
  constructor(
    private readonly queryService: ContentSafetyReviewTaskQueryService,
    private readonly writeService: ContentSafetyReviewTaskWriteService
  ) {}

  @Get('review-tasks')
  listReviewTasks(@Headers() headers: HeaderBag) {
    return this.queryService.list(resolveRequestContext(headers));
  }

  @Get('review-tasks/:taskId')
  getReviewTaskDetail(@Param('taskId') taskId: string, @Headers() headers: HeaderBag) {
    return this.queryService.detail(taskId, resolveRequestContext(headers));
  }

  @Post('profile-submissions/:submissionId/approve')
  @HttpCode(200)
  approveProfileSubmission(
    @Param('submissionId') submissionId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.writeService.approveProfileSubmission(
      submissionId,
      body,
      resolveRequestContext(headers)
    );
  }

  @Post('profile-submissions/:submissionId/reject')
  @HttpCode(200)
  rejectProfileSubmission(
    @Param('submissionId') submissionId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.writeService.rejectProfileSubmission(
      submissionId,
      body,
      resolveRequestContext(headers)
    );
  }

  @Post('forum-reports/:ticketId/decide')
  @HttpCode(200)
  decideForumReport(
    @Param('ticketId') ticketId: string,
    @Body() body: Record<string, unknown>,
    @Headers() headers: HeaderBag
  ) {
    return this.writeService.decideForumReport(
      ticketId,
      body,
      resolveRequestContext(headers)
    );
  }
}
