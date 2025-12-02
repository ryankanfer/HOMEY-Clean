'use client';

import { motion } from 'framer-motion';
import { Quote } from 'lucide-react';

interface VibeCheckCardProps {
  neighborhood: string;
  quote: string;
  author: string;
  authorTitle: string;
  imageUrl: string;
  category?: string;
}

export default function VibeCheckCard({
  neighborhood,
  quote,
  author,
  authorTitle,
  imageUrl,
  category = 'Vibe Check'
}: VibeCheckCardProps) {
  return (
    <motion.div
      className="relative min-w-[320px] h-[400px] rounded-2xl overflow-hidden cursor-pointer group"
      whileHover={{ scale: 1.02 }}
      whileTap={{ scale: 0.98 }}
    >
      {/* Background Image */}
      <div
        className="absolute inset-0 bg-cover bg-center transition-transform duration-700 group-hover:scale-110"
        style={{ backgroundImage: `url(${imageUrl})` }}
      />

      {/* Gradient Overlay */}
      <div className="absolute inset-0 bg-gradient-to-t from-black via-black/60 to-transparent" />

      {/* Content */}
      <div className="relative h-full flex flex-col justify-between p-6">
        {/* Category Badge */}
        <div className="flex items-center gap-2">
          <span className="px-3 py-1.5 rounded-full bg-emerald-500/20 backdrop-blur-sm border border-emerald-500/50 text-emerald-300 text-xs font-semibold">
            {category}
          </span>
        </div>

        {/* Quote Section */}
        <div>
          <Quote className="w-8 h-8 text-white/40 mb-3" />
          <p className="text-white text-lg leading-relaxed mb-4 font-light">
            "{quote}"
          </p>
          <div>
            <div className="text-white font-semibold">{author}</div>
            <div className="text-white/60 text-sm">{authorTitle} • {neighborhood}</div>
          </div>
        </div>
      </div>
    </motion.div>
  );
}
