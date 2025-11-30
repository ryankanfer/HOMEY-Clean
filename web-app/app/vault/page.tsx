'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';
import CinematicBackground from '@/components/CinematicBackground';
import BottomNav from '@/components/BottomNav';
import { auth } from '@/lib/supabase';

type DocumentCategory = 'leases' | 'contracts' | 'inspections' | 'financial' | 'insurance' | 'other';

interface Document {
  id: string;
  name: string;
  category: DocumentCategory;
  size: string;
  date: string;
  secured: boolean;
  expirationDate?: string;
  aiExtracted?: {
    rentAmount?: string;
    landlord?: string;
    address?: string;
    startDate?: string;
    endDate?: string;
    keyTerms?: string[];
  };
}

interface DocumentRecommendation {
  type: string;
  reason: string;
  icon: string;
  priority: 'high' | 'medium' | 'low';
}

const SAMPLE_DOCUMENTS: Document[] = [
  {
    id: '1',
    name: 'Lease Agreement - 245 E 25th St.pdf',
    category: 'leases',
    size: '2.4 MB',
    date: '2024-11-15',
    secured: true,
    expirationDate: '2025-11-15',
    aiExtracted: {
      rentAmount: '$2,800/month',
      landlord: 'Manhattan Properties LLC',
      address: '245 E 25th St, Apt 4B, New York, NY',
      startDate: '2024-11-15',
      endDate: '2025-11-15',
      keyTerms: ['First month + security deposit', 'No pets allowed', '60-day notice required'],
    },
  },
  {
    id: '2',
    name: 'Pre-approval Letter.pdf',
    category: 'financial',
    size: '156 KB',
    date: '2024-11-10',
    secured: true,
    expirationDate: '2025-02-10',
    aiExtracted: {
      rentAmount: 'Up to $450,000',
      keyTerms: ['3.5% down payment', 'Valid for 90 days', 'Rate: 6.875%'],
    },
  },
  {
    id: '3',
    name: 'Home Inspection Report.pdf',
    category: 'inspections',
    size: '5.2 MB',
    date: '2024-11-08',
    secured: true,
    aiExtracted: {
      address: '245 E 25th St, Apt 4B',
      keyTerms: ['No major issues found', 'Minor plumbing updates recommended', 'HVAC in good condition'],
    },
  },
];

