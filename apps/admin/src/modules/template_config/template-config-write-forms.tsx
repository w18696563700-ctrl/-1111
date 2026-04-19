import {
  archiveTemplateVersionAction,
  createTemplateConfigAction,
  createTemplateVersionAction,
  publishTemplateVersionAction,
  updateTemplateGroupingAction
} from './template-config-actions';

const DEFAULT_SCHEMA = JSON.stringify(
  {
    kind: 'object',
    revision: 1
  },
  null,
  2
);

const DEFAULT_FIELDS = JSON.stringify(
  [
    {
      fieldKey: 'projectTitle',
      fieldType: 'string',
      required: true,
      defaultValue: null,
      displayOrder: 1
    }
  ],
  null,
  2
);

export function CreateTemplateForm() {
  return (
    <form className="action-card" action={createTemplateConfigAction}>
      <div>
        <p className="eyebrow">Create Template</p>
        <h2>创建 template identity</h2>
      </div>
      <label>
        templateKey
        <input name="templateKey" maxLength={128} placeholder="exhibition-intake" required />
      </label>
      <label>
        templateName
        <input name="templateName" maxLength={128} placeholder="展会项目立项模板" required />
      </label>
      <label>
        description
        <textarea name="description" maxLength={500} placeholder="描述该模板治理对象。" />
      </label>
      <label>
        groupRef
        <input name="groupRef" maxLength={128} placeholder="exhibition/project" />
      </label>
      <button className="primary" type="submit">
        创建模板
      </button>
    </form>
  );
}

export function CreateVersionForm({ templateId }: { templateId: string | null }) {
  if (!templateId) {
    return <div className="action-card empty-card">选中 template 后，才会开放 draft version authoring。</div>;
  }

  return (
    <form className="action-card" action={createTemplateVersionAction}>
      <input name="templateId" type="hidden" value={templateId} />
      <div>
        <p className="eyebrow">Create Version</p>
        <h2>创建 draft version</h2>
      </div>
      <label>
        schemaJson
        <textarea name="schemaJson" defaultValue={DEFAULT_SCHEMA} required />
      </label>
      <label>
        fieldsJson
        <textarea name="fieldsJson" defaultValue={DEFAULT_FIELDS} required />
      </label>
      <label>
        templateRuleId
        <input name="templateRuleId" maxLength={128} placeholder="rule-project" required />
      </label>
      <label>
        ruleVersionId
        <input name="ruleVersionId" maxLength={128} placeholder="rule-project-v1" required />
      </label>
      <label>
        assignmentRefsText
        <textarea
          name="assignmentRefsText"
          defaultValue={'exhibition\nproject_publish'}
          placeholder="一行一个 assignment ref，或用逗号分隔。"
        />
      </label>
      <button className="primary" type="submit">
        创建版本
      </button>
    </form>
  );
}

export function UpdateGroupingForm({
  templateId,
  templateVersionId,
  currentGroupRef
}: {
  templateId: string | null;
  templateVersionId: string | null;
  currentGroupRef: string | null;
}) {
  if (!templateId) {
    return <div className="action-card empty-card">选中 template 后，才会开放 grouping 调整。</div>;
  }

  return (
    <form className="action-card" action={updateTemplateGroupingAction}>
      <input name="templateId" type="hidden" value={templateId} />
      {templateVersionId ? <input name="templateVersionId" type="hidden" value={templateVersionId} /> : null}
      <div>
        <p className="eyebrow">Grouping</p>
        <h2>调整 groupRef</h2>
      </div>
      <label>
        groupRef
        <input
          name="groupRef"
          defaultValue={currentGroupRef ?? ''}
          maxLength={128}
          placeholder="exhibition/project/high-risk"
        />
      </label>
      <button className="primary" type="submit">
        更新分组
      </button>
    </form>
  );
}

export function PublishVersionForm({
  templateId,
  templateVersionId,
  versionStatus
}: {
  templateId: string | null;
  templateVersionId: string | null;
  versionStatus?: string;
}) {
  if (!templateId || !templateVersionId) {
    return <div className="action-card empty-card">选中 version 后，才会开放 publish。</div>;
  }

  return (
    <form className="action-card" action={publishTemplateVersionAction}>
      <input name="templateId" type="hidden" value={templateId} />
      <input name="templateVersionId" type="hidden" value={templateVersionId} />
      <div>
        <p className="eyebrow">Publish</p>
        <h2>发布当前 version</h2>
      </div>
      <p className="lead">当前状态：{versionStatus ?? 'unknown'}</p>
      <label>
        publishNote
        <textarea name="publishNote" maxLength={500} placeholder="描述此次发布的变更意图。" />
      </label>
      <button className="primary" type="submit">
        发布版本
      </button>
    </form>
  );
}

export function ArchiveVersionForm({
  templateId,
  templateVersionId,
  versionStatus
}: {
  templateId: string | null;
  templateVersionId: string | null;
  versionStatus?: string;
}) {
  if (!templateId || !templateVersionId) {
    return <div className="action-card empty-card">选中 version 后，才会开放 archive。</div>;
  }

  return (
    <form className="action-card" action={archiveTemplateVersionAction}>
      <input name="templateId" type="hidden" value={templateId} />
      <input name="templateVersionId" type="hidden" value={templateVersionId} />
      <div>
        <p className="eyebrow">Archive</p>
        <h2>归档当前 version</h2>
      </div>
      <p className="lead">当前状态：{versionStatus ?? 'unknown'}</p>
      <label>
        archiveReason
        <textarea name="archiveReason" maxLength={500} placeholder="说明归档原因。" />
      </label>
      <button className="primary" type="submit">
        归档版本
      </button>
    </form>
  );
}
