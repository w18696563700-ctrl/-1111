import { Body, Controller, Get, Headers, HttpCode, HttpStatus, Param, Post, Query } from '@nestjs/common';
import type { IncomingHttpHeaders } from 'http';
import { ForumAuthorProfileService } from './forum-author-profile.service';
import { ForumDraftDeleteService } from './forum-draft-delete.service';
import { ForumDraftOpenService } from './forum-draft-open.service';
import { ForumInteractionInboxService } from './forum-interaction-inbox.service';
import { ForumInteractionService } from './forum-interaction.service';
import { ForumOwnPostContinuityService } from './forum-own-post-continuity.service';
import { ForumReportMineService } from './forum-report-mine.service';
import { ForumService } from './forum.service';

@Controller('bff/forum')
export class ForumController {
  constructor(
    private readonly forumService: ForumService,
    private readonly forumAuthorProfileService: ForumAuthorProfileService,
    private readonly forumInteractionService: ForumInteractionService,
    private readonly forumInteractionInboxService: ForumInteractionInboxService,
    private readonly forumDraftOpenService: ForumDraftOpenService,
    private readonly forumDraftDeleteService: ForumDraftDeleteService,
    private readonly forumOwnPostContinuityService: ForumOwnPostContinuityService,
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

  @Get('topic/detail')
  getTopicDetail(
    @Headers() headers: IncomingHttpHeaders,
    @Query('topicId') topicId?: string,
  ) {
    return this.forumService.getTopicDetail(topicId ?? '', headers);
  }

  @Get('post/detail')
  getPostDetail(
    @Headers() headers: IncomingHttpHeaders,
    @Query('postId') postId?: string,
  ) {
    return this.forumService.getPostDetail(postId ?? '', headers);
  }

  @Get('post/comments')
  getPostComments(
    @Headers() headers: IncomingHttpHeaders,
    @Query('postId') postId?: string,
    @Query('cursor') cursor?: string,
    @Query('pageSize') pageSize?: string,
  ) {
    return this.forumService.getPostComments(postId ?? '', headers, cursor, pageSize);
  }

  @Get('author/profile')
  getAuthorProfile(
    @Headers() headers: IncomingHttpHeaders,
    @Query('authorId') authorId?: string,
  ) {
    return this.forumAuthorProfileService.getAuthorProfile(headers, authorId);
  }

  @Get('author/posts')
  getAuthorPosts(
    @Headers() headers: IncomingHttpHeaders,
    @Query('authorId') authorId?: string,
    @Query('cursor') cursor?: string,
    @Query('pageSize') pageSize?: string,
  ) {
    return this.forumAuthorProfileService.getAuthorPosts(headers, authorId, cursor, pageSize);
  }

  @Get('draft/list')
  getDraftList(
    @Headers() headers: IncomingHttpHeaders,
    @Query('cursor') cursor?: string,
    @Query('pageSize') pageSize?: string,
  ) {
    return this.forumService.getDraftList(headers, cursor, pageSize);
  }

  @Get('draft/detail')
  getDraftDetail(
    @Headers() headers: IncomingHttpHeaders,
    @Query('draftId') draftId?: string,
  ) {
    return this.forumDraftOpenService.getDraftDetail(headers, draftId);
  }

  @Get('me/posts')
  getMyPosts(
    @Headers() headers: IncomingHttpHeaders,
    @Query('cursor') cursor?: string,
    @Query('pageSize') pageSize?: string,
  ) {
    return this.forumOwnPostContinuityService.getMyPosts(headers, cursor, pageSize);
  }

  @Get('me/comments')
  getMyComments(
    @Headers() headers: IncomingHttpHeaders,
    @Query('cursor') cursor?: string,
    @Query('pageSize') pageSize?: string,
  ) {
    return this.forumService.getMyComments(headers, cursor, pageSize);
  }

  @Get('me/bookmarks')
  getMyBookmarks(
    @Headers() headers: IncomingHttpHeaders,
    @Query('cursor') cursor?: string,
    @Query('pageSize') pageSize?: string,
  ) {
    return this.forumService.getMyBookmarks(headers, cursor, pageSize);
  }

  @Get('me/likes')
  getMyLikes(
    @Headers() headers: IncomingHttpHeaders,
    @Query('cursor') cursor?: string,
    @Query('pageSize') pageSize?: string,
  ) {
    return this.forumService.getMyLikes(headers, cursor, pageSize);
  }

  @Get('me/follows')
  getMyFollows(
    @Headers() headers: IncomingHttpHeaders,
    @Query('cursor') cursor?: string,
    @Query('pageSize') pageSize?: string,
  ) {
    return this.forumService.getMyFollows(headers, cursor, pageSize);
  }

  @Get('interaction/inbox')
  getInteractionInbox(
    @Headers() headers: IncomingHttpHeaders,
    @Query('tab') tab?: string,
    @Query('cursor') cursor?: string,
    @Query('pageSize') pageSize?: string,
  ) {
    return this.forumInteractionInboxService.getInbox(headers, tab, cursor, pageSize);
  }

  @Get('me/index')
  getMeIndex(@Headers() headers: IncomingHttpHeaders) {
    return this.forumService.getMeIndex(headers);
  }

  @Get('search')
  search(
    @Headers() headers: IncomingHttpHeaders,
    @Query('q') q?: string,
    @Query('cursor') cursor?: string,
    @Query('pageSize') pageSize?: string,
  ) {
    return this.forumService.search(q ?? '', headers, cursor, pageSize);
  }

  @Post('draft/save')
  @HttpCode(HttpStatus.ACCEPTED)
  saveDraft(@Body() payload: Record<string, unknown>, @Headers() headers: IncomingHttpHeaders) {
    return this.forumService.saveDraft(payload, headers);
  }

  @Post('draft/delete')
  @HttpCode(HttpStatus.ACCEPTED)
  deleteDraft(@Body() payload: Record<string, unknown>, @Headers() headers: IncomingHttpHeaders) {
    return this.forumDraftDeleteService.deleteDraft(payload, headers);
  }

  @Post('publish')
  @HttpCode(HttpStatus.ACCEPTED)
  publishDraft(@Body() payload: Record<string, unknown>, @Headers() headers: IncomingHttpHeaders) {
    return this.forumService.publishDraft(payload, headers);
  }

  @Post('post/comment')
  @HttpCode(HttpStatus.ACCEPTED)
  createComment(@Body() payload: Record<string, unknown>, @Headers() headers: IncomingHttpHeaders) {
    return this.forumInteractionService.createComment(payload, headers);
  }

  @Post('post/edit')
  @HttpCode(HttpStatus.ACCEPTED)
  enterPostEdit(@Body() payload: Record<string, unknown>, @Headers() headers: IncomingHttpHeaders) {
    return this.forumOwnPostContinuityService.enterEditDraft(payload, headers);
  }

  @Post('post/delete')
  @HttpCode(HttpStatus.ACCEPTED)
  deletePost(@Body() payload: Record<string, unknown>, @Headers() headers: IncomingHttpHeaders) {
    return this.forumOwnPostContinuityService.deletePost(payload, headers);
  }

  @Post('post/like')
  @HttpCode(HttpStatus.ACCEPTED)
  toggleLike(@Body() payload: Record<string, unknown>, @Headers() headers: IncomingHttpHeaders) {
    return this.forumInteractionService.toggleLike(payload, headers);
  }

  @Post('post/bookmark')
  @HttpCode(HttpStatus.ACCEPTED)
  toggleBookmark(@Body() payload: Record<string, unknown>, @Headers() headers: IncomingHttpHeaders) {
    return this.forumInteractionService.toggleBookmark(payload, headers);
  }

  @Post('author/follow')
  @HttpCode(HttpStatus.ACCEPTED)
  toggleAuthorFollow(@Body() payload: Record<string, unknown>, @Headers() headers: IncomingHttpHeaders) {
    return this.forumInteractionService.toggleAuthorFollow(payload, headers);
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
