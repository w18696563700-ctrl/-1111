import { Injectable } from '@nestjs/common';
import type {
  ForumInteractionReadSurface,
  ForumInteractionWriteAction,
} from './forum-command-error.types';

@Injectable()
export class ForumInteractionCommandErrorMessageService {
  translateInteractionReadMessage(
    surface: ForumInteractionReadSurface,
    code: string,
    message: string,
  ): string {
    if (code === 'AUTH_SESSION_INVALID') {
      return '当前登录状态已失效，请重新登录后再试。';
    }

    if (code === 'FORUM_COMMENT_INVALID') {
      if (surface === 'post_comments') {
        if (message.includes('postId is required')) {
          return '请先选择帖子后再查看评论。';
        }
        if (message.includes('cursor is invalid')) {
          return '当前评论列表游标无效，请刷新后再试。';
        }
        return '当前评论列表参数无效，请检查后再试。';
      }

      if (surface === 'my_comments') {
        if (message.includes('cursor is invalid')) {
          return '当前我的评论列表游标无效，请刷新后再试。';
        }
        return '当前我的评论列表参数无效，请检查后再试。';
      }
    }

    if (code === 'FORUM_POST_UNAVAILABLE') {
      return this.translatePostUnavailableReadMessage(surface, message);
    }

    return '论坛互动内容暂时不可用，请稍后再试。';
  }

  translateInteractionWriteMessage(
    action: ForumInteractionWriteAction,
    code: string,
    message: string,
  ): string {
    if (code === 'AUTH_SESSION_INVALID') {
      return '当前登录状态已失效，请重新登录后再试。';
    }

    if (code === 'FORUM_COMMENT_INVALID') {
      return this.translateCommentInvalidWriteMessage(action, message);
    }

    if (code === 'FORUM_POST_UNAVAILABLE') {
      return this.translatePostUnavailableWriteMessage(action, message);
    }

    return '论坛互动操作暂时失败，请稍后再试。';
  }

  private translatePostUnavailableReadMessage(
    surface: ForumInteractionReadSurface,
    message: string,
  ) {
    if (surface === 'post_comments') {
      if (message.includes('Forum post is unavailable')) {
        return '当前帖子暂不可查看评论，请刷新后再试。';
      }
      return '当前评论链暂不可用，请稍后再试。';
    }

    if (surface === 'my_comments') {
      if (message.includes('pageSize is invalid')) {
        return '当前我的评论列表参数无效，请检查后再试。';
      }
      return '当前我的评论资产暂不可用，请稍后再试。';
    }

    if (surface === 'my_bookmarks') {
      if (message.includes('cursor is invalid')) {
        return '当前我的收藏列表游标无效，请刷新后再试。';
      }
      if (message.includes('pageSize is invalid')) {
        return '当前我的收藏列表参数无效，请检查后再试。';
      }
      return '当前我的收藏资产暂不可用，请稍后再试。';
    }

    return '论坛互动内容暂时不可用，请稍后再试。';
  }

  private translateCommentInvalidWriteMessage(
    action: ForumInteractionWriteAction,
    message: string,
  ) {
    if (action === 'comment_submit') {
      if (message.includes('postId is required')) {
        return '请先选择帖子后再发表评论。';
      }
      if (message.includes('body is required')) {
        return '请先填写评论内容后再提交。';
      }
      if (message.includes('parentCommentId is unavailable')) {
        return '当前回复目标暂不可用，请刷新后再试。';
      }
      return '当前评论参数无效，请检查后再试。';
    }

    if (action === 'post_like') {
      if (message.includes('postId is required')) {
        return '当前点赞参数不完整，请刷新后再试。';
      }
      return '当前点赞请求无效，请检查后再试。';
    }

    if (message.includes('postId is required')) {
      return '当前收藏参数不完整，请刷新后再试。';
    }
    return '当前收藏请求无效，请检查后再试。';
  }

  private translatePostUnavailableWriteMessage(
    action: ForumInteractionWriteAction,
    message: string,
  ) {
    if (message.includes('actorId is unavailable')) {
      return '当前登录状态不可用，请重新登录后再试。';
    }
    if (message.includes('organizationId is unavailable')) {
      return '当前账号还没有可用的组织上下文，暂时不能进行论坛互动。';
    }
    if (message.includes('Forum post is unavailable for interaction')) {
      if (action === 'comment_submit') {
        return '当前帖子暂不可评论，请刷新后再试。';
      }
      if (action === 'post_like') {
        return '当前帖子暂不可点赞，请刷新后再试。';
      }
      return '当前帖子暂不可收藏，请刷新后再试。';
    }

    if (action === 'comment_submit') {
      return '当前评论暂不可提交，请稍后再试。';
    }
    if (action === 'post_like') {
      return '当前点赞操作暂不可用，请稍后再试。';
    }
    return '当前收藏操作暂不可用，请稍后再试。';
  }
}
