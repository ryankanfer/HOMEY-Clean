'use client';

import { motion } from 'framer-motion';
import { useRouter } from 'next/navigation';
import { AlertCircle, ArrowRight } from 'lucide-react';

interface Task {
  id: string;
  title: string;
  description: string;
  icon: string;
  priority: 'urgent' | 'pending' | 'suggestion';
  action: string;
  href: string;
}

interface PriorityDeckProps {
  tasks?: Task[];
}

const defaultTasks: Task[] = [
  {
    id: 'train_ai',
    title: 'Train the AI',
    description: 'Swipe on 10 properties to unlock recommendations',
    icon: '🎯',
    priority: 'urgent',
    action: 'Start Swiping',
    href: '/matchmaker'
  },
  {
    id: 'schedule_tour',
    title: 'Schedule Your First Tour',
    description: 'Book a viewing for your top 3 saved properties',
    icon: '📅',
    priority: 'pending',
    action: 'View Calendar',
    href: '/calendar'
  },
  {
    id: 'upload_docs',
    title: 'Upload Documents',
    description: 'Add proof of income and ID for faster applications',
    icon: '📄',
    priority: 'suggestion',
    action: 'Go to Vault',
    href: '/vault'
  },
  {
    id: 'style_quiz',
    title: 'Complete Style Quiz',
    description: 'Help us understand your design preferences',
    icon: '✨',
    priority: 'suggestion',
    action: 'Start Quiz',
    href: '/studio'
  }
];

export default function PriorityDeck({ tasks = defaultTasks }: PriorityDeckProps) {
  const router = useRouter();

  const completedCount = 0; // TODO: Hook this up to actual completion tracking
  const totalCount = tasks.length;
  const progressPercent = Math.round((completedCount / totalCount) * 100);

  const getPriorityStyle = (priority: string) => {
    switch (priority) {
      case 'urgent':
        return {
          border: 'border-red-500/50',
          glow: 'shadow-lg shadow-red-900/20',
          badge: 'bg-red-500/20 border-red-500/50 text-red-300',
          badgeText: 'Urgent'
        };
      case 'pending':
        return {
          border: 'border-yellow-500/30',
          glow: '',
          badge: 'bg-yellow-500/20 border-yellow-500/50 text-yellow-300',
          badgeText: 'Pending'
        };
      default:
        return {
          border: 'border-white/10',
          glow: '',
          badge: 'bg-white/5 border-white/20 text-white/60',
          badgeText: 'Suggested'
        };
    }
  };

  return (
    <motion.div
      className="mb-8"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.6, delay: 0.3 }}
    >
      {/* Header with Progress */}
      <div className="px-5 mb-4">
        <div className="flex items-center justify-between mb-3">
          <div>
            <h2 className="text-sm font-bold text-white/40 uppercase tracking-wider">Homey's Action Plan</h2>
            <p className="text-xs text-white/30 mt-1">Your personalized next steps</p>
          </div>
          <div className="text-right">
            <div className="text-2xl font-bold text-white">{progressPercent}%</div>
            <div className="text-xs text-white/40">Complete</div>
          </div>
        </div>

        {/* Progress Bar */}
        <div className="h-2 bg-white/5 rounded-full overflow-hidden">
          <motion.div
            className="h-full bg-gradient-to-r from-purple-500 via-pink-500 to-purple-500"
            initial={{ width: 0 }}
            animate={{ width: `${progressPercent}%` }}
            transition={{ duration: 1, delay: 0.5 }}
          />
        </div>
      </div>

      {/* Horizontal Scrolling Task Cards */}
      <style jsx>{`
        .hide-scrollbar::-webkit-scrollbar {
          display: none;
        }
        .hide-scrollbar {
          -ms-overflow-style: none;
          scrollbar-width: none;
        }
      `}</style>

      <div className="flex overflow-x-auto gap-4 pb-2 snap-x hide-scrollbar px-5">
        {tasks.map((task, index) => {
          const style = getPriorityStyle(task.priority);

          return (
            <motion.div
              key={task.id}
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: index * 0.1 }}
              className={`snap-start relative min-w-[280px] md:min-w-[320px] p-5 rounded-2xl border ${style.border} ${style.glow} bg-slate-800/50 backdrop-blur-sm group hover:border-white/30 transition-all cursor-pointer`}
              onClick={() => router.push(task.href)}
              whileHover={{ scale: 1.02, y: -4 }}
              whileTap={{ scale: 0.98 }}
            >
              {/* Priority Badge */}
              <div className={`absolute top-3 right-3 px-2 py-1 rounded-full border ${style.badge} text-xs font-medium`}>
                {style.badgeText}
              </div>

              {/* Urgent Indicator */}
              {task.priority === 'urgent' && (
                <div className="absolute -top-1 -left-1">
                  <AlertCircle className="w-5 h-5 text-red-500 animate-pulse" />
                </div>
              )}

              {/* Icon */}
              <div className="w-14 h-14 rounded-xl bg-gradient-to-br from-purple-500/20 to-pink-500/20 flex items-center justify-center text-3xl mb-4 group-hover:scale-110 transition-transform">
                {task.icon}
              </div>

              {/* Content */}
              <h3 className="text-white font-semibold text-lg mb-2">
                {task.title}
              </h3>
              <p className="text-white/60 text-sm mb-4 leading-relaxed">
                {task.description}
              </p>

              {/* Action Button */}
              <div className="flex items-center justify-between pt-3 border-t border-white/10">
                <span className="text-purple-400 font-medium text-sm group-hover:text-purple-300 transition-colors">
                  {task.action}
                </span>
                <ArrowRight className="w-4 h-4 text-purple-400 group-hover:translate-x-1 transition-transform" />
              </div>
            </motion.div>
          );
        })}
      </div>
    </motion.div>
  );
}
