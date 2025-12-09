'use client';

import { useState } from 'react';
import { ArrowLeft } from 'lucide-react';
import { useRouter } from 'next/navigation';

export default function LegalPage() {
  const router = useRouter();
  const [activeTab, setActiveTab] = useState<'terms' | 'privacy' | 'cookies'>('terms');

  return (
    <main className="min-h-screen bg-gradient-to-b from-gray-900 via-purple-900/20 to-gray-900 text-white">
      <div className="max-w-4xl mx-auto px-4 py-8">
        {/* Header */}
        <div className="mb-8">
          <button
            onClick={() => router.back()}
            className="flex items-center gap-2 text-white/60 hover:text-white transition-colors mb-6"
          >
            <ArrowLeft className="w-5 h-5" />
            Back
          </button>
          <h1 className="text-4xl font-bold mb-2">HOMEY™ Legal Documents</h1>
          <p className="text-white/60">Last Updated: December 6, 2025</p>
          <p className="text-white/60">Jurisdiction: State of New York, United States</p>
        </div>

        {/* Tabs */}
        <div className="flex gap-2 mb-6 border-b border-white/10">
          <button
            onClick={() => setActiveTab('terms')}
            className={`px-4 py-3 font-semibold transition-all ${
              activeTab === 'terms'
                ? 'text-primary border-b-2 border-primary'
                : 'text-white/60 hover:text-white'
            }`}
          >
            Terms of Service
          </button>
          <button
            onClick={() => setActiveTab('privacy')}
            className={`px-4 py-3 font-semibold transition-all ${
              activeTab === 'privacy'
                ? 'text-primary border-b-2 border-primary'
                : 'text-white/60 hover:text-white'
            }`}
          >
            Privacy Policy
          </button>
          <button
            onClick={() => setActiveTab('cookies')}
            className={`px-4 py-3 font-semibold transition-all ${
              activeTab === 'cookies'
                ? 'text-primary border-b-2 border-primary'
                : 'text-white/60 hover:text-white'
            }`}
          >
            Cookie Policy
          </button>
        </div>

        {/* Content */}
        <div className="glass rounded-2xl p-8 space-y-6">
          {activeTab === 'terms' && <TermsOfService />}
          {activeTab === 'privacy' && <PrivacyPolicy />}
          {activeTab === 'cookies' && <CookiePolicy />}
        </div>
      </div>
    </main>
  );
}

function TermsOfService() {
  return (
    <div className="space-y-6">
      <section>
        <h2 className="text-2xl font-bold mb-3">1. Acceptance of Terms</h2>
        <p className="text-white/80 leading-relaxed">
          By creating an account, accessing, or using the Homey™ application ("Service"), you agree to be bound by these Terms. If you do not agree, you may not use the Service.
        </p>
        <p className="text-white/80 leading-relaxed mt-3">
          <strong>Age Requirement:</strong> You must be at least 18 years old to use Homey™. By using the Service, you represent and warrant that you possess the legal capacity to enter into a binding contract.
        </p>
      </section>

      <section>
        <h2 className="text-2xl font-bold mb-3">2. Intellectual Property Rights (The "Homey Protection" Clause)</h2>
        <p className="text-white/80 leading-relaxed mb-3">
          The Service and its original content, features, and functionality are and will remain the exclusive property of Homey LLC and its licensors.
        </p>
        <ul className="list-disc list-inside space-y-2 text-white/80">
          <li><strong>Proprietary Logic:</strong> The specific user flows, "pocket" interface concepts, AI agent personalities ("Homey"), and underlying algorithms are proprietary trade secrets of Homey LLC.</li>
          <li><strong>Trademarks:</strong> The Homey™ name, the Homey logo, and "Homey in your pocket" are trademarks of Homey LLC. You may not use these marks without prior written permission.</li>
          <li><strong>No Reverse Engineering:</strong> You agree not to reproduce, duplicate, copy, sell, resell, or exploit any portion of the Service, use of the Service, or access to the Service, or attempt to reverse engineer or scrape data from the Service.</li>
        </ul>
      </section>

      <section>
        <h2 className="text-2xl font-bold mb-3">3. Artificial Intelligence (AI) Disclaimer</h2>
        <p className="text-white/80 leading-relaxed mb-3">
          Homey™ utilizes advanced artificial intelligence and large language models (LLMs) to provide conversational assistance and recommendations.
        </p>
        <ul className="list-disc list-inside space-y-2 text-white/80">
          <li><strong>Accuracy:</strong> While we strive for precision, AI can hallucinate or provide outdated information. You should independently verify all critical information (such as rent prices, square footage, and school zones) with a licensed real estate professional or the property management directly.</li>
          <li><strong>No Professional Advice:</strong> Homey™ is an information provider, not a licensed real estate broker, financial advisor, or attorney. No interaction with the Homey AI constitutes a fiduciary relationship.</li>
        </ul>
      </section>

      <section>
        <h2 className="text-2xl font-bold mb-3">4. Limitation of Liability</h2>
        <p className="text-white/80 leading-relaxed">
          To the fullest extent permitted by applicable law, in no event shall Homey LLC, its affiliates, directors, or employees be liable for any indirect, punitive, incidental, special, consequential, or exemplary damages, including without limitation damages for loss of profits, goodwill, use, data, or other intangible losses, arising out of or relating to the use of, or inability to use, the Service.
        </p>
      </section>

      <section>
        <h2 className="text-2xl font-bold mb-3">5. Governing Law</h2>
        <p className="text-white/80 leading-relaxed">
          These Terms shall be governed and construed in accordance with the laws of the State of New York, without regard to its conflict of law provisions.
        </p>
      </section>
    </div>
  );
}

