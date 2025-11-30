'use client';

import { useState } from 'react';

interface PropertyImageProps {
  src?: string | null;
  alt: string;
  className?: string;
  neighborhood?: string;
  propertyType?: string;
}

// Beautiful gradient fallbacks based on property type/neighborhood
const GRADIENTS = [
  'from-purple-500 via-pink-500 to-red-500',
  'from-blue-500 via-cyan-500 to-teal-500',
  'from-orange-500 via-red-500 to-pink-500',
  'from-green-500 via-emerald-500 to-teal-500',
  'from-indigo-500 via-purple-500 to-pink-500',
  'from-yellow-500 via-orange-500 to-red-500',
];

export default function PropertyImage({
  src,
  alt,
  className = '',
  neighborhood = '',
  propertyType = '',
}: PropertyImageProps) {
  const [imageError, setImageError] = useState(false);
  const [loading, setLoading] = useState(true);

  // Pick gradient based on neighborhood/property type for consistency
  const gradientIndex = (neighborhood + propertyType).length % GRADIENTS.length;
  const gradient = GRADIENTS[gradientIndex];

  // Determine icon based on property type
  const getPropertyIcon = () => {
    const type = propertyType.toLowerCase();
    if (type.includes('house')) return '🏡';
    if (type.includes('condo')) return '🏢';
    if (type.includes('apartment')) return '🏠';
    if (type.includes('studio')) return '🏘️';
    if (type.includes('loft')) return '🏭';
    return '🏠';
  };

  if (!src || imageError) {
    // Beautiful gradient fallback
    return (
      <div className={`relative overflow-hidden ${className}`}>
        <div className={`absolute inset-0 bg-gradient-to-br ${gradient} opacity-80`}></div>
        <div className="absolute inset-0 flex flex-col items-center justify-center text-white">
          <div className="text-6xl mb-3 drop-shadow-lg">{getPropertyIcon()}</div>
          <div className="text-sm font-medium opacity-80">{neighborhood || 'Property'}</div>
        </div>
        {/* Subtle pattern overlay */}
        <div
          className="absolute inset-0 opacity-10"
          style={{
            backgroundImage: `url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23ffffff' fill-opacity='1'%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E")`,
          }}
        />
      </div>
    );
  }

  return (
    <div className={`relative overflow-hidden ${className}`}>
      {loading && (
        <div className={`absolute inset-0 bg-gradient-to-br ${gradient} opacity-60 animate-pulse`}></div>
      )}
      <img
        src={src}
        alt={alt}
        className={`w-full h-full object-cover transition-opacity duration-300 ${
          loading ? 'opacity-0' : 'opacity-100'
        }`}
        onLoad={() => setLoading(false)}
        onError={() => {
          setImageError(true);
          setLoading(false);
        }}
      />
    </div>
  );
}
