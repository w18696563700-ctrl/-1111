export const EXHIBITION_REPORT_TARGET_TYPES = [
  'project',
  'project_profile',
  'bid',
  'contract',
  'inspection'
] as const;

export const EXHIBITION_REPORT_REASON_CODES = [
  'fabricated_project',
  'unauthorized_project_material',
  'false_budget_or_schedule',
  'fake_organization_or_contact',
  'fraudulent_collection_attempt',
  'other'
] as const;

export const EXHIBITION_REPORT_CASE_STATUSES = [
  'submitted',
  'under_review',
  'explanation_requested',
  'escalated',
  'decided',
  'closed'
] as const;

export const EXHIBITION_TEMPORARY_RESTRICTION_STATES = [
  'not_applied',
  'active',
  'lifted'
] as const;

export const EXHIBITION_REPORT_ADJUDICATION_RESULTS = [
  'not_established',
  'partially_established',
  'materially_established'
] as const;

export type ExhibitionReportTargetType =
  (typeof EXHIBITION_REPORT_TARGET_TYPES)[number];
export type ExhibitionReportCaseStatus =
  (typeof EXHIBITION_REPORT_CASE_STATUSES)[number];
export type ExhibitionTemporaryRestrictionState =
  (typeof EXHIBITION_TEMPORARY_RESTRICTION_STATES)[number];
export type ExhibitionReportAdjudicationResult =
  (typeof EXHIBITION_REPORT_ADJUDICATION_RESULTS)[number];
