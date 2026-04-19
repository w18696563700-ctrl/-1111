export const CONTENT_SAFETY_P0_ENGINE_TYPES = ['rule', 'ocr', 'manual'] as const;

export type ContentSafetyEngineType = (typeof CONTENT_SAFETY_P0_ENGINE_TYPES)[number];
export type ContentSafetyDecision = 'allow' | 'block' | 'manual_review';
export type ContentSafetyProfileField = 'nickname' | 'avatar' | 'intro';

export const CONTENT_SAFETY_FORUM_REPORT_TARGET_TYPES = ['post', 'comment'] as const;
export type ContentSafetyForumReportTargetType =
  (typeof CONTENT_SAFETY_FORUM_REPORT_TARGET_TYPES)[number];

export const CONTENT_SAFETY_FORUM_REPORT_REASON_CODES = [
  'ad_or_solicitation',
  'abuse_or_insult',
  'flamebait_or_conflict',
  'spam_or_flood',
  'plagiarism_or_repost',
  'other'
] as const;
export type ContentSafetyForumReportReasonCode =
  (typeof CONTENT_SAFETY_FORUM_REPORT_REASON_CODES)[number];

export const PROFILE_AVATAR_MAX_BYTES = 5 * 1024 * 1024;

export const CONTENT_SAFETY_FALLBACK_RULES = [
  {
    id: 'p0_reserved_official',
    ruleKey: 'reserved_official',
    ruleType: 'reserved_word',
    fieldScope: 'profile',
    matchMode: 'substring',
    pattern: '官方',
    decision: 'block',
    reasonCode: 'reserved_word',
    reasonText: '资料内容包含平台保留词。'
  },
  {
    id: 'p0_reserved_admin',
    ruleKey: 'reserved_admin',
    ruleType: 'reserved_word',
    fieldScope: 'profile',
    matchMode: 'substring',
    pattern: '管理员',
    decision: 'block',
    reasonCode: 'reserved_word',
    reasonText: '资料内容包含平台保留词。'
  },
  {
    id: 'p0_reserved_customer_service',
    ruleKey: 'reserved_customer_service',
    ruleType: 'reserved_word',
    fieldScope: 'profile',
    matchMode: 'substring',
    pattern: '客服',
    decision: 'block',
    reasonCode: 'reserved_word',
    reasonText: '资料内容包含平台保留词。'
  },
  {
    id: 'p0_contact_mobile',
    ruleKey: 'contact_mobile',
    ruleType: 'contact',
    fieldScope: 'profile',
    matchMode: 'regex',
    pattern: '1[3-9][0-9]{9}',
    decision: 'block',
    reasonCode: 'contact_info',
    reasonText: '资料内容不得包含联系方式或引流信息。'
  },
  {
    id: 'p0_contact_wechat',
    ruleKey: 'contact_wechat',
    ruleType: 'contact',
    fieldScope: 'profile',
    matchMode: 'regex',
    pattern: '(微信|VX|vx|V信|加我|联系我)',
    decision: 'block',
    reasonCode: 'contact_info',
    reasonText: '资料内容不得包含联系方式或引流信息。'
  },
  {
    id: 'p0_sensitive_scam',
    ruleKey: 'sensitive_scam',
    ruleType: 'sensitive_word',
    fieldScope: 'profile',
    matchMode: 'substring',
    pattern: '诈骗',
    decision: 'block',
    reasonCode: 'sensitive_word',
    reasonText: '资料内容包含明显违规词。'
  },
  {
    id: 'p0_sensitive_gambling',
    ruleKey: 'sensitive_gambling',
    ruleType: 'sensitive_word',
    fieldScope: 'profile',
    matchMode: 'substring',
    pattern: '博彩',
    decision: 'block',
    reasonCode: 'sensitive_word',
    reasonText: '资料内容包含明显违规词。'
  },
  {
    id: 'p0_sensitive_adult',
    ruleKey: 'sensitive_adult',
    ruleType: 'sensitive_word',
    fieldScope: 'profile',
    matchMode: 'substring',
    pattern: '裸聊',
    decision: 'block',
    reasonCode: 'sensitive_word',
    reasonText: '资料内容包含明显违规词。'
  }
] as const;
