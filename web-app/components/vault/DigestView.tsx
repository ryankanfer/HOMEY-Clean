'use client';

import { motion } from 'framer-motion';
import { DollarSign, Calendar, Shield, User, Phone, Mail, FileText, CheckCircle } from 'lucide-react';
import { PreApprovalData, InsuranceData, GenericData } from '@/types/documents';

interface DigestViewProps {
  data: PreApprovalData | InsuranceData | GenericData;
  onViewOriginal?: () => void;
}

export default function DigestView({ data, onViewOriginal }: DigestViewProps) {
  if (data.type === 'pre-approval') {
    return <PreApprovalDigestView data={data} onViewOriginal={onViewOriginal} />;
  } else if (data.type === 'insurance') {
    return <InsuranceDigestView data={data} onViewOriginal={onViewOriginal} />;
  } else if (data.type === 'other') {
    return <GenericDigestView data={data} onViewOriginal={onViewOriginal} />;
  }

  return null;
}

// Pre-Approval Digest View
function PreApprovalDigestView({ data, onViewOriginal }: { data: PreApprovalData; onViewOriginal?: () => void }) {
  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 0,
    }).format(amount);
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      month: 'long',
      day: 'numeric',
      year: 'numeric',
    });
  };

  const isExpiringSoon = (expirationDate: string) => {
    const expDate = new Date(expirationDate);
    const today = new Date();
    const daysUntilExpiration = Math.floor((expDate.getTime() - today.getTime()) / (1000 * 60 * 60 * 24));
    return daysUntilExpiration <= 30; // Within 30 days
  };

  return (
    <div className="space-y-6">
      {/* Header Section */}
      <div className="flex items-start justify-between">
        <div>
          <h2 className="text-2xl font-bold text-white mb-2">Pre-Approval Letter</h2>
          <p className="text-white/60">{data.borrower.name}</p>
        </div>
        {onViewOriginal && (
          <button
            onClick={onViewOriginal}
            className="px-4 py-2 bg-white/5 hover:bg-white/10 border border-white/10 rounded-lg text-white text-sm transition-colors"
          >
            View Original
          </button>
        )}
      </div>

      {/* Hero Card - Approval Amount */}
      <motion.div
        className="relative overflow-hidden p-8 bg-gradient-to-br from-green-500/20 to-blue-500/20 border border-white/20 rounded-2xl"
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ duration: 0.5 }}
      >
        <div className="relative z-10">
          <div className="flex items-center gap-3 mb-4">
            <div className="p-3 bg-green-500/20 rounded-xl">
              <CheckCircle className="w-8 h-8 text-green-400" />
            </div>
            <div>
              <p className="text-white/60 text-sm">You're Pre-Approved For</p>
              <h3 className="text-4xl font-bold text-white">{formatCurrency(data.approval.amount)}</h3>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4 mt-6">
            <div>
              <p className="text-white/50 text-xs uppercase tracking-wider mb-1">Loan Type</p>
              <p className="text-white font-medium">{data.approval.loanType}</p>
            </div>
            {data.approval.interestRate && (
              <div>
                <p className="text-white/50 text-xs uppercase tracking-wider mb-1">Interest Rate</p>
                <p className="text-white font-medium">{data.approval.interestRate}% APR</p>
              </div>
            )}
            {data.approval.term && (
              <div>
                <p className="text-white/50 text-xs uppercase tracking-wider mb-1">Term</p>
                <p className="text-white font-medium">{data.approval.term / 12} years</p>
              </div>
            )}
            <div>
              <p className="text-white/50 text-xs uppercase tracking-wider mb-1">Expires</p>
              <p
                className={`font-medium ${
                  isExpiringSoon(data.approval.expirationDate) ? 'text-orange-400' : 'text-white'
                }`}
              >
                {formatDate(data.approval.expirationDate)}
              </p>
            </div>
          </div>
        </div>

        {/* Background decoration */}
        <div className="absolute top-0 right-0 w-64 h-64 bg-gradient-to-br from-green-500/10 to-transparent rounded-full blur-3xl" />
      </motion.div>

      {/* Lender Information */}
      <div className="p-6 bg-white/5 border border-white/10 rounded-xl">
        <h3 className="text-sm font-semibold text-white/40 uppercase tracking-wider mb-4">Lender Information</h3>
        <div className="space-y-3">
          <InfoRow icon={<User className="w-4 h-4" />} label="Lender" value={data.lender.name} />
          {data.lender.loanOfficer && (
            <InfoRow icon={<User className="w-4 h-4" />} label="Loan Officer" value={data.lender.loanOfficer} />
          )}
          {data.lender.phone && <InfoRow icon={<Phone className="w-4 h-4" />} label="Phone" value={data.lender.phone} />}
          {data.lender.email && <InfoRow icon={<Mail className="w-4 h-4" />} label="Email" value={data.lender.email} />}
        </div>
      </div>

      {/* Conditions */}
      {data.conditions && data.conditions.length > 0 && (
        <div className="p-6 bg-orange-500/10 border border-orange-500/20 rounded-xl">
          <h3 className="text-sm font-semibold text-orange-300 uppercase tracking-wider mb-4 flex items-center gap-2">
            <FileText className="w-4 h-4" />
            Conditions
          </h3>
          <ul className="space-y-2">
            {data.conditions.map((condition, index) => (
              <li key={index} className="text-white/80 text-sm flex items-start gap-2">
                <span className="text-orange-400 mt-1">•</span>
                <span>{condition}</span>
              </li>
            ))}
          </ul>
        </div>
      )}

      {/* Summary */}
      {data.summary && (
        <div className="p-6 bg-white/5 border border-white/10 rounded-xl">
          <h3 className="text-sm font-semibold text-white/40 uppercase tracking-wider mb-3">Summary</h3>
          <p className="text-white/80 text-sm leading-relaxed">{data.summary}</p>
        </div>
      )}
    </div>
  );
}

