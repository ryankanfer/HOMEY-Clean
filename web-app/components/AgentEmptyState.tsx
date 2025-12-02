'use client';

import { motion } from 'framer-motion';
import { Users, Mail } from 'lucide-react';

interface AgentEmptyStateProps {
  onConnectAgent?: () => void;
  onInviteAgent?: () => void;
}

export default function AgentEmptyState({ onConnectAgent, onInviteAgent }: AgentEmptyStateProps) {
  return (
    <motion.div
      className="px-5 mb-8"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.6, delay: 0.2 }}
    >
      <div className="glass-strong rounded-2xl border border-white/10 p-5 sm:p-6">
        <div className="text-center">
          {/* Icon */}
          <div className="w-12 h-12 sm:w-14 sm:h-14 mx-auto mb-3 sm:mb-4 rounded-full bg-gradient-to-br from-purple-500/20 to-pink-500/20 flex items-center justify-center">
            <Users className="w-6 h-6 sm:w-7 sm:h-7 text-purple-400" />
          </div>

          {/* Title */}
          <h3 className="text-lg sm:text-xl font-bold text-white mb-2">
            Connect with an Agent
          </h3>

          {/* Description */}
          <p className="text-white/60 text-sm mb-5 max-w-md mx-auto leading-snug">
            Get expert help finding your perfect home
          </p>

          {/* Action Buttons */}
          <div className="flex flex-col sm:flex-row gap-3 justify-center">
            {/* Find an Agent */}
            <button
              onClick={onConnectAgent}
              className="flex items-center justify-center gap-2 px-5 py-3 bg-gradient-to-r from-purple-500 to-pink-500 hover:opacity-90 text-white font-semibold rounded-xl transition-all text-sm"
            >
              <Users className="w-4 h-4" />
              Find an Agent
            </button>

            {/* Invite Your Agent */}
            <button
              onClick={onInviteAgent}
              className="flex items-center justify-center gap-2 px-5 py-3 bg-white/10 hover:bg-white/20 text-white font-semibold rounded-xl transition-colors border border-white/20 text-sm"
            >
              <Mail className="w-4 h-4" />
              Invite Agent
            </button>
          </div>

          {/* Helper Text */}
          <p className="text-white/40 text-xs mt-4">
            Already working with someone? Invite them
          </p>
        </div>
      </div>
    </motion.div>
  );
}
