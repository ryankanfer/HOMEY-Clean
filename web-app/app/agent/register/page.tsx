'use client';

export const dynamic = 'force-dynamic';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';
import {
  User,
  Mail,
  Lock,
  Building2,
  CreditCard,
  MapPin,
  Briefcase,
  CheckCircle2,
  ArrowRight,
  ArrowLeft,
  Loader2
} from 'lucide-react';
import { supabase, auth, db, agentDb } from '@/lib/supabase';

interface RegistrationData {
  // Step 1: Account
  email: string;
  password: string;
  confirmPassword: string;
  fullName: string;

  // Step 2: License & Brokerage
  licenseNumber: string;
  licenseState: string;
  brokerageName: string;

  // Step 3: Professional Details
  specialties: string[];
  professionalPhone: string;
  bio: string;

  // Step 4: Service Area
  serviceNeighborhoods: string[];
  serviceRadiusMiles: number;
}

const US_STATES = [
  'AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'FL', 'GA',
  'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD',
  'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ',
  'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC',
  'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY'
];

const SPECIALTY_OPTIONS = [
  'Residential Sales',
  'Luxury Homes',
  'First-Time Buyers',
  'Investment Properties',
  'Commercial Real Estate',
  'New Construction',
  'Relocation',
  'Short Sales',
  'Foreclosures',
  'Property Management'
];

