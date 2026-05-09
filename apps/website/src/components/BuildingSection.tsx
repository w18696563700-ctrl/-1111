type BuildingContent = {
  eyebrow: string;
  title: string;
  summary: string;
  items: Array<{ title: string; summary: string; focus: string; icon: string; tags: string[] }>;
};

export function BuildingSection({ content }: { content: BuildingContent }) {
  return (
    <section className="section" id="buildings">
      <div className="section-heading">
        <div>
          <p className="eyebrow">{content.eyebrow}</p>
          <h2>{content.title}</h2>
        </div>
        <p>{content.summary}</p>
      </div>
      <div className="building-grid">
        {content.items.map((item) => (
          <article className="info-card building-card" key={item.title}>
            <span className="card-index">{item.icon}</span>
            <h3>{item.title}</h3>
            <p>{item.summary}</p>
            <div className="tag-row">
              {item.tags.map((tag) => (
                <span key={tag}>{tag}</span>
              ))}
            </div>
            <small>{item.focus}</small>
          </article>
        ))}
      </div>
    </section>
  );
}
