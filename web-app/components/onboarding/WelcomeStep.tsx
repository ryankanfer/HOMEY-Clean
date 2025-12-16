'use client';

import React, { useState } from 'react';
import { motion, AnimatePresence, useMotionValue } from 'framer-motion';
import { Home, Shield, FileText, ChevronRight, Lock, ArrowUp, Grid, Box, Columns, LayoutTemplate, ArrowLeft, Key } from 'lucide-react';
import { OnboardingData } from '@/app/onboarding/page';

interface WelcomeStepProps {
  data: OnboardingData;
  onNext: (data: Partial<OnboardingData>) => void;
  isSaving: boolean;
}

// Door animations now directly trigger onComplete instead of showing intermediate page

// --- SELECTION SCREEN (REDESIGNED) ---
const SelectionScreen = ({ onSelect }: { onSelect: (id: number) => void }) => {
  return (
    <div className="w-full h-full flex flex-col items-center justify-center relative z-10">
      {/* Header messaging */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="text-center mb-12"
      >
        <h2 className="text-xs font-bold uppercase tracking-[0.4em] text-white/40 mb-4">Welcome Home</h2>
        <h1 className="text-5xl font-serif text-white tracking-tight" style={{ fontFamily: 'Playfair Display, serif' }}>
          Choose your entrance.
        </h1>
      </motion.div>

      {/* Door Carousel */}
      <DoorCarousel onSelect={onSelect} />
    </div>
  );
};

const DoorCarousel = ({ onSelect }: { onSelect: (id: number) => void }) => {
  const [selectedDoor, setSelectedDoor] = useState(0);
  const dragX = useMotionValue(0);

  const doors = [
    { id: 0, name: 'The Classic', desc: 'Timeless elegance', icon: '🚪' },
    { id: 1, name: 'French Doors', desc: 'Light & airy', icon: '🪟' },
    { id: 2, name: 'The Elevator', desc: 'Penthouse views', icon: '🛗' },
    { id: 3, name: 'The Loft', desc: 'Industrial chic', icon: '🏭' },
    { id: 4, name: 'The Vault', desc: 'Secure & exclusive', icon: '🏦' },
    { id: 5, name: 'The Shoji', desc: 'Minimalist zen', icon: '🎎' },
  ];

  const onDragEnd = (event: any, info: any) => {
    const offset = info.offset.x;
    if (offset > 50 && selectedDoor > 0) {
      setSelectedDoor(selectedDoor - 1);
    } else if (offset < -50 && selectedDoor < doors.length - 1) {
      setSelectedDoor(selectedDoor + 1);
    }
  };

  return (
    <>
      <div className="relative w-full min-h-[500px] flex items-center justify-center mb-8">
        {doors.map((door, index) => {
          const offset = index - selectedDoor;
          const isActive = offset === 0;
          return (
            <motion.div
              key={door.id}
              drag={isActive ? "x" : false}
              dragConstraints={{ left: 0, right: 0 }}
              dragElastic={0.2}
              onDragEnd={onDragEnd}
              className={`absolute w-72 h-[420px] bg-gradient-to-b from-white/[0.03] via-white/[0.02] to-black/50 border border-white/[0.08] rounded-[2rem] flex flex-col items-center justify-center ${isActive ? 'cursor-grab active:cursor-grabbing' : 'cursor-pointer'} shadow-[0_8px_32px_rgba(0,0,0,0.4)] overflow-hidden backdrop-blur-sm`}
              initial={false}
              animate={{
                x: offset * 240,
                scale: isActive ? 1 : 0.85,
                opacity: Math.abs(offset) > 1 ? 0 : isActive ? 1 : 0.3,
                rotateY: offset * 15,
                filter: isActive ? 'blur(0px)' : 'blur(4px)',
                zIndex: isActive ? 20 : 10
              }}
              transition={{ duration: 0.6, ease: [0.32, 0.72, 0, 1] }}
              onClick={() => !isActive && setSelectedDoor(index)}
            >
              <div className="absolute inset-0 bg-gradient-to-br from-white/[0.05] via-transparent to-black/20" />
              <div className="text-7xl mb-8 filter drop-shadow-[0_0_20px_rgba(255,255,255,0.2)]">{door.icon}</div>
              <h3 className="text-2xl font-serif text-white mb-2 tracking-tight" style={{ fontFamily: 'Playfair Display, serif' }}>{door.name}</h3>
              <p className="text-[9px] text-white/30 uppercase tracking-[0.3em] font-light">{door.desc}</p>

              {isActive && (
                <motion.button
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 0.2 }}
                  onClick={(e) => { e.stopPropagation(); onSelect(door.id); }}
                  onPointerDown={(e) => e.stopPropagation()}
                  onTouchStart={(e) => e.stopPropagation()}
                  className="mt-10 px-8 py-3 bg-white/95 text-black rounded-full font-semibold text-xs uppercase tracking-[0.2em] hover:bg-white hover:scale-105 active:scale-95 transition-all shadow-lg relative z-50"
                >
                  Enter
                </motion.button>
              )}
            </motion.div>
          );
        })}
      </div>

      <div className="flex gap-2 justify-center">
        {doors.map((_, i) => (
          <motion.div
            key={i}
            animate={{
              width: i === selectedDoor ? 20 : 6,
              backgroundColor: i === selectedDoor ? 'rgba(255,255,255,0.9)' : 'rgba(255,255,255,0.15)'
            }}
            className="h-1 rounded-full cursor-pointer"
            onClick={() => setSelectedDoor(i)}
          />
        ))}
      </div>
    </>
  );
};

