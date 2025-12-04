'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { ChevronDown, ChevronUp, Plus, X, Sparkles, Save, Trash2 } from 'lucide-react';
import {
  APP_VERSION,
  getReleaseNotes,
  storeReleaseNotes,
  markVersionAsSeen,
  formatVersion,
  type ReleaseNote
} from '@/lib/version';

export default function VersionManager() {
  const [isExpanded, setIsExpanded] = useState(false);
  const [releaseNotes, setReleaseNotes] = useState<ReleaseNote[]>([]);
  const [isEditing, setIsEditing] = useState(false);
  const [editingNote, setEditingNote] = useState<ReleaseNote | null>(null);

  // Form state
  const [formVersion, setFormVersion] = useState('');
  const [formDate, setFormDate] = useState('');
  const [formTitle, setFormTitle] = useState('');
  const [formHighlights, setFormHighlights] = useState<string[]>(['']);
  const [formChanges, setFormChanges] = useState<string[]>(['']);

  useEffect(() => {
    loadNotes();
  }, []);

  const loadNotes = () => {
    const notes = getReleaseNotes();
    setReleaseNotes(notes);
  };

  const handleAddNew = () => {
    setIsEditing(true);
    setEditingNote(null);
    setFormVersion(APP_VERSION);
    setFormDate(new Date().toISOString().split('T')[0]);
    setFormTitle('');
    setFormHighlights(['']);
    setFormChanges(['']);
  };

  const handleEdit = (note: ReleaseNote) => {
    setIsEditing(true);
    setEditingNote(note);
    setFormVersion(note.version);
    setFormDate(note.date);
    setFormTitle(note.title);
    setFormHighlights(note.highlights || ['']);
    setFormChanges(note.changes);
  };

  const handleSave = () => {
    const newNote: ReleaseNote = {
      version: formVersion,
      date: formDate,
      title: formTitle,
      highlights: formHighlights.filter(h => h.trim()),
      changes: formChanges.filter(c => c.trim()),
    };

    let updatedNotes = [...releaseNotes];

    if (editingNote) {
      // Update existing
      const index = updatedNotes.findIndex(n => n.version === editingNote.version);
      if (index >= 0) {
        updatedNotes[index] = newNote;
      }
    } else {
      // Add new
      updatedNotes = [newNote, ...updatedNotes];
    }

    storeReleaseNotes(updatedNotes);
    setReleaseNotes(updatedNotes);
    handleCancel();
  };

  const handleDelete = (version: string) => {
    if (!confirm(`Delete release notes for ${formatVersion(version)}?`)) return;

    const updatedNotes = releaseNotes.filter(n => n.version !== version);
    storeReleaseNotes(updatedNotes);
    setReleaseNotes(updatedNotes);
  };

  const handleCancel = () => {
    setIsEditing(false);
    setEditingNote(null);
    setFormVersion('');
    setFormDate('');
    setFormTitle('');
    setFormHighlights(['']);
    setFormChanges(['']);
  };

  const handleTriggerAnnouncement = (version: string) => {
    if (!confirm(`This will reset the "last seen version" so users see the announcement for ${formatVersion(version)} again. Continue?`)) return;

    // Reset last seen version in localStorage
    localStorage.removeItem('homey_last_seen_version');
    alert(`Announcement triggered! Refresh the page to see it.`);
  };

  const addHighlight = () => {
    setFormHighlights([...formHighlights, '']);
  };

  const updateHighlight = (index: number, value: string) => {
    const updated = [...formHighlights];
    updated[index] = value;
    setFormHighlights(updated);
  };

  const removeHighlight = (index: number) => {
    setFormHighlights(formHighlights.filter((_, i) => i !== index));
  };

  const addChange = () => {
    setFormChanges([...formChanges, '']);
  };

  const updateChange = (index: number, value: string) => {
    const updated = [...formChanges];
    updated[index] = value;
    setFormChanges(updated);
  };

  const removeChange = (index: number) => {
    setFormChanges(formChanges.filter((_, i) => i !== index));
  };

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
          <div className="w-10 h-10 bg-gradient-to-br from-yellow-500 to-orange-500 rounded-lg flex items-center justify-center">
            <Sparkles className="w-6 h-6 text-white" />
          </div>
          <div className="text-left">
            <h2 className="text-base md:text-lg font-semibold text-white">Version Manager</h2>
            <p className="text-xs text-white/60">
              Current: {formatVersion(APP_VERSION)} • {releaseNotes.length} release{releaseNotes.length !== 1 ? 's' : ''}
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
            className="px-4 md:px-6 pb-6"
          >
            {!isEditing ? (
              <>
                {/* Add New Button */}
                <button
                  onClick={handleAddNew}
                  className="w-full mb-4 px-4 py-3 bg-gradient-to-r from-purple-500 to-pink-500 hover:from-purple-600 hover:to-pink-600 text-white font-semibold rounded-xl transition-all flex items-center justify-center gap-2"
                >
                  <Plus className="w-4 h-4" />
                  Add New Release Notes
                </button>

                {/* Release Notes List */}
                <div className="space-y-3">
                  {releaseNotes.length === 0 ? (
                    <div className="text-center py-8 text-white/40">
                      No release notes yet. Add your first one!
                    </div>
                  ) : (
                    releaseNotes.map((note) => (
                      <div
                        key={note.version}
                        className="p-4 bg-white/5 rounded-xl border border-white/10"
                      >
                        <div className="flex items-start justify-between mb-2">
                          <div>
                            <h3 className="text-white font-semibold">
                              {formatVersion(note.version)} • {note.title}
                            </h3>
                            <p className="text-white/60 text-sm">{note.date}</p>
                          </div>
                          <div className="flex gap-2">
                            <button
                              onClick={() => handleEdit(note)}
                              className="p-2 hover:bg-white/10 rounded-lg transition-colors text-white/60 hover:text-white"
                            >
                              ✏️
                            </button>
                            <button
                              onClick={() => handleDelete(note.version)}
                              className="p-2 hover:bg-red-500/20 rounded-lg transition-colors"
                            >
                              <Trash2 className="w-4 h-4 text-red-400" />
                            </button>
                          </div>
                        </div>

                        <div className="mb-3">
                          <p className="text-white/80 text-sm">
                            {note.changes.length} change{note.changes.length !== 1 ? 's' : ''}
                            {note.highlights && note.highlights.length > 0 && `, ${note.highlights.length} highlight${note.highlights.length !== 1 ? 's' : ''}`}
                          </p>
                        </div>

                        <button
                          onClick={() => handleTriggerAnnouncement(note.version)}
                          className="w-full px-3 py-2 bg-yellow-500/20 hover:bg-yellow-500/30 border border-yellow-500/30 text-yellow-300 rounded-lg text-sm font-medium transition-all"
                        >
                          <Sparkles className="w-3.5 h-3.5 inline mr-1" />
                          Trigger Announcement
                        </button>
                      </div>
                    ))
                  )}
                </div>
              </>
            ) : (
              /* Edit Form */
              <div className="space-y-4">
                <div className="flex items-center justify-between mb-4">
                  <h3 className="text-white font-semibold">
                    {editingNote ? 'Edit' : 'New'} Release Notes
                  </h3>
                  <button
                    onClick={handleCancel}
                    className="p-2 hover:bg-white/10 rounded-lg transition-colors"
                  >
                    <X className="w-5 h-5 text-white/60" />
                  </button>
                </div>

                {/* Version & Date */}
                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="text-white/60 text-sm mb-1 block">Version</label>
                    <input
                      type="text"
                      value={formVersion}
                      onChange={(e) => setFormVersion(e.target.value)}
                      placeholder="1.0.0"
                      className="w-full px-3 py-2 bg-white/5 border border-white/10 rounded-lg text-white placeholder-white/40 focus:outline-none focus:border-white/30 text-sm"
                    />
                  </div>
                  <div>
                    <label className="text-white/60 text-sm mb-1 block">Date</label>
                    <input
                      type="date"
                      value={formDate}
                      onChange={(e) => setFormDate(e.target.value)}
                      className="w-full px-3 py-2 bg-white/5 border border-white/10 rounded-lg text-white focus:outline-none focus:border-white/30 text-sm"
                    />
                  </div>
                </div>

                {/* Title */}
                <div>
                  <label className="text-white/60 text-sm mb-1 block">Title</label>
                  <input
                    type="text"
                    value={formTitle}
                    onChange={(e) => setFormTitle(e.target.value)}
                    placeholder="Profile Redesign & Admin Improvements"
                    className="w-full px-3 py-2 bg-white/5 border border-white/10 rounded-lg text-white placeholder-white/40 focus:outline-none focus:border-white/30 text-sm"
                  />
                </div>

                {/* Highlights */}
                <div>
                  <div className="flex items-center justify-between mb-2">
                    <label className="text-white/60 text-sm">Highlights (with emoji)</label>
                    <button
                      onClick={addHighlight}
                      className="text-purple-400 hover:text-purple-300 text-xs flex items-center gap-1"
                    >
                      <Plus className="w-3 h-3" />
                      Add
                    </button>
                  </div>
                  <div className="space-y-2">
                    {formHighlights.map((highlight, index) => (
                      <div key={index} className="flex gap-2">
                        <input
                          type="text"
                          value={highlight}
                          onChange={(e) => updateHighlight(index, e.target.value)}
                          placeholder="✨ Brand new passport-style profile page"
                          className="flex-1 px-3 py-2 bg-white/5 border border-white/10 rounded-lg text-white placeholder-white/40 focus:outline-none focus:border-white/30 text-sm"
                        />
                        {formHighlights.length > 1 && (
                          <button
                            onClick={() => removeHighlight(index)}
                            className="p-2 hover:bg-red-500/20 rounded-lg transition-colors"
                          >
                            <X className="w-4 h-4 text-red-400" />
                          </button>
                        )}
                      </div>
                    ))}
                  </div>
                </div>

                {/* Changes */}
                <div>
                  <div className="flex items-center justify-between mb-2">
                    <label className="text-white/60 text-sm">Changes</label>
                    <button
                      onClick={addChange}
                      className="text-purple-400 hover:text-purple-300 text-xs flex items-center gap-1"
                    >
                      <Plus className="w-3 h-3" />
                      Add
                    </button>
                  </div>
                  <div className="space-y-2 max-h-48 overflow-y-auto">
                    {formChanges.map((change, index) => (
                      <div key={index} className="flex gap-2">
                        <input
                          type="text"
                          value={change}
                          onChange={(e) => updateChange(index, e.target.value)}
                          placeholder="Added new feature..."
                          className="flex-1 px-3 py-2 bg-white/5 border border-white/10 rounded-lg text-white placeholder-white/40 focus:outline-none focus:border-white/30 text-sm"
                        />
                        {formChanges.length > 1 && (
                          <button
                            onClick={() => removeChange(index)}
                            className="p-2 hover:bg-red-500/20 rounded-lg transition-colors"
                          >
                            <X className="w-4 h-4 text-red-400" />
                          </button>
                        )}
                      </div>
                    ))}
                  </div>
                </div>

                {/* Actions */}
                <div className="flex gap-2 pt-4">
                  <button
                    onClick={handleCancel}
                    className="flex-1 px-4 py-2.5 bg-white/5 hover:bg-white/10 rounded-lg text-white font-medium transition-all"
                  >
                    Cancel
                  </button>
                  <button
                    onClick={handleSave}
                    disabled={!formVersion || !formTitle || formChanges.filter(c => c.trim()).length === 0}
                    className="flex-1 px-4 py-2.5 bg-gradient-to-r from-purple-500 to-pink-500 hover:from-purple-600 hover:to-pink-600 disabled:from-white/10 disabled:to-white/10 text-white disabled:text-white/40 rounded-lg font-medium transition-all flex items-center justify-center gap-2"
                  >
                    <Save className="w-4 h-4" />
                    Save
                  </button>
                </div>
              </div>
            )}
          </motion.div>
        )}
      </AnimatePresence>
    </motion.div>
  );
}