// Hierarchical neighborhood structure: State → City → Borough/District → Neighborhoods
const NEIGHBORHOODS_BY_STATE: Record<string, Record<string, Record<string, string[]> | string[]>> = {
  'CA': {
    'San Diego': {
      'Central': ['Downtown', 'Gaslamp Quarter', 'East Village', 'Little Italy', 'Cortez Hill', 'Marina District', 'Bankers Hill'],
      'North County Coastal': ['La Jolla', 'Pacific Beach', 'Mission Beach', 'Ocean Beach', 'Point Loma', 'Sunset Cliffs'],
      'Mid-City': ['Hillcrest', 'North Park', 'South Park', 'University Heights', 'Normal Heights', 'Kensington', 'Talmadge'],
      'North Central': ['Clairemont', 'Bay Park', 'Bay Ho', 'Linda Vista', 'Serra Mesa', 'Kearny Mesa', 'Mission Valley'],
      'Northern': ['Mira Mesa', 'Scripps Ranch', 'Rancho Peñasquitos', 'Carmel Valley', 'University City', 'Torrey Pines'],
      'Eastern': ['Allied Gardens', 'Del Cerro', 'Grantville', 'San Carlos', 'Navajo', 'Tierrasanta', 'College Area'],
      'Southern': ['Golden Hill', 'Grant Hill', 'Sherman Heights', 'Barrio Logan', 'Logan Heights', 'Paradise Hills', 'Skyline']
    },
    'Los Angeles': {
      'Central LA': ['Downtown', 'Arts District', 'Little Tokyo', 'Chinatown', 'Echo Park', 'Silver Lake', 'Los Feliz'],
      'Westside': ['Santa Monica', 'Venice', 'Marina del Rey', 'Culver City', 'Palms', 'Mar Vista', 'Playa Vista'],
      'Hollywood': ['Hollywood', 'West Hollywood', 'Hollywood Hills', 'Studio City', 'North Hollywood'],
      'South Bay': ['Manhattan Beach', 'Hermosa Beach', 'Redondo Beach', 'Torrance', 'El Segundo', 'Hawthorne'],
      'San Fernando Valley': ['Sherman Oaks', 'Encino', 'Tarzana', 'Woodland Hills', 'Calabasas', 'Van Nuys'],
      'Pasadena Area': ['Pasadena', 'South Pasadena', 'Altadena', 'Glendale', 'Burbank']
    },
    'San Francisco': {
      'Downtown': ['Financial District', 'Union Square', 'Tenderloin', 'Civic Center', 'SoMa'],
      'Northern': ['North Beach', 'Fisherman\'s Wharf', 'Russian Hill', 'Nob Hill', 'Pacific Heights', 'Marina'],
      'Western': ['Richmond', 'Sunset', 'Parkside', 'Outer Richmond', 'Outer Sunset'],
      'Eastern': ['Mission', 'Potrero Hill', 'Dogpatch', 'Bayview', 'Excelsior'],
      'Central': ['Hayes Valley', 'Castro', 'Noe Valley', 'Glen Park', 'Twin Peaks']
    }
  },
  'NY': {
    'New York City': {
      'Manhattan': ['Upper East Side', 'Upper West Side', 'Midtown', 'Chelsea', 'Greenwich Village', 'SoHo', 'Tribeca', 'Lower East Side', 'East Village', 'Harlem', 'Washington Heights', 'Inwood', 'Financial District', 'Battery Park City'],
      'Brooklyn': ['Williamsburg', 'Greenpoint', 'Park Slope', 'Brooklyn Heights', 'DUMBO', 'Cobble Hill', 'Carroll Gardens', 'Boerum Hill', 'Fort Greene', 'Clinton Hill', 'Bed-Stuy', 'Bushwick', 'Sunset Park', 'Bay Ridge', 'Bensonhurst'],
      'Queens': ['Long Island City', 'Astoria', 'Sunnyside', 'Woodside', 'Jackson Heights', 'Elmhurst', 'Forest Hills', 'Rego Park', 'Flushing', 'Bayside', 'Ridgewood'],
      'Bronx': ['Riverdale', 'Kingsbridge', 'Fordham', 'Belmont', 'Morris Park', 'Pelham Bay', 'Throggs Neck', 'Soundview', 'Mott Haven', 'Hunts Point'],
      'Staten Island': ['St. George', 'Stapleton', 'Tompkinsville', 'New Brighton', 'West Brighton', 'Port Richmond', 'Tottenville']
    }
  },
  'TX': {
    'Houston': {
      'Inner Loop': ['Downtown', 'Midtown', 'Montrose', 'Heights', 'Museum District', 'Rice Village', 'West University'],
      'West': ['Galleria', 'River Oaks', 'Memorial', 'Energy Corridor', 'Katy'],
      'North': ['Spring', 'The Woodlands', 'Tomball', 'Willowbrook'],
      'East': ['East End', 'Pasadena', 'Deer Park', 'Baytown'],
      'South': ['Pearland', 'Friendswood', 'League City', 'Clear Lake']
    },
    'Austin': ['Downtown', 'East Austin', 'South Congress', 'Travis Heights', 'Zilker', 'West Lake Hills', 'Hyde Park', 'North Loop', 'Mueller', 'Clarksville'],
    'Dallas': ['Downtown', 'Uptown', 'Deep Ellum', 'Bishop Arts', 'Knox-Henderson', 'Lakewood', 'White Rock Lake', 'Preston Hollow', 'Park Cities']
  },
  'FL': {
    'Miami': {
      'Miami Beach': ['South Beach', 'Mid-Beach', 'North Beach', 'Surfside', 'Bal Harbour'],
      'Downtown': ['Brickell', 'Downtown Miami', 'Edgewater', 'Wynwood', 'Design District'],
      'North': ['Aventura', 'Sunny Isles', 'North Miami', 'North Miami Beach'],
      'West': ['Doral', 'Kendall', 'Westchester', 'Coral Gables', 'Coconut Grove'],
      'South': ['Pinecrest', 'Palmetto Bay', 'Cutler Bay', 'Homestead']
    }
  }
};

