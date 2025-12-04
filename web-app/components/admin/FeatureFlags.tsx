'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Flag, ChevronDown, ChevronUp, AlertCircle } from 'lucide-react';

interface FeatureFlag {
  id: string;
  name: string;
  description: string;
  enabled: boolean;
  category: 'feature' | 'beta' | 'maintenance';
}

export default function FeatureFlags() {
  const [isExpanded, setIsExpanded] = useState(true);
  const [flags, setFlags] = useState<FeatureFlag[]>([
    {
      id: 'agent_messaging',
      name: 'Agent Messaging',
      description: 'Enable direct messaging between clients and agents',
      enabled: true,
      category: 'feature',
    },
    {
      id: 'ai_recommendations',
      name: 'AI Recommendations',
      description: 'Show AI-powered property recommendations',
      enabled: true,
      category: 'feature',
    },
    {
      id: 'style_studio',
      name: 'Style Studio (Beta)',
      description: 'Visual preference learning tool',
      enabled: false,
      category: 'beta',
    },
    {
      id: 'document_vault',
      name: 'Document Vault',
      description: 'Secure document storage for users',
      enabled: true,
      category: 'feature',
    },
    {
      id: 'property_comparison',
      name: 'Property Comparison',
      description: 'Side-by-side property comparison tool',
      enabled: true,
      category: 'feature',
    },
    {
      id: 'maintenance_mode',
      name: 'Maintenance Mode',
      description: 'Show maintenance page to all users',
      enabled: false,
      category: 'maintenance',
    },
  ]);

  useEffect(() => {
    // Load flags from localStorage
    const saved = localStorage.getItem('homey_feature_flags');
    if (saved) {
      setFlags(JSON.parse(saved));
    }
  }, []);

  const toggleFlag = (id: string) => {
    const updated = flags.map(flag =>
      flag.id === id ? { ...flag, enabled: !flag.enabled } : flag
    );
    setFlags(updated);
    localStorage.setItem('homey_feature_flags', JSON.stringify(updated));
  };

  const getCategoryColor = (category: string) => {
    switch (category) {
      case 'beta': return 'from-purple-500 to-pink-500';
      case 'maintenance': return 'from-red-500 to-orange-500';
      default: return 'from-blue-500 to-cyan-500';
    }
  };

  const getCategoryBadge = (category: string) => {
    switch (category) {
      case 'beta': return 'bg-purple-500/20 text-purple-400 border-purple-500/30';
      case 'maintenance': return 'bg-red-500/20 text-red-400 border-red-500/30';
      default: return 'bg-blue-500/20 text-blue-400 border-blue-500/30';
    }
  };

  const enabledCount = flags.filter(f => f.enabled).length;

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="glass-strong rounded-2xl border border-white/10 overflow-hidden"
    >
      {/* Header */}
      <button
        onClick={() => setIsExpanded(!isExpanded)}
        className="w-full px-4 md:px-6 py-4 flex items-center justify-between hover:bg-white/5 transition-colors touch-manipulation"
      >
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-gradient-to-br from-yellow-500 to-orange-500 rounded-lg flex items-center justify-center">
            <Flag className="w-6 h-6 text-white" />
          </div>
          <div className="text-left">
            <h2 className="text-base md:text-lg font-semibold text-white">Feature Flags</h2>
            <p className="text-xs text-white/60">{enabledCount} of {flags.length} enabled</p>
          </div>
        </div>
        {isExpanded ? (
          <ChevronUp className="w-5 h-5 text-white/60" />
        ) : (
          <ChevronDown className="w-5 h-5 text-white/60" />
        )}
      </button>

      <AnimatePresence>
        {isExpanded && (
          <motion.div
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: 'auto', opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            className="px-4 md:px-6 pb-6"
          >
            {/* Warning for maintenance mode */}
            {flags.find(f => f.id === 'maintenance_mode' && f.enabled) && (
              <div className="mb-4 p-3 bg-red-500/10 border border-red-500/30 rounded-lg flex items-start gap-2">
                <AlertCircle className="w-5 h-5 text-red-400 flex-shrink-0 mt-0.5" />
                <div className="flex-1">
                  <p className="text-sm font-semibold text-red-400">Maintenance Mode Active</p>
                  <p className="text-xs text-red-300/80 mt-0.5">Users will see a maintenance page</p>
                </div>
              </div>
            )}

            {/* Flags List */}
            <div className="space-y-3">
              {flags.map((flag) => (
                <motion.div
                  key={flag.id}
                  initial={{ opacity: 0, x: -20 }}
                  animate={{ opacity: 1, x: 0 }}
                  className="p-4 bg-white/5 rounded-lg border border-white/10"
                >
                  <div className="flex items-start justify-between gap-3">
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2 mb-1">
                        <h3 className="text-sm font-semibold text-white">{flag.name}</h3>
                        <span className={`px-2 py-0.5 rounded-full text-[10px] font-medium border ${getCategoryBadge(flag.category)}`}>
                          {flag.category}
                        </span>
                      </div>
                      <p className="text-xs text-white/60">{flag.description}</p>
                    </div>

                    {/* Toggle Switch */}
                    <button
                      onClick={() => toggleFlag(flag.id)}
                      className={`relative w-14 h-7 rounded-full transition-all touch-manipulation flex-shrink-0 ${
                        flag.enabled
                          ? 'bg-gradient-to-r ' + getCategoryColor(flag.category)
                          : 'bg-white/10'
                      }`}
                    >
                      <motion.div
                        className="absolute top-1 left-1 w-5 h-5 bg-white rounded-full shadow-lg"
                        animate={{
                          x: flag.enabled ? 28 : 0,
                        }}
                        transition={{ type: 'spring', stiffness: 500, damping: 30 }}
                      />
                    </button>
                  </div>
                </motion.div>
              ))}
            </div>

            {/* Info */}
            <div className="mt-4 text-center text-xs text-white/40">
              Changes save automatically to localStorage
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </motion.div>
  );
}
