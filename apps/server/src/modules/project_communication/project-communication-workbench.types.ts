export type ProjectCommunicationWorkbenchEntryKey =
  | 'publisher_effect_image_review'
  | 'publisher_construction_doc_review'
  | 'publisher_material_sample_review'
  | 'publisher_equipment_material_list_review'
  | 'publisher_service_list_review'
  | 'bid_project_understanding_review'
  | 'bid_quote_sheet_review'
  | 'bid_schedule_plan_review'
  | 'contract_confirmation'
  | 'final_confirmed_amount_confirmation';

export type ProjectCommunicationMaterialReviewEntryKey = Exclude<
  ProjectCommunicationWorkbenchEntryKey,
  'contract_confirmation' | 'final_confirmed_amount_confirmation'
>;

export type ProjectCommunicationMaterialReviewState =
  | 'pending_review'
  | 'confirmed'
  | 'needs_supplement';

export type ProjectCommunicationWorkbenchReviewState =
  | 'unsubmitted'
  | ProjectCommunicationMaterialReviewState;

export type ProjectCommunicationWorkbenchEntryGroup =
  | 'publisher_materials'
  | 'bid_materials'
  | 'deal_confirmation';

export type ProjectCommunicationWorkbenchViewerRole =
  | 'publisher'
  | 'bidder'
  | 'unknown';

export type ProjectCommunicationWorkbenchSubjectOwnerRole =
  | 'publisher'
  | 'bidder'
  | 'platform';

export type ProjectCommunicationWorkbenchAvailabilityState =
  | 'unsubmitted'
  | 'readable'
  | 'unavailable';

export type ProjectCommunicationWorkbenchActionState =
  | 'enabled'
  | 'readonly'
  | 'blocked';

export type ProjectCommunicationMaterialSubjectType =
  | 'publisher_quote_basis_material'
  | 'bid_submission_material';

export type ProjectQuoteBasisMaterialKind =
  | 'effect_image'
  | 'construction_doc'
  | 'material_sample'
  | 'equipment_material_list'
  | 'service_list';

export type ProjectBidMaterialSlot =
  | 'project_understanding'
  | 'quote_sheet'
  | 'schedule_plan';

export type ProjectCommunicationWorkbenchEntryDefinition = {
  entryKey: ProjectCommunicationWorkbenchEntryKey;
  group: ProjectCommunicationWorkbenchEntryGroup;
  label: string;
  subjectOwnerRole: ProjectCommunicationWorkbenchSubjectOwnerRole;
  subjectType: ProjectCommunicationMaterialSubjectType | 'deal_confirmation';
  materialKind: ProjectQuoteBasisMaterialKind | null;
  bidMaterialSlot: ProjectBidMaterialSlot | null;
};

export const projectCommunicationWorkbenchEntryDefinitions: readonly ProjectCommunicationWorkbenchEntryDefinition[] = [
  {
    entryKey: 'publisher_effect_image_review',
    group: 'publisher_materials',
    label: '效果图确认',
    subjectOwnerRole: 'publisher',
    subjectType: 'publisher_quote_basis_material',
    materialKind: 'effect_image',
    bidMaterialSlot: null
  },
  {
    entryKey: 'publisher_construction_doc_review',
    group: 'publisher_materials',
    label: '尺寸图 / 施工图确认',
    subjectOwnerRole: 'publisher',
    subjectType: 'publisher_quote_basis_material',
    materialKind: 'construction_doc',
    bidMaterialSlot: null
  },
  {
    entryKey: 'publisher_material_sample_review',
    group: 'publisher_materials',
    label: '材质图 / 材料样板确认',
    subjectOwnerRole: 'publisher',
    subjectType: 'publisher_quote_basis_material',
    materialKind: 'material_sample',
    bidMaterialSlot: null
  },
  {
    entryKey: 'publisher_equipment_material_list_review',
    group: 'publisher_materials',
    label: '设备物料清单确认',
    subjectOwnerRole: 'publisher',
    subjectType: 'publisher_quote_basis_material',
    materialKind: 'equipment_material_list',
    bidMaterialSlot: null
  },
  {
    entryKey: 'publisher_service_list_review',
    group: 'publisher_materials',
    label: '服务清单确认',
    subjectOwnerRole: 'publisher',
    subjectType: 'publisher_quote_basis_material',
    materialKind: 'service_list',
    bidMaterialSlot: null
  },
  {
    entryKey: 'bid_project_understanding_review',
    group: 'bid_materials',
    label: '项目理解确认',
    subjectOwnerRole: 'bidder',
    subjectType: 'bid_submission_material',
    materialKind: null,
    bidMaterialSlot: 'project_understanding'
  },
  {
    entryKey: 'bid_quote_sheet_review',
    group: 'bid_materials',
    label: '报价表确认',
    subjectOwnerRole: 'bidder',
    subjectType: 'bid_submission_material',
    materialKind: null,
    bidMaterialSlot: 'quote_sheet'
  },
  {
    entryKey: 'bid_schedule_plan_review',
    group: 'bid_materials',
    label: '进度安排确认',
    subjectOwnerRole: 'bidder',
    subjectType: 'bid_submission_material',
    materialKind: null,
    bidMaterialSlot: 'schedule_plan'
  },
  {
    entryKey: 'contract_confirmation',
    group: 'deal_confirmation',
    label: '合同确认',
    subjectOwnerRole: 'platform',
    subjectType: 'deal_confirmation',
    materialKind: null,
    bidMaterialSlot: null
  },
  {
    entryKey: 'final_confirmed_amount_confirmation',
    group: 'deal_confirmation',
    label: '最终成交金额确认',
    subjectOwnerRole: 'platform',
    subjectType: 'deal_confirmation',
    materialKind: null,
    bidMaterialSlot: null
  }
] as const;

export const projectCommunicationMaterialReviewEntryKeySet = new Set<ProjectCommunicationWorkbenchEntryKey>(
  projectCommunicationWorkbenchEntryDefinitions
    .filter((definition) => definition.group !== 'deal_confirmation')
    .map((definition) => definition.entryKey)
);