// Insurance Digest View
function InsuranceDigestView({ data, onViewOriginal }: { data: InsuranceData; onViewOriginal?: () => void }) {
  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 0,
    }).format(amount);
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      month: 'long',
      day: 'numeric',
      year: 'numeric',
    });
  };

  const getFrequencyLabel = (freq: string) => {
    switch (freq) {
      case 'monthly':
        return '/month';
      case 'quarterly':
        return '/quarter';
      case 'annually':
        return '/year';
      default:
        return '';
    }
  };

  return (
    <div className="space-y-6">
      {/* Header Section */}
      <div className="flex items-start justify-between">
        <div>
          <h2 className="text-2xl font-bold text-white mb-2">{data.policy.type} Insurance</h2>
          <p className="text-white/60">{data.policy.provider}</p>
        </div>
        {onViewOriginal && (
          <button
            onClick={onViewOriginal}
            className="px-4 py-2 bg-white/5 hover:bg-white/10 border border-white/10 rounded-lg text-white text-sm transition-colors"
          >
            View Original
          </button>
        )}
      </div>

      {/* Policy Card */}
      <motion.div
        className="relative overflow-hidden p-8 bg-gradient-to-br from-blue-500/20 to-purple-500/20 border border-white/20 rounded-2xl"
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ duration: 0.5 }}
      >
        <div className="relative z-10">
          <div className="flex items-center gap-3 mb-6">
            <div className="p-3 bg-blue-500/20 rounded-xl">
              <Shield className="w-8 h-8 text-blue-400" />
            </div>
            <div>
              <p className="text-white/60 text-sm">Policy Number</p>
              <p className="text-xl font-mono font-bold text-white">{data.policy.policyNumber}</p>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <p className="text-white/50 text-xs uppercase tracking-wider mb-1">Effective Date</p>
              <p className="text-white font-medium">{formatDate(data.policy.effectiveDate)}</p>
            </div>
            <div>
              <p className="text-white/50 text-xs uppercase tracking-wider mb-1">Expiration Date</p>
              <p className="text-white font-medium">{formatDate(data.policy.expirationDate)}</p>
            </div>
          </div>
        </div>

        {/* Background decoration */}
        <div className="absolute top-0 right-0 w-64 h-64 bg-gradient-to-br from-blue-500/10 to-transparent rounded-full blur-3xl" />
      </motion.div>

      {/* Premium */}
      <div className="p-6 bg-green-500/10 border border-green-500/20 rounded-xl">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-white/60 text-sm mb-1">Premium</p>
            <p className="text-3xl font-bold text-green-400">
              {formatCurrency(data.premium.amount)}
              <span className="text-lg text-white/60">{getFrequencyLabel(data.premium.frequency)}</span>
            </p>
          </div>
          <button className="px-4 py-2 bg-green-500/20 hover:bg-green-500/30 border border-green-500/40 rounded-lg text-green-300 text-sm font-medium transition-colors">
            Set up Auto-Pay →
          </button>
        </div>
      </div>

      {/* Coverage Details */}
      <div className="p-6 bg-white/5 border border-white/10 rounded-xl">
        <h3 className="text-sm font-semibold text-white/40 uppercase tracking-wider mb-4">Coverage</h3>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <CoverageItem label="Personal Property" amount={data.coverage.personalProperty} />
          <CoverageItem label="Liability" amount={data.coverage.liability} />
          {data.coverage.medicalPayments && (
            <CoverageItem label="Medical Payments" amount={data.coverage.medicalPayments} />
          )}
          {data.coverage.lossOfUse && <CoverageItem label="Loss of Use" amount={data.coverage.lossOfUse} />}
          <div className="p-4 bg-white/5 border border-white/10 rounded-lg">
            <p className="text-white/60 text-sm mb-1">Deductible</p>
            <p className="text-white font-semibold">{formatCurrency(data.coverage.deductible)}</p>
          </div>
        </div>
      </div>

      {/* Insured Information */}
      <div className="p-6 bg-white/5 border border-white/10 rounded-xl">
        <h3 className="text-sm font-semibold text-white/40 uppercase tracking-wider mb-4">Insured</h3>
        <div className="space-y-3">
          <InfoRow icon={<User className="w-4 h-4" />} label="Name" value={data.insured.name} />
          <InfoRow icon={<Shield className="w-4 h-4" />} label="Address" value={data.insured.address} />
        </div>
      </div>

      {/* Summary */}
      {data.summary && (
        <div className="p-6 bg-white/5 border border-white/10 rounded-xl">
          <h3 className="text-sm font-semibold text-white/40 uppercase tracking-wider mb-3">Summary</h3>
          <p className="text-white/80 text-sm leading-relaxed">{data.summary}</p>
        </div>
      )}
    </div>
  );
}

