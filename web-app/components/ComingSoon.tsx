'use client';

import { motion } from 'framer-motion';
import { useRouter } from 'next/navigation';
import { ArrowLeft } from 'lucide-react';
import CinematicBackground from './CinematicBackground';

interface ComingSoonProps {
  icon: string;
  title: string;
  description: string;
  gradient: string;
  additionalContent?: React.ReactNode;
}

export default function ComingSoon({ icon, title, description, gradient, additionalContent }: ComingSoonProps) {
  const router = useRouter();

  return (
    <main className="relative min-h-screen flex items-center justify-center overflow-hidden">
      <CinematicBackground timeOfDay="sunset" />

      {/* Animated Background */}
      <div className="absolute inset-0 bg-gradient-to-br from-slate-950 via-purple-950 to-pink-950">
        {/* Animated gradient orbs */}
        <motion.div
          className="absolute top-0 left-0 w-[600px] h-[600px] rounded-full bg-gradient-to-br from-purple-500/30 to-pink-500/30 blur-3xl"
          animate={{
            x: [0, 100, 0],
            y: [0, 50, 0],
            scale: [1, 1.2, 1],
          }}
          transition={{
            duration: 20,
            repeat: Infinity,
            ease: 'easeInOut'
          }}
        />
        <motion.div
          className="absolute bottom-0 right-0 w-[500px] h-[500px] rounded-full bg-gradient-to-br from-blue-500/30 to-purple-500/30 blur-3xl"
          animate={{
            x: [0, -80, 0],
            y: [0, -60, 0],
            scale: [1, 1.3, 1],
          }}
          transition={{
            duration: 18,
            repeat: Infinity,
            ease: 'easeInOut'
          }}
        />

        {/* Floating particles */}
        {[...Array(15)].map((_, i) => (
          <motion.div
            key={i}
            className="absolute w-2 h-2 rounded-full bg-white/20"
            style={{
              left: `${Math.random() * 100}%`,
              top: `${Math.random() * 100}%`,
            }}
            animate={{
              y: [0, -30, 0],
              opacity: [0.2, 0.5, 0.2],
            }}
            transition={{
              duration: 3 + Math.random() * 4,
              repeat: Infinity,
              delay: Math.random() * 2,
            }}
          />
        ))}

        {/* Radial gradient overlay */}
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_center,transparent_0%,rgba(0,0,0,0.4)_100%)]" />
      </div>

      {/* Back button */}
      <motion.button
        onClick={() => router.push('/home')}
        className="fixed top-6 left-6 z-50 flex items-center gap-2 px-4 py-2 glass-strong rounded-full border border-white/10 hover:border-white/20 transition-all text-white/90 hover:text-white"
        initial={{ opacity: 0, x: -20 }}
        animate={{ opacity: 1, x: 0 }}
        transition={{ delay: 0.3 }}
        whileHover={{ scale: 1.05 }}
        whileTap={{ scale: 0.95 }}
      >
        <ArrowLeft className="w-4 h-4" />
        <span className="text-sm font-medium">Back</span>
      </motion.button>

      {/* Content */}
      <div className="relative z-10 text-center px-8 max-w-2xl">
        {/* Animated Icon */}
        <motion.div
          className="mb-8"
          initial={{ scale: 0, opacity: 0, rotate: -180 }}
          animate={{ scale: 1, opacity: 1, rotate: 0 }}
          transition={{
            type: 'spring',
            stiffness: 200,
            damping: 20,
            delay: 0.2
          }}
        >
          <motion.div
            className={`inline-flex items-center justify-center w-32 h-32 rounded-3xl bg-gradient-to-br ${gradient} shadow-2xl`}
            animate={{
              rotate: [0, 5, -5, 0],
            }}
            transition={{
              duration: 6,
              repeat: Infinity,
              ease: 'easeInOut',
            }}
          >
            <span className="text-6xl">{icon}</span>
          </motion.div>
        </motion.div>

        {/* Coming Soon Badge */}
        <motion.div
          className="inline-flex items-center gap-2 px-4 py-2 mb-6 glass-strong rounded-full border border-purple-500/50"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.4 }}
        >
          <motion.div
            className="w-2 h-2 rounded-full bg-purple-400"
            animate={{
              scale: [1, 1.5, 1],
              opacity: [1, 0.5, 1],
            }}
            transition={{
              duration: 2,
              repeat: Infinity,
              ease: 'easeInOut',
            }}
          />
          <span className="text-sm font-semibold text-purple-200 uppercase tracking-wider">
            Coming Soon
          </span>
        </motion.div>

        {/* Title */}
        <motion.h1
          className="text-5xl sm:text-6xl font-bold mb-6 bg-gradient-to-r from-white via-purple-200 to-pink-200 bg-clip-text text-transparent"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.5 }}
          style={{
            textShadow: '0 0 60px rgba(168, 85, 247, 0.3)',
          }}
        >
          {title}
        </motion.h1>

        {/* Description */}
        <motion.p
          className="text-xl text-white/70 mb-8 leading-relaxed"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.6 }}
        >
          {description}
        </motion.p>

        {/* Additional Content */}
        {additionalContent && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.65 }}
            className="mb-8"
          >
            {additionalContent}
          </motion.div>
        )}

        {/* CTA Button */}
        <motion.button
          onClick={() => router.push('/home')}
          className="px-8 py-4 bg-gradient-to-r from-purple-500 to-pink-500 hover:from-purple-600 hover:to-pink-600 rounded-xl font-semibold text-white shadow-lg hover:shadow-xl transition-all"
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ delay: 0.7 }}
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
        >
          Back to Home
        </motion.button>
      </div>
    </main>
  );
}
