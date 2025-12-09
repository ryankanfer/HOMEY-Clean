'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { OnboardingData } from '@/app/onboarding/page';
import { agentDb, auth } from '@/lib/supabase';

interface AgentStepProps {
  data: OnboardingData;
  onNext: (data: Partial<OnboardingData>) => void;
  isSaving: boolean;
  agentConnection?: any;
}

export default function AgentStep({ data, onNext, isSaving, agentConnection }: AgentStepProps) {
  // If user was invited by an agent, they already have an agent
  const initialHasAgent = agentConnection ? true : (data.hasAgent !== undefined ? data.hasAgent : null);
  const [hasAgent, setHasAgent] = useState<boolean | null>(initialHasAgent);
  const [showAgentForm, setShowAgentForm] = useState(false);
  const [agentName, setAgentName] = useState(data.agentName || '');
  const [agentEmail, setAgentEmail] = useState(data.agentContact || '');
  const [agentMessage, setAgentMessage] = useState("Hey! I just joined HOMEY for my home search. Let's connect so we can work together on the platform!");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitError, setSubmitError] = useState('');
  const [agentNotFound, setAgentNotFound] = useState(false);
  const [wittyMessage, setWittyMessage] = useState('');
  const [showAgentMatchModal, setShowAgentMatchModal] = useState(false);
  const [showNeedAgentModal, setShowNeedAgentModal] = useState(false);

  const options = [
    {
      value: true,
      icon: '🤝',
      title: 'I have an agent',
      description: 'Already working with a real estate agent',
    },
    {
      value: false,
      icon: '🔍',
      title: 'I need an agent',
      description: 'Help me find the right agent',
    },
  ];

  // Witty messages for when agent isn't registered
  const getWittyMessage = (agentName: string) => {
    const messages = [
      `${agentName} isn't on HOMEY yet. Time to invite them to the future! 🚀`,
      `Looks like ${agentName} hasn't discovered HOMEY yet. Let's fix that! ✨`,
      `${agentName} isn't on HOMEY... yet. We're sending them the VIP invite now! 💌`,
      `${agentName} is missing out! We'll let them know about HOMEY. 🏠`,
      `Plot twist: ${agentName} isn't here yet. But they will be soon! 🎭`,
    ];
    return messages[Math.floor(Math.random() * messages.length)];
  };

  const handleSelect = (value: boolean) => {
    setHasAgent(value);
    setAgentNotFound(false);
    setSubmitError('');
    if (value === true) {
      // Show agent form if they have an agent
      setShowAgentForm(true);
      setShowNeedAgentModal(false);
    } else {
      // If they need an agent, show modal instead of inline message
      setShowAgentForm(false);
      setShowNeedAgentModal(true);
    }
  };

  const handleContinue = () => {
    if (hasAgent === false) {
      // They need an agent - just save and continue
      onNext({ hasAgent: false });
    } else if (hasAgent === true && !showAgentForm) {
      // They have an agent but form not shown yet
      setShowAgentForm(true);
    }
  };

  const handleSubmitAgentInfo = async () => {
    if (!agentName || !agentEmail) {
      setSubmitError('Please enter both agent name and email');
      return;
    }

    setIsSubmitting(true);
    setSubmitError('');
    setAgentNotFound(false);

    try {
      // Get current user
      const { data: { user } } = await auth.getUser();
      if (!user) {
        setSubmitError('You must be logged in to continue');
        setIsSubmitting(false);
        return;
      }

      // Check if agent exists
      const { data: agent, error: findError } = await agentDb.findAgentByEmail(agentEmail);

      if (agent) {
        // Agent exists! Create connection request
        const { data: connection, error: connectionError } = await agentDb.requestConnectionToAgent({
          clientId: user.id,
          agentEmail: agentEmail,
          agentName: agentName,
          connectionMessage: agentMessage,
        });

        if (connectionError) {
          console.error('Failed to create connection:', connectionError);
          setSubmitError('Failed to send connection request. Please try again.');
          setIsSubmitting(false);
          return;
        }

        console.log('✅ Connection request created:', connection);

        // Save to onboarding data and continue
        onNext({
          hasAgent: true,
          agentName,
          agentContact: agentEmail,
        });
      } else {
        // Agent not found - show witty message but still save the info
        const message = getWittyMessage(agentName);
        setWittyMessage(message);
        setAgentNotFound(true);

        // Still create a pending request for when agent signs up
        await agentDb.requestConnectionToAgent({
          clientId: user.id,
          agentEmail: agentEmail,
          agentName: agentName,
          connectionMessage: agentMessage,
        });

        // Wait a moment for user to read the message, then continue
        setTimeout(() => {
          onNext({
            hasAgent: true,
            agentName,
            agentContact: agentEmail,
          });
        }, 3000);
      }
    } catch (error) {
      console.error('Error submitting agent info:', error);
      setSubmitError('Something went wrong. Please try again.');
      setIsSubmitting(false);
    }
  };

  // If user has an agent connection, show confirmation screen
  if (agentConnection) {
    return (
      <motion.div
        initial={{ opacity: 0, x: 50 }}
        animate={{ opacity: 1, x: 0 }}
        exit={{ opacity: 0, x: -50 }}
        transition={{ duration: 0.5 }}
        className="w-full max-w-2xl mx-auto"
      >
        <motion.div
          initial={{ y: 20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ delay: 0.1, duration: 0.5 }}
          className="glass-strong rounded-3xl p-8 text-center"
        >
          <div className="text-6xl mb-6">🤝</div>
          <h2
            className="text-4xl md:text-5xl font-light text-white mb-4"
            style={{ fontFamily: 'Playfair Display, serif' }}
          >
            You're all set!
          </h2>
          <p className="text-white/60 text-lg mb-8">
            You're already connected with your agent.
            <br />
            They'll be able to assist you in your home search.
          </p>

          <button
            onClick={() => onNext({ hasAgent: true })}
            disabled={isSaving}
            className="px-10 py-4 bg-white text-black rounded-full font-bold text-lg hover:shadow-2xl hover:shadow-white/20 transition-all transform hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {isSaving ? 'Saving...' : 'Continue →'}
          </button>
        </motion.div>
      </motion.div>
    );
  }

  return (
    <motion.div
      initial={{ opacity: 0, x: 50 }}
      animate={{ opacity: 1, x: 0 }}
      exit={{ opacity: 0, x: -50 }}
      transition={{ duration: 0.5 }}
      className="w-full max-w-2xl mx-auto"
    >
      {/* Question */}
      <motion.h2
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.1, duration: 0.5 }}
        className="text-4xl md:text-5xl font-light text-white text-center mb-4"
        style={{ fontFamily: 'Playfair Display, serif' }}
      >
        Do you have an agent?
      </motion.h2>

      <motion.p
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.2, duration: 0.5 }}
        className="text-white/60 text-center mb-12 text-lg"
      >
        We can connect you with top-rated agents in your area
      </motion.p>

      {/* Options */}
      {!showAgentForm && (
        <>
          <div className="space-y-4 mb-8">
            {options.map((option, index) => (
              <motion.button
                key={option.value.toString()}
                initial={{ y: 20, opacity: 0 }}
                animate={{ y: 0, opacity: 1 }}
                transition={{ delay: 0.3 + index * 0.1, duration: 0.5 }}
                onClick={() => handleSelect(option.value)}
                className={`w-full p-6 rounded-2xl text-left transition-all transform ${
                  hasAgent === option.value
                    ? 'bg-gradient-to-r from-primary to-purple-500 text-white scale-105 shadow-2xl shadow-primary/30'
                    : 'glass-strong text-white hover:bg-white/10'
                }`}
              >
                <div className="flex items-center gap-4">
                  <div className="text-5xl">{option.icon}</div>
                  <div className="flex-1">
                    <h3 className="text-xl font-bold mb-1">{option.title}</h3>
                    <p
                      className={`text-sm ${
                        hasAgent === option.value ? 'text-white/90' : 'text-white/60'
                      }`}
                    >
                      {option.description}
                    </p>
                  </div>
                  {hasAgent === option.value && (
                    <motion.div
                      initial={{ scale: 0 }}
                      animate={{ scale: 1 }}
                      className="text-2xl"
                    >
                      ✓
                    </motion.div>
                  )}
                </div>
              </motion.button>
            ))}
          </div>

        </>
      )}

      {/* Need Agent Modal */}
      <AnimatePresence>
        {showNeedAgentModal && (
          <>
            {/* Backdrop */}
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="fixed inset-0 bg-black/80 backdrop-blur-md z-[100]"
              onClick={() => setShowNeedAgentModal(false)}
            />

            {/* Modal */}
            <motion.div
              initial={{ opacity: 0, scale: 0.9, y: 20 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.9, y: 20 }}
              className="fixed inset-0 z-[101] flex items-center justify-center p-4"
            >
              <div className="glass-strong rounded-2xl p-8 max-w-md w-full border border-primary/30 shadow-2xl text-center">
                <div className="text-5xl mb-4">✨</div>
                <h3 className="text-2xl font-bold text-white mb-3">
                  Perfect timing!
                </h3>
                <p className="text-white/80 text-base leading-relaxed mb-6">
                  <span className="font-semibold text-primary">When the time is right</span>, we'll match you with an agent you'll actually vibe with. No pressure, just good vibes and great homes.
                </p>
                <button
                  onClick={() => setShowNeedAgentModal(false)}
                  className="px-8 py-3 bg-gradient-to-r from-primary to-purple-500 text-white rounded-xl font-semibold hover:shadow-lg hover:shadow-primary/50 transition-all"
                >
                  Sounds good!
                </button>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>

      {/* Agent Info Form */}
      {showAgentForm && (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="space-y-6 mb-8"
        >
          <div className="glass-strong rounded-2xl p-6">
            <h3 className="text-xl font-bold text-white mb-4">Tell us about your agent</h3>

            <div className="space-y-4">
              <div>
                <label className="block text-white text-sm font-medium mb-2">
                  Agent's Full Name *
                </label>
                <input
                  type="text"
                  value={agentName}
                  onChange={(e) => setAgentName(e.target.value)}
                  placeholder="Sarah Chen"
                  className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-white/40 focus:outline-none focus:border-purple-500/50"
                />
              </div>

              <div>
                <label className="block text-white text-sm font-medium mb-2">
                  Agent's Email *
                </label>
                <input
                  type="email"
                  value={agentEmail}
                  onChange={(e) => setAgentEmail(e.target.value)}
                  placeholder="sarah@realestate.com"
                  className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-white/40 focus:outline-none focus:border-purple-500/50"
                />
              </div>

              <div>
                <label className="block text-white text-sm font-medium mb-2">
                  Message (optional)
                </label>
                <textarea
                  value={agentMessage}
                  onChange={(e) => setAgentMessage(e.target.value)}
                  rows={3}
                  className="w-full px-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-white/40 focus:outline-none focus:border-purple-500/50 resize-none"
                />
              </div>
            </div>

            <button
              onClick={() => setShowAgentForm(false)}
              className="mt-4 text-purple-400 hover:text-purple-300 text-sm transition-colors"
            >
              ← Back to options
            </button>
          </div>
        </motion.div>
      )}

      {/* Error Message */}
      {submitError && (
        <motion.div
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          className="mb-4 p-4 bg-red-500/20 border border-red-500/50 rounded-xl text-red-200 text-sm text-center"
        >
          {submitError}
        </motion.div>
      )}

      {/* Agent Not Found - Witty Message */}
      <AnimatePresence>
        {agentNotFound && wittyMessage && (
          <motion.div
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            exit={{ opacity: 0, scale: 0.9 }}
            className="mb-6"
          >
            <div className="glass-strong rounded-2xl p-6 text-center border-2 border-purple-500/50">
              <div className="text-5xl mb-4">📧</div>
              <p className="text-white text-lg font-semibold mb-2">
                {wittyMessage}
              </p>
              <p className="text-white/60 text-sm">
                Don't worry, we've saved your info. You'll be connected once they join!
              </p>
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Continue Button */}
      {((hasAgent !== null && !showAgentForm) || (showAgentForm && agentName && agentEmail)) && !agentNotFound && (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.3 }}
          className="text-center"
        >
          <button
            onClick={showAgentForm ? handleSubmitAgentInfo : handleContinue}
            disabled={isSaving || isSubmitting}
            className="px-10 py-4 bg-white text-black rounded-full font-bold text-lg hover:shadow-2xl hover:shadow-white/20 transition-all transform hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {isSaving || isSubmitting ? 'Saving...' : 'Continue →'}
          </button>
        </motion.div>
      )}
    </motion.div>
  );
}
