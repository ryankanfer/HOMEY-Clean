'use client';

import { useState } from 'react';
import { motion } from 'framer-motion';
import { Unlock, Home } from 'lucide-react';
import { OnboardingData } from '@/app/onboarding/page';

interface UserTypeStepProps {
  data: OnboardingData;
  onNext: (data: Partial<OnboardingData>) => void;
  isSaving: boolean;
}

export default function UserTypeStep({ data, onNext, isSaving }: UserTypeStepProps) {
  const [choice, setChoice] = useState<'renter' | 'buyer' | null>(null);

  const handleInteraction = (type: 'renter' | 'buyer') => {
    setChoice(type);
    setTimeout(() => {
      onNext({ userType: type });
    }, 800);
  };

  return (
    <div className="h-full w-full flex flex-col justify-between py-4 relative min-h-[600px]">
      <div className="text-center z-20">
        <h2 className="text-xs font-bold uppercase tracking-[0.3em] text-white/50 mb-4">The Threshold</h2>
        <h1 className="text-4xl font-serif text-white" style={{ fontFamily: 'Playfair Display, serif' }}>
          How will you enter?
        </h1>
      </div>

      <motion.div
        onClick={() => !isSaving && handleInteraction('renter')}
        className={`relative z-10 text-center cursor-pointer p-10 rounded-[3rem] border border-white/10 bg-gradient-to-b from-white/5 to-transparent hover:border-white/30 transition-all group ${choice === 'buyer' ? 'opacity-20 blur-sm' : 'opacity-100'}`}
        whileHover={{ scale: 1.02 }}
        whileTap={{ scale: 0.98 }}
      >
        <div className="w-16 h-16 rounded-full bg-white/10 flex items-center justify-center mx-auto mb-6 text-white group-hover:bg-white group-hover:text-black transition-colors">
          <Unlock size={24} />
        </div>
        <h2 className="text-xl uppercase tracking-[0.2em] font-medium text-white">Lease</h2>
      </motion.div>

      {/* GROWING PARTICLE VISUALIZER */}
      <div className="relative z-20 flex-1 flex items-center justify-center py-4">
        <div className="absolute h-full w-[1px] bg-gradient-to-b from-transparent via-white/10 to-transparent" />
        <motion.div
          className="w-4 h-4 bg-white rounded-full shadow-[0_0_30px_rgba(255,255,255,0.8)] z-30"
          initial={{ scale: 1 }}
          animate={{
            y: choice === 'renter' ? -150 : choice === 'buyer' ? 150 : 0,
            scale: choice ? 12 : 1,
            opacity: choice ? 0 : 1
          }}
          transition={{ duration: 0.6, ease: "easeInOut" }}
        />
      </div>

      <motion.div
        onClick={() => !isSaving && handleInteraction('buyer')}
        className={`relative z-10 text-center cursor-pointer p-10 rounded-[3rem] border border-white/10 bg-gradient-to-t from-white/5 to-transparent hover:border-white/30 transition-all group ${choice === 'renter' ? 'opacity-20 blur-sm' : 'opacity-100'}`}
        whileHover={{ scale: 1.02 }}
        whileTap={{ scale: 0.98 }}
      >
        <h2 className="text-xl uppercase tracking-[0.2em] font-medium text-white">Own</h2>
        <div className="w-16 h-16 rounded-full bg-white/10 flex items-center justify-center mx-auto mt-6 text-white group-hover:bg-white group-hover:text-black transition-colors">
          <Home size={24} />
        </div>
      </motion.div>

      <div className="text-center mt-8">
        <button
          onClick={() => !isSaving && onNext({ userType: 'browser' })}
          className="text-[10px] uppercase tracking-[0.2em] text-white/30 hover:text-white transition-colors border-b border-transparent hover:border-white pb-1"
        >
          Just Browsing
        </button>
      </div>
    </div>
  );
}
