'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import ProgressiveImage from './ProgressiveImage';

interface VirtualWalkthroughProps {
  isOpen: boolean;
  onClose: () => void;
  images: string[];
  address: string;
}

// Smart room detection from image filenames/metadata
const detectRoomType = (imageUrl: string, index: number): string => {
  const url = imageUrl.toLowerCase();

  if (url.includes('kitchen')) return 'Kitchen';
  if (url.includes('bedroom') || url.includes('master')) return `Bedroom ${index}`;
  if (url.includes('bathroom') || url.includes('bath')) return 'Bathroom';
  if (url.includes('living')) return 'Living Room';
  if (url.includes('dining')) return 'Dining Room';
  if (url.includes('office')) return 'Office';
  if (url.includes('balcony') || url.includes('patio')) return 'Outdoor Space';
  if (url.includes('entrance') || url.includes('lobby')) return 'Entrance';
  if (url.includes('gym') || url.includes('fitness')) return 'Gym';
  if (url.includes('amenity')) return 'Amenities';

  // Default labels
  const defaultLabels = [
    'Main View',
    'Living Area',
    'Bedroom',
    'Kitchen',
    'Bathroom',
    'Additional Room',
    'Building Exterior',
    'Common Area',
  ];

  return defaultLabels[index % defaultLabels.length];
};

export default function VirtualWalkthrough({
  isOpen,
  onClose,
  images,
  address,
}: VirtualWalkthroughProps) {
  const [currentIndex, setCurrentIndex] = useState(0);
  const [direction, setDirection] = useState(0);

  const handleNext = () => {
    setDirection(1);
    setCurrentIndex((prev) => (prev + 1) % images.length);
  };

  const handlePrevious = () => {
    setDirection(-1);
    setCurrentIndex((prev) => (prev - 1 + images.length) % images.length);
  };

  const handleDragEnd = (_: any, info: any) => {
    if (info.offset.x > 100) {
      handlePrevious();
    } else if (info.offset.x < -100) {
      handleNext();
    }
  };

  const currentRoom = detectRoomType(images[currentIndex], currentIndex);

  const slideVariants = {
    enter: (direction: number) => ({
      x: direction > 0 ? 1000 : -1000,
      opacity: 0,
    }),
    center: {
      zIndex: 1,
      x: 0,
      opacity: 1,
    },
    exit: (direction: number) => ({
      zIndex: 0,
      x: direction < 0 ? 1000 : -1000,
      opacity: 0,
    }),
  };

  return (
    <AnimatePresence>
      {isOpen && (
        <>
          {/* Backdrop */}
          <motion.div
            className="fixed inset-0 z-[300] bg-black/95"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={onClose}
          />

          {/* Walkthrough Interface */}
          <motion.div
            className="fixed inset-0 z-[301] flex flex-col"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={(e) => e.stopPropagation()}
          >
            {/* Header */}
            <div className="absolute top-0 left-0 right-0 z-10 bg-gradient-to-b from-black/80 to-transparent p-6">
              <div className="flex items-center justify-between">
                <div>
                  <h2 className="text-white text-xl font-bold">{address}</h2>
                  <p className="text-white/60 text-sm mt-1">
                    {currentIndex + 1} of {images.length} • {currentRoom}
                  </p>
                </div>
                <button
                  onClick={onClose}
                  className="w-11 h-11 rounded-full bg-white/10 hover:bg-white/20 backdrop-blur-md flex items-center justify-center text-white transition-colors"
                >
                  ✕
                </button>
              </div>
            </div>

            {/* Image Carousel */}
            <div className="flex-1 relative overflow-hidden flex items-center justify-center">
              <AnimatePresence initial={false} custom={direction}>
                <motion.div
                  key={currentIndex}
                  custom={direction}
                  variants={slideVariants}
                  initial="enter"
                  animate="center"
                  exit="exit"
                  transition={{
                    x: { type: 'spring', stiffness: 300, damping: 30 },
                    opacity: { duration: 0.2 },
                  }}
                  drag="x"
                  dragConstraints={{ left: 0, right: 0 }}
                  dragElastic={0.3}
                  onDragEnd={handleDragEnd}
                  className="absolute inset-0"
                >
                  <ProgressiveImage
                    src={images[currentIndex]}
                    alt={`${currentRoom} - ${address}`}
                    className="w-full h-full object-contain"
                  />

                  {/* Room Label Overlay */}
                  <div className="absolute bottom-24 left-1/2 -translate-x-1/2">
                    <motion.div
                      initial={{ y: 20, opacity: 0 }}
                      animate={{ y: 0, opacity: 1 }}
                      className="px-6 py-3 bg-black/60 backdrop-blur-md rounded-full border border-white/20"
                    >
                      <p className="text-white font-semibold">{currentRoom}</p>
                    </motion.div>
                  </div>
                </motion.div>
              </AnimatePresence>

              {/* Navigation Buttons */}
              {currentIndex > 0 && (
                <button
                  onClick={handlePrevious}
                  className="absolute left-4 w-14 h-14 rounded-full bg-black/40 hover:bg-black/60 backdrop-blur-md flex items-center justify-center text-white text-2xl transition-colors z-20"
                >
                  ←
                </button>
              )}

              {currentIndex < images.length - 1 && (
                <button
                  onClick={handleNext}
                  className="absolute right-4 w-14 h-14 rounded-full bg-black/40 hover:bg-black/60 backdrop-blur-md flex items-center justify-center text-white text-2xl transition-colors z-20"
                >
                  →
                </button>
              )}
            </div>

            {/* Footer: Thumbnail Strip */}
            <div className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/80 to-transparent p-6">
              <div className="flex gap-2 overflow-x-auto scrollbar-hide pb-2">
                {images.map((image, index) => (
                  <motion.button
                    key={index}
                    onClick={() => {
                      setDirection(index > currentIndex ? 1 : -1);
                      setCurrentIndex(index);
                    }}
                    whileTap={{ scale: 0.95 }}
                    className={`flex-shrink-0 w-20 h-20 rounded-xl overflow-hidden border-2 transition-all ${
                      index === currentIndex
                        ? 'border-primary scale-110'
                        : 'border-white/20 opacity-60 hover:opacity-100'
                    }`}
                  >
                    <img
                      src={image}
                      alt={detectRoomType(image, index)}
                      className="w-full h-full object-cover"
                    />
                  </motion.button>
                ))}
              </div>

              {/* Progress Dots */}
              <div className="flex items-center justify-center gap-2 mt-4">
                {images.map((_, index) => (
                  <button
                    key={index}
                    onClick={() => {
                      setDirection(index > currentIndex ? 1 : -1);
                      setCurrentIndex(index);
                    }}
                    className={`h-2 rounded-full transition-all ${
                      index === currentIndex ? 'w-8 bg-primary' : 'w-2 bg-white/30'
                    }`}
                  />
                ))}
              </div>
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
}
