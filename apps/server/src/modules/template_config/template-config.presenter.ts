import { Injectable } from '@nestjs/common';
import {
  TemplateConfigCompareProjection,
  TemplateConfigTemplateDetail,
  TemplateConfigTemplateListItem,
  TemplateConfigTemplateRecord,
  TemplateConfigTemplateVersionRecord,
  TemplateConfigVersionDetail,
  TemplateConfigVersionListItem
} from './template-config.types';

@Injectable()
export class TemplateConfigPresenter {
  toTemplateListItem(template: TemplateConfigTemplateRecord): TemplateConfigTemplateListItem {
    return {
      templateId: template.templateId,
      templateKey: template.templateKey,
      templateName: template.templateName,
      groupRef: template.groupRef,
      activeVersionId: template.activeVersionId,
      status: template.status,
      updatedAt: template.updatedAt
    };
  }

  toTemplateDetail(template: TemplateConfigTemplateRecord): TemplateConfigTemplateDetail {
    return {
      ...this.toTemplateListItem(template),
      description: template.description,
      publishedVersionCount: template.publishedVersionCount,
      createdAt: template.createdAt
    };
  }

  toVersionListItem(version: TemplateConfigTemplateVersionRecord): TemplateConfigVersionListItem {
    return {
      templateVersionId: version.templateVersionId,
      versionNo: version.versionNo,
      status: version.status,
      ruleVersionId: version.rule.ruleVersionId,
      publishedAt: version.publishedAt,
      archivedAt: version.archivedAt,
      createdAt: version.createdAt
    };
  }

  toVersionDetail(version: TemplateConfigTemplateVersionRecord): TemplateConfigVersionDetail {
    return {
      templateVersionId: version.templateVersionId,
      templateId: version.templateId,
      versionNo: version.versionNo,
      status: version.status,
      schema: version.schema,
      fields: version.fields,
      rule: version.rule,
      publishedAt: version.publishedAt,
      archivedAt: version.archivedAt,
      createdAt: version.createdAt
    };
  }

  toCompareProjection(compare: TemplateConfigCompareProjection) {
    return compare;
  }
}
