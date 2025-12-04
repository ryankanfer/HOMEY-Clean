'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Zap, UserPlus, Trash2, Database, FileText, X } from 'lucide-react';

export default function QuickActions() {
  const [isOpen, setIsOpen] = useState(false);

  const actions = [
    {
      icon: UserPlus,
      label: 'Create Test User',
      color: 'from-blue-500 to-cyan-500',
      action: () => console.log('Create test user')
    },
    {
      icon: Trash2,
      label: 'Clear Cache',
      color: 'from-red-500 to-pink-500',
      action: () => console.log('Clear cache')
    },
    {
      icon: Database,
      label: 'Database Backup',
      color: 'from-green-500 to-emerald-500',
      action: () => console.log('Database backup')
    },
    {
      icon: FileText,
      label: 'View Logs',
      color: 'from-purple-500 to-pink-500',
      action: () => console.log('View logs')
    }
  ];

  return (
    <>
      {/* Main Button */}
      <motion.button
        onClick={() => setIsOpen(!isOpen)}
        className="fixed bottom-24 right-4 md:right-6 z-[9998] w-14 h-14 bg-gradient-to-r from-cyan-500 to-blue-500 hover:from-cyan-600 hover:to-blue-600 rounded-full shadow-2xl flex items-center justify-center transition-all"
        whileHover={{ scale: 1.1 }}
        whileTap={{ scale: 0.95 }}
      >
        <AnimatePresence mode="wait">
          {isOpen ? (
            <motion.div
              key="close"
              initial={{ rotate: -90, opacity: 0 }}
              animate={{ rotate: 0, opacity: 1 }}
              exit={{ rotate: 90, opacity: 0 }}
            >
              <X className="w-6 h-6 text-white" />
            </motion.div>
          ) : (
            <motion.div
              key="open"
              initial={{ rotate: 90, opacity: 0 }}
              animate={{ rotate: 0, opacity: 1 }}
              exit={{ rotate: -90, opacity: 0 }}
            >
              <Zap className="w-6 h-6 text-white" />
            </motion.div>
          )}
        </AnimatePresence>
      </motion.button>

      {/* Action Buttons */}
      <AnimatePresence>
        {isOpen && (
          <>
            {/* Backdrop */}
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setIsOpen(false)}
              className="fixed inset-0 z-[9997] bg-black/20 backdrop-blur-sm"
            />

            {/* Actions */}
            <div className="fixed bottom-40 right-4 md:right-6 z-[9999] flex flex-col gap-3">
              {actions.map((action, index) => {
                const Icon = action.icon;
                return (
                  <motion.button
                    key={action.label}
                    initial={{ opacity: 0, x: 20, scale: 0.8 }}
                    animate={{ opacity: 1, x: 0, scale: 1 }}
                    exit={{ opacity: 0, x: 20, scale: 0.8 }}
                    transition={{ delay: index * 0.05 }}
                    onClick={() => {
                      action.action();
                      setIsOpen(false);
                    }}
                    className="flex items-center gap-3 px-4 py-3 glass-strong rounded-xl border border-white/20 hover:border-white/40 shadow-xl transition-all group"
                  >
                    <div className={`w-10 h-10 bg-gradient-to-br ${action.color} rounded-lg flex items-center justify-center flex-shrink-0`}>
                      <Icon className="w-5 h-5 text-white" />
                    </div>
                    <span className="text-sm font-medium text-white whitespace-nowrap">{action.label}</span>
                  </motion.button>
                );
              })}
            </div>
          </>
        )}
      </AnimatePresence>
    </>
  );
}
