'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useRouter } from 'next/navigation';
import { ArrowLeft, ChevronLeft, ChevronRight } from 'lucide-react';
import CinematicBackground from '@/components/CinematicBackground';

interface PartnerRole {
  id: string;
  icon: string;
  title: string;
  description: string;
  gradient: string;
}

const PARTNER_ROLES: PartnerRole[] = [
  {
    id: 'agent',
    icon: '🏢',
    title: 'Real Estate Agents',
    description: 'Expert guidance through your home search journey. From first showing to closing day.',
    gradient: 'from-blue-500 to-cyan-500'
  },
  {
    id: 'lender',
    icon: '💰',
    title: 'Mortgage Lenders',
    description: 'Get pre-approved and find the best financing options for your dream home.',
    gradient: 'from-green-500 to-emerald-500'
  },
  {
    id: 'inspector',
    icon: '🔍',
    title: 'Home Inspectors',
    description: 'Thorough inspections to ensure your home is safe, sound, and worth every penny.',
    gradient: 'from-amber-500 to-orange-500'
  },
  {
    id: 'attorney',
    icon: '⚖️',
    title: 'Real Estate Attorneys',
    description: 'Legal expertise to protect your interests and ensure a smooth transaction.',
    gradient: 'from-purple-500 to-pink-500'
  },
  {
    id: 'mover',
    icon: '🚚',
    title: 'Movers',
    description: 'Professional moving services to get you settled into your new home stress-free.',
    gradient: 'from-indigo-500 to-purple-500'
  },
  {
    id: 'cleaner',
    icon: '🧹',
    title: 'Cleaners',
    description: 'Deep cleaning services to make your new space sparkle before move-in day.',
    gradient: 'from-teal-500 to-cyan-500'
  },
  {
    id: 'painter',
    icon: '🎨',
    title: 'Painters',
    description: 'Transform your space with professional painting services and color consultation.',
    gradient: 'from-rose-500 to-pink-500'
  }
];

export default function DirectoryPage() {
  const router = useRouter();
  const [currentIndex, setCurrentIndex] = useState(0);

  const currentRole = PARTNER_ROLES[currentIndex];

  const handleNext = () => {
    setCurrentIndex((prev) => (prev + 1) % PARTNER_ROLES.length);
  };

  const handlePrevious = () => {
    setCurrentIndex((prev) => (prev - 1 + PARTNER_ROLES.length) % PARTNER_ROLES.length);
  };

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
        {/* Coming Soon Badge */}
        <motion.div
          className="inline-flex items-center gap-2 px-4 py-2 mb-6 glass-strong rounded-full border border-purple-500/50"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
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
          className="text-5xl sm:text-6xl font-bold mb-4 bg-gradient-to-r from-white via-purple-200 to-pink-200 bg-clip-text text-transparent"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
          style={{
            textShadow: '0 0 60px rgba(168, 85, 247, 0.3)',
          }}
        >
          Professional Directory
        </motion.h1>

        {/* Description */}
        <motion.p
          className="text-lg text-white/70 mb-8 leading-relaxed"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.4 }}
        >
          if you or anyone you may know would like to be added to the list of HOMEY's trusted partners, let us know.
        </motion.p>

        {/* Spotlight Feature */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.5 }}
          className="mb-8"
        >
          <div className="glass-strong rounded-3xl border border-white/10 p-8 relative overflow-hidden">
            {/* Background gradient based on current role */}
            <div className={`absolute inset-0 bg-gradient-to-br ${currentRole.gradient} opacity-5`} />

            {/* Spotlight Content */}
            <div className="relative">
              <AnimatePresence mode="wait">
                <motion.div
                  key={currentRole.id}
                  initial={{ opacity: 0, x: 100 }}
                  animate={{ opacity: 1, x: 0 }}
                  exit={{ opacity: 0, x: -100 }}
                  transition={{ duration: 0.3 }}
                  className="space-y-6"
                >
                  {/* Icon */}
                  <motion.div
                    className={`inline-flex items-center justify-center w-24 h-24 rounded-2xl bg-gradient-to-br ${currentRole.gradient} shadow-2xl`}
                    animate={{
                      rotate: [0, 5, -5, 0],
                    }}
                    transition={{
                      duration: 6,
                      repeat: Infinity,
                      ease: 'easeInOut',
                    }}
                  >
                    <span className="text-5xl">{currentRole.icon}</span>
                  </motion.div>

                  {/* Title */}
                  <h3 className="text-3xl font-bold text-white">
                    {currentRole.title}
                  </h3>

                  {/* Description */}
                  <p className="text-white/70 text-lg max-w-md mx-auto">
                    {currentRole.description}
                  </p>
                </motion.div>
              </AnimatePresence>

              {/* Navigation Arrows */}
              <div className="flex items-center justify-center gap-4 mt-8">
                <button
                  onClick={handlePrevious}
                  className="w-12 h-12 rounded-full glass-medium border border-white/20 hover:border-white/40 flex items-center justify-center text-white transition-all hover:scale-110"
                >
                  <ChevronLeft className="w-6 h-6" />
                </button>

                {/* Dots indicator */}
                <div className="flex items-center gap-2">
                  {PARTNER_ROLES.map((role, index) => (
                    <button
                      key={role.id}
                      onClick={() => setCurrentIndex(index)}
                      className={`h-2 rounded-full transition-all ${
                        index === currentIndex
                          ? 'w-8 bg-white'
                          : 'w-2 bg-white/30 hover:bg-white/50'
                      }`}
                    />
                  ))}
                </div>

                <button
                  onClick={handleNext}
                  className="w-12 h-12 rounded-full glass-medium border border-white/20 hover:border-white/40 flex items-center justify-center text-white transition-all hover:scale-110"
                >
                  <ChevronRight className="w-6 h-6" />
                </button>
              </div>

              {/* Counter */}
              <p className="text-white/40 text-sm mt-4">
                {currentIndex + 1} of {PARTNER_ROLES.length}
              </p>
            </div>
          </div>
        </motion.div>

        {/* CTA Button */}
        <motion.button
          onClick={() => router.push('/home')}
          className="px-8 py-4 bg-gradient-to-r from-purple-500 to-pink-500 hover:from-purple-600 hover:to-pink-600 rounded-xl font-semibold text-white shadow-lg hover:shadow-xl transition-all"
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ delay: 0.6 }}
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
        >
          Back to Home
        </motion.button>
      </div>
    </main>
  );
}
