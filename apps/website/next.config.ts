import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
  reactStrictMode: true,
  assetPrefix: process.env.NODE_ENV === 'production' ? '/website-assets' : undefined,
};

export default nextConfig;