// --- Door Variation Components (ENHANCED) ---
const BackButton = ({ onClick, dark }: { onClick: () => void; dark: boolean }) => (
  <button
    onClick={(e) => { e.stopPropagation(); onClick(); }}
    className={`absolute top-6 left-6 z-50 p-2.5 rounded-full transition-all flex items-center gap-1.5 text-xs font-semibold backdrop-blur-sm ${
      dark ? 'text-slate-700 bg-white/80 hover:bg-white shadow-sm' : 'text-white bg-black/30 hover:bg-black/50 shadow-lg'
    }`}
  >
    <ArrowLeft size={16} strokeWidth={2.5} /> Back
  </button>
);

const VariationClassic = ({ active, onBack, onComplete }: any) => {
  const [open, setOpen] = useState(false);

  React.useEffect(() => {
    if (open) {
      const timer = setTimeout(() => {
        onComplete();
      }, 1200); // Complete after door fully opens
      return () => clearTimeout(timer);
    }
  }, [open, onComplete]);

  if (!active) return null;

  return (
    <div className="fixed inset-0 w-full h-full bg-gradient-to-b from-amber-100 to-amber-50 overflow-hidden perspective-1000 animate-fade-in z-50">
      {/* Light flooding effect */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: open ? 1 : 0 }}
        transition={{ duration: 0.6, ease: "easeOut" }}
        className="absolute inset-0 bg-gradient-radial from-yellow-100 via-white to-white z-10 pointer-events-none"
      />

      {/* The Door */}
      <motion.div
        animate={{
          rotateY: open ? -95 : 0,
        }}
        transition={{
          duration: 1.2,
          ease: [0.22, 1, 0.36, 1],
        }}
        className="absolute inset-0 bg-[#3f2e22] z-20 origin-left border-r-4 border-[#2a1e16] flex items-center justify-end pr-6 shadow-2xl cursor-pointer"
        style={{
          transformStyle: 'preserve-3d',
          backgroundImage: 'linear-gradient(90deg, #3f2e22 0%, #5c4433 50%, #3f2e22 100%)'
        }}
        onClick={() => !open && setOpen(true)}
      >
        <BackButton onClick={onBack} dark={false} />

        {/* Wood grain details */}
        <div className="absolute inset-6 border-2 border-[#5c4433]/30 rounded-sm opacity-60"></div>
        <div className="absolute top-1/4 bottom-1/4 left-12 right-28 border border-[#5c4433]/30 opacity-40"></div>

        {/* Door knob */}
        <motion.div
          whileHover={{ scale: 1.1 }}
          whileTap={{ scale: 0.95 }}
          className="w-14 h-14 bg-gradient-to-br from-yellow-400 to-yellow-700 rounded-full shadow-xl flex items-center justify-center relative"
        >
           <div className="w-3 h-3 bg-yellow-900/50 rounded-full"></div>
           <div className="absolute inset-0 rounded-full ring-2 ring-yellow-600/30"></div>
        </motion.div>

        {!open && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.5 }}
            className="absolute top-1/2 left-1/2 -translate-x-1/2 mt-20 text-white/40 text-xs font-serif tracking-[0.3em] uppercase"
          >
            Turn Knob
          </motion.div>
        )}
      </motion.div>
    </div>
  );
};

