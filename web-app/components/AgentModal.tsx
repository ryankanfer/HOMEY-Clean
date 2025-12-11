'use client';

import { useState, useEffect, useRef } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, Phone, Mail, Send, Loader2, MessageCircle, ChevronDown } from 'lucide-react';
import { agentDb } from '@/lib/supabase';

interface VoiceNote {
  duration: string;
  transcript: string;
  timestamp: string;
}

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

interface AgentModalProps {
  isOpen: boolean;
  onClose: () => void;
  agentName: string;
  agentAvatar?: string | null;
  agentPhone?: string;
  agentEmail?: string;
  agentTitle?: string;
  connectionId?: string;
  userId?: string;
  voiceNote?: VoiceNote;
}

export default function AgentModal({
  isOpen,
  onClose,
  agentName,
  agentAvatar,
  agentPhone,
  agentEmail,
  agentTitle = 'Your Partner Agent',
  connectionId,
  userId,
  voiceNote,
}: AgentModalProps) {
  const [message, setMessage] = useState('');
  const [messages, setMessages] = useState<Message[]>([]);
  const [loading, setLoading] = useState(false);
  const [sending, setSending] = useState(false);
  const [showTranscript, setShowTranscript] = useState(false);
  const [isPlaying, setIsPlaying] = useState(false);
  const [activeTab, setActiveTab] = useState<'info' | 'chat'>('info');
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const getInitials = (name: string) => {
    const parts = name.split(' ');
    if (parts.length >= 2) {
      return `${parts[0][0]}${parts[parts.length - 1][0]}`.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  };

  // Fetch messages when modal opens or tab changes to chat
  useEffect(() => {
    if (isOpen && activeTab === 'chat' && connectionId) {
      loadMessages();
      markMessagesAsRead();
    }
  }, [isOpen, activeTab, connectionId]);

  // Scroll to bottom when messages change
  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  const loadMessages = async () => {
    if (!connectionId) return;
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
    if (!connectionId || !userId) return;
    try {
      await agentDb.markMessagesAsRead(connectionId, userId);
    } catch (error) {
      console.error('Error marking messages as read:', error);
    }
  };

  const handleSend = async () => {
    if (!message.trim() || sending || !connectionId || !userId) return;

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
            initial={{ opacity: 0, y: '100%' }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: '100%' }}
            transition={{ type: 'spring', damping: 30, stiffness: 300 }}
            className="fixed inset-x-0 bottom-0 md:inset-x-4 md:bottom-auto md:top-[5%] md:max-w-2xl md:mx-auto z-50 max-h-[90vh] md:max-h-[85vh] flex flex-col"
          >
            <div className="glass-strong rounded-t-3xl md:rounded-3xl border border-white/10 overflow-hidden shadow-2xl flex flex-col h-full">
              {/* Header */}
              <div className="p-5 border-b border-white/10 flex-shrink-0 bg-slate-900/95 backdrop-blur-xl">
                <div className="flex items-center justify-between mb-4">
                  <div className="flex items-center gap-3">
                    {agentAvatar ? (
                      <img
                        src={agentAvatar}
                        alt={agentName}
                        className="w-14 h-14 rounded-full object-cover"
                      />
                    ) : (
                      <div className="w-14 h-14 rounded-full bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center text-white text-xl font-bold">
                        {getInitials(agentName)}
                      </div>
                    )}
                    <div>
                      <h3 className="text-white font-semibold text-lg">{agentName}</h3>
                      <p className="text-white/60 text-sm">{agentTitle}</p>
                      <div className="flex items-center gap-2 mt-1">
                        <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse" />
                        <span className="text-xs text-green-400">Online</span>
                      </div>
                    </div>
                  </div>
                  <button
                    onClick={onClose}
                    className="w-8 h-8 rounded-full bg-white/10 hover:bg-white/20 flex items-center justify-center transition-colors"
                  >
                    <X className="w-5 h-5 text-white/60" />
                  </button>
                </div>

                {/* Tabs */}
                <div className="flex gap-2">
                  <button
                    onClick={() => setActiveTab('info')}
                    className={`flex-1 py-2 px-4 rounded-lg font-medium transition-all ${
                      activeTab === 'info'
                        ? 'bg-gradient-to-r from-purple-500 to-pink-500 text-white'
                        : 'bg-white/5 text-white/60 hover:bg-white/10'
                    }`}
                  >
                    Info & Contact
                  </button>
                  <button
                    onClick={() => setActiveTab('chat')}
                    className={`flex-1 py-2 px-4 rounded-lg font-medium transition-all ${
                      activeTab === 'chat'
                        ? 'bg-gradient-to-r from-purple-500 to-pink-500 text-white'
                        : 'bg-white/5 text-white/60 hover:bg-white/10'
                    }`}
                  >
                    Messages
                  </button>
                </div>
              </div>

              {/* Content Area */}
              <div className="flex-1 overflow-y-auto">
                <AnimatePresence mode="wait">
                  {activeTab === 'info' ? (
                    <motion.div
                      key="info"
                      initial={{ opacity: 0, x: -20 }}
                      animate={{ opacity: 1, x: 0 }}
                      exit={{ opacity: 0, x: 20 }}
                      className="p-5 space-y-4"
                    >
                      {/* Contact Card */}
                      <div className="bg-gradient-to-br from-purple-500/20 to-pink-500/20 border border-purple-500/30 rounded-2xl p-4">
                        <h4 className="text-white font-semibold mb-3">Contact</h4>
                        <div className="space-y-2">
                          {agentPhone && (
                            <button
                              onClick={() => window.location.href = `tel:${agentPhone}`}
                              className="w-full py-3 bg-white/10 hover:bg-white/20 text-white font-medium rounded-xl transition-colors flex items-center justify-center gap-2"
                            >
                              <Phone className="w-4 h-4" />
                              Call {agentPhone}
                            </button>
                          )}
                          {agentEmail && (
                            <button
                              onClick={() => window.location.href = `mailto:${agentEmail}`}
                              className="w-full py-3 bg-white/10 hover:bg-white/20 text-white font-medium rounded-xl transition-colors flex items-center justify-center gap-2"
                            >
                              <Mail className="w-4 h-4" />
                              Email {agentEmail}
                            </button>
                          )}
                        </div>
                      </div>

                      {/* Voice Note Player */}
                      {voiceNote && (
                        <div className="bg-slate-800/50 rounded-2xl p-4 border border-white/10">
                          <div className="flex items-center justify-between mb-3">
                            <div className="flex items-center gap-2">
                              <span className="text-2xl">🎙️</span>
                              <div>
                                <p className="text-white/90 text-sm font-medium">Voice Update</p>
                                <p className="text-white/40 text-xs">{voiceNote.timestamp}</p>
                              </div>
                            </div>
                            <span className="text-white/60 text-sm">{voiceNote.duration}</span>
                          </div>

                          {/* Waveform Visualization */}
                          <button
                            onClick={() => setIsPlaying(!isPlaying)}
                            className="w-full mb-3 group"
                          >
                            <div className="flex items-center justify-center gap-1 h-12 bg-slate-900/50 rounded-xl px-3 group-hover:bg-slate-900/70 transition-colors">
                              {/* Play/Pause Button */}
                              <div className="w-8 h-8 rounded-full bg-gradient-to-r from-purple-500 to-pink-500 flex items-center justify-center mr-2 group-hover:scale-110 transition-transform">
                                {isPlaying ? (
                                  <span className="text-white text-xs">⏸</span>
                                ) : (
                                  <span className="text-white text-xs">▶</span>
                                )}
                              </div>

                              {/* Waveform Bars */}
                              {[...Array(28)].map((_, i) => {
                                const height = Math.random() * 60 + 20;
                                return (
                                  <motion.div
                                    key={i}
                                    className="w-1 bg-gradient-to-t from-purple-500 to-pink-500 rounded-full"
                                    style={{ height: `${height}%` }}
                                    animate={isPlaying ? {
                                      height: [`${height}%`, `${Math.random() * 60 + 20}%`, `${height}%`],
                                    } : {}}
                                    transition={{
                                      duration: 0.5 + Math.random() * 0.5,
                                      repeat: isPlaying ? Infinity : 0,
                                      ease: 'easeInOut'
                                    }}
                                  />
                                );
                              })}
                            </div>
                          </button>

                          {/* Transcript Toggle */}
                          <button
                            onClick={() => setShowTranscript(!showTranscript)}
                            className="text-purple-400 text-sm hover:text-purple-300 transition-colors flex items-center gap-2"
                          >
                            {showTranscript ? 'Hide' : 'View'} Transcript
                            <ChevronDown className={`w-4 h-4 transition-transform ${showTranscript ? 'rotate-180' : ''}`} />
                          </button>

                          {/* Transcript */}
                          <AnimatePresence>
                            {showTranscript && (
                              <motion.div
                                initial={{ height: 0, opacity: 0 }}
                                animate={{ height: 'auto', opacity: 1 }}
                                exit={{ height: 0, opacity: 0 }}
                                className="mt-3 overflow-hidden"
                              >
                                <div className="bg-slate-900/50 rounded-xl p-3 border border-white/5">
                                  <p className="text-white/70 text-sm leading-relaxed">
                                    {voiceNote.transcript}
                                  </p>
                                </div>
                              </motion.div>
                            )}
                          </AnimatePresence>
                        </div>
                      )}

                      {/* Quick Action Button */}
                      <button
                        onClick={() => setActiveTab('chat')}
                        className="w-full py-3 bg-gradient-to-r from-purple-500 to-pink-500 hover:opacity-90 text-white font-semibold rounded-xl transition-opacity flex items-center justify-center gap-2"
                      >
                        <MessageCircle className="w-4 h-4" />
                        Send Message
                      </button>
                    </motion.div>
                  ) : (
                    <motion.div
                      key="chat"
                      initial={{ opacity: 0, x: 20 }}
                      animate={{ opacity: 1, x: 0 }}
                      exit={{ opacity: 0, x: -20 }}
                      className="flex flex-col h-full"
                    >
                      {/* Messages Area */}
                      <div className="flex-1 overflow-y-auto p-5 space-y-4">
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
                            disabled={!message.trim() || sending || !connectionId || !userId}
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
                    </motion.div>
                  )}
                </AnimatePresence>
              </div>
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
}
