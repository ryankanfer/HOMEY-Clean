'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';
import CinematicBackground from '@/components/CinematicBackground';
import BottomNav from '@/components/BottomNav';
import { auth, db } from '@/lib/supabase';

type ContactCategory = 'agents' | 'lenders' | 'inspectors' | 'movers' | 'contractors' | 'other';

interface Contact {
  id: string;
  name: string;
  role: string;
  category: ContactCategory;
  company: string;
  phone: string;
  email: string;
  avatar?: string;
  rating: number;
  reviewCount: number;
  verified: boolean;
  aiRecommended?: boolean;
  matchScore?: number;
  specializations?: string[];
  serviceAreas?: string[];
  yearsExperience?: number;
  recentReview?: {
    text: string;
    author: string;
    rating: number;
  };
}

interface Recommendation {
  type: string;
  reason: string;
  icon: string;
}

const SAMPLE_CONTACTS: Contact[] = [
  {
    id: '1',
    name: 'Sarah Johnson',
    role: 'Real Estate Agent',
    category: 'agents',
    company: 'Flatiron Living Realty',
    phone: '(555) 123-4567',
    email: 'sarah@flatironliving.com',
    rating: 4.9,
    reviewCount: 127,
    verified: true,
    aiRecommended: true,
    matchScore: 95,
    specializations: ['First-time buyers', 'Manhattan rentals', 'Luxury apartments'],
    serviceAreas: ['Chelsea', 'Flatiron', 'Gramercy'],
    yearsExperience: 8,
    recentReview: {
      text: 'Sarah helped us find our dream apartment in under 2 weeks! She understood exactly what we were looking for.',
      author: 'Jessica M.',
      rating: 5,
    },
  },
  {
    id: '2',
    name: 'Michael Chen',
    role: 'Mortgage Lender',
    category: 'lenders',
    company: 'Prime Home Loans',
    phone: '(555) 987-6543',
    email: 'mchen@primeloans.com',
    rating: 4.8,
    reviewCount: 89,
    verified: true,
    aiRecommended: true,
    matchScore: 88,
    specializations: ['First-time buyers', 'FHA loans', 'Pre-approval'],
    serviceAreas: ['New York', 'New Jersey'],
    yearsExperience: 12,
    recentReview: {
      text: 'Michael got us the best rate and made the process so easy. Highly recommend!',
      author: 'Tom R.',
      rating: 5,
    },
  },
  {
    id: '3',
    name: 'Emma Rodriguez',
    role: 'Home Inspector',
    category: 'inspectors',
    company: 'TruCheck Inspections',
    phone: '(555) 456-7890',
    email: 'emma@trucheck.com',
    rating: 5.0,
    reviewCount: 156,
    verified: true,
    specializations: ['Residential', 'Pre-purchase', 'Move-in inspections'],
    serviceAreas: ['Manhattan', 'Brooklyn', 'Queens'],
    yearsExperience: 15,
    recentReview: {
      text: 'Very thorough inspection. Emma caught issues we would have never noticed.',
      author: 'David L.',
      rating: 5,
    },
  },
  {
    id: '4',
    name: 'James Park',
    role: 'Moving Specialist',
    category: 'movers',
    company: 'Swift Move NYC',
    phone: '(555) 234-5678',
    email: 'james@swiftmove.com',
    rating: 4.7,
    reviewCount: 203,
    verified: true,
    specializations: ['Long-distance', 'Packing services', 'Storage'],
    serviceAreas: ['NYC Metro Area'],
    yearsExperience: 10,
  },
];

