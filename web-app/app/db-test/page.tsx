'use client';

import { useState, useEffect } from 'react';
import { db, auth, supabase } from '@/lib/supabase';

export default function DatabaseTestPage() {
  const [results, setResults] = useState<any>({});
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    runTests();
  }, []);

  const runTests = async () => {
    const testResults: any = {};

    // Test 1: Check Auth
    console.log('🧪 Test 1: Checking authentication...');
    try {
      const { data: { user }, error } = await auth.getUser();
      testResults.auth = {
        success: !error && !!user,
        user: user ? {
          id: user.id,
          email: user.email,
          created_at: user.created_at,
        } : null,
        error: error?.message,
      };
      console.log('✅ Auth test:', testResults.auth);
    } catch (err: any) {
      testResults.auth = { success: false, error: err.message };
      console.error('❌ Auth test failed:', err);
    }

    // Test 2: Check if profiles table exists and is readable
    console.log('🧪 Test 2: Reading from profiles table...');
    try {
      const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .limit(5);

      testResults.profilesRead = {
        success: !error,
        count: data?.length || 0,
        data: data,
        error: error?.message,
      };
      console.log('✅ Profiles read test:', testResults.profilesRead);
    } catch (err: any) {
      testResults.profilesRead = { success: false, error: err.message };
      console.error('❌ Profiles read test failed:', err);
    }

    // Test 3: Get current user's profile
    if (testResults.auth.user) {
      console.log('🧪 Test 3: Getting current user profile...');
      try {
        const { data, error } = await db.getProfile(testResults.auth.user.id);
        testResults.myProfile = {
          success: !error,
          data: data,
          error: error?.message,
        };
        console.log('✅ My profile test:', testResults.myProfile);
      } catch (err: any) {
        testResults.myProfile = { success: false, error: err.message };
        console.error('❌ My profile test failed:', err);
      }
    }

    // Test 4: Test write permission (update profile)
    if (testResults.auth.user) {
      console.log('🧪 Test 4: Testing write permission...');
      try {
        const testData = { updated_at: new Date().toISOString() };
        const { data, error } = await db.updateProfile(testResults.auth.user.id, testData);
        testResults.profileWrite = {
          success: !error,
          data: data,
          error: error?.message,
        };
        console.log('✅ Profile write test:', testResults.profileWrite);
      } catch (err: any) {
        testResults.profileWrite = { success: false, error: err.message };
        console.error('❌ Profile write test failed:', err);
      }
    }

    // Test 5: Check if triggers exist
    console.log('🧪 Test 5: Checking database triggers...');
    try {
      const { data, error } = await supabase.rpc('get_triggers_info');
      testResults.triggers = {
        success: !error,
        data: data,
        error: error?.message || (data ? null : 'RPC function not found - this is OK'),
      };
      console.log('ℹ️ Triggers test:', testResults.triggers);
    } catch (err: any) {
      testResults.triggers = {
        success: false,
        error: 'RPC function not found - this is normal, triggers might still work'
      };
    }

    // Test 6: Count all profiles
    console.log('🧪 Test 6: Counting all profiles...');
    try {
      const { count, error } = await supabase
        .from('profiles')
        .select('*', { count: 'exact', head: true });

      testResults.profileCount = {
        success: !error,
        count: count,
        error: error?.message,
      };
      console.log('✅ Profile count test:', testResults.profileCount);
    } catch (err: any) {
      testResults.profileCount = { success: false, error: err.message };
      console.error('❌ Profile count test failed:', err);
    }

    setResults(testResults);
    setIsLoading(false);
  };

  const ResultCard = ({ title, result }: any) => (
    <div className={`p-4 rounded-lg border-2 ${result?.success ? 'bg-green-50 border-green-500' : 'bg-red-50 border-red-500'}`}>
      <h3 className="font-bold mb-2 flex items-center gap-2">
        <span>{result?.success ? '✅' : '❌'}</span>
        {title}
      </h3>
      {result?.error && (
        <div className="text-red-700 text-sm mb-2">
          <strong>Error:</strong> {result.error}
        </div>
      )}
      {result?.data && (
        <details className="text-sm">
          <summary className="cursor-pointer font-semibold mb-2">View Data</summary>
          <pre className="bg-white p-2 rounded overflow-x-auto text-xs">
            {JSON.stringify(result.data, null, 2)}
          </pre>
        </details>
      )}
      {result?.count !== undefined && (
        <div className="text-sm">
          <strong>Count:</strong> {result.count}
        </div>
      )}
      {result?.user && (
        <div className="text-sm space-y-1">
          <div><strong>ID:</strong> {result.user.id}</div>
          <div><strong>Email:</strong> {result.user.email}</div>
        </div>
      )}
    </div>
  );

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-100 flex items-center justify-center">
        <div className="text-center">
          <div className="w-12 h-12 border-4 border-blue-500 border-t-transparent rounded-full animate-spin mx-auto mb-4" />
          <p className="text-gray-600">Running database tests...</p>
        </div>
      </div>
    );
  }

  const allPassed = Object.values(results).every((r: any) => r?.success);

  return (
    <div className="min-h-screen bg-gray-100 p-8">
      <div className="max-w-4xl mx-auto">
        {/* Header */}
        <div className="bg-white rounded-lg shadow-lg p-6 mb-6">
          <h1 className="text-3xl font-bold mb-2">Database Connection Test</h1>
          <p className="text-gray-600">Testing Supabase connection and permissions</p>

          {/* Overall Status */}
          <div className={`mt-4 p-4 rounded-lg ${allPassed ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800'}`}>
            <strong>Overall Status:</strong> {allPassed ? '✅ All tests passed!' : '⚠️ Some tests failed'}
          </div>
        </div>

        {/* Test Results */}
        <div className="space-y-4">
          <ResultCard title="1. Authentication" result={results.auth} />
          <ResultCard title="2. Read Profiles Table" result={results.profilesRead} />
          <ResultCard title="3. Get My Profile" result={results.myProfile} />
          <ResultCard title="4. Update Profile (Write Test)" result={results.profileWrite} />
          <ResultCard title="5. Database Triggers" result={results.triggers} />
          <ResultCard title="6. Total Profiles Count" result={results.profileCount} />
        </div>

        {/* Recommendations */}
        <div className="bg-blue-50 border-2 border-blue-500 rounded-lg p-6 mt-6">
          <h3 className="font-bold text-lg mb-2">🔍 What to check if tests fail:</h3>
          <ul className="space-y-2 text-sm">
            <li>✓ <strong>Auth fails:</strong> User not logged in - sign up or log in first</li>
            <li>✓ <strong>Read fails:</strong> Profiles table doesn't exist - run profiles_schema.sql</li>
            <li>✓ <strong>My Profile fails:</strong> Profile row doesn't exist - run handle_new_user trigger SQL</li>
            <li>✓ <strong>Write fails:</strong> RLS policy blocking - check Row Level Security policies</li>
            <li>✓ <strong>Count is 0:</strong> No profiles created yet - create a test account</li>
          </ul>
        </div>

        {/* Refresh Button */}
        <button
          onClick={() => {
            setIsLoading(true);
            runTests();
          }}
          className="mt-6 w-full bg-blue-600 text-white py-3 rounded-lg font-bold hover:bg-blue-700 transition-colors"
        >
          🔄 Re-run Tests
        </button>
      </div>
    </div>
  );
}
