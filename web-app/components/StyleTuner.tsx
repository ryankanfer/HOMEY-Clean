'use client';

import { useState } from 'react';
import { motion, AnimatePresence, useMotionValue, useTransform } from 'framer-motion';
import { X, Heart, ThumbsDown, RotateCcw } from 'lucide-react';

interface StyleCard {
  id: string;
  imageUrl: string;
  style: string;
  tags: string[];
}

interface StyleTunerProps {
  isOpen: boolean;
  onClose: () => void;
}

const sampleCards: StyleCard[] = [
  {
    id: '1',
    imageUrl: 'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?w=800&q=80',
    style: 'Modern Minimalist',
    tags: ['Clean Lines', 'Neutral', 'Open Space']
  },
  {
    id: '2',
    imageUrl: 'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=800&q=80',
    style: 'Industrial Loft',
    tags: ['Exposed Brick', 'Metal', 'Urban']
  },
  {
    id: '3',
    imageUrl: 'https://images.unsplash.com/photo-1615875605825-5eb9bb5d52ac?w=800&q=80',
    style: 'Scandinavian',
    tags: ['Wood', 'Cozy', 'Light']
  },
  {
    id: '4',
    imageUrl: 'https://images.unsplash.com/photo-1616137466211-f939a420be84?w=800&q=80',
    style: 'Mid-Century Modern',
    tags: ['Retro', 'Warm', 'Iconic']
  },
  {
    id: '5',
    imageUrl: 'https://images.unsplash.com/photo-1615529182904-14819c35db37?w=800&q=80',
    style: 'Bohemian',
    tags: ['Eclectic', 'Colorful', 'Textured']
  }
];

