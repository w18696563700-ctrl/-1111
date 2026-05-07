type WorkflowContent = {
  eyebrow: string;
  title: string;
  steps: Array<{ title: string; summary: string }>;
};

export function WorkflowSection({ content }: { content: WorkflowContent }) {
  return (
    <section className="section workflow-section" id="workflow">
      <div className="section-heading">
        <p className="eyebrow">{content.eyebrow}</p>
        <h2>{content.title}</h2>
      </div>
      <div className="workflow-list">
        {content.steps.map((step, index) => (
          <article className="workflow-step" key={step.title}>
            <span>{String(index + 1).padStart(2, '0')}</span>
            <div>
              <h3>{step.title}</h3>
              <p>{step.summary}</p>
            </div>
          </article>
        ))}
      </div>
    </section>
  );
}