const VariationFrench = ({ active, onBack, onComplete }: any) => {
  const [open, setOpen] = useState(false);

  React.useEffect(() => {
    if (open) {
      const timer = setTimeout(() => {
        onComplete();
      }, 1400);
      return () => clearTimeout(timer);
    }
  }, [open, onComplete]);

  if (!active) return null;

  return (
    <div className="fixed inset-0 w-full h-full bg-gradient-to-b from-blue-50 to-white overflow-hidden perspective-1000 flex animate-fade-in z-50">
      {/* Light effect */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: open ? 0.6 : 0 }}
        transition={{ duration: 0.8 }}
        className="absolute inset-0 bg-gradient-radial from-blue-100 via-white to-transparent z-10 pointer-events-none"
      />

      {/* Left Door */}
      <motion.div
        animate={{ rotateY: open ? -100 : 0 }}
        transition={{ duration: 1.4, ease: [0.19, 1, 0.22, 1] }}
        className="relative w-1/2 h-full bg-white border-r-2 border-slate-200 z-20 origin-left shadow-2xl"
        style={{ transformStyle: 'preserve-3d' }}
      >
        <BackButton onClick={onBack} dark={true} />
        {/* Glass panels */}
        <div className="absolute inset-4 border-4 border-slate-100 grid grid-rows-4 gap-3 py-6 mt-12 rounded-sm">
           {[...Array(4)].map((_,i) => (
             <div key={i} className="bg-gradient-to-br from-blue-50/40 to-cyan-50/40 mx-3 h-full rounded shadow-inner"></div>
           ))}
        </div>
        <div className="absolute right-3 top-1/2 -translate-y-1/2 w-3 h-20 bg-gradient-to-r from-slate-300 to-slate-400 rounded-l-lg shadow-md"></div>
      </motion.div>

      {/* Right Door */}
      <motion.div
        animate={{ rotateY: open ? 100 : 0 }}
        transition={{ duration: 1.4, ease: [0.19, 1, 0.22, 1] }}
        className="relative w-1/2 h-full bg-white border-l-2 border-slate-200 z-20 origin-right shadow-2xl"
        style={{ transformStyle: 'preserve-3d' }}
      >
         <div className="absolute inset-4 border-4 border-slate-100 grid grid-rows-4 gap-3 py-6 mt-12 rounded-sm">
           {[...Array(4)].map((_,i) => (
             <div key={i} className="bg-gradient-to-br from-blue-50/40 to-cyan-50/40 mx-3 h-full rounded shadow-inner"></div>
           ))}
        </div>
        <div className="absolute left-3 top-1/2 -translate-y-1/2 w-3 h-20 bg-gradient-to-l from-slate-300 to-slate-400 rounded-r-lg shadow-md"></div>
      </motion.div>

      {/* Lock button */}
      {!open && (
        <motion.button
          onClick={() => setOpen(true)}
          whileHover={{ scale: 1.1 }}
          whileTap={{ scale: 0.9 }}
          initial={{ opacity: 0, scale: 0.8 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ delay: 0.3 }}
          className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 z-30 w-20 h-20 bg-white rounded-full shadow-2xl flex items-center justify-center text-slate-400 hover:text-blue-500 transition-colors border-2 border-slate-100"
        >
           <Lock size={28} strokeWidth={2} />
        </motion.button>
      )}
    </div>
  );
};

