import { Injectable } from '@nestjs/common';
import { ProjectEntity } from '../project/entities/project.entity';

@Injectable()
export class ExhibitionWorkbenchPresenter {
  toReadModel(input: {
    recentProject: ProjectEntity | null;
    canCreateProject: boolean;
    canOpenProjectPool: boolean;
  }) {
    return {
      project_chain: {
        hasProjects: Boolean(input.recentProject),
        recentProjectId: input.recentProject?.id ?? null,
        recentProjectTitle: input.recentProject?.title ?? null,
        canCreateProject: input.canCreateProject,
        canOpenProjectPool: input.canOpenProjectPool
      },
      order_chain: {
        activeOrderId: null,
        activeOrderNo: null,
        activeOrderState: null,
        canOpenOrderDetail: false,
        canOpenContractDetail: false,
        canOpenDisputeOpen: false
      },
      fulfillment_chain: {
        activeMilestoneId: null,
        activeMilestoneTitle: null,
        inspectionState: null,
        canOpenMilestoneList: false,
        canOpenMilestoneSubmit: false,
        canOpenInspectionDetail: false,
        canOpenInspectionSubmit: false
      },
      extension_boundary: {
        canOpenContractDetail: false,
        ratingEntryState: 'controlled_unavailable',
        canOpenDisputeOpen: false,
        disputeWithdrawState: 'frozen'
      }
    };
  }
}
