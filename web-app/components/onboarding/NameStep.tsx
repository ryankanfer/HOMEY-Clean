'use client';

import { useState } from 'react';
import { motion } from 'framer-motion';
import { OnboardingData } from '@/app/onboarding/page';
import { User, Phone } from 'lucide-react';

interface NameStepProps {
  data: OnboardingData;
  onNext: (data: Partial<OnboardingData>) => void;
  isSaving: boolean;
}

export default function NameStep({ data, onNext, isSaving }: NameStepProps) {
  const [firstName, setFirstName] = useState(data.fullName?.split(' ')[0] || '');
  const [lastName, setLastName] = useState(data.fullName?.split(' ').slice(1).join(' ') || '');
  const [phone, setPhone] = useState(data.phone || '');
  const [errors, setErrors] = useState<{ [key: string]: string }>({});

  const formatPhone = (value: string) => {
    // Remove all non-digits
    const digits = value.replace(/\D/g, '');

    // Format as (XXX) XXX-XXXX
    if (digits.length <= 3) {
      return digits;
    } else if (digits.length <= 6) {
      return `(${digits.slice(0, 3)}) ${digits.slice(3)}`;
    } else {
      return `(${digits.slice(0, 3)}) ${digits.slice(3, 6)}-${digits.slice(6, 10)}`;
    }
  };

  const handlePhoneChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const formatted = formatPhone(e.target.value);
    setPhone(formatted);
    if (errors.phone) {
      setErrors({ ...errors, phone: '' });
    }
  };

  const validateForm = () => {
    const newErrors: { [key: string]: string } = {};

    if (!firstName.trim()) {
      newErrors.firstName = 'First name is required';
    }

    if (!lastName.trim()) {
      newErrors.lastName = 'Last name is required';
    }

    if (!phone.trim()) {
      newErrors.phone = 'Phone number is required';
    } else {
      const digits = phone.replace(/\D/g, '');
      if (digits.length !== 10) {
        newErrors.phone = 'Please enter a valid 10-digit phone number';
      }
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleContinue = () => {
    if (!validateForm()) return;

    const fullName = `${firstName.trim()} ${lastName.trim()}`;
    const displayName = firstName.trim();

    onNext({
      fullName,
      displayName,
      phone: phone.replace(/\D/g, ''), // Store digits only
    });
  };

  return (
    <motion.div
      initial={{ opacity: 0, x: 20 }}
      animate={{ opacity: 1, x: 0 }}
      exit={{ opacity: 0, x: -20 }}
      className="w-full max-w-md mx-auto"
    >
      <div className="glass-strong rounded-3xl p-8 md:p-10 border border-white/10">
        {/* Header */}
        <div className="text-center mb-8">
          <motion.div
            initial={{ scale: 0.8, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            transition={{ delay: 0.1 }}
            className="w-16 h-16 bg-gradient-to-br from-purple-500 to-pink-500 rounded-2xl flex items-center justify-center mx-auto mb-4"
          >
            <User className="w-8 h-8 text-white" />
          </motion.div>

          <h2 className="text-3xl font-bold text-white mb-2">
            Let's get to know you
          </h2>
          <p className="text-white/60">
            This helps us personalize your experience
          </p>
        </div>

        {/* Form */}
        <div className="space-y-5">
          {/* First Name */}
          <div>
            <label className="block text-sm font-medium text-white/80 mb-2">
              First Name
            </label>
            <input
              type="text"
              value={firstName}
              onChange={(e) => {
                setFirstName(e.target.value);
                if (errors.firstName) {
                  setErrors({ ...errors, firstName: '' });
                }
              }}
              placeholder="Enter your first name"
              className={`w-full px-4 py-3.5 bg-white/5 border ${
                errors.firstName ? 'border-red-500' : 'border-white/10'
              } rounded-xl text-white placeholder-white/40 focus:outline-none focus:border-purple-500 transition-colors`}
              disabled={isSaving}
            />
            {errors.firstName && (
              <p className="text-red-400 text-sm mt-1">{errors.firstName}</p>
            )}
          </div>

          {/* Last Name */}
          <div>
            <label className="block text-sm font-medium text-white/80 mb-2">
              Last Name
            </label>
            <input
              type="text"
              value={lastName}
              onChange={(e) => {
                setLastName(e.target.value);
                if (errors.lastName) {
                  setErrors({ ...errors, lastName: '' });
                }
              }}
              placeholder="Enter your last name"
              className={`w-full px-4 py-3.5 bg-white/5 border ${
                errors.lastName ? 'border-red-500' : 'border-white/10'
              } rounded-xl text-white placeholder-white/40 focus:outline-none focus:border-purple-500 transition-colors`}
              disabled={isSaving}
            />
            {errors.lastName && (
              <p className="text-red-400 text-sm mt-1">{errors.lastName}</p>
            )}
          </div>

          {/* Phone Number */}
          <div>
            <label className="block text-sm font-medium text-white/80 mb-2">
              Phone Number
            </label>
            <div className="relative">
              <div className="absolute left-4 top-1/2 -translate-y-1/2">
                <Phone className="w-5 h-5 text-white/40" />
              </div>
              <input
                type="tel"
                value={phone}
                onChange={handlePhoneChange}
                placeholder="(555) 555-5555"
                className={`w-full pl-12 pr-4 py-3.5 bg-white/5 border ${
                  errors.phone ? 'border-red-500' : 'border-white/10'
                } rounded-xl text-white placeholder-white/40 focus:outline-none focus:border-purple-500 transition-colors`}
                disabled={isSaving}
              />
            </div>
            {errors.phone && (
              <p className="text-red-400 text-sm mt-1">{errors.phone}</p>
            )}
          </div>

          <p className="text-xs text-white/40 text-center mt-2">
            We'll use this to send you important updates about your home search
          </p>
        </div>

        {/* Continue Button */}
        <button
          onClick={handleContinue}
          disabled={isSaving}
          className="w-full mt-8 px-6 py-4 bg-gradient-to-r from-purple-500 to-pink-500 text-white rounded-xl font-semibold hover:shadow-lg hover:shadow-purple-500/30 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {isSaving ? 'Saving...' : 'Continue'}
        </button>
      </div>
    </motion.div>
  );
}
