'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import AuroraBackground from '@/components/AuroraBackground';
import { auth, db, agentDb } from '@/lib/supabase';

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!email || !password) {
      setError('Please enter both email and password');
      return;
    }

    setIsLoading(true);
    setError('');

    // Real Supabase authentication
    const { data, error: signInError } = await auth.signIn(email, password);

    if (signInError) {
      setError(signInError.message);
      setIsLoading(false);
      return;
    }

    if (data?.user) {
      try {
        // First check if user is an agent
        const { isAgent } = await agentDb.isUserAgent(data.user.id);

        if (isAgent) {
          console.log('✅ User is an agent, redirecting to /agent');
          router.push('/agent');
          return;
        }

        // If not an agent, check if onboarding is complete
        const { data: profile } = await db.getProfile(data.user.id);

        // Read from onboarding_completed flag OR check onboarding_data JSONB
        const onboardingData = profile?.onboarding_data || {};
        const isOnboardingComplete = !!(
          profile?.onboarding_completed || (
            (onboardingData.userType || profile?.user_type) &&
            (onboardingData.location || profile?.primary_location) &&
            (onboardingData.budgetMax || profile?.budget_max)
          )
        );

        if (isOnboardingComplete) {
          console.log('✅ Onboarding complete, redirecting to /home');
          router.push('/home');
        } else {
          console.log('⚠️ Onboarding not complete, redirecting to /onboarding');
          router.push('/onboarding');
        }
      } catch (error) {
        console.error('Failed to check onboarding status:', error);
        // Default to home on error
        router.push('/home');
      }
    } else {
      setError('Login failed. Please try again.');
      setIsLoading(false);
    }
  };

  const handleGoogleSignIn = async () => {
    setIsLoading(true);
    setError('');
    const { error: signInError } = await auth.signInWithGoogle();
    if (signInError) {
      setError(signInError.message);
      setIsLoading(false);
    }
  };

  const handleAppleSignIn = async () => {
    setIsLoading(true);
    setError('');
    const { error: signInError } = await auth.signInWithApple();
    if (signInError) {
      setError(signInError.message);
      setIsLoading(false);
    }
  };

  return (
    <main className="relative min-h-screen flex items-center justify-center p-5">
      <AuroraBackground />

      <div className="relative z-10 w-full max-w-md">
        {/* Header */}
        <div className="text-center mb-8 animate-fade-in">
          <h1 className="text-4xl font-bold tracking-wider mb-2 text-shadow-lg">
            HOMEY
          </h1>
          <p className="text-xl font-semibold text-white/80">
            Welcome back
          </p>
        </div>

        {/* Login Card */}
        <div className="glass rounded-3xl p-8 shadow-2xl animate-slide-up">
          {error && (
            <div className="mb-4 p-3 bg-red-500/20 border border-red-500/50 rounded-xl text-red-200 text-sm">
              {error}
            </div>
          )}
          <form onSubmit={handleSubmit} className="space-y-4">
            {/* Email Input */}
            <div className="group">
              <div className="flex items-center gap-3 px-4 py-3.5 bg-white/[0.08] border border-white/[0.12] rounded-xl transition-all focus-within:bg-white/[0.12] focus-within:border-primary/50 focus-within:shadow-lg focus-within:shadow-primary/10">
                <span className="text-base opacity-60">✉️</span>
                <input
                  type="email"
                  placeholder="Email address"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="flex-1 bg-transparent border-none outline-none text-white placeholder:text-white/40"
                  autoComplete="email"
                />
              </div>
            </div>

            {/* Password Input */}
            <div className="group">
              <div className="flex items-center gap-3 px-4 py-3.5 bg-white/[0.08] border border-white/[0.12] rounded-xl transition-all focus-within:bg-white/[0.12] focus-within:border-primary/50 focus-within:shadow-lg focus-within:shadow-primary/10">
                <span className="text-base opacity-60">🔒</span>
                <input
                  type="password"
                  placeholder="Password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="flex-1 bg-transparent border-none outline-none text-white placeholder:text-white/40"
                  autoComplete="current-password"
                />
              </div>
              <div className="text-right mt-2">
                <a href="#" className="text-sm font-semibold text-primary hover:text-primary-hover transition-colors">
                  Forgot password?
                </a>
              </div>
            </div>

            {/* Sign In Button */}
            <button
              type="submit"
              disabled={isLoading || !email || !password}
              className="w-full py-3.5 bg-gradient-to-r from-primary to-purple-600 rounded-xl text-white font-bold uppercase tracking-wider text-base transition-all hover:scale-[1.02] hover:shadow-xl hover:shadow-primary/40 active:scale-[0.98] disabled:opacity-70 disabled:cursor-not-allowed disabled:hover:scale-100 mt-6"
            >
              {isLoading ? 'Signing In...' : 'Sign In'}
            </button>

            {/* Divider */}
            <div className="text-center my-6">
              <span className="text-sm font-semibold text-white/60">Or continue with</span>
            </div>

            {/* Social Buttons */}
            <div className="grid grid-cols-2 gap-3">
              <button
                type="button"
                onClick={handleAppleSignIn}
                disabled={isLoading}
                className="flex items-center justify-center gap-2 px-4 py-3 bg-white/[0.08] border border-white/[0.16] rounded-xl text-white font-semibold text-sm transition-all hover:bg-white/[0.12] hover:border-primary/50 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <span>🍎</span>
                <span>Apple</span>
              </button>
              <button
                type="button"
                onClick={handleGoogleSignIn}
                disabled={isLoading}
                className="flex items-center justify-center gap-2 px-4 py-3 bg-white/[0.08] border border-white/[0.16] rounded-xl text-white font-semibold text-sm transition-all hover:bg-white/[0.12] hover:border-primary/50 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <span>🌐</span>
                <span>Google</span>
              </button>
            </div>

            {/* Create Account */}
            <div className="text-center mt-5">
              <span className="text-sm text-white/60">Don't have an account? </span>
              <button
                type="button"
                onClick={() => router.push('/signup')}
                className="text-sm font-semibold text-primary hover:text-primary-hover transition-colors"
              >
                Create account
              </button>
            </div>

            {/* Agent Registration */}
            <div className="text-center mt-3">
              <span className="text-sm text-white/60">Are you a real estate agent? </span>
              <button
                type="button"
                onClick={() => router.push('/agent/register')}
                className="text-sm font-semibold text-purple-400 hover:text-purple-300 transition-colors"
              >
                Register as an agent
              </button>
            </div>
          </form>
        </div>
      </div>
    </main>
  );
}
