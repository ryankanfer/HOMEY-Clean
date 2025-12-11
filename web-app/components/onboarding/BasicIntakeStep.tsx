'use client';

import { useState } from 'react';
import { motion } from 'framer-motion';
import { User, Phone, Bell, BellOff } from 'lucide-react';

interface BasicIntakeStepProps {
  data: {
    firstName?: string;
    lastName?: string;
    phone?: string;
    notificationsEnabled?: boolean;
  };
  onNext: (data: any) => void;
}

export default function BasicIntakeStep({ data: initialData, onNext }: BasicIntakeStepProps) {
  const [formData, setFormData] = useState({
    firstName: initialData?.firstName || '',
    lastName: initialData?.lastName || '',
    phone: initialData?.phone || '',
    notificationsEnabled: initialData?.notificationsEnabled ?? true,
  });
  const [errors, setErrors] = useState<Record<string, string>>({});

  const updateField = (field: string, value: any) => {
    setFormData(prev => ({ ...prev, [field]: value }));
  };

  const validatePhone = (phone: string) => {
    // Remove all non-digit characters
    const cleaned = phone.replace(/\D/g, '');
    return cleaned.length === 10 || cleaned.length === 11;
  };

  const formatPhone = (value: string) => {
    // Remove all non-digit characters
    const cleaned = value.replace(/\D/g, '');

    // Format as (XXX) XXX-XXXX
    if (cleaned.length <= 3) {
      return cleaned;
    } else if (cleaned.length <= 6) {
      return `(${cleaned.slice(0, 3)}) ${cleaned.slice(3)}`;
    } else {
      return `(${cleaned.slice(0, 3)}) ${cleaned.slice(3, 6)}-${cleaned.slice(6, 10)}`;
    }
  };

  const handlePhoneChange = (value: string) => {
    const formatted = formatPhone(value);
    updateField('phone', formatted);

    if (errors.phone) {
      setErrors(prev => ({ ...prev, phone: '' }));
    }
  };

  const handleNext = () => {
    const newErrors: Record<string, string> = {};

    if (!formData.firstName?.trim()) {
      newErrors.firstName = 'First name is required';
    }
    if (!formData.lastName?.trim()) {
      newErrors.lastName = 'Last name is required';
    }
    if (!formData.phone?.trim()) {
      newErrors.phone = 'Phone number is required';
    } else if (!validatePhone(formData.phone)) {
      newErrors.phone = 'Please enter a valid 10-digit phone number';
    }

    if (Object.keys(newErrors).length > 0) {
      setErrors(newErrors);
      return;
    }

    // Pass form data to onboarding flow
    onNext(formData);
  };

  const canContinue = formData.firstName && formData.lastName && formData.phone;

  return (
    <div className="relative min-h-screen flex flex-col items-center justify-center px-6 py-12">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="text-center mb-12 max-w-2xl"
      >
        <h1 className="text-4xl md:text-5xl font-bold text-white mb-4">
          Let's get to know you
        </h1>
        <p className="text-white/60 text-lg">
          We'll use this to personalize your HOMEY experience
        </p>
      </motion.div>

      {/* Form Card */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.1 }}
        className="w-full max-w-md bg-gradient-to-br from-slate-900/95 to-slate-800/95 backdrop-blur-xl border border-white/10 rounded-3xl p-8 space-y-6"
      >
        {/* First Name */}
        <div>
          <label className="block text-white font-medium mb-2">
            First Name <span className="text-pink-500">*</span>
          </label>
          <div className="relative">
            <User className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-white/40" />
            <input
              type="text"
              value={formData.firstName}
              onChange={(e) => {
                updateField('firstName', e.target.value);
                if (errors.firstName) setErrors(prev => ({ ...prev, firstName: '' }));
              }}
              placeholder="Enter your first name"
              className={`w-full pl-12 pr-4 py-4 bg-white/5 border ${
                errors.firstName ? 'border-red-500' : 'border-white/10'
              } rounded-xl text-white placeholder-white/40 focus:outline-none focus:ring-2 focus:ring-purple-500 transition-all`}
            />
          </div>
          {errors.firstName && (
            <p className="mt-2 text-red-400 text-sm">{errors.firstName}</p>
          )}
        </div>

        {/* Last Name */}
        <div>
          <label className="block text-white font-medium mb-2">
            Last Name <span className="text-pink-500">*</span>
          </label>
          <div className="relative">
            <User className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-white/40" />
            <input
              type="text"
              value={formData.lastName}
              onChange={(e) => {
                updateField('lastName', e.target.value);
                if (errors.lastName) setErrors(prev => ({ ...prev, lastName: '' }));
              }}
              placeholder="Enter your last name"
              className={`w-full pl-12 pr-4 py-4 bg-white/5 border ${
                errors.lastName ? 'border-red-500' : 'border-white/10'
              } rounded-xl text-white placeholder-white/40 focus:outline-none focus:ring-2 focus:ring-purple-500 transition-all`}
            />
          </div>
          {errors.lastName && (
            <p className="mt-2 text-red-400 text-sm">{errors.lastName}</p>
          )}
        </div>

        {/* Phone Number */}
        <div>
          <label className="block text-white font-medium mb-2">
            Phone Number <span className="text-pink-500">*</span>
          </label>
          <div className="relative">
            <Phone className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-white/40" />
            <input
              type="tel"
              value={formData.phone}
              onChange={(e) => handlePhoneChange(e.target.value)}
              placeholder="(555) 123-4567"
              maxLength={14}
              className={`w-full pl-12 pr-4 py-4 bg-white/5 border ${
                errors.phone ? 'border-red-500' : 'border-white/10'
              } rounded-xl text-white placeholder-white/40 focus:outline-none focus:ring-2 focus:ring-purple-500 transition-all`}
            />
          </div>
          {errors.phone && (
            <p className="mt-2 text-red-400 text-sm">{errors.phone}</p>
          )}
        </div>

        {/* Notifications Toggle */}
        <div className="pt-4">
          <div className="flex items-center justify-between">
            <div className="flex-1">
              <label className="block text-white font-medium mb-1">
                Enable Notifications
              </label>
              <p className="text-white/50 text-sm">
                Get alerts for new matches and updates
              </p>
            </div>
            <button
              onClick={() => updateField('notificationsEnabled', !formData.notificationsEnabled)}
              className={`relative ml-4 w-16 h-9 rounded-full transition-all ${
                formData.notificationsEnabled
                  ? 'bg-gradient-to-r from-purple-500 to-pink-500'
                  : 'bg-white/10'
              }`}
            >
              <motion.div
                animate={{ x: formData.notificationsEnabled ? 28 : 4 }}
                transition={{ type: 'spring', stiffness: 500, damping: 30 }}
                className="absolute top-1 w-7 h-7 bg-white rounded-full shadow-lg flex items-center justify-center"
              >
                {formData.notificationsEnabled ? (
                  <Bell className="w-4 h-4 text-purple-500" />
                ) : (
                  <BellOff className="w-4 h-4 text-gray-400" />
                )}
              </motion.div>
            </button>
          </div>
        </div>
      </motion.div>

      {/* Navigation */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.2 }}
        className="w-full max-w-md mt-8"
      >
        <button
          onClick={handleNext}
          disabled={!canContinue}
          className={`w-full px-6 py-4 rounded-2xl font-bold transition-all ${
            canContinue
              ? 'bg-gradient-to-r from-purple-500 to-pink-500 text-white hover:shadow-lg hover:shadow-purple-500/50 active:scale-95'
              : 'bg-white/5 text-white/30 cursor-not-allowed'
          }`}
        >
          Continue
        </button>
      </motion.div>

      {/* Privacy Note */}
      <motion.p
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 0.3 }}
        className="text-white/40 text-sm text-center mt-6 max-w-md"
      >
        Your information is encrypted and will never be sold to third parties.
      </motion.p>
    </div>
  );
}
