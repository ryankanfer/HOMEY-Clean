'use client';

import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';

interface ProgressiveImageProps {
  src: string;
  alt: string;
  className?: string;
  blurDataURL?: string;
}

export default function ProgressiveImage({
  src,
  alt,
  className = '',
  blurDataURL = 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTAwJSIgaGVpZ2h0PSIxMDAlIiB2aWV3Qm94PSIwIDAgMSAxIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPjxyZWN0IHdpZHRoPSIxMDAlIiBoZWlnaHQ9IjEwMCUiIGZpbGw9IiMxMTExMTEiLz48L3N2Zz4=',
}: ProgressiveImageProps) {
  const [imgSrc, setImgSrc] = useState(blurDataURL);
  const [isLoaded, setIsLoaded] = useState(false);

  useEffect(() => {
    // Create a new image to load the full resolution
    const img = new Image();

    img.onload = () => {
      setImgSrc(src);
      setIsLoaded(true);
    };

    img.onerror = () => {
      // Fallback to placeholder on error
      setImgSrc('/placeholder-property.jpg');
      setIsLoaded(true);
    };

    img.src = src;

    return () => {
      img.onload = null;
      img.onerror = null;
    };
  }, [src]);

  return (
    <div className="relative w-full h-full overflow-hidden">
      {/* Blur placeholder */}
      {!isLoaded && (
        <motion.div
          className="absolute inset-0 bg-gray-900"
          initial={{ opacity: 1 }}
          animate={{ opacity: 0.5 }}
          transition={{ duration: 0.3 }}
        />
      )}

      {/* Actual image */}
      <motion.img
        src={imgSrc}
        alt={alt}
        className={`${className} ${!isLoaded ? 'blur-xl scale-110' : ''}`}
        initial={{ opacity: 0 }}
        animate={{ opacity: isLoaded ? 1 : 0.3 }}
        transition={{ duration: 0.5 }}
        loading="lazy"
      />

      {/* Loading shimmer effect */}
      {!isLoaded && (
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
      )}
    </div>
  );
}
