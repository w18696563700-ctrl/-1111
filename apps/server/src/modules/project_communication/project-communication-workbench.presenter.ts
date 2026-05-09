import { Injectable } from '@nestjs/common';
import { ProjectCommunicationMaterialReviewEntity } from './entities/project-communication-material-review.entity';
import type {
  ProjectCommunicationBusinessTodoSummary,
  ProjectCommunicationChatAvailability
} from './project-communication-business-state.service';
import type {
  ProjectCommunicationWorkbenchActionState,
  ProjectCommunicationWorkbenchAvailabilityState,
  ProjectCommunicationWorkbenchEntryDefinition,
  ProjectCommunicationWorkbenchReviewState,
  ProjectCommunicationWorkbenchViewerRole
} from './project-communication-workbench.types';

export type ProjectCommunicationWorkbenchEntryProjection = {
  definition: ProjectCommunicationWorkbenchEntryDefinition;
  projectId: string;
  threadId: string;
  bidId: string | null;
  viewerRole: ProjectCommunicationWorkbenchViewerRole;
  availabilityState: ProjectCommunicationWorkbenchAvailabilityState;
  reviewState: ProjectCommunicationWorkbenchReviewState | null;
  actionState: ProjectCommunicationWorkbenchActionState;
  attachmentCount: number;
  review: ProjectCommunicationMaterialReviewEntity | null;
  subjectOwnerOrganizationId: string | null;
  reviewerOrganizationId: string | null;
  sourceVersionToken: string | null;
  sourceFiles: ProjectCommunicationWorkbenchSourceFileProjection[];
  badgeCount: number;
  disabledReason: string | null;
};

export type ProjectCommunicationWorkbenchSourceFileProjection = {
  fileAssetId: string;
  fileName: string;
  mimeType: string;
  sortOrder: number;
};

@Injectable()
export class ProjectCommunicationWorkbenchPresenter {
  toWorkbench(input: {
    projectId: string;
    threadId: string;
    viewerRole: ProjectCommunicationWorkbenchViewerRole;
    businessTodoSummary: ProjectCommunicationBusinessTodoSummary;
    chatAvailability: ProjectCommunicationChatAvailability;
    entries: ProjectCommunicationWorkbenchEntryProjection[];
    generatedAt?: Date;
  }) {
    return {
      projectId: input.projectId,
      threadId: input.threadId,
      viewerRole: input.viewerRole,
      businessTodoSummary: input.businessTodoSummary,
      chatAvailability: input.chatAvailability,
      entries: input.entries.map((entry) => this.toEntry(entry)),
      generatedAt: (input.generatedAt ?? new Date()).toISOString()
    };
  }

  toMaterialReviewResponse(input: {
    entry: ProjectCommunicationWorkbenchEntryProjection;
    entries?: ProjectCommunicationWorkbenchEntryProjection[];
    projectId: string;
    threadId: string;
    viewerRole: ProjectCommunicationWorkbenchViewerRole;
  }) {
    return {
      entry: this.toEntry(input.entry),
      entries: input.entries?.map((entry) => this.toEntry(entry)),
      projectId: input.projectId,
      threadId: input.threadId,
      viewerRole: input.viewerRole,
      updatedAt: new Date().toISOString()
    };
  }

  toEntry(input: ProjectCommunicationWorkbenchEntryProjection) {
    const { definition, review } = input;
    return {
      entryKey: definition.entryKey,
      group: definition.group,
      label: definition.label,
      summary: null,
      projectId: input.projectId,
      threadId: input.threadId,
      bidId: input.bidId,
      viewerRole: input.viewerRole,
      subjectOwnerRole: definition.subjectOwnerRole,
      availabilityState: input.availabilityState,
      reviewState: input.reviewState,
      actionState: input.actionState,
      attachmentCount: input.attachmentCount,
      badgeCount: input.badgeCount,
      disabledReason: input.disabledReason,
      sourceFiles: input.sourceFiles.map((file) => ({
        fileAssetId: file.fileAssetId,
        fileName: file.fileName,
        mimeType: file.mimeType,
        sortOrder: file.sortOrder
      })),
      latestFeedbackText: review?.feedbackText ?? null,
      latestFeedbackAt: review?.feedbackAt?.toISOString() ?? null,
      reviewedAt: review?.confirmedAt?.toISOString() ?? null,
      routeTarget: this.routeTarget(input),
      truthAnchor: {
        truthOwner: 'server',
        subjectType: definition.subjectType,
        projectId: input.projectId,
        threadId: input.threadId,
        bidId: input.bidId,
        subjectOwnerOrganizationId: input.subjectOwnerOrganizationId,
        reviewerOrganizationId: input.reviewerOrganizationId,
        materialKind: definition.materialKind,
        bidMaterialSlot: definition.bidMaterialSlot,
        dealConfirmationId: null,
        sourceVersionToken: input.sourceVersionToken
      }
    };
  }

  private routeTarget(input: ProjectCommunicationWorkbenchEntryProjection) {
    const params = {
      projectId: input.projectId,
      threadId: input.threadId,
      bidId: input.bidId,
      entryKey: input.definition.entryKey
    };
    if (input.definition.group === 'deal_confirmation') {
      return {
        actionKey:
          input.definition.entryKey === 'final_confirmed_amount_confirmation'
            ? 'project_deal_confirmation.final_amount.open'
            : 'project_deal_confirmation.open',
        canonicalPath: '/api/app/project/{projectId}/deal-confirmations',
        params
      };
    }
    return {
      actionKey: 'project_communication_material_review.open',
      canonicalPath: '/api/app/message/project-communication/workbench/material-review-detail',
      params
    };
  }
}
