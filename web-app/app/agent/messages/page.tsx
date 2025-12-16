'use client';

export const dynamic = 'force-dynamic';

import { useState, useEffect, useRef } from 'react';
import { motion } from 'framer-motion';
import { Send, Loader2, MessageCircle, ArrowLeft } from 'lucide-react';
import { useAgent } from '@/hooks/useAgent';
import { agentDb, supabase } from '@/lib/supabase';

interface Message {
  id: string;
  connection_id: string;
  sender_id: string;
  sender_type: 'agent' | 'client';
  message: string;
  read: boolean;
  created_at: string;
}

interface Connection {
  id: string;
  client?: {
    id: string;
    full_name: string;
    avatar_url?: string;
  };
}

export default function AgentMessagesPage() {
  const { agentProfile, loading: agentLoading } = useAgent();
  const [connections, setConnections] = useState<Connection[]>([]);
  const [selectedConnection, setSelectedConnection] = useState<Connection | null>(null);
  const [messages, setMessages] = useState<Message[]>([]);
  const [newMessage, setNewMessage] = useState('');
  const [loading, setLoading] = useState(true);
  const [sending, setSending] = useState(false);
  const [unreadCounts, setUnreadCounts] = useState<Record<string, number>>({});
  const [userId, setUserId] = useState<string | null>(null);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    async function getUserId() {
      const { data: { user } } = await supabase.auth.getUser();
      if (user) setUserId(user.id);
    }
    getUserId();
  }, []);

  useEffect(() => {
    async function loadConnections() {
      if (!agentProfile || agentLoading) return;

      try {
        setLoading(true);
        const { data, error } = await agentDb.getAgentConnections(agentProfile.id);

        if (error) throw error;

        const activeConnections = data?.filter((c: any) => c.status === 'active') || [];
        setConnections(activeConnections);

        const counts: Record<string, number> = {};
        await Promise.all(
          activeConnections.map(async (conn: Connection) => {
            if (userId) {
              const { count } = await agentDb.getUnreadMessageCount(conn.id, userId);
              counts[conn.id] = count;
            }
          })
        );
        setUnreadCounts(counts);
        setLoading(false);
      } catch (error) {
        console.error('Error loading connections:', error);
        setLoading(false);
      }
    }

    loadConnections();
  }, [agentProfile, agentLoading, userId]);

  useEffect(() => {
    async function loadMessages() {
      if (!selectedConnection) return;

      try {
        const { data, error } = await agentDb.getMessages(selectedConnection.id);
        if (error) throw error;
        setMessages(data || []);

        if (userId) {
          await agentDb.markMessagesAsRead(selectedConnection.id, userId);
          setUnreadCounts(prev => ({ ...prev, [selectedConnection.id]: 0 }));
        }
      } catch (error) {
        console.error('Error loading messages:', error);
      }
    }

    loadMessages();
  }, [selectedConnection, userId]);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  const handleSendMessage = async () => {
    if (!newMessage.trim() || !selectedConnection || !userId || sending) return;

    setSending(true);
    try {
      const { data, error } = await agentDb.sendMessage({
        connectionId: selectedConnection.id,
        senderId: userId,
        senderType: 'agent',
        message: newMessage.trim(),
      });

      if (error) throw error;

      if (data) {
        setMessages([...messages, data]);
        setNewMessage('');
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

  const getInitials = (name: string) => {
    const parts = name.split(' ');
    if (parts.length >= 2) return `${parts[0][0]}${parts[parts.length - 1][0]}`.toUpperCase();
    return name.substring(0, 2).toUpperCase();
  };

  if (agentLoading || loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <Loader2 className="w-8 h-8 text-purple-500 animate-spin" />
      </div>
    );
  }

  return (
    <div className="h-screen flex flex-col md:flex-row bg-slate-950">
      {/* Clients Sidebar */}
      <div className={`${selectedConnection ? 'hidden md:flex' : 'flex'} md:w-80 lg:w-96 flex-col border-r border-white/10 bg-slate-900/50`}>
        <div className="p-4 border-b border-white/10">
          <h1 className="text-xl font-bold text-white mb-1">Messages</h1>
          <p className="text-white/60 text-sm">{connections.length} active client{connections.length !== 1 ? 's' : ''}</p>
        </div>
        <div className="flex-1 overflow-y-auto">
          {connections.length === 0 ? (
            <div className="flex flex-col items-center justify-center h-full p-8 text-center">
              <MessageCircle className="w-12 h-12 text-white/20 mb-3" />
              <p className="text-white/60 text-sm">No active clients yet</p>
            </div>
          ) : (
            connections.map((connection) => {
              const clientName = connection.client?.full_name || 'Client';
              const clientAvatar = connection.client?.avatar_url;
              const unreadCount = unreadCounts[connection.id] || 0;

              return (
                <button
                  key={connection.id}
                  onClick={() => setSelectedConnection(connection)}
                  className={`w-full p-4 flex items-center gap-3 border-b border-white/5 transition-colors ${
                    selectedConnection?.id === connection.id ? 'bg-purple-500/10 border-l-4 border-l-purple-500' : 'hover:bg-white/5'
                  }`}
                >
                  {clientAvatar ? (
                    <img src={clientAvatar} alt={clientName} className="w-12 h-12 rounded-full object-cover flex-shrink-0" />
                  ) : (
                    <div className="w-12 h-12 rounded-full bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center text-white text-sm font-bold flex-shrink-0">
                      {getInitials(clientName)}
                    </div>
                  )}
                  <div className="flex-1 min-w-0 text-left">
                    <div className="flex items-center justify-between mb-1">
                      <p className="text-white font-medium text-sm truncate">{clientName}</p>
                      {unreadCount > 0 && (
                        <span className="ml-2 w-5 h-5 rounded-full bg-purple-500 text-white text-xs flex items-center justify-center flex-shrink-0">{unreadCount}</span>
                      )}
                    </div>
                    <p className="text-white/40 text-xs truncate">Active client</p>
                  </div>
                </button>
              );
            })
          )}
        </div>
      </div>

      {/* Chat Area */}
      <div className={`${selectedConnection ? 'flex' : 'hidden md:flex'} flex-1 flex-col`}>
        {selectedConnection ? (
          <>
            <div className="p-4 border-b border-white/10 bg-slate-900/50 flex items-center gap-3">
              <button onClick={() => setSelectedConnection(null)} className="md:hidden w-8 h-8 rounded-full bg-white/10 hover:bg-white/20 flex items-center justify-center transition-colors">
                <ArrowLeft className="w-5 h-5 text-white" />
              </button>
              {selectedConnection.client?.avatar_url ? (
                <img src={selectedConnection.client.avatar_url} alt={selectedConnection.client?.full_name || 'Client'} className="w-10 h-10 rounded-full object-cover" />
              ) : (
                <div className="w-10 h-10 rounded-full bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center text-white text-sm font-bold">
                  {getInitials(selectedConnection.client?.full_name || 'Client')}
                </div>
              )}
              <div>
                <h2 className="text-white font-semibold">{selectedConnection.client?.full_name || 'Client'}</h2>
                <p className="text-white/60 text-xs">Active client</p>
              </div>
            </div>
            <div className="flex-1 overflow-y-auto p-4 space-y-4">
              {messages.length === 0 ? (
                <div className="flex flex-col items-center justify-center h-full text-center">
                  <MessageCircle className="w-12 h-12 text-white/20 mb-3" />
                  <p className="text-white/60 text-sm">No messages yet. Start the conversation!</p>
                </div>
              ) : (
                messages.map((msg) => {
                  const isOwnMessage = msg.sender_type === 'agent';
                  return (
                    <motion.div key={msg.id} initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} className={`flex ${isOwnMessage ? 'justify-end' : 'justify-start'}`}>
                      <div className={`max-w-[80%] flex flex-col gap-1`}>
                        <div className={`rounded-2xl px-4 py-3 ${isOwnMessage ? 'bg-gradient-to-r from-purple-500 to-pink-500 text-white' : 'bg-slate-800/50 text-white border border-white/10'}`}>
                          <p className="text-sm leading-relaxed break-words">{msg.message}</p>
                        </div>
                        <span className="text-white/40 text-xs px-2">{formatTime(msg.created_at)}</span>
                      </div>
                    </motion.div>
                  );
                })
              )}
              <div ref={messagesEndRef} />
            </div>
            <div className="p-4 border-t border-white/10 bg-slate-900/50">
              <div className="relative">
                <textarea
                  value={newMessage}
                  onChange={(e) => setNewMessage(e.target.value)}
                  placeholder="Type your message..."
                  className="w-full h-20 bg-slate-800/50 text-white placeholder-white/40 rounded-xl p-4 pr-14 border border-white/10 focus:border-purple-500/50 focus:outline-none resize-none"
                  onKeyDown={(e) => { if (e.key === 'Enter' && (e.metaKey || e.ctrlKey)) handleSendMessage(); }}
                  disabled={sending}
                />
                <button
                  onClick={handleSendMessage}
                  disabled={!newMessage.trim() || sending}
                  className="absolute right-3 bottom-3 w-10 h-10 bg-gradient-to-r from-purple-500 to-pink-500 disabled:opacity-50 disabled:cursor-not-allowed hover:opacity-90 rounded-xl flex items-center justify-center transition-opacity"
                >
                  {sending ? <Loader2 className="w-5 h-5 text-white animate-spin" /> : <Send className="w-5 h-5 text-white" />}
                </button>
              </div>
              <p className="text-white/40 text-xs mt-2 text-center">Press Cmd/Ctrl + Enter to send</p>
            </div>
          </>
        ) : (
          <div className="flex-1 flex items-center justify-center">
            <div className="text-center">
              <MessageCircle className="w-16 h-16 text-white/20 mx-auto mb-4" />
              <h3 className="text-white text-lg font-semibold mb-2">Select a client</h3>
              <p className="text-white/60 text-sm">Choose a client from the list to start messaging</p>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}