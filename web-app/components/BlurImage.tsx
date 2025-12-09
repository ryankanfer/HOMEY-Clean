'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

interface BlurImageProps {
  src: string;
  alt: string;
  className?: string;
  fallbackEmoji?: string;
  fallbackGradient?: string;
}

export default function BlurImage({
  src,
  alt,
  className = '',
  fallbackEmoji = '🏠',
  fallbackGradient = 'from-primary/40 to-purple-600/40',
}: BlurImageProps) {
  const [isLoading, setIsLoading] = useState(true);
  const [hasError, setHasError] = useState(false);

  const handleLoad = () => {
    setIsLoading(false);
  };

  const handleError = () => {
    setIsLoading(false);
    setHasError(true);
  };

  return (
    <div className={`relative overflow-hidden ${className}`}>
      {/* Skeleton Loader */}
      <AnimatePresence>
        {isLoading && (
          <motion.div
            initial={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.3 }}
            className="absolute inset-0 bg-white/5 backdrop-blur-sm"
          >
            {/* Shimmer Effect */}
            <div className="absolute inset-0 -translate-x-full animate-[shimmer_2s_infinite]">
              <div className="h-full w-full bg-gradient-to-r from-transparent via-white/10 to-transparent" />
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Actual Image or Fallback */}
      {!hasError ? (
        <motion.img
          src={src}
          alt={alt}
          className={`w-full h-full object-cover ${className}`}
          onLoad={handleLoad}
          onError={handleError}
          initial={{ opacity: 0 }}
          animate={{ opacity: isLoading ? 0 : 1 }}
          transition={{ duration: 0.4 }}
        />
      ) : (
        /* Fallback Gradient */
        <div className={`w-full h-full bg-gradient-to-br ${fallbackGradient} flex items-center justify-center text-4xl`}>
          {fallbackEmoji}
        </div>
      )}
    </div>
  );
}
