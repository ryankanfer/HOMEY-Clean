'use client';

import { motion, AnimatePresence } from 'framer-motion';
import { X, Swords, DollarSign, Zap, Hammer, Gift, Heart } from 'lucide-react';

export type GameMode = 'swipe' | 'battle' | 'guess' | 'speed' | 'build' | 'mystery';

interface GameModeOption {
  id: GameMode;
  name: string;
  description: string;
  icon: any;
  color: string;
  badge?: string;
}

interface GameModeSelectorProps {
  isOpen: boolean;
  onClose: () => void;
  currentMode: GameMode;
  onSelectMode: (mode: GameMode) => void;
}

const gameModes: GameModeOption[] = [
  {
    id: 'swipe',
    name: 'Classic Swipe',
    description: 'The original matchmaker experience',
    icon: Heart,
    color: 'from-pink-500 to-purple-500',
  },
  {
    id: 'battle',
    name: 'This or That',
    description: 'Side-by-side comparison • Fast-paced',
    icon: Swords,
    color: 'from-orange-500 to-red-500',
    badge: 'Quick Decisions',
  },
  {
    id: 'guess',
    name: 'Guess the Rent',
    description: 'Test your market knowledge • Earn points',
    icon: DollarSign,
    color: 'from-green-500 to-emerald-500',
    badge: 'Market Expert',
  },
  {
    id: 'speed',
    name: 'Speed Round',
    description: '60 seconds • Gut reactions only',
    icon: Zap,
    color: 'from-yellow-500 to-orange-500',
    badge: 'Fast Learner',
  },
  {
    id: 'build',
    name: 'Build Your Dream',
    description: 'Create your fantasy apartment',
    icon: Hammer,
    color: 'from-blue-500 to-cyan-500',
    badge: 'Architect',
  },
  {
    id: 'mystery',
    name: 'Mystery Box',
    description: 'Random surprises • Daily rewards',
    icon: Gift,
    color: 'from-purple-500 to-pink-500',
    badge: 'Lucky',
  },
];

export default function GameModeSelector({
  isOpen,
  onClose,
  currentMode,
  onSelectMode,
}: GameModeSelectorProps) {
  const handleSelectMode = (mode: GameMode) => {
    onSelectMode(mode);
    onClose();
  };

  return (
    <AnimatePresence>
      {isOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
          <motion.div
            key="mode-backdrop"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={onClose}
            className="absolute inset-0 bg-black/60 backdrop-blur-sm"
          />

          <motion.div
            key="mode-modal"
            initial={{ opacity: 0, scale: 0.9, y: 20 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.9, y: 20 }}
            className="relative glass-strong rounded-2xl p-6 max-w-2xl w-full border border-white/10 max-h-[85vh] overflow-y-auto"
          >
            {/* Header */}
            <div className="flex items-center justify-between mb-6">
              <div>
                <h3 className="text-2xl font-bold text-white">Game Modes</h3>
                <p className="text-sm text-white/60 mt-1">Choose your matchmaker style</p>
              </div>
              <button
                onClick={onClose}
                className="w-10 h-10 rounded-full bg-white/10 flex items-center justify-center text-white hover:bg-white/20 transition-all"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* Game Mode Grid */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {gameModes.map((mode, index) => {
                const Icon = mode.icon;
                const isActive = currentMode === mode.id;

                return (
                  <motion.button
                    key={mode.id}
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: index * 0.05 }}
                    onClick={() => handleSelectMode(mode.id)}
                    className={`relative p-5 rounded-xl border-2 transition-all text-left ${
                      isActive
                        ? 'bg-white/10 border-primary shadow-lg shadow-primary/20'
                        : 'bg-white/5 border-white/10 hover:bg-white/10 hover:border-white/20'
                    }`}
                  >
                    {/* Icon */}
                    <div className={`w-12 h-12 rounded-lg bg-gradient-to-br ${mode.color} flex items-center justify-center mb-3`}>
                      <Icon className="w-6 h-6 text-white" />
                    </div>

                    {/* Content */}
                    <div className="mb-2">
                      <h4 className="text-lg font-bold text-white flex items-center gap-2">
                        {mode.name}
                        {isActive && (
                          <span className="text-xs px-2 py-0.5 bg-primary/20 border border-primary/30 rounded-full text-primary">
                            Active
                          </span>
                        )}
                      </h4>
                      <p className="text-sm text-white/60 mt-1">{mode.description}</p>
                    </div>

                    {/* Badge */}
                    {mode.badge && (
                      <div className="flex items-center gap-2 mt-3 pt-3 border-t border-white/10">
                        <span className="text-xs text-white/50">Badge:</span>
                        <span className="text-xs font-medium text-white/80">{mode.badge}</span>
                      </div>
                    )}

                    {/* Active Indicator */}
                    {isActive && (
                      <motion.div
                        layoutId="active-mode"
                        className="absolute inset-0 border-2 border-primary rounded-xl pointer-events-none"
                        transition={{ type: 'spring', bounce: 0.2, duration: 0.6 }}
                      />
                    )}
                  </motion.button>
                );
              })}
            </div>

            {/* Info */}
            <motion.div
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.3 }}
              className="mt-6 p-4 bg-cyan-500/10 border border-cyan-500/30 rounded-xl"
            >
              <p className="text-sm text-cyan-300 font-medium mb-1">Pro Tip</p>
              <p className="text-xs text-white/70">
                Try different modes to earn badges and build your preference profile faster!
                Each mode helps our AI learn what you love in different ways.
              </p>
            </motion.div>
          </motion.div>
        </div>
      )}
    </AnimatePresence>
  );
}
