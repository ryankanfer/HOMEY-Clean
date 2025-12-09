'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';
import { CheckCircle2 } from 'lucide-react';
import { db, auth, agentDb } from '@/lib/supabase';
import { analytics } from '@/lib/analytics';
import { checkAdminFromProfile } from '@/lib/admin';
import CinematicBackground from '@/components/CinematicBackground';

// Step components (to be built)
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
import FeatureShowcase from '@/components/onboarding/FeatureShowcase';
import CompletionStep from '@/components/onboarding/CompletionStep';

export interface OnboardingData {
  // Legal Acceptance
  acceptedTerms?: boolean;
  acceptedBeta?: boolean;
  termsAcceptedAt?: string;

  // Basic Info
  fullName?: string;
  displayName?: string;
  phone?: string;

  // User Type & Location
  userType?: 'renter' | 'buyer' | 'browser';
  location?: 'new_york_city' | 'chicago' | 'los_angeles' | 'miami';
  neighborhoods?: string[];

  // Budget & Requirements (min-max range)
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
    { id: 'house-rules', component: HouseRulesStep, showProgress: false },
    { id: 'name', component: NameStep, showProgress: true },
    { id: 'user-type', component: UserTypeStep, showProgress: true },
    { id: 'location', component: LocationStep, showProgress: true },
    { id: 'neighborhood', component: NeighborhoodStep, showProgress: true },
    { id: 'budget', component: BudgetStep, showProgress: true },
    { id: 'crew', component: CrewStep, showProgress: true },
    { id: 'timeline', component: TimelineStep, showProgress: true },
    { id: 'vibe-check', component: VibeCheckStep, showProgress: true },
    { id: 'non-negotiable', component: NonNegotiableStep, showProgress: true },
    { id: 'income', component: IncomeStep, showProgress: true, conditional: true },
    { id: 'agent', component: AgentStep, showProgress: true },
    { id: 'match-tease', component: MatchTeaseStep, showProgress: false },
    { id: 'completion', component: CompletionStep, showProgress: false },
  ];

  // Check if income step should be shown (NYC renters only)
  const shouldShowIncomeStep = () => {
    return data.location === 'new_york_city' && data.userType === 'renter';
  };

  // Get the actual steps to show (filtering out conditional steps)
  const getActiveSteps = () => {
    return steps.filter(step => {
      if (step.id === 'income') {
        return shouldShowIncomeStep();
      }
      return true;
    });
  };

  const activeSteps = getActiveSteps();
  const totalSteps = activeSteps.filter(s => s.showProgress).length;
  const progressSteps = activeSteps.slice(0, currentStep + 1).filter(s => s.showProgress).length;
  const progress = totalSteps > 0 ? (progressSteps / totalSteps) * 100 : 0;

  useEffect(() => {
    loadUserAndProgress();
    analytics.pageView('onboarding');
  }, []);

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
      setData(updatedData);

      // Save to database (only onboarding_data during progress, not profile columns)
      await db.updateProfile(userId, {
        onboarding_data: updatedData,
        onboarding_step: currentStep,
      });

      console.log('Progress saved:', updatedData);
    } catch (error) {
      console.error('Failed to save progress:', error);
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
        <CinematicBackground timeOfDay="portal" />
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
    if (!stepId || stepId === 'house-rules') return 0;
    if (stepId === 'name' || stepId === 'user-type' || stepId === 'location' || stepId === 'neighborhood') return 1;
    if (stepId === 'budget' || stepId === 'crew' || stepId === 'timeline' || stepId === 'vibe-check' || stepId === 'non-negotiable' || stepId === 'income') return 2;
    if (stepId === 'agent') return 3;
    if (stepId === 'match-tease' || stepId === 'showcase' || stepId === 'completion') return 4;
    return 1;
  };

  const majorStepIndex = getMajorStepIndex();
  const majorStepLabels = ['Welcome', 'Profile', 'Preferences', 'Agent', 'Done'];

  return (
    <main className="relative min-h-screen">
      <CinematicBackground timeOfDay="portal" />

      {/* Journey Tracker */}
      {showProgress && (
        <div className="fixed top-6 left-1/2 -translate-x-1/2 z-50 w-full max-w-2xl px-4">
          <div className="glass-strong rounded-2xl p-4">
            <div className="flex items-center justify-between mb-2">
              {[0, 1, 2, 3, 4].map((num) => (
                <div key={num} className="flex items-center">
                  <div
                    className={`w-10 h-10 rounded-full flex items-center justify-center font-bold transition-all ${
                      num < majorStepIndex
                        ? 'bg-green-500 text-white'
                        : num === majorStepIndex
                        ? 'bg-gradient-to-r from-purple-500 to-pink-500 text-white'
                        : 'bg-white/10 text-white/40'
                    }`}
                  >
                    {num < majorStepIndex ? <CheckCircle2 className="w-6 h-6" /> : num + 1}
                  </div>
                  {num < 4 && (
                    <div
                      className={`h-1 mx-2 transition-all ${
                        num < majorStepIndex ? 'bg-green-500' : 'bg-white/10'
                      }`}
                      style={{ width: '60px' }}
                    />
                  )}
                </div>
              ))}
            </div>
            <div className="flex justify-between text-xs text-white/60 px-1">
              {majorStepLabels.map((label, idx) => (
                <span key={idx} className={majorStepIndex === idx ? 'text-white font-semibold' : ''}>
                  {label}
                </span>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* Back Button */}
      {currentStep > 0 && currentStep < activeSteps.length - 1 && (
        <button
          onClick={handleBack}
          className="fixed top-6 left-6 z-50 w-12 h-12 rounded-full bg-white/10 backdrop-blur-sm flex items-center justify-center text-white hover:bg-white/20 transition-colors"
          disabled={isSaving}
        >
          ←
        </button>
      )}

      {/* Step Progress Indicator */}
      {showProgress && (
        <div className="fixed top-6 right-6 z-50 glass-strong px-4 py-2 rounded-full text-white text-sm font-semibold">
          {progressSteps} / {totalSteps}
        </div>
      )}

      {/* Step Content */}
      <div className="relative z-10 min-h-screen flex items-center justify-center px-5 py-20">
        <AnimatePresence mode="wait">
          {CurrentStepComponent && (
            <CurrentStepComponent
              key={currentStep}
              data={data}
              onNext={handleNext}
              onComplete={handleComplete}
              isSaving={isSaving}
              agentConnection={activeSteps[currentStep]?.id === 'agent' ? agentConnection : undefined}
            />
          )}
        </AnimatePresence>
      </div>

      {/* Legal Disclaimer */}
      <div className="fixed bottom-4 left-0 right-0 z-10 text-center px-4">
        <p className="text-xs text-white/40 leading-relaxed">
          By continuing, you agree to our{' '}
          <a
            href="/legal"
            target="_blank"
            rel="noopener noreferrer"
            className="text-primary hover:text-primary-hover underline"
          >
            Terms of Service
          </a>
          {' '}and{' '}
          <a
            href="/legal"
            target="_blank"
            rel="noopener noreferrer"
            className="text-primary hover:text-primary-hover underline"
          >
            Privacy Policy
          </a>
        </p>
      </div>
    </main>
  );
}
