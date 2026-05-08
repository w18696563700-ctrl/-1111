export const COUNTERPART_CONVERSATION_CANONICAL_PATH =
  '/api/app/message/counterpart-conversation/detail';

export function buildCounterpartConversationRouteTarget(input: {
  conversationId: string;
  projectId: string;
  threadId: string;
}) {
  return {
    objectType: 'counterpart_conversation',
    actionKey: 'counterpart_conversation.open',
    canonicalPath: COUNTERPART_CONVERSATION_CANONICAL_PATH,
    params: {
      conversationId: input.conversationId,
      projectId: input.projectId,
      threadId: input.threadId,
    },
  };
}

export function buildProjectClarificationRouteTarget(projectId: string) {
  return {
    objectType: 'project_clarification',
    actionKey: 'project_clarification.open',
    canonicalPath: '/api/app/project/clarification/list',
    params: {
      projectId,
    },
  };
}

export function trimConversationText(value: string, maxLength = 120) {
  const normalized = value.trim();
  if (!normalized) {
    return '当前还没有可展示的项目沟通摘要。';
  }
  if (normalized.length <= maxLength) {
    return normalized;
  }
  return `${normalized.slice(0, maxLength - 3)}...`;
}
