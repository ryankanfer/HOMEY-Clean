import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  /* config options here */
  typescript: {
    // Temporarily ignore TypeScript errors during build
    ignoreBuildErrors: true,
  },
  images: {
    domains: ['photos.zillowstatic.com'],
  },
};

export default nextConfig;
