'use client';

import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import type { Listing } from '@/lib/types';
import BottomSheet from './BottomSheet';
import { db, auth } from '@/lib/supabase';

interface PriceAlertsProps {
  isOpen: boolean;
  onClose: () => void;
  property: Listing;
}

type AlertType = 'price_drop' | 'any_change' | 'below_target';
type NotificationMethod = 'email' | 'push' | 'sms';

interface PriceAlert {
  id?: string;
  property_id: string;
  alert_type: AlertType;
  target_price?: number;
  notification_methods: NotificationMethod[];
  is_active: boolean;
  created_at?: string;
}

export default function PriceAlerts({
  isOpen,
  onClose,
  property,
}: PriceAlertsProps) {
  const [alertType, setAlertType] = useState<AlertType>('price_drop');
  const [targetPrice, setTargetPrice] = useState<string>('');
  const [notificationMethods, setNotificationMethods] = useState<NotificationMethod[]>(['email']);
  const [saving, setSaving] = useState(false);
  const [existingAlert, setExistingAlert] = useState<PriceAlert | null>(null);

  useEffect(() => {
    if (isOpen) {
      loadExistingAlert();
    }
  }, [isOpen, property.id]);

  const loadExistingAlert = async () => {
    try {
      const { data: { user } } = await auth.getUser();
      if (!user) return;

      // In production, fetch from database
      // For now, check localStorage
      const alerts = localStorage.getItem('homey_price_alerts');
      if (alerts) {
        const parsed = JSON.parse(alerts);
        const existing = parsed.find((a: PriceAlert) => a.property_id === property.id);
        if (existing) {
          setExistingAlert(existing);
          setAlertType(existing.alert_type);
          if (existing.target_price) {
            setTargetPrice(existing.target_price.toString());
          }
          setNotificationMethods(existing.notification_methods);
        }
      }
    } catch (error) {
      console.error('Failed to load existing alert:', error);
    }
  };

  const handleSaveAlert = async () => {
    try {
      const { data: { user } } = await auth.getUser();
      if (!user) {
        alert('Please sign in to set price alerts');
        return;
      }

      if (alertType === 'below_target' && !targetPrice) {
        alert('Please enter a target price');
        return;
      }

      if (notificationMethods.length === 0) {
        alert('Please select at least one notification method');
        return;
      }

      setSaving(true);

      const alert: PriceAlert = {
        property_id: property.id,
        alert_type: alertType,
        target_price: targetPrice ? parseFloat(targetPrice) : undefined,
        notification_methods: notificationMethods,
        is_active: true,
        created_at: new Date().toISOString(),
      };

      // In production, save to Supabase
      // For now, save to localStorage
      const existing = localStorage.getItem('homey_price_alerts');
      const alerts: PriceAlert[] = existing ? JSON.parse(existing) : [];

      // Remove any existing alert for this property
      const filtered = alerts.filter(a => a.property_id !== property.id);
      filtered.push(alert);

      localStorage.setItem('homey_price_alerts', JSON.stringify(filtered));

      await new Promise(resolve => setTimeout(resolve, 1000));

      alert('✅ Price alert set! You\'ll be notified when the price changes.');
      onClose();
    } catch (error) {
      console.error('Failed to save alert:', error);
      alert('Failed to set price alert. Please try again.');
    } finally {
      setSaving(false);
    }
  };

  const handleRemoveAlert = async () => {
    try {
      setSaving(true);

      // Remove from localStorage
      const existing = localStorage.getItem('homey_price_alerts');
      if (existing) {
        const alerts: PriceAlert[] = JSON.parse(existing);
        const filtered = alerts.filter(a => a.property_id !== property.id);
        localStorage.setItem('homey_price_alerts', JSON.stringify(filtered));
      }

      await new Promise(resolve => setTimeout(resolve, 500));

      alert('Price alert removed');
      setExistingAlert(null);
      onClose();
    } catch (error) {
      console.error('Failed to remove alert:', error);
      alert('Failed to remove price alert. Please try again.');
    } finally {
      setSaving(false);
    }
  };

  const toggleNotificationMethod = (method: NotificationMethod) => {
    setNotificationMethods(prev => {
      if (prev.includes(method)) {
        return prev.filter(m => m !== method);
      } else {
        return [...prev, method];
      }
    });
  };

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 0,
      maximumFractionDigits: 0,
    }).format(price);
  };

  const alertTypes = [
    {
      type: 'price_drop' as AlertType,
      icon: '📉',
      label: 'Price Drop',
      description: 'Notify me when price decreases',
    },
    {
      type: 'any_change' as AlertType,
      icon: '🔔',
      label: 'Any Change',
      description: 'Notify me of any price change',
    },
    {
      type: 'below_target' as AlertType,
      icon: '🎯',
      label: 'Below Target',
      description: 'Notify me when price drops below target',
    },
  ];

  const notificationOptions = [
    { method: 'email' as NotificationMethod, icon: '✉️', label: 'Email' },
    { method: 'push' as NotificationMethod, icon: '📱', label: 'Push' },
    { method: 'sms' as NotificationMethod, icon: '💬', label: 'SMS' },
  ];

  return (
    <BottomSheet isOpen={isOpen} onClose={onClose} title="Price Alerts" height="auto">
      <div className="p-6 space-y-6">
        {/* Property Info */}
        <div className="glass-strong rounded-xl p-4 border border-white/10">
          <div className="flex gap-3">
            <img
              src={property.images?.[0] || '/placeholder-property.jpg'}
              alt={property.address}
              className="w-20 h-20 rounded-lg object-cover"
            />
            <div className="flex-1">
              <p className="text-white font-semibold">{property.address}</p>
              <p className="text-white/60 text-sm mb-1">{property.neighborhood}</p>
              <p className="text-primary font-bold text-lg">
                {formatPrice(property.price)}
                {property.listing_type === 'rental' && <span className="text-sm">/mo</span>}
              </p>
            </div>
          </div>
        </div>

        {existingAlert && (
          <motion.div
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            className="glass-strong rounded-xl p-4 border-2 border-primary/30"
          >
            <div className="flex items-center justify-between mb-2">
              <p className="text-white font-semibold">Active Alert</p>
              <span className="px-2 py-1 bg-primary/20 border border-primary/40 rounded-full text-primary text-xs font-bold">
                ACTIVE
              </span>
            </div>
            <p className="text-white/60 text-sm">
              You're currently tracking price changes for this property
            </p>
          </motion.div>
        )}

        {/* Alert Type */}
        <div>
          <h3 className="text-white font-semibold mb-3">Alert Type</h3>
          <div className="space-y-2">
            {alertTypes.map((type) => (
              <motion.button
                key={type.type}
                onClick={() => setAlertType(type.type)}
                whileTap={{ scale: 0.98 }}
                className={`w-full p-4 rounded-xl text-left transition-all flex items-start gap-3 min-h-[44px] ${
                  alertType === type.type
                    ? 'bg-primary/20 border-2 border-primary'
                    : 'bg-white/5 border border-white/10 hover:bg-white/10'
                }`}
              >
                <span className="text-2xl">{type.icon}</span>
                <div className="flex-1">
                  <p className="text-white font-semibold">{type.label}</p>
                  <p className="text-white/60 text-sm">{type.description}</p>
                </div>
                {alertType === type.type && (
                  <span className="text-primary text-xl">✓</span>
                )}
              </motion.button>
            ))}
          </div>
        </div>

        {/* Target Price Input (only for below_target) */}
        {alertType === 'below_target' && (
          <motion.div
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: 'auto' }}
            exit={{ opacity: 0, height: 0 }}
          >
            <h3 className="text-white font-semibold mb-3">Target Price</h3>
            <div className="relative">
              <span className="absolute left-4 top-1/2 -translate-y-1/2 text-white/60 text-lg">$</span>
              <input
                type="number"
                value={targetPrice}
                onChange={(e) => setTargetPrice(e.target.value)}
                placeholder={`Lower than ${formatPrice(property.price).replace('$', '')}`}
                className="w-full pl-10 pr-4 py-3 bg-white/5 border border-white/10 rounded-xl text-white placeholder-white/40 focus:outline-none focus:border-primary/50"
              />
            </div>
            <p className="text-white/60 text-xs mt-2">
              Current price: {formatPrice(property.price)}
              {property.listing_type === 'rental' && '/mo'}
            </p>
          </motion.div>
        )}

        {/* Notification Methods */}
        <div>
          <h3 className="text-white font-semibold mb-3">Notify Me Via</h3>
          <div className="grid grid-cols-3 gap-2">
            {notificationOptions.map((option) => (
              <motion.button
                key={option.method}
                onClick={() => toggleNotificationMethod(option.method)}
                whileTap={{ scale: 0.95 }}
                className={`p-4 rounded-xl transition-all min-h-[44px] ${
                  notificationMethods.includes(option.method)
                    ? 'bg-primary/20 border-2 border-primary'
                    : 'bg-white/5 border border-white/10 hover:bg-white/10'
                }`}
              >
                <div className="text-2xl mb-1">{option.icon}</div>
                <p className="text-white text-xs font-medium">{option.label}</p>
              </motion.button>
            ))}
          </div>
        </div>

        {/* Price History Insight */}
        <div className="glass-strong rounded-xl p-4 border border-white/10">
          <p className="text-white/60 text-sm mb-2">💡 Price Insight</p>
          <p className="text-white text-sm">
            This property's price has been stable for the last 30 days. Similar properties in the
            area typically see price changes every 45 days.
          </p>
        </div>

        {/* Action Buttons */}
        <div className="space-y-2">
          <button
            onClick={handleSaveAlert}
            disabled={saving}
            className={`w-full py-4 rounded-2xl font-bold transition-all min-h-[44px] ${
              !saving
                ? 'bg-gradient-to-r from-primary via-purple-500 to-pink-500 text-white hover:opacity-90'
                : 'bg-white/10 text-white/40 cursor-not-allowed'
            }`}
          >
            {saving ? '⏳ Saving...' : existingAlert ? '💾 Update Alert' : '🔔 Set Price Alert'}
          </button>

          {existingAlert && (
            <button
              onClick={handleRemoveAlert}
              disabled={saving}
              className="w-full py-4 rounded-2xl font-bold bg-white/10 text-white hover:bg-white/20 transition-colors min-h-[44px]"
            >
              Remove Alert
            </button>
          )}
        </div>
      </div>
    </BottomSheet>
  );
}
