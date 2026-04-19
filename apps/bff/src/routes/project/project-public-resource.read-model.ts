export type ProjectPublicResourceCategory =
  | 'contract_template'
  | 'process_guide'
  | 'other_resource';

export type ProjectPublicResourceReadModel = {
  resourceId: string;
  resourceCategory: ProjectPublicResourceCategory;
  title: string;
  summary: string | null;
  fileAssetId: string;
  fileName: string;
  mimeType: string;
  visibility: 'app_shared';
  sortOrder: number;
  publishedAt: string;
};

export type ProjectPublicResourceListResponse = {
  resources: ProjectPublicResourceReadModel[];
};
