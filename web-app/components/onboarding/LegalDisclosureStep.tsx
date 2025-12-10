'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { ChevronLeft, ChevronRight, Check } from 'lucide-react';

interface LegalDisclosureStepProps {
  onNext: () => void;
  onBack: () => void;
}

const DISCLOSURE_CARDS = [
  {
    id: 'terms',
    title: 'Terms of Service',
    lastUpdated: 'December 6, 2025',
    sections: [
      {
        heading: '1. Acceptance of Terms',
        content: 'By creating an account, accessing, or using the HOMEY™ application ("Service"), you agree to be bound by these Terms. If you do not agree, you may not use the Service.\n\nAge Requirement: You must be at least 18 years old to use HOMEY™. By using the Service, you represent and warrant that you possess the legal capacity to enter into a binding contract.'
      },
      {
        heading: '2. Intellectual Property Rights',
        content: 'The Service and its original content, features, and functionality are and will remain the exclusive property of HOMEY POCKET LLC and its licensors.\n\nProprietary Logic: The specific user flows, "pocket" interface concepts, AI agent personalities ("HOMEY"), and underlying algorithms are proprietary trade secrets of HOMEY POCKET LLC.\n\nTrademarks: The HOMEY™ name, the HOMEY logo, and "HOMEY in your pocket" are trademarks of HOMEY POCKET LLC. You may not use these marks without prior written permission.\n\nNo Reverse Engineering: You agree not to reproduce, duplicate, copy, sell, resell, or exploit any portion of the Service, use of the Service, or access to the Service, or attempt to reverse engineer or scrape data from the Service.'
      },
      {
        heading: '3. Artificial Intelligence (AI) Disclaimer',
        content: 'HOMEY™ utilizes advanced artificial intelligence and large language models (LLMs) to provide conversational assistance and recommendations.\n\nAccuracy: While we strive for precision, AI can hallucinate or provide outdated information. You should independently verify all critical information (such as rent prices, square footage, and school zones) with a licensed real estate professional or the property management directly.\n\nNo Professional Advice: HOMEY™ is an information provider, not a licensed real estate broker, financial advisor, or attorney. No interaction with the HOMEY AI constitutes a fiduciary relationship.'
      },
      {
        heading: '4. Limitation of Liability',
        content: 'To the fullest extent permitted by applicable law, in no event shall HOMEY POCKET LLC, its affiliates, directors, or employees be liable for any indirect, punitive, incidental, special, consequential, or exemplary damages, including without limitation damages for loss of profits, goodwill, use, data, or other intangible losses, arising out of or relating to the use of, or inability to use, the Service.'
      },
      {
        heading: '5. Governing Law',
        content: 'These Terms shall be governed and construed in accordance with the laws of the State of New York, without regard to its conflict of law provisions.'
      }
    ]
  },
  {
    id: 'privacy',
    title: 'Privacy Policy & AI Data Disclosure',
    lastUpdated: 'December 6, 2025',
    sections: [
      {
        heading: '1. AI Data Processing',
        content: 'Explicit Consent: By using HOMEY™, you explicitly acknowledge and consent that the text, voice, and search criteria you input into the application may be processed by third-party artificial intelligence providers (including but not limited to OpenAI and Anthropic) solely for the purpose of generating relevant responses and recommendations.\n\nData Usage: Your inputs are used to generate answers. We have implemented safeguards to prevent your personal data from being used to train public third-party models where possible.\n\nOpt-Out: You may opt-out of AI processing by ceasing use of the AI chat features, though this will limit the functionality of the Service.'
      },
      {
        heading: '2. Information We Collect',
        content: '• Identity Data: Name, email address, phone number.\n• Real Estate Preferences: Budget, desired neighborhoods, credit score range (if voluntarily provided), and amenity requirements.\n• Location Data: Approximate location (IP address) or precise location (GPS) if you grant permission.\n• Usage Data: Chat logs, saved listings, and interaction history.'
      },
      {
        heading: '3. How We Use Your Data',
        content: '• To provide the "HOMEY" concierge service and match you with properties.\n• To connect you with human agents or landlords only when you explicitly request it.\n• To improve our proprietary matching algorithms.'
      },
      {
        heading: '4. Data Sharing & Third Parties',
        content: 'We do not sell your personal data. We share data only with Service Providers (Cloud hosting, Maps, AI processors) and for Legal Compliance if required by law.'
      },
      {
        heading: '5. New York City Tenant Data Privacy',
        content: 'In compliance with NYC data standards, we collect only the minimum amount of data necessary. If you utilize HOMEY to interface with "smart access" building systems (future feature), specific consent will be obtained for biometric or keyless entry data, which will be retained for no longer than 90 days after deactivation.'
      },
      {
        heading: '6. Your Rights (Data Deletion)',
        content: 'You have the right to access, correct, or delete your personal data.\n\nTo Request Deletion: Email support@homey.app or use the "Delete Account" function in the app settings. We will permanently erase your data within 30 days of the request.'
      }
    ]
  },
  {
    id: 'cookies',
    title: 'Cookie Policy',
    lastUpdated: 'December 6, 2025',
    sections: [
      {
        heading: 'Cookie Usage',
        content: 'We use cookies and similar tracking technologies to track the activity on our Service and hold certain information.\n\nEssential Cookies: Required for login and security.\n\nPreference Cookies: Remember your search filters and "HOMEY" chat history context.\n\nAnalytics Cookies: Help us understand how users interact with the app.'
      }
    ]
  }
];

