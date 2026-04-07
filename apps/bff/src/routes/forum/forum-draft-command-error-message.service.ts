import { Injectable } from '@nestjs/common';

@Injectable()
export class ForumDraftCommandErrorMessageService {
  translateDraftSaveMessage(code: string, message: string): string {
    if (code === 'AUTH_SESSION_INVALID') {
      return '当前登录状态已失效，请重新登录后再试。';
    }

    if (code === 'FORUM_DRAFT_INVALID') {
      if (message.includes('topicId is required')) {
        return '请选择话题后再保存论坛草稿。';
      }
      if (message.includes('title is required')) {
        return '请先填写标题后再保存论坛草稿。';
      }
      if (message.includes('body is required')) {
        return '请先填写正文后再保存论坛草稿。';
      }
      if (message.includes('Draft-stage attachment binding is not approved')) {
        return '当前版本暂不支持给论坛草稿添加附件。';
      }
      if (message.includes('attachmentFileAssetIds')) {
        return '当前附件参数无效，请检查后再试。';
      }
      return '当前草稿内容不完整，请检查后再试。';
    }

    if (code === 'FORUM_DRAFT_UNAVAILABLE') {
      if (message.includes('organizationId is unavailable')) {
        return '当前账号还没有可用的组织上下文，暂时不能保存论坛草稿。';
      }
      if (message.includes('actorId is unavailable')) {
        return '当前登录状态不可用，暂时不能保存论坛草稿。';
      }
      if (message.includes('Forum topic is unavailable for draft save')) {
        return '当前话题暂不可用于保存草稿，请更换话题后再试。';
      }
      if (message.includes('Forum draft is unavailable for save')) {
        return '当前草稿暂不可编辑，请刷新后再试。';
      }
      if (message.includes('Forum draft is not editable in the current state')) {
        return '当前草稿状态不允许继续编辑。';
      }
      return '当前论坛草稿暂不可用，请稍后再试。';
    }

    return '论坛草稿暂时保存失败，请稍后再试。';
  }

  translatePublishMessage(code: string, message: string): string {
    if (code === 'AUTH_SESSION_INVALID') {
      return '当前登录状态已失效，请重新登录后再试。';
    }

    if (code === 'FORUM_PUBLISH_INVALID') {
      if (message.includes('draftId is required')) {
        return '请先保存论坛草稿后再发布。';
      }
      return '当前发布参数不完整，请检查后再试。';
    }

    if (code === 'FORUM_PUBLISH_INVALID_STATE') {
      if (message.includes('Forum draft is unavailable for publish')) {
        return '当前账号下没有可发布的论坛草稿，请确认草稿归属和当前组织后再试。';
      }
      if (message.includes('Only ready_to_publish drafts may be published')) {
        return '当前草稿还不能发布，请先保存完整内容后再试。';
      }
      if (message.includes('Forum draft body is unavailable')) {
        return '当前草稿正文暂不可用，请重新保存后再试。';
      }
      if (message.includes('Forum draft title is unavailable')) {
        return '当前草稿标题暂不可用，请重新保存后再试。';
      }
      if (message.includes('Reply draft topic is unavailable for publish')) {
        return '当前草稿对应的话题暂不可发布，请更换话题后再试。';
      }
      if (message.includes('Unsupported forum draft type')) {
        return '当前草稿类型暂不支持发布。';
      }
      return '当前论坛草稿暂时不能发布，请稍后再试。';
    }

    return '论坛草稿暂时发布失败，请稍后再试。';
  }

  translateDraftOpenMessage(code: string, message: string): string {
    if (code === 'AUTH_SESSION_INVALID') {
      return '当前登录状态已失效，请重新登录后再试。';
    }

    if (code === 'FORUM_DRAFT_OPEN_INVALID') {
      if (message.includes('draftId is required')) {
        return '请先选择要打开的草稿。';
      }
      return '当前草稿打开参数无效，请检查后再试。';
    }

    if (code === 'FORUM_DRAFT_OPEN_PERMISSION_DENIED') {
      return '你没有权限打开这份草稿。';
    }

    if (code === 'FORUM_DRAFT_OPEN_NOT_FOUND') {
      return '当前草稿不存在或已被删除。';
    }

    if (code === 'FORUM_DRAFT_OPEN_UNAVAILABLE') {
      return '当前草稿暂时不能打开。';
    }

    return '草稿暂时无法打开，请稍后再试。';
  }
}
