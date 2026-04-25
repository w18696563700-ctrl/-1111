export type ProjectNameAccessStatus = 'visible' | 'requestable' | 'pending' | 'rejected';

export type ProjectNameAccessReadModel = {
  status: ProjectNameAccessStatus;
  canRequest: boolean;
  requestId: string | null;
};

export type ProjectNameAccessProjection = {
  displayTitle: string;
  title: string;
  exhibitionName: string | null;
  brandName: string | null;
  nameAccess: ProjectNameAccessReadModel;
};

