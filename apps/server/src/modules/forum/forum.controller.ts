import { Body, Controller, Get, Headers, HttpCode, Param, Post, Query } from '@nestjs/common';
import type { HeaderBag } from '../../shared/request-context';
import { resolveRequestContext } from '../../shared/request-context';
import { ForumAuthorQueryService } from './forum-author.query.service';
import { ForumCommentService } from './forum-comment.service';
import { ForumReportQueryService } from './forum-report.query.service';
import { ForumReportService } from './forum-report.service';
import { ForumQueryService } from './forum.query.service';
import { ForumWriteService } from './forum.write.service';

@Controller('server/forum')
export class ForumController {
  constructor(
    private readonly queryService: ForumQueryService,
    private readonly writeService: ForumWriteService,
    private readonly authorQueryService: ForumAuthorQueryService,
    private readonly commentService: ForumCommentService,
    private readonly reportService: ForumReportService,
    private readonly reportQueryService: ForumReportQueryService
  ) {}

  @Get('feed')
  getFeed(
    @Headers() headers: HeaderBag,
    @Query('scope') scope?: string,
    @Query('topicId') topicId?: string
  ) {
    return this.queryService.getFeed(scope, topicId, resolveRequestContext(headers));
  }

  @Get('topic/list')
  getTopicList(@Query('categoryKey') categoryKey?: string, @Headers() headers?: HeaderBag) {
    return this.queryService.getTopicList(categoryKey, resolveRequestContext(headers ?? {}));
  }

  @Get('topic/metadata')
  getTopicMetadata() {
    return this.queryService.getTopicMetadata();
  }

  @Get('topic/detail')
  getTopicDetail(@Query('topicId') topicId?: string, @Headers() headers?: HeaderBag) {
    return this.queryService.getTopicDetail(topicId, resolveRequestContext(headers ?? {}));
  }

  @Get('post/detail')
  getPostDetail(@Query('postId') postId?: string, @Headers() headers?: HeaderBag) {
    return this.queryService.getPostDetail(postId, resolveRequestContext(headers ?? {}));
  }

  @Get('post/comments')
  getPostComments(
    @Query('postId') postId?: string,
    @Query('cursor') cursor?: string,
    @Query('pageSize') pageSize?: string
  ) {
    return this.commentService.getPostComments(postId, cursor, pageSize);
  }

  @Get('author/profile')
  getAuthorProfile(@Query('authorId') authorId?: string, @Headers() headers?: HeaderBag) {
    return this.authorQueryService.getAuthorProfile(authorId, resolveRequestContext(headers ?? {}));
  }

  @Get('author/posts')
  getAuthorPosts(
    @Query('authorId') authorId?: string,
    @Query('cursor') cursor?: string,
    @Query('pageSize') pageSize?: string
  ) {
    return this.authorQueryService.getAuthorPosts(authorId, cursor, pageSize);
  }

  @Get('search')
  search(@Query('q') q?: string) {
    return this.queryService.search(q);
  }

  @Get('me/index')
  getMeIndex(@Headers() headers: HeaderBag) {
    return this.queryService.getMeIndex(resolveRequestContext(headers));
  }

  @Get('draft/list')
  getDraftList(@Headers() headers: HeaderBag) {
    return this.queryService.getDraftList(resolveRequestContext(headers));
  }

  @Get('draft/detail')
  getDraftDetail(@Query('draftId') draftId: string | undefined, @Headers() headers: HeaderBag) {
    return this.queryService.getDraftDetail(draftId, resolveRequestContext(headers));
  }

  @Get('me/posts')
  getMyPosts(@Headers() headers: HeaderBag) {
    return this.queryService.getMyPosts(resolveRequestContext(headers));
  }

  @Get('me/comments')
  getMyComments(@Headers() headers: HeaderBag) {
    return this.queryService.getMyComments(resolveRequestContext(headers));
  }

  @Get('me/bookmarks')
  getMyBookmarks(@Headers() headers: HeaderBag) {
    return this.queryService.getMyBookmarks(resolveRequestContext(headers));
  }

  @Get('me/likes')
  getMyLikes(@Headers() headers: HeaderBag) {
    return this.queryService.getMyLikes(resolveRequestContext(headers));
  }

  @Get('me/follows')
  getMyFollows(@Headers() headers: HeaderBag) {
    return this.queryService.getMyFollows(resolveRequestContext(headers));
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

  @Post('post/comment')
  @HttpCode(202)
  createComment(@Body() body: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.commentService.createComment(body, resolveRequestContext(headers));
  }

  @Post('post/edit')
  @HttpCode(202)
  enterPostEdit(@Body() body: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.writeService.enterPostEdit(body, resolveRequestContext(headers));
  }

  @Post('post/delete')
  @HttpCode(202)
  deletePost(@Body() body: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.writeService.deletePost(body, resolveRequestContext(headers));
  }

  @Post('post/like')
  @HttpCode(202)
  toggleLike(@Body() body: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.commentService.deferLike(body, resolveRequestContext(headers));
  }

  @Post('post/bookmark')
  @HttpCode(202)
  toggleBookmark(@Body() body: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.commentService.deferBookmark(body, resolveRequestContext(headers));
  }

  @Post('author/follow')
  @HttpCode(202)
  toggleAuthorFollow(@Body() body: Record<string, unknown>, @Headers() headers: HeaderBag) {
    return this.commentService.toggleAuthorFollow(body, resolveRequestContext(headers));
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
