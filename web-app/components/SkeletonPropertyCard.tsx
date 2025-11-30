'use client';

import { motion } from 'framer-motion';

interface SkeletonPropertyCardProps {
  size?: 'small' | 'medium' | 'large';
}

export default function SkeletonPropertyCard({ size = 'medium' }: SkeletonPropertyCardProps) {
  const sizeClasses = {
    small: 'w-[240px] h-[280px]',
    medium: 'w-[280px] h-[320px]',
    large: 'w-[320px] h-[360px]',
  };

  const imageHeightClasses = {
    small: 'h-[140px]',
    medium: 'h-[160px]',
    large: 'h-[200px]',
  };

  return (
    <div className={`${sizeClasses[size]} flex-shrink-0 glass rounded-2xl overflow-hidden`}>
      {/* Image skeleton */}
      <div className={`${imageHeightClasses[size]} bg-gradient-to-br from-white/5 to-white/10 relative overflow-hidden`}>
        <motion.div
          className="absolute inset-0 bg-gradient-to-r from-transparent via-white/10 to-transparent"
          animate={{
            x: ['-100%', '100%'],
          }}
          transition={{
            duration: 1.5,
            repeat: Infinity,
            ease: 'linear',
          }}
        />
      </div>

      {/* Content skeleton */}
      <div className="p-4 space-y-3">
        {/* Price */}
        <div className="h-6 w-24 bg-white/10 rounded-lg overflow-hidden relative">
          <motion.div
            className="absolute inset-0 bg-gradient-to-r from-transparent via-white/10 to-transparent"
            animate={{
              x: ['-100%', '100%'],
            }}
            transition={{
              duration: 1.5,
              repeat: Infinity,
              ease: 'linear',
              delay: 0.1,
            }}
          />
        </div>

        {/* Address */}
        <div className="space-y-2">
          <div className="h-4 w-full bg-white/10 rounded overflow-hidden relative">
            <motion.div
              className="absolute inset-0 bg-gradient-to-r from-transparent via-white/10 to-transparent"
              animate={{
                x: ['-100%', '100%'],
              }}
              transition={{
                duration: 1.5,
                repeat: Infinity,
                ease: 'linear',
                delay: 0.2,
              }}
            />
          </div>
          <div className="h-3 w-3/4 bg-white/10 rounded overflow-hidden relative">
            <motion.div
              className="absolute inset-0 bg-gradient-to-r from-transparent via-white/10 to-transparent"
              animate={{
                x: ['-100%', '100%'],
              }}
              transition={{
                duration: 1.5,
                repeat: Infinity,
                ease: 'linear',
                delay: 0.3,
              }}
            />
          </div>
        </div>

        {/* Stats */}
        <div className="flex gap-2">
          <div className="h-3 w-16 bg-white/10 rounded overflow-hidden relative">
            <motion.div
              className="absolute inset-0 bg-gradient-to-r from-transparent via-white/10 to-transparent"
              animate={{
                x: ['-100%', '100%'],
              }}
              transition={{
                duration: 1.5,
                repeat: Infinity,
                ease: 'linear',
                delay: 0.4,
              }}
            />
          </div>
          <div className="h-3 w-16 bg-white/10 rounded overflow-hidden relative">
            <motion.div
              className="absolute inset-0 bg-gradient-to-r from-transparent via-white/10 to-transparent"
              animate={{
                x: ['-100%', '100%'],
              }}
              transition={{
                duration: 1.5,
                repeat: Infinity,
                ease: 'linear',
                delay: 0.5,
              }}
            />
          </div>
        </div>
      </div>
    </div>
  );
}