export default function DirectoryPage() {
  const router = useRouter();
  const [contacts, setContacts] = useState<Contact[]>(SAMPLE_CONTACTS);
  const [selectedCategory, setSelectedCategory] = useState<ContactCategory | 'all'>('all');
  const [searchQuery, setSearchQuery] = useState('');
  const [userId, setUserId] = useState<string | null>(null);
  const [recommendations, setRecommendations] = useState<Recommendation[]>([]);
  const [selectedContact, setSelectedContact] = useState<Contact | null>(null);
  const [savedContacts, setSavedContacts] = useState<Set<string>>(new Set());
  const [showAIRecommendedOnly, setShowAIRecommendedOnly] = useState(false);

  useEffect(() => {
    initPage();
  }, []);

  const initPage = async () => {
    const { data: { user } } = await auth.getUser();
    if (user) {
      setUserId(user.id);
      generateRecommendations(user.id);
    }
  };

  const generateRecommendations = async (uid: string) => {
    const recs: Recommendation[] = [];

    // Get user's profile to understand their stage
    const { data: profile } = await db.getProfile(uid);
    const prefs = profile?.teach_homey_preferences;

    // Recommend based on user's journey stage
    if (prefs?.searchingFor === 'rent') {
      recs.push({
        type: 'Real Estate Agent',
        reason: 'Connect with an agent who specializes in rentals',
        icon: '🏢',
      });
      recs.push({
        type: 'Renter\'s Insurance',
        reason: 'Most landlords require proof of insurance',
        icon: '🛡️',
      });
    }

    if (prefs?.searchingFor === 'buy') {
      recs.push({
        type: 'Mortgage Lender',
        reason: 'Get pre-approved to strengthen your offers',
        icon: '🏦',
      });
      recs.push({
        type: 'Home Inspector',
        reason: 'Essential for any home purchase',
        icon: '🔍',
      });
    }

    // Always recommend movers if they have a lease or are actively searching
    recs.push({
      type: 'Moving Company',
      reason: 'Book early for best rates and availability',
      icon: '🚚',
    });

    setRecommendations(recs);
  };

  const categories = [
    { id: 'all', label: 'All', icon: '👥' },
    { id: 'agents', label: 'Agents', icon: '🏢' },
    { id: 'lenders', label: 'Lenders', icon: '🏦' },
    { id: 'inspectors', label: 'Inspectors', icon: '🔍' },
    { id: 'movers', label: 'Movers', icon: '🚚' },
    { id: 'contractors', label: 'Contractors', icon: '🔨' },
    { id: 'other', label: 'Other', icon: '📇' },
  ];

  const filteredContacts = contacts.filter(contact => {
    const matchesCategory = selectedCategory === 'all' || contact.category === selectedCategory;
    const matchesSearch = searchQuery === '' ||
      contact.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      contact.company.toLowerCase().includes(searchQuery.toLowerCase()) ||
      contact.specializations?.some(s => s.toLowerCase().includes(searchQuery.toLowerCase())) ||
      contact.serviceAreas?.some(a => a.toLowerCase().includes(searchQuery.toLowerCase()));
    const matchesAIFilter = !showAIRecommendedOnly || contact.aiRecommended;
    return matchesCategory && matchesSearch && matchesAIFilter;
  });

  // Sort AI recommended to top
  const sortedContacts = [...filteredContacts].sort((a, b) => {
    if (a.aiRecommended && !b.aiRecommended) return -1;
    if (!a.aiRecommended && b.aiRecommended) return 1;
    if (a.matchScore && b.matchScore) return b.matchScore - a.matchScore;
    return b.rating - a.rating;
  });

  const toggleSaveContact = (contactId: string) => {
    setSavedContacts(prev => {
      const newSet = new Set(prev);
      if (newSet.has(contactId)) {
        newSet.delete(contactId);
      } else {
        newSet.add(contactId);
      }
      return newSet;
    });
  };

  return (
    <main className="relative min-h-screen pb-24">
      <CinematicBackground timeOfDay="sunset" />

      {/* Header */}
      <header className="relative z-20 px-5 py-6 bg-gradient-to-b from-black/60 to-transparent">
        <div className="flex items-center gap-4 mb-6">
          <button
            onClick={() => router.push('/home')}
            className="text-white/80 hover:text-white transition-colors"
          >
            ← Back
          </button>
          <div className="flex-1">
            <h1 className="text-3xl font-bold text-white">👥 Directory</h1>
            <p className="text-white/60 text-sm mt-1">AI-matched professionals</p>
          </div>
        </div>

        {/* Search */}
        <div className="mb-4">
          <div className="relative">
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search by name, company, specialty, or area..."
              className="w-full px-4 py-3 pl-12 bg-white/10 border border-white/20 rounded-xl text-white placeholder:text-white/40 focus:outline-none focus:border-primary/50"
            />
            <span className="absolute left-4 top-1/2 -translate-y-1/2 text-xl">🔍</span>
          </div>
        </div>

        {/* AI Filter Toggle */}
        <div className="mb-4">
          <button
            onClick={() => setShowAIRecommendedOnly(!showAIRecommendedOnly)}
            className={`px-4 py-2 rounded-xl text-sm font-semibold transition-all flex items-center gap-2 ${
              showAIRecommendedOnly
                ? 'bg-primary text-white'
                : 'bg-white/10 text-white/70 hover:bg-white/20'
            }`}
          >
            <span>🤖</span>
            <span>AI Recommended Only</span>
          </button>
        </div>

        {/* Category Filters */}
        <div className="overflow-x-auto scrollbar-hide">
          <div className="flex gap-2 pb-2">
            {categories.map((cat) => (
              <button
                key={cat.id}
                onClick={() => setSelectedCategory(cat.id as any)}
                className={`px-4 py-2 rounded-full text-sm font-semibold whitespace-nowrap transition-all ${
                  selectedCategory === cat.id
                    ? 'bg-primary text-white'
                    : 'bg-white/10 text-white/70 hover:bg-white/20'
                }`}
              >
                {cat.icon} {cat.label}
              </button>
            ))}
          </div>
        </div>
      </header>

      {/* Content */}
      <div className="relative z-10 px-5 space-y-6">
        {/* AI Recommendations */}
        {recommendations.length > 0 && (
          <motion.div
            className="glass-strong rounded-2xl p-5"
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
          >
            <div className="flex items-center gap-2 mb-4">
              <span className="text-2xl">🤖</span>
              <h3 className="text-lg font-bold text-white">Recommended for You</h3>
            </div>
            <div className="space-y-2">
              {recommendations.map((rec, idx) => (
                <div
                  key={idx}
                  className="flex items-center gap-3 p-3 bg-white/5 rounded-lg"
                >
                  <span className="text-2xl">{rec.icon}</span>
                  <div className="flex-1">
                    <h4 className="text-white font-semibold text-sm">{rec.type}</h4>
                    <p className="text-white/60 text-xs">{rec.reason}</p>
                  </div>
                </div>
              ))}
            </div>
          </motion.div>
        )}

        {/* Contacts List */}
        <div>
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-bold text-white">
              {sortedContacts.length} Contact{sortedContacts.length !== 1 ? 's' : ''}
            </h2>
            {sortedContacts.some(c => c.aiRecommended) && (
              <span className="text-xs text-primary font-semibold">
                {sortedContacts.filter(c => c.aiRecommended).length} AI matches
              </span>
            )}
          </div>

          {sortedContacts.length === 0 ? (
            <div className="glass rounded-xl p-12 text-center">
              <div className="text-6xl mb-4">📇</div>
              <h3 className="text-xl font-semibold text-white mb-2">No contacts found</h3>
              <p className="text-white/60">Try adjusting your filters</p>
            </div>
          ) : (
            <div className="space-y-3">
              {sortedContacts.map((contact, index) => (
                <motion.div
                  key={contact.id}
                  className="glass rounded-xl p-5 hover:bg-white/10 transition-colors cursor-pointer"
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: index * 0.05 }}
                  whileHover={{ x: 4 }}
                  onClick={() => setSelectedContact(contact)}
                >
                  {/* AI Recommended Badge */}
                  {contact.aiRecommended && (
                    <div className="mb-3 flex items-center gap-2">
                      <span className="px-3 py-1 bg-primary/20 text-primary text-xs font-bold rounded-full flex items-center gap-1">
                        <span>🤖</span>
                        <span>AI Match: {contact.matchScore}%</span>
                      </span>
                    </div>
                  )}

                  <div className="flex items-start gap-4">
                    {/* Avatar */}
                    <div className="w-14 h-14 rounded-full bg-gradient-to-br from-primary to-purple-600 flex items-center justify-center text-2xl font-bold text-white flex-shrink-0">
                      {contact.name.charAt(0)}
                    </div>

                    {/* Info */}
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2 mb-1">
                        <h3 className="text-white font-bold text-lg">
                          {contact.name}
                        </h3>
                        {contact.verified && (
                          <span className="text-blue-400 text-sm" title="Verified">
                            ✓
                          </span>
                        )}
                        <button
                          onClick={(e) => {
                            e.stopPropagation();
                            toggleSaveContact(contact.id);
                          }}
                          className="ml-auto text-xl"
                        >
                          {savedContacts.has(contact.id) ? '❤️' : '🤍'}
                        </button>
                      </div>

                      <p className="text-white/80 text-sm mb-1">
                        {contact.role} • {contact.company}
                      </p>

                      {contact.yearsExperience && (
                        <p className="text-white/60 text-xs mb-2">
                          {contact.yearsExperience} years experience
                        </p>
                      )}

                      <div className="flex items-center gap-3 text-white/60 text-sm mb-3">
                        <span className="flex items-center gap-1">
                          ⭐ {contact.rating.toFixed(1)}
                        </span>
                        <span>•</span>
                        <span>{contact.reviewCount} reviews</span>
                      </div>

                      {/* Specializations */}
                      {contact.specializations && contact.specializations.length > 0 && (
                        <div className="flex flex-wrap gap-2 mb-3">
                          {contact.specializations.slice(0, 3).map((spec, idx) => (
                            <span
                              key={idx}
                              className="px-2 py-1 bg-white/10 text-white/70 text-xs rounded-lg"
                            >
                              {spec}
                            </span>
                          ))}
                        </div>
                      )}

                      {/* Service Areas */}
                      {contact.serviceAreas && contact.serviceAreas.length > 0 && (
                        <div className="text-xs text-white/50">
                          📍 {contact.serviceAreas.join(', ')}
                        </div>
                      )}
                    </div>

                    {/* Action Buttons */}
                    <div className="flex flex-col gap-2 flex-shrink-0">
                      <button
                        className="px-4 py-2 bg-primary hover:bg-primary/90 text-white text-sm font-semibold rounded-lg transition-colors whitespace-nowrap"
                        onClick={(e) => {
                          e.stopPropagation();
                          window.location.href = `mailto:${contact.email}`;
                        }}
                      >
                        Contact
                      </button>
                      <button
                        className="px-4 py-2 bg-white/10 hover:bg-white/20 text-white text-sm font-semibold rounded-lg transition-colors"
                        onClick={(e) => e.stopPropagation()}
                      >
                        Share
                      </button>
                    </div>
                  </div>
                </motion.div>
              ))}
            </div>
          )}
        </div>

        {/* Network Info */}
        <div className="glass-strong rounded-xl p-6 border border-primary/30">
          <div className="flex items-start gap-4">
            <div className="text-3xl">🌟</div>
            <div>
              <h3 className="text-lg font-bold text-white mb-2">
                HOMEY Verified Network
              </h3>
              <p className="text-white/70 text-sm leading-relaxed">
                All verified professionals have been vetted by HOMEY and fellow users.
                Our AI matches you with the best professionals based on your specific needs and location.
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Contact Detail Modal */}
      <AnimatePresence>
        {selectedContact && (
          <motion.div
            className="fixed inset-0 z-[200] bg-black/50 backdrop-blur-sm flex items-end sm:items-center justify-center p-5"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={() => setSelectedContact(null)}
          >
            <motion.div
              className="bg-gradient-to-b from-gray-900 to-black rounded-2xl max-w-2xl w-full max-h-[80vh] overflow-y-auto border border-white/10"
              initial={{ opacity: 0, y: 50, scale: 0.95 }}
              animate={{ opacity: 1, y: 0, scale: 1 }}
              exit={{ opacity: 0, y: 50, scale: 0.95 }}
              onClick={(e) => e.stopPropagation()}
            >
              <div className="p-6">
                {/* Header */}
                <div className="flex items-start gap-4 mb-6">
                  <div className="w-20 h-20 rounded-full bg-gradient-to-br from-primary to-purple-600 flex items-center justify-center text-4xl font-bold text-white">
                    {selectedContact.name.charAt(0)}
                  </div>
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-1">
                      <h2 className="text-2xl font-bold text-white">{selectedContact.name}</h2>
                      {selectedContact.verified && <span className="text-blue-400">✓</span>}
                    </div>
                    <p className="text-white/80 mb-2">
                      {selectedContact.role} at {selectedContact.company}
                    </p>
                    <div className="flex items-center gap-3 text-white/60 text-sm">
                      <span className="flex items-center gap-1">
                        ⭐ {selectedContact.rating.toFixed(1)} ({selectedContact.reviewCount} reviews)
                      </span>
                      {selectedContact.yearsExperience && (
                        <>
                          <span>•</span>
                          <span>{selectedContact.yearsExperience} years exp.</span>
                        </>
                      )}
                    </div>
                  </div>
                  <button
                    onClick={() => setSelectedContact(null)}
                    className="text-white/60 hover:text-white text-2xl"
                  >
                    ✕
                  </button>
                </div>

                {/* AI Match Badge */}
                {selectedContact.aiRecommended && (
                  <div className="mb-6 p-4 bg-primary/10 rounded-xl border border-primary/30">
                    <div className="flex items-center gap-2 mb-2">
                      <span className="text-2xl">🤖</span>
                      <h3 className="font-bold text-white">AI Recommendation</h3>
                    </div>
                    <p className="text-white/70 text-sm">
                      {selectedContact.matchScore}% match based on your preferences, location, and needs.
                      This professional specializes in areas that align with your search.
                    </p>
                  </div>
                )}

                {/* Specializations */}
                {selectedContact.specializations && (
                  <div className="mb-6">
                    <h3 className="text-white font-bold mb-3">Specializations</h3>
                    <div className="flex flex-wrap gap-2">
                      {selectedContact.specializations.map((spec, idx) => (
                        <span
                          key={idx}
                          className="px-3 py-2 bg-white/10 text-white text-sm rounded-lg"
                        >
                          {spec}
                        </span>
                      ))}
                    </div>
                  </div>
                )}

                {/* Service Areas */}
                {selectedContact.serviceAreas && (
                  <div className="mb-6">
                    <h3 className="text-white font-bold mb-3">Service Areas</h3>
                    <p className="text-white/70">{selectedContact.serviceAreas.join(', ')}</p>
                  </div>
                )}

                {/* Recent Review */}
                {selectedContact.recentReview && (
                  <div className="mb-6">
                    <h3 className="text-white font-bold mb-3">Recent Review</h3>
                    <div className="p-4 bg-white/5 rounded-xl border border-white/10">
                      <div className="flex items-center gap-2 mb-2">
                        <span className="text-yellow-400">{'⭐'.repeat(selectedContact.recentReview.rating)}</span>
                      </div>
                      <p className="text-white/80 text-sm mb-2">"{selectedContact.recentReview.text}"</p>
                      <p className="text-white/50 text-xs">- {selectedContact.recentReview.author}</p>
                    </div>
                  </div>
                )}

                {/* Contact Info */}
                <div className="mb-6">
                  <h3 className="text-white font-bold mb-3">Contact Information</h3>
                  <div className="space-y-3">
                    <a
                      href={`tel:${selectedContact.phone}`}
                      className="flex items-center gap-3 p-3 bg-white/5 rounded-lg hover:bg-white/10 transition-colors"
                    >
                      <span className="text-xl">📞</span>
                      <span className="text-white">{selectedContact.phone}</span>
                    </a>
                    <a
                      href={`mailto:${selectedContact.email}`}
                      className="flex items-center gap-3 p-3 bg-white/5 rounded-lg hover:bg-white/10 transition-colors"
                    >
                      <span className="text-xl">📧</span>
                      <span className="text-white">{selectedContact.email}</span>
                    </a>
                  </div>
                </div>

                {/* Actions */}
                <div className="flex gap-3">
                  <button
                    onClick={() => {
                      window.location.href = `mailto:${selectedContact.email}`;
                    }}
                    className="flex-1 px-6 py-3 bg-primary hover:bg-primary/90 text-white font-semibold rounded-lg transition-colors"
                  >
                    Send Message
                  </button>
                  <button
                    onClick={() => toggleSaveContact(selectedContact.id)}
                    className={`px-6 py-3 font-semibold rounded-lg transition-colors ${
                      savedContacts.has(selectedContact.id)
                        ? 'bg-red-500/20 text-red-400 hover:bg-red-500/30'
                        : 'bg-white/10 text-white hover:bg-white/20'
                    }`}
                  >
                    {savedContacts.has(selectedContact.id) ? '❤️ Saved' : '🤍 Save'}
                  </button>
                </div>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Bottom Navigation */}
      <BottomNav />
    </main>
  );
}
