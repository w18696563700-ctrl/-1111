import { siteConfig } from '@/content/site';

type TrustStripContent = {
  items: Array<{ icon: string; title: string; summary: string }>;
};

export function TrustStrip({ content }: { content: TrustStripContent }) {
  return (
    <section className="trust-strip" aria-label={siteConfig.labels.trustStripAria}>
      {content.items.map((item) => (
        <article className="trust-item" key={item.title}>
          <span className={`trust-icon trust-icon-${item.icon}`} aria-hidden="true" />
          <div>
            <h2>{item.title}</h2>
            <p>{item.summary}</p>
          </div>
        </article>
      ))}
    </section>
  );
}
