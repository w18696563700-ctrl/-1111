import Link from 'next/link';
import { footer, siteConfig } from '@/content/site';

export function SiteFooter() {
  return (
    <footer className="site-footer">
      <div>
        <strong>{footer.title}</strong>
        <p>{footer.summary}</p>
      </div>
      <nav aria-label={siteConfig.labels.footerAria}>
        {footer.legal.map((item) => (
          <Link key={item.href} href={item.href}>
            {item.label}
          </Link>
        ))}
      </nav>
    </footer>
  );
}
