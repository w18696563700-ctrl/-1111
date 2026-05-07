import Link from 'next/link';

type CtaContent = {
  eyebrow: string;
  title: string;
  summary: string;
  primaryCta: { label: string; href: string };
  secondaryCta: { label: string; href: string };
};

export function CtaSection({ content }: { content: CtaContent }) {
  return (
    <section className="section cta-section" id="contact">
      <p className="eyebrow">{content.eyebrow}</p>
      <h2>{content.title}</h2>
      <p>{content.summary}</p>
      <div className="hero-actions">
        <Link className="button button-primary" href={content.primaryCta.href}>
          {content.primaryCta.label}
        </Link>
        <Link className="button button-secondary" href={content.secondaryCta.href}>
          {content.secondaryCta.label}
        </Link>
      </div>
    </section>
  );
}
