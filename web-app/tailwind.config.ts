import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        background: "var(--background)",
        foreground: "var(--foreground)",
        primary: {
          DEFAULT: "#9333ea",
          hover: "#a855f7",
        },
        glass: {
          light: "rgba(255, 255, 255, 0.1)",
          dark: "rgba(0, 0, 0, 0.1)",
        },
      },
      backdropBlur: {
        xs: "2px",
      },
      fontFamily: {
        sans: [
          '-apple-system',
          'BlinkMacSystemFont',
          '"SF Pro Display"',
          '"SF Pro Text"',
          'Inter',
          'system-ui',
          'sans-serif',
        ],
        display: [
          '"SF Pro Display"',
          '-apple-system',
          'BlinkMacSystemFont',
          'Inter',
          'system-ui',
          'sans-serif',
        ],
        body: [
          '"SF Pro Text"',
          '-apple-system',
          'BlinkMacSystemFont',
          'Inter',
          'system-ui',
          'sans-serif',
        ],
        josefin: ['"Josefin Sans"', 'sans-serif'],
      },
      letterSpacing: {
        tightest: '-0.04em',
        tight: '-0.02em',
        snug: '-0.01em',
      },
      animation: {
        'spin-slow': 'spin 40s linear infinite',
        'float-1': 'float1 30s ease-in-out infinite',
        'float-2': 'float2 35s ease-in-out infinite 5s',
        'float-3': 'float3 32s ease-in-out infinite 10s',
        'fade-in': 'fadeIn 1s ease-out',
        'slide-up': 'slideUp 0.6s ease-out',
        'scale-in': 'scaleIn 0.6s ease-out backwards',
        'pulse-subtle': 'pulseSubtle 2s ease-in-out infinite',
      },
      keyframes: {
        float1: {
          '0%, 100%': { transform: 'translate(0, 0) scale(1)' },
          '33%': { transform: 'translate(30px, -30px) scale(1.1)' },
          '66%': { transform: 'translate(-30px, 30px) scale(0.9)' },
        },
        float2: {
          '0%, 100%': { transform: 'translate(0, 0) scale(1)' },
          '33%': { transform: 'translate(-40px, -20px) scale(1.15)' },
          '66%': { transform: 'translate(40px, 20px) scale(0.85)' },
        },
        float3: {
          '0%, 100%': { transform: 'translate(0, 0) scale(1)' },
          '33%': { transform: 'translate(20px, -40px) scale(1.05)' },
          '66%': { transform: 'translate(-20px, 40px) scale(0.95)' },
        },
        fadeIn: {
          from: { opacity: '0', transform: 'translateY(-10px)' },
          to: { opacity: '1', transform: 'translateY(0)' },
        },
        slideUp: {
          from: { opacity: '0', transform: 'translateY(20px) scale(0.98)' },
          to: { opacity: '1', transform: 'translateY(0) scale(1)' },
        },
        scaleIn: {
          from: { opacity: '0', transform: 'scale(0.9)' },
          to: { opacity: '1', transform: 'scale(1)' },
        },
        pulseSubtle: {
          '0%, 100%': { transform: 'translateX(-50%) scale(1)' },
          '50%': { transform: 'translateX(-50%) scale(1.02)' },
        },
      },
    },
  },
  plugins: [],
};

export default config;
