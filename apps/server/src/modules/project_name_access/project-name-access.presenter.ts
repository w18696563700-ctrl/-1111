import { Injectable } from '@nestjs/common';
import { OrganizationEntity } from '../organization/entities/organization.entity';
import { UserEntity } from '../identity/entities/user.entity';
import { ProjectNameAccessRequestEntity } from './entities/project-name-access-request.entity';
import {
  buildProjectNameAccessThreadSummary,
  PROJECT_NAME_ACCESS_THREAD_TYPE,
} from './project-name-access.support';

@Injectable()
export class ProjectNameAccessPresenter {
  toRequestAcceptedResponse(request: ProjectNameAccessRequestEntity) {
    return {
      requestId: request.id,
      projectId: request.projectId,
      status: request.state,
      threadId: request.id,
    };
  }

  toPendingListResponse(input: {
    projectId: string;
    items: Array<{
      request: ProjectNameAccessRequestEntity;
      requesterOrganization: OrganizationEntity | null;
      requesterUser: UserEntity | null;
    }>;
  }) {
    return {
      projectId: input.projectId,
      items: input.items.map(({ request, requesterOrganization, requesterUser }) => ({
        requestId: request.id,
        requesterOrganization: {
          organizationId: request.requesterOrganizationId,
          displayName:
            requesterOrganization?.name?.trim() ||
            requesterUser?.nickname?.trim() ||
            '当前申请组织',
          avatarUrl: requesterUser?.avatarUrl?.trim() || null,
        },
        requestedAt: request.createdAt.toISOString(),
        status: request.state,
        threadId: request.id,
      })),
    };
  }

  toThreadDetail(input: {
    threadId: string;
    projectId: string;
    request: ProjectNameAccessRequestEntity;
    displayTitle: string;
    requesterOrganizationName: string;
    ownerCanReview: boolean;
  }) {
    const items = [
      {
        itemId: `${input.request.id}:seed`,
        itemKind: 'system_seed',
        title: '项目名称查看申请',
        summary: buildProjectNameAccessThreadSummary({
          requesterOrganizationName: input.requesterOrganizationName,
          state: 'pending',
        }),
        createdAt: input.request.createdAt.toISOString(),
        action:
          input.ownerCanReview && input.request.state === 'pending'
            ? {
                actionKey: 'project_name_access.review',
                objectType: 'project_name_access_request',
                canonicalPath: null,
                label: '处理申请',
                params: {},
              }
            : null,
      },
    ];

    if (input.request.state !== 'pending' && input.request.reviewedAt) {
      items.push({
        itemId: `${input.request.id}:decision`,
        itemKind: 'system_notice',
        title: input.request.state === 'approved' ? '审批已通过' : '审批已拒绝',
        summary: buildProjectNameAccessThreadSummary({
          requesterOrganizationName: input.requesterOrganizationName,
          state: input.request.state as 'approved' | 'rejected',
        }),
        createdAt: input.request.reviewedAt.toISOString(),
        action: {
          actionKey: 'project_name_access.refresh',
          objectType: 'project_name_access_request',
          canonicalPath: null,
          label: '刷新状态',
          params: {},
        },
      });
    }

    return {
      threadId: input.threadId,
      threadType: PROJECT_NAME_ACCESS_THREAD_TYPE,
      projectId: input.projectId,
      requestId: input.request.id,
      requestStatus: input.request.state,
      displayTitle: input.displayTitle,
      items,
      primaryReviewAction: {
        actionKey: 'project_name_access.review',
        enabled: input.ownerCanReview && input.request.state === 'pending',
        availableDecisions:
          input.ownerCanReview && input.request.state === 'pending' ? ['approve', 'reject'] : [],
      },
    };
  }
}
