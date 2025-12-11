'use client';

// Force dynamic rendering to avoid build-time Supabase client initialization
export const dynamic = 'force-dynamic';

import { Suspense, useEffect, useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { motion } from 'framer-motion';
import { CheckCircle2, Loader2, AlertCircle, UserPlus } from 'lucide-react';
import AuroraBackground from '@/components/AuroraBackground';
import { auth, agentDb, supabase } from '@/lib/supabase';

function AcceptInvitationContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const invitationId = searchParams.get('id');

  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [invitation, setInvitation] = useState<any>(null);
  const [agentInfo, setAgentInfo] = useState<any>(null);
  const [status, setStatus] = useState<'checking' | 'ready' | 'accepting' | 'success' | 'error'>('checking');

  // For login/signup
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [isSignup, setIsSignup] = useState(true); // Default to signup since most users won't have accounts
  const [fullName, setFullName] = useState('');

  useEffect(() => {
    if (!invitationId) {
      setError('Invalid invitation link');
      setStatus('error');
      setLoading(false);
      return;
    }

    checkInvitationAndUser();
  }, [invitationId]);

  const checkInvitationAndUser = async () => {
    try {
      // Fetch invitation details
      const { data: invData, error: invError } = await supabase
        .from('agent_client_connections')
        .select('*')
        .eq('id', invitationId)
        .single();

      // If we got the invitation, try to fetch agent details separately
      let agentDetails = null;
      if (invData && invData.agent_id) {
        try {
          // Fetch agent profile
          const { data: agentData, error: agentError } = await supabase
            .from('agent_profiles')
            .select('*')
            .eq('id', invData.agent_id)
            .single();

          if (!agentError && agentData) {
            // Fetch user profile separately if agent has user_id
            if (agentData.user_id) {
              const { data: userData } = await supabase
                .from('profiles')
                .select('*')
                .eq('id', agentData.user_id)
                .single();

              // Combine the data
              agentDetails = {
                ...agentData,
                user: userData
              };
            } else {
              agentDetails = agentData;
            }
          }
        } catch (error) {
          console.error('Error fetching agent details:', error);
          // Continue without agent details - page will still work
        }
      }

      if (invError || !invData) {
        console.error('Invitation fetch error:', invError);
        console.log('Invitation ID:', invitationId);
        setError('Invitation not found or has expired');
        setStatus('error');
        setLoading(false);
        return;
      }

      console.log('Invitation data:', invData);
      console.log('Invitation status:', invData.status);

      if (invData.status !== 'pending') {
        console.error('Invitation status is not pending:', invData.status);
        setError(`This invitation has already been ${invData.status === 'active' ? 'accepted' : invData.status}`);
        setStatus('error');
        setLoading(false);
        return;
      }

      setInvitation(invData);
      setAgentInfo(agentDetails);
      setEmail(invData.invited_email || '');

      // Check if user is already logged in
      const { data: session } = await auth.getSession();
      console.log('Session check:', session);

      if (session?.session?.user) {
        console.log('User is logged in, auto-accepting...');
        // User is logged in, auto-accept invitation
        await acceptInvitation(session.session.user.id);
      } else {
        console.log('No session, showing signup form');
        // User needs to login/signup
        setStatus('ready');
        setLoading(false);
      }
    } catch (err: any) {
      console.error('Error checking invitation:', err);
      setError(err.message || 'Failed to load invitation');
      setStatus('error');
      setLoading(false);
    }
  };

  const acceptInvitation = async (userId: string) => {
    try {
      setStatus('accepting');

      console.log('🔄 Accepting invitation with:', { invitationId, userId });

      // Update the connection with the user's ID and set to active
      const { error: updateError } = await agentDb.acceptInvitation(invitationId!, userId);

      if (updateError) {
        console.error('❌ Accept invitation error:', JSON.stringify(updateError, null, 2));
        console.error('❌ Full error object:', updateError);
        throw updateError;
      }

      console.log('✅ Invitation accepted successfully');
      setStatus('success');

      // Redirect to home after 2 seconds
      setTimeout(() => {
        router.push('/home');
      }, 2000);
    } catch (err: any) {
      console.error('❌ Error accepting invitation:', JSON.stringify(err, null, 2));
      console.error('❌ Full error:', err);
      setError(err.message || 'Failed to accept invitation');
      setStatus('error');

      // If session expired, log the user out automatically
      if (err.code === 'SESSION_EXPIRED') {
        console.log('🔄 Session expired, logging out...');
        setTimeout(async () => {
          await auth.signOut();
          window.location.reload();
        }, 3000);
      }
    }
  };

  const handleAuth = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      if (isSignup) {
        // Sign up new user
        console.log('📝 Signing up user:', email);
        const { data, error } = await supabase.auth.signUp({
          email,
          password,
          options: {
            data: {
              full_name: fullName,
              display_name: fullName.split(' ')[0],
            },
          },
        });

        if (error) throw error;

        if (data.user) {
          console.log('✅ User signed up:', data.user.id);

          // Wait a moment for session to be fully established
          await new Promise(resolve => setTimeout(resolve, 500));

          // Verify session is set
          const { data: sessionData } = await supabase.auth.getSession();
          console.log('Session after signup:', sessionData.session ? 'exists' : 'missing');

          // Accept invitation
          await acceptInvitation(data.user.id);
        }
      } else {
        // Sign in existing user
        console.log('🔐 Signing in user:', email);
        const { data, error } = await auth.signIn(email, password);

        if (error) throw error;

        if (data.user) {
          console.log('✅ User signed in:', data.user.id);
          // Accept invitation
          await acceptInvitation(data.user.id);
        }
      }
    } catch (err: any) {
      console.error('Auth error:', err);
      setError(err.message || 'Authentication failed');
      setLoading(false);
    }
  };

  if (status === 'checking' || (loading && !invitation)) {
    return (
      <main className="relative min-h-screen flex items-center justify-center p-5">
        <AuroraBackground />
        <div className="relative z-10 text-center">
          <Loader2 className="w-12 h-12 text-purple-400 animate-spin mx-auto mb-4" />
          <p className="text-white text-lg">Loading invitation...</p>
        </div>
      </main>
    );
  }

  if (status === 'accepting') {
    return (
      <main className="relative min-h-screen flex items-center justify-center p-5">
        <AuroraBackground />
        <div className="relative z-10 text-center">
          <Loader2 className="w-12 h-12 text-purple-400 animate-spin mx-auto mb-4" />
          <p className="text-white text-lg">Accepting invitation...</p>
        </div>
      </main>
    );
  }

  if (status === 'success') {
    return (
      <main className="relative min-h-screen flex items-center justify-center p-5">
        <AuroraBackground />
        <motion.div
          initial={{ scale: 0.9, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          className="relative z-10 text-center glass-strong rounded-3xl p-12 max-w-md"
        >
          <div className="w-20 h-20 rounded-full bg-gradient-to-br from-green-500 to-emerald-500 flex items-center justify-center mx-auto mb-6">
            <CheckCircle2 className="w-12 h-12 text-white" />
          </div>
          <h1 className="text-3xl font-bold text-white mb-4">Welcome to HOMEY!</h1>
          <p className="text-white/80 mb-2">
            You're now connected with {agentInfo?.user?.full_name || 'your agent'}
          </p>
          <p className="text-white/60 text-sm">Redirecting you to your home feed...</p>
        </motion.div>
      </main>
    );
  }

  if (status === 'error') {
    return (
      <main className="relative min-h-screen flex items-center justify-center p-5">
        <AuroraBackground />
        <div className="relative z-10 text-center glass-strong rounded-3xl p-12 max-w-md">
          <div className="w-20 h-20 rounded-full bg-red-500/20 flex items-center justify-center mx-auto mb-6">
            <AlertCircle className="w-12 h-12 text-red-400" />
          </div>
          <h1 className="text-2xl font-bold text-white mb-4">Oops!</h1>
          <p className="text-white/80 mb-6">{error}</p>
          <button
            onClick={() => router.push('/')}
            className="px-6 py-3 rounded-xl bg-gradient-to-r from-purple-500 to-pink-500 text-white font-semibold hover:shadow-lg hover:shadow-purple-500/50 transition-all"
          >
            Go to Login
          </button>
        </div>
      </main>
    );
  }

  // Show login/signup form
  return (
    <main className="relative min-h-screen flex items-center justify-center p-5">
      <AuroraBackground />

      <div className="relative z-10 w-full max-w-md">
        <motion.div
          initial={{ y: 20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          className="glass-strong rounded-3xl p-8 mb-6"
        >
          <div className="flex items-center gap-4 mb-6">
            <div className="w-16 h-16 rounded-full bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center flex-shrink-0">
              <UserPlus className="w-8 h-8 text-white" />
            </div>
            <div>
              <h2 className="text-xl font-bold text-white">
                {agentInfo?.user?.full_name || 'Your Agent'}
              </h2>
              {agentInfo?.brokerage_name && (
                <p className="text-white/60 text-sm">{agentInfo.brokerage_name}</p>
              )}
            </div>
          </div>

          {invitation?.invitation_message && (
            <div className="bg-white/5 rounded-xl p-4 mb-6 border border-white/10">
              <p className="text-white/80 text-sm italic">"{invitation.invitation_message}"</p>
            </div>
          )}

          <p className="text-white/60 text-sm mb-6">
            {isSignup
              ? 'Create your account to connect with your agent'
              : 'Sign in to accept this invitation'}
          </p>
        </motion.div>

        <motion.div
          initial={{ y: 20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 0.1 }}
          className="glass rounded-3xl p-8"
        >
          {error && (
            <div className="mb-4 p-3 bg-red-500/20 border border-red-500/50 rounded-xl text-red-200 text-sm">
              {error}
            </div>
          )}

          <form onSubmit={handleAuth} className="space-y-4">
            {isSignup && (
              <div>
                <input
                  type="text"
                  placeholder="Full Name"
                  value={fullName}
                  onChange={(e) => setFullName(e.target.value)}
                  required
                  className="w-full px-4 py-3.5 bg-white/[0.08] border border-white/[0.12] rounded-xl text-white placeholder:text-white/40 focus:bg-white/[0.12] focus:border-purple-500/50 focus:outline-none"
                />
              </div>
            )}

            <div>
              <input
                type="email"
                placeholder="Email address"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                disabled={!!invitation?.invited_email}
                className="w-full px-4 py-3.5 bg-white/[0.08] border border-white/[0.12] rounded-xl text-white placeholder:text-white/40 focus:bg-white/[0.12] focus:border-purple-500/50 focus:outline-none disabled:opacity-50"
              />
            </div>

            <div>
              <input
                type="password"
                placeholder="Password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                className="w-full px-4 py-3.5 bg-white/[0.08] border border-white/[0.12] rounded-xl text-white placeholder:text-white/40 focus:bg-white/[0.12] focus:border-purple-500/50 focus:outline-none"
              />
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full py-3.5 bg-gradient-to-r from-purple-500 to-pink-500 rounded-xl text-white font-bold uppercase tracking-wider hover:shadow-xl hover:shadow-purple-500/50 transition-all disabled:opacity-50"
            >
              {loading ? 'Processing...' : isSignup ? 'Create Account & Accept' : 'Sign In & Accept'}
            </button>
          </form>

          <div className="text-center mt-5">
            <button
              type="button"
              onClick={() => setIsSignup(!isSignup)}
              className="text-sm text-purple-400 hover:text-purple-300 transition-colors"
            >
              {isSignup ? 'Already have an account? Sign in' : "Don't have an account? Sign up"}
            </button>
          </div>
        </motion.div>
      </div>
    </main>
  );
}

export default function AcceptInvitationPage() {
  return (
    <Suspense fallback={
      <div className="min-h-screen bg-gradient-to-br from-purple-900 via-pink-800 to-orange-700 flex items-center justify-center">
        <Loader2 className="w-8 h-8 text-white animate-spin" />
      </div>
    }>
      <AcceptInvitationContent />
    </Suspense>
  );
}
