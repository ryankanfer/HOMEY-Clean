'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import AuroraBackground from '@/components/AuroraBackground';

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!email || !password) {
      alert('Please enter both email and password');
      return;
    }

    setIsLoading(true);

    // Simulate login - will connect to Supabase next
    await new Promise(resolve => setTimeout(resolve, 1500));

    // Navigate to dashboard
    router.push('/dashboard');
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
                className="flex items-center justify-center gap-2 px-4 py-3 bg-white/[0.08] border border-white/[0.16] rounded-xl text-white font-semibold text-sm transition-all hover:bg-white/[0.12] hover:border-primary/50"
              >
                <span>🍎</span>
                <span>Apple</span>
              </button>
              <button
                type="button"
                className="flex items-center justify-center gap-2 px-4 py-3 bg-white/[0.08] border border-white/[0.16] rounded-xl text-white font-semibold text-sm transition-all hover:bg-white/[0.12] hover:border-primary/50"
              >
                <span>🌐</span>
                <span>Google</span>
              </button>
            </div>

            {/* Create Account */}
            <div className="text-center mt-5">
              <a href="#" className="text-sm font-semibold text-primary hover:text-primary-hover transition-colors">
                Create account
              </a>
            </div>
          </form>
        </div>
      </div>
    </main>
  );
}
