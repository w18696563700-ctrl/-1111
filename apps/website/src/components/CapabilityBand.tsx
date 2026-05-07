type CapabilityBandContent = {
  eyebrow: string;
  items: Array<{ title: string; summary: string }>;
};

export function CapabilityBand({ content }: { content: CapabilityBandContent }) {
  return (
    <section className="capability-band" aria-label={content.eyebrow}>
      <div className="capability-band-inner">
        <div className="capability-copy">
          <p>{content.eyebrow}</p>
        </div>
        <div className="capability-items">
          {content.items.map((item) => (
            <article key={item.title}>
              <strong>{item.title}</strong>
              <span>{item.summary}</span>
            </article>
          ))}
        </div>
        <div className="capability-model" aria-hidden="true">
          <span />
          <span />
          <span />
        </div>
      </div>
    </section>
  );
}
