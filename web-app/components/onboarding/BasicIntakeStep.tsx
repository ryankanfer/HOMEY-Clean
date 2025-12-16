'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { ArrowRight } from 'lucide-react';
import { OnboardingData } from '@/app/onboarding/page';

interface BasicIntakeStepProps {
  data: OnboardingData;
  onNext: (data: Partial<OnboardingData>) => void;
  isSaving: boolean;
}

export default function BasicIntakeStep({ data, onNext, isSaving }: BasicIntakeStepProps) {
  const [step, setStep] = useState(0);
  const [form, setForm] = useState({
    firstName: data.firstName || '',
    lastName: data.lastName || '',
    phone: data.phone || ''
  });

  const handleNameSubmit = () => {
    if (form.firstName && form.lastName) setStep(1);
  };

  const formatPhone = (value: string) => {
    const digits = value.replace(/\D/g, '');
    if (digits.length <= 3) return digits;
    if (digits.length <= 6) return `(${digits.slice(0, 3)}) ${digits.slice(3)}`;
    return `(${digits.slice(0, 3)}) ${digits.slice(3, 6)}-${digits.slice(6, 10)}`;
  };

  const handlePhoneChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const formatted = formatPhone(e.target.value);
    setForm({ ...form, phone: formatted });
  };

  const handleComplete = () => {
    onNext({
      firstName: form.firstName,
      lastName: form.lastName,
      phone: form.phone,
      fullName: `${form.firstName} ${form.lastName}`,
      notificationsEnabled: true
    });
  };

  return (
    <div className="max-w-md w-full mx-auto px-4">
      <div className="mb-12">
        <h1 className="text-4xl font-serif text-white mb-2" style={{ fontFamily: 'Playfair Display, serif' }}>
          {step === 0 ? "Let's get introduced." : `Hi, ${form.firstName}.`}
        </h1>
        <p className="text-white/50">
          {step === 0 ? "We like to know who we're welcoming." : "How can we reach you regarding your search?"}
        </p>
      </div>

      <AnimatePresence mode="wait">
        {step === 0 ? (
          <motion.div
            key="name"
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -20 }}
            className="space-y-6 relative"
          >
            <input
              autoFocus
              value={form.firstName}
              onChange={e => setForm({ ...form, firstName: e.target.value })}
              className="w-full bg-transparent border-b border-white/20 p-4 text-3xl text-white outline-none focus:border-white transition-colors placeholder:text-white/10 font-serif"
              placeholder="First Name"
              style={{ fontFamily: 'Playfair Display, serif' }}
            />
            <input
              value={form.lastName}
              onChange={e => setForm({ ...form, lastName: e.target.value })}
              onKeyDown={e => e.key === 'Enter' && handleNameSubmit()}
              className="w-full bg-transparent border-b border-white/20 p-4 text-3xl text-white outline-none focus:border-white transition-colors placeholder:text-white/10 font-serif"
              placeholder="Last Name"
              style={{ fontFamily: 'Playfair Display, serif' }}
            />
            {form.firstName && form.lastName && (
              <motion.button
                initial={{ opacity: 0, scale: 0.8 }}
                animate={{ opacity: 1, scale: 1 }}
                onClick={handleNameSubmit}
                className="absolute -right-4 top-1/2 -translate-y-1/2 w-16 h-16 rounded-full bg-white text-black flex items-center justify-center hover:scale-110 transition-transform shadow-lg"
              >
                <ArrowRight />
              </motion.button>
            )}
          </motion.div>
        ) : (
          <motion.div
            key="phone"
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            className="space-y-6"
          >
            <input
              autoFocus
              value={form.phone}
              onChange={handlePhoneChange}
              onKeyDown={e => e.key === 'Enter' && form.phone.length >= 14 && handleComplete()}
              className="w-full bg-transparent border-b border-white/20 p-4 text-3xl text-white outline-none focus:border-white transition-colors placeholder:text-white/10 font-mono"
              placeholder="(555) 000-0000"
              inputMode="numeric"
            />
            <button
              onClick={handleComplete}
              disabled={form.phone.length < 14 || isSaving}
              className="w-full mt-8 py-5 bg-white text-black rounded-2xl font-bold text-lg disabled:opacity-50 disabled:cursor-not-allowed transition-all hover:scale-[1.02]"
            >
              {isSaving ? 'Saving...' : 'Complete Registration'}
            </button>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
