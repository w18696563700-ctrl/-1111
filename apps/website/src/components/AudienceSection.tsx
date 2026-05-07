type AudienceContent = {
  eyebrow: string;
  title: string;
  items: Array<{ icon: string; title: string; summary: string }>;
};

export function AudienceSection({ content }: { content: AudienceContent }) {
  return (
    <section className="section" id="audience">
      <div className="section-heading">
        <p className="eyebrow">{content.eyebrow}</p>
        <h2>{content.title}</h2>
      </div>
      <div className="audience-grid">
        {content.items.map((item) => (
          <article className="info-card audience-card" key={item.title}>
            <span className={`audience-icon audience-icon-${item.icon}`} aria-hidden="true" />
            <h3>{item.title}</h3>
            <p>{item.summary}</p>
          </article>
        ))}
      </div>
    </section>
  );
}
