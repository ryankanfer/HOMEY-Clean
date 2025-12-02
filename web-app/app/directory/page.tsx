'use client';

import { useState, useEffect, useRef } from 'react';
import { useRouter } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';
import CinematicBackground from '@/components/CinematicBackground';
import BottomNav from '@/components/BottomNav';
import { auth, db } from '@/lib/supabase';
import { useClientAgent } from '@/hooks/useClientAgent';
import {
  Play,
  Pause,
  Star,
  Check,
  Calendar,
  Phone,
  Mail,
  MessageCircle,
  Award,
  Clock,
  ChevronRight,
  Grid3x3,
  List,
  X
} from 'lucide-react';

// Squad Role Types
type SquadRole = 'agent' | 'lender' | 'inspector' | 'lawyer';

interface SquadSlot {
  role: SquadRole;
  title: string;
  icon: string;
  filled: boolean;
  professional?: Professional;
}

interface Professional {
  id: string;
  name: string;
  role: string;
  category: SquadRole;
  company: string;
  phone: string;
  email: string;
  avatar?: string;
  rating: number;
  reviewCount: number;
  verified: boolean;
  sarahsPick?: boolean;
  matchScore?: number;
  specializations: string[];
  serviceAreas: string[];
  yearsExperience: number;
  nextAvailable?: string; // e.g., "Tomorrow 10am", "Today 2pm"
  audioIntro?: string; // URL to audio introduction
  bio: string;
  recentReview?: {
    text: string;
    author: string;
    rating: number;
  };
  successStories?: number;
  responseTime?: string; // e.g., "within 2 hours"
}

