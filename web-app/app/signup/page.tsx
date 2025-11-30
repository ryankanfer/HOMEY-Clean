'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import AuroraBackground from '@/components/AuroraBackground';
import { auth, db } from '@/lib/supabase';
import { analytics } from '@/lib/analytics';

export default function SignUpPage() {
  const router = useRouter();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [fullName, setFullName] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState(false);

  const validateForm = () => {
    if (!email || !password || !confirmPassword || !fullName) {
      setError('Please fill in all fields');
      return false;
    }

    if (password.length < 8) {
      setError('Password must be at least 8 characters');
      return false;
    }

    if (password !== confirmPassword) {
      setError('Passwords do not match');
      return false;
    }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      setError('Please enter a valid email address');
      return false;
    }

    return true;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!validateForm()) {
      return;
    }

    setIsLoading(true);
    setError('');

    try {
      // Sign up with Supabase
      const { data, error: signUpError } = await auth.signUp(email, password);

      if (signUpError) {
        setError(signUpError.message);
        setIsLoading(false);
        return;
      }

      if (data?.user) {
        console.log('✅ User created:', data.user.id);

        // Sign in the user to get authenticated session
        console.log('🔐 Signing in user to establish session...');
        const { error: signInError } = await auth.signIn(email, password);

        if (signInError) {
          console.error('❌ Auto sign-in failed:', signInError);
          setError('Account created! Please sign in to continue.');
          setIsLoading(false);
          return;
        }

        console.log('✅ User signed in successfully');

        // Now save full name to profile (user is authenticated)
        try {
          const { data: profileData, error: profileError } = await db.updateProfile(data.user.id, {
            email: email,
            full_name: fullName,
            display_name: fullName.split(' ')[0], // Use first name as display name
          });

          if (profileError) {
            console.error('❌ Profile update failed:', profileError);
            // Don't block - continue to onboarding, they can update profile there
            console.warn('⚠️ Continuing to onboarding anyway...');
          } else {
            console.log('✅ Profile created/updated:', profileData);
          }
        } catch (profileErr) {
          console.error('❌ Profile update error:', profileErr);
          // Don't block - continue to onboarding
          console.warn('⚠️ Continuing to onboarding anyway...');
        }

        // Track signup
        try {
          analytics.createAccount('email', {
            user_id: data.user.id,
            email: email,
          });
        } catch (analyticsErr) {
          console.warn('⚠️ Analytics tracking failed (non-critical):', analyticsErr);
        }

        setSuccess(true);

        // Show success message
        console.log('✅ Redirecting to onboarding in 2 seconds...');
        setTimeout(() => {
          console.log('🚀 Redirecting now to /onboarding');
          router.push('/onboarding');
        }, 2000);
      } else {
        setError('Sign up failed. Please try again.');
        setIsLoading(false);
      }
    } catch (err: any) {
      setError(err.message || 'An error occurred. Please try again.');
      setIsLoading(false);
    }
  };

  const handleGoogleSignUp = async () => {
    setIsLoading(true);
    setError('');

    try {
      const { error: signInError } = await auth.signInWithGoogle();
      if (signInError) {
        setError(signInError.message);
        setIsLoading(false);
      }
      // Google will handle the redirect
    } catch (err: any) {
      setError(err.message || 'Google sign-up failed');
      setIsLoading(false);
    }
  };

  const handleAppleSignUp = async () => {
    setIsLoading(true);
    setError('');

    try {
      const { error: signInError } = await auth.signInWithApple();
      if (signInError) {
        setError(signInError.message);
        setIsLoading(false);
      }
      // Apple will handle the redirect
    } catch (err: any) {
      setError(err.message || 'Apple sign-up failed');
      setIsLoading(false);
    }
  };

  if (success) {
    return (
      <main className="relative min-h-screen flex items-center justify-center p-5">
        <AuroraBackground />
        <div className="relative z-10 w-full max-w-md text-center">
          <div className="glass rounded-3xl p-8 shadow-2xl">
            <div className="text-6xl mb-4">✅</div>
            <h2 className="text-3xl font-bold text-white mb-3">Account Created!</h2>
            <p className="text-white/80 mb-6">
              Welcome to HOMEY! Redirecting you to personalize your experience...
            </p>
            <div className="animate-spin rounded-full h-8 w-8 border-4 border-white/20 border-t-primary mx-auto"></div>
          </div>
        </div>
      </main>
    );
  }

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
            Create your account
          </p>
        </div>

        {/* Sign Up Card */}
        <div className="glass rounded-3xl p-8 shadow-2xl animate-slide-up">
          {error && (
            <div className="mb-4 p-3 bg-red-500/20 border border-red-500/50 rounded-xl text-red-200 text-sm">
              {error}
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-4">
            {/* Full Name Input */}
            <div className="group">
              <div className="flex items-center gap-3 px-4 py-3.5 bg-white/[0.08] border border-white/[0.12] rounded-xl transition-all focus-within:bg-white/[0.12] focus-within:border-primary/50 focus-within:shadow-lg focus-within:shadow-primary/10">
                <span className="text-base opacity-60">👤</span>
                <input
                  type="text"
                  placeholder="Full name"
                  value={fullName}
                  onChange={(e) => setFullName(e.target.value)}
                  className="flex-1 bg-transparent border-none outline-none text-white placeholder:text-white/40"
                  autoComplete="name"
                />
              </div>
            </div>

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
                  placeholder="Password (min 8 characters)"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="flex-1 bg-transparent border-none outline-none text-white placeholder:text-white/40"
                  autoComplete="new-password"
                />
              </div>
            </div>

            {/* Confirm Password Input */}
            <div className="group">
              <div className="flex items-center gap-3 px-4 py-3.5 bg-white/[0.08] border border-white/[0.12] rounded-xl transition-all focus-within:bg-white/[0.12] focus-within:border-primary/50 focus-within:shadow-lg focus-within:shadow-primary/10">
                <span className="text-base opacity-60">🔒</span>
                <input
                  type="password"
                  placeholder="Confirm password"
                  value={confirmPassword}
                  onChange={(e) => setConfirmPassword(e.target.value)}
                  className="flex-1 bg-transparent border-none outline-none text-white placeholder:text-white/40"
                  autoComplete="new-password"
                />
              </div>
            </div>

            {/* Sign Up Button */}
            <button
              type="submit"
              disabled={isLoading || !email || !password || !confirmPassword || !fullName}
              className="w-full py-3.5 bg-gradient-to-r from-primary to-purple-600 rounded-xl text-white font-bold uppercase tracking-wider text-base transition-all hover:scale-[1.02] hover:shadow-xl hover:shadow-primary/40 active:scale-[0.98] disabled:opacity-70 disabled:cursor-not-allowed disabled:hover:scale-100 mt-6"
            >
              {isLoading ? 'Creating Account...' : 'Create Account'}
            </button>

            {/* Divider */}
            <div className="text-center my-6">
              <span className="text-sm font-semibold text-white/60">Or sign up with</span>
            </div>

            {/* Social Buttons */}
            <div className="grid grid-cols-2 gap-3">
              <button
                type="button"
                onClick={handleAppleSignUp}
                disabled={isLoading}
                className="flex items-center justify-center gap-2 px-4 py-3 bg-white/[0.08] border border-white/[0.16] rounded-xl text-white font-semibold text-sm transition-all hover:bg-white/[0.12] hover:border-primary/50 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <span>🍎</span>
                <span>Apple</span>
              </button>
              <button
                type="button"
                onClick={handleGoogleSignUp}
                disabled={isLoading}
                className="flex items-center justify-center gap-2 px-4 py-3 bg-white/[0.08] border border-white/[0.16] rounded-xl text-white font-semibold text-sm transition-all hover:bg-white/[0.12] hover:border-primary/50 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <span>🌐</span>
                <span>Google</span>
              </button>
            </div>

            {/* Already have account */}
            <div className="text-center mt-5">
              <span className="text-sm text-white/60">Already have an account? </span>
              <button
                type="button"
                onClick={() => router.push('/')}
                className="text-sm font-semibold text-primary hover:text-primary-hover transition-colors"
              >
                Sign in
              </button>
            </div>
          </form>
        </div>

        {/* Terms */}
        <p className="text-center text-xs text-white/50 mt-6 px-4">
          By creating an account, you agree to our Terms of Service and Privacy Policy
        </p>
      </div>
    </main>
  );
}
