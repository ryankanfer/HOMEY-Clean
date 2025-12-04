'use client';

import { useRouter } from 'next/navigation';
import { motion } from 'framer-motion';
import { Shield } from 'lucide-react';

interface AdminPillProps {
  position?: 'bottom-left' | 'bottom-right';
}

export default function AdminPill({ position = 'bottom-left' }: AdminPillProps) {
  const router = useRouter();

  const positionClasses = {
    'bottom-left': 'bottom-20 left-4',
    'bottom-right': 'bottom-20 right-4',
  };

  return (
    <motion.button
      onClick={() => router.push('/admin')}
      className={`fixed ${positionClasses[position]} z-[9999] px-4 py-3 bg-gradient-to-r from-yellow-500 to-orange-500 hover:from-orange-500 hover:to-yellow-500 rounded-full shadow-2xl transition-all flex items-center gap-2 group border-2 border-yellow-600`}
      initial={{ opacity: 0, scale: 0.8, y: 20 }}
      animate={{ opacity: 1, scale: 1, y: 0 }}
      whileHover={{ scale: 1.08, boxShadow: '0 20px 60px rgba(251, 191, 36, 0.4)' }}
      whileTap={{ scale: 0.95 }}
    >
      <Shield className="w-5 h-5 text-black" />
      <span className="text-sm font-bold text-black uppercase tracking-wider">
        Admin
      </span>
      <motion.div
        className="w-2 h-2 rounded-full bg-black"
        animate={{ scale: [1, 1.3, 1] }}
        transition={{ duration: 1.5, repeat: Infinity }}
      />
    </motion.button>
  );
}
