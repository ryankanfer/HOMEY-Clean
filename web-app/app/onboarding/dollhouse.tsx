'use client';

import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useRouter } from 'next/navigation';
import {
  Home,
  User,
  MapPin,
  DollarSign,
  Users,
  Calendar,
  Sparkles,
  Shield,
  Phone,
  CheckCircle2,
  ArrowLeft,
  Bed,
  Heart,
} from 'lucide-react';
import { db, auth, agentDb } from '@/lib/supabase';
import { analytics } from '@/lib/analytics';
import { checkAdminFromProfile } from '@/lib/admin';

// Import all step components
import HouseRulesStep from '@/components/onboarding/HouseRulesStep';
import NameStep from '@/components/onboarding/NameStep';
import UserTypeStep from '@/components/onboarding/UserTypeStep';
import LocationStep from '@/components/onboarding/LocationStep';
import NeighborhoodStep from '@/components/onboarding/NeighborhoodStep';
import BudgetStep from '@/components/onboarding/BudgetStep';
import CrewStep from '@/components/onboarding/CrewStep';
import TimelineStep from '@/components/onboarding/TimelineStep';
import VibeCheckStep from '@/components/onboarding/VibeCheckStep';
import NonNegotiableStep from '@/components/onboarding/NonNegotiableStep';
import IncomeStep from '@/components/onboarding/IncomeStep';
import AgentStep from '@/components/onboarding/AgentStep';
import MatchTeaseStep from '@/components/onboarding/MatchTeaseStep';
import CompletionStep from '@/components/onboarding/CompletionStep';

export interface OnboardingData {
  acceptedTerms?: boolean;
  acceptedBeta?: boolean;
  termsAcceptedAt?: string;
  fullName?: string;
  displayName?: string;
  phone?: string;
  userType?: 'renter' | 'buyer' | 'browser';
  location?: 'new_york_city' | 'chicago' | 'los_angeles' | 'miami';
  neighborhoods?: string[];
  budgetMin?: number;
  budgetMax?: number;
  bedrooms?: number;
  bathrooms?: number;
  householdType?: string;
  timeline?: string;
  stylePreference?: string;
  mustHave?: string;
  householdIncome?: number;
  hasAgent?: boolean;
  agentName?: string;
  agentContact?: string;
  currentStep?: number;
}

const ROOMS = [
  // Intro
  { id: 'intro', name: "Let's Build Your Dream Home", x: 1, y: 3, color: '#6366f1', icon: Sparkles },

  // Foundation (Ground Rules)
  { id: 'house-rules', name: 'Ground Rules', x: 1, y: 2.5, color: '#1e293b', icon: Home },

  // Location (Where to build)
  { id: 'location', name: 'Where?', x: 0, y: 2, color: '#134e4a', icon: MapPin },
  { id: 'neighborhood', name: 'Which Neighborhood?', x: 1, y: 2, color: '#1e3a5f', icon: MapPin },

  // User Type & Budget (What kind of home)
  { id: 'user-type', name: 'Buying or Renting?', x: 2, y: 2, color: '#1e1b4b', icon: Users },
  { id: 'budget', name: 'Your Budget?', x: 0, y: 1, color: '#78350f', icon: DollarSign },

  // Size (How big)
  { id: 'crew', name: 'How Much Space?', x: 1, y: 1, color: '#4c1d95', icon: Bed },

  // Features & Style (Details)
  { id: 'non-negotiable', name: 'Must-Haves?', x: 2, y: 1, color: '#831843', icon: Heart },
  { id: 'vibe-check', name: 'Your Vibe?', x: 0, y: 0, color: '#581c87', icon: Sparkles },

  // Timeline
  { id: 'timeline', name: 'When?', x: 1, y: 0, color: '#0c4a6e', icon: Calendar },

  // Personal Info
  { id: 'name', name: 'Your Name?', x: 2, y: 0, color: '#0f172a', icon: User },
  { id: 'income', name: 'Income Verification', x: 0, y: -0.5, color: '#065f46', icon: DollarSign },
  { id: 'agent', name: 'Have an Agent?', x: 1, y: -0.5, color: '#14532d', icon: Phone },

  // Completion
  { id: 'match-tease', name: 'Finding Your Match...', x: 2, y: -0.5, color: '#1e40af', icon: Sparkles },
  { id: 'completion', name: 'Welcome Home!', x: 1, y: -1, color: '#0f766e', icon: CheckCircle2 },
];

