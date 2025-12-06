'use client';

import { useEffect, useState } from 'react';
import { motion } from 'framer-motion';

interface SnowflakeProps {
  delay: number;
  duration: number;
  left: string;
  size: number;
}

const Snowflake = ({ delay, duration, left, size }: SnowflakeProps) => {
  return (
    <motion.div
      initial={{ y: -20, opacity: 0 }}
      animate={{
        y: '100vh',
        opacity: [0, 1, 1, 0],
        x: [0, Math.random() * 100 - 50, Math.random() * 100 - 50],
      }}
      transition={{
        duration,
        delay,
        repeat: Infinity,
        ease: 'linear',
      }}
      className="absolute pointer-events-none"
      style={{
        left,
        top: '-20px',
      }}
    >
      <div
        className="text-white/70"
        style={{
          fontSize: `${size}px`,
          textShadow: '0 0 10px rgba(255, 255, 255, 0.5)',
        }}
      >
        ❄
      </div>
    </motion.div>
  );
};

interface SnowfallProps {
  enabled?: boolean;
  density?: number; // number of snowflakes (default: 50)
}

export default function Snowfall({ enabled = true, density = 50 }: SnowfallProps) {
  const [snowflakes, setSnowflakes] = useState<SnowflakeProps[]>([]);

  useEffect(() => {
    if (!enabled) {
      setSnowflakes([]);
      return;
    }

    const flakes = Array.from({ length: density }, (_, i) => ({
      delay: Math.random() * 10,
      duration: 10 + Math.random() * 20,
      left: `${Math.random() * 100}%`,
      size: 10 + Math.random() * 15,
    }));

    setSnowflakes(flakes);
  }, [enabled, density]);

  if (!enabled) return null;

  return (
    <div className="fixed inset-0 pointer-events-none z-50 overflow-hidden">
      {snowflakes.map((flake, index) => (
        <Snowflake key={index} {...flake} />
      ))}
    </div>
  );
}
