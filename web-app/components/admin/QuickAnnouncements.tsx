'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Megaphone, Send, ChevronDown, ChevronUp, CheckCircle } from 'lucide-react';

export default function QuickAnnouncements() {
  const [isExpanded, setIsExpanded] = useState(true);
  const [message, setMessage] = useState('');
  const [messageType, setMessageType] = useState<'info' | 'warning' | 'success'>('info');
  const [sending, setSending] = useState(false);
  const [sent, setSent] = useState(false);

  const handleSend = async () => {
    if (!message.trim()) return;

    setSending(true);
    // Simulate sending
    await new Promise(resolve => setTimeout(resolve, 1000));

    // Save to localStorage for demo
    const announcement = {
      message: message.trim(),
      type: messageType,
      timestamp: new Date().toISOString(),
    };
    localStorage.setItem('homey_latest_announcement', JSON.stringify(announcement));

    setSending(false);
    setSent(true);
    setTimeout(() => {
      setMessage('');
      setSent(false);
    }, 2000);
  };

  const messageTypes = [
    { id: 'info' as const, label: 'Info', color: 'from-blue-500 to-cyan-500' },
    { id: 'warning' as const, label: 'Warning', color: 'from-yellow-500 to-orange-500' },
    { id: 'success' as const, label: 'Success', color: 'from-green-500 to-emerald-500' },
  ];

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
          <div className="w-10 h-10 bg-gradient-to-br from-orange-500 to-red-500 rounded-lg flex items-center justify-center">
            <Megaphone className="w-6 h-6 text-white" />
          </div>
          <div className="text-left">
            <h2 className="text-base md:text-lg font-semibold text-white">Quick Announcements</h2>
            <p className="text-xs text-white/60">Send message to all users</p>
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
            {/* Message Type */}
            <div className="mb-4">
              <label className="text-xs text-white/60 mb-2 block">Message Type</label>
              <div className="flex gap-2">
                {messageTypes.map((type) => (
                  <button
                    key={type.id}
                    onClick={() => setMessageType(type.id)}
                    className={`flex-1 px-3 py-2 rounded-lg text-xs font-medium transition-all touch-manipulation ${
                      messageType === type.id
                        ? `bg-gradient-to-r ${type.color} text-white`
                        : 'bg-white/5 text-white/60 hover:bg-white/10'
                    }`}
                  >
                    {type.label}
                  </button>
                ))}
              </div>
            </div>

            {/* Message Input */}
            <div className="mb-4">
              <label className="text-xs text-white/60 mb-2 block">Message</label>
              <textarea
                value={message}
                onChange={(e) => setMessage(e.target.value)}
                placeholder="Enter announcement message..."
                className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-lg text-white placeholder-white/40 focus:outline-none focus:border-white/30 resize-none text-sm"
                rows={3}
              />
            </div>

            {/* Send Button */}
            <button
              onClick={handleSend}
              disabled={!message.trim() || sending || sent}
              className={`w-full px-4 py-3 rounded-lg font-medium transition-all touch-manipulation flex items-center justify-center gap-2 ${
                sent
                  ? 'bg-gradient-to-r from-green-500 to-emerald-500 text-white'
                  : 'bg-gradient-to-r from-orange-500 to-red-500 hover:from-orange-600 hover:to-red-600 disabled:from-white/10 disabled:to-white/10 text-white disabled:text-white/40'
              }`}
            >
              {sending ? (
                <>
                  <div className="w-4 h-4 border-2 border-white/20 border-t-white rounded-full animate-spin" />
                  Sending...
                </>
              ) : sent ? (
                <>
                  <CheckCircle className="w-5 h-5" />
                  Sent!
                </>
              ) : (
                <>
                  <Send className="w-4 h-4" />
                  Send Announcement
                </>
              )}
            </button>

            {/* Info */}
            <div className="mt-4 p-3 bg-white/5 rounded-lg border border-white/10">
              <p className="text-xs text-white/60">
                📢 This will send a notification to all active users. The message will be displayed as a banner on their next page load.
              </p>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </motion.div>
  );
}
