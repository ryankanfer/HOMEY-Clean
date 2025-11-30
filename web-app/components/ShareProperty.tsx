'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import type { Listing } from '@/lib/types';
import BottomSheet from './BottomSheet';

interface SharePropertyProps {
  isOpen: boolean;
  onClose: () => void;
  property: Listing;
}

export default function ShareProperty({
  isOpen,
  onClose,
  property,
}: SharePropertyProps) {
  const [copied, setCopied] = useState(false);

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      maximumFractionDigits: 0,
    }).format(price);
  };

  const shareUrl = `${window.location.origin}/scout/${property.id}`;

  const shareText = `Check out this ${property.bedrooms || ''} bedroom in ${property.neighborhood} for ${formatPrice(property.price)}/mo! Found via HOMEY 🏠`;

  const handleNativeShare = async () => {
    if (navigator.share) {
      try {
        await navigator.share({
          title: `${property.neighborhood} - ${formatPrice(property.price)}/mo`,
          text: shareText,
          url: shareUrl,
        });
      } catch (err) {
        console.error('Share failed:', err);
      }
    }
  };

  const handleCopyLink = () => {
    navigator.clipboard.writeText(shareUrl);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const downloadShareCard = () => {
    // Create a beautiful share card image
    const canvas = document.createElement('canvas');
    canvas.width = 1200;
    canvas.height = 630; // Standard OG image size
    const ctx = canvas.getContext('2d');

    if (ctx) {
      // Background gradient
      const gradient = ctx.createLinearGradient(0, 0, 0, 630);
      gradient.addColorStop(0, '#1a1a1a');
      gradient.addColorStop(1, '#000000');
      ctx.fillStyle = gradient;
      ctx.fillRect(0, 0, 1200, 630);

      // Load property image
      const img = new Image();
      img.crossOrigin = 'anonymous';
      img.onload = () => {
        // Draw image
        ctx.drawImage(img, 0, 0, 600, 630);

        // Right side content
        ctx.fillStyle = '#ffffff';
        ctx.font = 'bold 72px system-ui';
        ctx.fillText(formatPrice(property.price) + '/mo', 640, 180);

        ctx.font = '36px system-ui';
        ctx.fillStyle = '#cccccc';
        ctx.fillText(property.neighborhood, 640, 240);

        if (property.bedrooms) {
          ctx.fillText(`${property.bedrooms} bed • ${property.bathrooms || 1} bath`, 640, 300);
        }

        // HOMEY branding
        ctx.font = 'bold 28px system-ui';
        ctx.fillStyle = '#6366f1'; // Primary color
        ctx.fillText('Found via HOMEY 🏠', 640, 560);

        // Download
        canvas.toBlob((blob) => {
          if (blob) {
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `homey-${property.id}.png`;
            a.click();
            URL.revokeObjectURL(url);
          }
        });
      };
      img.src = property.images?.[0] || '/placeholder-property.jpg';
    }
  };

  return (
    <BottomSheet isOpen={isOpen} onClose={onClose} title="Share Property">
      <div className="p-6 space-y-6">
        {/* Property Preview Card */}
        <div className="rounded-2xl overflow-hidden glass-strong border border-white/10">
          <img
            src={property.images?.[0] || '/placeholder-property.jpg'}
            alt={property.address}
            className="w-full h-48 object-cover"
          />
          <div className="p-4">
            <h3 className="text-xl font-bold text-white mb-1">{formatPrice(property.price)}/mo</h3>
            <p className="text-white/70">{property.neighborhood}</p>
            {property.bedrooms && (
              <p className="text-white/50 text-sm mt-1">
                {property.bedrooms} bed • {property.bathrooms || 1} bath
              </p>
            )}
            <div className="mt-3 px-3 py-1.5 bg-primary/20 border border-primary/40 rounded-full inline-block">
              <span className="text-primary text-sm font-semibold">Found via HOMEY 🏠</span>
            </div>
          </div>
        </div>

        {/* Share Options */}
        <div className="space-y-3">
          {/* Native Share (Mobile) */}
          {navigator.share && (
            <button
              onClick={handleNativeShare}
              className="w-full py-4 bg-gradient-to-r from-primary via-purple-500 to-pink-500 text-white rounded-2xl font-bold flex items-center justify-center gap-2 hover:opacity-90 transition-opacity min-h-[44px]"
            >
              <span className="text-xl">↗️</span>
              Share via...
            </button>
          )}

          {/* Copy Link */}
          <button
            onClick={handleCopyLink}
            className="w-full py-4 bg-white/10 hover:bg-white/20 text-white rounded-2xl font-semibold flex items-center justify-center gap-2 transition-colors min-h-[44px]"
          >
            <span className="text-xl">{copied ? '✓' : '🔗'}</span>
            {copied ? 'Link Copied!' : 'Copy Link'}
          </button>

          {/* Download Share Card */}
          <button
            onClick={downloadShareCard}
            className="w-full py-4 bg-white/10 hover:bg-white/20 text-white rounded-2xl font-semibold flex items-center justify-center gap-2 transition-colors min-h-[44px]"
          >
            <span className="text-xl">📸</span>
            Download Share Card
          </button>

          {/* Social Media Quick Links */}
          <div className="grid grid-cols-3 gap-3 pt-2">
            <a
              href={`https://twitter.com/intent/tweet?text=${encodeURIComponent(shareText)}&url=${encodeURIComponent(shareUrl)}`}
              target="_blank"
              rel="noopener noreferrer"
              className="py-3 bg-[#1DA1F2]/20 hover:bg-[#1DA1F2]/30 text-white rounded-xl font-semibold text-center transition-colors min-h-[44px] flex items-center justify-center"
            >
              <span className="text-xl">𝕏</span>
            </a>
            <a
              href={`https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(shareUrl)}`}
              target="_blank"
              rel="noopener noreferrer"
              className="py-3 bg-[#4267B2]/20 hover:bg-[#4267B2]/30 text-white rounded-xl font-semibold text-center transition-colors min-h-[44px] flex items-center justify-center"
            >
              <span className="text-xl">f</span>
            </a>
            <a
              href={`mailto:?subject=${encodeURIComponent(`Check out this property!`)}&body=${encodeURIComponent(shareText + '\n\n' + shareUrl)}`}
              className="py-3 bg-white/10 hover:bg-white/20 text-white rounded-xl font-semibold text-center transition-colors min-h-[44px] flex items-center justify-center"
            >
              <span className="text-xl">✉️</span>
            </a>
          </div>
        </div>

        {/* Share Text Preview */}
        <div className="p-4 bg-white/5 rounded-xl border border-white/10">
          <p className="text-white/60 text-xs mb-2">Share message:</p>
          <p className="text-white text-sm">{shareText}</p>
        </div>
      </div>
    </BottomSheet>
  );
}