// Sample professionals with rich data
const SAMPLE_PROFESSIONALS: Professional[] = [
  {
    id: '1',
    name: 'Sarah Chen',
    role: 'Real Estate Agent',
    category: 'agent',
    company: 'Flatiron Living Realty',
    phone: '(555) 123-4567',
    email: 'sarah@flatironliving.com',
    rating: 4.9,
    reviewCount: 127,
    verified: true,
    sarahsPick: true, // Your assigned agent
    matchScore: 98,
    specializations: ['First-time buyers', 'Manhattan rentals', 'Luxury apartments'],
    serviceAreas: ['Chelsea', 'Flatiron', 'Gramercy'],
    yearsExperience: 8,
    nextAvailable: 'Today 3pm',
    audioIntro: '/audio/sarah-intro.mp3', // Placeholder
    bio: 'I specialize in helping first-time buyers navigate the NYC real estate market. My goal is to make your home search stress-free and successful.',
    successStories: 156,
    responseTime: 'within 1 hour',
    recentReview: {
      text: 'Sarah helped us find our dream apartment in under 2 weeks! She understood exactly what we were looking for.',
      author: 'Jessica M.',
      rating: 5,
    },
  },
  {
    id: '2',
    name: 'Michael Jin',
    role: 'Mortgage Lender',
    category: 'lender',
    company: 'Prime Home Loans',
    phone: '(555) 987-6543',
    email: 'mjin@primeloans.com',
    rating: 4.8,
    reviewCount: 203,
    verified: true,
    sarahsPick: true,
    matchScore: 92,
    specializations: ['First-time buyers', 'FHA loans', 'Pre-approval'],
    serviceAreas: ['New York', 'New Jersey', 'Connecticut'],
    yearsExperience: 12,
    nextAvailable: 'Tomorrow 10am',
    audioIntro: '/audio/michael-intro.mp3',
    bio: 'With over a decade of experience, I help first-time buyers secure the best rates and navigate the mortgage process with confidence.',
    successStories: 342,
    responseTime: 'within 2 hours',
    recentReview: {
      text: 'Michael got us the best rate and made the process so easy. Highly recommend!',
      author: 'Tom R.',
      rating: 5,
    },
  },
  {
    id: '3',
    name: 'Emma Rodriguez',
    role: 'Home Inspector',
    category: 'inspector',
    company: 'TruCheck Inspections',
    phone: '(555) 456-7890',
    email: 'emma@trucheck.com',
    rating: 5.0,
    reviewCount: 156,
    verified: true,
    sarahsPick: true,
    matchScore: 95,
    specializations: ['Residential', 'Pre-purchase', 'Move-in inspections'],
    serviceAreas: ['Manhattan', 'Brooklyn', 'Queens'],
    yearsExperience: 15,
    nextAvailable: 'Friday 9am',
    audioIntro: '/audio/emma-intro.mp3',
    bio: 'I provide comprehensive home inspections that give you peace of mind. Every detail matters when making the biggest investment of your life.',
    successStories: 487,
    responseTime: 'within 3 hours',
    recentReview: {
      text: 'Very thorough inspection. Emma caught issues we would have never noticed.',
      author: 'David L.',
      rating: 5,
    },
  },
  {
    id: '4',
    name: 'Robert Goldstein',
    role: 'Real Estate Attorney',
    category: 'lawyer',
    company: 'Goldstein & Associates',
    phone: '(555) 234-5678',
    email: 'rgoldstein@goldsteinlaw.com',
    rating: 4.9,
    reviewCount: 284,
    verified: true,
    matchScore: 89,
    specializations: ['Contract review', 'Closings', 'Co-op/Condo transactions'],
    serviceAreas: ['New York City'],
    yearsExperience: 22,
    nextAvailable: 'Next week Mon',
    audioIntro: '/audio/robert-intro.mp3',
    bio: 'I protect my clients through every step of the transaction. With 22 years of experience, I ensure your interests are represented.',
    successStories: 612,
    responseTime: 'within 4 hours',
    recentReview: {
      text: 'Robert was incredibly thorough and caught several issues in our contract. Worth every penny.',
      author: 'Lisa K.',
      rating: 5,
    },
  },
  {
    id: '5',
    name: 'Jennifer Park',
    role: 'Real Estate Attorney',
    category: 'lawyer',
    company: 'Park Legal Group',
    phone: '(555) 345-6789',
    email: 'jpark@parklegal.com',
    rating: 4.7,
    reviewCount: 142,
    verified: true,
    sarahsPick: true,
    matchScore: 87,
    specializations: ['First-time buyers', 'Contract negotiation', 'Title review'],
    serviceAreas: ['Manhattan', 'Brooklyn'],
    yearsExperience: 10,
    nextAvailable: 'Wed 2pm',
    audioIntro: '/audio/jennifer-intro.mp3',
    bio: 'I make complex legal processes simple. My mission is to help first-time buyers feel confident and protected.',
    successStories: 298,
    responseTime: 'within 2 hours',
    recentReview: {
      text: 'Jennifer explained everything clearly and made sure we understood every step. Highly recommend!',
      author: 'Marcus T.',
      rating: 5,
    },
  },
];

