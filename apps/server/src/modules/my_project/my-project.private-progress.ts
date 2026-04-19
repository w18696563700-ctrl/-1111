export type MyProjectFormalCompletionStatus = 'not_formally_completed' | 'formally_completed';
export type MyProjectEvaluationStatus = 'not_eligible' | 'eligible' | 'submitted';

export type MyProjectPrivateProgressReadModel = {
  hasAcceptedOrder: boolean;
  orderStatus: string | null;
  contractStatus: string | null;
  fulfillmentStatus: string | null;
  acceptanceStatus: string | null;
  afterSalesOrDisputeStatus: string | null;
  formalCompletionStatus: MyProjectFormalCompletionStatus;
  evaluationStatus: MyProjectEvaluationStatus;
};

export type MyProjectTradeTruthSnapshot = {
  hasAcceptedOrder: boolean;
  orderStatus: string | null;
  contractStatus: string | null;
  fulfillmentStatus: string | null;
  acceptanceStatus: string | null;
  afterSalesOrDisputeStatus: string | null;
  ratingStatus: string | null;
};

export function createDefaultMyProjectPrivateProgress(): MyProjectPrivateProgressReadModel {
  return {
    hasAcceptedOrder: false,
    orderStatus: null,
    contractStatus: null,
    fulfillmentStatus: null,
    acceptanceStatus: null,
    afterSalesOrDisputeStatus: null,
    formalCompletionStatus: 'not_formally_completed',
    evaluationStatus: 'not_eligible'
  };
}

export function deriveMyProjectPrivateProgress(
  snapshot: MyProjectTradeTruthSnapshot
): MyProjectPrivateProgressReadModel {
  const formalCompletionStatus = deriveFormalCompletionStatus(snapshot.orderStatus);

  return {
    hasAcceptedOrder: snapshot.hasAcceptedOrder,
    orderStatus: snapshot.orderStatus,
    contractStatus: snapshot.contractStatus,
    fulfillmentStatus: snapshot.fulfillmentStatus,
    acceptanceStatus: snapshot.acceptanceStatus,
    afterSalesOrDisputeStatus: snapshot.afterSalesOrDisputeStatus,
    formalCompletionStatus,
    evaluationStatus: deriveEvaluationStatus(formalCompletionStatus, snapshot.ratingStatus)
  };
}

function deriveFormalCompletionStatus(orderStatus: string | null): MyProjectFormalCompletionStatus {
  return orderStatus === 'completed' ? 'formally_completed' : 'not_formally_completed';
}

function deriveEvaluationStatus(
  formalCompletionStatus: MyProjectFormalCompletionStatus,
  ratingStatus: string | null
): MyProjectEvaluationStatus {
  if (formalCompletionStatus !== 'formally_completed') {
    return 'not_eligible';
  }
  return ratingStatus === 'submitted' ? 'submitted' : 'eligible';
}