const VariationElevator = ({ active, onBack, onComplete }: any) => {
  const [rising, setRising] = useState(false);
  const [open, setOpen] = useState(false);

  // Auto-rise on mount
  React.useEffect(() => {
    const timer = setTimeout(() => {
      setRising(true);
    }, 300); // Small delay for smooth entry
    return () => clearTimeout(timer);
  }, []);

  React.useEffect(() => {
    if (open) {
      // Complete after doors fully open
      const timer = setTimeout(() => {
        onComplete();
      }, 1200);
      return () => clearTimeout(timer);
    }
  }, [open, onComplete]);

  if (!active) return null;

  const handleOpenDoors = () => {
    setOpen(true);
  };

  return (
    <div className="fixed inset-0 w-full h-full bg-gradient-to-b from-slate-300 to-slate-200 overflow-hidden flex animate-fade-in z-50">
      {/* Elevator shaft background */}
      <div className="absolute inset-0 bg-slate-400/20" />

      {/* Elevator container - rises then doors open */}
      <motion.div
        animate={{
          y: rising ? 0 : '100%',
        }}
        transition={{
          duration: 1.2,
          ease: [0.65, 0, 0.35, 1],
        }}
        className="absolute inset-0 flex"
      >
        {/* Left Door */}
        <motion.div
          animate={{
            x: open ? '-100%' : 0,
          }}
          transition={{
            duration: 1.2,
            ease: [0.65, 0, 0.35, 1],
          }}
          className="w-1/2 h-full bg-gradient-to-r from-slate-300 to-slate-400 z-20 border-r-2 border-slate-500 shadow-lg relative"
        >
           <BackButton onClick={onBack} dark={true} />
           {/* Metal texture */}
           <div className="h-full w-full bg-[linear-gradient(90deg,transparent_0%,rgba(255,255,255,0.15)_50%,transparent_100%)] bg-[length:30px_100%]"></div>
           <div className="absolute inset-y-0 right-0 w-1 bg-slate-600"></div>
        </motion.div>

        {/* Right Door */}
        <motion.div
          animate={{
            x: open ? '100%' : 0,
          }}
          transition={{
            duration: 1.2,
            ease: [0.65, 0, 0.35, 1],
          }}
          className="w-1/2 h-full bg-gradient-to-l from-slate-300 to-slate-400 z-20 border-l-2 border-slate-500 shadow-lg relative"
        >
          <div className="h-full w-full bg-[linear-gradient(90deg,transparent_0%,rgba(255,255,255,0.15)_50%,transparent_100%)] bg-[length:30px_100%]"></div>
          <div className="absolute inset-y-0 left-0 w-1 bg-slate-600"></div>
        </motion.div>
      </motion.div>

      {/* Open doors button - appears after elevator has risen */}
      {rising && !open && (
        <motion.div
          initial={{ opacity: 0, scale: 0.8 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ delay: 1.2, duration: 0.4 }}
          className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 z-30"
        >
          <motion.button
            onClick={handleOpenDoors}
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            className="bg-white px-8 py-4 rounded-full shadow-2xl font-bold text-slate-800 flex items-center gap-3 border-2 border-slate-200"
          >
            <span>Open Doors</span>
          </motion.button>
        </motion.div>
      )}
    </div>
  );
};

