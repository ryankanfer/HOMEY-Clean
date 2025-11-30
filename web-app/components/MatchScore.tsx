'use client';

import { motion } from 'framer-motion';

interface MatchScoreProps {
  score: number;
  size?: 'small' | 'medium' | 'large';
  showLabel?: boolean;
}

export default function MatchScore({ score, size = 'medium', showLabel = true }: MatchScoreProps) {
  // Determine color based on score
  const getColorClasses = () => {
    if (score >= 80) return 'from-green-500 to-emerald-600 border-green-400';
    if (score >= 60) return 'from-primary to-purple-600 border-primary';
    if (score >= 40) return 'from-yellow-500 to-orange-500 border-yellow-400';
    return 'from-gray-500 to-gray-600 border-gray-400';
  };

  const getSizeClasses = () => {
    switch (size) {
      case 'small':
        return 'text-xs px-2 py-1';
      case 'large':
        return 'text-lg px-4 py-2';
      default:
        return 'text-sm px-3 py-1.5';
    }
  };

  const getIconSize = () => {
    switch (size) {
      case 'small':
        return 'text-sm';
      case 'large':
        return 'text-2xl';
      default:
        return 'text-lg';
    }
  };

  return (
    <motion.div
      className={`inline-flex items-center gap-1.5 rounded-full bg-gradient-to-r ${getColorClasses()} ${getSizeClasses()} text-white font-bold shadow-lg border-2 backdrop-blur-sm`}
      initial={{ scale: 0, opacity: 0 }}
      animate={{ scale: 1, opacity: 1 }}
      transition={{ type: 'spring', stiffness: 500, damping: 30 }}
      whileHover={{ scale: 1.05 }}
    >
      <motion.span
        className={getIconSize()}
        animate={{
          rotate: [0, 10, -10, 0],
        }}
        transition={{
          duration: 2,
          repeat: Infinity,
          repeatDelay: 3,
        }}
      >
        ✨
      </motion.span>
      <span>{score}%</span>
      {showLabel && size !== 'small' && <span className="text-white/90">Match</span>}
    </motion.div>
  );
}
