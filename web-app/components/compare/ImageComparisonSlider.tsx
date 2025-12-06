'use client';

import { useState, useRef } from 'react';
import { motion } from 'framer-motion';
import { ChevronLeft, ChevronRight, Home } from 'lucide-react';
import type { Listing } from '@/lib/types';

interface ImageComparisonSliderProps {
  listings: Listing[];
  selectedRoom: 'living' | 'kitchen' | 'bedroom' | 'bathroom';
  onRoomChange: (room: 'living' | 'kitchen' | 'bedroom' | 'bathroom') => void;
}

export default function ImageComparisonSlider({
  listings,
  selectedRoom,
  onRoomChange
}: ImageComparisonSliderProps) {
  const [sliderPosition, setSliderPosition] = useState(50);
  const [isDragging, setIsDragging] = useState(false);
  const containerRef = useRef<HTMLDivElement>(null);

  const handleMouseDown = () => {
    setIsDragging(true);
  };

  const handleMouseUp = () => {
    setIsDragging(false);
  };

  const handleMouseMove = (e: React.MouseEvent<HTMLDivElement>) => {
    if (!isDragging || !containerRef.current) return;

    const rect = containerRef.current.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const percentage = (x / rect.width) * 100;
    setSliderPosition(Math.max(0, Math.min(100, percentage)));
  };

  const handleTouchMove = (e: React.TouchEvent<HTMLDivElement>) => {
    if (!containerRef.current) return;

    const rect = containerRef.current.getBoundingClientRect();
    const x = e.touches[0].clientX - rect.left;
    const percentage = (x / rect.width) * 100;
    setSliderPosition(Math.max(0, Math.min(100, percentage)));
  };

  const rooms = [
    { id: 'living' as const, label: 'Living Room' },
    { id: 'kitchen' as const, label: 'Kitchen' },
    { id: 'bedroom' as const, label: 'Bedroom' },
    { id: 'bathroom' as const, label: 'Bathroom' },
  ];

  // For demo purposes, use the first image of each property
  // In a real app, you'd have images categorized by room type
  const getImageForRoom = (listing: Listing, roomType: string): string => {
    const images = listing.image_urls || [];
    if (images.length === 0) return '';

    // Simple heuristic: distribute images across rooms
    const roomIndex = rooms.findIndex(r => r.id === roomType);
    const imageIndex = roomIndex % images.length;
    return images[imageIndex] || images[0];
  };

  if (listings.length < 2) {
    return null;
  }

  const leftListing = listings[0];
  const rightListing = listings[1];

  const leftImage = getImageForRoom(leftListing, selectedRoom);
  const rightImage = getImageForRoom(rightListing, selectedRoom);

  return (
    <div className="relative overflow-hidden rounded-3xl bg-gradient-to-br from-primary/10 via-purple-600/10 to-pink-500/10 border border-white/10 p-8">
      {/* Animated blur effect */}
      <div className="absolute bottom-0 left-0 w-48 h-48 bg-primary/20 rounded-full blur-3xl opacity-50 animate-pulse" />

      <div className="relative z-10">
        {/* Room Selector */}
        <div className="flex items-center gap-3 mb-6 overflow-x-auto">
          {rooms.map((room) => (
            <button
              key={room.id}
              onClick={() => onRoomChange(room.id)}
              className={`px-5 py-2.5 rounded-2xl font-medium whitespace-nowrap transition-all ${
                selectedRoom === room.id
                  ? 'bg-gradient-to-r from-primary to-purple-500 text-white shadow-lg shadow-primary/20'
                  : 'glass-medium text-white/60 hover:text-white hover:bg-white/10'
              }`}
            >
              {room.label}
            </button>
          ))}
        </div>

        {/* Comparison Slider */}
        <div
          ref={containerRef}
          className="relative h-96 rounded-2xl overflow-hidden cursor-col-resize select-none"
          onMouseDown={handleMouseDown}
          onMouseUp={handleMouseUp}
          onMouseMove={handleMouseMove}
          onMouseLeave={handleMouseUp}
          onTouchMove={handleTouchMove}
        >
          {/* Left Image (Property 1) */}
          <div className="absolute inset-0 bg-gradient-to-br from-purple-900 to-blue-900">
            {leftImage ? (
              <img
                src={leftImage}
                alt={`${leftListing.address} - ${selectedRoom}`}
                className="w-full h-full object-cover"
                draggable={false}
              />
            ) : (
              <div className="w-full h-full flex items-center justify-center">
                <Home className="w-16 h-16 text-white/30" />
              </div>
            )}

            {/* Label */}
            <div className="absolute top-4 left-4 px-4 py-2 bg-purple-500/80 backdrop-blur-sm rounded-full">
              <span className="text-white text-sm font-semibold">Property 1</span>
            </div>
          </div>

          {/* Right Image (Property 2) with clip path */}
          <div
            className="absolute inset-0 bg-gradient-to-br from-pink-900 to-purple-900"
            style={{ clipPath: `inset(0 0 0 ${sliderPosition}%)` }}
          >
            {rightImage ? (
              <img
                src={rightImage}
                alt={`${rightListing.address} - ${selectedRoom}`}
                className="w-full h-full object-cover"
                draggable={false}
              />
            ) : (
              <div className="w-full h-full flex items-center justify-center">
                <Home className="w-16 h-16 text-white/30" />
              </div>
            )}

            {/* Label */}
            <div className="absolute top-4 right-4 px-4 py-2 bg-pink-500/80 backdrop-blur-sm rounded-full">
              <span className="text-white text-sm font-semibold">Property 2</span>
            </div>
          </div>

          {/* Slider Handle */}
          <div
            className="absolute inset-y-0 w-1 bg-white cursor-col-resize"
            style={{ left: `${sliderPosition}%` }}
          >
            <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-14 h-14 bg-white rounded-full shadow-xl flex items-center justify-center">
              <ChevronLeft className="w-6 h-6 text-gray-800 absolute left-1.5" />
              <ChevronRight className="w-6 h-6 text-gray-800 absolute right-1.5" />
            </div>
          </div>
        </div>

        {/* Property Info */}
        <div className="grid grid-cols-2 gap-4 mt-6">
          <div className="glass-medium rounded-2xl p-4">
            <p className="text-xs text-white/50 mb-2">Property 1</p>
            <p className="text-base text-white font-semibold line-clamp-1">
              {leftListing.address}
            </p>
            <p className="text-sm text-white/70 mt-2 font-semibold">
              ${leftListing.price?.toLocaleString()}/mo
            </p>
          </div>

          <div className="glass-medium rounded-2xl p-4">
            <p className="text-xs text-white/50 mb-2">Property 2</p>
            <p className="text-base text-white font-semibold line-clamp-1">
              {rightListing.address}
            </p>
            <p className="text-sm text-white/70 mt-2 font-semibold">
              ${rightListing.price?.toLocaleString()}/mo
            </p>
          </div>
        </div>

        <p className="text-sm text-white/40 mt-4 text-center">
          Drag the slider to compare room photos side-by-side
        </p>
      </div>
    </div>
  );
}