export default function DollhouseOnboarding() {
  const router = useRouter();
  const [currentStep, setCurrentStep] = useState(0);
  const [isInsideRoom, setIsInsideRoom] = useState(false);
  const [userId, setUserId] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [data, setData] = useState<OnboardingData>({});
  const [agentConnection, setAgentConnection] = useState<any>(null);

  const getActiveRooms = () => {
    return ROOMS.filter(room => {
      if (room.id === 'income') {
        return data.location === 'new_york_city' && data.userType === 'renter';
      }
      return true;
    });
  };

  const activeRooms = getActiveRooms();
  const activeRoom = activeRooms[currentStep];

  useEffect(() => {
    loadUserAndProgress();
    analytics.pageView('onboarding_dollhouse');
  }, []);

  // Removed auto-advance - user must click to enter room

  const loadUserAndProgress = async () => {
    try {
      const { data: { user } } = await auth.getUser();
      if (!user) {
        router.push('/signup');
        return;
      }

      setUserId(user.id);
      const { data: profile } = await db.getProfile(user.id);
      const urlParams = new URLSearchParams(window.location.search);
      const forceOnboarding = urlParams.get('force') === 'true';
      const isAdmin = await checkAdminFromProfile(profile);

      if (profile?.onboarding_completed && !(isAdmin && forceOnboarding)) {
        router.push('/home');
        return;
      }

      const { data: connections } = await agentDb.getClientConnections(user.id);
      const activeConnection = connections?.find((c: any) => c.status === 'active');
      if (activeConnection) {
        setAgentConnection(activeConnection);
      }

      if (profile?.onboarding_data) {
        setData(profile.onboarding_data);
        setCurrentStep(profile.onboarding_step || 0);
      }

      setIsLoading(false);
    } catch (error) {
      console.error('Failed to load user:', error);
      setIsLoading(false);
    }
  };

  const saveProgress = async (updates: Partial<OnboardingData>) => {
    if (!userId) return;
    setIsSaving(true);

    try {
      const updatedData = { ...data, ...updates };
      setData(updatedData);
      await db.updateProfile(userId, {
        onboarding_data: updatedData,
        onboarding_step: currentStep,
      });
    } catch (error) {
      console.error('Failed to save progress:', error);
    } finally {
      setIsSaving(false);
    }
  };

  const handleNext = async (stepData: Partial<OnboardingData>) => {
    await saveProgress(stepData);
    setIsInsideRoom(false);

    setTimeout(() => {
      if (currentStep < activeRooms.length - 1) {
        setCurrentStep((prev) => prev + 1);
      }
    }, 1000);
  };

  const handleBack = () => {
    if (currentStep > 0) {
      setIsInsideRoom(false);
      setTimeout(() => {
        setCurrentStep((prev) => prev - 1);
      }, 1000);
    }
  };

  const handleComplete = async (finalData: Partial<OnboardingData>) => {
    if (!userId) return;
    setIsSaving(true);

    try {
      const completeData = { ...data, ...finalData };
      const allUpdates: Record<string, any> = {
        onboarding_data: completeData,
        onboarding_completed: true,
        onboarding_completed_at: new Date().toISOString(),
        full_name: completeData.fullName,
        phone: completeData.phone,
      };

      const profileUpdates = Object.fromEntries(
        Object.entries(allUpdates).filter(([_, value]) => value !== undefined)
      );

      await db.updateProfile(userId, profileUpdates);

      if (completeData.fullName) {
        await auth.updateUser({
          data: { full_name: completeData.fullName }
        });
      }

      analytics.completeOnboarding('dollhouse_onboarding');

      setTimeout(() => {
        router.push('/home');
      }, 2000);
    } catch (error) {
      console.error('Failed to complete onboarding:', error);
      setIsSaving(false);
    }
  };

  const renderStepComponent = (roomId: string) => {
    const commonProps = {
      data,
      onNext: handleNext,
      isSaving,
    };

    switch (roomId) {
      case 'intro': return (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="max-w-2xl mx-auto text-center px-6"
        >
          <motion.div
            animate={{ rotate: [0, 10, -10, 0] }}
            transition={{ duration: 2, repeat: Infinity }}
            className="text-7xl mb-6"
          >
            ✨
          </motion.div>
          <h1 className="text-4xl md:text-5xl font-bold text-white mb-4" style={{ fontFamily: 'Playfair Display, serif' }}>
            Let's Sketch Your Dream Home
          </h1>
          <p className="text-xl text-white/80 mb-8 leading-relaxed">
            Answer a few quick questions, and watch as AI draws your perfect space in real-time.
            It's like having an architect in your pocket! 🏡
          </p>
          <div className="bg-white/10 backdrop-blur-sm rounded-2xl p-6 mb-8 border border-white/20">
            <p className="text-white/70 text-sm leading-relaxed">
              <span className="font-semibold text-white">Pro tip:</span> Be specific!
              The more details you share, the more personalized your sketch becomes.
              Your answers literally shape the home we draw for you.
            </p>
          </div>
          <button
            onClick={() => handleNext({})}
            className="px-12 py-5 bg-gradient-to-r from-blue-600 to-purple-600 text-white rounded-2xl font-bold text-xl shadow-2xl hover:scale-105 transition-all"
          >
            Let's Build! →
          </button>
        </motion.div>
      );
      case 'house-rules': return <HouseRulesStep {...commonProps} />;
      case 'name': return <NameStep {...commonProps} />;
      case 'user-type': return <UserTypeStep {...commonProps} />;
      case 'location': return <LocationStep {...commonProps} />;
      case 'neighborhood': return <NeighborhoodStep {...commonProps} />;
      case 'budget': return <BudgetStep {...commonProps} />;
      case 'crew': return <CrewStep {...commonProps} />;
      case 'timeline': return <TimelineStep {...commonProps} />;
      case 'vibe-check': return <VibeCheckStep {...commonProps} />;
      case 'non-negotiable': return <NonNegotiableStep {...commonProps} />;
      case 'income': return <IncomeStep {...commonProps} />;
      case 'agent': return <AgentStep {...commonProps} agentConnection={agentConnection} />;
      case 'match-tease': return <MatchTeaseStep {...commonProps} />;
      case 'completion': return <CompletionStep {...commonProps} onComplete={handleComplete} />;
      default: return null;
    }
  };

  if (isLoading) {
    return (
      <div className="h-screen w-screen flex items-center justify-center bg-gradient-to-b from-sky-300 via-sky-200 to-green-100">
        <div className="w-16 h-16 border-4 border-white/30 border-t-cyan-500 rounded-full animate-spin" />
      </div>
    );
  }

  return (
    <div className="h-screen w-screen overflow-hidden relative" style={{ background: 'linear-gradient(135deg, #f5f1e8 0%, #e8e4d9 100%)' }}>
      {/* HUD - Only show when NOT inside room */}
      <AnimatePresence>
        {!isInsideRoom && (
          <motion.div
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            className="fixed top-0 left-0 w-full p-4 md:p-6 flex justify-between items-center z-50"
          >
            <div className="bg-white/95 backdrop-blur-md px-4 md:px-6 py-3 rounded-2xl shadow-xl border border-white/40">
              <h1 className="text-xl md:text-2xl font-bold bg-gradient-to-r from-cyan-600 to-blue-600 bg-clip-text text-transparent">
                Build Your Homey
              </h1>
              <div className="flex items-center gap-2 text-slate-600 text-xs md:text-sm mt-1">
                <MapPin className="w-3 h-3 md:w-4 md:h-4" />
                <span>
                  Room {currentStep + 1}/{activeRooms.length}: <span className="text-slate-900 font-bold">{activeRoom?.name}</span>
                </span>
              </div>
            </div>

            {currentStep > 0 && (
              <button
                onClick={handleBack}
                className="p-2 md:p-3 bg-white/95 backdrop-blur-md rounded-full shadow-lg hover:bg-white transition-all hover:scale-105 active:scale-95"
              >
                <ArrowLeft className="w-5 h-5 md:w-6 md:h-6 text-slate-900" />
              </button>
            )}
          </motion.div>
        )}
      </AnimatePresence>

      {/* Progress Indicator - Only show when NOT inside room */}
      <AnimatePresence>
        {!isInsideRoom && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: 20 }}
            className="fixed bottom-4 md:bottom-6 left-1/2 -translate-x-1/2 z-50"
          >
            <div className="flex gap-1.5 md:gap-2 bg-white/90 backdrop-blur-md px-3 md:px-4 py-2 md:py-3 rounded-full shadow-xl">
              {activeRooms.map((room, index) => (
                <div
                  key={room.id}
                  className={`w-2 h-2 md:w-3 md:h-3 rounded-full transition-all ${
                    index < currentStep
                      ? 'bg-green-500 shadow-lg shadow-green-500/50'
                      : index === currentStep
                      ? 'bg-cyan-500 shadow-lg shadow-cyan-500/50 scale-125'
                      : 'bg-slate-300'
                  }`}
                />
              ))}
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* ARCHITECT'S WORKSPACE - Progressive Home Sketch */}
      <AnimatePresence>
        {!isInsideRoom && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.6 }}
            className="h-full w-full relative overflow-hidden"
          >
            {/* Paper Texture Overlay */}
            <div
              className="absolute inset-0 opacity-30 pointer-events-none"
              style={{
                backgroundImage: `
                  repeating-linear-gradient(0deg, transparent, transparent 2px, rgba(200, 180, 150, 0.05) 2px, rgba(200, 180, 150, 0.05) 4px),
                  repeating-linear-gradient(90deg, transparent, transparent 2px, rgba(200, 180, 150, 0.05) 2px, rgba(200, 180, 150, 0.05) 4px)
                `,
                backgroundSize: '100px 100px',
              }}
            />

            {/* Drafting Table Grid Pattern */}
            <div
              className="absolute inset-0 opacity-10"
              style={{
                backgroundImage: `
                  linear-gradient(rgba(100, 100, 100, 0.15) 1px, transparent 1px),
                  linear-gradient(90deg, rgba(100, 100, 100, 0.15) 1px, transparent 1px)
                `,
                backgroundSize: '40px 40px',
              }}
            />

            {/* Design Tools Scattered Around */}
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 0.15 }}
              className="absolute top-8 right-8 text-6xl"
              style={{ transform: 'rotate(15deg)' }}
            >
              📐
            </motion.div>
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 0.15 }}
              className="absolute top-12 left-12 text-5xl"
              style={{ transform: 'rotate(-25deg)' }}
            >
              ✏️
            </motion.div>
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 0.15 }}
              className="absolute bottom-20 left-16 text-4xl"
              style={{ transform: 'rotate(45deg)' }}
            >
              📏
            </motion.div>

            {/* Center: Progressive House Sketch - Hide on intro */}
            {currentStep > 0 && (
            <div className="absolute top-[45%] left-1/2 -translate-x-1/2 -translate-y-1/2 w-full max-w-xl md:max-w-2xl px-6 md:px-8">
              <motion.div
                initial={{ opacity: 0, scale: 0.8 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ duration: 1 }}
                className="relative"
              >
                {/* Animated Pencil Following Current Drawing */}
                {currentStep < 8 && (
                  <motion.div
                    className="absolute z-20 pointer-events-none"
                    initial={{ opacity: 0 }}
                    animate={{
                      opacity: [0, 1, 1, 0],
                      x: [100, 150, 200, 250],
                      y: [80, 100, 120, 100],
                    }}
                    transition={{
                      duration: 2,
                      repeat: Infinity,
                      repeatDelay: 1,
                    }}
                  >
                    <div className="text-4xl" style={{ transform: 'rotate(45deg)' }}>
                      ✏️
                    </div>
                  </motion.div>
                )}

                {/* AI-Generated House Sketch - Builds Progressively */}
                <svg
                  viewBox="0 0 400 300"
                  className="w-full h-auto"
                  style={{ filter: 'drop-shadow(0 2px 8px rgba(0, 0, 0, 0.08))' }}
                >
                  {/* Watercolor Ground Fill */}
                  {currentStep >= 0 && (
                    <motion.rect
                      x="40"
                      y="235"
                      width="320"
                      height="20"
                      fill="url(#groundGradient)"
                      initial={{ opacity: 0 }}
                      animate={{ opacity: 0.3 }}
                      transition={{ duration: 1, delay: 0.5 }}
                    />
                  )}

                  {/* Gradient Definitions */}
                  <defs>
                    <linearGradient id="groundGradient" x1="0%" y1="0%" x2="0%" y2="100%">
                      <stop offset="0%" stopColor="#8b7355" stopOpacity="0.3" />
                      <stop offset="100%" stopColor="#6b5844" stopOpacity="0.4" />
                    </linearGradient>
                    <linearGradient id="houseGradient" x1="0%" y1="0%" x2="0%" y2="100%">
                      <stop offset="0%" stopColor="#e8d5bb" stopOpacity="0.2" />
                      <stop offset="100%" stopColor="#d4c4a8" stopOpacity="0.3" />
                    </linearGradient>
                    <linearGradient id="roofGradient" x1="0%" y1="0%" x2="0%" y2="100%">
                      <stop offset="0%" stopColor="#8b4513" stopOpacity="0.2" />
                      <stop offset="100%" stopColor="#654321" stopOpacity="0.3" />
                    </linearGradient>
                  </defs>

                  {/* Foundation - Step 1 (House Rules) */}
                  {currentStep >= 0 && (
                    <motion.g
                      initial={{ pathLength: 0, opacity: 0 }}
                      animate={{ pathLength: 1, opacity: 1 }}
                      transition={{ duration: 1.5, ease: 'easeInOut' }}
                    >
                      <path
                        d="M 50 250 L 350 250 L 350 230 L 50 230 Z"
                        fill="none"
                        stroke="#444"
                        strokeWidth="2.5"
                        strokeDasharray="5,5"
                        strokeLinecap="round"
                      />
                      {/* Annotation */}
                      <text x="360" y="245" fontSize="10" fill="#666" fontStyle="italic">
                        foundation
                      </text>
                    </motion.g>
                  )}

                  {/* Main Structure - Step 2 (User Type) */}
                  {currentStep >= 1 && (
                    <>
                      {/* Watercolor House Fill */}
                      <motion.path
                        d="M 80 230 L 80 120 L 320 120 L 320 230 Z"
                        fill="url(#houseGradient)"
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        transition={{ duration: 1, delay: 0.8 }}
                      />
                      <motion.g
                        initial={{ pathLength: 0, opacity: 0 }}
                        animate={{ pathLength: 1, opacity: 1 }}
                        transition={{ duration: 1.5, ease: 'easeInOut', delay: 0.3 }}
                      >
                        <path
                          d="M 80 230 L 80 120 L 320 120 L 320 230"
                          fill="none"
                          stroke="#444"
                          strokeWidth="3"
                          strokeLinecap="round"
                        />
                        {/* Annotation */}
                        <text x="25" y="180" fontSize="10" fill="#666" fontStyle="italic">
                          main structure
                        </text>
                      </motion.g>
                    </>
                  )}

                  {/* Roof - Step 3 (Location) */}
                  {currentStep >= 2 && (
                    <>
                      {/* Watercolor Roof Fill */}
                      <motion.path
                        d="M 70 120 L 200 50 L 330 120 Z"
                        fill="url(#roofGradient)"
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        transition={{ duration: 1, delay: 0.8 }}
                      />
                      <motion.g
                        initial={{ pathLength: 0, opacity: 0 }}
                        animate={{ pathLength: 1, opacity: 1 }}
                        transition={{ duration: 1.5, ease: 'easeInOut', delay: 0.3 }}
                      >
                        <path
                          d="M 70 120 L 200 50 L 330 120"
                          fill="none"
                          stroke="#444"
                          strokeWidth="3"
                          strokeLinecap="round"
                        />
                        <path
                          d="M 200 50 L 200 30 L 220 30 L 220 50"
                          fill="none"
                          stroke="#444"
                          strokeWidth="2.5"
                          strokeLinecap="round"
                        />
                        {/* Annotation */}
                        <text x="240" y="70" fontSize="10" fill="#666" fontStyle="italic">
                          roofline
                        </text>
                      </motion.g>
                    </>
                  )}

                  {/* Windows - Dynamically based on bedrooms! */}
                  {currentStep >= 6 && data.bedrooms !== undefined && (
                    <motion.g
                      initial={{ scale: 0, opacity: 0 }}
                      animate={{ scale: 1, opacity: 1 }}
                      transition={{ duration: 0.8, delay: 0.5 }}
                    >
                      {/* Render windows based on bedroom count */}
                      {data.bedrooms === 0 && (
                        // Studio - One large window
                        <>
                          <rect x="175" y="150" width="50" height="50" fill="none" stroke="#444" strokeWidth="2" strokeLinecap="round" />
                          <line x1="200" y1="150" x2="200" y2="200" stroke="#444" strokeWidth="1.5" />
                          <line x1="175" y1="175" x2="225" y2="175" stroke="#444" strokeWidth="1.5" />
                        </>
                      )}
                      {data.bedrooms === 1 && (
                        // 1BR - Two windows
                        <>
                          <rect x="110" y="150" width="50" height="50" fill="none" stroke="#444" strokeWidth="2" strokeLinecap="round" />
                          <line x1="135" y1="150" x2="135" y2="200" stroke="#444" strokeWidth="1.5" />
                          <line x1="110" y1="175" x2="160" y2="175" stroke="#444" strokeWidth="1.5" />

                          <rect x="240" y="150" width="50" height="50" fill="none" stroke="#444" strokeWidth="2" strokeLinecap="round" />
                          <line x1="265" y1="150" x2="265" y2="200" stroke="#444" strokeWidth="1.5" />
                          <line x1="240" y1="175" x2="290" y2="175" stroke="#444" strokeWidth="1.5" />
                        </>
                      )}
                      {data.bedrooms >= 2 && (
                        // 2BR+ - Three windows (larger home)
                        <>
                          <rect x="95" y="150" width="45" height="45" fill="none" stroke="#444" strokeWidth="2" strokeLinecap="round" />
                          <line x1="117" y1="150" x2="117" y2="195" stroke="#444" strokeWidth="1.5" />
                          <line x1="95" y1="172" x2="140" y2="172" stroke="#444" strokeWidth="1.5" />

                          <rect x="177" y="150" width="45" height="45" fill="none" stroke="#444" strokeWidth="2" strokeLinecap="round" />
                          <line x1="199" y1="150" x2="199" y2="195" stroke="#444" strokeWidth="1.5" />
                          <line x1="177" y1="172" x2="222" y2="172" stroke="#444" strokeWidth="1.5" />

                          <rect x="260" y="150" width="45" height="45" fill="none" stroke="#444" strokeWidth="2" strokeLinecap="round" />
                          <line x1="282" y1="150" x2="282" y2="195" stroke="#444" strokeWidth="1.5" />
                          <line x1="260" y1="172" x2="305" y2="172" stroke="#444" strokeWidth="1.5" />
                        </>
                      )}
                      {/* Annotation */}
                      <text x="25" y="165" fontSize="10" fill="#666" fontStyle="italic">
                        {data.bedrooms === 0 ? 'studio' : `${data.bedrooms}br layout`}
                      </text>
                    </motion.g>
                  )}

                  {/* Door - Step 5 (Crew/Bedrooms) */}
                  {currentStep >= 4 && (
                    <motion.g
                      initial={{ scaleY: 0, opacity: 0 }}
                      animate={{ scaleY: 1, opacity: 1 }}
                      transition={{ duration: 0.8, delay: 0.5 }}
                      style={{ transformOrigin: '200px 230px' }}
                    >
                      <rect x="180" y="180" width="40" height="50" fill="none" stroke="#333" strokeWidth="2" />
                      <circle cx="210" cy="205" r="2" fill="#333" />
                    </motion.g>
                  )}

                  {/* Garden/Outdoor Space - Based on must-haves! */}
                  {currentStep >= 9 && data.mustHave && (
                    <motion.g
                      initial={{ opacity: 0, y: 20 }}
                      animate={{ opacity: 1, y: 0 }}
                      transition={{ duration: 1, delay: 0.5 }}
                    >
                      {/* Trees/Garden */}
                      {(data.mustHave.toLowerCase().includes('garden') ||
                        data.mustHave.toLowerCase().includes('outdoor') ||
                        data.mustHave.toLowerCase().includes('yard')) && (
                        <>
                          <circle cx="60" cy="240" r="10" fill="none" stroke="#4ade80" strokeWidth="2.5" />
                          <circle cx="340" cy="240" r="10" fill="none" stroke="#4ade80" strokeWidth="2.5" />
                          <path d="M 55 240 Q 50 235 55 228" fill="none" stroke="#4ade80" strokeWidth="2" />
                          <path d="M 65 240 Q 70 235 65 228" fill="none" stroke="#4ade80" strokeWidth="2" />
                          <text x="15" y="270" fontSize="9" fill="#4ade80" fontStyle="italic">
                            garden
                          </text>
                        </>
                      )}

                      {/* Balcony */}
                      {data.mustHave.toLowerCase().includes('balcony') && (
                        <>
                          <rect x="300" y="140" width="25" height="4" fill="none" stroke="#666" strokeWidth="2" />
                          <line x1="300" y1="144" x2="300" y2="155" stroke="#666" strokeWidth="1.5" />
                          <line x1="325" y1="144" x2="325" y2="155" stroke="#666" strokeWidth="1.5" />
                          <text x="310" y="135" fontSize="9" fill="#666" fontStyle="italic">
                            balcony
                          </text>
                        </>
                      )}

                      {/* Rooftop/Terrace */}
                      {(data.mustHave.toLowerCase().includes('rooftop') ||
                        data.mustHave.toLowerCase().includes('terrace')) && (
                        <>
                          <rect x="180" y="45" width="40" height="3" fill="#666" opacity="0.5" />
                          <text x="185" y="42" fontSize="8" fill="#666" fontStyle="italic">
                            rooftop
                          </text>
                        </>
                      )}

                      {/* Pool */}
                      {data.mustHave.toLowerCase().includes('pool') && (
                        <>
                          <ellipse cx="35" cy="260" rx="15" ry="8" fill="none" stroke="#3b82f6" strokeWidth="2" />
                          <path d="M 20 260 Q 25 258 30 260 Q 35 262 40 260 Q 45 258 50 260"
                                fill="none" stroke="#3b82f6" strokeWidth="1" opacity="0.5" />
                          <text x="15" y="280" fontSize="8" fill="#3b82f6" fontStyle="italic">
                            pool
                          </text>
                        </>
                      )}
                    </motion.g>
                  )}

                  {/* Fence - Step 7+ (Non-Negotiable) */}
                  {currentStep >= 6 && (
                    <motion.g
                      initial={{ pathLength: 0, opacity: 0 }}
                      animate={{ pathLength: 1, opacity: 1 }}
                      transition={{ duration: 1, delay: 0.7 }}
                    >
                      <line x1="20" y1="250" x2="20" y2="235" stroke="#666" strokeWidth="2" />
                      <line x1="35" y1="250" x2="35" y2="235" stroke="#666" strokeWidth="2" />
                      <line x1="365" y1="250" x2="365" y2="235" stroke="#666" strokeWidth="2" />
                      <line x1="380" y1="250" x2="380" y2="235" stroke="#666" strokeWidth="2" />
                    </motion.g>
                  )}

                  {/* Location-Based Background Elements - ENHANCED */}
                  {currentStep >= 3 && data.location && (
                    <motion.g
                      initial={{ opacity: 0, y: 10 }}
                      animate={{ opacity: 0.25, y: 0 }}
                      transition={{ duration: 1.5, delay: 0.7 }}
                    >
                      {data.location === 'new_york_city' && (
                        // Detailed NYC skyline
                        <>
                          {/* Empire State Building style */}
                          <g>
                            <rect x="8" y="70" width="10" height="60" fill="#666" />
                            <rect x="10" y="60" width="6" height="10" fill="#777" />
                            <rect x="11" y="55" width="4" height="5" fill="#888" />
                            {/* Windows */}
                            {[...Array(10)].map((_, i) => (
                              <rect key={i} x="10" y={75 + i * 5} width="2" height="3" fill="#fbbf24" opacity="0.6" />
                            ))}
                          </g>
                          {/* Other buildings */}
                          <rect x="2" y="95" width="8" height="35" fill="#555" />
                          <rect x="20" y="85" width="12" height="45" fill="#666" />
                          <rect x="360" y="90" width="15" height="40" fill="#666" />
                          <rect x="378" y="100" width="12" height="30" fill="#555" />
                          {/* Statue of Liberty hint */}
                          <path d="M 375 115 L 375 125" stroke="#4ade80" strokeWidth="2" opacity="0.4" />
                          <circle cx="375" cy="113" r="2" fill="#4ade80" opacity="0.4" />
                          <text x="330" y="88" fontSize="9" fill="#666" fontWeight="bold" opacity="0.7">
                            NYC
                          </text>
                        </>
                      )}
                      {data.location === 'miami' && (
                        // Detailed Miami beach scene
                        <>
                          {/* Palm trees with coconuts */}
                          <g>
                            <line x1="15" y1="250" x2="15" y2="195" stroke="#8b4513" strokeWidth="2.5" />
                            {/* Palm fronds */}
                            <path d="M 15 198 Q 8 195 5 200" fill="none" stroke="#16a34a" strokeWidth="2" strokeLinecap="round" />
                            <path d="M 15 198 Q 22 195 25 200" fill="none" stroke="#16a34a" strokeWidth="2" strokeLinecap="round" />
                            <path d="M 15 200 Q 10 197 7 203" fill="none" stroke="#16a34a" strokeWidth="2" strokeLinecap="round" />
                            <path d="M 15 200 Q 20 197 23 203" fill="none" stroke="#16a34a" strokeWidth="2" strokeLinecap="round" />
                            {/* Coconuts */}
                            <circle cx="13" cy="202" r="2" fill="#8b4513" />
                            <circle cx="17" cy="202" r="2" fill="#8b4513" />
                          </g>
                          <g>
                            <line x1="370" y1="250" x2="370" y2="200" stroke="#8b4513" strokeWidth="2.5" />
                            <path d="M 370 203 Q 363 200 360 205" fill="none" stroke="#16a34a" strokeWidth="2" strokeLinecap="round" />
                            <path d="M 370 203 Q 377 200 380 205" fill="none" stroke="#16a34a" strokeWidth="2" strokeLinecap="round" />
                          </g>
                          {/* Beach waves */}
                          <path d="M 0 255 Q 50 252 100 255" fill="none" stroke="#3b82f6" strokeWidth="1.5" opacity="0.3" />
                          <text x="5" y="190" fontSize="9" fill="#16a34a" fontWeight="bold" opacity="0.7">
                            Miami
                          </text>
                        </>
                      )}
                      {data.location === 'los_angeles' && (
                        // Detailed LA mountains and Hollywood feel
                        <>
                          {/* Mountain range */}
                          <path d="M 0 140 L 15 120 L 30 135 L 50 115 L 70 140"
                                fill="url(#mountainGradient)" stroke="#8b5cf6" strokeWidth="2" opacity="0.5" />
                          <path d="M 330 145 L 350 125 L 370 135 L 390 120 L 400 145"
                                fill="url(#mountainGradient)" stroke="#8b5cf6" strokeWidth="2" opacity="0.5" />
                          {/* Sun */}
                          <circle cx="380" cy="105" r="8" fill="#fbbf24" opacity="0.4" />
                          {/* Palm tree */}
                          <line x1="10" y1="140" x2="10" y2="115" stroke="#8b4513" strokeWidth="1.5" />
                          <path d="M 10 117 Q 5 115 3 118" fill="none" stroke="#16a34a" strokeWidth="1.5" />
                          <path d="M 10 117 Q 15 115 17 118" fill="none" stroke="#16a34a" strokeWidth="1.5" />
                          <defs>
                            <linearGradient id="mountainGradient" x1="0%" y1="0%" x2="0%" y2="100%">
                              <stop offset="0%" stopColor="#8b5cf6" stopOpacity="0.3" />
                              <stop offset="100%" stopColor="#6b21a8" stopOpacity="0.2" />
                            </linearGradient>
                          </defs>
                          <text x="325" y="115" fontSize="9" fill="#8b5cf6" fontWeight="bold" opacity="0.7">
                            LA
                          </text>
                        </>
                      )}
                      {data.location === 'chicago' && (
                        // Detailed Chicago skyline with Willis Tower
                        <>
                          {/* Willis Tower (tallest) */}
                          <g>
                            <rect x="8" y="65" width="12" height="65" fill="#444" />
                            <rect x="9" y="60" width="10" height="5" fill="#555" />
                            {/* Twin towers effect */}
                            <rect x="8" y="75" width="5" height="55" fill="#555" />
                            <rect x="15" y="75" width="5" height="55" fill="#555" />
                            {/* Windows */}
                            {[...Array(12)].map((_, i) => (
                              <React.Fragment key={i}>
                                <rect x="10" y={70 + i * 5} width="2" height="3" fill="#fbbf24" opacity="0.5" />
                                <rect x="16" y={70 + i * 5} width="2" height="3" fill="#fbbf24" opacity="0.5" />
                              </React.Fragment>
                            ))}
                          </g>
                          {/* Other buildings */}
                          <rect x="2" y="100" width="8" height="30" fill="#555" />
                          <rect x="22" y="90" width="10" height="40" fill="#666" />
                          <rect x="355" y="95" width="14" height="35" fill="#555" />
                          <rect x="372" y="105" width="10" height="25" fill="#666" />
                          <text x="330" y="93" fontSize="9" fill="#444" fontWeight="bold" opacity="0.7">
                            Chicago
                          </text>
                        </>
                      )}
                    </motion.g>
                  )}

                  {/* Budget-Based Details & Luxury Features */}
                  {currentStep >= 5 && data.budgetMax && (
                    <motion.g
                      initial={{ opacity: 0 }}
                      animate={{ opacity: data.budgetMax > 3000 ? 0.5 : 0.3 }}
                      transition={{ duration: 1, delay: 0.5 }}
                    >
                      {/* Basic shading for all */}
                      <path d="M 90 120 L 100 130 L 100 230" stroke="#999" strokeWidth="1" />
                      <path d="M 310 120 L 300 130 L 300 230" stroke="#999" strokeWidth="1" />

                      {/* Luxury details for high budget */}
                      {data.budgetMax > 3000 && (
                        <>
                          {/* Crown molding */}
                          <line x1="80" y1="122" x2="320" y2="122" stroke="#d4a574" strokeWidth="1.5" opacity="0.6" />
                          {/* Decorative trim */}
                          <rect x="190" y="118" width="20" height="3" fill="#d4a574" opacity="0.4" />
                          <text x="25" y="115" fontSize="8" fill="#d4a574" fontStyle="italic">
                            luxury finish
                          </text>
                        </>
                      )}
                    </motion.g>
                  )}
                </svg>

                {/* AI Label */}
                <motion.div
                  initial={{ opacity: 0, x: -20 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: 1 }}
                  className="absolute -top-12 left-0 px-4 py-2 bg-white/80 backdrop-blur-sm rounded-lg border-2 border-gray-300 shadow-sm"
                >
                  <div className="flex items-center gap-2">
                    <Sparkles className="w-4 h-4 text-purple-600" />
                    <span className="text-sm font-semibold text-gray-700">
                      AI Sketching Your Home...
                    </span>
                  </div>
                </motion.div>

                {/* Progress Indicator */}
                <motion.div
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  className="absolute -bottom-8 left-0 right-0 text-center"
                >
                  <p className="text-sm text-gray-500">
                    {Math.round((currentStep / activeRooms.length) * 100)}% Complete
                  </p>
                </motion.div>
              </motion.div>
            </div>
            )}

            {/* Current Question Card - Bottom (iPhone Optimized) */}
            <div className="absolute bottom-0 left-0 right-0 pb-safe">
              <div className="px-4 pb-6">
                <motion.div
                  key={currentStep}
                  initial={{ opacity: 0, y: 50 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -50 }}
                  transition={{ duration: 0.5, type: 'spring', damping: 15 }}
                  className="bg-white rounded-3xl shadow-2xl p-6 md:p-8 border-2 border-gray-100 max-w-lg mx-auto"
                  style={{
                    boxShadow: '0 20px 60px rgba(0, 0, 0, 0.2), 0 0 1px rgba(0, 0, 0, 0.1)',
                  }}
                >
                  {/* Step Indicator with Progress Bar */}
                  <div className="mb-5">
                    <div className="flex items-center justify-between mb-3">
                      <div className="flex items-center gap-2">
                        {React.createElement(activeRoom.icon, {
                          className: 'w-5 h-5 text-gray-600',
                        })}
                        <span className="text-sm font-semibold text-gray-500">
                          Step {currentStep + 1} of {activeRooms.length}
                        </span>
                      </div>
                      <span className="text-xs font-medium text-purple-600 bg-purple-50 px-3 py-1 rounded-full">
                        {Math.round((currentStep / activeRooms.length) * 100)}%
                      </span>
                    </div>
                    {/* Progress Bar */}
                    <div className="w-full h-1.5 bg-gray-100 rounded-full overflow-hidden">
                      <motion.div
                        className="h-full bg-gradient-to-r from-blue-500 to-purple-500 rounded-full"
                        initial={{ width: 0 }}
                        animate={{ width: `${(currentStep / activeRooms.length) * 100}%` }}
                        transition={{ duration: 0.8, ease: 'easeOut' }}
                      />
                    </div>
                  </div>

                  {/* Question Title */}
                  <h2 className="text-2xl md:text-3xl font-bold text-gray-900 mb-3 leading-tight">
                    {activeRoom.name}
                  </h2>

                  <p className="text-gray-600 mb-6 text-base leading-relaxed">
                    Help AI design your perfect home
                  </p>

                  {/* Begin Button - Large Touch Target */}
                  <button
                    onClick={() => setIsInsideRoom(true)}
                    className="w-full py-4 md:py-5 bg-gradient-to-r from-blue-600 to-purple-600 text-white rounded-2xl font-bold text-lg shadow-xl hover:shadow-2xl transition-all active:scale-[0.98] touch-manipulation"
                    style={{
                      boxShadow: '0 10px 30px rgba(79, 70, 229, 0.3)',
                    }}
                  >
                    Continue →
                  </button>
                </motion.div>
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* INSIDE ROOM VIEW - Full screen */}
      <AnimatePresence>
        {isInsideRoom && (
          <motion.div
            initial={{ opacity: 0, scale: 0.8 }}
            animate={{ opacity: 1, scale: 1 }}
            exit={{ opacity: 0, scale: 0.8 }}
            transition={{ duration: 0.8 }}
            className="fixed inset-0 z-50 flex items-center justify-center p-4"
            style={{
              background: `linear-gradient(135deg, ${activeRoom.color} 0%, ${activeRoom.color}dd 100%)`,
            }}
          >
            <div className="w-full h-full max-w-7xl mx-auto overflow-auto">
              {renderStepComponent(activeRoom.id)}
            </div>

            {/* Exit hint - subtle */}
            {currentStep > 0 && (
              <button
                onClick={handleBack}
                className="fixed top-4 right-4 p-3 bg-white/20 backdrop-blur-sm rounded-full hover:bg-white/30 transition-all"
              >
                <ArrowLeft className="w-6 h-6 text-white" />
              </button>
            )}
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
