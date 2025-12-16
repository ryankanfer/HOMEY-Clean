'use client';

export const dynamic = 'force-dynamic';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';
import { CheckCircle2 } from 'lucide-react';
import { db, auth, agentDb } from '@/lib/supabase';
import { analytics } from '@/lib/analytics';
import { checkAdminFromProfile } from '@/lib/admin';
import CinematicBackground from '@/components/CinematicBackground';

// Step components (to be built)
import WelcomeStep from '@/components/onboarding/WelcomeStep';
import LegalDisclosureStep from '@/components/onboarding/LegalDisclosureStep';
import BasicIntakeStep from '@/components/onboarding/BasicIntakeStep';
import UserTypeStep from '@/components/onboarding/UserTypeStep';
import LocationStep from '@/components/onboarding/LocationStep';
import NeighborhoodStep from '@/components/onboarding/NeighborhoodStep';
import BudgetStep from '@/components/onboarding/BudgetStep';
import CrewStep from '@/components/onboarding/CrewStep';
import TimelineStep from '@/components/onboarding/TimelineStep';
import VibeCheckStep from '@/components/onboarding/VibeCheckStep';
import NonNegotiableStep from '@/components/onboarding/NonNegotiableStep';
import AgentStep from '@/components/onboarding/AgentStep';
import MatchTeaseStep from '@/components/onboarding/MatchTeaseStep';

export interface OnboardingData {
  // Personalization
  doorSelection?: 'classic' | 'french' | 'elevator' | 'loft' | 'vault' | 'shoji';

  // Legal & Basic Registration
  firstName?: string;
  lastName?: string;
  phone?: string;
  notificationsEnabled?: boolean;

  // Basic Info
  fullName?: string;
  displayName?: string;

  // User Type & Location
  userType?: 'renter' | 'buyer' | 'browser';
  location?: 'new_york_city' | 'chicago' | 'los_angeles' | 'miami';
  neighborhoods?: string[];

  // Budget & Requirements
  budgetMin?: number;
  budgetMax?: number;
  bedrooms?: number;
  bathrooms?: number;
  householdType?: string;
  timeline?: string;
  stylePreference?: string;
  mustHave?: string;

  // NYC Renter Income
  householdIncome?: number;

  // Agent Status
  hasAgent?: boolean;
  agentName?: string;
  agentContact?: string;

  // Tracking
  currentStep?: number;
}

