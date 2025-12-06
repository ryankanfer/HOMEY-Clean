'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Hammer, MapPin, Building, Home, Eye, DollarSign, Sparkles, Check } from 'lucide-react';

interface DreamHomeConfig {
  neighborhood: string;
  buildingType: string;
  unitFeatures: string[];
  view: string;
}

interface BuildYourDreamProps {
  neighborhoods: string[];
  onComplete: (config: DreamHomeConfig, estimatedPrice: number) => void;
}

const buildingTypes = [
  { id: 'luxury', name: 'Luxury High-Rise', priceMultiplier: 1.5, icon: '🏙️' },
  { id: 'modern', name: 'Modern Mid-Rise', priceMultiplier: 1.2, icon: '🏢' },
  { id: 'boutique', name: 'Boutique Building', priceMultiplier: 1.3, icon: '🏛️' },
  { id: 'townhouse', name: 'Townhouse', priceMultiplier: 1.1, icon: '🏘️' },
  { id: 'loft', name: 'Industrial Loft', priceMultiplier: 1.25, icon: '🏭' },
];

const unitFeatures = [
  { id: 'penthouse', name: 'Penthouse', price: 1200, icon: '👑' },
  { id: 'balcony', name: 'Private Balcony', price: 300, icon: '🌿' },
  { id: 'parking', name: 'Parking Included', price: 250, icon: '🚗' },
  { id: 'laundry', name: 'In-Unit Laundry', price: 150, icon: '🧺' },
  { id: 'fireplace', name: 'Fireplace', price: 200, icon: '🔥' },
  { id: 'chef-kitchen', name: 'Chef\'s Kitchen', price: 400, icon: '👨‍🍳' },
  { id: 'smart-home', name: 'Smart Home Tech', price: 180, icon: '🤖' },
  { id: 'pet-friendly', name: 'Pet-Friendly', price: 100, icon: '🐕' },
];

const views = [
  { id: 'skyline', name: 'City Skyline', price: 600, icon: '🌆' },
  { id: 'water', name: 'Water View', price: 800, icon: '🌊' },
  { id: 'park', name: 'Park View', price: 400, icon: '🌳' },
  { id: 'street', name: 'Street View', price: 0, icon: '🛣️' },
];

