'use client';

import { motion, AnimatePresence } from 'framer-motion';
import { useState } from 'react';

interface Notification {
  id: string;
  type: 'price_drop' | 'new_match' | 'tour_reminder' | 'application' | 'market_alert';
  title: string;
  message: string;
  icon: string;
  color: string;
  href?: string;
  timestamp: Date;
}

interface SmartNotificationsProps {
  notifications?: Notification[];
}

export default function SmartNotifications({
  notifications = [],
}: SmartNotificationsProps) {
  const [dismissed, setDismissed] = useState<Set<string>>(new Set());

  // Mock notifications - in production, fetch from API
  const defaultNotifications: Notification[] = [
    {
      id: '1',
      type: 'price_drop',
      title: 'Price Drop Alert',
      message: '123 Main St dropped $200/month',
      icon: '💰',
      color: 'from-green-500 to-emerald-500',
      href: '/vault',
      timestamp: new Date(Date.now() - 1000 * 60 * 30), // 30 mins ago
    },
    {
      id: '2',
      type: 'new_match',
      title: 'New Match',
      message: '95% compatibility in Williamsburg',
      icon: '✨',
      color: 'from-purple-500 to-pink-500',
      href: '/scout',
      timestamp: new Date(Date.now() - 1000 * 60 * 60 * 2), // 2 hours ago
    },
    {
      id: '3',
      type: 'tour_reminder',
      title: 'Tour Tomorrow',
      message: 'Don\'t forget your 2PM tour at 456 Oak Ave',
      icon: '📅',
      color: 'from-orange-500 to-amber-500',
      href: '/calendar',
      timestamp: new Date(Date.now() - 1000 * 60 * 60 * 24), // 1 day ago
    },
  ];

  const activeNotifications = (notifications.length > 0 ? notifications : defaultNotifications)
    .filter(n => !dismissed.has(n.id));

  if (activeNotifications.length === 0) {
    return null;
  }

  const handleDismiss = (id: string) => {
    setDismissed(prev => new Set([...prev, id]));
  };

  return (
    <motion.div
      className="px-5 mb-8"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.6, delay: 0.4 }}
    >
      <div className="max-w-4xl mx-auto">
        {/* Header */}
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-sm font-semibold text-white/40 tracking-widest uppercase">
            Attention Needed
          </h3>
          <div className="w-6 h-6 rounded-full bg-red-500 flex items-center justify-center text-white text-xs font-bold">
            {activeNotifications.length}
          </div>
        </div>

        {/* Notifications */}
        <div className="space-y-3">
          <AnimatePresence>
            {activeNotifications.map((notification, index) => (
              <motion.div
                key={notification.id}
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: 20 }}
                transition={{ delay: index * 0.1 }}
                className="glass-strong rounded-2xl p-4 border border-white/10 relative overflow-hidden group"
              >
                {/* Gradient background */}
                <div className={`absolute inset-0 bg-gradient-to-r ${notification.color} opacity-10 group-hover:opacity-20 transition-opacity`} />

                <div className="relative z-10 flex items-start gap-4">
                  {/* Icon */}
                  <div className={`w-12 h-12 rounded-xl bg-gradient-to-br ${notification.color} flex items-center justify-center text-2xl shadow-lg flex-shrink-0`}>
                    {notification.icon}
                  </div>

                  {/* Content */}
                  <div className="flex-1 min-w-0">
                    <h4 className="text-white font-semibold mb-1">
                      {notification.title}
                    </h4>
                    <p className="text-white/70 text-sm">
                      {notification.message}
                    </p>
                  </div>

                  {/* Actions */}
                  <div className="flex items-center gap-2">
                    {notification.href && (
                      <motion.a
                        href={notification.href}
                        whileHover={{ scale: 1.1 }}
                        whileTap={{ scale: 0.9 }}
                        className="w-8 h-8 rounded-lg bg-white/10 hover:bg-white/20 flex items-center justify-center text-white transition-colors"
                      >
                        →
                      </motion.a>
                    )}
                    <motion.button
                      onClick={() => handleDismiss(notification.id)}
                      whileHover={{ scale: 1.1 }}
                      whileTap={{ scale: 0.9 }}
                      className="w-8 h-8 rounded-lg bg-white/10 hover:bg-white/20 flex items-center justify-center text-white/60 hover:text-white transition-colors"
                    >
                      ×
                    </motion.button>
                  </div>
                </div>
              </motion.div>
            ))}
          </AnimatePresence>
        </div>
      </div>
    </motion.div>
  );
}
