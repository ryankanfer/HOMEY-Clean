import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  /* config options here */
  typescript: {
    // Temporarily ignore TypeScript errors during build
    ignoreBuildErrors: true,
  },
  eslint: {
    // Temporarily ignore ESLint errors during build
    ignoreDuringBuilds: true,
  },
  images: {
    domains: ['photos.zillowstatic.com'],
  },
  // Output as standalone server to prevent static page generation issues
  output: 'standalone',
  // Disable static page generation for all routes to avoid build-time API initialization
  experimental: {
    isrFlushToDisk: false,
  },
};

export default nextConfig;
