import { Injectable } from '@nestjs/common';
import { ProjectEntity } from './entities/project.entity';
import { ProjectNameAccessProjection } from '../project_name_access/project-name-access.types';

@Injectable()
export class ProjectPresenter {
  toAcceptedResponse(projectId: string, state: string) {
    return { projectId, state };
  }

  toDeleteAcceptedResponse(projectId: string) {
    return { projectId, state: 'deleted' };
  }

  toListResponse(
    projects: ProjectEntity[],
    page: number,
    pageSize: number,
    total: number,
    accessProjectionByProjectId: Map<string, ProjectNameAccessProjection> = new Map(),
  ) {
    return {
      items: projects.map((project) =>
        this.toShowcaseListItem(project, accessProjectionByProjectId.get(project.id)),
      ),
      pagination: this.toPagination(page, pageSize, total)
    };
  }

  toReadModel(project: ProjectEntity, accessProjection?: ProjectNameAccessProjection) {
    return {
      ...this.toShowcaseListItem(project, accessProjection),
      buildingTypeRemark: this.toNullableText(project.buildingTypeRemark),
      provinceCode: this.toNullableText(project.provinceCode),
      provinceName: this.toNullableText(project.provinceName),
      cityCode: this.toNullableText(project.cityCode),
      cityName: this.toNullableText(project.cityName),
      districtCode: this.toNullableText(project.districtCode),
      districtName: this.toNullableText(project.districtName),
      detailAddress: this.toNullableText(project.detailAddress),
      scopeSummary: this.toNullableText(project.scopeSummary),
      plannedStartAt: this.toNullableDate(project.plannedStartAt),
      plannedEndAt: this.toNullableDate(project.plannedEndAt),
      scheduleDetail: this.toNullableText(project.scheduleDetail),
      description: this.toNullableText(project.description)
    };
  }

  toShowcaseListItem(project: ProjectEntity, accessProjection?: ProjectNameAccessProjection) {
    const access = accessProjection ?? this.toVisibleProjection(project);
    return {
      projectId: project.id,
      projectNo: project.projectNo,
      title: access.title,
      displayTitle: access.displayTitle,
      exhibitionName: access.exhibitionName,
      brandName: access.brandName,
      buildingType: project.buildingType,
      budgetAmount: Number(project.budgetAmount),
      areaSqm: this.toNullableNumber(project.areaSqm),
      provinceCode: this.toNullableText(project.provinceCode),
      provinceName: this.toNullableText(project.provinceName),
      cityCode: this.toNullableText(project.cityCode),
      cityName: this.toNullableText(project.cityName),
      plannedStartAt: this.toNullableDate(project.plannedStartAt),
      plannedEndAt: this.toNullableDate(project.plannedEndAt),
      state: project.state,
      nameAccess: {
        status: access.nameAccess.status,
        canRequest: access.nameAccess.canRequest,
        requestId: access.nameAccess.requestId,
      },
      summary: this.toSummary(project.summary, project.state)
    };
  }

  private toVisibleProjection(project: ProjectEntity): ProjectNameAccessProjection {
    return {
      displayTitle: this.toNullableText(project.exhibitionName) ?? project.title,
      title: project.title,
      exhibitionName: this.toNullableText(project.exhibitionName),
      brandName: this.toNullableText(project.brandName),
      nameAccess: {
        status: 'visible',
        canRequest: false,
        requestId: null,
      },
    };
  }

  private toSummary(summary: Record<string, unknown>, state: string) {
    return {
      heading: this.readString(summary.heading) ?? '项目已进入最小发布走廊。',
      ...(this.readString(summary.stateLabel)
        ? { stateLabel: this.readString(summary.stateLabel) }
        : { stateLabel: this.toStateLabel(state) })
    };
  }

  private toStateLabel(state: string) {
    if (state === 'draft') return '当前项目为草稿，尚未进入公域展示。';
    if (state === 'submitted') return '当前项目已提交，尚未进入公域展示。';
    if (state === 'published') return '当前项目已发布，可继续进入最小竞标继续面。';
    if (state === 'bidding_closed') return '当前项目投标窗口已关闭。';
    if (state === 'awarded') return '当前项目已授标。';
    if (state === 'converted_to_order') return '当前项目已进入订单链路。';
    if (state === 'archived') return '当前项目已归档，可在历史项目中查看。';
    return '当前项目状态已承接。';
  }

  private toPagination(page: number, pageSize: number, total: number) {
    return {
      page,
      pageSize,
      total,
      hasMore: page * pageSize < total
    };
  }

  private readString(value: unknown) {
    if (typeof value !== 'string') {
      return null;
    }
    const normalized = value.trim();
    return normalized ? normalized : null;
  }

  private toNullableText(value: string | null | undefined) {
    return this.readString(value ?? null);
  }

  private toNullableNumber(value: string | number | null | undefined) {
    if (value === null || value === undefined) {
      return null;
    }
    const parsed = typeof value === 'number' ? value : Number(value);
    return Number.isFinite(parsed) ? parsed : null;
  }

  private toNullableDate(value: string | Date | null | undefined) {
    if (typeof value === 'string') {
      const normalized = value.trim();
      return normalized ? normalized : null;
    }
    if (value instanceof Date && !Number.isNaN(value.getTime())) {
      return value.toISOString().slice(0, 10);
    }
    return null;
  }
}
