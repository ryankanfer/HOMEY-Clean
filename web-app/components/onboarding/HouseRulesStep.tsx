'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { ChevronDown, Brain, Lock, Shield, FileText, Eye } from 'lucide-react';

interface HouseRulesStepProps {
  data: any;
  onNext: (data: any) => void;
  isSaving?: boolean;
}

const houseRules = [
  {
    id: 'ai',
    icon: Brain,
    title: "HOMEY uses AI to help you",
    emoji: '🤖',
    summary: "HOMEY is powered by advanced AI to give you personalized recommendations",
    details: "HOMEY uses artificial intelligence (OpenAI & Anthropic) to chat with you and suggest properties. While HOMEY is pretty smart, AI can sometimes make mistakes or 'hallucinate' information. Always double-check important details (like rent prices, square footage, and school zones) with the landlord or a licensed real estate professional. HOMEY is here to help, not replace the experts!",
    neonColor: '#A8DADC',
  },
  {
    id: 'privacy',
    icon: Lock,
    title: "Your data stays private",
    emoji: '🔒',
    summary: "HOMEY protects your personal information and never sells your data",
    details: "HOMEY collects only what is needed to help you find your perfect home: your preferences, budget, and search history. HOMEY shares data only with trusted service providers (like cloud hosting and map services) and only when legally required. You can delete your account and all your data anytime from Settings. For NYC users: HOMEY follows all local tenant data privacy regulations.",
    neonColor: '#B4A7D6',
  },
  {
    id: 'legal',
    icon: Shield,
    title: "No legal advice, just vibes",
    emoji: '⚖️',
    summary: "HOMEY is not a lawyer, broker, or financial advisor",
    details: "HOMEY is an information provider and your friendly apartment-hunting companion, but not a licensed real estate broker, attorney, or financial advisor. Nothing HOMEY provides creates a fiduciary relationship or constitutes professional advice. When it comes to signing leases or making financial decisions, please consult with qualified professionals.",
    neonColor: '#7DD3C0',
  },
  {
    id: 'beta',
    icon: Eye,
    title: "Beta Tester Agreement",
    emoji: '🧪',
    summary: "You're among the first to experience Homey - help us make it better!",
    details: "As a beta tester, you understand that Homey is still in development and may have bugs or incomplete features. You agree to: (1) Keep all features, screenshots, and proprietary information confidential - no sharing on social media or with competitors; (2) Provide honest feedback to help us improve; (3) Not reverse engineer or attempt to extract our proprietary algorithms; (4) Understand that features may change or be removed during beta. In exchange, you get early access to Homey and the ability to shape its future! Thank you for being part of our journey. 🙏",
    neonColor: '#E8B4C8',
    spark: true,
  },
  {
    id: 'ip',
    icon: FileText,
    title: "Homey Protection Clause",
    emoji: '™️',
    summary: "The Homey experience is our proprietary creation",
    details: "The Homey™ name, logo, 'pocket' interface concepts, AI personality, user flows, and algorithms are proprietary trade secrets and trademarks of HOMEY POCKET LLC. You agree not to reproduce, copy, sell, scrape, or reverse engineer any part of Homey. We've worked hard to create this unique experience, and we appreciate you respecting our intellectual property!",
    neonColor: '#D4C5A9',
    spark: true,
  }
];

