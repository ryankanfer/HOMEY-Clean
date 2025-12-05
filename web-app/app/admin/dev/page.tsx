'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { motion } from 'framer-motion';
import { Code, ArrowLeft, Shield } from 'lucide-react';
import { db, auth } from '@/lib/supabase';
import { checkAdminFromProfile } from '@/lib/admin';
import { setAdminViewMode, type ViewAsMode } from '@/lib/adminViewMode';
import CinematicBackground from '@/components/CinematicBackground';

export default function DeveloperToolsPage() {
  const router = useRouter();
  const [loading, setLoading] = useState(true);
  const [authorized, setAuthorized] = useState(false);

  useEffect(() => {
    checkAdminAccess();
  }, []);

  const checkAdminAccess = async () => {
    try {
      const { data: { user } } = await auth.getUser();

      if (!user) {
        router.push('/');
        return;
      }

      const { data: profile } = await db.getProfile(user.id);
      const isAdmin = checkAdminFromProfile(profile);

      if (!isAdmin) {
        router.push('/home');
        return;
      }

      setAuthorized(true);
    } catch (error) {
      console.error('Failed to check admin access:', error);
      router.push('/home');
    } finally {
      setLoading(false);
    }
  };

  const navigateToPage = (path: string, requiredMode?: ViewAsMode) => {
    if (requiredMode) {
      setAdminViewMode(requiredMode);
    }
    router.push(path);
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-black">
        <motion.div
          animate={{ rotate: 360 }}
          transition={{ duration: 1, repeat: Infinity, ease: 'linear' }}
          className="w-8 h-8 border-2 border-white/20 border-t-white rounded-full"
        />
      </div>
    );
  }

  if (!authorized) {
    return null;
  }

  return (
    <main className="relative min-h-screen pb-24">
      <CinematicBackground timeOfDay="day" />

      {/* Dark overlay */}
      <div className="fixed inset-0 z-0 bg-gradient-to-b from-black/30 via-black/20 to-black/40" />

      {/* Content */}
      <div className="relative z-10 min-h-screen">
        {/* Header */}
        <header className="sticky top-0 z-50 bg-gradient-to-b from-black/60 via-black/40 to-transparent backdrop-blur-sm">
          <div className="flex items-center justify-between px-5 py-4">
            <div className="flex items-center gap-3">
              <button
                onClick={() => router.push('/admin')}
                className="p-2 hover:bg-white/10 rounded-lg transition-colors"
              >
                <ArrowLeft className="w-5 h-5 text-white" />
              </button>
              <div>
                <h1 className="text-2xl font-bold text-white flex items-center gap-2">
                  <Code className="w-6 h-6 text-cyan-400" />
                  Developer Tools
                </h1>
                <p className="text-sm text-white/60">Page explorer and debugging tools</p>
              </div>
            </div>
            <div className="px-4 py-2 bg-gradient-to-r from-cyan-500/20 to-blue-500/20 border border-cyan-500/30 rounded-full">
              <span className="text-xs font-bold text-cyan-400">DEV</span>
            </div>
          </div>
        </header>

        <div className="px-4 md:px-5 py-6 md:py-8 max-w-7xl mx-auto">
          {/* Page Explorer */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="glass-strong rounded-2xl p-6 border border-white/10"
          >
            <div className="flex items-center gap-3 mb-6">
              <div className="w-10 h-10 bg-gradient-to-br from-cyan-500 to-blue-500 rounded-lg flex items-center justify-center">
                <Code className="w-6 h-6 text-white" />
              </div>
              <div>
                <h2 className="text-lg font-semibold text-white">Page Explorer</h2>
                <p className="text-xs text-white/60">Quick access to all pages in different view modes</p>
              </div>
            </div>

            <div className="space-y-6">
              {/* Client Portal */}
              <div>
                <div className="border-b border-white/10 pb-2 mb-3">
                  <h3 className="text-sm font-semibold text-white/80 uppercase tracking-wider">Client Portal</h3>
                  <p className="text-xs text-white/40 mt-1">Pages for buyers and renters</p>
                </div>
                <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-2">
                  {[
                    { path: '/directory', label: 'Agent Directory', desc: 'All agents' },
                    { path: '/vault', label: 'Document Vault', desc: 'Secure docs' },
                    { path: '/education', label: 'Education', desc: 'Learn more' },
                    { path: '/home', label: 'Home Feed', desc: 'Main feed' },
                    { path: '/learn', label: 'Learn Hub', desc: 'Education' },
                    { path: '/matchmaker', label: 'Matchmaker', desc: 'Find agents' },
                    { path: '/saved', label: 'Saved Properties', desc: 'Favorites' },
                    { path: '/search', label: 'Search', desc: 'Find properties' },
                    { path: '/settings', label: 'Settings', desc: 'User settings' },
                    { path: '/profile', label: 'User Profile', desc: 'Profile page' },
                  ].map((page) => (
                    <button
                      key={page.path}
                      onClick={() => navigateToPage(page.path, 'client')}
                      className="p-3 bg-white/5 hover:bg-white/10 border border-white/10 hover:border-cyan-400/30 rounded-lg text-left transition-all group"
                    >
                      <div className="text-sm font-medium text-white group-hover:text-cyan-400 transition-colors">
                        {page.label}
                      </div>
                      <div className="text-[10px] text-white/40 mt-1">{page.desc}</div>
                      <div className="text-[10px] text-white/30 font-mono mt-1">{page.path}</div>
                      <div className="text-[9px] text-cyan-400/60 mt-1">→ View as Client</div>
                    </button>
                  ))}
                </div>
              </div>

              {/* Agent Portal */}
              <div>
                <div className="border-b border-white/10 pb-2 mb-3">
                  <h3 className="text-sm font-semibold text-white/80 uppercase tracking-wider">Agent Portal</h3>
                  <p className="text-xs text-white/40 mt-1">Pages for real estate agents</p>
                </div>
                <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-2">
                  {[
                    { path: '/agent', label: 'Agent Dashboard', desc: 'Main hub' },
                    { path: '/agent/register', label: 'Agent Registration', desc: 'Sign up' },
                    { path: '/calendar', label: 'Calendar', desc: 'Schedule' },
                    { path: '/agent/clients', label: 'Client Management', desc: 'Manage clients' },
                    { path: '/agent/documents', label: 'Documents', desc: 'Files & docs' },
                    { path: '/agent/listings', label: 'Listings', desc: 'Properties' },
                    { path: '/agent/messages', label: 'Messages', desc: 'Chat' },
                    { path: '/agent/showings', label: 'Showings', desc: 'Schedule tours' },
                  ].map((page) => (
                    <button
                      key={page.path}
                      onClick={() => navigateToPage(page.path, 'agent')}
                      className="p-3 bg-white/5 hover:bg-white/10 border border-white/10 hover:border-purple-400/30 rounded-lg text-left transition-all group"
                    >
                      <div className="text-sm font-medium text-white group-hover:text-purple-400 transition-colors">
                        {page.label}
                      </div>
                      <div className="text-[10px] text-white/40 mt-1">{page.desc}</div>
                      <div className="text-[10px] text-white/30 font-mono mt-1">{page.path}</div>
                      <div className="text-[9px] text-purple-400/60 mt-1">→ View as Agent</div>
                    </button>
                  ))}
                </div>
              </div>

              {/* Development & Testing */}
              <div>
                <div className="border-b border-white/10 pb-2 mb-3">
                  <h3 className="text-sm font-semibold text-white/80 uppercase tracking-wider">Development & Testing</h3>
                  <p className="text-xs text-white/40 mt-1">Special pages and flows</p>
                </div>
                <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-2">
                  {[
                    { path: '/db-test', label: 'Database Test', desc: 'DB testing' },
                    { path: '/onboarding?force=true', label: 'Onboarding Flow', desc: 'User onboarding' },
                    { path: '/signup', label: 'Signup Page', desc: 'Registration' },
                    { path: '/studio', label: 'Style Studio', desc: 'Design prefs' },
                    { path: '/teach', label: 'Teach (ML)', desc: 'ML training' },
                  ].map((page) => (
                    <button
                      key={page.path}
                      onClick={() => navigateToPage(page.path)}
                      className="p-3 bg-white/5 hover:bg-white/10 border border-white/10 hover:border-green-400/30 rounded-lg text-left transition-all group"
                    >
                      <div className="text-sm font-medium text-white group-hover:text-green-400 transition-colors">
                        {page.label}
                      </div>
                      <div className="text-[10px] text-white/40 mt-1">{page.desc}</div>
                      <div className="text-[10px] text-white/30 font-mono mt-1">{page.path}</div>
                      <div className="text-[9px] text-green-400/60 mt-1">→ Keep current mode</div>
                    </button>
                  ))}
                </div>
              </div>
            </div>
          </motion.div>

          {/* Quick Info */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="mt-6 p-4 bg-cyan-500/10 border border-cyan-500/30 rounded-xl"
          >
            <div className="flex items-start gap-3">
              <Shield className="w-5 h-5 text-cyan-400 flex-shrink-0 mt-0.5" />
              <div>
                <p className="text-sm text-cyan-300 font-medium mb-1">Developer Mode Active</p>
                <p className="text-xs text-white/60">
                  When you click a page link, the app will automatically switch to the appropriate view mode (Client, Agent, or keep current).
                  You can always return to admin view from the admin button.
                </p>
              </div>
            </div>
          </motion.div>
        </div>
      </div>
    </main>
  );
}