// Generic Digest View
function GenericDigestView({ data, onViewOriginal }: { data: GenericData; onViewOriginal?: () => void }) {
  return (
    <div className="space-y-6">
      {/* Header Section */}
      <div className="flex items-start justify-between">
        <div>
          <h2 className="text-2xl font-bold text-white mb-2">Document</h2>
        </div>
        {onViewOriginal && (
          <button
            onClick={onViewOriginal}
            className="px-4 py-2 bg-white/5 hover:bg-white/10 border border-white/10 rounded-lg text-white text-sm transition-colors"
          >
            View Original
          </button>
        )}
      </div>

      {/* Summary Card */}
      <div className="p-6 bg-white/5 border border-white/10 rounded-xl">
        <h3 className="text-sm font-semibold text-white/40 uppercase tracking-wider mb-4">Summary</h3>
        <p className="text-white/80 text-base leading-relaxed whitespace-pre-wrap">{data.summary}</p>
      </div>

      {/* Key Points */}
      {data.keyPoints && data.keyPoints.length > 0 && (
        <div className="p-6 bg-blue-500/10 border border-blue-500/20 rounded-xl">
          <h3 className="text-sm font-semibold text-blue-300 uppercase tracking-wider mb-4">Key Points</h3>
          <ul className="space-y-3">
            {data.keyPoints.map((point, index) => (
              <li key={index} className="text-white/80 text-sm flex items-start gap-3">
                <span className="text-blue-400 mt-1">→</span>
                <span>{point}</span>
              </li>
            ))}
          </ul>
        </div>
      )}
    </div>
  );
}

// Helper Components
function InfoRow({ icon, label, value }: { icon: React.ReactNode; label: string; value: string }) {
  return (
    <div className="flex items-center gap-3">
      <div className="text-white/60">{icon}</div>
      <div className="flex-1 min-w-0">
        <p className="text-white/50 text-xs">{label}</p>
        <p className="text-white text-sm truncate">{value}</p>
      </div>
    </div>
  );
}

function CoverageItem({ label, amount }: { label: string; amount: number }) {
  const formatCurrency = (amt: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 0,
    }).format(amt);
  };

  return (
    <div className="p-4 bg-white/5 border border-white/10 rounded-lg">
      <p className="text-white/60 text-sm mb-1">{label}</p>
      <p className="text-white font-semibold">{formatCurrency(amount)}</p>
    </div>
  );
}