export default function BuildYourDream({
  neighborhoods,
  onComplete,
}: BuildYourDreamProps) {
  const [step, setStep] = useState<'neighborhood' | 'building' | 'features' | 'view'>('neighborhood');
  const [selectedNeighborhood, setSelectedNeighborhood] = useState<string>('');
  const [selectedBuilding, setSelectedBuilding] = useState<string>('');
  const [selectedFeatures, setSelectedFeatures] = useState<string[]>([]);
  const [selectedView, setSelectedView] = useState<string>('');
  const [basePrice, setBasePrice] = useState(2500);

  const neighborhoodPrices: Record<string, number> = {
    'Downtown': 3500,
    'Midtown': 3000,
    'Upper East': 4000,
    'Brooklyn Heights': 3200,
    'Williamsburg': 2800,
    'Default': 2500,
  };

  const calculatePrice = () => {
    let price = neighborhoodPrices[selectedNeighborhood] || basePrice;

    // Apply building multiplier
    const building = buildingTypes.find((b) => b.id === selectedBuilding);
    if (building) {
      price *= building.priceMultiplier;
    }

    // Add feature prices
    selectedFeatures.forEach((featureId) => {
      const feature = unitFeatures.find((f) => f.id === featureId);
      if (feature) {
        price += feature.price;
      }
    });

    // Add view price
    const view = views.find((v) => v.id === selectedView);
    if (view) {
      price += view.price;
    }

    return Math.round(price);
  };

  const estimatedPrice = calculatePrice();

  const toggleFeature = (featureId: string) => {
    setSelectedFeatures((prev) =>
      prev.includes(featureId)
        ? prev.filter((f) => f !== featureId)
        : [...prev, featureId]
    );
  };

  const handleNext = () => {
    if (step === 'neighborhood' && selectedNeighborhood) {
      setStep('building');
    } else if (step === 'building' && selectedBuilding) {
      setStep('features');
    } else if (step === 'features') {
      setStep('view');
    } else if (step === 'view' && selectedView) {
      onComplete(
        {
          neighborhood: selectedNeighborhood,
          buildingType: selectedBuilding,
          unitFeatures: selectedFeatures,
          view: selectedView,
        },
        estimatedPrice
      );
    }
  };

  const canProceed =
    (step === 'neighborhood' && selectedNeighborhood) ||
    (step === 'building' && selectedBuilding) ||
    step === 'features' ||
    (step === 'view' && selectedView);

  return (
    <div className="relative h-full flex flex-col">
      {/* Header */}
      <div className="px-4 py-4 border-b border-white/10">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-gradient-to-br from-blue-500 to-cyan-500 rounded-lg flex items-center justify-center">
              <Hammer className="w-6 h-6 text-white" />
            </div>
            <div>
              <h3 className="text-lg font-bold text-white">Build Your Dream</h3>
              <p className="text-xs text-white/60">Create your fantasy apartment</p>
            </div>
          </div>

          {/* Price Display */}
          <motion.div
            key={estimatedPrice}
            initial={{ scale: 1.2 }}
            animate={{ scale: 1 }}
            className="px-4 py-2 bg-gradient-to-r from-green-500/20 to-emerald-500/20 rounded-full border border-green-500/30"
          >
            <div className="flex items-center gap-2">
              <DollarSign className="w-5 h-5 text-green-400" />
              <span className="text-xl font-bold text-green-300">
                {estimatedPrice.toLocaleString()}/mo
              </span>
            </div>
          </motion.div>
        </div>

        {/* Progress Steps */}
        <div className="flex items-center gap-2">
          {['neighborhood', 'building', 'features', 'view'].map((s, index) => (
            <div key={s} className="flex-1 flex items-center gap-2">
              <div
                className={`flex-1 h-1 rounded-full ${
                  step === s
                    ? 'bg-gradient-to-r from-blue-500 to-cyan-500'
                    : selectedNeighborhood && index === 0
                    ? 'bg-green-500'
                    : selectedBuilding && index === 1
                    ? 'bg-green-500'
                    : selectedView && index === 3
                    ? 'bg-green-500'
                    : 'bg-white/20'
                }`}
              />
            </div>
          ))}
        </div>
      </div>

      {/* Content */}
      <div className="flex-1 overflow-y-auto px-4 py-6">
        <AnimatePresence mode="wait">
          {/* Step 1: Neighborhood */}
          {step === 'neighborhood' && (
            <motion.div
              key="neighborhood"
              initial={{ opacity: 0, x: 50 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -50 }}
              className="space-y-4"
            >
              <div className="flex items-center gap-3 mb-6">
                <div className="w-12 h-12 bg-gradient-to-br from-blue-500 to-cyan-500 rounded-lg flex items-center justify-center">
                  <MapPin className="w-6 h-6 text-white" />
                </div>
                <div>
                  <h4 className="text-xl font-bold text-white">Choose Your Neighborhood</h4>
                  <p className="text-sm text-white/60">Where do you want to live?</p>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                {(neighborhoods.length > 0 ? neighborhoods.slice(0, 8) : ['Downtown', 'Midtown', 'Upper East', 'Brooklyn Heights']).map((neighborhood) => (
                  <button
                    key={neighborhood}
                    onClick={() => setSelectedNeighborhood(neighborhood)}
                    className={`p-4 rounded-xl border-2 transition-all text-left ${
                      selectedNeighborhood === neighborhood
                        ? 'bg-blue-500/20 border-blue-500'
                        : 'bg-white/5 border-white/10 hover:bg-white/10'
                    }`}
                  >
                    <p className="text-white font-medium">{neighborhood}</p>
                    <p className="text-white/60 text-sm mt-1">
                      ~${neighborhoodPrices[neighborhood] || basePrice}/mo
                    </p>
                    {selectedNeighborhood === neighborhood && (
                      <Check className="w-5 h-5 text-blue-400 absolute top-3 right-3" />
                    )}
                  </button>
                ))}
              </div>
            </motion.div>
          )}

          {/* Step 2: Building Type */}
          {step === 'building' && (
            <motion.div
              key="building"
              initial={{ opacity: 0, x: 50 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -50 }}
              className="space-y-4"
            >
              <div className="flex items-center gap-3 mb-6">
                <div className="w-12 h-12 bg-gradient-to-br from-blue-500 to-cyan-500 rounded-lg flex items-center justify-center">
                  <Building className="w-6 h-6 text-white" />
                </div>
                <div>
                  <h4 className="text-xl font-bold text-white">Choose Building Type</h4>
                  <p className="text-sm text-white/60">What style suits you?</p>
                </div>
              </div>

              <div className="space-y-3">
                {buildingTypes.map((building) => (
                  <button
                    key={building.id}
                    onClick={() => setSelectedBuilding(building.id)}
                    className={`w-full p-4 rounded-xl border-2 transition-all text-left relative ${
                      selectedBuilding === building.id
                        ? 'bg-blue-500/20 border-blue-500'
                        : 'bg-white/5 border-white/10 hover:bg-white/10'
                    }`}
                  >
                    <div className="flex items-center gap-3">
                      <span className="text-3xl">{building.icon}</span>
                      <div className="flex-1">
                        <p className="text-white font-medium">{building.name}</p>
                        <p className="text-white/60 text-sm">+{Math.round((building.priceMultiplier - 1) * 100)}% price</p>
                      </div>
                      {selectedBuilding === building.id && (
                        <Check className="w-5 h-5 text-blue-400" />
                      )}
                    </div>
                  </button>
                ))}
              </div>
            </motion.div>
          )}

          {/* Step 3: Unit Features */}
          {step === 'features' && (
            <motion.div
              key="features"
              initial={{ opacity: 0, x: 50 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -50 }}
              className="space-y-4"
            >
              <div className="flex items-center gap-3 mb-6">
                <div className="w-12 h-12 bg-gradient-to-br from-blue-500 to-cyan-500 rounded-lg flex items-center justify-center">
                  <Home className="w-6 h-6 text-white" />
                </div>
                <div>
                  <h4 className="text-xl font-bold text-white">Pick Your Features</h4>
                  <p className="text-sm text-white/60">Select all that apply (optional)</p>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                {unitFeatures.map((feature) => (
                  <button
                    key={feature.id}
                    onClick={() => toggleFeature(feature.id)}
                    className={`p-4 rounded-xl border-2 transition-all text-left relative ${
                      selectedFeatures.includes(feature.id)
                        ? 'bg-blue-500/20 border-blue-500'
                        : 'bg-white/5 border-white/10 hover:bg-white/10'
                    }`}
                  >
                    <span className="text-2xl mb-2 block">{feature.icon}</span>
                    <p className="text-white font-medium text-sm">{feature.name}</p>
                    <p className="text-white/60 text-xs mt-1">+${feature.price}/mo</p>
                    {selectedFeatures.includes(feature.id) && (
                      <Check className="w-5 h-5 text-blue-400 absolute top-3 right-3" />
                    )}
                  </button>
                ))}
              </div>
            </motion.div>
          )}

          {/* Step 4: View */}
          {step === 'view' && (
            <motion.div
              key="view"
              initial={{ opacity: 0, x: 50 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -50 }}
              className="space-y-4"
            >
              <div className="flex items-center gap-3 mb-6">
                <div className="w-12 h-12 bg-gradient-to-br from-blue-500 to-cyan-500 rounded-lg flex items-center justify-center">
                  <Eye className="w-6 h-6 text-white" />
                </div>
                <div>
                  <h4 className="text-xl font-bold text-white">Choose Your View</h4>
                  <p className="text-sm text-white/60">What do you want to wake up to?</p>
                </div>
              </div>

              <div className="space-y-3">
                {views.map((view) => (
                  <button
                    key={view.id}
                    onClick={() => setSelectedView(view.id)}
                    className={`w-full p-4 rounded-xl border-2 transition-all text-left relative ${
                      selectedView === view.id
                        ? 'bg-blue-500/20 border-blue-500'
                        : 'bg-white/5 border-white/10 hover:bg-white/10'
                    }`}
                  >
                    <div className="flex items-center gap-3">
                      <span className="text-3xl">{view.icon}</span>
                      <div className="flex-1">
                        <p className="text-white font-medium">{view.name}</p>
                        <p className="text-white/60 text-sm">
                          {view.price > 0 ? `+$${view.price}/mo` : 'No extra cost'}
                        </p>
                      </div>
                      {selectedView === view.id && (
                        <Check className="w-5 h-5 text-blue-400" />
                      )}
                    </div>
                  </button>
                ))}
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </div>

      {/* Footer Buttons */}
      <div className="px-4 py-4 border-t border-white/10">
        <div className="flex gap-3">
          {step !== 'neighborhood' && (
            <button
              onClick={() => {
                if (step === 'building') setStep('neighborhood');
                else if (step === 'features') setStep('building');
                else if (step === 'view') setStep('features');
              }}
              className="px-6 py-3 bg-white/10 rounded-xl text-white font-semibold hover:bg-white/20 transition-all"
            >
              Back
            </button>
          )}

          <button
            onClick={handleNext}
            disabled={!canProceed}
            className="flex-1 py-3 bg-gradient-to-r from-blue-500 to-cyan-500 rounded-xl text-white font-semibold hover:opacity-90 transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
          >
            {step === 'view' ? (
              <>
                <Sparkles className="w-5 h-5" />
                See Matches
              </>
            ) : (
              'Next'
            )}
          </button>
        </div>
      </div>
    </div>
  );
}
