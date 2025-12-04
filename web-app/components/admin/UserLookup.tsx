'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Search, User, Mail, Calendar, Eye, ChevronDown, ChevronUp, X } from 'lucide-react';
import { supabase } from '@/lib/supabase';
import { setAdminViewMode } from '@/lib/adminViewMode';
import { useRouter } from 'next/navigation';

interface UserResult {
  id: string;
  email: string;
  full_name: string | null;
  user_type: string | null;
  created_at: string;
  last_sign_in_at: string | null;
}

export default function UserLookup() {
  const router = useRouter();
  const [isExpanded, setIsExpanded] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [searching, setSearching] = useState(false);
  const [results, setResults] = useState<UserResult[]>([]);
  const [selectedUser, setSelectedUser] = useState<UserResult | null>(null);

  const handleSearch = async () => {
    if (!searchQuery.trim()) return;

    setSearching(true);
    try {
      const { data, error } = await supabase
        .from('profiles')
        .select('id, email, full_name, user_type, created_at, last_sign_in_at')
        .or(`email.ilike.%${searchQuery}%,full_name.ilike.%${searchQuery}%`)
        .limit(10);

      if (error) throw error;
      setResults(data || []);
    } catch (error) {
      console.error('Error searching users:', error);
    } finally {
      setSearching(false);
    }
  };

  const handleViewAs = (user: UserResult) => {
    // Set view mode based on user type
    const viewMode = user.user_type === 'agent' ? 'agent' : 'client';
    setAdminViewMode(viewMode);

    // Navigate to appropriate page
    const targetPage = user.user_type === 'agent' ? '/agent' : '/home';
    router.push(targetPage);
  };

  const formatDate = (dateString: string | null) => {
    if (!dateString) return 'Never';
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
  };

  const getTimeAgo = (dateString: string | null) => {
    if (!dateString) return 'Never';
    const date = new Date(dateString);
    const now = new Date();
    const diff = now.getTime() - date.getTime();
    const days = Math.floor(diff / (1000 * 60 * 60 * 24));

    if (days === 0) return 'Today';
    if (days === 1) return 'Yesterday';
    if (days < 7) return `${days} days ago`;
    if (days < 30) return `${Math.floor(days / 7)} weeks ago`;
    return formatDate(dateString);
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
          <div className="w-10 h-10 bg-gradient-to-br from-blue-500 to-cyan-500 rounded-lg flex items-center justify-center">
            <Search className="w-6 h-6 text-white" />
          </div>
          <div className="text-left">
            <h2 className="text-base md:text-lg font-semibold text-white">User Lookup</h2>
            <p className="text-xs text-white/60">Search by name or email</p>
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
            {/* Search Input */}
            <div className="flex gap-2 mb-4">
              <input
                type="text"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                onKeyPress={(e) => e.key === 'Enter' && handleSearch()}
                placeholder="Enter name or email..."
                className="flex-1 px-4 py-3 bg-white/5 border border-white/10 rounded-lg text-white placeholder-white/40 focus:outline-none focus:border-white/30 text-sm"
              />
              <button
                onClick={handleSearch}
                disabled={searching || !searchQuery.trim()}
                className="px-6 py-3 bg-gradient-to-r from-blue-500 to-cyan-500 hover:from-blue-600 hover:to-cyan-600 disabled:from-white/10 disabled:to-white/10 text-white disabled:text-white/40 rounded-lg font-medium transition-all touch-manipulation flex items-center gap-2"
              >
                {searching ? (
                  <div className="w-4 h-4 border-2 border-white/20 border-t-white rounded-full animate-spin" />
                ) : (
                  <Search className="w-4 h-4" />
                )}
              </button>
            </div>

            {/* Results */}
            <div className="space-y-2 max-h-[400px] overflow-y-auto">
              {results.length === 0 && !searching && searchQuery && (
                <div className="text-center py-8">
                  <User className="w-8 h-8 text-white/20 mx-auto mb-2" />
                  <p className="text-white/40 text-sm">No users found</p>
                </div>
              )}

              {results.map((user) => (
                <motion.div
                  key={user.id}
                  initial={{ opacity: 0, x: -20 }}
                  animate={{ opacity: 1, x: 0 }}
                  className="p-4 bg-white/5 hover:bg-white/10 rounded-lg border border-white/10 transition-all"
                >
                  <div className="flex items-start justify-between gap-3 mb-3">
                    <div className="flex-1 min-w-0">
                      <h3 className="text-sm font-semibold text-white flex items-center gap-2">
                        {user.full_name || 'No name'}
                        <span className={`px-2 py-0.5 rounded-full text-[10px] font-medium ${
                          user.user_type === 'client'
                            ? 'bg-cyan-500/20 text-cyan-400'
                            : user.user_type === 'agent'
                            ? 'bg-purple-500/20 text-purple-400'
                            : 'bg-white/10 text-white/60'
                        }`}>
                          {user.user_type || 'unknown'}
                        </span>
                      </h3>
                      <p className="text-xs text-white/60 mt-1 flex items-center gap-1.5">
                        <Mail className="w-3 h-3" />
                        {user.email}
                      </p>
                      <p className="text-xs text-white/40 mt-1 flex items-center gap-1.5">
                        <Calendar className="w-3 h-3" />
                        Joined {formatDate(user.created_at)} • Last seen {getTimeAgo(user.last_sign_in_at)}
                      </p>
                    </div>
                  </div>

                  {/* Actions */}
                  <div className="flex gap-2">
                    <button
                      onClick={() => handleViewAs(user)}
                      className="flex-1 px-3 py-2 bg-gradient-to-r from-purple-500/20 to-pink-500/20 hover:from-purple-500/30 hover:to-pink-500/30 border border-purple-500/30 rounded-lg text-xs font-medium text-white transition-all touch-manipulation flex items-center justify-center gap-1.5"
                    >
                      <Eye className="w-3.5 h-3.5" />
                      View as {user.user_type || 'user'}
                    </button>
                  </div>
                </motion.div>
              ))}
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </motion.div>
  );
}
