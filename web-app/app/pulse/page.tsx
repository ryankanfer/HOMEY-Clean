'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  Users, MapPin, Sparkles, Shield, Award,
  TrendingUp, TrendingDown, Clock, Plus,
  ThumbsUp, X, ChevronLeft, Send, Star
} from 'lucide-react';
import { useRouter } from 'next/navigation';
import CinematicBackground from '@/components/CinematicBackground';
import Snowfall from '@/components/Snowfall';
import BottomNav from '@/components/BottomNav';
import Tutorial from '@/components/Tutorial';
import { pulseTutorialSteps } from '@/lib/tutorialSteps';
import pulseDb, { type VibeLog, type NeighborhoodPulse, type VibePlaylist, type NeighborhoodStats, type QuickVibe } from '@/lib/pulseDb';
import { auth } from '@/lib/supabase';
import { searchNeighborhoods } from '@/lib/neighborhoods';
import { isHolidaySeason } from '@/lib/holidayConfig';
import { detectTags } from '@/lib/aiTagging';

// --- Helper Functions ---

function timeAgo(dateString: string): string {
  const now = new Date();
  const past = new Date(dateString);
  const diffMs = now.getTime() - past.getTime();
  const diffMins = Math.floor(diffMs / 60000);

  if (diffMins < 1) return 'just now';
  if (diffMins < 60) return `${diffMins}m ago`;

  const diffHours = Math.floor(diffMins / 60);
  if (diffHours < 24) return `${diffHours}h ago`;

  const diffDays = Math.floor(diffHours / 24);
  return `${diffDays}d ago`;
}

// --- Components ---

