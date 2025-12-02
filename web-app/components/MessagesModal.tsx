'use client';

import { useState, useEffect, useRef } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, Send, Loader2 } from 'lucide-react';
import { agentDb } from '@/lib/supabase';
import { supabase } from '@/lib/supabase';

interface Message {
  id: string;
  connection_id: string;
  sender_id: string;
  sender_type: 'agent' | 'client';
  message: string;
  read: boolean;
  created_at: string;
  updated_at: string;
}

interface MessagesModalProps {
  isOpen: boolean;
  onClose: () => void;
  agentName: string;
  agentAvatar?: string | null;
  connectionId: string;
  userId: string;
}

export default function MessagesModal({
  isOpen,
  onClose,
  agentName,
  agentAvatar,
  connectionId,
  userId
}: MessagesModalProps) {
  const [message, setMessage] = useState('');
  const [messages, setMessages] = useState<Message[]>([]);
  const [loading, setLoading] = useState(false);
  const [sending, setSending] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const getInitials = (name: string) => {
    const parts = name.split(' ');
    if (parts.length >= 2) {
      return `${parts[0][0]}${parts[parts.length - 1][0]}`.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  };

  // Fetch messages when modal opens
  useEffect(() => {
    if (isOpen && connectionId) {
      loadMessages();
      markMessagesAsRead();
    }
  }, [isOpen, connectionId]);

  // Scroll to bottom when messages change
  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  const loadMessages = async () => {
    setLoading(true);
    try {
      const { data, error } = await agentDb.getMessages(connectionId);
      if (error) throw error;
      setMessages(data || []);
    } catch (error) {
      console.error('Error loading messages:', error);
    } finally {
      setLoading(false);
    }
  };

  const markMessagesAsRead = async () => {
    try {
      await agentDb.markMessagesAsRead(connectionId, userId);
    } catch (error) {
      console.error('Error marking messages as read:', error);
    }
  };

  const handleSend = async () => {
    if (!message.trim() || sending) return;

    setSending(true);
    try {
      const { data, error } = await agentDb.sendMessage({
        connectionId,
        senderId: userId,
        senderType: 'client',
        message: message.trim(),
      });

      if (error) throw error;

      if (data) {
        setMessages([...messages, data]);
        setMessage('');
      }
    } catch (error) {
      console.error('Error sending message:', error);
      alert('Failed to send message. Please try again.');
    } finally {
      setSending(false);
    }
  };

  const formatTime = (timestamp: string) => {
    const date = new Date(timestamp);
    const now = new Date();
    const diffMs = now.getTime() - date.getTime();
    const diffMins = Math.floor(diffMs / 60000);
    const diffHours = Math.floor(diffMs / 3600000);
    const diffDays = Math.floor(diffMs / 86400000);

    if (diffMins < 1) return 'Just now';
    if (diffMins < 60) return `${diffMins}m ago`;
    if (diffHours < 24) return `${diffHours}h ago`;
    if (diffDays < 7) return `${diffDays}d ago`;

    return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
  };

  return (
    <AnimatePresence>
      {isOpen && (
        <>
          {/* Backdrop */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={onClose}
            className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50"
          />

          {/* Modal */}
          <motion.div
            initial={{ opacity: 0, scale: 0.95, y: 20 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.95, y: 20 }}
            className="fixed inset-x-4 top-[10%] max-w-lg mx-auto z-50 max-h-[80vh] flex flex-col"
          >
            <div className="glass-strong rounded-3xl border border-white/10 overflow-hidden shadow-2xl flex flex-col h-full">
              {/* Header */}
              <div className="p-5 border-b border-white/10 flex items-center justify-between flex-shrink-0">
                <div className="flex items-center gap-3">
                  {agentAvatar ? (
                    <img
                      src={agentAvatar}
                      alt={agentName}
                      className="w-12 h-12 rounded-full object-cover"
                    />
                  ) : (
                    <div className="w-12 h-12 rounded-full bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center text-white text-lg font-bold">
                      {getInitials(agentName)}
                    </div>
                  )}
                  <div>
                    <h3 className="text-white font-semibold text-lg">{agentName}</h3>
                    <p className="text-white/60 text-sm">Your Partner Agent</p>
                  </div>
                </div>
                <button
                  onClick={onClose}
                  className="w-8 h-8 rounded-full bg-white/10 hover:bg-white/20 flex items-center justify-center transition-colors"
                >
                  <X className="w-5 h-5 text-white/60" />
                </button>
              </div>

              {/* Messages Area */}
              <div className="flex-1 overflow-y-auto p-5 space-y-4" style={{ maxHeight: 'calc(80vh - 200px)' }}>
                {loading ? (
                  <div className="flex items-center justify-center h-full">
                    <Loader2 className="w-8 h-8 text-purple-500 animate-spin" />
                  </div>
                ) : messages.length === 0 ? (
                  <div className="flex flex-col items-center justify-center h-full text-center">
                    <div className="w-16 h-16 rounded-full bg-white/5 flex items-center justify-center mb-4">
                      <MessageCircle className="w-8 h-8 text-white/40" />
                    </div>
                    <p className="text-white/60 text-sm">
                      No messages yet. Start a conversation with your agent!
                    </p>
                  </div>
                ) : (
                  messages.map((msg) => {
                    const isOwnMessage = msg.sender_id === userId;
                    return (
                      <motion.div
                        key={msg.id}
                        initial={{ opacity: 0, y: 10 }}
                        animate={{ opacity: 1, y: 0 }}
                        className={`flex ${isOwnMessage ? 'justify-end' : 'justify-start'}`}
                      >
                        <div className={`max-w-[80%] ${isOwnMessage ? 'items-end' : 'items-start'} flex flex-col gap-1`}>
                          <div
                            className={`rounded-2xl px-4 py-3 ${
                              isOwnMessage
                                ? 'bg-gradient-to-r from-purple-500 to-pink-500 text-white'
                                : 'bg-slate-800/50 text-white border border-white/10'
                            }`}
                          >
                            <p className="text-sm leading-relaxed break-words">{msg.message}</p>
                          </div>
                          <span className="text-white/40 text-xs px-2">
                            {formatTime(msg.created_at)}
                          </span>
                        </div>
                      </motion.div>
                    );
                  })
                )}
                <div ref={messagesEndRef} />
              </div>

              {/* Message Input */}
              <div className="p-5 border-t border-white/10 flex-shrink-0">
                <div className="relative">
                  <textarea
                    value={message}
                    onChange={(e) => setMessage(e.target.value)}
                    placeholder="Type your message..."
                    className="w-full h-20 bg-slate-900/50 text-white placeholder-white/40 rounded-xl p-4 pr-14 border border-white/10 focus:border-purple-500/50 focus:outline-none resize-none"
                    onKeyDown={(e) => {
                      if (e.key === 'Enter' && (e.metaKey || e.ctrlKey)) {
                        handleSend();
                      }
                    }}
                    disabled={sending}
                  />
                  <button
                    onClick={handleSend}
                    disabled={!message.trim() || sending}
                    className="absolute right-3 bottom-3 w-10 h-10 bg-gradient-to-r from-purple-500 to-pink-500 disabled:opacity-50 disabled:cursor-not-allowed hover:opacity-90 rounded-xl flex items-center justify-center transition-opacity"
                  >
                    {sending ? (
                      <Loader2 className="w-5 h-5 text-white animate-spin" />
                    ) : (
                      <Send className="w-5 h-5 text-white" />
                    )}
                  </button>
                </div>
                <p className="text-white/40 text-xs mt-2 text-center">
                  Press Cmd/Ctrl + Enter to send
                </p>
              </div>
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
}

function MessageCircle({ className }: { className?: string }) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      className={className}
    >
      <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z" />
    </svg>
  );
}
