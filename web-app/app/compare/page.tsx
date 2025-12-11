'use client';

import { useState, useEffect, useMemo, Suspense } from 'react';
import { useSearchParams, useRouter } from 'next/navigation';
import { motion, AnimatePresence, Reorder } from 'framer-motion';
import {
  X, ChevronLeft, ChevronRight, MapPin, DollarSign, Bed, Bath,
  Home, Calendar, Sparkles, Heart, Share2, ExternalLink,
  Maximize2, Package, Award, Clock, TrendingUp, Download,
  Mail, Copy, Check, Trash2, StickyNote, BarChart3,
  Zap, AlertCircle, PawPrint, Car, Target
} from 'lucide-react';
import type { Listing } from '@/lib/types';
import { supabase } from '@/lib/supabase';
import CinematicBackground from '@/components/CinematicBackground';
import ValueScoreCard from '@/components/compare/ValueScoreCard';
import ImageComparisonSlider from '@/components/compare/ImageComparisonSlider';
import CustomWeights from '@/components/compare/CustomWeights';
import EnhancedMetrics from '@/components/compare/EnhancedMetrics';
import DealBreakers from '@/components/compare/DealBreakers';
import PropertyNotes from '@/components/compare/PropertyNotes';

interface ComparisonMetric {
  label: string;
  icon: JSX.Element;
  getValue: (listing: Listing) => number | null;
  isBetterWhen: 'lower' | 'higher';
  format: (value: number) => string;
  weight?: number;
}

interface UserWeights {
  price: number;
  location: number;
  space: number;
  commute: number;
  amenities: number;
}

const DEFAULT_WEIGHTS: UserWeights = {
  price: 1,
  location: 1,
  space: 1,
  commute: 1,
  amenities: 1,
};