export default function OnboardingPage() {
  const router = useRouter();
  const [currentStep, setCurrentStep] = useState(0);
  const [userId, setUserId] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [data, setData] = useState<OnboardingData>({});
  const [agentConnection, setAgentConnection] = useState<any>(null);

  // Define all steps
  const steps = [
    { id: 'welcome', component: WelcomeStep, showProgress: false },
    { id: 'legal-disclosure', component: LegalDisclosureStep, showProgress: false },
    { id: 'basic-intake', component: BasicIntakeStep, showProgress: false },
    { id: 'user-type', component: UserTypeStep, showProgress: true },
    { id: 'location', component: LocationStep, showProgress: true },
    { id: 'neighborhood', component: NeighborhoodStep, showProgress: true },
    { id: 'budget', component: BudgetStep, showProgress: true },
    { id: 'crew', component: CrewStep, showProgress: true },
    { id: 'timeline', component: TimelineStep, showProgress: true },
    { id: 'vibe-check', component: VibeCheckStep, showProgress: true },
    { id: 'non-negotiable', component: NonNegotiableStep, showProgress: true },
    { id: 'agent', component: AgentStep, showProgress: true },
    { id: 'match-tease', component: MatchTeaseStep, showProgress: false },
  ];

  // Get the actual steps to show
  const getActiveSteps = () => {
    return steps;
  };

  const activeSteps = getActiveSteps();
  const totalSteps = activeSteps.filter(s => s.showProgress).length;
  const progressSteps = activeSteps.slice(0, currentStep + 1).filter(s => s.showProgress).length;
  const progress = totalSteps > 0 ? (progressSteps / totalSteps) * 100 : 0;

  useEffect(() => {
    loadUserAndProgress();
    analytics.pageView('onboarding');
  }, []);

  // Sanitize data to remove circular references and non-serializable values
  const sanitizeData = (obj: any): any => {
    if (obj === null || obj === undefined) {
      return obj;
    }

    // Handle primitive types
    if (typeof obj !== 'object') {
      return obj;
    }

    // Handle arrays
    if (Array.isArray(obj)) {
      return obj.map(item => sanitizeData(item));
    }

    // Skip DOM elements, functions, and other non-serializable objects
    if (obj instanceof HTMLElement || typeof obj === 'function' || obj instanceof Event) {
      return undefined;
    }

    // Handle plain objects
    const sanitized: any = {};
    for (const key in obj) {
      if (obj.hasOwnProperty(key)) {
        try {
          const value = obj[key];
          // Skip React internal properties and circular refs
          if (key.startsWith('__react') || key.startsWith('_react')) {
            continue;
          }
          sanitized[key] = sanitizeData(value);
        } catch (error) {
          // Skip properties that cause errors
          continue;
        }
      }
    }
    return sanitized;
  };

  const loadUserAndProgress = async () => {
    try {
      const { data: { user } } = await auth.getUser();

      if (!user) {
        // Not logged in, redirect to signup
        router.push('/signup');
        return;
      }

      setUserId(user.id);

      // Try to load existing profile/progress
      const { data: profile } = await db.getProfile(user.id);

      // Check for admin bypass - allow admins to test onboarding even if completed
      const urlParams = new URLSearchParams(window.location.search);
      const forceOnboarding = urlParams.get('force') === 'true';
      const isAdmin = await checkAdminFromProfile(profile);

      if (profile?.onboarding_completed && !(isAdmin && forceOnboarding)) {
        // Already completed onboarding, redirect to home (unless admin forcing)
        router.push('/home');
        return;
      }

      // Check if user has an agent connection
      const { data: connections } = await agentDb.getClientConnections(user.id);
      const activeConnection = connections?.find((c: any) => c.status === 'active');
      if (activeConnection) {
        setAgentConnection(activeConnection);
        console.log('User has agent connection:', activeConnection);
      }

      // Load any saved progress
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

      // Sanitize data to remove circular references and non-serializable values
      const sanitizedData = sanitizeData(updatedData);

      setData(sanitizedData);

      // Save to database (only onboarding_data during progress, not profile columns)
      await db.updateProfile(userId, {
        onboarding_data: sanitizedData,
        onboarding_step: currentStep,
      });

      console.log('✅ Progress saved:', sanitizedData);
    } catch (error) {
      console.error('❌ Failed to save progress:', error);
    } finally {
      setIsSaving(false);
    }
  };

  const handleNext = async (stepData: Partial<OnboardingData>) => {
    // Save the data from this step
    await saveProgress(stepData);

    // Move to next step
    if (currentStep < activeSteps.length - 1) {
      setCurrentStep(currentStep + 1);
    }
  };

  const handleBack = () => {
    if (currentStep > 0) {
      setCurrentStep(currentStep - 1);
    }
  };

  const handleComplete = async (finalData: Partial<OnboardingData>) => {
    if (!userId) return;

    setIsSaving(true);

    try {
      const completeData = { ...data, ...finalData };

      // WORKAROUND for database trigger issue:
      // Only save to onboarding_data JSONB and completion flag
      // Don't update profile columns to avoid triggering user_preferences sync
      const allUpdates: Record<string, any> = {
        // Store ALL data in JSONB (includes userType, location, budgetMax, etc.)
        onboarding_data: completeData,
        onboarding_completed: true,
        onboarding_completed_at: new Date().toISOString(),
        // Save name and phone to profile columns
        full_name: completeData.fullName,
        phone: completeData.phone,
      };

      // Filter out undefined values to prevent database errors
      const profileUpdates = Object.fromEntries(
        Object.entries(allUpdates).filter(([_, value]) => value !== undefined)
      );

      console.log('Saving onboarding completion:', profileUpdates);

      // Mark onboarding as complete
      const { data: savedProfile, error: saveError } = await db.updateProfile(userId, profileUpdates);

      if (saveError) {
        console.error('❌ Database error:', saveError);
        console.error('Error details:', JSON.stringify(saveError, null, 2));
        console.error('Data we tried to save:', JSON.stringify(profileUpdates, null, 2));
        setIsSaving(false);
        return;
      }

      console.log('✅ Onboarding saved successfully:', savedProfile);

      // Update auth user metadata with full_name
      if (completeData.fullName) {
        try {
          await auth.updateUser({
            data: {
              full_name: completeData.fullName,
            }
          });
          console.log('✅ User metadata updated with full_name');
        } catch (metaError) {
          console.error('❌ Failed to update user metadata:', metaError);
          // Continue anyway - profile update succeeded
        }
      }

      // Track completion
      analytics.completeOnboarding('full_onboarding');

      // Redirect to home after brief delay
      setTimeout(() => {
        router.push('/home');
      }, 2000);
    } catch (error) {
      console.error('Failed to complete onboarding:', error);
      setIsSaving(false);
    }
  };

  if (isLoading) {
    return (
      <main className="relative min-h-screen flex items-center justify-center">
        <CinematicBackground timeOfDay="day" />
        <div className="relative z-10">
          <div className="w-12 h-12 border-4 border-white/20 border-t-primary rounded-full animate-spin" />
        </div>
      </main>
    );
  }

  const CurrentStepComponent = activeSteps[currentStep]?.component;
  const showProgress = activeSteps[currentStep]?.showProgress;

  // Calculate which major section we're in
  const getMajorStepIndex = () => {
    const stepId = activeSteps[currentStep]?.id;
    if (!stepId || stepId === 'welcome' || stepId === 'legal-disclosure' || stepId === 'basic-intake') return 0;
    if (stepId === 'user-type' || stepId === 'location' || stepId === 'neighborhood') return 1;
    if (stepId === 'budget' || stepId === 'crew' || stepId === 'timeline' || stepId === 'vibe-check' || stepId === 'non-negotiable') return 2;
    if (stepId === 'agent') return 3;
    if (stepId === 'match-tease') return 4;
    return 1;
  };

  const majorStepIndex = getMajorStepIndex();
  const majorStepLabels = ['Welcome', 'Profile', 'Preferences', 'Agent', 'Complete'];

  // Check if we're in a "logic" step (steps 3-7) for ambient background color shift
  const isLogicStep = currentStep >= 3 && currentStep <= 7;

  return (
    <main className="relative min-h-screen bg-black flex flex-col items-center justify-center p-6 overflow-hidden font-sans selection:bg-white/30">

      {/* DYNAMIC AMBIENT BACKGROUND */}
      <div className="absolute inset-0 pointer-events-none transition-colors duration-[2000ms]">
        <motion.div
          animate={{
            background: isLogicStep
              ? 'radial-gradient(circle at 0% 0%, rgba(30,58,138,0.15) 0%, transparent 50%)'
              : 'radial-gradient(circle at 0% 0%, rgba(88,28,135,0.15) 0%, transparent 50%)'
          }}
          className="absolute top-0 left-0 w-full h-full"
        />
        <motion.div
          animate={{
            background: isLogicStep
              ? 'radial-gradient(circle at 100% 100%, rgba(6,182,212,0.1) 0%, transparent 50%)'
              : 'radial-gradient(circle at 100% 100%, rgba(217,70,239,0.1) 0%, transparent 50%)'
          }}
          className="absolute bottom-0 right-0 w-full h-full"
        />
        <div className="absolute inset-0 bg-[url('data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIzMDAiIGhlaWdodD0iMzAwIj48ZmlsdGVyIGlkPSJhIiB4PSIwIiB5PSIwIj48ZmVUdXJidWxlbmNlIGJhc2VGcmVxdWVuY3k9Ii43NSIgc3RpdGNoVGlsZXM9InN0aXRjaCIgdHlwZT0iZnJhY3RhbE5vaXNlIi8+PGZlQ29sb3JNYXRyaXggdHlwZT0ic2F0dXJhdGUiIHZhbHVlcz0iMCIvPjwvZmlsdGVyPjxwYXRoIGQ9Ik0wIDBoMzAwdjMwMEgweiIgZmlsdGVyPSJ1cmwoI2EpIiBvcGFjaXR5PSIuMDUiLz48L3N2Zz4=')] opacity-20 mix-blend-overlay" />
      </div>

      {/* HEADER & NAV */}
      <div className="absolute top-0 left-0 right-0 p-8 flex justify-between items-center z-50">
        {currentStep > 0 && currentStep < activeSteps.length - 1 && (
          <button
            onClick={handleBack}
            disabled={isSaving}
            className="w-12 h-12 rounded-full bg-white/5 border border-white/10 flex items-center justify-center text-white hover:bg-white/10 transition-colors disabled:opacity-50"
          >
            ←
          </button>
        )}
        {currentStep === 0 && <div />}
        {/* Numeric Tracker */}
        <div className="font-mono text-xs text-white/30 tracking-widest ml-auto">
          {String(currentStep + 1).padStart(2, '0')} / {String(activeSteps.length).padStart(2, '0')}
        </div>
      </div>

      {/* ACTIVE STEP CONTAINER */}
      <AnimatePresence mode="wait">
        <motion.div
          key={currentStep}
          initial={{ opacity: 0, y: 20, filter: 'blur(10px)' }}
          animate={{ opacity: 1, y: 0, filter: 'blur(0px)' }}
          exit={{ opacity: 0, y: -20, filter: 'blur(10px)' }}
          transition={{ duration: 0.6, ease: [0.32, 0.72, 0, 1] }}
          className="w-full max-w-4xl relative z-10 flex-1 flex flex-col justify-center"
        >
          {CurrentStepComponent && (
            <CurrentStepComponent
              data={data}
              onNext={handleNext}
              isSaving={isSaving}
              {...(activeSteps[currentStep]?.id === 'match-tease' && { onComplete: handleComplete })}
              {...(activeSteps[currentStep]?.id === 'agent' && { agentConnection })}
            />
          )}
        </motion.div>
      </AnimatePresence>
    </main>
  );
}
