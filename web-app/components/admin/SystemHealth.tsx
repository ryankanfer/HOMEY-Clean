'use client';

import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { Database, Wifi, Zap, CheckCircle, AlertCircle, Clock } from 'lucide-react';

interface HealthMetric {
  label: string;
  status: 'healthy' | 'warning' | 'error';
  value: string;
  icon: any;
}

export default function SystemHealth() {
  // TODO: Fetch actual system health metrics from monitoring service
  const [metrics, setMetrics] = useState<HealthMetric[]>([]);

  const getStatusColor = (status: HealthMetric['status']) => {
    switch (status) {
      case 'healthy':
        return 'text-green-400';
      case 'warning':
        return 'text-yellow-400';
      case 'error':
        return 'text-red-400';
    }
  };

  const getStatusIcon = (status: HealthMetric['status']) => {
    switch (status) {
      case 'healthy':
        return CheckCircle;
      case 'warning':
        return Clock;
      case 'error':
        return AlertCircle;
    }
  };

  const allHealthy = metrics.every(m => m.status === 'healthy');

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className="glass-strong rounded-xl border border-white/10 p-4"
    >
      <div className="flex items-center justify-between mb-3">
        <h3 className="text-sm font-semibold text-white">System Health</h3>
        <div className="flex items-center gap-2">
          {allHealthy ? (
            <>
              <div className="w-2 h-2 bg-green-400 rounded-full animate-pulse" />
              <span className="text-xs text-green-400">All Systems Operational</span>
            </>
          ) : (
            <>
              <div className="w-2 h-2 bg-yellow-400 rounded-full animate-pulse" />
              <span className="text-xs text-yellow-400">Issues Detected</span>
            </>
          )}
        </div>
      </div>

      <div className="grid grid-cols-3 gap-3">
        {metrics.map((metric, index) => {
          const Icon = metric.icon;
          const StatusIcon = getStatusIcon(metric.status);
          return (
            <motion.div
              key={metric.label}
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ delay: index * 0.05 }}
              className="p-3 bg-white/5 rounded-lg border border-white/5"
            >
              <div className="flex items-center justify-between mb-2">
                <Icon className="w-4 h-4 text-white/60" />
                <StatusIcon className={`w-3 h-3 ${getStatusColor(metric.status)}`} />
              </div>
              <div className="text-sm font-medium text-white mb-1">{metric.value}</div>
              <div className="text-xs text-white/60">{metric.label}</div>
            </motion.div>
          );
        })}
      </div>
    </motion.div>
  );
}
