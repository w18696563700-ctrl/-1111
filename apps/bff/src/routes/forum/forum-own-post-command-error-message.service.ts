import { Injectable } from '@nestjs/common';
import type { ForumOwnPostAction } from './forum-command-error.types';

@Injectable()
export class ForumOwnPostCommandErrorMessageService {
  translateOwnPostReadMessage(code: string, message: string): string {
    if (code === 'AUTH_SESSION_INVALID') {
      return '当前登录状态已失效，请重新登录后再试。';
    }

    if (code === 'FORUM_POST_UNAVAILABLE') {
      if (message.includes('cursor is invalid')) {
        return '当前我的帖子列表游标无效，请刷新后再试。';
      }
      if (message.includes('pageSize is invalid')) {
        return '当前我的帖子列表参数无效，请检查后再试。';
      }
      return '当前我的帖子暂不可用，请稍后再试。';
    }

    return '我的帖子暂时不可用，请稍后再试。';
  }

  translateOwnPostActionMessage(
    action: ForumOwnPostAction,
    code: string,
    message: string,
  ): string {
    if (code === 'AUTH_SESSION_INVALID') {
      return '当前登录状态已失效，请重新登录后再试。';
    }

    if (code === 'FORUM_POST_PERMISSION_DENIED') {
      return action === 'edit' ? '你没有权限编辑这篇帖子。' : '你没有权限删除这篇帖子。';
    }

    if (action === 'edit') {
      return this.translateEditMessage(code, message);
    }

    return this.translateDeleteMessage(code, message);
  }

  private translateEditMessage(code: string, message: string) {
    if (code === 'FORUM_POST_EDIT_INVALID') {
      if (message.includes('postId is required')) {
        return '请先选择要编辑的帖子。';
      }
      return '当前编辑参数无效，请检查后再试。';
    }

    if (code === 'FORUM_POST_EDIT_INVALID_STATE') {
      if (message.includes('Forum post is unavailable')) {
        return '当前帖子不存在或暂不可编辑。';
      }
      return '当前帖子暂时不能进入编辑。';
    }

    return '帖子暂时不能进入编辑，请稍后再试。';
  }

  private translateDeleteMessage(code: string, message: string) {
    if (code === 'FORUM_POST_DELETE_INVALID') {
      if (message.includes('postId is required')) {
        return '请先选择要删除的帖子。';
      }
      return '当前删除参数无效，请检查后再试。';
    }

    if (code === 'FORUM_POST_DELETE_INVALID_STATE') {
      if (message.includes('Forum post is unavailable')) {
        return '当前帖子不存在或暂不可删除。';
      }
      return '当前帖子暂时不能删除。';
    }

    return '帖子暂时不能删除，请稍后再试。';
  }
}
