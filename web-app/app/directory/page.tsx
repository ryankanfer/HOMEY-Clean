'use client';

import { motion } from 'framer-motion';
import { Truck, DollarSign, Scale, Users, Sparkles, Search, Paintbrush, ArrowRight } from 'lucide-react';
import BottomNav from '@/components/BottomNav';

const PARTNERS = [
  { icon: Truck, label: 'Movers', color: 'from-blue-500 to-cyan-500' },
  { icon: DollarSign, label: 'Lenders', color: 'from-green-500 to-emerald-500' },
  { icon: Scale, label: 'Lawyers', color: 'from-purple-500 to-violet-500' },
  { icon: Users, label: 'Agents', color: 'from-pink-500 to-rose-500' },
  { icon: Sparkles, label: 'Cleaners', color: 'from-yellow-500 to-orange-500' },
  { icon: Search, label: 'Inspectors', color: 'from-indigo-500 to-blue-500' },
  { icon: Paintbrush, label: 'Painters', color: 'from-red-500 to-pink-500' },
];

export default function DirectoryPage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900 pb-24">
      {/* Hero Section */}
      <div className="relative overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-b from-white/5 to-transparent" />
        <div className="relative max-w-4xl mx-auto px-6 pt-20 pb-16 text-center">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6 }}
          >
            <h1 className="text-5xl md:text-6xl font-bold text-white mb-6">
              Partner Directory
            </h1>
            <p className="text-xl text-white/70 mb-4">
              Coming Soon
            </p>
            <p className="text-lg text-white/60 max-w-2xl mx-auto">
              We're building a curated network of trusted partners to make your home journey seamless.
            </p>
          </motion.div>
        </div>
      </div>

      {/* Partner Categories Grid */}
      <div className="max-w-6xl mx-auto px-6 py-12">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
          className="mb-12 text-center"
        >
          <h2 className="text-3xl font-bold text-white mb-4">
            Partner Spotlight
          </h2>
          <p className="text-white/70 text-lg">
            Looking for exceptional service providers in these categories
          </p>
        </motion.div>

        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6 mb-16">
          {PARTNERS.map((partner, idx) => (
            <motion.div
              key={partner.label}
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ delay: 0.4 + idx * 0.1 }}
              className="relative group"
            >
              <div className="relative overflow-hidden rounded-2xl bg-white/5 backdrop-blur-xl border border-white/10 p-8 hover:bg-white/10 transition-all duration-300">
                <div className={`w-16 h-16 rounded-xl bg-gradient-to-br ${partner.color} flex items-center justify-center mb-4 group-hover:scale-110 transition-transform duration-300`}>
                  <partner.icon className="w-8 h-8 text-white" />
                </div>
                <h3 className="text-xl font-semibold text-white">{partner.label}</h3>
              </div>
            </motion.div>
          ))}
        </div>

        {/* CTA Section */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.8 }}
          className="bg-gradient-to-r from-pink-500/20 to-rose-500/20 backdrop-blur-xl border border-white/20 rounded-3xl p-12 text-center"
        >
          <h3 className="text-3xl font-bold text-white mb-4">
            Want to Partner with HOMEY?
          </h3>
          <p className="text-xl text-white/80 mb-8 max-w-2xl mx-auto">
            If you or anyone you know may want to partner with HOMEY, let us know
          </p>
          <button className="group inline-flex items-center gap-3 px-8 py-4 bg-gradient-to-r from-pink-500 to-rose-500 text-white rounded-full text-lg font-semibold hover:shadow-2xl hover:shadow-pink-500/50 transition-all duration-300 hover:scale-105">
            Get in Touch
            <ArrowRight className="w-5 h-5 group-hover:translate-x-1 transition-transform" />
          </button>
        </motion.div>
      </div>

      <BottomNav />
    </div>
  );
}
