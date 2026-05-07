export type ProjectBidMaterialKind =
  | 'effect_image'
  | 'construction_doc'
  | 'material_sample'
  | 'equipment_material_list'
  | 'service_list';

export type ProjectBidMaterialReadModel = {
  attachmentId: string;
  projectId: string;
  fileAssetId: string;
  fileName: string;
  attachmentKind: ProjectBidMaterialKind;
  mimeType: string;
  sortOrder: number;
  createdAt: string;
};

export type ProjectBidMaterialReviewReadModel = {
  projectId: string;
  threadId: string;
  viewerRole: string;
  chatAvailability: Record<string, unknown>;
  entries: Record<string, unknown>[];
  generatedAt: string;
};

export type ProjectBidMaterialListResponse = {
  projectId: string;
  attachments: ProjectBidMaterialReadModel[];
  materialReview: ProjectBidMaterialReviewReadModel | null;
};
