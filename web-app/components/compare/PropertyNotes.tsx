'use client';

import { useState } from 'react';
import { StickyNote, Save, Edit2 } from 'lucide-react';

interface PropertyNotesProps {
  listingId: string;
  note: string;
  onSave: (note: string) => void;
}

export default function PropertyNotes({ listingId, note, onSave }: PropertyNotesProps) {
  const [isEditing, setIsEditing] = useState(false);
  const [localNote, setLocalNote] = useState(note);

  const handleSave = () => {
    onSave(localNote);
    setIsEditing(false);
  };

  const handleCancel = () => {
    setLocalNote(note);
    setIsEditing(false);
  };

  return (
    <div>
      <div className="flex items-center gap-2 mb-3">
        <StickyNote className="w-4 h-4 text-yellow-400" />
        <h5 className="text-sm font-semibold text-white">My Notes</h5>
      </div>

      {isEditing ? (
        <div>
          <textarea
            value={localNote}
            onChange={(e) => setLocalNote(e.target.value)}
            placeholder="Add your thoughts, questions, or reminders..."
            className="w-full h-28 px-4 py-3 bg-white/5 border border-white/20 rounded-2xl text-sm text-white placeholder:text-white/40 focus:outline-none focus:border-primary/50 resize-none"
            autoFocus
          />
          <div className="flex items-center gap-2 mt-3">
            <button
              onClick={handleSave}
              className="flex-1 px-4 py-2 bg-gradient-to-r from-primary to-purple-500 rounded-2xl text-sm text-white font-semibold hover:opacity-90 transition-all flex items-center justify-center gap-2 shadow-lg shadow-primary/20"
            >
              <Save className="w-4 h-4" />
              Save Note
            </button>
            <button
              onClick={handleCancel}
              className="flex-1 px-4 py-2 glass-medium rounded-2xl text-sm text-white/60 hover:bg-white/10 transition-all font-medium"
            >
              Cancel
            </button>
          </div>
        </div>
      ) : (
        <div>
          {note ? (
            <div
              onClick={() => setIsEditing(true)}
              className="p-4 bg-yellow-500/10 border border-yellow-500/20 rounded-2xl cursor-pointer hover:bg-yellow-500/15 transition-all group"
            >
              <p className="text-sm text-white/80 whitespace-pre-wrap mb-3">{note}</p>
              <div className="flex items-center gap-2 text-yellow-400 opacity-0 group-hover:opacity-100 transition-opacity">
                <Edit2 className="w-4 h-4" />
                <span className="text-xs font-medium">Click to edit</span>
              </div>
            </div>
          ) : (
            <button
              onClick={() => setIsEditing(true)}
              className="w-full px-4 py-2.5 glass-medium border border-white/10 rounded-2xl text-sm text-white/60 hover:text-white hover:bg-white/10 transition-all flex items-center justify-center gap-2 font-medium"
            >
              <Edit2 className="w-4 h-4" />
              Add a note
            </button>
          )}
        </div>
      )}
    </div>
  );
}
