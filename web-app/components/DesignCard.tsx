'use client';

import { useState } from 'react';
import { motion, useMotionValue, useTransform, PanInfo } from 'framer-motion';

interface DesignInspiration {
  id: string;
  image_url: string;
  title?: string;
  description?: string;
  room_type?: string;
  style_tags?: string[];
  color_palette?: string[];
}

interface DesignCardProps {
  design: DesignInspiration;
  onSwipe: (direction: 'left' | 'right' | 'up') => void;
  style?: React.CSSProperties;
}

export default function DesignCard({ design, onSwipe, style }: DesignCardProps) {
  const [exitDirection, setExitDirection] = useState<'left' | 'right' | 'up' | null>(null);

  const x = useMotionValue(0);
  const y = useMotionValue(0);

  const rotate = useTransform(x, [-200, 200], [-15, 15]);

  const passOpacity = useTransform(x, [-150, -50, 0], [1, 0, 0]);
  const likeOpacity = useTransform(x, [0, 50, 150], [0, 0, 1]);
  const loveOpacity = useTransform(y, [-150, -50, 0], [1, 0, 0]);

  const handleDragEnd = (_: any, info: PanInfo) => {
    const threshold = 100;
    const upThreshold = -100;

    if (info.offset.y < upThreshold) {
      setExitDirection('up');
      onSwipe('up');
    } else if (info.offset.x > threshold) {
      setExitDirection('right');
      onSwipe('right');
    } else if (info.offset.x < -threshold) {
      setExitDirection('left');
      onSwipe('left');
    }
  };

  const exitVariants = {
    left: { x: -500, opacity: 0, transition: { duration: 0.3 } },
    right: { x: 500, opacity: 0, transition: { duration: 0.3 } },
    up: { y: -500, opacity: 0, transition: { duration: 0.3 } },
  };

  const formatRoomType = (room?: string) => {
    if (!room) return '';
    return room.split('_').map(word => word.charAt(0).toUpperCase() + word.slice(1)).join(' ');
  };

  return (
    <motion.div
      className="absolute w-full h-full"
      style={{
        x,
        y,
        rotate,
        cursor: 'grab',
        ...style,
      }}
      drag
      dragConstraints={{ left: 0, right: 0, top: 0, bottom: 0 }}
      dragElastic={1}
      onDragEnd={handleDragEnd}
      animate={exitDirection ? exitVariants[exitDirection] : {}}
      whileTap={{ cursor: 'grabbing' }}
    >
      <div className="w-full h-full rounded-3xl overflow-hidden glass-strong shadow-2xl">
        {/* Design Image */}
        <div className="relative h-4/5">
          <img
            src={design.image_url}
            alt={design.title || 'Design inspiration'}
            className="w-full h-full object-cover"
            loading="lazy"
          />

          {/* Gradient Overlay */}
          <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent" />

          {/* Action Overlays */}
          <motion.div
            className="absolute top-8 left-8 px-6 py-3 bg-red-500 text-white font-bold text-2xl rounded-2xl border-4 border-white shadow-lg rotate-[-15deg]"
            style={{ opacity: passOpacity }}
          >
            PASS
          </motion.div>

          <motion.div
            className="absolute top-8 right-8 px-6 py-3 bg-green-500 text-white font-bold text-2xl rounded-2xl border-4 border-white shadow-lg rotate-[15deg]"
            style={{ opacity: likeOpacity }}
          >
            LIKE
          </motion.div>

          <motion.div
            className="absolute top-8 left-1/2 -translate-x-1/2 px-6 py-3 bg-primary text-white font-bold text-2xl rounded-2xl border-4 border-white shadow-lg"
            style={{ opacity: loveOpacity }}
          >
            💕 SAVE
          </motion.div>

          {/* Tags */}
          <div className="absolute top-4 left-4 flex flex-wrap gap-2">
            {design.room_type && (
              <span className="px-3 py-1 bg-white/20 backdrop-blur-sm rounded-full text-white text-xs font-bold border border-white/30">
                {formatRoomType(design.room_type)}
              </span>
            )}
          </div>

          {/* Content Overlay */}
          <div className="absolute bottom-0 left-0 right-0 p-6">
            {design.title && (
              <h2 className="text-3xl font-bold text-white mb-2">{design.title}</h2>
            )}
            {design.description && (
              <p className="text-white/90 mb-3 line-clamp-2">{design.description}</p>
            )}
            {design.style_tags && design.style_tags.length > 0 && (
              <div className="flex flex-wrap gap-2">
                {design.style_tags.slice(0, 4).map((tag, i) => (
                  <span
                    key={i}
                    className="px-3 py-1 bg-white/10 backdrop-blur-sm rounded-full text-white/80 text-xs font-medium border border-white/20"
                  >
                    {tag}
                  </span>
                ))}
              </div>
            )}
          </div>
        </div>

        {/* Color Palette */}
        {design.color_palette && design.color_palette.length > 0 && (
          <div className="h-1/5 bg-gradient-to-b from-black/80 to-black/90 backdrop-blur-sm p-6">
            <div className="flex items-center gap-3">
              <span className="text-white/60 text-sm font-medium">Colors:</span>
              <div className="flex gap-2">
                {design.color_palette.map((color, i) => (
                  <div
                    key={i}
                    className="w-10 h-10 rounded-full border-2 border-white/30 shadow-lg"
                    style={{ backgroundColor: color }}
                    title={color}
                  />
                ))}
              </div>
            </div>
          </div>
        )}
      </div>
    </motion.div>
  );
}
