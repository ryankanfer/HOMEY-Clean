'use client';

import { useRouter } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';
import { Shield, StickyNote, MessageSquare, X, Plus } from 'lucide-react';
import { useState, useRef, useEffect } from 'react';

interface AdminPillProps {
  position?: 'bottom-left' | 'bottom-right';
}

interface Note {
  id: string;
  content: string;
  type: 'note' | 'claude';
  timestamp: number;
}

export default function AdminPill({ position = 'bottom-left' }: AdminPillProps) {
  const router = useRouter();
  const [showNoteModal, setShowNoteModal] = useState(false);
  const [newNote, setNewNote] = useState('');
  const [noteType, setNoteType] = useState<'note' | 'claude'>('claude');
  const longPressTimer = useRef<NodeJS.Timeout | null>(null);
  const [isLongPressing, setIsLongPressing] = useState(false);

  const positionClasses = {
    'bottom-left': 'bottom-20 left-4',
    'bottom-right': 'bottom-20 right-4',
  };

  const handleLongPressStart = () => {
    setIsLongPressing(true);
    longPressTimer.current = setTimeout(() => {
      setShowNoteModal(true);
      setIsLongPressing(false);
    }, 500); // 500ms for long press
  };

  const handleLongPressEnd = () => {
    if (longPressTimer.current) {
      clearTimeout(longPressTimer.current);
    }
    if (!isLongPressing) return;
    setIsLongPressing(false);
    // If we haven't triggered the modal yet, treat as normal click
    router.push('/admin');
  };

  const addNote = () => {
    if (!newNote.trim()) return;

    try {
      const note: Note = {
        id: Date.now().toString(),
        content: newNote.trim(),
        type: noteType,
        timestamp: Date.now(),
      };

      // Load existing notes
      const saved = localStorage.getItem('homey_admin_notes');
      const existingNotes = saved ? JSON.parse(saved) : [];

      // Add new note
      const updatedNotes = [note, ...existingNotes];
      localStorage.setItem('homey_admin_notes', JSON.stringify(updatedNotes));

      console.log('✅ Note saved successfully:', note);

      // Dispatch custom event to notify AdminNotes component
      window.dispatchEvent(new CustomEvent('admin-notes-updated'));

      // Reset and close
      setNewNote('');
      setShowNoteModal(false);
    } catch (error) {
      console.error('❌ Failed to save note:', error);
      alert('Failed to save note. Please try again.');
    }
  };

  return (
    <>
    <motion.button
      onMouseDown={handleLongPressStart}
      onMouseUp={handleLongPressEnd}
      onMouseLeave={handleLongPressEnd}
      onTouchStart={handleLongPressStart}
      onTouchEnd={handleLongPressEnd}
      className={`fixed ${positionClasses[position]} z-[9999] px-4 py-3 bg-gradient-to-r from-yellow-500 to-orange-500 hover:from-orange-500 hover:to-yellow-500 rounded-full shadow-2xl transition-all flex items-center gap-2 group border-2 border-yellow-600`}
      initial={{ opacity: 0, scale: 0.8, y: 20 }}
      animate={{ opacity: 1, scale: 1, y: 0 }}
      whileHover={{ scale: 1.08, boxShadow: '0 20px 60px rgba(251, 191, 36, 0.4)' }}
      whileTap={{ scale: 0.95 }}
    >
      <Shield className="w-5 h-5 text-black" />
      <span className="text-sm font-bold text-black uppercase tracking-wider">
        Admin
      </span>
      <motion.div
        className="w-2 h-2 rounded-full bg-black"
        animate={{ scale: [1, 1.3, 1] }}
        transition={{ duration: 1.5, repeat: Infinity }}
      />
    </motion.button>

    {/* Quick Note Modal */}
    {showNoteModal && (
      <div className="fixed inset-0 z-[10000] flex items-center justify-center p-4">
        <AnimatePresence>
          {/* Backdrop */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={() => setShowNoteModal(false)}
            className="absolute inset-0 bg-black/60 backdrop-blur-sm"
          />

          {/* Modal */}
          <motion.div
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            exit={{ opacity: 0, scale: 0.9 }}
            className="relative w-full max-w-md z-10"
          >
            <div className="glass-strong rounded-2xl border border-white/20 p-6 shadow-2xl">
              {/* Header */}
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-lg font-bold text-white">Quick Note</h3>
                <button
                  onClick={() => setShowNoteModal(false)}
                  className="p-2 hover:bg-white/10 rounded-lg transition-colors"
                >
                  <X className="w-5 h-5 text-white/60" />
                </button>
              </div>

              {/* Type Selector */}
              <div className="flex gap-2 mb-4">
                <button
                  onClick={() => setNoteType('note')}
                  className={`flex-1 px-3 py-2 rounded-lg border text-xs font-medium transition-all ${
                    noteType === 'note'
                      ? 'bg-white/10 border-white/30 text-white'
                      : 'bg-white/5 border-white/10 text-white/60'
                  }`}
                >
                  <StickyNote className="w-3 h-3 inline mr-1" />
                  Note
                </button>
                <button
                  onClick={() => setNoteType('claude')}
                  className={`flex-1 px-3 py-2 rounded-lg border text-xs font-medium transition-all ${
                    noteType === 'claude'
                      ? 'bg-gradient-to-r from-purple-500/20 to-pink-500/20 border-purple-500/30 text-white'
                      : 'bg-white/5 border-white/10 text-white/60'
                  }`}
                >
                  <MessageSquare className="w-3 h-3 inline mr-1" />
                  Claude
                </button>
              </div>

              {/* Input */}
              <textarea
                value={newNote}
                onChange={(e) => setNewNote(e.target.value)}
                placeholder={
                  noteType === 'claude'
                    ? 'Message for Claude...'
                    : 'Quick note...'
                }
                className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-lg text-white placeholder-white/40 focus:outline-none focus:border-white/30 resize-none mb-4"
                rows={4}
                autoFocus
                onKeyDown={(e) => {
                  if (e.key === 'Enter' && (e.metaKey || e.ctrlKey)) {
                    addNote();
                  }
                }}
              />

              {/* Actions */}
              <div className="flex gap-2">
                <button
                  onClick={() => setShowNoteModal(false)}
                  className="flex-1 px-4 py-2.5 bg-white/5 hover:bg-white/10 rounded-lg text-white font-medium transition-all"
                >
                  Cancel
                </button>
                <button
                  onClick={addNote}
                  disabled={!newNote.trim()}
                  className="flex-1 px-4 py-2.5 bg-gradient-to-r from-purple-500 to-pink-500 hover:from-purple-600 hover:to-pink-600 disabled:from-white/10 disabled:to-white/10 text-white disabled:text-white/40 rounded-lg font-medium transition-all flex items-center justify-center gap-2"
                >
                  <Plus className="w-4 h-4" />
                  Add
                </button>
              </div>

              <p className="text-xs text-white/40 text-center mt-3">
                Hold Admin button for quick notes • {noteType === 'claude' ? '💬 Claude will see this' : '📝 Personal note'}
              </p>
            </div>
          </motion.div>
        </AnimatePresence>
      </div>
    )}
    </>
  );
}
