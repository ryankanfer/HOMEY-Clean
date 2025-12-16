'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';
import CinematicBackground from '@/components/CinematicBackground';
import BottomNav from '@/components/BottomNav';
import EventModal from '@/components/EventModal';
import { analytics } from '@/lib/analytics';

export const dynamic = 'force-dynamic';

type ViewMode = 'month' | 'week' | 'day' | 'list';

export type EventType = 'tour' | 'document' | 'reminder' | 'deadline' | 'moving';

export interface CalendarEvent {
  id: string;
  type: EventType;
  title: string;
  description?: string;
  date: Date;
  endDate?: Date;
  time?: string;
  location?: string;
  propertyId?: string;
  propertyAddress?: string;
  completed?: boolean;
}

export default function CalendarPage() {
  const router = useRouter();
  const [viewMode, setViewMode] = useState<ViewMode>('month');
  const [currentDate, setCurrentDate] = useState(new Date());
  const [events, setEvents] = useState<CalendarEvent[]>([]);
  const [selectedDate, setSelectedDate] = useState<Date | null>(null);
  const [showEventModal, setShowEventModal] = useState(false);
  const [selectedEvent, setSelectedEvent] = useState<CalendarEvent | null>(null);
  const [presetTime, setPresetTime] = useState<string | undefined>(undefined);

  useEffect(() => {
    analytics.pageView('calendar');
    loadEvents();
  }, []);

  const loadEvents = () => {
    // Load scheduled tours from localStorage
    const tours = localStorage.getItem('homey_scheduled_tours');
    const tourEvents: CalendarEvent[] = tours ? JSON.parse(tours) : [];

    // Load document deadlines from Vault and convert to calendar events
    const vaultDocs = localStorage.getItem('homey_vault_documents');
    const docEvents: CalendarEvent[] = [];

    if (vaultDocs) {
      const docs = JSON.parse(vaultDocs);
      docs.forEach((doc: any) => {
        if (doc.expirationDate) {
          // Calculate days until expiration
          const daysUntil = Math.ceil(
            (new Date(doc.expirationDate).getTime() - new Date().getTime()) / (1000 * 60 * 60 * 24)
          );

          const urgencyText = daysUntil <= 7
            ? '⚠️ Expires soon!'
            : daysUntil <= 30
            ? 'Expiring this month'
            : 'Document expiration';

          docEvents.push({
            id: `doc-${doc.id}`,
            type: 'deadline',
            title: doc.name.replace('.pdf', ''),
            description: `${urgencyText} - ${doc.category}`,
            date: new Date(doc.expirationDate),
            time: '11:59 PM',
            location: 'Vault',
            completed: false,
          });
        }
      });
    }

    // Load custom reminders
    const reminders = localStorage.getItem('homey_calendar_events');
    const reminderEvents: CalendarEvent[] = reminders ? JSON.parse(reminders) : [];

    // Combine all events
    const combined = [...tourEvents, ...docEvents, ...reminderEvents];

    // Deduplicate by ID
    const uniqueEvents = combined.reduce((acc, event) => {
      if (!acc.find((e) => e.id === event.id)) {
        acc.push(event);
      }
      return acc;
    }, [] as CalendarEvent[]);

    // Sort by date
    const sorted = uniqueEvents.sort(
      (a, b) => new Date(a.date).getTime() - new Date(b.date).getTime()
    );

    setEvents(sorted);
  };

  const handleSaveEvent = (event: CalendarEvent) => {
    // Determine which storage to use based on event type
    const storageKey = event.type === 'tour' ? 'homey_scheduled_tours' : 'homey_calendar_events';

    // Load existing events
    const existingData = localStorage.getItem(storageKey);
    const existingEvents: CalendarEvent[] = existingData ? JSON.parse(existingData) : [];

    // Check if updating existing event or creating new one
    const eventIndex = existingEvents.findIndex((e) => e.id === event.id);

    if (eventIndex >= 0) {
      // Update existing
      existingEvents[eventIndex] = event;
    } else {
      // Add new
      existingEvents.push(event);
    }

    // Save back to localStorage
    localStorage.setItem(storageKey, JSON.stringify(existingEvents));

    // Reload all events
    loadEvents();

    analytics.click('calendar_event_saved', 'button', { event_type: event.type });
  };

  const handleDeleteEvent = (eventId: string) => {
    // Try to find and delete from all storage locations
    const storageKeys = ['homey_scheduled_tours', 'homey_calendar_events', 'homey_vault_documents'];

    storageKeys.forEach((key) => {
      const data = localStorage.getItem(key);
      if (data) {
        const events: CalendarEvent[] = JSON.parse(data);
        const filtered = events.filter((e) => e.id !== eventId);
        if (filtered.length !== events.length) {
          localStorage.setItem(key, JSON.stringify(filtered));
        }
      }
    });

    // Reload all events
    loadEvents();

    analytics.click('calendar_event_deleted', 'button');
  };

  const handleEditEvent = (event: CalendarEvent) => {
    setSelectedEvent(event);
    setShowEventModal(true);
  };

  const handleAddEvent = (date?: Date, hour?: number) => {
    setSelectedEvent(null);
    setSelectedDate(date || null);
    setPresetTime(hour !== undefined ? formatHourToTime(hour) : undefined);
    setShowEventModal(true);
  };

  const formatHourToTime = (hour: number): string => {
    const period = hour < 12 ? 'AM' : 'PM';
    const displayHour = hour % 12 || 12;
    return `${displayHour}:00 ${period}`;
  };

  const getEventIcon = (type: EventType) => {
    switch (type) {
      case 'tour':
        return '🏠';
      case 'document':
        return '📄';
      case 'reminder':
        return '🔔';
      case 'deadline':
        return '⏰';
      case 'moving':
        return '📦';
      default:
        return '📅';
    }
  };

  const getEventColor = (type: EventType) => {
    switch (type) {
      case 'tour':
        return 'bg-primary/20 border-primary/50 text-primary';
      case 'document':
        return 'bg-blue-500/20 border-blue-500/50 text-blue-300';
      case 'reminder':
        return 'bg-yellow-500/20 border-yellow-500/50 text-yellow-300';
      case 'deadline':
        return 'bg-red-500/20 border-red-500/50 text-red-300';
      case 'moving':
        return 'bg-purple-500/20 border-purple-500/50 text-purple-300';
      default:
        return 'bg-white/20 border-white/50 text-white';
    }
  };

  const formatDate = (date: Date) => {
    return new Date(date).toLocaleDateString('en-US', {
      month: 'short',
      day: 'numeric',
      year: 'numeric',
    });
  };

  const formatDayOfWeek = (date: Date) => {
    return new Date(date).toLocaleDateString('en-US', { weekday: 'short' });
  };

  const formatTime = (time: string) => {
    return time;
  };

  const isToday = (date: Date) => {
    const today = new Date();
    return (
      date.getDate() === today.getDate() &&
      date.getMonth() === today.getMonth() &&
      date.getFullYear() === today.getFullYear()
    );
  };

  const isSameDay = (date1: Date, date2: Date) => {
    return (
      date1.getDate() === date2.getDate() &&
      date1.getMonth() === date2.getMonth() &&
      date1.getFullYear() === date2.getFullYear()
    );
  };

  const getEventsForDate = (date: Date) => {
    return events.filter((event) => isSameDay(new Date(event.date), date));
  };

  const getDaysInMonth = (date: Date) => {
    const year = date.getFullYear();
    const month = date.getMonth();
    const firstDay = new Date(year, month, 1);
    const lastDay = new Date(year, month + 1, 0);
    const daysInMonth = lastDay.getDate();
    const startingDayOfWeek = firstDay.getDay();

    const days: (Date | null)[] = [];

    // Add empty cells for days before the first of the month
    for (let i = 0; i < startingDayOfWeek; i++) {
      days.push(null);
    }

    // Add all days of the month
    for (let day = 1; day <= daysInMonth; day++) {
      days.push(new Date(year, month, day));
    }

    return days;
  };

  const monthName = currentDate.toLocaleDateString('en-US', { month: 'long', year: 'numeric' });

  const previousMonth = () => {
    setCurrentDate(new Date(currentDate.getFullYear(), currentDate.getMonth() - 1, 1));
  };

  const nextMonth = () => {
    setCurrentDate(new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 1));
  };

  const goToToday = () => {
    setCurrentDate(new Date());
  };

  const upcomingEvents = events
    .filter((event) => new Date(event.date) >= new Date())
    .slice(0, 5);

  // Week view helpers
  const getWeekDates = () => {
    const dates: Date[] = [];
    const start = new Date(currentDate);
    start.setDate(start.getDate() - start.getDay()); // Start on Sunday

    for (let i = 0; i < 7; i++) {
      const date = new Date(start);
      date.setDate(start.getDate() + i);
      dates.push(date);
    }
    return dates;
  };

  const previousWeek = () => {
    setCurrentDate(new Date(currentDate.getTime() - 7 * 24 * 60 * 60 * 1000));
  };

  const nextWeek = () => {
    setCurrentDate(new Date(currentDate.getTime() + 7 * 24 * 60 * 60 * 1000));
  };

  const previousDay = () => {
    setCurrentDate(new Date(currentDate.getTime() - 24 * 60 * 60 * 1000));
  };

  const nextDay = () => {
    setCurrentDate(new Date(currentDate.getTime() + 24 * 60 * 60 * 1000));
  };

  const timeSlots = Array.from({ length: 24 }, (_, i) => {
    const hour = i % 12 || 12;
    const period = i < 12 ? 'AM' : 'PM';
    return { hour: i, label: `${hour}:00 ${period}` };
  });

  const getEventPosition = (event: CalendarEvent) => {
    if (!event.time) return null;

    // Parse time like "2:00 PM"
    const [time, period] = event.time.split(' ');
    const [hourStr, minute] = time.split(':');
    let hour = parseInt(hourStr);

    if (period === 'PM' && hour !== 12) hour += 12;
    if (period === 'AM' && hour === 12) hour = 0;

    return hour;
  };

  const getCurrentHour = () => {
    return new Date().getHours();
  };

  const weekDates = getWeekDates();

  return (
    <main className="relative min-h-screen pb-24">
      <CinematicBackground timeOfDay="day" />

      {/* Header */}
      <header className="fixed top-0 left-0 right-0 z-50 bg-gradient-to-b from-black/60 via-black/40 to-transparent backdrop-blur-sm">
        <div className="flex items-center justify-between px-5 py-4">
          <h1 className="text-2xl font-bold text-white">Calendar</h1>
          <button
            onClick={() => handleAddEvent()}
            className="px-4 py-2 bg-primary hover:bg-primary/90 rounded-full text-white font-semibold transition-colors flex items-center gap-2 min-h-[44px]"
          >
            <span className="text-lg">+</span>
            Add Event
          </button>
        </div>
      </header>

      {/* Beta Notice Banner */}
      <div className="relative z-40 pt-20 px-5">
        <motion.div
          initial={{ opacity: 0, y: -10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
          className="mb-4 p-3 bg-blue-500/20 border border-blue-500/30 rounded-xl backdrop-blur-sm"
        >
          <div className="flex items-start gap-3">
            <span className="text-lg flex-shrink-0">ℹ️</span>
            <div className="text-xs text-blue-100">
              <p className="font-semibold mb-1">Beta Notice</p>
              <p className="text-blue-200/80">
                Calendar events are currently stored locally on this device only. Events will not sync across devices or browsers.
              </p>
            </div>
          </div>
        </motion.div>
      </div>

      {/* Content */}
      <div className="relative z-10 px-5">
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.6 }}
        >
          {/* View Mode Selector */}
          <div className="mb-6 flex gap-2 overflow-x-auto scrollbar-hide">
            {(['month', 'week', 'day', 'list'] as ViewMode[]).map((mode) => (
              <button
                key={mode}
                onClick={() => setViewMode(mode)}
                className={`px-4 py-2 rounded-full text-sm font-medium whitespace-nowrap transition-all min-h-[44px] ${
                  viewMode === mode
                    ? 'bg-primary text-white'
                    : 'bg-white/10 text-white/60 hover:bg-white/20'
                }`}
              >
                {mode.charAt(0).toUpperCase() + mode.slice(1)}
              </button>
            ))}
          </div>

          {/* Navigation */}
          {viewMode !== 'list' && (
            <div className="mb-6 flex items-center justify-between">
              <button
                onClick={viewMode === 'month' ? previousMonth : viewMode === 'week' ? previousWeek : previousDay}
                className="w-11 h-11 rounded-full bg-white/10 hover:bg-white/20 flex items-center justify-center text-white transition-colors"
              >
                ←
              </button>
              <div className="flex items-center gap-3">
                <h2 className="text-xl font-bold text-white">
                  {viewMode === 'month' && monthName}
                  {viewMode === 'week' && `Week of ${formatDate(weekDates[0])}`}
                  {viewMode === 'day' && formatDate(currentDate)}
                </h2>
                <button
                  onClick={goToToday}
                  className="px-3 py-1.5 bg-white/10 hover:bg-white/20 rounded-full text-white text-sm font-medium transition-colors"
                >
                  Today
                </button>
              </div>
              <button
                onClick={viewMode === 'month' ? nextMonth : viewMode === 'week' ? nextWeek : nextDay}
                className="w-11 h-11 rounded-full bg-white/10 hover:bg-white/20 flex items-center justify-center text-white transition-colors"
              >
                →
              </button>
            </div>
          )}

          {/* Month View */}
          {viewMode === 'month' && (
            <div className="bg-white/5 backdrop-blur-md rounded-2xl p-4 border-2 border-white/20 mb-6">
              {/* Weekday Headers */}
              <div className="grid grid-cols-7 gap-2 mb-3">
                {['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((day) => (
                  <div key={day} className="text-center text-white font-bold text-sm py-2">
                    {day}
                  </div>
                ))}
              </div>

              {/* Calendar Grid */}
              <div className="grid grid-cols-7 gap-2">
                {getDaysInMonth(currentDate).map((day, index) => {
                  if (!day) {
                    return <div key={`empty-${index}`} className="aspect-square" />;
                  }

                  const dayEvents = getEventsForDate(day);
                  const isCurrentDay = isToday(day);

                  return (
                    <motion.button
                      key={day.toISOString()}
                      onClick={() => {
                        setSelectedDate(day);
                        if (dayEvents.length > 0) {
                          setViewMode('list');
                        }
                      }}
                      whileTap={{ scale: 0.95 }}
                      className={`aspect-square rounded-xl p-2 transition-all relative border-2 min-h-[44px] ${
                        isCurrentDay
                          ? 'bg-primary border-primary shadow-lg shadow-primary/50'
                          : dayEvents.length > 0
                          ? 'bg-white/20 border-white/30 hover:bg-white/30'
                          : 'bg-white/5 border-white/10 hover:bg-white/15 hover:border-white/20'
                      }`}
                    >
                      <span
                        className={`text-base font-bold block ${
                          isCurrentDay ? 'text-white' : 'text-white'
                        }`}
                      >
                        {day.getDate()}
                      </span>
                      {dayEvents.length > 0 && (
                        <div className="absolute bottom-1.5 left-1/2 -translate-x-1/2 flex gap-1">
                          {dayEvents.slice(0, 3).map((event, idx) => (
                            <div
                              key={idx}
                              className={`w-1.5 h-1.5 rounded-full ${
                                isCurrentDay ? 'bg-white' : 'bg-primary'
                              }`}
                            />
                          ))}
                        </div>
                      )}
                    </motion.button>
                  );
                })}
              </div>
            </div>
          )}

          {/* Week View */}
          {viewMode === 'week' && (
            <div className="bg-white/5 backdrop-blur-md rounded-2xl p-4 border-2 border-white/20 mb-6">
              {/* Week Header */}
              <div className="grid grid-cols-8 gap-2 mb-4">
                <div className="text-white/60 text-xs font-semibold py-2"></div>
                {weekDates.map((date) => (
                  <div
                    key={date.toISOString()}
                    className={`text-center ${
                      isToday(date) ? 'text-primary font-bold' : 'text-white'
                    }`}
                  >
                    <div className="text-xs font-semibold">{formatDayOfWeek(date)}</div>
                    <div className={`text-lg font-bold ${isToday(date) ? 'bg-primary rounded-full w-8 h-8 flex items-center justify-center mx-auto' : ''}`}>
                      {date.getDate()}
                    </div>
                  </div>
                ))}
              </div>

              {/* Time Grid */}
              <div className="relative overflow-auto max-h-[500px]">
                {timeSlots.map((slot) => {
                  const currentHour = getCurrentHour();
                  const isCurrentTime = isToday(currentDate) && slot.hour === currentHour;

                  return (
                    <div key={slot.hour} className="grid grid-cols-8 gap-2 border-t border-white/10">
                      {/* Time Label */}
                      <div className="text-white/60 text-xs py-3 pr-2 text-right">
                        {slot.label}
                      </div>

                      {/* Day Columns */}
                      {weekDates.map((date) => {
                        const dayEvents = getEventsForDate(date).filter(
                          (e) => getEventPosition(e) === slot.hour
                        );

                        return (
                          <button
                            key={`${date.toISOString()}-${slot.hour}`}
                            onClick={() => {
                              handleAddEvent(date, slot.hour);
                            }}
                            className={`min-h-[60px] p-1 rounded-lg transition-colors relative ${
                              isCurrentTime && isSameDay(date, new Date())
                                ? 'bg-primary/10 border border-primary/50'
                                : 'hover:bg-white/5'
                            }`}
                          >
                            {dayEvents.map((event) => (
                              <motion.div
                                key={event.id}
                                onClick={(e) => {
                                  e.stopPropagation();
                                  handleEditEvent(event);
                                }}
                                whileTap={{ scale: 0.98 }}
                                className={`${getEventColor(event.type)} rounded-lg p-1.5 mb-1 text-left border cursor-pointer`}
                              >
                                <div className="flex items-center gap-1">
                                  <span className="text-xs">{getEventIcon(event.type)}</span>
                                  <span className="text-xs font-semibold truncate">{event.title}</span>
                                </div>
                                {event.time && (
                                  <div className="text-[10px] opacity-80">{event.time}</div>
                                )}
                              </motion.div>
                            ))}
                          </button>
                        );
                      })}
                    </div>
                  );
                })}
              </div>
            </div>
          )}

          {/* Day View */}
          {viewMode === 'day' && (
            <div className="bg-white/5 backdrop-blur-md rounded-2xl p-4 border-2 border-white/20 mb-6">
              {/* Day Header */}
              <div className="text-center mb-4">
                <div className="text-white/60 text-sm font-semibold">
                  {formatDayOfWeek(currentDate)}
                </div>
                <div className={`text-3xl font-bold ${isToday(currentDate) ? 'text-primary' : 'text-white'}`}>
                  {currentDate.getDate()}
                </div>
              </div>

              {/* Time Grid */}
              <div className="relative overflow-auto max-h-[600px]">
                {timeSlots.map((slot) => {
                  const currentHour = getCurrentHour();
                  const isCurrentTime = isToday(currentDate) && slot.hour === currentHour;
                  const slotEvents = getEventsForDate(currentDate).filter(
                    (e) => getEventPosition(e) === slot.hour
                  );

                  return (
                    <button
                      key={slot.hour}
                      onClick={() => {
                        handleAddEvent(currentDate, slot.hour);
                      }}
                      className={`w-full border-t border-white/10 p-4 transition-all text-left relative ${
                        isCurrentTime
                          ? 'bg-primary/10 border-l-4 border-l-primary'
                          : 'hover:bg-white/5'
                      }`}
                    >
                      <div className="flex gap-4">
                        {/* Time */}
                        <div className={`text-sm font-semibold w-20 flex-shrink-0 ${
                          isCurrentTime ? 'text-primary' : 'text-white/60'
                        }`}>
                          {slot.label}
                          {isCurrentTime && (
                            <div className="text-[10px] text-primary/80 mt-0.5">Now</div>
                          )}
                        </div>

                        {/* Events */}
                        <div className="flex-1 space-y-2">
                          {slotEvents.length === 0 ? (
                            <div className="text-white/30 text-sm">No events</div>
                          ) : (
                            slotEvents.map((event) => (
                              <motion.div
                                key={event.id}
                                onClick={(e) => {
                                  e.stopPropagation();
                                  handleEditEvent(event);
                                }}
                                whileTap={{ scale: 0.98 }}
                                className={`${getEventColor(event.type)} rounded-xl p-3 border cursor-pointer`}
                              >
                                <div className="flex items-center gap-2 mb-1">
                                  <span className="text-xl">{getEventIcon(event.type)}</span>
                                  <span className="font-semibold">{event.title}</span>
                                </div>
                                {event.description && (
                                  <p className="text-sm opacity-80 mb-2">{event.description}</p>
                                )}
                                <div className="flex flex-wrap gap-2 text-xs opacity-70">
                                  {event.time && <span>⏰ {event.time}</span>}
                                  {event.location && <span>📍 {event.location}</span>}
                                </div>
                              </motion.div>
                            ))
                          )}
                        </div>
                      </div>
                    </button>
                  );
                })}
              </div>
            </div>
          )}

          {/* List View / Upcoming Events */}
          {(viewMode === 'list' || viewMode === 'month') && (
            <div className="space-y-4">
              <h3 className="text-xl font-bold text-white mb-4">
                {selectedDate ? `Events for ${formatDate(selectedDate)}` : 'Upcoming Events'}
              </h3>

              {(selectedDate ? getEventsForDate(selectedDate) : upcomingEvents).length === 0 ? (
                <div className="glass-strong rounded-2xl p-8 border border-white/10 text-center">
                  <p className="text-white/60 text-lg mb-2">📅</p>
                  <p className="text-white/60">No events scheduled</p>
                  <button
                    onClick={() => setShowEventModal(true)}
                    className="mt-4 px-4 py-2 bg-primary/20 hover:bg-primary/30 rounded-full text-primary font-semibold transition-colors"
                  >
                    Add your first event
                  </button>
                </div>
              ) : (
                (selectedDate ? getEventsForDate(selectedDate) : upcomingEvents).map((event) => (
                  <motion.button
                    key={event.id}
                    onClick={() => handleEditEvent(event)}
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    whileTap={{ scale: 0.98 }}
                    className="glass-strong rounded-2xl p-4 border border-white/10 hover:bg-white/5 transition-colors w-full text-left"
                  >
                    <div className="flex items-start gap-3">
                      <div
                        className={`w-12 h-12 rounded-xl flex items-center justify-center text-2xl ${getEventColor(
                          event.type
                        )} border flex-shrink-0`}
                      >
                        {getEventIcon(event.type)}
                      </div>
                      <div className="flex-1 min-w-0">
                        <div className="flex items-start justify-between gap-2 mb-1">
                          <h4 className="text-white font-semibold">{event.title}</h4>
                          <span className="text-white/40 text-xs whitespace-nowrap">✏️ Edit</span>
                        </div>
                        {event.description && (
                          <p className="text-white/60 text-sm mb-2 line-clamp-2">{event.description}</p>
                        )}
                        <div className="flex flex-wrap gap-2 text-xs">
                          <span className="text-white/60">
                            📅 {formatDate(new Date(event.date))}
                          </span>
                          {event.time && (
                            <span className="text-white/60">
                              ⏰ {formatTime(event.time)}
                            </span>
                          )}
                          {event.location && (
                            <span className="text-white/60 truncate">
                              📍 {event.location}
                            </span>
                          )}
                        </div>
                        {event.propertyAddress && (
                          <div
                            onClick={(e) => {
                              e.stopPropagation();
                              router.push(`/scout/${event.propertyId}`);
                            }}
                            className="mt-2 text-primary text-sm font-medium hover:underline cursor-pointer inline-block"
                          >
                            View Property →
                          </div>
                        )}
                        {event.type === 'deadline' && event.location === 'Vault' && (
                          <div
                            onClick={(e) => {
                              e.stopPropagation();
                              router.push('/vault');
                            }}
                            className="mt-2 text-red-400 text-sm font-medium hover:underline cursor-pointer inline-block"
                          >
                            View in Vault →
                          </div>
                        )}
                      </div>
                    </div>
                  </motion.button>
                ))
              )}
            </div>
          )}
        </motion.div>
      </div>

      {/* Event Modal */}
      <EventModal
        isOpen={showEventModal}
        onClose={() => {
          setShowEventModal(false);
          setSelectedEvent(null);
          setSelectedDate(null);
          setPresetTime(undefined);
        }}
        onSave={handleSaveEvent}
        onDelete={handleDeleteEvent}
        event={selectedEvent}
        presetDate={selectedDate || undefined}
        presetTime={presetTime}
      />

      {/* Bottom Navigation */}
      <BottomNav />
    </main>
  );
}
