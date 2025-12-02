'use client';

import { motion } from 'framer-motion';
import { Calendar, DollarSign, MapPin, User, AlertCircle, Home, Zap, Wrench } from 'lucide-react';
import { LeaseData, PaystubData, BankStatementData } from '@/types/documents';

interface ExecutiveViewProps {
  data: LeaseData | PaystubData | BankStatementData;
  onViewOriginal?: () => void;
}

export default function ExecutiveView({ data, onViewOriginal }: ExecutiveViewProps) {
  if (data.type === 'lease') {
    return <LeaseExecutiveView data={data} onViewOriginal={onViewOriginal} />;
  } else if (data.type === 'paystub') {
    return <PaystubExecutiveView data={data} onViewOriginal={onViewOriginal} />;
  } else if (data.type === 'bank-statement') {
    return <BankStatementExecutiveView data={data} onViewOriginal={onViewOriginal} />;
  }

  return null;
}

// Lease Executive View
function LeaseExecutiveView({ data, onViewOriginal }: { data: LeaseData; onViewOriginal?: () => void }) {
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

  const addToCalendar = (date: string, title: string) => {
    // Simple ICS format
    const startDate = new Date(date);
    const endDate = new Date(startDate);
    endDate.setHours(startDate.getHours() + 1);

    const icsContent = `BEGIN:VCALENDAR
VERSION:2.0
BEGIN:VEVENT
DTSTART:${startDate.toISOString().replace(/[-:]/g, '').split('.')[0]}Z
DTEND:${endDate.toISOString().replace(/[-:]/g, '').split('.')[0]}Z
SUMMARY:${title}
DESCRIPTION:Lease event for ${data.property.address}
END:VEVENT
END:VCALENDAR`;

    const blob = new Blob([icsContent], { type: 'text/calendar' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = `${title.replace(/\s+/g, '-').toLowerCase()}.ics`;
    link.click();
    URL.revokeObjectURL(url);
  };

  return (
    <div className="space-y-6">
      {/* Header Section */}
      <div className="flex items-start justify-between">
        <div>
          <h2 className="text-2xl font-bold text-white mb-2">Lease Agreement</h2>
          <div className="flex items-center gap-2 text-white/60">
            <MapPin className="w-4 h-4" />
            <span>
              {data.property.address}
              {data.property.unit && `, Unit ${data.property.unit}`}
            </span>
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

      {/* Financial Terms */}
      <section>
        <h3 className="text-sm font-semibold text-white/40 uppercase tracking-wider mb-4">Financial Terms</h3>
        <div className="space-y-3">
          <ExecutiveItem
            icon={<DollarSign className="w-5 h-5 text-green-400" />}
            label="Monthly Rent"
            value={formatCurrency(data.terms.rentAmount)}
            action={
              <button className="text-green-400 hover:text-green-300 text-sm font-medium transition-colors">
                Set up Auto-Pay →
              </button>
            }
          />
          <ExecutiveItem
            icon={<DollarSign className="w-5 h-5 text-blue-400" />}
            label="Security Deposit"
            value={formatCurrency(data.terms.securityDeposit)}
          />
          {data.fees.lateFee && (
            <ExecutiveItem
              icon={<AlertCircle className="w-5 h-5 text-red-400" />}
              label="Late Fee"
              value={data.fees.lateFee}
            />
          )}
          {data.fees.parkingFee && (
            <ExecutiveItem
              icon={<DollarSign className="w-5 h-5 text-purple-400" />}
              label="Parking Fee"
              value={formatCurrency(data.fees.parkingFee)}
            />
          )}
          {data.fees.petFee && (
            <ExecutiveItem
              icon={<DollarSign className="w-5 h-5 text-orange-400" />}
              label="Pet Fee"
              value={formatCurrency(data.fees.petFee)}
            />
          )}
        </div>
      </section>

      {/* Important Dates */}
      <section>
        <h3 className="text-sm font-semibold text-white/40 uppercase tracking-wider mb-4">Important Dates</h3>
        <div className="space-y-3">
          <ExecutiveItem
            icon={<Calendar className="w-5 h-5 text-blue-400" />}
            label="Move-in Date"
            value={formatDate(data.terms.moveInDate)}
            action={
              <button
                onClick={() => addToCalendar(data.terms.moveInDate, 'Move-in Day')}
                className="text-blue-400 hover:text-blue-300 text-sm font-medium transition-colors"
              >
                Add to Calendar →
              </button>
            }
          />
          <ExecutiveItem
            icon={<Calendar className="w-5 h-5 text-green-400" />}
            label="Lease Start"
            value={formatDate(data.terms.leaseStartDate)}
          />
          <ExecutiveItem
            icon={<Calendar className="w-5 h-5 text-orange-400" />}
            label="Lease End"
            value={formatDate(data.terms.leaseEndDate)}
            action={
              <button
                onClick={() => addToCalendar(data.terms.leaseEndDate, 'Lease End Date')}
                className="text-orange-400 hover:text-orange-300 text-sm font-medium transition-colors"
              >
                Add to Calendar →
              </button>
            }
          />
          <ExecutiveItem
            icon={<Calendar className="w-5 h-5 text-white/60" />}
            label="Lease Duration"
            value={data.terms.leaseDuration}
          />
        </div>
      </section>

      {/* Policies */}
      <section>
        <h3 className="text-sm font-semibold text-white/40 uppercase tracking-wider mb-4">Policies</h3>
        <div className="space-y-3">
          <ExecutiveItem
            icon={<Home className="w-5 h-5 text-purple-400" />}
            label="Pet Policy"
            value={data.policies.petPolicy}
          />
          <ExecutiveItem
            icon={<AlertCircle className="w-5 h-5 text-yellow-400" />}
            label="Smoking Policy"
            value={data.policies.smokingPolicy}
          />
          {data.policies.guestPolicy && (
            <ExecutiveItem
              icon={<User className="w-5 h-5 text-blue-400" />}
              label="Guest Policy"
              value={data.policies.guestPolicy}
            />
          )}
        </div>
      </section>

      {/* Utilities */}
      <section>
        <h3 className="text-sm font-semibold text-white/40 uppercase tracking-wider mb-4">Utilities</h3>
        <div className="space-y-3">
          {data.utilities.included.length > 0 && (
            <ExecutiveItem
              icon={<Zap className="w-5 h-5 text-green-400" />}
              label="Included in Rent"
              value={data.utilities.included.join(', ')}
            />
          )}
          {data.utilities.tenantResponsible.length > 0 && (
            <ExecutiveItem
              icon={<Zap className="w-5 h-5 text-orange-400" />}
              label="Tenant Responsible"
              value={data.utilities.tenantResponsible.join(', ')}
            />
          )}
        </div>
      </section>

      {/* Maintenance */}
      {data.maintenance.emergencyContact && (
        <section>
          <h3 className="text-sm font-semibold text-white/40 uppercase tracking-wider mb-4">Maintenance</h3>
          <div className="space-y-3">
            <ExecutiveItem
              icon={<Wrench className="w-5 h-5 text-red-400" />}
              label="Emergency Contact"
              value={data.maintenance.emergencyContact}
            />
          </div>
        </section>
      )}

      {/* Summary */}
      {data.summary && (
        <div className="p-4 bg-white/5 border border-white/10 rounded-xl">
          <p className="text-white/80 text-sm leading-relaxed">{data.summary}</p>
        </div>
      )}
    </div>
  );
}

// Paystub Executive View
function PaystubExecutiveView({ data, onViewOriginal }: { data: PaystubData; onViewOriginal?: () => void }) {
  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
    }).format(amount);
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      month: 'short',
      day: 'numeric',
      year: 'numeric',
    });
  };

  return (
    <div className="space-y-6">
      <div className="flex items-start justify-between">
        <div>
          <h2 className="text-2xl font-bold text-white mb-2">Pay Stub</h2>
          <p className="text-white/60">{data.employer.name}</p>
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

      <section>
        <h3 className="text-sm font-semibold text-white/40 uppercase tracking-wider mb-4">Pay Period</h3>
        <div className="space-y-3">
          <ExecutiveItem
            icon={<Calendar className="w-5 h-5 text-blue-400" />}
            label="Period"
            value={`${formatDate(data.payPeriod.startDate)} - ${formatDate(data.payPeriod.endDate)}`}
          />
          <ExecutiveItem
            icon={<Calendar className="w-5 h-5 text-green-400" />}
            label="Pay Date"
            value={formatDate(data.payPeriod.payDate)}
          />
        </div>
      </section>

      <section>
        <h3 className="text-sm font-semibold text-white/40 uppercase tracking-wider mb-4">Earnings</h3>
        <div className="space-y-3">
          <ExecutiveItem
            icon={<DollarSign className="w-5 h-5 text-green-400" />}
            label="Gross Pay"
            value={formatCurrency(data.earnings.grossPay)}
          />
          <ExecutiveItem
            icon={<DollarSign className="w-5 h-5 text-blue-400" />}
            label="Net Pay"
            value={formatCurrency(data.earnings.netPay)}
          />
          {data.earnings.yearToDateGross && (
            <ExecutiveItem
              icon={<DollarSign className="w-5 h-5 text-purple-400" />}
              label="YTD Gross"
              value={formatCurrency(data.earnings.yearToDateGross)}
            />
          )}
        </div>
      </section>

      {data.deductions && data.deductions.length > 0 && (
        <section>
          <h3 className="text-sm font-semibold text-white/40 uppercase tracking-wider mb-4">Deductions</h3>
          <div className="space-y-3">
            {data.deductions.map((deduction, index) => (
              <ExecutiveItem
                key={index}
                icon={<DollarSign className="w-5 h-5 text-orange-400" />}
                label={deduction.type}
                value={formatCurrency(deduction.amount)}
              />
            ))}
          </div>
        </section>
      )}
    </div>
  );
}

