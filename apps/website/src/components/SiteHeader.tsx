import Link from 'next/link';
import { navigation, siteConfig } from '@/content/site';

export function SiteHeader() {
  return (
    <header className="site-header">
      <Link className="brand" href="/" aria-label={`${siteConfig.name} ${siteConfig.labels.homeAria}`}>
        <span className="brand-mark">{siteConfig.brandMark}</span>
        <span>
          <strong>{siteConfig.name}</strong>
          <small>{siteConfig.alternateName}</small>
        </span>
      </Link>
      <div className="site-header-actions">
        <nav className="site-nav" aria-label={siteConfig.labels.navigationAria}>
          {navigation.map((item) => (
            <Link key={item.href} href={item.href}>
              {item.label}
            </Link>
          ))}
        </nav>
        <div className="header-buttons">
          {siteConfig.headerActions.map((action) => (
            <Link
              className={`button header-cta button-${action.variant}`}
              href={action.href}
              key={action.href}
            >
              {action.label}
            </Link>
          ))}
        </div>
      </div>
    </header>
  );
}