export default function LegalDisclosureStep({ onNext, onBack }: LegalDisclosureStepProps) {
  const [currentCard, setCurrentCard] = useState(0);
  const [acceptedCards, setAcceptedCards] = useState<Set<string>>(new Set());
  const [direction, setDirection] = useState(1);

  const currentDisclosure = DISCLOSURE_CARDS[currentCard];
  const allAccepted = acceptedCards.size === DISCLOSURE_CARDS.length;

  const handleAccept = () => {
    const newAccepted = new Set(acceptedCards).add(currentDisclosure.id);
    setAcceptedCards(newAccepted);

    // Auto-advance to next card if not on last one
    if (currentCard < DISCLOSURE_CARDS.length - 1) {
      setDirection(1);
      setCurrentCard(prev => prev + 1);
    }
  };

  const handlePrevCard = () => {
    if (currentCard > 0) {
      setDirection(-1);
      setCurrentCard(prev => prev - 1);
    }
  };

  const handleNextCard = () => {
    if (currentCard < DISCLOSURE_CARDS.length - 1) {
      setDirection(1);
      setCurrentCard(prev => prev + 1);
    }
  };

  const slideVariants = {
    enter: (direction: number) => ({
      x: direction > 0 ? 1000 : -1000,
      opacity: 0
    }),
    center: {
      x: 0,
      opacity: 1
    },
    exit: (direction: number) => ({
      x: direction < 0 ? 1000 : -1000,
      opacity: 0
    })
  };

  return (
    <div className="relative min-h-screen flex flex-col items-center justify-center px-6 py-12">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="text-center mb-8 max-w-2xl"
      >
        <h1 className="text-4xl md:text-5xl font-light text-white mb-4" style={{ fontFamily: 'Playfair Display, serif' }}>
          House Rules
        </h1>
        <p className="text-white/60 text-lg">
          A few quick things to review before we get started
        </p>
      </motion.div>

      {/* Progress Dots */}
      <div className="flex gap-2 mb-8">
        {DISCLOSURE_CARDS.map((card, index) => (
          <div
            key={card.id}
            className={`h-2 rounded-full transition-all duration-300 ${
              index === currentCard
                ? 'w-8 bg-gradient-to-r from-purple-500 to-pink-500'
                : acceptedCards.has(card.id)
                ? 'w-2 bg-green-500'
                : 'w-2 bg-white/20'
            }`}
          />
        ))}
      </div>

      {/* Card Container */}
      <div className="relative w-full max-w-2xl h-[600px] mb-8">
        <AnimatePresence mode="wait" custom={direction}>
          <motion.div
            key={currentCard}
            custom={direction}
            variants={slideVariants}
            initial="enter"
            animate="center"
            exit="exit"
            transition={{
              x: { type: 'spring', stiffness: 300, damping: 30 },
              opacity: { duration: 0.2 }
            }}
            className="absolute inset-0"
          >
            <div className="h-full bg-gradient-to-br from-slate-900/95 to-slate-800/95 backdrop-blur-xl border border-white/10 rounded-3xl p-8 overflow-hidden flex flex-col">
              {/* Card Header */}
              <div className="flex items-start justify-between mb-6">
                <div>
                  <h2 className="text-2xl font-bold text-white mb-2">
                    {currentDisclosure.title}
                  </h2>
                  <p className="text-white/40 text-sm">
                    Last Updated: {currentDisclosure.lastUpdated} • Jurisdiction: NY, USA
                  </p>
                </div>
                {acceptedCards.has(currentDisclosure.id) && (
                  <motion.div
                    initial={{ scale: 0 }}
                    animate={{ scale: 1 }}
                    className="w-8 h-8 rounded-full bg-green-500 flex items-center justify-center flex-shrink-0"
                  >
                    <Check className="w-5 h-5 text-white" />
                  </motion.div>
                )}
              </div>

              {/* Scrollable Content */}
              <div className="flex-1 overflow-y-auto pr-4 space-y-6 scrollbar-thin scrollbar-thumb-white/10 scrollbar-track-transparent">
                {currentDisclosure.sections.map((section, index) => (
                  <div key={index}>
                    <h3 className="text-white font-bold mb-2">{section.heading}</h3>
                    <p className="text-white/70 text-sm leading-relaxed whitespace-pre-line">
                      {section.content}
                    </p>
                  </div>
                ))}
              </div>

              {/* Accept Button */}
              {!acceptedCards.has(currentDisclosure.id) && (
                <motion.button
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 0.3 }}
                  onClick={handleAccept}
                  className="mt-6 w-full px-6 py-4 bg-gradient-to-r from-purple-500 to-pink-500 text-white rounded-2xl font-bold text-lg hover:shadow-lg hover:shadow-purple-500/50 transition-all active:scale-95"
                >
                  I Accept
                </motion.button>
              )}
            </div>
          </motion.div>
        </AnimatePresence>
      </div>

      {/* Navigation */}
      <div className="flex items-center justify-between w-full max-w-2xl mb-8">
        <button
          onClick={handlePrevCard}
          disabled={currentCard === 0}
          className="flex items-center gap-2 px-6 py-3 rounded-xl bg-white/10 text-white disabled:opacity-30 disabled:cursor-not-allowed hover:bg-white/20 transition-all"
        >
          <ChevronLeft className="w-5 h-5" />
          Previous
        </button>

        <span className="text-white/60 text-sm">
          {currentCard + 1} of {DISCLOSURE_CARDS.length}
        </span>

        {/* Spacer to maintain layout balance */}
        <div className="w-[120px]" />
      </div>

      {/* Continue Button */}
      {allAccepted && (
        <motion.button
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          onClick={(e) => {
            e.preventDefault();
            onNext();
          }}
          className="px-12 py-4 bg-gradient-to-r from-green-500 to-emerald-500 text-white rounded-2xl font-bold text-xl hover:shadow-lg hover:shadow-green-500/50 transition-all active:scale-95"
        >
          Continue to Registration
        </motion.button>
      )}
    </div>
  );
}
