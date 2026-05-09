import type { MetadataRoute } from 'next';
import { siteConfig } from '@/content/site';

const routes = ['', '/privacy', '/terms', '/contact'];

export default function sitemap(): MetadataRoute.Sitemap {
  return routes.map((route) => ({
    url: `${siteConfig.url}${route}`,
    lastModified: new Date('2026-05-08T00:00:00+08:00'),
    changeFrequency: 'weekly',
    priority: route === '' ? 1 : 0.7,
  }));
}
