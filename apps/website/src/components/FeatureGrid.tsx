type FeatureContent = {
  eyebrow: string;
  title: string;
  summary: string;
  items: Array<{
    icon: string;
    title: string;
    summary: string;
    visualTitle: string;
    visualLines: string[];
  }>;
};

export function FeatureGrid({ content }: { content: FeatureContent }) {
  return (
    <section className="section" id="scenarios">
      <div className="section-heading">
        <div>
          <p className="eyebrow">{content.eyebrow}</p>
          <h2>{content.title}</h2>
        </div>
        <p>{content.summary}</p>
      </div>
      <div className="feature-grid">
        {content.items.map((item) => (
          <article className="info-card feature-card" key={item.title}>
            <span className={`feature-icon feature-icon-${item.icon}`} aria-hidden="true" />
            <h3>{item.title}</h3>
            <p>{item.summary}</p>
            <div className="feature-visual" aria-label={item.visualTitle}>
              <strong>{item.visualTitle}</strong>
              {item.visualLines.map((line) => (
                <span key={line}>{line}</span>
              ))}
            </div>
          </article>
        ))}
      </div>
    </section>
  );
}
