import { createClient } from '@supabase/supabase-js';
import { ExtractedData } from '@/types/documents';

/**
 * Profile Learning Service
 *
 * Intelligently extracts insights from document data and updates user profile.
 * This allows Homey to learn about users and provide personalized experiences.
 */

export interface UserProfile {
  id: string;
  user_id: string;

  // Financial Profile
  monthly_income: number | null;
  max_budget: number | null;
  pre_approval_amount: number | null;
  loan_type: string | null;

  // Housing Preferences
  budget_min: number | null;
  budget_max: number | null;
  preferred_neighborhoods: string[] | null;
  min_bedrooms: number | null;
  min_bathrooms: number | null;
  pet_friendly: boolean | null;
  smoking_policy: string | null;
  move_in_date: string | null;

  // Current Lease Info
  current_lease_address: string | null;
  current_lease_end_date: string | null;
  current_monthly_rent: number | null;

  // AI-Derived Insights
  financial_capacity: 'low' | 'medium' | 'high' | null;
  urgency: 'low' | 'medium' | 'high' | null;
  ready_to_buy: boolean;

  // Metadata
  created_at: string;
  updated_at: string;
}

/**
 * Main function to update user profile from extracted document data
 */
export async function updateProfileFromDocument(
  userId: string,
  documentType: string,
  extractedData: ExtractedData
): Promise<void> {
  try {
    console.log(`[Profile Learning] Processing ${documentType} for user ${userId}`);

    // Create admin client for server-side operations
    const supabase = createClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
    );

    // Get current profile or create new one
    const { data: currentProfile } = await supabase
      .from('user_profiles')
      .select('*')
      .eq('user_id', userId)
      .single();

    // Extract insights based on document type
    const updates = extractInsights(documentType, extractedData, currentProfile);

    if (Object.keys(updates).length === 0) {
      console.log('[Profile Learning] No updates needed');
      return;
    }

    console.log('[Profile Learning] Applying updates:', updates);

    // Upsert profile
    const { error } = await supabase
      .from('user_profiles')
      .upsert({
        user_id: userId,
        ...updates,
      }, {
        onConflict: 'user_id',
      });

    if (error) {
      console.error('[Profile Learning] Error updating profile:', error);
      throw error;
    }

    console.log('[Profile Learning] Profile updated successfully');
  } catch (error) {
    console.error('[Profile Learning] Failed to update profile:', error);
    // Don't throw - profile learning is non-critical
  }
}

/**
 * Extract insights from document data
 */
function extractInsights(
  documentType: string,
  data: ExtractedData,
  currentProfile: UserProfile | null
): Partial<UserProfile> {
  const updates: Partial<UserProfile> = {};

  switch (documentType) {
    case 'lease':
      return extractLeaseInsights(data as any, currentProfile);

    case 'paystub':
      return extractPaystubInsights(data as any, currentProfile);

    case 'bank-statement':
      return extractBankStatementInsights(data as any, currentProfile);

    case 'pre-approval':
      return extractPreApprovalInsights(data as any, currentProfile);

    default:
      return {};
  }
}

/**
 * Extract insights from lease documents
 */
function extractLeaseInsights(
  data: any,
  currentProfile: UserProfile | null
): Partial<UserProfile> {
  const updates: Partial<UserProfile> = {};

  // Current lease info
  if (data.property?.address) {
    const fullAddress = [
      data.property.address,
      data.property.unit,
      data.property.city,
      data.property.state,
      data.property.zipCode
    ].filter(Boolean).join(', ');

    updates.current_lease_address = fullAddress;
  }

  if (data.terms?.leaseEndDate) {
    updates.current_lease_end_date = data.terms.leaseEndDate;

    // Calculate urgency based on lease end date
    const endDate = new Date(data.terms.leaseEndDate);
    const today = new Date();
    const daysUntilEnd = Math.floor((endDate.getTime() - today.getTime()) / (1000 * 60 * 60 * 24));

    if (daysUntilEnd < 60) {
      updates.urgency = 'high';
    } else if (daysUntilEnd < 120) {
      updates.urgency = 'medium';
    } else {
      updates.urgency = 'low';
    }
  }

  if (data.terms?.rentAmount) {
    updates.current_monthly_rent = data.terms.rentAmount;

    // Set budget based on current rent (typically 30% rule - can afford 3.33x rent as income)
    // Assume user wants similar or slightly higher budget
    const estimatedBudget = data.terms.rentAmount * 1.2; // 20% increase
    updates.budget_min = data.terms.rentAmount * 0.8; // 20% below current
    updates.budget_max = estimatedBudget;
  }

  // Pet policy
  if (data.policies?.petPolicy) {
    const petFriendly = !data.policies.petPolicy.toLowerCase().includes('no pets');
    updates.pet_friendly = petFriendly;
  }

  // Smoking policy
  if (data.policies?.smokingPolicy) {
    updates.smoking_policy = data.policies.smokingPolicy;
  }

  return updates;
}

