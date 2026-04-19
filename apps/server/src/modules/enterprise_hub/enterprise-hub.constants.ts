export const ENTERPRISE_HUB_BOARD_TYPES = ['company', 'factory', 'supplier'] as const;
export const ENTERPRISE_HUB_APPLICATION_STATUSES = [
  'draft',
  'submitted',
  'under_review',
  'revision_required',
  'approved',
  'rejected'
] as const;
export const ENTERPRISE_HUB_ENTERPRISE_STATUSES = [
  'unpublished',
  'published',
  'offline',
  'frozen'
] as const;
export const ENTERPRISE_HUB_DISPLAY_STATUSES = ['hidden', 'visible'] as const;
export const ENTERPRISE_HUB_CASE_STATUSES = [
  'draft',
  'pending_review',
  'approved',
  'rejected',
  'hidden'
] as const;
export const ENTERPRISE_HUB_CERT_STATUSES = ['pending', 'approved', 'rejected'] as const;
export const ENTERPRISE_HUB_SLOT_STATUSES = ['pending', 'active', 'expired', 'disabled'] as const;
export const ENTERPRISE_HUB_REQUIRED_REVIEW_ACTIONS = [
  'approved',
  'revision_required',
  'rejected'
] as const;
export const ENTERPRISE_HUB_CHANGE_REQUEST_STATUSES = [
  'draft',
  'submitted',
  'under_review',
  'revision_required',
  'approved',
  'rejected',
  'applied'
] as const;
export const ENTERPRISE_HUB_ACTIVE_CHANGE_REQUEST_STATUSES = [
  'draft',
  'submitted',
  'under_review',
  'revision_required'
] as const;
export const ENTERPRISE_HUB_EDITABLE_CHANGE_REQUEST_STATUSES = [
  'draft',
  'revision_required'
] as const;

export const BOARD_LABELS: Record<string, string> = {
  company: '优秀公司',
  factory: '优秀工厂',
  supplier: '优秀供应商'
};
