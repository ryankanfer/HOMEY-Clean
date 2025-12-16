'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Check, X } from 'lucide-react';
import { OnboardingData } from '@/app/onboarding/page';

interface LegalDisclosureStepProps {
  data: OnboardingData;
  onNext: (data: Partial<OnboardingData>) => void;
  isSaving: boolean;
}

const legalContent = {
  tos: `HOMEY TERMS OF SERVICE

Last Updated: December 6, 2025

Welcome to HOMEY. By using our platform, you agree to these terms.

1. ACCEPTANCE OF TERMS
By accessing or using HOMEY's services, you agree to be bound by these Terms of Service and all applicable laws and regulations.

2. USE OF SERVICE
HOMEY provides a real estate search and connection platform. You agree to use the service only for lawful purposes and in accordance with these Terms.

3. USER ACCOUNTS
You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.

4. REAL ESTATE TRANSACTIONS
HOMEY facilitates connections with licensed real estate agents. All real estate transactions are subject to applicable state and federal laws.

5. INTELLECTUAL PROPERTY
All content, features, and functionality on HOMEY are owned by us and are protected by copyright, trademark, and other laws.

6. LIMITATION OF LIABILITY
HOMEY is not liable for any indirect, incidental, special, consequential, or punitive damages arising from your use of the service.

7. MODIFICATIONS
We reserve the right to modify these terms at any time. Continued use of the service constitutes acceptance of modified terms.

For questions, contact us at legal@homey.com`,

  privacy: `PRIVACY & AI DATA POLICY

Last Updated: December 6, 2025

At HOMEY, we take your privacy seriously and are committed to protecting your personal information.

1. INFORMATION WE COLLECT
• Personal information (name, email, phone number)
• Search preferences and browsing history
• Location data for property searches
• Communication records with agents

2. HOW WE USE YOUR DATA
• To provide personalized property recommendations
• To connect you with qualified real estate agents
• To improve our AI-powered search algorithms
• To communicate important updates

3. AI & MACHINE LEARNING
Our platform uses AI to:
• Analyze your preferences and suggest relevant properties
• Match you with compatible agents
• Predict market trends and pricing

Your data helps train our models, but we:
• Never sell your personal information
• Anonymize data used for model training
• Allow you to opt-out of AI features

4. DATA SHARING
We share your information only with:
• Real estate agents you choose to connect with
• Service providers who assist our operations
• Legal authorities when required by law

5. YOUR RIGHTS
You have the right to:
• Access your personal data
• Request data deletion
• Opt-out of marketing communications
• Disable AI personalization

6. DATA SECURITY
We use industry-standard encryption and security measures to protect your information.

Contact our privacy team: privacy@homey.com`,

  cookies: `COOKIE POLICY

Last Updated: December 6, 2025

HOMEY uses cookies and similar technologies to enhance your experience.

1. WHAT ARE COOKIES
Cookies are small text files stored on your device that help us recognize you and remember your preferences.

2. TYPES OF COOKIES WE USE

ESSENTIAL COOKIES (Always Active)
• Authentication and security
• Session management
• Load balancing

ANALYTICS COOKIES (Optional)
• Usage statistics
• Performance monitoring
• Error tracking

PERSONALIZATION COOKIES (Optional)
• Saved searches and preferences
• Recommended properties
• Agent matching

3. THIRD-PARTY COOKIES
We use select third-party services:
• Google Analytics (anonymized)
• Mapbox for property visualization
• Stripe for payment processing

4. MANAGING COOKIES
You can control cookies through:
• Browser settings
• Our cookie preference center
• Opt-out links in emails

5. DO NOT TRACK
We respect Do Not Track signals and will not track you across other websites.

6. COOKIE DURATION
• Session cookies: Deleted when you close your browser
• Persistent cookies: Stored for up to 12 months

For questions: cookies@homey.com`
};