function PrivacyPolicy() {
  return (
    <div className="space-y-6">
      <section>
        <h2 className="text-2xl font-bold mb-3">1. AI Data Processing (Apple App Store Compliance)</h2>
        <ul className="list-disc list-inside space-y-2 text-white/80">
          <li><strong>Explicit Consent:</strong> By using Homey™, you explicitly acknowledge and consent that the text, voice, and search criteria you input into the application may be processed by third-party artificial intelligence providers (including but not limited to OpenAI and Anthropic) solely for the purpose of generating relevant responses and recommendations.</li>
          <li><strong>Data Usage:</strong> Your inputs are used to generate answers. We have implemented safeguards to prevent your personal data from being used to train public third-party models where possible.</li>
          <li><strong>Opt-Out:</strong> You may opt-out of AI processing by ceasing use of the AI chat features, though this will limit the functionality of the Service.</li>
        </ul>
      </section>

      <section>
        <h2 className="text-2xl font-bold mb-3">2. Information We Collect</h2>
        <ul className="list-disc list-inside space-y-2 text-white/80">
          <li><strong>Identity Data:</strong> Name, email address, phone number.</li>
          <li><strong>Real Estate Preferences:</strong> Budget, desired neighborhoods, credit score range (if voluntarily provided), and amenity requirements.</li>
          <li><strong>Location Data:</strong> Approximate location (IP address) or precise location (GPS) if you grant permission, used to show nearby listings.</li>
          <li><strong>Usage Data:</strong> Chat logs, saved listings, and interaction history.</li>
        </ul>
      </section>

      <section>
        <h2 className="text-2xl font-bold mb-3">3. How We Use Your Data</h2>
        <ul className="list-disc list-inside space-y-2 text-white/80">
          <li>To provide the "Homey" concierge service and match you with properties.</li>
          <li>To connect you with human agents or landlords only when you explicitly request it.</li>
          <li>To improve our proprietary matching algorithms.</li>
        </ul>
      </section>

      <section>
        <h2 className="text-2xl font-bold mb-3">4. Data Sharing & Third Parties</h2>
        <p className="text-white/80 leading-relaxed mb-3">
          We do not sell your personal data. We share data only in the following ways:
        </p>
        <ul className="list-disc list-inside space-y-2 text-white/80">
          <li><strong>Service Providers:</strong> Cloud hosting (AWS/Supabase), map services (Google/Mapbox), and AI processors (OpenAI).</li>
          <li><strong>Legal Compliance:</strong> If required by law enforcement or valid court order.</li>
        </ul>
      </section>

      <section>
        <h2 className="text-2xl font-bold mb-3">5. New York City Tenant Data Privacy</h2>
        <p className="text-white/80 leading-relaxed">
          In compliance with NYC data standards:
        </p>
        <ul className="list-disc list-inside space-y-2 text-white/80 mt-2">
          <li>We collect only the minimum amount of data necessary to provide the service.</li>
          <li>If you utilize Homey to interface with "smart access" building systems (future feature), specific consent will be obtained for biometric or keyless entry data, which will be retained for no longer than 90 days after deactivation.</li>
        </ul>
      </section>

      <section>
        <h2 className="text-2xl font-bold mb-3">6. Your Rights (Data Deletion)</h2>
        <p className="text-white/80 leading-relaxed mb-2">
          You have the right to access, correct, or delete your personal data.
        </p>
        <p className="text-white/80 leading-relaxed">
          <strong>To Request Deletion:</strong> Email support@homey.app or use the "Delete Account" function in the app settings. We will permanently erase your data within 30 days of the request.
        </p>
      </section>
    </div>
  );
}

function CookiePolicy() {
  return (
    <div className="space-y-6">
      <p className="text-white/80 leading-relaxed">
        We use cookies and similar tracking technologies to track the activity on our Service and hold certain information.
      </p>

      <section>
        <h3 className="text-xl font-bold mb-2">Essential Cookies</h3>
        <p className="text-white/80 leading-relaxed">
          Required for login and security.
        </p>
      </section>

      <section>
        <h3 className="text-xl font-bold mb-2">Preference Cookies</h3>
        <p className="text-white/80 leading-relaxed">
          Remember your search filters and "Homey" chat history context.
        </p>
      </section>

      <section>
        <h3 className="text-xl font-bold mb-2">Analytics Cookies</h3>
        <p className="text-white/80 leading-relaxed">
          Help us understand how users interact with the app (e.g., Google Analytics). You can instruct your browser to refuse all cookies, but some portions of our Service may become unavailable.
        </p>
      </section>
    </div>
  );
}
