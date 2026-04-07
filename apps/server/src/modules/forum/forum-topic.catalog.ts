export type ForumTopicCatalogItem = {
  topicId: string;
  title: string;
  description: string;
  categoryKey: string;
};

export const FORUM_TOPIC_CATALOG: readonly ForumTopicCatalogItem[] = [
  {
    topicId: 'expo-materials',
    title: '布展进场',
    description: '围绕进场排期、吊装窗口和现场衔接的最小讨论面。',
    categoryKey: 'expo'
  },
  {
    topicId: 'vendor-collab',
    title: '材料协同',
    description: '围绕材料交接、替代方案和供应协作的最小讨论面。',
    categoryKey: 'material'
  },
  {
    topicId: 'local-supply',
    title: '本地供应链',
    description: '围绕本地找货、补货和交付承接的最小讨论面。',
    categoryKey: 'local'
  },
  {
    topicId: 'expo-night',
    title: '施工夜班',
    description: '围绕夜班施工、现场值守和安全节奏的最小讨论面。',
    categoryKey: 'night'
  }
];

export function listForumTopics(categoryKey?: string | null) {
  const normalizedCategoryKey = normalizeOptional(categoryKey);
  if (!normalizedCategoryKey) {
    return [...FORUM_TOPIC_CATALOG];
  }
  return FORUM_TOPIC_CATALOG.filter((item) => item.categoryKey === normalizedCategoryKey);
}

export function findForumTopic(topicId?: string | null) {
  const normalizedTopicId = normalizeOptional(topicId);
  if (!normalizedTopicId) {
    return null;
  }
  return FORUM_TOPIC_CATALOG.find((item) => item.topicId === normalizedTopicId) ?? null;
}

function normalizeOptional(value?: string | null) {
  const normalized = value?.trim() ?? '';
  return normalized ? normalized : null;
}
