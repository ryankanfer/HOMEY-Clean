'use client';

import { useState, useRef } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Play, Pause, MessageCircle, Sparkles } from 'lucide-react';
import type { AgentNote } from '@/lib/types';

interface SarahVoiceNoteProps {
  agentNote: AgentNote;
  compact?: boolean;
}

export default function SarahVoiceNote({ agentNote, compact = false }: SarahVoiceNoteProps) {
  const [isPlaying, setIsPlaying] = useState(false);
  const [showTranscript, setShowTranscript] = useState(false);
  const audioRef = useRef<HTMLAudioElement | null>(null);

  // Generate initials from agent name
  const getInitials = (name: string) => {
    const parts = name.split(' ');
    if (parts.length >= 2) {
      return `${parts[0][0]}${parts[parts.length - 1][0]}`.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  };

  const initials = getInitials(agentNote.agentName);

  const toggleAudio = () => {
    if (agentNote.audioUrl) {
      if (isPlaying) {
        audioRef.current?.pause();
        setIsPlaying(false);
      } else {
        setIsPlaying(true);
        // Simulate playback (in production, use actual audio)
        setTimeout(() => {
          setIsPlaying(false);
        }, 15000);
      }
    }
  };

  const getPriorityColor = (priority?: 'high' | 'medium' | 'low') => {
    switch (priority) {
      case 'high':
        return 'from-pink-500/20 to-red-500/20 border-pink-500/40';
      case 'medium':
        return 'from-purple-500/20 to-pink-500/20 border-purple-500/40';
      default:
        return 'from-purple-500/20 to-blue-500/20 border-purple-500/30';
    }
  };

  if (compact) {
    // Compact badge version for property cards
    return (
      <motion.div
        className={`px-3 py-2 bg-gradient-to-r ${getPriorityColor(agentNote.priority)} border rounded-full flex items-center gap-2 cursor-pointer hover:scale-105 transition-transform`}
        onClick={() => setShowTranscript(!showTranscript)}
        initial={{ scale: 0 }}
        animate={{ scale: 1 }}
        transition={{ type: 'spring', stiffness: 300 }}
      >
        <Sparkles className="w-3 h-3 text-purple-300" />
        <span className="text-purple-200 text-xs font-bold">Sarah's Take</span>
        {agentNote.audioUrl && (
          <button
            onClick={(e) => {
              e.stopPropagation();
              toggleAudio();
            }}
            className="ml-1"
          >
            {isPlaying ? (
              <Pause className="w-3 h-3 text-purple-200" />
            ) : (
              <Play className="w-3 h-3 text-purple-200" />
            )}
          </button>
        )}
      </motion.div>
    );
  }

  // Full version with transcript
  return (
    <motion.div
      className={`px-5 py-4 bg-gradient-to-r ${getPriorityColor(agentNote.priority)} border backdrop-blur-sm rounded-2xl`}
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
    >
      <div className="flex items-start gap-3">
        {/* Agent Avatar */}
        <div className="flex-shrink-0">
          <div className="w-12 h-12 rounded-full bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center text-white text-sm font-bold">
            {initials}
          </div>
        </div>

        {/* Content */}
        <div className="flex-1">
          <div className="flex items-center justify-between mb-2">
            <div className="flex items-center gap-2">
              <Sparkles className="w-4 h-4 text-purple-300" />
              <h4 className="text-white font-bold text-sm">{agentNote.agentName}</h4>
            </div>
            <span className="text-white/50 text-xs">{agentNote.timestamp}</span>
          </div>

          {/* Voice Note Player */}
          {agentNote.audioUrl && (
            <button
              onClick={toggleAudio}
              className="w-full mb-3 px-4 py-3 bg-slate-900/40 hover:bg-slate-900/60 rounded-xl flex items-center gap-3 transition-colors group"
            >
              <div className="w-8 h-8 rounded-full bg-gradient-to-r from-purple-500 to-pink-500 flex items-center justify-center group-hover:scale-110 transition-transform">
                {isPlaying ? (
                  <Pause className="w-4 h-4 text-white" />
                ) : (
                  <Play className="w-4 h-4 text-white ml-0.5" />
                )}
              </div>

              <div className="flex-1 text-left">
                <div className="text-white text-sm font-medium">
                  {isPlaying ? 'Playing voice note...' : 'Play voice note'}
                </div>
                {agentNote.duration && (
                  <div className="text-white/50 text-xs">{agentNote.duration}</div>
                )}
              </div>

              {/* Simple waveform visualization */}
              {isPlaying && (
                <div className="flex items-center gap-0.5 h-6">
                  {[...Array(12)].map((_, i) => (
                    <motion.div
                      key={i}
                      className="w-0.5 bg-gradient-to-t from-purple-500 to-pink-500 rounded-full"
                      animate={{
                        height: ['20%', `${Math.random() * 60 + 20}%`, '20%'],
                      }}
                      transition={{
                        duration: 0.5 + Math.random() * 0.3,
                        repeat: Infinity,
                        ease: 'easeInOut',
                      }}
                    />
                  ))}
                </div>
              )}
            </button>
          )}

          {/* Text Note */}
          <div className="text-white/90 text-sm leading-relaxed mb-3">
            {agentNote.note}
          </div>

          {/* Transcript Toggle */}
          {agentNote.audioUrl && (
            <button
              onClick={() => setShowTranscript(!showTranscript)}
              className="text-purple-300 text-xs hover:text-purple-200 transition-colors flex items-center gap-1"
            >
              <MessageCircle className="w-3 h-3" />
              {showTranscript ? 'Hide' : 'View'} full transcript
            </button>
          )}

          {/* Transcript */}
          <AnimatePresence>
            {showTranscript && (
              <motion.div
                initial={{ height: 0, opacity: 0 }}
                animate={{ height: 'auto', opacity: 1 }}
                exit={{ height: 0, opacity: 0 }}
                className="mt-3 overflow-hidden"
              >
                <div className="p-3 bg-slate-900/40 rounded-lg border border-white/10">
                  <p className="text-white/70 text-xs leading-relaxed">
                    {agentNote.note}
                  </p>
                </div>
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      </div>
    </motion.div>
  );
}

/**
 * Get demo agent notes for testing
 */
export function getDemoAgentNotes(listingId: string): AgentNote | null {
  // Only show agent notes for specific listings (to demo the feature)
  const notes: Record<string, AgentNote> = {
    // Example: First listing gets a note
    'demo-1': {
      listingId,
      agentName: 'Sarah Chen',
      note: "I love this one! The open kitchen flows perfectly into the living space, and that balcony? Perfect for your morning coffee. Plus, it's a 5-minute bike ride to your office. The building has amazing light all day.",
      audioUrl: '/audio/sarah-note-1.mp3',
      duration: '0:28',
      timestamp: '2 hours ago',
      priority: 'high',
    },
  };

  return notes[listingId] || null;
}
