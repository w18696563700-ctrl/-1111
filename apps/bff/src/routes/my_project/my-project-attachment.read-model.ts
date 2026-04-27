export type MyProjectAttachmentReadModel = {
  attachmentId: string;
  projectId: string;
  fileAssetId: string;
  fileName: string;
  attachmentKind: string;
  mimeType: string;
  visibility: string;
  sortOrder: number;
  createdAt: string;
  createdBy?: string;
};

export type MyProjectAttachmentListResponse = {
  projectId: string;
  attachments: MyProjectAttachmentReadModel[];
};

export type MyProjectAttachmentDeleteResponse = {
  projectId: string;
  attachmentId: string;
  deleted: true;
};
