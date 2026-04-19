import { Body, Controller, Get, Headers, HttpCode, HttpStatus, Param, Post, Query } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { ForumReportMineService } from './forum-report-mine.service';
import { ForumService } from './forum.service';

@Controller('bff/forum')
export class ForumController {
  constructor(
    private readonly forumService: ForumService,
    private readonly forumReportMineService: ForumReportMineService,
  ) {}

  @Get('feed')
  getFeed(
    @Headers() headers: IncomingHttpHeaders,
    @Query('scope') scope?: string,
    @Query('topicId') topicId?: string,
    @Query('cursor') cursor?: string,
    @Query('pageSize') pageSize?: string,
  ) {
    return this.forumService.getFeed(headers, scope, topicId, cursor, pageSize);
  }

  @Get('topic/metadata')
  getTopicMetadata(@Headers() headers: IncomingHttpHeaders) {
    return this.forumService.getTopicMetadata(headers);
  }

  @Get('topic/list')
  getTopicList(
    @Headers() headers: IncomingHttpHeaders,
    @Query('categoryKey') categoryKey?: string,
    @Query('cursor') cursor?: string,
    @Query('pageSize') pageSize?: string,
  ) {
    return this.forumService.getTopicList(headers, categoryKey, cursor, pageSize);
  }

  @Get('draft/list')
  getDraftList(
    @Headers() headers: IncomingHttpHeaders,
    @Query('cursor') cursor?: string,
    @Query('pageSize') pageSize?: string,
  ) {
    return this.forumService.getDraftList(headers, cursor, pageSize);
  }

  @Post('draft/save')
  @HttpCode(HttpStatus.ACCEPTED)
  saveDraft(@Body() payload: Record<string, unknown>, @Headers() headers: IncomingHttpHeaders) {
    return this.forumService.saveDraft(payload, headers);
  }

  @Post('publish')
  @HttpCode(HttpStatus.ACCEPTED)
  publishDraft(@Body() payload: Record<string, unknown>, @Headers() headers: IncomingHttpHeaders) {
    return this.forumService.publishDraft(payload, headers);
  }

  @Get('reports/mine')
  getMyReports(@Headers() headers: IncomingHttpHeaders, @Query('limit') limit?: string) {
    return this.forumReportMineService.getMine(headers, limit);
  }

  @Get('reports/mine/:ticketId')
  getMyReportDetail(@Headers() headers: IncomingHttpHeaders, @Param('ticketId') ticketId: string) {
    return this.forumReportMineService.getMineDetail(headers, ticketId);
  }

  @Post('report/submit')
  @HttpCode(HttpStatus.ACCEPTED)
  submitReport(@Body() payload: Record<string, unknown>, @Headers() headers: IncomingHttpHeaders) {
    return this.forumService.submitReport(payload, headers);
  }
}