export default function DirectoryPage() {
  const router = useRouter();
  const { agent: agentConnection, hasAgent } = useClientAgent();
  const [professionals, setProfessionals] = useState<Professional[]>(SAMPLE_PROFESSIONALS);
  const [selectedCategory, setSelectedCategory] = useState<SquadRole | 'all'>('all');
  const [searchQuery, setSearchQuery] = useState('');
  const [viewMode, setViewMode] = useState<'list' | 'focus'>('list');
  const [focusedProfessional, setFocusedProfessional] = useState<Professional | null>(null);
  const [playingAudio, setPlayingAudio] = useState<string | null>(null);
  const [savedProfessionals, setSavedProfessionals] = useState<Set<string>>(new Set());
  const [squadSlots, setSquadSlots] = useState<SquadSlot[]>([]);
  const audioRef = useRef<HTMLAudioElement | null>(null);

  // Get agent name for display
  const agentName = agentConnection?.agent?.user?.full_name || 'Your Agent';
  const agentFirstName = agentName.split(' ')[0];

  useEffect(() => {
    initSquad();
  }, [professionals]);

  const initSquad = () => {
    const slots: SquadSlot[] = [
      {
        role: 'agent',
        title: 'Your Agent',
        icon: '🏢',
        filled: false,
        professional: undefined,
      },
      {
        role: 'lender',
        title: 'Your Lender',
        icon: '💰',
        filled: false,
        professional: undefined,
      },
      {
        role: 'inspector',
        title: 'Your Inspector',
        icon: '🔍',
        filled: false,
        professional: undefined,
      },
      {
        role: 'lawyer',
        title: 'Your Attorney',
        icon: '⚖️',
        filled: false,
        professional: undefined,
      },
    ];

    // Fill slots with Sarah's Picks or top-rated professionals
    slots.forEach((slot) => {
      const match = professionals.find(
        (p) => p.category === slot.role && p.sarahsPick
      ) || professionals.find((p) => p.category === slot.role);

      if (match) {
        slot.filled = true;
        slot.professional = match;
      }
    });

    setSquadSlots(slots);
  };

  const filteredProfessionals = professionals.filter((pro) => {
    const matchesCategory = selectedCategory === 'all' || pro.category === selectedCategory;
    const matchesSearch =
      searchQuery === '' ||
      pro.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      pro.company.toLowerCase().includes(searchQuery.toLowerCase()) ||
      pro.specializations.some((s) => s.toLowerCase().includes(searchQuery.toLowerCase()));
    return matchesCategory && matchesSearch;
  });

  // Sort: Sarah's Picks first, then by match score
  const sortedProfessionals = [...filteredProfessionals].sort((a, b) => {
    if (a.sarahsPick && !b.sarahsPick) return -1;
    if (!a.sarahsPick && b.sarahsPick) return 1;
    return (b.matchScore || 0) - (a.matchScore || 0);
  });

  const toggleAudio = (professionalId: string, audioUrl?: string) => {
    if (!audioUrl) return;

    if (playingAudio === professionalId) {
      audioRef.current?.pause();
      setPlayingAudio(null);
    } else {
      if (audioRef.current) {
        audioRef.current.pause();
      }
      // In production, this would load and play the actual audio file
      setPlayingAudio(professionalId);

      // Simulate audio playback
      setTimeout(() => {
        setPlayingAudio(null);
      }, 15000); // Auto-stop after 15 seconds
    }
  };

  const triggerHaptic = () => {
    if ('vibrate' in navigator) {
      navigator.vibrate(50);
    }
  };

  const handleProfessionalClick = (pro: Professional) => {
    triggerHaptic();
    if (viewMode === 'focus') {
      setFocusedProfessional(pro);
    } else {
      setFocusedProfessional(pro);
    }
  };

  const toggleSave = (proId: string) => {
    triggerHaptic();
    setSavedProfessionals((prev) => {
      const newSet = new Set(prev);
      if (newSet.has(proId)) {
        newSet.delete(proId);
      } else {
        newSet.add(proId);
      }
      return newSet;
    });
  };

  return (
    <main className="relative min-h-screen pb-24">
      <CinematicBackground timeOfDay="sunset" />

      {/* Header */}
      <header className="relative z-20 px-5 py-6 bg-gradient-to-b from-black/80 via-black/50 to-transparent">
        <div className="flex items-center gap-4 mb-6">
          <button
            onClick={() => router.push('/home')}
            className="text-white/80 hover:text-white transition-colors"
          >
            ← Back
          </button>
          <div className="flex-1">
            <h1 className="text-3xl font-bold text-white">🎯 Build Your Squad</h1>
            <p className="text-white/60 text-sm mt-1">Assemble your dream team</p>
          </div>

          {/* View Toggle */}
          <div className="flex gap-2 bg-white/10 rounded-lg p-1">
            <button
              onClick={() => setViewMode('list')}
              className={`p-2 rounded transition-all ${
                viewMode === 'list'
                  ? 'bg-white/20 text-white'
                  : 'text-white/50 hover:text-white/80'
              }`}
            >
              <List className="w-4 h-4" />
            </button>
            <button
              onClick={() => setViewMode('focus')}
              className={`p-2 rounded transition-all ${
                viewMode === 'focus'
                  ? 'bg-white/20 text-white'
                  : 'text-white/50 hover:text-white/80'
              }`}
            >
              <Grid3x3 className="w-4 h-4" />
            </button>
          </div>
        </div>

        {/* Search */}
        <div className="relative mb-6">
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search by name, company, or specialty..."
            className="w-full px-4 py-3 pl-12 bg-white/10 border border-white/20 rounded-xl text-white placeholder:text-white/40 focus:outline-none focus:border-purple-500/50 backdrop-blur-sm"
          />
          <span className="absolute left-4 top-1/2 -translate-y-1/2 text-xl">🔍</span>
        </div>

        {/* Your Squad Grid */}
        <div className="mb-6">
          <div className="flex items-center justify-between mb-3">
            <h2 className="text-lg font-bold text-white">Your Squad</h2>
            <span className="text-xs text-white/50">
              {squadSlots.filter((s) => s.filled).length}/{squadSlots.length} recruited
            </span>
          </div>

          <div className="grid grid-cols-2 gap-3">
            {squadSlots.map((slot) => (
              <motion.div
                key={slot.role}
                className={`glass-strong rounded-2xl overflow-hidden border ${
                  slot.filled
                    ? 'border-green-400/30 bg-green-500/5'
                    : 'border-purple-500/30 bg-gradient-to-br from-purple-500/5 to-pink-500/5'
                }`}
                whileTap={{ scale: 0.98 }}
                onClick={() => {
                  triggerHaptic();
                  if (slot.professional) {
                    handleProfessionalClick(slot.professional);
                  } else {
                    setSelectedCategory(slot.role);
                    // Scroll to professionals list
                    window.scrollTo({ top: 400, behavior: 'smooth' });
                  }
                }}
              >
                <div className="p-4">
                  <div className="flex items-center gap-3 mb-2">
                    <div
                      className={`w-12 h-12 rounded-full flex items-center justify-center text-2xl flex-shrink-0 ${
                        slot.filled
                          ? 'bg-gradient-to-br from-green-400 to-emerald-500'
                          : 'bg-gradient-to-br from-purple-500/20 to-pink-500/20 border-2 border-dashed border-purple-400/40'
                      }`}
                    >
                      {slot.filled && slot.professional ? (
                        <span className="text-white font-bold">{slot.professional.name.charAt(0)}</span>
                      ) : (
                        <motion.span
                          className="text-purple-300 text-xl font-bold"
                          animate={{ scale: [1, 1.1, 1] }}
                          transition={{ duration: 2, repeat: Infinity, ease: "easeInOut" }}
                        >
                          +
                        </motion.span>
                      )}
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-xs text-white/50 mb-0.5">{slot.title}</p>
                      {slot.filled && slot.professional ? (
                        <p className="text-white font-semibold text-sm truncate">
                          {slot.professional.name.split(' ')[0]}
                        </p>
                      ) : (
                        <p className="text-purple-300 text-sm font-medium">Empty slot</p>
                      )}
                    </div>
                    {slot.filled && (
                      <Check className="w-4 h-4 text-green-400 flex-shrink-0" />
                    )}
                  </div>

                  {/* Add button for empty slots */}
                  {!slot.filled && (
                    <motion.button
                      className="w-full mt-2 px-3 py-2 bg-gradient-to-r from-purple-500 to-pink-500 hover:opacity-90 text-white text-xs font-semibold rounded-lg transition-all flex items-center justify-center gap-2"
                      whileHover={{ scale: 1.02 }}
                      whileTap={{ scale: 0.98 }}
                      onClick={(e) => {
                        e.stopPropagation();
                        triggerHaptic();
                        setSelectedCategory(slot.role);
                        window.scrollTo({ top: 400, behavior: 'smooth' });
                      }}
                    >
                      <span>Add {slot.title.replace('Your ', '')}</span>
                      <ChevronRight className="w-3 h-3" />
                    </motion.button>
                  )}
                </div>
              </motion.div>
            ))}
          </div>
        </div>

        {/* Category Filters */}
        <div className="overflow-x-auto scrollbar-hide">
          <div className="flex gap-2 pb-2">
            {[
              { id: 'all', label: 'All', icon: '👥' },
              { id: 'agent', label: 'Agents', icon: '🏢' },
              { id: 'lender', label: 'Lenders', icon: '💰' },
              { id: 'inspector', label: 'Inspectors', icon: '🔍' },
              { id: 'lawyer', label: 'Attorneys', icon: '⚖️' },
            ].map((cat) => (
              <button
                key={cat.id}
                onClick={() => setSelectedCategory(cat.id as any)}
                className={`px-4 py-2 rounded-full text-sm font-semibold whitespace-nowrap transition-all ${
                  selectedCategory === cat.id
                    ? 'bg-gradient-to-r from-purple-500 to-pink-500 text-white'
                    : 'bg-white/10 text-white/70 hover:bg-white/20'
                }`}
              >
                {cat.icon} {cat.label}
              </button>
            ))}
          </div>
        </div>
      </header>

      {/* Content */}
      <div className="relative z-10 px-5 space-y-4">
        {/* No results message - but not a dead end */}
        {sortedProfessionals.length === 0 && (
          <div className="glass-strong rounded-2xl p-8 text-center border border-white/10">
            <div className="text-6xl mb-4">🔍</div>
            <h3 className="text-xl font-semibold text-white mb-2">No matches found</h3>
            <p className="text-white/60 mb-4">Try adjusting your search or filters</p>
            <p className="text-white/50 text-sm">
              Don't worry! {agentFirstName} can help you find the perfect match below ⬇️
            </p>
          </div>
        )}

        {/* Professional Cards */}
        {sortedProfessionals.length > 0 && (
          <>
            {sortedProfessionals.map((pro, index) => (
              <motion.div
                key={pro.id}
                className="glass-strong rounded-2xl overflow-hidden border border-white/10 hover:border-purple-500/30 transition-all cursor-pointer"
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: index * 0.05 }}
                whileTap={{ scale: 0.98 }}
                onClick={() => handleProfessionalClick(pro)}
              >
                <div className="p-5">
                  {/* Agent's Pick Badge */}
                  {pro.sarahsPick && (
                    <div className="mb-3 flex items-center gap-2">
                      <div className="px-3 py-1.5 bg-gradient-to-r from-purple-500/20 to-pink-500/20 border border-purple-500/30 rounded-full flex items-center gap-2">
                        <Award className="w-3 h-3 text-purple-300" />
                        <span className="text-purple-200 text-xs font-bold">{agentFirstName}'s Pick</span>
                      </div>
                      {pro.matchScore && (
                        <span className="text-xs text-white/50">{pro.matchScore}% match</span>
                      )}
                    </div>
                  )}

                  <div className="flex items-start gap-4">
                    {/* Avatar */}
                    <div className="relative">
                      <div className="w-16 h-16 rounded-full bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center text-2xl font-bold text-white flex-shrink-0">
                        {pro.name.charAt(0)}
                      </div>
                      {pro.verified && (
                        <div className="absolute -bottom-1 -right-1 w-5 h-5 bg-blue-500 rounded-full border-2 border-slate-900 flex items-center justify-center">
                          <Check className="w-3 h-3 text-white" />
                        </div>
                      )}
                    </div>

                    {/* Info */}
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2 mb-1">
                        <h3 className="text-white font-bold text-lg">{pro.name}</h3>
                        <button
                          onClick={(e) => {
                            e.stopPropagation();
                            toggleSave(pro.id);
                          }}
                          className="ml-auto text-lg"
                        >
                          {savedProfessionals.has(pro.id) ? '❤️' : '🤍'}
                        </button>
                      </div>

                      <p className="text-white/80 text-sm mb-2">
                        {pro.role} • {pro.company}
                      </p>

                      <div className="flex items-center gap-3 text-white/60 text-xs mb-3">
                        <span className="flex items-center gap-1">
                          <Star className="w-3 h-3 fill-yellow-400 text-yellow-400" />
                          {pro.rating.toFixed(1)} ({pro.reviewCount})
                        </span>
                        <span>•</span>
                        <span>{pro.yearsExperience} years</span>
                      </div>

                      {/* Availability */}
                      {pro.nextAvailable && (
                        <div className="flex items-center gap-2 mb-3 px-3 py-1.5 bg-green-500/10 border border-green-500/30 rounded-lg inline-flex">
                          <Calendar className="w-3 h-3 text-green-400" />
                          <span className="text-green-300 text-xs font-semibold">
                            Next: {pro.nextAvailable}
                          </span>
                        </div>
                      )}

                      {/* Audio Intro */}
                      {pro.audioIntro && (
                        <button
                          onClick={(e) => {
                            e.stopPropagation();
                            toggleAudio(pro.id, pro.audioIntro);
                          }}
                          className="flex items-center gap-2 px-3 py-2 bg-white/10 hover:bg-white/20 rounded-lg transition-colors mb-3"
                        >
                          {playingAudio === pro.id ? (
                            <>
                              <Pause className="w-4 h-4 text-white" />
                              <span className="text-white text-xs font-medium">Playing intro...</span>
                            </>
                          ) : (
                            <>
                              <Play className="w-4 h-4 text-white" />
                              <span className="text-white text-xs font-medium">Play intro (0:42)</span>
                            </>
                          )}
                        </button>
                      )}

                      {/* Specializations */}
                      <div className="flex flex-wrap gap-2">
                        {pro.specializations.slice(0, 2).map((spec, idx) => (
                          <span
                            key={idx}
                            className="px-2 py-1 bg-white/10 text-white/70 text-xs rounded-lg"
                          >
                            {spec}
                          </span>
                        ))}
                      </div>
                    </div>

                    <ChevronRight className="w-5 h-5 text-white/40 flex-shrink-0 mt-2" />
                  </div>
                </div>
              </motion.div>
            ))}
          </>
        )}

        {/* Ask Sarah Card (Concierge Fallback) - ALWAYS VISIBLE */}
        <motion.div
          className="glass-strong rounded-2xl p-6 border border-purple-500/30 bg-gradient-to-br from-purple-500/10 to-pink-500/10"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: sortedProfessionals.length * 0.05 + 0.2 }}
        >
          <div className="flex items-start gap-4">
            <div className="w-14 h-14 rounded-full bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center text-2xl flex-shrink-0">
              💬
            </div>
            <div className="flex-1">
              <h3 className="text-white font-bold text-lg mb-2">
                {sortedProfessionals.length === 0
                  ? `Let ${agentFirstName} find the perfect match`
                  : "Can't find the right match?"}
              </h3>
              <p className="text-white/70 text-sm mb-4 leading-relaxed">
                {sortedProfessionals.length === 0
                  ? `${agentFirstName} has access to their entire trusted network of professionals. Tell them what you're looking for and they'll personally match you with the right expert.`
                  : `Ask ${agentFirstName} to personally recommend a professional from their trusted network. They'll match you based on your specific needs.`}
              </p>
              <button
                onClick={() => {
                  triggerHaptic();
                  router.push('/home');
                }}
                className="px-6 py-3 bg-gradient-to-r from-purple-500 to-pink-500 hover:opacity-90 text-white font-semibold rounded-xl transition-all active:scale-95 flex items-center gap-2"
              >
                <MessageCircle className="w-4 h-4" />
                {sortedProfessionals.length === 0 ? `Get ${agentFirstName}'s Help` : `Message ${agentFirstName}`}
              </button>
            </div>
          </div>
        </motion.div>
      </div>

      {/* Professional Focus Modal */}
      <AnimatePresence>
        {focusedProfessional && (
          <motion.div
            className="fixed inset-0 z-[200] bg-black/80 backdrop-blur-sm flex items-end sm:items-center justify-center p-0 sm:p-5"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={() => setFocusedProfessional(null)}
          >
            <motion.div
              className="bg-gradient-to-b from-slate-900 to-slate-800 sm:rounded-3xl rounded-t-3xl w-full sm:max-w-2xl max-h-[90vh] overflow-y-auto border border-white/10"
              initial={{ y: '100%', opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
              exit={{ y: '100%', opacity: 0 }}
              transition={{ type: 'spring', damping: 30, stiffness: 300 }}
              onClick={(e) => e.stopPropagation()}
            >
              <div className="sticky top-0 bg-slate-900/95 backdrop-blur-xl z-10 p-6 border-b border-white/10">
                <div className="flex items-start gap-4">
                  <div className="relative">
                    <div className="w-20 h-20 rounded-full bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center text-3xl font-bold text-white">
                      {focusedProfessional.name.charAt(0)}
                    </div>
                    {focusedProfessional.verified && (
                      <div className="absolute -bottom-1 -right-1 w-6 h-6 bg-blue-500 rounded-full border-2 border-slate-900 flex items-center justify-center">
                        <Check className="w-4 h-4 text-white" />
                      </div>
                    )}
                  </div>
                  <div className="flex-1">
                    <h2 className="text-2xl font-bold text-white mb-1">
                      {focusedProfessional.name}
                    </h2>
                    <p className="text-white/70 text-sm mb-2">
                      {focusedProfessional.role} at {focusedProfessional.company}
                    </p>
                    <div className="flex items-center gap-3 text-white/60 text-sm">
                      <span className="flex items-center gap-1">
                        <Star className="w-4 h-4 fill-yellow-400 text-yellow-400" />
                        {focusedProfessional.rating.toFixed(1)} ({focusedProfessional.reviewCount})
                      </span>
                      <span>•</span>
                      <span>{focusedProfessional.yearsExperience} years</span>
                    </div>
                  </div>
                  <button
                    onClick={() => setFocusedProfessional(null)}
                    className="p-2 hover:bg-white/10 rounded-full transition-colors"
                  >
                    <X className="w-5 h-5 text-white/60" />
                  </button>
                </div>
              </div>

              <div className="p-6 space-y-6">
                {/* Agent's Pick */}
                {focusedProfessional.sarahsPick && (
                  <div className="p-4 bg-gradient-to-r from-purple-500/10 to-pink-500/10 border border-purple-500/30 rounded-xl">
                    <div className="flex items-center gap-3 mb-2">
                      <Award className="w-5 h-5 text-purple-300" />
                      <h3 className="text-white font-bold">{agentFirstName}'s Top Pick</h3>
                    </div>
                    <p className="text-white/70 text-sm leading-relaxed">
                      {agentFirstName} personally recommends {focusedProfessional.name.split(' ')[0]} based on your needs and preferences. They're trusted in their network and have an excellent track record.
                    </p>
                  </div>
                )}

                {/* Bio */}
                <div>
                  <h3 className="text-white font-bold mb-3">About</h3>
                  <p className="text-white/70 text-sm leading-relaxed">
                    {focusedProfessional.bio}
                  </p>
                </div>

                {/* Stats */}
                <div className="grid grid-cols-3 gap-3">
                  <div className="bg-white/5 rounded-xl p-4 text-center border border-white/10">
                    <div className="text-2xl font-bold text-white mb-1">
                      {focusedProfessional.successStories}
                    </div>
                    <div className="text-xs text-white/50">Success Stories</div>
                  </div>
                  <div className="bg-white/5 rounded-xl p-4 text-center border border-white/10">
                    <div className="text-2xl font-bold text-white mb-1">
                      {focusedProfessional.rating.toFixed(1)}
                    </div>
                    <div className="text-xs text-white/50">Rating</div>
                  </div>
                  <div className="bg-white/5 rounded-xl p-4 text-center border border-white/10">
                    <div className="text-2xl font-bold text-white mb-1">
                      {focusedProfessional.yearsExperience}
                    </div>
                    <div className="text-xs text-white/50">Years</div>
                  </div>
                </div>

                {/* Availability */}
                {focusedProfessional.nextAvailable && (
                  <div className="p-4 bg-green-500/10 border border-green-500/30 rounded-xl">
                    <div className="flex items-center gap-3 mb-2">
                      <Calendar className="w-5 h-5 text-green-400" />
                      <h3 className="text-white font-bold">Next Available</h3>
                    </div>
                    <p className="text-green-300 text-lg font-semibold">
                      {focusedProfessional.nextAvailable}
                    </p>
                    {focusedProfessional.responseTime && (
                      <p className="text-white/50 text-xs mt-1">
                        Usually responds {focusedProfessional.responseTime}
                      </p>
                    )}
                  </div>
                )}

                {/* Audio Intro */}
                {focusedProfessional.audioIntro && (
                  <div>
                    <h3 className="text-white font-bold mb-3">Voice Introduction</h3>
                    <button
                      onClick={() => toggleAudio(focusedProfessional.id, focusedProfessional.audioIntro)}
                      className="w-full p-4 bg-white/10 hover:bg-white/20 rounded-xl transition-all flex items-center justify-center gap-3"
                    >
                      {playingAudio === focusedProfessional.id ? (
                        <>
                          <Pause className="w-5 h-5 text-white" />
                          <span className="text-white font-medium">Playing introduction...</span>
                        </>
                      ) : (
                        <>
                          <Play className="w-5 h-5 text-white" />
                          <span className="text-white font-medium">
                            Listen to introduction (0:42)
                          </span>
                        </>
                      )}
                    </button>
                  </div>
                )}

                {/* Specializations */}
                <div>
                  <h3 className="text-white font-bold mb-3">Specializations</h3>
                  <div className="flex flex-wrap gap-2">
                    {focusedProfessional.specializations.map((spec, idx) => (
                      <span
                        key={idx}
                        className="px-3 py-2 bg-white/10 text-white text-sm rounded-lg border border-white/10"
                      >
                        {spec}
                      </span>
                    ))}
                  </div>
                </div>

                {/* Service Areas */}
                <div>
                  <h3 className="text-white font-bold mb-3">Service Areas</h3>
                  <p className="text-white/70">{focusedProfessional.serviceAreas.join(', ')}</p>
                </div>

                {/* Recent Review */}
                {focusedProfessional.recentReview && (
                  <div>
                    <h3 className="text-white font-bold mb-3">Recent Review</h3>
                    <div className="p-4 bg-white/5 rounded-xl border border-white/10">
                      <div className="flex items-center gap-1 mb-2">
                        {Array.from({ length: 5 }).map((_, i) => (
                          <Star
                            key={i}
                            className={`w-4 h-4 ${
                              i < focusedProfessional.recentReview!.rating
                                ? 'fill-yellow-400 text-yellow-400'
                                : 'text-white/20'
                            }`}
                          />
                        ))}
                      </div>
                      <p className="text-white/80 text-sm mb-2 leading-relaxed">
                        "{focusedProfessional.recentReview.text}"
                      </p>
                      <p className="text-white/50 text-xs">
                        - {focusedProfessional.recentReview.author}
                      </p>
                    </div>
                  </div>
                )}

                {/* Action Buttons */}
                <div className="flex gap-3 pt-4 border-t border-white/10">
                  <a
                    href={`mailto:${focusedProfessional.email}`}
                    className="flex-1 px-6 py-4 bg-gradient-to-r from-purple-500 to-pink-500 hover:opacity-90 text-white font-semibold rounded-xl transition-all active:scale-95 flex items-center justify-center gap-2"
                  >
                    <Mail className="w-4 h-4" />
                    Send Message
                  </a>
                  <a
                    href={`tel:${focusedProfessional.phone}`}
                    className="px-6 py-4 bg-white/10 hover:bg-white/20 text-white font-semibold rounded-xl transition-all active:scale-95 flex items-center justify-center gap-2"
                  >
                    <Phone className="w-4 h-4" />
                    Call
                  </a>
                </div>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      <BottomNav />
    </main>
  );
}
