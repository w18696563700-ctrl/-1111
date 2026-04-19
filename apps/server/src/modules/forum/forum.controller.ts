import { Body, Controller, Get, Headers, HttpCode, Param, Post, Query } from '@nestjs/common';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { ForumReportQueryService } from './forum-report.query.service';
import { ForumReportService } from './forum-report.service';
import { ForumQueryService } from './forum.query.service';
import { ForumWriteService } from './forum.write.service';

@Controller('server/forum')
export class ForumController {
  constructor(
    private readonly queryService: ForumQueryService,
    private readonly writeService: ForumWriteService,
    private readonly reportService: ForumReportService,
    private readonly reportQueryService: ForumReportQueryService
  ) {}

  @Get('feed')
  getFeed(
    @Query('scope') scope?: string,
    @Query('topicId') topicId?: string
  ) {
    return this.queryService.getFeed(scope, topicId);
  }

  @Get('topic/list')
  getTopicList(@Query('categoryKey') categoryKey?: string) {
    return this.queryService.getTopicList(categoryKey);
  }

  @Get('topic/metadata')
  getTopicMetadata() {
    return this.queryService.getTopicMetadata();
  }

  @Get('draft/list')
  getDraftList(@Headers() headers: HeaderBag) {
    return this.queryService.getDraftList(resolveRequestContext(headers));
  }

  @Post('draft/save')
  @HttpCode(202)
  saveDraft(@Body() body: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.writeService.saveDraft(body, resolveRequestContext(headers));
  }

  @Post('publish')
  @HttpCode(202)
  publishDraft(@Body() body: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.writeService.publishDraft(body, resolveRequestContext(headers));
  }

  @Get('reports/mine')
  getMyReports(@Query() query: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.reportQueryService.listMine(query, resolveRequestContext(headers));
  }

  @Get('reports/mine/:ticketId')
  getMyReportDetail(@Param('ticketId') ticketId: string, @Headers() headers: HeaderBag) {
    return this.reportQueryService.getMineReportTicket(ticketId, resolveRequestContext(headers));
  }

  @Post('report/submit')
  @HttpCode(202)
  submitReport(@Body() body: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.reportService.submitReport(body, resolveRequestContext(headers));
  }
}
