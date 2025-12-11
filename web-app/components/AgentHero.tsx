'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { ChevronDown, ChevronUp, Phone, MessageCircle, ArrowRight } from 'lucide-react';
import { agentDb } from '@/lib/supabase';
import { getAvatarUrl } from '@/lib/avatarGenerator';
import { useRouter } from 'next/navigation';

interface VoiceNote {
  duration: string;
  transcript: string;
  timestamp: string;
}

interface AgentHeroProps {
  agentName?: string;
  agentTitle?: string;
  agentStatus?: 'online' | 'offline' | 'away';
  agentAvatar?: string | null;
  agentPhone?: string;
  agentEmail?: string;
  voiceNote?: VoiceNote;
  onMessageClick?: () => void;
  connectionId?: string;
  userId?: string;
  hasSwipeData?: boolean;
  savedCount?: number;
}

export default function AgentHero({
  agentName = 'Sarah Chen',
  agentTitle = 'Your Partner Agent',
  agentStatus = 'online',
  agentAvatar,
  agentPhone,
  agentEmail,
  voiceNote = {
    duration: '0:42',
    transcript: "Hey! I found 3 new properties that match your style perfectly. The SoHo loft we discussed is still available, but there's been some interest. Let me know if you want to schedule a viewing this week. Also, I noticed you've been swiping more on industrial-style spaces—should we adjust your search filters?",
    timestamp: '2 hours ago'
  },
  onMessageClick,
  connectionId,
  userId,
  hasSwipeData = false,
  savedCount = 0
}: AgentHeroProps) {
  const router = useRouter();
  const [isExpanded, setIsExpanded] = useState(false); // Start collapsed
  const [showTranscript, setShowTranscript] = useState(false);
  const [isPlaying, setIsPlaying] = useState(false);
  const [hasUnreadMessage, setHasUnreadMessage] = useState(false);
  const [unreadCount, setUnreadCount] = useState(0);

  // Smart Next Step Logic
  const getNextStep = () => {
    if (!hasSwipeData) {
      return {
        icon: '🎯',
        title: 'Train HOMEY\'s AI',
        description: 'Swipe on 10 properties to unlock personalized matches',
        action: 'Start Swiping',
        href: '/teach',
        gradient: 'from-blue-500 to-cyan-500'
      };
    } else if (savedCount === 0) {
      return {
        icon: '❤️',
        title: 'Save Your First Home',
        description: 'Build your shortlist by saving properties you love',
        action: 'Browse Properties',
        href: '/search',
        gradient: 'from-pink-500 to-rose-500'
      };
    } else if (savedCount < 3) {
      return {
        icon: '🏠',
        title: 'Build Your Shortlist',
        description: `You have ${savedCount} saved. Add ${3 - savedCount} more to compare`,
        action: 'Keep Exploring',
        href: '/search',
        gradient: 'from-purple-500 to-pink-500'
      };
    } else {
      return {
        icon: '📅',
        title: 'Ready for Tours?',
        description: `You have ${savedCount} saved homes ready to view`,
        action: 'View Saved',
        href: '/saved',
        gradient: 'from-green-500 to-emerald-500'
      };
    }
  };

  const nextStep = getNextStep();

  // Fetch unread message count
  useEffect(() => {
    async function fetchUnreadCount() {
      if (!connectionId || !userId) return;

      try {
        const { count } = await agentDb.getUnreadMessageCount(connectionId, userId);
        setUnreadCount(count);
        setHasUnreadMessage(count > 0);
      } catch (error) {
        console.error('Error fetching unread count:', error);
      }
    }

    fetchUnreadCount();

    // Poll for new messages every 10 seconds
    const interval = setInterval(fetchUnreadCount, 10000);
    return () => clearInterval(interval);
  }, [connectionId, userId]);

  const statusConfig = {
    online: { color: 'bg-green-500', text: 'Online Now', pulse: true },
    away: { color: 'bg-yellow-500', text: 'Away', pulse: false },
    offline: { color: 'bg-gray-500', text: 'Offline', pulse: false }
  };

  const status = statusConfig[agentStatus];

  // Generate initials from agent name
  const getInitials = (name: string) => {
    const parts = name.split(' ');
    if (parts.length >= 2) {
      return `${parts[0][0]}${parts[parts.length - 1][0]}`.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  };

  const initials = getInitials(agentName);

  // Get avatar with AI fallback
  const displayAvatar = userId ? getAvatarUrl(agentAvatar, userId, agentName) : agentAvatar;

  return (
    <motion.div
      className="px-5 mb-8"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.6, delay: 0.2 }}
    >
      <div className="glass-strong rounded-t-3xl border border-white/10 border-b-0 overflow-hidden">
        {/* Agent Header - Always Visible */}
        <button
          onClick={() => {
            setIsExpanded(!isExpanded);
            if (!isExpanded) {
              // Mark as read when expanding
              setHasUnreadMessage(false);
            }
          }}
          className="w-full p-5 flex items-center justify-between hover:bg-white/5 transition-colors"
        >
          <div className="flex items-center gap-4">
            {/* Agent Avatar */}
            <div className="relative">
              {displayAvatar ? (
                <img
                  src={displayAvatar}
                  alt={agentName}
                  className="w-14 h-14 rounded-full object-cover"
                />
              ) : (
                <div className="w-14 h-14 rounded-full bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center text-white text-xl font-bold">
                  {initials}
                </div>
              )}
              {/* Notification Badge - Blinking when unread */}
              {hasUnreadMessage && !isExpanded && (
                <motion.div
                  className="absolute -top-1 -right-1 w-5 h-5 bg-red-500 rounded-full border-2 border-slate-900 flex items-center justify-center"
                  animate={{
                    scale: [1, 1.2, 1],
                    opacity: [1, 0.8, 1],
                  }}
                  transition={{
                    duration: 1.5,
                    repeat: Infinity,
                    ease: "easeInOut"
                  }}
                >
                  <div className="w-2.5 h-2.5 bg-white rounded-full animate-pulse" />
                </motion.div>
              )}
            </div>

            {/* Agent Info */}
            <div className="text-left">
              <h3 className="text-white font-semibold text-lg">{agentName}</h3>
              <p className="text-white/60 text-sm">{agentTitle}</p>
            </div>
          </div>

          {/* Expand/Collapse Icon */}
          <motion.div
            animate={{ rotate: isExpanded ? 180 : 0 }}
            transition={{ duration: 0.3 }}
          >
            <ChevronDown className="w-5 h-5 text-white/40" />
          </motion.div>
        </button>

        {/* Expandable Content */}
        <AnimatePresence>
          {isExpanded && (
            <motion.div
              initial={{ height: 0, opacity: 0 }}
              animate={{ height: 'auto', opacity: 1 }}
              exit={{ height: 0, opacity: 0 }}
              transition={{ duration: 0.3 }}
              className="overflow-hidden"
            >
              <div className="px-5 pb-5 space-y-4">
                {/* Voice Note Player */}
                <div className="bg-slate-800/50 rounded-2xl p-4 border border-white/10">
                  <div className="flex items-center justify-between mb-3">
                    <div className="flex items-center gap-2">
                      <span className="text-2xl">🎙️</span>
                      <div>
                        <p className="text-white/90 text-sm font-medium">Voice Update</p>
                        <p className="text-white/40 text-xs">{voiceNote.timestamp}</p>
                      </div>
                    </div>
                    <span className="text-white/60 text-sm">{voiceNote.duration}</span>
                  </div>

                  {/* Waveform Visualization */}
                  <button
                    onClick={() => setIsPlaying(!isPlaying)}
                    className="w-full mb-3 group"
                  >
                    <div className="flex items-center justify-center gap-1 h-12 bg-slate-900/50 rounded-xl px-3 group-hover:bg-slate-900/70 transition-colors">
                      {/* Play/Pause Button */}
                      <div className="w-8 h-8 rounded-full bg-gradient-to-r from-purple-500 to-pink-500 flex items-center justify-center mr-2 group-hover:scale-110 transition-transform">
                        {isPlaying ? (
                          <span className="text-white text-xs">⏸</span>
                        ) : (
                          <span className="text-white text-xs">▶</span>
                        )}
                      </div>

                      {/* Waveform Bars */}
                      {[...Array(28)].map((_, i) => {
                        const height = Math.random() * 60 + 20;
                        return (
                          <motion.div
                            key={i}
                            className="w-1 bg-gradient-to-t from-purple-500 to-pink-500 rounded-full"
                            style={{ height: `${height}%` }}
                            animate={isPlaying ? {
                              height: [`${height}%`, `${Math.random() * 60 + 20}%`, `${height}%`],
                            } : {}}
                            transition={{
                              duration: 0.5 + Math.random() * 0.5,
                              repeat: isPlaying ? Infinity : 0,
                              ease: 'easeInOut'
                            }}
                          />
                        );
                      })}
                    </div>
                  </button>

                  {/* Transcript Toggle */}
                  <button
                    onClick={() => setShowTranscript(!showTranscript)}
                    className="text-purple-400 text-sm hover:text-purple-300 transition-colors flex items-center gap-2"
                  >
                    {showTranscript ? 'Hide' : 'View'} Transcript
                    <ChevronDown className={`w-4 h-4 transition-transform ${showTranscript ? 'rotate-180' : ''}`} />
                  </button>

                  {/* Transcript */}
                  <AnimatePresence>
                    {showTranscript && (
                      <motion.div
                        initial={{ height: 0, opacity: 0 }}
                        animate={{ height: 'auto', opacity: 1 }}
                        exit={{ height: 0, opacity: 0 }}
                        className="mt-3 overflow-hidden"
                      >
                        <div className="bg-slate-900/50 rounded-xl p-3 border border-white/5">
                          <p className="text-white/70 text-sm leading-relaxed">
                            {voiceNote.transcript}
                          </p>
                        </div>
                      </motion.div>
                    )}
                  </AnimatePresence>
                </div>

                {/* Quick Actions */}
                <div className="flex gap-3">
                  <button
                    onClick={onMessageClick}
                    className="flex-1 py-3 bg-gradient-to-r from-purple-500 to-pink-500 hover:opacity-90 text-white font-medium rounded-xl transition-opacity flex items-center justify-center gap-2 relative"
                  >
                    <MessageCircle className="w-4 h-4" />
                    Message
                    {unreadCount > 0 && (
                      <span className="absolute -top-1 -right-1 w-5 h-5 bg-red-500 rounded-full border-2 border-slate-900 flex items-center justify-center text-xs font-bold">
                        {unreadCount}
                      </span>
                    )}
                  </button>
                  <button
                    onClick={() => {
                      if (agentPhone) {
                        window.location.href = `tel:${agentPhone}`;
                      }
                    }}
                    className="flex-1 py-3 bg-white/10 hover:bg-white/20 text-white font-medium rounded-xl transition-colors flex items-center justify-center gap-2"
                  >
                    <Phone className="w-4 h-4" />
                    Call
                  </button>
                </div>
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </div>

      {/* Smart Next Step Card - Connected to Agent Card */}
      <motion.div
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.4, delay: 0.3 }}
        onClick={() => router.push(nextStep.href)}
        className="relative rounded-b-3xl overflow-hidden border border-white/10 border-t border-t-white/5 hover:border-white/20 transition-all glass-strong cursor-pointer group"
      >
        {/* Gradient Glow */}
        <div className={`absolute inset-0 bg-gradient-to-r ${nextStep.gradient} opacity-5 group-hover:opacity-15 transition-opacity`} />

        {/* Subtle Divider */}
        <div className="absolute top-0 left-0 right-0 h-px bg-gradient-to-r from-transparent via-white/10 to-transparent" />

        {/* Content */}
        <div className="relative p-4 flex items-center gap-4">
          {/* Icon */}
          <div className={`w-12 h-12 rounded-xl bg-gradient-to-br ${nextStep.gradient} flex items-center justify-center text-2xl shadow-lg group-hover:scale-110 transition-transform flex-shrink-0`}>
            {nextStep.icon}
          </div>

          {/* Text */}
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2 mb-0.5">
              <h3 className="text-white font-semibold text-sm group-hover:text-blue-200 transition-colors">
                {nextStep.title}
              </h3>
              <span className="text-[10px] text-white/40 font-medium uppercase tracking-wider">Next Step</span>
            </div>
            <p className="text-white/50 text-xs">
              {nextStep.description}
            </p>
          </div>

          {/* Arrow */}
          <ArrowRight className="w-5 h-5 text-white/30 group-hover:text-white/60 group-hover:translate-x-1 transition-all flex-shrink-0" />
        </div>
      </motion.div>
    </motion.div>
  );
}
