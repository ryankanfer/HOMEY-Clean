'use client';

import { useState } from 'react';
import { motion } from 'framer-motion';
import { useRouter } from 'next/navigation';
import { ArrowUpRight, ArrowRight, ChevronLeft, ChevronRight } from 'lucide-react';

interface Page {
  id: string;
  name: string;
  icon: string;
  href: string;
  gradient: string;
  description: string;
  comingSoon?: boolean;
}

const APPS: Page[] = [
  {
    id: 'search',
    name: 'Search',
    icon: '🔍',
    href: '/search',
    gradient: 'from-blue-500 to-cyan-500',
    description: 'Find your home'
  },
  {
    id: 'vault',
    name: 'Vault',
    icon: '📁',
    href: '/vault',
    gradient: 'from-amber-500 to-orange-500',
    description: 'Your documents'
  },
  {
    id: 'teach',
    name: 'Teach HOMEY',
    icon: '🎓',
    href: '/teach',
    gradient: 'from-orange-500 to-amber-500',
    description: 'Explore & learn'
  },
  {
    id: 'calendar',
    name: 'Calendar',
    icon: '📅',
    href: '/calendar',
    gradient: 'from-green-500 to-emerald-500',
    description: 'Schedule tours'
  },
  {
    id: 'pulse',
    name: 'Pulse',
    icon: '🫧',
    href: '/pulse',
    gradient: 'from-cyan-500 to-blue-500',
    description: 'Community vibes'
  },
  {
    id: 'profile',
    name: 'Profile',
    icon: '👤',
    href: '/settings',
    gradient: 'from-purple-500 to-pink-500',
    description: 'Your account'
  },
];

const COMING_SOON: Page[] = [
  {
    id: 'studio',
    name: 'Studio',
    icon: '✨',
    href: '/studio',
    gradient: 'from-purple-500 to-indigo-500',
    description: 'AI-powered staging and visualization tools to see homes transformed before you move in',
    comingSoon: true
  },
  {
    id: 'directory',
    name: 'Directory',
    icon: '👥',
    href: '/directory',
    gradient: 'from-teal-500 to-cyan-500',
    description: 'Connect with trusted movers, lenders, lawyers, and service providers all in one place',
    comingSoon: true
  },
  {
    id: 'education',
    name: 'Education',
    icon: '📚',
    href: '/education',
    gradient: 'from-indigo-500 to-purple-500',
    description: 'Interactive guides and resources to master every step of your housing journey',
    comingSoon: true
  }
];

