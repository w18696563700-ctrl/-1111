import Link from 'next/link';
import { siteConfig } from '@/content/site';

type HeroContent = {
  eyebrow: string;
  title: string;
  summary: string;
  primaryCta: { label: string; href: string };
  secondaryCta: { label: string; href: string };
  proofPoints: string[];
  appPreview: {
    statusTime: string;
    title: string;
    subtitle: string;
    location: string;
    weather: string;
    weatherNote: string;
    syncLabel: string;
    actions: string[];
    channelTitle: string;
    tabs: string[];
    quickActions: string[];
    projectTitle: string;
    projectMeta: string[];
    projectCta: string;
    bottomNav: string[];
  };
};

type AppPreviewContent = HeroContent['appPreview'];

export function HeroSection({ content }: { content: HeroContent }) {
  return (
    <section className="hero-section" id="positioning">
      <div className="hero">
        <div className="hero-copy">
          <p className="eyebrow">{content.eyebrow}</p>
          <h1>{content.title}</h1>
          <p>{content.summary}</p>
          <div className="hero-actions">
            <Link className="button button-primary" href={content.primaryCta.href}>
              {content.primaryCta.label}
            </Link>
            <Link className="button button-secondary" href={content.secondaryCta.href}>
              {content.secondaryCta.label}
            </Link>
          </div>
          <ul className="proof-list" aria-label={siteConfig.labels.proofListAria}>
            {content.proofPoints.map((point) => (
              <li key={point}>{point}</li>
            ))}
          </ul>
        </div>
        <HeroPreview content={content.appPreview} />
      </div>
    </section>
  );
}

function HeroPreview({ content }: { content: AppPreviewContent }) {
  return (
    <div className="product-preview" aria-label={siteConfig.labels.previewAria}>
      <VenueVisual />
      <div className="phone-frame">
        <div className="phone-shell">
          <PhoneStatus time={content.statusTime} />
          <div className="phone-panel">
            <AppHeading content={content} />
            <WeatherCard content={content} />
            <PillList className="phone-actions" items={content.actions} />
            <div className="channel-title">{content.channelTitle}</div>
            <PillList className="phone-tabs" items={content.tabs} />
            <PillList className="phone-actions quick" items={content.quickActions} />
            <ProjectPreview content={content} />
          </div>
          <BottomNav items={content.bottomNav} />
        </div>
      </div>
    </div>
  );
}

function VenueVisual() {
  return (
    <div className="venue-visual" aria-hidden="true">
      <span />
      <span />
      <span />
      <span />
    </div>
  );
}

function PhoneStatus({ time }: { time: string }) {
  return (
    <div className="phone-status">
      <span>{time}</span>
      <span className="phone-notch" />
      <span className="phone-signal" />
    </div>
  );
}

function AppHeading({ content }: { content: AppPreviewContent }) {
  return (
    <div className="app-heading">
      <div>
        <strong>{content.title}</strong>
        <p>{content.subtitle}</p>
      </div>
      <span>{content.syncLabel}</span>
    </div>
  );
}

function WeatherCard({ content }: { content: AppPreviewContent }) {
  return (
    <div className="weather-card">
      <div>
        <small>{content.location}</small>
        <strong>{content.weather}</strong>
        <p>{content.weatherNote}</p>
      </div>
      <div className="building-lines" aria-hidden="true">
        <span />
        <span />
        <span />
      </div>
    </div>
  );
}

function PillList({ className, items }: { className: string; items: string[] }) {
  return (
    <div className={className}>
      {items.map((item) => (
        <span key={item}>{item}</span>
      ))}
    </div>
  );
}

function ProjectPreview({ content }: { content: AppPreviewContent }) {
  return (
    <article className="phone-project-card">
      <div className="project-thumb" aria-hidden="true" />
      <div>
        <strong>{content.projectTitle}</strong>
        <div className="project-meta">
          {content.projectMeta.map((item) => (
            <span key={item}>{item}</span>
          ))}
        </div>
        <small>{content.projectCta}</small>
      </div>
    </article>
  );
}

function BottomNav({ items }: { items: string[] }) {
  return (
    <div className="phone-tabbar">
      {items.map((item, index) => (
        <span className={index === 0 ? 'active' : undefined} key={item}>
          {item}
        </span>
      ))}
    </div>
  );
}
