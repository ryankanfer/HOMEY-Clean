'use client';

import { motion } from 'framer-motion';
import { useRouter } from 'next/navigation';
import { ArrowUpRight } from 'lucide-react';

interface Page {
  id: string;
  name: string;
  icon: string;
  href: string;
  gradient: string;
  description: string;
}

const PAGES: Page[] = [
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
    id: 'matchmaker',
    name: 'Matchmaker',
    icon: '💘',
    href: '/matchmaker',
    gradient: 'from-pink-500 to-rose-500',
    description: 'Play & discover'
  },
  {
    id: 'studio',
    name: 'Studio',
    icon: '✨',
    href: '/studio',
    gradient: 'from-purple-500 to-indigo-500',
    description: 'Design style'
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
    id: 'teach',
    name: 'Teach Homey',
    icon: '🎓',
    href: '/teach',
    gradient: 'from-orange-500 to-amber-500',
    description: 'Coming soon'
  },
  {
    id: 'directory',
    name: 'Directory',
    icon: '👥',
    href: '/directory',
    gradient: 'from-teal-500 to-cyan-500',
    description: 'Find your team'
  },
  {
    id: 'education',
    name: 'Education',
    icon: '📚',
    href: '/education',
    gradient: 'from-indigo-500 to-purple-500',
    description: 'Coming soon'
  }
];

export default function AllPages() {
  const router = useRouter();

  return (
    <motion.div
      className="mb-8"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.6, delay: 0.25 }}
    >
      <div className="px-5 mb-4">
        <h2 className="text-sm font-bold text-white/40 uppercase tracking-wider">Quick Access</h2>
        <p className="text-xs text-white/30 mt-1">Navigate to any page</p>
      </div>

      {/* 2-column grid with larger cards */}
      <div className="px-5">
        <div className="grid grid-cols-2 gap-3">
          {PAGES.map((page, index) => (
            <motion.button
              key={page.id}
              onClick={() => router.push(page.href)}
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ delay: index * 0.04 }}
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
              className="group relative"
            >
              <div className="relative rounded-2xl overflow-hidden border border-white/10 hover:border-white/20 transition-all bg-gradient-to-br from-slate-800/50 to-slate-900/50 backdrop-blur-sm">
                {/* Gradient overlay */}
                <div className={`absolute inset-0 bg-gradient-to-br ${page.gradient} opacity-5 group-hover:opacity-10 transition-opacity`} />

                {/* Content */}
                <div className="relative p-4">
                  <div className="flex items-start gap-3">
                    {/* Icon */}
                    <div className={`w-12 h-12 rounded-xl bg-gradient-to-br ${page.gradient} flex items-center justify-center text-2xl shadow-md group-hover:shadow-lg transition-all flex-shrink-0 group-hover:scale-110`}>
                      {page.icon}
                    </div>

                    {/* Text */}
                    <div className="flex-1 text-left min-w-0">
                      <div className="flex items-start justify-between gap-1">
                        <h3 className="text-white font-semibold text-sm group-hover:text-purple-200 transition-colors leading-tight">
                          {page.name}
                        </h3>
                        <ArrowUpRight className="w-3.5 h-3.5 text-white/30 group-hover:text-white/50 group-hover:translate-x-0.5 group-hover:-translate-y-0.5 transition-all flex-shrink-0 mt-0.5" />
                      </div>
                      <p className="text-white/50 text-xs mt-1 leading-snug">
                        {page.description}
                      </p>
                    </div>
                  </div>
                </div>
              </div>
            </motion.button>
          ))}
        </div>
      </div>
    </motion.div>
  );
}