export default function LegalDisclosureStep({ data, onNext, isSaving }: LegalDisclosureStepProps) {
  const [accepted, setAccepted] = useState({ tos: false, privacy: false, cookies: false });
  const [openModal, setOpenModal] = useState<string | null>(null);
  const allAccepted = accepted.tos && accepted.privacy && accepted.cookies;

  const items = [
    { id: 'tos', title: 'Terms of Service', meta: 'Updated Dec 6, 2025 • NY, USA' },
    { id: 'privacy', title: 'Privacy & AI Data', meta: 'We protect your data' },
    { id: 'cookies', title: 'Cookie Policy', meta: 'Essential analytics only' },
  ];

  return (
    <>
      <div className="max-w-md w-full mx-auto px-4">
        <h1 className="text-4xl font-serif text-white mb-3" style={{ fontFamily: 'Playfair Display, serif' }}>
          House Rules
        </h1>
        <p className="text-white/50 text-sm mb-10 leading-relaxed">Protocol Check.</p>

        <div className="space-y-4">
          {items.map((item, index) => {
            const isLast = index === items.length - 1;
            const isAccepted = accepted[item.id as keyof typeof accepted];

            return (
              <motion.div
                key={item.id}
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: index * 0.1 }}
                className={`p-6 rounded-2xl border transition-all cursor-pointer ${
                  isAccepted
                    ? 'bg-white/10 border-white/40'
                    : 'bg-white/5 border-white/5 hover:bg-white/10'
                }`}
                onClick={() => setOpenModal(item.id)}
              >
                <div className="flex items-center justify-between group">
                  <div>
                    <div className="font-medium text-white text-lg">{item.title}</div>
                    <div className="text-xs text-white/40 mt-1 font-mono">{item.meta}</div>
                  </div>
                  <div
                    className={`w-8 h-8 rounded-full border flex items-center justify-center transition-all duration-300 ${
                      isAccepted
                        ? 'bg-white border-white scale-110'
                        : 'border-white/20 group-hover:border-white/50'
                    }`}
                    onClick={(e) => {
                      e.stopPropagation();
                      setAccepted(prev => ({ ...prev, [item.id]: !prev[item.id as keyof typeof accepted] }));
                    }}
                  >
                    {isAccepted && <Check size={16} className="text-black" />}
                  </div>
                </div>

                {/* Show continue button in last card when all accepted */}
                {isLast && allAccepted && (
                  <motion.button
                    initial={{ opacity: 0, height: 0 }}
                    animate={{ opacity: 1, height: 'auto' }}
                    transition={{ delay: 0.2 }}
                    disabled={isSaving}
                    onClick={(e) => {
                      e.stopPropagation();
                      onNext({});
                    }}
                    className="w-full mt-6 py-4 bg-white text-black rounded-xl font-bold text-lg disabled:cursor-not-allowed hover:shadow-[0_0_20px_rgba(255,255,255,0.3)] transition-all"
                  >
                    {isSaving ? 'Saving...' : 'Continue'}
                  </motion.button>
                )}
              </motion.div>
            );
          })}
        </div>
      </div>

      {/* Legal Content Modal */}
      <AnimatePresence>
        {openModal && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 bg-black/80 backdrop-blur-sm z-50 flex items-center justify-center p-4"
            onClick={() => setOpenModal(null)}
          >
            <motion.div
              initial={{ scale: 0.9, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0.9, opacity: 0 }}
              transition={{ type: 'spring', damping: 25, stiffness: 300 }}
              className="bg-gradient-to-b from-white/95 to-white/90 rounded-3xl max-w-2xl w-full max-h-[80vh] overflow-hidden shadow-2xl"
              onClick={(e) => e.stopPropagation()}
            >
              {/* Header */}
              <div className="sticky top-0 bg-white/95 backdrop-blur-sm border-b border-black/5 p-6 flex items-center justify-between">
                <h2 className="text-2xl font-serif text-black" style={{ fontFamily: 'Playfair Display, serif' }}>
                  {items.find(i => i.id === openModal)?.title}
                </h2>
                <button
                  onClick={() => setOpenModal(null)}
                  className="p-2 rounded-full hover:bg-black/5 transition-colors"
                >
                  <X size={24} className="text-black/60" />
                </button>
              </div>

              {/* Content */}
              <div className="p-6 overflow-y-auto max-h-[calc(80vh-120px)]">
                <pre className="whitespace-pre-wrap font-sans text-sm text-black/80 leading-relaxed">
                  {legalContent[openModal as keyof typeof legalContent]}
                </pre>
              </div>

              {/* Footer */}
              <div className="sticky bottom-0 bg-white/95 backdrop-blur-sm border-t border-black/5 p-6">
                <button
                  onClick={() => setOpenModal(null)}
                  className="w-full py-4 bg-black text-white rounded-xl font-bold hover:bg-black/90 transition-all"
                >
                  Close
                </button>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
}
