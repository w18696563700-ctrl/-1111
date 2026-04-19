import Link from 'next/link';
import type {
  AdminTemplateConfigCompareResponse,
  AdminTemplateConfigField,
  AdminTemplateConfigTemplateListItem,
  AdminTemplateConfigVersionListItem
} from '@/core/server/admin-api-client';
import type { TemplateConfigShellState } from './template-config-state';
import {
  buildTemplateHref,
  buildVersionHref,
  formatDate,
  type TemplateConfigViewFilters
} from './template-config-view-helpers';

const STATUS_OPTIONS = ['draft', 'published', 'archived', 'deprecated'] as const;

export function TemplateFilters(props: {
  status?: string;
  groupRef?: string;
  keyword?: string;
}) {
  return (
    <form className="filter-card" action="/template_config">
      <label>
        状态
        <select name="status" defaultValue={props.status ?? ''}>
          <option value="">全部状态</option>
          {STATUS_OPTIONS.map((item) => (
            <option key={item} value={item}>
              {item}
            </option>
          ))}
        </select>
      </label>
      <label>
        groupRef
        <input name="groupRef" defaultValue={props.groupRef ?? ''} />
      </label>
      <label>
        关键词
        <input
          name="keyword"
          defaultValue={props.keyword ?? ''}
          placeholder="templateKey / templateName / description"
        />
      </label>
      <button className="primary" type="submit">
        筛选模板
      </button>
    </form>
  );
}

export function TemplateList({
  items,
  total,
  selectedTemplateId,
  filters
}: {
  items: AdminTemplateConfigTemplateListItem[];
  total: number;
  selectedTemplateId: string | null;
  filters: TemplateConfigViewFilters;
}) {
  if (!items.length) {
    return <div className="empty-card">当前还没有可供治理的 template identity。</div>;
  }

  return (
    <div className="review-list" aria-label="template queue">
      <p className="eyebrow">共 {total} 条</p>
      {items.map((item) => (
        <Link
          className={item.templateId === selectedTemplateId ? 'task-card active' : 'task-card'}
          href={buildTemplateHref(item.templateId, filters)}
          key={item.templateId}
        >
          <span>
            {item.status} · {item.groupRef ?? '未分组'}
          </span>
          <strong>{item.templateName}</strong>
          <small>{item.templateKey}</small>
          <small>{formatDate(item.updatedAt)}</small>
        </Link>
      ))}
    </div>
  );
}

export function TemplateDetailCard({
  template,
  selectedTemplateVersionId
}: {
  template: TemplateConfigShellState['template'];
  selectedTemplateVersionId: string | null;
}) {
  if (!template) {
    return <div className="review-detail empty-card">选中模板后可查看 detail 与 version 队列。</div>;
  }

  return (
    <div className="review-detail">
      <div className="detail-heading">
        <div>
          <p className="eyebrow">Template Detail</p>
          <h2>{template.templateName}</h2>
        </div>
        <span className="badge">{template.status}</span>
      </div>
      <dl className="meta-grid compact">
        <div><dt>templateId</dt><dd>{template.templateId}</dd></div>
        <div><dt>templateKey</dt><dd>{template.templateKey}</dd></div>
        <div><dt>groupRef</dt><dd>{template.groupRef ?? '暂无'}</dd></div>
        <div><dt>activeVersionId</dt><dd>{template.activeVersionId ?? '暂无'}</dd></div>
        <div><dt>publishedVersionCount</dt><dd>{String(template.publishedVersionCount)}</dd></div>
        <div><dt>selectedVersionId</dt><dd>{selectedTemplateVersionId ?? '暂无'}</dd></div>
        <div><dt>createdAt</dt><dd>{formatDate(template.createdAt)}</dd></div>
        <div><dt>updatedAt</dt><dd>{formatDate(template.updatedAt)}</dd></div>
      </dl>
      <div className="value-compare single">
        <div><span>description</span><p>{template.description ?? '暂无'}</p></div>
      </div>
    </div>
  );
}

export function VersionList({
  templateId,
  items,
  selectedTemplateVersionId,
  filters
}: {
  templateId: string | null;
  items: AdminTemplateConfigVersionListItem[];
  selectedTemplateVersionId: string | null;
  filters: TemplateConfigViewFilters;
}) {
  if (!templateId) {
    return <div className="empty-card">当前没有选中的 template。</div>;
  }
  if (!items.length) {
    return <div className="empty-card">当前 template 还没有 version。</div>;
  }

  return (
    <div className="review-list" aria-label="template versions">
      <p className="eyebrow">Version Queue</p>
      {items.map((item) => (
        <Link
          className={
            item.templateVersionId === selectedTemplateVersionId ? 'task-card active' : 'task-card'
          }
          href={buildVersionHref(templateId, item.templateVersionId, filters)}
          key={item.templateVersionId}
        >
          <span>
            v{item.versionNo} · {item.status}
          </span>
          <strong>{item.ruleVersionId}</strong>
          <small>publishedAt: {formatDate(item.publishedAt)}</small>
          <small>createdAt: {formatDate(item.createdAt)}</small>
        </Link>
      ))}
    </div>
  );
}

