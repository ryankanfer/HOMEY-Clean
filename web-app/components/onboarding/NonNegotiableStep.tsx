'use client';

import { useState } from 'react';
import { motion, useMotionValue, useTransform } from 'framer-motion';
import { Shirt, Moon, Sun, ArrowLeft, ArrowRight } from 'lucide-react';
import { OnboardingData } from '@/app/onboarding/page';

interface NonNegotiableStepProps {
  data: OnboardingData;
  onNext: (data: Partial<OnboardingData>) => void;
  isSaving: boolean;
}

export default function NonNegotiableStep({ data, onNext, isSaving }: NonNegotiableStepProps) {
  const [round, setRound] = useState(0);
  const [choices, setChoices] = useState<string[]>([]);
  const x = useMotionValue(0);
  const rotate = useTransform(x, [-200, 200], [-15, 15]);
  const opacityLeft = useTransform(x, [-150, 0], [1, 0]);
  const opacityRight = useTransform(x, [0, 150], [0, 1]);

  const rounds = [
    { left: 'In-unit Laundry', right: 'Building Gym', idLeft: 'laundry', idRight: 'gym', icon: <Shirt size={48} className="text-white/40" /> },
    { left: 'Quiet Street', right: 'Near Train', idLeft: 'quiet', idRight: 'train', icon: <Moon size={48} className="text-white/40" /> },
    { left: 'Natural Light', right: 'Extra Storage', idLeft: 'light', idRight: 'storage', icon: <Sun size={48} className="text-white/40" /> }
  ];

  const current = rounds[round];

  const handleDragEnd = (event: any, info: any) => {
    if (info.offset.x > 100) handleChoice(current.idRight);
    else if (info.offset.x < -100) handleChoice(current.idLeft);
  };

  const handleChoice = (selection: string) => {
    const newChoices = [...choices, selection];
    if (round < rounds.length - 1) {
      setChoices(newChoices);
      setRound(r => r + 1);
      x.set(0);
    } else {
      onNext({ mustHave: newChoices.join(',') });
    }
  };

  return (
    <div className="h-full flex flex-col items-center justify-center max-w-sm mx-auto w-full overflow-hidden relative">
      <div className="text-center mb-12">
        <p className="text-[10px] font-bold uppercase tracking-[0.2em] text-white/40 mb-3">
          Decision Matrix • {round + 1}/{rounds.length}
        </p>
        <h1 className="text-4xl font-serif text-white" style={{ fontFamily: 'Playfair Display, serif' }}>
          This or That?
        </h1>
        <p className="text-white/50 text-sm mt-2">Swipe to decide</p>
      </div>

      <div className="relative w-full h-96 flex items-center justify-center">
        <div className="absolute left-0 top-1/2 -translate-y-1/2 -translate-x-8 w-40 text-right z-0">
          <span className="text-white font-bold text-xl opacity-30 leading-tight block">{current.left}</span>
          <ArrowLeft size={16} className="text-white/20 ml-auto mt-2" />
        </div>
        <div className="absolute right-0 top-1/2 -translate-y-1/2 translate-x-8 w-40 text-left z-0">
          <span className="text-white font-bold text-xl opacity-30 leading-tight block">{current.right}</span>
          <ArrowRight size={16} className="text-white/20 mr-auto mt-2" />
        </div>

        <motion.div
          style={{ x, rotate }}
          drag="x"
          dragConstraints={{ left: 0, right: 0 }}
          onDragEnd={handleDragEnd}
          whileDrag={{ cursor: "grabbing" }}
          className="w-64 h-96 bg-[#151515] rounded-[3rem] border border-white/10 shadow-[0_20px_50px_rgba(0,0,0,0.5)] flex flex-col items-center justify-center relative cursor-grab z-10"
        >
          <div className="p-8 bg-white/5 rounded-full mb-8 shadow-inner border border-white/5">
            {current.icon}
          </div>
          <div className="text-white/20 font-serif text-2xl italic" style={{ fontFamily: 'Playfair Display, serif' }}>
            vs
          </div>

          <motion.div
            style={{ opacity: opacityLeft }}
            className="absolute inset-0 bg-blue-600 rounded-[3rem] flex items-center justify-center z-20 pointer-events-none"
          >
            <span className="text-3xl font-bold text-white text-center px-6">{current.left}</span>
          </motion.div>
          <motion.div
            style={{ opacity: opacityRight }}
            className="absolute inset-0 bg-purple-600 rounded-[3rem] flex items-center justify-center z-20 pointer-events-none"
          >
            <span className="text-3xl font-bold text-white text-center px-6">{current.right}</span>
          </motion.div>
        </motion.div>
      </div>
    </div>
  );
}
