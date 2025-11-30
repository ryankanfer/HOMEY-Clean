'use client';

import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import BottomSheet from './BottomSheet';
import type { CalendarEvent, EventType } from '@/app/calendar/page';

interface EventModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSave: (event: CalendarEvent) => void;
  onDelete?: (eventId: string) => void;
  event?: CalendarEvent | null;
  presetDate?: Date;
  presetTime?: string;
}

export default function EventModal({
  isOpen,
  onClose,
  onSave,
  onDelete,
  event,
  presetDate,
  presetTime,
}: EventModalProps) {
  const [eventType, setEventType] = useState<EventType>('reminder');
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [date, setDate] = useState('');
  const [time, setTime] = useState('');
  const [location, setLocation] = useState('');
  const [hasEndDate, setHasEndDate] = useState(false);
  const [endDate, setEndDate] = useState('');

  useEffect(() => {
    if (event) {
      // Edit mode - populate from existing event
      setEventType(event.type);
      setTitle(event.title);
      setDescription(event.description || '');
      setDate(new Date(event.date).toISOString().split('T')[0]);
      setTime(event.time || '');
      setLocation(event.location || '');
      if (event.endDate) {
        setHasEndDate(true);
        setEndDate(new Date(event.endDate).toISOString().split('T')[0]);
      }
    } else if (presetDate) {
      // Create mode with preset date and optional time
      setDate(presetDate.toISOString().split('T')[0]);
      if (presetTime) {
        setTime(presetTime);
      }
    } else {
      // Create mode - reset to defaults
      resetForm();
    }
  }, [event, presetDate, presetTime, isOpen]);

  const resetForm = () => {
    setEventType('reminder');
    setTitle('');
    setDescription('');
    setDate(new Date().toISOString().split('T')[0]);
    setTime('');
    setLocation('');
    setHasEndDate(false);
    setEndDate('');
  };

  const handleSave = () => {
    if (!title.trim() || !date) {
      alert('Please enter a title and date');
      return;
    }

    const newEvent: CalendarEvent = {
      id: event?.id || `event-${Date.now()}`,
      type: eventType,
      title: title.trim(),
      description: description.trim() || undefined,
      date: new Date(date).toISOString(),
      endDate: hasEndDate && endDate ? new Date(endDate).toISOString() : undefined,
      time: time || undefined,
      location: location.trim() || undefined,
      completed: event?.completed || false,
    };

    onSave(newEvent);
    resetForm();
    onClose();
  };

  const handleDelete = () => {
    if (!event) return;

    if (confirm('Are you sure you want to delete this event?')) {
      onDelete?.(event.id);
      onClose();
    }
  };

  const eventTypes: Array<{ type: EventType; label: string; icon: string; description: string }> = [
    { type: 'reminder', label: 'Reminder', icon: '🔔', description: 'General reminder or note' },
    { type: 'deadline', label: 'Deadline', icon: '⏰', description: 'Important deadline' },
    { type: 'document', label: 'Document', icon: '📄', description: 'Document-related date' },
    { type: 'moving', label: 'Moving', icon: '📦', description: 'Move-in or move-out' },
    { type: 'tour', label: 'Tour', icon: '🏠', description: 'Property tour' },
  ];

  const quickTitles = {
    reminder: ['Follow up with agent', 'Check listing updates', 'Schedule viewings', 'Review applications'],
    deadline: ['Application deadline', 'Deposit due', 'Lease signing', 'First rent payment'],
    document: ['Upload pay stubs', 'Get reference letters', 'Sign lease', 'Review contract'],
    moving: ['Move-in day', 'Move-out day', 'Book movers', 'Start packing'],
    tour: ['Property tour', 'Second viewing', 'Final walkthrough', 'Meet landlord'],
  };

  return (
    <BottomSheet
      isOpen={isOpen}
      onClose={onClose}
      title={event ? 'Edit Event' : 'Add Event'}
      height="full"
    >
      <div className="p-6 space-y-6">
        {/* Event Type */}
        <div>
          <h3 className="text-white font-semibold mb-3">Event Type</h3>
          <div className="grid grid-cols-2 gap-2">
            {eventTypes.map((type) => (
              <motion.button
                key={type.type}
                onClick={() => setEventType(type.type)}
                whileTap={{ scale: 0.98 }}
                className={`p-3 rounded-xl text-left transition-all min-h-[44px] ${
                  eventType === type.type
                    ? 'bg-primary/20 border-2 border-primary'
                    : 'bg-white/5 border border-white/10 hover:bg-white/10'
                }`}
              >
                <div className="flex items-center gap-2 mb-1">
                  <span className="text-xl">{type.icon}</span>
                  <span className="text-white font-semibold text-sm">{type.label}</span>
                </div>
                <p className="text-white/60 text-xs">{type.description}</p>
              </motion.button>
            ))}
          </div>
        </div>

        {/* Quick Title Suggestions */}
        <div>
          <h3 className="text-white font-semibold mb-3">Title</h3>
          <input
            type="text"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            placeholder="What's this event about?"
            className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-white/40 focus:outline-none focus:border-primary/50 mb-2"
          />
          <div className="flex flex-wrap gap-2">
            {quickTitles[eventType].map((suggestion) => (
              <button
                key={suggestion}
                onClick={() => setTitle(suggestion)}
                className="px-3 py-1.5 bg-white/10 hover:bg-white/20 rounded-full text-white/80 text-xs transition-colors"
              >
                {suggestion}
              </button>
            ))}
          </div>
        </div>

        {/* Description */}
        <div>
          <h3 className="text-white font-semibold mb-3">Description (Optional)</h3>
          <textarea
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            placeholder="Add any additional details..."
            className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-white/40 focus:outline-none focus:border-primary/50 resize-none"
            rows={3}
          />
        </div>

        {/* Date & Time */}
        <div className="grid grid-cols-2 gap-3">
          <div>
            <h3 className="text-white font-semibold mb-3">Date</h3>
            <input
              type="date"
              value={date}
              onChange={(e) => setDate(e.target.value)}
              className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white focus:outline-none focus:border-primary/50"
            />
          </div>
          <div>
            <h3 className="text-white font-semibold mb-3">Time (Optional)</h3>
            <input
              type="time"
              value={time}
              onChange={(e) => setTime(e.target.value)}
              className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white focus:outline-none focus:border-primary/50"
            />
          </div>
        </div>

        {/* End Date Toggle */}
        <div>
          <label className="flex items-center gap-3 cursor-pointer">
            <input
              type="checkbox"
              checked={hasEndDate}
              onChange={(e) => setHasEndDate(e.target.checked)}
              className="w-5 h-5 rounded border-white/20 bg-white/5 text-primary focus:ring-primary"
            />
            <span className="text-white font-medium">This is a multi-day event</span>
          </label>
          {hasEndDate && (
            <motion.div
              initial={{ opacity: 0, height: 0 }}
              animate={{ opacity: 1, height: 'auto' }}
              exit={{ opacity: 0, height: 0 }}
              className="mt-3"
            >
              <h3 className="text-white font-semibold mb-3">End Date</h3>
              <input
                type="date"
                value={endDate}
                onChange={(e) => setEndDate(e.target.value)}
                min={date}
                className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white focus:outline-none focus:border-primary/50"
              />
            </motion.div>
          )}
        </div>

        {/* Location */}
        <div>
          <h3 className="text-white font-semibold mb-3">Location (Optional)</h3>
          <input
            type="text"
            value={location}
            onChange={(e) => setLocation(e.target.value)}
            placeholder="Where is this happening?"
            className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-white/40 focus:outline-none focus:border-primary/50"
          />
        </div>

        {/* Action Buttons */}
        <div className="space-y-3 pt-4">
          <button
            onClick={handleSave}
            className="w-full py-4 rounded-2xl font-bold bg-gradient-to-r from-primary via-purple-500 to-pink-500 text-white hover:opacity-90 transition-opacity min-h-[44px]"
          >
            {event ? '💾 Update Event' : '➕ Add Event'}
          </button>

          {event && onDelete && (
            <button
              onClick={handleDelete}
              className="w-full py-4 rounded-2xl font-bold bg-red-500/20 hover:bg-red-500/30 border border-red-500/50 text-red-300 transition-colors min-h-[44px]"
            >
              🗑️ Delete Event
            </button>
          )}

          <button
            onClick={onClose}
            className="w-full py-4 rounded-2xl font-bold bg-white/10 hover:bg-white/20 text-white transition-colors min-h-[44px]"
          >
            Cancel
          </button>
        </div>
      </div>
    </BottomSheet>
  );
}
