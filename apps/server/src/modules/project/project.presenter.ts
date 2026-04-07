import { Injectable } from '@nestjs/common';
import { ProjectEntity } from './entities/project.entity';

@Injectable()
export class ProjectPresenter {
  toAcceptedResponse(projectId: string) {
    return { projectId };
  }

  toListResponse(projects: ProjectEntity[]) {
    return {
      items: projects.map((project) => this.toShowcaseListItem(project))
    };
  }

  toReadModel(project: ProjectEntity) {
    return {
      ...this.toShowcaseListItem(project),
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

  toShowcaseListItem(project: ProjectEntity) {
    return {
      projectId: project.id,
      projectNo: project.projectNo,
      title: project.title,
      buildingType: project.buildingType,
      budgetAmount: Number(project.budgetAmount),
      areaSqm: this.toNullableNumber(project.areaSqm),
      provinceCode: this.toNullableText(project.provinceCode),
      provinceName: this.toNullableText(project.provinceName),
      cityCode: this.toNullableText(project.cityCode),
      cityName: this.toNullableText(project.cityName),
      state: project.state,
      summary: this.toSummary(project.summary, project.state)
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
    if (state === 'published') return '当前项目已发布，可继续进入最小竞标继续面。';
    if (state === 'bidding_closed') return '当前项目投标窗口已关闭。';
    if (state === 'awarded') return '当前项目已授标。';
    if (state === 'converted_to_order') return '当前项目已进入订单链路。';
    return '当前项目状态已承接。';
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
