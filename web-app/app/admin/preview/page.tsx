'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  BookOpen,
  Target,
  Home,
  Lock,
  Unlock,
  TrendingUp,
  CheckCircle,
  AlertCircle,
  Sparkles,
  Award,
  ChevronRight,
  BarChart3,
  Shield,
  Brain,
  Lightbulb,
} from 'lucide-react';

type PreviewSection =
  | 'overview'
  | 'readiness'
  | 'confidence'
  | 'homepage'
  | 'unlocking'
  | 'trust'
  | 'ai-moments'
  | 'education';

export default function BetaV2PreviewPage() {
  const [activeSection, setActiveSection] = useState<PreviewSection>('overview');
  const [confidenceScore, setConfidenceScore] = useState(45);
  const [readinessStep, setReadinessStep] = useState(0);

  const sections = [
    { id: 'overview', name: 'Overview', icon: Target },
    { id: 'readiness', name: 'Readiness Check', icon: CheckCircle },
    { id: 'confidence', name: 'Confidence Score', icon: TrendingUp },
    { id: 'homepage', name: 'New Homepage', icon: Home },
    { id: 'unlocking', name: 'Feature Unlocking', icon: Unlock },
    { id: 'trust', name: 'Trust Indicators', icon: Shield },
    { id: 'ai-moments', name: 'AI Moments', icon: Brain },
    { id: 'education', name: 'Education Mode', icon: BookOpen },
  ];

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-950 via-purple-950 to-slate-950">
      {/* Header */}
      <div className="border-b border-white/10 bg-black/20 backdrop-blur-sm">
        <div className="max-w-7xl mx-auto px-6 py-4">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-2xl font-bold text-white mb-1">
                Beta V2 Preview Center
              </h1>
              <p className="text-white/60 text-sm">
                "Learn First, Explore Confident" - Interactive Demos
              </p>
            </div>
            <div className="flex items-center gap-2 px-4 py-2 rounded-lg bg-gradient-to-r from-purple-500/20 to-pink-500/20 border border-purple-500/30">
              <Sparkles className="w-4 h-4 text-purple-400" />
              <span className="text-white font-medium">Dev Preview Mode</span>
            </div>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-6 py-8">
        <div className="grid grid-cols-12 gap-6">
          {/* Sidebar Navigation */}
          <div className="col-span-3">
            <div className="sticky top-8 space-y-2">
              {sections.map((section) => {
                const Icon = section.icon;
                return (
                  <button
                    key={section.id}
                    onClick={() => setActiveSection(section.id as PreviewSection)}
                    className={`w-full flex items-center gap-3 px-4 py-3 rounded-lg transition-all ${
                      activeSection === section.id
                        ? 'bg-gradient-to-r from-purple-500 to-pink-500 text-white shadow-lg'
                        : 'bg-white/5 text-white/60 hover:bg-white/10 hover:text-white'
                    }`}
                  >
                    <Icon className="w-5 h-5" />
                    <span className="font-medium">{section.name}</span>
                  </button>
                );
              })}
            </div>
          </div>

          {/* Main Content */}
          <div className="col-span-9">
            <AnimatePresence mode="wait">
              <motion.div
                key={activeSection}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -20 }}
                transition={{ duration: 0.3 }}
                className="bg-white/5 backdrop-blur-sm rounded-2xl border border-white/10 p-8"
              >
                {/* Overview Section */}
                {activeSection === 'overview' && (
                  <div className="space-y-6">
                    <h2 className="text-3xl font-bold text-white mb-2">
                      Beta V2: "Learn First, Explore Confident"
                    </h2>
                    <p className="text-white/70 text-lg">
                      A redesigned experience focused on building user confidence through
                      education and progressive feature unlocking.
                    </p>

                    <div className="grid grid-cols-2 gap-4 mt-8">
                      <div className="bg-gradient-to-br from-purple-500/10 to-pink-500/10 border border-purple-500/20 rounded-xl p-6">
                        <div className="flex items-center gap-3 mb-3">
                          <div className="w-10 h-10 rounded-lg bg-purple-500/20 flex items-center justify-center">
                            <Target className="w-5 h-5 text-purple-400" />
                          </div>
                          <h3 className="text-lg font-semibold text-white">Core Philosophy</h3>
                        </div>
                        <p className="text-white/70">
                          "HOMEY ensures you're in charge and confident in your journey"
                        </p>
                      </div>

                      <div className="bg-gradient-to-br from-blue-500/10 to-cyan-500/10 border border-blue-500/20 rounded-xl p-6">
                        <div className="flex items-center gap-3 mb-3">
                          <div className="w-10 h-10 rounded-lg bg-blue-500/20 flex items-center justify-center">
                            <Lightbulb className="w-5 h-5 text-blue-400" />
                          </div>
                          <h3 className="text-lg font-semibold text-white">Aha Moment</h3>
                        </div>
                        <p className="text-white/70">
                          Proactive AI that knows you + You're confident in your journey
                        </p>
                      </div>
                    </div>

                    <div className="mt-8 p-6 bg-white/5 rounded-xl border border-white/10">
                      <h3 className="text-lg font-semibold text-white mb-4">Key Changes</h3>
                      <div className="space-y-3">
                        {[
                          'Progressive feature unlocking based on confidence score',
                          'Education-first onboarding with readiness check',
                          'Simplified homepage with 2 primary CTAs',
                          'Trust indicators on all listings',
                          'AI moments showcasing intelligence',
                          'Gamified learning integrated with Education mode',
                        ].map((change, i) => (
                          <div key={i} className="flex items-start gap-3">
                            <CheckCircle className="w-5 h-5 text-green-400 mt-0.5 flex-shrink-0" />
                            <p className="text-white/70">{change}</p>
                          </div>
                        ))}
                      </div>
                    </div>

                    <div className="mt-6 p-4 bg-yellow-500/10 border border-yellow-500/20 rounded-lg">
                      <p className="text-yellow-200/80 text-sm">
                        💡 <strong>Note:</strong> Use the sidebar to explore each component of the
                        Beta V2 experience. All previews are interactive!
                      </p>
                    </div>
                  </div>
                )}

                {/* Readiness Check Section */}
                {activeSection === 'readiness' && (
                  <div className="space-y-6">
                    <h2 className="text-3xl font-bold text-white mb-2">Readiness Check Flow</h2>
                    <p className="text-white/70">
                      A quick 2-3 minute assessment that replaces heavy onboarding
                    </p>

                    <div className="mt-8 bg-gradient-to-br from-slate-900 to-slate-800 rounded-2xl p-8 border border-white/10">
                      {/* Progress Bar */}
                      <div className="mb-8">
                        <div className="flex justify-between text-sm text-white/60 mb-2">
                          <span>Question {readinessStep + 1} of 5</span>
                          <span>{((readinessStep + 1) / 5) * 100}% Complete</span>
                        </div>
                        <div className="h-2 bg-white/10 rounded-full overflow-hidden">
                          <motion.div
                            className="h-full bg-gradient-to-r from-purple-500 to-pink-500"
                            initial={{ width: 0 }}
                            animate={{ width: `${((readinessStep + 1) / 5) * 100}%` }}
                          />
                        </div>
                      </div>

                      {/* Questions */}
                      <AnimatePresence mode="wait">
                        {readinessStep === 0 && (
                          <motion.div
                            key="q1"
                            initial={{ opacity: 0, x: 20 }}
                            animate={{ opacity: 1, x: 0 }}
                            exit={{ opacity: 0, x: -20 }}
                          >
                            <h3 className="text-2xl font-bold text-white mb-6">
                              Have you been pre-approved for a mortgage or rental?
                            </h3>
                            <div className="space-y-3">
                              {['Yes, I have', 'No, not yet', "What's that?"].map((option) => (
                                <button
                                  key={option}
                                  onClick={() => setReadinessStep(1)}
                                  className="w-full p-4 bg-white/5 hover:bg-white/10 border border-white/10 hover:border-purple-500/50 rounded-lg text-left text-white transition-all"
                                >
                                  {option}
                                </button>
                              ))}
                            </div>
                          </motion.div>
                        )}

                        {readinessStep === 1 && (
                          <motion.div
                            key="q2"
                            initial={{ opacity: 0, x: 20 }}
                            animate={{ opacity: 1, x: 0 }}
                            exit={{ opacity: 0, x: -20 }}
                          >
                            <h3 className="text-2xl font-bold text-white mb-6">
                              What's your ideal move-in timeline?
                            </h3>
                            <div className="space-y-3">
                              {[
                                'ASAP (within 1 month)',
                                '1-3 months',
                                '3-6 months',
                                'Just browsing',
                              ].map((option) => (
                                <button
                                  key={option}
                                  onClick={() => setReadinessStep(2)}
                                  className="w-full p-4 bg-white/5 hover:bg-white/10 border border-white/10 hover:border-purple-500/50 rounded-lg text-left text-white transition-all"
                                >
                                  {option}
                                </button>
                              ))}
                            </div>
                          </motion.div>
                        )}

                        {readinessStep === 2 && (
                          <motion.div
                            key="q3"
                            initial={{ opacity: 0, x: 20 }}
                            animate={{ opacity: 1, x: 0 }}
                            exit={{ opacity: 0, x: -20 }}
                          >
                            <h3 className="text-2xl font-bold text-white mb-4">
                              Rate your knowledge: Lease Agreements
                            </h3>
                            <p className="text-white/60 mb-6">
                              Drag the slider to rate your understanding
                            </p>
                            <div className="space-y-4">
                              <input
                                type="range"
                                min="1"
                                max="5"
                                defaultValue="3"
                                className="w-full"
                              />
                              <div className="flex justify-between text-sm text-white/60">
                                <span>Beginner</span>
                                <span>Expert</span>
                              </div>
                            </div>
                            <button
                              onClick={() => setReadinessStep(3)}
                              className="mt-6 w-full px-6 py-3 bg-gradient-to-r from-purple-500 to-pink-500 text-white rounded-lg font-semibold"
                            >
                              Continue
                            </button>
                          </motion.div>
                        )}

                        {readinessStep === 3 && (
                          <motion.div
                            key="results"
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                          >
                            <div className="text-center mb-8">
                              <div className="w-16 h-16 bg-gradient-to-br from-green-500 to-emerald-500 rounded-full flex items-center justify-center mx-auto mb-4">
                                <CheckCircle className="w-8 h-8 text-white" />
                              </div>
                              <h3 className="text-2xl font-bold text-white mb-2">
                                Assessment Complete!
                              </h3>
                              <p className="text-white/60">Here's what we recommend</p>
                            </div>

                            <div className="space-y-4">
                              <div className="bg-white/5 border border-white/10 rounded-xl p-6">
                                <h4 className="text-lg font-semibold text-white mb-3 flex items-center gap-2">
                                  <BookOpen className="w-5 h-5 text-purple-400" />
                                  Priority Learning Path:
                                </h4>
                                <div className="space-y-2">
                                  {[
                                    { title: 'Understanding your budget', time: '15 min' },
                                    { title: 'Lease basics', time: '10 min' },
                                    { title: 'NYC neighborhoods guide', time: '20 min' },
                                  ].map((lesson, i) => (
                                    <div
                                      key={i}
                                      className="flex items-center justify-between p-3 bg-white/5 rounded-lg"
                                    >
                                      <span className="text-white/80">
                                        {i + 1}. {lesson.title}
                                      </span>
                                      <span className="text-white/50 text-sm">{lesson.time}</span>
                                    </div>
                                  ))}
                                </div>
                              </div>

                              <div className="bg-blue-500/10 border border-blue-500/20 rounded-xl p-6">
                                <h4 className="text-lg font-semibold text-white mb-2">
                                  Your Search Status: Early Explorer
                                </h4>
                                <p className="text-white/70">
                                  We'll start you with browsing. You can search seriously when
                                  ready.
                                </p>
                              </div>

                              <div className="flex gap-3">
                                <button className="flex-1 px-6 py-3 bg-gradient-to-r from-purple-500 to-pink-500 text-white rounded-lg font-semibold">
                                  Start Learning
                                </button>
                                <button className="flex-1 px-6 py-3 bg-white/10 text-white rounded-lg font-semibold hover:bg-white/20">
                                  Skip to Browsing
                                </button>
                              </div>
                            </div>

                            <button
                              onClick={() => setReadinessStep(0)}
                              className="mt-6 text-white/60 hover:text-white text-sm mx-auto block"
                            >
                              ← Restart Demo
                            </button>
                          </motion.div>
                        )}
                      </AnimatePresence>
                    </div>
                  </div>
                )}

                {/* Confidence Score Section */}
                {activeSection === 'confidence' && (
                  <div className="space-y-6">
                    <h2 className="text-3xl font-bold text-white mb-2">Confidence Score System</h2>
                    <p className="text-white/70">
                      Track user knowledge and unlock features progressively
                    </p>

                    <div className="mt-8 space-y-6">
                      {/* Score Display */}
                      <div className="bg-gradient-to-br from-purple-500/10 to-pink-500/10 border border-purple-500/20 rounded-2xl p-8">
                        <div className="text-center mb-6">
                          <div className="text-6xl font-bold text-white mb-2">
                            {confidenceScore}%
                          </div>
                          <p className="text-white/60">Your Confidence Score</p>
                        </div>

                        <div className="h-4 bg-white/10 rounded-full overflow-hidden mb-6">
                          <motion.div
                            className="h-full bg-gradient-to-r from-purple-500 to-pink-500"
                            initial={{ width: 0 }}
                            animate={{ width: `${confidenceScore}%` }}
                          />
                        </div>

                        <div className="flex justify-between text-sm text-white/60 mb-6">
                          <span>New User</span>
                          <span>Confident Explorer</span>
                        </div>

                        <input
                          type="range"
                          min="0"
                          max="100"
                          value={confidenceScore}
                          onChange={(e) => setConfidenceScore(parseInt(e.target.value))}
                          className="w-full"
                        />
                        <p className="text-center text-white/50 text-sm mt-2">
                          Drag to simulate different confidence levels
                        </p>
                      </div>

                      {/* Feature Unlocking */}
                      <div className="space-y-3">
                        <h3 className="text-xl font-semibold text-white mb-4">
                          Features at This Level
                        </h3>

                        {[
                          { threshold: 0, features: ['Basic swiping', 'Essential lessons', 'FAQ/Help'] },
                          {
                            threshold: 25,
                            features: ['Saved homes', 'Comparison tool', 'Neighborhood guides'],
                          },
                          {
                            threshold: 50,
                            features: [
                              'AI Scout recommendations',
                              'Document vault',
                              'Budget calculator',
                            ],
                          },
                          {
                            threshold: 75,
                            features: [
                              'Agent connection',
                              'Tour scheduling',
                              'Application assistance',
                              'Full journey tracking',
                            ],
                          },
                        ].map((tier) => {
                          const isUnlocked = confidenceScore >= tier.threshold;
                          return (
                            <div
                              key={tier.threshold}
                              className={`p-4 rounded-xl border transition-all ${
                                isUnlocked
                                  ? 'bg-green-500/10 border-green-500/30'
                                  : 'bg-white/5 border-white/10 opacity-50'
                              }`}
                            >
                              <div className="flex items-center gap-3 mb-2">
                                {isUnlocked ? (
                                  <Unlock className="w-5 h-5 text-green-400" />
                                ) : (
                                  <Lock className="w-5 h-5 text-white/40" />
                                )}
                                <span className="font-semibold text-white">
                                  {tier.threshold}%+ Confidence
                                </span>
                              </div>
                              <div className="ml-8 space-y-1">
                                {tier.features.map((feature) => (
                                  <div
                                    key={feature}
                                    className="text-sm text-white/70 flex items-center gap-2"
                                  >
                                    <div className="w-1.5 h-1.5 rounded-full bg-white/40" />
                                    {feature}
                                  </div>
                                ))}
                              </div>
                            </div>
                          );
                        })}
                      </div>
                    </div>
                  </div>
                )}

                {/* New Homepage Section */}
                {activeSection === 'homepage' && (
                  <div className="space-y-6">
                    <h2 className="text-3xl font-bold text-white mb-2">
                      Simplified Homepage V2
                    </h2>
                    <p className="text-white/70">Clean, focused design with 2 primary CTAs</p>

                    <div className="mt-8">
                      {/* Phone Mockup */}
                      <div className="mx-auto max-w-sm">
                        <div className="bg-black rounded-[3rem] p-4 border-8 border-slate-800 shadow-2xl">
                          <div className="bg-gradient-to-br from-slate-900 to-slate-800 rounded-[2.5rem] overflow-hidden">
                            {/* Status Bar */}
                            <div className="bg-black/50 px-6 py-3 flex justify-between items-center">
                              <span className="text-white text-sm">9:41</span>
                              <div className="flex gap-1">
                                <div className="w-1 h-1 rounded-full bg-white/50" />
                                <div className="w-1 h-1 rounded-full bg-white/50" />
                                <div className="w-1 h-1 rounded-full bg-white/50" />
                              </div>
                            </div>

                            {/* Header */}
                            <div className="px-6 py-6">
                              <h1 className="text-2xl font-bold text-white mb-1">HOMEY</h1>
                            </div>

                            {/* Content */}
                            <div className="px-6 pb-8 space-y-6">
                              {/* Confidence Score */}
                              <div className="bg-gradient-to-br from-yellow-500/20 to-orange-500/20 border border-yellow-500/30 rounded-2xl p-4">
                                <div className="flex items-center justify-between mb-2">
                                  <span className="text-white font-semibold">
                                    Your Confidence Score: 65%
                                  </span>
                                  <div className="w-8 h-8 rounded-full bg-yellow-500/20 flex items-center justify-center">
                                    <span className="text-xl">🟡</span>
                                  </div>
                                </div>
                                <div className="h-2 bg-white/10 rounded-full overflow-hidden">
                                  <div
                                    className="h-full bg-gradient-to-r from-yellow-500 to-orange-500"
                                    style={{ width: '65%' }}
                                  />
                                </div>
                                <p className="text-white/60 text-sm mt-2">
                                  3 lessons to unlock full features
                                </p>
                              </div>

                              {/* Primary CTA 1 */}
                              <div className="bg-gradient-to-br from-purple-500/10 to-pink-500/10 border border-purple-500/30 rounded-2xl p-6">
                                <div className="flex items-center gap-3 mb-3">
                                  <Home className="w-6 h-6 text-purple-400" />
                                  <h2 className="text-xl font-bold text-white">Explore Homes</h2>
                                </div>
                                <p className="text-white/60 mb-4">
                                  Browse verified NYC listings
                                </p>
                                <button className="w-full px-6 py-3 bg-gradient-to-r from-purple-500 to-pink-500 text-white rounded-xl font-semibold">
                                  Start Swiping
                                </button>
                              </div>

                              {/* Primary CTA 2 */}
                              <div className="bg-gradient-to-br from-blue-500/10 to-cyan-500/10 border border-blue-500/30 rounded-2xl p-6">
                                <div className="flex items-center gap-3 mb-3">
                                  <BookOpen className="w-6 h-6 text-blue-400" />
                                  <h2 className="text-xl font-bold text-white">
                                    Boost Your Knowledge
                                  </h2>
                                </div>
                                <p className="text-white/60 mb-4">2 quick lessons recommended</p>
                                <button className="w-full px-6 py-3 bg-gradient-to-r from-blue-500 to-cyan-500 text-white rounded-xl font-semibold">
                                  Learn Now
                                </button>
                              </div>

                              {/* Locked Features Preview */}
                              <div className="bg-white/5 border border-white/10 rounded-2xl p-4">
                                <div className="flex items-center gap-2 mb-3">
                                  <Lock className="w-4 h-4 text-white/40" />
                                  <span className="text-white/60 text-sm font-medium">
                                    Unlocks at 75% confidence:
                                  </span>
                                </div>
                                <div className="space-y-2 ml-6">
                                  {['AI Scout', 'Agent matching', 'Advanced search'].map((f) => (
                                    <div key={f} className="text-white/40 text-sm flex items-center gap-2">
                                      <div className="w-1 h-1 rounded-full bg-white/40" />
                                      {f}
                                    </div>
                                  ))}
                                </div>
                              </div>
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                )}

                {/* Feature Unlocking Section */}
                {activeSection === 'unlocking' && (
                  <div className="space-y-6">
                    <h2 className="text-3xl font-bold text-white mb-2">
                      Progressive Feature Unlocking
                    </h2>
                    <p className="text-white/70">Features revealed as users build confidence</p>

                    <div className="mt-8 space-y-4">
                      {[
                        {
                          range: '0-25%',
                          label: 'New User',
                          color: 'from-red-500 to-orange-500',
                          features: ['Basic swiping', 'Essential lessons', 'FAQ/Help'],
                        },
                        {
                          range: '25-50%',
                          label: 'Learning',
                          color: 'from-yellow-500 to-amber-500',
                          features: ['Saved homes', 'Comparison tool', 'Neighborhood guides'],
                        },
                        {
                          range: '50-75%',
                          label: 'Getting Ready',
                          color: 'from-blue-500 to-cyan-500',
                          features: [
                            'AI Scout recommendations',
                            'Document vault',
                            'Budget calculator',
                          ],
                        },
                        {
                          range: '75%+',
                          label: 'Confident',
                          color: 'from-green-500 to-emerald-500',
                          features: [
                            'Agent connection',
                            'Tour scheduling',
                            'Application assistance',
                            'Full journey tracking',
                          ],
                        },
                      ].map((tier, i) => (
                        <motion.div
                          key={i}
                          initial={{ opacity: 0, y: 20 }}
                          animate={{ opacity: 1, y: 0 }}
                          transition={{ delay: i * 0.1 }}
                          className="bg-white/5 border border-white/10 rounded-xl p-6"
                        >
                          <div className="flex items-center justify-between mb-4">
                            <div className="flex items-center gap-4">
                              <div
                                className={`px-4 py-2 rounded-lg bg-gradient-to-r ${tier.color} font-bold text-white`}
                              >
                                {tier.range}
                              </div>
                              <span className="text-xl font-semibold text-white">
                                {tier.label}
                              </span>
                            </div>
                            <Award className={`w-6 h-6 bg-gradient-to-r ${tier.color} bg-clip-text text-transparent`} />
                          </div>

                          <div className="grid grid-cols-2 gap-3">
                            {tier.features.map((feature) => (
                              <div
                                key={feature}
                                className="flex items-center gap-2 p-3 bg-white/5 rounded-lg"
                              >
                                <CheckCircle className="w-4 h-4 text-green-400" />
                                <span className="text-white/80 text-sm">{feature}</span>
                              </div>
                            ))}
                          </div>
                        </motion.div>
                      ))}
                    </div>
                  </div>
                )}

                {/* Trust Indicators Section */}
                {activeSection === 'trust' && (
                  <div className="space-y-6">
                    <h2 className="text-3xl font-bold text-white mb-2">
                      Listing Trust Indicators
                    </h2>
                    <p className="text-white/70">Build confidence with verified, transparent data</p>

                    <div className="mt-8 grid grid-cols-2 gap-6">
                      {/* Example Listing Card */}
                      <div className="bg-white/5 border border-white/10 rounded-2xl overflow-hidden">
                        <div className="aspect-video bg-gradient-to-br from-slate-700 to-slate-600 relative">
                          <div className="absolute top-3 left-3 px-3 py-1 rounded-full bg-green-500 text-white text-sm font-semibold flex items-center gap-1">
                            <CheckCircle className="w-3 h-3" />
                            Verified
                          </div>
                        </div>
                        <div className="p-4">
                          <div className="text-2xl font-bold text-white mb-1">$2,400/mo</div>
                          <div className="text-white/60 mb-3">2BR • Williamsburg</div>

                          <div className="space-y-2 mb-4">
                            <div className="flex items-center gap-2 text-sm">
                              <Shield className="w-4 h-4 text-green-400" />
                              <span className="text-white/80">Verified Listing</span>
                            </div>
                            <div className="flex items-center gap-2 text-sm">
                              <Clock className="w-4 h-4 text-blue-400" />
                              <span className="text-white/60">Updated 2 hours ago</span>
                            </div>
                            <div className="flex items-center gap-2 text-sm">
                              <Building2 className="w-4 h-4 text-purple-400" />
                              <span className="text-white/60">Managed by: ABC Realty</span>
                            </div>
                          </div>

                          <button className="w-full px-4 py-2 bg-white/10 hover:bg-white/20 text-white rounded-lg text-sm font-medium flex items-center justify-center gap-2">
                            View on Zillow
                            <ChevronRight className="w-4 h-4" />
                          </button>
                        </div>
                      </div>

                      {/* Trust Features List */}
                      <div className="space-y-4">
                        <h3 className="text-xl font-semibold text-white mb-4">
                          Trust Features
                        </h3>

                        {[
                          {
                            icon: Shield,
                            title: 'Verification Badge',
                            desc: 'Confirmed with property manager',
                            color: 'text-green-400',
                          },
                          {
                            icon: Clock,
                            title: 'Real-time Updates',
                            desc: 'See when listing was last checked',
                            color: 'text-blue-400',
                          },
                          {
                            icon: Building2,
                            title: 'Source Attribution',
                            desc: 'Direct link to original listing',
                            color: 'text-purple-400',
                          },
                          {
                            icon: AlertCircle,
                            title: 'Report System',
                            desc: 'Flag unavailable or suspicious listings',
                            color: 'text-orange-400',
                          },
                        ].map((feature, i) => {
                          const Icon = feature.icon;
                          return (
                            <div
                              key={i}
                              className="bg-white/5 border border-white/10 rounded-xl p-4"
                            >
                              <div className="flex items-start gap-3">
                                <div className="w-10 h-10 rounded-lg bg-white/5 flex items-center justify-center flex-shrink-0">
                                  <Icon className={`w-5 h-5 ${feature.color}`} />
                                </div>
                                <div>
                                  <h4 className="font-semibold text-white mb-1">
                                    {feature.title}
                                  </h4>
                                  <p className="text-white/60 text-sm">{feature.desc}</p>
                                </div>
                              </div>
                            </div>
                          );
                        })}
                      </div>
                    </div>
                  </div>
                )}

                {/* AI Moments Section */}
                {activeSection === 'ai-moments' && (
                  <div className="space-y-6">
                    <h2 className="text-3xl font-bold text-white mb-2">AI Showcase Moments</h2>
                    <p className="text-white/70">
                      Make AI intelligence visible and impressive from day 1
                    </p>

                    <div className="mt-8 space-y-6">
                      {/* Moment 1: After 3 swipes */}
                      <div className="bg-gradient-to-br from-purple-500/10 to-pink-500/10 border border-purple-500/20 rounded-2xl p-6">
                        <div className="flex items-start gap-4">
                          <div className="w-12 h-12 rounded-full bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center flex-shrink-0">
                            <Lightbulb className="w-6 h-6 text-white" />
                          </div>
                          <div className="flex-1">
                            <div className="text-sm text-purple-300 font-semibold mb-2">
                              AFTER 3 SWIPES
                            </div>
                            <h3 className="text-lg font-bold text-white mb-2">
                              💡 HOMEY noticed:
                            </h3>
                            <p className="text-white/80 mb-4">
                              You prefer walkups over high-rises. Would you like more like this?
                            </p>
                            <div className="flex gap-3">
                              <button className="px-4 py-2 bg-gradient-to-r from-purple-500 to-pink-500 text-white rounded-lg font-medium">
                                Yes, show me similar
                              </button>
                              <button className="px-4 py-2 bg-white/10 text-white rounded-lg font-medium">
                                No, I'm exploring
                              </button>
                            </div>
                          </div>
                        </div>
                      </div>

                      {/* Moment 2: After saving a home */}
                      <div className="bg-gradient-to-br from-blue-500/10 to-cyan-500/10 border border-blue-500/20 rounded-2xl p-6">
                        <div className="flex items-start gap-4">
                          <div className="w-12 h-12 rounded-full bg-gradient-to-br from-blue-500 to-cyan-500 flex items-center justify-center flex-shrink-0">
                            <Bell className="w-6 h-6 text-white" />
                          </div>
                          <div className="flex-1">
                            <div className="text-sm text-blue-300 font-semibold mb-2">
                              AFTER SAVING A HOME
                            </div>
                            <h3 className="text-lg font-bold text-white mb-2">
                              🤖 Smart Alert Set:
                            </h3>
                            <p className="text-white/80 mb-3">I'll watch for:</p>
                            <div className="space-y-2 mb-4">
                              {[
                                'Similar places in this area',
                                'Price drops on this building',
                                'New listings matching your pattern',
                              ].map((item) => (
                                <div
                                  key={item}
                                  className="flex items-center gap-2 text-white/70"
                                >
                                  <CheckCircle className="w-4 h-4 text-green-400" />
                                  {item}
                                </div>
                              ))}
                            </div>
                          </div>
                        </div>
                      </div>

                      {/* Moment 3: After first lesson */}
                      <div className="bg-gradient-to-br from-green-500/10 to-emerald-500/10 border border-green-500/20 rounded-2xl p-6">
                        <div className="flex items-start gap-4">
                          <div className="w-12 h-12 rounded-full bg-gradient-to-br from-green-500 to-emerald-500 flex items-center justify-center flex-shrink-0">
                            <Award className="w-6 h-6 text-white" />
                          </div>
                          <div className="flex-1">
                            <div className="text-sm text-green-300 font-semibold mb-2">
                              AFTER FIRST LESSON
                            </div>
                            <h3 className="text-lg font-bold text-white mb-2">
                              🎓 Nice work! You now know:
                            </h3>
                            <div className="space-y-2 mb-4">
                              {['How to calculate your max budget', 'What to ask landlords'].map(
                                (item) => (
                                  <div
                                    key={item}
                                    className="flex items-center gap-2 text-white/70"
                                  >
                                    <CheckCircle className="w-4 h-4 text-green-400" />
                                    {item}
                                  </div>
                                )
                              )}
                            </div>
                            <p className="text-white/80 mb-4">Want me to remember this for you?</p>
                            <div className="flex gap-3">
                              <button className="px-4 py-2 bg-gradient-to-r from-green-500 to-emerald-500 text-white rounded-lg font-medium">
                                Save to my profile
                              </button>
                              <button className="px-4 py-2 bg-white/10 text-white rounded-lg font-medium">
                                Just learning
                              </button>
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                )}

                {/* Education Mode Section */}
                {activeSection === 'education' && (
                  <div className="space-y-6">
                    <h2 className="text-3xl font-bold text-white mb-2">
                      Education Mode Integration
                    </h2>
                    <p className="text-white/70">
                      Gamified learning built into existing Education feature
                    </p>

                    <div className="mt-8 space-y-6">
                      {/* Learning Path */}
                      <div className="bg-gradient-to-br from-purple-500/10 to-pink-500/10 border border-purple-500/20 rounded-2xl p-6">
                        <h3 className="text-xl font-semibold text-white mb-4 flex items-center gap-2">
                          <BookOpen className="w-6 h-6 text-purple-400" />
                          Your Learning Path
                        </h3>

                        <div className="space-y-3">
                          {[
                            {
                              title: 'Understanding Your Budget',
                              time: '5 min',
                              completed: true,
                              unlocks: '+10% confidence',
                            },
                            {
                              title: 'How to Spot Red Flags',
                              time: '8 min',
                              completed: true,
                              unlocks: '+15% confidence',
                            },
                            {
                              title: "Your Renter's Rights",
                              time: '10 min',
                              completed: false,
                              unlocks: '+15% → Unlock Scout AI',
                            },
                            {
                              title: 'NYC Neighborhood Guide',
                              time: '12 min',
                              completed: false,
                              unlocks: '+10% confidence',
                              locked: true,
                            },
                          ].map((lesson, i) => (
                            <div
                              key={i}
                              className={`p-4 rounded-xl border transition-all ${
                                lesson.completed
                                  ? 'bg-green-500/10 border-green-500/30'
                                  : lesson.locked
                                  ? 'bg-white/5 border-white/10 opacity-50'
                                  : 'bg-white/5 border-white/10'
                              }`}
                            >
                              <div className="flex items-center justify-between">
                                <div className="flex items-center gap-3">
                                  {lesson.completed ? (
                                    <CheckCircle className="w-5 h-5 text-green-400" />
                                  ) : lesson.locked ? (
                                    <Lock className="w-5 h-5 text-white/40" />
                                  ) : (
                                    <div className="w-5 h-5 rounded-full border-2 border-white/40" />
                                  )}
                                  <div>
                                    <div className="font-semibold text-white">{lesson.title}</div>
                                    <div className="text-white/50 text-sm">{lesson.time}</div>
                                  </div>
                                </div>
                                <div className="text-right">
                                  <div className="text-sm text-purple-400 font-medium">
                                    {lesson.unlocks}
                                  </div>
                                </div>
                              </div>
                            </div>
                          ))}
                        </div>

                        <div className="mt-6 p-4 bg-white/5 rounded-xl">
                          <div className="flex items-center justify-between mb-2">
                            <span className="text-white/80 text-sm">Progress to next unlock</span>
                            <span className="text-white font-semibold">2/3 complete</span>
                          </div>
                          <div className="h-2 bg-white/10 rounded-full overflow-hidden">
                            <div
                              className="h-full bg-gradient-to-r from-purple-500 to-pink-500"
                              style={{ width: '66%' }}
                            />
                          </div>
                        </div>
                      </div>

                      {/* Badges */}
                      <div className="bg-white/5 border border-white/10 rounded-2xl p-6">
                        <h3 className="text-xl font-semibold text-white mb-4 flex items-center gap-2">
                          <Award className="w-6 h-6 text-yellow-400" />
                          Earned Badges
                        </h3>

                        <div className="grid grid-cols-4 gap-4">
                          {[
                            { emoji: '💰', title: 'Budget Master', earned: true },
                            { emoji: '🔍', title: 'Red Flag Spotter', earned: true },
                            { emoji: '📜', title: 'Rights Champion', earned: false },
                            { emoji: '🗺️', title: 'Neighborhood Expert', earned: false },
                          ].map((badge, i) => (
                            <div
                              key={i}
                              className={`text-center p-4 rounded-xl ${
                                badge.earned
                                  ? 'bg-gradient-to-br from-yellow-500/20 to-amber-500/20 border border-yellow-500/30'
                                  : 'bg-white/5 border border-white/10 opacity-40'
                              }`}
                            >
                              <div className="text-4xl mb-2">{badge.emoji}</div>
                              <div className="text-white text-sm font-medium">{badge.title}</div>
                            </div>
                          ))}
                        </div>
                      </div>
                    </div>
                  </div>
                )}
              </motion.div>
            </AnimatePresence>
          </div>
        </div>
      </div>
    </div>
  );
}

// Missing icon imports
import { Clock, Building2, Bell } from 'lucide-react';