const Toast = ({ message, show }: { message: string; show: boolean }) => {
  return (
    <AnimatePresence>
      {show && (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          exit={{ opacity: 0, y: -20 }}
          className="fixed top-20 left-1/2 -translate-x-1/2 z-50 pointer-events-none"
        >
          <div className="bg-white/10 backdrop-blur-xl border border-white/20 text-white px-4 sm:px-6 py-2 sm:py-3 rounded-full shadow-xl flex items-center gap-2">
            <Sparkles size={14} className="text-yellow-300 flex-shrink-0" />
            <span className="font-medium text-xs sm:text-sm">{message}</span>
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  );
};

const VibeLogCard = ({
  log,
  onLike
}: {
  log: VibeLog;
  onLike: (logId: string) => void;
}) => {
  const [currentUserId, setCurrentUserId] = useState<string | null>(null);

  useEffect(() => {
    auth.getUser().then(({ data }) => {
      if (data.user) setCurrentUserId(data.user.id);
    });
  }, []);

  const hasLiked = currentUserId ? log.liked_by?.includes(currentUserId) : false;

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="bg-white/5 backdrop-blur-sm border border-white/10 rounded-2xl sm:rounded-3xl p-4 sm:p-6"
    >
      {/* User Info */}
      <div className="flex items-start justify-between mb-3">
        <div className="flex items-center gap-2 sm:gap-3">
          <div className="w-8 h-8 sm:w-10 sm:h-10 rounded-full bg-gradient-to-br from-primary/40 to-purple-600/40 flex items-center justify-center text-white font-bold text-xs sm:text-sm">
            {log.user?.full_name?.charAt(0) || 'U'}
          </div>
          <div>
            <div className="flex items-center gap-2">
              <p className="text-sm sm:text-base font-semibold text-white">{log.user?.full_name || 'Anonymous'}</p>
              {log.user?.is_resident && (
                <span title="Verified Resident">
                  <Shield className="w-3 h-3 sm:w-4 sm:h-4 text-emerald-400" />
                </span>
              )}
              {log.user?.is_agent && (
                <span title="Real Estate Agent">
                  <Award className="w-3 h-3 sm:w-4 sm:h-4 text-amber-400" />
                </span>
              )}
            </div>
            <p className="text-xs text-white/50">{timeAgo(log.created_at)}</p>
          </div>
        </div>

        {/* Rating */}
        <div className="flex items-center gap-0.5 bg-white/5 px-2 py-1 rounded-full flex-shrink-0">
          {[...Array(log.rating)].map((_, i) => (
            <Star key={i} className="w-3 h-3 fill-yellow-400 text-yellow-400" />
          ))}
        </div>
      </div>

      {/* Content */}
      <p className="text-sm sm:text-base text-white/90 mb-3 leading-relaxed">{log.text}</p>

      {/* Tags & Like Button */}
      <div className="flex items-center justify-between gap-2">
        <div className="flex flex-wrap gap-1.5 sm:gap-2">
          {log.tags?.map((tag, idx) => (
            <span
              key={idx}
              className="px-2 sm:px-3 py-1 bg-primary/10 text-primary text-xs rounded-full border border-primary/20"
            >
              {tag}
            </span>
          ))}
        </div>

        {/* Small Like Button - Bottom Right */}
        <motion.button
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
          onClick={() => onLike(log.id)}
          className={`flex items-center gap-1.5 px-2.5 py-1.5 rounded-lg transition-all flex-shrink-0 ${
            hasLiked
              ? 'bg-pink-500/20 text-pink-400 border border-pink-500/30'
              : 'bg-white/5 text-white/60 hover:bg-white/10 border border-white/10'
          }`}
        >
          <ThumbsUp className={`w-3.5 h-3.5 ${hasLiked ? 'fill-current' : ''}`} />
          <span className="text-xs font-medium">{log.likes || 0}</span>
        </motion.button>
      </div>
    </motion.div>
  );
};

const QuickVibeModal = ({
  isOpen,
  onClose,
  onSubmit
}: {
  isOpen: boolean;
  onClose: () => void;
  onSubmit: (vibe: { text: string; neighborhood: string; latitude?: number; longitude?: number }) => void;
}) => {
  const [text, setText] = useState('');
  const [neighborhood, setNeighborhood] = useState('');
  const [isDetectingLocation, setIsDetectingLocation] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    if (isOpen && !neighborhood) {
      detectLocation();
    }
  }, [isOpen]);

  const detectLocation = () => {
    setIsDetectingLocation(true);
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        async (position) => {
          const { latitude, longitude } = position.coords;
          // Use reverse geocoding or default to a neighborhood
          // For now, we'll prompt user to confirm/select
          setNeighborhood(''); // User will type it in
          setIsDetectingLocation(false);
        },
        (error) => {
          console.error('Location detection failed:', error);
          setIsDetectingLocation(false);
        }
      );
    } else {
      setIsDetectingLocation(false);
    }
  };

  const handleSubmit = async () => {
    if (!text.trim() || !neighborhood.trim() || isSubmitting) return;

    try {
      setIsSubmitting(true);
      await onSubmit({ text, neighborhood });
      setText('');
      setNeighborhood('');
      onClose();
    } catch (error) {
      console.error('Error submitting quick vibe:', error);
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <AnimatePresence>
      {isOpen && (
        <>
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={onClose}
            className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50"
          />

          <motion.div
            initial={{ opacity: 0, scale: 0.95, y: 20 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.95, y: 20 }}
            className="fixed left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 w-[calc(100%-2rem)] sm:w-full sm:max-w-lg z-50"
          >
            <div className="bg-gradient-to-br from-rose-900/95 via-orange-900/95 to-rose-900/95 backdrop-blur-xl border border-white/20 rounded-3xl p-6 sm:p-8 shadow-2xl">
              <div className="flex items-center justify-between mb-6">
                <h2 className="text-xl sm:text-2xl font-bold text-white flex items-center gap-2">
                  <span className="text-2xl">🔴</span>
                  What's Happening Now?
                </h2>
                <button
                  onClick={onClose}
                  className="w-8 h-8 rounded-full bg-white/10 flex items-center justify-center hover:bg-white/20 transition"
                >
                  <X className="w-5 h-5 text-white" />
                </button>
              </div>

              <div className="mb-4">
                <label className="block text-sm font-medium text-white/80 mb-2">Where are you?</label>
                <input
                  type="text"
                  value={neighborhood}
                  onChange={(e) => setNeighborhood(e.target.value)}
                  placeholder="Your neighborhood..."
                  className="w-full px-4 py-2.5 bg-white/5 border border-white/10 rounded-xl text-white placeholder:text-white/40 focus:outline-none focus:border-rose-500/50"
                  disabled={isDetectingLocation}
                />
              </div>

              <div className="mb-4">
                <label className="block text-sm font-medium text-white/80 mb-2">What's going on?</label>
                <textarea
                  value={text}
                  onChange={(e) => setText(e.target.value)}
                  placeholder="Live band at the park, coffee shop packed, block party starting..."
                  rows={3}
                  className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder:text-white/40 focus:outline-none focus:border-rose-500/50 resize-none"
                />
              </div>

              <div className="mb-6 p-3 bg-rose-500/10 border border-rose-500/20 rounded-xl">
                <p className="text-xs text-white/70">
                  ⏱️ Your quick vibe will expire in 24 hours
                </p>
              </div>

              <button
                onClick={handleSubmit}
                disabled={!text.trim() || !neighborhood.trim() || isSubmitting}
                className="w-full py-3 bg-gradient-to-r from-rose-500 to-orange-500 rounded-xl text-white font-semibold hover:opacity-90 transition disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
              >
                <Sparkles className="w-5 h-5" />
                Post Quick Vibe
              </button>
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
};

const NewPostModal = ({
  isOpen,
  onClose,
  onSubmit
}: {
  isOpen: boolean;
  onClose: () => void;
  onSubmit: (post: { text: string; rating: number; tags: string[]; neighborhood: string }) => void;
}) => {
  const [text, setText] = useState('');
  const [rating, setRating] = useState(5);
  const [neighborhood, setNeighborhood] = useState('');
  const [suggestions, setSuggestions] = useState<string[]>([]);
  const [showSuggestions, setShowSuggestions] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleNeighborhoodChange = (value: string) => {
    setNeighborhood(value);
    if (value.length > 0) {
      const results = searchNeighborhoods(value);
      setSuggestions(results);
      setShowSuggestions(true);
    } else {
      setSuggestions([]);
      setShowSuggestions(false);
    }
  };

  const selectNeighborhood = (hood: string) => {
    setNeighborhood(hood);
    setShowSuggestions(false);
    setSuggestions([]);
  };

  const handleSubmit = async () => {
    if (!text.trim() || !neighborhood.trim() || isSubmitting) return;

    try {
      setIsSubmitting(true);
      // Auto-detect tags using AI
      const detectedTags = await detectTags(text);
      onSubmit({ text, rating, tags: detectedTags, neighborhood });
      setText('');
      setRating(5);
      setNeighborhood('');
      onClose();
    } catch (error) {
      console.error('Error submitting vibe:', error);
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <AnimatePresence>
      {isOpen && (
        <>
          {/* Backdrop */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={onClose}
            className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50"
          />

          {/* Modal */}
          <motion.div
            initial={{ opacity: 0, scale: 0.95, y: 20 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.95, y: 20 }}
            className="fixed left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 w-[calc(100%-2rem)] sm:w-full sm:max-w-lg max-h-[90vh] overflow-y-auto z-50"
          >
            <div className="bg-gradient-to-br from-slate-900/95 via-purple-900/95 to-slate-900/95 backdrop-blur-xl border border-white/20 rounded-3xl p-6 sm:p-8 shadow-2xl">
              {/* Header */}
              <div className="flex items-center justify-between mb-6">
                <h2 className="text-xl sm:text-2xl font-bold text-white">Share a Vibe</h2>
                <button
                  onClick={onClose}
                  className="w-8 h-8 rounded-full bg-white/10 flex items-center justify-center hover:bg-white/20 transition"
                >
                  <X className="w-5 h-5 text-white" />
                </button>
              </div>

              {/* Neighborhood */}
              <div className="mb-4 relative">
                <label className="block text-sm font-medium text-white/80 mb-2">Neighborhood</label>
                <input
                  type="text"
                  value={neighborhood}
                  onChange={(e) => handleNeighborhoodChange(e.target.value)}
                  onFocus={() => neighborhood.length > 0 && setShowSuggestions(true)}
                  placeholder="Start typing... (e.g., Chelsea)"
                  className="w-full px-4 py-2.5 bg-white/5 border border-white/10 rounded-xl text-white placeholder:text-white/40 focus:outline-none focus:border-primary/50"
                  autoComplete="off"
                />
                {/* Autocomplete Dropdown */}
                {showSuggestions && suggestions.length > 0 && (
                  <div className="absolute z-10 w-full mt-2 bg-slate-900/95 backdrop-blur-xl border border-white/20 rounded-xl shadow-xl max-h-48 overflow-y-auto">
                    {suggestions.map((hood, index) => (
                      <button
                        key={index}
                        type="button"
                        onClick={() => selectNeighborhood(hood)}
                        className="w-full px-4 py-2.5 text-left text-white hover:bg-primary/20 transition-colors first:rounded-t-xl last:rounded-b-xl flex items-center gap-2"
                      >
                        <MapPin className="w-4 h-4 text-primary" />
                        {hood}
                      </button>
                    ))}
                  </div>
                )}
              </div>

              {/* Text */}
              <div className="mb-4">
                <label className="block text-sm font-medium text-white/80 mb-2">What's the vibe?</label>
                <textarea
                  value={text}
                  onChange={(e) => setText(e.target.value)}
                  placeholder="Share what makes this neighborhood special..."
                  rows={4}
                  className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder:text-white/40 focus:outline-none focus:border-primary/50 resize-none"
                />
              </div>

              {/* Rating */}
              <div className="mb-4">
                <label className="block text-sm font-medium text-white/80 mb-2">Rating</label>
                <div className="flex gap-2">
                  {[1, 2, 3, 4, 5].map((star) => (
                    <button
                      key={star}
                      onClick={() => setRating(star)}
                      className="transition-transform hover:scale-110"
                    >
                      <Star
                        className={`w-8 h-8 ${
                          star <= rating
                            ? 'fill-yellow-400 text-yellow-400'
                            : 'text-white/20'
                        }`}
                      />
                    </button>
                  ))}
                </div>
              </div>

              {/* AI Tag Notice */}
              <div className="mb-6 p-3 bg-primary/10 border border-primary/20 rounded-xl">
                <p className="text-xs text-white/70">
                  <Sparkles className="w-3 h-3 inline mr-1" />
                  Tags will be auto-detected from your vibe using AI
                </p>
              </div>

              {/* Submit */}
              <button
                onClick={handleSubmit}
                disabled={!text.trim() || !neighborhood.trim()}
                className="w-full py-3 bg-gradient-to-r from-primary to-purple-500 rounded-xl text-white font-semibold hover:opacity-90 transition disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
              >
                <Send className="w-5 h-5" />
                Post Vibe
              </button>
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
};

const VotingCard = ({
  question,
  optionA,
  optionB,
  votesA,
  votesB,
  userVote,
  onVote
}: {
  question: string;
  optionA: string;
  optionB: string;
  votesA: number;
  votesB: number;
  userVote: 'A' | 'B' | null;
  onVote: (option: 'A' | 'B') => void;
}) => {
  const totalVotes = votesA + votesB;
  const percentA = totalVotes > 0 ? Math.round((votesA / totalVotes) * 100) : 50;
  const percentB = totalVotes > 0 ? Math.round((votesB / totalVotes) * 100) : 50;
  const hasVoted = userVote !== null;

  return (
    <motion.div
      initial={{ opacity: 0, x: 20 }}
      animate={{ opacity: 1, x: 0 }}
      className="flex-shrink-0 w-[220px] bg-gradient-to-br from-indigo-900/40 via-purple-900/40 to-pink-900/40 backdrop-blur-sm border border-white/10 rounded-xl p-3"
    >
      {/* Question Title */}
      <h3 className="text-xs font-bold text-white mb-2 text-center">{question}</h3>

      {/* Options Stacked Vertically */}
      <div className="space-y-1.5">
        {/* Option A */}
        <button
          onClick={() => !hasVoted && onVote('A')}
          disabled={hasVoted}
          className={`relative w-full overflow-hidden rounded-lg transition-all ${
            hasVoted ? 'cursor-default' : 'hover:scale-[1.02] active:scale-[0.98]'
          }`}
        >
          {/* Background Progress Bar */}
          {hasVoted && (
            <motion.div
              initial={{ width: 0 }}
              animate={{ width: `${percentA}%` }}
              transition={{ duration: 0.8, ease: 'easeOut' }}
              className="absolute inset-y-0 left-0 bg-gradient-to-r from-blue-500/30 to-cyan-500/30"
            />
          )}

          {/* Content */}
          <div className={`relative z-10 px-2 py-1.5 border rounded-lg transition-all ${
            userVote === 'A'
              ? 'border-blue-500 bg-blue-500/10'
              : hasVoted
              ? 'border-white/10 bg-white/5'
              : 'border-white/20 bg-white/5 hover:border-blue-500/50'
          }`}>
            <div className="flex items-center justify-between gap-1">
              <div className="flex items-center gap-1 min-w-0">
                <span className="text-base flex-shrink-0">{optionA.split(':')[0]}</span>
                <span className="text-[9px] font-medium text-white/90 truncate">
                  {optionA.split(':')[1]?.trim() || optionA}
                </span>
              </div>
              {userVote === 'A' && (
                <div className="w-3.5 h-3.5 bg-blue-500 rounded-full flex items-center justify-center flex-shrink-0">
                  <span className="text-white text-[9px]">✓</span>
                </div>
              )}
            </div>
            {hasVoted && (
              <div className="flex items-center justify-between mt-0.5">
                <span className="text-sm font-bold text-white">{percentA}%</span>
                <span className="text-[9px] text-white/60">{votesA.toLocaleString()}</span>
              </div>
            )}
          </div>
        </button>

        {/* Option B */}
        <button
          onClick={() => !hasVoted && onVote('B')}
          disabled={hasVoted}
          className={`relative w-full overflow-hidden rounded-lg transition-all ${
            hasVoted ? 'cursor-default' : 'hover:scale-[1.02] active:scale-[0.98]'
          }`}
        >
          {/* Background Progress Bar */}
          {hasVoted && (
            <motion.div
              initial={{ width: 0 }}
              animate={{ width: `${percentB}%` }}
              transition={{ duration: 0.8, ease: 'easeOut' }}
              className="absolute inset-y-0 left-0 bg-gradient-to-r from-pink-500/30 to-purple-500/30"
            />
          )}

          {/* Content */}
          <div className={`relative z-10 px-2 py-1.5 border rounded-lg transition-all ${
            userVote === 'B'
              ? 'border-pink-500 bg-pink-500/10'
              : hasVoted
              ? 'border-white/10 bg-white/5'
              : 'border-white/20 bg-white/5 hover:border-pink-500/50'
          }`}>
            <div className="flex items-center justify-between gap-1">
              <div className="flex items-center gap-1 min-w-0">
                <span className="text-base flex-shrink-0">{optionB.split(':')[0]}</span>
                <span className="text-[9px] font-medium text-white/90 truncate">
                  {optionB.split(':')[1]?.trim() || optionB}
                </span>
              </div>
              {userVote === 'B' && (
                <div className="w-3.5 h-3.5 bg-pink-500 rounded-full flex items-center justify-center flex-shrink-0">
                  <span className="text-white text-[9px]">✓</span>
                </div>
              )}
            </div>
            {hasVoted && (
              <div className="flex items-center justify-between mt-0.5">
                <span className="text-sm font-bold text-white">{percentB}%</span>
                <span className="text-[9px] text-white/60">{votesB.toLocaleString()}</span>
              </div>
            )}
          </div>
        </button>
      </div>

      {!hasVoted && (
        <p className="text-center text-[10px] text-white/50 mt-2">Tap to vote</p>
      )}
    </motion.div>
  );
};

// --- Main Component ---

export default function PulsePage() {
  const router = useRouter();
  const [logs, setLogs] = useState<VibeLog[]>([]);
  const [playlists, setPlaylists] = useState<VibePlaylist[]>([]);
  const [neighborhoodStats, setNeighborhoodStats] = useState<NeighborhoodStats[]>([]);
  const [quickVibes, setQuickVibes] = useState<QuickVibe[]>([]);
  const [activeFilter, setActiveFilter] = useState<string | null>(null);
  const [sortMode, setSortMode] = useState<'recent' | 'popular'>('recent');
  const [quickVibeFilter, setQuickVibeFilter] = useState<'all' | 'nearby' | 'following'>('all');
  const [feedView, setFeedView] = useState<'timeline' | 'neighborhood'>('timeline');
  const [userLocation, setUserLocation] = useState<{ lat: number; lng: number } | null>(null);
  const [toast, setToast] = useState({ show: false, message: '' });
  const [isPostModalOpen, setIsPostModalOpen] = useState(false);
  const [isQuickVibeModalOpen, setIsQuickVibeModalOpen] = useState(false);
  const [selectedQuickVibe, setSelectedQuickVibe] = useState<QuickVibe | null>(null);
  const [currentUser, setCurrentUser] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [showHolidayTheme] = useState(isHolidaySeason());

  // Voting state
  const [votingPolls, setVotingPolls] = useState([
    {
      id: '1',
      question: 'Best NYC Taco Spot?',
      optionA: '🌮: Los Tacos No. 1',
      optionB: '🌮: Tacombi',
      votesA: 1247,
      votesB: 983,
    },
    {
      id: '2',
      question: 'Coffee Order?',
      optionA: '☕️: Iced Coffee',
      optionB: '☕️: Hot Coffee',
      votesA: 2156,
      votesB: 1432,
    },
    {
      id: '3',
      question: 'Weekend Brunch Vibe?',
      optionA: '🥞: Classic Diner',
      optionB: '🥑: Trendy Cafe',
      votesA: 891,
      votesB: 1567,
    },
    {
      id: '4',
      question: 'Pizza Debate?',
      optionA: '🍕: Brooklyn Style',
      optionB: '🍕: Manhattan Style',
      votesA: 1834,
      votesB: 1205,
    },
  ]);
  const [userVotes, setUserVotes] = useState<{ [pollId: string]: 'A' | 'B' }>({});

  useEffect(() => {
    loadData();
  }, [activeFilter]);

  useEffect(() => {
    auth.getUser().then(({ data }) => {
      if (data.user) setCurrentUser(data.user);
    });
  }, []);

  useEffect(() => {
    // Get user's location for "nearby" filter
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          setUserLocation({
            lat: position.coords.latitude,
            lng: position.coords.longitude,
          });
        },
        (error) => {
          console.log('Location access denied or unavailable');
        }
      );
    }
  }, []);

  const loadData = async () => {
    try {
      setLoading(true);
      console.log('Loading pulse data...');

      const [logsData, playlistsData, quickVibesData] = await Promise.all([
        pulseDb.getVibeLogs(50, activeFilter || undefined),
        pulseDb.getPlaylists(),
        pulseDb.getQuickVibes(20),
      ]);

      console.log('Vibe logs loaded:', logsData?.length || 0, 'logs');
      console.log('Playlists loaded:', playlistsData?.length || 0, 'playlists');
      console.log('Quick vibes loaded:', quickVibesData?.length || 0, 'quick vibes');

      setLogs(logsData);
      setPlaylists(playlistsData);
      setQuickVibes(quickVibesData);
    } catch (error: any) {
      console.error('Error loading pulse data:', error);
      console.error('Error type:', typeof error);
      console.error('Error keys:', Object.keys(error || {}));
      console.error('Error message:', error?.message);
      console.error('Error code:', error?.code);
      console.error('Error details:', error?.details);
      console.error('Error hint:', error?.hint);

      const errorMessage = error?.message || error?.error_description || error?.code || 'Failed to load data';

      // Check if tables don't exist
      if (errorMessage.includes('relation') && errorMessage.includes('does not exist')) {
        showToast('Database setup required. Please contact admin.');
      } else if (errorMessage.includes('not found') || errorMessage.includes('schema cache')) {
        showToast('The Pulse tables need to be set up. Check the migration.');
      } else {
        showToast(errorMessage.length > 50 ? 'Failed to load data' : errorMessage);
      }
    } finally {
      setLoading(false);
    }
  };

  const showToast = (message: string) => {
    setToast({ show: true, message });
    setTimeout(() => setToast({ show: false, message: '' }), 3000);
  };

  const handleLike = async (logId: string) => {
    if (!currentUser) {
      showToast('Please sign in to like posts');
      return;
    }

    try {
      await pulseDb.toggleLike(logId, currentUser.id);
      // Optimistically update UI
      setLogs(prev => prev.map(log => {
        if (log.id === logId) {
          const hasLiked = log.liked_by?.includes(currentUser.id);
          return {
            ...log,
            liked_by: hasLiked
              ? log.liked_by.filter(id => id !== currentUser.id)
              : [...(log.liked_by || []), currentUser.id],
            likes: hasLiked ? log.likes - 1 : log.likes + 1,
          };
        }
        return log;
      }));
    } catch (error) {
      console.error('Error liking post:', error);
      showToast('Failed to like post');
    }
  };

  const handleCreatePost = async (post: { text: string; rating: number; tags: string[]; neighborhood: string }) => {
    if (!currentUser) {
      showToast('Please sign in to post');
      return;
    }

    try {
      await pulseDb.createVibeLog({
        user_id: currentUser.id,
        neighborhood: post.neighborhood,
        text: post.text,
        rating: post.rating,
        tags: post.tags,
      });
      showToast('Vibe posted! ✨');
      loadData(); // Reload to show new post
    } catch (error: any) {
      console.error('Error creating post:', error);
      const errorMessage = error?.message || error?.error_description || 'Failed to post';

      // Check if tables don't exist
      if (errorMessage.includes('relation') && errorMessage.includes('does not exist')) {
        showToast('Database not set up. Please run the migration.');
      } else if (errorMessage.includes('not found') || errorMessage.includes('schema cache')) {
        showToast('Pulse tables missing. Contact admin.');
      } else {
        showToast(errorMessage.length > 50 ? 'Failed to post' : errorMessage);
      }
    }
  };

  const handleCreateQuickVibe = async (vibe: { text: string; neighborhood: string; latitude?: number; longitude?: number }) => {
    if (!currentUser) {
      showToast('Please sign in to post');
      return;
    }

    try {
      await pulseDb.createQuickVibe({
        user_id: currentUser.id,
        neighborhood: vibe.neighborhood,
        text: vibe.text,
        latitude: vibe.latitude,
        longitude: vibe.longitude,
      });
      showToast('Quick vibe posted! 🔴');
      loadData(); // Reload to show new quick vibe
    } catch (error: any) {
      console.error('Error creating quick vibe:', error);
      showToast('Failed to post quick vibe');
    }
  };

  const handleVote = (pollId: string, option: 'A' | 'B') => {
    // Record the user's vote
    setUserVotes(prev => ({ ...prev, [pollId]: option }));

    // Update vote counts
    setVotingPolls(prev => prev.map(poll => {
      if (poll.id === pollId) {
        return {
          ...poll,
          votesA: option === 'A' ? poll.votesA + 1 : poll.votesA,
          votesB: option === 'B' ? poll.votesB + 1 : poll.votesB,
        };
      }
      return poll;
    }));

    showToast('Vote recorded! 🎯');
  };

  // Helper: Calculate distance between two coordinates (Haversine formula)
  const calculateDistance = (lat1: number, lon1: number, lat2: number, lon2: number): number => {
    const R = 6371; // Earth's radius in km
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLon = (lon2 - lon1) * Math.PI / 180;
    const a =
      Math.sin(dLat/2) * Math.sin(dLat/2) +
      Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
      Math.sin(dLon/2) * Math.sin(dLon/2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    return R * c;
  };

  // Filter Quick Vibes based on selected filter
  const filteredQuickVibes = (() => {
    let result = quickVibes;

    if (quickVibeFilter === 'nearby' && userLocation) {
      // Show Quick Vibes within 5km
      result = result.filter(vibe => {
        if (!vibe.latitude || !vibe.longitude) return false;
        const distance = calculateDistance(
          userLocation.lat,
          userLocation.lng,
          vibe.latitude,
          vibe.longitude
        );
        return distance <= 5; // 5km radius
      });
    } else if (quickVibeFilter === 'following' && currentUser) {
      // TODO: Filter by friends/following when we have that data
      // For now, show all (will implement when we have friends system)
      result = result;
    }

    return result;
  })();

  // Filter and sort regular vibes
  const filteredLogs = (() => {
    let result = activeFilter
      ? logs.filter(log => log.tags?.includes(activeFilter))
      : logs;

    // Sort based on mode
    if (sortMode === 'popular') {
      result = [...result].sort((a, b) => b.likes - a.likes);
    }
    // 'recent' is already sorted by created_at DESC from the query

    return result;
  })();

  // Group vibes by neighborhood
  const groupedByNeighborhood = (() => {
    const groups: { [key: string]: VibeLog[] } = {};
    filteredLogs.forEach(log => {
      if (!groups[log.neighborhood]) {
        groups[log.neighborhood] = [];
      }
      groups[log.neighborhood].push(log);
    });
    return groups;
  })();

  return (
    <>
      <CinematicBackground timeOfDay="night" />

      {/* Holiday Snow Effect */}
      {showHolidayTheme && <Snowfall density={40} />}

      <div className="min-h-screen pb-24 relative z-10">
        {/* Header - Mobile Optimized */}
        <div className="sticky top-0 z-30 glass-strong border-b border-white/10 px-3 sm:px-4 py-4 sm:py-6">
          <div className="max-w-4xl mx-auto">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2 sm:gap-4">
                <button
                  onClick={() => router.push('/home')}
                  className="w-10 h-10 sm:w-12 sm:h-12 rounded-full glass-medium flex items-center justify-center hover:bg-white/10 transition-all"
                >
                  <ChevronLeft className="w-5 h-5 sm:w-6 sm:h-6 text-white" />
                </button>
                <div>
                  <div className="flex items-center gap-2">
                    <h1 className="text-xl sm:text-2xl md:text-3xl font-bold text-white">The Pulse</h1>
                    {showHolidayTheme && (
                      <span className="text-xl sm:text-2xl animate-pulse">❄️</span>
                    )}
                    <span className="inline-flex items-center gap-1 px-2 py-0.5 sm:py-1 rounded-full bg-emerald-500/10 text-xs text-emerald-300 border border-emerald-400/40">
                      <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse" />
                      <span className="hidden sm:inline">Live</span>
                    </span>
                  </div>
                  <p className="text-xs sm:text-sm text-white/60 mt-0.5 sm:mt-1">
                    Your neighborhood, in real-time {showHolidayTheme && '· Happy Holidays! 🎄'}
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Quick Vibes - Instagram Stories Style */}
        <div className="px-3 sm:px-4 py-4 sm:py-6 border-b border-white/10">
          <div className="max-w-4xl mx-auto">
            <div className="flex items-center justify-between mb-3 sm:mb-4">
              <h2 className="text-sm sm:text-base font-semibold text-white/80 flex items-center gap-2">
                <span className="text-base sm:text-lg">🔴</span>
                What's Happening Now
              </h2>

              {/* Quick Vibe Filters */}
              <div className="flex gap-1.5">
                <button
                  onClick={() => setQuickVibeFilter('all')}
                  className={`px-2.5 py-1 rounded-lg text-xs font-medium transition-all ${
                    quickVibeFilter === 'all'
                      ? 'bg-rose-500/20 text-rose-400 border border-rose-500/30'
                      : 'bg-white/5 text-white/60 hover:bg-white/10'
                  }`}
                >
                  All
                </button>
                <button
                  onClick={() => setQuickVibeFilter('nearby')}
                  className={`px-2.5 py-1 rounded-lg text-xs font-medium transition-all ${
                    quickVibeFilter === 'nearby'
                      ? 'bg-rose-500/20 text-rose-400 border border-rose-500/30'
                      : 'bg-white/5 text-white/60 hover:bg-white/10'
                  }`}
                  disabled={!userLocation}
                  title={!userLocation ? 'Location access required' : ''}
                >
                  <MapPin className="w-3 h-3 inline mr-1" />
                  Nearby
                </button>
                <button
                  onClick={() => setQuickVibeFilter('following')}
                  className={`px-2.5 py-1 rounded-lg text-xs font-medium transition-all ${
                    quickVibeFilter === 'following'
                      ? 'bg-rose-500/20 text-rose-400 border border-rose-500/30'
                      : 'bg-white/5 text-white/60 hover:bg-white/10'
                  }`}
                >
                  <Users className="w-3 h-3 inline mr-1" />
                  Following
                </button>
              </div>
            </div>

            <div className="flex gap-3 overflow-x-auto hide-scrollbar pb-2">
              {/* Add New Quick Vibe Button */}
              <button
                onClick={() => setIsQuickVibeModalOpen(true)}
                className="flex flex-col items-center gap-2 flex-shrink-0"
              >
                <div className="w-16 h-16 sm:w-20 sm:h-20 rounded-full bg-gradient-to-br from-rose-500 to-orange-500 flex items-center justify-center border-4 border-white/20 hover:border-white/40 transition-all shadow-lg">
                  <Plus className="w-7 h-7 sm:w-9 sm:h-9 text-white" />
                </div>
                <span className="text-xs text-white/80 font-medium max-w-[70px] text-center truncate">
                  Your Vibe
                </span>
              </button>

              {/* Quick Vibes */}
              {filteredQuickVibes.map((vibe) => (
                <button
                  key={vibe.id}
                  onClick={() => setSelectedQuickVibe(vibe)}
                  className="flex flex-col items-center gap-2 flex-shrink-0"
                >
                  <div className="relative">
                    <div className="w-16 h-16 sm:w-20 sm:h-20 rounded-full bg-gradient-to-br from-primary/40 to-purple-600/40 flex items-center justify-center border-4 border-rose-500 hover:border-orange-500 transition-all shadow-lg">
                      <span className="text-lg sm:text-2xl font-bold text-white">
                        {vibe.user?.full_name?.charAt(0) || '?'}
                      </span>
                    </div>
                    <div className="absolute -bottom-1 -right-1 w-6 h-6 rounded-full bg-rose-500 border-2 border-slate-900 flex items-center justify-center">
                      <span className="text-[10px]">🔴</span>
                    </div>
                  </div>
                  <div className="text-center max-w-[70px]">
                    <p className="text-xs text-white/80 font-medium truncate">{vibe.neighborhood}</p>
                    <p className="text-[10px] text-white/50">{timeAgo(vibe.created_at)}</p>
                  </div>
                </button>
              ))}

              {filteredQuickVibes.length === 0 && (
                <div className="flex-1 text-center py-8">
                  <p className="text-sm text-white/50">
                    {quickVibeFilter === 'nearby' && !userLocation
                      ? 'Enable location to see nearby Quick Vibes'
                      : quickVibeFilter === 'nearby'
                      ? 'No Quick Vibes nearby'
                      : quickVibeFilter === 'following'
                      ? 'No Quick Vibes from people you follow'
                      : 'No quick vibes yet. Be the first!'}
                  </p>
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Quick Vibe Detail Modal */}
        <AnimatePresence>
          {selectedQuickVibe && (
            <>
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
                onClick={() => setSelectedQuickVibe(null)}
                className="fixed inset-0 bg-black/80 backdrop-blur-sm z-50"
              />
              <motion.div
                initial={{ opacity: 0, scale: 0.9 }}
                animate={{ opacity: 1, scale: 1 }}
                exit={{ opacity: 0, scale: 0.9 }}
                className="fixed left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 w-[calc(100%-2rem)] sm:w-96 z-50"
              >
                <div className="bg-gradient-to-br from-rose-900/95 via-orange-900/95 to-rose-900/95 backdrop-blur-xl border border-white/20 rounded-3xl p-6 shadow-2xl">
                  <div className="flex items-center justify-between mb-4">
                    <div className="flex items-center gap-3">
                      <div className="w-12 h-12 rounded-full bg-gradient-to-br from-primary/40 to-purple-600/40 flex items-center justify-center">
                        <span className="text-lg font-bold text-white">
                          {selectedQuickVibe.user?.full_name?.charAt(0) || '?'}
                        </span>
                      </div>
                      <div>
                        <p className="text-sm font-semibold text-white">{selectedQuickVibe.user?.full_name}</p>
                        <p className="text-xs text-white/60">{selectedQuickVibe.neighborhood}</p>
                      </div>
                    </div>
                    <button
                      onClick={() => setSelectedQuickVibe(null)}
                      className="w-8 h-8 rounded-full bg-white/10 flex items-center justify-center hover:bg-white/20 transition"
                    >
                      <X className="w-5 h-5 text-white" />
                    </button>
                  </div>

                  <div className="mb-4 p-4 bg-white/5 rounded-2xl border border-white/10">
                    <p className="text-base text-white/90 leading-relaxed">{selectedQuickVibe.text}</p>
                  </div>

                  <div className="flex items-center justify-between text-xs text-white/50">
                    <span className="flex items-center gap-1">
                      <Clock className="w-3 h-3" />
                      {timeAgo(selectedQuickVibe.created_at)}
                    </span>
                    <span>Expires in {Math.round((new Date(selectedQuickVibe.expires_at).getTime() - Date.now()) / (1000 * 60 * 60))}h</span>
                  </div>
                </div>
              </motion.div>
            </>
          )}
        </AnimatePresence>

        {/* Voting Section - Kalshi Style Carousel */}
        <div className="px-3 sm:px-4 py-4 sm:py-6 border-b border-white/10">
          <div className="max-w-4xl mx-auto">
            <div className="flex items-center justify-between mb-4 px-2">
              <h2 className="text-base sm:text-lg font-bold text-white flex items-center gap-2">
                <span className="text-lg sm:text-xl">🎯</span>
                Community Votes
              </h2>
              <span className="text-xs text-white/60">Tap to pick your side</span>
            </div>

            {/* Horizontal Carousel */}
            <div className="flex gap-3 overflow-x-auto hide-scrollbar pb-2">
              {votingPolls.map((poll, index) => (
                <VotingCard
                  key={poll.id}
                  question={poll.question}
                  optionA={poll.optionA}
                  optionB={poll.optionB}
                  votesA={poll.votesA}
                  votesB={poll.votesB}
                  userVote={userVotes[poll.id] || null}
                  onVote={(option) => handleVote(poll.id, option)}
                />
              ))}
            </div>
          </div>
        </div>

        {/* Playlists Filter - Mobile Scrollable */}
        <div className="px-3 sm:px-4 py-4 sm:py-6 border-b border-white/10">
          <div className="max-w-4xl mx-auto">
            <div className="flex gap-2 overflow-x-auto hide-scrollbar pb-2">
              {playlists.map((playlist) => (
                <button
                  key={playlist.id}
                  onClick={() => setActiveFilter(playlist.tag_filter)}
                  className={`flex items-center gap-2 px-3 sm:px-4 py-2 rounded-full whitespace-nowrap text-xs sm:text-sm font-medium transition flex-shrink-0 ${
                    activeFilter === playlist.tag_filter
                      ? 'bg-gradient-to-r from-primary to-purple-500 text-white'
                      : 'bg-white/5 text-white/70 hover:bg-white/10'
                  }`}
                >
                  <span>{playlist.emoji}</span>
                  <span className="hidden sm:inline">{playlist.name}</span>
                </button>
              ))}
            </div>
          </div>
        </div>

        {/* Recent vs Popular Toggle + View Mode */}
        <div className="px-3 sm:px-4 py-3 sm:py-4 border-b border-white/10">
          <div className="max-w-4xl mx-auto flex items-center justify-between">
            {/* Sort Mode */}
            <div className="flex items-center gap-2">
              <button
                onClick={() => setSortMode('recent')}
                className={`px-3 sm:px-4 py-1.5 sm:py-2 rounded-lg text-xs sm:text-sm font-medium transition-all ${
                  sortMode === 'recent'
                    ? 'bg-primary text-white shadow-lg shadow-primary/30'
                    : 'bg-white/5 text-white/60 hover:bg-white/10 hover:text-white/80'
                }`}
              >
                <Clock className="w-3.5 h-3.5 sm:w-4 sm:h-4 inline mr-1.5" />
                Recent
              </button>
              <button
                onClick={() => setSortMode('popular')}
                className={`px-3 sm:px-4 py-1.5 sm:py-2 rounded-lg text-xs sm:text-sm font-medium transition-all ${
                  sortMode === 'popular'
                    ? 'bg-primary text-white shadow-lg shadow-primary/30'
                    : 'bg-white/5 text-white/60 hover:bg-white/10 hover:text-white/80'
                }`}
              >
                <TrendingUp className="w-3.5 h-3.5 sm:w-4 sm:h-4 inline mr-1.5" />
                Popular
              </button>
            </div>

            {/* View Mode */}
            <div className="flex items-center gap-2">
              <button
                onClick={() => setFeedView('timeline')}
                className={`px-3 sm:px-4 py-1.5 sm:py-2 rounded-lg text-xs sm:text-sm font-medium transition-all ${
                  feedView === 'timeline'
                    ? 'bg-primary text-white shadow-lg shadow-primary/30'
                    : 'bg-white/5 text-white/60 hover:bg-white/10 hover:text-white/80'
                }`}
              >
                Timeline
              </button>
              <button
                onClick={() => setFeedView('neighborhood')}
                className={`px-3 sm:px-4 py-1.5 sm:py-2 rounded-lg text-xs sm:text-sm font-medium transition-all ${
                  feedView === 'neighborhood'
                    ? 'bg-primary text-white shadow-lg shadow-primary/30'
                    : 'bg-white/5 text-white/60 hover:bg-white/10 hover:text-white/80'
                }`}
              >
                <MapPin className="w-3.5 h-3.5 sm:w-4 sm:h-4 inline mr-1.5" />
                By Neighborhood
              </button>
            </div>
          </div>
        </div>

        {/* Feed - Mobile Optimized */}
        <div className="px-3 sm:px-4 py-4 sm:py-6">
          <div className="max-w-4xl mx-auto space-y-3 sm:space-y-4">
            {loading ? (
              <div className="text-center py-12">
                <div className="w-12 h-12 border-4 border-white/20 border-t-primary rounded-full animate-spin mx-auto mb-4" />
                <p className="text-white/60 text-sm">Loading vibes...</p>
              </div>
            ) : filteredLogs.length === 0 ? (
              <div className="text-center py-12">
                <Users className="w-16 h-16 text-white/20 mx-auto mb-4" />
                <p className="text-white/60 text-sm sm:text-base mb-2">No vibes yet in this category</p>
                <p className="text-white/40 text-xs sm:text-sm">Be the first to share!</p>
              </div>
            ) : feedView === 'timeline' ? (
              // Timeline View
              filteredLogs.map((log) => (
                <VibeLogCard key={log.id} log={log} onLike={handleLike} />
              ))
            ) : (
              // Neighborhood Grouped View
              Object.entries(groupedByNeighborhood)
                .sort(([, a], [, b]) => b.length - a.length) // Sort by most vibes
                .map(([neighborhood, vibes]) => (
                  <div key={neighborhood} className="space-y-3">
                    {/* Neighborhood Header */}
                    <div className="flex items-center gap-2 px-3 py-2 bg-white/5 rounded-xl border border-white/10">
                      <MapPin className="w-4 h-4 text-primary" />
                      <h3 className="text-sm sm:text-base font-bold text-white">{neighborhood}</h3>
                      <span className="ml-auto text-xs text-white/60 bg-white/10 px-2 py-0.5 rounded-full">
                        {vibes.length} {vibes.length === 1 ? 'vibe' : 'vibes'}
                      </span>
                    </div>

                    {/* Vibes in this neighborhood */}
                    <div className="space-y-3 sm:space-y-4">
                      {vibes.map((log) => (
                        <VibeLogCard key={log.id} log={log} onLike={handleLike} />
                      ))}
                    </div>
                  </div>
                ))
            )}
          </div>
        </div>

        {/* Floating Action Button - Mobile Optimized */}
        <motion.button
          initial={{ scale: 0 }}
          animate={{ scale: 1 }}
          whileHover={{ scale: 1.1 }}
          whileTap={{ scale: 0.95 }}
          onClick={() => setIsPostModalOpen(true)}
          className="fixed bottom-20 sm:bottom-24 right-4 sm:right-6 w-14 h-14 sm:w-16 sm:h-16 bg-gradient-to-tr from-pink-500 to-indigo-500 rounded-full flex items-center justify-center text-white shadow-xl shadow-indigo-500/40 z-40"
        >
          <Plus className="w-7 h-7 sm:w-8 sm:h-8" />
        </motion.button>
      </div>

      <Toast message={toast.message} show={toast.show} />
      <QuickVibeModal
        isOpen={isQuickVibeModalOpen}
        onClose={() => setIsQuickVibeModalOpen(false)}
        onSubmit={handleCreateQuickVibe}
      />
      <NewPostModal
        isOpen={isPostModalOpen}
        onClose={() => setIsPostModalOpen(false)}
        onSubmit={handleCreatePost}
      />

      {/* Bottom Navigation */}
      <BottomNav />

      {/* Tutorial */}
      <Tutorial
        steps={pulseTutorialSteps}
        tutorialKey="pulse"
        onComplete={() => {}}
        onSkip={() => {}}
      />

      <style jsx global>{`
        .hide-scrollbar::-webkit-scrollbar {
          display: none;
        }
        .hide-scrollbar {
          -ms-overflow-style: none;
          scrollbar-width: none;
        }
      `}</style>
    </>
  );
}
