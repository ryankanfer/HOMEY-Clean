'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { ChevronDown, ChevronUp, Mail, Calendar, Download, RefreshCw, Users as UsersIcon } from 'lucide-react';
import { supabase } from '@/lib/supabase';

interface BetaSignup {
  id: string;
  email: string;
  name?: string;
  feedback?: string;
  created_at: string;
}

export default function BetaSignups() {
  const [isExpanded, setIsExpanded] = useState(false);
  const [signups, setSignups] = useState<BetaSignup[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (isExpanded) {
      loadSignups();
    }
  }, [isExpanded]);

  const loadSignups = async () => {
    setLoading(true);
    setError(null);
    try {
      const { data, error: fetchError } = await supabase
        .from('beta_signups')
        .select('*')
        .order('created_at', { ascending: false });

      if (fetchError) throw fetchError;
      setSignups(data || []);
    } catch (err: any) {
      console.error('Error loading beta signups:', err);
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const exportToCSV = () => {
    const headers = ['Email', 'Name', 'Feedback/Notes', 'Signed Up'];
    const rows = signups.map(s => [
      s.email,
      s.name || 'N/A',
      s.feedback ? `"${s.feedback.replace(/"/g, '""')}"` : 'N/A',
      new Date(s.created_at).toLocaleString()
    ]);

    const csv = [
      headers.join(','),
      ...rows.map(row => row.join(','))
    ].join('\n');

    const blob = new Blob([csv], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `beta-signups-${new Date().toISOString().split('T')[0]}.csv`;
    a.click();
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      month: 'short',
      day: 'numeric',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="glass-strong rounded-2xl border border-white/10 overflow-hidden"
    >
      {/* Header */}
      <button
        onClick={() => setIsExpanded(!isExpanded)}
        className="w-full px-4 md:px-6 py-4 flex items-center justify-between hover:bg-white/5 transition-colors touch-manipulation"
      >
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-gradient-to-br from-green-500 to-emerald-500 rounded-lg flex items-center justify-center">
            <UsersIcon className="w-6 h-6 text-white" />
          </div>
          <div className="text-left">
            <h2 className="text-base md:text-lg font-semibold text-white">Beta Signups</h2>
            <p className="text-xs text-white/60">
              {signups.length} total {signups.length !== 1 ? 'signups' : 'signup'}
            </p>
          </div>
        </div>
        {isExpanded ? (
          <ChevronUp className="w-5 h-5 text-white/60" />
        ) : (
          <ChevronDown className="w-5 h-5 text-white/60" />
        )}
      </button>

      <AnimatePresence>
        {isExpanded && (
          <motion.div
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: 'auto', opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            className="px-4 md:px-6 pb-6"
          >
            {/* Actions */}
            <div className="flex gap-2 mb-4">
              <button
                onClick={loadSignups}
                disabled={loading}
                className="flex items-center gap-2 px-4 py-2 bg-white/5 hover:bg-white/10 disabled:opacity-50 border border-white/10 rounded-lg text-sm text-white transition-all"
              >
                <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
                Refresh
              </button>
              <button
                onClick={exportToCSV}
                disabled={signups.length === 0}
                className="flex items-center gap-2 px-4 py-2 bg-green-500/20 hover:bg-green-500/30 disabled:opacity-50 border border-green-500/30 rounded-lg text-sm text-green-300 transition-all"
              >
                <Download className="w-4 h-4" />
                Export CSV
              </button>
            </div>

            {/* Error State */}
            {error && (
              <div className="mb-4 p-4 bg-red-500/10 border border-red-500/30 rounded-lg">
                <p className="text-sm text-red-400">{error}</p>
                <p className="text-xs text-white/60 mt-1">
                  Make sure the beta_signups table exists in your Supabase database.
                </p>
              </div>
            )}

            {/* Loading State */}
            {loading && signups.length === 0 && (
              <div className="text-center py-8">
                <RefreshCw className="w-8 h-8 text-white/20 mx-auto mb-2 animate-spin" />
                <p className="text-sm text-white/40">Loading signups...</p>
              </div>
            )}

            {/* Empty State */}
            {!loading && !error && signups.length === 0 && (
              <div className="text-center py-12">
                <Mail className="w-12 h-12 text-white/20 mx-auto mb-3" />
                <p className="text-white/40 text-sm mb-2">No beta signups yet</p>
                <p className="text-white/30 text-xs">
                  Signups from your marketing site will appear here
                </p>
              </div>
            )}

            {/* Signups List */}
            {signups.length > 0 && (
              <div className="space-y-2 max-h-96 overflow-y-auto">
                {signups.map((signup, index) => (
                  <motion.div
                    key={signup.id}
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: index * 0.03 }}
                    className="p-4 bg-white/5 border border-white/10 rounded-lg hover:bg-white/10 transition-colors"
                  >
                    <div className="flex items-start justify-between gap-3">
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-2 mb-2">
                          <Mail className="w-4 h-4 text-green-400 flex-shrink-0" />
                          <p className="text-sm font-medium text-white truncate">
                            {signup.email}
                          </p>
                        </div>
                        {signup.name && (
                          <p className="text-xs text-white/60 mb-1">
                            Name: {signup.name}
                          </p>
                        )}
                        {signup.feedback && (
                          <div className="mb-2 p-2 bg-white/5 rounded border border-white/5">
                            <p className="text-xs text-white/50 mb-1 font-medium">Feedback/Notes:</p>
                            <p className="text-xs text-white/80 italic">"{signup.feedback}"</p>
                          </div>
                        )}
                        <div className="flex items-center gap-2">
                          <Calendar className="w-3 h-3 text-white/40" />
                          <p className="text-xs text-white/40">
                            {formatDate(signup.created_at)}
                          </p>
                        </div>
                      </div>
                    </div>
                  </motion.div>
                ))}
              </div>
            )}

            {/* Stats */}
            {signups.length > 0 && (
              <div className="mt-4 p-3 bg-white/5 rounded-lg border border-white/10">
                <div className="grid grid-cols-2 gap-4 text-center">
                  <div>
                    <div className="text-2xl font-bold text-white">{signups.length}</div>
                    <div className="text-xs text-white/60">Total Signups</div>
                  </div>
                  <div>
                    <div className="text-2xl font-bold text-white">
                      {signups.filter(s => {
                        const date = new Date(s.created_at);
                        const today = new Date();
                        return date.toDateString() === today.toDateString();
                      }).length}
                    </div>
                    <div className="text-xs text-white/60">Today</div>
                  </div>
                </div>
              </div>
            )}
          </motion.div>
        )}
      </AnimatePresence>
    </motion.div>
  );
}
