import { loadTemplateConfigState } from './template-config-state';
import {
  CompareCard,
  CompareSelector,
  TemplateDetailCard,
  TemplateFilters,
  TemplateList,
  VersionDetailCard,
  VersionList
} from './template-config-read-panels';
import {
  ArchiveVersionForm,
  CreateTemplateForm,
  CreateVersionForm,
  PublishVersionForm,
  UpdateGroupingForm
} from './template-config-write-forms';
import { toNoticeText } from './template-config-view-helpers';

export type TemplateConfigShellProps = {
  selectedTemplateId?: string;
  selectedTemplateVersionId?: string;
  baseVersionId?: string;
  targetVersionId?: string;
  status?: string;
  groupRef?: string;
  keyword?: string;
  notice?: string;
  error?: string;
};

export async function TemplateConfigShell(props: TemplateConfigShellProps) {
  const state = await loadTemplateConfigState(props);

  return (
    <section className="panel review-console governance-console">
      <div className="panel-header">
        <div>
          <p className="eyebrow">Package D 模板治理台</p>
          <h1>模板与规则快照治理工作台</h1>
        </div>
        <span className="badge">仅调用服务端管理接口</span>
      </div>
      <p className="lead">
        `/template_config` 当前只承接 template queue、version detail、compare、draft、publish、archive、grouping。
        它不是 runtime-config、CMS 或历史实例回写台。
      </p>
      <div className="notice-grid">
        {props.notice ? <div className="notice">{toNoticeText(props.notice)}</div> : null}
        {props.error ? <div className="notice danger">{props.error}</div> : null}
        {state.error ? <div className="notice danger">{state.error}</div> : null}
      </div>
      <TemplateFilters status={props.status} groupRef={props.groupRef} keyword={props.keyword} />
      <div className="review-grid governance-grid">
        <TemplateList
          items={state.items}
          total={state.total}
          selectedTemplateId={state.selectedTemplateId}
          filters={props}
        />
        <div className="detail-stack">
          <TemplateDetailCard
            template={state.template}
            selectedTemplateVersionId={state.selectedTemplateVersionId}
          />
          <VersionList
            templateId={state.selectedTemplateId}
            items={state.versions}
            selectedTemplateVersionId={state.selectedTemplateVersionId}
            filters={props}
          />
          <CompareSelector
            templateId={state.selectedTemplateId}
            versions={state.versions}
            baseVersionId={state.baseVersionId}
            targetVersionId={state.targetVersionId}
            filters={props}
          />
          <VersionDetailCard version={state.version} />
          <CompareCard compare={state.compare} />
          <CreateTemplateForm />
          <CreateVersionForm templateId={state.selectedTemplateId} />
          <UpdateGroupingForm
            templateId={state.selectedTemplateId}
            templateVersionId={state.selectedTemplateVersionId}
            currentGroupRef={state.template?.groupRef ?? null}
          />
          <PublishVersionForm
            templateId={state.selectedTemplateId}
            templateVersionId={state.selectedTemplateVersionId}
            versionStatus={state.version?.status}
          />
          <ArchiveVersionForm
            templateId={state.selectedTemplateId}
            templateVersionId={state.selectedTemplateVersionId}
            versionStatus={state.version?.status}
          />
        </div>
      </div>
    </section>
  );
}