/**
 * Extract insights from paystub documents
 */
function extractPaystubInsights(
  data: any,
  currentProfile: UserProfile | null
): Partial<UserProfile> {
  const updates: Partial<UserProfile> = {};

  if (data.earnings?.grossPay && data.payPeriod?.startDate && data.payPeriod?.endDate) {
    // Calculate monthly income from pay period
    const startDate = new Date(data.payPeriod.startDate);
    const endDate = new Date(data.payPeriod.endDate);
    const payPeriodDays = Math.floor((endDate.getTime() - startDate.getTime()) / (1000 * 60 * 60 * 24));

    let monthlyIncome = data.earnings.grossPay;

    // Convert to monthly
    if (payPeriodDays <= 7) {
      // Weekly
      monthlyIncome = data.earnings.grossPay * 4.33;
    } else if (payPeriodDays <= 16) {
      // Bi-weekly
      monthlyIncome = data.earnings.grossPay * 2;
    } else if (payPeriodDays <= 20) {
      // Semi-monthly
      monthlyIncome = data.earnings.grossPay * 2;
    }

    updates.monthly_income = Math.round(monthlyIncome);

    // Calculate max budget (30% of gross income rule)
    const maxAffordableRent = monthlyIncome * 0.3;
    updates.max_budget = Math.round(maxAffordableRent);

    // Determine financial capacity
    if (monthlyIncome >= 10000) {
      updates.financial_capacity = 'high';
    } else if (monthlyIncome >= 5000) {
      updates.financial_capacity = 'medium';
    } else {
      updates.financial_capacity = 'low';
    }
  }

  return updates;
}

/**
 * Extract insights from bank statement documents
 */
function extractBankStatementInsights(
  data: any,
  currentProfile: UserProfile | null
): Partial<UserProfile> {
  const updates: Partial<UserProfile> = {};

  if (data.balances?.closingBalance) {
    // Use average balance if available, otherwise closing balance
    const balance = data.balances.averageBalance || data.balances.closingBalance;

    // High balance = high financial capacity
    if (balance >= 50000) {
      updates.financial_capacity = 'high';
    } else if (balance >= 10000) {
      updates.financial_capacity = 'medium';
    } else {
      updates.financial_capacity = 'low';
    }
  }

  // If high number of deposits, might indicate stable income
  if (data.activity?.totalDeposits) {
    const monthlyDeposits = data.activity.totalDeposits;

    // Estimate monthly income from deposits (conservative estimate)
    if (!currentProfile?.monthly_income) {
      updates.monthly_income = Math.round(monthlyDeposits * 0.8);
    }
  }

  return updates;
}

/**
 * Extract insights from pre-approval documents
 */
function extractPreApprovalInsights(
  data: any,
  currentProfile: UserProfile | null
): Partial<UserProfile> {
  const updates: Partial<UserProfile> = {};

  if (data.approval?.amount) {
    updates.pre_approval_amount = data.approval.amount;
    updates.ready_to_buy = true;

    // Calculate max budget from pre-approval
    // Assuming 20% down payment and 30-year mortgage at 7% interest
    // Monthly payment = P * [r(1+r)^n] / [(1+r)^n - 1]
    const loanAmount = data.approval.amount;
    const monthlyRate = (data.approval.interestRate || 7) / 100 / 12;
    const numberOfPayments = (data.approval.term || 360);

    const monthlyPayment = loanAmount * (monthlyRate * Math.pow(1 + monthlyRate, numberOfPayments)) /
                          (Math.pow(1 + monthlyRate, numberOfPayments) - 1);

    updates.max_budget = Math.round(monthlyPayment);
  }

  if (data.approval?.loanType) {
    updates.loan_type = data.approval.loanType;
  }

  if (data.approval?.expirationDate) {
    // Check urgency based on pre-approval expiration
    const expirationDate = new Date(data.approval.expirationDate);
    const today = new Date();
    const daysUntilExpiration = Math.floor((expirationDate.getTime() - today.getTime()) / (1000 * 60 * 60 * 24));

    if (daysUntilExpiration < 30) {
      updates.urgency = 'high';
    } else if (daysUntilExpiration < 60) {
      updates.urgency = 'medium';
    }
  }

  return updates;
}

/**
 * Get user profile
 */
export async function getUserProfile(userId: string): Promise<UserProfile | null> {
  try {
    const supabase = createClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
    );

    const { data, error } = await supabase
      .from('user_profiles')
      .select('*')
      .eq('user_id', userId)
      .single();

    if (error) {
      if (error.code === 'PGRST116') {
        // No profile found
        return null;
      }
      throw error;
    }

    return data;
  } catch (error) {
    console.error('[Profile Learning] Error fetching profile:', error);
    return null;
  }
}
