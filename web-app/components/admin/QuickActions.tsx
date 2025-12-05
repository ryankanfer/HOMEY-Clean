'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';
import { Zap, UserPlus, Trash2, Database, FileText, X, Home, StickyNote, MessageSquare, Plus } from 'lucide-react';

interface Note {
  id: string;
  content: string;
  type: 'note' | 'claude';
  timestamp: number;
}

export default function QuickActions() {
  const [isOpen, setIsOpen] = useState(false);
  const [showNoteModal, setShowNoteModal] = useState(false);
  const [newNote, setNewNote] = useState('');
  const [noteType, setNoteType] = useState<'note' | 'claude'>('claude');
  const router = useRouter();

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
      setIsOpen(false);
    } catch (error) {
      console.error('❌ Failed to save note:', error);
      alert('Failed to save note. Please try again.');
    }
  };

  const actions = [
    {
      icon: Home,
      label: 'Admin Home',
      color: 'from-yellow-500 to-orange-500',
      action: () => router.push('/admin')
    },
    {
      icon: StickyNote,
      label: 'Notes',
      color: 'from-amber-500 to-yellow-500',
      action: () => {
        setIsOpen(false);
        setShowNoteModal(true);
      }
    },
    {
      icon: UserPlus,
      label: 'Create Test User',
      color: 'from-blue-500 to-cyan-500',
      action: () => console.log('Create test user')
    },
    {
      icon: Trash2,
      label: 'Clear Cache',
      color: 'from-red-500 to-pink-500',
      action: () => console.log('Clear cache')
    },
    {
      icon: Database,
      label: 'Database Backup',
      color: 'from-green-500 to-emerald-500',
      action: () => console.log('Database backup')
    },
    {
      icon: FileText,
      label: 'View Logs',
      color: 'from-purple-500 to-pink-500',
      action: () => console.log('View logs')
    }
  ];

  return (
    <>
      {/* Main Button */}
      <motion.button
        onClick={() => setIsOpen(!isOpen)}
        className="fixed bottom-24 right-4 md:right-6 z-[9998] w-14 h-14 bg-gradient-to-r from-cyan-500 to-blue-500 hover:from-cyan-600 hover:to-blue-600 rounded-full shadow-2xl flex items-center justify-center transition-all"
        whileHover={{ scale: 1.1 }}
        whileTap={{ scale: 0.95 }}
      >
        <AnimatePresence mode="wait">
          {isOpen ? (
            <motion.div
              key="close"
              initial={{ rotate: -90, opacity: 0 }}
              animate={{ rotate: 0, opacity: 1 }}
              exit={{ rotate: 90, opacity: 0 }}
            >
              <X className="w-6 h-6 text-white" />
            </motion.div>
          ) : (
            <motion.div
              key="open"
              initial={{ rotate: 90, opacity: 0 }}
              animate={{ rotate: 0, opacity: 1 }}
              exit={{ rotate: -90, opacity: 0 }}
            >
              <Zap className="w-6 h-6 text-white" />
            </motion.div>
          )}
        </AnimatePresence>
      </motion.button>

      {/* Action Buttons */}
      <AnimatePresence>
        {isOpen && (
          <>
            {/* Backdrop */}
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setIsOpen(false)}
              className="fixed inset-0 z-[9997] bg-black/20 backdrop-blur-sm"
            />

            {/* Actions */}
            <div className="fixed bottom-40 right-4 md:right-6 z-[9999] flex flex-col gap-3">
              {actions.map((action, index) => {
                const Icon = action.icon;
                return (
                  <motion.button
                    key={action.label}
                    initial={{ opacity: 0, x: 20, scale: 0.8 }}
                    animate={{ opacity: 1, x: 0, scale: 1 }}
                    exit={{ opacity: 0, x: 20, scale: 0.8 }}
                    transition={{ delay: index * 0.05 }}
                    onClick={() => {
                      action.action();
                      setIsOpen(false);
                    }}
                    className="flex items-center gap-3 px-4 py-3 glass-strong rounded-xl border border-white/20 hover:border-white/40 shadow-xl transition-all group"
                  >
                    <div className={`w-10 h-10 bg-gradient-to-br ${action.color} rounded-lg flex items-center justify-center flex-shrink-0`}>
                      <Icon className="w-5 h-5 text-white" />
                    </div>
                    <span className="text-sm font-medium text-white whitespace-nowrap">{action.label}</span>
                  </motion.button>
                );
              })}
            </div>
          </>
        )}
      </AnimatePresence>

      {/* Quick Note Modal */}
      <AnimatePresence>
        {showNoteModal && (
          <div className="fixed inset-0 z-[10000] flex items-center justify-center p-4">
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
                  {noteType === 'claude' ? '💬 Claude will see this' : '📝 Personal note'}
                </p>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>
    </>
  );
}