export default function VaultPage() {
  const router = useRouter();
  const [documents, setDocuments] = useState<Document[]>([]);
  const [selectedCategory, setSelectedCategory] = useState<DocumentCategory | 'all'>('all');
  const [userId, setUserId] = useState<string | null>(null);
  const [recommendations, setRecommendations] = useState<DocumentRecommendation[]>([]);
  const [expiringDocs, setExpiringDocs] = useState<Document[]>([]);
  const [selectedDoc, setSelectedDoc] = useState<Document | null>(null);
  const [searchQuery, setSearchQuery] = useState('');

  useEffect(() => {
    initPage();
    loadDocuments();
  }, []);

  const loadDocuments = () => {
    const stored = localStorage.getItem('homey_vault_documents');
    if (stored) {
      const docs = JSON.parse(stored);
      setDocuments(docs);
    } else {
      // Initialize with sample documents
      localStorage.setItem('homey_vault_documents', JSON.stringify(SAMPLE_DOCUMENTS));
      setDocuments(SAMPLE_DOCUMENTS);
    }
  };

  const initPage = async () => {
    const { data: { user } } = await auth.getUser();
    if (user) {
      setUserId(user.id);
      generateRecommendations();
      checkExpiringDocuments();
    }
  };

  const generateRecommendations = () => {
    const recs: DocumentRecommendation[] = [];

    // Check for missing documents
    const hasLease = documents.some(d => d.category === 'leases');
    const hasInsurance = documents.some(d => d.category === 'insurance');
    const hasFinancial = documents.some(d => d.category === 'financial');

    if (!hasInsurance) {
      recs.push({
        type: "Renter's Insurance",
        reason: 'Most leases require proof of insurance',
        icon: '🛡️',
        priority: 'high',
      });
    }

    if (!hasFinancial && hasLease) {
      recs.push({
        type: 'Bank Statements',
        reason: 'Helpful for proving income for future applications',
        icon: '💰',
        priority: 'medium',
      });
    }

    if (hasLease && !documents.some(d => d.name.includes('Move-in'))) {
      recs.push({
        type: 'Move-in Checklist',
        reason: 'Document the condition of your apartment',
        icon: '📋',
        priority: 'high',
      });
    }

    setRecommendations(recs);
  };

  const checkExpiringDocuments = () => {
    const now = new Date();
    const thirtyDaysFromNow = new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000);

    const expiring = documents.filter(doc => {
      if (!doc.expirationDate) return false;
      const expDate = new Date(doc.expirationDate);
      return expDate >= now && expDate <= thirtyDaysFromNow;
    });

    setExpiringDocs(expiring);
  };

  const categories = [
    { id: 'all', label: 'All Documents', icon: '📁' },
    { id: 'leases', label: 'Leases', icon: '📄' },
    { id: 'contracts', label: 'Contracts', icon: '✍️' },
    { id: 'inspections', label: 'Inspections', icon: '🔍' },
    { id: 'financial', label: 'Financial', icon: '💰' },
    { id: 'insurance', label: 'Insurance', icon: '🛡️' },
    { id: 'other', label: 'Other', icon: '📌' },
  ];

  const filteredDocs = selectedCategory === 'all'
    ? documents
    : documents.filter(d => d.category === selectedCategory);

  const searchedDocs = searchQuery
    ? filteredDocs.filter(doc =>
        doc.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        doc.aiExtracted?.address?.toLowerCase().includes(searchQuery.toLowerCase()) ||
        doc.aiExtracted?.landlord?.toLowerCase().includes(searchQuery.toLowerCase())
      )
    : filteredDocs;

  const getDaysUntilExpiration = (expirationDate: string) => {
    const now = new Date();
    const expDate = new Date(expirationDate);
    const diffTime = expDate.getTime() - now.getTime();
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    return diffDays;
  };

  return (
    <main className="relative min-h-screen pb-24">
      <CinematicBackground timeOfDay="night" />

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
            <h1 className="text-3xl font-bold text-white">🔐 Vault</h1>
            <p className="text-white/60 text-sm mt-1">AI-powered document management</p>
          </div>
        </div>

        {/* Search Bar */}
        <div className="mb-4">
          <div className="relative">
            <input
              type="text"
              placeholder="Search documents, addresses, landlords..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full px-4 py-3 pl-12 bg-white/10 backdrop-blur-sm border border-white/20 rounded-xl text-white placeholder-white/50 focus:outline-none focus:border-primary/50"
            />
            <span className="absolute left-4 top-1/2 -translate-y-1/2 text-xl">🔍</span>
            {searchQuery && (
              <button
                onClick={() => setSearchQuery('')}
                className="absolute right-4 top-1/2 -translate-y-1/2 text-white/50 hover:text-white"
              >
                ✕
              </button>
            )}
          </div>
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
        {/* Expiring Documents Alert */}
        {expiringDocs.length > 0 && (
          <motion.div
            className="glass-strong rounded-2xl p-5 border border-yellow-500/50"
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
          >
            <div className="flex items-start gap-3">
              <span className="text-3xl">⚠️</span>
              <div className="flex-1">
                <h3 className="text-lg font-bold text-white mb-2">
                  {expiringDocs.length} Document{expiringDocs.length !== 1 ? 's' : ''} Expiring Soon
                </h3>
                <div className="space-y-2">
                  {expiringDocs.map(doc => (
                    <div key={doc.id} className="flex items-center justify-between text-sm">
                      <span className="text-white/80">{doc.name}</span>
                      <span className="text-yellow-400 font-semibold">
                        {getDaysUntilExpiration(doc.expirationDate!)} days
                      </span>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </motion.div>
        )}

        {/* AI Recommendations */}
        {recommendations.length > 0 && (
          <motion.div
            className="glass-strong rounded-2xl p-5"
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
          >
            <div className="flex items-center gap-2 mb-4">
              <span className="text-2xl">🤖</span>
              <h3 className="text-lg font-bold text-white">AI Recommendations</h3>
            </div>
            <div className="space-y-3">
              {recommendations.map((rec, idx) => (
                <motion.div
                  key={idx}
                  className="flex items-start gap-3 p-3 bg-white/5 rounded-lg hover:bg-white/10 transition-colors cursor-pointer"
                  whileHover={{ x: 4 }}
                >
                  <span className="text-2xl">{rec.icon}</span>
                  <div className="flex-1">
                    <div className="flex items-center gap-2">
                      <h4 className="text-white font-semibold">{rec.type}</h4>
                      <span
                        className={`text-xs px-2 py-0.5 rounded-full ${
                          rec.priority === 'high'
                            ? 'bg-red-500/20 text-red-400'
                            : rec.priority === 'medium'
                            ? 'bg-yellow-500/20 text-yellow-400'
                            : 'bg-blue-500/20 text-blue-400'
                        }`}
                      >
                        {rec.priority}
                      </span>
                    </div>
                    <p className="text-white/60 text-sm mt-1">{rec.reason}</p>
                  </div>
                  <button className="px-3 py-1 bg-primary/20 hover:bg-primary/30 text-primary text-sm font-semibold rounded-lg transition-colors">
                    Upload
                  </button>
                </motion.div>
              ))}
            </div>
          </motion.div>
        )}

        {/* Upload Area */}
        <motion.div
          className="glass-strong rounded-2xl p-8 text-center border-2 border-dashed border-white/20 hover:border-primary/50 transition-colors cursor-pointer"
          whileHover={{ scale: 1.01 }}
          whileTap={{ scale: 0.99 }}
        >
          <div className="text-5xl mb-3">📤</div>
          <h3 className="text-xl font-bold text-white mb-2">Upload Documents</h3>
          <p className="text-white/60 mb-4">
            AI will automatically extract key information
          </p>
          <button className="px-6 py-2 bg-primary hover:bg-primary/90 text-white font-semibold rounded-lg transition-colors">
            Choose Files
          </button>
        </motion.div>

        {/* Documents List */}
        <div>
          <h2 className="text-lg font-bold text-white mb-4">
            {searchedDocs.length} Document{searchedDocs.length !== 1 ? 's' : ''}
          </h2>

          {searchedDocs.length === 0 ? (
            <div className="glass rounded-xl p-12 text-center">
              <div className="text-6xl mb-4">📂</div>
              <h3 className="text-xl font-semibold text-white mb-2">
                {searchQuery ? 'No documents found' : 'No documents yet'}
              </h3>
              <p className="text-white/60">
                {searchQuery ? 'Try a different search term' : 'Upload your first document to get started'}
              </p>
            </div>
          ) : (
            <div className="space-y-3">
              {searchedDocs.map((doc) => (
                <motion.div
                  key={doc.id}
                  className="glass rounded-xl p-4 hover:bg-white/10 transition-colors cursor-pointer"
                  whileHover={{ x: 4 }}
                  onClick={() => setSelectedDoc(doc)}
                >
                  <div className="flex items-start gap-4">
                    {/* Icon */}
                    <div className="w-12 h-12 rounded-lg bg-primary/20 flex items-center justify-center text-2xl flex-shrink-0">
                      📄
                    </div>

                    {/* Info */}
                    <div className="flex-1 min-w-0">
                      <div className="flex items-start justify-between gap-2 mb-2">
                        <h3 className="text-white font-semibold">
                          {doc.name}
                        </h3>
                        {doc.expirationDate && getDaysUntilExpiration(doc.expirationDate) <= 30 && (
                          <span className="text-xs px-2 py-1 bg-yellow-500/20 text-yellow-400 rounded-full whitespace-nowrap">
                            Expires in {getDaysUntilExpiration(doc.expirationDate)}d
                          </span>
                        )}
                      </div>

                      <div className="flex items-center gap-3 text-sm text-white/60 mb-3">
                        <span>{doc.size}</span>
                        <span>•</span>
                        <span>{new Date(doc.date).toLocaleDateString()}</span>
                        {doc.secured && (
                          <>
                            <span>•</span>
                            <span className="flex items-center gap-1">
                              <span className="text-green-400">🔒</span>
                              Encrypted
                            </span>
                          </>
                        )}
                      </div>

                      {/* AI Extracted Data */}
                      {doc.aiExtracted && (
                        <div className="bg-primary/5 rounded-lg p-3 border border-primary/20">
                          <div className="flex items-center gap-2 mb-2">
                            <span className="text-sm">🤖</span>
                            <span className="text-xs font-semibold text-primary">AI Extracted</span>
                          </div>
                          <div className="space-y-1 text-sm">
                            {doc.aiExtracted.rentAmount && (
                              <div className="flex items-center gap-2">
                                <span className="text-white/50">Amount:</span>
                                <span className="text-white font-semibold">{doc.aiExtracted.rentAmount}</span>
                              </div>
                            )}
                            {doc.aiExtracted.address && (
                              <div className="flex items-center gap-2">
                                <span className="text-white/50">Address:</span>
                                <span className="text-white">{doc.aiExtracted.address}</span>
                              </div>
                            )}
                            {doc.aiExtracted.landlord && (
                              <div className="flex items-center gap-2">
                                <span className="text-white/50">Landlord:</span>
                                <span className="text-white">{doc.aiExtracted.landlord}</span>
                              </div>
                            )}
                            {doc.aiExtracted.startDate && doc.aiExtracted.endDate && (
                              <div className="flex items-center gap-2">
                                <span className="text-white/50">Term:</span>
                                <span className="text-white">
                                  {new Date(doc.aiExtracted.startDate).toLocaleDateString()} - {new Date(doc.aiExtracted.endDate).toLocaleDateString()}
                                </span>
                              </div>
                            )}
                          </div>
                        </div>
                      )}
                    </div>

                    {/* Actions */}
                    <button className="px-4 py-2 bg-white/10 hover:bg-white/20 text-white text-sm font-semibold rounded-lg transition-colors flex-shrink-0">
                      View
                    </button>
                  </div>
                </motion.div>
              ))}
            </div>
          )}
        </div>

        {/* Security Info */}
        <div className="glass-strong rounded-xl p-6 border border-green-500/30">
          <div className="flex items-start gap-4">
            <div className="text-3xl">🛡️</div>
            <div>
              <h3 className="text-lg font-bold text-white mb-2">
                Bank-Level Security
              </h3>
              <p className="text-white/70 text-sm leading-relaxed">
                Your documents are encrypted end-to-end and stored securely in compliance with industry standards.
                Only you and authorized parties can access your files.
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Document Detail Modal */}
      <AnimatePresence>
        {selectedDoc && (
          <motion.div
            className="fixed inset-0 z-[200] bg-black/50 backdrop-blur-sm flex items-end sm:items-center justify-center p-5"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={() => setSelectedDoc(null)}
          >
            <motion.div
              className="bg-gradient-to-b from-gray-900 to-black rounded-2xl max-w-2xl w-full max-h-[80vh] overflow-y-auto border border-white/10"
              initial={{ opacity: 0, y: 50, scale: 0.95 }}
              animate={{ opacity: 1, y: 0, scale: 1 }}
              exit={{ opacity: 0, y: 50, scale: 0.95 }}
              onClick={(e) => e.stopPropagation()}
            >
              <div className="p-6">
                <div className="flex items-start justify-between mb-6">
                  <div>
                    <h2 className="text-2xl font-bold text-white mb-2">{selectedDoc.name}</h2>
                    <div className="flex items-center gap-3 text-sm text-white/60">
                      <span>{selectedDoc.size}</span>
                      <span>•</span>
                      <span>{new Date(selectedDoc.date).toLocaleDateString()}</span>
                    </div>
                  </div>
                  <button
                    onClick={() => setSelectedDoc(null)}
                    className="text-white/60 hover:text-white text-2xl"
                  >
                    ✕
                  </button>
                </div>

                {selectedDoc.aiExtracted && (
                  <div className="space-y-4">
                    <div className="flex items-center gap-2 mb-4">
                      <span className="text-2xl">🤖</span>
                      <h3 className="text-lg font-bold text-white">AI-Extracted Information</h3>
                    </div>

                    {selectedDoc.aiExtracted.keyTerms && (
                      <div>
                        <h4 className="text-white/70 font-semibold mb-3">Key Terms</h4>
                        <div className="space-y-2">
                          {selectedDoc.aiExtracted.keyTerms.map((term, idx) => (
                            <div
                              key={idx}
                              className="flex items-start gap-3 p-3 bg-white/5 rounded-lg"
                            >
                              <span className="text-primary">•</span>
                              <span className="text-white">{term}</span>
                            </div>
                          ))}
                        </div>
                      </div>
                    )}

                    <div className="pt-4 border-t border-white/10">
                      <button className="w-full px-6 py-3 bg-primary hover:bg-primary/90 text-white font-semibold rounded-lg transition-colors">
                        Download Document
                      </button>
                    </div>
                  </div>
                )}
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
