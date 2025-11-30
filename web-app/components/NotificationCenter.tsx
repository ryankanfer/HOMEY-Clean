'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { db, supabase, auth } from '@/lib/supabase';
import { analytics } from '@/lib/analytics';

interface Notification {
  id: string;
  type: 'new_listing' | 'price_change' | 'new_match' | 'saved_available';
  title: string;
  message: string;
  listing_id?: string;
  created_at: string;
  read: boolean;
}

export default function NotificationCenter() {
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [unreadCount, setUnreadCount] = useState(0);
  const [showPanel, setShowPanel] = useState(false);
  const [userId, setUserId] = useState<string | null>(null);

  useEffect(() => {
    initNotifications();
  }, []);

  const initNotifications = async () => {
    const { data: { user } } = await auth.getUser();
    if (!user) return;

    setUserId(user.id);

    // Load existing notifications
    await loadNotifications(user.id);

    // Subscribe to real-time updates
    subscribeToListings(user.id);
  };

  const loadNotifications = async (uid: string) => {
    // Simulated notifications - in production, these would come from a database
    const mockNotifications: Notification[] = [
      {
        id: '1',
        type: 'new_match',
        title: 'New Perfect Match!',
        message: 'Scout found a 95% match in Brooklyn',
        created_at: new Date().toISOString(),
        read: false,
      },
    ];

    setNotifications(mockNotifications);
    setUnreadCount(mockNotifications.filter(n => !n.read).length);
  };

  const subscribeToListings = (uid: string) => {
    // Subscribe to new listings in real-time
    const channel = supabase
      .channel('listings-changes')
      .on(
        'postgres_changes',
        {
          event: 'INSERT',
          schema: 'public',
          table: 'listings',
        },
        async (payload) => {
          // Check if this listing matches user preferences
          const { data: matchScore } = await db.calculateMatchScore(uid, payload.new.id);

          if (matchScore && matchScore > 80) {
            const newNotif: Notification = {
              id: Date.now().toString(),
              type: 'new_match',
              title: 'New High Match!',
              message: `${Math.round(matchScore)}% match in ${payload.new.neighborhood}`,
              listing_id: payload.new.id,
              created_at: new Date().toISOString(),
              read: false,
            };

            setNotifications(prev => [newNotif, ...prev]);
            setUnreadCount(prev => prev + 1);

            // Track
            analytics.click('receive_notification', 'new_match', {
              listing_id: payload.new.id,
              match_score: matchScore,
            });
          }
        }
      )
      .subscribe();

    return () => {
      channel.unsubscribe();
    };
  };

  const markAsRead = (id: string) => {
    setNotifications(prev =>
      prev.map(n => (n.id === id ? { ...n, read: true } : n))
    );
    setUnreadCount(prev => Math.max(0, prev - 1));
  };

  const markAllAsRead = () => {
    setNotifications(prev => prev.map(n => ({ ...n, read: true })));
    setUnreadCount(0);
  };

  if (!userId) return null;

  return (
    <>
      {/* Notification Bell */}
      <button
        onClick={() => setShowPanel(!showPanel)}
        className="relative w-10 h-10 rounded-full bg-white/10 flex items-center justify-center text-xl hover:bg-white/20 transition-colors"
      >
        🔔
        {unreadCount > 0 && (
          <motion.div
            className="absolute -top-1 -right-1 w-5 h-5 rounded-full bg-red-500 flex items-center justify-center text-xs font-bold text-white"
            initial={{ scale: 0 }}
            animate={{ scale: 1 }}
            transition={{ type: 'spring', stiffness: 500 }}
          >
            {unreadCount}
          </motion.div>
        )}
      </button>

      {/* Notification Panel */}
      <AnimatePresence>
        {showPanel && (
          <motion.div
            className="fixed inset-0 z-[200] bg-black/50 backdrop-blur-sm"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={() => setShowPanel(false)}
          >
            <motion.div
              className="absolute top-16 right-5 w-96 max-w-[calc(100vw-2.5rem)] max-h-[80vh] glass-strong rounded-2xl overflow-hidden"
              initial={{ opacity: 0, y: -20, scale: 0.95 }}
              animate={{ opacity: 1, y: 0, scale: 1 }}
              exit={{ opacity: 0, y: -20, scale: 0.95 }}
              onClick={(e) => e.stopPropagation()}
            >
              {/* Header */}
              <div className="p-4 border-b border-white/10 flex items-center justify-between">
                <h3 className="text-lg font-bold text-white">Notifications</h3>
                {unreadCount > 0 && (
                  <button
                    onClick={markAllAsRead}
                    className="text-xs text-primary hover:text-purple-400 font-semibold"
                  >
                    Mark all read
                  </button>
                )}
              </div>

              {/* Notifications List */}
              <div className="overflow-y-auto max-h-[60vh]">
                {notifications.length === 0 ? (
                  <div className="p-8 text-center text-white/60">
                    <div className="text-4xl mb-2">🔕</div>
                    <p>No notifications yet</p>
                  </div>
                ) : (
                  <div className="divide-y divide-white/10">
                    {notifications.map((notif) => (
                      <motion.div
                        key={notif.id}
                        className={`p-4 hover:bg-white/5 cursor-pointer transition-colors ${
                          !notif.read ? 'bg-primary/5' : ''
                        }`}
                        onClick={() => {
                          markAsRead(notif.id);
                          if (notif.listing_id) {
                            setShowPanel(false);
                            window.location.href = `/scout/${notif.listing_id}`;
                          }
                        }}
                        initial={{ opacity: 0, x: -20 }}
                        animate={{ opacity: 1, x: 0 }}
                      >
                        <div className="flex items-start gap-3">
                          <div className="text-2xl">
                            {notif.type === 'new_match' && '🎯'}
                            {notif.type === 'new_listing' && '🏠'}
                            {notif.type === 'price_change' && '💰'}
                            {notif.type === 'saved_available' && '❤️'}
                          </div>
                          <div className="flex-1 min-w-0">
                            <div className="flex items-center gap-2">
                              <h4 className="text-white font-semibold text-sm">
                                {notif.title}
                              </h4>
                              {!notif.read && (
                                <div className="w-2 h-2 rounded-full bg-primary flex-shrink-0" />
                              )}
                            </div>
                            <p className="text-white/70 text-sm mt-1">
                              {notif.message}
                            </p>
                            <p className="text-white/40 text-xs mt-1">
                              {new Date(notif.created_at).toLocaleTimeString([], {
                                hour: '2-digit',
                                minute: '2-digit',
                              })}
                            </p>
                          </div>
                        </div>
                      </motion.div>
                    ))}
                  </div>
                )}
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
}