const VariationLoft = ({ active, onBack, onComplete }: any) => {
  const [open, setOpen] = useState(false);

  React.useEffect(() => {
    if (open) {
      const timer = setTimeout(() => {
        onComplete();
      }, 1500);
      return () => clearTimeout(timer);
    }
  }, [open, onComplete]);

  if (!active) return null;

  return (
    <div className="fixed inset-0 w-full h-full bg-gradient-to-b from-slate-100 to-white overflow-hidden animate-fade-in z-50">
      {/* Light behind the door */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: open ? 1 : 0 }}
        transition={{ duration: 0.8 }}
        className="absolute inset-0 bg-gradient-to-b from-amber-100 to-white z-10 pointer-events-none"
      />

      {/* Rolling Garage Door */}
      <motion.div
        animate={{
          y: open ? '-100%' : 0,
        }}
        transition={{
          duration: 1.5,
          ease: [0.45, 0, 0.55, 1],
        }}
        className="absolute inset-0 bg-gradient-to-b from-slate-800 to-slate-700 z-20 flex flex-col justify-end shadow-2xl"
      >
         <BackButton onClick={onBack} dark={false} />

         {/* Metal slats */}
         {[...Array(24)].map((_, i) => (
           <div
             key={i}
             className="flex-grow border-b-2 border-slate-900/50 bg-gradient-to-r from-slate-700 via-slate-600 to-slate-700 relative"
           >
             <div className="absolute inset-0 bg-[linear-gradient(90deg,transparent_0%,rgba(255,255,255,0.05)_50%,transparent_100%)]" />
           </div>
         ))}

         {/* Bottom handle bar */}
         <div className="h-16 bg-slate-900 border-t-2 border-slate-600 flex items-center justify-center shadow-inner">
             <div className="w-24 h-3 bg-slate-600 rounded-full shadow-md"></div>
         </div>
      </motion.div>

      {/* Control button */}
      <motion.div
        animate={{ opacity: open ? 0 : 1 }}
        className="absolute bottom-12 left-1/2 -translate-x-1/2 z-30"
      >
         <motion.button
           onClick={() => setOpen(true)}
           whileHover={{ scale: 1.05 }}
           whileTap={{ scale: 0.95 }}
           initial={{ opacity: 0, y: 20 }}
           animate={{ opacity: 1, y: 0 }}
           transition={{ delay: 0.3 }}
           className="bg-white px-8 py-4 rounded-full shadow-2xl font-bold text-slate-800 flex items-center gap-3 border-2 border-slate-200"
         >
           <ArrowUp size={20} strokeWidth={2.5} />
           <span>Open Garage</span>
         </motion.button>
      </motion.div>
    </div>
  );
};

