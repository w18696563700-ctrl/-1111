type ModuleShellProps = {
  title: string;
  description: string;
  apiPath: string;
  owner: string;
  nextStep: string;
};

export function ModuleShell({
  title,
  description,
  apiPath,
  owner,
  nextStep,
}: ModuleShellProps) {
  return (
    <section className="panel">
      <div className="panel-header">
        <div>
          <p className="eyebrow">管理后台占位页</p>
          <h1>{title}</h1>
        </div>
        <span className="badge">仅调用服务端管理接口</span>
      </div>
      <p className="lead">{description}</p>
      <dl className="meta-grid">
        <div>
          <dt>受控接口</dt>
          <dd>{apiPath}</dd>
        </div>
        <div>
          <dt>真相归属</dt>
          <dd>{owner}</dd>
        </div>
        <div>
          <dt>下一步</dt>
          <dd>{nextStep}</dd>
        </div>
      </dl>
    </section>
  );
}
