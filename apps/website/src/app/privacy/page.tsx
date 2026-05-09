import { SiteFooter } from '@/components/SiteFooter';
import { SiteHeader } from '@/components/SiteHeader';
import { legalPages, siteConfig } from '@/content/site';

const page = legalPages.privacy;

export const metadata = {
  title: page.metadataTitle,
  description: page.metadataDescription,
};

export default function PrivacyPage() {
  return (
    <>
      <SiteHeader />
      <main className="page-shell">
        <section className="section legal-hero">
          <p className="eyebrow">{page.eyebrow}</p>
          <h1>{page.title}</h1>
          <p>{page.summary}</p>
          <p className="source-note">{siteConfig.labels.sourcePrefix}：{page.source}</p>
        </section>
        <section className="section legal-list" aria-label={page.itemsAria}>
          {page.items.map((item) => (
            <article className="info-card" key={item}>
              <p>{item}</p>
            </article>
          ))}
        </section>
      </main>
      <SiteFooter />
    </>
  );
}
