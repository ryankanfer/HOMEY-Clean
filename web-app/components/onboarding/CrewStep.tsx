'use client';

import { useState } from 'react';
import { motion } from 'framer-motion';
import { OnboardingData } from '@/app/onboarding/page';

interface CrewStepProps {
  data: OnboardingData;
  onNext: (data: Partial<OnboardingData>) => void;
  isSaving: boolean;
}

export default function CrewStep({ data, onNext, isSaving }: CrewStepProps) {
  const [beds, setBeds] = useState(data.bedrooms || 1);
  const [baths, setBaths] = useState(data.bathrooms || 1);

  const Counter = ({ label, val, setVal }: any) => (
    <div className="mb-8">
      <div className="text-xs uppercase tracking-widest text-white/40 mb-4 text-center">{label}</div>
      <div className="flex items-center justify-center gap-4">
        {[0, 1, 2, 3, 4].map((num) => {
          const isSelected = val === num;
          const display = num === 0 && label === 'Bedrooms' ? 'Studio' : num === 4 ? '4+' : num;
          return (
            <motion.button
              key={num}
              onClick={() => setVal(num)}
              whileTap={{ scale: 0.9 }}
              animate={{
                backgroundColor: isSelected ? 'white' : 'transparent',
                color: isSelected ? 'black' : 'white',
                borderColor: isSelected ? 'white' : 'rgba(255,255,255,0.2)',
                scale: isSelected ? 1.1 : 1
              }}
              className={`w-14 h-14 rounded-full border flex items-center justify-center font-bold text-lg transition-all ${
                num === 0 && label === 'Bedrooms' ? 'text-[10px] w-16' : ''
              }`}
            >
              {display}
            </motion.button>
          );
        })}
      </div>
    </div>
  );

  return (
    <div className="max-w-md w-full mx-auto">
      <h1 className="text-3xl font-serif text-white mb-2 text-center" style={{ fontFamily: 'Playfair Display, serif' }}>
        Space.
      </h1>
      <p className="text-white/50 mb-12 text-center">How much room do you need?</p>
      <Counter label="Bedrooms" val={beds} setVal={setBeds} />
      <Counter label="Bathrooms" val={baths} setVal={setBaths} />
      <button
        onClick={() => onNext({ bedrooms: beds, bathrooms: baths })}
        disabled={isSaving}
        className="w-full mt-8 py-4 bg-white text-black rounded-xl font-bold hover:scale-[1.02] transition-transform disabled:opacity-50"
      >
        {isSaving ? 'Saving...' : 'Confirm Space'}
      </button>
    </div>
  );
}
