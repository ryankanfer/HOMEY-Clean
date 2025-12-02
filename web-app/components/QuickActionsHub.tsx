'use client';

import { motion } from 'framer-motion';
import { useRouter } from 'next/navigation';

interface QuickAction {
  id: string;
  icon: string;
  label: string;
  href: string;
  color: string;
  badge?: number;
}

interface QuickActionsHubProps {
  savedCount?: number;
  toursCount?: number;
  newMatchesCount?: number;
}

export default function QuickActionsHub({
  savedCount = 0,
  toursCount = 0,
  newMatchesCount = 0,
}: QuickActionsHubProps) {
  const router = useRouter();

  const actions: QuickAction[] = [
    {
      id: 'search',
      icon: '🔍',
      label: 'Search',
      href: '/search',
      color: 'from-blue-500 to-cyan-500',
      badge: newMatchesCount,
    },
    {
      id: 'swipe',
      icon: '💫',
      label: 'Swipe',
      href: '/matchmaker',
      color: 'from-purple-500 to-pink-500',
    },
    {
      id: 'saved',
      icon: '💾',
      label: 'Saved',
      href: '/vault',
      color: 'from-pink-500 to-rose-500',
      badge: savedCount,
    },
    {
      id: 'tours',
      icon: '📅',
      label: 'Tours',
      href: '/calendar',
      color: 'from-orange-500 to-amber-500',
      badge: toursCount,
    },
    {
      id: 'teach',
      icon: '🎓',
      label: 'Learn',
      href: '/teach',
      color: 'from-teal-500 to-emerald-500',
    },
    {
      id: 'settings',
      icon: '⚙️',
      label: 'Settings',
      href: '/settings',
      color: 'from-gray-500 to-slate-500',
    },
  ];

  const container = {
    hidden: { opacity: 0 },
    show: {
      opacity: 1,
      transition: {
        staggerChildren: 0.05,
      },
    },
  };

  const item = {
    hidden: { opacity: 0, y: 20 },
    show: { opacity: 1, y: 0 },
  };

  return (
    <motion.div
      className="px-5 mb-8"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.6, delay: 0.1 }}
    >
      <div className="max-w-4xl mx-auto">
        {/* Title */}
        <h3 className="text-sm font-semibold text-white/40 tracking-widest uppercase mb-4 text-center">
          Quick Actions
        </h3>

        {/* Actions Grid */}
        <motion.div
          className="grid grid-cols-3 md:grid-cols-6 gap-3 md:gap-4"
          variants={container}
          initial="hidden"
          animate="show"
        >
          {actions.map((action) => (
            <motion.button
              key={action.id}
              variants={item}
              whileHover={{ scale: 1.05, y: -4 }}
              whileTap={{ scale: 0.95 }}
              onClick={() => router.push(action.href)}
              className="relative group"
            >
              {/* Action Card */}
              <div className="glass-strong rounded-2xl p-4 md:p-5 border border-white/10 hover:border-white/20 transition-all">
                {/* Icon with gradient background */}
                <div className={`w-12 h-12 md:w-14 md:h-14 mx-auto mb-2 md:mb-3 rounded-xl bg-gradient-to-br ${action.color} flex items-center justify-center text-2xl md:text-3xl shadow-lg group-hover:shadow-xl transition-shadow`}>
                  {action.icon}
                </div>

                {/* Label */}
                <p className="text-white text-xs md:text-sm font-medium text-center">
                  {action.label}
                </p>

                {/* Badge */}
                {action.badge !== undefined && action.badge > 0 && (
                  <motion.div
                    initial={{ scale: 0 }}
                    animate={{ scale: 1 }}
                    className="absolute -top-1 -right-1 w-5 h-5 md:w-6 md:h-6 bg-red-500 rounded-full flex items-center justify-center text-white text-xs font-bold shadow-lg"
                  >
                    {action.badge > 99 ? '99+' : action.badge}
                  </motion.div>
                )}
              </div>
            </motion.button>
          ))}
        </motion.div>
      </div>
    </motion.div>
  );
}
