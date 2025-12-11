'use client';

import { motion } from 'framer-motion';

interface JourneyTimelineProps {
  currentStage: number; // 0-5 for renters, 0-7 for buyers
  totalStages: number;
  stageName: string; // Current stage name
  isRenter?: boolean;
}

export default function JourneyTimeline({
  currentStage,
  totalStages,
  stageName,
  isRenter = true,
}: JourneyTimelineProps) {
  const progressPercentage = Math.round((currentStage / totalStages) * 100);

  return (
    <motion.div
      className="px-5 mb-6"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.6, delay: 0.4 }}
    >
      <div className="glass-strong rounded-2xl border border-white/10 p-4">
        {/* Header with Progress Text */}
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-sm font-bold text-white/40 uppercase tracking-wider">
            Journey Progress
          </h2>
          <div className="text-xs text-white/60 font-medium">
            {currentStage}/{totalStages} Complete • {progressPercentage}%
          </div>
        </div>

        {/* Current Stage Name */}
        <div className="mb-4">
          <p className="text-white text-sm font-medium">
            Current: <span className="text-purple-300">{stageName}</span>
          </p>
        </div>

        {/* Timeline Dots */}
        <div className="flex items-center justify-center gap-0">
          {Array.from({ length: totalStages }).map((_, index) => {
            const isCompleted = index < currentStage;
            const isCurrent = index === currentStage;
            const isUpcoming = index > currentStage;

            return (
              <div key={index} className="flex items-center">
                {/* Dot */}
                <motion.div
                  initial={{ scale: 0 }}
                  animate={{ scale: 1 }}
                  transition={{ delay: index * 0.1, type: 'spring' }}
                  className="relative"
                >
                  {isCompleted && (
                    <div className="w-2 h-2 rounded-full bg-green-500" />
                  )}
                  {isCurrent && (
                    <motion.div
                      className="w-2.5 h-2.5 rounded-full bg-gradient-to-r from-purple-500 to-pink-500"
                      animate={{
                        scale: [1, 1.2, 1],
                      }}
                      transition={{
                        duration: 2,
                        repeat: Infinity,
                        ease: "easeInOut"
                      }}
                    />
                  )}
                  {isUpcoming && (
                    <div className="w-2 h-2 rounded-full border-2 border-white/20 bg-transparent" />
                  )}
                </motion.div>

                {/* Line connecting to next dot (don't show after last dot) */}
                {index < totalStages - 1 && (
                  <div className="relative">
                    {isCompleted ? (
                      <motion.div
                        initial={{ width: 0 }}
                        animate={{ width: '16px' }}
                        transition={{ delay: index * 0.1 + 0.2, duration: 0.3 }}
                        className="h-0.5 w-4 bg-green-500"
                      />
                    ) : (
                      <div className="h-0.5 w-4 bg-white/10" />
                    )}
                  </div>
                )}
              </div>
            );
          })}
        </div>

        {/* Progress Bar (alternative visualization) */}
        <div className="relative h-1 bg-white/5 rounded-full overflow-hidden mt-4">
          <motion.div
            className="absolute inset-y-0 left-0 bg-gradient-to-r from-purple-500 to-pink-500 rounded-full"
            initial={{ width: 0 }}
            animate={{ width: `${progressPercentage}%` }}
            transition={{ duration: 1, ease: 'easeOut', delay: 0.5 }}
          />
        </div>
      </div>
    </motion.div>
  );
}