const VariationVault = ({ active, onBack, onComplete }: any) => {
  const [step, setStep] = useState(0);

  const handleUnlock = () => {
    if (step !== 0) return;
    setStep(1); // Spin wheel
    setTimeout(() => setStep(2), 800); // Then swing door
  };

  React.useEffect(() => {
    if (step === 2) {
      const timer = setTimeout(() => {
        onComplete();
      }, 1400);
      return () => clearTimeout(timer);
    }
  }, [step, onComplete]);

  if (!active) return null;

  return (
    <div className="fixed inset-0 w-full h-full bg-gradient-to-b from-gray-200 to-gray-100 overflow-hidden perspective-1000 animate-fade-in z-50">
      {/* Light effect */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: step === 2 ? 0.8 : 0 }}
        transition={{ duration: 0.6 }}
        className="absolute inset-0 bg-gradient-radial from-gray-100 via-white to-transparent z-10 pointer-events-none"
      />

      {/* Vault Door */}
      <motion.div
        animate={{
          rotateY: step === 2 ? -95 : 0,
        }}
        transition={{
          duration: 1.4,
          ease: [0.16, 1, 0.3, 1],
        }}
        className="absolute inset-0 bg-gradient-to-br from-gray-300 to-gray-400 z-20 origin-left flex items-center justify-center shadow-2xl border-r-8 border-gray-500"
        style={{ transformStyle: 'preserve-3d' }}
      >
         <BackButton onClick={onBack} dark={true} />

         {/* Metal texture */}
         <div className="absolute inset-0 bg-[radial-gradient(circle_at_center,_var(--tw-gradient-stops))] from-gray-200 via-gray-300 to-gray-400 opacity-80"></div>

         {/* Heavy bolts */}
         <motion.div
           animate={{
             x: step >= 1 ? '100%' : 0,
           }}
           transition={{ duration: 0.6, ease: "easeInOut" }}
           className="absolute right-4 top-16 w-5 h-10 bg-gradient-to-r from-gray-500 to-gray-600 rounded-l-lg shadow-lg"
         />
         <motion.div
           animate={{
             x: step >= 1 ? '100%' : 0,
           }}
           transition={{ duration: 0.6, ease: "easeInOut", delay: 0.1 }}
           className="absolute right-4 bottom-16 w-5 h-10 bg-gradient-to-r from-gray-500 to-gray-600 rounded-l-lg shadow-lg"
         />

         {/* The Wheel */}
         <motion.div
           onClick={handleUnlock}
           animate={{
             rotate: step >= 1 ? 360 : 0,
           }}
           transition={{
             duration: 0.8,
             ease: [0.34, 1.56, 0.64, 1],
           }}
           whileHover={{ scale: 1.05 }}
           className="relative w-48 h-48 rounded-full border-8 border-gray-500 bg-gradient-to-br from-gray-200 to-gray-300 shadow-2xl flex items-center justify-center cursor-pointer"
         >
            {/* Spokes */}
            <div className="absolute w-full h-6 bg-gradient-to-r from-gray-400 to-gray-500 rounded-full shadow-md"></div>
            <div className="absolute w-6 h-full bg-gradient-to-b from-gray-400 to-gray-500 rounded-full shadow-md"></div>

            {/* Center hub */}
            <div className="w-24 h-24 rounded-full bg-gradient-to-br from-gray-300 to-gray-400 border-4 border-gray-500 z-10 shadow-inner"></div>

            {/* Handles on cardinal directions */}
            {[0, 90, 180, 270].map((angle) => (
              <div
                key={angle}
                className="absolute w-6 h-12 bg-gradient-to-b from-gray-500 to-gray-600 rounded-full shadow-lg"
                style={{
                  transform: `rotate(${angle}deg) translateY(-90px)`,
                }}
              />
            ))}
         </motion.div>

         {step === 0 && (
           <motion.div
             initial={{ opacity: 0 }}
             animate={{ opacity: 1 }}
             transition={{ delay: 0.3 }}
             className="absolute bottom-24 text-gray-600 text-sm font-bold uppercase tracking-widest"
           >
             Spin Wheel
           </motion.div>
         )}
      </motion.div>
    </div>
  );
};

