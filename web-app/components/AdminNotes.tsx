'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Plus, Trash2, StickyNote, MessageSquare, ChevronDown, ChevronUp } from 'lucide-react';

interface Note {
  id: string;
  content: string;
  type: 'note' | 'claude';
  timestamp: number;
}

export default function AdminNotes() {
  const [notes, setNotes] = useState<Note[]>([]);
  const [newNote, setNewNote] = useState('');
  const [noteType, setNoteType] = useState<'note' | 'claude'>('note');
  const [isExpanded, setIsExpanded] = useState(true);

  useEffect(() => {
    loadNotes();
  }, []);

  const loadNotes = () => {
    const saved = localStorage.getItem('homey_admin_notes');
    if (saved) {
      setNotes(JSON.parse(saved));
    }
  };

  const saveNotes = (updatedNotes: Note[]) => {
    localStorage.setItem('homey_admin_notes', JSON.stringify(updatedNotes));
    setNotes(updatedNotes);
  };

  const addNote = () => {
    if (!newNote.trim()) return;

    const note: Note = {
      id: Date.now().toString(),
      content: newNote.trim(),
      type: noteType,
      timestamp: Date.now(),
    };

    const updatedNotes = [note, ...notes];
    saveNotes(updatedNotes);
    setNewNote('');
  };

  const deleteNote = (id: string) => {
    const updatedNotes = notes.filter(n => n.id !== id);
    saveNotes(updatedNotes);
  };

  const formatTimestamp = (timestamp: number) => {
    const date = new Date(timestamp);
    const now = new Date();
    const diff = now.getTime() - date.getTime();
    const hours = Math.floor(diff / (1000 * 60 * 60));

    if (hours < 1) return 'Just now';
    if (hours < 24) return `${hours}h ago`;
    return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
  };

  const claudeNotes = notes.filter(n => n.type === 'claude');
  const regularNotes = notes.filter(n => n.type === 'note');

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="glass-strong rounded-2xl border border-white/10 overflow-hidden"
    >
      {/* Header */}
      <button
        onClick={() => setIsExpanded(!isExpanded)}
        className="w-full px-6 py-4 flex items-center justify-between hover:bg-white/5 transition-colors"
      >
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-gradient-to-br from-pink-500 to-purple-500 rounded-lg flex items-center justify-center">
            <StickyNote className="w-6 h-6 text-white" />
          </div>
          <div className="text-left">
            <h2 className="text-lg font-semibold text-white">Admin Notes & Messages</h2>
            <p className="text-xs text-white/60">
              {claudeNotes.length} messages for Claude • {regularNotes.length} notes
            </p>
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
            className="px-6 pb-6"
          >
            {/* Add Note Form */}
            <div className="space-y-3 mb-6">
              {/* Type Selector */}
              <div className="flex gap-2">
                <button
                  onClick={() => setNoteType('note')}
                  className={`flex-1 px-4 py-2.5 rounded-lg border transition-all text-sm font-medium ${
                    noteType === 'note'
                      ? 'bg-white/10 border-white/30 text-white'
                      : 'bg-white/5 border-white/10 text-white/60 hover:bg-white/10'
                  }`}
                >
                  <StickyNote className="w-4 h-4 inline mr-2" />
                  Personal Note
                </button>
                <button
                  onClick={() => setNoteType('claude')}
                  className={`flex-1 px-4 py-2.5 rounded-lg border transition-all text-sm font-medium ${
                    noteType === 'claude'
                      ? 'bg-gradient-to-r from-purple-500/20 to-pink-500/20 border-purple-500/30 text-white'
                      : 'bg-white/5 border-white/10 text-white/60 hover:bg-white/10'
                  }`}
                >
                  <MessageSquare className="w-4 h-4 inline mr-2" />
                  Message for Claude
                </button>
              </div>

              {/* Input */}
              <div className="flex gap-2">
                <textarea
                  value={newNote}
                  onChange={(e) => setNewNote(e.target.value)}
                  placeholder={
                    noteType === 'claude'
                      ? 'Ask Claude a question or leave a task...'
                      : 'Leave yourself a note...'
                  }
                  className="flex-1 px-4 py-3 bg-white/5 border border-white/10 rounded-lg text-white placeholder-white/40 focus:outline-none focus:border-white/30 resize-none"
                  rows={3}
                  onKeyDown={(e) => {
                    if (e.key === 'Enter' && (e.metaKey || e.ctrlKey)) {
                      addNote();
                    }
                  }}
                />
              </div>

              <button
                onClick={addNote}
                disabled={!newNote.trim()}
                className="w-full px-4 py-3 bg-gradient-to-r from-purple-500 to-pink-500 hover:from-purple-600 hover:to-pink-600 disabled:from-white/10 disabled:to-white/10 text-white disabled:text-white/40 rounded-lg font-medium transition-all flex items-center justify-center gap-2 touch-manipulation"
              >
                <Plus className="w-5 h-5" />
                Add {noteType === 'claude' ? 'Message' : 'Note'}
              </button>

              <p className="text-xs text-white/40 text-center">
                {noteType === 'claude'
                  ? '💬 Claude will see these messages in your next session'
                  : '📝 Personal notes saved locally on this device'
                }
              </p>
            </div>

            {/* Messages for Claude */}
            {claudeNotes.length > 0 && (
              <div className="mb-6">
                <h3 className="text-sm font-semibold text-purple-400 mb-3 flex items-center gap-2">
                  <MessageSquare className="w-4 h-4" />
                  Messages for Claude ({claudeNotes.length})
                </h3>
                <div className="space-y-2">
                  {claudeNotes.map((note) => (
                    <motion.div
                      key={note.id}
                      initial={{ opacity: 0, x: -20 }}
                      animate={{ opacity: 1, x: 0 }}
                      exit={{ opacity: 0, x: 20 }}
                      className="p-4 bg-gradient-to-r from-purple-500/10 to-pink-500/10 border border-purple-500/20 rounded-lg group"
                    >
                      <div className="flex items-start justify-between gap-3">
                        <div className="flex-1 min-w-0">
                          <p className="text-sm text-white whitespace-pre-wrap break-words">
                            {note.content}
                          </p>
                          <p className="text-xs text-white/40 mt-2">
                            {formatTimestamp(note.timestamp)}
                          </p>
                        </div>
                        <button
                          onClick={() => deleteNote(note.id)}
                          className="p-2 hover:bg-red-500/20 rounded-lg transition-colors opacity-0 group-hover:opacity-100 touch-manipulation"
                        >
                          <Trash2 className="w-4 h-4 text-red-400" />
                        </button>
                      </div>
                    </motion.div>
                  ))}
                </div>
              </div>
            )}

            {/* Personal Notes */}
            {regularNotes.length > 0 && (
              <div>
                <h3 className="text-sm font-semibold text-white/80 mb-3 flex items-center gap-2">
                  <StickyNote className="w-4 h-4" />
                  Personal Notes ({regularNotes.length})
                </h3>
                <div className="space-y-2">
                  {regularNotes.map((note) => (
                    <motion.div
                      key={note.id}
                      initial={{ opacity: 0, x: -20 }}
                      animate={{ opacity: 1, x: 0 }}
                      exit={{ opacity: 0, x: 20 }}
                      className="p-4 bg-white/5 border border-white/10 rounded-lg group"
                    >
                      <div className="flex items-start justify-between gap-3">
                        <div className="flex-1 min-w-0">
                          <p className="text-sm text-white/80 whitespace-pre-wrap break-words">
                            {note.content}
                          </p>
                          <p className="text-xs text-white/40 mt-2">
                            {formatTimestamp(note.timestamp)}
                          </p>
                        </div>
                        <button
                          onClick={() => deleteNote(note.id)}
                          className="p-2 hover:bg-red-500/20 rounded-lg transition-colors opacity-0 group-hover:opacity-100 touch-manipulation"
                        >
                          <Trash2 className="w-4 h-4 text-red-400" />
                        </button>
                      </div>
                    </motion.div>
                  ))}
                </div>
              </div>
            )}

            {notes.length === 0 && (
              <div className="text-center py-12">
                <StickyNote className="w-12 h-12 text-white/20 mx-auto mb-3" />
                <p className="text-white/40 text-sm">No notes yet</p>
              </div>
            )}
          </motion.div>
        )}
      </AnimatePresence>
    </motion.div>
  );
}