export default function HouseRulesStep({ data, onNext, isSaving }: HouseRulesStepProps) {
  const [currentRuleIndex, setCurrentRuleIndex] = useState(0);
  const [expandedRule, setExpandedRule] = useState<string | null>(houseRules[0].id);
  const [agreedToTerms, setAgreedToTerms] = useState(false);
  const [agreedToBeta, setAgreedToBeta] = useState(false);
  const [agreedToUpdates, setAgreedToUpdates] = useState(false);
  const [showVideoModal, setShowVideoModal] = useState(false);
  const [ripples, setRipples] = useState<{ id: string; x: number; y: number }[]>([]);
  const [acceptedRules, setAcceptedRules] = useState<Set<number>>(new Set());

  const currentRule = houseRules[currentRuleIndex];
  const isLastRule = currentRuleIndex === houseRules.length - 1;
  const hasAcceptedCurrent = acceptedRules.has(currentRuleIndex);

  const toggleRule = (id: string) => {
    setExpandedRule(expandedRule === id ? null : id);
  };

  const handleAcceptRule = () => {
    const newAccepted = new Set(acceptedRules);
    newAccepted.add(currentRuleIndex);
    setAcceptedRules(newAccepted);

    if (!isLastRule) {
      // Move to next rule
      setTimeout(() => {
        setCurrentRuleIndex(prev => prev + 1);
        setExpandedRule(houseRules[currentRuleIndex + 1].id);
      }, 300);
    }
  };

  const handlePrevious = () => {
    if (currentRuleIndex > 0) {
      setCurrentRuleIndex(prev => prev - 1);
      setExpandedRule(houseRules[currentRuleIndex - 1].id);
    }
  };

  const handleCheckboxClick = (e: React.MouseEvent, setter: (value: boolean) => void, currentValue: boolean) => {
    const rect = e.currentTarget.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;

    // Add ripple effect
    const rippleId = Math.random().toString();
    setRipples([...ripples, { id: rippleId, x, y }]);

    // Remove ripple after animation
    setTimeout(() => {
      setRipples(prev => prev.filter(r => r.id !== rippleId));
    }, 600);

    setter(!currentValue);
  };

  const canAccept = agreedToTerms && agreedToBeta && agreedToUpdates;

  const handleAccept = () => {
    if (canAccept) {
      setShowVideoModal(true);
    }
  };

  const handleVideoEnd = () => {
    // Detailed legal tracking for protection
    const acceptanceTimestamp = new Date().toISOString();
    const userAgent = typeof window !== 'undefined' ? window.navigator.userAgent : 'unknown';

    onNext({
      acceptedTerms: true,
      acceptedBeta: true,
      acceptedUpdates: agreedToUpdates,
      // Detailed audit trail
      termsAcceptedAt: acceptanceTimestamp,
      betaAcceptedAt: acceptanceTimestamp,
      updatesAcceptedAt: agreedToUpdates ? acceptanceTimestamp : null,
      // Device/browser info for legal records
      acceptanceUserAgent: userAgent,
      acceptanceUrl: typeof window !== 'undefined' ? window.location.href : 'unknown',
      // Version tracking (update this when terms change)
      termsVersion: '1.0',
      betaVersion: '1.0',
    });
  };

  return (
    <>
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        exit={{ opacity: 0, y: -20 }}
        className="w-full max-w-2xl mx-auto"
      >
        {/* Header with Zoom & Flicker */}
        <div className="text-center mb-8">
          <motion.h1
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.6, ease: 'easeOut' }}
            className="text-4xl md:text-5xl font-bold mb-3 bg-gradient-to-r from-white via-cyan-200 to-white bg-clip-text text-transparent"
          >
            🏠 Welcome to Homey
          </motion.h1>

          <motion.p
            initial={{ opacity: 0 }}
            animate={{ opacity: [0, 1, 0.7, 1, 0.9, 1] }}
            transition={{ duration: 1.2, times: [0, 0.2, 0.4, 0.6, 0.8, 1] }}
            className="text-xl text-white/80"
          >
            Let's sync your house rules...
          </motion.p>
        </div>

        {/* Progress Indicators */}
        <div className="flex justify-center gap-2 mb-6">
          {houseRules.map((_, index) => (
            <motion.div
              key={index}
              className="h-1.5 rounded-full"
              style={{
                width: index === currentRuleIndex ? '32px' : '8px',
                backgroundColor: acceptedRules.has(index)
                  ? '#7DD3C0'
                  : index === currentRuleIndex
                    ? 'rgba(168, 218, 220, 0.8)'
                    : 'rgba(255, 255, 255, 0.2)',
              }}
              animate={{
                width: index === currentRuleIndex ? '32px' : '8px',
              }}
              transition={{ duration: 0.3 }}
            />
          ))}
        </div>

        {/* Carousel Card - Single Rule with Holo-Glass Effect */}
        <div className="relative mb-6 min-h-[400px]">
          <AnimatePresence mode="wait">
            <motion.div
              key={currentRuleIndex}
              initial={{ opacity: 0, x: 100, rotateY: -20 }}
              animate={{ opacity: 1, x: 0, rotateY: 0 }}
              exit={{ opacity: 0, x: -100, rotateY: 20 }}
              transition={{ duration: 0.4, ease: 'easeOut' }}
              className="relative"
            >
              {/* Removed spark animation */}

              {/* Holo-Glass Card */}
              <motion.div
                className="relative rounded-2xl overflow-hidden backdrop-blur-xl"
                style={{
                  background: 'rgba(255, 255, 255, 0.05)',
                  boxShadow: '0 8px 32px 0 rgba(0, 0, 0, 0.37)',
                  border: '1.5px solid rgba(255, 255, 255, 0.18)',
                }}
                whileHover={{
                  scale: 1.01,
                  boxShadow: '0 8px 32px 0 rgba(0, 0, 0, 0.4)',
                }}
              >
                {/* Card Header */}
                <button
                  onClick={() => toggleRule(currentRule.id)}
                  className="w-full px-6 py-5 flex items-center justify-between text-left"
                >
                  <div className="flex items-center gap-4 flex-1">
                    <motion.div
                      className="w-14 h-14 rounded-xl flex items-center justify-center flex-shrink-0 backdrop-blur-sm"
                      style={{
                        backgroundColor: 'rgba(255, 255, 255, 0.1)',
                        border: '1px solid rgba(255, 255, 255, 0.2)',
                      }}
                      whileHover={{
                        scale: 1.1,
                        backgroundColor: 'rgba(255, 255, 255, 0.15)',
                      }}
                    >
                      <span className="text-3xl">{currentRule.emoji}</span>
                    </motion.div>
                    <div className="min-w-0 flex-1">
                      <h3 className="font-bold text-white text-lg mb-1">{currentRule.title}</h3>
                      <p className="text-sm text-white/70">{currentRule.summary}</p>
                    </div>
                  </div>
                  <motion.div
                    animate={{ rotate: expandedRule === currentRule.id ? 180 : 0 }}
                    transition={{ duration: 0.3 }}
                  >
                    <ChevronDown className="w-6 h-6 text-white/60" />
                  </motion.div>
                </button>

                {/* Expandable Details */}
                <AnimatePresence>
                  {expandedRule === currentRule.id && (
                    <motion.div
                      initial={{ height: 0, opacity: 0 }}
                      animate={{ height: 'auto', opacity: 1 }}
                      exit={{ height: 0, opacity: 0 }}
                      transition={{ duration: 0.3 }}
                      className="overflow-hidden"
                    >
                      <div className="px-6 pb-6 pt-0">
                        <div
                          className="text-sm leading-relaxed rounded-xl p-5 backdrop-blur-sm"
                          style={{
                            color: '#fff',
                            backgroundColor: 'rgba(255, 255, 255, 0.05)',
                            border: '1px solid rgba(255, 255, 255, 0.15)',
                          }}
                        >
                          {currentRule.details}
                        </div>

                        {/* Accept Button for Current Card */}
                        <motion.button
                          onClick={handleAcceptRule}
                          disabled={hasAcceptedCurrent}
                          className="w-full mt-4 py-3 rounded-xl font-bold text-base transition-all relative overflow-hidden"
                          style={{
                            background: hasAcceptedCurrent
                              ? 'rgba(168, 218, 220, 0.2)'
                              : 'linear-gradient(135deg, rgba(168, 218, 220, 0.3) 0%, rgba(180, 167, 214, 0.3) 100%)',
                            border: hasAcceptedCurrent
                              ? '1px solid rgba(168, 218, 220, 0.5)'
                              : '1px solid rgba(255, 255, 255, 0.3)',
                          }}
                          whileHover={!hasAcceptedCurrent ? {
                            scale: 1.02,
                            background: 'linear-gradient(135deg, rgba(168, 218, 220, 0.4) 0%, rgba(180, 167, 214, 0.4) 100%)',
                          } : {}}
                          whileTap={!hasAcceptedCurrent ? { scale: 0.98 } : {}}
                        >
                          <span className="relative z-10 text-white flex items-center justify-center gap-2">
                            {hasAcceptedCurrent ? (
                              <>
                                <motion.span
                                  initial={{ scale: 0 }}
                                  animate={{ scale: 1 }}
                                  transition={{ type: 'spring', damping: 15 }}
                                >
                                  ✓
                                </motion.span>
                                Accepted
                              </>
                            ) : (
                              `Accept & ${isLastRule ? 'Continue' : 'Next'}`
                            )}
                          </span>
                        </motion.button>
                      </div>
                    </motion.div>
                  )}
                </AnimatePresence>
              </motion.div>
            </motion.div>
          </AnimatePresence>

          {/* Navigation Arrows */}
          <div className="absolute top-1/2 -translate-y-1/2 left-0 right-0 flex justify-between pointer-events-none px-2">
            {currentRuleIndex > 0 && (
              <motion.button
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -20 }}
                onClick={handlePrevious}
                className="pointer-events-auto w-10 h-10 rounded-full backdrop-blur-xl flex items-center justify-center"
                style={{
                  background: 'rgba(255, 255, 255, 0.1)',
                  border: '1px solid rgba(255, 255, 255, 0.2)',
                  boxShadow: '0 0 20px rgba(168, 218, 220, 0.3)',
                }}
                whileHover={{
                  scale: 1.1,
                  boxShadow: '0 0 30px rgba(168, 218, 220, 0.5)',
                }}
                whileTap={{ scale: 0.95 }}
              >
                <span className="text-white text-xl">←</span>
              </motion.button>
            )}
            <div className="flex-1" />
            {currentRuleIndex < houseRules.length - 1 && hasAcceptedCurrent && (
              <motion.button
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: 20 }}
                onClick={() => {
                  setCurrentRuleIndex(prev => prev + 1);
                  setExpandedRule(houseRules[currentRuleIndex + 1].id);
                }}
                className="pointer-events-auto w-10 h-10 rounded-full backdrop-blur-xl flex items-center justify-center"
                style={{
                  background: 'rgba(255, 255, 255, 0.1)',
                  border: '1px solid rgba(255, 255, 255, 0.2)',
                  boxShadow: '0 0 20px rgba(168, 218, 220, 0.3)',
                }}
                whileHover={{
                  scale: 1.1,
                  boxShadow: '0 0 30px rgba(168, 218, 220, 0.5)',
                }}
                whileTap={{ scale: 0.95 }}
              >
                <span className="text-white text-xl">→</span>
              </motion.button>
            )}
          </div>
        </div>

        {/* Agreement Checkboxes with Ripple Effect - Only show after all rules accepted */}
        {acceptedRules.size === houseRules.length && (
          <motion.div
            initial={{ opacity: 0, y: 20, scale: 0.95 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            transition={{ delay: 0.3, duration: 0.5 }}
            className="rounded-2xl p-6 mb-6 space-y-4 backdrop-blur-xl"
            style={{
              background: 'rgba(255, 255, 255, 0.05)',
              border: '1.5px solid rgba(168, 218, 220, 0.4)',
              boxShadow: '0 8px 32px 0 rgba(0, 0, 0, 0.37), 0 0 30px rgba(168, 218, 220, 0.3), inset 0 0 30px rgba(168, 218, 220, 0.1)',
            }}
          >
          {[
            { id: 'terms', checked: agreedToTerms, setter: setAgreedToTerms, label: (
              <>
                I've read and accept the{' '}
                <a href="/legal" target="_blank" rel="noopener noreferrer" className="text-blue-300 hover:text-blue-200 underline" onClick={(e) => e.stopPropagation()}>
                  Terms of Service
                </a>
                {' '}and{' '}
                <a href="/legal" target="_blank" rel="noopener noreferrer" className="text-blue-300 hover:text-blue-200 underline" onClick={(e) => e.stopPropagation()}>
                  Privacy Policy
                </a>
              </>
            )},
            { id: 'beta', checked: agreedToBeta, setter: setAgreedToBeta, label: 'I understand this is a beta product and agree to keep all features and proprietary information confidential (no screenshots or social media sharing)' },
            { id: 'updates', checked: agreedToUpdates, setter: setAgreedToUpdates, label: 'I want to receive important updates about new features, market insights, and my home search' },
          ].map((item) => (
            <div key={item.id} className="relative">
              <motion.div
                className="flex items-start gap-3 cursor-pointer"
                onClick={(e) => handleCheckboxClick(e, item.setter, item.checked)}
                whileHover={{ x: 2 }}
              >
                <div className="relative mt-1">
                  <input
                    type="checkbox"
                    id={item.id}
                    checked={item.checked}
                    onChange={() => {}}
                    className="w-5 h-5 rounded border-2 border-blue-300/50 bg-transparent checked:bg-blue-400 checked:border-blue-400 cursor-pointer transition-all"
                    style={{
                      boxShadow: item.checked ? '0 0 10px rgba(168, 218, 220, 0.6)' : 'none',
                    }}
                  />
                  {/* Ripple Effects */}
                  <AnimatePresence>
                    {ripples.map((ripple) => (
                      <motion.div
                        key={ripple.id}
                        initial={{ scale: 0, opacity: 1 }}
                        animate={{ scale: 4, opacity: 0 }}
                        exit={{ opacity: 0 }}
                        transition={{ duration: 0.6 }}
                        className="absolute rounded-full border-2 border-blue-300"
                        style={{
                          left: ripple.x,
                          top: ripple.y,
                          width: 20,
                          height: 20,
                          marginLeft: -10,
                          marginTop: -10,
                          pointerEvents: 'none',
                        }}
                      />
                    ))}
                  </AnimatePresence>
                </div>
                <label htmlFor={item.id} className="text-sm text-white/80 cursor-pointer flex-1">
                  {item.label}
                </label>
              </motion.div>
            </div>
          ))}
          </motion.div>
        )}

        {/* Accept Button - Slides in from bottom */}
        <AnimatePresence>
          {canAccept && (
            <motion.div
              initial={{ y: 100, opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
              exit={{ y: 100, opacity: 0 }}
              transition={{ type: 'spring', damping: 20, stiffness: 300 }}
            >
              <motion.button
                onClick={handleAccept}
                disabled={!canAccept || isSaving}
                className="w-full py-4 rounded-xl font-bold text-lg transition-all relative overflow-hidden backdrop-blur-xl"
                style={{
                  background: 'linear-gradient(135deg, rgba(168, 218, 220, 0.3) 0%, rgba(180, 167, 214, 0.3) 100%)',
                  border: '1.5px solid rgba(255, 255, 255, 0.3)',
                  boxShadow: '0 8px 32px 0 rgba(0, 0, 0, 0.37), 0 0 30px rgba(168, 218, 220, 0.5), 0 10px 40px rgba(180, 167, 214, 0.3)',
                }}
                whileHover={{
                  scale: 1.02,
                  boxShadow: '0 8px 32px 0 rgba(0, 0, 0, 0.37), 0 0 40px rgba(168, 218, 220, 0.7), 0 15px 50px rgba(180, 167, 214, 0.5)',
                  background: 'linear-gradient(135deg, rgba(168, 218, 220, 0.4) 0%, rgba(180, 167, 214, 0.4) 100%)',
                }}
                whileTap={{ scale: 0.98 }}
              >
                <motion.span
                  className="relative z-10 text-white"
                  animate={{
                    textShadow: [
                      '0 0 10px rgba(255, 255, 255, 0.5)',
                      '0 0 20px rgba(255, 255, 255, 0.8)',
                      '0 0 10px rgba(255, 255, 255, 0.5)',
                    ],
                  }}
                  transition={{ duration: 2, repeat: Infinity }}
                >
                  ✨ I Accept the House Rules
                </motion.span>
              </motion.button>
            </motion.div>
          )}
        </AnimatePresence>

        {!canAccept && (
          <div className="text-center py-4 text-white/40 text-sm">
            👆 Check all boxes above to continue
          </div>
        )}
      </motion.div>

      {/* Video Confirmation Modal */}
      <AnimatePresence>
        {showVideoModal && (
          <>
            {/* Backdrop */}
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="fixed inset-0 bg-black/80 backdrop-blur-md z-[100]"
              onClick={() => {}}
            />

            {/* Modal */}
            <motion.div
              initial={{ opacity: 0, scale: 0.9, y: 20 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.9, y: 20 }}
              className="fixed inset-0 z-[101] flex items-center justify-center p-4"
            >
              <div
                className="rounded-2xl p-6 max-w-2xl w-full shadow-2xl"
                style={{
                  background: 'linear-gradient(135deg, rgba(10, 14, 39, 0.95) 0%, rgba(26, 36, 86, 0.9) 100%)',
                  border: '1px solid rgba(168, 218, 220, 0.5)',
                  boxShadow: '0 0 40px rgba(168, 218, 220, 0.3)',
                }}
              >
                <div className="text-center mb-6">
                  <h2 className="text-3xl font-bold mb-2 text-white">Hi! Just as a reminder...</h2>
                  <p className="text-white/70">Thanks for agreeing to the house rules! 🎉</p>
                </div>

                <div className="relative aspect-video rounded-xl overflow-hidden bg-black/30 mb-6">
                  <video
                    className="w-full h-full object-cover"
                    controls
                    autoPlay
                    onEnded={handleVideoEnd}
                  >
                    <source src="/videos/house-rules.mp4" type="video/mp4" />
                    <div className="absolute inset-0 flex flex-col items-center justify-center text-white/60 p-8">
                      <p className="text-center mb-4">🎥 Video coming soon!</p>
                      <p className="text-sm text-center">Add your video at /public/videos/house-rules.mp4</p>
                      <button
                        onClick={handleVideoEnd}
                        className="mt-6 px-6 py-3 rounded-xl font-semibold transition-colors"
                        style={{
                          background: 'linear-gradient(135deg, #A8DADC 0%, #B4A7D6 100%)',
                          boxShadow: '0 0 20px rgba(168, 218, 220, 0.4)',
                        }}
                      >
                        Continue Anyway
                      </button>
                    </div>
                  </video>
                </div>

                <button
                  onClick={handleVideoEnd}
                  className="w-full py-3 text-white rounded-xl font-bold transition-all"
                  style={{
                    background: 'linear-gradient(135deg, #A8DADC 0%, #B4A7D6 100%)',
                    boxShadow: '0 0 20px rgba(168, 218, 220, 0.4)',
                  }}
                >
                  Let's Go! →
                </button>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </>
  );
}
