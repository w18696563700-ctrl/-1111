import { Injectable } from '@nestjs/common';

@Injectable()
export class ForumReportCommandErrorMessageService {
  translateReportSubmitMessage(code: string, message: string): string {
    if (code === 'AUTH_SESSION_INVALID') {
      return '当前登录状态已失效，请重新登录后再试。';
    }

    if (code === 'FORUM_REPORT_INVALID') {
      if (message.includes('targetType must be post or comment')) {
        return '举报目标类型无效，请重新选择后再试。';
      }
      if (message.includes('targetId is required')) {
        return '请先选择要举报的内容后再提交。';
      }
      if (message.includes('reasonCode is invalid')) {
        return '请选择举报原因后再提交。';
      }
      if (message.includes('reasonDetail must be a string')) {
        return '举报补充说明格式无效，请检查后再试。';
      }
      if (message.includes('actorId is unavailable')) {
        return '当前登录状态不可用，请重新登录后再试。';
      }
      if (message.includes('organizationId is unavailable')) {
        return '当前账号还没有可用的组织上下文，暂时不能提交举报。';
      }
      return '当前举报参数无效，请检查后再试。';
    }

    if (code === 'FORUM_POST_UNAVAILABLE') {
      if (message.includes('Forum report target post is unavailable')) {
        return '当前帖子暂不可举报，请刷新后再试。';
      }
      if (message.includes('Forum report target comment is unavailable')) {
        return '当前评论暂不可举报，请刷新后再试。';
      }
      return '当前举报目标暂不可用，请稍后再试。';
    }

    return '举报提交暂时失败，请稍后再试。';
  }
}
