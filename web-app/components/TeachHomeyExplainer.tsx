'use client';

import { motion } from 'framer-motion';

export default function TeachHomeyExplainer() {
  return (
    <motion.div
      className="px-5 mb-16"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: 0.6 }}
    >
      <div className="max-w-6xl mx-auto space-y-12">
        {/* How It Works */}
        <div>
          <h3 className="text-center text-sm font-bold text-white/40 uppercase tracking-wider mb-6">
            How It Works
          </h3>
          <div className="grid md:grid-cols-3 gap-6">
            <div className="glass rounded-2xl p-6 border border-white/10 text-center">
              <div className="w-16 h-16 mx-auto mb-4 rounded-full bg-gradient-to-br from-purple-500/20 to-pink-500/20 flex items-center justify-center text-4xl">
                👆
              </div>
              <h4 className="text-white font-bold text-lg mb-2">Swipe</h4>
              <p className="text-white/60 text-sm leading-relaxed">
                Pass, like, or love properties and designs
              </p>
            </div>

            <div className="glass rounded-2xl p-6 border border-white/10 text-center">
              <div className="w-16 h-16 mx-auto mb-4 rounded-full bg-gradient-to-br from-blue-500/20 to-cyan-500/20 flex items-center justify-center text-4xl">
                🧠
              </div>
              <h4 className="text-white font-bold text-lg mb-2">Learn</h4>
              <p className="text-white/60 text-sm leading-relaxed">
                AI analyzes your patterns and preferences
              </p>
            </div>

            <div className="glass rounded-2xl p-6 border border-white/10 text-center">
              <div className="w-16 h-16 mx-auto mb-4 rounded-full bg-gradient-to-br from-green-500/20 to-emerald-500/20 flex items-center justify-center text-4xl">
                🎯
              </div>
              <h4 className="text-white font-bold text-lg mb-2">Match</h4>
              <p className="text-white/60 text-sm leading-relaxed">
                Get personalized property recommendations
              </p>
            </div>
          </div>
        </div>

        {/* What You'll Unlock */}
        <div>
          <h3 className="text-center text-sm font-bold text-white/40 uppercase tracking-wider mb-6">
            What You'll Unlock
          </h3>
          <div className="grid md:grid-cols-4 gap-4">
            <div className="glass rounded-2xl p-5 border border-white/10 text-center group hover:border-purple-500/30 transition-all">
              <div className="text-4xl mb-3 group-hover:scale-110 transition-transform">🎯</div>
              <h4 className="text-white font-semibold text-sm mb-2">Smart Matches</h4>
              <p className="text-white/50 text-xs">AI-powered recommendations</p>
            </div>

            <div className="glass rounded-2xl p-5 border border-white/10 text-center group hover:border-yellow-500/30 transition-all">
              <div className="text-4xl mb-3 group-hover:scale-110 transition-transform">⚡</div>
              <h4 className="text-white font-semibold text-sm mb-2">Time Saved</h4>
              <p className="text-white/50 text-xs">Less browsing, more finding</p>
            </div>

            <div className="glass rounded-2xl p-5 border border-white/10 text-center group hover:border-blue-500/30 transition-all">
              <div className="text-4xl mb-3 group-hover:scale-110 transition-transform">📊</div>
              <h4 className="text-white font-semibold text-sm mb-2">Price Insights</h4>
              <p className="text-white/50 text-xs">Learn your sweet spot</p>
            </div>

            <div className="glass rounded-2xl p-5 border border-white/10 text-center group hover:border-pink-500/30 transition-all">
              <div className="text-4xl mb-3 group-hover:scale-110 transition-transform">🏆</div>
              <h4 className="text-white font-semibold text-sm mb-2">Top Picks</h4>
              <p className="text-white/50 text-xs">Daily curated selections</p>
            </div>
          </div>
        </div>

        {/* Pro Tips */}
        <div>
          <h3 className="text-center text-sm font-bold text-white/40 uppercase tracking-wider mb-6">
            Pro Tips
          </h3>
          <div className="grid md:grid-cols-2 gap-4">
            <div className="glass rounded-2xl p-5 border border-white/10 hover:border-white/20 transition-all">
              <div className="flex items-start gap-4">
                <div className="w-12 h-12 shrink-0 rounded-xl bg-gradient-to-br from-yellow-500/20 to-orange-500/20 flex items-center justify-center text-2xl">
                  💡
                </div>
                <div className="flex-1">
                  <h4 className="text-white font-semibold text-sm mb-1">Be Honest</h4>
                  <p className="text-white/60 text-xs leading-relaxed">
                    Swipe based on gut feeling. The AI learns best from your authentic reactions.
                  </p>
                </div>
              </div>
            </div>

            <div className="glass rounded-2xl p-5 border border-white/10 hover:border-white/20 transition-all">
              <div className="flex items-start gap-4">
                <div className="w-12 h-12 shrink-0 rounded-xl bg-gradient-to-br from-purple-500/20 to-pink-500/20 flex items-center justify-center text-2xl">
                  🎨
                </div>
                <div className="flex-1">
                  <h4 className="text-white font-semibold text-sm mb-1">Style Matters</h4>
                  <p className="text-white/60 text-xs leading-relaxed">
                    Don't skip Style Studio. Design preferences help us find spaces you'll actually love living in.
                  </p>
                </div>
              </div>
            </div>

            <div className="glass rounded-2xl p-5 border border-white/10 hover:border-white/20 transition-all">
              <div className="flex items-start gap-4">
                <div className="w-12 h-12 shrink-0 rounded-xl bg-gradient-to-br from-blue-500/20 to-cyan-500/20 flex items-center justify-center text-2xl">
                  🔄
                </div>
                <div className="flex-1">
                  <h4 className="text-white font-semibold text-sm mb-1">Keep Teaching</h4>
                  <p className="text-white/60 text-xs leading-relaxed">
                    Your taste evolves. Come back regularly to keep your recommendations fresh.
                  </p>
                </div>
              </div>
            </div>

            <div className="glass rounded-2xl p-5 border border-white/10 hover:border-white/20 transition-all">
              <div className="flex items-start gap-4">
                <div className="w-12 h-12 shrink-0 rounded-xl bg-gradient-to-br from-pink-500/20 to-red-500/20 flex items-center justify-center text-2xl">
                  ❤️
                </div>
                <div className="flex-1">
                  <h4 className="text-white font-semibold text-sm mb-1">Save Everything</h4>
                  <p className="text-white/60 text-xs leading-relaxed">
                    Saved properties create your personal collection and strengthen the AI's understanding.
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </motion.div>
  );
}
