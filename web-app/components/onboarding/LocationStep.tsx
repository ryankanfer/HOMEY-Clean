'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { OnboardingData } from '@/app/onboarding/page';
import { MapPin } from 'lucide-react';
import { db } from '@/lib/supabase';

interface LocationStepProps {
  data: OnboardingData;
  onNext: (data: Partial<OnboardingData>) => void;
  isSaving: boolean;
}

export default function LocationStep({ data, onNext, isSaving }: LocationStepProps) {
  const [selected, setSelected] = useState<string | null>(
    data.location || null
  );
  const [showCityRequest, setShowCityRequest] = useState(false);
  const [requestedCity, setRequestedCity] = useState('');
  const [isSubmittingRequest, setIsSubmittingRequest] = useState(false);
  const [requestSubmitted, setRequestSubmitted] = useState(false);

  const cities = [
    {
      id: 'new_york_city',
      name: 'New York City',
      icon: '🗽',
      gradient: 'from-blue-500 to-cyan-500',
    },
    {
      id: 'chicago',
      name: 'Chicago',
      icon: '🌆',
      gradient: 'from-red-500 to-orange-500',
    },
    {
      id: 'los_angeles',
      name: 'Los Angeles',
      icon: '🌴',
      gradient: 'from-yellow-500 to-pink-500',
    },
    {
      id: 'miami',
      name: 'Miami',
      icon: '🏖️',
      gradient: 'from-pink-500 to-purple-500',
    },
  ];

  const handleSelect = (cityId: string) => {
    setSelected(cityId);
  };

  const handleContinue = () => {
    if (selected) {
      onNext({
        location: selected as 'new_york_city' | 'chicago' | 'los_angeles' | 'miami',
      });
    }
  };

  const handleCityRequest = async () => {
    if (!requestedCity.trim()) return;

    setIsSubmittingRequest(true);

    try {
      // Store city request in a feedback/requests table for admin to review
      // For now, we'll just log it - you can create a Supabase table later
      const { error } = await db.supabase
        .from('city_requests')
        .insert({
          requested_city: requestedCity,
          created_at: new Date().toISOString(),
        });

      if (error) {
        console.error('Error submitting city request:', error);
      }

      setRequestSubmitted(true);
      setTimeout(() => {
        setShowCityRequest(false);
        setRequestSubmitted(false);
        setRequestedCity('');
      }, 2000);
    } catch (err) {
      console.error('Error:', err);
    } finally {
      setIsSubmittingRequest(false);
    }
  };

  return (
    <motion.div
      initial={{ opacity: 0, x: 50 }}
      animate={{ opacity: 1, x: 0 }}
      exit={{ opacity: 0, x: -50 }}
      transition={{ duration: 0.5 }}
      className="w-full max-w-3xl mx-auto"
    >
      {/* Question */}
      <motion.h2
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.1, duration: 0.5 }}
        className="text-4xl md:text-5xl font-light text-white text-center mb-4"
        style={{ fontFamily: 'Playfair Display, serif' }}
      >
        Where are you looking?
      </motion.h2>

      <motion.p
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.2, duration: 0.5 }}
        className="text-white/60 text-center mb-12 text-lg"
      >
        Choose your city
      </motion.p>

      {/* City Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-8">
        {cities.map((city, index) => (
          <motion.button
            key={city.id}
            initial={{ y: 20, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ delay: 0.3 + index * 0.1, duration: 0.5 }}
            onClick={() => handleSelect(city.id)}
            className={`relative p-8 rounded-3xl text-left transition-all transform overflow-hidden ${
              selected === city.id
                ? 'scale-105 shadow-2xl'
                : 'glass-strong hover:bg-white/10'
            }`}
          >
            {/* Gradient Background (when selected) */}
            {selected === city.id && (
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                className={`absolute inset-0 bg-gradient-to-br ${city.gradient} opacity-90`}
              />
            )}

            {/* Content */}
            <div className="relative z-10">
              <div className="text-6xl mb-3">{city.icon}</div>
              <h3 className="text-2xl font-bold text-white mb-1">
                {city.name}
              </h3>
              {selected === city.id && (
                <motion.div
                  initial={{ scale: 0, opacity: 0 }}
                  animate={{ scale: 1, opacity: 1 }}
                  transition={{ delay: 0.1 }}
                  className="absolute top-8 right-8 text-3xl"
                >
                  ✓
                </motion.div>
              )}
            </div>
          </motion.button>
        ))}
      </div>

      {/* Continue Button */}
      {selected && (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.3 }}
          className="text-center"
        >
          <button
            onClick={handleContinue}
            disabled={isSaving}
            className="px-10 py-4 bg-white text-black rounded-full font-bold text-lg hover:shadow-2xl hover:shadow-white/20 transition-all transform hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {isSaving ? 'Saving...' : 'Continue →'}
          </button>
        </motion.div>
      )}

      {/* Don't See Your City? */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 0.8 }}
        className="text-center mt-8"
      >
        <button
          onClick={() => setShowCityRequest(true)}
          className="text-white/60 hover:text-white transition-colors text-sm font-medium flex items-center gap-2 mx-auto group"
        >
          <MapPin className="w-4 h-4 group-hover:scale-110 transition-transform" />
          Don't see your city? Let us know where Homey needs to go next!
        </button>
      </motion.div>

      {/* City Request Modal */}
      <AnimatePresence>
        {showCityRequest && (
          <>
            {/* Backdrop */}
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="fixed inset-0 bg-black/60 backdrop-blur-sm z-[100]"
              onClick={() => !isSubmittingRequest && setShowCityRequest(false)}
            />

            {/* Modal */}
            <motion.div
              initial={{ opacity: 0, scale: 0.9, y: 20 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.9, y: 20 }}
              className="fixed inset-0 z-[101] flex items-center justify-center p-4"
            >
              <div className="glass-strong rounded-2xl p-6 max-w-md w-full border border-primary/30 shadow-2xl">
                {!requestSubmitted ? (
                  <>
                    <div className="text-center mb-6">
                      <div className="text-4xl mb-3">📍</div>
                      <h3 className="text-2xl font-bold text-white mb-2">
                        Where should we go next?
                      </h3>
                      <p className="text-white/70 text-sm">
                        Help us expand Homey to your city! We'll notify our team.
                      </p>
                    </div>

                    <input
                      type="text"
                      placeholder="Enter city name..."
                      value={requestedCity}
                      onChange={(e) => setRequestedCity(e.target.value)}
                      disabled={isSubmittingRequest}
                      className="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white placeholder:text-white/40 focus:outline-none focus:border-primary/50 focus:bg-white/15 transition-all mb-4"
                      autoFocus
                    />

                    <div className="flex gap-3">
                      <button
                        onClick={() => setShowCityRequest(false)}
                        disabled={isSubmittingRequest}
                        className="flex-1 py-3 bg-white/10 hover:bg-white/20 text-white rounded-xl font-semibold transition-all disabled:opacity-50 disabled:cursor-not-allowed"
                      >
                        Cancel
                      </button>
                      <button
                        onClick={handleCityRequest}
                        disabled={!requestedCity.trim() || isSubmittingRequest}
                        className="flex-1 py-3 bg-gradient-to-r from-primary to-purple-500 text-white rounded-xl font-semibold hover:shadow-lg hover:shadow-primary/50 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
                      >
                        {isSubmittingRequest ? 'Sending...' : 'Submit'}
                      </button>
                    </div>
                  </>
                ) : (
                  <div className="text-center py-8">
                    <div className="text-6xl mb-4">✅</div>
                    <h3 className="text-2xl font-bold text-white mb-2">
                      Thanks for the feedback!
                    </h3>
                    <p className="text-white/70">
                      We'll let you know when Homey arrives in {requestedCity}
                    </p>
                  </div>
                )}
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </motion.div>
  );
}
