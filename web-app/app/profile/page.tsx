'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { auth } from '@/lib/supabase';
import { useUserProfile } from '@/contexts/UserProfileContext';
import BottomNavigation from '@/components/BottomNav';

export default function ProfilePage() {
  const router = useRouter();
  const { profile, isLoading, error, refreshProfile } = useUserProfile();
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  useEffect(() => {
    async function checkAuth() {
      const { data: { user } } = await auth.getUser();
      if (!user) {
        router.push('/login');
      } else {
        setIsAuthenticated(true);
      }
    }
    checkAuth();
  }, [router]);

  if (!isAuthenticated) {
    return null;
  }

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-purple-900 via-pink-800 to-orange-700 flex items-center justify-center">
        <div className="text-white text-center">
          <div className="text-4xl mb-4">🧠</div>
          <p className="text-lg">Loading your profile...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-purple-900 via-pink-800 to-orange-700 p-6 flex items-center justify-center">
        <div className="bg-red-500/20 border-2 border-red-500 rounded-xl p-6 max-w-md">
          <h2 className="text-xl font-bold text-red-400 mb-2">Error Loading Profile</h2>
          <p className="text-white/80 mb-4">{error}</p>
          <button
            onClick={refreshProfile}
            className="bg-red-500 text-white px-4 py-2 rounded-lg hover:bg-red-600"
          >
            Retry
          </button>
        </div>
      </div>
    );
  }

  const hasAnyData = profile && (
    profile.monthly_income ||
    profile.max_budget ||
    profile.pre_approval_amount ||
    profile.current_lease_address ||
    profile.budget_min ||
    (profile.preferred_neighborhoods && profile.preferred_neighborhoods.length > 0)
  );

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-900 via-pink-800 to-orange-700 pb-24">
      {/* Header */}
      <div className="bg-black/20 backdrop-blur-sm border-b border-white/10 p-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-white">What Homey Knows</h1>
            <p className="text-white/60 text-sm mt-1">
              AI-learned insights from your documents
            </p>
          </div>
          <button
            onClick={refreshProfile}
            className="bg-white/10 hover:bg-white/20 text-white px-4 py-2 rounded-lg text-sm"
          >
            Refresh
          </button>
        </div>
      </div>

      <div className="p-6 space-y-6">
        {!hasAnyData ? (
          // Empty State
          <div className="bg-white/10 backdrop-blur-sm rounded-xl p-8 text-center">
            <div className="text-6xl mb-4">📄</div>
            <h2 className="text-xl font-bold text-white mb-2">No Profile Data Yet</h2>
            <p className="text-white/70 mb-6">
              Upload documents to your Vault to help Homey learn about your housing needs and preferences.
            </p>
            <button
              onClick={() => router.push('/vault')}
              className="bg-primary hover:bg-primary/80 text-white px-6 py-3 rounded-lg font-semibold"
            >
              Go to Vault
            </button>
          </div>
        ) : (
          <>
            {/* Financial Profile */}
            {(profile?.monthly_income || profile?.max_budget || profile?.pre_approval_amount) && (
              <div className="bg-white/10 backdrop-blur-sm rounded-xl p-6">
                <div className="flex items-center gap-3 mb-4">
                  <div className="text-3xl">💰</div>
                  <div>
                    <h2 className="text-xl font-bold text-white">Financial Profile</h2>
                    <p className="text-white/60 text-sm">From paystubs, bank statements, and pre-approvals</p>
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  {profile.monthly_income && (
                    <div className="bg-black/20 rounded-lg p-4">
                      <p className="text-white/60 text-sm mb-1">Monthly Income</p>
                      <p className="text-2xl font-bold text-white">
                        ${profile.monthly_income.toLocaleString()}
                      </p>
                    </div>
                  )}

                  {profile.max_budget && (
                    <div className="bg-black/20 rounded-lg p-4">
                      <p className="text-white/60 text-sm mb-1">Max Budget (30% rule)</p>
                      <p className="text-2xl font-bold text-white">
                        ${profile.max_budget.toLocaleString()}/mo
                      </p>
                    </div>
                  )}

                  {profile.pre_approval_amount && (
                    <div className="bg-black/20 rounded-lg p-4">
                      <p className="text-white/60 text-sm mb-1">Pre-Approval Amount</p>
                      <p className="text-2xl font-bold text-green-400">
                        ${profile.pre_approval_amount.toLocaleString()}
                      </p>
                      {profile.loan_type && (
                        <p className="text-white/60 text-xs mt-1">{profile.loan_type}</p>
                      )}
                    </div>
                  )}

                  {profile.financial_capacity && (
                    <div className="bg-black/20 rounded-lg p-4">
                      <p className="text-white/60 text-sm mb-1">Financial Capacity</p>
                      <p className="text-2xl font-bold text-white capitalize">
                        {profile.financial_capacity}
                      </p>
                    </div>
                  )}
                </div>
              </div>
            )}

            {/* Housing Preferences */}
            {(profile?.budget_min || profile?.min_bedrooms || profile?.pet_friendly !== null ||
              (profile?.preferred_neighborhoods && profile.preferred_neighborhoods.length > 0)) && (
              <div className="bg-white/10 backdrop-blur-sm rounded-xl p-6">
                <div className="flex items-center gap-3 mb-4">
                  <div className="text-3xl">🏠</div>
                  <div>
                    <h2 className="text-xl font-bold text-white">Housing Preferences</h2>
                    <p className="text-white/60 text-sm">From leases and search history</p>
                  </div>
                </div>

                <div className="space-y-4">
                  {profile.budget_min && profile.budget_max && (
                    <div className="bg-black/20 rounded-lg p-4">
                      <p className="text-white/60 text-sm mb-1">Budget Range</p>
                      <p className="text-xl font-bold text-white">
                        ${profile.budget_min.toLocaleString()} - ${profile.budget_max.toLocaleString()}/mo
                      </p>
                    </div>
                  )}

                  <div className="grid grid-cols-2 gap-4">
                    {profile.min_bedrooms && (
                      <div className="bg-black/20 rounded-lg p-4">
                        <p className="text-white/60 text-sm mb-1">Min Bedrooms</p>
                        <p className="text-xl font-bold text-white">{profile.min_bedrooms}</p>
                      </div>
                    )}

                    {profile.min_bathrooms && (
                      <div className="bg-black/20 rounded-lg p-4">
                        <p className="text-white/60 text-sm mb-1">Min Bathrooms</p>
                        <p className="text-xl font-bold text-white">{profile.min_bathrooms}</p>
                      </div>
                    )}
                  </div>

                  {profile.preferred_neighborhoods && profile.preferred_neighborhoods.length > 0 && (
                    <div className="bg-black/20 rounded-lg p-4">
                      <p className="text-white/60 text-sm mb-2">Preferred Neighborhoods</p>
                      <div className="flex flex-wrap gap-2">
                        {profile.preferred_neighborhoods.map((neighborhood, i) => (
                          <span
                            key={i}
                            className="bg-primary/20 border border-primary text-white px-3 py-1 rounded-full text-sm"
                          >
                            {neighborhood}
                          </span>
                        ))}
                      </div>
                    </div>
                  )}

                  {profile.pet_friendly !== null && (
                    <div className="bg-black/20 rounded-lg p-4">
                      <p className="text-white/60 text-sm mb-1">Pet Friendly</p>
                      <p className="text-xl font-bold text-white">
                        {profile.pet_friendly ? '✅ Yes' : '❌ No'}
                      </p>
                    </div>
                  )}

                  {profile.smoking_policy && (
                    <div className="bg-black/20 rounded-lg p-4">
                      <p className="text-white/60 text-sm mb-1">Smoking Policy</p>
                      <p className="text-lg text-white">{profile.smoking_policy}</p>
                    </div>
                  )}
                </div>
              </div>
            )}

            {/* Current Lease */}
            {profile?.current_lease_address && (
              <div className="bg-white/10 backdrop-blur-sm rounded-xl p-6">
                <div className="flex items-center gap-3 mb-4">
                  <div className="text-3xl">📍</div>
                  <div>
                    <h2 className="text-xl font-bold text-white">Current Lease</h2>
                    <p className="text-white/60 text-sm">From uploaded lease documents</p>
                  </div>
                </div>

                <div className="space-y-4">
                  <div className="bg-black/20 rounded-lg p-4">
                    <p className="text-white/60 text-sm mb-1">Address</p>
                    <p className="text-lg text-white">{profile.current_lease_address}</p>
                  </div>

                  <div className="grid grid-cols-2 gap-4">
                    {profile.current_monthly_rent && (
                      <div className="bg-black/20 rounded-lg p-4">
                        <p className="text-white/60 text-sm mb-1">Current Rent</p>
                        <p className="text-xl font-bold text-white">
                          ${profile.current_monthly_rent.toLocaleString()}/mo
                        </p>
                      </div>
                    )}

                    {profile.current_lease_end_date && (
                      <div className="bg-black/20 rounded-lg p-4">
                        <p className="text-white/60 text-sm mb-1">Lease Ends</p>
                        <p className="text-xl font-bold text-white">
                          {new Date(profile.current_lease_end_date).toLocaleDateString()}
                        </p>
                      </div>
                    )}
                  </div>
                </div>
              </div>
            )}

            {/* AI Insights */}
            {(profile?.urgency || profile?.ready_to_buy !== null) && (
              <div className="bg-white/10 backdrop-blur-sm rounded-xl p-6">
                <div className="flex items-center gap-3 mb-4">
                  <div className="text-3xl">🧠</div>
                  <div>
                    <h2 className="text-xl font-bold text-white">AI Insights</h2>
                    <p className="text-white/60 text-sm">Homey's analysis</p>
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  {profile.urgency && (
                    <div className="bg-black/20 rounded-lg p-4">
                      <p className="text-white/60 text-sm mb-1">Search Urgency</p>
                      <p className={`text-xl font-bold capitalize ${
                        profile.urgency === 'high' ? 'text-red-400' :
                        profile.urgency === 'medium' ? 'text-yellow-400' :
                        'text-green-400'
                      }`}>
                        {profile.urgency}
                      </p>
                    </div>
                  )}

                  {profile.ready_to_buy !== null && (
                    <div className="bg-black/20 rounded-lg p-4">
                      <p className="text-white/60 text-sm mb-1">Ready to Buy</p>
                      <p className="text-xl font-bold text-white">
                        {profile.ready_to_buy ? '✅ Yes' : '📋 Renting'}
                      </p>
                    </div>
                  )}
                </div>
              </div>
            )}

            {/* Privacy Notice */}
            <div className="bg-blue-500/20 border border-blue-400/50 rounded-xl p-4">
              <div className="flex items-start gap-3">
                <div className="text-2xl">ℹ️</div>
                <div className="flex-1">
                  <h3 className="text-white font-semibold mb-1">How Homey Uses This Data</h3>
                  <ul className="text-white/70 text-sm space-y-1">
                    <li>• Personalize property recommendations in your feed</li>
                    <li>• Filter search results to match your budget and preferences</li>
                    <li>• Show urgent actions (like lease ending soon)</li>
                    <li>• Improve Scout's recommendations</li>
                  </ul>
                  <p className="text-white/60 text-xs mt-2">
                    This data is private, encrypted, and never shared. You can delete your profile anytime from Settings.
                  </p>
                </div>
              </div>
            </div>
          </>
        )}
      </div>

      <BottomNavigation />
    </div>
  );
}
