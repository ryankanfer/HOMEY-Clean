'use client';

import { motion } from 'framer-motion';
import { CheckCircle, XCircle, AlertTriangle, Calendar, User, MapPin, DollarSign } from 'lucide-react';
import { InspectionData, IdentificationData } from '@/types/documents';

interface CardViewProps {
  data: InspectionData | IdentificationData;
  onViewOriginal?: () => void;
}

export default function CardView({ data, onViewOriginal }: CardViewProps) {
  if (data.type === 'inspection') {
    return <InspectionCardView data={data} onViewOriginal={onViewOriginal} />;
  } else if (data.type === 'identification') {
    return <IdentificationCardView data={data} onViewOriginal={onViewOriginal} />;
  }

  return null;
}

// Inspection Card View
function InspectionCardView({ data, onViewOriginal }: { data: InspectionData; onViewOriginal?: () => void }) {
  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 0,
    }).format(amount);
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      month: 'short',
      day: 'numeric',
      year: 'numeric',
    });
  };

  const getStatusColor = (status: 'pass' | 'fail' | 'needs_repair' | 'monitor') => {
    switch (status) {
      case 'pass':
        return 'bg-green-500/20 text-green-300 border-green-500/30';
      case 'fail':
        return 'bg-red-500/20 text-red-300 border-red-500/30';
      case 'needs_repair':
        return 'bg-orange-500/20 text-orange-300 border-orange-500/30';
      case 'monitor':
        return 'bg-yellow-500/20 text-yellow-300 border-yellow-500/30';
      default:
        return 'bg-white/10 text-white/60 border-white/20';
    }
  };

  const getConditionColor = (condition: string) => {
    switch (condition) {
      case 'excellent':
        return 'text-green-400';
      case 'good':
        return 'text-blue-400';
      case 'fair':
        return 'text-yellow-400';
      case 'poor':
        return 'text-red-400';
      default:
        return 'text-white/60';
    }
  };

  const getPassFailBadge = (status: string) => {
    if (status === 'pass') {
      return <span className="px-3 py-1 bg-green-500/20 text-green-300 border border-green-500/30 rounded-full text-xs font-bold">PASS</span>;
    } else if (status === 'fail') {
      return <span className="px-3 py-1 bg-red-500/20 text-red-300 border border-red-500/30 rounded-full text-xs font-bold">FAIL</span>;
    } else {
      return <span className="px-3 py-1 bg-yellow-500/20 text-yellow-300 border border-yellow-500/30 rounded-full text-xs font-bold">CONDITIONAL</span>;
    }
  };

  return (
    <div className="space-y-6">
      {/* Header Section */}
      <div className="flex items-start justify-between">
        <div>
          <h2 className="text-2xl font-bold text-white mb-2">Inspection Report</h2>
          <div className="flex items-center gap-2 text-white/60">
            <MapPin className="w-4 h-4" />
            <span>{data.property.address}</span>
          </div>
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

      {/* Summary Stats */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <StatCard
          label="Overall"
          value={data.summary.overallCondition}
          className={getConditionColor(data.summary.overallCondition)}
        />
        <StatCard label="Major Issues" value={data.summary.majorIssues} className="text-red-400" />
        <StatCard label="Minor Issues" value={data.summary.minorIssues} className="text-yellow-400" />
        <StatCard label="Est. Repairs" value={formatCurrency(data.estimatedTotalRepairs)} className="text-blue-400" />
      </div>

      {/* Pass/Fail Status */}
      <div className="p-4 bg-white/5 border border-white/10 rounded-xl flex items-center justify-between">
        <div>
          <p className="text-white/60 text-sm mb-1">Inspection Result</p>
          <p className="text-white font-medium">
            Inspected by {data.inspection.inspector} on {formatDate(data.inspection.date)}
          </p>
        </div>
        {getPassFailBadge(data.summary.passFailStatus)}
      </div>

      {/* Categories Grid */}
      <div>
        <h3 className="text-sm font-semibold text-white/40 uppercase tracking-wider mb-4">Categories</h3>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {data.categories.map((category, index) => (
            <motion.div
              key={index}
              className="p-4 bg-white/5 border border-white/10 rounded-xl hover:bg-white/[0.07] transition-colors"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: index * 0.05 }}
            >
              {/* Category Header */}
              <div className="flex items-start justify-between mb-3">
                <div className="flex items-center gap-2">
                  {category.status === 'pass' && <CheckCircle className="w-5 h-5 text-green-400 shrink-0" />}
                  {category.status === 'fail' && <XCircle className="w-5 h-5 text-red-400 shrink-0" />}
                  {(category.status === 'needs_repair' || category.status === 'monitor') && (
                    <AlertTriangle className="w-5 h-5 text-orange-400 shrink-0" />
                  )}
                  <h4 className="font-semibold text-white">{category.name}</h4>
                </div>
                <span
                  className={`px-2 py-0.5 rounded-full text-xs font-medium border ${getStatusColor(category.status)}`}
                >
                  {category.status.replace('_', ' ').toUpperCase()}
                </span>
              </div>

              {/* Issues */}
              {category.issues && category.issues.length > 0 && (
                <ul className="space-y-1 mb-3">
                  {category.issues.map((issue, idx) => (
                    <li key={idx} className="text-white/60 text-sm flex items-start gap-2">
                      <span className="text-white/40 mt-1">•</span>
                      <span>{issue}</span>
                    </li>
                  ))}
                </ul>
              )}

              {/* Repair Cost */}
              {category.estimatedRepairCost && (
                <div className="pt-3 border-t border-white/10">
                  <div className="flex items-center gap-2 text-blue-400">
                    <DollarSign className="w-4 h-4" />
                    <span className="text-sm font-medium">{formatCurrency(category.estimatedRepairCost)} est.</span>
                  </div>
                </div>
              )}
            </motion.div>
          ))}
        </div>
      </div>

      {/* Recommendations */}
      {data.recommendations.length > 0 && (
        <div>
          <h3 className="text-sm font-semibold text-white/40 uppercase tracking-wider mb-4">Recommendations</h3>
          <div className="p-4 bg-blue-500/10 border border-blue-500/20 rounded-xl">
            <ul className="space-y-2">
              {data.recommendations.map((rec, index) => (
                <li key={index} className="text-white/80 text-sm flex items-start gap-2">
                  <span className="text-blue-400 mt-1">→</span>
                  <span>{rec}</span>
                </li>
              ))}
            </ul>
          </div>
        </div>
      )}

      {/* Notes */}
      {data.notes && (
        <div className="p-4 bg-white/5 border border-white/10 rounded-xl">
          <p className="text-white/80 text-sm leading-relaxed">{data.notes}</p>
        </div>
      )}
    </div>
  );
}