export default function AgentRegisterPage() {
  const router = useRouter();
  const [step, setStep] = useState(1);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const [formData, setFormData] = useState<RegistrationData>({
    email: '',
    password: '',
    confirmPassword: '',
    fullName: '',
    licenseNumber: '',
    licenseState: 'CA',
    brokerageName: '',
    specialties: [],
    professionalPhone: '',
    bio: '',
    serviceNeighborhoods: [],
    serviceRadiusMiles: 25
  });

  // Neighborhood selection state
  const [selectedCity, setSelectedCity] = useState<string>('');
  const [expandedDistricts, setExpandedDistricts] = useState<Set<string>>(new Set());

  const updateField = (field: keyof RegistrationData, value: any) => {
    setFormData(prev => ({ ...prev, [field]: value }));
    setError(null);
  };

  const toggleSpecialty = (specialty: string) => {
    setFormData(prev => ({
      ...prev,
      specialties: prev.specialties.includes(specialty)
        ? prev.specialties.filter(s => s !== specialty)
        : [...prev.specialties, specialty]
    }));
  };

  const toggleNeighborhood = (neighborhood: string) => {
    setFormData(prev => ({
      ...prev,
      serviceNeighborhoods: prev.serviceNeighborhoods.includes(neighborhood)
        ? prev.serviceNeighborhoods.filter(n => n !== neighborhood)
        : [...prev.serviceNeighborhoods, neighborhood]
    }));
  };

  const toggleDistrict = (district: string) => {
    setExpandedDistricts(prev => {
      const next = new Set(prev);
      if (next.has(district)) {
        next.delete(district);
      } else {
        next.add(district);
      }
      return next;
    });
  };

  // Get available cities for selected state
  const getAvailableCities = () => {
    const stateData = NEIGHBORHOODS_BY_STATE[formData.licenseState];
    return stateData ? Object.keys(stateData) : [];
  };

  // Check if a city has districts or flat neighborhoods
  const cityHasDistricts = (city: string) => {
    const stateData = NEIGHBORHOODS_BY_STATE[formData.licenseState];
    if (!stateData) return false;
    const cityData = stateData[city];
    if (!cityData) return false;
    // Check if first value is an object (districts) or array (flat neighborhoods)
    if (Array.isArray(cityData)) return false;
    const firstKey = Object.keys(cityData)[0];
    return firstKey ? Array.isArray(cityData[firstKey]) : false;
  };

  // Get districts for a city
  const getCityDistricts = (city: string) => {
    const stateData = NEIGHBORHOODS_BY_STATE[formData.licenseState];
    if (!stateData) return [];
    const cityData = stateData[city];
    if (!cityData || !cityHasDistricts(city)) return [];
    return Object.keys(cityData);
  };

  // Get neighborhoods for a city/district
  const getNeighborhoods = (city: string, district?: string) => {
    const stateData = NEIGHBORHOODS_BY_STATE[formData.licenseState];
    if (!stateData) return [];
    const cityData = stateData[city];
    if (!cityData) return [];

    if (district) {
      return (cityData as Record<string, string[]>)[district] || [];
    } else {
      // Flat neighborhood list
      return cityData as string[];
    }
  };

  const validateStep = (currentStep: number): boolean => {
    setError(null);

    switch (currentStep) {
      case 1:
        if (!formData.email || !formData.password || !formData.fullName) {
          setError('Please fill in all required fields');
          return false;
        }
        if (formData.password.length < 6) {
          setError('Password must be at least 6 characters');
          return false;
        }
        if (formData.password !== formData.confirmPassword) {
          setError('Passwords do not match');
          return false;
        }
        if (!/\S+@\S+\.\S+/.test(formData.email)) {
          setError('Please enter a valid email');
          return false;
        }
        return true;

      case 2:
        if (!formData.licenseNumber || !formData.licenseState || !formData.brokerageName) {
          setError('Please fill in all required fields');
          return false;
        }
        return true;

      case 3:
        if (!formData.professionalPhone) {
          setError('Please enter your professional phone number');
          return false;
        }
        if (formData.specialties.length === 0) {
          setError('Please select at least one specialty');
          return false;
        }
        return true;

      case 4:
        if (formData.serviceNeighborhoods.length === 0) {
          setError('Please select at least one neighborhood');
          return false;
        }
        return true;

      default:
        return true;
    }
  };

  const handleNext = () => {
    if (validateStep(step)) {
      // Auto-select city if moving to step 4 and only one city available
      if (step === 3) {
        const cities = getAvailableCities();
        if (cities.length === 1 && !selectedCity) {
          setSelectedCity(cities[0]);
        }
      }
      setStep(step + 1);
    }
  };

  const handleBack = () => {
    setError(null);
    setStep(step - 1);
  };

  const handleSubmit = async () => {
    if (!validateStep(4)) return;

    try {
      setLoading(true);
      setError(null);

      // Step 1: Create Supabase auth account with metadata
      const { data: authData, error: authError } = await supabase.auth.signUp({
        email: formData.email,
        password: formData.password,
        options: {
          data: {
            full_name: formData.fullName,
            display_name: formData.fullName.split(' ')[0],
          }
        }
      });

      if (authError) throw authError;
      if (!authData.user) throw new Error('Failed to create account');

      console.log('✅ Auth account created:', authData.user.id);

      // Step 2: Create/update user profile in profiles table
      try {
        const { error: userProfileError } = await db.updateProfile(authData.user.id, {
          email: formData.email,
          full_name: formData.fullName,
          display_name: formData.fullName.split(' ')[0],
        });

        if (userProfileError) {
          console.warn('⚠️ User profile update failed (non-critical):', userProfileError);
        } else {
          console.log('✅ User profile created');
        }
      } catch (profileErr) {
        console.warn('⚠️ User profile error (non-critical):', profileErr);
      }

      // Prepare neighborhoods with city context for better data quality
      // Format: "City - Neighborhood" (e.g., "San Diego - Downtown")
      const neighborhoodsWithCity = selectedCity
        ? formData.serviceNeighborhoods.map(n => `${selectedCity} - ${n}`)
        : formData.serviceNeighborhoods;

      // Step 3: Create agent profile with all collected data
      const agentProfileData = {
        // License & Brokerage Info
        license_number: formData.licenseNumber,
        license_state: formData.licenseState,
        brokerage_name: formData.brokerageName,

        // Professional Details
        specialties: formData.specialties,
        professional_phone: formData.professionalPhone,
        professional_email: formData.email,
        bio: formData.bio || null,

        // Service Area
        service_neighborhoods: neighborhoodsWithCity,
        service_radius_miles: formData.serviceRadiusMiles,

        // Default Settings
        accepting_new_clients: true,
        verified: false,
        auto_respond_enabled: true,
        availability_status: 'available',
      };

      console.log('📝 Creating agent profile with data:', agentProfileData);

      const { error: agentProfileError } = await agentDb.createAgentProfile(
        authData.user.id,
        agentProfileData
      );

      if (agentProfileError) {
        console.error('❌ Agent profile creation failed:', agentProfileError);
        throw agentProfileError;
      }

      console.log('✅ Agent profile created successfully');

      // Success! Redirect to agent dashboard
      router.push('/agent');

    } catch (err: any) {
      console.error('Registration error:', err);
      setError(err.message || 'Failed to create account. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-950 via-purple-950 to-slate-950 flex items-center justify-center p-4">
      <div className="w-full max-w-2xl">
        {/* Progress Bar */}
        <div className="mb-8">
          <div className="flex items-center justify-between mb-2">
            {[1, 2, 3, 4].map((num) => (
              <div key={num} className="flex items-center">
                <div
                  className={`w-10 h-10 rounded-full flex items-center justify-center font-bold transition-all ${
                    num < step
                      ? 'bg-green-500 text-white'
                      : num === step
                      ? 'bg-gradient-to-r from-purple-500 to-pink-500 text-white'
                      : 'bg-white/10 text-white/40'
                  }`}
                >
                  {num < step ? <CheckCircle2 className="w-6 h-6" /> : num}
                </div>
                {num < 4 && (
                  <div
                    className={`w-full h-1 mx-2 transition-all ${
                      num < step ? 'bg-green-500' : 'bg-white/10'
                    }`}
                    style={{ width: '100px' }}
                  />
                )}
              </div>
            ))}
          </div>
          <div className="flex justify-between text-xs text-white/60">
            <span>Account</span>
            <span>License</span>
            <span>Professional</span>
            <span>Service Area</span>
          </div>
        </div>

        {/* Form Card */}
        <motion.div
          className="glass-strong rounded-2xl p-6 md:p-8 border border-white/10"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
        >
          <h1 className="text-2xl md:text-3xl font-bold text-white mb-2">
            Become a HOMEY Agent
          </h1>
          <p className="text-white/60 mb-6">
            {step === 1 && 'Create your account to get started'}
            {step === 2 && 'Verify your real estate license'}
            {step === 3 && 'Tell us about your expertise'}
            {step === 4 && 'Define your service area'}
          </p>

          {error && (
            <div className="mb-6 p-4 rounded-xl bg-red-500/20 border border-red-500/50 text-red-300 text-sm">
              {error}
            </div>
          )}

          <AnimatePresence mode="wait">
            {/* Step 1: Account Creation */}
            {step === 1 && (
              <motion.div
                key="step1"
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -20 }}
                className="space-y-4"
              >
                <div>
                  <label className="block text-white text-sm font-medium mb-2">
                    Full Name *
                  </label>
                  <div className="relative">
                    <User className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-white/40" />
                    <input
                      type="text"
                      value={formData.fullName}
                      onChange={(e) => updateField('fullName', e.target.value)}
                      placeholder="John Doe"
                      className="w-full pl-12 pr-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-white/40 focus:outline-none focus:border-purple-500/50"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-white text-sm font-medium mb-2">
                    Email Address *
                  </label>
                  <div className="relative">
                    <Mail className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-white/40" />
                    <input
                      type="email"
                      value={formData.email}
                      onChange={(e) => updateField('email', e.target.value)}
                      placeholder="agent@example.com"
                      className="w-full pl-12 pr-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-white/40 focus:outline-none focus:border-purple-500/50"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-white text-sm font-medium mb-2">
                    Password *
                  </label>
                  <div className="relative">
                    <Lock className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-white/40" />
                    <input
                      type="password"
                      value={formData.password}
                      onChange={(e) => updateField('password', e.target.value)}
                      placeholder="••••••••"
                      className="w-full pl-12 pr-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-white/40 focus:outline-none focus:border-purple-500/50"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-white text-sm font-medium mb-2">
                    Confirm Password *
                  </label>
                  <div className="relative">
                    <Lock className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-white/40" />
                    <input
                      type="password"
                      value={formData.confirmPassword}
                      onChange={(e) => updateField('confirmPassword', e.target.value)}
                      placeholder="••••••••"
                      className="w-full pl-12 pr-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-white/40 focus:outline-none focus:border-purple-500/50"
                    />
                  </div>
                </div>
              </motion.div>
            )}

            {/* Step 2: License & Brokerage */}
            {step === 2 && (
              <motion.div
                key="step2"
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -20 }}
                className="space-y-4"
              >
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-white text-sm font-medium mb-2">
                      License Number *
                    </label>
                    <div className="relative">
                      <CreditCard className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-white/40" />
                      <input
                        type="text"
                        value={formData.licenseNumber}
                        onChange={(e) => updateField('licenseNumber', e.target.value)}
                        placeholder="CA-DRE-12345678"
                        className="w-full pl-12 pr-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-white/40 focus:outline-none focus:border-purple-500/50"
                      />
                    </div>
                  </div>

                  <div>
                    <label className="block text-white text-sm font-medium mb-2">
                      License State *
                    </label>
                    <select
                      value={formData.licenseState}
                      onChange={(e) => updateField('licenseState', e.target.value)}
                      className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white focus:outline-none focus:border-purple-500/50"
                    >
                      {US_STATES.map((state) => (
                        <option key={state} value={state}>
                          {state}
                        </option>
                      ))}
                    </select>
                  </div>
                </div>

                <div>
                  <label className="block text-white text-sm font-medium mb-2">
                    Brokerage Name *
                  </label>
                  <div className="relative">
                    <Building2 className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-white/40" />
                    <input
                      type="text"
                      value={formData.brokerageName}
                      onChange={(e) => updateField('brokerageName', e.target.value)}
                      placeholder="Acme Realty Group"
                      className="w-full pl-12 pr-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-white/40 focus:outline-none focus:border-purple-500/50"
                    />
                  </div>
                </div>
              </motion.div>
            )}

            {/* Step 3: Professional Details */}
            {step === 3 && (
              <motion.div
                key="step3"
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -20 }}
                className="space-y-4"
              >
                <div>
                  <label className="block text-white text-sm font-medium mb-2">
                    Professional Phone *
                  </label>
                  <input
                    type="tel"
                    value={formData.professionalPhone}
                    onChange={(e) => updateField('professionalPhone', e.target.value)}
                    placeholder="(555) 123-4567"
                    className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-white/40 focus:outline-none focus:border-purple-500/50"
                  />
                </div>

                <div>
                  <label className="block text-white text-sm font-medium mb-2">
                    Specialties * (Select at least one)
                  </label>
                  <div className="grid grid-cols-2 gap-2">
                    {SPECIALTY_OPTIONS.map((specialty) => (
                      <button
                        key={specialty}
                        type="button"
                        onClick={() => toggleSpecialty(specialty)}
                        className={`px-3 py-2 rounded-lg text-sm font-medium transition-all ${
                          formData.specialties.includes(specialty)
                            ? 'bg-gradient-to-r from-purple-500 to-pink-500 text-white'
                            : 'bg-white/5 text-white/60 hover:bg-white/10 border border-white/10'
                        }`}
                      >
                        {specialty}
                      </button>
                    ))}
                  </div>
                </div>

                <div>
                  <label className="block text-white text-sm font-medium mb-2">
                    Bio
                  </label>
                  <textarea
                    value={formData.bio}
                    onChange={(e) => updateField('bio', e.target.value)}
                    rows={3}
                    placeholder="Tell clients about yourself and your approach..."
                    className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-white/40 focus:outline-none focus:border-purple-500/50 resize-none"
                  />
                </div>
              </motion.div>
            )}

            {/* Step 4: Service Area */}
            {step === 4 && (
              <motion.div
                key="step4"
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -20 }}
                className="space-y-4"
              >
                <div>
                  <label className="block text-white text-sm font-medium mb-2">
                    Service Radius (miles)
                  </label>
                  <input
                    type="number"
                    min="1"
                    max="100"
                    value={formData.serviceRadiusMiles}
                    onChange={(e) => updateField('serviceRadiusMiles', parseInt(e.target.value) || 25)}
                    className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white focus:outline-none focus:border-purple-500/50"
                  />
                </div>

                {/* City Selection */}
                {getAvailableCities().length > 0 && (
                  <div>
                    <label className="block text-white text-sm font-medium mb-2">
                      Select City/Metro Area *
                    </label>
                    <select
                      value={selectedCity}
                      onChange={(e) => {
                        setSelectedCity(e.target.value);
                        setExpandedDistricts(new Set());
                      }}
                      className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white focus:outline-none focus:border-purple-500/50"
                    >
                      <option value="">Choose a city...</option>
                      {getAvailableCities().map((city) => (
                        <option key={city} value={city}>
                          {city}
                        </option>
                      ))}
                    </select>
                  </div>
                )}

                {/* Neighborhoods */}
                {selectedCity && (
                  <div>
                    <label className="block text-white text-sm font-medium mb-2">
                      Service Neighborhoods * (Select at least one)
                    </label>
                    <div className="max-h-96 overflow-y-auto pr-2 space-y-2">
                      {cityHasDistricts(selectedCity) ? (
                        // Show districts with expandable neighborhoods
                        getCityDistricts(selectedCity).map((district) => (
                          <div key={district} className="space-y-2">
                            <button
                              type="button"
                              onClick={() => toggleDistrict(district)}
                              className="w-full px-4 py-2 bg-white/10 hover:bg-white/[0.15] border border-white/20 rounded-lg text-white font-semibold text-left flex items-center justify-between transition-all"
                            >
                              <span>{district}</span>
                              <span className="text-white/60">
                                {expandedDistricts.has(district) ? '▼' : '▶'}
                              </span>
                            </button>

                            {expandedDistricts.has(district) && (
                              <div className="pl-4 grid grid-cols-2 gap-2">
                                {getNeighborhoods(selectedCity, district).map((neighborhood) => (
                                  <button
                                    key={neighborhood}
                                    type="button"
                                    onClick={() => toggleNeighborhood(neighborhood)}
                                    className={`px-3 py-2 rounded-lg text-sm font-medium transition-all text-left ${
                                      formData.serviceNeighborhoods.includes(neighborhood)
                                        ? 'bg-gradient-to-r from-purple-500 to-pink-500 text-white'
                                        : 'bg-white/5 text-white/60 hover:bg-white/10 border border-white/10'
                                    }`}
                                  >
                                    {neighborhood}
                                  </button>
                                ))}
                              </div>
                            )}
                          </div>
                        ))
                      ) : (
                        // Show flat neighborhood list
                        <div className="grid grid-cols-2 gap-2">
                          {getNeighborhoods(selectedCity).map((neighborhood) => (
                            <button
                              key={neighborhood}
                              type="button"
                              onClick={() => toggleNeighborhood(neighborhood)}
                              className={`px-3 py-2 rounded-lg text-sm font-medium transition-all text-left ${
                                formData.serviceNeighborhoods.includes(neighborhood)
                                  ? 'bg-gradient-to-r from-purple-500 to-pink-500 text-white'
                                  : 'bg-white/5 text-white/60 hover:bg-white/10 border border-white/10'
                              }`}
                            >
                              {neighborhood}
                            </button>
                          ))}
                        </div>
                      )}
                    </div>
                    {formData.serviceNeighborhoods.length > 0 && (
                      <p className="text-sm text-white/60 mt-2">
                        Selected: {formData.serviceNeighborhoods.length} neighborhoods
                      </p>
                    )}
                  </div>
                )}

                {!selectedCity && getAvailableCities().length > 0 && (
                  <p className="text-sm text-white/60 text-center py-8">
                    Please select a city to view available neighborhoods
                  </p>
                )}
              </motion.div>
            )}
          </AnimatePresence>

          {/* Navigation Buttons */}
          <div className="flex gap-3 mt-8">
            {step > 1 && (
              <button
                onClick={handleBack}
                disabled={loading}
                className="px-6 py-3 rounded-xl bg-white/5 hover:bg-white/10 text-white font-semibold border border-white/10 transition-all disabled:opacity-50 flex items-center gap-2"
              >
                <ArrowLeft className="w-5 h-5" />
                Back
              </button>
            )}

            {step < 4 ? (
              <button
                onClick={handleNext}
                className="flex-1 px-6 py-3 rounded-xl bg-gradient-to-r from-purple-500 to-pink-500 text-white font-semibold hover:shadow-lg hover:shadow-purple-500/50 transition-all flex items-center justify-center gap-2"
              >
                Next
                <ArrowRight className="w-5 h-5" />
              </button>
            ) : (
              <button
                onClick={handleSubmit}
                disabled={loading}
                className="flex-1 px-6 py-3 rounded-xl bg-gradient-to-r from-purple-500 to-pink-500 text-white font-semibold hover:shadow-lg hover:shadow-purple-500/50 transition-all disabled:opacity-50 flex items-center justify-center gap-2"
              >
                {loading ? (
                  <>
                    <Loader2 className="w-5 h-5 animate-spin" />
                    Creating Account...
                  </>
                ) : (
                  <>
                    Complete Registration
                    <CheckCircle2 className="w-5 h-5" />
                  </>
                )}
              </button>
            )}
          </div>

          <p className="text-center text-white/40 text-sm mt-6">
            Already have an account?{' '}
            <a href="/login" className="text-purple-400 hover:text-purple-300">
              Sign in
            </a>
          </p>
        </motion.div>
      </div>
    </div>
  );
}
