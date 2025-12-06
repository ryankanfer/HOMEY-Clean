'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Users, Send, Heart, MessageCircle, UserPlus, X, Check } from 'lucide-react';
import { supabase } from '@/lib/supabase';
import type { Listing } from '@/lib/types';

interface Friend {
  id: string;
  full_name: string;
  avatar_url?: string;
  mutualLoves: number;
}

interface FriendActivity {
  friend: Friend;
  listing: Listing;
  action: 'like' | 'love';
  timestamp: string;
}

interface SocialPanelProps {
  isOpen: boolean;
  onClose: () => void;
  currentListing?: Listing;
  userId: string;
}

export default function SocialPanel({
  isOpen,
  onClose,
  currentListing,
  userId
}: SocialPanelProps) {
  const [activeTab, setActiveTab] = useState<'friends' | 'activity' | 'send'>('activity');
  const [friends, setFriends] = useState<Friend[]>([]);
  const [friendActivity, setFriendActivity] = useState<FriendActivity[]>([]);
  const [loading, setLoading] = useState(true);
  const [sendingTo, setSendingTo] = useState<string[]>([]);

  useEffect(() => {
    if (isOpen) {
      loadFriends();
      loadFriendActivity();
    }
  }, [isOpen, userId]);

  const loadFriends = async () => {
    try {
      // Mock friends for now - replace with actual friend system
      const mockFriends: Friend[] = [
        {
          id: '1',
          full_name: 'Sarah Johnson',
          avatar_url: undefined,
          mutualLoves: 12
        },
        {
          id: '2',
          full_name: 'Mike Chen',
          avatar_url: undefined,
          mutualLoves: 8
        },
        {
          id: '3',
          full_name: 'Emma Rodriguez',
          avatar_url: undefined,
          mutualLoves: 15
        }
      ];
      setFriends(mockFriends);
    } catch (error) {
      console.error('Error loading friends:', error);
    } finally {
      setLoading(false);
    }
  };

  const loadFriendActivity = async () => {
    try {
      // Mock activity - replace with actual query
      // This would query user_swipes joined with friends table
      const mockActivity: FriendActivity[] = [];
      setFriendActivity(mockActivity);
    } catch (error) {
      console.error('Error loading friend activity:', error);
    }
  };

  const handleSendToFriend = async (friendId: string) => {
    if (!currentListing) return;

    try {
      setSendingTo(prev => [...prev, friendId]);

      // Create a property share record
      const { error } = await supabase
        .from('property_shares')
        .insert({
          sender_id: userId,
          recipient_id: friendId,
          listing_id: currentListing.id,
          message: 'Check out this property!',
        });

      if (error) throw error;

      // Show success feedback
      setTimeout(() => {
        setSendingTo(prev => prev.filter(id => id !== friendId));
      }, 2000);
    } catch (error) {
      console.error('Error sending property:', error);
      setSendingTo(prev => prev.filter(id => id !== friendId));
    }
  };

  const getInitials = (name: string) => {
    return name
      .split(' ')
      .map(n => n[0])
      .join('')
      .toUpperCase()
      .slice(0, 2);
  };

  const tabs = [
    { id: 'activity' as const, label: 'Activity', icon: Heart, disabled: false },
    { id: 'friends' as const, label: 'Friends', icon: Users, disabled: false },
    { id: 'send' as const, label: 'Send', icon: Send, disabled: !currentListing },
  ];

  return (
    <AnimatePresence>
      {isOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
          <motion.div
            key="social-backdrop"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={onClose}
            className="absolute inset-0 bg-black/60 backdrop-blur-sm"
          />

          <motion.div
            key="social-modal"
            initial={{ opacity: 0, scale: 0.9, x: 20 }}
            animate={{ opacity: 1, scale: 1, x: 0 }}
            exit={{ opacity: 0, scale: 0.9, x: 20 }}
            className="relative glass-strong rounded-2xl p-6 max-w-md w-full border border-white/10 max-h-[85vh] overflow-hidden flex flex-col"
          >
            {/* Header */}
            <div className="flex items-center justify-between mb-6">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-gradient-to-br from-pink-500 to-purple-500 rounded-xl flex items-center justify-center">
                  <Users className="w-6 h-6 text-white" />
                </div>
                <div>
                  <h3 className="text-xl font-bold text-white">Social</h3>
                  <p className="text-xs text-white/60">Connect with friends</p>
                </div>
              </div>
              <button
                onClick={onClose}
                className="w-8 h-8 rounded-full bg-white/10 flex items-center justify-center text-white hover:bg-white/20 transition-all"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* Tabs */}
            <div className="flex gap-2 mb-6">
              {tabs.map(tab => {
                const Icon = tab.icon;
                return (
                  <button
                    key={tab.id}
                    onClick={() => !tab.disabled && setActiveTab(tab.id)}
                    disabled={tab.disabled}
                    className={`flex-1 py-2 px-3 rounded-lg font-medium text-sm transition-all ${
                      activeTab === tab.id
                        ? 'bg-gradient-to-r from-primary to-purple-500 text-white'
                        : 'bg-white/5 text-white/60 hover:bg-white/10'
                    } ${tab.disabled ? 'opacity-50 cursor-not-allowed' : ''}`}
                  >
                    <Icon className="w-4 h-4 inline mr-2" />
                    {tab.label}
                  </button>
                );
              })}
            </div>

            {/* Content */}
            <div className="flex-1 overflow-y-auto">
              {/* Friends Activity Tab */}
              {activeTab === 'activity' && (
                <div className="space-y-3">
                  {friendActivity.length === 0 ? (
                    <div className="text-center py-12">
                      <Heart className="w-12 h-12 text-white/20 mx-auto mb-3" />
                      <p className="text-white/60 text-sm mb-2">No recent activity</p>
                      <p className="text-white/40 text-xs">
                        Your friends haven't loved any properties yet
                      </p>
                    </div>
                  ) : (
                    friendActivity.map((activity, index) => (
                      <motion.div
                        key={index}
                        initial={{ opacity: 0, y: 10 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: index * 0.05 }}
                        className="glass-medium rounded-lg p-3 border border-white/10"
                      >
                        <div className="flex items-start gap-3">
                          <div className="w-10 h-10 rounded-full bg-gradient-to-br from-primary to-purple-500 flex items-center justify-center flex-shrink-0">
                            <span className="text-white text-xs font-bold">
                              {getInitials(activity.friend.full_name)}
                            </span>
                          </div>
                          <div className="flex-1 min-w-0">
                            <p className="text-white text-sm">
                              <span className="font-medium">{activity.friend.full_name}</span>
                              <span className="text-white/60">
                                {' '}
                                {activity.action === 'love' ? '❤️ loved' : '👍 liked'}
                              </span>
                            </p>
                            <p className="text-white/60 text-xs truncate mt-1">
                              {activity.listing.neighborhood} • ${activity.listing.price}/mo
                            </p>
                            <p className="text-white/40 text-xs mt-1">
                              {new Date(activity.timestamp).toLocaleDateString()}
                            </p>
                          </div>
                        </div>
                      </motion.div>
                    ))
                  )}
                </div>
              )}

              {/* Friends List Tab */}
              {activeTab === 'friends' && (
                <div className="space-y-2">
                  {friends.map((friend, index) => (
                    <motion.div
                      key={friend.id}
                      initial={{ opacity: 0, x: -10 }}
                      animate={{ opacity: 1, x: 0 }}
                      transition={{ delay: index * 0.05 }}
                      className="glass-medium rounded-lg p-3 border border-white/10 hover:bg-white/10 transition-all"
                    >
                      <div className="flex items-center justify-between">
                        <div className="flex items-center gap-3">
                          <div className="w-10 h-10 rounded-full bg-gradient-to-br from-primary to-purple-500 flex items-center justify-center">
                            <span className="text-white text-xs font-bold">
                              {getInitials(friend.full_name)}
                            </span>
                          </div>
                          <div>
                            <p className="text-white text-sm font-medium">{friend.full_name}</p>
                            <p className="text-white/60 text-xs">
                              {friend.mutualLoves} mutual loves
                            </p>
                          </div>
                        </div>
                        <button className="p-2 rounded-lg bg-white/5 hover:bg-white/10 transition-all">
                          <MessageCircle className="w-4 h-4 text-white/60" />
                        </button>
                      </div>
                    </motion.div>
                  ))}

                  {friends.length === 0 && (
                    <div className="text-center py-12">
                      <UserPlus className="w-12 h-12 text-white/20 mx-auto mb-3" />
                      <p className="text-white/60 text-sm mb-2">No friends yet</p>
                      <p className="text-white/40 text-xs mb-4">
                        Connect with friends to share properties
                      </p>
                      <button className="px-4 py-2 bg-gradient-to-r from-primary to-purple-500 rounded-lg text-white text-sm font-medium hover:opacity-90 transition-all">
                        <UserPlus className="w-4 h-4 inline mr-2" />
                        Add Friends
                      </button>
                    </div>
                  )}
                </div>
              )}

              {/* Send Property Tab */}
              {activeTab === 'send' && currentListing && (
                <div className="space-y-3">
                  <div className="glass-medium rounded-lg p-3 border border-primary/30 mb-4">
                    <p className="text-white/80 text-sm mb-1">Sending:</p>
                    <p className="text-white font-medium text-sm truncate">
                      {currentListing.neighborhood} • ${currentListing.price}/mo
                    </p>
                  </div>

                  {friends.map((friend, index) => {
                    const isSent = sendingTo.includes(friend.id);
                    return (
                      <motion.button
                        key={friend.id}
                        initial={{ opacity: 0, x: -10 }}
                        animate={{ opacity: 1, x: 0 }}
                        transition={{ delay: index * 0.05 }}
                        onClick={() => handleSendToFriend(friend.id)}
                        disabled={isSent}
                        className={`w-full glass-medium rounded-lg p-3 border border-white/10 transition-all ${
                          isSent
                            ? 'bg-green-500/20 border-green-500/30'
                            : 'hover:bg-white/10'
                        }`}
                      >
                        <div className="flex items-center justify-between">
                          <div className="flex items-center gap-3">
                            <div className="w-10 h-10 rounded-full bg-gradient-to-br from-primary to-purple-500 flex items-center justify-center">
                              <span className="text-white text-xs font-bold">
                                {getInitials(friend.full_name)}
                              </span>
                            </div>
                            <div className="text-left">
                              <p className="text-white text-sm font-medium">
                                {friend.full_name}
                              </p>
                              <p className="text-white/60 text-xs">
                                {friend.mutualLoves} mutual loves
                              </p>
                            </div>
                          </div>
                          <div>
                            {isSent ? (
                              <div className="w-8 h-8 rounded-full bg-green-500/20 flex items-center justify-center">
                                <Check className="w-5 h-5 text-green-400" />
                              </div>
                            ) : (
                              <div className="w-8 h-8 rounded-full bg-primary/20 flex items-center justify-center">
                                <Send className="w-4 h-4 text-primary" />
                              </div>
                            )}
                          </div>
                        </div>
                      </motion.button>
                    );
                  })}

                  {friends.length === 0 && (
                    <div className="text-center py-12">
                      <Send className="w-12 h-12 text-white/20 mx-auto mb-3" />
                      <p className="text-white/60 text-sm">No friends to send to</p>
                    </div>
                  )}
                </div>
              )}
            </div>
          </motion.div>
        </div>
      )}
    </AnimatePresence>
  );
}