export default function AllPages() {
  const router = useRouter();
  const [currentIndex, setCurrentIndex] = useState(0);

  const nextSlide = () => {
    setCurrentIndex((prev) => (prev + 1) % COMING_SOON.length);
  };

  const prevSlide = () => {
    setCurrentIndex((prev) => (prev - 1 + COMING_SOON.length) % COMING_SOON.length);
  };

  return (
    <div className="mb-6 space-y-6">

      {/* Browse Apps Section - iPhone-Minimal Grid */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6, delay: 0.25 }}
        className="px-5"
      >
        <div className="mb-4">
          <h2 className="text-[10px] font-bold text-white/30 uppercase tracking-[0.15em]">Quick Access</h2>
        </div>

        {/* Refined Grid - Bigger icons, More Spaced */}
        <div className="grid grid-cols-3 gap-5">
          {APPS.map((page, index) => (
            <motion.button
              key={page.id}
              onClick={() => router.push(page.href)}
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ delay: index * 0.03 }}
              whileTap={{ scale: 0.92 }}
              className="group relative aspect-square"
            >
              {/* Premium glass card */}
              <div className="absolute inset-0 rounded-[18px] bg-white/[0.03] border border-white/[0.05] backdrop-blur-sm group-active:bg-white/[0.05] transition-all" />

              {/* Gradient accent */}
              <div className={`absolute inset-0 rounded-[18px] bg-gradient-to-br ${page.gradient} opacity-0 group-active:opacity-10 transition-opacity`} />

              {/* Content */}
              <div className="relative h-full flex flex-col items-center justify-center gap-2 p-3">
                {/* Icon with subtle gradient bg - Bigger */}
                <div className={`w-14 h-14 rounded-[14px] bg-gradient-to-br ${page.gradient} flex items-center justify-center text-2xl shadow-sm`}>
                  {page.icon}
                </div>
                {/* Label - Tighter tracking */}
                <span className="text-white/70 text-[10px] font-semibold tracking-tight leading-tight text-center">
                  {page.name}
                </span>
              </div>
            </motion.button>
          ))}
        </div>
      </motion.div>

      {/* Coming Soon Section - Compact & Elegant */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6, delay: 0.35 }}
        className="px-5"
      >
        <div className="mb-4 flex items-center justify-between">
          <div>
            <h2 className="text-[10px] font-bold text-white/30 uppercase tracking-[0.15em]">In Development</h2>
          </div>
          {/* Minimal Page Indicators */}
          <div className="flex items-center gap-1.5">
            {COMING_SOON.map((_, index) => (
              <button
                key={index}
                onClick={() => setCurrentIndex(index)}
                className={`transition-all ${
                  index === currentIndex
                    ? 'w-4 h-1 bg-white/40'
                    : 'w-1 h-1 bg-white/15'
                } rounded-full`}
              />
            ))}
          </div>
        </div>

        {/* Compact Feature Card */}
        <motion.button
          key={COMING_SOON[currentIndex].id}
          onClick={() => router.push(COMING_SOON[currentIndex].href)}
          initial={{ opacity: 0, x: 20 }}
          animate={{ opacity: 1, x: 0 }}
          whileTap={{ scale: 0.97 }}
          className="group relative w-full"
        >
          <div className="relative rounded-[20px] overflow-hidden border border-white/[0.06] bg-white/[0.02] backdrop-blur-sm">
            {/* Subtle gradient accent */}
            <div className={`absolute inset-0 bg-gradient-to-br ${COMING_SOON[currentIndex].gradient} opacity-[0.06] group-active:opacity-[0.12] transition-opacity`} />

            {/* Content - More compact */}
            <div className="relative p-5 flex items-center gap-4">
              {/* Icon - Smaller, left-aligned */}
              <div className={`w-14 h-14 rounded-[16px] bg-gradient-to-br ${COMING_SOON[currentIndex].gradient} opacity-90 flex items-center justify-center text-3xl shadow-md flex-shrink-0`}>
                {COMING_SOON[currentIndex].icon}
              </div>

              {/* Text Content */}
              <div className="flex-1 text-left">
                {/* Title & Badge on same line */}
                <div className="flex items-center gap-2 mb-1.5">
                  <h3 className="text-white font-bold text-base tracking-tight">
                    {COMING_SOON[currentIndex].name}
                  </h3>
                  <div className="px-2 py-0.5 bg-white/[0.08] rounded-md">
                    <span className="text-white/40 text-[9px] font-bold tracking-wider">SOON</span>
                  </div>
                </div>

                {/* Description - Two lines max */}
                <p className="text-white/50 text-[11px] leading-relaxed line-clamp-2">
                  {COMING_SOON[currentIndex].description}
                </p>
              </div>

              {/* Arrow indicator */}
              <div className="text-white/20 group-active:text-white/40 transition-colors">
                <ArrowRight className="w-4 h-4" />
              </div>
            </div>
          </div>
        </motion.button>

        {/* Navigation Arrows - Minimal */}
        <div className="flex items-center justify-center gap-6 mt-3">
          <button
            onClick={prevSlide}
            className="w-8 h-8 rounded-full bg-white/[0.04] border border-white/[0.06] flex items-center justify-center active:bg-white/[0.08] transition-all"
          >
            <ChevronLeft className="w-4 h-4 text-white/40" />
          </button>
          <button
            onClick={nextSlide}
            className="w-8 h-8 rounded-full bg-white/[0.04] border border-white/[0.06] flex items-center justify-center active:bg-white/[0.08] transition-all"
          >
            <ChevronRight className="w-4 h-4 text-white/40" />
          </button>
        </div>
      </motion.div>
    </div>
  );
}

// Add scrollbar-hide styles
if (typeof document !== 'undefined') {
  const style = document.createElement('style');
  style.textContent = `
    .scrollbar-hide::-webkit-scrollbar { display: none; }
    .scrollbar-hide { -ms-overflow-style: none; scrollbar-width: none; }
  `;
  if (!document.head.querySelector('[data-scrollbar-hide]')) {
    style.setAttribute('data-scrollbar-hide', '');
    document.head.appendChild(style);
  }
}
