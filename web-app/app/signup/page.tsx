'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';
import { Key } from 'lucide-react';
import AuroraBackground from '@/components/AuroraBackground';
import { auth, db, supabase } from '@/lib/supabase';
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

  // Access code state
  const [showAccessCodeModal, setShowAccessCodeModal] = useState(true);
  const [accessCode, setAccessCode] = useState('');
  const [codeError, setCodeError] = useState('');
  const [validatingCode, setValidatingCode] = useState(false);

  // Coming soon modal state
  const [showComingSoonModal, setShowComingSoonModal] = useState(false);

  // Error modal state
  const [errorModal, setErrorModal] = useState<string | null>(null);

  const handleAccessCodeSubmit = async () => {
    if (!accessCode.trim()) return;

    setValidatingCode(true);
    setCodeError('');

    try {
      const { data, error } = await supabase.rpc('validate_early_access_code', {
        access_code: accessCode.trim()
      });

      if (error) throw error;

      if (data?.valid) {
        setShowAccessCodeModal(false); // Close modal and show signup form
      } else {
        setCodeError(data?.message || 'Invalid access code');
      }
    } catch (error) {
      console.error('Error validating code:', error);
      setCodeError('Unable to validate code. Please try again.');
    } finally {
      setValidatingCode(false);
    }
  };

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
    setErrorModal(null);

    try {
      // Sign up with Supabase
      const { data, error: signUpError } = await auth.signUp(email, password);

      if (signUpError) {
        setErrorModal(signUpError.message);
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
          setErrorModal('Account created! Please sign in to continue.');
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
        setErrorModal('Sign up failed. Please try again.');
        setIsLoading(false);
      }
    } catch (err: any) {
      setErrorModal(err.message || 'An error occurred. Please try again.');
      setIsLoading(false);
    }
  };

  const handleGoogleSignUp = () => {
    setShowComingSoonModal(true);
  };

  const handleAppleSignUp = () => {
    setShowComingSoonModal(true);
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

      {/* Access Code Modal */}
      <AnimatePresence>
        {showAccessCodeModal && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-[100] flex items-center justify-center p-5 bg-black/60 backdrop-blur-sm"
          >
            <motion.div
              initial={{ scale: 0.9, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0.9, opacity: 0 }}
              className="relative z-[101] w-full max-w-md"
            >
              <div className="glass-strong rounded-3xl p-8 shadow-2xl border border-white/20">
                {/* Header */}
                <div className="text-center mb-8">
                  <h1 className="text-4xl font-bold tracking-wider mb-2 text-shadow-lg">
                    HOMEY
                  </h1>
                  <p className="text-xl font-semibold text-white/80 mb-2">
                    Early Access
                  </p>
                  <p className="text-sm text-white/60">
                    Enter your access code to continue
                  </p>
                </div>

                {/* Access Code Input */}
                <div className="space-y-6">
                  <div className="relative">
                    <div className="absolute left-4 top-1/2 -translate-y-1/2">
                      <Key className="w-6 h-6 text-white/20" />
                    </div>
                    <input
                      autoFocus
                      value={accessCode}
                      onChange={(e) => {
                        setAccessCode(e.target.value.toUpperCase());
                        setCodeError('');
                      }}
                      onKeyDown={(e) => e.key === 'Enter' && handleAccessCodeSubmit()}
                      className="w-full bg-transparent border-b border-white/20 pl-14 p-4 text-3xl text-white outline-none focus:border-white transition-colors placeholder:text-white/10 font-mono tracking-widest"
                      placeholder="ACCESS CODE"
                      disabled={validatingCode}
                    />
                  </div>

                  {codeError && (
                    <motion.p
                      initial={{ opacity: 0, y: -10 }}
                      animate={{ opacity: 1, y: 0 }}
                      className="text-red-400 text-sm"
                    >
                      {codeError}
                    </motion.p>
                  )}

                  <button
                    onClick={handleAccessCodeSubmit}
                    disabled={!accessCode.trim() || validatingCode}
                    className="w-full mt-8 py-5 bg-white text-black rounded-2xl font-bold text-lg disabled:opacity-50 disabled:cursor-not-allowed transition-all hover:scale-[1.02]"
                  >
                    {validatingCode ? 'Validating...' : 'Verify Access'}
                  </button>

                  <div className="text-center">
                    <button
                      onClick={() => router.push('/')}
                      className="text-sm text-white/60 hover:text-white transition-colors"
                    >
                      Back to login
                    </button>
                  </div>
                </div>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Coming Soon Modal */}
      <AnimatePresence>
        {showComingSoonModal && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={() => setShowComingSoonModal(false)}
            className="fixed inset-0 z-[100] flex items-center justify-center p-5 bg-black/60 backdrop-blur-sm"
          >
            <motion.div
              initial={{ scale: 0.9, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0.9, opacity: 0 }}
              onClick={(e) => e.stopPropagation()}
              className="relative z-[101] w-full max-w-sm"
            >
              <div className="glass-strong rounded-3xl p-8 shadow-2xl border border-white/20 text-center">
                <div className="text-6xl mb-4">🚀</div>
                <h2 className="text-2xl font-serif text-white mb-3" style={{ fontFamily: 'Playfair Display, serif' }}>
                  Coming Soon
                </h2>
                <p className="text-white/60 mb-6">
                  Social sign-in is on its way. For now, please create an account with your email.
                </p>
                <button
                  onClick={() => setShowComingSoonModal(false)}
                  className="w-full py-3 bg-white text-black rounded-xl font-bold text-base transition-all hover:scale-[1.02]"
                >
                  Got it
                </button>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Error Modal */}
      <AnimatePresence>
        {errorModal && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={() => setErrorModal(null)}
            className="fixed inset-0 z-[100] flex items-center justify-center p-5 bg-black/60 backdrop-blur-sm"
          >
            <motion.div
              initial={{ scale: 0.9, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0.9, opacity: 0 }}
              onClick={(e) => e.stopPropagation()}
              className="relative z-[101] w-full max-w-sm"
            >
              <div className="glass-strong rounded-3xl p-8 shadow-2xl border border-white/20 text-center">
                <div className="text-6xl mb-4">⚠️</div>
                <h2 className="text-2xl font-serif text-white mb-3" style={{ fontFamily: 'Playfair Display, serif' }}>
                  Oops!
                </h2>
                <p className="text-white/80 mb-6">
                  {errorModal}
                </p>
                <button
                  onClick={() => setErrorModal(null)}
                  className="w-full py-3 bg-white text-black rounded-xl font-bold text-base transition-all hover:scale-[1.02]"
                >
                  Try Again
                </button>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Signup Form (only shown after access code is validated) */}
      {!showAccessCodeModal && (
        <div className="relative z-10 w-full max-w-md px-4">
          {/* Header */}
          <div className="mb-12">
            <h1 className="text-4xl font-serif text-white mb-2" style={{ fontFamily: 'Playfair Display, serif' }}>
              Welcome to HOMEY.
            </h1>
            <p className="text-white/50">
              Let's create your account.
            </p>
          </div>

          <form onSubmit={handleSubmit} className="space-y-6">
            {/* Full Name Input */}
            <input
              autoFocus
              type="text"
              placeholder="Full Name"
              value={fullName}
              onChange={(e) => setFullName(e.target.value)}
              className="w-full bg-transparent border-b border-white/20 p-4 text-2xl text-white outline-none focus:border-white transition-colors placeholder:text-white/20 font-serif"
              style={{ fontFamily: 'Playfair Display, serif' }}
              autoComplete="name"
            />

            {/* Email Input */}
            <input
              type="email"
              placeholder="Email Address"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="w-full bg-transparent border-b border-white/20 p-4 text-2xl text-white outline-none focus:border-white transition-colors placeholder:text-white/20 font-serif"
              style={{ fontFamily: 'Playfair Display, serif' }}
              autoComplete="email"
            />

            {/* Password Input */}
            <input
              type="password"
              placeholder="Password (min 8 characters)"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full bg-transparent border-b border-white/20 p-4 text-2xl text-white outline-none focus:border-white transition-colors placeholder:text-white/20 font-serif"
              style={{ fontFamily: 'Playfair Display, serif' }}
              autoComplete="new-password"
            />

            {/* Confirm Password Input */}
            <input
              type="password"
              placeholder="Confirm Password"
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              className="w-full bg-transparent border-b border-white/20 p-4 text-2xl text-white outline-none focus:border-white transition-colors placeholder:text-white/20 font-serif"
              style={{ fontFamily: 'Playfair Display, serif' }}
              autoComplete="new-password"
            />

            {/* Sign Up Button */}
            <button
              type="submit"
              disabled={isLoading || !email || !password || !confirmPassword || !fullName}
              className="w-full mt-8 py-5 bg-white text-black rounded-2xl font-bold text-lg disabled:opacity-50 disabled:cursor-not-allowed transition-all hover:scale-[1.02]"
            >
              {isLoading ? 'Creating Account...' : 'Create Account'}
            </button>

            {/* Divider */}
            <div className="text-center my-8">
              <span className="text-sm text-white/40">Or continue with</span>
            </div>

            {/* Social Buttons */}
            <div className="grid grid-cols-2 gap-3">
              <button
                type="button"
                onClick={handleAppleSignUp}
                className="px-4 py-3 bg-white/5 hover:bg-white/10 border border-white/10 rounded-xl text-white font-medium text-sm transition-all"
              >
                🍎 Apple
              </button>
              <button
                type="button"
                onClick={handleGoogleSignUp}
                className="px-4 py-3 bg-white/5 hover:bg-white/10 border border-white/10 rounded-xl text-white font-medium text-sm transition-all"
              >
                🌐 Google
              </button>
            </div>

            {/* Already have account */}
            <div className="text-center mt-8">
              <span className="text-sm text-white/60">Already have an account? </span>
              <button
                type="button"
                onClick={() => router.push('/')}
                className="text-sm font-semibold text-white hover:text-white/80 transition-colors"
              >
                Sign in
              </button>
            </div>

            {/* Terms */}
            <p className="text-center text-xs text-white/40 mt-6">
              By creating an account, you agree to our Terms of Service and Privacy Policy
            </p>
          </form>
        </div>
      )}
    </main>
  );
}
