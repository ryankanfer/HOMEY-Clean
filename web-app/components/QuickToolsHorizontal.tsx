'use client';

import { motion } from 'framer-motion';
import { useRouter } from 'next/navigation';

interface QuickTool {
  id: string;
  icon: string;
  label: string;
  description: string;
  href?: string;
  action?: () => void;
  gradient: string;
}

interface QuickToolsHorizontalProps {
  onStyleTunerOpen?: () => void;
}

export default function QuickToolsHorizontal({ onStyleTunerOpen }: QuickToolsHorizontalProps) {
  const router = useRouter();

  const tools: QuickTool[] = [
    {
      id: 'train_ai',
      icon: '🎨',
      label: 'Train AI',
      description: 'Swipe on designs',
      action: onStyleTunerOpen,
      gradient: 'from-purple-500 to-pink-500'
    },
    {
      id: 'search',
      icon: '🔍',
      label: 'Search',
      description: 'Find properties',
      href: '/search',
      gradient: 'from-blue-500 to-cyan-500'
    },
    {
      id: 'tours',
      icon: '📅',
      label: 'Tours',
      description: 'Schedule viewings',
      href: '/calendar',
      gradient: 'from-green-500 to-emerald-500'
    },
    {
      id: 'docs',
      icon: '📄',
      label: 'Docs',
      description: 'Upload files',
      href: '/vault',
      gradient: 'from-orange-500 to-amber-500'
    },
    {
      id: 'finance',
      icon: '💰',
      label: 'Finance',
      description: 'Budget tools',
      href: '/settings',
      gradient: 'from-yellow-500 to-orange-500'
    },
    {
      id: 'legal',
      icon: '⚖️',
      label: 'Legal',
      description: 'Lease help',
      href: '/teach',
      gradient: 'from-indigo-500 to-purple-500'
    },
    {
      id: 'movers',
      icon: '🚚',
      label: 'Movers',
      description: 'Find help',
      href: '/directory',
      gradient: 'from-red-500 to-pink-500'
    }
  ];

  const handleToolClick = (tool: QuickTool) => {
    if (tool.action) {
      tool.action();
    } else if (tool.href) {
      router.push(tool.href);
    }
  };

  return (
    <motion.div
      className="mb-8"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.6, delay: 0.4 }}
    >
      <div className="px-5 mb-4">
        <h2 className="text-sm font-bold text-white/40 uppercase tracking-wider">Quick Tools</h2>
        <p className="text-xs text-white/30 mt-1">Everything you need in one swipe</p>
      </div>

      {/* Horizontal Scroll */}
      <style jsx>{`
        .hide-scrollbar::-webkit-scrollbar {
          display: none;
        }
        .hide-scrollbar {
          -ms-overflow-style: none;
          scrollbar-width: none;
        }
      `}</style>

      <div className="flex overflow-x-auto gap-3 pb-2 snap-x hide-scrollbar px-5">
        {tools.map((tool, index) => (
          <motion.button
            key={tool.id}
            onClick={() => handleToolClick(tool)}
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: index * 0.05 }}
            whileHover={{ scale: 1.05, y: -4 }}
            whileTap={{ scale: 0.95 }}
            className="snap-start relative min-w-[140px] group"
          >
            <div className="glass-strong rounded-2xl p-4 border border-white/10 hover:border-white/20 transition-all">
              {/* Icon with Gradient */}
              <div className={`w-14 h-14 mx-auto mb-3 rounded-xl bg-gradient-to-br ${tool.gradient} flex items-center justify-center text-2xl shadow-lg group-hover:shadow-xl transition-shadow`}>
                {tool.icon}
              </div>

              {/* Label */}
              <h3 className="text-white font-semibold text-sm mb-1">
                {tool.label}
              </h3>
              <p className="text-white/50 text-xs">
                {tool.description}
              </p>
            </div>
          </motion.button>
        ))}
      </div>
    </motion.div>
  );
}
