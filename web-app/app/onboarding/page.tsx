'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';
import { db, auth } from '@/lib/supabase';
import { analytics } from '@/lib/analytics';
import CinematicBackground from '@/components/CinematicBackground';

// Step components (to be built)
import WelcomeStep from '@/components/onboarding/WelcomeStep';
import UserTypeStep from '@/components/onboarding/UserTypeStep';
import LocationStep from '@/components/onboarding/LocationStep';
import NeighborhoodStep from '@/components/onboarding/NeighborhoodStep';
import BudgetStep from '@/components/onboarding/BudgetStep';
import BedroomBathStep from '@/components/onboarding/BedroomBathStep';
import IncomeStep from '@/components/onboarding/IncomeStep';
import AgentStep from '@/components/onboarding/AgentStep';
import FeatureShowcase from '@/components/onboarding/FeatureShowcase';
import CompletionStep from '@/components/onboarding/CompletionStep';

export interface OnboardingData {
  // Basic Info
  fullName?: string;
  displayName?: string;
  phone?: string;

  // User Type & Location
  userType?: 'renter' | 'buyer' | 'browser';
  location?: 'new_york_city' | 'chicago' | 'los_angeles' | 'miami';
  neighborhoods?: string[];

  // Budget & Requirements
  budgetMin?: number;
  budgetMax?: number;
  bedrooms?: number;
  bathrooms?: number;

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

  // Define all steps
  const steps = [
    { id: 'welcome', component: WelcomeStep, showProgress: false },
    { id: 'user-type', component: UserTypeStep, showProgress: true },
    { id: 'location', component: LocationStep, showProgress: true },
    { id: 'neighborhood', component: NeighborhoodStep, showProgress: true },
    { id: 'budget', component: BudgetStep, showProgress: true },
    { id: 'bedroom-bath', component: BedroomBathStep, showProgress: true },
    { id: 'income', component: IncomeStep, showProgress: true, conditional: true },
    { id: 'agent', component: AgentStep, showProgress: true },
    { id: 'showcase', component: FeatureShowcase, showProgress: false },
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

      if (profile?.onboarding_completed) {
        // Already completed onboarding, redirect to home
        router.push('/home');
        return;
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

  return (
    <main className="relative min-h-screen">
      <CinematicBackground timeOfDay="day" />

      {/* Progress Bar */}
      {showProgress && (
        <div className="fixed top-0 left-0 right-0 z-50">
          <motion.div
            className="h-1 bg-gradient-to-r from-primary to-purple-500"
            initial={{ width: 0 }}
            animate={{ width: `${progress}%` }}
            transition={{ duration: 0.5, ease: 'easeOut' }}
          />
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
            />
          )}
        </AnimatePresence>
      </div>
    </main>
  );
}