function ComparePageContent() {
  const searchParams = useSearchParams();
  const router = useRouter();
  const [listings, setListings] = useState<Listing[]>([]);
  const [loading, setLoading] = useState(true);
  const [currentImageIndices, setCurrentImageIndices] = useState<number[]>([]);
  const [showImageComparison, setShowImageComparison] = useState(false);
  const [selectedRoom, setSelectedRoom] = useState<'living' | 'kitchen' | 'bedroom' | 'bathroom'>('living');
  const [userWeights, setUserWeights] = useState<UserWeights>(DEFAULT_WEIGHTS);
  const [showWeightCustomizer, setShowWeightCustomizer] = useState(false);
  const [notes, setNotes] = useState<Record<string, string>>({});
  const [dealBreakers, setDealBreakers] = useState<Record<string, string[]>>({});
  const [shareLink, setShareLink] = useState('');
  const [copySuccess, setCopySuccess] = useState(false);

  useEffect(() => {
    const ids = searchParams.get('ids');
    if (!ids) {
      router.push('/search');
      return;
    }

    fetchListings(ids.split(','));
  }, [searchParams]);

  const fetchListings = async (ids: string[]) => {
    setLoading(true);
    try {
      const { data, error } = await supabase
        .from('listings')
        .select('*')
        .in('id', ids);

      if (error) throw error;

      if (data) {
        setListings(data);
        setCurrentImageIndices(new Array(data.length).fill(0));

        // Initialize notes and deal breakers from localStorage
        const savedNotes = localStorage.getItem('comparison-notes');
        const savedDealBreakers = localStorage.getItem('comparison-dealbreakers');
        if (savedNotes) setNotes(JSON.parse(savedNotes));
        if (savedDealBreakers) setDealBreakers(JSON.parse(savedDealBreakers));
      }
    } catch (error) {
      console.error('Error fetching listings:', error);
    } finally {
      setLoading(false);
    }
  };

  const metrics: ComparisonMetric[] = [
    {
      label: 'Monthly Rent',
      icon: <DollarSign className="w-4 h-4" />,
      getValue: (listing) => listing.price || 0,
      isBetterWhen: 'lower',
      format: (value) => `$${value.toLocaleString()}`,
      weight: userWeights.price,
    },
    {
      label: 'Square Feet',
      icon: <Maximize2 className="w-4 h-4" />,
      getValue: (listing) => listing.square_footage || 0,
      isBetterWhen: 'higher',
      format: (value) => `${value.toLocaleString()} sqft`,
      weight: userWeights.space,
    },
    {
      label: 'Bedrooms',
      icon: <Bed className="w-4 h-4" />,
      getValue: (listing) => listing.bedrooms || 0,
      isBetterWhen: 'higher',
      format: (value) => `${value}`,
      weight: userWeights.space,
    },
    {
      label: 'Bathrooms',
      icon: <Bath className="w-4 h-4" />,
      getValue: (listing) => listing.bathrooms || 0,
      isBetterWhen: 'higher',
      format: (value) => `${value}`,
      weight: userWeights.space,
    },
    {
      label: 'Walk Score',
      icon: <MapPin className="w-4 h-4" />,
      getValue: (listing) => listing.walk_score || 0,
      isBetterWhen: 'higher',
      format: (value) => `${value}/100`,
      weight: userWeights.location,
    },
    {
      label: 'Price per sqft',
      icon: <DollarSign className="w-4 h-4" />,
      getValue: (listing) => {
        const sqft = listing.square_footage;
        if (!sqft || !listing.price) return 0;
        return Math.round(listing.price / sqft);
      },
      isBetterWhen: 'lower',
      format: (value) => `$${value}/sqft`,
      weight: userWeights.price,
    },
  ];

  const calculateValueScore = (listing: Listing): number => {
    let score = 0;
    let totalWeight = 0;

    metrics.forEach((metric) => {
      const value = metric.getValue(listing);
      if (value === null || value === 0) return;

      const allValues = listings
        .map(l => metric.getValue(l))
        .filter(v => v !== null && v !== 0) as number[];

      const min = Math.min(...allValues);
      const max = Math.max(...allValues);

      if (min === max) return;

      let normalizedScore = 0;
      if (metric.isBetterWhen === 'lower') {
        normalizedScore = ((max - value) / (max - min)) * 100;
      } else {
        normalizedScore = ((value - min) / (max - min)) * 100;
      }

      const weight = metric.weight || 1;
      score += normalizedScore * weight;
      totalWeight += weight;
    });

    return totalWeight > 0 ? Math.round(score / totalWeight) : 0;
  };

  const rankedListings = useMemo(() => {
    return [...listings]
      .map(listing => ({
        listing,
        score: calculateValueScore(listing)
      }))
      .sort((a, b) => b.score - a.score);
  }, [listings, userWeights]);

  const getBestIndices = (metric: ComparisonMetric): number[] => {
    const values = listings.map(metric.getValue);
    const validValues = values.filter(v => v !== null && v !== 0) as number[];

    if (validValues.length === 0) return [];

    const bestValue = metric.isBetterWhen === 'lower'
      ? Math.min(...validValues)
      : Math.max(...validValues);

    return values
      .map((v, i) => v === bestValue ? i : -1)
      .filter(i => i !== -1);
  };

  const handleRemoveListing = (id: string) => {
    const newListings = listings.filter(l => l.id !== id);
    if (newListings.length < 2) {
      router.push('/search');
      return;
    }

    const newIds = newListings.map(l => l.id).join(',');
    router.push(`/compare?ids=${newIds}`);
  };

  const handleReorder = (newOrder: Listing[]) => {
    setListings(newOrder);
  };

  const handleGenerateShareLink = async () => {
    const ids = listings.map(l => l.id).join(',');
    const url = `${window.location.origin}/compare?ids=${ids}`;
    setShareLink(url);

    try {
      await navigator.clipboard.writeText(url);
      setCopySuccess(true);
      setTimeout(() => setCopySuccess(false), 2000);
    } catch (err) {
      console.error('Failed to copy:', err);
    }
  };

  const handleExportPDF = async () => {
    // Will implement PDF export with jsPDF
    console.log('Exporting to PDF...');
    alert('PDF export coming soon!');
  };

  const handleEmailToSelf = async () => {
    const ids = listings.map(l => l.id).join(',');
    const subject = 'My Property Comparison from HOMEY';
    const body = `Check out my property comparison:\n\n${window.location.origin}/compare?ids=${ids}`;

    window.location.href = `mailto:?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(body)}`;
  };

  const handleSaveNote = (listingId: string, note: string) => {
    const newNotes = { ...notes, [listingId]: note };
    setNotes(newNotes);
    localStorage.setItem('comparison-notes', JSON.stringify(newNotes));
  };

  const handleSaveDealBreakers = (listingId: string, breakers: string[]) => {
    const newDealBreakers = { ...dealBreakers, [listingId]: breakers };
    setDealBreakers(newDealBreakers);
    localStorage.setItem('comparison-dealbreakers', JSON.stringify(newDealBreakers));
  };

  const nextImage = (index: number) => {
    setCurrentImageIndices(prev => {
      const newIndices = [...prev];
      const images = listings[index]?.image_urls || [];
      newIndices[index] = (newIndices[index] + 1) % images.length;
      return newIndices;
    });
  };

  const prevImage = (index: number) => {
    setCurrentImageIndices(prev => {
      const newIndices = [...prev];
      const images = listings[index]?.image_urls || [];
      newIndices[index] = (newIndices[index] - 1 + images.length) % images.length;
      return newIndices;
    });
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <div className="w-16 h-16 border-4 border-primary border-t-transparent rounded-full animate-spin mx-auto mb-4" />
          <p className="text-white/60">Loading comparison...</p>
        </div>
      </div>
    );
  }

  if (listings.length < 2) {
    return (
      <div className="min-h-screen flex items-center justify-center p-4">
        <div className="text-center">
          <AlertCircle className="w-16 h-16 text-yellow-500 mx-auto mb-4" />
          <h2 className="text-2xl font-bold text-white mb-2">Not Enough Properties</h2>
          <p className="text-white/60 mb-6">You need at least 2 properties to compare.</p>
          <button
            onClick={() => router.push('/search')}
            className="px-6 py-3 bg-gradient-to-r from-primary to-purple-500 rounded-xl text-white font-semibold hover:opacity-90 transition-all"
          >
            Back to Search
          </button>
        </div>
      </div>
    );
  }

  return (
    <>
      <CinematicBackground timeOfDay="sunset" />
      <div className="min-h-screen pb-20 relative z-10">
        {/* Header */}
        <div className="sticky top-0 z-30 glass-strong border-b border-white/10 px-4 py-6">
          <div className="max-w-7xl mx-auto flex items-center justify-between">
            <div className="flex items-center gap-4">
              <button
                onClick={() => router.push('/search')}
                className="w-12 h-12 rounded-full glass-medium flex items-center justify-center hover:bg-white/10 transition-all"
              >
                <ChevronLeft className="w-6 h-6 text-white" />
              </button>
              <div>
                <h1 className="text-2xl md:text-3xl font-bold text-white">Property Comparison</h1>
                <p className="text-sm text-white/60 mt-1">{listings.length} properties selected</p>
              </div>
            </div>

            <div className="flex items-center gap-2">
              <button
                onClick={handleGenerateShareLink}
                className="px-4 py-2.5 glass-medium rounded-xl text-white hover:bg-white/10 transition-all flex items-center gap-2"
              >
                {copySuccess ? (
                  <>
                    <Check className="w-4 h-4 text-green-400" />
                    <span className="hidden md:inline text-green-400">Copied!</span>
                  </>
                ) : (
                  <>
                    <Share2 className="w-4 h-4" />
                    <span className="hidden md:inline">Share</span>
                  </>
                )}
              </button>

              <button
                onClick={handleExportPDF}
                className="px-4 py-2.5 glass-medium rounded-xl text-white hover:bg-white/10 transition-all flex items-center gap-2"
              >
                <Download className="w-4 h-4" />
                <span className="hidden md:inline">PDF</span>
              </button>

              <button
                onClick={handleEmailToSelf}
                className="px-4 py-2.5 glass-medium rounded-xl text-white hover:bg-white/10 transition-all flex items-center gap-2"
              >
                <Mail className="w-4 h-4" />
              </button>
            </div>
          </div>

          {/* Custom Weights Panel */}
          <AnimatePresence>
            {showWeightCustomizer && (
              <CustomWeights
                weights={userWeights}
                onWeightsChange={setUserWeights}
                onClose={() => setShowWeightCustomizer(false)}
              />
            )}
          </AnimatePresence>
        </div>

      <div className="max-w-7xl mx-auto px-4 py-6">
        {/* Value Scores - Simplified */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 mb-8">
          {rankedListings.map(({ listing, score }, idx) => (
            <ValueScoreCard
              key={listing.id}
              listing={listing}
              score={score}
              rank={idx + 1}
              isWinner={false}
            />
          ))}
        </div>

        {/* Interactive Image Galleries */}
        <div className="mb-8">
          <div className="mb-6">
            <h3 className="text-2xl md:text-3xl font-bold text-white">Property Photos</h3>
          </div>
            <div className="overflow-x-auto scrollbar-hide" style={{ WebkitOverflowScrolling: 'touch' }}>
            <Reorder.Group
              axis="x"
              values={listings}
              onReorder={handleReorder}
              className="grid grid-cols-3 gap-4 min-w-[900px] lg:min-w-0 pb-2"
            >
              {listings.map((listing, idx) => {
                const images = listing.image_urls || [];
                const hasImages = images.length > 0;

                return (
                  <Reorder.Item key={listing.id} value={listing}>
                    <motion.div
                      whileHover={{ scale: 1.02 }}
                      className="relative overflow-hidden rounded-3xl bg-gradient-to-br from-primary/10 via-purple-600/10 to-pink-500/10 border border-white/10 cursor-move"
                    >
                      {/* Animated blur effect */}
                      <div className="absolute top-0 right-0 w-32 h-32 bg-primary/20 rounded-full blur-3xl opacity-30 animate-pulse" />

                      {/* Image */}
                      <div className="relative h-64 bg-gradient-to-br from-purple-900 to-blue-900 z-10">
                        {hasImages ? (
                          <>
                            <img
                              src={images[currentImageIndices[idx]]}
                              alt={listing.address}
                              className="w-full h-full object-cover"
                            />
                            {images.length > 1 && (
                              <>
                                <button
                                  onClick={() => prevImage(idx)}
                                  className="absolute left-2 top-1/2 -translate-y-1/2 w-8 h-8 rounded-full bg-black/60 backdrop-blur-sm flex items-center justify-center text-white hover:bg-black/80 transition-all"
                                >
                                  <ChevronLeft className="w-5 h-5" />
                                </button>
                                <button
                                  onClick={() => nextImage(idx)}
                                  className="absolute right-2 top-1/2 -translate-y-1/2 w-8 h-8 rounded-full bg-black/60 backdrop-blur-sm flex items-center justify-center text-white hover:bg-black/80 transition-all"
                                >
                                  <ChevronRight className="w-5 h-5" />
                                </button>
                                <div className="absolute bottom-2 left-1/2 -translate-x-1/2 px-3 py-1 bg-black/60 backdrop-blur-sm rounded-full">
                                  <span className="text-white text-xs">
                                    {currentImageIndices[idx] + 1} / {images.length}
                                  </span>
                                </div>
                              </>
                            )}
                          </>
                        ) : (
                          <div className="w-full h-full flex items-center justify-center">
                            <Home className="w-16 h-16 text-white/30" />
                          </div>
                        )}

                        <button
                          onClick={() => handleRemoveListing(listing.id)}
                          className="absolute top-2 right-2 w-8 h-8 rounded-full bg-red-500/80 backdrop-blur-sm flex items-center justify-center text-white hover:bg-red-600 transition-all"
                        >
                          <X className="w-4 h-4" />
                        </button>
                      </div>

                      {/* Info */}
                      <div className="p-4">
                        <p className="text-lg font-bold text-white mb-1">
                          ${listing.price?.toLocaleString()}/mo
                        </p>
                        <p className="text-sm text-white/80 mb-2">{listing.address}</p>
                        <div className="flex items-center gap-3 text-white/60 text-sm">
                          <span>{listing.bedrooms} bed</span>
                          <span>•</span>
                          <span>{listing.bathrooms} bath</span>
                          {listing.square_footage && (
                            <>
                              <span>•</span>
                              <span>{listing.square_footage} sqft</span>
                            </>
                          )}
                        </div>
                      </div>
                    </motion.div>
                  </Reorder.Item>
                );
              })}
            </Reorder.Group>
            </div>
        </div>

        {/* Comparison Table */}
        <div className="mb-8 relative overflow-hidden rounded-3xl bg-gradient-to-br from-primary/10 via-purple-600/10 to-pink-500/10 border border-white/10">
          {/* Animated blur effect */}
          <div className="absolute bottom-0 left-0 w-48 h-48 bg-purple-500/20 rounded-full blur-3xl opacity-50 animate-pulse" style={{ animationDelay: '0.5s' }} />

          <div className="relative z-10 p-8 border-b border-white/10">
            <h3 className="text-2xl md:text-3xl font-bold text-white flex items-center gap-3">
              <BarChart3 className="w-7 h-7 text-primary" />
              Metric Comparison
            </h3>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-white/10">
                  <th className="text-left p-4 text-white/60 font-medium text-sm">Metric</th>
                  {listings.map((listing, idx) => (
                    <th key={listing.id} className="text-center p-4 text-white font-medium">
                      Property {idx + 1}
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {metrics.map((metric) => {
                  const bestIndices = getBestIndices(metric);

                  return (
                    <tr key={metric.label} className="border-b border-white/10 hover:bg-white/5 transition-colors">
                      <td className="p-4">
                        <div className="flex items-center gap-2 text-white/80">
                          {metric.icon}
                          <span className="text-sm">{metric.label}</span>
                        </div>
                      </td>
                      {listings.map((listing, idx) => {
                        const value = metric.getValue(listing);
                        const isBest = bestIndices.includes(idx);

                        return (
                          <td
                            key={listing.id}
                            className={`p-4 text-center font-semibold ${
                              isBest
                                ? 'bg-green-500/20 text-green-300'
                                : 'text-white'
                            }`}
                          >
                            {value !== null && value !== 0 ? metric.format(value) : '—'}
                          </td>
                        );
                      })}
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </div>

        {/* Enhanced Metrics */}
        <EnhancedMetrics listings={listings} />

        {/* Deal Breakers & Notes */}
        <div className="mb-8">
          <div className="mb-6">
            <h3 className="text-3xl md:text-4xl font-bold text-white mb-2">Deal Breakers & Red Flags</h3>
            <p className="text-white/60">What might make you say "hard pass"</p>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-6">
            {listings.map((listing, idx) => (
              <div key={listing.id} className="relative overflow-hidden rounded-3xl bg-gradient-to-br from-primary/10 via-purple-600/10 to-pink-500/10 border border-white/10 p-8">
                {/* Animated blur effect */}
                <div
                  className="absolute top-0 left-0 w-32 h-32 bg-orange-500/20 rounded-full blur-3xl opacity-50 animate-pulse"
                  style={{ animationDelay: `${idx * 0.2}s` }}
                />

                <div className="relative z-10">
                  <h4 className="text-xl font-bold text-white mb-6">Property {idx + 1}</h4>

                  <DealBreakers
                    listingId={listing.id}
                    listing={listing}
                    dealBreakers={dealBreakers[listing.id] || []}
                    onSave={(breakers) => handleSaveDealBreakers(listing.id, breakers)}
                  />

                  <div className="mt-6 pt-6 border-t border-white/10">
                    <PropertyNotes
                      listingId={listing.id}
                      note={notes[listing.id] || ''}
                      onSave={(note) => handleSaveNote(listing.id, note)}
                    />
                  </div>
                </div>
              </div>
            ))}
          </div>

          {/* HOMEY Voice - Interactive Learning */}
          {Object.values(dealBreakers).some(arr => arr.length > 0) && (
            <motion.div
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              className="relative overflow-hidden rounded-3xl bg-gradient-to-br from-primary/10 to-purple-500/10 border border-primary/30 p-8"
            >
              {/* Animated blur effect */}
              <div className="absolute bottom-0 right-0 w-48 h-48 bg-primary/30 rounded-full blur-3xl opacity-50 animate-pulse" />

              <div className="relative z-10 flex items-start gap-4">
                <div className="w-14 h-14 bg-gradient-to-br from-primary to-purple-500 rounded-2xl flex items-center justify-center flex-shrink-0">
                  <Sparkles className="w-7 h-7 text-white" />
                </div>
                <div className="flex-1">
                  <p className="text-xl md:text-2xl font-bold text-white mb-3">I see what matters to you</p>
                  <p className="text-sm text-white/80 leading-relaxed mb-4">
                    {(() => {
                      const allBreakers = Object.values(dealBreakers).flat();
                      const commonBreakers = allBreakers.reduce((acc: Record<string, number>, breaker) => {
                        acc[breaker] = (acc[breaker] || 0) + 1;
                        return acc;
                      }, {});
                      const mostCommon = Object.entries(commonBreakers)
                        .sort(([,a], [,b]) => (b as number) - (a as number))
                        .slice(0, 2)
                        .map(([breaker]) => {
                          // Convert negative deal breakers to positive preferences
                          // e.g., "No in-unit laundry" -> "in-unit laundry"
                          if (breaker.toLowerCase().startsWith('no ')) {
                            return breaker.substring(3);
                          }
                          return breaker;
                        });

                      if (mostCommon.length > 0) {
                        return `I see ${mostCommon.join(' and ')} ${mostCommon.length === 1 ? 'is' : 'are'} important to you. Want me to push listings with ${mostCommon.length === 1 ? 'this' : 'these'} features higher in your next search?`;
                      }
                      return "I'm learning what you can't compromise on. This helps me find better matches next time.";
                    })()}
                  </p>
                  <button
                    onClick={() => {
                      // This would trigger saving preferences to the backend
                      alert('Great! I\'ll remember this for your future searches.');
                    }}
                    className="px-5 py-2.5 bg-white/10 hover:bg-white/20 border border-white/20 rounded-2xl text-base text-white font-semibold transition-all shadow-lg"
                  >
                    Yes, remember this
                  </button>
                </div>
              </div>
            </motion.div>
          )}
        </div>

        {/* Amenities Comparison */}
        {listings.some(l => l.amenities && l.amenities.length > 0) && (
          <div className="relative overflow-hidden rounded-3xl bg-gradient-to-br from-primary/10 via-purple-600/10 to-pink-500/10 border border-white/10 p-8">
            {/* Animated blur effect */}
            <div className="absolute top-0 right-0 w-48 h-48 bg-pink-500/20 rounded-full blur-3xl opacity-50 animate-pulse" />

            <div className="relative z-10">
              <h3 className="text-2xl md:text-3xl font-bold text-white mb-6 flex items-center gap-3">
                <Package className="w-7 h-7 text-primary" />
                Amenities Comparison
              </h3>

              <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
                {listings.map((listing) => (
                  <div key={listing.id}>
                    <p className="text-base font-bold text-white mb-4">
                      Property {listings.indexOf(listing) + 1}
                    </p>
                    <div className="space-y-3">
                      {(listing.amenities || []).map((amenity, idx) => (
                        <div
                          key={idx}
                          className="px-4 py-2.5 bg-white/5 rounded-2xl border border-white/10 text-sm text-white/80 font-medium"
                        >
                          {amenity}
                        </div>
                      ))}
                      {(!listing.amenities || listing.amenities.length === 0) && (
                        <p className="text-sm text-white/40 italic">No amenities listed</p>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
    </>
  );
}

export default function ComparePage() {
  return (
    <Suspense fallback={
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <div className="w-16 h-16 border-4 border-primary border-t-transparent rounded-full animate-spin mx-auto mb-4" />
          <p className="text-white/60">Loading comparison...</p>
        </div>
      </div>
    }>
      <ComparePageContent />
    </Suspense>
  );
}
