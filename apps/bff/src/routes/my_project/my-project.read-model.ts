export type ProjectSummary = Record<string, unknown>;

export type ProjectViewerRelation = 'owner' | 'non_owner';

export type ProjectShowcaseListItemReadModel = {
  projectId: string;
  projectNo: string;
  title: string;
  buildingType: string;
  budgetAmount: number;
  areaSqm: number | null;
  provinceCode: string | null;
  provinceName: string | null;
  cityCode: string | null;
  cityName: string | null;
  state: string;
  summary: ProjectSummary;
};

export type ProjectReadModel = ProjectShowcaseListItemReadModel & {
  buildingTypeRemark: string | null;
  districtCode: string | null;
  districtName: string | null;
  detailAddress: string | null;
  scopeSummary: string | null;
  plannedStartAt: string | null;
  plannedEndAt: string | null;
  scheduleDetail: string | null;
  description: string | null;
  viewerProjectRelation: ProjectViewerRelation;
};

export type MyProjectFormalCompletionStatus =
  | 'not_formally_completed'
  | 'formally_completed';

export type MyProjectEvaluationStatus =
  | 'not_eligible'
  | 'eligible'
  | 'submitted';

export type MyProjectPrivateProgressBase = {
  hasAcceptedOrder: boolean;
  orderStatus: string | null;
  contractStatus: string | null;
  fulfillmentStatus: string | null;
  acceptanceStatus: string | null;
  afterSalesOrDisputeStatus: string | null;
  formalCompletionStatus: MyProjectFormalCompletionStatus;
  evaluationStatus: MyProjectEvaluationStatus;
};

export type MyProjectPrivateProgressSummaryReadModel =
  MyProjectPrivateProgressBase;

export type MyProjectPrivateProgressReadModel = MyProjectPrivateProgressBase;

export type MyProjectListItemReadModel = {
  publicProject: ProjectShowcaseListItemReadModel;
  privateSummary: MyProjectPrivateProgressSummaryReadModel;
};

export type MyProjectListResponse = {
  ongoingProjects: MyProjectListItemReadModel[];
  historicalProjects: MyProjectListItemReadModel[];
};

export type MyProjectDetailReadModel = {
  publicProject: ProjectReadModel;
  privateProgress: MyProjectPrivateProgressReadModel;
};
