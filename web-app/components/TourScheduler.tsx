'use client';

import { useState } from 'react';
import { motion } from 'framer-motion';
import type { Listing } from '@/lib/types';
import BottomSheet from './BottomSheet';
import { analytics } from '@/lib/analytics';

interface TourSchedulerProps {
  isOpen: boolean;
  onClose: () => void;
  property: Listing;
}

export default function TourScheduler({
  isOpen,
  onClose,
  property,
}: TourSchedulerProps) {
  const [selectedDate, setSelectedDate] = useState<Date | null>(null);
  const [selectedTime, setSelectedTime] = useState<string | null>(null);
  const [tourType, setTourType] = useState<'in-person' | 'virtual'>('in-person');
  const [additionalProperties, setAdditionalProperties] = useState<string[]>([]);
  const [notes, setNotes] = useState('');

  // Generate next 14 days
  const generateDates = () => {
    const dates: Date[] = [];
    const today = new Date();
    for (let i = 0; i < 14; i++) {
      const date = new Date(today);
      date.setDate(today.getDate() + i);
      dates.push(date);
    }
    return dates;
  };

  // Available time slots
  const timeSlots = [
    '9:00 AM', '10:00 AM', '11:00 AM', '12:00 PM',
    '1:00 PM', '2:00 PM', '3:00 PM', '4:00 PM', '5:00 PM', '6:00 PM'
  ];

  const formatDate = (date: Date) => {
    return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
  };

  const formatDayOfWeek = (date: Date) => {
    return date.toLocaleDateString('en-US', { weekday: 'short' });
  };

  const handleSchedule = () => {
    if (!selectedDate || !selectedTime) {
      alert('Please select a date and time');
      return;
    }

    analytics.scheduleTour(property.id);

    // Save tour to calendar
    const calendarEvent = {
      id: `tour-${Date.now()}`,
      type: 'tour' as const,
      title: `${tourType === 'in-person' ? '🏠' : '💻'} Property Tour`,
      description: `${tourType === 'in-person' ? 'In-Person' : 'Virtual'} tour at ${property.address}${notes ? `\n\nNotes: ${notes}` : ''}`,
      date: selectedDate.toISOString(),
      time: selectedTime,
      location: property.address,
      propertyId: property.id,
      propertyAddress: property.address,
      completed: false,
    };

    // Get existing tours
    const existingTours = localStorage.getItem('homey_scheduled_tours');
    const tours = existingTours ? JSON.parse(existingTours) : [];
    tours.push(calendarEvent);
    localStorage.setItem('homey_scheduled_tours', JSON.stringify(tours));

    const tourDetails = {
      property: property.address,
      date: selectedDate.toLocaleDateString(),
      time: selectedTime,
      type: tourType,
      additionalProperties: additionalProperties.length,
      notes,
    };

    console.log('Tour scheduled:', tourDetails);

    alert(`✅ Tour scheduled!\n\n${property.address}\n${formatDate(selectedDate)} at ${selectedTime}\n${tourType === 'in-person' ? '🏠' : '💻'} ${tourType === 'in-person' ? 'In-Person' : 'Virtual'} Tour\n\nYou'll receive a confirmation email shortly.\n\n💡 Check your Calendar to view all scheduled tours!`);

    onClose();
  };

  const dates = generateDates();

  return (
    <BottomSheet isOpen={isOpen} onClose={onClose} title="Schedule a Tour" height="full">
      <div className="space-y-6">
        {/* Property Info */}
        <div className="sticky top-0 bg-gradient-to-b from-gray-900 to-transparent z-10 px-6 pt-4 pb-2">
          <div className="glass-strong rounded-xl p-3 border border-white/10">
            <div className="flex gap-3">
              <img
                src={property.images?.[0] || '/placeholder-property.jpg'}
                alt={property.address}
                className="w-16 h-16 rounded-lg object-cover"
              />
              <div className="flex-1">
                <p className="text-white font-semibold text-sm">{property.address}</p>
                <p className="text-white/60 text-xs">{property.neighborhood}</p>
              </div>
            </div>
          </div>
        </div>

        <div className="px-6 space-y-6 pb-6">
          {/* Tour Type */}
          <div>
            <h3 className="text-white font-semibold mb-3">Tour Type</h3>
            <div className="grid grid-cols-2 gap-3">
              <motion.button
                onClick={() => setTourType('in-person')}
                whileTap={{ scale: 0.98 }}
                className={`p-4 rounded-xl transition-all min-h-[44px] ${
                  tourType === 'in-person'
                    ? 'bg-primary/20 border-2 border-primary'
                    : 'bg-white/5 border border-white/10'
                }`}
              >
                <div className="text-2xl mb-1">🏠</div>
                <p className="text-white font-semibold text-sm">In-Person</p>
              </motion.button>

              <motion.button
                onClick={() => setTourType('virtual')}
                whileTap={{ scale: 0.98 }}
                className={`p-4 rounded-xl transition-all min-h-[44px] ${
                  tourType === 'virtual'
                    ? 'bg-primary/20 border-2 border-primary'
                    : 'bg-white/5 border border-white/10'
                }`}
              >
                <div className="text-2xl mb-1">💻</div>
                <p className="text-white font-semibold text-sm">Virtual</p>
              </motion.button>
            </div>
          </div>

          {/* Date Selection */}
          <div>
            <h3 className="text-white font-semibold mb-3">Select Date</h3>
            <div className="flex gap-2 overflow-x-auto scrollbar-hide pb-2">
              {dates.map((date, idx) => {
                const isSelected = selectedDate?.toDateString() === date.toDateString();
                const isToday = idx === 0;
                return (
                  <motion.button
                    key={idx}
                    onClick={() => setSelectedDate(date)}
                    whileTap={{ scale: 0.95 }}
                    className={`flex-shrink-0 w-20 p-3 rounded-xl text-center transition-all ${
                      isSelected
                        ? 'bg-primary border-2 border-primary'
                        : 'bg-white/5 border border-white/10 hover:bg-white/10'
                    }`}
                  >
                    <p className="text-white/60 text-xs mb-1">{formatDayOfWeek(date)}</p>
                    <p className="text-white font-bold">{formatDate(date).split(' ')[1]}</p>
                    {isToday && <p className="text-primary text-xs mt-1">Today</p>}
                  </motion.button>
                );
              })}
            </div>
          </div>

          {/* Time Selection */}
          {selectedDate && (
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
            >
              <h3 className="text-white font-semibold mb-3">Select Time</h3>
              <div className="grid grid-cols-3 gap-2">
                {timeSlots.map((time) => (
                  <motion.button
                    key={time}
                    onClick={() => setSelectedTime(time)}
                    whileTap={{ scale: 0.95 }}
                    className={`p-3 rounded-xl text-sm font-medium transition-all min-h-[44px] ${
                      selectedTime === time
                        ? 'bg-primary text-white'
                        : 'bg-white/5 text-white/80 border border-white/10 hover:bg-white/10'
                    }`}
                  >
                    {time}
                  </motion.button>
                ))}
              </div>
            </motion.div>
          )}

          {/* Add More Properties */}
          {selectedDate && selectedTime && (
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              className="glass-strong rounded-xl p-4 border border-white/10"
            >
              <div className="flex items-center justify-between mb-2">
                <div>
                  <p className="text-white font-semibold text-sm">Tour Multiple Properties</p>
                  <p className="text-white/60 text-xs">Save time by combining tours</p>
                </div>
                <button className="px-3 py-1.5 bg-primary/20 border border-primary/40 rounded-full text-primary text-xs font-bold hover:bg-primary/30 transition-colors">
                  + Add
                </button>
              </div>
              {additionalProperties.length > 0 && (
                <p className="text-white/60 text-xs">{additionalProperties.length} additional properties</p>
              )}
            </motion.div>
          )}

          {/* Notes */}
          {selectedDate && selectedTime && (
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
            >
              <h3 className="text-white font-semibold mb-3">Special Requests (Optional)</h3>
              <textarea
                value={notes}
                onChange={(e) => setNotes(e.target.value)}
                placeholder="Any questions or special requests for the agent?"
                className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-white/40 focus:outline-none focus:border-primary/50 resize-none"
                rows={3}
              />
            </motion.div>
          )}

          {/* Confirmation Summary */}
          {selectedDate && selectedTime && (
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              className="glass-strong rounded-xl p-4 border-2 border-primary/30"
            >
              <p className="text-white/60 text-xs mb-3">Tour Summary</p>
              <div className="space-y-2">
                <div className="flex items-center justify-between">
                  <span className="text-white/60 text-sm">Date</span>
                  <span className="text-white font-semibold">{formatDate(selectedDate)}</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-white/60 text-sm">Time</span>
                  <span className="text-white font-semibold">{selectedTime}</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-white/60 text-sm">Type</span>
                  <span className="text-white font-semibold">
                    {tourType === 'in-person' ? '🏠 In-Person' : '💻 Virtual'}
                  </span>
                </div>
              </div>
            </motion.div>
          )}

          {/* Schedule Button */}
          <button
            onClick={handleSchedule}
            disabled={!selectedDate || !selectedTime}
            className={`w-full py-4 rounded-2xl font-bold transition-all min-h-[44px] ${
              selectedDate && selectedTime
                ? 'bg-gradient-to-r from-primary via-purple-500 to-pink-500 text-white hover:opacity-90'
                : 'bg-white/10 text-white/40 cursor-not-allowed'
            }`}
          >
            📅 Confirm Tour
          </button>
        </div>
      </div>
    </BottomSheet>
  );
}
