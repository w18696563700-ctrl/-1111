import { Injectable } from '@nestjs/common';
import { ProjectEntity } from '../project/entities/project.entity';
import { ProjectPresenter } from '../project/project.presenter';
import { MyProjectPrivateProgressReadModel } from './my-project.private-progress';

type ProjectViewerRelation = 'owner' | 'non_owner';

@Injectable()
export class MyProjectPresenter {
  constructor(private readonly projectPresenter: ProjectPresenter) {}

  toListResponse(
    projects: ProjectEntity[],
    privateProgressByProjectId: Map<string, MyProjectPrivateProgressReadModel>
  ) {
    const ongoingProjects = [];
    const historicalProjects = [];

    for (const project of projects) {
      const item = this.toListItem(project, privateProgressByProjectId.get(project.id));
      if (item.publicProject.state === 'archived') {
        historicalProjects.push(item);
        continue;
      }
      // historicalProjects contains owner-archived items plus formally completed continuation.
      if (item.privateSummary.formalCompletionStatus === 'formally_completed') {
        historicalProjects.push(item);
        continue;
      }
      ongoingProjects.push(item);
    }

    return {
      ongoingProjects,
      historicalProjects
    };
  }

  toDetailResponse(
    project: ProjectEntity,
    privateProgress: MyProjectPrivateProgressReadModel,
    viewerProjectRelation: ProjectViewerRelation
  ) {
    return {
      publicProject: {
        ...this.projectPresenter.toReadModel(project),
        viewerProjectRelation
      },
      privateProgress
    };
  }

  private toListItem(project: ProjectEntity, privateSummary: MyProjectPrivateProgressReadModel) {
    return {
      publicProject: this.projectPresenter.toShowcaseListItem(project),
      privateSummary
    };
  }
}
