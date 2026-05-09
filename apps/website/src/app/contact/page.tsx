import { SiteFooter } from '@/components/SiteFooter';
import { SiteHeader } from '@/components/SiteHeader';
import { contactPage, siteConfig } from '@/content/site';

export const metadata = {
  title: contactPage.metadataTitle,
  description: contactPage.metadataDescription,
};

export default function ContactPage() {
  return (
    <>
      <SiteHeader />
      <main className="page-shell">
        <section className="section legal-hero">
          <p className="eyebrow">{contactPage.eyebrow}</p>
          <h1>{contactPage.title}</h1>
          <p>{contactPage.summary}</p>
          <a className="button button-primary" href={`mailto:${siteConfig.contactEmail}`}>
            {contactPage.mailCta}
          </a>
        </section>
        <section className="section contact-grid" aria-label={contactPage.cardsAria}>
          {contactPage.cards.map((card) => (
            <article className="info-card" key={card.title}>
              <h2>{card.title}</h2>
              <p>{card.summary}</p>
            </article>
          ))}
        </section>
        <section className="section section-compact">
          <div className="section-copy">
            <p className="eyebrow">{contactPage.emailLabel}</p>
            <h2>{siteConfig.contactEmail}</h2>
            <p>{contactPage.responseNote}</p>
          </div>
        </section>
      </main>
      <SiteFooter />
    </>
  );
}