// Identification Card View
function IdentificationCardView({
  data,
  onViewOriginal,
}: {
  data: IdentificationData;
  onViewOriginal?: () => void;
}) {
  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      month: 'short',
      day: 'numeric',
      year: 'numeric',
    });
  };

  const getDocumentTypeLabel = (type: string) => {
    switch (type) {
      case 'drivers-license':
        return "Driver's License";
      case 'passport':
        return 'Passport';
      case 'state-id':
        return 'State ID';
      default:
        return type;
    }
  };

  const isExpiringSoon = (expirationDate: string) => {
    const expDate = new Date(expirationDate);
    const today = new Date();
    const daysUntilExpiration = Math.floor((expDate.getTime() - today.getTime()) / (1000 * 60 * 60 * 24));
    return daysUntilExpiration <= 90; // Within 90 days
  };

  return (
    <div className="space-y-6">
      {/* Header Section */}
      <div className="flex items-start justify-between">
        <div>
          <h2 className="text-2xl font-bold text-white mb-2">{getDocumentTypeLabel(data.document.type)}</h2>
          <p className="text-white/60">{data.person.fullName}</p>
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

      {/* ID Card Display */}
      <div className="relative p-6 bg-gradient-to-br from-blue-500/20 to-purple-500/20 border border-white/20 rounded-2xl">
        {/* Expiration Warning */}
        {isExpiringSoon(data.document.expirationDate) && (
          <div className="absolute top-4 right-4">
            <span className="px-3 py-1 bg-orange-500/20 text-orange-300 border border-orange-500/30 rounded-full text-xs font-bold flex items-center gap-1">
              <AlertTriangle className="w-3 h-3" />
              EXPIRING SOON
            </span>
          </div>
        )}

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {/* Personal Info */}
          <div className="space-y-4">
            <div>
              <p className="text-white/50 text-xs uppercase tracking-wider mb-1">Full Name</p>
              <p className="text-white font-semibold text-lg">{data.person.fullName}</p>
            </div>
            <div>
              <p className="text-white/50 text-xs uppercase tracking-wider mb-1">Date of Birth</p>
              <p className="text-white font-medium">{formatDate(data.person.dateOfBirth)}</p>
            </div>
            {data.person.address && (
              <div>
                <p className="text-white/50 text-xs uppercase tracking-wider mb-1">Address</p>
                <p className="text-white/80 text-sm">{data.person.address}</p>
              </div>
            )}
          </div>

          {/* Document Info */}
          <div className="space-y-4">
            <div>
              <p className="text-white/50 text-xs uppercase tracking-wider mb-1">Document Number</p>
              <p className="text-white font-mono">{data.document.number}</p>
            </div>
            {data.document.issuingState && (
              <div>
                <p className="text-white/50 text-xs uppercase tracking-wider mb-1">Issuing State</p>
                <p className="text-white font-medium">{data.document.issuingState}</p>
              </div>
            )}
            {data.document.issuingCountry && (
              <div>
                <p className="text-white/50 text-xs uppercase tracking-wider mb-1">Issuing Country</p>
                <p className="text-white font-medium">{data.document.issuingCountry}</p>
              </div>
            )}
          </div>
        </div>

        {/* Dates */}
        <div className="mt-6 pt-6 border-t border-white/20 grid grid-cols-2 gap-4">
          <div>
            <p className="text-white/50 text-xs uppercase tracking-wider mb-1 flex items-center gap-1">
              <Calendar className="w-3 h-3" />
              Issue Date
            </p>
            <p className="text-white font-medium">{formatDate(data.document.issueDate)}</p>
          </div>
          <div>
            <p className="text-white/50 text-xs uppercase tracking-wider mb-1 flex items-center gap-1">
              <Calendar className="w-3 h-3" />
              Expiration Date
            </p>
            <p className={`font-medium ${isExpiringSoon(data.document.expirationDate) ? 'text-orange-400' : 'text-white'}`}>
              {formatDate(data.document.expirationDate)}
            </p>
          </div>
        </div>
      </div>

      {/* Summary */}
      {data.summary && (
        <div className="p-4 bg-white/5 border border-white/10 rounded-xl">
          <p className="text-white/80 text-sm leading-relaxed">{data.summary}</p>
        </div>
      )}
    </div>
  );
}

// Stat Card Component
function StatCard({ label, value, className }: { label: string; value: string | number; className?: string }) {
  return (
    <div className="p-4 bg-white/5 border border-white/10 rounded-xl">
      <p className="text-white/50 text-xs uppercase tracking-wider mb-2">{label}</p>
      <p className={`text-2xl font-bold ${className || 'text-white'} capitalize`}>{value}</p>
    </div>
  );
}