export function CompareSelector({
  templateId,
  versions,
  baseVersionId,
  targetVersionId,
  filters
}: {
  templateId: string | null;
  versions: AdminTemplateConfigVersionListItem[];
  baseVersionId: string | null;
  targetVersionId: string | null;
  filters: TemplateConfigViewFilters;
}) {
  if (!templateId || versions.length < 2) {
    return <div className="action-card empty-card">至少两个 version 才会开放 compare。</div>;
  }

  return (
    <form className="action-card" action="/template_config">
      <input name="templateId" type="hidden" value={templateId} />
      {filters.selectedTemplateVersionId ? (
        <input name="templateVersionId" type="hidden" value={filters.selectedTemplateVersionId} />
      ) : null}
      {filters.status ? <input name="status" type="hidden" value={filters.status} /> : null}
      {filters.groupRef ? <input name="groupRef" type="hidden" value={filters.groupRef} /> : null}
      {filters.keyword ? <input name="keyword" type="hidden" value={filters.keyword} /> : null}
      <div>
        <p className="eyebrow">Version Compare</p>
        <h2>选择 compare 版本对</h2>
      </div>
      <label>
        baseVersionId
        <select name="baseVersionId" defaultValue={baseVersionId ?? versions[1].templateVersionId}>
          {versions.map((item) => (
            <option key={item.templateVersionId} value={item.templateVersionId}>
              v{item.versionNo} · {item.templateVersionId}
            </option>
          ))}
        </select>
      </label>
      <label>
        targetVersionId
        <select name="targetVersionId" defaultValue={targetVersionId ?? versions[0].templateVersionId}>
          {versions.map((item) => (
            <option key={item.templateVersionId} value={item.templateVersionId}>
              v{item.versionNo} · {item.templateVersionId}
            </option>
          ))}
        </select>
      </label>
      <button className="primary" type="submit">
        查看版本差异
      </button>
    </form>
  );
}

export function VersionDetailCard({
  version
}: {
  version: TemplateConfigShellState['version'];
}) {
  if (!version) {
    return <div className="review-detail empty-card">选中 version 后可查看 schema 与 rule 快照。</div>;
  }

  return (
    <div className="review-detail">
      <div className="detail-heading">
        <div>
          <p className="eyebrow">Version Detail</p>
          <h2>{version.templateVersionId}</h2>
        </div>
        <span className="badge">v{version.versionNo}</span>
      </div>
      <dl className="meta-grid compact">
        <div><dt>status</dt><dd>{version.status}</dd></div>
        <div><dt>templateId</dt><dd>{version.templateId}</dd></div>
        <div><dt>ruleVersionId</dt><dd>{version.rule.ruleVersionId}</dd></div>
        <div><dt>templateRuleId</dt><dd>{version.rule.templateRuleId}</dd></div>
        <div><dt>publishedAt</dt><dd>{formatDate(version.publishedAt)}</dd></div>
        <div><dt>archivedAt</dt><dd>{formatDate(version.archivedAt)}</dd></div>
        <div><dt>createdAt</dt><dd>{formatDate(version.createdAt)}</dd></div>
      </dl>
      <FieldList fields={version.fields} />
      <pre className="json-panel">{JSON.stringify(version.schema, null, 2)}</pre>
      <pre className="json-panel">
        {JSON.stringify(
          {
            assignmentRefs: version.rule.assignmentRefs
          },
          null,
          2
        )}
      </pre>
    </div>
  );
}

export function CompareCard({ compare }: { compare: AdminTemplateConfigCompareResponse | null }) {
  if (!compare) {
    return <div className="review-detail empty-card">当前没有 compare projection。</div>;
  }

  return (
    <div className="review-detail">
      <div className="detail-heading">
        <div>
          <p className="eyebrow">Compare Projection</p>
          <h2>
            v{compare.baseVersion.versionNo} -&gt; v{compare.targetVersion.versionNo}
          </h2>
        </div>
        <span className="badge">
          {compare.groupingDiff.changed ? 'grouping changed' : 'grouping stable'}
        </span>
      </div>
      <div className="value-compare">
        <div>
          <span>fieldDiff</span>
          <pre>{JSON.stringify(compare.fieldDiff, null, 2)}</pre>
        </div>
        <div>
          <span>ruleDiff</span>
          <pre>{JSON.stringify(compare.ruleDiff, null, 2)}</pre>
        </div>
      </div>
      <div className="value-compare single">
        <div>
          <span>groupingDiff</span>
          <p>
            {compare.groupingDiff.baseGroupRef ?? '暂无'} -&gt;{' '}
            {compare.groupingDiff.targetGroupRef ?? '暂无'}
          </p>
        </div>
      </div>
    </div>
  );
}

function FieldList({ fields }: { fields: AdminTemplateConfigField[] }) {
  return (
    <div className="value-compare single">
      <div>
        <span>fields</span>
        <ul className="plain-list">
          {fields.map((field) => (
            <li key={field.fieldKey}>
              {field.displayOrder}. {field.fieldKey} / {field.fieldType} /{' '}
              {field.required ? 'required' : 'optional'}
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
}