// Bank Statement Executive View
function BankStatementExecutiveView({
  data,
  onViewOriginal,
}: {
  data: BankStatementData;
  onViewOriginal?: () => void;
}) {
  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
    }).format(amount);
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      month: 'short',
      day: 'numeric',
      year: 'numeric',
    });
  };

  return (
    <div className="space-y-6">
      <div className="flex items-start justify-between">
        <div>
          <h2 className="text-2xl font-bold text-white mb-2">Bank Statement</h2>
          <p className="text-white/60">
            {data.account.bankName} - {data.account.accountType}
          </p>
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

      <section>
        <h3 className="text-sm font-semibold text-white/40 uppercase tracking-wider mb-4">Statement Period</h3>
        <div className="space-y-3">
          <ExecutiveItem
            icon={<Calendar className="w-5 h-5 text-blue-400" />}
            label="Period"
            value={`${formatDate(data.period.startDate)} - ${formatDate(data.period.endDate)}`}
          />
        </div>
      </section>

      <section>
        <h3 className="text-sm font-semibold text-white/40 uppercase tracking-wider mb-4">Balances</h3>
        <div className="space-y-3">
          <ExecutiveItem
            icon={<DollarSign className="w-5 h-5 text-blue-400" />}
            label="Opening Balance"
            value={formatCurrency(data.balances.openingBalance)}
          />
          <ExecutiveItem
            icon={<DollarSign className="w-5 h-5 text-green-400" />}
            label="Closing Balance"
            value={formatCurrency(data.balances.closingBalance)}
          />
          {data.balances.averageBalance && (
            <ExecutiveItem
              icon={<DollarSign className="w-5 h-5 text-purple-400" />}
              label="Average Balance"
              value={formatCurrency(data.balances.averageBalance)}
            />
          )}
        </div>
      </section>

      <section>
        <h3 className="text-sm font-semibold text-white/40 uppercase tracking-wider mb-4">Activity</h3>
        <div className="space-y-3">
          <ExecutiveItem
            icon={<DollarSign className="w-5 h-5 text-green-400" />}
            label="Total Deposits"
            value={formatCurrency(data.activity.totalDeposits)}
          />
          <ExecutiveItem
            icon={<DollarSign className="w-5 h-5 text-red-400" />}
            label="Total Withdrawals"
            value={formatCurrency(data.activity.totalWithdrawals)}
          />
          <ExecutiveItem
            icon={<AlertCircle className="w-5 h-5 text-white/60" />}
            label="Transactions"
            value={`${data.activity.numberOfTransactions} total`}
          />
        </div>
      </section>
    </div>
  );
}

// Reusable Executive Item Component
function ExecutiveItem({
  icon,
  label,
  value,
  action,
}: {
  icon: React.ReactNode;
  label: string;
  value: string;
  action?: React.ReactNode;
}) {
  return (
    <motion.div
      className="flex items-center justify-between p-4 bg-white/5 hover:bg-white/[0.07] border border-white/10 rounded-xl transition-colors group"
      whileHover={{ scale: 1.01 }}
      transition={{ duration: 0.2 }}
    >
      <div className="flex items-center gap-4 flex-1 min-w-0">
        <div className="shrink-0">{icon}</div>
        <div className="flex-1 min-w-0">
          <p className="text-white/50 text-sm mb-1">{label}</p>
          <p className="text-white font-medium truncate">{value}</p>
        </div>
      </div>
      {action && <div className="ml-4 shrink-0">{action}</div>}
    </motion.div>
  );
}
