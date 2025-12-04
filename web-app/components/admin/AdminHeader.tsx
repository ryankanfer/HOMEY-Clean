'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';
import {
  Shield,
  Search,
  Bell,
  User,
  LogOut,
  ChevronDown,
  X,
  Command,
  Users,
  Home,
  Settings as SettingsIcon,
  AlertCircle,
  CheckCircle
} from 'lucide-react';
import { auth, db } from '@/lib/supabase';

interface Notification {
  id: string;
  type: 'agent_pending' | 'error' | 'support' | 'system';
  title: string;
  message: string;
  timestamp: number;
  read: boolean;
}

interface AdminHeaderProps {
  userName?: string;
  userEmail?: string;
}

export default function AdminHeader({ userName, userEmail }: AdminHeaderProps) {
  const router = useRouter();
  const [showSearch, setShowSearch] = useState(false);
  const [showProfile, setShowProfile] = useState(false);
  const [showNotifications, setShowNotifications] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [notifications, setNotifications] = useState<Notification[]>([]);

  useEffect(() => {
    // Keyboard shortcut for search (Cmd/Ctrl + K)
    const handleKeyDown = (e: KeyboardEvent) => {
      if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
        e.preventDefault();
        setShowSearch(true);
      }
      if (e.key === 'Escape') {
        setShowSearch(false);
        setShowProfile(false);
        setShowNotifications(false);
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, []);

  useEffect(() => {
    loadNotifications();
  }, []);

  const loadNotifications = async () => {
    // Mock notifications - replace with actual data fetching
    const mockNotifications: Notification[] = [
      {
        id: '1',
        type: 'agent_pending',
        title: 'New Agent Registration',
        message: '3 agents pending approval',
        timestamp: Date.now() - 1000 * 60 * 30,
        read: false
      },
      {
        id: '2',
        type: 'system',
        title: 'System Update',
        message: 'Database backup completed successfully',
        timestamp: Date.now() - 1000 * 60 * 60,
        read: false
      }
    ];
    setNotifications(mockNotifications);
  };

  const handleSignOut = async () => {
    await auth.signOut();
    router.push('/');
  };

  const handleSearch = (query: string) => {
    setSearchQuery(query);
    // Implement search logic here
  };

  const unreadCount = notifications.filter(n => !n.read).length;

  const getNotificationIcon = (type: Notification['type']) => {
    switch (type) {
      case 'agent_pending':
        return <Users className="w-4 h-4 text-purple-400" />;
      case 'error':
        return <AlertCircle className="w-4 h-4 text-red-400" />;
      case 'system':
        return <CheckCircle className="w-4 h-4 text-green-400" />;
      default:
        return <Bell className="w-4 h-4 text-blue-400" />;
    }
  };

  const formatTimestamp = (timestamp: number) => {
    const diff = Date.now() - timestamp;
    const minutes = Math.floor(diff / (1000 * 60));
    const hours = Math.floor(diff / (1000 * 60 * 60));

    if (minutes < 60) return `${minutes}m ago`;
    if (hours < 24) return `${hours}h ago`;
    return new Date(timestamp).toLocaleDateString();
  };

  return (
    <>
      <header className="sticky top-0 z-50 bg-gradient-to-b from-black/60 via-black/40 to-transparent backdrop-blur-sm border-b border-white/10">
        <div className="flex items-center justify-between px-4 md:px-5 py-3 md:py-4 gap-3">
          {/* Left: Title */}
          <div className="flex items-center gap-3">
            <div className="flex items-center gap-2">
              <Shield className="w-5 h-5 md:w-6 md:h-6 text-orange-400" />
              <h1 className="text-lg md:text-2xl font-bold text-white">Admin</h1>
            </div>
          </div>

          {/* Center: Search Bar */}
          <button
            onClick={() => setShowSearch(true)}
            className="hidden md:flex flex-1 max-w-md items-center gap-2 px-4 py-2 bg-white/5 hover:bg-white/10 border border-white/10 rounded-lg transition-colors text-left"
          >
            <Search className="w-4 h-4 text-white/40" />
            <span className="text-sm text-white/40">Search users, properties...</span>
            <div className="ml-auto flex items-center gap-1 px-2 py-0.5 bg-white/5 rounded text-[10px] text-white/40">
              <Command className="w-3 h-3" />
              K
            </div>
          </button>

          {/* Right: Actions */}
          <div className="flex items-center gap-2">
            {/* Mobile Search */}
            <button
              onClick={() => setShowSearch(true)}
              className="md:hidden p-2 hover:bg-white/10 rounded-lg transition-colors"
            >
              <Search className="w-5 h-5 text-white" />
            </button>

            {/* Notifications */}
            <button
              onClick={() => setShowNotifications(!showNotifications)}
              className="relative p-2 hover:bg-white/10 rounded-lg transition-colors"
            >
              <Bell className="w-5 h-5 text-white" />
              {unreadCount > 0 && (
                <span className="absolute top-1 right-1 w-2 h-2 bg-red-500 rounded-full" />
              )}
            </button>

            {/* Profile */}
            <button
              onClick={() => setShowProfile(!showProfile)}
              className="flex items-center gap-2 p-2 hover:bg-white/10 rounded-lg transition-colors"
            >
              <div className="w-8 h-8 bg-gradient-to-br from-orange-500 to-yellow-500 rounded-full flex items-center justify-center">
                <User className="w-4 h-4 text-white" />
              </div>
              <ChevronDown className="w-4 h-4 text-white/60 hidden md:block" />
            </button>

            {/* Admin Badge */}
            <div className="hidden sm:flex px-3 py-1.5 bg-gradient-to-r from-orange-500/20 to-yellow-500/20 border border-orange-500/30 rounded-full">
              <span className="text-xs font-bold text-orange-400">ADMIN</span>
            </div>
          </div>
        </div>

        {/* Profile Dropdown */}
        <AnimatePresence>
          {showProfile && (
            <motion.div
              initial={{ opacity: 0, y: -10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -10 }}
              className="absolute right-4 md:right-5 top-16 md:top-20 w-64 glass-strong rounded-xl border border-white/20 shadow-2xl overflow-hidden z-50"
            >
              <div className="p-4 border-b border-white/10">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 bg-gradient-to-br from-orange-500 to-yellow-500 rounded-full flex items-center justify-center">
                    <User className="w-5 h-5 text-white" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium text-white truncate">{userName || 'Admin User'}</p>
                    <p className="text-xs text-white/60 truncate">{userEmail || 'admin@homey.com'}</p>
                  </div>
                </div>
              </div>
              <div className="p-2">
                <button
                  onClick={() => router.push('/profile')}
                  className="w-full flex items-center gap-3 px-3 py-2 text-sm text-white hover:bg-white/10 rounded-lg transition-colors"
                >
                  <User className="w-4 h-4" />
                  View Profile
                </button>
                <button
                  onClick={() => router.push('/admin/settings')}
                  className="w-full flex items-center gap-3 px-3 py-2 text-sm text-white hover:bg-white/10 rounded-lg transition-colors"
                >
                  <SettingsIcon className="w-4 h-4" />
                  Settings
                </button>
                <div className="my-1 border-t border-white/10" />
                <button
                  onClick={handleSignOut}
                  className="w-full flex items-center gap-3 px-3 py-2 text-sm text-red-400 hover:bg-red-500/10 rounded-lg transition-colors"
                >
                  <LogOut className="w-4 h-4" />
                  Sign Out
                </button>
              </div>
            </motion.div>
          )}
        </AnimatePresence>

        {/* Notifications Dropdown */}
        <AnimatePresence>
          {showNotifications && (
            <motion.div
              initial={{ opacity: 0, y: -10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -10 }}
              className="absolute right-4 md:right-20 top-16 md:top-20 w-80 max-w-[calc(100vw-2rem)] glass-strong rounded-xl border border-white/20 shadow-2xl overflow-hidden z-50"
            >
              <div className="p-4 border-b border-white/10 flex items-center justify-between">
                <h3 className="text-sm font-semibold text-white">Notifications</h3>
                {unreadCount > 0 && (
                  <span className="text-xs text-white/60">{unreadCount} unread</span>
                )}
              </div>
              <div className="max-h-96 overflow-y-auto">
                {notifications.length === 0 ? (
                  <div className="p-8 text-center">
                    <Bell className="w-8 h-8 text-white/20 mx-auto mb-2" />
                    <p className="text-sm text-white/40">No notifications</p>
                  </div>
                ) : (
                  notifications.map((notif) => (
                    <button
                      key={notif.id}
                      className="w-full p-4 hover:bg-white/5 transition-colors border-b border-white/5 last:border-0 text-left"
                    >
                      <div className="flex items-start gap-3">
                        <div className="flex-shrink-0 mt-0.5">
                          {getNotificationIcon(notif.type)}
                        </div>
                        <div className="flex-1 min-w-0">
                          <p className="text-sm font-medium text-white mb-1">{notif.title}</p>
                          <p className="text-xs text-white/60 mb-2">{notif.message}</p>
                          <p className="text-xs text-white/40">{formatTimestamp(notif.timestamp)}</p>
                        </div>
                        {!notif.read && (
                          <div className="w-2 h-2 bg-blue-400 rounded-full flex-shrink-0 mt-2" />
                        )}
                      </div>
                    </button>
                  ))
                )}
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </header>

      {/* Search Modal */}
      <AnimatePresence>
        {showSearch && (
          <div className="fixed inset-0 z-[10000] flex items-start justify-center p-4 pt-20">
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setShowSearch(false)}
              className="absolute inset-0 bg-black/60 backdrop-blur-sm"
            />

            <motion.div
              initial={{ opacity: 0, scale: 0.95, y: -20 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.95, y: -20 }}
              className="relative w-full max-w-2xl glass-strong rounded-xl border border-white/20 shadow-2xl overflow-hidden"
            >
              <div className="flex items-center gap-3 p-4 border-b border-white/10">
                <Search className="w-5 h-5 text-white/40" />
                <input
                  type="text"
                  value={searchQuery}
                  onChange={(e) => handleSearch(e.target.value)}
                  placeholder="Search users, agents, properties, pages..."
                  className="flex-1 bg-transparent text-white placeholder-white/40 focus:outline-none"
                  autoFocus
                />
                <button
                  onClick={() => setShowSearch(false)}
                  className="p-1 hover:bg-white/10 rounded transition-colors"
                >
                  <X className="w-5 h-5 text-white/60" />
                </button>
              </div>

              <div className="p-4 space-y-2 max-h-96 overflow-y-auto">
                {searchQuery === '' ? (
                  <div className="text-center py-8">
                    <Search className="w-8 h-8 text-white/20 mx-auto mb-2" />
                    <p className="text-sm text-white/40">Type to search...</p>
                    <p className="text-xs text-white/30 mt-2">Try searching for users, properties, or agents</p>
                  </div>
                ) : (
                  <div className="text-center py-8">
                    <p className="text-sm text-white/40">No results found for "{searchQuery}"</p>
                  </div>
                )}
              </div>

              <div className="p-3 border-t border-white/10 bg-black/20">
                <div className="flex items-center justify-between text-xs text-white/40">
                  <div className="flex items-center gap-4">
                    <div className="flex items-center gap-1">
                      <kbd className="px-2 py-1 bg-white/5 rounded text-[10px]">↑↓</kbd>
                      <span>Navigate</span>
                    </div>
                    <div className="flex items-center gap-1">
                      <kbd className="px-2 py-1 bg-white/5 rounded text-[10px]">↵</kbd>
                      <span>Select</span>
                    </div>
                  </div>
                  <div className="flex items-center gap-1">
                    <kbd className="px-2 py-1 bg-white/5 rounded text-[10px]">ESC</kbd>
                    <span>Close</span>
                  </div>
                </div>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>
    </>
  );
}