const VariationShoji = ({ active, onBack, onComplete }: any) => {
  const [open, setOpen] = useState(false);

  React.useEffect(() => {
    if (open) {
      const timer = setTimeout(() => {
        onComplete();
      }, 1300);
      return () => clearTimeout(timer);
    }
  }, [open, onComplete]);

  if (!active) return null;

  return (
    <div className="fixed inset-0 w-full h-full bg-gradient-to-br from-orange-50 to-amber-50 overflow-hidden flex animate-fade-in z-50">
      {/* Soft ambient light behind */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: open ? 1 : 0 }}
        transition={{ duration: 0.8 }}
        className="absolute inset-0 bg-gradient-radial from-orange-100 via-amber-50 to-transparent z-10 pointer-events-none"
      />

      {/* Shoji Screen Panel */}
      <motion.div
        onClick={() => !open && setOpen(true)}
        animate={{
          x: open ? '100%' : 0,
        }}
        transition={{
          duration: 1.3,
          ease: [0.45, 0, 0.55, 1],
        }}
        className="absolute inset-0 z-20 bg-[#fbf7f0] border-l-8 border-[#3d2b1f] flex shadow-2xl cursor-pointer"
      >
        <BackButton onClick={onBack} dark={true} />

        {/* Frame grid with translucent paper panels */}
        <div className="w-full h-full border-4 border-[#3d2b1f] grid grid-cols-2 grid-rows-4 gap-0 p-2">
           {[...Array(8)].map((_, i) => (
             <div
               key={i}
               className="border-2 border-[#3d2b1f]/40 bg-gradient-to-br from-white/90 to-amber-50/60 shadow-[inset_0_2px_15px_rgba(0,0,0,0.06)] m-1 rounded-sm backdrop-blur-sm"
             />
           ))}
        </div>

        {/* Wooden handle */}
        <div className="absolute left-6 top-1/2 -translate-y-1/2 w-10 h-28 bg-gradient-to-r from-[#2a1d15] to-[#1a110d] rounded-lg flex items-center justify-center shadow-xl">
           <div className="w-1.5 h-16 bg-[#0d0805] rounded-full shadow-inner"></div>
        </div>
      </motion.div>

      {/* Vertical text instruction */}
      {!open && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.4 }}
          className="absolute left-24 top-1/2 -translate-y-1/2 z-30 text-[#3d2b1f] text-sm font-serif tracking-[0.3em] [writing-mode:vertical-rl] rotate-180 opacity-40 pointer-events-none"
        >
          SLIDE OPEN
        </motion.div>
      )}
    </div>
  );
};

// --- MAIN COMPONENT ---
export default function WelcomeStep({ onNext, isSaving }: WelcomeStepProps) {
  const [view, setView] = useState<'selection' | 'variation'>('selection');
  const [activeVariation, setActiveVariation] = useState(0);
  const [key, setKey] = useState(0);

  const variations = [
    { name: "Classic", component: VariationClassic },
    { name: "French", component: VariationFrench },
    { name: "Elevator", component: VariationElevator },
    { name: "Loft", component: VariationLoft },
    { name: "Vault", component: VariationVault },
    { name: "Shoji", component: VariationShoji },
  ];

  const handleSelect = (id: number) => {
    console.log('Door selected:', id);
    setActiveVariation(id);
    setView('variation');
    setKey(prev => prev + 1);
  };

  const handleBack = () => {
    setView('selection');
    setKey(prev => prev + 1); // Force re-render
  };

  const handleComplete = () => {
    console.log('Door animation complete, moving to next step');
    // Save the door selection for AI personalization later
    const doorNames = ["classic", "french", "elevator", "loft", "vault", "shoji"];
    onNext({
      doorSelection: doorNames[activeVariation]
    });
  };

  const ActiveComponent = variations[activeVariation].component;

  return (
    <div className="fixed inset-0 w-full h-full overflow-visible z-50">
      <AnimatePresence mode="wait">
        {view === 'selection' ? (
          <motion.div
            key="selection"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.3 }}
            className="fixed inset-0 w-full h-full z-50"
          >
            <SelectionScreen onSelect={handleSelect} />
          </motion.div>
        ) : (
          <motion.div
            key={`variation-${key}`}
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.3 }}
            className="fixed inset-0 w-full h-full z-50"
          >
            <ActiveComponent
              active={true}
              onBack={handleBack}
              onComplete={handleComplete}
            />
          </motion.div>
        )}
      </AnimatePresence>

      <style jsx global>{`
        .perspective-1000 { perspective: 1000px; }
        .-rotate-y-90 { transform: rotateY(-100deg); }
        .rotate-y-0 { transform: rotateY(0deg); }
        .rotate-y-90 { transform: rotateY(100deg); }
        .animate-fade-in-up { animation: fadeInUp 0.8s ease-out forwards; }
        .animate-fade-in { animation: fadeIn 0.4s ease-out forwards; }
        @keyframes fadeInUp {
          from { opacity: 0; transform: translateY(10px); }
          to { opacity: 1; transform: translateY(0); }
        }
        @keyframes fadeIn {
          from { opacity: 0; }
          to { opacity: 1; }
        }
      `}</style>
    </div>
  );
}