export default function StyleTuner({ isOpen, onClose }: StyleTunerProps) {
  const [cards, setCards] = useState(sampleCards);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [swipeCount, setSwipeCount] = useState(0);

  const x = useMotionValue(0);
  const rotate = useTransform(x, [-200, 200], [-25, 25]);
  const opacity = useTransform(x, [-200, -100, 0, 100, 200], [0, 1, 1, 1, 0]);

  const handleDragEnd = (_: any, info: any) => {
    if (Math.abs(info.offset.x) > 100) {
      const direction = info.offset.x > 0 ? 'like' : 'pass';
      handleSwipe(direction);
    } else {
      x.set(0);
    }
  };

  const handleSwipe = (direction: 'like' | 'pass') => {
    const newIndex = currentIndex + 1;
    setCurrentIndex(newIndex);
    setSwipeCount(prev => prev + 1);
    x.set(0);

    // Track the swipe
    console.log(`Swiped ${direction} on ${cards[currentIndex]?.style}`);

    // Close modal after 10 swipes
    if (swipeCount >= 9) {
      setTimeout(() => {
        onClose();
        // Reset for next time
        setCurrentIndex(0);
        setSwipeCount(0);
      }, 500);
    }
  };

  const handleUndo = () => {
    if (currentIndex > 0) {
      setCurrentIndex(currentIndex - 1);
      setSwipeCount(Math.max(0, swipeCount - 1));
    }
  };

  const currentCard = cards[currentIndex];
  const progress = Math.min((swipeCount / 10) * 100, 100);

  return (
    <AnimatePresence>
      {isOpen && (
        <motion.div
          className="fixed inset-0 z-[200] bg-black/80 backdrop-blur-md flex items-center justify-center p-4"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          onClick={onClose}
        >
          <motion.div
            className="w-full max-w-md"
            initial={{ scale: 0.9, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            exit={{ scale: 0.9, opacity: 0 }}
            onClick={(e) => e.stopPropagation()}
          >
            {/* Header */}
            <div className="mb-6">
              <div className="flex items-center justify-between mb-4">
                <div>
                  <h2 className="text-2xl font-bold text-white mb-1">Style Tuner</h2>
                  <p className="text-white/60 text-sm">Swipe to train your aesthetic</p>
                </div>
                <button
                  onClick={onClose}
                  className="w-10 h-10 rounded-full bg-white/10 hover:bg-white/20 flex items-center justify-center transition-colors"
                >
                  <X className="w-5 h-5 text-white" />
                </button>
              </div>

              {/* Progress Bar */}
              <div className="flex items-center gap-3">
                <div className="flex-1 h-2 bg-white/10 rounded-full overflow-hidden">
                  <motion.div
                    className="h-full bg-gradient-to-r from-purple-500 to-pink-500"
                    initial={{ width: 0 }}
                    animate={{ width: `${progress}%` }}
                  />
                </div>
                <span className="text-white/60 text-sm font-medium">{swipeCount}/10</span>
              </div>
            </div>

            {/* Card Stack */}
            <div className="relative h-[500px] mb-6">
              {currentCard ? (
                <>
                  {/* Next Card (Background) */}
                  {cards[currentIndex + 1] && (
                    <div className="absolute inset-0 rounded-3xl overflow-hidden opacity-50 scale-95">
                      <img
                        src={cards[currentIndex + 1].imageUrl}
                        alt="Next"
                        className="w-full h-full object-cover"
                      />
                    </div>
                  )}

                  {/* Current Card */}
                  <motion.div
                    className="absolute inset-0 rounded-3xl overflow-hidden shadow-2xl cursor-grab active:cursor-grabbing"
                    drag="x"
                    dragConstraints={{ left: 0, right: 0 }}
                    dragElastic={0.7}
                    onDragEnd={handleDragEnd}
                    style={{ x, rotate, opacity }}
                  >
                    <img
                      src={currentCard.imageUrl}
                      alt={currentCard.style}
                      className="w-full h-full object-cover"
                    />

                    {/* Gradient Overlay */}
                    <div className="absolute inset-0 bg-gradient-to-t from-black via-black/40 to-transparent" />

                    {/* Card Info */}
                    <div className="absolute bottom-0 left-0 right-0 p-6">
                      <h3 className="text-white text-2xl font-bold mb-2">{currentCard.style}</h3>
                      <div className="flex flex-wrap gap-2">
                        {currentCard.tags.map(tag => (
                          <span
                            key={tag}
                            className="px-3 py-1 bg-white/20 backdrop-blur-sm rounded-full text-white text-xs font-medium"
                          >
                            {tag}
                          </span>
                        ))}
                      </div>
                    </div>

                    {/* Swipe Indicators */}
                    <motion.div
                      className="absolute top-1/2 left-8 -translate-y-1/2"
                      style={{ opacity: useTransform(x, [0, -100], [0, 1]) }}
                    >
                      <div className="w-24 h-24 rounded-full border-4 border-red-500 flex items-center justify-center rotate-[-20deg]">
                        <span className="text-red-500 text-2xl font-bold">NOPE</span>
                      </div>
                    </motion.div>

                    <motion.div
                      className="absolute top-1/2 right-8 -translate-y-1/2"
                      style={{ opacity: useTransform(x, [0, 100], [0, 1]) }}
                    >
                      <div className="w-24 h-24 rounded-full border-4 border-green-500 flex items-center justify-center rotate-[20deg]">
                        <span className="text-green-500 text-2xl font-bold">LIKE</span>
                      </div>
                    </motion.div>
                  </motion.div>
                </>
              ) : (
                // All Done
                <div className="absolute inset-0 bg-gradient-to-br from-purple-900/50 to-pink-900/50 rounded-3xl flex items-center justify-center">
                  <div className="text-center">
                    <div className="text-6xl mb-4">🎉</div>
                    <h3 className="text-white text-2xl font-bold mb-2">All Done!</h3>
                    <p className="text-white/70">Your style profile has been updated</p>
                  </div>
                </div>
              )}
            </div>

            {/* Action Buttons */}
            <div className="flex items-center justify-center gap-4">
              <button
                onClick={() => handleSwipe('pass')}
                disabled={!currentCard}
                className="w-16 h-16 rounded-full bg-white/10 hover:bg-red-500/20 border-2 border-white/20 hover:border-red-500 flex items-center justify-center transition-all disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <ThumbsDown className="w-6 h-6 text-white" />
              </button>

              <button
                onClick={handleUndo}
                disabled={currentIndex === 0}
                className="w-14 h-14 rounded-full bg-white/10 hover:bg-white/20 flex items-center justify-center transition-all disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <RotateCcw className="w-5 h-5 text-white" />
              </button>

              <button
                onClick={() => handleSwipe('like')}
                disabled={!currentCard}
                className="w-16 h-16 rounded-full bg-white/10 hover:bg-green-500/20 border-2 border-white/20 hover:border-green-500 flex items-center justify-center transition-all disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <Heart className="w-6 h-6 text-white" />
              </button>
            </div>

            {/* Instructions */}
            <p className="text-center text-white/40 text-sm mt-6">
              Swipe right to like • Swipe left to pass
            </p>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
